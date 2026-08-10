# catLock — Testing Plan

**Last updated:** 10 August 2026
**Current state:** 239 lines of tests across 12 files, several still Xcode templates. CI runs them on every PR into `dev`.

---

## 1. Honest assessment of what you have

| File | Lines | Reality |
|---|---|---|
| `goCatTests/FocusTimerServiceTests.swift` | 15 | One test: reset restores duration. Does not test the countdown at all. |
| `goCatTests/FocusSessionViewModelTests.swift` | 13 | Minimal |
| `goCatTests/HomeViewModelTests.swift` | 32 | The most substantial file here |
| `goCatTests/AudioPlayerServiceTests.swift` | 14 | Tests that a Bool flips. The service plays no audio, so this test passes and proves nothing. |
| `goCatTests/PersistenceTests.swift` | 10 | Persistence isn't wired up, so there is nothing real to test |
| `goCatTests/goCatTests.swift` | 37 | Template |
| `goCatUITests/*.swift` (6 files) | 118 | Four are 10-line stubs; two are Xcode templates |

**The verdict:** the test suite exists as scaffolding, not as a safety net. It would not have caught a single one of the six bugs listed in `PLAN.md` §1. `AudioPlayerServiceTests` is actively misleading — it's green while the feature is silent.

This is normal for this stage and not worth being precious about. What matters is fixing it *before* the app gets complicated enough that manual testing stops working.

---

## 2. What to actually test

Testing everything is a waste of time on a solo project. Test the things that are (a) pure logic, (b) easy to get wrong, and (c) catastrophic when wrong.

### Tier 1 — Write these first. They map 1:1 to known bugs.

**Timer math** (`FocusTimerService`) — the highest-value tests in the project:
- A 25-minute session started at T reports the correct remaining time at T+60s
- **Backgrounding for 10 minutes must consume 10 minutes of the session** ← this is bug #3 in `PLAN.md`, and it is the test that forces the end-date fix
- Reaching zero fires `onComplete` exactly once
- `cancel()` stops ticking and no further completion fires
- Cancel at 00:01 does not race into a completion
- Custom durations at both bounds: 5 minutes and 120 minutes

**Streak logic** (`StreakStore`) — currently wrong, so write the tests that define correct:
- Two sessions on the same calendar day = streak of 1, not 2
- A session yesterday and one today = 2
- A gap day resets to 1
- Crossing midnight mid-session counts once
- Timezone change does not double-count or wipe the streak
- Completion increments; **cancellation must not**

**Persistence** (once one stack is chosen):
- A saved session survives relaunch
- Tasks survive relaunch
- An interrupted session restores with the correct remaining time
- Corrupt or missing stored data degrades gracefully instead of crashing

**Duration selection** (`HomeViewModel`) — partly covered already:
- Custom selection updates both `customMinutes` and `selectedMinutes`
- `customChipTitle` formats 45 / 60 / 80 / 120 correctly ("45 min", "1h", "1h 20m", "2h")
- The 2-hour cap cannot be exceeded through any path

### Tier 2 — Add during Phase 2

- Audio: correct file loads per `SoundOption`, looping, respects the silent switch, survives an interruption (phone call), stops when a session ends
- Stats: computed from real persisted sessions rather than samples; empty state when there is no history
- Notifications: scheduled on session start, cancelled on cancel, not scheduled when permission is denied

### Tier 3 — Before the first paid build

- Purchase success, cancellation, failure, restore
- Entitlement is honoured after relaunch and after reinstall
- Premium gating actually gates (a free user cannot reach a Plus sound by any route)

### What not to unit-test

SwiftUI view bodies, the design tokens, the Lottie and video wrappers (third-party behaviour — verify by eye), and anything whose test would just restate the implementation.

---

## 3. UI tests

Keep these few and load-bearing. UI tests are slow and brittle; four good ones beat twenty flaky ones.

1. **First run → first completed session.** Onboarding through to a session finishing (use a 5-second debug duration). This is your activation path; if it breaks, nothing else matters.
2. **Cancel flow.** Start → Cancel → trash animation appears → streak did not change.
3. **Custom duration.** Open the dial, choose 1h 20m, confirm the chip reads "1h 20m" and the session starts at 1:20:00.
4. **Sheets dismiss.** Room, Sounds, Tasks, Progress, Settings each open and close via their Done button. (You added these buttons after discovering none existed — worth locking down.)

Accessibility, run once per release rather than per PR:
- VoiceOver reaches every control on Home and in a session
- Dynamic Type at the largest accessibility size doesn't clip Home or onboarding
- Reduce Motion shows the poster instead of the video
- Contrast passes 4.5:1 for the countdown against the video — **the red `AppColors.danger` on a bright video frame is the likeliest failure here**

