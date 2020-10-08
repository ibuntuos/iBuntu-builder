
#!/bin/bash
#Script for iBuntu to load in /etc/skel what is needed

username=ibuntu
echo "###############Clean whole System#############"
sudo apt -f install &&
sudo apt -y autoremove &&
sudo apt -y autoclean &&
sudo apt -y clean &&
sudo aptitude purge
echo ""
echo "########Clean Temp-Files of local user########"
echo "sudo rm -rf /tmp/*"
sudo rm -rf /tmp/*
echo "sudo rm -rf /var/logs/*"
sudo rm -rf /var/logs/*
echo "sudo rm -rf /var/tmp/*"
sudo rm -rf /var/tmp/*
echo "rm -rf ~/.thumbs/*"
rm -rf ~/.thumbs/*
echo "sudo rm -rf ~/.cache/*"
sudo rm -rf ~/.cache/*
# rm -rf ~/.xbmc/addons/packages
echo "rm -rf ~/.local/share/Trash/files/*"
rm -rf ~/.local/share/Trash/files/*
echo "rm -rf .gvfs"
rm -rf .gvfs
echo "rm -rf .local/share/gvfs-metadata"
rm -rf .local/share/gvfs-metadata
echo "rm -rf .locl/share/Trash"
rm -rf .local/share/Trash/
echo "echo '' > ~/.bash_history"
echo "" > ~/.bash_history
echo "history -c"
history -c
echo ""
echo "###############Clean /etc/skel################"
echo "sudo rm -rf /etc/skel/.??*"
sudo rm -rf /etc/skel/.??*
echo "sudo rm -rf /etc/skel/*"
sudo rm -rf /etc/skel/*
echo ""
echo "########Copy relevant things to /etc/skel#######"
echo "sudo cp -r /home/$username/* /etc/skel/"
sudo cp -r /home/$username/* /etc/skel/
sudo cp -r /home/$username/.* /etc/skel/
#echo "sudo cp -r /home/$username/.local /etc/skel"
#sudo cp -r /home/$username/.local /etc/skel
#echo "sudo cp -r /home/$username/.kde /etc/skel"
#sudo cp -r /home/$username/.kde /etc/skel
#sudo cp -r /home/$username/.gconf /etc/skel
#sudo cp -r /home/$username/.gnome2 /etc/skel
#sudo cp -r /home/$username/.mplayer /etc/skel
#echo "sudo cp /home/$username/.bashrc /etc/skel"
#sudo cp /home/$username/.bashrc /etc/skel
#echo "sudo cp /home/$username/.profile /etc/skel"
#sudo cp /home/$username/.profile /etc/skel
#sudo cp /home/$username/.face /etc/skel
#sudo cp -r /home/$username/.dockbarx /etc/skel
#sudo cp -r /home/$username/.easystroke /etc/skel
#sudo cp -r /home/$username/.xscreensaver /etc/skel
#sudo cp -r /home/$username/.mozilla /etc/skel
#echo "sudo cp -r /home/$username/.themes /etc/skel"
#sudo cp -r /home/$username/.themes /etc/skel
#echo "sudo cp -r /home/$username/.icons /etc/skel"
#sudo cp -r /home/$username/.icons /etc/skel
#sudo cp -r /home/$username/Escritorio /etc/skel
#sudo cp -r /home/$username/Desktop /etc/skel
#echo "sudo cp -r /home/$username/snap /etc/skel"
#sudo cp -r /home/$username/snap /etc/skel


echo "######## Now Remove unrelevant stuff from to /etc/skel#######"
echo "sudo rm /etc/skel/.config/user-dirs.*"
sudo rm /etc/skel/.config/user-dirs.*
echo "sudo rm /etc/skel/.config/monitors.*"
sudo rm /etc/skel/.config/monitors.*
sudo rm /etc/skel/.config/google.*
sudo rm -R /etc/skel/Downloads/*
sudo chown $username:$username -R /etc/skel
#
#
