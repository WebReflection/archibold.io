###############################
# archibold 0.6.0             #
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
# SWAP    default 2GiB, a swap partition
#         SWAP=0 to not use any SWAP
#
# PASSWD  root password, by default root
# UPASSWD user password, by default this is
#         the chosen $USER variable
# if either only PASSWD or UPASSWD are specified
# this will be set as both root and user password
#
#
# GNOME   if GNOME is 0 or NO
#         it will not be installed
#
# LABEL   default archibold
#         the EFI label name
#
# UEFI    either efi64 or efi32 or NO
#         by default is based on uname -m
#
# EDD     either NO or off, by default is not used.
#         edd=$EDD is a boot argument specially useful
#         for the Gizmo2 board and its BIOS
#
# basic usage example (root:root archiboold:archiboold)
# DISK=/dev/sdb USER=archibold sh archibold.sh
#
# basic usage with pass example (root:mypwd archiboold:mypwd)
# DISK=/dev/sdb USER=archibold PASSWD=myppwd sh archibold.sh
#
###############################

ARCHIBOLD='0.6.0'

clear

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
  local arch=$(uname -m)
  case $arch in
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
      echo "Apologies, at this time archibold does not work"
      echo "on systems with current architecture: ${arch}"
      ;;
  esac
}

# adjust local time
ntpdate pool.ntp.org
timedatectl set-local-rtc 1

# video card checks
if [ "$(lspci -v -s `lspci | awk '/VGA/{print $1}'` | grep Intel)" != "" ]; then
  GPU='Intel'
  GPU_DRIVERS='xf86-video-intel libva-intel-driver'
elif [ "$(lspci -v -s `lspci | awk '/VGA/{print $1}'` | grep NVIDIA)" != "" ]; then
  GPU='nVidia'
  GPU_DRIVERS='xf86-video-nouveau mesa-libgl'
elif [ "$(lspci -v -s `lspci | awk '/VGA/{print $1}'` | grep AMD)" != "" ]; then
  GPU='Radeon'
  GPU_DRIVERS='xf86-video-ati libva-mesa-driver'
fi

# disk checks
if [ "$DISK" = "" ]; then
  echo 'please specify a DISK target (i.e. DISK=/dev/sdb)'
  echo '(use lsblk or fdisk -l to know which one could be OK)'
  exit 1
fi

# swap checks
if [ "$SWAP" = "" ]; then
  SWAP=2GiB
fi

if [ "$EDD" = "NO" ]; then
  EDD=off
fi

# USER checks
if [ "$(verifyuser $USER root)" != "" ]; then
  echo 'please specify a USER name in lower case (i.e. archibold)'
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
  echo 'please specify a USER name in lower case (i.e. archibold)'
  exit 1
fi

# password checks
if [ "$PASSWD" = "" ]; then
  if [ "$UPASSWD" = "" ]; then
    PASSWD=root
  else
    PASSWD="$UPASSWD"
  fi
else
  if [ "$UPASSWD" = "" ]; then
    UPASSWD="$PASSWD"
  fi
fi
if [ "$UPASSWD" = "" ]; then
  UPASSWD="$USER"
fi

# UEFI architecture check
if [ "$UEFI" != "" ]; then
  if [ "$UEFI" != "NO" ]; then
    if [ "$UEFI" != "efi64" ]; then
      if [ "$UEFI" != "efi32" ]; then
        echo "valid UEFI are efi64 or efi32, not $UEFI"
        exit 1
      fi
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

pacman -Sy --noconfirm
pacman-db-upgrade
pacman-key --init
pacman-key --populate archlinux

pacman -S --needed --noconfirm fbset
if [ "$WIDTH" = "" ]; then
  WIDTH=$(fbset | grep 'mode ' | sed -e 's/mode "//' | sed -e 's/x.*//')
fi
if [ "$HEIGHT" = "" ]; then
  HEIGHT=$(fbset | grep 'mode ' | sed -e 's/mode "[0-9]*x//' | sed -e 's/"//')
fi

