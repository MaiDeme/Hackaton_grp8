#!/bin/bash

snakemake --cores all --use-singularity
#snakemake --forceall --dag | dot -Tpdf > dag.pdf
snakemake --rulegraph | dot -Tpng -o rg.png
