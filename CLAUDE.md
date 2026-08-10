# CLAUDE.md

Context for Claude working in this repository. Read this first, every session.

---

## What this is

**catLock** (internal name `goCat`) — an iOS focus timer with a cat companion, aimed at an ADHD-friendly audience. SwiftUI, MVVM, iOS-only, local-first, no backend.

Owner: Ashu (raj075512@gmail.com), operating from India, publishing worldwide.

**⚠️ The name is disputed.** A live App Store app called "Cat Lock — Screen Time Control" already exists in the same category. See `legal/IP_CLEARANCE.md` — a rename is recommended and unresolved. Don't invest effort in name-dependent assets (icon, marketing copy, domain) until it's decided.

---

## Current state — read this before believing any other doc

**The app looks more finished than it is.** Six features are visible in the UI but have no implementation behind them. Do not assume a feature works because a view exists for it.

| Feature | Reality |
|---|---|
| Ambient sound | **Plays no audio.** `AudioPlayerService` flips a Bool. No `AVAudioPlayer`, `Resources/Audio/` is empty. |
| Tasks | In-memory array with two placeholders. Nothing persists across launch. |
| Progress / stats | Hardcoded fake session + `ProgressSummary.sample`. |
| Room | `RoomViewModel` is two hardcoded strings; `RoomView` is unreachable from the UI. |
| Premium / StoreKit | Product loading only. No purchase, restore, or entitlement. Called from nowhere. |
| Notifications | `LocalNotificationService` is **never called.** Permission is requested in onboarding and never used. |

**Known bugs, all unfixed:**

1. **Timer drifts.** `FocusTimerService` decrements a counter in a `Task`; iOS suspends it when backgrounded, so a 25-min session can take an hour of wall clock. Needs to be end-date based.
2. **Streak is not a streak.** `StreakStore` counts completed sessions with no day boundaries. Three sessions today displays "3 day streak".
3. **`IPHONEOS_DEPLOYMENT_TARGET = 26.5`** — ships to only the newest iOS. Almost certainly wrong.
4. **Bundle ID `ashutosh.goCat`** — not reverse-DNS. Must change before an App Store Connect record exists.
5. **Onboarding says "GoCat"** to the user, not catLock.
6. **`README.md` is stale** — advertises pause/resume (removed), working sounds, and premium IAP.

Dead scaffolding, safe to delete when touched: `TimerPersistenceService` + `SessionStore` (written, never called), `CatAnimationController`, `RiveAnimationService`, `AnimationInput`, `AppRouter`, `TabItem`, `NavigationDestination`, `Item.swift`, `RoomView`.

Persistence is in a half-state: a SwiftData container whose schema holds only the template `Item`, plus an unused Core Data model. **Pick SwiftData, delete the other.**

Full analysis and roadmap: **`PLAN.md`**.

---

## Product rules — do not violate without being asked

These are deliberate decisions, not oversights. If a change would break one, say so before doing it.

- **No pause.** A started session runs to completion or is explicitly cancelled. `pause()` was removed on purpose.
- **No back or close button during a session.** The only control is Cancel. This is the "lock yourself in with your cat" premise.
- **Cancel discards the session.** Trash animation, streak unchanged. Completion gets the trophy and streak +1.
- **No cat or chair customization, ever.** One fixed companion. Room background and sound are the only customization.
- **No tab bar.** `HomeView` is the whole app; everything else is a sheet or lives in the overflow menu.
- **Cat video plays `.once` on Home, `.looping` during a session.** Motion means "a session is running".
- **Collects zero user data as built.** No analytics, no accounts, no network calls. This is a feature — see `legal/PRIVACY_POLICY.md`. Optional accounts are *designed* (`design/WIREFRAME_PROMPT.md` §8) but not implemented; if they ever are, the account must stay optional, and in-app account deletion becomes mandatory. See `DECISIONS.md` 2026-08-10.

---

## Code conventions

**Design tokens are mandatory.** Never hardcode a color, font, spacing value, corner radius, or animation curve in feature code. Everything comes from `Core/DesignSystem/` (`AppColors`, `AppFonts`, `AppSpacing`, `AppCornerRadius`, `AppAnimation`). If a token doesn't exist, add it there — don't inline a value. `DESIGN.md` is the reference and must be updated in the same commit as any visual change.

