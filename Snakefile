samples = [
    "SRR10379721",
    "SRR10379722",
   # "SRR10379723",
   # "SRR10379724",
   # "SRR10379725",
   # "SRR10379726",
]

FASTA_URL = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=CP000253.1&rettype=fasta&retmode=text"
GFF_URL = "https://www.ncbi.nlm.nih.gov/sviewer/viewer.cgi?db=nuccore&report=gff3&id=CP000253.1"

rule all:  # by convention this is the expected final output (at the stage the raw data)
    input:
        expand("results/data/{sample}_fastqc.html", sample=samples),
        expand("results/trimm/{sample}_trimmed.fastq.gz", sample=samples),
        expand("results/mapping/{sample}_aligned.sam", sample=samples),
        expand("results/counts/{sample}.txt", sample=samples),

rule download_fasta:
    output:
        "results/data/{sample}.fastq.gz", #compressed file
    container:
        "docker://maidem/fasterq-dump"
    shell:
        """
        prefetch --progress {wildcards.sample}  -O data/
        fasterq-dump --progress --threads 16 {wildcards.sample} -O results/data/
        gzip results/data/{wildcards.sample}.fastq
        rm -r results/data/{wildcards.sample}
        """

rule fastqc:
    input:
        "results/data/{sample}.fastq.gz"
    output:
        html="results/data/{sample}_fastqc.html",
        zip="results/data/{sample}_fastqc.zip",
    container:
        "docker://maidem/fastqc"
    shell:
        """
        fastqc results/data/{wildcards.sample}.fastq.gz
        """


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
    "mapping/mapping.sif"
  shell:
    """
    bowtie2-build {input} .genome_index
    tar -cf genome_index.tar .genome_index*
    """

rule mapping:
  input:
    reads = "results/trimm/{sample}_trimmed.fastq.gz",
    index = "results/mapping/genome_index.tar",
  output:
    "results/mapping/{sample}_aligned.sam"
  singularity:
    "mapping.sif"
  shell:
    """
    base_index={input.index.replace('.tar', '')}
    tar -xf {input.index}
    bowtie2 -x {base_index} -U {input.reads} -S {output}
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

# === ===  Counting reads expression : featureCounts === === ===

rule featurecounts:
    input:
        annotation="results/counts/gencode.gff",  
        sam_file="results/mapping/{sample}_aligned.sam"  #A changer en fonction de la partie mapping
    output:
        "results/counts/{sample}.txt"
    container:
        "featureCounts/featureCounts.img"
    shell:
        """       
        /usr/local/bin/subread-1.4.6-p3-Linux-x86_64/bin/featureCounts -p -t exon -g gene_id \
        -a {input.annotation} \
        -o {output} \
        {input.sam_file}
        """


# === === === === === === === === === === === ===

