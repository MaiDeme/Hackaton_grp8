################################################################################
### Preparation des donnees et des parametres
################################################################################

rm(list=objects())
graphics.off()
set.seed(12345)

library(DESeq2)



dir = "/home/marmotte/Documents/Université/Master BIBS/M2AMI2B/ReproHackathon/Hackaton_grp8/"
setwd(dir)


counts = read.table("results/counts/Combined_table.txt", header = T, row.names = 1)
#On a le bon nombre de gènes 


################################################################################
####DESeq2
################################################################################

#Vecteur de condition : Antibio ou pas 
#O : controle : pas antibio
#1 : Antibio 
#3 Replicats pour chacun 
help("DESeq2")
cond <- factor(rep(0:1, each=3))
head(cond)

#Parametres par defaut sont utilises dans l article et ajustement des pvalues automatique
dds <- DESeqDataSetFromMatrix(counts, DataFrame(cond), ~ cond)
dds <- DESeq(dds)  
res <- results(dds, test = "Wald")

pvalues = res$padj


genes_diff = dim(counts[which(pvalues<0.05),])[1]
genes_up = dim(counts[which(pvalues<0.05 & res$log2FoldChange>0),])[1]
genes_down = dim(counts[which(pvalues<0.05 & res$log2FoldChange<0),])[1]
# On remarque qu'on a 1484 genes significatifs
genes_up + genes_down
#Normalement : 1477 avec 710 up et 767 down 

################################################################################
####MA plots
################################################################################

signi = pvalues<0.05



y = res$log2FoldChange
x = log2(apply(X = counts, MARGIN = 1, FUN = mean))

ggplot(mapping = aes(x = x, 
                     y = y, 
                     color = ifelse(!is.na(pvalues) & pvalues > 0.05, "Non Significatif", "Significatif"))) +
  geom_point(size = 0.85) +
  scale_color_manual(values = c("Non Significatif" = "black", "Significatif" = "red"),
                     name = NULL) +
  geom_line(mapping = aes(x = x, y = 0), color = "black", linetype = "dashed") +
  xlab("Log2 Base Mean")+
  ylab("Log2 fold change")


################################################################################
#### Verif version
################################################################################

info = sessionInfo()


writeLines(paste("Hello world\n R version : ", info$R.version$version.string,
                 "\n DefSeq version : ", info$otherPkgs$DESeq2$Version),
           con='results/DESeq2/DESeq2_results.txt')
