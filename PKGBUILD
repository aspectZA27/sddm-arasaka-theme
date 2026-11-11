# Maintainer: Ruan <ruakruger@gmail.com>
# NOTE: set 'url' to your real repo and tag a v1.0 release before publishing to the AUR.
pkgname=sddm-arasaka-theme
pkgver=1.0
pkgrel=1
pkgdesc="Arasaka-style corporate security login theme for SDDM (Qt6)"
arch=('any')
url="https://github.com/aspectZA27/sddm-arasaka-theme"
license=('MIT')
depends=('sddm' 'qt6-declarative')
optdepends=('noto-fonts-cjk: Japanese footer text'
            'imagemagick: converting your own logo to PNG')
source=("$pkgname-$pkgver.tar.gz::$url/archive/v$pkgver.tar.gz")
sha256sums=('SKIP')

package() {
    cd "$srcdir/$pkgname-$pkgver"
    install -d "$pkgdir/usr/share/sddm/themes/arasaka"
    cp -r arasaka/. "$pkgdir/usr/share/sddm/themes/arasaka/"
    find "$pkgdir/usr/share/sddm/themes/arasaka" -type d -exec chmod 755 {} +
    find "$pkgdir/usr/share/sddm/themes/arasaka" -type f -exec chmod 644 {} +
    install -Dm644 LICENSE "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}
