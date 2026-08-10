# catLock — Project Plan & State of the App

**Last updated:** 10 August 2026
**Branch audited:** `feature/catlock-app-setup` @ `1b435a8`
**Source of truth for scope:** this file + `DESIGN.md`. The original `GoCat_ADHD_Focus_App_Development_Plan.xlsm` is now a *reference blueprint*, not a commitment — see "Reconciling the Excel plan" below.

---

## 0. The short answer

**Are you on the right track? Yes for the product, no for the plan.**

The part that is hardest to get right — the core loop and how the app *feels* — is genuinely good and mostly done. Landing screen, duration selection, countdown, cancel/complete outcomes, the cat, the design-token system. That is real work and it is the right work.

The part that is off is the accounting. **The app currently claims more than it does.** Several features are visible in the UI, described in `README.md`, and listed as "in scope" in `DESIGN.md`, but have no implementation behind them. Ambient sound plays no audio. Tasks vanish on relaunch. Progress shows a hardcoded fake session. The streak is not a streak. None of these are hard to fix, but right now you cannot ship, and you would not know that from reading the docs.

The Excel's 30-day timeline ends **26 August 2026 — sixteen days from now.** That date is not reachable and should be formally abandoned rather than quietly missed. A realistic first TestFlight is 4–6 weeks out; App Store submission 8–10 weeks. Details in §5.

---

## 1. Where you actually are

Audited by reading every file in `goCat/`, not by reading the docs. Line counts are a rough honesty check — a 13-line "service" is a stub.

### ✅ Built and working

| Area | Evidence | Notes |
|---|---|---|
| Design system | `Core/DesignSystem/` — colors, fonts, spacing, radii, animation | Genuinely good. Tokens are respected throughout feature code. |
| Landing screen | `HomeView` + `GlassSurface`/`DurationChip`/`QuickActionPill` | Matches the target mockup. Full-bleed scene, glass panel, overflow menu. |
| Duration selection | `HomeViewModel`, `CustomDurationPickerView` | 15/25/45 + Custom dial, capped at 2h. |
| Countdown | `FocusTimerService` (80 lines) | Ticks, completes, cancels. **But see bug #3 — it drifts.** |
| Session outcomes | `SessionCompletedView`, `SessionCancelledView`, `LottiePlaybackView` | Trophy / sad-trash Lottie, streak bump on completion. Not yet compile-verified by me. |
| Cat scene | `CatSceneVideo`, `CatSceneBackground` | `.once` on Home, `.looping` in session. Reduce Motion falls back to the poster. |
| Onboarding shell | `OnboardingView` + 3 pages | Welcome → focus goal → notification permission. Persists completion. |
| Settings screens | `SettingsView`, `AboutView`, `AccessibilitySettingsView` | Present and navigable. |
| Security baseline | `AppSecurityManager`, `KeychainStore` | Advisory jailbreak/debugger checks, Keychain wrapper. Nothing sensitive stored yet. |
| CI | `.github/workflows/pr-checks.yml` | Merge-conflict check + `xcodebuild test` on macOS 15 for PRs into `dev`. Better than most solo projects have. |

### ⚠️ Visible in the UI but hollow

These are the ones that matter. Each is reachable by a user and does nothing, or lies.

