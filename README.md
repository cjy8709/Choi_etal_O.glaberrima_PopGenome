# Scripts and commands used for Choi et al. 2019 Plos Genet Oryza glaberrima population genomics study
https://journals.plos.org/plosgenetics/article?id=10.1371/journal.pgen.1007414

All files shown in the script or commands below can be found in dryad:
https://datadryad.org/resource/doi:10.5061/dryad.t7g7cj4

## commands taken from raw FASTQ to BAM to VCF generation
FromFASTQ_to_VCF.sh

## script and commands for calculating and plotting LD
### calculate LD
LD_calculator.sh
LD_calculator.r

### plot LD
plot_LD.r

## generate output for plotting genotypes from VCF region of interest
haplotype_view_generate.sh
### commands for ploting (visualize) the genotypes
plot_haplotype_view.r

## commands for plotting geography of West Africa
plot_WestAfrica_geo.r

## plot haplotype network
plot_haplonetwork.r

## visualize the NGSadmix results
plot_ngsAdmix.r

## visualize NGScovar (PCA) results
plot_ngsCovar.r
