FROM ubuntu:22.04@sha256:67cadaff1dca187079fce41360d5a7eb6f7dcd3745e53c79ad5efd8563118240

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        openjdk-21-jre \
        bash curl jq zip unzip build-essential \
    && rm -rf /var/lib/apt/lists/*

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
