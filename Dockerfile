FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
    build-essential \
    bash \
    bc \
    binutils \
    build-essential \
    bzip2 \
    cpio \
    g++ \
    gcc \
    git \
    gzip \
    locales \
    libncurses5-dev \
    libdevmapper-dev \
    libsystemd-dev \
    make \
    mercurial \
    whois \
    patch \
    perl \
    python \
    rsync \
    sed \
    tar \
    vim \ 
    unzip \
    wget \
    bison \
    flex \
    libssl-dev \
    libfdt-dev

# Sometimes Buildroot need proper locale, e.g. when using a toolchain
# based on glibc.
RUN locale-gen en_US.utf8

# RUN git clone git://git.buildroot.net/buildroot --depth=1 --branch=2020.08 /root/buildroot
RUN git clone git://git.buildroot.net/buildroot --depth=1 /root/buildroot
COPY systemtap.patch /root/systemtap.patch
WORKDIR /root/buildroot
RUN git apply ../systemtap.patch

# O will be set dynamically in run.sh based on firmware name
RUN touch .config
RUN touch kernel.config

VOLUME /root/buildroot/dl
# Output directories will be created dynamically

RUN ["/bin/bash"]
