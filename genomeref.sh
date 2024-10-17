#!/bin/bash

wget -O reference.gff "https://www.ncbi.nlm.nih.gov/sviewer/viewer.cgi?db=nuccore&report=gff3&id=CP000253.1"
wget "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=CP000253.1&rettype=fasta&retmode=text" -O full-genome.fasta

# Installing bowtie: conda install bowtie
# 

bowtie-build full-genome.fasta reference.gff