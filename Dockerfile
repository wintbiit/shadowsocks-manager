ARG SS_RUST_VERSION="v1.20.4"
ARG TZ="Asia/Shanghai"

FROM node:20-alpine AS base
ARG SS_RUST_VERSION

WORKDIR /app/ss-rust

RUN apk add --no-cache tzdata curl wget iproute2 && \
    ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime && \
    echo "${TZ}" > /etc/timezone

# Download shadowsocks-rust binary and link to /usr/bin
RUN curl -L -o ss-rust.tar.gz "https://github.com/shadowsocks/shadowsocks-rust/releases/download/${SS_RUST_VERSION}/shadowsocks-${SS_RUST_VERSION}.x86_64-unknown-linux-musl.tar.xz" \
    && tar -xvf ss-rust.tar.gz \
    && rm ss-rust.tar.gz \
    && chmod +x ./* \
    && ln -s /app/ss-rust/sslocal /usr/bin/sslocal \
    && ln -s /app/ss-rust/ssmanager /usr/bin/ssmanager \
    && ln -s /app/ss-rust/ssserver /usr/bin/ssserver \
    && ln -s /app/ss-rust/ssurl /usr/bin/ssurl

FROM base

WORKDIR /app/ssmgr

ADD package.json gulpfile.js ./
COPY plugins ./plugins

RUN yarn install

COPY . .

RUN yarn build && \
    chmod +x ./bin/ssmgr && \
    npm link

ENTRYPOINT ["ssmgr", "-r", "rust"]