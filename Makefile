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
TEST_DEPENDS=	dot:graphics/graphviz \
		gxargs:misc/findutils \
		git:devel/git

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
# Workaround for:
#   /usr/bin/ld: error: undefined symbol: SHA512_Update
MAKE_ARGS=		libutil_ALLOW_UNDEFINED=yes \
			mandir=${MANPREFIX}/man
TEST_ARGS=		nix_tests="${_SETUP_TESTS} ${_PASSING_TESTS}"
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

# These tests are required to be executed before any tests as they prepare
# environment.
_SETUP_TESTS=	init.sh
# These tests never finish.
_HANGING_TESTS=	restricted.sh
# These tests probably fail due to something more complicated than a missing
# binary or an incompatibility between GNU and BSD tools.
_FAILING_TESTS=	check.sh
# These test suffer from some problems like a misconfigued testing environment
# (binaries are not found in the PATH) or incompatibilities between GNU and BSD
# tools.
_BROKEN_TESTS=	check-reqs.sh gc-auto.sh nar-access.sh pass-as-file.sh \
		tarball.sh timeout.sh fetchGit.sh
# These tests are skipped by the testing framework.
_SKIPPED_TESTS=	fetchMercurial.sh
# These tests just pass.
_PASSING_TESTS=	add.sh binary-cache.sh brotli.sh build-dry.sh build-remote.sh \
		case-hack.sh check-refs.sh dependencies.sh dump-db.sh \
		export-graph.sh export.sh fetchurl.sh filter-source.sh fixed.sh \
		function-trace.sh gc-concurrent.sh gc-runtime.sh gc.sh hash.sh \
		import-derivation.sh init.sh lang.sh linux-sandbox.sh \
		logging.sh misc.sh multiple-outputs.sh nix-build.sh \
		nix-channel.sh nix-copy-ssh.sh nix-profile.sh nix-shell.sh \
		optimise-store.sh placeholders.sh plugins.sh post-hook.sh \
		pure-eval.sh referrers.sh remote-store.sh repair.sh run.sh \
		search.sh secure-drv-outputs.sh signing.sh simple.sh \
		structured-attrs.sh user-envs.sh

post-install:
	@${MKDIR} ${STAGEDIR}${DATADIR}
	${INSTALL_SCRIPT} ${FILESDIR}/add-nixbld-users ${STAGEDIR}${DATADIR}
	@cd ${STAGEDIR}${PREFIX} && ${STRIP_CMD} ${_STRIP_TARGETS}

pre-test:
	${MKDIR} /tmp/nix-test

	# Patch tests.
	${REINPLACE_CMD} -e 's| xargs | gxargs |g' ${WRKSRC}/tests/push-to-store.sh

post-test:
	${RM} -r /tmp/nix-test

.include <bsd.port.mk>
