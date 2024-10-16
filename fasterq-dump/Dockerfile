FROM ubuntu:22.04

RUN apt-get update && apt-get install --fix-missing wget -y  \
    && cd /usr/local \
    && wget --output-document sratoolkit.tar.gz https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/3.1.1/sratoolkit.3.1.1-ubuntu64.tar.gz   \
    && tar -vxzf sratoolkit.tar.gz \
    && rm sratoolkit.tar.gz \
    && ln -s /usr/local/sratoolkit/bin/* /usr/local/bin/ \    
    && apt-get clean

#ENV PATH=$PATH:/usr/local/sratoolkit.3.1.1-ubuntu64/bin
ENV PATH="/usr/local/sratoolkit.3.1.1-ubuntu64/bin:${PATH}"

CMD [ "/bin/bash" ]

