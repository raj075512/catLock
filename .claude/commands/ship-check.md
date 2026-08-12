---
description: Run the pre-TestFlight readiness checklist and report blockers
---

Check whether this build is ready to go to TestFlight. Work through `TESTING.md` §7 and `PLAN.md` Tier 0–3, and verify each item against the actual project rather than assuming.

Check at minimum:

- `IPHONEOS_DEPLOYMENT_TARGET` in `project.pbxproj` — is it still 26.5?
- `PRODUCT_BUNDLE_IDENTIFIER` — is it still `ashutosh.goCat`?
- Does `FocusTimerService` compute remaining time from an end `Date`, or is it still decrementing a counter? (The counter version drifts when backgrounded.)
- Does `StreakStore` have day-boundary logic yet, or is it still counting sessions?
- Is any user-visible string still "GoCat" instead of "catLock"?
- Does `AudioPlayerService` construct a real audio player?
- Are `PrivacyInfo.xcprivacy`, an app icon, and a launch screen present?
- Is `README.md` still describing features that don't exist?

Report as a blocker list ordered by what stops submission first. For anything you cannot verify without building or running the app, say so rather than guessing.
