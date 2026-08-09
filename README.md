# catLock 🐱🔒

**catLock** (internal project name `goCat`) is an iOS focus & productivity app that helps you stay on task with the company of an animated cat. Start a focus session, watch your cat settle into a cozy, customizable room, and build streaks as you get things done.

---

## ✨ Features

- **Focus Sessions** — Pomodoro-style timed focus sessions with pause/resume, live timer, and a completion flow.
- **Cat Companion** — A fixed, cozy default: your cat rocking in its chair, played as a looping video for every session. Not customizable by design — one less decision before you focus.
- **Room Customization** — Personalize your space: choose your **room background** and ambient **sound**.
- **Ambient Sounds** — Background audio to help you concentrate.
- **Tasks** — Create and track tasks alongside your focus sessions.
- **Progress Tracking** — Weekly summaries, focus history, and streaks.
- **Onboarding** — Guided first-run experience with focus goals and notification permissions.
- **Local Notifications** — Session reminders and completion alerts.
- **Premium / StoreKit** — Premium-gated content via in-app purchases.
- **Accessibility** — Dedicated accessibility settings and VoiceOver-friendly components.

---

## 🏗️ Architecture

The app follows an **MVVM** pattern with a clear, feature-based folder structure and SwiftUI throughout (async/await over Combine).

| Layer | Location | Responsibility |
|-------|----------|----------------|
| **App** | `goCat/App/` | Entry point, app state, routing, root view |
| **Core** | `goCat/Core/` | Design system, reusable components, extensions, storage, utilities |
| **Features** | `goCat/Features/` | Self-contained feature modules (Home, FocusSession, Tasks, Progress, Room, Settings, Onboarding, Launch) — each with `ViewModels/` and `Views/` |
| **Models** | `goCat/Models/` | Domain models (FocusSession, FocusTask, CatOption, etc.) |
| **Services** | `goCat/Services/` | Animation (Rive), Audio, Notifications, Purchases (StoreKit), Timer |
| **Persistence** | `goCat/Persistence/` | Core Data model + entity mappings |
| **Navigation** | `goCat/Navigation/` | Tab and navigation destinations |

---

## 📁 Project Structure

```
goCat/
├── App/                 # App entry, state, routing
├── Core/
│   ├── Components/       # Reusable SwiftUI components
│   ├── DesignSystem/     # Colors, fonts, spacing, animation
│   ├── Extensions/       # Swift/SwiftUI extensions
│   ├── Storage/          # UserDefaults-backed stores
│   └── Utilities/        # Logger, haptics, notifications, accessibility
├── Features/             # Feature modules (MVVM)
├── Models/               # Domain models
├── Navigation/           # Tabs & navigation
├── Persistence/          # Core Data
├── Services/             # Animation, Audio, Notifications, Purchases, Timer
├── Resources/            # Assets & localizations
└── PreviewContent/       # Mock data for SwiftUI previews
```

---

## 🚀 Getting Started

### Requirements
- Xcode (latest recommended)
- iOS deployment target as configured in the project
- A Swift toolchain matching the project settings

### Build & Run
1. Clone the repository:
   ```bash
   git clone https://github.com/raj075512/catLock.git
   ```
2. Open `goCat.xcodeproj` in Xcode.
3. Select an iOS Simulator (or device) and press **⌘R**.

### Tests
- **Unit tests** (Swift Testing framework): `goCatTests/`
- **UI tests** (XCUIAutomation): `goCatUITests/`

Run all tests with **⌘U** in Xcode.

---

## 🌱 Branching & Contribution Workflow

We use a **git-flow**-style model:

| Branch | Purpose |
|--------|---------|
| `main` | Stable / release-ready code |
| `dev` | Integration branch — all features merge here first |
| `feature/*` | New features & fixes, branched **from `dev`** |

**Workflow for new work:**
```bash
git checkout dev
git pull
git checkout -b feature/<short-name>
# ...commit your work...
git push -u origin feature/<short-name>
# then open a Pull Request targeting `dev`
```

- Feature branches **always** branch off `dev`.
- Pull Requests **always** target `dev`.
- `dev` is merged into `main` for releases.

---

## 📄 Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history and release stages.

---

## 📝 License

_Proprietary — all rights reserved unless stated otherwise._
