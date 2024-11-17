FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends\
    wget \
    build-essential \
    ca-certificates \
    gfortran \
    libblas-dev \
    libbz2-1.0 \
    libcurl4 \
    libjpeg-dev \
    libopenblas-dev \
    libpcre3 \
    libpng16-16 \
    libreadline7 \
    libtiff5 \
    liblzma5 \
    libxml2-dev \
    zlib1g
# Source Repositories
RUN sed -i.bak "/^#.*deb-src.*universe$/s/^# //g" /etc/apt/sources.list \
    && apt-get update && apt-get build-dep -y r-base

# Download and install R
RUN wget -O R-3.4.1.tar.gz https://cran.rstudio.com/src/base/R-3/R-3.4.1.tar.gz \
    && tar -xvf R-3.4.1.tar.gz \
    && cd R-3.4.1 \
    && ./configure \
        --prefix=/opt/R/3.4.1 \
        --with-blas \
        --with-lapack \
    && make \
    && make install\
    && cd ..\
    && rm -rf R-3.4.1*

RUN cd / \ 
    && rm -rf /tmp/* \
    && apt-get autoremove -y \
    && apt-get autoclean -y \
    && rm -rf /var/lib/apt/lists/*

ENV PATH="/opt/R/3.4.1/bin:${PATH}"
RUN wget https://bioconductor.org/packages/3.5/bioc/src/contrib/BiocInstaller_1.26.1.tar.gz \
    && R CMD INSTALL BiocInstaller_1.26.1.tar.gz \
    && Rscript -e 'install.packages("https://cran.r-project.org/src/contrib/Archive/XML/XML_3.98-1.1.tar.gz",repos=NULL)' \
    && Rscript -e 'library(BiocInstaller);options(repos = c(CRAN = "https://packagemanager.posit.co/cran/2017-10-10"));biocLite("DESeq2", ask=FALSE, suppressUpdates=TRUE, suppressAutoUpdate=TRUE, dependencies=TRUE, type="source")'
CMD [ "R" ]