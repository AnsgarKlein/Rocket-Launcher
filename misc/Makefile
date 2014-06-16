PORTABLE_SCRIPT			:=		run.sh
RUN_SCRIPT				:=		rocket-launcher
DESKTOP_FILE			:=		rocket-launcher.desktop
ICON_NAME				:=		rocket-launcher


ifndef RCKTL_DIR
	$(error variable RCKTL_DIR is not set)
endif

ifndef RCKTL_INSTALL_LIB_DIR
	$(error variable RCKTL_INSTALL_LIB_DIR is not set)
endif

ifndef RCKTL_INSTALL_BIN_DIR
	$(error variable RCKTL_INSTALL_BIN_DIR is not set)
endif

ifndef RCKTL_INSTALL_ICON_DIR
	$(error variable RCKTL_INSTALL_ICON_DIR is not set)
endif

ifndef RCKTL_INSTALL_DESKTOPFILE_DIR
	$(error variable RCKTL_INSTALL_DESKTOPFILE_DIR is not set)
endif

all: $(RCKTL_DIR)/$(PORTABLE_SCRIPT)
	

clean:
	rm -f "$(RCKTL_DIR)/$(PORTABLE_SCRIPT)"

install:
	install -D "$(RUN_SCRIPT)" "$(DESTDIR)$(RCKTL_INSTALL_BIN_DIR)/$(RUN_SCRIPT)"
	
	install -D "$(DESKTOP_FILE)" "$(DESTDIR)$(RCKTL_INSTALL_DESKTOPFILE_DIR)/$(DESKTOP_FILE)"
	
	install -D "$(ICON_NAME)_16x16.png" "$(DESTDIR)$(RCKTL_INSTALL_ICON_DIR)/16x16/apps/$(ICON_NAME).png"
	install -D "$(ICON_NAME)_22x22.png" "$(DESTDIR)$(RCKTL_INSTALL_ICON_DIR)/22x22/apps/$(ICON_NAME).png"
	install -D "$(ICON_NAME)_24x24.png" "$(DESTDIR)$(RCKTL_INSTALL_ICON_DIR)/24x24/apps/$(ICON_NAME).png"
	install -D "$(ICON_NAME)_32x32.png" "$(DESTDIR)$(RCKTL_INSTALL_ICON_DIR)/32x32/apps/$(ICON_NAME).png"
	install -D "$(ICON_NAME)_36x36.png" "$(DESTDIR)$(RCKTL_INSTALL_ICON_DIR)/36x36/apps/$(ICON_NAME).png"
	install -D "$(ICON_NAME)_48x48.png" "$(DESTDIR)$(RCKTL_INSTALL_ICON_DIR)/48x48/apps/$(ICON_NAME).png"
	install -D "$(ICON_NAME)_64x64.png" "$(DESTDIR)$(RCKTL_INSTALL_ICON_DIR)/64x64/apps/$(ICON_NAME).png"
	install -D "$(ICON_NAME)_72x72.png" "$(DESTDIR)$(RCKTL_INSTALL_ICON_DIR)/72x72/apps/$(ICON_NAME).png"
	install -D "$(ICON_NAME)_96x96.png" "$(DESTDIR)$(RCKTL_INSTALL_ICON_DIR)/96x96/apps/$(ICON_NAME).png"
	install -D "$(ICON_NAME)_128x128.png" "$(DESTDIR)$(RCKTL_INSTALL_ICON_DIR)/128x128/apps/$(ICON_NAME).png"
	install -D "$(ICON_NAME)_192x192.png" "$(DESTDIR)$(RCKTL_INSTALL_ICON_DIR)/192x192/apps/$(ICON_NAME).png"
	install -D "$(ICON_NAME)_256x256.png" "$(DESTDIR)$(RCKTL_INSTALL_ICON_DIR)/256x256/apps/$(ICON_NAME).png"
	install -D "$(ICON_NAME)_512x512.png" "$(DESTDIR)$(RCKTL_INSTALL_ICON_DIR)/512x512/apps/$(ICON_NAME).png"
	
	-update-icon-caches "$(RCKTL_INSTALL_ICON_DIR)"

uninstall:
	rm -f "$(DESTDIR)$(RCKTL_INSTALL_BIN_DIR)/$(RUN_SCRIPT)"
	
	rm -f "$(DESTDIR)$(RCKTL_INSTALL_DESKTOPFILE_DIR)/$(DESKTOP_FILE)"
	
	rm -f "$(DESTDIR)$(RCKTL_INSTALL_ICON_DIR)/16x16/apps/$(ICON_NAME).png"
	rm -f "$(DESTDIR)$(RCKTL_INSTALL_ICON_DIR)/22x22/apps/$(ICON_NAME).png"
	rm -f "$(DESTDIR)$(RCKTL_INSTALL_ICON_DIR)/24x24/apps/$(ICON_NAME).png"
	rm -f "$(DESTDIR)$(RCKTL_INSTALL_ICON_DIR)/32x32/apps/$(ICON_NAME).png"
	rm -f "$(DESTDIR)$(RCKTL_INSTALL_ICON_DIR)/36x36/apps/$(ICON_NAME).png"
	rm -f "$(DESTDIR)$(RCKTL_INSTALL_ICON_DIR)/48x48/apps/$(ICON_NAME).png"
	rm -f "$(DESTDIR)$(RCKTL_INSTALL_ICON_DIR)/64x64/apps/$(ICON_NAME).png"
	rm -f "$(DESTDIR)$(RCKTL_INSTALL_ICON_DIR)/72x72/apps/$(ICON_NAME).png"
	rm -f "$(DESTDIR)$(RCKTL_INSTALL_ICON_DIR)/96x96/apps/$(ICON_NAME).png"
	rm -f "$(DESTDIR)$(RCKTL_INSTALL_ICON_DIR)/128x128/apps/$(ICON_NAME).png"
	rm -f "$(DESTDIR)$(RCKTL_INSTALL_ICON_DIR)/192x192/apps/$(ICON_NAME).png"
	rm -f "$(DESTDIR)$(RCKTL_INSTALL_ICON_DIR)/256x256/apps/$(ICON_NAME).png"
	rm -f "$(DESTDIR)$(RCKTL_INSTALL_ICON_DIR)/512x512/apps/$(ICON_NAME).png"
	
	-update-icon-caches "$(RCKTL_INSTALL_ICON_DIR)"
	-gtk-update-icon-cache "$(RCKTL_INSTALL_ICON_DIR)"

$(RCKTL_DIR)/$(PORTABLE_SCRIPT): $(PORTABLE_SCRIPT)
	@echo "  CP      $(notdir $@)"
	@cp "$(PORTABLE_SCRIPT)" "$(RCKTL_DIR)/$(PORTABLE_SCRIPT)"
	@chmod +x "$(RCKTL_DIR)/$(PORTABLE_SCRIPT)"

