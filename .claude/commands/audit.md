---
description: Re-audit what is actually built vs stubbed, and report honestly
---

Audit the current state of this app by reading the code, not the docs. The docs have been wrong before.

For every feature reachable from the UI, classify it as **working**, **partial**, **hollow** (a view exists, the implementation does not), or **dead** (code exists, nothing calls it).

Do this concretely:

1. List every file under `goCat/Services/` and `goCat/Features/*/ViewModels/` with its line count. Anything under ~20 lines is a stub until proven otherwise.
2. For each service, grep for who calls it. A service nothing references is dead code, however complete it looks.
3. Check that anything claiming to play audio actually constructs an `AVAudioPlayer`, that anything claiming to persist actually writes to a store, and that anything claiming to show stats reads real data rather than a `.sample` constant.
4. Compare your findings against the "Current state" table in `CLAUDE.md` and the audit in `PLAN.md`.

Then report:

- What changed since those documents were written
- Anything newly hollow or newly fixed
- Any *new* dead code introduced since the last audit

If `CLAUDE.md` or `PLAN.md` are now out of date, say so explicitly and offer to update them. Do not silently correct them, and do not soften the findings — an honest list is the entire point of this command.
