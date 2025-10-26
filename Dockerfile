# ── Stage 1: build ───────────────────────────────────────
FROM alpine:latest AS builder
RUN apk add --no-cache git build-base openssl-dev zlib-dev \
    && git clone https://github.com/TelegramMessenger/MTProxy.git /opt/MTProxy \
    && cd /opt/MTProxy \
    && make \
    && mkdir -p /out/bin \
    && cp objs/bin/mtproto-proxy /out/bin/

# ── Stage 2: runtime ───────────────────────────────────
FROM alpine:latest
RUN apk add --no-cache ca-certificates && update-ca-certificates
COPY --from=builder /out/bin/mtproto-proxy /usr/local/bin/mtproto-proxy
EXPOSE 443 8888
ENTRYPOINT ["/usr/local/bin/mtproto-proxy"]
CMD ["-u","nobody","-p","8888","-H","443","-S","<YOUR_SECRET_HEX>","/etc/mtproto-proxy/proxy-multi.conf"]

