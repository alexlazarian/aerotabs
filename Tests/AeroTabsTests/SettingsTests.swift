import Foundation
import Testing
@testable import AeroTabs

@Suite("Settings")
struct SettingsTests {
    @Test("default display mode is iconAndNameAll")
    func defaultDisplayMode() {
        let defaults = UserDefaults(suiteName: "test-\(UUID().uuidString)")!
        let settings = Settings(defaults: defaults)
        #expect(settings.displayMode == .iconAndNameAll)
    }

    @Test("persists display mode")
    func persistDisplayMode() {
        let suiteName = "test-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        let settings = Settings(defaults: defaults)
        settings.displayMode = .iconOnly
        let settings2 = Settings(defaults: defaults)
        #expect(settings2.displayMode == .iconOnly)
    }

    @Test("display mode has correct labels")
    func displayModeLabels() {
        #expect(DisplayMode.iconAndNameAll.label == "Icon + Name (All)")
        #expect(DisplayMode.iconAndNameActive.label == "Icon + Name (Active Only)")
        #expect(DisplayMode.iconOnly.label == "Icon Only")
    }

    @Test("showLabel returns correct values for iconAndNameAll")
    func showLabelAll() {
        #expect(DisplayMode.iconAndNameAll.showLabel(isActive: true) == true)
        #expect(DisplayMode.iconAndNameAll.showLabel(isActive: false) == true)
    }

    @Test("showLabel returns correct values for iconAndNameActive")
    func showLabelActive() {
        #expect(DisplayMode.iconAndNameActive.showLabel(isActive: true) == true)
        #expect(DisplayMode.iconAndNameActive.showLabel(isActive: false) == false)
    }

    @Test("showLabel returns correct values for iconOnly")
    func showLabelIconOnly() {
        #expect(DisplayMode.iconOnly.showLabel(isActive: true) == false)
        #expect(DisplayMode.iconOnly.showLabel(isActive: false) == false)
    }
}
