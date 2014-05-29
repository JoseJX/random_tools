#!/usr/bin/perl -w
use strict;
use Data::Dumper;

my $filter = $ARGV[0];

sub parse_sectors {
	my @setfile = @{shift()};
	my $ppos = shift;
	my $pos = $$ppos;
	my %sectors;

	for (; $pos<$#setfile+1; $pos++) {
		my $line = $setfile[$pos];

		### Found a sector
		if ($line =~ m/sector\s?(.*)\s?/) {
			my $s = $1;

			### If there's a filter defined, loop until we find the type
			if (defined($filter)) {
				my $type;
				for (;$pos<$#setfile+1; $pos++) {
					my $type_line = $setfile[$pos];
					if ($type_line =~ m/type\s?(.*)\s?/) {
						$type = $1;	
						last;
					}
				}

				### Skip if it's not the right type
				if ($type ne $filter) {
					next;
				}
			}

			my $found = 0;
			foreach my $sector (keys(%sectors)) {
				### Check if the key is a substring of this sector
				if ($sector =~ m/$s/) {
					$found = 1;
					$sectors{$sector}++;
				### Check if the sector is a substring of this key
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
		### Bail if we see another section
		} elsif($line =~ m/section:/) {
			last;
		}
	}
	$$ppos = $pos;
	return \%sectors;
}

sub parse_setups {
	my @setfile = @{$_[0]};
	my $ppos = $_[1];
	my $pos = $$ppos;
	my %setups;
	
	for (; $pos<$#setfile+1; $pos++) {
		my $line = $setfile[$pos];

		### Found a setup
		if ($line =~ m/\s?name\s?(.*)\s?/ or $line =~ m/\s?setup\s?(.*)\s?/) {
			my $s = $1;

			my $found = 0;
			foreach my $setup (keys(%setups)) {
				### Check if the key is a substring of this setup
				if ($setup =~ m/$s/) {
					$found = 1;
					$setups{$setup}++;
				### Check if the setup is a substring of this key
				} elsif ($s =~ m/$setup/) {
					$found = 1;
					my $old_count = $setups{$setup};
					undef($setups{$setup});
					$setups{$setup} = $old_count + 1;
				}
			}

			### Add a new setup to the list
			if (not $found) {
				$setups{$s} = 1;
			}
		### Bail if we see another section
		} elsif ($line =~ m/section:/) {
			last;
		}
	}
	$$ppos = $pos;
	return \%setups;
}

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
my %setups_by_set;

foreach my $set (@fl) {
	open SET, $set or die "Can't open the set file.\n";
	my @setfile = <SET>;
	### Make sure it's a unix file...
	s/\r\n/\n/g for(@setfile);
	chomp(@setfile);
	close SET;

	for (my $pos = 0; $pos < $#setfile+1; $pos++) {
		my $line = $setfile[$pos];

		### Find the setup section
		if ($line =~ m/section:\s*setups/) {
			$pos++;
			my $setups = parse_setups(\@setfile, \$pos);
			$setups_by_set{$set} = $setups;
		}
		
		### Find the sector section
		if ($line =~ m/section:\s*sectors/) {
			$pos++;
			my $sectors = parse_sectors(\@setfile, \$pos);
			$sectors_by_set{$set} = $sectors;
		}
	}	
}

### Print out the results
my $setup_substr_ct = 0;
my $sector_substr_ct = 0;
foreach my $set (@fl) {
	print "$set:\n";

	my $set_ct = 0;
	if (defined($setups_by_set{$set})) {
		foreach my $setup (keys($setups_by_set{$set})) {
			if ($setups_by_set{$set}->{$setup} > 1) {
				print "\tSetup: $setup: ",$setups_by_set{$set}->{$setup},"\n";
				$setup_substr_ct = $setup_substr_ct + ($setups_by_set{$set}->{$setup} - 1);
				$set_ct++;
			}
		}
	}

	my $sec_ct = 0;
	if (defined($sectors_by_set{$set})) {
		foreach my $sector (keys($sectors_by_set{$set})) {
			if ($sectors_by_set{$set}->{$sector} > 1) {
				print "\tSector: $sector: ",$sectors_by_set{$set}->{$sector},"\n";
				$sector_substr_ct = $sector_substr_ct + ($sectors_by_set{$set}->{$sector} - 1);
				$sec_ct++;
			}
		}
	}
	if ($set_ct == 0 and $sec_ct == 0) {
		print "\t None.\n";
	}
}

print $setup_substr_ct, " total setups w/substrings.\n";
print $sector_substr_ct, " total sectors w/substrings.\n";
