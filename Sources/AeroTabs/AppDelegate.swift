import AppKit

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBarManager: StatusBarManager?
    private let settings = Settings()

    static let refreshNotification = "com.srjep.AeroTabs.refresh"

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusBarManager = StatusBarManager(settings: settings)
        statusBarManager?.refresh()

        // Listen for refresh notifications (sent by aerospace hooks via notifyutil)
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(handleRefresh),
            name: NSNotification.Name(AppDelegate.refreshNotification),
            object: nil
        )
    }

    @objc private func handleRefresh(_ notification: Notification) {
        statusBarManager?.refresh()
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        statusBarManager?.refresh()
        return false
    }

    func applicationWillTerminate(_ notification: Notification) {
        statusBarManager?.removeAll()
    }
}
