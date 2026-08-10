# Decision Log

Why catLock is the way it is. One entry per decision, newest first. Written so that six months from now — or a fresh Claude session — nobody re-litigates a settled question or "fixes" something that was deliberate.

**Add an entry whenever you make a choice that a reasonable person might later question.** If the reasoning only lives in a chat log, it's already lost.

---

## 2026-08-10 — Accounts added to the design, but kept optional

**Decision:** sign-up / sign-in screens and a Plan & Billing section are being designed. This **reverses** the "no accounts" position recorded on 2026-08-08.

**Shape of the reversal, which matters more than the reversal itself:**
- An account is **optional**. Timer, cat, streaks and tasks all work fully signed out. There is no sign-in wall.
- It is offered once, after a third completed session — never during onboarding. A mandatory account in front of a focus timer is a conversion killer and an App Review 5.1.1 risk.
- **Sign in with Apple + email one-time code. No passwords.** No Google or Facebook — offering a third-party login would force Sign in with Apple as an equivalent option under Guideline 4.8 anyway, and the extra provider buys nothing. No passwords means no reset flow, no credential storage, and a far smaller breach surface.

**What this costs, and it is not small:**
- **In-app account deletion becomes mandatory** — Apple requires it to be reachable inside the app, not via a support email. Screen 39 in the wireframe prompt.
- The privacy policy stops saying "Data Not Collected". `legal/PRIVACY_POLICY.md` Part B activates and the Apple privacy label changes.
- DPDP age assurance applies for under-18 users, and breach notification (72 hours) becomes a real operational duty.
- Local-to-cloud data merge becomes a correctness problem. Silently overwriting a 47-session local history with an empty cloud account is the classic way to lose a user permanently — hence the explicit merge screen.

**Still true:** this is design work, not implementation. Nothing is built. The right build order remains `PLAN.md` Tier 0 first — the timer still drifts and the streak still isn't a streak.

---

## 2026-08-10 — Docs live in the repo, not in a chat

**Decision:** `PLAN.md`, `TESTING.md`, `ONBOARDING.md`, `MONETIZATION.md`, `legal/*` and `CLAUDE.md` are committed alongside the code.

**Why:** the project had already drifted into a state where the docs described intentions as if they were features, and it took a direct question to surface it. Docs in git are versioned, diffable, and reviewed in the same PR as the code they describe. Docs in a chat window are gone.

**Consequence:** any behaviour change must update its doc in the same commit. This is a real cost and it's the point.

---

## 2026-08-10 — Cat video plays once on Home, loops during a session

**Decision:** `CatSceneVideo` gained a `Playback` mode. Home passes `.once` and holds the final frame; an active session passes `.looping`.

**Why:** motion should mean "a session is running". A landing screen that rocks forever is decoration; one that settles into stillness makes starting a session feel like something changed.

**Trade-off accepted:** the session screen is a `fullScreenCover` and builds its own player from frame 0, so there is a handover from Home's last frame to the session's first frame. This is invisible **only because the clip is authored as a seamless loop.** Any replacement clip must preserve that, or the cut appears at the exact moment the user taps Start Focus.

**Also:** "once" means once per `HomeView` lifetime — returning from a finished session leaves it frozen. A `hasFinishedSingleRun` latch stops the foreground-resume path handing out a second run.

---

## 2026-08-10 — Pause removed entirely

**Decision:** `FocusTimerService.pause()` deleted. The only session control is Cancel. `SessionControlsView` and `PauseSessionSheet` deleted with it.

**Why:** the product premise is "lock yourself in with your cat." A pause button is a socially acceptable way to quit without admitting it. Forcing a binary — finish, or explicitly throw the session away — is what makes the completion mean anything.

**Consequence:** `FocusSessionState.paused` still exists as an enum case and `CatAnimationController` still switches on it. Harmless (unreachable), not a compile error. Don't "fix" it by re-adding pause.

---

## 2026-08-10 — Cancel is destructive and visible

**Decision:** cancelling plays a sad trash-can animation and leaves the streak untouched. Completing plays a trophy and increments the streak.

**Why:** a neutral "session ended" teaches nothing. A small, visible consequence for quitting is the motivational mechanic, and it mirrors the reward economy from the original blueprint without building the whole fish/coins system.

---

## 2026-08-10 — Custom duration capped at 2 hours

**Decision:** the Custom chip opens a dial + hour/minute wheels, hard-capped at 120 minutes, in 5-minute steps.

**Why:** the cap is a wellbeing decision as much as a technical one. Unbroken focus blocks beyond two hours are counterproductive for the audience this app targets, and an app with no pause button should not let someone lock themselves in for six hours.

**Note:** the picker is currently free. Moving a shipped free feature behind a paywall generates real anger — decide before v1.0 whether Custom is a Plus feature. See `MONETIZATION.md`.

---

## 2026-08-09 — No back or close button during a session

**Decision:** `FocusSessionView` has no dismiss control. The only way out is Cancel.

**Why:** same premise as removing pause. An exit button that silently abandons a session without consequence undermines the entire mechanic.

