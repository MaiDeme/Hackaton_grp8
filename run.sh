#!/bin/bash 

conda activate snakemake
conda install -y singularity

export PATH=$PATH:/var/lib/miniforge/envs/snakemake/bin/singularity

if [ ! -f featureCounts.img ]; then
    sudo -E env "PATH=$PATH" singularity build featureCounts.img Singularity.featureCounts
fi


snakemake -s Snakefile --forceall --use-singularity --cores all

