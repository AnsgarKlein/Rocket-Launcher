CC							=		valac
BINARYDIR					=		build/

MISCDIR						=		res/
ICON						=		rocket-launcher
DESKTOPFILE					=		rocket-launcher.desktop

ICONDIR						=		$(DESTDIR)/usr/share/icons/hicolor/
ICONDIR_FALLBACK			=		$(DESTDIR)/usr/share/pixmaps/
DESKTOPFILEDIR				=		$(DESTDIR)/usr/share/applications/
INSTALLDIR					=		$(DESTDIR)/usr/bin/

################################################################################
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
################################################################################

DAEMON_PACKAGES				=		--pkg glib-2.0
DAEMON_PACKAGES				+=		--pkg gio-2.0
DAEMON_PACKAGES				+=		--pkg gtk+-3.0

DAEMON_CFLAGS				+=		--thread
DAEMON_CFLAGS				+=		--save-temps
DAEMON_CFLAGS				+=		-X -w
DAEMON_CFLAGS				+=		$(DAEMON_PACKAGES)

DAEMON_SOURCES				+=		$(wildcard src/*.vala)
DAEMON_SOURCES				+=		$(wildcard src/AppHandling/*.vala)
DAEMON_SOURCES				+=		$(wildcard src/Gui/*.vala)
DAEMON_SOURCES				+=		$(wildcard src/D-Bus-Server/*.vala)
DAEMON_SOURCES_C			=		$(DAEMON_SOURCES:.vala=.c)

DAEMON_BINARY				=		rocket-launcher-daemon

################################################################################
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
################################################################################

EXEC_PACKAGES				=		--pkg glib-2.0
EXEC_PACKAGES				+=		--pkg gio-2.0

EXEC_CFLAGS					+=		--thread
EXEC_CFLAGS					+=		--save-temps
EXEC_CFLAGS					+=		-X -w
EXEC_CFLAGS					+=		$(EXEC_PACKAGES)

EXEC_SOURCES				=		$(wildcard src/D-Bus-Client/*.vala)
EXEC_SOURCES_C				=		$(EXEC_SOURCES:.vala=.c)

EXEC_BINARY					=		rocket-launcher

################################################################################
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
################################################################################

ifdef DEBUG_BUILD
    DAEMON_CFLAGS			+=		--debug
    EXEC_CFLAGS				+=		--debug
else
    ifdef RELEASE_BUILD
        DAEMON_CFLAGS		+=		-X -O3
        EXEC_CFLAGS			+=		-X -O3
    endif
endif


ifdef WITH_APPINDICATOR
    DAEMON_PACKAGES			+=		--pkg appindicator3-0.1
    DAEMON_CFLAGS			+=		-D WITH_APPINDICATOR
endif

################################################################################
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
################################################################################

all: $(BINARYDIR)$(DAEMON_BINARY) $(BINARYDIR)$(EXEC_BINARY)
	@echo -e sucessfully compiled

clean:
	rm -f $(BINARYDIR)$(DAEMON_BINARY)
	rm -f $(BINARYDIR)$(EXEC_BINARY)
	rm -f $(DAEMON_SOURCES_C)
	rm -f $(EXEC_SOURCES_C)
	@echo -e sucessfully cleaned

$(BINARYDIR)$(DAEMON_BINARY): $(DAEMON_SOURCES)
	@echo -e "\n\nCompiling the daemon executable...\n"
	$(CC) $(DAEMON_CFLAGS) $(DAEMON_SOURCES) -o $(BINARYDIR)$(DAEMON_BINARY)

$(BINARYDIR)$(EXEC_BINARY): $(EXEC_SOURCES)
	@echo -e "\n\nCompiling the launcher executable...\n"
	$(CC) $(EXEC_CFLAGS) $(EXEC_SOURCES) -o $(BINARYDIR)$(EXEC_BINARY)

$(ICONDIR):
	mkdir --parents $(ICONDIR)

$(ICONDIR_FALLBACK):
	mkdir --parents $(ICONDIR_FALLBACK)

$(DESKTOPFILEDIR):
	mkdir --parents $(DESKTOPFILEDIR)

$(INSTALLDIR):
	mkdir --parents $(INSTALLDIR)

###############################################################################
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
###############################################################################

install: all $(ICONDIR) $(ICONDIR_FALLBACK) $(DESKTOPFILEDIR) $(INSTALLDIR)
	cp $(BINARYDIR)$(DAEMON_BINARY) $(INSTALLDIR)$(DAEMON_BINARY)
	cp $(BINARYDIR)$(EXEC_BINARY) $(INSTALLDIR)$(EXEC_BINARY)
	
	mkdir --parents $(ICONDIR)16x16/apps/
	mkdir --parents $(ICONDIR)22x22/apps/
	mkdir --parents $(ICONDIR)24x24/apps/
	mkdir --parents $(ICONDIR)32x32/apps/
	mkdir --parents $(ICONDIR)36x36/apps/
	mkdir --parents $(ICONDIR)48x48/apps/
	mkdir --parents $(ICONDIR)64x64/apps/
	mkdir --parents $(ICONDIR)72x72/apps/
	mkdir --parents $(ICONDIR)96x96/apps/
	mkdir --parents $(ICONDIR)128x128/apps/
	mkdir --parents $(ICONDIR)192x192/apps/
	mkdir --parents $(ICONDIR)256x256/apps/
	mkdir --parents $(ICONDIR)512x512/apps/
	
	cp $(MISCDIR)$(ICON)_16x16.png $(ICONDIR)16x16/apps/$(ICON).png
	cp $(MISCDIR)$(ICON)_22x22.png $(ICONDIR)22x22/apps/$(ICON).png
	cp $(MISCDIR)$(ICON)_24x24.png $(ICONDIR)24x24/apps/$(ICON).png
	cp $(MISCDIR)$(ICON)_32x32.png $(ICONDIR)32x32/apps/$(ICON).png
	cp $(MISCDIR)$(ICON)_36x36.png $(ICONDIR)36x36/apps/$(ICON).png
	cp $(MISCDIR)$(ICON)_48x48.png $(ICONDIR)48x48/apps/$(ICON).png
	cp $(MISCDIR)$(ICON)_64x64.png $(ICONDIR)64x64/apps/$(ICON).png
	cp $(MISCDIR)$(ICON)_72x72.png $(ICONDIR)72x72/apps/$(ICON).png
	cp $(MISCDIR)$(ICON)_96x96.png $(ICONDIR)96x96/apps/$(ICON).png
	cp $(MISCDIR)$(ICON)_128x128.png $(ICONDIR)128x128/apps/$(ICON).png
	cp $(MISCDIR)$(ICON)_192x192.png $(ICONDIR)192x192/apps/$(ICON).png
	cp $(MISCDIR)$(ICON)_256x256.png $(ICONDIR)256x256/apps/$(ICON).png
	cp $(MISCDIR)$(ICON)_512x512.png $(ICONDIR)512x512/apps/$(ICON).png
	ln --symbolic --force $(ICONDIR)512x512/apps/$(ICON).png $(ICONDIR_FALLBACK)$(ICON).png
	
	cp $(MISCDIR)$(DESKTOPFILE) $(DESKTOPFILEDIR)$(DESKTOPFILE)
	touch $(ICONDIR)
	@echo -e sucessfully installed

uninstall:
	rm --force /usr/bin/$(DAEMON_BINARY)
	rm --force /usr/bin/$(EXEC_BINARY)
	
	rm --force $(ICONDIR)16x16/apps/$(ICON).png
	rm --force $(ICONDIR)22x22/apps/$(ICON).png
	rm --force $(ICONDIR)24x24/apps/$(ICON).png
	rm --force $(ICONDIR)32x32/apps/$(ICON).png
	rm --force $(ICONDIR)36x36/apps/$(ICON).png
	rm --force $(ICONDIR)48x48/apps/$(ICON).png
	rm --force $(ICONDIR)64x64/apps/$(ICON).png
	rm --force $(ICONDIR)72x72/apps/$(ICON).png
	rm --force $(ICONDIR)96x96/apps/$(ICON).png
	rm --force $(ICONDIR)128x128/apps/$(ICON).png
	rm --force $(ICONDIR)192x192/apps/$(ICON).png
	rm --force $(ICONDIR)256x256/apps/$(ICON).png
	rm --force $(ICONDIR)512x512/apps/$(ICON).png
	rm --force /usr/share/pixmaps/$(ICON).png
	
	rm --force $(DESKTOPFILEDIR)$(DESKTOPFILE)
	touch $(ICONDIR)
	@echo -e sucessfully uninstalled

linecount:
	wc --lines $(DAEMON_SOURCES) $(EXEC_SOURCES)
