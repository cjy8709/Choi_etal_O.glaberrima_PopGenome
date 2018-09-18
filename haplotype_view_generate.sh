#!/bin/bash

# gets specific region of interest from VCF input and converts to a haplotype format where the genotype for each site are coded as 0,1,2 for ref, het, alt genotypes
# output file *.haplotype.txt can be visualized in R with commands in plot_haplotype_view.r script

###### param set up

# input vcf file containing SNPs from all individuals, all chromosomes, and imputed
INVCF=combined.impute.vcf

# outnmae
OUTNAME="OBART07G03450_OR_OBART07G03460_PROG1"

# coordinate to extract SNPs
COORD="7:2660603-2668534" # this example its the PROG1 region

# bps to add on to $COORD
PAD=50000

######

# SCRIPT STARTS HERE

# get coordinates
CHR=$(awk -F':' '{print $1}' <<< "$COORD")
START=$(awk -F':' '{print $2}' <<< "$COORD" | awk -F'-' '{print $1}'); START=$((START-PAD))
END=$(awk -F':' '{print $2}' <<< "$COORD" | awk -F'-' '{print $2}'); END=$((END+PAD))

# get plink format for region of interest
vcftools --vcf "$INVCF" --out "$OUTNAME"_"$CHR"_"$START"_"$END"_"$PAD"bpPADDED --chr "$CHR" --from-bp "$START" --to-bp "$END" --plink

# get vcf format for region of interest
vcftools --vcf "$INVCF" --recode --out "$OUTNAME"_"$CHR"_"$START"_"$END"_"$PAD"bpPADDED --chr "$CHR" --from-bp "$START" --to-bp "$END"

# remove lines starting with '#' in vcf
sed -i '/^#/ d' "$OUTNAME"_"$CHR"_"$START"_"$END"_"$PAD"bpPADDED.recode.vcf

## loop through each line of PED file. FOR loop through the genotypes of each column in PED file
#TOTALCOL=$(awk '{print NF}' "$OUTNAME"_"$CHR"_"$START"_"$END"_"$PAD"bpPADDED.ped | head -1)
while read -r LINE; do
        ID=$(awk '{print $1}' <<< "$LINE")
        printf "$ID"
        # count the line number to go to in the MAP file
        itr=6

        # go through each column of PED file
        for (( k=7; k<=$(awk '{print NF}' <<< "$LINE" | head -1); k+=2 )); do
                MAPLINENUM=$((k-itr))
                MAPFOUND=$(sed "${MAPLINENUM}q;d" "$OUTNAME"_"$CHR"_"$START"_"$END"_"$PAD"bpPADDED.map)
                MAPCOORD=$(awk '{print $NF}' <<< "$MAPFOUND")

                # get the VCF coordinate
                VCFFOUND=$(awk -v var="$MAPCOORD" '$2==var{print}' "$OUTNAME"_"$CHR"_"$START"_"$END"_"$PAD"bpPADDED.recode.vcf)
                REFALLELE=$(awk '{print $4}' <<< "$VCFFOUND")
                ALTALLELE=$(awk '{print $5}' <<< "$VCFFOUND")

                ### alleles to check and see if they are hom or het and whether they are hom REF or ALT
                PEDALLELE1=$(awk -v k="$k" '{print $k}' <<< "$LINE")
                PEDALLELE2=$(awk -v k="$k" '{print $(k+1)}' <<< "$LINE")
                if [ "$PEDALLELE1" == "$PEDALLELE2" ]; then #homozygote test to see if its hom alt or ref genotype
                        if [ "$PEDALLELE1" -eq 0 ] 2>/dev/null; then # missing data
                                printf "\t-9"
                        elif [ "$PEDALLELE1" == "$REFALLELE" ]; then # matches ref allele
                                printf "\t0"
                        else
                                printf "\t2"
                        fi
                else    # else het so code accordingly
                        printf "\t1"
                fi
                ###

                # increment the itr count to go to the next MAP coordinate for next for LOOP of PED file
                itr=$((itr+1))

        done
        printf "\n"

done < "$OUTNAME"_"$CHR"_"$START"_"$END"_"$PAD"bpPADDED.ped > "$OUTNAME"_"$CHR"_"$START"_"$END"_"$PAD"bpPADDED.haplotype.txt

HEADER=$(printf "NAME\t$(awk -F'\t' '{print $4}' "$OUTNAME"_"$CHR"_"$START"_"$END"_"$PAD"bpPADDED.map | tr '\n' '\t' | sed 's/\t$/\n/')")

sed -i '1i'"${HEADER}"'\' "$OUTNAME"_"$CHR"_"$START"_"$END"_"$PAD"bpPADDED.haplotype.txt
