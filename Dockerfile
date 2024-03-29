FROM ubuntu:jammy
LABEL maintainer="Piasy Xu (xz4215@gmail.com)"

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && apt-get install -y htop iftop unzip git wget curl \
    vim openjdk-11-jdk-headless file cmake \
    # needed for webrtc env
    lsb-release sudo python-pip tzdata

# libfaketime
RUN cd ~ && \
    git clone https://github.com/wolfcw/libfaketime.git && \
    cd libfaketime/src && \
    make install && \
    echo "export LD_PRELOAD=/usr/local/lib/faketime/libfaketime.so.1" \
        >> /root/.bashrc && \
    echo "export FAKETIME_NO_CACHE=1" >> /root/.bashrc && \
    cd ~ && \
    rm -rf libfaketime

# prepare webrtc env
COPY install-build-deps.sh /root/
COPY install-build-deps-android.sh /root/
RUN cd ~ && \
    chmod +x ./install-build-deps.sh && \
    chmod +x ./install-build-deps-android.sh && \
    echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula \
        select true | debconf-set-selections && \
    ./install-build-deps-android.sh && \
    echo 'export PATH=/root/src/media/webrtc_repo/depot_tools_linux:$PATH' \
        >> /root/.bashrc && \
    rm -rf install-build-deps.sh install-build-deps-android.sh

SHELL ["/bin/bash", "-c"]
RUN touch ~/.bashrc && chmod +x ~/.bashrc
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
RUN . ~/.nvm/nvm.sh && source ~/.bashrc && nvm install 16
RUN apt-get install -y python3-pip

# prepare owt env
# RUN cd ~ && \
#     wget https://nodejs.org/dist/v8.15.1/node-v8.15.1-linux-x64.tar.gz && \
#     mkdir -p /usr/local/lib/nodejs && \
#     tar xf node-v8.15.1-linux-x64.tar.gz -C /usr/local/lib/nodejs && \
#     echo 'export PATH=/usr/local/lib/nodejs/node-v8.15.1-linux-x64/bin:$PATH' \
#         >> ~/.bashrc && \
#     export PATH=/usr/local/lib/nodejs/node-v8.15.1-linux-x64/bin:$PATH && \
#     cd ~ && \
#     git config --global user.name test && \
#     git config --global user.email test@example.com && \
#     git clone https://github.com/open-webrtc-toolkit/owt-server.git \
#     owt-server-4.3 && \
#     cd owt-server-4.3 && \
#     git checkout 4.3.x && \
#     ./scripts/installDepsUnattended.sh && \
#     npm install -g node-gyp graceful-fs grunt-cli && \
#     ./scripts/build.js -t mcu --check && \
#     rm -rf owt-server-4.3 node-v8.15.1-linux-x64.tar.gz

# prepare vscode debug env
# RUN apt-get install -y gdb
# COPY vscode-server-0-28-0.zip /root/
# RUN cd ~ && \
#     unzip vscode-server-0-28-0.zip && \
#     rm -f vscode-server-0-28-0.zip

# clean up
RUN  apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*

