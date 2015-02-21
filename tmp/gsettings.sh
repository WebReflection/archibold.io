sudo -u $USER dbus-launch gsettings set org.gnome.desktop.background picture-uri '/usr/share/backgrounds/gnome/Sandstone.jpg'
sudo -u $USER dbus-launch gsettings set org.gnome.desktop.screensaver picture-uri '/usr/share/backgrounds/gnome/Whispy_Tails.jpg'
sudo -u $USER dbus-launch gsettings set org.gnome.desktop.datetime automatic-timezone true
sudo -u $USER dbus-launch gsettings set org.gnome.desktop.interface clock-show-date true
sudo -u $USER dbus-launch gsettings set org.gnome.desktop.background show-desktop-icons true
sudo -u $USER dbus-launch gsettings set org.gnome.Terminal.Legacy.Settings dark-theme true