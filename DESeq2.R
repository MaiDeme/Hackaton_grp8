################################################################################
### Preparation des donnees et des parametres
################################################################################

#Nettoyage de la session
rm(list=objects())
graphics.off()
set.seed(12345)

#Chargement des librairies

library(DESeq2)
library(ggplot2)
library(EnrichmentBrowser)

#Mise en place du repertoire de travail
args <- commandArgs(trailingOnly = TRUE)
dir = args[1]
#dir = "/home/marmotte/Documents/Université/Master BIBS/M2AMI2B/ReproHackathon/Hackaton_grp8"

#Creation des fichiers de sortie

res_dir = paste0(dir,"/results/DESeq2/")
MAplot_all = paste0(dir,"/results/DESeq2/MA_plot_all.pdf")
Volcano_plot_all = paste0(dir,"/results/DESeq2/Volcano_plot_all.pdf")
res_txt = paste0(dir,"/results/DESeq2/DESeq2_results.txt")

if (!dir.exists(res_dir)) {
  dir.create(res_dir)
}
if (!file.exists(MAplot_all)) {
  file.create(MAplot_all)
}
if (!file.exists(Volcano_plot_all)) {
  file.create(Volcano_plot_all)
}
if (!file.exists(res_txt)) {
  file.create(res_txt)
}

#Chargement des fichiers 
counts = read.table(paste0(dir,"/results/counts/Combined_table.txt"), header = T, row.names = 1)


################################################################################
####DESeq2
################################################################################

#Vecteur de condition : Antibio ou pas
#O : controle : 3 derniers
#1 : Antibio : 3 premiers

cond <- factor(rep(c(1,0), each=3))


#Utilisation des parametres par defaut
dds <- DESeqDataSetFromMatrix(counts, DataFrame(cond), ~ cond)
dds <- DESeq(dds)  
res <- results(dds, test = "Wald")

pvalues = res$padj


genes_diff = dim(counts[which(pvalues<0.05),])[1]
genes_up = dim(counts[which(pvalues<0.05 & res$log2FoldChange>0),])[1]
genes_down = dim(counts[which(pvalues<0.05 & res$log2FoldChange<0),])[1]


################################################################################
#### MA plots
################################################################################

pdf(MAplot_all)



y <- pmin(pmax(res$log2FoldChange, -4), 4)
x = apply(X = counts, MARGIN = 1, FUN = mean)


is_max <- res$log2FoldChange > 4 | res$log2FoldChange < -4

# Création des data.frames pour ggplot
data_normal <- data.frame(x = x[!is_max], 
                          y = y[!is_max], 
                          pvalues = pvalues[!is_max])
data_max <- data.frame(x = x[is_max], 
                           y = y[is_max], 
                           pvalues = pvalues[is_max])


ggplot() +
  # Points normaux
  geom_point(data = data_normal,
             mapping = aes(x = x, 
                           y = y, 
                           color = ifelse(!is.na(pvalues) & pvalues > 0.05, 
                                          "Non Significatif", 
                                          "Significatif")),
             size = 1) +
  # Triangles pour les valeurs limites
  geom_point(data = data_max,
             mapping = aes(x = x, 
                           y = y, 
                           color = ifelse(!is.na(pvalues) & pvalues > 0.05, 
                                          "Non Significatif", 
                                          "Significatif")),
             shape = 17,  
             size = 1) + 
  # Couleurs
  scale_color_manual(values = c("Non Significatif" = "black", "Significatif" = "red"),
                     name = NULL) +
  # Axe X en log10
  scale_x_log10(
    breaks = scales::trans_breaks("log10", function(x) 10^x),
    labels = scales::trans_format("log10", scales::math_format(10^.x))
  ) +
  # Ligne horizontale à y=0
  geom_line(mapping = aes(x = x, y = 0), color = "black", linetype = "dashed") +
  # Titres des axes
  xlab("Mean of normalized counts") +
  ylab("Log2 fold change")

dev.off()

################################################################################
#### Volcano plots
################################################################################
pdf(Volcano_plot_all)

x = res$log2FoldChange
y = -log10(pvalues)


ggplot(data = cbind(x,y), 
       mapping = aes(x,
                     y, 
                     color = ifelse(!is.na(pvalues) & pvalues > 0.05, 
                                            "Non Significatif", 
                                            "Significatif")))+
  geom_point()+
  scale_color_manual(values = c("Non Significatif" = "black", "Significatif" = "red"),
                     name = NULL) +
  xlab("Log2 fold change") +
  ylab("-Log10 pvalues adjusted")

dev.off()

################################################################################
#### Export outputs
################################################################################

info = sessionInfo()


writeLines(paste("R version : ", info$R.version$version.string,
                 "\n DefSeq version : ", info$otherPkgs$DESeq2$Version,
                 "\n\n Resultats Analyse differentielle tous les genes :
                 \n genes diff : ", genes_diff,
                 "\n genes up : ", genes_up,
                 "\n genes down : ", genes_down),
           con=res_txt)
