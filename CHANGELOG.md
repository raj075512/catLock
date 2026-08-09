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
