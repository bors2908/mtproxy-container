# ── Stage 1: build
FROM ubuntu:18.04 AS builder
RUN apt-get update \
    && apt-get install -y git curl build-essential libssl-dev zlib1g-dev mc \
    && git clone https://github.com/TelegramMessenger/MTProxy.git /opt/MTProxy \
    && cd /opt/MTProxy \
    && make \
    && mkdir -p /out/bin \
    && cp objs/bin/mtproto-proxy /out/bin/

# ── Stage 2: runtime
FROM ubuntu:18.04
RUN apt-get update  \
    && apt-get install -y ca-certificates curl cron xxd  \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /out/bin/mtproto-proxy /usr/local/bin/mtproto-proxy

WORKDIR /etc/mtproto-proxy

RUN curl -s https://core.telegram.org/getProxySecret -o proxy-secret \
 && curl -s https://core.telegram.org/getProxyConfig -o proxy-multi.conf

RUN echo "curl -s https://core.telegram.org/getProxyConfig -o /etc/mtproto-proxy/proxy-multi.conf" > /etc/cron.daily/mtproto-proxy \
 && chmod 755 /etc/cron.daily/mtproto-proxy

RUN MT_SECRET=$(head -c 16 /dev/urandom | xxd -p) \
 && echo "$MT_SECRET" > /etc/mtproto-proxy/mt_secret

RUN echo '#!/bin/bash\n'\
'set -e\n'\
'[ ! -f /etc/mtproto-proxy/proxy-secret ] && curl -s https://core.telegram.org/getProxySecret -o /etc/mtproto-proxy/proxy-secret\n'\
'[ ! -f /etc/mtproto-proxy/proxy-multi.conf ] && curl -s https://core.telegram.org/getProxyConfig -o /etc/mtproto-proxy/proxy-multi.conf\n'\
'MT_SECRET=$(cat /etc/mtproto-proxy/mt_secret)\n'\
'exec /usr/local/bin/mtproto-proxy -u nobody -p 8888 -H 443 -S "$MT_SECRET" --aes-pwd /etc/mtproto-proxy/proxy-secret /etc/mtproto-proxy/proxy-multi.conf -M 1' \
> /entrypoint.sh \
 && chmod +x /entrypoint.sh

EXPOSE 443
ENTRYPOINT ["/entrypoint.sh"]
