FROM ubuntu:22.04

RUN apt-get update && apt-get install --fix-missing wget perl default-jre unzip -y \
    && cd /usr/local/bin    \
    && wget --output-document fastqc.0.12.1.zip https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.12.1.zip \
    && unzip fastqc.0.12.1.zip -d temp_extract \
    && mv temp_extract/* . \
    && rm -r temp_extract \
    && rm fastqc.0.12.1.zip \ 
    && ln -s FastQC/fastqc /usr/local/bin/fastqc \
    && apt-get remove unzip wget && apt-get clean

ENV PATH="/usr/local/bin/FastQC/${PATH}"
