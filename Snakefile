# Define sample list 
samples = [
    "SRR10379721",
    "SRR10379722",
    "SRR10379723",
    "SRR10379724",
    "SRR10379725",
    "SRR10379726",
]

#Final output
rule all:  
    input:
        expand("counts/{sample}.txt", sample=samples),

rule download_annotation :
    input : 
        "counts"
    output : 
        "counts/gencode.gtf"
    shell:
        """ 
        wget -O counts/gencode.gtf "https://www.ncbi.nlm.nih.gov/sviewer/viewer.cgi?db=nuccore&report=gff3&id=CP000253.1"
        """ 

#Execute the featureCounts command with the parameters used in the article
rule featurecounts:
    input:
        annotation="counts/gencode.gtf",  
        bam_file="mapping/{sample}.bam"  #A changer en fonction de la partie mapping
    output:
        "counts/{sample}.txt"
    container:
        "featureCounts.img"
    shell:
        """       
        /usr/local/bin/subread-1.4.6-p3-Linux-x86_64/bin/featureCounts -p -t exon -g gene_id \
        -a {input.annotation} \
        -o {output} \
        {input.bam_file}
        """
