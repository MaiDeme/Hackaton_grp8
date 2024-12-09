################################################################################
### Preparation des donnees et des parametres
################################################################################

#Nettoyage de la session
graphics.off()
set.seed(22222222)

#Chargement des librairies

library(DESeq2)
library(ggplot2)
library(EnrichmentBrowser)
library(FactoMineR)
library(factoextra, verbose = F)


dir = getwd()

#dir = "/home/marmotte/Documents/Université/Master_BIBS/M2AMI2B/ReproHackathon/Hackaton_grp8"

#Creation des fichiers de sortie

res_dir = paste0(dir,"/results/DESeq2/")

MAplot_all = paste0(dir,"/results/DESeq2/MA_plot_all.pdf")
Volcano_plot_all = paste0(dir,"/results/DESeq2/Volcano_plot_all.pdf")
PCA_all = paste0(dir,"/results/DESeq2/PCA_all.pdf")

MAplot_trans = paste0(dir,"/results/DESeq2/MA_plot_trans.pdf")
Volcano_plot_trans = paste0(dir,"/results/DESeq2/Volcano_plot_trans.pdf")
PCA_trans = paste0(dir,"/results/DESeq2/PCA_trans.pdf")

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
if(!file.exists(PCA_all)){
  file.create(PCA_all)
}


if (!file.exists(MAplot_trans)) {
  file.create(MAplot_trans)
}
if (!file.exists(Volcano_plot_trans)) {
  file.create(Volcano_plot_trans)
}
if(!file.exists(PCA_trans)){
  file.create(PCA_trans)
}


if (!file.exists(res_txt)) {
  file.create(res_txt)
}

#Chargement des fichiers 
counts = read.table(paste0(dir,"/results/counts/Combined_table.txt"), header = T, row.names = 1)

################################################################################
### Recuperation des genes impliques dans la traduction
################################################################################

translation_genes = NULL
AA_rna_path = NULL

KEGG = download.kegg.pathways(org = "sao")
#KEGG = downloadPathways(org = "sao")

#Recuperation des path lies a la traduction
Ribo_path = KEGG$sao03010
Aminoacyl_path = KEGG$sao00970

#Recuperation des noms de genes lies a la traduction
names = names(Ribo_path@nodes)

for (name in names) {
  gene <- Ribo_path@nodes[[name]]
  translation_genes = c(translation_genes, gene@name)

}

names = names(Aminoacyl_path@nodes)
for (name in names) {
  gene <- Aminoacyl_path@nodes[[name]]
  translation_genes = c(translation_genes, gene@name)
  AA_rna_path = c(AA_rna_path, gene@name)
}

#Filtre des counts en fonction des noms de genes

rownames(counts) = sub("gene-","sao:",rownames(counts))

counts_trans = counts[rownames(counts) %in% translation_genes,]

is_rna_path = (!startsWith(rownames(counts_trans), "sao:SAOUHSC_T")) & rownames(counts_trans) %in% AA_rna_path
counts_trans$is_rna_path = is_rna_path



################################################################################
####DESeq2 all 
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
#### MA plot off all genes
################################################################################

pdf(MAplot_all)



y <- pmin(pmax(res$log2FoldChange, -4), 4)
x = apply(X = counts, MARGIN = 1, FUN = mean)


is_max <- res$log2FoldChange > 4 | res$log2FoldChange < -4

# Création des data.frames pour ggplot
data_normal <- data.frame(x_norm = x[!is_max], 
                          y_norm = y[!is_max], 
                          pvalues = pvalues[!is_max])
data_max <- data.frame(x_max = x[is_max], 
                           y_max = y[is_max], 
                           pvalues = pvalues[is_max])