clear
cat archibold.header
# print summary
echo ' - - - - - - - - - - - - - - '
echo ' SUMMARY '
echo ' - - - - - - - - - - - - - - '
echo "  installing archibld $ARCHIBOLD"
echo "  for users/passwords"
echo "    root/${PASSWD}"
echo "    ${USER}/${UPASSWD}"
echo "  on disk $DISK"
if [ "$SWAP" = "0" ]; then
  echo "  without swap"
else
  echo "  with $SWAP of swap"
fi
if [ "$UEFI" = "NO" ]; then
  SYSLINUX_BOOT='/boot'
  SYSLINUX_ROOT='/boot'
  echo "  without EFI"
else
  SYSLINUX_BOOT=''
  SYSLINUX_ROOT='/boot'
  echo "  using syslinux/$UEFI"
  echo "  with label $LABEL"
fi
if [ "$GNOME" = "0" ]; then
  GNOME="NO"
fi
if [ "$GNOME" = "NO" ]; then
  echo "  without GNOME"
else
  if [ "$GNOME" = "EXTRA" ]; then
    echo "  with GNOME and all extras"
  else
    echo "  with GNOME"
  fi
  echo "  with GPU $GPU"
  echo "  and resolution ${WIDTH}x${HEIGHT}"
fi
if [ "$EDD" != "" ]; then
  echo "  with EDD $EDD"
fi
echo ' - - - - - - - - - - - - - - '

echo "verifying $DISK"
POSSIBLEDISKS=$(ls ${DISK}[0-9p]*)

if [[ $? -ne 0 ]] ; then
  POSSIBLEDISKS=$(ls ${DISK})
  if [[ $? -ne 0 ]] ; then
    exit 1
  fi
fi

for CHOICE in $POSSIBLEDISKS; do
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

echo "Please read carefully above info."
echo "WARNING: disk $DISK will be completely erased."
read -n1 -r -p "Is it OK to proceed? [y/n]" CHOICE

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

clear
cat archibold.header

echo ''
sudo dd if=/dev/zero of=$DISK bs=1 count=2048
sync
sleep 2

if [ "$UEFI" = "NO" ]; then
  PARTED_START_AT="2048s"
  sudo parted --script $DISK mklabel msdos
else
  PARTED_START_AT="64M"
  sudo parted --script $DISK mklabel gpt
  sudo parted --script --align optimal $DISK mkpart primary fat16 2048s 64M
  sudo parted $DISK set 1 boot on
fi

if [ "$SWAP" = "0" ]; then
  sudo parted --script --align optimal $DISK mkpart primary ext4 $PARTED_START_AT 100%
else
  sudo parted --script --align optimal $DISK mkpart primary linux-swap $PARTED_START_AT $SWAP
  sudo parted --script --align optimal $DISK mkpart primary ext4 $SWAP 100%
fi

sync

POSSIBLEDISKS=$(ls ${DISK}[0-9p]*)
if [[ $? -ne 0 ]] ; then
  exit 1
fi

TMP=
ROOT=
if [ "$UEFI" = "NO" ]; then
  for CHOICE in $POSSIBLEDISKS; do
    if [ "$CHOICE" != "$DISK" ]; then
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
  done
else
  EFI=
  for CHOICE in $POSSIBLEDISKS; do
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
fi

if [ "$SWAP" != "0" ]; then
  echo "SWAP:             $SWAP"
fi
echo "ROOT:             $ROOT"

if [ "$SWAP" != "0" ]; then
  sudo mkswap $SWAP
  sudo swapon $SWAP
fi

sync

if [ "$DEBUG" = "YES" ]; then
  read -n1 -r -p "[ partitions ]" TMP
fi

if [ "$UEFI" != "NO" ]; then
  sudo mkfs.vfat $EFI
fi
yes | sudo mkfs.ext4 $ROOT

sync
mkdir -p archibold

# temporary hack to test boot from SD
# and system in the EMMC
# needed to be done upfront:
#   1. create a primary ext4 partition in /dev/emmcblk0
#   2. mkfs.ext4 /dev/emmcblk0p1
#   3. specify such partition before running this installer
if [ "$EXP_USE_EMMC" != "" ]; then
  sudo mount $EXP_USE_EMMC archibold
  sudo mkdir -p "archibold$SYSLINUX_ROOT"
  sudo mount $ROOT "archibold$SYSLINUX_ROOT"
  SYSLINUX_BOOT=''
