# Run snakemake with local containers
snakemake --forceall --use-singularity --cores all
#snakemake --forceall --dag | dot -Tpdf > dag.pdf