**Watch for:** this is the decision most likely to be "helpfully" reverted by someone who assumes it's an oversight. It isn't.

---

## 2026-08-09 — Pre-rendered video instead of a Rive rig

**Decision:** the cat is a ~10s looping MP4 (`session_cat_loop.mp4`) played through `AVQueuePlayer` + `AVPlayerLooper`, not a Rive state machine.

**Why:** a Rive rig only pays for itself if the character reacts to state (idle/happy/sad). Since the cat is fixed and non-customizable, a video is simpler, cheaper to render, has no runtime dependency, and looks better than anything achievable in the same time.

**Consequence:** `RiveAnimationService` and `CatAnimationController` remain as orphaned scaffolding. Delete when convenient.

**Reconsider if:** per-state cat reactions become a priority. That's the one thing video can't do well.

---

## 2026-08-09 — Lottie for outcome animations, video for the scene

**Decision:** two animation technologies. Video for the ambient cat scene, Lottie (`airbnb/lottie-spm`) for the trophy and trash outcomes.

**Why:** they solve different problems. The scene is photographic and long-running; the outcomes are vector, short, one-shot, and need a completion callback to drive dismissal. Forcing either into the other's tool would be worse.

**⚠️ Open risk:** the provenance of both `.lottie` files is unknown. See `legal/IP_CLEARANCE.md` — trace or replace before launch.

---

## 2026-08-09 — Single-screen architecture, no tab bar

**Decision:** `RootView` goes straight to `HomeView`. Everything else is a sheet or lives behind the `…` overflow menu.

**Why:** the artwork is the screen. A tab bar would permanently occupy the bottom of a full-bleed scene and compete with the thing the app is selling.

**Consequence:** `AppRouter`, `TabItem` and `NavigationDestination` are unused scaffolding, kept in case a tabbed structure ever returns. `RoomView` became unreachable this way and is now dead code.

---

## 2026-08-09 — No cat or chair customization

**Decision:** one fixed companion. Customization is limited to room background and ambient sound.

**Why:** every decision before a focus session is friction, and this audience is the least able to afford it. The original blueprint had a 6-slot furniture inventory and multiple cat personalities; that's a reward economy, and building one to support a timer is backwards. Also cuts a large asset-production cost.

**Deferred, not cut** — see the MVP Scope section of `DESIGN.md`.

---

## 2026-08-09 — Design tokens are mandatory

**Decision:** no hardcoded colors, fonts, spacing, radii or animation curves anywhere in feature code. Everything from `Core/DesignSystem/`.

**Why:** it's the only thing that keeps a solo-built app visually coherent as it grows, and it makes a future theming or dark-mode pass a change in one directory rather than a hunt through fifty files.

**Enforcement:** this is the convention most worth defending in review. One inline `Color(hex:)` becomes ten.

---

## 2026-08-08 — Local-first, no backend, no accounts

**Decision:** everything in `UserDefaults` and local storage. No Supabase, no auth, no sync, despite the blueprint scheduling all three for days 12–14.

**Why:** a backend is the largest source of cost, latency, failure modes and legal obligation in an app like this, and buys nothing for a single-device focus timer. It also means the app collects zero personal data, which is both a genuine selling point and an enormous reduction in compliance surface — see `legal/PRIVACY_POLICY.md`.

**The moment this changes**, in-app account deletion becomes mandatory under Apple's rules, DPDP age-assurance applies, and breach notification becomes a real operational requirement. Don't add accounts casually.

---

## 2026-08-08 — iOS only; Mac and visionOS support removed

**Decision:** `SUPPORTED_PLATFORMS` restricted to iOS.

**Why:** the layout is designed for a phone-shaped full-bleed scene. Shipping a Mac build that nobody designed is worse than not shipping one.

**⚠️ Unrelated but adjacent problem:** `IPHONEOS_DEPLOYMENT_TARGET` is set to **26.5**, which restricts the app to the newest iOS release. That was not a deliberate decision, it's a default nobody changed, and it should be dropped to 17 or 18. Tracked in `PLAN.md`.

---

## Open decisions — not yet made

These need an answer before launch. Listed so they don't get forgotten.

| Question | Blocking | Where |
|---|---|---|
| **Does the app get renamed?** A live "Cat Lock" exists in the same App Store category. | Icon, domain, marketing, App Store record | `legal/IP_CLEARANCE.md` |
| Individual vs registered entity as App Store publisher? Individual publishes under your personal legal name, visible worldwide. | App Store Connect record | `legal/TERMS_OF_USE.md` §1 |
| Is the custom duration picker free or Plus? | Paywall design | `MONETIZATION.md` |
| SwiftData or Core Data? Both are half-present. | All persistence work | `PLAN.md` Tier 0 |
| Is iPad supported? `TARGETED_DEVICE_FAMILY` allows it; nothing was designed for it. | Layout, screenshots | `TESTING.md` |
| Ship free first and add Plus in v1.1, or launch paid? | Whole roadmap | `PLAN.md` §5 |
