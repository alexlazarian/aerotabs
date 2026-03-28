<p align="center">
  <img src="screenshots/icon.png" width="128" alt="AeroTabs icon">
  <br>
  <strong>AeroTabs</strong>
</p>

<p align="center">
  A companion app for <a href="https://github.com/nikitabobko/AeroSpace">AeroSpace</a> window manager that shows your workspace windows as clickable tabs in the macOS menu bar.
</p>

<p align="center">
  <img src="screenshots/demo.gif" alt="AeroTabs demo" width="100%">
</p>

> **Requires [AeroSpace](https://github.com/nikitabobko/AeroSpace).** AeroTabs is built specifically for AeroSpace and will not work without it.

## Features

- Shows each window on your focused workspace as a tab with its app icon
- Click a tab to focus that window
- Active window highlighted with a pill background
- Three display modes: **Icon + Name (All)**, **Icon + Name (Active Only)**, **Icon Only**
- Right-click for settings (display mode, launch at login, quit)
- Event-driven updates via AeroSpace hooks — no polling, instant response
- Lightweight native Swift app — no Electron, no runtime dependencies

## Install

### Homebrew (recommended)

```bash
brew tap alexlazarian/aerotabs
brew install --cask aerotabs
```

### Build from source

Requires Xcode Command Line Tools or Xcode.

```bash
git clone https://github.com/alexlazarian/aerotabs.git
cd aerotabs
make install
```

This builds a release binary and installs `AeroTabs.app` to `/Applications/`.

To uninstall:

```bash
make uninstall
```

## Setup

Add these lines to your `~/.aerospace.toml` to trigger AeroTabs on focus and workspace changes:

```toml
on-focus-changed = ['exec-and-forget /usr/bin/open -g -a AeroTabs --args --refresh']
exec-on-workspace-change = ['/usr/bin/open', '-g', '-a', 'AeroTabs', '--args', '--refresh']
```

Then reload your config:

```bash
aerospace reload-config
```

## Display Modes

Right-click any tab to switch between modes:

| Mode | Active Tab | Inactive Tabs |
|------|-----------|---------------|
| **Icon + Name (All)** | Icon + name + pill | Icon + name |
| **Icon + Name (Active Only)** | Icon + name + pill | Icon only |
| **Icon Only** | Icon + pill | Icon only |

Default is **Icon + Name (All)**.

## How It Works

AeroTabs listens for focus and workspace change events from AeroSpace, queries the current workspace windows via the `aerospace` CLI, and renders them as a single `NSStatusItem` in the menu bar.

```
    AeroSpace focus/workspace change
                  |
                  v
       aerospace config hook
     (exec-and-forget: open -g)
                  |
                  v
           AeroTabs.app
                  |
        +---------+---------+
        |                   |
        v                   v
  aerospace             aerospace
  list-windows          list-windows
  --workspace focused   --focused
        |                   |
        v                   v
  window list          focused ID
        |                   |
        +---------+---------+
                  |
                  v
          NSStatusItem
       renders app icons,
       labels, active pill
```

## Bonus: Workspace-Scoped Alt-Tab

macOS native `Cmd+Tab` cycles between apps based on recency across all workspaces, which can jump you to a completely different workspace. If you want `Alt+Tab` to cycle only through windows on your current workspace, save this script somewhere (e.g. `~/.config/aerospace/cycle-window.sh`):

```bash
#!/bin/bash
export PATH="/opt/homebrew/bin:$PATH"

windows=$(aerospace list-windows --workspace focused --format '%{window-id}')
count=$(echo "$windows" | wc -l | tr -d ' ')
[ "$count" -lt 2 ] && exit 0

focused=$(aerospace list-windows --focused --format '%{window-id}')

ids=()
while IFS= read -r line; do
    ids+=("$line")
done <<< "$windows"

current_index=0
for i in $(seq 0 $(( count - 1 ))); do
    if [ "${ids[$i]}" = "$focused" ]; then
        current_index=$i
        break
    fi
done

if [ "${1:-}" = "--reverse" ]; then
    next_index=$(( (current_index - 1 + count) % count ))
else
    next_index=$(( (current_index + 1) % count ))
fi

aerospace focus --window-id "${ids[$next_index]}"

app_bundle=$(aerospace list-windows --focused --format '%{app-bundle-id}')
if [ -n "$app_bundle" ]; then
    osascript -e "tell application id \"$app_bundle\" to activate" 2>/dev/null &
fi
```

Make it executable:

```bash
chmod +x ~/.config/aerospace/cycle-window.sh
```

Then add to your `~/.aerospace.toml`:

```toml
[mode.main.binding]
alt-tab = 'exec-and-forget ~/.config/aerospace/cycle-window.sh'
alt-shift-tab = 'exec-and-forget ~/.config/aerospace/cycle-window.sh --reverse'
```

## Requirements

- macOS 14+ (Sonoma or later)
- [AeroSpace](https://github.com/nikitabobko/AeroSpace) window manager

## License

MIT
