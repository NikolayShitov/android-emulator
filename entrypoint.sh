#!/bin/bash

set -e

#echo "see places libGL"
#ldconfig -p | grep libGL.so.1

function array_contains {
    local name="$1[@]"
    local arr=("${!name}")
    local item="$2"

    for i in "${arr[@]}"
    do
        if [ "$i" == "$item" ]
        then
            echo "1"
            return
        fi
    done

    echo "0"
    return
}

function update {
    mapfile -t res < <(${ANDOIRD_BIN}/sdkmanager --list | sed -e '/Available Packages/q' | head -n-2 | tail -n +4 | cut -d'|' -f 1)
    retcode=$?
    echo "recode of sdk list installed packages: [$retcode]"

    item_in_array=$(array_contains res "$1")
    echo "[$1] in array installed packages?: [$item_in_array]"
    if [ $retcode -eq 0 ] && [ $item_in_array -eq 1 ]
    then
        echo "package already installed and updated: [${res[*]}]"
    else
        echo "install package: [$1]"
        ${ANDOIRD_BIN}/sdkmanager $1
    fi

    item_in_array=$(array_contains res "$2")
    echo "[$2] in array installed packages?: [$item_in_array]"  
    if [ $retcode -eq 0 ] && [ $item_in_array -eq 1 ]
    then
        echo "package already installed and updated: [${res[*]}]"
    else
        echo "install package: [$2]"
        ${ANDOIRD_BIN}/sdkmanager $2
    fi
}

echo "Start ssh"
service ssh restart

echo "Detect ip and forward ports to outside interface via socat"
# show output for interface eth0
# get line with "inet"
# trim spaces in line
# split line by spaces and get part with number 2
# split line with : and get second part
ip=$(ifconfig eth0 | grep 'inet ' | sed -e 's/^[ \t]*//' | cut -d' ' -f 2 | cut -d':' -f 2 | head -n 1)

if [ -z "$ip" ]
then
  echo "\$ip is empty!"
  exit 1
else
  echo "\$ip is [${ip}]"
fi

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

#echo "See free space:"
#df

#echo "Packages info"
#${ANDOIRD_BIN}/sdkmanager --list

echo "Update installed sdk packages"
${ANDOIRD_BIN}/sdkmanager --update

echo "Install/update sysimage and platform for [${ANDROID_EMULATOR_API_VERSION_FOR_START}]"
case "${ANDROID_EMULATOR_API_VERSION_FOR_START}" in
    ${!API14@}) export LD_LIBRARY_PATH="/usr/lib/i386-linux-gnu/mesa" && update ${PLATFORM14} ${API14};;
    ${!API15@}) export LD_LIBRARY_PATH="/usr/lib/i386-linux-gnu/mesa" && update ${PLATFORM15} ${API15};;
    ${!API16@}) export LD_LIBRARY_PATH="/usr/lib/i386-linux-gnu/mesa" && update ${PLATFORM16} ${API16};;
    ${!API17@}) export LD_LIBRARY_PATH="/usr/lib/i386-linux-gnu/mesa" && update ${PLATFORM17} ${API17};;
    ${!API18@}) export LD_LIBRARY_PATH="/usr/lib/i386-linux-gnu/mesa" && update ${PLATFORM18} ${API18};;
    ${!API19@}) export LD_LIBRARY_PATH="/usr/lib/i386-linux-gnu/mesa" && update ${PLATFORM19} ${API19};;
    ${!API21@}) update ${PLATFORM21} ${API21};;
    ${!API22@}) update ${PLATFORM22} ${API22};;
    ${!API23@}) update ${PLATFORM23} ${API23};;
    ${!API24@}) update ${PLATFORM24} ${API24};;
    ${!API25@}) update ${PLATFORM25} ${API25};;
    ${!API26@}) update ${PLATFORM26} ${API26};;
    ${!API27@}) export LD_LIBRARY_PATH="/usr/lib/i386-linux-gnu/mesa" && update ${PLATFORM27} ${API27};;
    ${!API28@}) update ${PLATFORM28} ${API28};;
    *) 
        echo "UNSUPPORTED API VERSION [${ANDROID_EMULATOR_API_VERSION_FOR_START}]"
        exit 1
esac

echo "Create, if no exists, virtual device for [${ANDROID_EMULATOR_API_VERSION_FOR_START}]"
${ANDOIRD_BIN}/avdmanager -v create avd \
    -n ${ANDROID_EMULATOR_API_VERSION_FOR_START} \
    -k ${!ANDROID_EMULATOR_API_VERSION_FOR_START} \
    -d "10.1in WXGA (Tablet)" \
  || echo "avdmanager retcode [$?]"

echo "Running emulator for [$ANDROID_EMULATOR_API_VERSION_FOR_START]"
if [ "${ANDROID_EMULATOR_API_VERSION_FOR_START}" == "API14" ]
then
    ${ANDROID_EMU}/emulator \
        -avd ${ANDROID_EMULATOR_API_VERSION_FOR_START} \
        -partition-size 1024 \
        -no-boot-anim -noaudio -no-window -gpu off -verbose \
        -qemu -vnc :2 &
else
    ${ANDROID_EMU}/emulator \
        -avd ${ANDROID_EMULATOR_API_VERSION_FOR_START} \
        -partition-size 1024 \
        -no-boot-anim -noaudio -no-window -gpu auto -verbose \
        -qemu -vnc :2 -enable-kvm &
fi

echo "Wait device starting"
${ANDROID_TOOLS}/adb wait-for-device

# for prevent exiting, because we have only background tasks
# this must run bash, which passed as last arg for docker run command
exec "$@";
