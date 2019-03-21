#!/usr/bin/env bash

getHash() {
    for hash in $("${1}sum" $2); do
        echo $hash
        return
    done
}

maintainer='Andrea Giammarchi <andrea.giammarchi@gmail.com>'
pkgbase=cairo-gl
pkgname=${pkgbase}-aarch64
pkgver=1.17.2
pkgrel=8
pkgdesc='Cairo vector graphics library (gl version)'
pkgfile=
for file in $(ls ${pkgname}-${pkgver}*.pkg.tar.xz); do
    pkgfile="${file}"
done
if [ ! -f ${pkgfile} ]; then
    echo "no ${pkgname} found"
    exit 1
fi

echo ""
echo " $(tput bold)${pkgname}$(tput sgr0) v${pkgver}-${pkgrel}"
echo -en "\r package update in 5 seconds ..."
sleep 1
echo -en "\r package update in 4 seconds ..."
sleep 1
echo -en "\r package update in 3 seconds ..."
sleep 1
echo -en "\r package update in 2 seconds ..."
sleep 1
echo -en "\r package update in 1 seconds ..."
sleep 1
echo -en "\r preparing                      "
echo ""

mkdir -p ~/aur/${pkgname}
if [ ! -d ~/aur/${pkgname} ]; then
    echo "unable to create ~/aur/${pkgname}"
    exit 1
fi
rm -rf ~/aur/${pkgname}/*
cp ./${pkgfile} ~/aur/${pkgname}
cd ~/aur/${pkgname}
tar --warning=none -xf ${pkgfile}
rm .{B,M,P}*
rm ${pkgfile}
tar -czf ${pkgname}-${pkgver}.tar.gz ./usr
echo "# Maintainer: Andrea Giammarchi <andrea.giammarchi@gmail.com>
pkgname=${pkgname}
pkgver=${pkgver}
pkgrel=${pkgrel}
pkgdesc='${pkgdesc}'
arch=(aarch64)
url='http://cairographics.org/'
license=('LGPL' 'MPL')
groups=(wpe)
provides=('cairo=${pkgver}' 'cairo-xcb=${pkgver}')
conflicts=('cairo' 'cairo-xcb')
depends=('libpng' 'libxrender' 'libxext' 'fontconfig' 'pixman>=0.28.0' 'glib2' 'mesa' 'libgl' 'lzo')
source=('https://webreflection.github.io/aur/$pkgname-$pkgver.tar.gz')
md5sums=('$(getHash md5 $pkgname-$pkgver.tar.gz)')
sha1sums=('$(getHash sha1 $pkgname-$pkgver.tar.gz)')
sha256sums=('$(getHash sha256 $pkgname-$pkgver.tar.gz)')
sha512sums=('$(getHash sha512 $pkgname-$pkgver.tar.gz)')
">PKGBUILD
echo '
package () {
    cp -R "${srcdir}/usr" "${pkgdir}"
}
'>>PKGBUILD
mv ${pkgname}-${pkgver}.tar.gz ~/git/aur
cd ~/git/aur
git add .
git commit -m "Pushing ${pkgname}-${pkgver}"
git push
cd ~/aur/${pkgname}
git clone ssh://aur@aur.archlinux.org/${pkgname}.git
rm -rf usr
mv PKGBUILD ${pkgname}/
cd ${pkgname}/
makepkg --printsrcinfo > .SRCINFO
git add -f PKGBUILD .SRCINFO
git commit -m "Updating ${pkgname}"
git push
rm -rf ~/aur/${pkgname}
