# $FreeBSD$

PORTNAME=	nix
DISTVERSION=	2.3.1
CATEGORIES=	sysutils

MAINTAINER=	0mp@FreeBSD.org
COMMENT=	Purely functional package manager

LICENSE=	LGPL21
LICENSE_FILE=	${WRKSRC}/COPYING

# XXX: Consider adding aws-sdk-cpp>0:devel/aws-sdk-cpp when S3 support is
# compiling.
BUILD_DEPENDS=	${LOCALBASE}/share/aclocal/ax_cxx_compile_stdcxx.m4:devel/autoconf-archive \
		bash:shells/bash \
		docbook-xsl-ns>=0:textproc/docbook-xsl-ns \
		gnustat:sysutils/coreutils \
		grealpath:sysutils/coreutils \
		xmllint:textproc/libxml2 \
		xsltproc:textproc/libxslt
LIB_DEPENDS=	libboost_context.so:devel/boost-libs \
		libbrotlienc.so:archivers/brotli \
		libcurl.so:ftp/curl \
		libeditline.so:devel/editline \
		libgc.so:devel/boehm-gc \
		libsodium.so:security/libsodium
TEST_DEPENDS=	dot:graphics/graphviz

USES=		autoreconf bison:build compiler:c++17-lang gmake localbase \
		pkgconfig sqlite:3 ssl tar:xz
USE_GITHUB=	yes
GH_ACCOUNT=	NixOS
USE_LDCONFIG=	yes

HAS_CONFIGURE=		yes
# Workaround for bashisms in the configure script.
CONFIGURE_SHELL=	${_BASH}
CONFIGURE_ARGS=		--disable-seccomp-sandboxing \
			--enable-gc
CONFIGURE_ENV=		OPENSSL_CFLAGS="-I ${OPENSSLINC}" \
			OPENSSL_LIBS="-L ${OPENSSLLIB}"
# XXX
# Workaround for:
#   /usr/bin/ld: error: undefined symbol: SHA512_Update
MAKE_ARGS=		libutil_ALLOW_UNDEFINED=yes \
			mandir=${MANPREFIX}/man
MAKE_JOBS_UNSAFE=	yes
TEST_ENV=		PATH="$${PATH}:${STAGEDIR}${PREFIX}/bin"
TEST_TARGET=		installcheck

# grealpath and gnustat are needed for tests.
BINARY_ALIAS=	realpath=grealpath stat=gnustat

GROUPS=		nixbld

OPTIONS_DEFINE=	DOCS
# XXX: Test with DOCS turned off.

_BASH=		${LOCALBASE}/bin/bash
_STRIP_TARGETS=	bin/nix bin/nix-build bin/nix-channel bin/nix-collect-garbage \
		bin/nix-copy-closure bin/nix-daemon bin/nix-env \
		bin/nix-instantiate bin/nix-prefetch-url bin/nix-store \
		lib/libnixexpr.so lib/libnixmain.so lib/libnixstore.so \
		lib/libnixutil.so

post-install:
	@${MKDIR} ${STAGEDIR}${DATADIR}
	${INSTALL_SCRIPT} ${FILESDIR}/add-nixbld-users ${STAGEDIR}${DATADIR}
	@cd ${STAGEDIR}${PREFIX} && ${STRIP_CMD} ${_STRIP_TARGETS}

pre-test:
	# Disable hanging tests.
	${REINPLACE_CMD} -e 's|restricted.sh||g' ${WRKSRC}/tests/local.mk


.include <bsd.port.mk>
