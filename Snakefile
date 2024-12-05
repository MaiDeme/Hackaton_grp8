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
BOWTIE_IMAGE_URL = "https://zenodo.org/records/14204426/files/bowtie.sif?download=1"
FEATURES_COUNTS_IMAGE_URL = "https://zenodo.org/records/14229723/files/featureCounts.sif?download=1"

rule all:  # by convention this is the expected final output 
  input:
    expand("results/fastqc/{sample}_fastqc.html", sample=samples),
    expand("results/2fastqc/{sample}_trimmed_fastqc.html", sample=samples),
    expand("results/counts/{sample}.txt", sample=samples),
    "results/DESeq2/DESeq2_results.txt"

# === === === === Downloading data  === === ===
rule download_fasta:
  output:
    "results/data/{sample}.fastq.gz",
  container:
    "docker://maidem/fasterq-dump:latest"
  shell:
    # prefetch is used to download the data from SRA
    # then fasterq-dump is used to convert the data to fastq
    """
    prefetch --progress {wildcards.sample}  -O results/data/    
    fasterq-dump --progress --threads 16 {wildcards.sample} -O results/data/
    gzip results/data/{wildcards.sample}.fastq
    rm -r results/data/{wildcards.sample}
    """

# === === === === === === === === === === === ===

# === === === === Fastqc  === === === === === ===

rule fastqc:
  input:
    "results/data/{sample}.fastq.gz"
  output:
    html="results/fastqc/{sample}_fastqc.html",
    zip="results/fastqc/{sample}_fastqc.zip",
  container:
    "docker://maidem/fastqc:latest"
  shell:
    """
    fastqc {input} -O results/fastqc/
    """

# === === === === === === === === === === === ===

# === Trimming: Run cutadapt for each sample  ===

rule trim:
  input:
    "results/data/{sample}.fastq.gz"
  output:
    "results/trimm/{sample}_trimmed.fastq.gz"
  log:
    "results/trimm/{sample}_trimmed.log"
  container:
    "docker://maximeparizot/cutadapt-image:1.11"
  shell:
    """
    cutadapt -a AGATCGGAAGAGC -m 25 -o {output} {input} > {log}
    """
# === === === === === === === === === === === ===


# === === Fastqc after trimming === === === === ===

rule second_fastqc:
  input:
    "results/trimm/{sample}_trimmed.fastq.gz"
  output:
    html="results/2fastqc/{sample}_trimmed_fastqc.html",
    zip="results/2fastqc/{sample}_trimmed_fastqc.zip",
  container:
    "docker://maidem/fastqc:latest"
  shell:
    """
    fastqc {input} -O results/2fastqc/
    """

# === === === === === === === === === === === ===

# === ===  Index & Mapping: bowtie2   === === ===


rule download_genome_fasta:
  output:
    "results/mapping/full-genome.fasta"
  shell:
    "wget -O {output} '{FASTA_URL}'"

rule indexing:
  input:
    fasta = "results/mapping/full-genome.fasta",
  output:
    "results/mapping/genome_index.tar"
  container:
    BOWTIE_IMAGE_URL
  shell:
    """
    rm -f .genome_index*
    bowtie-build {input.fasta} .genome_index
    tar -cf {output} .genome_index* --remove-files
    """

rule mapping:
  input:
    reads = "results/trimm/{sample}_trimmed.fastq.gz",
    index = "results/mapping/genome_index.tar",
  output:
    "results/mapping/{sample}_aligned.sam"
  container:
    BOWTIE_IMAGE_URL
  shell:
    """
    base_index=$(basename {input.index} .tar)
    tar -xf {input.index} -C results/mapping 
    bowtie -q -S results/mapping/.$base_index {input.reads} > {output}
    """
# === === === === === === === === === === === ===

# === ===  Compression of .sam into .bam === === ===
rule convert_bam:
  input:
    sam_file="results/mapping/{sample}_aligned.sam"
  output:
    "results/mapping/{sample}_aligned.bam"
  container:
    "docker://maidem/samtools:1.9"
  shell:
    """
    samtools view -bS {input.sam_file} > {output}
    rm -f {input.sam_file}
    """
# === === === === === === === === === === === ===

# === ===  Download genome annotation === === ===

rule download_annotation:
  output: 
    "results/counts/gencode.gff"
  shell:
    """ 
    wget -O {output} '{GFF_URL}'
    """

# === === === === === === === === === === === ===


# == Counting reads expression: featureCounts ===

# Règle pour Compter les reads mappes sur le genome de reference
rule featurecounts:
  input:
    annotation="results/counts/gencode.gff",  
    bam_file="results/mapping/{sample}_aligned.bam"
  output:
    "results/counts/raw_{sample}.txt"
  container:
    FEATURES_COUNTS_IMAGE_URL
  shell:
    """       
    /usr/local/bin/subread-1.4.6-p3-Linux-x86_64/bin/featureCounts -p -t gene -g ID -T 16 -s 1\
    -a {input.annotation} \
    -o {output} \
    {input.bam_file}
    """

# Règle pour formater et trier les fichiers individuels
rule format_and_sort:
    input:
        "results/counts/raw_{sample}.txt"
    output:
        "results/counts/Count_table_{sample}.txt"
        
    shell:
        """
        
        awk '{{print $1 " " $7}}' {input} > {output}

        sed -i '1,2d' {output}

        echo -e "geneid {wildcards.sample}" > results/counts/temp_file{wildcards.sample}
        cat {output} >> results/counts/temp_file{wildcards.sample}

        mv results/counts/temp_file{wildcards.sample} {output}

        sed -i 's/ \\+/\\t/g' {output}
        sort -k1,1 -t $'\\t' {output} -o {output}
        """


# Règle pour joindre les fichiers et supprimer les fichiers temporaires
rule join_tables:
    input:
        expand("results/counts/Count_table_{sample}.txt", sample=samples)
    output:
        "results/counts/Combined_table.txt"
    params:
        # Créer une chaîne d'échantillons pour la boucle
        samples=" ".join(samples[1:])
    shell:
        """
        # Copier le premier fichier vers le fichier de sortie
        cp {input[0]} {output}

        rm {input[0]}

        # Boucle sur les échantillons à partir du second
        for sample in {params.samples}; do
            # Afficher l'échantillon pour débogage
            echo $sample

            # Joindre les fichiers avec `join`
            join -1 1 -2 1 -t $'\\t' -a 1 -a 2 {output} results/counts/Count_table_$sample.txt > results/counts/temp_file

            # Déplacer le fichier temporaire vers le fichier de sortie final
            mv results/counts/temp_file {output}

            #Supprimmer le fichier de compte temporaire
            rm results/counts/Count_table_$sample.txt
        done
        """



# === === === === === === === === === === === ===

# === === === === DESeq2 === === === === === ===
rule DESeq2:
  input:
    "results/counts/Combined_table.txt"
  output:
    "results/DESeq2/DESeq2_results.txt"
  container:
    "docker://maidem/deseq2:latest"
  script:
    "DESeq2.R"

# === === === === === === === === === === === ===
