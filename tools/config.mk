

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

.PHONY: all package fetch extract config build dest clean

all: package

fetch: $(SRCPKG)
extract: .ex
config: .cf
build: .bd
dest: .dd
package: $(TARGETPKG)

clean:
	rm -rf $(TARGETPKG) $(SRCPKG) $(SRCDIR) .{ex,cf,bd,dd} dest


$(SRCPKG):
	@echo [FETCH] 
	curl -# -C - $(SRCURL) -o $(SRCPKG)

.ex: $(SRCPKG)
	@echo [EXTRACT]
	tar xf $^
	touch $@
	

.cf: extract
	@echo [CONFIG]
	cd $(SRCDIR) && \
		$(CFGVARS) $(CFGCMD) $(CFGFLAGS)
	touch $@

.bd: config
	@echo [BUILD]
	cd $(SRCDIR) && make $(MAKEOPTS)
	touch $@

.dd: build
	@echo [DEST]
	rm -rf $(DESTDIR)
	cd $(SRCDIR) && make DESTDIR=$(DESTDIR) install
	touch $@

$(TARGETPKG): dest
	cd $(DESTDIR) && tar cJf $@ .


