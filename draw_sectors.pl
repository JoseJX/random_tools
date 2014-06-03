#!/usr/bin/perl -w
use strict;
use Data::Dumper;

###############################################################################
### Subroutines
###############################################################################
### Color code to avoid duplication
sub get_color {
	my $type = shift;

	### WALK - Blue
	if ($type eq "walk") {
		return 1;
	### FUNNEL - Yellow
	} elsif ($type eq "funnel") {
		return 6;
	### CAMERA - Black
	} elsif ($type eq "camera") {
		return 0;
	### SPECIAL - Magenta
	} elsif ($type eq "special") {
		return 5;
	### HOT - Red
	} elsif ($type eq "hot" or $type eq "chernobyl") {
		return 4;
	} else {
		print "ERROR: Unknown type: ",$type,"\n";
		return 0;
	}
	return 0; ### Shouldn't get here
}

### Find the center of a bounding box
sub bb_center {
	my @verts = @{shift()};
	my ($x, $y, $nx, $ny);
	my ($cx, $cy) = (0, 0);
	my $area = 0;

	my ($lowX, $lowY, $highX, $highY) = (99999.0, 99999.9, -99999.9, -99999.9);
	for (my $i=0; $i<$#verts; $i++) {
		if ($verts[$i]->[0] > $highX) {
			$highX = $verts[$i]->[0];
		}
		if ($verts[$i]->[0] < $lowX) {
			$lowX = $verts[$i]->[0];
		}
		if ($verts[$i]->[1] > $highY) {
			$highY = $verts[$i]->[1];
		}
		if ($verts[$i]->[1] < $lowY) {
			$lowY = $verts[$i]->[1];
		}
	}

	$cx = int($lowX + ($highX - $lowX)/2);
	$cy = int($lowY + ($highY - $lowY)/2);
	return ($cx, $cy);
}

### Convert coordinates to XFIG coordinates
sub conv_verts {
	my @new_verts;
	my @verts = @{shift()};
	my $scale = shift();
	my @offset = @{shift()};
	my $game = shift();

	### Loop over the verts
	for (my $i=0; $i<$#verts + 1; $i++) {
		my $x = $offset[0] + int($verts[$i]->[0] * 1000);
		my $y;
		### EMI
		if ($game eq "EMI") {
			$y = $offset[2] + int($verts[$i]->[2] * 1000);
		### GRIM
		} else {
			$y = $offset[1] + int($verts[$i]->[1] * 1000);
		}
		push @new_verts, [int($scale * $x), int($scale * $y)];
	}
	### Add the start to the list
	push @new_verts, [ $new_verts[0]->[0], $new_verts[0]->[1] ];
	return \@new_verts;
}

###############################################################################
### Main code
###############################################################################

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

### Adjust the high and low values into ints so we can shift the actual verts
### so that there are no negative verts
for (my $i=0; $i<3; $i++) {
	$lowest[$i] = int($lowest[$i] * 1000);
	if ($lowest[$i] > 0) {
		$lowest[$i] = 0;
	} else {
		$lowest[$i] = abs($lowest[$i]);
	}

	$highest[$i] = $lowest[$i] + int($highest[$i] * 1000);
}

### Set the scale - 1200ppi
### US Letter is 8.5x11 inches
my $xdim = 11 * 1200;
my $ydim = 8.5 * 1200;

### Scaling
my $xs = 1.0;
if ($highest[0] > $xdim)  {
	$xs = $xdim / $highest[0];
}
my $ys;
if ($game eq "EMI") {
	if ($highest[2] > $ydim) {
		$ys = $ydim / $highest[2];
	}
} else {
	if ($highest[1] > $ydim) {
		$ys = $ydim / $highest[1];
	}
}

my $scale = 1.0;
if ($xs < $scale) {
	$scale = $xs;
}
if ($ys < $scale) {
	$scale = $ys;
}

### Convert the sector list to XFIG polygons
open XFIG, ">".$ARGV[1].".fig" or die "Can't open the xfig file for writing.\n";
print XFIG "#FIG 3.2\n";
print XFIG "Landscape\n";
print XFIG "Center\n";
print XFIG "Inches\n";
print XFIG "Letter\n";
print XFIG "100.00\n";
print XFIG "Single\n";
print XFIG "-2\n";
print XFIG "1200 2\n";

### All sectors will be represented by polylines
foreach my $k (keys %sectors) {
	my %sector = %{$sectors{$k}};

	### Filter?
	next if (defined($filter) and $sector{type} ne $filter);

	### Add a comment with the name
	print XFIG "# ",$sector{name}," ($k)\n";

	### Create the polyline object (type 2), type is polygon (type 3)
	print XFIG "2 3 ";
	### Determine visibility, solid if visible, dashed if not, thickness is always 1
	if ($sector{visibility}) {
		print XFIG "0 1 ";
	} else {
		print XFIG "1 1 ";
	}
	### Determine the pen and fill color based on the type
	my $color = get_color($sector{type});
	print XFIG "$color $color ";
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
	my @verts = @{conv_verts($sector{verts}, $scale, \@lowest, $game)};
	foreach my $v (@verts) {
		print XFIG $v->[0], " ", $v->[1], "\n";
	}

	### Draw the text for this sector
	print XFIG "# Text object for ", $sector{name}, " ($k)\n";
	### Text object is always 4
	print XFIG "4 ";
	### Centered
	print XFIG "1 ";
	### Color
	print XFIG "$color ";
	### Depth
	print XFIG "0 ";
	### Pen Style - unused
	print XFIG "-1 ";
	### Font - Courier
	print XFIG "12 ";
	### Font Size
	print XFIG "10 ";
	### Angle (in radians)
	print XFIG "0.0000 ";
	### Font Flags - Sans Serif
	print XFIG "4 ";
	### Height, Length
	print XFIG "105 ", 90 * length($k), " ";
	### X, Y of Center
	my ($text_x, $text_y) = bb_center(\@verts);
	print XFIG "$text_x $text_y ";
	### Text (sector ID), terminated by \001
	print XFIG $k,"\\001\n";
}
close XFIG;
