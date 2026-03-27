import AppKit

struct WindowDiff {
    let added: [WindowInfo]
    let removed: [WindowInfo]
    let unchanged: [WindowInfo]
}

@MainActor
class StatusBarManager {
    private var statusItems: [(window: WindowInfo, item: NSStatusItem)] = []
    private let settings: Settings
    private var contextMenu: ContextMenu?

    init(settings: Settings) {
        self.settings = settings
        self.contextMenu = ContextMenu(settings: settings) { [weak self] in
            self?.refreshDisplay()
        }
    }

    nonisolated static func diffWindows(old: [WindowInfo], new: [WindowInfo]) -> WindowDiff {
        let oldIds = Set(old.map(\.windowId))
        let newIds = Set(new.map(\.windowId))
        let added = new.filter { !oldIds.contains($0.windowId) }
        let removed = old.filter { !newIds.contains($0.windowId) }
        let unchanged = new.filter { oldIds.contains($0.windowId) }
        return WindowDiff(added: added, removed: removed, unchanged: unchanged)
    }

    func update(windows: [WindowInfo], focusedId: String?) {
        let oldWindows = statusItems.map(\.window)
        let diff = StatusBarManager.diffWindows(old: oldWindows, new: windows)

        // Remove items for closed windows
        for window in diff.removed {
            if let index = statusItems.firstIndex(where: { $0.window.windowId == window.windowId }) {
                NSStatusBar.system.removeStatusItem(statusItems[index].item)
                statusItems.remove(at: index)
            }
        }

        // Add items for new windows
        for window in diff.added {
            let item = createStatusItem(for: window)
            statusItems.append((window: window, item: item))
        }

        // Reorder to match the new window list order
        var reordered: [(window: WindowInfo, item: NSStatusItem)] = []
        for window in windows {
            if let existing = statusItems.first(where: { $0.window.windowId == window.windowId }) {
                reordered.append(existing)
            }
        }
        statusItems = reordered

        // Update display state for all items
        updateDisplay(focusedId: focusedId)
    }

    func refresh() {
        let windows = AeroSpaceClient.fetchWorkspaceWindows()
        let focusedId = AeroSpaceClient.fetchFocusedWindowId()
        update(windows: windows, focusedId: focusedId)
    }

    func refreshDisplay() {
        let focusedId = AeroSpaceClient.fetchFocusedWindowId()
        updateDisplay(focusedId: focusedId)
    }

    private func updateDisplay(focusedId: String?) {
        for (window, item) in statusItems {
            let isActive = window.windowId == focusedId
            let showLabel = settings.displayMode.showLabel(isActive: isActive)

            if let button = item.button {
                let icon = appIcon(for: window.bundleId)
                button.image = icon
                button.title = showLabel ? window.appName : ""
                button.imagePosition = showLabel ? .imageLeading : .imageOnly

                // Active state: use attributed string for bold
                if showLabel {
                    let weight: NSFont.Weight = isActive ? .semibold : .regular
                    let font = NSFont.systemFont(ofSize: NSFont.systemFontSize, weight: weight)
                    let attrs: [NSAttributedString.Key: Any] = [.font: font]
                    button.attributedTitle = NSAttributedString(string: window.appName, attributes: attrs)
                }
            }
        }
    }

    private func createStatusItem(for window: WindowInfo) -> NSStatusItem {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = item.button {
            let icon = appIcon(for: window.bundleId)
            button.image = icon
            button.imagePosition = .imageLeading
            button.title = window.appName

            button.target = self
            button.action = #selector(tabClicked(_:))
            button.tag = Int(window.windowId) ?? 0

            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        return item
    }

    @objc private func tabClicked(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent
        if event?.type == .rightMouseUp {
            if let menu = contextMenu?.build() {
                menu.popUp(positioning: nil, at: NSPoint(x: 0, y: sender.bounds.height), in: sender)
            }
        } else {
            let windowId = String(sender.tag)
            AeroSpaceClient.focusWindow(id: windowId)
        }
    }

    private func appIcon(for bundleId: String) -> NSImage {
        if let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) {
            let icon = NSWorkspace.shared.icon(forFile: appURL.path)
            icon.size = NSSize(width: 18, height: 18)
            return icon
        }
        return NSImage(systemSymbolName: "app.fill", accessibilityDescription: nil)
            ?? NSImage()
    }

    func removeAll() {
        for (_, item) in statusItems {
            NSStatusBar.system.removeStatusItem(item)
        }
        statusItems.removeAll()
    }
}
