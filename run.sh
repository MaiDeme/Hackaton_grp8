#!/bin/bash

# Singularity mapping image
sudo docker build -t mapping_image mapping/
sudo singularity build mapping.sif docker-daemon://mapping_image

# Singularity cutadapt image
sudo docker build -t cutadapt-image:1.11 trimming/
sudo singularity build trimming/cutadapt.sif docker-daemon://cutadapt-image:1.11

#Then we build the featureCounts image
dir=featureCounts
if [ ! -f $dir/featureCounts.img ]; then
    sudo -E env "PATH=$PATH" singularity build $dir/featureCounts.img $dir/Singularity.featureCounts
fi

#Finally we execute the Snakfile

snakemake --forceall --cores all --use-singularity
#snakemake --forceall --dag | dot -Tpdf > dag.pdf
