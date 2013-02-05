VER=3.1.1
SRCURL=http://www.mpfr.org/mpfr-current/mpfr-3.1.1.tar.xz

include ../config.mk

config:
	LDFLAGS="-Wl,-rpath,${FIXME}tools/lib" \
		./configure --prefix=${FIXME}/tools --enable-shared \
		--with-gmp=${FIXME}/tools

