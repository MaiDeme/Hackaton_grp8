FROM ubuntu:22.04

RUN apt-get update && apt-get install --fix-missing wget -y  \
    && cd /opt/ \
    && wget -O reference.gff "https://www.ncbi.nlm.nih.gov/sviewer/viewer.cgi?db=nuccore&report=gff3&id=CP000253.1" \
    && wget -O full-genome.fasta "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=CP000253.1&rettype=fasta&retmode=text"
