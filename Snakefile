rule all:
  input:
    "genome_index.bt2"

rule mapping:
  input:
    "full-genome.fasta",
    "reference.gff"
  output:
    "genome_index.bt2"
  shell:
    "bowtie-build {input}" 
