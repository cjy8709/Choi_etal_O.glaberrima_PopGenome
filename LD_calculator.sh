#!/bin/bash
# Script to calculate LD in window

#######
# Input plink file to calculate LD
PLINK_IN=/path/to/plink_in
# number of BINS to average the LD per bin
BINSIZE=1000
# window size to analyze LD (in kb) 
WINDOWSIZE=1000

#####

# glaberrima has 12 chromosomes and calculate LD by chromosome
for i in {1..12};
do
        # plink for calculating LD
        plink2 --file "$PLINK_IN" --chr "$i" --r2 --ld-window 99999 --ld-window-kb 1000 --ld-window-r2 0 --out ${PLINK_IN##*/}_CHR"${i}"_LD

        # manipulating LD file for Rscript
        awk '{print $2,$5,$7}' ${PLINK_IN##*/}_CHR"${i}"_LD.ld > ${PLINK_IN##*/}_CHR"${i}"_LD.REDUCED_LDplot.txt

        # remove *.ld file if deemed necessary (file is usually very big)
        #rm ${PLINK_IN##*/}_CHR"${i}"_LD.ld

        # script to calculate LD in windows
        Rscript LD_calculator.r ${PLINK_IN##*/}_CHR"${i}"_LD.REDUCED_LDplot.txt "$i" "$BINSIZE" "$WINDOWSIZE"
done
