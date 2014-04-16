#!/usr/bin/perl -w
use strict;
use Data::Dumper;

my $golden_vector_list = "retailoutput.txt";
my $test_vector_list = "testoutput.txt";
my $tolerance = 0.005;

### Open the golden vector list and read it in
open (GF, $golden_vector_list);
my @gf = <GF>;
close (GF);

### Open the test file
open (TF, $test_vector_list);
my @tf = <TF>;
close (TF);

my $test_id = 0;
my $errors = 0;
my $tf_idx = 0;
my $print_line = 0;
my $count = 0;
foreach my $line (@tf) {
	### Start/End
	if ($line =~ m/test(\d+)\s+(\S+)/) {
		$test_id = $1;	
		if ($2 eq "start") {
			$errors = 0;
			$count = 1;
			print ("Checking test$test_id...\n");
		} else {
			print ("Done with test$test_id: $errors errors out of $count tests\n");
		}
	### Parse the line
	} else {
		### Remove the parens
		chomp($line);
		$line =~ s/[\(\)]//g;
		my $gv_line = $gf[$tf_idx];
		chomp($gv_line);
		$gv_line =~ s/[\(\)]//g;

		### Split into vectors
		my @tv = split(/,/, $line);
		my @gv = split(/,/, $gv_line);

		### Expecting 3 elements
		for (my $i=0; $i<3; $i++) {
			### Error!
			if(abs($tv[$i] - $gv[$i]) > $tolerance) {
				$print_line = 1;
			}
		}
		if($print_line) {
			$errors++;
			print "Test ", $count, ": ", $gv_line, " != ", $line, "\n";
			$print_line = 0;
		}
		$count++;
	}
	$tf_idx++;
}
