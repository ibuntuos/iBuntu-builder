# iBuntu-builder
```
Update 2023: Since 2021 this builder is outdated and was last used for the Creation of iBuntu 2.0 
It will be discontinued and archived since we switched to a process 
with the Help of Penguin's Eggs in mid 2022.
```

```
Info from iBuntu: We forked this Project from valueerrorx to adjjust it for our
own needs to create our final distribution builds.So this fork only works
perfect for us in what and how we use this tool and maybe won't fit your needs
since it's customized to our demands.
The original you can find here: https://github.com/valueerrorx/life-builder
```

This apptlication is based on "remastersys" and creates an ISO file from the running system.
The GUI is written in Python and QT.
The Bash Script can also be used without GUI.

It allows to include the complete user configuration (backup mode) in the live system and use the live system as installer device.
The finalised ISO Image can be tested directly in KVM or "burned" to a USB device.
life-usbcreator is included in this application.

Tested with KDE Neon 18.04 but should work with most Ubuntu derivates. (minor adjustments needed)

Python Dependencies:
pyqt5
ipaddress
#
A known bug in /usr/share/initramfs-tools/scripts/casper prevents boot with a persistent partition since 2014
https://bugs.launchpad.net/ubuntu/+source/casper/+bug/1489855
a patched casper script will be applied

#
The application also removes private information like ssh keys, password store files, browserhistory, bashhistory, klipper contents, recent documents and unused kernels and packages...
