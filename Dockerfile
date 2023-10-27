FROM alpine:3.18.4@sha256:eece025e432126ce23f223450a0326fbebde39cdf496a85d8c016293fc851978

RUN apk --no-cache add openjdk17-jre
RUN apk --no-cache add bash curl jq
RUN apk --no-cache add libxext libxi libstdc++ fontconfig ttf-dejavu

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
