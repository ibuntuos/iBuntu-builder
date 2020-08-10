#!/bin/bash

#
# Modified to ibuntubuilder from remastersys.
#
# For use on iBuntu OS 1.3 and up
# 
# Forged out of Bodhibuilder and merged with some code of life-builder
# All based on the old remastersys script
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# ORIGINAL REMASTERSYS COMMENTS:
# remastersys script to make an installable livecd/dvd from an (XK)Ubuntu installed
# and customized system
#  Created by Tony "Fragadelic" Brijeski
#  Copyright 2007-2012 Tony "Fragadelic" Brijeski <tb6517@yahoo.com>
#  Originally Created February 12th, 2007
#  This version is only for Ubuntu's and variants of Lucid 10.04 and up
# Code cleanup with suggestions and code from Ivailo (a.k.a. SmiL3y)
#####



# checking to make sure script is running with root privileges
if [ "$(whoami)" != "root" ] ; then
    echo "Need to be root or run with sudo. Exiting."
    exit 1
fi


#added log_msg to reduce size. code provided by Ivailo (a.k.a. SmiL3y)
log_msg() {
    echo "$1"
    echo "$1" >>${WORKDIR}/ibuntubuilder.log
}


ARCH=`archdetect | cut -d/ -f1`
SUBARCH=`archdetect | cut -d/ -f2`
CDBOOTTYPE="ISOLINUX"
UBUVERSION=`lsb_release -r | awk '{print$2}' | cut -d. -f1`
ibuntubuilderVERSION="1.2"
USER=$(logname)
HOME="/home/${USER}/"
#SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SCRIPTDIR="$( cd "$( dirname "$0" )" && pwd )"
echo $SCRIPTDIR " 1"
EXCLUDESFILE="${SCRIPTDIR}/excludes"

echo $SCRIPTDIR" 2"
#################
# OUTPUT # the output is formatted in a special way in order to be parsed by the python script - do not change !! § is the split character
##########################
output() {
    echo "OUTPUT: $1 § $2"
}


#################
#  load the system config file (written by main.py)
##########################
source ${SCRIPTDIR}/conf/config.py
echo $SCRIPTDIR" 3"
if [[( $BASEWORKDIR = "" ) || ( $LIVEUSER = "" ) || ( $DISTNAME = "" ) || ( $CUSTOMISO = "" ) || ( $LIVECDLABEL = "" )]]; then
    output "At least one important setting is missing!" "0"
    exit 0
fi
echo 
WORKDIR="$BASEWORKDIR/build"
##### Gather info #####
# what kind of disk space are we dealing with to begin?
echo "------------------------------------------------------" >>${WORKDIR}/ibuntubuilder.log
echo "Original disk size information" >>${WORKDIR}/ibuntubuilder.log
df -h >>${WORKDIR}/ibuntubuilder.log
echo "------------------------------------------------------" >>${WORKDIR}/ibuntubuilder.log
echo "Original mount information" >>${WORKDIR}/ibuntubuilder.log
mount >>${WORKDIR}/ibuntubuilder.log
echo "------------------------------------------------------" >>${WORKDIR}/ibuntubuilder.log


# echo ibuntubuilder .conf & .version vars to log
echo " ibuntubuilder.conf variables received:" >>${WORKDIR}/ibuntubuilder.log
#cat /etc/ibuntubuilder.conf | grep -e '^[A-Z].*=".*"' >>${WORKDIR}/ibuntubuilder.log
echo " ibuntubuilder version info:" >>${WORKDIR}/ibuntubuilder.log
#cat /etc/ibuntubuilder/ibuntubuilder.version >>${WORKDIR}/ibuntubuilder.log

# echo info about system into log file
echo " System info:" >>${WORKDIR}/ibuntubuilder.log
echo "ARCH = ${ARCH}" >>${WORKDIR}/ibuntubuilder.log
echo "SUBARCH = ${SUBARCH}" >>${WORKDIR}/ibuntubuilder.log
if [ -e "/sys/firmware/efi/efivars/*" ] ; then
  BOOT_FIRMWARE="EFI"
  echo "EFI vars found in /sys/firmware/efi/efivars/" >>${WORKDIR}/ibuntubuilder.log
