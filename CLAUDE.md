# CLAUDE.md

Context for Claude working in this repository. Read this first, every session.

---

## What this is

**catLock** (internal name `goCat`) — an iOS focus timer with a cat companion, aimed at an ADHD-friendly audience. SwiftUI, MVVM, iOS-only, local-first, no backend.

Owner: Ashu (raj075512@gmail.com), operating from India, publishing worldwide.

**⚠️ The name is disputed.** A live App Store app called "Cat Lock — Screen Time Control" already exists in the same category. See `legal/IP_CLEARANCE.md` — a rename is recommended and unresolved. Don't invest effort in name-dependent assets (icon, marketing copy, domain) until it's decided.

---

## Current state — read this before believing any other doc

**Screens 1–29 of the wireframe set are built and verified** (baseline onboarding, Home, the
session and its end states, all sheets, Progress, Settings, About, Accessibility). Subscriptions
and accounts are designed but not implemented.

| Feature | Reality |
|---|---|
| Ambient sound | **Works.** `AVAudioPlayer` against the six loops in `Resources/Audio/`. |
| Tasks | **Persist.** SwiftData `TaskItem`; completed rows clear at local midnight. |
| Progress / stats | **Real.** Computed from `CompletedSession` history. |
| Room | Six rooms, selection persists and swaps Home's video. **Only Living room's clip is bundled** — the rest fall back to it until the art exists. |
| Premium / StoreKit | **Works.** StoreKit 2 purchase, restore and entitlement; paywall, trial banner and Plan & Billing built. Two tiers — yearly with a 7-day trial, monthly without. Products don't exist in App Store Connect yet; a bundled `.storekit` config covers local testing. |
| Notifications | `LocalNotificationService` is still **never called** — the completion-notification copy is undecided (handoff outstanding decision #5). |
| Accounts | Not built. No backend. Settings' Sign in / Plan & Billing rows are disabled. |

**Fixed, with tests:**

1. ~~Timer drifts~~ — now derives from a wall-clock end date and survives backgrounding, force-quit and reboot.
2. ~~Streak is not a streak~~ — `StreakState` counts days, increments once per local day.
3. ~~`IPHONEOS_DEPLOYMENT_TARGET = 26.5`~~ — now 17.0.
4. ~~Persistence half-state~~ — SwiftData only; the Core Data model is deleted.
5. ~~Onboarding says "GoCat"~~ — all user-facing copy is now catLock, taken verbatim from the wireframes.
6. ~~`README.md` is stale~~ — rewritten.

**Still open:**

- **Bundle ID `ashutosh.goCat`** — not reverse-DNS. Must change before an App Store Connect record exists. Left alone deliberately: the rename is unresolved, and a name-derived ID would need changing twice.
- **Screen 44 is undrawn** — Reduce Motion / largest Dynamic Type / notifications-denied variants of Home. The four-chip duration row is the known Dynamic Type break point.
- **Room, Catty and empty-state art** — every room but Living room, and the Tasks empty state, use placeholders.

Dead scaffolding has been removed (`AppRouter`, `TabItem`, `NavigationDestination`, `Item.swift`,
`SessionStore`, `TimerPersistenceService`, the animation services, `MockData`).

**Money rules — enforced by `PaywallTrigger`, pinned by `PaywallTriggerTests`:** the
paywall appears once, on top of the completion screen, after the second *completed*
session. Never during a session, never after a cancellation, never twice
automatically. It sells only what exists — the widget and advanced-stats lines from
the wireframe stay out until those are built.

Full analysis and roadmap: **`PLAN.md`**.

---

## Product rules — do not violate without being asked

These are deliberate decisions, not oversights. If a change would break one, say so before doing it.

- **No pause.** A started session runs to completion or is explicitly cancelled. `pause()` was removed on purpose.
- **No back or close button during a session.** The only control is Cancel. This is the "lock yourself in with your cat" premise.
- **Cancel discards the session.** Trash animation, streak unchanged. Completion gets the trophy and streak +1.
- **No cat or chair customization, ever.** One fixed companion. Room background and sound are the only customization.
- **No tab bar.** `HomeView` is the whole app; everything else is a sheet or lives in the overflow menu.
- **Cat video plays `.once` on Home, `.looping` during a session.** Motion means "a session is running".
- **Collects zero user data as built.** No analytics, no accounts, no network calls. This is a feature — see `legal/PRIVACY_POLICY.md`. Optional accounts are *designed* (`design/WIREFRAME_PROMPT.md` §8) but not implemented; if they ever are, the account must stay optional, and in-app account deletion becomes mandatory. See `DECISIONS.md` 2026-08-10.

---

## Code conventions

**Design tokens are mandatory.** Never hardcode a color, font, spacing value, corner radius, or animation curve in feature code. Everything comes from `Core/DesignSystem/` (`AppColors`, `AppFonts`, `AppSpacing`, `AppCornerRadius`, `AppAnimation`). If a token doesn't exist, add it there — don't inline a value. `DESIGN.md` is the reference and must be updated in the same commit as any visual change.

**Architecture:** MVVM. `@MainActor @Observable final class` view models. `async/await` over Combine. Features are self-contained under `Features/<Name>/{Views,ViewModels,Sheets}`.

**Comments explain *why*, not *what*.** The existing code does this consistently — match it. A comment restating the line below it is noise; a comment explaining why pause was removed is the reason the next person doesn't re-add it.

**Xcode project format:** `objectVersion 77`, using `PBXFileSystemSynchronizedRootGroup`. Files dropped into `goCat/` are picked up automatically — **do not hand-edit `project.pbxproj` to add source files.** The one exception is Swift Package dependencies, which do require manual pbxproj edits (`XCRemoteSwiftPackageReference`, `XCSwiftPackageProductDependency`, a `PBXBuildFile` with `productRef`, and an entry in the target's `packageProductDependencies`). Lottie was added this way; follow the same ID convention and verify brace/paren balance afterwards.

**Dependencies:** only `airbnb/lottie-spm` (4.6.1, MIT). Adding another needs a good reason — this app's simplicity is the point.

---

## Workflow

**`dev` is the branch. Everything starts there and everything goes back there.**

1. **Cut every branch from `dev`** — never from `main`, never from another feature
   branch. `git checkout dev && git pull` first, every time.
2. **Every PR targets `dev`.** No exceptions, including one-line fixes and doc-only
   changes.
3. **`main` only ever receives `dev`,** as a release. Never a feature branch, never a
   direct push.

This is not bureaucracy — it has already broken twice. A feature branch was merged
straight into `main`, which left `dev` two weeks behind the real app, and because CI
only fired on PRs into `dev`, `main` sat with a failing test for a day and nobody saw
it. Anything cut from `dev` in that window would have started from a codebase that no
longer existed. Skipping `dev` skips CI.

- **Branch names:** `feature/*` for features, `fix/*`, `chore/*`, `docs/*` otherwise.
- **CI:** `.github/workflows/pr-checks.yml` runs a merge-conflict check plus
  `xcodebuild test` on PRs into `dev` **and** `main`.
- **Commits:** conventional prefixes (`feat:`, `fix:`, `docs:`, `chore:`) with a body explaining what and *why*. Look at recent history for the house style — bullet points, one thought per line.
- **Pushing:** the Cowork/desktop sandbox **cannot reach github.com** (`403 from proxy`). It commits; `scripts/autopush.sh` on the user's Mac pushes. The terminal CLI can push directly.
- **Never** force-push, never commit secrets, never commit to `main` or `dev` directly,
  and never open a PR against `main` from anything other than `dev`.

---

## Verifying your work

**If you have no Swift toolchain** (the desktop/Cowork sandbox does not — it's Linux, no `xcodebuild`, no `swiftc`), you cannot compile. Say so plainly rather than implying a build passed. Static checks that are still worth doing: brace/paren balance per file, grep for references to symbols you deleted, and confirming any new file is under `goCat/` so the synchronized group picks it up.

**If you can run `xcodebuild`**, use it. Build for an iOS **Simulator** destination, not "My Mac" — running on My Mac triggers an unrelated dyld crash (`ABPeoplePickerView` missing from the iOSSupport runtime) that looks like an app bug and isn't.

Tests live in `goCatTests` and `goCatUITests` but currently prove very little (239 lines, several still Xcode templates). `TESTING.md` says what to write and in what order. `AudioPlayerServiceTests` is green for a feature that plays nothing — delete it rather than trusting it.

---

## Document map

| File | What it holds |
|---|---|
| `PLAN.md` | Honest state of the app, gap analysis, phased roadmap, verdict |
| `DESIGN.md` | Design tokens, components, information architecture, scope, security |
| `DECISIONS.md` | Why things are the way they are, dated |
| `ONBOARDING.md` | First-run flow, permission timing, activation metric |
| `TESTING.md` | Test strategy, device matrix, beta plan, submission checklist |
| `MONETIZATION.md` | Subscription strategy, pricing, paywall placement, why not ads |
| `legal/TERMS_OF_USE.md` | Terms draft — placeholders unfilled, needs an advocate |
| `legal/PRIVACY_POLICY.md` | Full data inventory; v1.0 declares "Data Not Collected" |
| `legal/COMPLIANCE.md` | Trial reminders, auto-renewal disclosure, billing rules, cancellation |
| `legal/IP_CLEARANCE.md` | Name conflict, asset provenance, clearance checklist |
| `README.md` | ⚠️ stale, needs rewriting |
| `CHANGELOG.md` | Release history |

**Keep these in sync.** If you change behaviour, update the doc that describes it in the same commit. Docs describing features that don't exist is the exact failure this project already had once.

---

## How to be useful here

- **Audit before you assume.** The docs have been wrong before. Read the code.
- **Say when something doesn't work.** The user has explicitly asked for honest accounting over reassurance, more than once. "I could not verify this" is a valid and valued answer.
- **Prefer deleting to adding.** The user's consistent instruction has been to reduce complexity. Orphaned files are a recurring problem here.
- **Don't gold-plate.** Small, correct, verifiable changes. The known bug list is long enough without new abstractions.
