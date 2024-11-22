# === === === === DESeq2 === === === === === ===
rule DESeq2:
  output:
    "results/DESeq2/DESeq2_results.txt"
  container:
    "docker://maidem/deseq2:latest"
  shell:
    """
    Rscript DESeq2.R 
    """
# === === === === === === === === === === === ===
