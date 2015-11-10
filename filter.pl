use strict;
use warnings;

die "perl $0 chr1.filtered.vcf depth_threshold depth_upper_bound  balance_threshold\n" unless(@ARGV==4);

my $vcf_file=shift;
my $d_thresh=shift;
my $d_upperbound=shift;
my $b_thresh=shift;

open I, $vcf_file or die $!;
while(<I>){
        chomp;
        if($_=~/^#/){
                print "$_\n";
                next;
        }
        my @tmp=split;
        my @all_samples=@tmp[9 .. $#tmp];
        my @header=@tmp[0 .. 8];
        my $head=join "\t",@header;
        &final_filtering($head,\@all_samples,$d_thresh,$d_upperbound,$b_thresh);
}
sub final_filtering{
        my $head_column=shift;
        my $ref=shift;
        my $depth_thresh=shift;
        my $depth_upper=shift;
        my $balance_thresh=shift;

        my @samples=@{$ref};
        my @new_samples;

        foreach my $s(@samples){
                my $filter_result=&depth_filter($s,$depth_thresh,$depth_upper,$balance_thresh);
                if($filter_result==0){
                        push @new_samples,"./.:0:0:0:0:0:0";
                }else{
                        push @new_samples,$s;
                }
        }

        my $father=shift @new_samples;
        my $mother=shift @new_samples;
        
        my ($da1,$da2)=&parse_gt($father);
        my ($ma1,$ma2)=&parse_gt($mother);

        #not sure if filter informative snp here
        my @kids;
        if($da1 ne "." && $da2 ne "." && $ma1 ne "." && $ma2 ne "."){
                my $flag=0;
                foreach my $k(@new_samples){
                        my ($ka1,$ka2)=&parse_gt($k);
                        my $check_result=&mendelian($da1,$da2,$ma1,$ma2,$ka1,$ka2);
                        if($check_result==1){
                                push @kids,$k;
                        }else{
                                $flag++;
                                push @kids, "./.:0:0:0:0:0:0";
                        }
                }
                if($flag < $#new_samples+1){
                        print "$head_column\t";
                        print "$father\t$mother\t";
                        print join "\t",@kids,"\n";
                }
        }
}

sub mendelian{
        my ($d1,$d2,$m1,$m2,$k1,$k2)=@_;

        my %uniqset=($d1=>1,$d2=>1,$m1=>1,$m2=>1);
        if((exists $uniqset{$k1}) && (exists $uniqset{$k2})){
                my %muniq=($m1=>1,$m2=>1);
                my %duniq=($d1=>1,$d2=>1);

                if((exists $muniq{$k1}) && (exists $duniq{$k2})){
                        return 1;
                }elsif((exists $muniq{$k2}) && (exists $duniq{$k1})){
                        return 1;
                }else{
                        return 0;
                }

        }else{
                return 0;
        }
}

sub parse_gt{
        my $total=shift;
        my $gt=(split /:/,$total)[0];
        my ($a1,$a2)=split /\//,$gt;
        return($a1,$a2);
}



sub depth_filter{
        my $total=shift;
        my $depth_threshold=shift;
        my $depth_upbound=shift;
        my $balance_threshold=shift;
        my ($gt,$pl,$dp,$dv,$sp,$dp4,$dpr)=split /:/,$total;
        my ($rf,$rr,$af,$ar)=split /,/,$dp4;

#category by homozygous heterozygous here
        if($dp>$depth_upbound || $dp <$depth_threshold){
                return 0;
        }
        my ($ga,$gb)=&parse_gt($gt);
        if($ga eq "0" && $gb eq "1"){
                if($rf<$depth_threshold/2 || $rr<$depth_threshold/2 || $af<$depth_threshold/2 || $ar<$depth_threshold/2){
                        return 0;
                }elsif($rf>$depth_upbound/2 || $rr>$depth_upbound/2 || $af>$depth_upbound/2 || $ar>$depth_upbound/2){
                        return 0;
                }else{
                        my $balan_r=&balance_filter($rf,$rr,$balance_threshold);
                        my $balan_a=&balance_filter($af,$ar,$balance_threshold);
                        if($balan_r==0 || $balan_a==0){
                                return 0;
                        }else{
                                return 1;
                        }
                }
        }
        
        if($ga eq "0" && $gb eq "0"){
                if($rf<$depth_threshold || $rr<$depth_threshold){
                        return 0;
                }elsif($rf>$depth_upbound/2 || $rr>$depth_upbound/2){
                        return 0;
                }else{
                        my $balan_r=&balance_filter($rf,$rr,$balance_threshold);
                        if($balan_r==0){
                                return 0;
                        }else{
                                return 1;
                        }
                }
        }
        
        if($ga eq "1" && $gb eq "1"){
                if($af<$depth_threshold || $ar<$depth_threshold){
                        return 0;
                }elsif($af>$depth_upbound/2 || $ar>$depth_upbound/2){
                        return 0;
                }else{
                        my $balan_a=&balance_filter($af,$ar,$balance_threshold);
                        if($balan_a==0){
                                return 0;
                        }else{
                                return 1;
                        }
                }
        }
        return 0;
}

sub balance_filter{
        my $allele1=shift;
        my $allele2=shift;
        my $bias_threshold=shift;

        my ($big,$small);
        if($allele1>$allele2 ){
                $big=$allele1;
                $small=$allele2;
        }else{
                $big=$allele2;
                $small=$allele1;
        }

        if($big > $small*$bias_threshold){
                return 0;
        }else{
                return 1;
        }

}
