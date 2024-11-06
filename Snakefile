# Define sample list 
samples = [
    "SRR10379721",
    "SRR10379722",
    "SRR10379723",
    "SRR10379724",
    "SRR10379725",
    "SRR10379726",
]

rule all:  # by convention this is the expected final output (at the stage the raw data)
    input:
        expand("data/{sample}_fastqc.html", sample=samples),
        expand("trimm/{sample}_trimmed.fastq.gz", sample=samples)

#rule download_fasta:
#    output:
#        "data/{sample}.fastq.gz", #compressed file
#    container:
#        "docker://maidem/fasterq-dump"
#    shell:
#        """
#        prefetch --progress {wildcards.sample}  -O data/
#        fasterq-dump --progress --threads 16 {wildcards.sample} -O data/
#        gzip data/{wildcards.sample}.fastq
#        rm -r data/{wildcards.sample}
#        """
        

rule fastqc:
    input:
        "data/{sample}.fastq.gz"
    output:
        html="data/{sample}_fastqc.html",
        zip="data/{sample}_fastqc.zip"
    container:
        "docker://maidem/fastqc"
    shell:
        """
        fastqc data/{wildcards.sample}.fastq.gz
        """


# Run cutadapt for each sample 
rule trim:
    input:
        "data/{sample}.fastq.gz"
    output:
        "trimm/{sample}_trimmed.fastq.gz"
    #use cutadapt image 
    singularity:
        "cutadapt.sif" 
    shell:
        """
        cutadapt -a AGATCGGAAGAGC -o {output} {input}
        """
