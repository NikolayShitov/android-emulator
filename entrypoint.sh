#!/bin/bash

if [[ $EMULATOR == "" ]]; then
    EMULATOR="android-28"
    echo "Using default emulator $EMULATOR"
fi

if [[ $ARCH == "" ]]; then
    ARCH="x86_64"
    echo "Using default arch $ARCH"
fi
echo EMULATOR  = "Requested API: ${EMULATOR} (${ARCH}) emulator."
#if [[ -n $1 ]]; then
#    echo "Last line of file specified as non-opt/last argument:"
#    tail -1 $1
#fi

# Run sshd
/usr/sbin/sshd

# Detect ip and forward ADB ports outside to outside interface
ip=$(ifconfig  | grep 'inet '| grep -v '127.0.0.1' | cut -d' ' -f 10 | awk '{ print $1}')
echo "IP is: [${ip}]"
echo "running socat port 5037"
socat tcp-listen:5037,bind=$ip,fork tcp:127.0.0.1:5037 &
echo "running socat port 5554"
socat tcp-listen:5554,bind=$ip,fork tcp:127.0.0.1:5554 &
echo "running socat port 5555"
socat tcp-listen:5555,bind=$ip,fork tcp:127.0.0.1:5555 &
echo "running socat port 80"
socat tcp-listen:80,bind=$ip,fork tcp:127.0.0.1:80 &
echo "running socat port 443"
socat tcp-listen:443,bind=$ip,fork tcp:127.0.0.1:443 &

# Set up and run emulator
if [[ $ARCH == *"x86"* ]]
then 
    EMU="x86"
else
    EMU="arm"
fi

echo "running emulator"
echo "no" | ${ANDROID_EMU}/emulator -avd $1 -no-boot-anim -noaudio -no-window -gpu off -verbose -qemu -vnc :2 -enable-kvm
