TOPDIR:=$(realpath $(dir $(lastword $(MAKEFILE_LIST))))
MKDIR:=$(TOPDIR)/mk

CONFIG=$(TOPDIR)/config.mk
ifneq ($(wildcard $(CONFIG)),)
include $(TOPDIR)/config.mk
endif

ifeq ($(NAME),)
$(error NAME is not defined)
endif

# Basic directories
ifeq ($(WORKDIR),)
WORKDIR:=$(CURDIR)/build
else
WORKDIR:=$(WORKDIR)/$(NAME)
endif
BUILDDIR?=$(WORKDIR)/$(PKGNAME)
DESTDIR?=$(WORKDIR)/dest
SRCDIR?=$(TOPDIR)/sources
PKGDIR?=$(TOPDIR)/packages
ROOTDIR?=$(TOPDIR)/rootfs

# Package variables
PKGNAME?=$(NAME)-$(VER)
SRCEXT?=tar.xz
SRCPKG?=$(PKGNAME).$(SRCEXT)
SRCURL?=$(URLBASE)/$(SRCPKG)
SRCPKGPATH=$(SRCDIR)/$(SRCPKG)
TARGETPKG?=$(PKGDIR)/$(PKGNAME).hrup
DBDIR?=$(ROOTDIR)/var/db/hpb

# State files
STAMP_EXTRACTED=$(WORKDIR)/.ex
STAMP_PATCHED=$(WORKDIR)/.pt
STAMP_CONFIGURED=$(WORKDIR)/.cf
STAMP_BUILT=$(WORKDIR)/.bd
STAMP_DEST=$(WORKDIR)/.dd
STAMP_INSTALL=$(DBDIR)/$(PKGNAME)

# Build step targets
.PHONY: all fetch prepare extract patch config build dest package install clean

all: package

fetch: $(SRCPKGPATH)
extract: $(STAMP_EXTRACTED)
patch: $(STAMP_PATCHED)
config: $(STAMP_CONFIGURED)
build: $(STAMP_BUILT)
dest: $(STAMP_DEST)
package: $(TARGETPKG)
install: $(STAMP_INSTALL)

clean:
	rm -rf $(TARGETPKG) $(BUILDDIR) $(DESTDIR) \
		$(STAMP_EXTRACTED) $(STAMP_PATCHED) $(STAMP_CONFIGURED) \
		$(STAMP_BUILT) $(STAMP_DEST)

$(SRCPKGPATH):
	@echo [FETCH]
	@mkdir -p $(SRCDIR)
	$(fetch)

$(STAMP_EXTRACTED): $(SRCPKGPATH)
	@echo [EXTRACT]
	@mkdir -p $(WORKDIR)
	$(extract)
	@touch $@


$(STAMP_PATCHED): $(STAMP_EXTRACTED)
	@echo [PATCH]
	$(patch)
	@touch $@


$(STAMP_CONFIGURED): $(STAMP_PATCHED)
	@echo [CONFIG]
	$(config)
	@touch $@

$(STAMP_BUILT): $(STAMP_CONFIGURED)
	@echo [BUILD]
	$(build)
	@touch $@

$(STAMP_DEST): $(STAMP_BUILT)
	@echo [DEST]
	@mkdir -p $(DESTDIR)
	$(dest)
	@touch $@

$(TARGETPKG): $(STAMP_DEST)
	@echo [PACKAGE]
	@mkdir -p $(PKGDIR)
	cd $(DESTDIR) && \
		tar cJf $@ *

$(STAMP_INSTALL): $(TARGETPKG)
	@echo [INSTALL]
	@mkdir -p $(ROOTDIR) $(DBDIR)
	tar -C $(ROOTDIR) -xJvf $(TARGETPKG) > $(STAMP_INSTALL)

# Build steps variables
# Can be customized in individual makefiles

define fetch
	curl -# -f -C - $(SRCURL) -o $(SRCPKGPATH)
endef

define extract
	tar -xf $(SRCPKGPATH) -C $(WORKDIR)
endef

# FIXME - determine -pnum automatically
define patch
	@for i in $(PATCHES); do \
		echo "[PATCH $$i]"; \
		echo patch -p$(if $(PATCHSTRIP),$(PATCHSTRIP),1) -d$(BUILDDIR) $$i; \
	done
endef

define config
	cd $(BUILDDIR) && \
		$(CFG_VARS) ./configure $(CFG_FLAGS)
endef

define build
	cd $(BUILDDIR) && \
		make $(MAKEOPTS) $(MAKE_VARS)
endef

define dest
	cd $(BUILDDIR) && \
		make DESTDIR=$(DESTDIR) $(MAKE_INSTALL_VARS) install
endef
