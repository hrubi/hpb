## Set VER and URLBASE then include this

NAME?=$(shell basename $(CURDIR))
PKGNAME?=$(NAME)-$(VER)
URLSUBDIR?=$(PKGNAME)
SRCEXT?=tar.xz
SRCPKG?=$(PKGNAME).$(SRCEXT)
SRCURL?=$(URLBASE)/$(URLSUBDIR)/$(SRCPKG)
SRCDIR?=$(CURDIR)/$(PKGNAME)
DESTDIR?=$(CURDIR)/dest
TARGETPKG?=$(CURDIR)/../packages/$(PKGNAME).tar.xz

all: package

fetch: $(SRCPKG)
extract: .ex
config: .cf
build: .bd
dest: .dd
package: $(TARGETPKG)

clean:
	rm -rf $(TARGETPKG) $(SRCPKG) $(SRCDIR) $(SRCDIR).{ex,cf,bd,dd} dest


$(SRCPKG):
	@echo [FETCH] 
	curl -# -C - $(SRCURL) -o $(SRCPKG)

.ex: $(SRCPKG)
	@echo [EXTRACT]
	tar xf $^
	touch $@
	

.cf: .ex
	@echo [CONFIG]
	cd $(SRCDIR) && \
		$(CFGVARS) ./configure $(CFGFLAGS)
	touch $@

.bd: .cf
	@echo [BUILD]
	cd $(SRCDIR) && make $(MAKEOPTS)
	touch $@

.dd: .bd
	@echo [DEST]
	rm -rf $(DESTDIR)
	cd $(SRCDIR) && make DESTDIR=$(DESTDIR) install
	touch $@

$(TARGETPKG): .dd
	cd $(DESTDIR) && tar cJf $@ .


