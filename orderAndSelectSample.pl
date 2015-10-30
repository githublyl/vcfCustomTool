use strict;
use warnings;

die "perl $0 good_sample chr5.vcf\n" unless(@ARGV==2);
my $goodSample=shift;
my $vcf=shift;

my %mark;
open I, $goodSample or die $!;
while(<I>){
        chomp;
        $mark{$_}=$.;
}
close I;

open II, $vcf or die $!;
my $header;
my @new_header;
while(<II>){
        chomp;
        if($_=~/^##/){
                print "$_\n";
                next;
        }elsif($_=~/#CHROM/){
                $header=$_;
                my $ref_new_header=&process_header($header,\%mark);
                @new_header=@{$ref_new_header};
                &print_selected($header,\@new_header);
                next;
        }else{
                my $content=$_;
                &print_selected($content,\@new_header);
        }
}
close II;

sub print_selected{
        my $line=shift;
        my $ref=shift;
        my @needed=@{$ref};
        my @all_content=split /\s+/,$line;

        foreach my $i(0 .. 8){
                print "$all_content[$i]\t";
        }
        foreach my $j(@needed){
                print "$all_content[$j]\t";
        }
        print "\n";
}

sub process_header{
        my $line=shift;
        my $tmp=shift;
        my %hash=%{$tmp};
        my @parse=split /\s+/,$line;
        my @result;
        my %reverse_hash;
        foreach my $i(0 .. $#parse){
                if(exists $hash{$parse[$i]}){
                        my $value=$hash{$parse[$i]};
                        $reverse_hash{$value}=$i;
                }
        }

        foreach my $key(sort {$a <=> $b} keys %reverse_hash){
                my $v=$reverse_hash{$key};
#               print "$key\t$v\n";
                push @result, $v;
        }

        return \@result;
}







