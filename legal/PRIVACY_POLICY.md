# catLock — Privacy Policy

> **⚠️ Not legal advice.** Draft for a lawyer to review. Fill every `[[PLACEHOLDER]]` before publishing.
>
> **The single most important rule in this document:** declare what you *actually* do, not what you plan to do. Over-declaring is a compliance problem (you must then honour rights requests for data you never held). Under-declaring is a worse one — App Store rejection, and under India's DPDP Act penalties reaching **₹250 crore** for security failures. Keep §3 and §4 accurate as the App changes.

**Effective date:** `[[DD MONTH YYYY]]`
**Last updated:** `[[DD MONTH YYYY]]`
**Applies to:** catLock for iOS, all versions, worldwide.

---

## 1. Summary in plain language

**As of version 1.0, catLock collects nothing.**

Everything the App knows about you — your sessions, your streak, your tasks, your chosen room and sound — is stored on your device and nowhere else. There is no account, no server, no analytics, no advertising, no tracking. Delete the App and every trace of your data is gone.

That is unusual, it is deliberate, and it is worth saying out loud on your App Store listing.

This policy also describes, in **Part B**, what would change if we later add optional accounts, cloud sync, subscriptions or analytics. **None of Part B is active today.** We will update this policy and the effective date before any of it becomes true, and where the law requires it, we will ask for your consent first.

## 2. Who is responsible for your data

`[[YOUR FULL LEGAL NAME]]`, `[[ADDRESS, CITY, STATE, PIN, India]]`
Email: `[[privacy@yourdomain.com]]`

Under the **EU/UK GDPR** we are the "data controller". Under **India's Digital Personal Data Protection Act, 2023** we are the "Data Fiduciary". Under the **CCPA/CPRA** we are a "business".

Because catLock is available worldwide, we apply the strictest applicable standard globally rather than varying our practices by country.

`[[If you appoint an EU or UK representative under GDPR Art. 27, name them here. Required only once you process EU/UK personal data at scale — not applicable while Part A holds true.]]`

---

# PART A — What version 1.0 actually does

## 3. Complete data inventory

Every category of personal data that exists, with an honest status. "Collected" means it leaves your device or is accessible to us. **Nothing in this table is collected.**

### 3.1 Stored on your device only — never transmitted

| Data point | Where | Why | Leaves device? |
|---|---|---|---|
| Focus session records (start time, planned duration, completed or cancelled) | `UserDefaults` / local database | Show your history and stats | **No** |
| Streak count | `UserDefaults` | Show your streak | **No** |
| Tasks you type | Local memory / local database | The task list feature | **No** |
| Selected room / scene | `UserDefaults` | Remember your preference | **No** |
| Selected ambient sound | `UserDefaults` | Remember your preference | **No** |
| Preferred session length | `UserDefaults` | Remember your preference | **No** |
| Onboarding completed flag | `UserDefaults` | Don't show onboarding twice | **No** |
| Notification permission state | iOS system | Decide whether to schedule alerts | **No** |
| Accessibility preferences (Reduce Motion, Dynamic Type) | Read from iOS | Adapt the interface | **No** |

**Note on device backups.** If you have iCloud Backup or encrypted iTunes/Finder backup enabled, the above data may be included in your device backup. That backup is between you and Apple, governed by Apple's privacy policy. We have no access to it and cannot read it.

### 3.2 Explicitly NOT collected

Stated individually, because "we don't collect much" is not a disclosure. We do not collect, access, request, infer, store or transmit:

