###############################
# archibold 0.1.2             #
# - - - - - - - - - - - - - - #
#        by Andrea Giammarchi #
# - - - - - - - - - - - - - - #
# =========================== #
# ========= WARNING ========= #
# =========================== #
#                             #
#    THIS SCRIPT CAN ERASE    #
#       YOUR ENTIRE DISK      #
#     USE AT YOUR OWN RISK    #
#   NO WARRANTY PROVIDED AND  #
# NOT RESPONSIBLE FOR DAMAGES #
#                             #
###############################
#
# options
#
# DISK    where to install archibold
# USER    the main user name, lower case
#
# SWAP    default 2G, a swap partition
#         SWAP=0 to not use any SWAP
#
# LABEL   default archibold
#         the EFI label name
#
# GNOME   if GNOME=0 will not install GNOME
#
# UEFI    either efi64 or efi32
#         by default is based on uname -m
#
# basic usage example
# DISK=/dev/sdb USER=archibold sh archibold.sh
#
###############################

ARCHIBOLD='0.1.2'

echo ''
echo "SAY
SAY                                _|        _|  _|                  _|        _|
SAY     _|_|_|  _|  _|_|   _|_|_|  _|_|_|        _|_|_|      _|_|    _|    _|_|_|
SAY   _|    _|  _|_|     _|        _|    _|  _|  _|    _|  _|    _|  _|  _|    _|
SAY   _|    _|  _|       _|        _|    _|  _|  _|    _|  _|    _|  _|  _|    _|
SAY     _|_|_|  _|         _|_|_|  _|    _|  _|  _|_|_|      _|_|    _|    _|_|_|
SAY
SAY
SAY     by Andrea Giammarchi - @WebReflection                             $ARCHIBOLD
SAY
">archibold.header
cat archibold.header

verifyuser() {
  if [ "$1" = "$2" ]; then
    echo "please specify a USER name (i.e. USER=archibold)"
    echo "please note this should be different from $2"
  fi
}

verifyTechnology() {
  case $(uname -m) in
    x86_64)
      ;;
    i386)
      ;;
    i486)
      ;;
    i586)
      ;;
    i686)
      ;;
    *)
      echo 'my apologies, at this time archibold works'
      echo 'only on systems powered by Intel'
      ;;
  esac
}

# video card checks
if [ "$(lspci -v -s `lspci | awk '/VGA/{print $1}'` | grep Intel)" != "" ]; then
  GPU='Intel'
  GPU_DRIVERS='xf86-video-intel libva-intel-driver'
elif [ "$(lspci -v -s `lspci | awk '/VGA/{print $1}'` | grep NVIDIA)" != "" ]; then
  GPU='nVidia'
  GPU_DRIVERS='nvidia xf86-video-nouveau'
fi

# disk checks
if [ "$DISK" = "" ]; then
  echo 'please specify a DISK target (i.e. DISK=/dev/sdb)'
  exit 1
fi

# swap checks
if [ "$SWAP" = "" ]; then
  SWAP=2G
fi

# USER checks
if [ "$(verifyuser $USER root)" != "" ]; then
  exit 1
fi
if [ "$USER" = "" ]; then
  echo 'please specify a USER name in lower case (i.e. archibold)'
  exit 1
fi
if [ "$(echo $USER | sed -e 's/[a-z]//g')" != "" ]; then
  echo 'please specify a USER name in lower case (i.e. archibold)'
  exit 1
fi
if [ "$(verifyuser $USER root)" != "" ]; then
  exit 1
fi

# UEFI architecture check
if [ "$UEFI" != "" ]; then
  if [ "$UEFI" != "efi64" ]; then
    if [ "$UEFI" != "efi32" ]; then
      echo "valid UEFI are efi64 or efi32, not $UEFI"
      exit 1
    fi
  fi
else
  if [ "$(uname -m)" = "x86_64" ]; then
    UEFI=efi64
  else
    UEFI=efi32
  fi
fi

# Technology check
if [ "$(verifyTechnology)" != "" ]; then
  exit 1
fi
if [ "$LABEL" = "" ]; then
  LABEL="archibold"
fi

# print summary
echo ' - - - - - - - - - - - - - - '
echo ' SUMMARY '
echo ' - - - - - - - - - - - - - - '
echo "  installing archibld $ARCHIBOLD"
echo "  with label $LABEL"
echo "  for user $USER"
echo "  on disk $DISK"
echo "  using syslinux/$UEFI"
if [ "$SWAP" = "0" ]; then
  echo "  without swap"
else
  echo "  with $SWAP of swap"
fi
if [ "$GNOME" = "0" ]; then
  echo "  without GNOME"
else
  echo "  with GPU $GPU"
fi
echo ' - - - - - - - - - - - - - - '

echo "verifying $DISK"
ls ${DISK}*

if [[ $? -ne 0 ]] ; then
  exit 1
fi

for CHOICE in $(ls ${DISK}*); do
  if [ "$CHOICE" != "$DISK" ]; then
    if [ "$(df | grep $CHOICE)" != "" ]; then
      echo "unmounting $CHOICE"
      sudo umount $CHOICE
      if [[ $? -ne 0 ]] ; then
        echo ''
        echo '... be careful with these scripts ;-)'
        exit 1
      fi
    fi
  fi
