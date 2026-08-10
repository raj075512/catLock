# catLock — IP & Originality Review

> **⚠️ Not legal advice, and not a formal trademark search.** This is a developer-level review based on public web searches and an audit of the assets in this repository. A real clearance search costs money and looks at registries this review cannot access. Read §1 before you do anything else.

**Date of review:** 10 August 2026
**Reviewed:** the name "catLock", all bundled assets, all third-party code.

---

## 1. 🔴 Finding: the name is already taken by a near-identical app

**This is the most important thing in this document. Read it before you design an icon, buy a domain, or create an App Store Connect record.**

There is a **live iOS app on the US App Store called "Cat Lock — Screen Time Control"** (App Store ID `6772551745`), with the website [catlock.io](https://www.catlock.io/) and the tagline *"Block your phone until you watch the cats."*

Compare:

| | Their app | Your app |
|---|---|---|
| Name | Cat Lock | catLock |
| Category | Screen time / focus | Focus timer |
| Concept | Blocks your phone, cats gate access | Locks you into a session with a cat |
| Animal | Cat | Cat |
| Store | US App Store | US App Store (planned) |

The only difference between the names is a space and a capital letter. **Trademark analysis turns on likelihood of confusion between similar marks for similar goods, and this is about as similar as it gets.** "catLock" and "Cat Lock" are phonetically identical — in trademark terms that's usually decisive.

There is also [catlock.app](https://catlock.app/), a Windows utility that locks the keyboard so your cat can't type on it, and an [open-source `Catlock`](https://github.com/ehamiter/Catlock) doing the same on macOS. Those are different product categories and matter less, but they confirm the name is crowded.

### What this means for you

1. **App Store rejection risk.** Apple rejects apps with names confusingly similar to existing apps (Guideline 4.1, Copycats; 5.2, Intellectual Property). A reviewer searching "cat lock" will find theirs immediately.
2. **Takedown risk.** If they registered the trademark and you launch, they can file an App Store IP complaint. Apple removes first and asks questions later. You could lose the listing, the reviews, and the ranking.
3. **ASO is already lost.** Even if you launch successfully, you would be competing for the exact search term that returns their app, in the same store, in the same category. You would spend your marketing budget sending users to a competitor.
4. **Sunk-cost risk grows daily.** Right now the name lives in a README, some copy and a git repo. After a launch it lives in an App Store listing, a domain, reviews, screenshots, and users' heads. **The cost of changing it will never be lower than it is today.**

### Recommendation

**Change the name.** I know that's not what you wanted to hear after building an identity around it, but this is a clean, cheap fix now and an expensive mess in three months.

Note that the *product* is not the problem. Their app is a phone blocker where cats are the reward; yours is a focus timer where the cat is company. Different products, genuinely. It's only the name that collides — and the name is the easiest thing in the project to change.

**When picking a replacement:**

- Search the App Store **and** [tmrsearch.uspto.gov](https://tmrsearch.uspto.gov) (US) and [ipindiaonline.gov.in](https://ipindiaonline.gov.in/tmrpublicsearch/) (India) before falling in love with it
- Check the `.com` or `.app` domain is free
- Avoid generic combinations of `cat` + `focus`/`lock`/`timer`/`study` — that space is saturated
- Something coined and slightly odd (a made-up word, or a cat-adjacent word that isn't "cat") is both easier to clear and easier to rank for
- Once chosen, **file a trademark application before launch.** In India a single-class application is roughly ₹4,500–₹9,000 official fee; in the US it's around $250–$350 per class. Filing early is cheap insurance and establishes your priority date.

The internal project name `goCat` can stay as-is — internal names aren't published and aren't a trademark issue.

---

## 2. Asset-by-asset provenance

The other half of "is the app unique" is: do you actually own what's in it?

| Asset | File | Source | Licence status | Risk |
|---|---|---|---|---|
| Cat rocking-chair video | `Resources/Media/session_cat_loop.mp4` | AI-generated (Gemini/Veo) | ⚠️ See §2.1 | Medium |
| Poster frame | `Resources/Media/session_cat_poster.jpg` | Frame from the above | Same as above | Medium |
| Trophy animation | `Resources/Animations/session_trophy.lottie` | ⚠️ **Unverified** — uploaded, origin unrecorded | ❓ **Unknown** | **High** |
| Trash animation | `Resources/Animations/trash_cancel.lottie` | ⚠️ **Unverified** — uploaded, origin unrecorded | ❓ **Unknown** | **High** |
| Lottie library | SPM `airbnb/lottie-spm` 4.6.1 | Airbnb | ✅ MIT | Low — attribution required |
| Fonts | System (`.system(design: .rounded)`) | Apple SF Pro | ✅ Licensed for use in apps on Apple platforms | None |
| Icons | SF Symbols | Apple | ✅ Licensed — but **do not** use them in your app icon, marketing, or screenshots-as-artwork; Apple's licence restricts SF Symbols to in-app UI | Low, if respected |
| Colours, spacing, components | Your own | ✅ Yours | None |
| Ambient sounds | *not yet added* | — | ⚠️ See §2.3 | **Future high** |
| App icon | *not yet created* | — | — | — |

### 2.1 The AI-generated cat video

Two separate issues, often confused:

**Do you own it?** Under Google's generative-AI terms, output is generally assigned to you, subject to their prohibited-use policies. Check the terms attached to the specific product and account you used, and **save a record**: which tool, which date, which prompt. That record is your provenance evidence if anyone ever asks.

**Can you stop others from copying it?** Probably not. The US Copyright Office has consistently held that **purely AI-generated works lack the human authorship required for copyright protection**. So the video likely sits in a grey zone: yours to use, but hard to defend. For a background loop this is an acceptable trade — nobody's business model depends on that clip being exclusive. Just don't build brand equity on it, and don't assume you could stop a copycat from generating a similar one.

**A third, smaller risk:** generative models occasionally reproduce recognisable elements from training data. Look at your clip specifically for anything that resembles an existing character (Pusheen, Hello Kitty, a Studio Ghibli cat). If it does, regenerate. Generic cat in a generic chair is fine; a cat that reads as *someone's* cat is not.

### 2.2 🔴 The Lottie files — verify these before launch

You uploaded `Trash Animation.lottie` and `Trophy.lottie`, and I bundled them into the app. **I have no record of where they came from, and neither does the repo.** That's a genuine gap.

Most Lottie animations circulating online come from LottieFiles, where licensing varies per asset:
- Some are free for commercial use, no attribution
- Some are free but **require attribution**
- Some are **personal use only** — using those in a paid app is straightforward infringement
- Some are paid assets that get re-shared without licences attached

**Action required before launch:**

- [ ] Identify where each `.lottie` came from — the LottieFiles page, the creator, the licence
- [ ] Record it in `legal/ASSET_LICENCES.md` (see §4) with a link and a date
- [ ] If attribution is required, add it to Settings → About
- [ ] **If you cannot establish the licence, replace the file.** Commission it, buy it, or make it. Two animations are not worth an infringement claim, and "I found it online" is not a defence.

This is the highest-probability IP problem in the project. Name conflicts get you rejected; unlicensed assets get you sued.

### 2.3 Ambient sounds — not yet a problem, about to be

`Resources/Audio/` is empty and `AudioPlayerService` plays nothing (see `PLAN.md`). When you fix that, sound licensing becomes live.

- **"Royalty-free" does not mean "free".** It means no per-use royalty. Many royalty-free libraries still require a paid licence.
- **Freesound.org** is good but mixed: CC0 assets are unrestricted; **CC-BY requires attribution**; **CC-BY-NC forbids commercial use entirely** — which includes a free app that sells a subscription.
- **YouTube audio libraries** are licensed for YouTube videos, not for redistribution inside an app. Do not use them.
- Rain, fire and ocean recordings are cheap from Epidemic Sound, Artlist, or Pond5. The Excel budget allocates $20–100; that is enough.
- **A purr is the one to be careful about** — real cat recordings are usually someone's copyrighted recording. Buy it or record your own cat.

Keep the receipt and licence text for each file.

---

## 3. Is the *product* unique?

Distinct from the name. Short answer: the category is crowded, but your specific take is defensible.

**The crowded part:** Pomodoro timers with a cute companion is an established genre — Forest (trees), Flora, Focus Plant, Study Bunny, plus dozens of cat-themed timers. You will not be first.

**The defensible part:** functional ideas aren't protectable anyway — you cannot infringe a patent by building a timer, and nobody owns "cute animal motivates focus". What matters is whether your execution is distinct, and it is:

- **No pause and no exit during a session.** Most competitors let you pause. Committing to "you cannot back out" is a real product opinion, and it's the thing to lead with.
- **The cancel-goes-to-trash outcome.** A visible, slightly sad consequence for quitting, rather than a neutral "session ended".
- **Deliberately zero customisation of the companion.** Everyone else sells character skins. Refusing to is a positioning statement.
- **Collects no data at all.** Increasingly rare and increasingly valued.

What you must **not** do: copy Forest's specific visual language, reuse anyone's marketing copy, or name yourself in a way that trades on another app's recognition. As long as your assets are yours and your name is clear, similar mechanics are fine.

---

## 4. Documents and actions

### Create `legal/ASSET_LICENCES.md`

One row per bundled asset, filled in as you add them. This takes ten minutes and answers every future "where did this come from?" instantly:

```markdown
| Asset | File | Source URL | Creator | Licence | Attribution required | Date acquired | Receipt |
|-------|------|-----------|---------|---------|---------------------|---------------|---------|
| Trophy animation | session_trophy.lottie | ??? | ??? | ??? | ??? | ??? | ??? |
```

### Add a licences screen

Settings → About → Licences, listing at minimum:
- Lottie (MIT, Airbnb) — full licence text
- Any attribution-required animations or sounds
- Any font that isn't a system font

This is a requirement of most open-source licences, including MIT, and takes an hour.

### Checklist

**Before you write another line of code**
- [ ] Decide whether the name changes. Everything else waits on this.

**Before launch**
- [ ] New name cleared against the App Store, USPTO and IP India
- [ ] Domain secured
- [ ] Trademark application filed (India, and US if that's your primary market)
- [ ] Provenance established for both `.lottie` files, or files replaced
- [ ] `ASSET_LICENCES.md` complete
- [ ] Sound assets licensed with receipts kept
- [ ] AI video generation records saved (tool, date, prompt)
- [ ] Cat clip reviewed for resemblance to any known character
- [ ] Licences screen shipped in Settings → About
- [ ] App icon original — not a modified SF Symbol, not a stock image, not AI output resembling an existing brand
- [ ] Screenshots and listing copy contain no competitor names and no borrowed phrasing

**Ongoing**
- [ ] Every new asset gets a row in `ASSET_LICENCES.md` on the day it's added
- [ ] Re-check the App Store for name collisions before each major release

---

## 5. What this review could not do

Being clear about the limits:

- **No formal trademark search.** I searched the public web. I did not search USPTO, IP India, EUIPO, WIPO, or state registries. An unregistered mark in use can still block you, and only a proper search finds those.
- **No visual comparison of your video against copyrighted characters.** I have not viewed the clip frame by frame against any database.
- **No review of the actual licence terms** of the two `.lottie` files, because their origin is unknown.
- **No opinion on patents.** Software patents in this space are unlikely to affect a timer app, but I have not searched.

If the app is going to be a serious commercial product, a one-off consultation with an IP attorney covering the name and the asset chain is worth the fee. The Excel budget already sets aside ₹8,000–₹40,000 for legal — this is the highest-value place to spend part of it.

---

**Sources:**

- [Cat Lock — catlock.io](https://www.catlock.io/) · [App Store listing](https://apps.apple.com/us/app/cat-lock-screen-time-control/id6772551745)
- [CatLock — catlock.app](https://catlock.app/)
- [ehamiter/Catlock on GitHub](https://github.com/ehamiter/Catlock)
- [App Review Guidelines — Apple Developer](https://developer.apple.com/app-store/review/guidelines/)
- [Apple Trademark and Copyright Guidelines for Third Parties](https://www.apple.com/legal/intellectual-property/guidelinesfor3rdparties.html)
- [Trademarks for Mobile Apps — Rapacke Law Group](https://arapackelaw.com/trademarks/trademarks-for-mobile-apps/)
