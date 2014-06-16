LIB_VERSION				:=		0.1
SHARED_LIBRARY			:=		librocketlauncher.so
VAPI_FILE				:=		rocketlauncher-$(LIB_VERSION).vapi
HEADER_FILE				:=		rocketlauncher-$(LIB_VERSION).h
BINARY					:=		rocket-launcher

GEN_FLAGS				:=		--pkg glib-2.0 --target-glib=2.32
GEN_FLAGS				+=		--pkg gio-2.0
GEN_FLAGS				+=		--pkg x11
GEN_FLAGS				+=		--pkg gtk+-3.0
GEN_FLAGS				+=		--ccode
GEN_FLAGS				+=		"$(RCKTL_DIR)/$(VAPI_FILE)"

CC_FLAGS				:=		-w
CC_FLAGS				+=		-I"$(RCKTL_DIR)"
CC_FLAGS				+=		`pkg-config --cflags gobject-2.0`
CC_FLAGS				+=		`pkg-config --cflags glib-2.0`
CC_FLAGS				+=		`pkg-config --cflags gio-2.0`
CC_FLAGS				+=		`pkg-config --cflags gtk+-3.0`

LD_FLAGS				:=		-L"$(RCKTL_DIR)"
LD_FLAGS				+=		-lrocketlauncher
LD_FLAGS				+=		`pkg-config --libs gobject-2.0`
LD_FLAGS				+=		`pkg-config --libs glib-2.0`
LD_FLAGS				+=		`pkg-config --libs gio-2.0`
LD_FLAGS				+=		`pkg-config --libs gtk+-3.0`

SOURCES					:=		AppGrid.vala
SOURCES					+=		AppIcon.vala
SOURCES					+=		CategoryButton.vala
SOURCES					+=		Constants.vala
SOURCES					+=		DBusManager.vala
SOURCES					+=		Main.vala
SOURCES					+=		MainWindow.vala

OBJECTS					:=		${SOURCES:.vala=.o}
VAPIFILES				:=		${SOURCES:.vala=.vapi}


ifndef RCKTL_DIR
	$(error variable RCKTL_DIR is not set)
endif

ifndef RCKTL_INSTALL_LIB_DIR
	$(error variable RCKTL_INSTALL_LIB_DIR is not set)
endif

ifdef RCKTL_BUILD_DEBUG
	GEN_FLAGS			+=		--debug
	CC_FLAGS			+=		--debug
endif

ifdef RCKTL_BUILD_RELEASE
	CC_FLAGS			+=		-O3
endif

ifdef RCKTL_FEATURE_APPINDICATOR
	GEN_FLAGS			+=		-D RCKTL_FEATURE_APPINDICATOR
	GEN_FLAGS			+=		--pkg appindicator3-0.1
	CC_FLAGS			+=		`pkg-config --cflags appindicator3-0.1`
	LD_FLAGS			+=		`pkg-config --libs appindicator3-0.1`
endif


.SECONDARY:
	@#

.PHONY: all clean install uninstall
	@#


all: $(RCKTL_DIR)/$(BINARY)
	@#

clean:
	rm -f ${SOURCES:.vala=.c}
	rm -f ${SOURCES:.vala=.h}
	rm -f ${SOURCES:.vala=.o}
	rm -f ${SOURCES:.vala=.vapi}
	rm -f "$(RCKTL_DIR)/$(BINARY)"

install:
	install -D "$(RCKTL_DIR)/$(BINARY)" "$(DESTDIR)$(RCKTL_INSTALL_LIB_DIR)/$(BINARY)"

uninstall:
	rm -f "$(DESTDIR)$(RCKTL_INSTALL_LIB_DIR)/$(BINARY)"


%.vapi: %.vala
	@echo "  GEN     $(notdir $@)"
	@valac --fast-vapi="$@" --deps="$(subst .vapi,.dep,$@)" $<

MISSINGVAPIFILES=$(subst $(subst .c,.vapi,$@),,$(VAPIFILES))
%.c: $(MISSINGVAPIFILES) %.vala
	@echo "  GEN     $(notdir $@)"
	@valac $(GEN_FLAGS) $(addprefix --use-fast-vapi=,$(MISSINGVAPIFILES)) "$(subst .c,.vala,$@)"

%.o: %.c
	@echo "  CC      $(notdir $@)"
	@$(CC) $(CC_FLAGS) -c $<

$(RCKTL_DIR)/$(BINARY): $(OBJECTS)
	@echo "  LD      $(notdir $@)"
	@$(CC) $(OBJECTS) $(LD_FLAGS) -o "$(RCKTL_DIR)/$(BINARY)"

