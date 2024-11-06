# Run snakemake with local containers
snakemake --forceall --cores all --use-singularity
#snakemake --forceall --dag | dot -Tpdf > dag.pdf
