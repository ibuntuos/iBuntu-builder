#!/bin/bash
sed -i '/PRETTY/c\PRETTY_NAME="iBuntu 2.0 Lix Sur BETA"' /etc/os-release
sed -i '/VERSION_ID/c\VERSION_ID="2.0"' /etc/os-release
sed -i '/HOME_URL/c\HOME_URL="https://ibuntuos.com"' /etc/os-release
sed -i '/DISTRIB_DESCRIPTION/c\DISTRIB_DESCRIPTION="iBuntu 2.0 Lix Sur 64Bit BETA"' /etc/lsb-release
#sed -i '/NAME=/c\NAME="iBuntu 2.0"' /etc/os-release
sed -i '/VARIANT=/c\VARIANT="Six Nur -BETA-"' /etc/os-release
cp /etc/os-release /usr/lib/os-release
#update-grub
