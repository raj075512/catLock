# catLock — Design System & Guidelines

This document describes the visual and interaction design language for **catLock** (`goCat`), an ADHD-friendly focus timer app with a cozy cat companion. All values are sourced from the app's design-system code in `goCat/Core/DesignSystem/` and should be treated as the single source of truth. **Do not hardcode colors, fonts, spacing, or radii in feature code — always reference these tokens.**

This document also tracks the **product scope** (distilled from the full GoCat product blueprint) and the app's **security posture**. Keep all three in sync in the same PR whenever they change.

---

## 🎯 MVP Scope & Reductions

The full product blueprint covers a large surface: a reward economy (fish/coins/trash), a 6-slot room-furniture inventory, Supabase-backed cloud sync and auth, RevenueCat subscriptions with a paywall, WidgetKit, Apple Sign-In, product analytics, and crash reporting. Building all of it at once adds risk without adding value to the core loop, so the MVP is deliberately smaller. Anything not listed under "In scope" is **deferred, not cut** — it stays a documented Post-MVP target.

**In scope (this build)**
- Focus timer: start, cancel, complete (`Services/Timer/`, `Features/FocusSession/`). **Pause was deliberately removed** — a started session is a commitment, so the only way out is an explicit Cancel that discards it.
- A single, fixed cat companion shown as a video (`SessionVideoPlayerView`) — one run on Home, looping during a session. See "Signature Elements" below. No cat/chair customization.
- Room customization: background/scene only (`SceneSelectionView`).
- Sound customization: ambient loop selection (`SoundSelectionView`).
- Tasks: add, complete, start a session from a task (`Features/Tasks/`).
- Progress: basic local stats — streak, sessions, weekly view (`Features/Progress/`).
- Local-first persistence via Core Data/SwiftData + `UserDefaultsStore`. No backend.

**Explicitly deferred (Post-MVP)**
- Reward economy (fish/coins/trash wallet, unlockable inventory catalog) — `RoomViewModel` keeps a placeholder purchased-items list only.
- Supabase auth + cloud sync (the `Database Schema` in the product blueprint documents the target shape for when this lands).
- RevenueCat subscriptions/paywall — `StoreKitService` stays a thin StoreKit product-loading stub until this is prioritized.
- WidgetKit home-screen widget, Sign in with Apple.
- Product analytics (PostHog/Amplitude) and crash reporting (Crashlytics/Sentry).
- Multiple cat personalities/seasonal items, themed rooms.

Reintroducing any deferred item should start with a short addition to this section, not straight to code.

---

## 🎯 Design Principles

1. **Calm & cozy** — A warm, muted palette and soft rounded shapes create a relaxing focus environment.
2. **Focus-first** — The UI recedes so the cat, the room, and the timer stay center stage.
3. **Consistent tokens** — Every color, font, space, and radius comes from a named token; no magic numbers.
4. **Gentle motion** — Animations are short and eased; they guide, never distract.
5. **Accessible by default** — Dynamic Type, VoiceOver labels, and reduced-motion support are first-class.

---

## 🎨 Color Palette

Defined in `AppColors.swift`. Colors are built from hex via the `Color(hex:)` extension.

| Token | Hex | Swatch | Usage |
|-------|-----|--------|-------|
| `background` | `#F7F4EF` | 🟫 warm off-white | App/screen backgrounds |
| `surface` | `#FFFFFF` | ⬜ white | Cards, sheets, primary surfaces |
| `elevatedSurface` | `#F0EEE8` | 🟫 light sand | Secondary/elevated surfaces, wells |
| `primary` | `#2F6F73` | 🟦 deep teal | Primary actions, key accents, active states |
| `secondary` | `#D98C5F` | 🟧 warm terracotta | Secondary actions, highlights |
| `accent` | `#6E8B58` | 🟩 sage green | Success, positive accents, streaks |
| `textPrimary` | `#1E2525` | ⬛ near-black | Primary text |
| `textSecondary` | `#69706F` | ⬜ muted gray | Secondary/supporting text, captions |
| `warning` | `#B85C38` | 🟥 burnt orange | Sync/billing problems, non-destructive alerts |
| `danger` | `#D14343` | 🟥 clear red | Countdown text and Cancel **only**, plus destructive confirms |

### Derived tokens

| Token | Hex | Usage |
|-------|-----|-------|
| `hairline` | `#E2DED5` | Border on light surfaces, dividers between rows |
| `disabled` | `#C6C0B4` | Placeholder fills, chevrons, and the em dash in an empty stat card |
| `grabber` | `#D6D2C8` | Sheet grabber |
| `scrim` | `rgba(30,37,37,.28)` | Dims the video behind a presented sheet |
| `selectedRowTint` | `primary` at 8% | Selected option row, paired with a 1.5pt `primary` border |

### Glass (`AppGlass`)

