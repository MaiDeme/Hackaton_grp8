# Définition de la liste des échantillons
samples = [
    "SRR10379721",
    "SRR10379722",
    "SRR10379723",
    "SRR10379724",
    "SRR10379725",
    "SRR10379726",
]

# Règle cible pour générer les fichiers de sortie pour tous les échantillons
rule all:
    input:
        expand("trimm/{sample}_trimmed.fastq.gz", sample=samples)

# Règle pour appliquer Cutadapt à chaque échantillon
rule trim:
    input:
        "data/{sample}.fastq.gz"
    output:
        "trimm/{sample}_trimmed.fastq.gz"
    shell:
        """
        cutadapt -a AGATCGGAAGAGC -o {output} {input}
        """

# Règle pour créer le dossier de sortie s'il n'existe pas
rule create_output_dir:
    output:
        directory("trimm/")
    run:
        import os
        os.makedirs("trimm/", exist_ok=True)
