samples = [
    "GSM4145661",
    "GSM4145662",
    "GSM4145663",
    "GSM4145664",
    "GSM4145665",
    "GSM4145666",
]
rule all:  # by convention this is the expected final output
    input:
        expand("data/{sample}.fastq.gz", sample=samples),


rule create_dir:
    output:
        directory("data"),
        directory("results"),
    shell:
        "mkdir -p {output}"

rule download_fasta:
    output:
        "data/{sample}.fastq.gz",
    container:
        "docker://maidem/fasterq-dump"
    shell:
        """        
        fasterq-dump --threads 16 --progress GSE139659 -O data
        """