else
  sudo mount $ROOT archibold
  if [ "$UEFI" != "NO" ]; then
    sudo mkdir -p "archibold$SYSLINUX_ROOT"
    sudo mount $EFI "archibold$SYSLINUX_ROOT"
  fi
fi
sync

TOPACKSTRAP="base sudo syslinux gptfdisk arch-install-scripts intel-ucode"
if [ "$UEFI" != "NO" ]; then
  TOPACKSTRAP="$TOPACKSTRAP efibootmgr prebootloader"
fi

if [ "$GNOME" != "NO" ]; then
  TOPACKSTRAP="$TOPACKSTRAP networkmanager"
else
  TOPACKSTRAP="$TOPACKSTRAP dialog wpa_supplicant iw"
fi

if [ "$DEBUG" = "YES" ]; then
  echo $TOPACKSTRAP
  read -n1 -r -p "[ pacstrapping ]" TMP
fi

sudo pacstrap archibold $TOPACKSTRAP
sync

if [ "$UEFI" = "NO" ]; then
  if [ "$SAVE_FSTAB_INFO" = "1" ]; then
    mkdir -p archibold/info
    fdisk -l > archibold/info/fdisk
    cat archibold/etc/fstab > archibold/info/fstab
    genfstab -U -p archibold > archibold/info/genfstab
  fi
fi

if [ "$UEFI" = "NO" ]; then
  cat archibold/etc/fstab > archibold.fstab
  genfstab -U -p archibold >> archibold.fstab
  cat archibold.fstab | sed -e 's/root\/archibold//g' | sed -e 's/\/\/boot/\/boot/g' > etc.fstab
  sudo mv etc.fstab archibold/etc/fstab
  rm archibold.fstab
  cat archibold/etc/fstab
  sync
fi

if [ "$DEBUG" = "YES" ]; then
  read -n1 -r -p "[ fstab ]" TMP
fi

APPEND="APPEND root=$ROOT rw"
if [ "$BOOT_LOUDLY" = "" ]; then
  APPEND="$APPEND quiet splash loglevel=0 console=tty2"
fi
if [ "$EDD" != "" ]; then
  APPEND="$APPEND edd=$EDD"
fi
if [ "$DEBUG" = "YES" ]; then
  echo "$APPEND"
  read -n1 -r -p "[ appended ]" TMP
fi

echo "#!/usr/bin/env bash

DISK='$DISK'
USER='$USER'
EFI='$EFI'
ROOT='$ROOT'
LABEL='$LABEL'
LOCALE='$LOCALE'

echo '
en_US.UTF-8 UTF-8
en_GB.UTF-8 UTF-8
' >> /etc/locale.gen

if [ '$LOCALE' != '' ]; then
  echo '$LOCALE.UTF-8 UTF-8' >> /etc/locale.gen
fi

locale-gen
locale > /etc/locale.conf

if [ '$LOCALE' != '' ]; then
  echo '
LANG=$LOCALE.UTF-8
LC_TIME=$LOCALE.UTF-8
'>>/etc/locale.conf
else
  echo '
LANG=en_US.UTF-8
LC_TIME=en_US.UTF-8
'>>/etc/locale.conf
fi

hwclock --systohc --utc

if [ '$(uname -m)' = 'x86_64' ]; then
  echo '
[multilib]
Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf
  sync
fi

pacman -Syu --noconfirm
pacman-db-upgrade

echo '###############
##   root    ##
###############'
echo -e '$PASSWD
$PASSWD' | passwd

useradd -m -g users -G wheel,storage,power,video -s /bin/bash $USER
echo '##################
## $USER ##
##################'
echo -e '$UPASSWD
$UPASSWD' | passwd $USER

echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers
echo '
# password once asked never expires
Defaults env_reset, timestamp_timeout=-1
' >> /etc/sudoers

mkdir -p /etc/systemd/system/getty@tty1.service.d
echo '[Service]
ExecStart=
ExecStart=-/usr/sbin/agetty -n -i -a $USER %I'>/etc/systemd/system/getty@tty1.service.d/autologin.conf

sync

free -h

if [ '$GNOME' != 'NO' ]; then
  systemctl enable NetworkManager.service
fi

syslinux-install_update -ia

