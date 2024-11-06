cd trimming 
sudo docker build -t cutadapt-image:1.11 .
cd .. 
sudo singularity build cutadapt.sif docker-daemon://cutadapt-image:1.11
snakemake --forceall --use-singularity --cores all
cd .. 