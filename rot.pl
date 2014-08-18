#!/usr/bin/perl -w
use strict;
use Data::Dumper;

if (!defined($ARGV[0])) {
	print "Please supply an order in the form of: XYZ\n";
	exit;
}
my $ord = uc($ARGV[0]);
if ($ord !~ m/[XYZ][XYZ][XYZ]/) {
	print "Please supply an order in the form of: XYZ\n";
	exit;
}

### Setup the rotations
my %rot;
$rot{"X"} = [ [ "1", "0", "0" ],
	  [ "0", "Cx", "-Sx" ],
	  [ "0", "Sx", "Cx" ] ];

$rot{"Y"} = [ [ "Cy", "0", "Sy" ],
	  [ "0", "1", "0" ],
	  [ "-Sy", "0", "Cy" ]];

$rot{"Z"} = [ [ "Cz", "-Sz", "0" ],
	  [ "Sz", "Cz", "0" ],
	  [ "0", "0", "1" ]];

### Multiplication
sub mult {
	my $d1 = shift;
	my $d2 = shift;
	my $r = [ [], [], [] ];

	for (my $i = 0; $i < 3; $i++) {
		for (my $j = 0; $j < 3; $j++) {
			$$r[$i][$j] = "";
			for (my $k = 0; $k < 3; $k++) {
				if (($$d1[$i][$k] eq "0") or ($$d2[$k][$j] eq "0")) {
					next;
				}
				
				if ($k != 0 and length($$r[$i][$j]) != 0) {
					$$r[$i][$j] = $$r[$i][$j] . " + ";
				}
				if (($$d1[$i][$k] eq "1") and ($$d2[$k][$j] eq "1")) {
					$$r[$i][$j] = "1";
				} elsif (($$d1[$i][$k] eq "1")) {
					$$r[$i][$j] = $$r[$i][$j] . $$d2[$k][$j];
				} elsif (($$d2[$k][$j] eq "1")) {
					$$r[$i][$j] = $$r[$i][$j] . $$d1[$i][$k];
				} else {
					### Multiply the components
					my $mult = $$d1[$i][$k] . $$d2[$k][$j];
					### Count the number of -'s by matches
					my @count = ($mult =~ /-/g);
					### Remove the -'s
					$mult =~ s/-//g;
					### Decide on the sign (note that count is 1 less than the #)
					if ($#count % 2 == 0) {
						$mult = "-".$mult;	
					}
					$$r[$i][$j] = $$r[$i][$j] . $mult;
				}
			}
			if (length($$r[$i][$j]) == 0) {
				$$r[$i][$j] = "0";
			}
		}
	}
	return $r;
}

### Print the matrix
sub printMat {
	my $m = shift;
	for (my $i = 0; $i < 3; $i++) {
		for (my $j = 0; $j < 3; $j++) {
			printf ("%20s\t", $$m[$i][$j]);	
		}
		print "\n";
	}
}

### Find the angle equations
sub getAE {
	my $m = shift;
	my $gimbal = "";
	my $gimbalOp = "";
	
	### First, identify the position that has a single sin/cos
	for (my $i = 0; $i < 3; $i++) {
		for (my $j = 0; $j < 3; $j++) {
			if ($$m[$i][$j] =~ m/^(-)?([SC])([xyz])$/) {
				print "\t",$3, " = ";
				if (defined($1)) {
					print "-";
				}
				if ($2 eq "S") {
					print "asin(M[$i][$j])\n";
				} else {
					print "acos(M[$i][$j])\n";
				}
				$gimbal = $3;
				$gimbalOp = $2;

				### Exit the loop...
				$i = $j = 5;
			}
		}
	}
	
	### Now, we're going to look for components that we can make the tangents with
	### First, break each of the elements up into component pieces
	### $b holds strings of all the pieces and $pm holds the sign of the piece
	my $b = [ [], [], [] ];
	my $pm = [ [], [], [] ];
	my $l = [ [], [], [] ];
	for (my $i = 0; $i < 3; $i++) {
		for (my $j = 0; $j < 3; $j++) {
			$$b[$i][$j] = "";
			my @plus = split(/ \+ /, $$m[$i][$j]);
			for (my $k = 0; $k <= $#plus; $k++) {
				$plus[$k] =~ s/(-)//;
				### Mark with a 1 if we have a minus
				if (defined($1)) {
					$$pm[$i][$j] = 1;
				} else {
					$$pm[$i][$j] = 0;
				}
				$$b[$i][$j] = $$b[$i][$j] . $plus[$k];
			}
			$$l[$i][$j] = length($$b[$i][$j]);
		}
	}

	### Now, compare lines
	my %sets;
	for (my $i = 0; $i < 3; $i++) {
		for (my $j = 0; $j < 3; $j++) {
			for (my $k = 0; $k < 3; $k++) {
				for (my $h = 0; $h < 3; $h++) {
					### If this length matches, check the difference
					if ($$l[$i][$j] == $$l[$k][$h]) {
						my @partsA = split("", $$b[$i][$j]);
						my @partsB = split("", $$b[$k][$h]);

						### Loop one less because we don't need to compare the last letter...
						my $diffs = 0;
						my $sineInA = 0;
						my $ax = "";
						for (my $p = 0; $p < $#partsA; $p++) {
							if ($partsA[$p] ne $partsB[$p] and $partsA[$p] =~ m/([CS])/ and $partsA[$p + 1] eq $partsB[$p + 1]) {
								$diffs++;	
								if (defined($1) and $1 eq "S") {
									$sineInA = 1;
								} else {
									$sineInA = 0;
								}
								$ax = $partsA[$p + 1];
							}
						}
						if ($diffs == 1) {
							next if (defined($sets{ $$b[$k][$h] . $$b[$i][$j] }));
							$sets{ $$b[$i][$j] . $$b[$k][$h] } = [$i, $j, $k, $h, $sineInA, $ax];
						}
					}
				}
			}
		}
	}

	### Okay, we've got the tangent components, print out the solution for the rotation
	foreach my $key (keys(%sets)) {
		my @pos = @{$sets{$key}};

		### If the Sine component is in A
		if ($pos[4]) {
			print "\t",$pos[5], " = ";
			if ($$pm[$pos[0]][$pos[1]] != $$pm[$pos[2]][$pos[3]]) {
				print("-");	
			}
			print "arctan2(";
			print "M[", $pos[0],"][", $pos[1],"], ";
			print "M[", $pos[2],"][", $pos[3],"])\n";
		} else {
			print "\t", $pos[5], " = ";
			print "arctan2(";
			print "M[", $pos[2],"][", $pos[3],"], ";
			print "M[", $pos[0],"][", $pos[1],"])\n";
		}
	}

	### And now, let's report the gimbal locked axis and at what values
	print " * Gimbal lock on the $gimbal axis at: ";
	if ($gimbalOp eq "S") {
		print ("S\n");
	} else {
		print ("C\n");
	}
}

### Generate a matrix and conversion
sub doOrder {
	my $order = shift;
	my @ord = split //, $order;
	my $mat = mult(mult($rot{$ord[0]}, $rot{$ord[1]}), $rot{$ord[2]});
	print "Order: ", $order,":\n";
	print " * Matrix:\n";
	printMat($mat);
	print " * To Euler:\n";
	getAE($mat);
}

doOrder($ord);
