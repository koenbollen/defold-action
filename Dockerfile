FROM alpine:3.21.2@sha256:56fa17d2a7e7f168a043a2712e63aed1f8543aeafdcee47c58dcffe38ed51099

RUN apk --no-cache add openjdk21-jre
RUN apk --no-cache add bash curl jq zip unzip
RUN apk --no-cache add libxext libxi libstdc++ fontconfig ttf-dejavu libc6-compat gcompat

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
