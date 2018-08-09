FROM dtdservices/android-sdk-docker

MAINTAINER cheshir "ns@devtodev.com"

ARG ANDROID_EMULATOR_API_VERSION_FOR_START=API28

# Update packages
RUN apt-get -y update \
    && apt-get -y install sudo qemu qemu-kvm libvirt-bin bridge-utils virt-manager cpu-checker libpulse0 software-properties-common bzip2 ssh net-tools openssh-server socat curl libguestfs-tools \
    && apt-get clean
    
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

RUN echo $(${ANDOIRD_BIN}/sdkmanager --version)

RUN yes | ${ANDOIRD_BIN}/sdkmanager --licenses

# Install latest android tools and system images
RUN ${ANDOIRD_BIN}/sdkmanager \
        "tools" \
        "platform-tools" \
        "emulator"

# Run sshd
RUN mkdir /var/run/sshd && \
    echo "root:$ROOTPASSWORD" | chpasswd && \
    sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
    echo "export VISIBLE=now" >> /etc/profile

ENV NOTVISIBLE "in users profile"

# Add entrypoint. current wirkdir - opt
COPY entrypoint.sh entrypoint.sh
RUN ls /opt
RUN chmod +x entrypoint.sh
ENTRYPOINT ["/opt/entrypoint.sh", "${ANDROID_EMULATOR_API_VERSION_FOR_START}"]
