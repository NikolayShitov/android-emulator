FROM dtdservices/android-sdk-docker

MAINTAINER cheshir "ns@devtodev.com"

# Expose ADB, ADB control and VNC ports
EXPOSE 22
EXPOSE 5037
EXPOSE 5554
EXPOSE 5555
EXPOSE 5902
EXPOSE 80
EXPOSE 443

# Specially for SSH access and port redirection
ENV ROOTPASSWORD android

ARG ANDROID_EMULATOR_API_VERSION_FOR_START=API28
ENV ANDROID_EMULATOR_API_VERSION_FOR_START=${ANDROID_EMULATOR_API_VERSION_FOR_START}

ENV DEBIAN_FRONTEND noninteractive

# Update packages
RUN dpkg --add-architecture i386
RUN apt-get -y update
RUN apt-get -y install sudo software-properties-common bzip2 socat curl net-tools openssh-server
RUN apt-get -y install qemu qemu-kvm libvirt-bin bridge-utils virt-manager cpu-checker libpulse0 libguestfs-tools
RUN apt-get -y install default-jre default-jdk
RUN apt-get clean

# Export JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/default-java
RUN echo $JAVA_HOME

ENV API14 "system-images;android-14;default;armeabi-v7a"
ENV PLATFORM14 "platforms;android-14"

ENV API15 "system-images;android-15;google_apis;x86"
ENV PLATFORM15 "platforms;android-15"

ENV API16 "system-images;android-16;google_apis;x86"
ENV PLATFORM16 "platforms;android-16"

ENV API17 "system-images;android-17;google_apis;x86"
ENV PLATFORM17 "platforms;android-17"

ENV API18 "system-images;android-18;google_apis;x86"
ENV PLATFORM18 "platforms;android-18"

ENV API19 "system-images;android-19;google_apis;x86"
ENV PLATFORM19 "platforms;android-19"

ENV API21 "system-images;android-21;google_apis;x86_64"
ENV PLATFORM21 "platforms;android-21"

ENV API22 "system-images;android-22;google_apis;x86_64"
ENV PLATFORM22 "platforms;android-22"

ENV API23 "system-images;android-23;google_apis;x86_64"
ENV PLATFORM23 "platforms;android-23"

ENV API24 "system-images;android-24;google_apis;x86_64"
ENV PLATFORM24 "platforms;android-24"

ENV API25 "system-images;android-25;google_apis;x86_64"
ENV PLATFORM25 "platforms;android-25"

ENV API26 "system-images;android-26;google_apis;x86_64"
ENV PLATFORM26 "platforms;android-26"

ENV API27 "system-images;android-27;google_apis;x86"
ENV PLATFORM27 "platforms;android-27"

ENV API28 "system-images;android-28;google_apis;x86_64"
ENV PLATFORM28 "platforms;android-28"

ENV JAVA_OPTS "-XX:+IgnoreUnrecognizedVMOptions --add-modules java.se.ee"

RUN echo $(${ANDOIRD_BIN}/sdkmanager --version)

RUN yes | ${ANDOIRD_BIN}/sdkmanager --licenses

# Install latest android tools and system images
RUN ${ANDOIRD_BIN}/sdkmanager \
        "tools" \
        "platform-tools" \
        "emulator"
        
# setup sshd
RUN mkdir /var/run/sshd && \
RUN echo "sshd : ALL : allow" >> /etc/hosts.allow
RUN echo "root:${ROOTPASSWORD}" | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
RUN sed -i 's/#AllowTcpForwarding yes/AllowTcpForwarding yes/' /etc/ssh/sshd_config
RUN echo "AllowUsers root" >> /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"

RUN echo "export VISIBLE=now" >> /etc/profile

# Add entrypoint. current wirkdir - opt
COPY entrypoint.sh entrypoint.sh
RUN ls /opt
RUN chmod +x entrypoint.sh
ENTRYPOINT ["/opt/entrypoint.sh"]
