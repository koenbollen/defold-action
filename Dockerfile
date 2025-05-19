FROM ubuntu:22.04@sha256:67cadaff1dca187079fce41360d5a7eb6f7dcd3745e53c79ad5efd8563118240

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        openjdk-21-jre \
        bash curl jq zip unzip \
        autoconf automake build-essential freeglut3-dev libssl-dev libtool libxi-dev libx11-xcb-dev libxrandr-dev libopenal-dev libgl1-mesa-dev libglw1-mesa-dev openssl tofrodos tree valgrind uuid-dev fontconfig fonts-dejavu \
    && rm -rf /var/lib/apt/lists/*

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
