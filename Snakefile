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
        expand("trimm/{sample}_trimmed.fastq.gz", sample=samples),
        #expand("counts/{sample}.txt", sample=samples),

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
#
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
#Run cutadapt for each sample 
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

# Download annotation
rule download_annotation:
    output: 
        "counts/gencode.gtf"
    shell:
        """ 
        wget -O counts/gencode.gtf 'https://www.ncbi.nlm.nih.gov/sviewer/viewer.cgi?db=nuccore&report=gff3&id=CP000253.1'
        """


#######################
### TITOUAN ####
## Met tes rules ici
#######################

#Execute the featureCounts command with the parameters used in the article
#rule featurecounts:
#    input:
#        annotation="counts/gencode.gtf",  
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


