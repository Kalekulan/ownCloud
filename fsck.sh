#!/bin/bash

: <<'END'
Filesystem check script to determine health of USB device with fs type ext4
Date: 2017-01-07

Usage: fsck.sh <DEVICE>
Example: fschk.sh /dev/sda

Find the device by issuing "ls /dev/sd*"

END

device=$1

if [ -z "$device" ]; then
    echo Device argument is null.
    exit
fi
#else
  #echo $String is NOT null.
#fi     # $String is null.

ls $device > /dev/null 2>&1
lsExitCode=$?

if [[ $lsExitCode -eq 0 ]]; then
    echo Device $device exists
else
    echo Device $device does not exist. Exiting...
    exit
fi


sudo findmnt -mn "$device"  > /dev/null 2>&1 #s flag = fstab only
mountCode=$?

echo Stopping apache2 server...
sudo service apache2 stop > /dev/null 2>&1

if [[ $mntCode -eq 0 ]]; then
    echo Device: $device is mounted. Unmounting now...
    sudo umount $device > /dev/null 2>&1
    unmountCode=$?

    if [[ $unmountCode -eq 0 ]]; then
        echo umount went OK
    else
        echo umount failed with exitcode $unmountCode. Exiting...
        exit
    fi
else
    echo Device: $device is not mounted.
fi

echo Starting fsck...
echo
#fsCheck=$(sudo fsck.ext4 "$device")
sudo fsck.ext4 -v $device
# > /dev/null 2>&1
fsckCode=$?

#echo $fsCheck

if [[ $fsckCode -eq 0 ]]; then
    echo File system is all clean!
else
    echo Fsck failed with exitcode $fsckCode. Exiting...
    #notify somehow
fi

echo
echo Mounting everything in fstab...
sudo mount -all  > /dev/null 2>&1
echo Starting apache2 server again...
sudo service apache2 start > /dev/null 2>&1
echo Done
exit