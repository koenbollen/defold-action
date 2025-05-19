FROM ubuntu:24.04@sha256:6015f66923d7afbc53558d7ccffd325d43b4e249f41a6e93eef074c9505d2233

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        openjdk-21-jre \
        bash curl jq zip unzip \
        build-essential fontconfig fonts-dejavu \
    && rm -rf /var/lib/apt/lists/*

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
