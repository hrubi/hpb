TOPDIR:=$(realpath $(dir $(lastword $(MAKEFILE_LIST))))

CONFIG=$(TOPDIR)/config.mk
ifneq ($(wildcard $(CONFIG)),)
include $(TOPDIR)/config.mk
endif

ifeq ($(NAME),)
$(error NAME is not defined)
endif
PKGNAME?=$(NAME)-$(VER)
SRCEXT?=tar.xz
SRCPKG?=$(PKGNAME).$(SRCEXT)
SRCURL?=$(URLBASE)/$(SRCPKG)
SRCPKGPATH=$(SRCDIR)/$(SRCPKG)
ifeq ($(WORKDIR),)
WORKDIR:=$(CURDIR)/build
else
WORKDIR:=$(WORKDIR)/$(NAME)
endif
BUILDDIR?=$(WORKDIR)/$(PKGNAME)
DESTDIR?=$(WORKDIR)/dest
SRCDIR?=$(WORKDIR)
PKGDIR?=$(TOPDIR)/packages
TARGETPKG?=$(PKGDIR)/$(PKGNAME).tar.xz

STAMP_EXTRACTED=$(WORKDIR)/.ex
STAMP_PATCHED=$(WORKDIR)/.pt
STAMP_CONFIGURED=$(WORKDIR)/.cf
STAMP_BUILT=$(WORKDIR)/.bd
STAMP_DEST=$(WORKDIR)/.dd

.PHONY: all fetch prepare extract patch config build dest package clean

define fetch
	mkdir -p $(SRCDIR)
	curl -# -f -C - $(SRCURL) -o $(SRCPKGPATH)
endef

define extract
	mkdir -p $(WORKDIR)
	tar -xf $(SRCPKGPATH) -C $(WORKDIR)
endef

# FIXME - determine -pnum automatically
define patch
	@for i in $(PATCHES); do \
		echo "[PATCH $$i]"; \
		echo patch -p$(if $(PATCHSTRIP),($PATCHSTRIP),1) -d$(BUILDDIR) $$i; \
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

all: package

fetch: $(SRCPKGPATH)
extract: $(STAMP_EXTRACTED)
patch: $(STAMP_PATCHED)
config: $(STAMP_CONFIGURED)
build: $(STAMP_BUILT)
dest: $(STAMP_DEST)
package: $(TARGETPKG)

clean:
	rm -rf $(TARGETPKG) $(SRCPKGPATH) $(BUILDDIR) $(DESTDIR) \
		$(STAMP_EXTRACTED) $(STAMP_PATCHED) $(STAMP_CONFIGURED) \
		$(STAMP_BUILT) $(STAMP_DEST)

$(SRCPKGPATH):
	@echo [FETCH]
	$(fetch)

$(STAMP_EXTRACTED): $(SRCPKGPATH)
	@echo [EXTRACT]
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
	$(dest)
	@touch $@

$(TARGETPKG): $(STAMP_DEST)
	mkdir -p $(PKGDIR)
	cd $(DESTDIR) && \
		tar cJf $@ *

