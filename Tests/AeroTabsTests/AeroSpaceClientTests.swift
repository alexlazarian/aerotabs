import Testing
@testable import AeroTabs

@Suite("AeroSpaceClient parsing")
struct AeroSpaceClientParsingTests {
    @Test("parses pipe-delimited window list")
    func parseWindowList() {
        let output = """
        10025|Finder|com.apple.finder
        9612|Google Chrome|com.google.Chrome
        254|iTerm2|com.googlecode.iterm2
        """
        let windows = AeroSpaceClient.parseWindowList(output)
        #expect(windows.count == 3)
        #expect(windows[0].windowId == "10025")
        #expect(windows[0].appName == "Finder")
        #expect(windows[0].bundleId == "com.apple.finder")
        #expect(windows[1].windowId == "9612")
        #expect(windows[1].appName == "Google Chrome")
        #expect(windows[2].bundleId == "com.googlecode.iterm2")
    }

    @Test("parses empty output")
    func parseEmptyOutput() {
        let windows = AeroSpaceClient.parseWindowList("")
        #expect(windows.isEmpty)
    }

    @Test("skips malformed lines")
    func parseMalformedLines() {
        let output = """
        10025|Finder|com.apple.finder
        bad-line
        254|iTerm2|com.googlecode.iterm2
        """
        let windows = AeroSpaceClient.parseWindowList(output)
        #expect(windows.count == 2)
    }

    @Test("parses focused window ID")
    func parseFocusedWindowId() {
        let output = "254\n"
        let focusedId = AeroSpaceClient.parseFocusedWindowId(output)
        #expect(focusedId == "254")
    }

    @Test("handles empty focused window output")
    func parseEmptyFocusedWindow() {
        let focusedId = AeroSpaceClient.parseFocusedWindowId("")
        #expect(focusedId == nil)
    }
}
