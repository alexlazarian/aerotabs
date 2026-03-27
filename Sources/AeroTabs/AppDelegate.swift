import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBarManager: StatusBarManager?
    private let settings = Settings()

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusBarManager = StatusBarManager(settings: settings)
        statusBarManager?.refresh()
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        // Triggered by: open -a WorkspaceTabs --args --refresh
        statusBarManager?.refresh()
        return false
    }

    func applicationWillTerminate(_ notification: Notification) {
        statusBarManager?.removeAll()
    }
}
