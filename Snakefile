# Define sample list 
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
        expand("counts/{sample}.txt", sample=samples),


# Create counts directory if it doesn't exist 
rule create_counts_dir:
    output:
        directory("counts/")
    run:
        import os
        os.makedirs("counts/", exist_ok=True)

#Execute the featureCounts command with the parameters used in the article
rule featurecounts:
    input:
        counts_dir="counts" ,
        annotation="mapping/gencode.gtf",
        bam_file="mapping/sample.bam"
    output:
        "counts/{sample}.txt"
    container:
        "featurecounts.img"
    shell:
        """       
        /opt/subread-1.4.6-p3-Linux-x86_64/bin/featureCounts -p -t exon -g gene_id _
        -a {input.annotation} \
        -o {output} \
        {input.bam_file}
        """