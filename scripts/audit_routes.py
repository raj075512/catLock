#!/usr/bin/env python3
"""
Static route and build-risk audit for catLock.

There is no Swift toolchain in the Cowork sandbox, so this is the closest
available thing to "run the app and click everything". It checks the failures
this project has actually hit before:

  1. Unbalanced braces/parens/brackets (string- and comment-aware)
  2. Framework types used without their import — the target builds with
     SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY, so nothing is visible
     transitively
  3. Logger `privacy:` interpolation without `import os`
  4. Screens that are declared but unreachable from any navigation path
  5. Presented screens with no way back out
  6. Presentation flags that are never raised, or never bound
  7. SoundOption entries with no bundled audio file
  8. Source files outside goCat/, which the synchronized group will not compile

Run from the repo root:  python3 scripts/audit_routes.py
Exit code is non-zero if anything fails, so CI can use it.
"""
import pathlib
import re
import sys

APP = pathlib.Path("goCat")
TEST_DIRS = [pathlib.Path("goCatTests"), pathlib.Path("goCatUITests")]

app_files = {p: p.read_text() for p in sorted(APP.rglob("*.swift"))}
test_files = {p: p.read_text() for d in TEST_DIRS for p in sorted(d.rglob("*.swift"))}
every = {**app_files, **test_files}

failures: list[str] = []
notes: list[str] = []


def strip_literals(source: str) -> str:
    """Remove string literals and line comments so their punctuation doesn't count."""
    out, i, n = [], 0, len(source)
    while i < n:
        if source[i] == '"':
            i += 1
            while i < n and source[i] != '"':
                i += 2 if source[i] == "\\" else 1
            i += 1
            continue
        if source.startswith("//", i):
            while i < n and source[i] != "\n":
                i += 1
            continue
        out.append(source[i])
        i += 1
    return "".join(out)


# 1 ── balance ────────────────────────────────────────────────────────────────
for path, source in every.items():
    clean = strip_literals(source)
    for open_ch, close_ch, label in [("{", "}", "braces"), ("(", ")", "parens"), ("[", "]", "brackets")]:
        if clean.count(open_ch) != clean.count(close_ch):
            failures.append(f"{path}: unbalanced {label} {clean.count(open_ch)}/{clean.count(close_ch)}")

# 2 ── imports ────────────────────────────────────────────────────────────────
NEEDS_IMPORT = {
    "UIImage": "UIKit", "UIView": "UIKit", "UIApplication": "UIKit", "UIDevice": "UIKit",
    "AVAudioPlayer": "AVFoundation", "AVAudioSession": "AVFoundation",
    "AVQueuePlayer": "AVFoundation", "AVPlayerLooper": "AVFoundation",
    "AVPlayerLayer": "AVFoundation", "AVPlayerItem": "AVFoundation",
    "UNUserNotificationCenter": "UserNotifications",
    "Product": "StoreKit", "LottieView": "Lottie", "DotLottieFile": "Lottie",
    "ModelContainer": "SwiftData", "Logger": "OSLog",
}
ALIASES = {"OSLog": ("OSLog", "os")}
for path, source in app_files.items():
    imports = set(re.findall(r"^import\s+(\w+)", source, re.M))
    for symbol, module in NEEDS_IMPORT.items():
        if re.search(rf"\b{symbol}\b", source):
            accepted = set(ALIASES.get(module, (module,)))
            if not accepted & imports:
                failures.append(f"{path.name}: uses {symbol} without `import {module}`")

# 3 ── Logger privacy interpolation needs `os` explicitly ─────────────────────
for path, source in app_files.items():
    if "privacy: ." in source and not re.search(r"^import (os|OSLog)", source, re.M):
        failures.append(f"{path.name}: Logger privacy interpolation without `import os`")

# 4/5 ── navigation graph ─────────────────────────────────────────────────────
views: dict[str, tuple[pathlib.Path, str]] = {}
for path, source in app_files.items():
    for m in re.finditer(r"^struct (\w+): View", source, re.M):
        views[m.group(1)] = (path, source)

presented: set[str] = set()
for path, source in app_files.items():
    for m in re.finditer(r"\b([A-Z]\w*(?:View|Page|Sheet))\s*[\({]", source):
        if m.group(1) != path.stem:
            presented.add(m.group(1))

ROOTS = {"ContentView", "RootView", "HomeView", "OnboardingView"}
COMPONENTS = {"GlassSurface", "GlassPill", "DurationChip", "QuickActionPill", "SelectionCard",
              "PrimaryButton", "IconButton", "EmptyStateView", "ErrorStateView", "LoadingView",
              "PremiumLockBadge", "LottiePlaybackView", "CatSceneBackground", "CatScenePoster",
              "LiveSceneView", "CatSceneVideo", "TaskRowView"}
for name in sorted(set(views) - presented - ROOTS - COMPONENTS):
    failures.append(f"`{name}` is declared but never presented — unreachable")

SESSION_HAS_NO_EXIT_BY_DESIGN = {"FocusSessionView"}
EMBEDDED_IN_A_WRAPPER = {"SoundSelectionView", "SceneSelectionView"}
for path, source in app_files.items():
    for m in re.finditer(r"\.(?:sheet|fullScreenCover)\([^)]*\)\s*\{(.{0,400}?)\n\s*\}", source, re.S):
        for target in re.findall(r"\b([A-Z]\w*(?:View|Sheet))\s*[\({]", m.group(1)):
            if target in EMBEDDED_IN_A_WRAPPER or target not in views:
                continue
            body = views[target][1]
            has_exit = "dismiss()" in body or "onContinue" in body or "onDone" in body
            if not has_exit and target not in SESSION_HAS_NO_EXIT_BY_DESIGN:
                failures.append(f"{target} is presented by {path.name} but offers no way back")

# 6 ── presentation flags ─────────────────────────────────────────────────────
for path, source in app_files.items():
    for m in re.finditer(r"@State private var (is[A-Z]\w+)\b", source):
        flag = m.group(1)
        if not re.search(rf"\b{flag}\s*=\s*true", source):
            failures.append(f"{path.name}: `{flag}` is never set to true — the screen it guards is unreachable")
        if not re.search(rf"\${flag}\b", source):
            failures.append(f"{path.name}: `{flag}` is never bound to a presentation modifier")

# 7 ── every sound resolves to a bundled file ─────────────────────────────────
sound_model = APP / "Models" / "SoundOption.swift"
if sound_model.exists():
    wanted = set(re.findall(r'resourceName:\s*"([^"]+)"', sound_model.read_text()))
    bundled = {p.stem for p in (APP / "Resources" / "Audio").glob("*.m4a")}
    for missing in sorted(wanted - bundled):
        failures.append(f"SoundOption `{missing}` has no bundled {missing}.m4a")
    for orphan in sorted(bundled - wanted):
        notes.append(f"{orphan}.m4a is bundled but no SoundOption references it")

# 8 ── everything compiled must live under goCat/ ─────────────────────────────
for path in pathlib.Path(".").glob("*.swift"):
    failures.append(f"{path} is outside goCat/ and will not be compiled")

# ── report ───────────────────────────────────────────────────────────────────
print("=" * 66)
print(f"catLock route audit · {len(app_files)} source files · {len(test_files)} test files · {len(views)} views")
print("=" * 66)
if failures:
    print(f"\n{len(set(failures))} FAILURES")
    for f in sorted(set(failures)):
        print(f"  x {f}")
else:
    print("\nAll checks passed.")
if notes:
    print(f"\n{len(set(notes))} notes")
    for n in sorted(set(notes)):
        print(f"  - {n}")
sys.exit(1 if failures else 0)
