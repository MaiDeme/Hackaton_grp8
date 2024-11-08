# === Defining the variables and final output ===

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

rule all:  
    input:
        expand("results/data/{sample}_fastqc.html", sample=samples),
        expand("results/trimm/{sample}_trimmed.fastq.gz", sample=samples),
        expand("results/mapping/{sample}_aligned.sam", sample=samples),
        expand("results/counts/{sample}.txt", sample=samples),

# === === === === === === === === === === === ===

# === Downloading the data  ===

rule download_fasta:
    message:
        "Telechargement de {wildcards.sample}"
    output:
        "results/data/{sample}.fastq.gz", #compressed file
    container:
        "docker://maidem/fasterq-dump"
    shell:
        """
        prefetch --progress {wildcards.sample}  -O results/data/
        fasterq-dump --progress --threads 16 {wildcards.sample} -O results/data/
        gzip results/data/{wildcards.sample}.fastq
        rm -r results/data/{wildcards.sample}
        """
# === === === === === === === === === === === ===

# === Analyzing the quality : Run fastqc for each sample  ===

rule fastqc:
    message:
        "Fastqc de {wildcards.sample}"
    input:
        "results/data/{sample}.fastq.gz"
    output:
        html="results/data/{sample}_fastqc.html",
        zip="results/data/{sample}_fastqc.zip",
    container:
        "docker://maidem/fastqc"
    shell:
        """
        fastqc {input}
        """
# === === === === === === === === === === === ===


# === Trimming: Run cutadapt for each sample  ===

rule trim:
    message:
        "Trimming de {wildcards.sample}"
    input:
        "results/data/{sample}.fastq.gz"
    output:
        "results/trimm/{sample}_trimmed.fastq.gz"
    singularity:
        "Recipes/cutadapt/cutadapt.sif" #local cutadapt image
    shell:
        """
        cutadapt -a AGATCGGAAGAGC -m 25 -o {output} {input}
        """

# === === === === === === === === === === === ===





# === ===  Index & Mapping: Run bowtie2 for each sample  === === ===

rule download_genome_fasta:
    message:
        "Telechargement du genome"
    output:
        "results/mapping/full-genome.fasta"
    shell:
        "wget -O {output} '{FASTA_URL}'"

rule indexing:
    message:
        "Indexage"
    input:
        "results/mapping/full-genome.fasta"
    output:
        "results/mapping/genome_index.tar"
    singularity:
        "Recipes/bowtie/bowtie.sif"
    shell:
        """
        bowtie2-build {input} .genome_index
        tar -cf {output} .genome_index*
        """

rule mapping:
    message:
        "Mapping de {wildcards.sample}"
    input:
        reads = "results/trimm/{sample}_trimmed.fastq.gz",
        index = "results/mapping/genome_index.tar",
    output:
        "results/mapping/{sample}_aligned.sam"
    singularity:
        "Recipes/bowtie/bowtie.sif"
    shell:
        """
        base_index={input.index.replace('.tar', '')}
        tar -xf {input.index}
        bowtie2 -x {base_index} -U {input.reads} -S {output}
        """

# === === === === === === === === === === === ===



# === ===  Counting reads expression : Run featureCounts for each sample === === ===

rule download_annotation:
    message:
        "Telechargement de annotation"
    output:
        "results/counts/gencode.gff"
    shell:
        """
        wget -O {output} '{GFF_URL}'
        """



rule featurecounts:
    message: 
        "Comptage de {wildcards.sample}"
    input:
        annotation="results/counts/gencode.gff",
        sam_file="results/mapping/{sample}_aligned.sam"
    output:
        "results/counts/{sample}.txt"
    container:
        "Recipes/featureCounts/featureCounts.img"
    shell:
        """
        /usr/local/bin/subread-1.4.6-p3-Linux-x86_64/bin/featureCounts -p -t gene -g ID -s 1 -T 16  \
        -a {input.annotation} \
        -o {output} \
        {input.sam_file}

        #T a 16 pour aller plus vite
        """


# === === === === === === === === === === === ===

