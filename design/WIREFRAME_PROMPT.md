# catLock — Wireframe Generation Prompt

Copy everything below the line into Claude. It is written to be self-contained: it carries the design tokens, the product rules and all 44 screens, so you don't have to explain the app first.

**How to use it:** paste it, and Claude will deliver Section 0–1 first. Reply `next` to get each following section. Asking for all 44 at once produces worse work than ten focused batches.

**Defaults I locked in** (you didn't specify, these are reversible — just edit the prompt):
- Paywall screens **included**, marked as v1.1
- Cancel is **immediate**, no confirmation dialog — matches the code and the premise
- All five survey questions **up front**, one continuous progress bar, as you described
- **Accounts are optional and never block the timer.** Sign-in is offered after a first completed session, not during onboarding — a mandatory account in front of a focus timer is both a conversion killer and an App Review risk
- **Sign in with Apple plus email one-time code. No passwords**, which removes password reset, credential storage and most of the breach surface

---

You are a senior product designer producing wireframes for an iOS app. Work in **greyscale-plus-accent wireframe fidelity**: real layout, real copy, real hierarchy, but no illustration detail, no shadows, no photographic texture. Boxes with an X for images. This is for deciding structure, not for visual polish.

Deliver each screen as a **clean SVG artboard, 390 × 844 (iPhone 15/16 logical size)**, with the screen number and name above it and a short annotation block beneath listing: purpose, key interactions, and anything that changes in another state. Render each section as a single artifact containing its screens stacked vertically.

## The product

**catLock** is an iOS focus timer with a cat companion, aimed at people who struggle to start and stay with tasks. The premise is in the name: you lock yourself in with your cat for the length of a session.

The full-bleed background on Home and during a session is a pre-rendered video of a cat rocking in a chair. On Home it plays **once and holds on its last frame**; during a session it **loops**. Motion means "a session is running". All controls float on frosted-glass panels over that video.

## Non-negotiable product rules

These are deliberate. Do not design around them, and do not "improve" them.

1. **No pause.** A started session runs to completion or is explicitly cancelled.
2. **No back or close button during a session.** The only control is Cancel.
3. **Cancel discards the session** — sad trash animation, streak unchanged. Completion gets a trophy and streak +1.
4. **No tab bar.** Home is the entire app. Everything else is a sheet or lives behind a `…` overflow menu.
5. **No cat or chair customization.** One fixed companion, forever. Only the room background and ambient sound are customisable.
6. **An account is optional and always skippable.** The timer, the cat, streaks and tasks all work fully signed out. An account exists only to sync across devices and carry a subscription. Never gate the core loop behind sign-in, never show a sign-in wall on launch, and always draw a visible way to continue without one.

## Design system — use these exact values

**Colour**
| Token | Hex | Use |
|---|---|---|
| background | `#F7F4EF` | Warm off-white page background |
| surface | `#FFFFFF` | Cards, sheets |
| elevatedSurface | `#F0EEE8` | Inset areas, progress-bar tracks |
| primary | `#2F6F73` | Deep teal — primary actions, selected states |
| secondary | `#D98C5F` | Warm terracotta — streak flame, highlights |
| accent | `#6E8B58` | Sage green — success, progress fills, Start Focus |
| textPrimary | `#1E2525` | |
| textSecondary | `#69706F` | |
| warning | `#B85C38` | |
| danger | `#D14343` | Countdown text and Cancel **only** |

**Type** — SF Rounded for display, SF Pro for body.
Large title 34 bold rounded · Title 24 semibold rounded · Headline 17 semibold rounded · Body 16 regular · Caption 13 medium

**Spacing** — 4 · 8 · 16 · 24 · 32. Nothing between these values.
**Corner radius** — 6 small · 8 medium · 12 large. Glass panels use 26–32. Buttons and chips are full capsules.
**Glass panels** — translucent white over the video, 1px white border at ~35% opacity, radius 26–32.

## Deliver in these sections. Stop after each and wait for `next`.

---

### Section 0–1 · Entry and onboarding survey (10 screens)

**1. Splash** — full-bleed video still, wordmark centred, nothing else. No spinner unless load exceeds 1s.

**2. Meet the cat** — full-bleed video. Wordmark, tagline *"Lock yourself in with your cat."* Single capsule button **Get started** in accent. This is the first thing a human sees; it must feel calm.

**3–7. Survey questions**, one per screen, all sharing one layout:
- A **five-segment progress bar** pinned to the top, filling one segment per answer. Track `elevatedSurface`, fill `accent`, 5pt tall, inset 16 from each edge. Back chevron top-left, **Skip** top-right in textSecondary.
- Question in Title 24. Answers as full-width selectable rows, radius 12, `surface` fill, `primary` border and tint when selected.
- Advancing happens on selection — no separate Continue button.

  3. *How did you hear about catLock?* — App Store search · TikTok or Reels · YouTube · Reddit · A friend · Other
  4. *What will you use it for?* — Studying · Work · Reading · Creative work · Chores & admin · Something else
  5. *How long can you usually focus before drifting?* — Under 15 min · 15–25 · 25–45 · 45 or more
  6. *What's hardest for you?* — Getting started · Staying with it · Phone distractions · Losing track of time
  7. *When do you usually focus?* — Morning · Afternoon · Evening · Late night

**8. Personalised summary** — bar complete. *"25-minute sessions it is."* Restates what their answers changed, so the survey visibly did something. Button: **Sounds good.**

**9. How it works** — sets the expectation before they hit it: *"Pick a length. Start. No pause, no going back — your cat waits it out with you."* This screen exists so the no-pause rule reads as a feature rather than a bug.

**10. Pick your first session** — 15 / 25 / 45 chips with the survey's answer preselected. Button **Start focusing** launches a real session immediately. Onboarding ends inside the product, not on Home.

---

### Section 2 · Home (3 screens)

**11. Home, default** — full-bleed video. Top bar: glass streak pill left (flame in `secondary`, "7 day streak"), `…` glass circle right. Bottom glass panel, radius 32, containing three rows: duration chips **15 · 25 · 45 · Custom** (selected chip brighter, capsule), a full-width **Start Focus** capsule in `accent` with a play icon, and a quick-action row of **Sounds · Room · Tasks** capsules. Nothing else on screen.

**12. Home, custom duration set** — identical, but the fourth chip reads **1h 20m** and is selected.

**13. Home, first run** — streak pill reads "0 day streak". Show how the empty state avoids feeling like failure.

---

### Section 3 · Custom duration (1 screen)

**14. Custom duration sheet** — presented sheet on `background`. A large circular ring, 220pt, `elevatedSurface` track with an `accent` fill arc showing the chosen length as a fraction of the 2-hour maximum. Centred inside: **1:20** in 44pt bold rounded, with `hr : min` beneath in caption. Below the ring, two wheel pickers side by side — hours 0–2, minutes in 5-minute steps. Caption: *"Up to 2 hours."* Toolbar: Cancel left, **Set** right.

---

### Section 4 · The session (5 screens)

**15. Session running** — full-bleed looping video, no top bar, **no back button anywhere**. A single thin glass strip pinned to the bottom, radius 26, low opacity. Left: caption "Focusing" above **24:37** in 32pt bold rounded monospaced, in `danger` red. Right: **Cancel** in `danger`, headline weight. That's the whole screen. Resist adding anything.

**16. Session running, final minute** — same layout at **00:47**. Propose one restrained change that signals the end approaching without startling someone mid-task, and annotate why.

**17. Session cancelled** — the bottom panel has grown to hold a 120pt trash-can animation placeholder, *"Session cancelled"* in headline, and *"This one didn't count — start again whenever you're ready."* in caption. A **Continue** text button. The streak pill is unchanged. No guilt-tripping copy.

**18. Session complete** — same panel shape holding a 120pt trophy placeholder, *"Session complete"*, and *"8 day streak"* in caption. **Continue** button. This is the reward moment — give it room.

**19. Session complete, first ever** — the same screen when the streak becomes 1. Show how a first win reads.

---

### Section 5 · Sheets from the quick-action row (5 screens)

**20. Sounds** — presented sheet. List of ambient options (Rain · Purr · Fireplace · Ocean · Café · White noise) as rows with an icon, name, and a selected checkmark in `primary`. Show one row playing. Mark three as free and the rest with a small lock — Plus gating arrives later. **Done** in the toolbar.

**21. Room** — same sheet pattern, but a 2-column grid of room thumbnails (boxes with an X), selected one outlined in `primary`. Reminder in the annotation: **no cat or chair options may appear here.**

**22. Tasks, populated** — sheet with its own navigation bar. Rows with a checkbox, title, and completed items struck through in textSecondary. A **+** in the toolbar. **Done** to dismiss.

**23. Tasks, empty** — no tasks yet. Illustration box, a line of copy, and one clear action. Should feel like an invitation, not an error.

**24. Add task** — a compact sheet: single text field, autofocus implied, Cancel and **Add**.

---

### Section 6 · Overflow menu destinations (5 screens)

**25. Progress, with data** — sheet. A streak card at the top (large number, flame in `secondary`), then today's minutes and session count as two stat cards, then a 7-bar weekly chart in `accent` on an `elevatedSurface` track, then a short session history list. **Done** in the toolbar.

**26. Progress, empty** — no sessions ever completed. The chart still renders as an empty frame rather than vanishing, so the screen doesn't collapse.

**27. Settings** — grouped list. **The first group is account and money, because that is what people open Settings looking for:**
- **Account** — shows the signed-in email, or *"Sign in"* with a subtitle *"Sync across your devices"* when signed out
- **Plan & Billing** — right-hand detail text reads *Free* or *Plus · renews 4 Sep*

Then a second group: Sounds · Accessibility · About. Then *Replay intro*. Draw both the signed-in and signed-out variants of the top group.

**28. About** — app name, version, a one-line description, and a **Licences** row. Legal links: **Privacy Policy** and **Terms of Use**, both required.

**29. Accessibility settings** — toggles for reduced motion, haptics, and larger text guidance.

---

### Section 7 · Subscription — not built yet, v1.1 (3 screens)

These have hard legal constraints. Follow them exactly; they are App Store rejection reasons, not preferences.

**30. Paywall** — triggered after a second completed session. Two plan cards, **yearly preselected**. The **billed amount must be the largest, boldest pricing element on the screen** — `₹999 / year`. Trial wording and any per-month equivalent must be visibly smaller and positioned below it. A short benefits list (all sounds · all rooms · advanced stats · widget). One primary capsule button. Beneath it, in caption size but legible: the auto-renewal disclosure, a **Restore Purchases** text button, and links to **Terms** and **Privacy**. Close button top-left.

**31. Trial ending** — an in-app banner on Home, 2 days before conversion: *"Your trial ends Friday. You'll be charged ₹999 unless you cancel."* With a **Manage** action. Plain, unmanipulative.

**32. Plus active** — the Settings row showing an active subscription, renewal date, and **Manage Subscription**, which opens the system sheet. One tap to reach cancellation. No retention interstitial, no discount offer, no confirmation gauntlet.

---

### Section 8 · Accounts (8 screens)

Accounts are **optional**. Everything here is reachable from Settings → Account, or from one soft prompt after a completed session. There is no sign-in wall anywhere in this app.

**33. Soft account prompt** — appears once, on the session-complete screen after the user's third completed session. A short line — *"Keep your streak safe across devices?"* — with **Create an account** and an equally visible **Not now**. Both buttons must have the same visual weight. Dismissing must never re-prompt on the next session.

**34. Sign in / Sign up — combined** — one screen, not two. Modern apps do not make the user declare in advance whether they are new; the system works that out from the email. Layout:
- Wordmark and a single line of value: *"Sync your sessions across devices."*
- **Sign in with Apple** — black capsule, full width, Apple's exact wording and logo. This is the primary action and must be the top option.
- **Continue with email** — secondary capsule, `surface` fill with a `primary` border.
- **Continue without an account** — a plain text button, always visible, never greyed out.
- Beneath: *"By continuing you agree to our Terms and Privacy Policy"*, both words linked.
- No password field anywhere. No Google or Facebook buttons — if you draw one, Apple's Guideline 4.8 forces Sign in with Apple to appear as an equivalent option, and the extra provider buys nothing here.

**35. Email entry** — one field, keyboard type email, a single **Continue** button, and a back chevron. Explain what happens next in caption: *"We'll send you a 6-digit code. No password to remember."*

**36. Code entry** — six single-character boxes, auto-advancing. Shows the address it was sent to with an **edit** affordance. A **Resend code** text button that is disabled with a countdown for 30 seconds. Include the error state: wrong code, field boxes outlined in `danger`, one plain line of help text.

**37. Local data merge** — the screen most apps get wrong and then lose data over. On first sign-in, if local sessions exist: *"We found 47 sessions and a 12-day streak on this device. Keep them?"* with **Keep my data** as the primary action and **Start fresh** as a quieter secondary. Never merge silently, and never overwrite local history with an empty cloud account.

**38. Account — signed in** — Settings → Account. Shows the email address (or the Apple private relay address, in which case add a caption explaining what that is), the sign-in method, the date joined, sync status, **Sign out**, and at the bottom, visually separated, **Delete account** in `danger`.

**39. Delete account — confirmation** — Apple requires account deletion to be reachable inside the app, not by emailing support. This screen must state plainly what is destroyed and what is not: sessions, streak, tasks and account are deleted permanently; **an active subscription is not cancelled by deleting the account** and must be cancelled separately through Apple. Require typing DELETE or an equivalent deliberate action. Primary button in `danger`, cancel as the safe default.

**40. Signed-out / sync error** — the account row when a token has expired, plus an inline banner pattern for a failed sync. Copy must make clear that **local data is safe and nothing has been lost**, because that is the user's first fear.

---

### Section 9 · Plan & billing (3 screens)

Reached from Settings → Plan & Billing. These have the same hard legal constraints as the paywall.

**41. Plan & Billing — free user** — a card showing **Current plan: Free**, a short list of what Free includes, then what Plus adds. One primary **Upgrade to Plus** capsule that opens screen 30. Below it, a **Restore Purchases** text button — this must be reachable without an account, because entitlements live with the Apple ID.

**42. Plan & Billing — Plus active** — card reads **catLock Plus · Yearly**, with **Renews 4 September 2027 · ₹999/year** stated explicitly in body text, not caption. Then: **Manage Subscription** (opens the system sheet — one tap to reach cancellation), **Restore Purchases**, and links to **Terms** and **Privacy**. No retention offer, no discount interstitial, no "are you sure" gauntlet anywhere on the path out.

**43. Plan & Billing — in trial or lapsed** — two variants on one artboard. *In trial:* **Free trial · ends 4 September**, with the converting price stated in full and a **Manage Subscription** action. *Lapsed:* **Plus expired**, a plain statement that their data is untouched, and a single **Resubscribe** action. Never use urgency, countdown pressure or streak-loss threats on either.

---

### Section 10 · States that break layouts (1 screen, 3 panels)

**44.** Side-by-side variants of **Home**:
- **Reduce Motion** — static poster instead of the video. Is the glass panel still legible?
- **Largest Dynamic Type** — accessibility text sizes. Show what happens to a four-chip duration row that already fits tightly, and propose the reflow.
- **Notifications denied** — how the app behaves with no completion alert.

---

## Rules for the whole set

- Every screen must be reachable from the flow described. If you invent a screen, say so and explain why.
- Copy must be real. No lorem ipsum, no `[placeholder]`.
- The tone is calm and plain. Never scold the user for cancelling, and never use urgency, streak-loss threats, or fake scarcity anywhere.
- Flag it explicitly if any screen you draw would break one of the six product rules.
- After each section, list anything you think is missing or wrong in the flow, then stop and wait for `next`.
