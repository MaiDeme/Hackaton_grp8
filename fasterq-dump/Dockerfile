FROM ubuntu:22.04

RUN apt-get update && apt-get install --fix-missing wget -y  \
    && cd /usr/local/bin \
    && wget --output-document sratoolkit.tar.gz https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/3.1.1/sratoolkit.3.1.1-ubuntu64.tar.gz   \
    && tar -vxzf sratoolkit.tar.gz \
    && rm sratoolkit.tar.gz \    
    && apt-get clean

ENV PATH="/usr/local/bin/sratoolkit.3.1.1-ubuntu64/bin:${PATH}"
