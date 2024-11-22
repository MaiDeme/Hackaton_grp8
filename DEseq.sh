#!/bin/bash

samples=("SRR10379721" "SRR10379722" "SRR10379723" "SRR10379724" "SRR10379725" "SRR10379726")


#Pas beoin de faire de table d'équivalence, les noms de genes sont deja leurs identifiants 

##################################################################################
### Formattage et tri des fichiers de comptes
##################################################################################

for N in ${samples[@]}
do

    awk '{{print $1 " " $7}}' "results/counts/$N.txt" > "results/counts/Count_table_$N.txt"

    sed -i '1,2d' "results/counts/Count_table_$N.txt"

    echo -e "geneid ${N}" > temp_file
    cat "results/counts/Count_table_$N.txt" >> temp_file
    mv temp_file "results/counts/Count_table_$N.txt"

    sed -i 's/ \+/\t/g' "results/counts/Count_table_$N.txt"

    sort -k1,1 -t $'\t' "results/counts/Count_table_$N.txt" -o "results/counts/Count_table_$N.txt"

done



##################################################################################
### Jointure des fichiers
##################################################################################

cp "results/counts/Count_table_${samples[0]}.txt" results/counts/Combined_table.txt

for N in ${samples[@]:1}
do
    join -1 1 -2 1 -t $'\t' -a 1 -a 2 results/counts/Combined_table.txt "results/counts/Count_table_${N}.txt" > results/counts/temp_file
    mv results/counts/temp_file results/counts/Combined_table.txt
done



##################################################################################
### Suppresion des fichiers temporaires
##################################################################################

for N in ${samples[@]}
do

   rm "results/counts/Count_table_$N.txt"

done


##################################################################################
### Analyse avec DESeq2
##################################################################################

