

#perl filter.pl chr4.filtered.vcf 1 3 >chr4.per.individual.filter.vcf



#########July 29 test

#initial_vcf="/fml/chones/projects/PJ023_FamilyRecomb/marine_X20/5.SNP/chr/chr4.alt.vcf"
initial_vcf="chr4.alt.vcf"
initial_snp_vcf="chr4.snp.vcf"
#grep -v "INDEL;" $initial_vcf >$inital_snp_vcf
grep -v "INDEL;"  chr4.alt.vcf >chr4.snp.vcf
#this will run 15 minutes
perl filter.pl chr4.snp.vcf  2 20 3 >chr4.snp.individual_filter.vcf

#this one is quicker
#perl order.pl top.18  chr4.snp.individual_filter.vcf  >chr4.snp.individual_filter.good_samples.vcf
#perl order.pl top.18  chr4.snp.individual_filter.vcf  >chr4.snp.individual_filter.good_samples.vcf
vcftools --vcf chr4.snp.individual_filter.vcf --out select18ind  --recode --recode-INFO-all   --keep top.18


perl -ne 'chomp;if($_=~/^#/){print "$_\n";}else{my @tmp=split;my @head=@tmp[0 .. 8];my @tail=@tmp[9 .. $#tmp];my $count=0;foreach my $i(@tail){if($i=~/^\.\/\./){$count++;}} if($count<5){print join "\t",@head;print "\t";print join "\t",@tail,"\n";}}'  chr4.snp.individual_filter.good_samples.vcf >chr4.snp.individual_filter.good_samples.least_na.vcf


perl -ne 'chomp;$na_cutoff=1;if($_=~/^#/){print "$_\n";}else{my @tmp=split;my @head=@tmp[0 .. 8];my @tail=@tmp[9 .. $#tmp];my $count=0;foreach my $i(@tail){if($i=~/^\.\/\./){$count++;}} if($count<$na_cutoff){print join "\t",@head;print "\t";print join "\t",@tail,"\n";}}'  chr4.snp.individual_filter.good_samples.vcf >chr4.snp.individual_filter.good_samples.least_na.vcf


perl count.inform.pl chr4.snp.individual_filter.good_samples.least_na.vcf   >chr4.snp.individual_filter.good_samples.least_na.informative.vcf



perl -ne 'chomp;if($_!~/^#/){my @tmp=split;my @head=@tmp[0 .. 8];my @tail=@tmp[9 .. $#tmp];foreach my $i(@tail){my $depth=(split /:/,$i)[2];print "$depth\t";}print "\n";}'  chr4.snp.individual_filter.good_samples.least_na.informative.vcf >depth.matrix

perl -ne 'chomp;if($_!~/^#/){my @tmp=split;my @head=@tmp[0 .. 8];my @tail=@tmp[9 .. $#tmp]; my $count=0;foreach my $i(@tail){if($i=~/^\.\/\./){$count++;}} print "$count\n"; }'   chr4.snp.individual_filter.good_samples.vcf  >na.frequency




