import AppKit
import ServiceManagement

@MainActor
class ContextMenu {
    private let settings: Settings
    private let onDisplayModeChanged: () -> Void

    init(settings: Settings, onDisplayModeChanged: @escaping () -> Void) {
        self.settings = settings
        self.onDisplayModeChanged = onDisplayModeChanged
    }

    func build() -> NSMenu {
        let menu = NSMenu()

        let displayModeItem = NSMenuItem(title: "Display Mode", action: nil, keyEquivalent: "")
        let displaySubmenu = NSMenu()
        for mode in DisplayMode.allCases {
            let item = NSMenuItem(title: mode.label, action: #selector(displayModeSelected(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = mode.rawValue
            item.state = settings.displayMode == mode ? .on : .off
            displaySubmenu.addItem(item)
        }
        displayModeItem.submenu = displaySubmenu
        menu.addItem(displayModeItem)

        menu.addItem(.separator())

        let launchItem = NSMenuItem(title: "Launch at Login", action: #selector(toggleLaunchAtLogin(_:)), keyEquivalent: "")
        launchItem.target = self
        launchItem.state = launchAtLoginEnabled() ? .on : .off
        menu.addItem(launchItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Quit", action: #selector(quit(_:)), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        return menu
    }

    @objc private func displayModeSelected(_ sender: NSMenuItem) {
        guard let rawValue = sender.representedObject as? String,
              let mode = DisplayMode(rawValue: rawValue) else { return }
        settings.displayMode = mode
        onDisplayModeChanged()
    }

    @objc private func toggleLaunchAtLogin(_ sender: NSMenuItem) {
        let service = SMAppService.mainApp
        do {
            if service.status == .enabled {
                try service.unregister()
            } else {
                try service.register()
            }
        } catch {
            // Silently fail — user can retry
        }
    }

    @objc private func quit(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(nil)
    }

    private func launchAtLoginEnabled() -> Bool {
        SMAppService.mainApp.status == .enabled
    }
}
