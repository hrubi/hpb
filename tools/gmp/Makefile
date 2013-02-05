#HPB_CONF=/home/hrubi/projects/hpb/make.conf
#include ${HPB_CONF}

.PHONY: fetch extract configure build package install

N=gmp
V=5.1.0
P=${N}-${V}
SOURCE=ftp://ftp.gmplib.org/pub/${P}/${P}.tar.xz
SHA1SUM=5119848b69259de9384994ff7d4fbc2f54074895

BUILD=build

FETCH=${P}.tar.xz
EXTRACT=${BUILD}/${N}/${P}
CONFIGURE=${EXTRACT}/Makefile
PACKAGE=${PACKAGES}/${P}.tar.xz


fetch:    	${FETCH}
extract:  	| ${EXTRACT}
configure: 	${CONFIGURE}
package: 	${PACKAGE}

${FETCH}:
	curl -# -C - -O ${SOURCE}

${EXTRACT}:
	sha1sum ${FETCH} | grep -q ${SHA1SUM}
	mkdir -p ${BUILD}/${N}
	tar xf ${P}.tar.xz -C ${BUILD}/${N}

${CONFIGURE}:
	cd ${EXTRACT} && \
		CPPFLAGS=-fexceptions ./configure --prefix=${ROOT}/tools

build: ${CONFIGURE}
	cd ${BUILD}/${N}/${P} && \
		make ${MAKEOPTS} && \
		make ${MAKEOPTS} check

package: build
	cd ${BUILD}/${N}/${P}
	make DESTDIR=${BUILD}/${N}/dest install
	cd ${BUILD}/${N}/dest
	tar cJf ${PACKAGES}/${P}.tar.xz .

install: package
	tar xJf ${PACKAGES}/${P}.tar.xz -C ${ROOT}

#all: install
