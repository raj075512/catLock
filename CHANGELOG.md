# Changelog

All notable changes to **catLock** (`goCat`) are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

> **Versioning:** `MAJOR.MINOR.PATCH`
> - **MAJOR** — incompatible / breaking changes
> - **MINOR** — new functionality, backwards-compatible
> - **PATCH** — backwards-compatible bug fixes

---

## [Unreleased]

Work integrated on `dev`, not yet released to `main`.

### Added
- **Wireframe screens 1–29 implemented** from `catLock Wireframes.dc.html` — baseline onboarding (splash, welcome, five-question survey, personalised summary, "How it works", first session), Home in all three states, the custom-duration ring sheet, the session and its cancelled/complete/first-ever end states, the Sounds, Room, Tasks and Add-task sheets, and Progress, Settings, About and Accessibility.
- **Real session history.** SwiftData `CompletedSession` records every completed session; Progress computes today's totals, the weekly chart and the recent list from it. Cancelled sessions are never written.
- **Tasks persist.** SwiftData `TaskItem` replaces the in-memory placeholder array. Completed rows stay struck through until local midnight, then clear.
- **Rooms.** Six selectable rooms replacing `SceneOption`; selection persists and swaps Home's video live.
- **Accessibility settings that do something** — Reduce motion, Haptics and a new "Higher contrast panels" toggle that makes every glass panel fully opaque.
- **Force-quit safety.** A running session's end date is persisted, so relaunching resumes it or shows the completion it earned while away.
- Design tokens for the full spec: hairline, disabled, grabber, scrim, the three glass fill opacities, strip/panel radii, the monospaced countdown and 44pt display faces.
- `ProportionalHStack`, a small `Layout` that gives Home's custom chip its 1.3×/1.9× share of the duration row.
- Unit tests for the timer, streak, persistence and onboarding flow, plus UI tests that walk onboarding and assert the product rules (no pause, no back, cancel without a dialog).

### Fixed
- **Timer drift.** `FocusTimerService` derived time by decrementing a counter once per `Task.sleep(1s)`; iOS suspends backgrounded tasks, so a 25-minute session could take an hour of wall clock. It now always computes `endDate - now`.
- **The streak counted sessions, not days.** Three sessions in one afternoon displayed "3 day streak". `StreakState` now tracks `{ current, best, lastCompletedDay }` and increments once per local day. Existing counters are migrated rather than reset.
- **Deployment target.** `IPHONEOS_DEPLOYMENT_TARGET` 26.5 → 17.0; the app would not install on anything but the newest iOS.
- **Onboarding could not start its first session** — completing onboarding swapped the root view over to Home, tearing down the cover that was presenting the session. Home now owns that presentation.
- Haptics now respect the Accessibility toggle instead of firing unconditionally.

### Changed
- **Persistence settled on SwiftData.** The unused Core Data model, its entity mappings and `PersistenceController` are deleted.
- `UserPreferences` restructured to the handoff's state model. Silence is now `selectedSoundID == nil` rather than a separate `soundEnabled` flag, which is what the Sounds sheet needs — tapping the selected row deselects it.
- `AppState` is the single owner of user choices, so sheets and covers no longer depend on an optional environment injection.
- `README.md` rewritten; it advertised pause/resume, working premium IAP and a Core Data layer, none of which are real.

### Removed
- Dead scaffolding: `AppRouter`, `TabItem`, `NavigationDestination`, `Item.swift`, `ContentView`, `SessionStore`, `TimerPersistenceService`, `CatAnimationController`, `RiveAnimationService`, `AnimationInput`, `LiveSceneView`, `MockData`, and the four placebo UI tests that only asserted `app.exists`.

### Added (earlier)
- **Default session companion video**: `SessionVideoPlayerView` plays a looping, muted, pre-rendered video of the cat resting in its rocking chair (`Resources/Media/session_cat_loop.mp4`) during a focus session, with a static poster fallback (`session_cat_poster.jpg`) for Home and for Reduce Motion.
- **Security baseline**: `AppSecurityManager` (advisory jailbreak/debugger checks at launch) and `KeychainStore` (secure storage for future secrets/tokens/entitlements), wired into `AppDelegate`.
- **MVP scope documentation**: `DESIGN.md` now documents in-scope vs. deferred features distilled from the full product blueprint, plus a Security section.

### Changed
- **Home customization reduced to Room + Sound**: removed cat/chair character customization entirely; `CustomizationSheet.Kind` is now `.room` / `.sound` only. The companion is a fixed default, not user-selectable.
- `LiveSceneView` now shows a static room preview (poster image) instead of a live cat/chair renderer.

### Removed
- `CatOption`, `ChairOption`, `CatSelectionView`, `ChairSelectionView`, `CatRiveView`, and their fields on `HomeViewModel`/`UserPreferences` — unused now that the companion is fixed rather than customizable.

### Fixed
- _Nothing yet._

---

## [0.1.0] - 2026-08-08

Initial project foundation — the first tracked milestone.

### Added
- **App foundation**: entry point (`GoCatApp`), `AppState`, `AppRouter`, `RootView`, and app delegate.
- **Design system**: colors, fonts, spacing, corner radius, and animation tokens.
- **Reusable components**: buttons, cards, empty/error/loading states, badges, icon buttons.
- **Feature modules (MVVM)**:
  - Onboarding (welcome, focus goal, notification permission)
  - Home (customization sheets for cat / chair / scene / sound, live scene, header)
  - Focus Session (timer, controls, pause, scene, completion)
  - Tasks (list, add, row)
  - Progress (weekly summary, focus history, streaks)
  - Room (purchased items)
  - Settings (about, sound, accessibility)
  - Launch
- **Services**: Rive animation, audio (ambient sound, player, session manager), local notifications, StoreKit purchases, focus timer + persistence.
- **Persistence**: Core Data model with entity mappings.
- **Models**: focus session/state/task, cat/chair/scene/sound options, progress summary, user preferences.
- **Tests**: unit tests (Swift Testing) and UI tests (XCUIAutomation) scaffolding.
- **Repository setup**: `.gitignore`, `README.md`, `CHANGELOG.md`, and git-flow branch structure (`main` / `dev` / `feature/*`).

---

## Release Stages

| Stage | Version range | Branch | Description |
|-------|---------------|--------|-------------|
| **Foundation** | `0.1.x` | `dev` → `main` | Project scaffold, architecture, and core modules |
| **Alpha** | `0.2.x` – `0.9.x` | `dev` | Feature completion & internal testing |
| **Beta** | `0.9.x` | `dev` | Feature-frozen, stabilization & bug fixing |
| **Release** | `1.0.0+` | `main` | Public App Store release |

<!--
Link references — update the compare URLs as versions are tagged.
-->
[Unreleased]: https://github.com/raj075512/catLock/compare/0.1.0...HEAD
[0.1.0]: https://github.com/raj075512/catLock/releases/tag/0.1.0
