#!/bin/bash

#No need to build fasterqdump and fastqc images, it imports them from DockerHub

# Singularity bowtie image
sudo docker build -t bowtie_image:latest Recipes/bowtie/
docker save -o Recipes/bowtie/bowtie_image.tar bowtie_image:latest 
sudo -E env "PATH=$PATH" singularity build Recipes/bowtie/bowtie.sif docker-archive://Recipes/bowtie/bowtie_image.tar



# Singularity cutadapt image
sudo docker build -t cutadapt-image:1.11 Recipes/cutadapt/
docker save -o Recipes/cutadapt/cutadapt-image.tar cutadapt-image:1.11
sudo -E env "PATH=$PATH" singularity build Recipes/cutadapt/cutadapt.sif docker-archive://Recipes/cutadapt/cutadapt-image.tar

# Singularity featureCounts image

sudo -E env "PATH=$PATH" singularity build featureCounts/featureCounts.img Recipes/featureCounts/Singularity.featureCounts



#Executing the Snakefile

snakemake --forceall --cores all --use-singularity --rerun-incomplete
#snakemake --forceall --dag | dot -Tpdf > dag.pdf
