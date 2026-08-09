# catLock — Design System & Guidelines

This document describes the visual and interaction design language for **catLock** (`goCat`). All values are sourced from the app's design-system code in `goCat/Core/DesignSystem/` and should be treated as the single source of truth. **Do not hardcode colors, fonts, spacing, or radii in feature code — always reference these tokens.**

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
| `warning` | `#B85C38` | 🟥 burnt orange | Warnings, destructive/attention states |

**Guidance**
- Use `primary` for the main call-to-action (e.g. Start Focus).
- Use `textSecondary` for captions, hints, and metadata.
- Reserve `warning` for destructive or attention-critical states only.

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
| `large` | 12 | Cards, sheets, selection tiles |

---

## 🎬 Motion & Animation

Defined in `AppAnimation.swift`. Keep motion subtle and purposeful; respect Reduce Motion.

| Token | Curve | Duration | Usage |
|-------|-------|----------|-------|
| `quick` | easeOut | 0.18s | Taps, toggles, micro-interactions |
| `standard` | easeInOut | 0.28s | View transitions, sheet presentation |
| `slow` | easeInOut | 0.45s | Ambient/scene changes, emphasis |

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

Shared modifiers live in `Core/Extensions/View+Modifiers.swift` and `View+Accessibility.swift`.

---

## 🗺️ Information Architecture

The app uses a **tab-based** structure (`Navigation/MainTabView.swift`, `TabItem.swift`) with per-tab navigation destinations (`NavigationDestination.swift`).

Primary areas:
- **Home** — Customize the room (cat, chair, scene, sound) and start a focus session.
- **Focus Session** — Live timer, session controls, pause/resume, completion.
- **Tasks** — Manage focus tasks.
- **Progress** — Weekly summary, focus history, streaks.
- **Room** — View owned/purchased items.
- **Settings** — About, sound, accessibility.

First-run flow: **Launch → Onboarding** (welcome → focus goal → notification permission) → **Home**.

---

## 🐱 Signature Elements

- **The Cat** — A Rive-powered animated cat (`Services/Animation/`, `Features/Home/Views/CatRiveView.swift`) that reacts to session state. It is the emotional core of the UI.
- **The Room / Scene** — A customizable, illustrated space (`LiveSceneView`, `SessionSceneView`) with selectable backgrounds and furniture.
- **Ambient Sound** — Optional background audio (`Services/Audio/`) paired with the scene.

---

## ♿ Accessibility

- **Dynamic Type** — All typography uses system fonts that scale automatically.
- **VoiceOver** — Components apply labels/traits via `View+Accessibility.swift`; managed centrally by `AccessibilityManager`.
- **Reduce Motion** — Honor the system setting; fall back to fades/instant changes instead of the `slow`/`standard` animations.
- **Contrast** — `textPrimary` on `background`/`surface` meets contrast needs; avoid placing `textSecondary` on saturated colors.
- **Dedicated settings** — `Features/Settings/Views/AccessibilitySettingsView.swift` exposes user-facing accessibility options.

---

## ✅ Usage Rules

- **Always** reference tokens (`AppColors.primary`, `AppSpacing.medium`, …) — never hardcode literal values.
- **Reuse** `Core/Components/` before building a new view.
- **Match** the surrounding code's conventions (4-space indentation, `PascalCase` types, `camelCase` members).
- **New tokens** go into the appropriate `Core/DesignSystem/` file and get documented here in the same PR.
- Prefer Swift **async/await** over Combine for any dynamic/animated data flow.

---

_This document tracks the design system as implemented. Update it in the same PR whenever tokens or shared components change._
