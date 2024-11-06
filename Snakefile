rule mapping:
    input:
	"full-genome.fasta",
        "reference.gff"
    output:
    	"genome_index"
    shell:
        "bowtie-build {input}" 
