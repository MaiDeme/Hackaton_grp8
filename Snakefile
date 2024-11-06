GFF_URL = "https://www.ncbi.nlm.nih.gov/sviewer/viewer.cgi?db=nuccore&report=gff3&id=CP000253.1"
FASTA_URL = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=CP000253.1&rettype=fasta&retmode=text"

rule all:
  input:
    "genome_index.bt2"

rule download_gff:
  output:
    "reference.gff"
  shell:
    "wget -O {output} '{GFF_URL}'"

rule download_fasta:
  output:
    "full-genome.fasta"
  shell:
    "wget -O {output} '{FASTA_URL}'"

rule mapping:
  input:
    "full-genome.fasta",
    "reference.gff"
  output:
    "genome_index.bt2"
  shell:
    "bowtie-build {input}" 
