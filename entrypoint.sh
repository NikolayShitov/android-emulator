#!/bin/bash

function array_contains {
    local name=$1[@]
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
	res=$(${ANDOIRD_BIN}/sdkmanager --list | sed -e '/Available Packages/q' | head -n-2 | tail -n +4 | cut -d'|' -f 1)
	item_in_array=$(array_contains res "$1")
	if [ $? -eq 0 ] && [ $item_in_array -eq 1 ]
	then
		echo "package already installed and updated: [${res[@]}]"
	else
		echo "install package: [$1]"
		${ANDOIRD_BIN}/sdkmanager $1
	fi
	
	res=$(${ANDOIRD_BIN}/sdkmanager --list | sed -e '/Available Packages/q' | head -n-2 | tail -n +4 | cut -d'|' -f 1)
	item_in_array=$(array_contains res "$2")
	if [ $? -eq 0 ] && [ $item_in_array -eq 1 ]
	then
		echo "package already installed and updated: [${res[@]}]"
	else
		echo "install package: [$2]"
		${ANDOIRD_BIN}/sdkmanager $2
	fi
}

echo "Run sshd"
/usr/sbin/sshd

echo "Detect ip and forward ports to outside interface via socat"
ip=$(ifconfig  | grep 'inet ' | grep -v '127.0.0.1' | cut -d' ' -f 12 | cut -d':' -f 2 | head -n 1)

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

echo "See free space:"
df

echo "Packages info"
${ANDOIRD_BIN}/sdkmanager --list

echo "Update installed sdk packages"
${ANDOIRD_BIN}/sdkmanager --update

echo "Install/update sysimage and platform for [${ANDROID_EMULATOR_API_VERSION_FOR_START}]"
case "${ANDROID_EMULATOR_API_VERSION_FOR_START}" in
	${!API14@}) update ${PLATFORM14} ${API14};;
	${!API15@}) update ${PLATFORM15} ${API15};;
	${!API16@}) update ${PLATFORM16} ${API16};;
	${!API17@}) update ${PLATFORM17} ${API17};;
	${!API18@}) update ${PLATFORM18} ${API18};;
	${!API19@}) update ${PLATFORM19} ${API19};;
	${!API21@}) update ${PLATFORM21} ${API21};;
	${!API22@}) update ${PLATFORM22} ${API22};;
	${!API23@}) update ${PLATFORM23} ${API23};;
	${!API24@}) update ${PLATFORM24} ${API24};;
	${!API25@}) update ${PLATFORM25} ${API25};;
	${!API26@}) update ${PLATFORM26} ${API26};;
	${!API27@}) update ${PLATFORM27} ${API27};;
	${!API28@}) update ${PLATFORM28} ${API28};;
	*) 
		echo "UNSUPPORTED API VERSION [${ANDROID_EMULATOR_API_VERSION_FOR_START}]"
		exit 1
esac

echo "Create, if no exists, virtual device for [${ANDROID_EMULATOR_API_VERSION_FOR_START}]"
${ANDOIRD_BIN}/avdmanager -v create avd \
	-n ${ANDROID_EMULATOR_API_VERSION_FOR_START} \
	-k ${!ANDROID_EMULATOR_API_VERSION_FOR_START} \
	-d "10.1in WXGA (Tablet)"

echo "Running emulator for [$ANDROID_EMULATOR_API_VERSION_FOR_START]"
echo ${ANDROID_EMU}/emulator \
	-avd ${ANDROID_EMULATOR_API_VERSION_FOR_START} -no-boot-anim -noaudio -no-window -gpu off -verbose -qemu -vnc :2 -enable-kvm
