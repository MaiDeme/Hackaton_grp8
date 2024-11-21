FROM ubuntu:22.04


RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    zlib1g-dev \
    libncurses5-dev \
    libbz2-dev \
    liblzma-dev \
    && rm -rf /var/lib/apt/lists/* \
    && wget https://github.com/samtools/samtools/releases/download/1.9/samtools-1.9.tar.bz2 \
    && tar -vxjf samtools-1.9.tar.bz2 \
    && cd samtools-1.9 \
    && make \
    && make install \
    && cd .. \
    && rm -rf samtools-1.9 samtools-1.9.tar.bz2

ENV PATH="/samtools-1.9:${PATH}"
