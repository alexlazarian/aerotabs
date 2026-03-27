APP_NAME = WorkspaceTabs
BUILD_DIR = $(shell swift build -c release --show-bin-path 2>/dev/null)
APP_BUNDLE = $(APP_NAME).app
INSTALL_DIR = /Applications

.PHONY: build install uninstall clean

build:
	swift build -c release

install: build
	mkdir -p "$(INSTALL_DIR)/$(APP_BUNDLE)/Contents/MacOS"
	mkdir -p "$(INSTALL_DIR)/$(APP_BUNDLE)/Contents"
	cp "$(BUILD_DIR)/$(APP_NAME)" "$(INSTALL_DIR)/$(APP_BUNDLE)/Contents/MacOS/$(APP_NAME)"
	cp Sources/WorkspaceTabs/Info.plist "$(INSTALL_DIR)/$(APP_BUNDLE)/Contents/Info.plist"
	@echo "Installed to $(INSTALL_DIR)/$(APP_BUNDLE)"

uninstall:
	rm -rf "$(INSTALL_DIR)/$(APP_BUNDLE)"
	@echo "Uninstalled $(APP_BUNDLE)"

clean:
	swift package clean
