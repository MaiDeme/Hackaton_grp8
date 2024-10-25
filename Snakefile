samples = [
    "SRR10379721",
    "SRR10379722",
    "SRR10379723",
    "SRR10379724",
    "SRR10379725",
    "SRR10379726",
]
rule all:  # by convention this is the expected final output
    input:
        expand("data/{sample}_fastqc.html", sample=samples),


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
