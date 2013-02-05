include $(HOME)/projects/hpb/make.conf

N=gmp
V=5.1.0
P=${N}-${V}
SOURCE=ftp://ftp.gmplib.org/pub/${P}/${P}.tar.xz
SHA1SUM=5119848b69259de9384994ff7d4fbc2f54074895

all: build package

build:
	mkdir -p build
	cd build && \
		curl -# -C - -O ${SOURCE}
	sha1sum build/${P}.tar.xz | grep -q ${SHA1SUM}
	tar xf build/${P}.tar.xz -C build
	cd build/${P} && \
		CPPFLAGS=-fexceptions ./configure --prefix=${ROOT}/tools && \
		make ${MAKEOPTS} && \
		make ${MAKEOPTS} check

package:
	cd build/${P} && \
		make DESTDIR=${CURDIR}/dest install
	cd dest && \
		tar cJf ${CURDIR}/${P}.tar.xz .

install:
	tar xJf ${CURDIR}/${P}.tar.xz -C ${ROOT}

clean:
	rm -rf build dest
