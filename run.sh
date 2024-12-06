snakemake --cores all --use-singularity
snakemake --rulegraph | dot -Tpng > rulegraph.png
