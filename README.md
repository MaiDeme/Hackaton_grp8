#featureCounts : outil de comptage des gènes

#Singularity.featurecounts 
#Recette pour construire le conteneur de featureCounts version 1.4.6-p3


# Dans cette branche 'main' se trouve le dossier principal qui servira de rendu final ou le Snakefile est le wrokflow qui contient tout les rules necessaire au procédé.
## Chaque dossier contient une image a la base travaillé individuellement dans une autre branche pour une création et un test plus facile. 
          # Bowtie contient l'image qui permet d'utiliser Bowtie pour indexer et mapper , trimming contient l'image qui permet de nettoyer puis trier les sequences etc...


