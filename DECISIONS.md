# Decision Log

Why catLock is the way it is. One entry per decision, newest first. Written so that six months from now — or a fresh Claude session — nobody re-litigates a settled question or "fixes" something that was deliberate.

**Add an entry whenever you make a choice that a reasonable person might later question.** If the reasoning only lives in a chat log, it's already lost.

---

## 2026-08-10 — Trial-led pricing at $6.59/wk, $19.99/mo, $79.99/yr

**Decision:** catLock Plus becomes trial-led — 7 days free on every tier — at prices roughly 8–11× the earlier $29.99/year plan.

**Shape of it:**
- Home's primary button becomes **"Try 7 days free"**, but **"Start a free session" sits directly beneath it and always works.** Locking the timer behind payment would hit Guideline 4.2 and 3.1.2, and it contradicts the whole ADHD-friendly premise: a payment demand between someone and a timer is exactly the friction this app exists to remove.
- Tapping a Plus sound raises a sheet naming that sound, with two actions only: start the trial, or Not now.
- When the trial lapses, one "Keep your streak safe" screen. It leads with the streak, states that data stays either way, and offers "Keep using catLock free" as a real option. **The streak is never threatened** — that converts marginally better and earns one-star reviews from the exact audience being courted.
- Annual added at $79.99 and preselected. It anchors the others: against $79.99/year, $6.59/week reads as the expensive convenience option.

**Risk accepted, stated plainly:** $6.59/week annualises to ~$343. That is the pricing band Apple scrutinises hardest under 3.1.2, and the pattern — aggressive weekly price plus thin functionality — is one Apple has been removing apps for. The mitigations are the free session on Home, an immaculate paywall, and 48-hour trial reminders. Watch the refund rate; sustained refunds on weekly are the signal that draws attention.

**Superseded:** the 2026-08-10 entry recommending $4.99/mo and $29.99/yr with a paywall after two completed sessions.

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

## 2026-08-11 — Baseline onboarding chosen over v2 and v3

**Decision:** implement the baseline 10-screen onboarding (wireframes 1–10), not v2's
six-screen cut and not v3's dark amber direction.