if [ '$DEBUG' = 'YES' ]; then
  read -n1 -r -p '[ syslinux ]' TMP
fi

if [ '$UEFI' != 'NO' ]; then
  mkdir -p $SYSLINUX_ROOT/syslinux
  if [ '$(uname -m)' = 'x86_64' ]; then
    cp -r /usr/lib/syslinux/efi64/* $SYSLINUX_ROOT/syslinux
  else
    cp -r /usr/lib/syslinux/efi32/* $SYSLINUX_ROOT/syslinux
  fi
  cp -r /usr/lib/syslinux/$UEFI/syslinux.efi $SYSLINUX_ROOT/syslinux
  echo '[Unit]
Description=$SYSLINUX_ROOT EFI partition automatically mounted

[Service]
User=root
Type=simple
ExecStart=/usr/bin/mount $EFI $SYSLINUX_ROOT

[Install]
WantedBy=multi-user.target'>/etc/systemd/system/automount-efi.service
  systemctl enable automount-efi
fi

if [ '$GNOME' != 'NO' ]; then
  sync
  pacman -Syu --needed --noconfirm \
    $GPU_DRIVERS \
    libva-mesa-driver mesa-vdpau \
    xf86-input-synaptics \
    xorg-server xorg-xinit xorg-server-xwayland \
    gnome gnome-software gnome-calendar gnome-tweak-tool \
    gstreamer-vaapi gst-libav \
    alsa-utils xdg-utils \
    hunspell-en \
    file-roller \
    ttf-liberation ttf-symbola ttf-droid ttf-freefont

  echo 'UI $SYSLINUX_BOOT/syslinux/vesamenu.c32

TIMEOUT 15
PROMPT 0
DEFAULT arch

MENU TITLE archibold
MENU RESOLUTION $WIDTH $HEIGHT
MENU BACKGROUND $SYSLINUX_BOOT/archibold.jpg
MENU HIDDEN
MENU COLOR timeout_msg 37;40 #00000000 #00000000 none
MENU COLOR timeout 37;40 #00000000 #00000000 none

LABEL arch
      LINUX $SYSLINUX_BOOT/vmlinuz-linux
      INITRD $SYSLINUX_BOOT/intel-ucode.img,$SYSLINUX_BOOT/initramfs-linux.img
      $APPEND
      MENU CLEAR

' > $SYSLINUX_ROOT/syslinux/syslinux.cfg

  pacman -Syu --needed --noconfirm inkscape
  curl -L -O http://archibold.io/img/archibold.svg
  inkscape \
    --export-png=archibold.png \
    --export-width=$WIDTH \
    --export-height=$HEIGHT \
    archibold.svg
  convert archibold.png -quality 100% archibold.jpg
  mv archibold.jpg $SYSLINUX_ROOT
  rm archibold.{png,svg}

  if [ '$DEBUG' = 'YES' ]; then
    read -n1 -r -p '[ splash screen ]' TMP
  fi

  systemctl enable gdm.service

  sudo -u $USER mkdir -p /home/$USER/.config/gtk-3.0
  sudo -u $USER touch /home/$USER/.config/gtk-3.0/settings.ini
  sudo -u $USER echo '[Settings]
gtk-application-prefer-dark-theme=1' >> /home/$USER/.config/gtk-3.0/settings.ini

  sync

  if [ '$GNOME' = 'EXTRA' ]; then
    pacman -Syu --needed --noconfirm gnome-extra
  fi

  sudo -u $USER echo '# new tabs, same dir
[[ -s /etc/profile.d/vte.sh ]] && . /etc/profile.d/vte.sh' >> /home/$USER/.bashrc

  sudo -u $USER dbus-launch gsettings set org.gnome.desktop.background picture-uri '/usr/share/backgrounds/gnome/Sandstone.jpg'
  sudo -u $USER dbus-launch gsettings set org.gnome.desktop.screensaver picture-uri '/usr/share/backgrounds/gnome/FootFall.jpg'
  sudo -u $USER dbus-launch gsettings set org.gnome.desktop.datetime automatic-timezone true
  sudo -u $USER dbus-launch gsettings set org.gnome.desktop.interface clock-show-date true
  sudo -u $USER dbus-launch gsettings set org.gnome.desktop.background show-desktop-icons true
  sudo -u $USER dbus-launch gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
  # sudo -u $USER dbus-launch gsettings set org.gnome.desktop.peripherals.touchpad disable-while-typing true
  sudo -u $USER dbus-launch gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll true
  sudo -u $USER dbus-launch gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
  sudo -u $USER dbus-launch gsettings set org.gnome.nautilus.icon-view default-zoom-level 'small'
  sudo -u $USER dbus-launch gsettings set org.gnome.nautilus.list-view default-zoom-level 'small'
  sudo -u $USER dbus-launch gsettings set org.gnome.Epiphany.web enable-webaudio true
  sudo -u $USER dbus-launch gsettings set org.gnome.Epiphany.web enable-webgl true
  # sudo -u $USER xdg-mime default org.gnome.Nautilus.desktop inode/directory

  echo '
#lockDialogGroup {
  background: #2e3436 url(/usr/share/backgrounds/gnome/FootFall.jpg);
  background-size: cover;
  background-repeat: no-repeat;
}' >> /usr/share/gnome-shell/theme/gnome-classic.css

else
  echo 'TIMEOUT 15
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
      LINUX $SYSLINUX_BOOT/vmlinuz-linux
      INITRD $SYSLINUX_BOOT/intel-ucode.img,$SYSLINUX_BOOT/initramfs-linux.img
      $APPEND

' > $SYSLINUX_ROOT/syslinux/syslinux.cfg
fi

pacman-db-upgrade
sync

if [ '$UEFI' != 'NO' ]; then
  if [ -d /usr/lib/prebootloader ]; then
    cp /usr/lib/prebootloader/{PreLoader,HashTool}.efi /boot/syslinux/
    cp /boot/syslinux/syslinux.efi /boot/syslinux/loader.efi
    efibootmgr -c -d $DISK -l /syslinux/PreLoader.efi -L '$LABEL'
  else
    efibootmgr -c -d $DISK -l /syslinux/syslinux.efi -L '$LABEL'
  fi
  sync
fi

sleep 3

if [ '$DEBUG' = 'YES' ]; then
  read -n1 -r -p '[ after syslinux ]' TMP
fi

mkinitcpio -p linux

# if [ '$UEFI' != 'NO' ]; then
#   mv /boot/{vmlinuz-linux,*.img} $SYSLINUX_ROOT
# fi

sync

sleep 3
if [ '$DEBUG' = 'YES' ]; then
  read -n1 -r -p '[ after mkinitcpio ]' TMP
fi

cd /home/$USER
sudo -u $USER touch /home/$USER/.hushlogin
# sudo -u $USER curl -L -O http://archibold.io/sh/archibold
sudo -u $USER curl -L -O http://archibold.io/sh/archy
# chmod +x archibold
chmod +x archy
# mv archibold /usr/bin
mv archy /usr/bin
ln -s /usr/bin/archy /usr/bin/archibold
sync

rm /archibold
if [ '$DEBUG' = 'YES' ]; then
  read -n1 -r -p '[ after cleanup ]' TMP
fi

if [ '$SETUP' != '' ]; then
  curl -L -O http://archibold.io/sh/$SETUP-setup.sh
  sh setup.sh
  rm setup.sh
fi

sleep 3

# echo '$LABEL' >> /etc/hostname
hostnamectl set-hostname '$LABEL'

if [ '$GNOME' != 'NO' ]; then
  echo '[keyfile]
hostname=$LABEL
'>>/etc/NetworkManager/NetworkManager.conf
  archy gnome-login-bg /usr/share/backgrounds/gnome/FootFall.jpg
fi

if [ '$UEFI' = 'NO' ]; then
  if [ '$SAVE_FSTAB_INFO' = '1' ]; then
    fdisk -l > /info/fdisk-chroot
    genfstab -U -p / > /info/genfstab-chroot
  fi
fi

exit
">archibold.bash

sudo mv archibold.bash archibold/archibold
sudo chmod +x archibold/archibold
rm archibold.header

sudo arch-chroot archibold /archibold

echo "

CONGRATULATIONS!

archibold is ready to go!

- - - - - - - - - - - - -

please write the following in the console:

shutdown -h now

and remove the CD/USB stick after

bye bye
"