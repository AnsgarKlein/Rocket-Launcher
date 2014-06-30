LIB_VERSION				:=		0.1
SHARED_LIBRARY			:=		librocketlauncher.so
VAPI_FILE				:=		rocketlauncher-$(LIB_VERSION).vapi
HEADER_FILE				:=		rocketlauncher-$(LIB_VERSION).h

GEN_PACKAGES			:=		--pkg glib-2.0 --target-glib=2.32
GEN_PACKAGES			+=		--pkg gio-2.0
GEN_PACKAGES			+=		--pkg x11

GEN_FLAGS				:=		$(GEN_PACKAGES)
GEN_FLAGS				+=		--ccode
GEN_FLAGS				+=		--header="$(RCKTL_DIR)/$(HEADER_FILE)"
GEN_FLAGS				+=		--vapi="$(RCKTL_DIR)/$(VAPI_FILE)"

CC_PACKAGES				:=		`pkg-config --cflags gobject-2.0`
CC_PACKAGES				+=		`pkg-config --cflags glib-2.0`
CC_PACKAGES				+=		`pkg-config --cflags gio-2.0`
CC_PACKAGES				+=		`pkg-config --cflags x11`

CC_FLAGS				:=		-w
CC_FLAGS				+=		-fPIC
CC_FLAGS				+=		-shared

LD_FLAGS				:=		-fPIC
LD_FLAGS				+=		-shared
LD_FLAGS				+=		`pkg-config --libs gobject-2.0`
LD_FLAGS				+=		`pkg-config --libs glib-2.0`
LD_FLAGS				+=		`pkg-config --libs gio-2.0`
LD_FLAGS				+=		`pkg-config --libs x11`

SOURCES					:=		ApplicationHandler.vala
SOURCES					+=		App.vala
SOURCES					+=		Constants.vala
SOURCES					+=		IconDirectory.vala
SOURCES					+=		IconManager.vala
SOURCES					+=		IconTheme.vala
SOURCES					+=		Printer.vala

OBJECTS					:=		${SOURCES:.vala=.o}
VAPIFILES				:=		${SOURCES:.vala=.vapi}


ifndef RCKTL_DIR
	$(error variable RCKTL_DIR is not set)
endif

ifndef RCKTL_INSTALL_LIB_DIR
	$(error variable RCKTL_INSTALL_LIB_DIR is not set)
endif

ifdef RCKTL_BUILD_DEBUG
	GEN_FLAGS				+=		--debug
	CC_FLAGS				+=		--debug
endif

ifdef RCKTL_BUILD_RELEASE
	CC_FLAGS				+=		-O3
endif


.SECONDARY:
	@#

.PHONY: all clean install uninstall
	@#


all: $(SOURCES) $(CFILES) $(RCKTL_DIR)/$(SHARED_LIBRARY) $(RCKTL_DIR)/$(VAPI_FILE) $(RCKTL_DIR)/$(HEADER_FILE)
	@#

clean:
	rm -f ${SOURCES:.vala=.c}
	rm -f ${SOURCES:.vala=.h}
	rm -f ${SOURCES:.vala=.o}
	rm -f ${SOURCES:.vala=.vapi}
	rm -f "$(RCKTL_DIR)/$(VAPI_FILE)"
	rm -f "$(RCKTL_DIR)/$(HEADER_FILE)"
	rm -f "$(RCKTL_DIR)/$(SHARED_LIBRARY)"

install:
	install -D "$(RCKTL_DIR)/$(SHARED_LIBRARY)" "$(DESTDIR)$(RCKTL_INSTALL_LIB_DIR)/$(SHARED_LIBRARY)"

uninstall:
	rm -f "$(DESTDIR)$(RCKTL_INSTALL_LIB_DIR)/$(SHARED_LIBRARY)"


%.vapi: %.vala
	@echo "  GEN     $(notdir $@)"
	@valac --fast-vapi="$@" $<

MISSINGVAPIFILES=$(subst $(subst .c,.vapi,$@),,$(VAPIFILES))
$(RCKTL_DIR)/$(HEADER_FILE):
$(RCKTL_DIR)/$(VAPI_FILE):
%.c: $(MISSINGVAPIFILES) %.vala
	@echo "  GEN     $(notdir $@)"
	@valac $(GEN_FLAGS) $(addprefix --use-fast-vapi=,$(MISSINGVAPIFILES)) "$(subst .c,.vala,$@)"

%.o: %.c
	@echo "  CC      $(notdir $@)"
	@$(CC) $(CC_FLAGS) $(CC_PACKAGES) -c $<

$(RCKTL_DIR)/$(SHARED_LIBRARY): $(OBJECTS)
	@echo "  LD      $(notdir $@)"
	@$(CC) $(OBJECTS) $(LD_FLAGS) -o "$(RCKTL_DIR)/$(SHARED_LIBRARY)"