Panels floating over the cat video. Depth comes from translucency and the scrim — **there are
no shadows anywhere in this design.**

| Token | Value | Usage |
|-------|-------|-------|
| `panelFill` | 0.72 | Home's control panel, end-state panels |
| `sessionStripFill` | 0.55 | The session strip — lower on purpose, so the cat stays the brightest thing on screen |
| `bannerFill` | 0.86 | Trial-ending banner (v1.1) |
| `innerChipFill` / `innerChipBorder` | 0.5 / 0.6 | Chips sitting *on* a glass panel |
| `borderOpacity` | 0.35 | 1pt white border on every glass surface |

**Higher contrast panels** (Accessibility) replaces all of the above with an opaque `surface`
and a `textSecondary` border. `GlassSurface` is the single place this is applied.

**Guidance**
- `accent` starts something (Get started, Start Focus, Start focusing).
- `primary` confirms or continues (Sounds good, Got it, Continue on completion).
- `textSecondary` for captions, hints, and metadata.
- `danger` is the countdown and Cancel, and nothing else.
- Reserve `warning` for non-destructive attention states.

---

## 🔤 Typography

Defined in `AppFonts.swift`. Headings use the **rounded** system design for a friendly tone; body copy uses the default system design for readability. All scale with Dynamic Type.

| Token | Size | Weight | Design | Usage |
|-------|------|--------|--------|-------|
| `largeTitle` | 34 | Bold | Rounded | Screen titles, hero text |
| `title` | 24 | Semibold | Rounded | Section titles, sheet headers |
| `headline` | 17 | Semibold | Rounded | Card titles, list headers, buttons |
| `body` | 16 | Regular | Default | Body copy, descriptions |
| `caption` | 13 | Medium | Default | Metadata, hints, timestamps |
| `countdown` | 32 | Bold | Rounded | Session countdown — monospaced digits, −1 tracking |
| `display` | 44 | Bold | Rounded | Custom-duration ring value, Progress streak number |

Large title carries −0.5 tracking (`Text.largeTitleTracking()`). **Never below 13.** Supported
to Accessibility XXXL.

---

## 📐 Spacing

Defined in `AppSpacing.swift`. A 4pt base scale. Use these for padding, margins, and stack spacing.

| Token | Value | Typical usage |
|-------|-------|---------------|
| `xSmall` | 4 | Tight gaps between related elements |
| `small` | 8 | Icon/label gaps, compact padding |
| `medium` | 16 | Default padding & stack spacing |
| `large` | 24 | Section separation, card padding |
| `xLarge` | 32 | Screen margins, major sections |

---

## 🔲 Corner Radius

Defined in `AppCornerRadius.swift`. Rounded corners reinforce the soft, cozy feel.

| Token | Value | Usage |
|-------|-------|-------|
| `small` | 6 | Chips, small controls, badges |
| `medium` | 8 | Buttons, input fields |
| `large` | 12 | Cards, list groups, option rows |
| `strip` | 26 | Session strip, banners |
| `panel` | 32 | Home control panel, end-state panels, sheet tops |
| `capsule` | 999 | **All buttons and chips are full capsules** |

---

## 🎬 Motion & Animation

Defined in `AppAnimation.swift`. Keep motion subtle and purposeful; respect Reduce Motion.

| Token | Curve | Duration | Usage |
|-------|-------|----------|-------|
| `quick` | easeOut | 0.18s | Taps, toggles, micro-interactions |
| `standard` | easeInOut | 0.28s | View transitions, sheet presentation |
| `slow` | easeInOut | 0.45s | Ambient/scene changes, emphasis |
| `entrance` | spring(0.55, 0.82) | — | Content arriving for the first time |
| `surveyAdvance` | easeOut | 0.18s | Survey row tints, then the flow moves on |
| `panelGrow` | easeOut | 0.3s | Session strip growing into an end-state panel, radius 26 → 32 |
| `streakCountUp` | easeOut | 0.4s | Streak pill counting 7 → 8 on completion |
| `finalMinuteSweep` | linear | 60s | The accent hairline crossing the strip — linear because it is a clock |

**Reduce Motion** (system setting OR the in-app toggle) swaps the video for a static poster,
makes the ring arc jump rather than sweep, and shows the final-minute hairline at full width at
00:30 instead of filling. The timer is always the source of truth about whether a session is
running — **motion is decoration, never information.**

### Layout constants (`AppLayout`)

Fixed positions that aren't spacing between two things: glass panels sit 16 from each side and
40 from the bottom; the minimum hit target is 44 everywhere; the overflow circle and survey back
chevron are 40.

---

## 🧩 Reusable Components

Located in `goCat/Core/Components/`. Prefer these over bespoke views so styling stays consistent.

