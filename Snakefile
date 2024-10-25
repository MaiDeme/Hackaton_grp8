# Define sample list 
samples = [
    "SRR10379721",
    "SRR10379722",
    "SRR10379723",
    "SRR10379724",
    "SRR10379725",
    "SRR10379726",
]

rule all:
    input:
        expand("trimm/{sample}_trimmed.fastq.gz", sample=samples)

# Run cutadapt for each sample 
rule trim:
    input:
        "data/{sample}.fastq.gz"
    output:
        "trimm/{sample}_trimmed.fastq.gz"
    shell:
        """
        cutadapt -a AGATCGGAAGAGC -o {output} {input}
        """

# Create trimm directory if it doesn't exist 
rule create_output_dir:
    output:
        directory("trimm/")
    run:
        import os
        os.makedirs("trimm/", exist_ok=True)
