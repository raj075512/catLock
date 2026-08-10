# Auto-push setup

Claude can commit to this repo but cannot push — its sandbox blocks network access to github.com (`403 from proxy after CONNECT`). This runs on your Mac and pushes for you.

## Option A — one-off, while you're working

Leave this running in a Terminal tab. It checks every 60 seconds and pushes anything new.

```bash
while true; do ~/Documents/goCat/scripts/autopush.sh; sleep 60; done
```

Stop it with `Ctrl-C`. Nothing persists after you close the tab.

## Option B — permanent, survives reboot (recommended)

A launchd agent that runs the script every 2 minutes in the background.

**1. Make the script executable:**

```bash
chmod +x ~/Documents/goCat/scripts/autopush.sh
```

**2. Create the agent:**

```bash
cat > ~/Library/LaunchAgents/com.catlock.autopush.plist <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.catlock.autopush</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>-lc</string>
        <string>$HOME/Documents/goCat/scripts/autopush.sh</string>
    </array>
    <key>StartInterval</key>
    <integer>120</integer>
    <key>RunAtLoad</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/catlock-autopush.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/catlock-autopush.err</string>
</dict>
</plist>
PLIST
```

**3. Load it:**

```bash
launchctl unload ~/Library/LaunchAgents/com.catlock.autopush.plist 2>/dev/null
launchctl load ~/Library/LaunchAgents/com.catlock.autopush.plist
```

**4. Check it's working:**

```bash
tail -f /tmp/catlock-autopush.log
```

You should see a line each time it pushes, and silence when there's nothing to do.

**To turn it off:**

```bash
launchctl unload ~/Library/LaunchAgents/com.catlock.autopush.plist
```

## Credentials

The script uses whatever git credentials you already have. If pushing normally works in your terminal without a password prompt, this will too.

If it asks for credentials when run from launchd (which has no terminal to prompt in), fix it once:

```bash
# store the token in the macOS keychain
git config --global credential.helper osxkeychain
git push origin HEAD   # enter your GitHub token once when prompted
```

Or switch the remote to SSH, which needs no prompt:

```bash
cd ~/Documents/goCat
git remote set-url origin git@github.com:raj075512/catLock.git
```

## What it will and won't do

| | |
|---|---|
| Pushes the branch you're currently on | ✅ |
| Pushes `main`, `master` or `dev` | ❌ never — open a PR instead |
| Force-pushes | ❌ never |
| Creates commits | ❌ never |
| Touches uncommitted work | ❌ never |

## Worth knowing

This means commits reach GitHub without you reviewing them first. On a solo feature branch that's fine — the branch is a work surface, and `main`/`dev` are still protected by PR review and your CI checks.

If you'd rather keep a gate, use Option A and only start the loop when you're actively working with Claude.