| Feature | What the user sees | What the code does | File |
|---|---|---|---|
| **Ambient sounds** | Sounds sheet, pick Rain / Purr / etc. | Sets `isPlaying = true` on a Bool. **No `AVAudioPlayer` anywhere. `Resources/Audio/` is an empty folder.** `AmbientSoundPlayer` is not referenced by any view. | `Services/Audio/AudioPlayerService.swift` (21 lines) |
| **Tasks** | Add/complete tasks | In-memory array seeded with two placeholder tasks. Nothing is saved. Relaunch = gone. | `Features/Tasks/ViewModels/TaskViewModel.swift` (26 lines) |
| **Progress / stats** | Weekly summary, history, streak | Hardcoded: one fabricated `FocusSession` and `ProgressSummary.sample`. The numbers are fiction. | `Features/Progress/ViewModels/ProgressViewModel.swift` (11 lines) |
| **Room** | "Room" quick action | Opens scene *background* selection only. `RoomViewModel` is a hardcoded array of two strings and `RoomView` is **unreachable from the UI** — dead code. | `Features/Room/` |
| **Premium** | `PremiumLockBadge` component exists | `StoreKitService` loads products and nothing else — no purchase, no restore, no entitlement. `PremiumAccessService` is a Bool nobody ever sets. Neither is called from anywhere. | `Services/Purchases/` (27 lines total) |
| **Notifications** | Permission requested in onboarding | `LocalNotificationService` is **never called by anything.** You ask for permission and then never send a notification. | `Services/Notifications/` |

### ❌ Written but wired to nothing

Dead scaffolding. Not harmful, but it inflates the apparent size of the project and will confuse you in three months.

- `TimerPersistenceService` + `SessionStore` — a complete timer-snapshot save/restore, called by nobody. Kill the app mid-session and the session is simply lost.
- `PersistenceController` — SwiftData container whose schema contains only `Item` (the stock Xcode template model). Meanwhile `Persistence/GoCatModel.xcdatamodeld` + two 7-line Core Data mapping files sit unused. **You have two half-built persistence stacks and neither stores a session.**
- `CatAnimationController`, `RiveAnimationService`, `AnimationInput` — from the pre-video approach.
- `AppRouter`, `TabItem`, `NavigationDestination` — from the pre-single-screen architecture.
- `Item.swift` — Xcode template leftover, still referenced by the live `ModelContainer`.

### 🐛 Bugs and decisions that will bite you

1. **The streak is not a streak.** `StreakStore.recordCompletedSession()` does `currentStreak + 1` per completed session. Three sessions today shows "3 day streak." There is no day boundary, no reset on a missed day, no timezone handling. The badge on your landing screen is currently mislabeled. *Fix before any user sees it — it's the one number on your home screen.*

2. **`IPHONEOS_DEPLOYMENT_TARGET = 26.5`.** You are shipping to only the newest iOS release. This may be the single most expensive line in the project — it removes most of the installed base from your addressable market on day one. Unless you are deliberately using an iOS 26-only API, drop this to iOS 17 or 18.

3. **The countdown drifts when backgrounded.** The timer decrements a counter once per second inside a `Task`. iOS suspends that task when the app leaves the foreground, so a 25-minute session can take an hour of wall-clock time. **The fix is architectural, not cosmetic:** store an end `Date` and compute `remaining = endDate - .now` on every tick and on foreground. Do this before TestFlight — beta testers will notice immediately, and for a focus app it's a credibility bug.

4. **Bundle ID is `ashutosh.goCat`.** Not reverse-DNS, and it is the internal name rather than the product name. Change it to something like `com.<yourdomain>.catlock` **before** you create the App Store Connect record — the bundle ID is permanent once a record exists.

5. **`README.md` is now fiction.** It advertises "pause/resume" (removed), "ambient sounds" (silent), and "Premium / StoreKit" (a stub). Harmless today; dangerous the moment any of it becomes App Store copy. `DESIGN.md` was refreshed on 10 Aug; `README.md` was not.

6. **Tests are nominal.** 239 lines across 12 files, several still the Xcode template. `FocusTimerServiceTests` has exactly one assertion pair. CI runs them, which is good, but it is currently proving very little. See `TESTING.md`.

---

## 2. Reconciling the Excel plan

The blueprint (`GoCat_ADHD_Focus_App_Development_Plan.xlsm`) describes a substantially bigger app than what is being built, and that is **intentional** — the reduction is recorded in `DESIGN.md`. What follows is where reality sits against each blueprint sheet.

### 30-Day Timeline — Day 1 to 30, 28 Jul → 26 Aug 2026

