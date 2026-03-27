import Foundation

struct WindowInfo: Equatable, Hashable, Sendable {
    let windowId: String
    let appName: String
    let bundleId: String
}

struct AeroSpaceClient {
    static let aerospacePath = "/opt/homebrew/bin/aerospace"

    static func parseWindowList(_ output: String) -> [WindowInfo] {
        output
            .split(separator: "\n", omittingEmptySubsequences: true)
            .compactMap { line -> WindowInfo? in
                let parts = line.split(separator: "|", maxSplits: 2)
                guard parts.count == 3 else { return nil }
                return WindowInfo(
                    windowId: String(parts[0]),
                    appName: String(parts[1]),
                    bundleId: String(parts[2])
                )
            }
    }

    static func parseFocusedWindowId(_ output: String) -> String? {
        let trimmed = output.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    static func fetchWorkspaceWindows() -> [WindowInfo] {
        let output = shell(
            aerospacePath,
            "list-windows", "--workspace", "focused",
            "--format", "%{window-id}|%{app-name}|%{app-bundle-id}"
        )
        return parseWindowList(output)
    }

    static func fetchFocusedWindowId() -> String? {
        let output = shell(
            aerospacePath,
            "list-windows", "--focused",
            "--format", "%{window-id}"
        )
        return parseFocusedWindowId(output)
    }

    static func focusWindow(id: String) {
        _ = shell(aerospacePath, "focus", "--window-id", id)
    }

    @discardableResult
    private static func shell(_ args: String...) -> String {
        let process = Process()
        let pipe = Pipe()
        process.executableURL = URL(fileURLWithPath: args[0])
        process.arguments = Array(args.dropFirst())
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice
        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            return ""
        }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8) ?? ""
    }
}
