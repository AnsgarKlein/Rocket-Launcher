CC		=	valac
BINARYDIR	=	build/

MISCDIR		=	res/

ICONDIR		=	/usr/share/icons/hicolor/
ICON		=	rocket-launcher

DESKTOPFILEDIR	=	/usr/share/applications/
DESKTOPFILE	=	rocket-launcher.desktop

################################################################################
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
################################################################################

DAEMON_PACKAGES	=	--pkg glib-2.0
DAEMON_PACKAGES	+=	--pkg gio-2.0
DAEMON_PACKAGES	+=	--pkg gtk+-3.0
DAEMON_PACKAGES	+=	--pkg appindicator3-0.1

DAEMON_CFLAGS	+=	--thread
DAEMON_CFLAGS	+=	$(DAEMON_PACKAGES)
DAEMON_CFLAGS	+=	-X -w

DAEMON_SOURCES	+=	src/*.vala
DAEMON_SOURCES	+=	src/AppHandling/*.vala
DAEMON_SOURCES	+=	src/Gui/*.vala
DAEMON_SOURCES	+=	src/AppIndicator/*.vala
DAEMON_SOURCES	+=	src/D-Bus-Server/*.vala

DAEMON_BINARY	=	rocket-launcher-daemon

################################################################################
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
################################################################################

EXEC_PACKAGES	=	--pkg glib-2.0
EXEC_PACKAGES	+=	--pkg gio-2.0

EXEC_CFLAGS	+=	--thread
EXEC_CFLAGS	+=	$(EXEC_PACKAGES)
EXEC_CFLAGS	+=	-X -w

EXEC_SOURCES	=	src/D-Bus-Client/*.vala

EXEC_BINARY	=	rocket-launcher

################################################################################
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
################################################################################

all: $(BINARYDIR)$(DAEMON_BINARY) $(BINARYDIR)$(EXEC_BINARY)
	@echo sucessfully compiled

clean:
	rm -f $(BINARYDIR)$(DAEMON_BINARY)
	rm -f $(BINARYDIR)$(EXEC_BINARY)
	@echo sucessfully cleaned

debug: DAEMON_CFLAGS	+=	--debug
debug: EXEC_CFLAGS	+=	--debug
debug: all

release: DAEMON_CFLAGS	+=	-X -O3
release: EXEC_CFLAGS	+=	-X -O3
release: all


$(BINARYDIR)$(DAEMON_BINARY): $(DAEMON_SOURCES)
	@echo "\n\nCompiling the daemon executable...\n"
	$(CC) $(DAEMON_CFLAGS) $(DAEMON_SOURCES) -o $(BINARYDIR)$(DAEMON_BINARY)

$(BINARYDIR)$(EXEC_BINARY): $(EXEC_SOURCES)
	@echo "\n\nCompiling the launcher executable...\n"
	$(CC) $(EXEC_CFLAGS) $(EXEC_SOURCES) -o $(BINARYDIR)$(EXEC_BINARY)


###############################################################################
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
###############################################################################

install: all
	cp $(BINARYDIR)$(DAEMON_BINARY) /usr/bin/$(DAEMON_BINARY)
	cp $(BINARYDIR)$(EXEC_BINARY) /usr/bin/$(EXEC_BINARY)
	
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
	ln --symbolic --force $(ICONDIR)512x512/apps/$(ICON).png /usr/share/pixmaps/$(ICON).png
	
	cp $(MISCDIR)$(DESKTOPFILE) $(DESKTOPFILEDIR)$(DESKTOPFILE)
	update-icon-caches $(ICONDIR)
	@echo sucessfully installed

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
	update-icon-caches $(ICONDIR)
	@echo sucessfully uninstalled

linecount:
	wc --lines $(DAEMON_SOURCES) $(EXEC_SOURCES)
