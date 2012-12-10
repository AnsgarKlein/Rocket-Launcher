PACKAGES	=	--pkg glib-2.0 --pkg gio-2.0 --pkg gtk+-3.0 --pkg appindicator3-0.1

CC		=	valac
CFLAGS		=	--debug --thread $(PACKAGES) --target-glib=2.32
SOURCES		+=	src/*.vala
SOURCES		+=	src/Backend/*.vala
SOURCES		+=	src/Gui/*.vala
SOURCES		+=	src/AppIndicator/*.vala

BINARYDIR	=	binary/
BINARY		=	panzerfaust-launcher

MISCDIR		=	res/

ICONDIR		=	/usr/share/pixmaps/
ICON		=	panzerfaust-launcher.png

DESKTOPFILEDIR	=	/usr/share/applications/
DESKTOPFILE	=	panzerfaust-launcher.desktop


all: Panzerfaust
	@echo sucessfully compiled

install: all $(MISCDIR)$(ICON)
	cp $(BINARYDIR)$(BINARY) /usr/bin/$(BINARY)
	cp $(MISCDIR)$(ICON) $(ICONDIR)$(ICON)
	cp $(MISCDIR)$(DESKTOPFILE) $(DESKTOPFILEDIR)$(DESKTOPFILE)
	@echo sucessfully installed

uninstall:
	rm /usr/bin/$(BINARY)
	rm $(ICONDIR)$(ICON)
	rm $(DESKTOPFILEDIR)$(DESKTOPFILE)
	@echo sucessfully uninstalled

clean:
	rm $(BINARYDIR)$(BINARY)
	@echo sucessfully cleaned

linecount:
	wc --lines $(SOURCES)

###############################################################################
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
###############################################################################


Panzerfaust: $(BINARYDIR)
	$(CC) $(CFLAGS) $(SOURCES) -o $(BINARYDIR)$(BINARY)

$(BINARYDIR):
	mkdir -p $(BINARYDIR)
