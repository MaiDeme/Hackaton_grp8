#!/bin/bash

# Singularity cutadapt image
sudo docker build -t cutadapt-image:1.11 trimming/
sudo singularity build --force trimming/cutadapt.sif docker-daemon://cutadapt-image:1.11

#Then we build the featureCounts image
dir=featureCounts
if [ ! -f $dir/featureCounts.img ]; then
    sudo -E env "PATH=$PATH" singularity build $dir/featureCounts.img $dir/Singularity.featureCounts
fi

#Finally we execute the Snakfile

snakemake --cores all --use-singularity
#snakemake --forceall --dag | dot -Tpdf > dag.pdf
snakemake --rulegraph | dot -Tpng -o rg.png
