NAME?=$(shell basename $(CURDIR))
PKGNAME?=$(NAME)-$(VER)
URLSUBDIR?=$(PKGNAME)
SRCEXT?=tar.xz
SRCPKG?=$(PKGNAME).$(SRCEXT)
SRCURL?=$(URLBASE)/$(URLSUBDIR)/$(SRCPKG)
SRCDIR?=$(CURDIR)/$(PKGNAME)
DESTDIR?=$(CURDIR)/dest
PKGDIR?=$(CURDIR)/../packages
TARGETPKG?=$(PKGDIR)/$(PKGNAME).tar.xz
CFGCMD?=./configure 

.PHONY: all package fetch extract config build dest clean patch

all: package

fetch: $(SRCPKG)
extract: .ex
patch: .pt
config: .cf
build: .bd
dest: .dd
package: $(TARGETPKG)

clean:
	rm -rf $(TARGETPKG) $(SRCPKG) $(SRCDIR) .{ex,pt,cf,bd,dd} $(DESTDIR)


$(SRCPKG):
	@echo [FETCH] 
	curl -# -C - $(SRCURL) -o $(SRCPKG)

.ex: $(SRCPKG)
	@echo [EXTRACT]
	tar xf $^
	@touch $@
	

.pt: .ex
	@for i in $(wildcard *.patch); do echo "[PATCH $$i]"; echo patch -p0 -d$(SRCDIR) $$i; done
	@touch $@ 


.cf: .pt
	@echo [CONFIG]
	cd $(SRCDIR) && \
		$(CFGVARS) $(CFGCMD) $(CFGFLAGS)
	@touch $@

.bd: .cf
	@echo [BUILD]
	cd $(SRCDIR) && make $(MAKEOPTS)
	@touch $@

.dd: .bd 
	@echo [DEST]
	rm -rf $(DESTDIR)
	cd $(SRCDIR) && make DESTDIR=$(DESTDIR) install
	@touch $@

$(TARGETPKG): dest
	cd $(DESTDIR) && tar cJf $@ .