| Category | Status |
|---|---|
| **Name** | ❌ Never collected. There is no name field in the App. |
| **Email address** | ❌ Never collected. No account, no sign-up, no newsletter. |
| **Phone number** | ❌ Never collected. |
| **Postal address** | ❌ Never collected. |
| **Date of birth / age** | ❌ Never collected. |
| **Precise location (GPS)** | ❌ Never collected. The App does not link against Core Location and cannot request it. |
| **Coarse / approximate location** | ❌ Never collected. |
| **IP address** | ❌ Not collected by us. The App makes no network requests. |
| **Photos / camera** | ❌ No access requested. The App cannot open your camera or photo library. |
| **Microphone / audio recording** | ❌ No access requested. Ambient sound is playback only; nothing is recorded. |
| **Contacts / address book** | ❌ No access requested. |
| **Calendar / reminders** | ❌ No access requested. |
| **Health / HealthKit data** | ❌ No access requested. catLock is not a health app. |
| **Motion / fitness sensors** | ❌ No access requested. |
| **Device identifiers (IDFA / IDFV)** | ❌ Not collected. No advertising identifier is read. |
| **Advertising / marketing data** | ❌ None. The App contains no ads and no ad SDK. |
| **Usage analytics / behavioural events** | ❌ No analytics SDK is integrated. |
| **Crash logs** | ❌ Not collected by us. If you have opted in to Apple's device-level analytics sharing, Apple may send anonymised crash reports; that is Apple's process, under your control in **Settings → Privacy & Security → Analytics & Improvements**. |
| **Purchase / payment data** | ❌ Not collected by us. No purchases exist in v1.0. |
| **Biometrics (Face ID / Touch ID)** | ❌ Not used. |
| **Browsing / search history** | ❌ Not collected. The App has no browser or search. |
| **Social media accounts** | ❌ No social login, no sharing integration. |
| **Files / documents** | ❌ No file system access outside the App's own sandbox. |
| **Network / carrier information** | ❌ Not collected. |
| **Keyboard input outside the App** | ❌ Impossible — iOS does not permit it and we do not attempt it. |

### 3.3 Permissions the App requests

| Permission | Requested? | Purpose | Consequence of declining |
|---|---|---|---|
| **Notifications** | Yes, once | Alert you when a focus session ends | The App works normally; you simply get no completion alert |
| Location | No | — | — |
| Camera | No | — | — |
| Photos | No | — | — |
| Microphone | No | — | — |
| Contacts | No | — | — |
| Calendar | No | — | — |
| Health | No | — | — |
| Bluetooth | No | — | — |
| Tracking (ATT) | No | — | — |

> **Implementation note.** The App currently requests notification permission during onboarding but never sends a notification (see `ONBOARDING.md`). That is a defect, not a privacy risk — but until it is fixed, the table above overstates the reason for the request. Fix the code, don't edit the table.

## 4. Third-party components

| Component | What it is | Data it sends | Privacy manifest |
|---|---|---|---|
| **Lottie** (airbnb/lottie-spm 4.6.1) | Animation renderer, MIT licence | **None.** Renders bundled files offline. No network access. | Bundled with the SDK |
| **AVFoundation, SwiftUI, UserNotifications, StoreKit** | Apple system frameworks | None beyond normal OS operation | N/A — first-party |

There are **no** analytics SDKs, no advertising SDKs, no attribution SDKs, no crash-reporting SDKs, and no social SDKs.

