#!/usr/bin/env bash

pkgbase=cog
pkgname=${pkgbase}-wpe-gl

mkdir -p ~/aur/${pkgname}
cd ~/aur/${pkgname}
rm -rf *

git clone https://aur.archlinux.org/${pkgbase}
cd cog
sed -i 's/Adrian Perez de Castro <aperez@igalia.com>/Andrea Giammarchi <andrea.giammarchi@gmail.com>/' PKGBUILD
sed -i 's/wpewebkit/wpewebkit-bin/' PKGBUILD
sed -i "s/pkgname=${pkgbase}/pkgname=${pkgname}/" PKGBUILD
sed -i "s/\${pkgname}/${pkgbase}/" PKGBUILD
cd ..
git clone ssh://aur@aur.archlinux.org/${pkgname}.git
cd ${pkgname}/
cp ../cog/PKGBUILD ./
makepkg --printsrcinfo > .SRCINFO
git add -f PKGBUILD .SRCINFO
git commit -m "Updating ${pkgname}"
git push
rm -rf ~/aur/${pkgname}

