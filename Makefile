BUILD_DIR				:=		build

BINARY_DIR				:=		binary/
LIB_DIR					:=		lib/
MISC_DIR				:=		misc


export RCKTL_INSTALL_LIB_DIR=/usr/lib/rocket-launcher
export RCKTL_INSTALL_BIN_DIR=/usr/bin
export RCKTL_INSTALL_ICON_DIR=/usr/share/icons/hicolor
export RCKTL_INSTALL_DESKTOPFILE_DIR=/usr/share/applications

export RCKTL_DIR=../$(BUILD_DIR)

export RCKTL_BUILD_DEBUG
export RCKTL_BUILD_RELEASE
export RCKTL_FEATURE_APPINDICATOR


.PHONY: all clean install uninstall
	@#


all: .BINARY .LIBRARY .MISC
	@#

clean:
	@$(MAKE) clean -C "$(BINARY_DIR)"
	@$(MAKE) clean -C "$(LIB_DIR)"
	@$(MAKE) clean -C "$(MISC_DIR)"

install:
	@$(MAKE) install -C "$(BINARY_DIR)"
	@$(MAKE) install -C "$(LIB_DIR)"
	@$(MAKE) install -C "$(MISC_DIR)"

uninstall:
	@$(MAKE) uninstall -C "$(BINARY_DIR)"
	@$(MAKE) uninstall -C "$(LIB_DIR)"
	@$(MAKE) uninstall -C "$(MISC_DIR)"
	
	-rmdir "$(DESTDIR)$(RCKTL_INSTALL_LIB_DIR)"


$(BUILD_DIR):
	mkdir --parents "$(BUILD_DIR)"

.BINARY: $(BUILD_DIR) .LIBRARY
	@$(MAKE) -C "$(BINARY_DIR)"

.LIBRARY: $(BUILD_DIR)
	@$(MAKE) -C "$(LIB_DIR)"

.MISC: $(BUILD_DIR)
	@$(MAKE) -C "$(MISC_DIR)"