| Component | Purpose |
|-----------|---------|
| `PrimaryButton` | Main call-to-action button (uses `primary`) |
| `IconButton` | Compact icon-only action |
| `SelectionCard` | Selectable tile for customization options (cat, chair, scene, sound) |
| `PremiumLockBadge` | Overlay marking premium-gated content |
| `LoadingView` | Standard loading/progress state |
| `EmptyStateView` | Standard empty-state messaging |
| `ErrorStateView` | Standard error presentation |
| `GlassSurface` / `GlassPill` | Frosted translucent panels that float over the cat scene |
| `DurationChip` | Selectable session-length chip (15 / 25 / 45 / Custom) |
| `LottiePlaybackView` (`Core/Components/`) | Plays a bundled `.lottie` once and reports completion; used for the trophy and trash outcomes |
| `QuickActionPill` | Secondary action in the Sounds / Room / Tasks row |
| `CatSceneBackground` (`Features/Home/Views/`) | Full-bleed cat scene shared by Home and the active session; takes a `playback` mode, and handles the Reduce Motion poster fallback and legibility scrim |
| `CatSceneVideo` (`Features/FocusSession/Views/`) | Muted playback of the companion clip in either `.looping` (session) or `.once` (Home) mode; pauses when backgrounded |

Shared modifiers live in `Core/Extensions/View+Modifiers.swift` and `View+Accessibility.swift`.

---

## 🗺️ Information Architecture

The app is **single-screen first**: there is no tab bar. `RootView` goes straight to `HomeView`, which is a full-bleed cat scene with every control floating on frosted glass above it. Everything else is presented from there as a sheet or from the overflow menu, so the artwork is never competing with chrome.

- **Home (landing)** — Full-bleed `CatSceneBackground` in `.once` playback. Top bar: streak pill (left) + `…` overflow (right). Bottom glass panel: duration chips (15 / 25 / 45 / **Custom**), **Start Focus**, and the **Sounds / Room / Tasks** shortcut row. Custom opens `CustomDurationPickerView` — a large progress dial over hour/minute wheels, hard-capped at 2 hours.
- **Focus Session** — Presented full-screen over Home. Keeps the *same* artwork, switched to `.looping`; only the glass panel swaps to the countdown. **No back button and no pause** — the single control is Cancel. A session either runs to zero (trophy animation, streak +1 via `StreakStore`) or is cancelled (trash animation, streak untouched). Both outcomes are one-shot Lottie playbacks through `LottiePlaybackView`.
- **Sounds / Room** — Sheets (`CustomizationSheet`, kinds `.sound` / `.room`). No character customization.
- **Tasks** — Sheet from the shortcut row.
- **Progress**, **Settings** — Sheets from the `…` overflow menu.

`AppRouter`/`TabItem` remain in the codebase but are unused by this flow; they're kept as scaffolding in case a tabbed structure returns.

First-run flow: **Launch → Onboarding** (welcome → focus goal → notification permission) → **Home**.

---

## 🐱 Signature Elements

- **The Cat** — A single, fixed companion: a cat resting in a rocking chair, delivered as a short (~10s) pre-rendered video (`Resources/Media/session_cat_loop.mp4`, played back by `CatSceneVideo` in `Features/FocusSession/Views/SessionVideoPlayerView.swift`). It is intentionally **not** customizable, keeping the session view simple, predictable, and cheap to render (no rig, no character-selection code path). `Resources/Media/session_cat_poster.jpg` is the static first-frame fallback used both as the Home room preview (`LiveSceneView`) and whenever Reduce Motion is on.
  - **Playback differs by screen, and that difference is the point.** Home passes `.once`: the clip runs a single time and holds on its final frame, so the scene greets the user and then settles while they choose a duration. An active session passes `.looping`: continuous rocking for as long as the timer runs. Motion signals "a session is happening"; stillness signals "you haven't started yet."
  - Mechanically, `.looping` is `AVQueuePlayer` + `AVPlayerLooper`; `.once` is a plain `AVPlayer` with `actionAtItemEnd = .pause` plus a `hasFinishedSingleRun` latch, so returning from the background doesn't hand out a second run. One run means one run per `HomeView` lifetime — coming back from a finished session leaves Home's frozen frame untouched, since the session is a `fullScreenCover` layered above it rather than a replacement.
  - The session screen builds its own player from frame 0 rather than inheriting Home's paused one. **This depends on the clip being authored as a seamless loop** (last frame meeting first frame) — otherwise the handover reads as a visible cut at the exact moment the user taps Start Focus. Any replacement clip must preserve that property.
  - A Rive-based rig remains a reasonable future upgrade if per-state reactions (idle/happy/sad from the product blueprint) are prioritized later — see `Services/Animation/RiveAnimationService.swift`, currently unused by the video-based flow but left in place as scaffolding.
