# Necessitate bowtie2: sudo apt-get install bowtie2
FASTA_URL = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=CP000253.1&rettype=fasta&retmode=text"

rule all:
  input:
    "genome_index.tar"

rule download_fasta:
  output:
    "full-genome.fasta"
  shell:
    "wget -O {output} '{FASTA_URL}'"

rule mapping:
  input:
    "full-genome.fasta"
  output:
    "genome_index.tar"
  singularity:
    "mapping.sif"
  shell:
    """
    bowtie2-build {input} .genome_index
    tar -cf genome_index.tar .genome_index*
    """
