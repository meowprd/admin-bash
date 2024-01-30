#!/bin/bash

echo "installing..."
sudo apt install ssh vino xrdp libglib2.0-bin -y
echo "Starting ssh..."
sudo systemctl enable ssh
sudo systemctl start ssh

echo "Configuring Vino server..."
echo -n "Enter password for remote desktop: "
read pass
gsettings set org.gnome.Vino authentication-methods "['vnc']"
gsettings set org.gnome.Vino vnc-password "$(echo -n "$pass" | base64)"
echo "Restart xrdp..."
systemctl restart xrdp
echo "All done!"
