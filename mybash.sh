#!/bin/bash
sudo docker build -t mapping_image ./mapping/
sudo singularity build mapping.sif docker-daemon://mapping_image
snakemake --forceall --use-singularity --cores all
