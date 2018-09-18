# steps taken to work from raw FASTQ files to ultimately analzye ready VCF files

###### Trim/QC control raw FASTQ reads ######
# used bbduk for qualty control FASTQ trimming
bbduk.sh -Xmx8g threads="$THREAD" \
qin=33 \
in1="$FASTQ1" in2="$FASTQ2" \
out1="$SAMPLENAME"_1_paired.fastq.gz out2="$SAMPLENAME"_2_paired.fastq.gz \
minlen=25 qtrim=rl trimq=10 \
ktrim=r k=25 mink=11 hdist=1 \
tpe \
tbo \
ref="$BBMAP_DIR"/resources/truseq.fa.gz,"$BBMAP_DIR"/resources/nextera.fa.gz


###### Generate BAM alignment ready for SNP calling ######
# BWA for aligning FASTQ
bwa mem -t "$THREAD" -M "$REF_GENOME" "$FQ1" "$FQ2" > "$SAMPLENAME"_bwa.sam

# PICARD sam -> bam
# convert the sam to bam. Using PICARD istead of SAMTOOLS to unify the tool thats used later on
java -Xmx40g -jar "$PICARD" SortSam \
INPUT="$SAMPLENAME"_bwa.sam \
OUTPUT="$SAMPLENAME"_bwa_csort.bam \
SORT_ORDER=coordinate

# PICARD: BAM RG header editing ##
java -Xmx40g -jar "$PICARD" AddOrReplaceReadGroups \
INPUT="$SAMPLENAME"_bwa_csort.bam \
OUTPUT="$SAMPLENAME"_bwa_RGedit_csort.bam \
SORT_ORDER=coordinate \
RGID="$SAMPLENAME" RGLB="$LIBNAME" RGPL=Illumina RGSM="$LIBNAME" RGPU=none

# PICARD: MarkDuplicate (Duplicate reads are removed)
java -Xmx40g -jar "$PICARD" MarkDuplicates \
INPUT="$SAMPLENAME"_bwa_RGedit_csort.bam \
OUTPUT="$SAMPLENAME"_bwa_RGedit_dedup_csort.bam \
METRICS_FILE="$SAMPLENAME".dup_metrics \
REMOVE_DUPLICATES=true

# build index
java -Xmx8g -jar "$PICARD" BuildBamIndex INPUT="$SAMPLENAME"_bwa_RGedit_dedup_csort.bam


###### Use BAM to call genotypes and generate VCF SNP file ######
# For each sample use GATK haplotypecaller engine to call variants into gVCF format
java -Xmx16g -jar "$GATK" -T HaplotypeCaller \
-R "$GENOMEPREFIX" \
-I "$SAMPLENAME"_bwa_RGedit_dedup_csort.bam \
-o "$SAMPLENAME".g.vcf.gz \
-ERC GVCF

# Run GATK joint genotyping method
VCFDIR="/path/to/VCF_files"
VARIANTS=$(while read -r LINE; do printf " --variant $LINE"; done < <(ls ${VCFDIR}/*.g.vcf.gz))
CMD=$(printf "java -jar "${GATK}" -T GenotypeGVCFs -R "${GENOMEPREFIX}" "${VARIANTS}" -o combined.vcf.gz")
eval "$CMD"

# seperate combined VCF into SNP and INDELs 
java -Xmx8g -jar "${GATK}" \
-T SelectVariants -selectType SNP \
-R ${GENOMEPREFIX} \
-V combined.vcf.gz \
-o combined.SNP.vcf.gz

java -Xmx8g -jar "${GATK}" \
-T SelectVariants -selectType INDEL \
-R ${GENOMEPREFIX} \
-V combined.vcf.gz \
-o combined.INDEL.vcf.gz

### Filtering step
# INDEL VCF hard filter
java -Xmx8g -jar "${GATK}" \
-T VariantFiltration \
-R "$GENOMEPREFIX" \
-filter "vc.hasAttribute('QD') && QD<2.0" \
-filter "vc.hasAttribute('ReadPosRankSum') && ReadPosRankSum < -20.0" \
-filter "vc.hasAttribute('InbreedingCoeff') && InbreedingCoeff < -0.8" \
-filter "vc.hasAttribute('FS') && FS > 200.0" \
-filter "vc.hasAttribute('SOR') && SOR > 10.0" \
-filterName INDELQD \
-filterName INDELReadPos \
-filterName INDELInbreed \
-filterName INDELFS \
-filterName INDELSOR \
--variant combined.INDEL.vcf.gz \
-o combined.INDEL.FILTERED.vcf.gz

# Select "passed" variants
java -Xmx8g -jar "${GATK}" \
-T SelectVariants \
-R "$GENOMEPREFIX" \
-select 'vc.isNotFiltered()' \
--variant combined.INDEL.FILTERED.vcf.gz \
-o combined.INDEL.FILTERED.PASS.vcf.gz

# SNP VCF hard filter
java -Xmx8g -jar "${GATK}" \
-T VariantFiltration \
-R "$GENOMEPREFIX" \
--mask combined.INDEL.FILTERED.PASS.vcf.gz --maskExtension 5 \
--maskName INDELMASK \
-filter "vc.hasAttribute('QD') && QD<2.0" \
-filter "vc.hasAttribute('MQ') && MQ<40.0" \
-filter "vc.hasAttribute('FS') && FS>60.0" \
-filter "vc.hasAttribute('MQRankSum') && MQRankSum < -12.5" \
-filter "vc.hasAttribute('ReadPosRankSum') && ReadPosRankSum < -8.0" \
-filter "vc.hasAttribute('SOR') && SOR > 3.0" \
-filterName SNPQD \
-filterName SNPMQ \
-filterName SNPFS \
-filterName SNPMQRankSum \
-filterName SNPReadPos \
-filterName SNPSOR \
--variant combined.SNP.vcf.gz \
-o combined.SNP.FILTERED.vcf.gz

# passed variants
java -Xmx8g -jar /share/apps/gatk/3.8-0/GenomeAnalysisTK.jar \
-T SelectVariants \
-R "$GENOMEPREFIX" \
-select 'vc.isNotFiltered()' \
--variant combined.SNP.FILTERED.vcf.gz \
-o combined.SNP.FILTERED.PASS.vcf.gz

