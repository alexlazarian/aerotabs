import Testing
@testable import WorkspaceTabs

@Suite("StatusBarManager diff logic")
struct StatusBarManagerDiffTests {
    @Test("computes additions")
    func additions() {
        let old: [WindowInfo] = []
        let new = [
            WindowInfo(windowId: "1", appName: "Finder", bundleId: "com.apple.finder"),
        ]
        let diff = StatusBarManager.diffWindows(old: old, new: new)
        #expect(diff.added.count == 1)
        #expect(diff.removed.isEmpty)
        #expect(diff.unchanged.isEmpty)
    }

    @Test("computes removals")
    func removals() {
        let old = [
            WindowInfo(windowId: "1", appName: "Finder", bundleId: "com.apple.finder"),
        ]
        let new: [WindowInfo] = []
        let diff = StatusBarManager.diffWindows(old: old, new: new)
        #expect(diff.added.isEmpty)
        #expect(diff.removed.count == 1)
        #expect(diff.unchanged.isEmpty)
    }

    @Test("computes unchanged")
    func unchanged() {
        let windows = [
            WindowInfo(windowId: "1", appName: "Finder", bundleId: "com.apple.finder"),
        ]
        let diff = StatusBarManager.diffWindows(old: windows, new: windows)
        #expect(diff.added.isEmpty)
        #expect(diff.removed.isEmpty)
        #expect(diff.unchanged.count == 1)
    }

    @Test("mixed diff")
    func mixedDiff() {
        let old = [
            WindowInfo(windowId: "1", appName: "Finder", bundleId: "com.apple.finder"),
            WindowInfo(windowId: "2", appName: "Safari", bundleId: "com.apple.Safari"),
        ]
        let new = [
            WindowInfo(windowId: "1", appName: "Finder", bundleId: "com.apple.finder"),
            WindowInfo(windowId: "3", appName: "Chrome", bundleId: "com.google.Chrome"),
        ]
        let diff = StatusBarManager.diffWindows(old: old, new: new)
        #expect(diff.added.count == 1)
        #expect(diff.added[0].windowId == "3")
        #expect(diff.removed.count == 1)
        #expect(diff.removed[0].windowId == "2")
        #expect(diff.unchanged.count == 1)
        #expect(diff.unchanged[0].windowId == "1")
    }
}
