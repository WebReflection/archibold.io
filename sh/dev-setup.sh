if [ "$GIT_USER" = "" ]; then
  echo 'you need to specify a GIT_USER and a GIT_EMAIL'
  exit 1
fi
if [ "$GIT_EMAIL" = "" ]; then
  echo 'you need to specify a GIT_EMAIL too'
  exit 1
fi

sudo pacman -S --needed --noconfirm exfat-utils fuse-exfat dosfstools

sudo pacman -S --needed --noconfirm firefox lynx

sudo pacman -S --needed --noconfirm virtualbox
echo 'vboxdrv
vboxnetadp
vboxnetflt
vboxpci'>~/virtualbox.conf
sudo mv ~/virtualbox.conf /etc/modules-load.d/virtualbox.conf
sudo modprobe vboxdrv
sudo modprobe vboxnetadp
sudo modprobe vboxnetflt
sudo modprobe vboxpci

sudo pacman -S --needed --noconfirm filezilla

sudo pacman -S --needed --noconfirm inkscape gimp

sudo pacman -S --needed --noconfirm qt

sudo pacman -S --needed --noconfirm skype

sudo pacman -S --needed --noconfirm mariadb

sudo pacman -S --needed --noconfirm ffmpeg-compat
archibold install spotify

archibold install sublime-text-nightly
cd /home/$USER/.config/sublime-text-3/Packages
git clone https://github.com/buymeasoda/soda-theme/ "Theme - Soda"

git config --global user.name "$GIT_USER"
git config --global user.email "$GIT_EMAIL"
git config --global push.default simple
sudo pacman -S --needed --noconfirm openssh xclip
ssh-keygen -t rsa -C "$GIT_EMAIL"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
echo '
Time to add your key in GitHub.'
read -n1 -r -p "Press any key to copy to clipboard" key
cat ~/.ssh/id_rsa.pub | xclip -selection clipboard
firefox https://github.com/settings/ssh

sudo pacman -S --needed --noconfirm nodejs
echo '
Please add your npm info (if any)'
npm adduser
