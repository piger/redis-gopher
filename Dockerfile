FROM debian:9

RUN apt -q update && \
    env DEBIAN_FRONTEND=noninteractive apt -q -y upgrade && \
    env DEBIAN_FRONTEND=noninteractive apt -q -y install eatmydata && \
    env DEBIAN_FRONTEND=noninteractive eatmydata apt -q -y install build-essential git-core

WORKDIR /src

RUN git clone https://github.com/antirez/redis.git --depth 1 redis && \
        cd redis && \
        make

FROM debian:stretch-slim
COPY --from=0 /src/redis/src/redis-server /src/redis/src/redis-cli /usr/local/bin/

RUN apt -q update && \
    env DEBIAN_FRONTEND=noninteractive apt -q -y upgrade && \
    adduser --system --group --home /var/lib/redis redis && \
    install -d -g redis -o root -m 750 /etc/redis && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

ADD redis.conf security.conf /etc/redis/

USER redis
CMD ["/usr/local/bin/redis-server", "/etc/redis/redis.conf"]
