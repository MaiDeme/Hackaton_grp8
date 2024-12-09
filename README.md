## ReproHackathon 2024

This is a repository for the project of the course "ReproHackathon" (Project report : https://docs.google.com/document/d/1_xx_bITZrKBWvEZ71qsTfWxVgI6EPCRxSXAjsIBsN-g/edit?usp=sharing). 

The goal of this project is to create a reproducible workflow for the analysis of RNA-seq data. The workflow will be implemented using the Snakemake workflow management system. The workflow include the following steps:

1. Retrieving the raw data using fasterq-dump from sratoolkit 3.1.1
2. Quality control using FastQC 0.12.1
3. Trimming using cutadapt 1.11
4. Mapping using Bowtie 2.5.4
5. Counting using featureCounts from subread 1.4.6-p3
6. Differential analysis with DESeq2 1.16.1 on R 3.4.1

In the `main` branch, you will find the final version of the workflow.
In the `results` branch, you will find, graphs plots and additional files.
Use the following command to run the workflow:

```
./run.sh
```
Each folder contains images created individually by different contributors, each in a separate branch to streamline creation and testing
