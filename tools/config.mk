## Set VER and URLBASE then include this

NAME?=$(shell basename $(CURDIR))
PKGNAME?=$(NAME)-$(VER)
SRCEXT?=tar.xz
SRCURL?=$(URLBASE)/$(PKGNAME)/$(PKGNAME).$(SRCEXT)
SRCPKG?=$(PKGNAME).$(SRCEXT)
SRCDIR?=./$(PKGNAME)
TARGETPKG?=$(CURDIR)/../packages/$(PKGNAME).tar.xz

all: package

fetch: $(SRCPKG)
extract: $(SRCDIR).ex
config: $(SRCDIR).cf
build: $(SRCDIR).bd
dest: $(SRCDIR).dd
package: $(TARGETPKG)

clean:
	rm -rf $(TARGETPKG) $(SRCPKG) $(SRCDIR) $(SRCDIR).{ex,cf,bd,dd} dest


$(SRCPKG):
	@echo [FETCH] 
	curl -# -C - $(SRCURL) -o $(SRCPKG)

$(SRCDIR).ex: $(SRCPKG)
	@echo [EXTRACT]
	tar xf $^
	touch $@
	

$(SRCDIR).cf: $(SRCDIR).ex
	@echo [CONFIG]
	cd $(SRCDIR) && \
		CPPFLAGS=-fexceptions ./configure --prefix=$(CURDIR)/tools
	touch $@

$(SRCDIR).bd: $(SRCDIR).cf
	@echo [BUILD]
	cd $(SRCDIR) && make $(MAKEOPTS)
	touch $@

$(SRCDIR).dd: $(SRCDIR).bd
	@echo [DEST]
	cd $(SRCDIR) && make DESTDIR=$(CURDIR)/dest install
	touch $@

$(TARGETPKG): $(SRCDIR).dd
	cd dest && tar cJf $@ .


