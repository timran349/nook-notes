# Nook Notes

> **Small notes. Always within reach.**

**Nook Notes** is a tiny, fast, and quiet macOS sticky-notes utility that lives permanently in the bottom-left corner of your Mac screen. When inactive, it collapses into a subtle edge tab that peeks on mouse proximity and slides open into a compact scratchpad when clicked.

---

## Features

- **Bottom-Left Quick Access**: Anchored permanently to the bottom-left corner of your screen across all macOS desktop spaces.
- **Hover-to-Reveal**: Subtly elevates when your cursor approaches the bottom-left corner.
- **Instant Note Engine**: Press `⌘ N` to create a note and immediately start typing.
- **Continuous Autosave**: All notes auto-save locally in real-time with zero friction.
- **Global Shortcut**: Press `⌘ ⇧ Space` to open or collapse Nook from any application.
- **Fast Search**: Instant real-time search across titles and note body content (`⌘ F`).
- **Native macOS Aesthetic**: Translucent glass backdrop, SF Pro typography, and automatic Light/Dark mode support.
- **100% Local & Private**: Completely offline. No cloud sync, accounts, or background tracking.
- **Launch at Login**: Optional setting to remain available as soon as your Mac starts.

---

## Installation

1. Download [`Nook-Notes.dmg`](https://github.com/timran349/nook-notes/releases/latest) from the latest release.
2. Open the `.dmg` file.
3. Drag **Nook Notes** into your **Applications** folder.
4. Launch **Nook Notes** from Applications or Spotlight (`⌘ Space`).

---

## Keyboard Shortcuts

| Shortcut | Action |
| :--- | :--- |
| `⌘ ⇧ Space` | Toggle Nook Notes panel from anywhere on macOS |
| `⌘ N` | Create a new note instantly |
| `⌘ F` | Toggle real-time search filter |
| `Esc` | Close/collapse panel or return to note list |
| `⌘ Delete` | Delete active note |

---

## Architecture & Tech Stack

- **Language & UI**: Swift 6, SwiftUI, AppKit (`NSPanel`, `NSVisualEffectView`).
- **Global Hotkey**: Carbon Event HotKeys (`RegisterEventHotKey`).
- **Persistence**: Atomic local JSON file storage (`~/Library/Application Support/NookNotes/notes.json`).
- **Distribution**: Universal Binary supporting both Apple Silicon (`arm64`) and Intel (`x86_64`) Macs.

---

## Building from Source

To build the release application and `.dmg` installer locally:

```bash
# Clone repository
git clone https://github.com/timran349/nook-notes.git
cd nook-notes

# Compile Universal binary, bundle app, sign, and build DMG
./build_app.sh
```

---

## License

[MIT License](LICENSE) © 2026 Nook Notes
