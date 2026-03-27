import AppKit

struct TabEntry {
    let window: WindowInfo
    let icon: NSImage
    let isActive: Bool
    let showLabel: Bool
    var frame: NSRect = .zero
}

class TabStripView: NSView {
    var entries: [TabEntry] = []
    var onLeftClick: ((WindowInfo) -> Void)?
    var onRightClick: ((NSPoint) -> Void)?

    private static let iconSize: CGFloat = 16
    private static let spacing: CGFloat = 4
    private static let labelSpacing: CGFloat = 3
    private static let labelPadding: CGFloat = 4
    private static let pillCornerRadius: CGFloat = 4
    private static let pillColor = NSColor(white: 1.0, alpha: 0.2)

    func update(entries: [TabEntry]) {
        self.entries = layoutEntries(entries)
        let totalWidth = self.entries.last.map { $0.frame.maxX } ?? 0
        let height = superview?.bounds.height ?? 22
        setFrameSize(NSSize(width: totalWidth, height: height))
        needsDisplay = true
        invalidateIntrinsicContentSize()
    }

    private func layoutEntries(_ entries: [TabEntry]) -> [TabEntry] {
        var result = entries
        let height: CGFloat = bounds.height > 0 ? bounds.height : 22
        var x: CGFloat = 0

        for i in result.indices {
            let entry = result[i]

            if entry.showLabel {
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: NSFont.systemFont(ofSize: 12, weight: entry.isActive ? .semibold : .regular)
                ]
                let labelSize = (entry.window.appName as NSString).size(withAttributes: attrs)
                let width = TabStripView.labelPadding + TabStripView.iconSize + TabStripView.labelSpacing + labelSize.width + TabStripView.labelPadding
                result[i].frame = NSRect(x: x, y: 0, width: width, height: height)
                x += width + TabStripView.spacing
            } else {
                // Icon-only: square frame
                let size = height
                result[i].frame = NSRect(x: x, y: 0, width: size, height: height)
                x += size + TabStripView.spacing
            }
        }

        // Remove trailing spacing
        if !result.isEmpty {
            x -= TabStripView.spacing
        }

        return result
    }

    override var intrinsicContentSize: NSSize {
        let width = entries.last.map { $0.frame.maxX } ?? 0
        let height = superview?.bounds.height ?? 22
        return NSSize(width: width, height: height)
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        for entry in entries {
            // Draw pill background for active tab
            if entry.isActive {
                TabStripView.pillColor.setFill()
                let pillHeight = TabStripView.iconSize + 4
                let pillY = (entry.frame.height - pillHeight) / 2
                let pillRect = NSRect(x: entry.frame.minX + 1, y: pillY, width: entry.frame.width - 2, height: pillHeight)
                let path = NSBezierPath(roundedRect: pillRect, xRadius: TabStripView.pillCornerRadius, yRadius: TabStripView.pillCornerRadius)
                path.fill()
            }

            // Draw icon — centered in frame for icon-only, left-aligned for label mode
            let iconY = (entry.frame.height - TabStripView.iconSize) / 2
            let iconX: CGFloat
            if entry.showLabel {
                iconX = entry.frame.minX + TabStripView.labelPadding
            } else {
                iconX = entry.frame.minX + (entry.frame.width - TabStripView.iconSize) / 2
            }
            let iconRect = NSRect(x: iconX, y: iconY, width: TabStripView.iconSize, height: TabStripView.iconSize)
            entry.icon.draw(in: iconRect)

            // Draw label
            if entry.showLabel {
                let weight: NSFont.Weight = entry.isActive ? .semibold : .regular
                let color: NSColor = entry.isActive ? .white : NSColor(white: 1.0, alpha: 0.7)
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: NSFont.systemFont(ofSize: 12, weight: weight),
                    .foregroundColor: color,
                ]
                let labelX = iconRect.maxX + TabStripView.labelSpacing
                let labelSize = (entry.window.appName as NSString).size(withAttributes: attrs)
                let labelY = (entry.frame.height - labelSize.height) / 2
                (entry.window.appName as NSString).draw(at: NSPoint(x: labelX, y: labelY), withAttributes: attrs)
            }
        }
    }

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        true
    }

    override func mouseDown(with event: NSEvent) {
        // Intercept mouseDown to prevent the button from handling it
    }

    override func mouseUp(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        if let entry = hitEntry(at: point) {
            onLeftClick?(entry.window)
        }
    }

    override func rightMouseDown(with event: NSEvent) {
        // Intercept to prevent button handling
    }

    override func rightMouseUp(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        onRightClick?(point)
    }

    private func hitEntry(at point: NSPoint) -> TabEntry? {
        entries.first { $0.frame.contains(point) }
    }
}
