VER=1.0.1
SRCURL=http://www.multiprecision.org/mpc/download/mpc-1.0.1.tar.gz

include ../config.mk

config:
	LDFLAGS="-Wl,-rpath,${FIXME}/tools/lib" \
		  ./configure --prefix=${FIXME}-tools \
		  --with-gmp=${FIXME}/tools \
		  --with-mpfr=${FIXME}/tools