done

echo "WARNING: I am going to erase $DISK"
echo "is that OK? There is NO coming back!"
read -n1 -r -p "press y to confirm:" CHOICE

if [[ $? -ne 0 ]] ; then
  echo ''
  echo '... be careful with these scripts ;-)'
  exit 1
fi

if [ "$CHOICE" != "y" ]; then
  echo ''
  echo 'nothing to do then, bye bye'
  exit 1
fi

echo ''
sudo dd if=/dev/zero of=$DISK bs=1 count=2048

sudo parted --script $DISK mklabel gpt
sudo parted --script --align optimal $DISK mkpart primary fat16 2048s 64M
sudo parted $DISK set 1 boot on

if [ "$SWAP" = "0" ]; then
  sudo parted --script --align optimal $DISK mkpart primary ext4 64M 100%
else
  sudo parted --script --align optimal $DISK mkpart primary linux-swap 64M $SWAP
  sudo parted --script --align optimal $DISK mkpart primary ext4 $SWAP 100%
fi

TMP=
EFI=
ROOT=
for CHOICE in $(ls ${DISK}*); do
  if [ "$CHOICE" != "$DISK" ]; then
    if [ "$EFI" = "" ]; then
      EFI="$CHOICE"
    else
      if [ "$SWAP" = "0" ]; then
        ROOT="$CHOICE"
      else
        if [ "$TMP" = "" ]; then
          SWAP="$CHOICE"
          TMP="$SWAP"
        else
          ROOT="$CHOICE"
        fi
      fi
    fi
  fi
done

echo "EFI boot loader:  $EFI"
echo "ROOT:             $ROOT"
if [ "$SWAP" != "0" ]; then
  echo "SWAP:             $SWAP"
  sudo mkswap $SWAP
  sudo swapon $SWAP
fi

sudo mkfs.vfat $EFI
yes | sudo mkfs.ext4 $ROOT

sync
mkdir -p archibold
sudo mount $ROOT archibold
sudo mkdir -p archibold/boot/EFI
sudo mount $EFI archibold/boot/EFI
sync

sudo pacstrap archibold base sudo intel-ucode networkmanager syslinux gptfdisk efibootmgr
sync

cat archibold/etc/fstab > archibold.fstab
genfstab -U -p archibold >> archibold.fstab
sudo mv archibold.fstab archibold/etc/fstab
cat archibold/etc/fstab
sync

echo "#!/usr/bin/env bash

DISK='$DISK'
USER='$USER'
EFI='$EFI'
ROOT='$ROOT'
LABEL='$LABEL'

echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen
locale-gen
locale > /etc/locale.conf
hwclock --systohc --utc

if [ '$(uname -m)' = 'x86_64' ]; then
  echo '
[multilib]
Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf
fi

pacman -Syyu

echo '###############
##   root    ##
###############'
passwd

useradd -m -g users -G wheel,storage,power -s /bin/bash $USER
echo '##################
## $USER ##
##################'
passwd $USER

echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers

mkdir -p /etc/systemd/system/getty@tty1.service.d
echo '[Service]
ExecStart=
ExecStart=-/usr/sbin/agetty -n -i -a $USER %I'>/etc/systemd/system/getty@tty1.service.d/autologin.conf

sync

free -h

systemctl enable NetworkManager.service

syslinux-install_update -ia

mkdir -p /boot/EFI/syslinux

if [ '$(uname -m)' = 'x86_64' ]; then
  cp -r /usr/lib/syslinux/efi64/* /boot/EFI/syslinux
else
  cp -r /usr/lib/syslinux/efi32/* /boot/EFI/syslinux
fi
cp -r /usr/lib/syslinux/$UEFI/syslinux.efi /boot/EFI/syslinux

efibootmgr -c -d $DISK -l /syslinux/syslinux.efi -L '$LABEL'

echo 'TIMEOUT 0
PROMPT 0
DEFAULT arch

SAY
SAY
SAY
SAY
SAY
SAY
SAY
SAY
SAY
$(cat archibold.header)
SAY
SAY
SAY
SAY

LABEL arch
      LINUX /vmlinuz-linux
      INITRD /intel-ucode.img,/initramfs-linux.img
      APPEND root=$ROOT rw quiet loglevel=0

' > /boot/EFI/syslinux/syslinux.cfg

mkinitcpio -p linux
mv /boot/{vmlinuz-linux,*.img} /boot/EFI
sync
rm /archibold

sleep 3

if [ '$GNOME' != '0' ]; then

  pacman -S --needed --noconfirm \
    $GPU_DRIVERS \
    libva-mesa-driver mesa-vdpau \
    xf86-input-synaptics \
    xorg-server xorg-xinit xorg-server-xwayland \
    gnome gnome-extra gnome-tweak-tool \
    gstreamer-vaapi gst-libav \
    alsa-utils \
    hunspell-en

  systemctl enable gdm.service

fi

exit
">archibold.bash

sudo mv archibold.bash archibold/archibold
sudo chmod +x archibold/archibold
rm archibold.header

sudo arch-chroot archibold /archibold

sudo umount $EFI $ROOT

sync

rm -r archibold

echo "

CONGRATULATIONS!

archibold is ready to go!
please reboot directly through $DISK

bye bye
"