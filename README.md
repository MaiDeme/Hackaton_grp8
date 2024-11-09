## ReproHackathon 2024

This is a repository for the project of the course "ReproHackathon". The goal of this project is to create a reproducible workflow for the analysis of RNA-seq data. The workflow will be implemented using the Snakemake workflow management system. The workflow include the following steps:

1. Retrieving the raw data using fasterq-dump from sratoolkit 3.1.1
2. Quality control using FastQC 0.12.1
3. Trimming using cutadapt 1.11
4. Mapping using Bowtie 
5. Counting using featureCounts from subread 1.4.6-p3

In the `main` branch, you will find the final version of the workflow.
Use the following command to run the workflow:

```
./run.sh
```
Each folder contains images created individually by different contributors, each in a separate branch to streamline creation and testing
