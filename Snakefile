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
        expand("data/{sample}.fastq", sample=samples),


rule create_dir:
    output:
        directory("data"),
        directory("results"),
    shell:
        """
        for dir in {outputs}; do
            mkdir -p $dir
        done
        """

rule download_fasta:
    output:
        "{sample}.fastq",
    container:
        "docker://maidem/fasterq-dump"
    shell:
        """ 
        cd data/ &&       
        /usr/local/sratoolkit.3.1.1-ubuntu64/bin/fasterq-dump --threads 16 {wildcards.sample} -O data
        """