cd trimming 
sudo docker build -t cutadapt-image:1.11 .
cd .. 
sudo singularity build cutadapt.sif docker-daemon://cutadapt-image:1.11

#First we install the a recent version of Singularity
#sudo -E env "PATH=$PATH" conda install -y -c conda-forge singularity=3.8.6

#export PATH=$PATH:/var/lib/miniforge/envs/snakemake/bin/singularity

#Then we build the featureCounts image
if [ ! -f featureCounts.img ]; then
    sudo -E env "PATH=$PATH" singularity build featureCounts.img Singularity.featureCounts
fi

#Finally we execute the Snakfile

snakemake --forceall --cores all --use-singularity
#snakemake --forceall --dag | dot -Tpdf > dag.pdf