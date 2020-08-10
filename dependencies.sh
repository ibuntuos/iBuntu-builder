#!/bin/bash
BASEDIR=$(dirname "$0")
echo "iBuntu Builder could not load we try to install missing dependencies"
echo "After this window closes just open the app again."
echo "========================================================================"
echo "Installing: python3-tk, python3-pip, isolinux, casper, syslinux," 
echo "ubiquity and PySimpleGui:"
sudo apt update
sudo apt install python3-tk python3-pip isolinux casper syslinux-utils syslinux syslinux-common archdetect-deb casper ubiquity ubiquity-slideshow-ubuntu ubiquity-casper mbr dpkg-dev -y
pip3 install pysimplegui
pip3 install python-resize-image
sudo pip3 install pysimplegui
#sudo pip3 install python-resize-image
read -p "Press any key to reload iBuntu Builder" x
sudo $BASEDIR/ibuntu_builder.py
