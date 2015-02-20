if [ "$GIT_USER" = "" ]; then
  echo 'you need to specify a GIT_USER and a GIT_EMAIL'
  exit 1
fi
if [ "$GIT_EMAIL" = "" ]; then
  echo 'you need to specify a GIT_EMAIL too'
  exit 1
fi

sudo pacman -S --needed exfat-utils fuse-exfat

sudo pacman -S --needed firefox lynx

sudo pacman -S --needed ffmpeg-compat
aur spotify

aur sublime-text-nightly
cd /home/$USER/.config/sublime-text-3/Packages
git clone https://github.com/buymeasoda/soda-theme/ "Theme - Soda"

sudo pacman -S --needed virtualbox
echo 'vboxdrv
vboxnetadp
vboxnetflt
vboxpci'>/etc/modules-load.d/virtualbox.conf
sudo modprobe vboxdrv
sudo modprobe vboxnetadp
sudo modprobe vboxnetflt
sudo modprobe vboxpci

sudo pacman -S --needed openssh xclip
git config --global user.name "$GIT_USER"
git config --global user.email "$GIT_EMAIL"
ssh-keygen -t rsa -C "$GIT_EMAIL"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub | xclip -selection clipboard
firefox https://github.com/settings/ssh

sudo pacman -S --needed nodejs
npm adduser

sudo pacman -S --needed --noconfirm qt

sudo pacman -S --needed --noconfirm skype

