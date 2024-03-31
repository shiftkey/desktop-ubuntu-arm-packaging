FROM ubuntu:18.04

ENV AS=arm-linux-gnueabihf-as
ENV STRIP=arm-linux-gnueabihf-strip
ENV AR=arm-linux-gnueabihf-ar
ENV CC=arm-linux-gnueabihf-gcc
ENV CPP=arm-linux-gnueabihf-cpp
ENV CXX=arm-linux-gnueabihf-g++
ENV LD=arm-linux-gnueabihf-ld
ENV FC=arm-linux-gnueabihf-gfortran
ENV PKG_CONFIG_PATH=/usr/lib/arm-linux-gnueabihf/pkgconfig
ENV npm_config_arch=arm

# baseline dependencies for all versions
RUN apt update && apt install -y software-properties-common lsb-release \
    sudo wget curl build-essential jq autoconf automake \
    pkg-config ca-certificates rpm

# additional setup for arm
RUN apt-get install -y gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf binutils-arm-linux-gnueabihf pkg-config-arm-linux-gnueabihf
RUN sudo sed -i "s/^deb/deb [arch=amd64,i386]/g" /etc/apt/sources.list
RUN echo "deb [arch=arm64,armhf] http://ports.ubuntu.com/ $(lsb_release -s -c) main universe multiverse restricted" | tee -a /etc/apt/sources.list
RUN echo "deb [arch=arm64,armhf] http://ports.ubuntu.com/ $(lsb_release -s -c)-updates main universe multiverse restricted" | tee -a /etc/apt/sources.list
RUN dpkg --add-architecture armhf
RUN apt-get update && apt-get install -y libx11-dev:armhf libx11-xcb-dev:armhf libxkbfile-dev:armhf libsecret-1-dev:armhf

# This version supports older GLIBC (official builds required a minimum of GLIBC 2.28)
# this might break if you bump the `env.NODE_VERSION` version - ensure you are on the latest version
# of which ever major/minor release which should have this variant available
#
# See https://github.com/nodejs/unofficial-builds/ for more information on these versions.
#
RUN curl -sL 'https://unofficial-builds.nodejs.org/download/release/v18.16.1/node-v18.16.1-linux-x64-glibc-217.tar.xz' | xzcat | tar -vx  --strip-components=1 -C /usr/local/
RUN npm install --global yarn

# install new enough git to work with repository
RUN add-apt-repository ppa:git-core/ppa -y
RUN apt update && apt install -y git
RUN git --version

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