- **The Room** — A customizable, illustrated background only (`LiveSceneView`, `SceneSelectionView`). Furniture-slot customization (chair, rug, lamp, plant, wall art) from the product blueprint is deferred — see MVP Scope.
- **Ambient Sound** — Optional background audio (`Services/Audio/`) paired with the room.

---

## ♿ Accessibility

- **Dynamic Type** — All typography uses system fonts that scale automatically.
- **VoiceOver** — Components apply labels/traits via `View+Accessibility.swift`; managed centrally by `AccessibilityManager`.
- **Reduce Motion** — Honor the system setting; fall back to fades/instant changes instead of the `slow`/`standard` animations.
- **Contrast** — `textPrimary` on `background`/`surface` meets contrast needs; avoid placing `textSecondary` on saturated colors.
- **Dedicated settings** — `Features/Settings/Views/AccessibilitySettingsView.swift` exposes user-facing accessibility options.

---

## 🔒 Security

Security hardening is on by default, not opt-in. Current baseline:

- **`Core/Security/AppSecurityManager.swift`** — runs at launch (`AppDelegate.application(_:didFinishLaunchingWithOptions:)`) and checks for a jailbroken/tampered environment and an attached debugger. This is **advisory, not a hard block**: it never prevents a legitimate user from using the app. It exists so future entitlement/purchase logic can treat on-device state as lower-trust on a flagged device (e.g. prefer server-side receipt validation once a backend exists) and so we have a signal in logs if something looks off.
- **`Core/Storage/KeychainStore.swift`** — the designated home for any secret, token, or entitlement cache. `UserDefaultsStore`/`SettingsStore` are unencrypted on disk and must stay limited to plain preferences (room, sound, durations) — never auth material or purchase receipts.
- **No hardcoded secrets** — there are none, because there is no backend. See "Backend seam" below. If one is adopted, publishable/anon keys must come from build configuration (`.xcconfig`, already gitignored) rather than source, secret keys (`service_role`, SMTP, App Store Connect) must never enter this repo in any form, and any long-lived token goes in `KeychainStore`.
- **App Transport Security** — the app makes no network calls at all, so leave ATS at its strict default (no arbitrary loads); do not add exceptions without a concrete, reviewed reason.

---

## 🔌 Backend seam

**There is no backend, and the app does not depend on one.** No account, no
network call, no vendor SDK — which is what lets `legal/PRIVACY_POLICY.md` keep
saying the app makes no network requests and collects no data.

The boundary exists anyway, because the expensive mistake is not "no backend
yet", it is letting a vendor's types leak into feature code. A `Supabase`
import in a view model or an `AWSCognito` type in `AppState` means switching
provider is a rewrite rather than a file.

| File | Role |
|---|---|
| `goCat/Services/Backend/BackendProvider.swift` | `IdentityProviding` + `SyncProviding`, and the plain value types that cross the boundary. No vendor types. |
| `goCat/Services/Backend/LocalOnlyBackend.swift` | The shipping default. Every operation is a no-op reporting `.unavailable` / `.notConfigured`. |
| `goCatTests/BackendSeamTests.swift` | Proves the default is inert and that a conforming provider substitutes cleanly. |

**To adopt AWS or Supabase later:** add one type conforming to `Backend`
(`IdentityProviding & SyncProviding`), and change the one line in
`BackendProvider.current`. Nothing in `Features/` changes — nothing there
imports a networking library, and that rule is what keeps the swap cheap in
both directions.

**Rules for any implementation:**

- The account stays optional. Timer, streak and tasks work fully signed out and
  offline (product rule 6).
- Sign out changes identity only. It never touches local data.
- `.expired` is not `.signedOut` — they say very different things to a user and
  only one of them is alarming.
- Errors surface as a plain sentence, never an error code and never a dialog.
- Adopting a backend makes three statements in `legal/PRIVACY_POLICY.md` false
  ("makes no network requests", twice, and "Data Not Collected"). Those must be
  corrected in the same PR, and in-app account deletion becomes mandatory under
  Guideline 5.1.1(v).
- **Least data collection** — no analytics/crash SDKs are integrated yet (deliberately deferred); when they are, event payloads should stay in line with `Analytics Events` in the product blueprint and avoid collecting anything beyond what's declared in App Privacy.

Run the `security-review` skill against the diff before merging any change that touches persistence, networking, or purchases.

---

## ✅ Usage Rules

- **Always** reference tokens (`AppColors.primary`, `AppSpacing.medium`, …) — never hardcode literal values.
- **Reuse** `Core/Components/` before building a new view.
- **Match** the surrounding code's conventions (4-space indentation, `PascalCase` types, `camelCase` members).
- **New tokens** go into the appropriate `Core/DesignSystem/` file and get documented here in the same PR.
- Prefer Swift **async/await** over Combine for any dynamic/animated data flow.

---

_This document tracks the design system as implemented. Update it in the same PR whenever tokens or shared components change._
