die "perl $0 filtered.vcf\n" unless(@ARGV==1);
my $vcffile=shift;

my $total=0;
my $count=0;
open I, $vcffile or die $!;
while(<I>){
        chomp;
        if($_=~/^#/){
                print "$_\n";
                next;
        }

        my ($dad,$mom)=(split)[9,10];
        my $gtm=(split /:/,$mom)[0];
        my $gtd=(split /:/,$dad)[0];
        if($gtm ne $gtd){
                $count++;
                print "$_\n";
        }
        $total++;
}

print STDERR "informative:\t$count\n";
print STDERR "total:\t$total\n";