else
  BOOT_FIRMWARE="BIOS"
  echo "no EFI vars found in /sys/firmware/efi/efivars/" >>${WORKDIR}/ibuntubuilder.log
fi
echo "BOOT_FIRMWARE = ${BOOT_FIRMWARE}" >>${WORKDIR}/ibuntubuilder.log
echo "UBUVERSION = ${UBUVERSION}  (bb's take on Ubuntu version)" >>${WORKDIR}/ibuntubuilder.log

echo " System lsb-release info:" >>${WORKDIR}/ibuntubuilder.log
cat /etc/lsb-release >>${WORKDIR}/ibuntubuilder.log
echo "------------------------------------------------------" >>${WORKDIR}/ibuntubuilder.log
echo "" >>${WORKDIR}/ibuntubuilder.log

# echo files/dirs in /etc/ibuntubuilder to the log file
echo " Files & Dirs in location /etc/ibuntubuilder:" >>${WORKDIR}/ibuntubuilder.log
ls -l /etc/ibuntubuilder/ >>${WORKDIR}/ibuntubuilder.log

if [ ! "${LIVEUSER}" ] ; then
    #Somebody must have removed the username from the configuration file
    echo "no LIVEUSER found, using default" >>${WORKDIR}/ibuntubuilder.log
    #this is a custom live user
    LIVEUSER="custom"
fi
#make sure live user is all lowercase
LIVEUSER="`echo ${LIVEUSER} | awk '{print tolower ($0)}'`"

if [ ! "${LIVECDLABEL}" ] ; then
    echo "no LIVECDLABEL found, using default" >>${WORKDIR}/ibuntubuilder.log
    LIVECDLABEL="Custom Live CD"
fi

if [ ! "${LIVECDURL}" ] ; then
    echo "no LIVECDURL found, using default" >>${WORKDIR}/ibuntubuilder.log
    LIVECDURL="http://www.ibuntulinux.com"
fi

if [ ! "${SQUASHFSOPTS}" ] ; then
    echo "no SQUASHFSOPTS found, using default" >>${WORKDIR}/ibuntubuilder.log
    #~ SQUASHFSOPTS="-no-recovery -always-use-fragments -b 1M -no-duplicates -comp xz -Xdict-size 100%"
    SQUASHFSOPTS="-no-recovery -always-use-fragments -b 1M -no-duplicates -comp xz -Xbcj x86 -Xdict-size 100%"
else
    echo "Using SQUASHFSOPTS from ibuntubuilder.conf" >> ${WORKDIR}/ibuntubuilder.log
    echo "SQUASHFSOPTS = ${SQUASHFSOPTS}" >> ${WORKDIR}/ibuntubuilder.log
fi

if [ "${BACKUPSHOWINSTALL}" = "0" -o "${BACKUPSHOWINSTALL}" = "1" ] ; then
    echo "Using BACKUPSHOWINSTALL from config file:" >> ${WORKDIR}/ibuntubuilder.log
    echo "BACKUPSHOWINSTALL=${BACKUPSHOWINSTALL}" >> ${WORKDIR}/ibuntubuilder.log
else
    echo "BACKUPSHOWINSTALL incorrect, using default of 1" >>${WORKDIR}/ibuntubuilder.log
    BACKUPSHOWINSTALL="1"
fi

echo "done"