**Architecture:** MVVM. `@MainActor @Observable final class` view models. `async/await` over Combine. Features are self-contained under `Features/<Name>/{Views,ViewModels,Sheets}`.

**Comments explain *why*, not *what*.** The existing code does this consistently — match it. A comment restating the line below it is noise; a comment explaining why pause was removed is the reason the next person doesn't re-add it.

**Xcode project format:** `objectVersion 77`, using `PBXFileSystemSynchronizedRootGroup`. Files dropped into `goCat/` are picked up automatically — **do not hand-edit `project.pbxproj` to add source files.** The one exception is Swift Package dependencies, which do require manual pbxproj edits (`XCRemoteSwiftPackageReference`, `XCSwiftPackageProductDependency`, a `PBXBuildFile` with `productRef`, and an entry in the target's `packageProductDependencies`). Lottie was added this way; follow the same ID convention and verify brace/paren balance afterwards.

**Dependencies:** only `airbnb/lottie-spm` (4.6.1, MIT). Adding another needs a good reason — this app's simplicity is the point.

---

## Workflow

- **Branch:** work happens on `feature/catlock-app-setup`. `main` and `dev` change only via PR.
- **CI:** `.github/workflows/pr-checks.yml` runs a merge-conflict check plus `xcodebuild test` on PRs into `dev`.
- **Commits:** conventional prefixes (`feat:`, `fix:`, `docs:`, `chore:`) with a body explaining what and *why*. Look at recent history for the house style — bullet points, one thought per line.
- **Pushing:** the Cowork/desktop sandbox **cannot reach github.com** (`403 from proxy`). It commits; `scripts/autopush.sh` on the user's Mac pushes. The terminal CLI can push directly.
- **Never** force-push, never commit secrets, never commit to `main` or `dev` directly.

---

## Verifying your work

**If you have no Swift toolchain** (the desktop/Cowork sandbox does not — it's Linux, no `xcodebuild`, no `swiftc`), you cannot compile. Say so plainly rather than implying a build passed. Static checks that are still worth doing: brace/paren balance per file, grep for references to symbols you deleted, and confirming any new file is under `goCat/` so the synchronized group picks it up.

**If you can run `xcodebuild`**, use it. Build for an iOS **Simulator** destination, not "My Mac" — running on My Mac triggers an unrelated dyld crash (`ABPeoplePickerView` missing from the iOSSupport runtime) that looks like an app bug and isn't.

Tests live in `goCatTests` and `goCatUITests` but currently prove very little (239 lines, several still Xcode templates). `TESTING.md` says what to write and in what order. `AudioPlayerServiceTests` is green for a feature that plays nothing — delete it rather than trusting it.

---

## Document map

| File | What it holds |
|---|---|
| `PLAN.md` | Honest state of the app, gap analysis, phased roadmap, verdict |
| `DESIGN.md` | Design tokens, components, information architecture, scope, security |
| `DECISIONS.md` | Why things are the way they are, dated |
| `ONBOARDING.md` | First-run flow, permission timing, activation metric |
| `TESTING.md` | Test strategy, device matrix, beta plan, submission checklist |
| `MONETIZATION.md` | Subscription strategy, pricing, paywall placement, why not ads |
| `legal/TERMS_OF_USE.md` | Terms draft — placeholders unfilled, needs an advocate |
| `legal/PRIVACY_POLICY.md` | Full data inventory; v1.0 declares "Data Not Collected" |
| `legal/COMPLIANCE.md` | Trial reminders, auto-renewal disclosure, billing rules, cancellation |
| `legal/IP_CLEARANCE.md` | Name conflict, asset provenance, clearance checklist |
| `README.md` | ⚠️ stale, needs rewriting |
| `CHANGELOG.md` | Release history |

**Keep these in sync.** If you change behaviour, update the doc that describes it in the same commit. Docs describing features that don't exist is the exact failure this project already had once.

---

## How to be useful here

- **Audit before you assume.** The docs have been wrong before. Read the code.
- **Say when something doesn't work.** The user has explicitly asked for honest accounting over reassurance, more than once. "I could not verify this" is a valid and valued answer.
- **Prefer deleting to adding.** The user's consistent instruction has been to reduce complexity. Orphaned files are a recurring problem here.
- **Don't gold-plate.** Small, correct, verifiable changes. The known bug list is long enough without new abstractions.
