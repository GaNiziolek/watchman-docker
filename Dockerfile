FROM ubuntu:20.04

# https://serverfault.com/a/1016972 to ensure installing tzdata does
# not result in a prompt that hangs forever.
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Ubuntu 18.04 has an older version of Git, which causes actions/checkout@v3
# to check out the repository with REST, breaking version number generation.
RUN apt-get -y update && \ 
    apt-get -y install software-properties-common && \
    add-apt-repository -y ppa:git-core/ppa && \
    apt-get -y install \ 
        python3 \
        gcc \
        g++ \
        libssl-dev \
        curl \
        git

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Avoid build output from Watchman's build getting buffered in large
# chunks, which makes debugging progress tough.
ENV PYTHONUNBUFFERED=1

RUN git clone --branch patch-1 https://github.com/GaNiziolek/watchman  && \
    rustup default stable

WORKDIR /watchman

RUN ./install-system-packages.sh && \
    git config --global --add safe.directory /watchman  && \
    ./autogen.sh  && \
    mkdir -p /usr/local/{bin,lib} /usr/local/var/run/watchman  && \
    cp built/bin/* /usr/local/bin  && \
    cp built/lib/* /usr/local/lib || true  && \
    chmod 755 /usr/local/bin/watchman  && \
    chmod 2777 /usr/local/var/run/watchman  && \
    rm -rf /tmp/*

RUN rm -rf /root/.rustup && rm -rf /root/.cargo
