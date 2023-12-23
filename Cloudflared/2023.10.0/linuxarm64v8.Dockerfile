FROM golang:1.20.6 as builder
ENV GO111MODULE=on \
    CGO_ENABLED=0 \ 
    CLOUDFLARED_VERSION=2023.10.0
WORKDIR /go/src/github.com/cloudflare/cloudflared/

# copy our sources into the builder image
RUN git clone --branch ${CLOUDFLARED_VERSION} --single-branch --depth 1 https://github.com/cloudflare/cloudflared.git .

# compile cloudflared
RUN GOOS=linux GOARCH=arm64 make cloudflared

# use a distroless base image with glibc
FROM --platform=arm64 gcr.io/distroless/base-debian11:nonroot

LABEL org.opencontainers.image.source="https://github.com/cloudflare/cloudflared"

# copy our compiled binary
COPY --from=builder --chown=nonroot /go/src/github.com/cloudflare/cloudflared/cloudflared /usr/local/bin/

# run as non-privileged user
USER nonroot

# command / entrypoint of container
ENTRYPOINT ["cloudflared", "--no-autoupdate"]
CMD ["version"]