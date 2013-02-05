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
		CPPFLAGS=$(CPPFLAGS) ./configure --prefix=$(CURDIR)/tools
	touch $@

.bd: .cf
	@echo [BUILD]
	cd $(SRCDIR) && make $(MAKEOPTS)
	touch $@

.dd: .bd
	@echo [DEST]
	cd $(SRCDIR) && make DESTDIR=$(CURDIR)/dest install
	touch $@

$(TARGETPKG): .dd
	cd dest && tar cJf $@ .


