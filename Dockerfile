FROM ubuntu:18.04
MAINTAINER quriouspixel

ENV QTVER=5.14.2
ENV QTVERMIN=514
ENV LLVMVER=10
ENV GCCVER=10

ENV CLANG_BINARY=clang-${LLVMVER}
ENV CLANGXX_BINARY=clang++-${LLVMVER}
ENV LLD_BINARY=lld-${LLVMVER}
ENV GCC_BINARY=gcc-${GCCVER}
ENV GXX_BINARY=g++-${GCCVER}

RUN \
    apt-get update -y && \
    apt-get install -y curl software-properties-common apt-transport-https && \
    add-apt-repository -y ppa:ubuntu-toolchain-r/test && \
    add-apt-repository -y ppa:beineri/opt-qt-${QTVER}-bionic && \
    DEBIAN_FRONTEND=noninteractive apt-get update && apt-get -y full-upgrade && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
    build-essential \
    dpkg \
    fuse \
    $GCC_BINARY $GXX_BINARY \
    libbluetooth-dev \
    liblz4-dev \
    liblzma-dev \
    libssl-dev \
    libopus-dev \
    libpng-dev \
    libsystemd-dev \
    libzip-dev \
    libzstd-dev \
    zlib1g-dev \
    libasound2-dev \
    libpulse-dev \
    pulseaudio \
    p7zip \
    p7zip-full \
    libsfml-dev \
    libminiupnpc-dev \
    libmbedtls-dev \
    libpugixml-dev \
    libbz2-dev \
    liblzo2-dev \
    qt514-meta-full \
    libxi-dev \
    libavcodec-dev \
    libudev-dev \
    libusb-1.0-0-dev \
    libevdev-dev \
    libc6-dev \
    libhidapi-dev \
    libavformat-dev \
    libavdevice-dev \
    libfmt-dev \
    libwayland-dev \
    libxrandr-dev \
    libglu1-mesa-dev \
    libcurl4-openssl-dev \
    x11-utils \
    zenity \
    wget \
    curl \
    git \
    gettext \
    ccache \
    ninja-build 
     
RUN \
	update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-${GCCVER} 10 && \
	update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-${GCCVER} 10 && \
	ls -al /opt/qt514/ && \
	ls -al /opt/qt514/bin/ && \
	find . -name "qt514-env.sh" -exec sh qt514-env.sh {} \; && \
	. /opt/qt514/bin/qt514-env.sh && \
	rm -rf /opt/qt514/examples /opt/qt514/doc && \
	gcc --version && \
	g++ --version 
    
RUN 	apt-get clean autoclean && apt-get autoremove --yes && rm -rf /var/lib/apt /var/lib/cache /var/lib/log