ggplot() +
  # Points normaux
  geom_point(data = data_normal,
             mapping = aes(x = x_norm, 
                           y =y_norm , 
                           color = ifelse(!is.na(pvalues) & pvalues > 0.05, 
                                          "Non Significatif", 
                                          "Significatif")),
             size = 1) +
  # Triangles pour les valeurs limites
  geom_point(data = data_max,
             mapping = aes(x=x_max, 
                           y=y_max, 
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
#### Volcano plot of all genes
################################################################################

pdf(Volcano_plot_all)

x = res$log2FoldChange
y = -log10(pvalues)


ggplot(data = as.data.frame(cbind(x,y)), 
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
#### PCA of translation genes
################################################################################

pdf(PCA_all)

cond_color = c(rep("Antibiotique",3), rep("Controle",3))
PCA_all = PCA(t(counts), graph = F, scale.unit = T)
fviz_pca_ind(PCA_all, col.ind = cond_color)

dev.off()

################################################################################
####DESeq2 translation genes
################################################################################

#Vecteur de condition : Antibio ou pas
#O : controle : 3 derniers
#1 : Antibio : 3 premiers

cond <- factor(rep(c(1,0), each=3))


#Utilisation des parametres par defaut
dds_trans <- DESeqDataSetFromMatrix(counts_trans[,1:6], DataFrame(cond), ~ cond)
dds_trans <- DESeq(dds_trans)  
res_trans <- results(dds_trans, test = "Wald")

pvalues_trans = res_trans$padj


genes_diff_trans = dim(counts_trans[which(pvalues_trans<0.05),])[1]
genes_up_trans = dim(counts_trans[which(pvalues_trans<0.05 & res_trans$log2FoldChange>0),])[1]
genes_down_trans = dim(counts_trans[which(pvalues_trans<0.05 & res_trans$log2FoldChange<0),])[1]


################################################################################
#### MA plot of translation genes
################################################################################

pdf(MAplot_trans)

y <- res_trans$log2FoldChange
x <- apply(X = counts_trans, MARGIN = 1, FUN = mean)


data <- data.frame(
  x = x,
  y = y,
  pvalue_group = ifelse(!is.na(pvalues_trans) & pvalues_trans > 0.05, 
                        "Non Significatif", 
                        "Significatif")
)

data_rna_path <- data.frame(
  x = apply(X = counts_trans, MARGIN = 1, FUN = mean)[counts_trans$is_rna_path == TRUE],
  y = res_trans$log2FoldChange[counts_trans$is_rna_path == TRUE]
)


# Ajouter une colonne pour distinguer les groupes RNA path dans la légende
data_rna_path$legend_group <- "tRNA Synthese"

# Ajouter une colonne légende aux données principales
data$legend_group <- ifelse(data$pvalue_group == "Non Significatif", 
                            "Non Significatif", 
                            "Significatif")

# Fusionner les données : On va representer deux fois les donnees trna synthetase
data_combined <- rbind(
  data[, c("x", "y", "legend_group")],
  data_rna_path[, c("x", "y", "legend_group")]
)

data_combined$x <- ifelse(data_combined$x <= 0, 1e-6, data_combined$x)


# Création du plot
ggplot(data_combined, aes(x = x, y = y, color = legend_group, shape = legend_group)) +
  geom_point(data = data, size = 2) + 
  geom_point(data = data_rna_path, size = 2, fill = NA) + 
  scale_shape_manual(
    values = c(
      "Non Significatif" = 16,   
      "Significatif" = 16,       
      "tRNA Synthese" = 21       
    ),
    name = NULL 
  ) +
  scale_color_manual(
    values = c(
      "Non Significatif" = "darkgrey",
      "Significatif" = "red",
      "tRNA Synthese" = "black"
    ),
    name = NULL 
  ) +
  
  scale_x_continuous(
    trans = "log2",
    breaks = scales::trans_breaks("log2", function(x) 2^x),
    labels = function(x) log2(x),
    limits = c(1, 2^20) 
  ) +
  scale_y_continuous(
    limits = c(-6,5) 
  ) +
  geom_line(aes(x = x, y = 0), color = "black", linetype = "dashed") + 
  xlab("Log2 Base Mean") +
  ylab("Log2 fold change") +
  guides(
    color = guide_legend(override.aes = list(
      size = 3, 
      fill = c(NA, NA, NA) 
    ))
  ) 


dev.off()

################################################################################
#### Volcano plot of translation genes
################################################################################

pdf(Volcano_plot_trans)

x = res_trans$log2FoldChange
y = -log10(pvalues_trans)


ggplot(data = as.data.frame(cbind(x,y)), 
       mapping = aes(x,
                     y, 
                     color = ifelse(!is.na(pvalues_trans) & pvalues_trans > 0.05, 
                                    "Non Significatif", 
                                    "Significatif")))+
  geom_point()+
  scale_color_manual(values = c("Non Significatif" = "black", "Significatif" = "red"),
                     name = NULL) +
  xlab("Log2 Fold change") +
  ylab("-Log10 Pvalues")

dev.off()



################################################################################
#### PCA of all genes
################################################################################

pdf(PCA_trans)

cond_color = c(rep("Antibiotique",3), rep("Controle",3))
PCA_trans = PCA(t(counts_trans[,1:6]), graph = F, scale.unit = T)
fviz_pca_ind(PCA_trans, col.ind=cond_color)

head(t(counts_trans[1:6,]))

dev.off()
################################################################################
#### Export outputs
################################################################################

info = sessionInfo()


writeLines(paste("R version : ", info$R.version$version.string,
                 "\n DefSeq version : ", info$otherPkgs$DESeq2$Version,
                 "\n EnrichmentBrowser version : ", info$otherPkgs$EnrichmentBrowser$Version,
                 "\n\n Resultats Analyse differentielle tous les genes :
                 \n genes diff : ", genes_diff,
                 "\n genes up : ", genes_up,
                 "\n genes down : ", genes_down,
                 "\n\n Resultats Analyse differentielle des genes de traduction :
                 \n genes diff : ", genes_diff_trans,
                 "\n genes up : ", genes_up_trans,
                 "\n genes down : ", genes_down_trans),
           con=res_txt)
