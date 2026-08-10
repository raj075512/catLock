# catLock — Onboarding Plan

**Last updated:** 10 August 2026
**Current implementation:** `Features/Onboarding/` — three pages, ~21 lines of view model.
**Goal of onboarding:** get the user into their **first completed focus session** in under 60 seconds. Nothing else.

---

## 1. What exists today

`RootView` shows `OnboardingView` until `preferences.hasCompletedOnboarding` is true, then switches to `HomeView` permanently.

| Step | Screen | Content | Action |
|---|---|---|---|
| 1 | `WelcomePage` | Pawprint SF Symbol, "GoCat", "A calm focus timer with a room you can shape over time." | Continue |
| 2 | `FocusGoalPage` | Timer SF Symbol, "Choose a steady rhythm", explains 25 min | "Use 25 minutes" |
| 3 | `NotificationPermissionPage` | Bell SF Symbol, "Know when the session ends" | Continue → system permission prompt → done |

Three taps, then Home. Completion persists via `AppState.completeOnboarding()`.

### Problems with it

1. **It says "GoCat".** The app is called **catLock**. `WelcomePage` shows the internal project name as the very first word a user reads, and `NotificationPermissionPage` says "GoCat can remind you…". This is a one-line fix and it is the most visible bug in the app.

2. **The "focus goal" page doesn't select a goal.** It has one button that says "Use 25 minutes". Nothing is chosen, nothing is stored, `UserPreferences.focusDuration` is never written. The blueprint's `onboarding_completed` analytics event expects a `selected_goal` property that does not exist. It is currently a page that exists to be dismissed.

3. **The notification permission is asked too early, and for nothing.** It fires before the user has run a single session — no value has been delivered, so the "yes" rate will be poor, and iOS only lets you ask once. Worse: `LocalNotificationService` is **never called anywhere in the app**, so even a "yes" produces no notification, ever. You are spending your one permission prompt on a feature that isn't wired up.

4. **The result of the permission request is discarded.** `requestAuthorization()` returns a Bool that is thrown away with `_ =`. `UserPreferences.notificationsEnabled` stays `false` regardless.

5. **The cat never appears.** Your single strongest asset — the cat rocking in the chair — is absent from the entire first-run experience. The user meets a pawprint SF Symbol instead.

6. **No skip, no back.** Three forced taps. Not terrible at this length, but there is no escape hatch.

---

## 2. The plan

### Principle

Onboarding is not where you explain the app. It is where you get someone to feel it. Every screen that isn't moving them toward a completed session is a screen where they close the app. For an ADHD audience this is not a nice-to-have — a long setup flow is precisely the failure mode the product exists to solve.

**Target: 3 screens, under 30 seconds, ending in a running session.**

### Proposed flow

**Screen 1 — Meet the cat**

Full-bleed `CatSceneBackground` (the real video, `.once`), the app name **catLock**, and the tagline *"Lock yourself in with your cat."* One button: **Get started.**

*Why:* leads with the product's actual differentiator instead of describing it. It also confirms, on first launch, that the video pipeline works on the user's device.

**Screen 2 — Say what it does, in one sentence**

*"Pick a length. Start. No pause, no going back — your cat's waiting it out with you."*

Set the honest expectation that a session can't be paused, before they discover it mid-session and feel tricked. One button: **Sounds good.**

*Why:* the no-pause rule is your boldest decision. Framed here it is a feature; discovered later it's a bug report.

**Screen 3 — Pick your first session**

The three duration chips (15 / 25 / 45), 25 preselected. One button: **Start focusing.** Tapping it goes straight into a live session.

*Why:* the fastest path to the activation moment. It also writes a real value into `UserPreferences.focusDuration` — which finally makes the blueprint's `selected_goal` property meaningful.

**Then: nothing.** No notification prompt, no account, no paywall. Home is reached *after* the first session ends.

### Permission timing

| Permission | Ask when | Reason |
|---|---|---|
| **Notifications** | After the user's **second completed session**, or the first time they background the app during a session | They now know what a completed session feels like, and a "your session is done" alert is obviously useful. This matches the blueprint's own Tech Stack note: *"Ask permission after value moment."* |
| **ATT / tracking** | Never, unless ads happen | See `MONETIZATION.md` — the recommendation is no ads. |

**Do not ship the notification prompt until `LocalNotificationService` is actually called.** Asking for a permission you don't use is the worst of both worlds: you burn the one-time prompt and deliver nothing.

Prime it with your own screen before the system dialog ("Want a nudge when your session ends?" → Yes / Not now). If they say "Not now", don't call `requestAuthorization()` at all — that preserves your ability to ask again later. Once iOS shows the real dialog and the user declines, your only remaining route is Settings.

### Returning users, edge cases

- **Onboarding runs once.** `hasCompletedOnboarding` persists in `UserDefaults` — reinstalling replays it, which is correct.
- Add a **"Replay intro"** row in Settings. Costs nothing and helps you test.
- If the video fails to load, `CatSceneBackground` falls back to the poster automatically — verify onboarding still looks right in that state.
- With **Reduce Motion** on, screen 1 shows the static poster. Check that the tagline is still legible against it.
- Screens must survive **Dynamic Type at accessibility sizes** — the current pages use fixed `VStack` spacing with no `ScrollView` and will clip at the largest settings.

---

## 3. What to measure

From the blueprint's Analytics Events sheet, with corrections:

| Event | Properties | Question it answers |
|---|---|---|
| `onboarding_started` | `app_version` | Denominator |
| `onboarding_step_viewed` | `step_index` | Where they drop |
| `onboarding_completed` | `selected_duration` (**now real**), `time_to_complete` | Did they get through |
| `first_session_started` | `duration`, `seconds_since_install` | **The activation metric** |
| `first_session_completed` | `duration` | The one that actually predicts retention |
| `notification_permission_prompted` | `trigger`, `session_count` | Was the timing right |
| `notification_permission_result` | `granted` | Was the timing right |

**The number to care about: percentage of installs that complete a first session on day one.** Under 40% and onboarding is in the way. Everything else in this table is diagnostic.

Note that no analytics SDK is integrated yet, so none of this fires today. That's fine — it's a Phase 3 item in `PLAN.md`. Define the events now so instrumentation is a mechanical task later.

---

## 4. Work items

Ordered by value per unit of effort.

- [ ] **Rename "GoCat" → "catLock"** in `WelcomePage` and `NotificationPermissionPage` *(5 minutes, highest visibility)*
- [ ] **Remove the notification permission request from onboarding** *(it currently costs you the prompt and returns nothing)*
- [ ] Make `FocusGoalPage` an actual duration choice that writes `UserPreferences.focusDuration`
- [ ] Put the cat video on screen 1
- [ ] Rewrite copy to set the no-pause expectation up front
- [ ] Have screen 3 launch the first session directly instead of landing on Home
- [ ] Store the real result of `requestAuthorization()` into `UserPreferences.notificationsEnabled`
- [ ] Add a soft pre-prompt, triggered after the second completed session
- [ ] Add "Replay intro" to Settings
- [ ] Wrap onboarding pages in a `ScrollView` for large Dynamic Type
- [ ] Add the analytics events above (Phase 3, once an SDK exists)
