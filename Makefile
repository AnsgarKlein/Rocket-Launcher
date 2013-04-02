CC		=	valac
BINARYDIR	=	build/

MISCDIR		=	res/

ICONDIR		=	/usr/share/pixmaps/
ICON		=	panzerfaust-launcher.png

DESKTOPFILEDIR	=	/usr/share/applications/
DESKTOPFILE	=	panzerfaust-launcher.desktop

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

DAEMON_BINARY	=	panzerfaust-launcher-daemon

################################################################################
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
################################################################################

EXEC_PACKAGES	=	--pkg glib-2.0
EXEC_PACKAGES	+=	--pkg gio-2.0

EXEC_CFLAGS	+=	--thread
EXEC_CFLAGS	+=	$(EXEC_PACKAGES)
EXEC_CFLAGS	+=	-X -w

EXEC_SOURCES	=	src/D-Bus-Client/*.vala

EXEC_BINARY	=	panzerfaust-launcher

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
	
	cp $(MISCDIR)$(ICON) $(ICONDIR)$(ICON)
	cp $(MISCDIR)$(DESKTOPFILE) $(DESKTOPFILEDIR)$(DESKTOPFILE)
	@echo sucessfully installed

uninstall:
	rm -f /usr/bin/$(DAEMON_BINARY)
	rm -f /usr/bin/$(EXEC_BINARY)
	
	rm -f $(ICONDIR)$(ICON)
	rm -f $(DESKTOPFILEDIR)$(DESKTOPFILE)
	@echo sucessfully uninstalled

linecount:
	wc --lines $(DAEMON_SOURCES) $(EXEC_SOURCES)