##### FUNCTION iso #####
iso (){

  # If xorriso exists, use it to make the iso. It can be used to create a UEFI bootable iso via dd.
  # Otherwise, make genisoimage primary because it supercedes mkisofs
  CREATEISO="`which xorriso`"
  if [ "${CREATEISO}" = "" ] ; then
    CREATEISO="`which genisoimage`"
    if [ "${CREATEISO}" = "" ] ; then
      CREATEISO="`which mkisofs`"
    fi
  fi

  case ${CREATEISO} in
    *xorriso* )
      ISOCMD="xorriso"
    ;;
    *genisoimage )
      ISOCMD="genisoimage"
    ;;
    *mkisofs )
      ISOCMD="mkisofs"
    ;;
  esac

  # Feedback to the log about which will be used to create the ISO
  log_msg "On first detection (this could change based on other parameters)  ---"
  log_msg "   Found '${CREATEISO}'"
  log_msg "   Currently planning to use '${ISOCMD}' to create the ISO."

  # check to see if the cd filesystem exists
  if [ ! -f "${WORKDIR}/ISOTMP/casper/filesystem.squashfs" ] ; then
      log_msg "The filesystem.squashfs filesystem is missing.  Either there was a problem creating the compressed filesystem or you are trying to run sudo ibuntubuilder dist iso before sudo ibuntubuilder dist cdfs"
      exit 1
  fi

  #checking the size of the compressed filesystem to ensure it meets the iso9660 spec for a single file"
  ## Not worried about the squashfs size for xorriso because it doesn't care what size the iso will be
  ## Although if genisoimage or mkisofs are being used they do care about the iso size <-sef>
  case ${CREATEISO} in
    *genisoimage|*mkisofs )
      SQUASHFSSIZE=`ls -s ${WORKDIR}/ISOTMP/casper/filesystem.squashfs | awk -F " " '{print $1}'`
      if [ "${SQUASHFSSIZE}" -gt "3999999" ] ; then
          log_msg "The compressed filesystem is larger than genisoimage allows for a single file. You must try to reduce the amount of data you are backing up and try again."
          exit 1
      fi
    ;;
  esac


  #Step 6.5 - Make ISO compatible with UEFI Grub Boot. This needs to be here or else UEFI boot won't work.
  log_msg "Making disk compatible with UEFI Grub Boot."

  . ${WORKDIR}/dummysys/etc/lsb-release

  touch ${WORKDIR}/ISOTMP/ubuntu

  touch ${WORKDIR}/ISOTMP/.disk/base_installable
  echo "full_cd/single" > ${WORKDIR}/ISOTMP/.disk/cd_type
  # starting with 12.04 need to have correct ubuntu version or startup disk creator uses syslinux-legacy which won't work
  echo ${DISKINFONAME} ${DISTRIB_RELEASE} - Release ${ARCH} > ${WORKDIR}/ISOTMP/.disk/info
  echo ${LIVECDURL} > ${WORKDIR}/ISOTMP/.disk/release_notes_url


  # Step 7 - Make md5sum.txt for the files on the livecd - this is used during the
  # checking function of the livecd
  log_msg "Creating md5sum.txt for the livecd/dvd"
  cd ${WORKDIR}/ISOTMP && find . -type f -print0 | xargs -0 md5sum > md5sum.txt


  #isolinux mode

  # remove files that change and cause problems with checking the disk
  sed -e '/isolinux/d' md5sum.txt > md5sum.txt.new
  sed -e '/md5sum/d' md5sum.txt.new > md5sum.txt
  rm -f md5sum.txt.new &> /dev/null

  sleep 1

  # Step 8 - Make the ISO file
  log_msg "Creating ${CUSTOMISO} in ${WORKDIR}"


  # if file isohdpfx.bin doesn't exist, don't use xorriso
    if [ ! -f "${WORKDIR}/ISOTMP/isolinux/isohdpfx.bin" ] ; then
      log_msg "File '${WORKDIR}/ISOTMP/isolinux/isohdpfx.bin' not found."
      log_msg "Can't use xorriso."
      CREATEISO="`which genisoimage`"
      ISOCMD="genisoimage"
      if [ ! "${CREATEISO}" ] ; then
        CREATEISO="`which mkisofs`"
        ISOCMD="mkisofs"
      fi
      case ${CREATEISO} in
        *genisoimage|*mkisofs )
          log_msg "   No longer using xorriso..."
          log_msg "   Now using '${ISOCMD}' @ '${CREATEISO}' to create the ISO."
        ;;
      esac
    fi

  # set ISO creation command based on architecture
  # and then create the ISO
  isopass=0
  until [ "${isopass}" -eq 1 ] ; do

    # do xorriso, genisoimage, or mkisofs depending on which will work best:
    case ${CREATEISO} in
      *xorriso* ) # Possibly create ISO using /usr/bin/xorriso - must be 64-bit OS
        isopass=1 # Use xorriso regardless of ${ARCH}
      ;; # end xorriso case select
         # if isopass=0, goes back to beginning of loop

      *genisoimage|*mkisofs ) # Create ISO using /usr/bin/genisoimage

        #checking the size of the compressed filesystem to ensure it meets the iso9660 spec for a single file"
        ## Not worried about the squashfs size for xorriso because it doesn't care what size the iso will be
        ##  xorriso can create an iso exceeding the 4Gb limit that genisoimage has
        ## So if genisoimage or mkisofs are being used they do care about the iso size <-sef>
        SQUASHFSSIZE=`ls -s ${WORKDIR}/ISOTMP/casper/filesystem.squashfs | awk -F " " '{print $1}'`
        if [ "${SQUASHFSSIZE}" -gt "3999999" ] ; then
            log_msg "The compressed filesystem is larger than genisoimage allows for a single file. You must try to reduce the amount of data you are backing up and try again."
            exit 1
        fi

        # log message
        if [ "${ISOCMD}" = "genisoimage" ] ; then
          log_msg "Using genisoimage to create ISO."
        elif [ "${ISOCMD}" = "mkisofs" ] ; then
          log_msg "Using mkisofs to create ISO."
        fi

        # check architecture
        if [ ! "${ARCH}" = "amd64" ] ; then
          log_msg "This ISO may not be UEFI bootable. At this time, UEFI is only fully supported in 64-bit OS."
        fi

        isopass=1
      ;; # end genisoimage|mkisofs case select

      * ) # none of the three ISO creation programs are found on OS
        log_msg "ERROR: xorriso, genisoimage, or mkisofs programs not found;"
        log_msg "because of this the iso was not created. Exiting"
        exit 1
      ;;
    esac # end CREATEISO check
  done # end isopass loop check


  ## Now actually create the ISO
  case ${CREATEISO} in
      *xorriso* ) # 
          # xorriso
          #   - Can boot to ISO in either UEFI or non-UEFI mode when dd'd to a USB, CD or DVD
          #   - Copy direct to CD or DVD using command:  sudo xorrecord dev=/dev/sr0 speed=12 fs=8m blank=as_needed -eject padsize=300k file.iso
          #   - Copy direct to USB using command:  sudo dd if=file.iso of=/dev/sdX
          case ${ARCH} in
            amd64 )
              log_msg "creating 64-bit ISO with xorriso"
              ${CREATEISO} -as mkisofs \
                -isohybrid-mbr ${WORKDIR}/ISOTMP/isolinux/isohdpfx.bin \
                -partition_offset 16 \
                -cache-inodes -J -l \
                -iso-level 3 \
                -V "${LIVECDLABEL}" \
                -c isolinux/boot.cat \
                -b isolinux/isolinux.bin \
                -no-emul-boot \
                -boot-load-size 4 \
                -boot-info-table \
                -eltorito-alt-boot \
                -e boot/grub/efi.img \
                -no-emul-boot \
                -isohybrid-gpt-basdat \
                -isohybrid-apm-hfsplus \
                -o ${WORKDIR}/${CUSTOMISO} "${WORKDIR}/ISOTMP" 2>>${WORKDIR}/ibuntubuilder.log 1>>${WORKDIR}/ibuntubuilder.log
            ;;
            * ) # 32-bit arch using xorriso
              log_msg "creating 32-bit ISO with xorriso"
              ${CREATEISO} -as mkisofs \
                -isohybrid-mbr ${WORKDIR}/ISOTMP/isolinux/isohdpfx.bin \
                -partition_offset 16 \
                -cache-inodes -J -l \
                -iso-level 3 \
                -V "${LIVECDLABEL}" \
                -c isolinux/boot.cat \
                -b isolinux/isolinux.bin \
                -no-emul-boot \
                -boot-load-size 4 \
                -boot-info-table \
                -eltorito-alt-boot \
                -e boot/grub/efi.img \
                -no-emul-boot \
                -isohybrid-gpt-basdat \
                -isohybrid-apm-hfsplus \
                -o ${WORKDIR}/${CUSTOMISO} "${WORKDIR}/ISOTMP" 2>>${WORKDIR}/ibuntubuilder.log 1>>${WORKDIR}/ibuntubuilder.log
            ;;
          esac
      ;;
      *genisoimage|*mkisofs ) # 
          log_msg "creating ISO with ${ISOCMD}"
          # create the ISO
          ${CREATEISO} -iso-level 3 -quiet -r -V "${LIVECDLABEL}" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o ${WORKDIR}/${CUSTOMISO} "${WORKDIR}/ISOTMP" 2>>${WORKDIR}/ibuntubuilder.log 1>>${WORKDIR}/ibuntubuilder.log
      ;;
  esac


  if [ ! -f ${WORKDIR}/${CUSTOMISO} ] ; then
      log_msg "The iso was not created. There was a problem. Exiting"
      exit 1
  fi

  log_msg "Copying apt-setup back to original"
  if [ -f "/usr/share/ubiquity/apt-setup.0RIG" ] ; then
      cp -f /usr/share/ubiquity/apt-setup.0RIG /usr/share/ubiquity/apt-setup
  fi

  # Make the iso hybrid so it can be simply dd copied to a usb flash drive.
  case ${CREATEISO} in
    *xorriso* ) # no need to make hybrid with xorriso
      case ${ARCH} in
        amd64 )
          log_msg "================================================================================"
          log_msg ""
          log_msg "Good news, ${CUSTOMISO} was created using the xorriso package."
          log_msg "You can now optionally use the following commands to make a medium"
          log_msg "that is bootable in both UEFI or BIOS (non-UEFI) modes."
          log_msg "  *Create a bootable CD or DVD:"
          log_msg "    $ sudo xorrecord dev=/dev/sr0 speed=12 fs=8m blank=as_needed -eject padsize=300k ${WORKDIR}/${CUSTOMISO}"
          log_msg "  *Create a bootable USB:"
          log_msg "   (you will need to determine which device your USB has been assigned,"
          log_msg "   Do not copy & paste this command directly without changing '/dev/sdX', it won't work."
          log_msg "   dd CAN be dangerous ... now you've been warned.)"
          log_msg "    $ sudo dd if=${WORKDIR}/${CUSTOMISO} of=/dev/sdX"
          log_msg ""
          log_msg "================================================================================"
        ;;
        * )
          log_msg ""
          log_msg "32-bit xorriso,  I don't really know what's going to happen with UEFI right now."
          log_msg ""
        ;;
      esac
    ;;
    * ) # if not using xorriso, need to make it a hybrid, but it still might not be uefi bootable
      log_msg "Making ${CUSTOMISO} a hybrid iso"
      #~ isohybrid ${WORKDIR}/${CUSTOMISO} # disable this when isohybrid has --uefi option available, as below command
      isohybrid --uefi ${WORKDIR}/${CUSTOMISO} # enable this when isohybrid has --uefi option available
    ;;
  esac

  # create the md5 sum file so the user doesn't have to - this is good so the iso
  # file can later be tested to ensure it hasn't become corrupted
  log_msg "Creating ${CUSTOMISO}.md5 in ${WORKDIR}"
  cd ${WORKDIR}
  md5sum ${CUSTOMISO} > ${CUSTOMISO}.md5
  sleep 1
  # create the sha256 sum
  log_msg "Creating ${CUSTOMISO}.sha256 in ${WORKDIR}"
  cd ${WORKDIR}
  sha256sum ${CUSTOMISO} > ${CUSTOMISO}.sha256

  sleep 1

  ISOSIZE1="`ls -hs ${WORKDIR}/${CUSTOMISO} | awk '{print $1}'`"
  ISOSIZE2="`ls -l ${WORKDIR}/${CUSTOMISO} | awk '{print $5}'`"

  log_msg "  Custom ISO  ${WORKDIR}/${CUSTOMISO}  =  ${ISOSIZE1} (${ISOSIZE2})"
  log_msg "    is ready to be burned or tested in a virtual machine."
}
##### END function iso #####


iso
