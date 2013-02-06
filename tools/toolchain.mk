TOOLDIR:=$(realpath $(dir $(lastword $(MAKEFILE_LIST))))
PKGDIR=$(TOOLDIR)/packages

pkgdir:
	@echo $(PKGDIR)
