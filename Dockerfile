# Android development environment for ubuntu.
# version 0.0.5

FROM ubuntu

MAINTAINER cheshir <ns@devtodev.com>

# Specially for SSH access and port redirection
ENV ROOTPASSWORD android

# Expose ADB, ADB control and VNC ports
EXPOSE 22
EXPOSE 5037
EXPOSE 5554
EXPOSE 5555
EXPOSE 5900
EXPOSE 80
EXPOSE 443

ENV DEBIAN_FRONTEND noninteractive

# Update packages
RUN apt-get -y update && \
    apt-get -y install software-properties-common bzip2 ssh net-tools openssh-server socat curl && \
    apt-get update && \
    apt-get -y install default-jdk && \
    rm -rf /var/lib/apt/lists/*

# Add android tools and platform tools to PATH
ENV ANDROID_HOME /sdk
ENV ANDOIRD_BIN $ANDROID_HOME/tools/bin 
ENV ANDROID_TOOLS $ANDROID_HOME/platform-tools
ENV ANDROID_EMU $ANDROID_HOME/emulator

ENV PATH $PATH:$ANDOIRD_BIN
ENV PATH $PATH:$ANDROID_TOOLS
ENV PATH $PATH:$ANDROID_EMU

# Export JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/default-java

RUN echo $PATH
RUN echo $ANDROID_HOME
RUN echo $JAVA_HOME

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
		"system-images;android-14;default;armeabi-v7a" \
		"system-images;android-15;google_apis;x86" \
		"system-images;android-16;google_apis;x86" \
		"system-images;android-17;google_apis;x86" \
		"system-images;android-18;google_apis;x86" \
		"system-images;android-19;google_apis;x86" \
		"system-images;android-21;google_apis;x86_64" \
		"system-images;android-22;google_apis;x86_64" \
		"system-images;android-23;google_apis;x86_64" \
		"system-images;android-24;google_apis;x86_64" \
		"system-images;android-25;google_apis;x86_64" \
		"system-images;android-26;google_apis;x86_64" \
		"system-images;android-27;google_apis;x86" \
		"system-images;android-28;google_apis;x86_64"

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
ENTRYPOINT ["/entrypoint.sh"]