Today is **Day 14**. Actual position:

| Blueprint days | Planned | Status |
|---|---|---|
| 1–3 Strategy, wireframes, Xcode foundation | Product brief, screens, design tokens | ✅ Done |
| 4 Timer engine | focus/pause/resume/cancel/complete + persistence | ⚠️ Partial — pause deliberately removed; persistence not wired |
| 5 Cat companion | idle/success/failure states | ✅ Done (video + Lottie, better than planned) |
| 6 Task list | add/edit/complete/category/start-from-task | ⚠️ UI only, no persistence, no categories, no start-from-task |
| 7 Week-1 QA | timer edge cases, lock screen, first run | ❌ Not done — and this is where bug #3 would have surfaced |
| 8–9 Wallet, rewards, inventory | fish/coins/trash economy | ⛔ Deliberately deferred (DESIGN.md) |
| 10 Room customization | 6 furniture slots | ⛔ Deliberately reduced to background-only |
| 11 Ambient sounds | AVFoundation, background audio | ❌ **Not deferred — believed done, actually absent** |
| 12–14 Supabase, cloud sync, sync QA | backend | ⛔ Deliberately deferred |

You are roughly **half a timeline behind on paper**, but most of that gap is deliberate scope reduction, which is a good decision, not a failure. The genuine problem is Day 11 (sounds) and Day 7 (QA): one is a hole you didn't know about, the other is the reason you didn't know.

### Feature Backlog

Blueprint marks 11 features as MVP/High. Honest status: **3 done** (timer, cat, task UI), **1 reduced** (room), **1 hollow** (sounds), **6 not started** (rewards, stats, GoCat Plus, widgets, Apple login, analytics).

### Tech Stack

Blueprint recommends Supabase + RevenueCat + PostHog/Amplitude + Crashlytics. **None are integrated, and for the reduced MVP that is correct.** The only one I'd pull forward is crash reporting — see §5, Phase 3. Note the blueprint assumes SwiftData *or* Core Data; you currently have fragments of both and must pick one.

### Revenue Model, Budget, Analytics, Launch Checklist

Untouched, appropriately — these are Phase 4+ concerns. The blueprint's paywall-trigger analysis ("after 2 completed sessions", avoid first-launch) is good thinking and is carried forward into `MONETIZATION.md`. Budget estimate of $479–$2,249 (better: $1,500–$3,000) still looks sane; the Apple Developer Program at $99/yr is the only unavoidable line.

---

## 3. What to do next — the honest priority order

Ordered by "what stops you shipping," not by what's fun.

