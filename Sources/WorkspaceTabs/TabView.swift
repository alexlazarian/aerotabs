import AppKit

class TabView: NSView {
    private let iconView = NSImageView()
    private let labelField = NSTextField(labelWithString: "")
    private var isActive = false
    private let pillLayer = CALayer()

    private static let iconSize: CGFloat = 18
    private static let pillCornerRadius: CGFloat = 4
    private static let pillColor = NSColor(white: 1.0, alpha: 0.15)
    private static let activePillColor = NSColor(white: 1.0, alpha: 0.25)
    private static let padding: CGFloat = 4
    private static let spacing: CGFloat = 4

    override init(frame: NSRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        wantsLayer = true

        iconView.imageScaling = .scaleProportionallyUpOrDown
        iconView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconView)

        labelField.font = NSFont.systemFont(ofSize: 12, weight: .medium)
        labelField.textColor = .white
        labelField.translatesAutoresizingMaskIntoConstraints = false
        labelField.cell?.lineBreakMode = .byTruncatingTail
        addSubview(labelField)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: TabView.padding),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: TabView.iconSize),
            iconView.heightAnchor.constraint(equalToConstant: TabView.iconSize),

            labelField.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: TabView.spacing),
            labelField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -TabView.padding),
            labelField.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    func configure(icon: NSImage, name: String, isActive: Bool, showLabel: Bool) {
        self.isActive = isActive
        iconView.image = icon
        labelField.stringValue = name
        labelField.isHidden = !showLabel

        if isActive {
            labelField.font = NSFont.systemFont(ofSize: 12, weight: .semibold)
            labelField.textColor = .white
        } else {
            labelField.font = NSFont.systemFont(ofSize: 12, weight: .medium)
            labelField.textColor = NSColor(white: 1.0, alpha: 0.6)
        }

        needsDisplay = true
        invalidateIntrinsicContentSize()
    }

    override var intrinsicContentSize: NSSize {
        let iconWidth = TabView.iconSize
        let padding = TabView.padding * 2
        if labelField.isHidden {
            return NSSize(width: iconWidth + padding, height: 22)
        }
        let labelWidth = labelField.intrinsicContentSize.width
        return NSSize(width: iconWidth + TabView.spacing + labelWidth + padding, height: 22)
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        if isActive {
            TabView.activePillColor.setFill()
            let pillRect = bounds.insetBy(dx: 1, dy: 2)
            let path = NSBezierPath(roundedRect: pillRect, xRadius: TabView.pillCornerRadius, yRadius: TabView.pillCornerRadius)
            path.fill()
        }
    }
}
