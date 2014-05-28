#!/usr/bin/perl -w
use strict;
use Data::Dumper;

### Default to the current working directory
my $dir = ".";	
if (defined($ARGV[0])) {
	my $dir = $ARGV[0];
}

### Get the file list
my @fl;
opendir(my $dh, $dir) or die "Can't open the directory\n";
while (my $f = readdir($dh)) {
	if ($f =~ m/set$/) {
		push @fl, $f;
	}
}
closedir($dh);

### Read each file and record the sector count
my %sectors_by_set;
foreach my $set (@fl) {
	my %sectors;
	open SET, $set or die "Can't open the set file.\n";
	while (my $line = <SET>) {
		### Make sure it's a unix file...
		$line =~ s/\r\n/\n/g;

		### Found a sector
		if ($line =~ m/sector\s(.*)\s/) {
			my $s = $1;
			chomp($s);

			my $found = 0;
			foreach my $sector (keys(%sectors)) {
				### Check for substrings
				if ($sector =~ m/$s/) {
					$found = 1;
					$sectors{$sector}++;
				### Check if the key is a substring of this sector
				} elsif ($s =~ m/$sector/) {
					$found = 1;
					my $old_count = $sectors{$sector};
					undef($sectors{$sector});
					$sectors{$sector} = $old_count + 1;
				}
			}

			### Add a new sector to the list
			if (not $found) {
				$sectors{$s} = 1;
			}
		}
	}
	close SET;
	$sectors_by_set{$set} = \%sectors;
}

### Print out the results
my $substr_ct = 0;
foreach my $set (@fl) {
	my $ct = 0;

	foreach my $sector (keys($sectors_by_set{$set})) {
		if ($sectors_by_set{$set}->{$sector} > 1) {
			if ($ct == 0) {
				print "Set: $set\n";
			}
			print "\t$sector: ",$sectors_by_set{$set}->{$sector},"\n";
			$substr_ct = $substr_ct + ($sectors_by_set{$set}->{$sector} - 1);
			$ct++;
		}
	}
}

print $substr_ct, " total substring sectors.\n";
