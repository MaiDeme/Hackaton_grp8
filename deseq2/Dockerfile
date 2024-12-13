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
    libssl-dev \
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
    && make -j$(nproc)\
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
    && Rscript -e 'install.packages(c("car", "ellipse", "flashClust", "leaps", "scatterplot3d","ggpubr","ggrepel","abind"), repos="https://packagemanager.posit.co/cran/2017-10-10")' \
    && Rscript -e 'install.packages("https://cran.r-project.org/src/contrib/Archive/FactoMineR/FactoMineR_1.36.tar.gz", repos=NULL)' \
    && Rscript -e 'install.packages("https://cran.r-project.org/src/contrib/Archive/XML/XML_3.98-1.1.tar.gz",repos=NULL)' \
    && Rscript -e 'library(BiocInstaller);options(repos = c(CRAN = "https://packagemanager.posit.co/cran/2017-10-10"));biocLite(c("DESeq2","EnrichmentBrowser"), ask=FALSE, suppressUpdates=TRUE, suppressAutoUpdate=TRUE, dependencies=TRUE, type="source")'

RUN Rscript -e 'install.packages("https://cran.r-project.org/src/contrib/Archive/factoextra/factoextra_1.0.5.tar.gz", repos=NULL)'
CMD [ "R" ]