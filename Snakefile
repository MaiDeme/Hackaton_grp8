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

rule all:  # by convention this is the expected final output (at the stage the raw data)
    input:
        #expand("data/{sample}_fastqc.html", sample=samples),
        expand("trimm/{sample}_trimmed.fastq.gz", sample=samples),
        expand("{sample}_aligned.sam", sample=samples),
        #expand("counts/{sample}.txt", sample=samples),

rule download_fasta:
    output:
        "data/{sample}.fastq.gz", #compressed file
    container:
        "docker://maidem/fasterq-dump"
    shell:
        """
        prefetch --progress {wildcards.sample}  -O data/
        fasterq-dump --progress --threads 16 {wildcards.sample} -O data/
        gzip data/{wildcards.sample}.fastq
        rm -r data/{wildcards.sample}
        """

#rule fastqc:
#    input:
#        "data/{sample}.fastq.gz"
#    output:
#        html="data/{sample}_fastqc.html",
#        zip="data/{sample}_fastqc.zip",
#    container:
#        "docker://maidem/fastqc"
#    shell:
#        """
#        fastqc data/{wildcards.sample}.fastq.gz
#        """
#

# === Trimming: Run cutadapt for each sample  ===

rule trim:
    input:
        "data/{sample}.fastq.gz"
    output:
        "trimm/{sample}_trimmed.fastq.gz"
    singularity:
        "trimming/cutadapt.sif" #local cutadapt image 
    shell:
        """
        cutadapt -a AGATCGGAAGAGC -m 25 -o {output} {input}
        """

# === === === === === === === === === === === ===


# === ===  Download genome annotation === === ===

rule download_annotation:
    output: 
        "counts/gencode.gff"
    shell:
        """ 
        wget -O {output} '{GFF_URL}'
        """

# === === === === === === === === === === === ===


# === ===  Index & Mapping: bowtie2   === === ===

rule download_genome_fasta:
  output:
    "full-genome.fasta"
  shell:
    "wget -O {output} '{FASTA_URL}'"

rule indexing:
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

rule mapping:
  input:
    reads = "trimm/{sample}_trimmed.fastq.gz",
    index = "genome_index.tar"
  output:
    "{sample}_aligned.sam"
  singularity:
    "mapping.sif"
  shell:
    """
    tar -xf {input.index}
    bowtie2 -x {input.index.replace('.tar', '')} -U {input.reads} -S {output}
    """

# === === === === === === === === === === === ===

#Execute the featureCounts command with the parameters used in the article
#rule featurecounts:
#    input:
#        annotation="counts/gencode.gff",  
#        bam_file="mapping/{sample}.bam"  #A changer en fonction de la partie mapping
#    output:
#        "counts/{sample}.txt"
#    container:
#        "featureCounts/featureCounts.img"
#    shell:
#        """       
#        /usr/local/bin/subread-1.4.6-p3-Linux-x86_64/bin/featureCounts -p -t exon -g gene_id \
#        -a {input.annotation} \
#        -o {output} \
#        {input.bam_file}
#        """
#

