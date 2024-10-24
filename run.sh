conda activate snakemake
conda install -y singularity

export PATH=$PATH:/var/lib/miniforge/envs/snakemake/bin/singularity

sudo -E env "PATH=$PATH" singularity build featureCounts.img Singularity.featureCounts
sudo -E env "PATH=$PATH" singularity featureCounts.img --help


