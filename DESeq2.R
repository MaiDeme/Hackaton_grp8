################################################################################
### Preparation des donnees et des parametres
################################################################################

rm(list=objects())
graphics.off()
set.seed(12345)

library(DESeq2)
library(ggplot2)
library(EnrichmentBrowser)

args <- commandArgs(trailingOnly = TRUE)


dir = args[1]
print(dir)
setwd(dir)


counts = read.table("./results/counts/Combined_table.txt", header = T, row.names = 1)
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

pdf(pasteo(dir,"/results/Figures/MA_plot_all.pdf"), width = 7, height = 5)

# Centrer y autour de sa moyenne
y <- res$log2FoldChange
y <- y - mean(y, na.rm = TRUE)

boxplot(y)

x = apply(X = counts, MARGIN = 1, FUN = mean)
x2 = log2(apply(X = counts, MARGIN = 1, FUN = mean))

ggplot(mapping = aes(x = x, 
                     y = y, 
                     color = ifelse(!is.na(pvalues) & pvalues > 0.05, "Non Significatif", "Significatif"))) +
  geom_point(size = 1) +
  scale_color_manual(values = c("Non Significatif" = "black", "Significatif" = "red"),
                     name = NULL) +
  scale_x_log10(
    breaks = scales::trans_breaks("log10", function(x) 10^x),
    labels = scales::trans_format("log10", scales::math_format(10^.x))
  ) +
  geom_line(mapping = aes(x = x, y = 0), color = "black", linetype = "dashed") +
  xlab("Log2 Base Mean")+
  ylab("Log2 fold change")

dev.off()

################################################################################
#### Export outputs
################################################################################

info = sessionInfo()


writeLines(paste("Hello world\n R version : ", info$R.version$version.string,
                 "\n DefSeq version : ", info$otherPkgs$DESeq2$Version),
           con='/results/DESeq2/DESeq2_results.txt')