---

## 4. Manual test matrix

Some things cannot be automated. Run this before every TestFlight build.

**Devices** — minimum viable coverage:
- One small screen (iPhone SE / 13 mini) — the four-chip duration row is tightest here
- One current standard (iPhone 16/17)
- One Pro Max — check the video's `resizeAspectFill` cropping
- One iPad if iPad is supported — **decide this explicitly; `TARGETED_DEVICE_FAMILY` currently allows it and the full-bleed layout was never designed for it**

**Scenarios that break focus timers specifically:**
- [ ] Start a session, lock the phone, wait 5 real minutes, unlock → **is the remaining time correct?**
- [ ] Start a session, switch apps for 10 minutes, return → same question
- [ ] Start a session, force-quit the app, reopen → what happens? (Today: session silently lost)
- [ ] Incoming call during a session
- [ ] Low Power Mode
- [ ] Silent switch on with ambient sound playing
- [ ] Airplane mode (nothing should break — the app is fully local)
- [ ] Fill the device storage, then try to save a session
- [ ] Change the system timezone mid-session, and change the date across a day boundary — this is how streak bugs surface
- [ ] Let the battery die mid-session, recharge, reopen

**Sanity checks:**
- [ ] The app never says "GoCat" anywhere a user can see (see `ONBOARDING.md`)
- [ ] Video plays once on Home, loops in a session, and the transition between them has no visible cut
- [ ] Trophy and trash animations play to completion and dismiss cleanly
- [ ] Streak on Home matches the streak on the Progress screen

---

## 5. CI

`.github/workflows/pr-checks.yml` already does the two things that matter: a dry-run merge check against `dev`, and `xcodebuild test` on an iOS 16 simulator. Keep it.

Worth adding when you get to Phase 3:
- Cache SPM dependencies (Lottie is currently re-resolved every run)
- Run `xcodebuild build` for Release, not just Debug — Release-only optimizer failures are a classic late surprise
- Upload the `.xcresult` bundle as an artifact so failures are diagnosable without a local repro

Not worth it yet: code coverage gates, snapshot testing infrastructure, multi-simulator matrices.

---

## 6. Beta plan (TestFlight)

**Timing:** end of Phase 3, per `PLAN.md` — target mid-September 2026. Ship to beta only once no visible feature is hollow. Testers who find that ambient sound is silent will report *that* and nothing else, and you'll waste the round.

**Internal (up to 100 testers, no review):** you and 2–3 people. One full week of daily real use. The goal is finding things a test suite structurally cannot — does a 25-minute session actually *feel* right, is the cat charming or annoying by day four.

**External (up to 10,000, requires beta review):** the blueprint says 10–30, which is right. Recruit from r/ADHD, r/productivity, r/GetStudying, and any focus-app Discord. Ask three questions and no more:
1. Did you complete a session on the first day?
2. What made you close the app?
3. Would you notice if it disappeared tomorrow?

**Instrument before you invite.** Crash reporting (Crashlytics or Sentry) must be in the first beta build — a crash you can't see is a wasted tester. This is the one blueprint tech-stack item worth pulling forward.

**Two rounds minimum.** Build 1 → collect a week → fix → build 2 → confirm. A single beta round mostly measures whether the app launches.

---

## 7. Pre-submission checklist

From the blueprint's Launch Checklist, filtered to what applies to a no-account, no-backend v1:

- [ ] No crashes across the device matrix
- [ ] Timer is accurate after backgrounding — **this is the one App Review might actually catch**
- [ ] Every screen has a way out
- [ ] App icon at all sizes; launch screen
- [ ] Screenshots for every required iPhone size
- [ ] Privacy Policy URL live and reachable
- [ ] Support URL live and reachable
- [ ] App Store privacy questionnaire answered truthfully (currently: no data collected — keep it that way as long as you can, it's a genuine selling point for this audience)
- [ ] Age rating questionnaire
- [ ] Keywords: ADHD, focus, pomodoro, study timer, productivity, cat, habit
- [ ] Account deletion — **N/A while there are no accounts.** Becomes mandatory the day auth ships.
- [ ] If paid: full sandbox purchase matrix (see `MONETIZATION.md` §7)
- [ ] Release build tested on a real device, not just the simulator

---

## 8. Immediate next steps

1. Delete `AudioPlayerServiceTests.swift` — a green test for a feature that does nothing is worse than no test
2. Write the backgrounding test for `FocusTimerService`; watch it fail; fix the timer
3. Write the streak day-boundary tests; watch them fail; fix the streak
4. Delete the remaining Xcode template test files
5. Add the four UI tests from §3
6. Run the manual matrix in §4 once, right now, and write down what breaks — that list is more valuable than anything in this document
