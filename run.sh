#!/bin/bash 


#First we install the a recent version of Singularity
sudo -E env "PATH=$PATH" conda install -y -c conda-forge singularity=3.8.6

#export PATH=$PATH:/var/lib/miniforge/envs/snakemake/bin/singularity

#Then we build the featureCounts image
if [ ! -f featureCounts.img ]; then
    sudo -E env "PATH=$PATH" singularity build featureCounts.img Singularity.featureCounts
fi


#Finally we execute the Snakfile
snakemake -s Snakefile --forceall --use-singularity --cores all








