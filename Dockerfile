FROM alpine:3.11

RUN apk add --no-cache git bash

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
