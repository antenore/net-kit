# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )
PYTHON_REQ_USE="threads(+)"

inherit cmake-utils python-any-r1

DESCRIPTION="C++ BitTorrent implementation focusing on efficiency and scalability"
HOMEPAGE="https://libtorrent.org https://github.com/arvidn/libtorrent"
SRC_URI="https://github.com/arvidn/libtorrent/releases/download/v2.0.2/libtorrent-rasterbar-2.0.2.tar.gz -> libtorrent-rasterbar-2.0.2.tar.gz"

LICENSE="BSD"
SLOT="0/11"
KEYWORDS="*"
IUSE="debug +dht doc examples gnutls libressl python +ssl static-libs test"

REQUIRED_USE="
	gnutls? ( ssl )
	libressl? ( ssl )
"

RESTRICT="!test? ( test )"

RDEPEND="
	>=dev-libs/boost-1.72:=[threads]
	examples? (
		!net-p2p/mldonkey
		dev-util/patchelf
	)
	python? (
		${PYTHON_DEPS}
		$(python_gen_any_dep '
			dev-libs/boost:=[python,${PYTHON_USEDEP}]')
	)
	ssl? (
		gnutls? ( net-libs/gnutls:0= )
		!gnutls? (
			!libressl? ( dev-libs/openssl:0= )
			libressl? ( dev-libs/libressl:= )
		)
	)
"
DEPEND="${RDEPEND}
	sys-devel/libtool
"

pkg_setup() {
	use python && python-any-r1_pkg_setup
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_CXX_STANDARD=14
		-Dlogging=$(usex debug ON OFF)
		-Ddht=$(usex dht ON OFF)
		-Dbuild_examples=$(usex examples ON OFF)
		-Dencryption=$(usex ssl ON OFF)
		-DBUILD_SHARED_LIBS=$(usex static-libs OFF ON)
		-Dbuild_tests=$(usex test ON OFF)
		-Dgnutls=$(usex gnutls ON OFF)
		-Dpython-bindings=$(usex python ON OFF)
	)
	use python && mycmakeargs+=( -Dboost-python-module-name="${EPYTHON}" )

	cmake-utils_src_configure
}

src_install() {
	use doc && HTML_DOCS+=( "${S}"/docs )
	cmake-utils_src_install

	use python && python_optimize
	use examples && dobin $(find ${BUILD_DIR}/examples -type f -executable \
		-print -exec patchelf --remove-rpath \{\} \+)
}