**Why:** v3 replaces the entire palette — the handoff says so itself ("it is a direction, not
a patch"), and adopting it means re-tokenising every screen in the app. v2 is genuinely
shorter and its 60-second taster is a better teacher than a text screen, but it was drawn
after the baseline was approved and reopening the flow was not what this build was for.
The baseline keeps the locked light design system, so nothing else had to change.

**Revisit if** first-session completion is weak in beta. v2 exists, fully specified, and the
survey code is already structured to drop questions.

---

## 2026-08-11 — A running session survives force-quit and reboot

**Decision:** the end date of a running session is persisted (`ActiveSessionStore`). Relaunching
mid-session drops straight back into it; relaunching after it would have ended shows the
completion screen and records it.

**Why:** the handoff left this undefined and warned that silence here becomes a bug report.
A session already survives backgrounding, and "leaving the app keeps the timer running" has to
mean the same thing whether the user swiped up to the Home screen or swiped the app away.
Discarding it would make force-quit the one escape hatch the product deliberately doesn't
offer — which is rule 1 with a loophole.

---

## 2026-08-11 — The timer derives from a wall-clock end date

**Decision:** `FocusTimerService.remainingSeconds` is always `endDate - now`. The tick exists
only to give SwiftUI something to redraw against.

**Why:** the previous implementation decremented a counter once per `Task.sleep(1s)`. iOS
suspends a backgrounded app's tasks, so time spent away simply didn't count: a 25-minute
session could take an hour of wall clock and the number on screen was fiction. Covered by
`FocusTimerServiceTests.testTimeElapsedWhileSuspendedStillCounts`.

---

## 2026-08-11 — The streak counts days, not sessions

**Decision:** `StreakState` holds `{ current, best, lastCompletedDay }`. A completion
increments at most once per local day, and the displayed value reads as zero once a whole day
is missed.

**Why:** the old store incremented a counter per completed session, so three sessions in one
afternoon displayed "3 day streak". Cancelling still never touches it — that promise is made
in the copy on two separate screens, so it needs to be true.

**Migration:** the old bare counter is carried over as a best-effort current streak ending
today rather than resetting existing users to zero.

---

## 2026-08-11 — SwiftData, and the Core Data model deleted

**Decision:** one SwiftData container holding `CompletedSession` and `TaskItem`. The unused
Core Data model, its entity mappings, `PersistenceController`, `SessionStore`,
`TimerPersistenceService` and the template `Item` are all gone.

**Why:** this was listed as an open decision below and had been blocking every persistence
task. Two half-present stacks is worse than either one. SwiftData is what the container was
already declared with, and no feature here needs anything Core Data does better.

---

## 2026-08-11 — Deployment target dropped to iOS 17.0

**Decision:** `IPHONEOS_DEPLOYMENT_TARGET` 26.5 → 17.0.

**Why:** 26.5 restricted the app to the newest iOS release — it would not even install on a
26.4 simulator. 17.0 is the genuine floor: `@Observable`, SwiftData and
`contentTransition(.numericText)` all require it, and nothing in the app needs more.

---

## 2026-08-12 — Two subscription tiers, not three

**Decision:** ship `catlock.plus.yearly` (7-day free trial, preselected) and
`catlock.plus.monthly` (no trial). No weekly tier.

**Why:** `MONETIZATION.md` described three tiers including a weekly one, but the
paywall was drawn for two cards and its legal disclosure, its 32pt price and its
swapping button label were all written against that. That document also warns that
the weekly price it proposed "puts catLock in the pricing band Apple scrutinises
hardest" and that "Apple has been actively removing apps" pairing an aggressive
weekly price with thin functionality. Two tiers is the smaller surface for a first
paid build.

**Revisit** once there is real retention data. Adding a third product later is a
one-line change to `PlusProduct` plus a card on the paywall.

---

## 2026-08-12 — The paywall appears on top of the completion screen

**Decision:** after the second *completed* session, present the paywall over the
trophy — not instead of it, and never after a cancelled one.

**Why:** two of our own documents disagreed. `MONETIZATION.md` §4 carried a hard rule
that the completion screen must never show a paywall; wireframes 30 and 18 both
specified exactly that placement. The wireframe won: it is the more specific
artefact, it is what screens 1–29 were built against, and the completion moment is
the highest-intent one the app has. The rule in `MONETIZATION.md` has been rewritten
rather than left to contradict the code.

**What did *not* change:** it still never interrupts a running session, never follows
a cancellation, and fires exactly once automatically. `PaywallTrigger` enforces all
four rules and `PaywallTriggerTests` pins them.

---

## 2026-08-12 — The paywall sells only what exists

**Decision:** the perk list is the six sounds and the six rooms. The wireframe's
"Advanced stats and history" and "Home Screen widget" lines are omitted.

**Why:** neither is built. Guideline 3.1.2 treats charging for absent features as
grounds for rejection, and `MONETIZATION.md` itself warns that a high price "invites
the reviewer to ask what recurring value justifies it" — a promise of a widget that
does not exist is the worst possible answer. Both perks were already visibly locked
in the Sounds and Room sheets, so the paywall sells something the user has already
bumped into rather than introducing new claims.

**Restore the lines** when the widget and the expanded stats ship, not before.
`PaywallUITests` asserts they stay out until then.

---

## 2026-08-12 — The entitlement is derived from StoreKit, never cached

**Decision:** `PremiumAccessService` reads `Transaction.currentEntitlements` on every
refresh and persists nothing except a "has ever subscribed" marker.

**Why:** a cached entitlement is a cached wrong answer the moment a subscription
lapses or is refunded. The free tier is a complete app, so there is no offline state
worth protecting with a stale flag. The one persisted bit exists only so Plan &
Billing can tell "never subscribed" from "lapsed" — the lapsed copy leads by
reassuring that history is intact, which would read as nonsense to someone who never
paid.

---

## 2026-08-12 — The StoreKit config lives in the test target, not the app

**Decision:** `catLock.storekit` sits in `goCatTests/`, referenced by the scheme.

**Why:** it was briefly in `goCat/Resources/`, where the synchronized group copied it
straight into the shipping app bundle — a development fixture with placeholder prices
has no business in a release build.

**Also worth knowing:** StoreKit's test configuration does not reach the app process
when tests are driven from `xcodebuild`, and `SKTestSession` configures the runner
rather than the app under test. A first version of the paywall UI tests passed
against a paywall rendering **no prices at all**, because every assertion happened to
match copy that also exists in the no-products fallback. Purchase, pricing and
entitlement are covered in-process by `StoreKitServiceTests`; the UI tests cover the
legal furniture and the unavailable state.

---

## 2026-08-13 — No backend, and a seam instead of a commitment

**Decision:** the app stays local-only. No auth, no accounts, no sync, no vendor
SDK. What ships instead is a provider-agnostic boundary — `IdentityProviding` and
`SyncProviding` in `Services/Backend/`, with `LocalOnlyBackend` as the default —
so AWS or Supabase can be adopted later by adding one conforming type and changing
one line.

**Why:** a Supabase project, schema and SDK were briefly added and then removed the
same day. The work surfaced three costs that were not worth paying yet:

- Adopting a backend makes three statements in `legal/PRIVACY_POLICY.md` false and
  turns the App Store label from "Data Not Collected" into Contact Info linked to
  identity. For an ADHD-focused app whose pitch includes collecting nothing, that
  is a product cost, not just paperwork.
- Email OTP needs custom SMTP with a verified sending domain. The product name is
  disputed and unresolved (`legal/IP_CLEARANCE.md`), so buying a domain now risks
  buying the wrong one.
- Sign in with Apple binds to the bundle ID, and `ashutosh.goCat` is already flagged
  for change. Configuring against it means doing it twice.

**Why a seam rather than nothing:** "no backend yet" and "no backend ever" are
different, and the expensive mistake is letting a vendor's types leak into feature
code. A `Supabase` import in a view model means switching provider is a rewrite.
The boundary costs two files and seven tests today and makes the choice reversible
in both directions.

**The rule it creates:** nothing under `Features/` imports a networking library.
Feature code talks to the protocols; only one file per provider knows a vendor
exists.

---

## Open decisions — not yet made

These need an answer before launch. Listed so they don't get forgotten.

| Question | Blocking | Where |
|---|---|---|
| **Does the app get renamed?** A live "Cat Lock" exists in the same App Store category. | Icon, domain, marketing, App Store record | `legal/IP_CLEARANCE.md` |
| Individual vs registered entity as App Store publisher? Individual publishes under your personal legal name, visible worldwide. | App Store Connect record | `legal/TERMS_OF_USE.md` §1 |
| Is iPad supported? `TARGETED_DEVICE_FAMILY` allows it; nothing was designed for it. | Layout, screenshots | `TESTING.md` |
| Ship free first and add Plus in v1.1, or launch paid? | Whole roadmap | `PLAN.md` §5 |
