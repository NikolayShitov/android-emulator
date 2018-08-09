#!/bin/sh

echo "Run sshd"
/usr/sbin/sshd

echo "Detect ip and forward ports to outside interface via socat"
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

echo "Install/update sysimage and platform for [$1]"
case "$1" in
	${API14}) ${ANDOIRD_BIN}/sdkmanager ${PLATFORM14} ${API14};;
	${API15}) ${ANDOIRD_BIN}/sdkmanager ${PLATFORM15} ${API15};;
	${API16}) ${ANDOIRD_BIN}/sdkmanager ${PLATFORM16} ${API16};;
	${API17}) ${ANDOIRD_BIN}/sdkmanager ${PLATFORM17} ${API17};;
	${API18}) ${ANDOIRD_BIN}/sdkmanager ${PLATFORM18} ${API18};;
	${API19}) ${ANDOIRD_BIN}/sdkmanager ${PLATFORM19} ${API19};;
	${API21}) ${ANDOIRD_BIN}/sdkmanager ${PLATFORM21} ${API21};;
	${API22}) ${ANDOIRD_BIN}/sdkmanager ${PLATFORM22} ${API22};;
	${API23}) ${ANDOIRD_BIN}/sdkmanager ${PLATFORM23} ${API23};;
	${API24}) ${ANDOIRD_BIN}/sdkmanager ${PLATFORM24} ${API24};;
	${API25}) ${ANDOIRD_BIN}/sdkmanager ${PLATFORM25} ${API25};;
	${API26}) ${ANDOIRD_BIN}/sdkmanager ${PLATFORM26} ${API26};;
	${API27}) ${ANDOIRD_BIN}/sdkmanager ${PLATFORM27} ${API27};;
	${API28}) ${ANDOIRD_BIN}/sdkmanager ${PLATFORM28} ${API28};;
	*) 
		echo "UNSUPPORTED API VERSION [$1]"
		exit 1
esac

echo "Create, if no exists, virtual device for [$1]"
${ANDOIRD_BIN}/avdmanager -v create avd -n $1 -k ${!1} -d "10.1in WXGA (Tablet)"

echo "Running emulator for [$1]"
echo ${ANDROID_EMU}/emulator -avd $1 -no-boot-anim -noaudio -no-window -gpu off -verbose -qemu -vnc :2 -enable-kvm
