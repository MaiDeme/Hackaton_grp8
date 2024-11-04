mkdir ./mapping

wget -O ./mapping/test1.bam http://hgdownload.cse.ucsc.edu/goldenPath/hg19/encodeDCC/wgEncodeUwRepliSeq/wgEncodeUwRepliSeqBjG1bAlnRep1.bam
wget -O ./mapping/test2.bam https://hgdownload-test.gi.ucsc.edu/goldenPath/hg19/encodeDCC/wgEncodeUwRepliSeq/wgEncodeUwRepliSeqBg02esS4AlnRep1.bam

wget -O ./mapping/gencode.gtf.gz ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_24/GRCh37_mapping/gencode.v24lift37.basic.annotation.gtf.gz

gunzip ./mapping/*.gz