### Tier 0 — Correctness. Nothing else matters until these are done.
1. Fix the timer to be end-date based (bug #3).
2. Fix or relabel the streak (bug #1). Either implement day boundaries, or rename it "sessions" until you do.
3. Pick **one** persistence stack (SwiftData is the right call for a new iOS app) and actually save sessions and tasks. Delete the other. Delete `Item.swift`.
4. Drop the deployment target (bug #2) and fix the bundle ID (bug #4).

### Tier 1 — Make the visible features real.
5. Ambient sound: license 4–6 loops, add real `AVAudioPlayer` playback, configure the audio session for background/mixing, wire `AmbientSoundPlayer` into the Sounds sheet.
6. Progress: compute real stats from persisted sessions. Delete the fake sample data.
7. Tasks: persist them; add start-session-from-task (it's the feature that links your two halves together).
8. Wire `LocalNotificationService` to fire on session completion — you already have the permission.

### Tier 2 — Make it survivable.
9. Restore-on-relaunch for an interrupted session (`TimerPersistenceService` is already written — just call it).
10. Delete dead scaffolding: Rive, `CatAnimationController`, `AppRouter`/`TabItem`, unreachable `RoomView`.
11. Rewrite `README.md` to describe what exists.
12. Real tests around timer math, streak boundaries, and persistence — see `TESTING.md`.

### Tier 3 — Ship it.
13. Crash reporting, app icon, launch screen, App Store assets, privacy policy + support page, TestFlight.

### Tier 4 — Money.
14. StoreKit 2 subscription, paywall, entitlement gating. See `MONETIZATION.md`.

---

## 4. Documents you should keep

You asked what else to track. Five documents, each with one job. More than this and they go stale.

| File | Status | Purpose | Update when |
|---|---|---|---|
| `README.md` | ⚠️ **stale — rewrite** | What the app is, how to build it | Features ship |
| `DESIGN.md` | ✅ current | Design tokens, components, IA, scope, security posture | Any visual or scope change |
| `PLAN.md` (this) | ✅ new | State of the app, gaps, roadmap, verdict | Every 1–2 weeks, and after each phase |
| `TESTING.md` | ✅ new | What gets tested and how, device matrix, beta plan | Before each TestFlight build |
| `ONBOARDING.md` | ✅ new | First-run flow, permission timing, activation goal | Onboarding or permission changes |
| `MONETIZATION.md` | ✅ new | Subscription + ads strategy, pricing, paywall placement | Before touching StoreKit |
| `CHANGELOG.md` | ✅ exists | Release history | Every release |

**Two more worth adding when the time comes:**

- `DECISIONS.md` — a running log of *why*, one paragraph per entry, dated. You have already made several decisions that will look arbitrary later: no pause, no back button during a session, video instead of Rive, no character customization, `.once` playback on Home. Write them down now while the reasoning is fresh. This is the single highest-value doc you don't have.
- `PRIVACY.md` — required content for the App Store privacy questionnaire and your hosted policy. Needed at Phase 3, not before. Trivial while you collect no data; do not let that change silently.

Skip: separate ARCHITECTURE.md (DESIGN.md covers it at this size), CONTRIBUTING.md (solo project), API.md (no backend).

---

## 5. Revised timeline

Assumes solo, part-time. Adjust the multiplier to your actual hours; the *order* matters more than the dates.

| Phase | Work | Realistic window |
|---|---|---|
| **1. Correctness** | Tier 0 — timer, streak, persistence, deployment target, bundle ID | 1 week |
| **2. Real features** | Tier 1 — audio, stats, tasks, notifications | 1.5–2 weeks |
| **3. Ship-ready** | Tier 2 + 3 — cleanup, tests, icon, crash reporting, legal pages, **first TestFlight** | 1.5–2 weeks |
| **4. Beta** | 10–30 testers, fix what they find | 2 weeks |
| **5. Monetization** | StoreKit 2, paywall, entitlement gating, sandbox testing | 2 weeks |
| **6. Submission** | ASO, screenshots, metadata, review | 1 week + review time |

**First TestFlight: mid-September 2026. App Store submission: mid-to-late October 2026.**

That is 8–10 weeks past the blueprint's 26 August date. It is also achievable, which the original date is not.

One structural suggestion: **ship the free app first, add the subscription in v1.1.** Phase 5 is the only phase that can be moved after launch, it is the one most likely to fail App Review on a technicality, and you will price it better once you can see real retention data. The blueprint's "subscription-ready in 30 days" goal is the least valuable of its assumptions.

---

## 6. Verdict

Keep going. The instinct that produced "no pause, no back button, lock yourself with your cat" is a real product opinion, and it is the reason this could be more than another Pomodoro timer. The design system is disciplined. The CI setup is better than most solo projects ever get.

The thing to correct is not your direction, it's your bookkeeping: for a few weeks the docs have described intentions as if they were features, and you found out by asking rather than by testing. Fix the six hollow features, make the docs honest, and put a QA pass at the end of each phase — the blueprint had one on Day 7 and Day 14 for exactly this reason, and skipping them is what let the sound gap survive this long.

Nothing found in this audit is expensive to fix. It is roughly two weeks of work standing between you and an app that does everything it currently claims.
