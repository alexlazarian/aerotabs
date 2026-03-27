import AppKit

struct WindowDiff {
    let added: [WindowInfo]
    let removed: [WindowInfo]
    let unchanged: [WindowInfo]
}

@MainActor
class StatusBarManager {
    private let statusItem: NSStatusItem
    private let tabStrip = TabStripView(frame: .zero)
    private var windows: [WindowInfo] = []
    private var focusedId: String?
    private let settings: Settings
    private var contextMenu: ContextMenu?

    init(settings: Settings) {
        self.settings = settings
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        self.contextMenu = ContextMenu(settings: settings) { [weak self] in
            self?.refreshDisplay()
        }

        tabStrip.onLeftClick = { [weak self] window in
            AeroSpaceClient.focusWindow(id: window.windowId)
        }
        tabStrip.onRightClick = { [weak self] point in
            guard let self, let menu = self.contextMenu?.build() else { return }
            menu.popUp(positioning: nil, at: NSPoint(x: point.x, y: self.tabStrip.bounds.height), in: self.tabStrip)
        }

        if let button = statusItem.button {
            button.addSubview(tabStrip)
            tabStrip.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                tabStrip.leadingAnchor.constraint(equalTo: button.leadingAnchor),
                tabStrip.trailingAnchor.constraint(equalTo: button.trailingAnchor),
                tabStrip.topAnchor.constraint(equalTo: button.topAnchor),
                tabStrip.bottomAnchor.constraint(equalTo: button.bottomAnchor),
            ])
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

    func refresh() {
        windows = AeroSpaceClient.fetchWorkspaceWindows()
        focusedId = AeroSpaceClient.fetchFocusedWindowId()
        updateDisplay()
    }

    func refreshDisplay() {
        focusedId = AeroSpaceClient.fetchFocusedWindowId()
        updateDisplay()
    }

    private func updateDisplay() {
        let entries = windows.map { window in
            let isActive = window.windowId == focusedId
            return TabEntry(
                window: window,
                icon: appIcon(for: window.bundleId),
                isActive: isActive,
                showLabel: settings.displayMode.showLabel(isActive: isActive)
            )
        }

        tabStrip.update(entries: entries)
        statusItem.length = tabStrip.intrinsicContentSize.width
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
        NSStatusBar.system.removeStatusItem(statusItem)
    }
}
