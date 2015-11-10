#//bin/perl -w
use File::Basename;
die "perl $0 sticklebacks.vcf\n" unless (@ARGV==1);

my $file=shift;
my $dir="/fml/chones/projects/PJ023_FamilyRecomb/hetero_snp_density/individual/";
my $chr_prefix=basename $file;
$chr_prefix=(split /\./,$chr_prefix)[1];


my @archive_names;
my %save;
open I, $file or die $!;
while(<I>){
        chomp;
        if($_=~/^##/){
                next;
        }

        my $line=$_;
        my ($chr, $pos, $ref, $alt, $filter) = (split /\t/,$line)[0,1,3,4,6];

        my @tmp=split /\t/,$line;
        my @samples=@tmp[9 .. 214];
        if($line=~/^#CHROM/){
                @archive_names=@samples;
                foreach my $n(0 .. $#archive_names){
                        my $name=$archive_names[$n];
                        if($name =~/\|/){
                                $name=~s#\|#_#g;
                        }
                        if($name=~/#/){
                                $name=~s/#/_/g;
                        }
                        $archive_names[$n]=$name;
                        print "$name\n";
                }
                print "\n";
                next;
        }

        if($filter ne "PASS"){
                next;
        }
        
        foreach my $s(0 .. $#samples){
                my $s_name=$archive_names[$s];
                my $s_gt=$samples[$s];
                my $gt=(split /:/,$s_gt)[0];
                my ($gt1, $gt2)=split /\//,$gt;
                if($gt1 != $gt2){
                        push @{$save{$s_name}},$pos;
                }
        }
}
close I;

my $pre;
my $current;
foreach my $s(keys %save){
        my $dir_idv=$dir."/".$s;
        if(! -e $dir_idv){
                `mkdir $dir_idv`;
        }
        my $file_name=$s.".".$chr_prefix.".hetero.snp.density";
        open O, ">$dir_idv/$file_name" or die $!;
        foreach my $index(0 .. $#{$save{$s}}){
                if($index==0){
                        $pre=$save{$s}->[0];
                        print O "chr\tpre_pos\tpos\tdistance\n";
                        next;
                }
                $current=$save{$s}->[$index];
                my $distance=$current-$pre;
                print O "$chr_prefix\t$pre\t$current\t$distance\n";
                $pre=$current;
        }
}

close O;
