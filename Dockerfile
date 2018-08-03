FROM dtdservices/android-sdk-docker

MAINTAINER cheshir "ns@devtodev.com"

ARG ANDROID_EMULATOR_API_VERSION_FOR_START=API28

# Update packages
RUN apt-get -y update \
    && apt-get -y install software-properties-common bzip2 ssh net-tools openssh-server socat curl \
    && rm -rf /var/lib/apt/lists/*
    
ENV API14 "system-images;android-14;default;armeabi-v7a"
ENV API15 "system-images;android-15;google_apis;x86"
ENV API16 "system-images;android-16;google_apis;x86"
ENV API17 "system-images;android-17;google_apis;x86"
ENV API18 "system-images;android-18;google_apis;x86"
ENV API19 "system-images;android-19;google_apis;x86"
ENV API21 "system-images;android-21;google_apis;x86_64"
ENV API22 "system-images;android-22;google_apis;x86_64"
ENV API23 "system-images;android-23;google_apis;x86_64"
ENV API24 "system-images;android-24;google_apis;x86_64"
ENV API25 "system-images;android-25;google_apis;x86_64"
ENV API26 "system-images;android-26;google_apis;x86_64"
ENV API27 "system-images;android-27;google_apis;x86"
ENV API28 "system-images;android-28;google_apis;x86_64"

RUN echo $API14

RUN yes | ${ANDROID_TOOLS}/sdkmanager --licenses

# Install latest android tools and system images
RUN ${ANDOIRD_BIN}/sdkmanager \
        "tools" \
		"platform-tools" \
		"emulator" \
		"platforms;android-14" \
		"platforms;android-15" \
		"platforms;android-16" \
		"platforms;android-17" \
		"platforms;android-18" \
		"platforms;android-19" \
		"platforms;android-20" \
		"platforms;android-21" \
		"platforms;android-22" \
		"platforms;android-23" \
		"platforms;android-24" \
		"platforms;android-25" \
		"platforms;android-26" \
		"platforms;android-27" \
		"platforms;android-28" \
		$API14 \
		$API15 \
		$API16 \
		$API17 \
		$API18 \
		$API19 \
		$API21 \
		$API22 \
		$API23 \
		$API24 \
		$API25 \
		$API26 \
		$API27 \
		$API28
		
# Do you wish to create a custom hardware profile? [no]		
RUN no | ${ANDROID_TOOLS}/avdmanager -f -v create avd -n API14 -k $API14 -d "10.1in WXGA (Tablet)"
RUN no | ${ANDROID_TOOLS}/avdmanager -f -v create avd -n API15 -k $API15 -d "10.1in WXGA (Tablet)"
RUN no | ${ANDROID_TOOLS}/avdmanager -f -v create avd -n API16 -k $API16 -d "10.1in WXGA (Tablet)"
RUN no | ${ANDROID_TOOLS}/avdmanager -f -v create avd -n API17 -k $API17 -d "10.1in WXGA (Tablet)"
RUN no | ${ANDROID_TOOLS}/avdmanager -f -v create avd -n API18 -k $API18 -d "10.1in WXGA (Tablet)"
RUN no | ${ANDROID_TOOLS}/avdmanager -f -v create avd -n API19 -k $API19 -d "10.1in WXGA (Tablet)"
RUN no | ${ANDROID_TOOLS}/avdmanager -f -v create avd -n API21 -k $API21 -d "10.1in WXGA (Tablet)"
RUN no | ${ANDROID_TOOLS}/avdmanager -f -v create avd -n API22 -k $API22 -d "10.1in WXGA (Tablet)"
RUN no | ${ANDROID_TOOLS}/avdmanager -f -v create avd -n API23 -k $API23 -d "10.1in WXGA (Tablet)"
RUN no | ${ANDROID_TOOLS}/avdmanager -f -v create avd -n API24 -k $API24 -d "10.1in WXGA (Tablet)"
RUN no | ${ANDROID_TOOLS}/avdmanager -f -v create avd -n API25 -k $API25 -d "10.1in WXGA (Tablet)"
RUN no | ${ANDROID_TOOLS}/avdmanager -f -v create avd -n API26 -k $API26 -d "10.1in WXGA (Tablet)"
RUN no | ${ANDROID_TOOLS}/avdmanager -f -v create avd -n API27 -k $API27 -d "10.1in WXGA (Tablet)"
RUN no | ${ANDROID_TOOLS}/avdmanager -f -v create avd -n API28 -k $API28 -d "10.1in WXGA (Tablet)"

# Create fake keymap file
RUN mkdir /usr/local/android-sdk/tools/keymaps && \
    touch /usr/local/android-sdk/tools/keymaps/en-us

# Run sshd
RUN mkdir /var/run/sshd && \
    echo "root:$ROOTPASSWORD" | chpasswd && \
    sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
    echo "export VISIBLE=now" >> /etc/profile

ENV NOTVISIBLE "in users profile"

# Add entrypoint
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT /entrypoint.sh $ANDROID_EMULATOR_API_VERSION_FOR_START
