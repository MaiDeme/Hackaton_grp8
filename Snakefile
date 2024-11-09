samples = [
  "SRR10379721",
  "SRR10379722",
  "SRR10379723",
  "SRR10379724",
  "SRR10379725",
  "SRR10379726",
]

FASTA_URL = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=CP000253.1&rettype=fasta&retmode=text"
GFF_URL = "https://www.ncbi.nlm.nih.gov/sviewer/viewer.cgi?db=nuccore&report=gff3&id=CP000253.1"

rule all:  # by convention this is the expected final output 
  input:
    expand("results/fastqc/{sample}_fastqc.html", sample=samples),
    expand("results/counts/{sample}.txt", sample=samples),

# === === === === Downloading data  === === ===

rule download_fasta:
  output:
    "results/data/{sample}.fastq.gz",
  container:
    "docker://maidem/fasterq-dump:latest"
  shell:
    # prefetch is used to download the data from SRA
    # then fasterq-dump is used to convert the data to fastq
    """
    prefetch --progress {wildcards.sample}  -O results/data/    
    fasterq-dump --progress --threads 16 {wildcards.sample} -O results/data/
    gzip results/data/{wildcards.sample}.fastq
    rm -r results/data/{wildcards.sample}
    """

# === === === === === === === === === === === ===



# === === === === Fastqc  === === === === === ===

rule fastqc:
  input:
    "results/data/{sample}.fastq.gz"
  output:
    html="results/fastqc/{sample}_fastqc.html",
    zip="results/fastqc/{sample}_fastqc.zip",
  container:
    "docker://maidem/fastqc:latest"
  shell:
    """
    fastqc results/data/{wildcards.sample}.fastq.gz
    """

# === === === === === === === === === === === ===



# === Trimming: Run cutadapt for each sample  ===

rule trim:
  input:
    "results/data/{sample}.fastq.gz"
  output:
    "results/trimm/{sample}_trimmed.fastq.gz"
  singularity:
    "trimming/cutadapt.sif" #local cutadapt image 
  shell:
    """
    cutadapt -a AGATCGGAAGAGC -m 25 -o {output} {input}
    """
# === === === === === === === === === === === ===


# === === Fastqc after trimming === === === === ===

rule second_fastqc:
  input:
    "results/trimm/{sample}_trimmed.fastq.gz"
  output:
    html="results/2fastqc/{sample}_fastqc.html",
    zip="results/2fastqc/{sample}_fastqc.zip",
  container:
    "docker://maidem/fastqc:latest"
  shell:
    """
    fastqc results/trimm/{wildcards.sample}_trimmed.fastq.gz
    """

# === === === === === === === === === === === ===



# === ===  Index & Mapping: bowtie2   === === ===

rule download_genome_fasta:
  output:
    "results/mapping/full-genome.fasta"
  shell:
    "wget -O {output} '{FASTA_URL}'"

rule indexing:
  input:
    "results/mapping/full-genome.fasta"
  output:
    "results/mapping/genome_index.tar"
  singularity:
    "bowtie/bowtie.sif"
  shell:
    """
    bowtie2-build {input} .genome_index
    tar -cf {output} .genome_index* --remove-files
    """

rule mapping:
  input:
    reads = "results/trimm/{sample}_trimmed.fastq.gz",
    index = "results/mapping/genome_index.tar",
  output:
    "results/mapping/{sample}_aligned.sam"
  singularity:
    "bowtie/bowtie.sif"
  shell:
    """
    base_index=$(basename {input.index} .tar)
    tar -xf {input.index} -C results/mapping 
    bowtie2 -x results/mapping/.$base_index -U {input.reads} -S {output}
    """

# === === === === === === === === === === === ===



# === ===  Download genome annotation === === ===

rule download_annotation:
  output: 
    "results/counts/gencode.gff"
  shell:
    """ 
    wget -O {output} '{GFF_URL}'
    """

# === === === === === === === === === === === ===



# == Counting reads expression: featureCounts ===

rule featurecounts:
  input:
    annotation="results/counts/gencode.gff",  
    sam_file="results/mapping/{sample}_aligned.sam"
  output:
    "results/counts/{sample}.txt"
  container:
    "featureCounts/featureCounts.img"
  shell:
    """       
    /usr/local/bin/subread-1.4.6-p3-Linux-x86_64/bin/featureCounts -p -t gene -g ID -T 16 -s 1\
    -a {input.annotation} \
    -o {output} \
    {input.sam_file}
    """

# === === === === === === === === === === === ===