> **Keep this current.** Every SDK you add must be added here, and any SDK using a "required reason API" must ship its own `PrivacyInfo.xcprivacy` — it cannot rely on yours. Missing manifests are an automatic App Store rejection ([Apple Developer](https://developer.apple.com/documentation/bundleresources/adding-a-privacy-manifest-to-your-app-or-third-party-sdk)).

## 5. Children

catLock is not directed at children under 13 and we do not knowingly collect data from them. Since v1.0 collects no data from anyone, no child's data is collected either.

Under India's DPDP Act, anyone under **18** is a child, and processing their personal data requires verifiable parental consent and prohibits behavioural advertising and tracking directed at them. Because we do no tracking and no behavioural advertising at all, we comply by construction. If we ever add accounts, age assurance becomes a genuine engineering requirement — flagged in Part B.

## 6. Your rights

Rights under GDPR, CCPA/CPRA, the DPDP Act and comparable laws include access, correction, deletion, portability, objection, restriction, withdrawal of consent, and non-discrimination for exercising them.

**In v1.0 you can exercise all of these yourself, instantly, without contacting us:**

| Right | How to exercise it |
|---|---|
| **Access** your data | It is on your device. There is no copy anywhere else. |
| **Delete** your data | Delete the App. All data is removed with it. |
| **Correct** your data | Edit it in the App. |
| **Port** your data | `[[Not yet supported — an export feature is on the roadmap]]` |
| **Withdraw consent** | Revoke notification permission in iOS Settings. |
| **Object to / opt out of sale or sharing** | Nothing is sold or shared. There is nothing to opt out of. We do not sell personal data, and have never done so. |

If you want to make a formal request anyway, write to `[[privacy@yourdomain.com]]`. We will respond within **30 days** (GDPR allows one month, extendable to three for complex requests; the DPDP Act and CCPA have comparable windows). We will not charge you and will not treat you differently for asking.

**Complaints.** If you are unhappy with our response you may complain to your local supervisory authority — in the EU, your national Data Protection Authority; in the UK, the ICO; in India, the Data Protection Board of India.

## 7. Security

Data never leaves your device, which removes most of the risk. Beyond that:

- Data at rest is protected by **iOS file-system encryption** whenever your device has a passcode set. Set a passcode.
- The App includes advisory **jailbreak and debugger detection** (`AppSecurityManager`) and does not weaken iOS's App Transport Security.
- Any future sensitive value will be stored in the **iOS Keychain** (`KeychainStore`), not in `UserDefaults`.
- The App makes **no network requests**, so there is no transmission to intercept.

**No system is perfectly secure.** If we ever hold data on a server and a breach occurs, India's DPDP Rules require us to notify affected users and the Data Protection Board **without delay**, with a detailed report within **72 hours** — a commitment we make here, and one that is only operationally meaningful once Part B activates.

## 8. Data retention

Local data persists until you delete it or delete the App. We hold nothing, so we retain nothing.

---

# PART B — Not active today

> ⚠️ **Nothing in Part B currently applies.** It is published in advance so you can see the direction of travel. Before any of it becomes true we will update this policy, change the effective date, notify you in-App, and where the law requires it, request your consent.

## 9. If we add subscriptions (catLock Plus)

**Would be collected:** purchase status and entitlement, transaction identifier, subscription tier, renewal and expiry dates.

**Would not be collected:** your card number, billing address, or any payment credential. **Apple processes all payments; we never see payment details.**

Legal basis: performance of a contract (GDPR Art. 6(1)(b)) / necessary for the service (DPDP). Purchase records are retained as long as required by Indian tax and accounting law — typically **8 years** — and cannot be deleted on request during that period, as retention is a legal obligation.

## 10. If we add analytics

**Would be collected:** anonymised or pseudonymised usage events (app opened, session started, session completed, paywall viewed), app version, device model, OS version, coarse country.

**Would never be collected:** task contents, session notes, or anything you type.

Legal basis: consent. We would ask before enabling it, offer a clear opt-out in Settings, and default it **off** for users in the EU, UK and India. The DPDP Act has **no "legitimate interests" basis** — for Indian users, consent is the only route, and it cannot be a condition of using the App.

## 11. If we add accounts and cloud sync

**Would be collected:** email address (or an Apple relay address via Sign in with Apple), a user identifier, and your synced sessions, tasks and preferences.

This is the change that triggers the heaviest obligations:

- **In-App account deletion becomes mandatory** under Apple's rules — an app that supports account creation must let you delete the account from within the App, not merely by emailing support ([Apple Developer](https://developer.apple.com/support/offering-account-deletion-in-your-app/)).
- International transfer safeguards, because a database in one country serving users in another triggers GDPR Chapter V.
- Age assurance for the DPDP Act's under-18 rule.
- Real breach-notification capability.

**Recommendation: stay account-free as long as you can.** "Your data never leaves your phone" is both a genuine competitive advantage for a focus app and an enormous reduction in legal surface area.

## 12. If we add advertising

We do not currently plan to (see `MONETIZATION.md`). If we ever did, it would require: an App Tracking Transparency prompt, a rewritten Apple privacy label including "Data Used to Track You", CCPA "sale/sharing" opt-out mechanics, and a materially longer version of this policy. We would notify you clearly before any of it shipped.

---

## 13. Changes to this policy

Material changes will be announced in-App and by updating the effective date. The current version is always at `[[https://yourdomain.com/privacy]]`.

## 14. Contact

`[[YOUR FULL LEGAL NAME]]` · `[[ADDRESS]]` · `[[privacy@yourdomain.com]]`

---

# Appendix A — Apple "Privacy Nutrition Label" answers

Copy these into App Store Connect → App Privacy. **For version 1.0, the entire questionnaire is answered by one selection:**

> ### **"Data Not Collected"** ✅

Choose that and you are done. Do not tick anything else. If you are tempted to declare something "just to be safe" — don't; an inaccurate label is itself a violation.

**When Plus ships**, the answers change to:

| Apple category | Collected | Linked to you | Used for tracking | Purpose |
|---|---|---|---|---|
| Purchases | Yes | No | No | App Functionality |
| Identifiers → User ID | Yes | Yes | No | App Functionality |
| Usage Data → Product Interaction | Only with consent | No | No | Analytics |
| Diagnostics → Crash Data | Only with consent | No | No | App Functionality |
| Contact Info → Email | Only if accounts ship | Yes | No | App Functionality |

Everything else stays **Not Collected**.

# Appendix B — Regulation map

| Regulation | Applies because | v1.0 status |
|---|---|---|
| **DPDP Act 2023 + Rules (India)** | You operate from India and have Indian users. Rules notified 13 Nov 2025; substantive obligations phase in through **May 2027**. No revenue or user-count exemption. | ✅ Compliant — no personal data processed |
| **GDPR (EU)** | The App is downloadable in the EU | ✅ Compliant |
| **UK GDPR / DPA 2018** | Downloadable in the UK | ✅ Compliant |
| **CCPA / CPRA (California)** | Downloadable in California | ✅ Compliant — no sale or sharing |
| **COPPA (US, under-13)** | Public app store distribution | ✅ Compliant — no collection from anyone |
| **PIPEDA (Canada)**, **Privacy Act (Australia)**, **LGPD (Brazil)**, **PIPL (China)** | Global availability | ✅ Compliant by the same logic. Note: PIPL has strict localisation rules — reconsider before listing in mainland China with any backend. |
| **Apple App Store Review Guideline 5.1** | Required for listing | ✅ Requires this policy to be linked and accurate |
| **Apple Privacy Manifest** | Mandatory since 1 May 2024 | ⚠️ Verify `PrivacyInfo.xcprivacy` exists before submission |

---

**Sources:**

- [Adding a privacy manifest to your app or third-party SDK — Apple Developer](https://developer.apple.com/documentation/bundleresources/adding-a-privacy-manifest-to-your-app-or-third-party-sdk)
- [Offering account deletion in your app — Apple Developer](https://developer.apple.com/support/offering-account-deletion-in-your-app/)
- [DPDP Act and Rules: Practical Overview (2026) — Glocert International](https://www.glocertinternational.com/resources/guides/dpdp-act-and-rules-overview/)
- [India DPDP Act for Mobile Apps: Compliance Deadlines and Penalties — Respectlytics](https://respectlytics.com/blog/india-dpdp-act-mobile-app-compliance/)
- [App Review Guidelines — Apple Developer](https://developer.apple.com/app-store/review/guidelines/)
