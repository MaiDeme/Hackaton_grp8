
#docker login puis connexion
#sudo docker build -t maximeparizot/cutadapt-image:1.11 trimming
# sudo docker tag cutadapt-image:1.11 maximeparizot/cutadapt-image:1.11.  pour taguer l'image 
# sudo docker push maximeparizot/cutadapt-image:1.11
sudo singularity build cutadapt.sif docker://maximeparizot/cutadapt-image:1.11
snakemake --forceall --use-singularity --cores all