use strict;
use warnings;

die "perl $0 sample.list chr.list\n" unless (@ARGV==2);
my $sample_list=shift;
my $chr_list=shift;

my @chrs;
open I, $chr_list or die $!;
while(<I>){
        chomp;
        my $chr_name=(split)[0];
        push @chrs,$chr_name;
}
close I;

open II, $sample_list or die $!;
while(<II>){
        chomp;
        &count($_,\@chrs);
}
close II;

sub count{
        my $dir="/fml/chones/projects/PJ023_FamilyRecomb/2014.10.16.hetero_snp_density/individual";
        my @cut=(20,40,60,80,100,500,1000,4000,394766);
        my $sample_name=shift;
        my $chromo=shift;
        my @chromosomes=@{$chromo};
        my %save;       #count the different cut
        my $total_num=0;        #total lines of snp
        my @region=();  #region with extreme long span
        foreach my $chr (@chromosomes){
                my $file_name=$dir."/".$sample_name."/".$sample_name.".".$chr.".hetero.snp.density";
                open I, $file_name or die $!;
                <I>;
                while(<I>){
                        chomp;
                        $total_num++;
                        my $line=$_;
                        my $distance=(split /\t/,$_)[3];
                        foreach my $c(@cut){
                                if($c==394766){
                                        $save{$c}++;
                                        my ($chr_this,$start,$end)=(split /\t/,$line)[0,1,2];
                                        push @region,$chr_this."_".$start."_".$end;
                                        last;
                                }
                                if($distance <$c){
                                        $save{$c}++;
                                        last;
                                        }
                        }
                }
        }
        my $out_dir="/fml/chones/projects/PJ023_FamilyRecomb/2014.10.16.hetero_snp_density/individual/all/statistics/";
        open O,">$out_dir/$sample_name.statistics" or die $!;
        print O "$sample_name\t";
        foreach my $k(sort {$a<=>$b} keys %save){
                my $v=$save{$k};
                print O "$k:$v\t";
        }
        print O "$total_num\n";
        close O;

        open OUT, ">$out_dir/$sample_name.long.region";
        if($#region >=1){
                foreach my $r(@region){
                        my ($this_chr,$this_start,$this_end)=split /_/,$r;
                        my $distan=$this_end-$this_start;
                        print OUT "$this_chr\t$this_start\t$this_end\t$distan\n";
                }
        }
        close OUT;
  }
