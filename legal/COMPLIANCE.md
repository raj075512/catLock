# catLock — Billing & Subscription Compliance

> **⚠️ Not legal advice.** This is an engineering and operations checklist for not getting rejected, refunded, or fined. Have a lawyer review the documents it references.

**Scope:** the rules that apply the moment catLock starts charging money. None of this applies to a free version — but **all of it applies from the first paid build**, so read it before you write the paywall, not after it's rejected.

---

## 1. Why this document exists

Subscription apps get punished in three separate ways, by three different bodies, for the same mistakes:

1. **Apple** rejects your build (App Review Guideline 3.1.2). Costs you a week per round trip.
2. **Regulators** fine you (FTC/ROSCA in the US, state auto-renewal laws, EU consumer directives, India's Consumer Protection Act).
3. **Users** charge back and leave one-star reviews, which is slower and more expensive than either.

The good news: satisfying Apple's rules gets you most of the way to satisfying the regulators. The rules exist because the same dark patterns keep recurring — hiding the price, burying the renewal, making cancellation hard.

---

## 2. Auto-renewal disclosure

**The rule:** before a user can complete a purchase, they must see — on screen, without scrolling, without tapping "more" — what they are buying, what it costs, how often it recurs, and that it recurs *automatically*.

### 2.1 What must appear on the paywall

Apple requires all of the following **in the app binary itself**, not only in App Store Connect metadata:

- [ ] **Title** of the subscription — "catLock Plus"
- [ ] **Length** of the subscription period — "1 month" / "1 year"
- [ ] **Price** of the subscription, and price-per-unit if you show one
- [ ] **Functional link to the Privacy Policy**
- [ ] **Functional link to the Terms of Use / EULA**

Both links must actually work in the shipped build. A dead link here is one of the most common 3.1.2 rejections.

### 2.2 The pricing-prominence rule

This is where most apps get rejected, and it is subtle:

> **The total amount the user will be billed must be the most clear and conspicuous pricing element on the screen.** Free trial wording and calculated "per month" breakdowns must be *subordinate* in both position and size.

So this is a rejection:

```
        7 DAYS FREE          ← biggest text on screen
     then ₹999/year          ← small grey text underneath
```

And this is fine:

```
        ₹999 / year          ← biggest, boldest element
   Includes a 7-day free trial
     (≈ ₹83/month)           ← smaller, subordinate
```

Same offer. One ships, one doesn't.

### 2.3 Required disclosure text

Place this near the purchase button, legibly — not in a collapsed section, not at 9pt grey-on-grey:

> catLock Plus is an auto-renewing subscription. Payment is charged to your Apple ID at confirmation of purchase. **Your subscription renews automatically unless auto-renew is turned off at least 24 hours before the end of the current period.** Your account is charged for renewal within 24 hours before the period ends. You can manage or cancel your subscription in your device Settings → [your name] → Subscriptions. Deleting the app does not cancel your subscription.

- [ ] Present on the paywall
- [ ] Present in the App Store listing description
- [ ] Present in `TERMS_OF_USE.md` §8
- [ ] Consistent across all three — a mismatch is its own rejection reason

### 2.4 The "ongoing value" test

Guideline 3.1.2 requires a subscription to deliver **ongoing value**, last at least **seven days**, and work **across all the user's devices**.

catLock Plus as scoped in `MONETIZATION.md` (full sound library, extra rooms, advanced stats, widget) passes. But note the third clause: **"across all the user's devices."** With no accounts and no cloud sync, a user who buys Plus on their iPhone and installs on their iPad restores entitlement through their Apple ID — this works via StoreKit, but **only if you implement Restore Purchases correctly**. Reviewers do test this.

---

## 3. Free-trial reminders

**Apple does not send a "your trial ends tomorrow" reminder for standard introductory offers.** Users may receive a renewal receipt, but there is no guaranteed pre-charge warning. Unexpected charges after a forgotten trial are the single largest driver of chargebacks and angry reviews in this category.

### 3.1 What the law increasingly requires

- **California's amended auto-renewal law** requires advance notice before charging after a free trial, and is treated as the de facto national US standard because compliance there is simplest to apply everywhere.
- **The FTC's "click-to-cancel" Negative Option Rule was vacated** by the Eighth Circuit on 8 July 2025 on procedural grounds — but this changed **less than headlines suggested**. Enforcement continues under **ROSCA**, Section 5 of the FTC Act, and state UDAP laws, and the FTC reopened rulemaking with comments due April 2026. Building to the vacated rule's standard is the safe course; it is likely to return in some form.
- The **EU Consumer Rights Directive** and India's **Consumer Protection Act 2019** both prohibit charging without clear prior disclosure.

### 3.2 What to build

**Send your own reminder. It is the highest-ROI compliance work you can do, and it also reduces churn.**

- [ ] Schedule a **local notification 48 hours before the trial converts** — no server needed, you already have `LocalNotificationService` and notification permission
- [ ] Copy, plainly: *"Your catLock Plus trial ends in 2 days. You'll be charged ₹999 on [date] unless you cancel."* Include the amount and the date.
- [ ] Show an **in-app banner** during the final 48 hours for users who denied notifications
- [ ] Put a **"Trial ends [date]"** row in Settings, visible for the whole trial
- [ ] Make sure the reminder includes a **direct link to the cancellation screen** (§5)

> **Note the tension with `MONETIZATION.md`:** ideally you'd remind the user before charging, but you can only send a local notification if they granted permission. Request notification permission *after* the second completed session — well before any trial — and this works. Another reason not to burn the prompt during onboarding.

### 3.3 Trial mechanics to get right

- [ ] One trial per Apple ID — StoreKit enforces this; check eligibility with `Product.SubscriptionInfo.isEligibleForIntroOffer` and **don't advertise a trial to someone who can't have one** (rejection reason)
- [ ] Trial length, converting price, and conversion date all shown before purchase
- [ ] Cancelling during the trial keeps access until the trial ends
- [ ] Never describe it as "free" without immediately stating what happens when it isn't

---

## 4. Apple and Google billing rules

### 4.1 Apple — mandatory today

| Rule | Requirement | Status |
|---|---|---|
| **In-App Purchase only** | Digital content and features unlocked in the app **must** use Apple's IAP. You may not link to your own payment page, take UPI/Razorpay, or mention cheaper prices elsewhere. | ⬜ |
| **No "buy on our website"** | Do not tell users to subscribe outside the app. Rules on external link entitlements vary by region and change frequently; **do not attempt this without checking the current guidelines for each storefront.** | ⬜ |
| **Restore Purchases** | Must exist and be reachable without an account. Reviewers test on a second device. | ⬜ |
| **Subscription group** | Monthly and yearly in **one group** so users can switch tiers instead of double-subscribing | ⬜ |
| **Price shown in local currency** | StoreKit handles this — always display `product.displayPrice`, never a hardcoded string | ⬜ |
| **No feature loss on refund** | Handle revoked transactions gracefully via `Transaction.updates` | ⬜ |
| **Entitlement verified on launch** | Check `Transaction.currentEntitlements`, never trust a cached Bool | ⬜ |
| **Small Business Program** | Enrol before your first sale — 15% instead of 30% | ⬜ |

**Indian tax specifics** (Apple handles collection, you handle declaration):
- Apple acts as merchant of record in most territories and remits VAT/GST where required
- You must still complete **tax and banking** in App Store Connect: PAN, bank account, and the tax forms for each territory
- Foreign earnings arriving in India generally need **FIRC/FIRA** documentation for your bank
- Consult a CA about GST registration on export of services — the Excel budget already allows for this

### 4.2 Google Play — not applicable yet, but here for when Android ships

catLock is iOS-only. If an Android build happens, the equivalents are:

| Apple | Google Play |
|---|---|
| StoreKit 2 | Google Play Billing Library (must be a **current** version — Google deprecates aggressively and blocks updates on old ones) |
| App Review Guideline 3.1.2 | Play Console **Subscriptions policy** |
| Small Business Program (15%) | **15% on the first $1M** of annual revenue, automatic |
| Restore Purchases | `queryPurchasesAsync` on launch |
| Settings → Subscriptions | Play Store → Payments & subscriptions |

Two differences that actually bite:
1. **Google requires a Data Safety form** in Play Console — similar to Apple's privacy label but separately worded and separately enforced. Answers must match your privacy policy.
2. **Google requires an in-app link to manage the subscription**, deep-linking to the Play subscription centre. Apple only recommends it; Google expects it.

---

## 5. Cancellation must be simple

**The principle:** cancelling must be no harder than subscribing. If subscribing is two taps, cancelling should be about two taps.

### 5.1 What you must not do

Every one of these is a documented dark pattern and a regulatory target:

- ❌ Requiring an email, phone call, or chat with support to cancel
- ❌ Hiding the cancel option in a submenu of a submenu
- ❌ Multi-step "are you sure?" gauntlets with guilt-trip copy
- ❌ Offering a discount and treating dismissal of it as a cancelled cancellation
- ❌ Making the "keep subscription" button large and "cancel" a small grey link
- ❌ Cancelling access immediately on cancellation instead of at period end

### 5.2 What to build

On iOS, Apple owns the cancellation flow — you cannot cancel a subscription from inside your app. What you *can* do is make finding it trivial:

- [ ] **Settings → Manage Subscription** row in catLock, always visible to subscribers
- [ ] It calls `showManageSubscriptions(in:)` (StoreKit 2), which opens the native sheet **directly** — one tap, no Safari detour
- [ ] Fallback for older iOS: open `https://apps.apple.com/account/subscriptions`
- [ ] Same link in the trial-reminder notification
- [ ] Plain-language explanation next to it: *"Cancel any time. You'll keep Plus until [date]."*
- [ ] **No retention interstitial.** If you later add a "before you go, here's 50% off" offer, it must be dismissible in one tap and must not block the path.

### 5.3 After cancellation

- [ ] Access continues to the end of the paid period — never revoke immediately
- [ ] No feature that existed in the free tier is ever taken away
- [ ] **User data is never deleted for lapsing.** Sessions, streaks and tasks belong to the user. Losing a 90-day streak because a card expired is the kind of thing people write reviews about.
- [ ] Re-subscription restores Plus instantly with no data loss

---

## 6. Hosting the documents

You need `TERMS_OF_USE.md` and `PRIVACY_POLICY.md` at **stable public URLs**. App Store Connect requires them, and the links must work from anywhere in the world, forever, without a login.

### 6.1 The cheapest reliable option

**GitHub Pages — free, permanent, version-controlled:**

1. Create a public repo, e.g. `catlock-legal`
2. Add `privacy.md` and `terms.md`
3. Settings → Pages → deploy from `main`
4. You get `https://<username>.github.io/catlock-legal/privacy`
5. Optionally point a custom domain at it

Because the source lives in git, you get a dated history of every change — genuinely useful if anyone ever asks what your policy said on a given date.

**Alternatives:** Notion public pages (fast, but URLs are ugly and Notion can change how public pages work), Carrd (~$19/yr), or a page on your own domain. A custom domain costs $10–50/yr per the Excel budget and looks materially more legitimate on the listing.

### 6.2 Using Termly (as you asked)

Termly is a policy generator with a free tier. **How to use it:**

1. Go to [termly.io](https://termly.io) and create a free account
2. Choose **Privacy Policy** → platform **Mobile app**
3. Answer the questionnaire. **For catLock v1.0 the answers are almost all "no"** — no analytics, no ads, no accounts, no location, no third-party data sharing. Use §3 of `PRIVACY_POLICY.md` as your answer key.
4. Generate, then either host on Termly's URL or copy the HTML to your own site
5. Repeat for **Terms & Conditions**
6. Termly can host at `app.termly.io/document/...` on the free tier; a custom domain usually needs a paid plan

**Honest assessment of generators, since you asked:**

They are a reasonable starting point and much better than nothing. But they have real limits you should know about:

- **They generate generic documents.** A questionnaire cannot know that your app requests notification permission and never uses it, that your streak counter is mislabelled, or that you market to an ADHD audience and therefore need the "not a medical device" clause. The documents in this folder are catLock-specific for exactly that reason.
- **They tend to over-declare.** Generators frequently include clauses about cookies, web beacons, and third-party advertising partners that do not apply to a fully offline iOS app. Declaring collection you don't perform creates obligations you then have to honour, and it turns your best marketing line — "collects nothing" — into a wall of boilerplate that says the opposite.
- **They don't cover India well.** Most generators are built around GDPR and CCPA. DPDP Act specifics — Data Fiduciary duties, the under-18 rule, 72-hour breach reporting — are usually thin or absent.
- **The free tier is limited** and typically requires a "Powered by Termly" badge.

**Recommended approach:** use Termly's output as a **cross-check**, not as your document. Generate one, diff it against the drafts here, and if Termly includes a clause these drafts don't, work out whether it applies to you. Then have an advocate review the merged result. Generator + human review is meaningfully cheaper than human-from-scratch, and much safer than generator alone.

### 6.3 Where each URL goes

| Location | Terms | Privacy |
|---|---|---|
| App Store Connect → App Information | EULA URL | Privacy Policy URL (**required**) |
| App Store Connect → App Privacy | — | Must match your declared label |
| In-app: Settings → About | ✅ | ✅ |
| **In-app: paywall screen** | ✅ **required by 3.1.2** | ✅ **required by 3.1.2** |
| Your marketing site, if any | ✅ | ✅ |

---

## 7. Pre-submission checklist for the first paid build

**Paywall**
- [ ] Title, length, price, both links present and working
- [ ] Billed amount is the most prominent element on screen
- [ ] Auto-renewal disclosure visible without scrolling
- [ ] Restore Purchases button present
- [ ] Trial only advertised to eligible users
- [ ] Prices from `product.displayPrice`, never hardcoded

**Trial**
- [ ] Local reminder scheduled 48h before conversion
- [ ] Settings shows the conversion date throughout the trial
- [ ] Reminder deep-links to cancellation

**Cancellation**
- [ ] `showManageSubscriptions(in:)` wired to a visible Settings row
- [ ] No retention gauntlet
- [ ] Access persists to period end; data survives lapse

**Store & tax**
- [ ] Subscription group with both products
- [ ] Small Business Program enrolment submitted
- [ ] Tax forms, PAN and banking complete in App Store Connect
- [ ] CA consulted on GST / export of services / FIRC

**Documents**
- [ ] Terms and Privacy hosted, public, permanent
- [ ] Both linked in App Store Connect, in-app, and on the paywall
- [ ] Privacy label matches the privacy policy exactly
- [ ] `PrivacyInfo.xcprivacy` present in the app bundle

**Sandbox testing** (all of it, on a real device)
- [ ] Purchase monthly · purchase yearly · start trial
- [ ] Trial converts to paid · cancel during trial · cancel after paid
- [ ] Restore on a second device · restore after reinstall
- [ ] Upgrade monthly → yearly · refund revokes entitlement
- [ ] Expiry downgrades to free without data loss

---

**Sources:**

- [App Review Guidelines — Apple Developer](https://developer.apple.com/app-store/review/guidelines/)
- [Auto-renewable Subscriptions — Apple Developer](https://developer.apple.com/app-store/subscriptions/)
- [Eighth Circuit Vacates FTC's Click-to-Cancel Rule — Latham & Watkins](https://www.lw.com/en/insights/eighth-circuit-vacates-ftc-click-to-cancel-rule-days-before-compliance-deadline)
- [FTC Restarts Negative Option Rulemaking After Eighth Circuit Vacatur — Gibson Dunn](https://www.gibsondunn.com/ftc-restarts-negative-option-rulemaking-after-eighth-circuit-vacatur-enforcement-under-rosca-continues/)
- [Clicking All the Right Boxes: FTC Moves to Revive Click-to-Cancel — Crowell & Moring](https://www.crowell.com/en/insights/client-alerts/clicking-all-the-right-boxes-ftc-moves-to-revive-click-to-cancel-rule-following-eighth-circuit-vacatur)
- [App Store Small Business Program — Apple Developer](https://developer.apple.com/app-store/small-business-program/)
