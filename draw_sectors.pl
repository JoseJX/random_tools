#!/usr/bin/perl -w
use strict;
use Data::Dumper;

### Check for params
if ($#ARGV < 1) {
	print "Usage:\n\tdraw_sectors.pl <game type> <set file> <optional filter>\n\n";
	print "\tGame type is one of: EMI, GRIM\n";
	print "\tFilter is one of: walk, funnel, camera, special, hot, chernobyl\n";
	exit(0);
}

### We have to force the game type because of the sector vert order
my $game = $ARGV[0];

### Read the set file
open SET, $ARGV[1] or die "Can't open the set file: ".$ARGV[1]."\n";
my @set = <SET>;
close SET;

### If supplied, filter
my $filter = $ARGV[2];

### Make sure it's a unix file...
s/\r\n/\n/g for(@set);
chomp(@set);

my @lowest = ( 9999.0, 9999.0, 9999.0 );
my @highest = ( -9999.0, -9999.0, -9999.0 );
my %sectors;
for (my $pos=0; $pos<$#set+1; $pos++) {
	my $line = $set[$pos];

	### We found a sector
	if ($line =~ m/sector\s+(\w*)/) {
		my $name = $1;
		### The ID must always be the next line
		$pos++;
		$set[$pos] =~ m/ID\s+(\d+)/;
		my $id = $1;
		$pos++;

		### Save the sector
		$sectors{$id} = { name=>$name };

		### Loop until a whole line is just whitespace
		while ($set[$pos] !~ m/^\s*$/) {
			$line = $set[$pos];	

			if ($line =~ m/type\s+(\w*)/) {
				$sectors{$id}->{'type'} = $1;
			} elsif ($line =~ m/default visibility\s+(\w*)/) {
				if ($1 eq "visible") {
					$sectors{$id}->{'visible'} = 1;
				} else {
					$sectors{$id}->{'visible'} = 0;
				}
			### Match FP for height
			} elsif ($line =~ m/height\s+([-+]?[0-9]*\.?[0-9]+)/) {
				$sectors{$id}->{'height'} = $1;
			} elsif ($line =~ m/numvertices\s+(\d+)/) {
				$sectors{$id}->{'numvertices'} = $1;
			} elsif ($line =~ m/sortplanes\s+(\d+)/) {
				$sectors{$id}->{'sortplanes'} = $1;
			} elsif ($line =~ m/normal\s+([-+]?[0-9]*\.?[0-9]+)\s+([-+]?[0-9]*\.?[0-9]+)\s+([-+]?[0-9]*\.?[0-9]+)/) {
				$sectors{$id}->{'normal'} = [ $1, $2, $3 ];
			} elsif ($line =~ m/vertices:/) {
				my @verts;
				for (my $i=0; $i<$sectors{$id}->{'numvertices'}; $i++) {
					$line =~ m/([-+]?[0-9]*\.?[0-9]+)\s+([-+]?[0-9]*\.?[0-9]+)\s+([-+]?[0-9]*\.?[0-9]+)/;
					my @v = ( $1, $2, $3 );
					push @verts, \@v;
					for (my $j=0; $j<3; $j++) {
						$lowest[$j] = $v[$j] if ($v[$j] < $lowest[$j]);
						$highest[$j] = $v[$j] if ($v[$j] > $highest[$j]);
					}
					
					$pos++;
					$line = $set[$pos];
				}
				### Fix the position so that we're pointing to the last line of the verts
				$pos--;
				### Add the verticies to the sector
				$sectors{$id}->{'verts'} = \@verts;
			}
			$pos++;
		}
	}
}
close SET;

### Adjust the values so we can shift the points
my $max = 0;
for (my $i=0; $i<3; $i++) {
	$lowest[$i] = int($lowest[$i] * 1000);
	if ($lowest[$i] > 0) {
		$lowest[$i] = 0;
	} else {
		$lowest[$i] = abs($lowest[$i]);
	}

	$highest[$i] = $lowest[$i] + int($highest[$i] * 1000);
	if ($highest[$i] > $max) {
		$max = $highest[$i];
	}
}

### Convert the sector list to XFIG polygons
open XFIG, ">".$ARGV[1].".fig" or die "Can't open the xfig file for writing.\n";
print XFIG "#FIG 3.2\n";
print XFIG "Landscape\n";
print XFIG "Center\n";
print XFIG "Metric\n";
print XFIG "A4\n";
print XFIG "100.00\n";
print XFIG "Single\n";
print XFIG "-2\n";

### Set the scale
### FIXME: This works, but it's kind of voodoo magic at the moment
print XFIG int(1300 * ($max / 10000)), " 2\n";

### All sectors will be represented by polylines
foreach my $k (keys %sectors) {
	my %sector = %{$sectors{$k}};	

	### Filter?
	next if (defined($filter) and $sector{type} ne $filter);

	### Add a comment with the name
	print XFIG "# ",$sector{name},"\n";
	
	### Create the polyline object (type 2), type is polygon (type 3)
	print XFIG "2 3 ";
	
	### Determine visibility, solid if visible, dashed if not, thickness is always 1
	if ($sector{visibility}) {
		print XFIG "0 1 ";
	} else {
		print XFIG "1 1 ";
	}

	### Determine the pen and fill color based on the type
	### WALK - Blue
	if ($sector{type} eq "walk") {
		print XFIG "1 1 ";
	### FUNNEL - Yellow
	} elsif ($sector{type} eq "funnel") {
		print XFIG "6 6 ";
	### CAMERA - Black
	} elsif ($sector{type} eq "camera") {
		print XFIG "0 0 ";
	### SPECIAL - Magenta
	} elsif ($sector{type} eq "special") {
		print XFIG "5 5 ";
	### HOT - Red
	} elsif ($sector{type} eq "hot" or $sector{type} eq "chernobyl") {
		print XFIG "4 4 ";
	} else {
		print "ERROR: Unknown type: ",$sector{type},"\n";
	}

	### Depth is just 0 for now
	print XFIG "0 ";

	### Pen style, not used
	print XFIG "-1 ";

	### Area fill - No fill
	print XFIG "-1 ";

	### Style value
	print XFIG "0.000 ";

	### Join style - Miter
	print XFIG "0 ";

	### Cap style - unused
	print XFIG "0 ";

	### Radius - unused
	print XFIG "-1 ";

	### Arrows -> off
	print XFIG "0 0 ";

	### Number of points in the line
	print XFIG $sector{numvertices} + 1,"\n";

	### Now loop through the vertices
	my @verts = @{$sector{verts}};
	foreach my $v (@verts) {
		my $x = $v->[0];
		my $y = $v->[1];
		my $z = $v->[2];

		### EMI
		if ($game eq "EMI") {
			print XFIG $lowest[0] + int($x * 1000), " ", $lowest[2] + int($z * 1000), "\n";
		### GRIM
		} else {
			print XFIG $lowest[0] + int($x * 1000), " ", $lowest[1] + int($y * 1000), "\n";
		}
	}
	### Return to the first vert
	my $x = $verts[0]->[0];
	my $y = $verts[0]->[1];
	my $z = $verts[0]->[2];

	### EMI
	if ($game eq "EMI") {
		print XFIG $lowest[0] + int($x * 1000), " ", $lowest[2] + int($z * 1000), "\n";
	### GRIM
	} else {
		print XFIG $lowest[0] + int($x * 1000), " ", $lowest[1] + int($y * 1000), "\n";
	}
}
close XFIG;
