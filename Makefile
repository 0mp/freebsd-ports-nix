# $FreeBSD$

PORTNAME=	nix
DISTVERSION=	2.3.1
CATEGORIES=	sysutils

MAINTAINER=	0mp@FreeBSD.org
COMMENT=	Purely functional package manager

LICENSE=	LGPL21
LICENSE_FILE=	${WRKSRC}/COPYING

BUILD_DEPENDS=	${LOCALBASE}/share/aclocal/ax_cxx_compile_stdcxx.m4:devel/autoconf-archive \
		bash:shells/bash \
		docbook-xsl-ns>=0:textproc/docbook-xsl-ns \
		gnustat:sysutils/coreutils \
		grealpath:sysutils/coreutils \
		xmllint:textproc/libxml2 \
		xsltproc:textproc/libxslt
LIB_DEPENDS=	libaws-cpp-sdk-core.so:devel/aws-sdk-cpp \
		libaws-cpp-sdk-s3.so:devel/aws-sdk-cpp \
		libaws-cpp-sdk-transfer.so:devel/aws-sdk-cpp \
		libboost_context.so:devel/boost-libs \
		libbrotlienc.so:archivers/brotli \
		libcurl.so:ftp/curl \
		libeditline.so:devel/editline \
		libgc.so:devel/boehm-gc \
		libsodium.so:security/libsodium
TEST_DEPENDS=	dot:graphics/graphviz \
		git:devel/git \
		gxargs:misc/findutils \
		hg:devel/mercurial

USES=		autoreconf bison compiler:c++17-lang gmake localbase pkgconfig \
		sqlite:3 ssl tar:xz
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
# Workaround for:
#   /usr/bin/ld: error: undefined symbol: SHA512_Update
MAKE_ARGS=		libutil_ALLOW_UNDEFINED=yes
# XXX: Tests require the port to be installed on the system. Being installed in
# the stage directory is not enough.
TEST_ARGS=		nix_tests="${_SETUP_TESTS} ${_PASSING_TESTS} ${_HANGING_TESTS}"
TEST_TARGET=		installcheck

# grealpath and gnustat are needed for tests.
BINARY_ALIAS=	realpath=grealpath stat=gnustat

SUB_FILES=	pkg-message

GROUPS=		nixbld

OPTIONS_DEFINE=	DOCS
# XXX: Test with DOCS turned off.

_BASH=		${LOCALBASE}/bin/bash
_STRIP_TARGETS=	bin/nix bin/nix-build bin/nix-channel bin/nix-collect-garbage \
		bin/nix-copy-closure bin/nix-daemon bin/nix-env \
		bin/nix-instantiate bin/nix-prefetch-url bin/nix-store \
		lib/libnixexpr.so lib/libnixmain.so lib/libnixstore.so \
		lib/libnixutil.so

# These tests are required to be executed before any other tests.
_SETUP_TESTS=	init.sh
# These tests never finish.
_HANGING_TESTS=	restricted.sh
# These tests just pass.
_PASSING_TESTS=	add.sh binary-cache.sh brotli.sh build-dry.sh build-remote.sh \
		case-hack.sh check-refs.sh check-reqs.sh check.sh \
		dependencies.sh dump-db.sh export-graph.sh export.sh \
		fetchGit.sh fetchMercurial.sh fetchurl.sh filter-source.sh \
		fixed.sh function-trace.sh gc-auto.sh gc-concurrent.sh \
		gc-runtime.sh gc.sh hash.sh import-derivation.sh init.sh \
		lang.sh linux-sandbox.sh logging.sh misc.sh multiple-outputs.sh \
		nar-access.sh nix-build.sh nix-channel.sh nix-copy-ssh.sh \
		nix-profile.sh nix-shell.sh optimise-store.sh pass-as-file.sh \
		placeholders.sh plugins.sh post-hook.sh pure-eval.sh \
		referrers.sh remote-store.sh repair.sh run.sh search.sh \
		secure-drv-outputs.sh signing.sh simple.sh structured-attrs.sh \
		tarball.sh timeout.sh user-envs.sh

post-install:
	@${MKDIR} ${STAGEDIR}${DATADIR}
	${INSTALL_SCRIPT} ${FILESDIR}/add-nixbld-users ${STAGEDIR}${DATADIR}

	@${RM} ${STAGEDIR}${PREFIX}/libexec/nix/build-remote
	@${RLN} ${STAGEDIR}${PREFIX}/bin/nix ${STAGEDIR}${PREFIX}/libexec/nix/build-remote

	@cd ${STAGEDIR}${PREFIX} && ${STRIP_CMD} ${_STRIP_TARGETS}

pre-test:
	${MKDIR} /tmp/nix-test

	${REINPLACE_CMD} -e 's| xargs | gxargs |g' ${WRKSRC}/tests/push-to-store.sh
	${REINPLACE_CMD} -e 's| touch | /usr/bin/touch |g' ${WRKSRC}/tests/timeout.nix
	${REINPLACE_CMD} -e 's| touch | /usr/bin/touch |g' ${WRKSRC}/tests/check-reqs.nix
	${REINPLACE_CMD} -e 's| touch | /usr/bin/touch |g' ${WRKSRC}/tests/nar-access.nix
	${REINPLACE_CMD} -e 's| touch | /usr/bin/touch |g' ${WRKSRC}/tests/pass-as-file.sh
	${REINPLACE_CMD} -e 's| date | ${LOCALBASE}/bin/gdate |g' ${WRKSRC}/tests/check.nix

	${REINPLACE_CMD} -e 's| wc -l)| /usr/bin/grep -c .)|g' ${WRKSRC}/tests/gc-auto.sh
	${REINPLACE_CMD} -e 's| tar c tarball)| tar -cf - tarball)|' ${WRKSRC}/tests/tarball.sh
	${REINPLACE_CMD} -e 's|^grep |/usr/bin/grep |' ${WRKSRC}/tests/check.sh

post-test:
	${RM} -r /tmp/nix-test

.include <bsd.port.mk>
