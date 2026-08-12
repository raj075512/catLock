# catLock — Monetization Plan

**Last updated:** 10 August 2026
**Status:** implemented on `feature/adding-money`. StoreKit 2 purchase, restore and
entitlement are live; the paywall, trial banner and Plan & Billing screens are built.
Prices below are the *plan*; the shipping tier structure is two products, not three —
see §2.
**Prerequisite:** do not start any of this until `PLAN.md` Tier 0 and Tier 1 are done. Charging for an app whose ambient sound is silent is the fastest route to refunds and one-star reviews.

---

## 1. The strategic call: subscription yes, ads almost certainly no

You asked about both ads and subscriptions. They are not equally good fits here, and it is worth being direct about why.

### Ads are a poor fit for this specific app

Not because ads are bad, but because of what catLock *is*:

- **The product is an absence of distraction.** You built a session screen with no back button and no pause because the premise is "lock yourself with your cat." An interstitial ad after a focus session contradicts the entire product thesis. The ADHD audience is the one most harmed by an attention interrupt, and they will name this in reviews.
- **The economics don't work at your scale.** iOS rewarded video runs roughly **$19 eCPM in the US** ([RevenueFlex, 2026](https://revenueflex.com/blog/app-ad-revenue-benchmarks-2026/)) — and that is the best-paying format. Banners are far lower. At 1,000 daily active users each seeing two rewarded ads a day, you're looking at roughly $38/day gross, before Apple, before the network's cut, and before ATT reduces your fill quality. One $4.99 subscriber per 200 users beats it.
- **ATT makes it worse.** Opt-in has plateaued at about **27% globally (31% US, 22% EU)**, and unconsented traffic earns **20–40% lower eCPMs** ([RevenueFlex, 2026](https://revenueflex.com/blog/app-ad-revenue-benchmarks-2026/)). You would also have to add an ATT prompt to a first-run flow you are trying to keep calm and short.
- **It adds an SDK, a privacy-manifest entry, and a whole App Store privacy disclosure** for a revenue line that will be rounding-error at launch.

**Recommendation: no ads in v1.** If you ever revisit it, the only format I would consider is a *user-initiated* rewarded video — "watch a 30s ad to unlock this room theme for a week" — placed on the customization screen, never in the session flow, never on launch, never on completion. Ship it only if subscription conversion has plateaued and you have enough DAU for the numbers to matter (realistically 10k+).

### Subscription is the right model

The blueprint already reached this conclusion and it holds up. Focus apps have a natural recurring-value story, the cost base is near-zero per user, and the competitive set (Forest, Flora, Focus Keeper, Session) is priced the same way.

---

## 2. Pricing

**Trial-led, two tiers, annual preselected.**

> **Built:** two products — `catlock.plus.yearly` (7-day free trial) and
> `catlock.plus.monthly` (no trial), yearly preselected. The weekly tier below was
> planned but not shipped: the paywall was drawn for two cards, and its legal
> disclosure, its 32pt price and its swapping button label were all written against
> that. This document's own warning in "Read this before you commit to weekly
> pricing" is the other reason. Revisit once there is retention data.

| Product | Price | Per week | Trial |
|---|---|---|---|
| catLock Plus — weekly | **$6.59 / week** | $6.59 | 7 days free |
| catLock Plus — monthly | **$19.99 / month** | ~$4.61 | 7 days free |
| catLock Plus — annual | **$79.99 / year** | ~$1.54 | 7 days free, **preselected** |

India gets localised pricing set through App Store Connect's tier system rather than a direct conversion — a straight FX conversion of $79.99 is far above what that market converts at.

### Read this before you commit to weekly pricing

Weekly at $6.59 annualises to about **$343/year**; monthly to **$240**. That is 8–11× the $29.99/year this document previously recommended, and it puts catLock in the pricing band Apple scrutinises hardest.

- **Guideline 3.1.2 requires ongoing value.** A high weekly price on a timer app invites the reviewer to ask what recurring value justifies it. Have an answer: the sound library, room themes, stats, and widget.
- **Apple has been actively removing apps** that pair an aggressive weekly price with a hard paywall and thin functionality. The paywall must be immaculate — see §4.
- **Weekly subscribers churn fastest** in this category. Expect most weekly signups to be gone inside a month; the annual tier is where lifetime value comes from, which is why it is preselected.
- **Watch your refund rate.** Sustained high refunds on weekly plans is the signal that draws attention.

The annual tier exists partly to anchor: against $79.99/year, $6.59/week reads as the expensive convenience option, which is exactly how it should read.

### What Apple actually takes

- Standard commission is 30%, dropping to **15% after a subscriber's 12th consecutive month**.
- The **App Store Small Business Program** puts you at **15% from day one** if you earned under $1M in the prior calendar year — which is you. ([Apple](https://developer.apple.com/app-store/small-business-program/), [RevenueCat](https://www.revenuecat.com/blog/engineering/small-business-program))
- **Enrol in the Small Business Program before your first sale.** It is a form, it takes minutes, and it doubles your effective margin. This is the highest-return 15 minutes in this entire document.

At 15%, a $79.99 yearly subscription nets you about $67.99, a $19.99 month about $16.99, and a $6.59 week about $5.60.

---

## 3. What goes behind the paywall

The hard part. Gate too much and the free app can't demonstrate value; gate too little and nobody converts.

**Free forever (never gate these):**
- The core focus loop: start, run, complete, cancel. *Never* charge for the thing the app is for.
- 15 / 25 / 45 minute presets.
- The cat, the default room, the completion and cancel animations.
- Basic streak and today's session count.
- Tasks.

**catLock Plus:**
- **Custom durations** — you already built the dial, and "I need 90 minutes for this exam" is a real willingness-to-pay moment.
- **The full sound library** — 3 free, the rest Plus. Sound is the clearest "more of a good thing" upsell.
- **Additional rooms / scenes** — the free tier gets one; themes are Plus.
- **Advanced stats** — weekly and monthly breakdowns, best-focus-time analysis, history beyond 7 days.
- **Home screen widget** — a well-established Plus feature in this category.
- *Later:* cloud sync across devices, once a backend exists.

A note on gating the custom duration picker: it is currently free and prominent on the landing screen. Moving a shipped free feature behind a paywall generates real anger. **Decide before v1.0 ships**, not after. If you're unsure, ship it free and gate the *2-hour+* range later instead — extending a limit reads very differently from taking something away.

---

## 3a. The trial, end to end

**Seven days free on every tier.** The trial is the primary conversion mechanism, so the three moments below matter more than the paywall itself.

### Home — trial-forward, never a wall

The Home CTA reads **"Try 7 days free"** with *"then $19.99/month · cancel any time"* beneath it. Directly under that sits **"Start a free session"** as a plain text button.

That second button is not optional. Starting a focus session must never require a subscription:

- **Guideline 4.2 (minimum functionality)** and **3.1.2** both bite when an app's core purpose is locked behind payment before any value is shown.
- The audience is people who struggle to start tasks. A payment demand between them and a timer is precisely the friction the product exists to remove.
- It is also worse economically. Trial starts from people who have never felt the product convert badly and refund often.

### Locked sounds raise the offer, and always offer a way out

Tapping a Plus sound presents a sheet naming the specific thing they wanted — *"Fireplace is part of Plus"* — with exactly two actions: **Try 7 days free**, and **Not now**. Never a dead end, never a dismissal that is hard to find, never a second prompt in the same session after they decline.

This is the highest-intent paywall in the app. Someone who taps Fireplace has told you what they want.

### Trial ended — "Keep your streak safe"

The conversion screen, shown once when the trial lapses. It leads with the streak they built, not with the price, and states plainly:

> Your 7 free days are up. Your sessions, tasks and 12-day streak are still here — they stay whether or not you subscribe.

Then annual and monthly, **Continue with Plus**, and **Keep using catLock free** as a real, visible option.

**Do not threaten the streak.** "Subscribe or lose your progress" converts a little better and earns one-star reviews from exactly the audience you are courting. Deleting someone's history because a card expired is also the kind of thing that generates refund requests and, for an app marketed to people with ADHD, is straightforwardly unkind.

### Trial reminders are not optional here

At $6.59/week, an unexpected charge is the difference between a subscriber and a chargeback. Schedule a local notification **48 hours before conversion** stating the amount and the date, show an in-app banner for anyone who declined notifications, and keep the conversion date visible in Settings for the whole trial. See `legal/COMPLIANCE.md` §3.

## 4. Paywall placement

The blueprint's analysis here is good and I'd follow it almost exactly.

| Trigger | When | Verdict |
|---|---|---|
| **After 2 completed sessions** | The user has felt the value and has a streak worth protecting | ✅ **Primary trigger.** Use this. |
| Tap a premium sound | Clear intent | ✅ Contextual paywall |
| Tap a premium room/theme | Clear intent | ✅ Contextual paywall |
| Tap advanced stats | Clear intent | ✅ Good secondary trigger |
| Settings → Upgrade | Always available | ✅ Table stakes, low volume |
| **First launch** | Max exposure | ❌ **Don't.** Highest install-to-uninstall driver there is, and for an ADHD audience an immediate payment demand is exactly the friction that makes people close an app forever. |
| Streak recovery offer | Retention lifecycle | ⏳ Post-launch experiment |

**Hard rules:**
- Never interrupt a running session with a paywall. Not once.
- The paywall appears **on top of** the completion screen, never instead of it — the
  trophy and the streak land first, and the sheet arrives over them.
- Never after a *cancelled* session. Asking for money straight after someone gave up
  is the worst possible read of the room.
- Once, automatically. If they dismiss it, that's an answer; afterwards it is
  reachable only from Plan & Billing or by tapping a lock.

> This section previously read "never show a paywall on the completion screen",
> which directly contradicted wireframe 30 ("triggered on top of 18") and wireframe
> 18 ("the paywall is presented on top of this screen, not instead of it"). The
> wireframe won — it is the more specific artefact and the one screens 1–29 were
> built against. Enforced by `PaywallTrigger` and pinned by `PaywallTriggerTests`.

---

## 5. Implementation: StoreKit 2, not RevenueCat (for now)

The blueprint specifies RevenueCat with an entitlement named `gocat_plus`. I'd push back for v1.

**Use StoreKit 2 directly.** For one platform, two products, and one entitlement, StoreKit 2's modern async API (`Product.products(for:)`, `Transaction.currentEntitlements`, `Transaction.updates`) is roughly 200 lines and has no dependency, no third-party pricing tier, and no extra privacy disclosure. `StoreKitService.swift` already starts down this road.

**Move to RevenueCat when** you add Android, want server-side receipt validation you don't maintain, need subscription analytics dashboards, or start running pricing/paywall experiments. All of those are real reasons — none of them apply to a single-platform v1.

If you do adopt RevenueCat later, keep the entitlement name `gocat_plus` as the blueprint specifies so nothing has to be renamed.

**Shape of the work:**

```
Services/Purchases/
  StoreKitService.swift      # load products, purchase, listen to Transaction.updates
  PremiumAccessService.swift # single source of truth: hasPremiumAccess
  PurchaseError.swift        # user-facing failure mapping
Features/Paywall/
  PaywallView.swift          # yearly preselected, trial badge, feature list
  PaywallViewModel.swift
```

Non-negotiables, all of which are App Review rejection reasons:
- A visible **Restore Purchases** button.
- Price, billing period, and renewal terms shown **before** purchase.
- Links to your Terms and Privacy Policy on the paywall itself.
- Trial terms stated plainly: what it costs, when it converts, how to cancel.
- Entitlement re-verified on launch via `Transaction.currentEntitlements` — never trust a cached Bool.

---

## 6. The long game

**Months 0–3 — validate.** Ship free, instrument the funnel, learn whether people come back on day 7. Retention with no paywall is the cleanest signal you will ever get. If D7 retention is under ~10%, monetization is not your problem and no paywall will save it.

**Months 3–6 — introduce Plus.** Launch with the trigger set above. Watch trial-start and trial-conversion rates separately; they fail for different reasons. Target for this category: 2–5% of active users on a paid plan. Under 1% means the gating is wrong, not the price.

**Months 6–12 — expand.** Seasonal room packs and cat themes (the blueprint's post-launch list) are the natural Plus retention drivers. Consider a lifetime tier *only* once you know your average subscription lifetime — price it at roughly 2.5× the yearly.

**Year 2 — reconsider platform.** Android roughly doubles the addressable market and is the point where RevenueCat starts paying for itself. A Mac catalyst build is nearly free given the iOS-only SwiftUI codebase and reaches the "I focus at my desk" user.

**What to watch, in order of importance:** D1/D7/D30 retention → sessions completed per weekly active user (the blueprint's core metric, and it's the right one) → paywall view-to-trial rate → trial-to-paid rate → churn. Revenue is the output; the first two are what you can actually move.

---

## 7. Compliance checklist before the first paid build

- [ ] Enrol in the App Store Small Business Program (15% vs 30%)
- [x] StoreKit 2 purchase, restore and entitlement implemented (`Services/Purchases/`)
- [x] Paywall carries close, full auto-renewal disclosure, Restore, Terms and Privacy above the fold
- [x] Paywall sells only what exists — the widget and advanced-stats lines are omitted until built
- [ ] Create subscription group + monthly/yearly products in App Store Connect
- [ ] Privacy Policy and Terms of Service, publicly hosted, linked in-app and on the listing
- [ ] Support URL (required for the listing)
- [ ] Restore Purchases implemented and visibly reachable
- [ ] Sandbox-test: purchase, restore, cancel, expiry, upgrade monthly→yearly, refund
- [ ] Complete the App Store privacy questionnaire honestly (StoreKit alone collects nothing extra; an ad SDK would change every answer)
- [ ] Account deletion — **only required if you add accounts.** No accounts in v1 means this is not yet applicable. It becomes mandatory the moment Supabase auth lands. ([Apple](https://developer.apple.com/support/offering-account-deletion-in-your-app/))
- [ ] Confirm tax and banking setup in App Store Connect (for India-based receipts, budget for the GST/FIRC advice the blueprint already allocated)

---

**Sources:**

- [App Store Small Business Program — Apple Developer](https://developer.apple.com/app-store/small-business-program/)
- [The 15% App Store Fee: A Guide for Developers (2026) — RevenueCat](https://www.revenuecat.com/blog/engineering/small-business-program)
- [App Ad Revenue Benchmarks 2026: eCPMs by Format, Region, and Platform — RevenueFlex](https://revenueflex.com/blog/app-ad-revenue-benchmarks-2026/)
- [Offering Account Deletion in Your App — Apple Developer](https://developer.apple.com/support/offering-account-deletion-in-your-app/)
- [App Review Guidelines — Apple Developer](https://developer.apple.com/app-store/review/guidelines/)
