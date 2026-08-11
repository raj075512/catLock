# catLock 🐱🔒

**catLock** (internal project name `goCat`) is an iOS focus timer you can't pause, with a cat
who waits it out with you. Pick a length, start, and the only way out is to give the session
up — that constraint is the product, not a limitation of it.

Aimed at people who struggle to start and stay with tasks. Local-first, no accounts, no
analytics, no network calls.

> ⚠️ **The name is disputed.** A live App Store app called "Cat Lock — Screen Time Control"
> exists in the same category. See `legal/IP_CLEARANCE.md`; a rename is unresolved.

---

## ✨ What's built

Screens 1–29 of the wireframe set (`design/`), implemented in SwiftUI.

- **Onboarding** — splash, welcome, a five-question survey, a personalised summary, "How it
  works", and a first session that starts inside the product rather than after a tour.
- **Home** — full-bleed cat video, streak pill, duration chips (15 / 25 / 45 / custom up to
  two hours), Start Focus, and the Sounds / Room / Tasks quick actions. No tab bar.
- **The session** — looping video, one glass strip, a red countdown and a single Cancel.
  A sage hairline fills across the final minute. Completion gets a trophy and streak +1;
  cancelling gets a trash animation and changes nothing.
- **Sheets** — Sounds (six ambient loops, three free), Room (six rooms, three free), Tasks
  (a scratchpad, not a task manager), custom duration, Progress, Settings, About,
  Accessibility.

### Not built yet

Subscriptions (screens 30–32, 41–43) and accounts (33–40) are designed but not implemented.
StoreKit loads products and nothing else; there is no backend, and rows that would lead to
those screens are inert. Completion notifications are unwired — `LocalNotificationService`
exists but is never called, pending a copy decision.

---

## 🧭 Product rules

These are deliberate. Don't design or code around them.

1. **No pause.** A session runs to completion or is explicitly cancelled.
2. **No back or close during a session.** Cancel is the only control; swipe-to-dismiss is off.
3. **Cancel discards.** Streak unchanged, nothing recorded, no guilt copy, ever.
4. **No tab bar.** Home is the whole app; everything else is a sheet or behind the `…` menu.
5. **No cat or chair customization.** One fixed companion. Room and sound only.
6. **No personal data.** No account, no email, no analytics SDKs. Works fully offline.

---

## 🏗️ Architecture

**MVVM**, SwiftUI throughout, `@MainActor @Observable` view models, `async/await` over Combine.

| Layer | Location | Responsibility |
|-------|----------|----------------|
| **App** | `goCat/App/` | Entry point, `AppState`, root view |
| **Core** | `goCat/Core/` | Design system, components, extensions, storage, utilities |
| **Features** | `goCat/Features/` | Self-contained modules, each with `Views/`, `ViewModels/`, `Sheets/` |
| **Models** | `goCat/Models/` | `SoundOption`, `RoomOption`, `SurveyAnswers`, `StreakState`, … |
| **Services** | `goCat/Services/` | Audio, Notifications, Purchases, Timer |
| **Persistence** | `goCat/Persistence/` | SwiftData container and models |

**Design tokens are mandatory.** Never hardcode a colour, font, spacing value, corner radius
or animation curve in feature code — everything comes from `Core/DesignSystem/`. If a token
doesn't exist, add it there. `DESIGN.md` must be updated in the same commit as any visual
change.

**Persistence** is SwiftData (`CompletedSession`, `TaskItem`) plus `UserDefaults` for
preferences. The old Core Data model has been removed.

**Dependencies:** only `airbnb/lottie-spm` (4.6.1, MIT).

---

## 🚀 Getting started

### Requirements
- Xcode 26 or later
- iOS 17.0 deployment target

### Build & run
```bash
git clone https://github.com/raj075512/catLock.git
```
Open `goCat.xcodeproj`, pick an **iOS Simulator** destination, press **⌘R**.

> Build for a Simulator, not "My Mac" — running on My Mac triggers an unrelated dyld crash
> (`ABPeoplePickerView` missing from the iOSSupport runtime) that looks like an app bug.

### Tests

```bash
xcodebuild -project goCat.xcodeproj -scheme goCat -destination 'platform=iOS Simulator,name=iPhone 17' test
```

- `goCatTests/` — timer, streak, persistence, onboarding, sound preferences
- `goCatUITests/` — walks onboarding and Home, asserting the product rules hold

---

## 🌱 Branching

| Branch | Purpose |
|--------|---------|
| `main` | Stable / release-ready |
| `dev` | Integration — features merge here first |
| `feature/*` | Branched from `dev`, PRs target `dev` |

Never force-push, never commit secrets, never commit to `main` or `dev` directly.

---

## 📚 Documents

| File | What it holds |
|---|---|
| `PLAN.md` | State of the app, gap analysis, roadmap |
| `DESIGN.md` | Tokens, components, information architecture |
| `DECISIONS.md` | Why things are the way they are, dated |
| `TESTING.md` | Test strategy, device matrix, submission checklist |
| `MONETIZATION.md` | Subscription strategy and pricing |
| `legal/` | Privacy policy, terms, compliance, IP clearance |

---

## 📝 License

_Proprietary — all rights reserved unless stated otherwise._
