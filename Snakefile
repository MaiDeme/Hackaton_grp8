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
        expand("data/{sample}.fastq.gz", sample=samples),


rule download_fasta:
    output:
        "data/{sample}.fastq.gz", #compressed file
    container:
        "docker://maidem/fasterq-dump"
    shell:
        """
        /usr/local/sratoolkit.3.1.1-ubuntu64/bin/prefetch --progress {wildcards.sample}  -O data/
        /usr/local/sratoolkit.3.1.1-ubuntu64/bin/fasterq-dump --progress --threads 16 {wildcards.sample} -O data/
        gzip data/{wildcards.sample}.fastq
        rm -r data/{wildcards.sample}
        """

