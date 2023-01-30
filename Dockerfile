FROM ubuntu:22.04

RUN apt update && \
    apt install -y \
        git \
        curl \
        cargo \
        python3 \
        libssl-dev \
        g++ \
        extra-cmake-modules

RUN curl -L https://api.github.com/repos/facebook/watchman/tarball | tar xzvf - --one-top-level="watchman" --strip-components 1    

WORKDIR /watchman

RUN ./install-system-packages.sh && \
    ./autogen.sh && \
    mkdir -p /usr/local/{bin,lib} /usr/local/var/run/watchman && \
    cp built/bin/* /usr/local/bin && \
    cp built/lib/* /usr/local/lib || true && \
    chmod 755 /usr/local/bin/watchman && \
    chmod 2777 /usr/local/var/run/watchman && \
    rm -rf /tmp/*