NAME?=$(shell basename $(CURDIR))
PKGNAME?=$(NAME)-$(VER)
SRCEXT?=tar.xz
SRCPKG?=$(PKGNAME).$(SRCEXT)
SRCURL?=$(URLBASE)/$(SRCPKG)
SRCDIR?=$(CURDIR)/$(PKGNAME)
DESTDIR?=$(CURDIR)/dest
PKGDIR?=$(CURDIR)/../packages
TARGETPKG?=$(PKGDIR)/$(PKGNAME).tar.xz

STAMP_EXTRACTED=.ex
STAMP_PATCHED=.pt
STAMP_CONFIGURED=.cf
STAMP_BUILT=.bd
STAMP_DEST=.dd

.PHONY: all package fetch extract config build dest clean patch

define fetch
	curl -# -f -C - $(SRCURL) -o $(SRCPKG)
endef

define extract
	tar -xf $^
endef

# FIXME - determine -pnum automatically
define patch
	@for i in $(PATCHES); do \
		echo "[PATCH $$i]"; \
		echo patch -p$(if $(PATCHSTRIP),($PATCHSTRIP),1) -d$(SRCDIR) $$i; \
	done
endef

define config
	cd $(SRCDIR) && \
		$(CFG_VARS) ./configure $(CFG_FLAGS)
endef

define build
	cd $(SRCDIR) && \
		make $(MAKEOPTS) $(MAKE_VARS)
endef

define dest
	cd $(SRCDIR) && \
		make DESTDIR=$(DESTDIR) $(MAKE_INSTALL_VARS) install
endef

all: package

fetch: $(SRCPKG)
extract: $(STAMP_EXTRACTED)
patch: $(STAMP_PATCHED)
config: $(STAMP_CONFIGURED)
build: $(STAMP_BUILT)
dest: $(STAMP_DEST)
package: $(TARGETPKG)

clean:
	rm -rf $(TARGETPKG) $(SRCPKG) $(SRCDIR) $(DESTDIR) \
		$(STAMP_EXTRACTED) $(STAMP_PATCHED) $(STAMP_CONFIGURED) \
		$(STAMP_BUILT) $(STAMP_DEST)

$(SRCPKG):
	@echo [FETCH]
	$(fetch)

$(STAMP_EXTRACTED): $(SRCPKG)
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

$(TARGETPKG): dest
	cd $(DESTDIR) && \
		tar cJf $@ .

