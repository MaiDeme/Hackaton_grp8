# Définir les fichiers d'entrée
input_dir = "fastq-exemple/"
R1_file = f"{input_dir}R1.fastq"
R2_file = f"{input_dir}R2.fastq"

rule all:
    input:
        "trimm/R1_trimmed.fastq",
        "trimm/R2_trimmed.fastq"

rule trim:
    input:
        R1=R1_file,
        R2=R2_file
    output:
        R1_trimmed="trimm/R1_trimmed.fastq",
        R2_trimmed="trimm/R2_trimmed.fastq"
    threads: 4  # Nombre de threads à utiliser
    singularity:
        "cutadapt.sif" 
    shell:
        """
        
        cutadapt -a AGATCGGAAGAGC -o {output.R1_trimmed} {input.R1}
        cutadapt -a AGATCGGAAGAGC -o {output.R2_trimmed} {input.R2}
        """

# Règle pour créer le dossier de sortie s'il n'existe pas
rule create_output_dir:
    output:
        directory("trimm/")
    run:
        import os
        os.makedirs("trimm/", exist_ok=True)
