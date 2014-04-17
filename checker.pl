#!/usr/bin/perl -w
use strict;
use Data::Dumper;

if($#ARGV != 1) {
	print ("Usage: checker.pl <golden vectors> <test vectors>\n");
	exit(-1);
}

my $tolerance = 0.005;
my $golden_vector_list = $ARGV[0];
my $test_vector_list = $ARGV[1];

### Open the golden vector list and read it in
open (GF, $golden_vector_list) or die "Can't open the file: ".$ARGV[0]."\n";
my @gf = <GF>;
chomp(@gf);
close (GF);
my $gv = parse_test_file(\@gf);

### Open the test file
open (TF, $test_vector_list) or die "Can't open the file: ".$ARGV[1]."\n";
my @tf = <TF>;
chomp(@tf);
close (TF);
my $tv = parse_test_file(\@tf);

### Check the two vector lists
compare_results($gv, $tv);

###############################################################################
### Support Functions
###############################################################################
sub coords {
	my $line = shift;

	$line =~ s/[\(\)]//g;
	my @vec = split(/,/, $line);
	return \@vec;
}

sub parse_test_file {
	my @data = @{shift @_};
	my $results = {};
	my $test_id;
	my $test_count = 0;
	my $test_set;

	for (my $idx=0; $idx<$#data+1;) {
		my $line = $data[$idx];
		### Start/End
		if ($line =~ m/^test(\d+)\s+(\S+)/) {
			$test_id = $1;
			if ($2 eq "start") {
				$test_count = 1;
				$test_set = [];
			} elsif ($2 eq "end") {
				$results->{'test'.$test_id} = $test_set;
				undef($test_id);
			}
		### Parse an attach test
		} elsif ($line =~ m/attachTest with (\d+) actors/) {
			my $test = {};
			my $actors = $1;

			### Read in the actor positions
			for(my $i=0; $i<3; $i++) {
				$idx++;
				$test->{'actor'.$i} = coords($data[$idx]);
			}

			### Skip the result line
			$idx++;
			if (not $data[$idx] =~ m/^result/) {
				print "ERROR: unexpected input: ", $data[$idx], "\n";
				exit;
			}

			### Read in the result
			$idx++;
			$test->{'attached'} = coords($data[$idx]);
			$idx++;
			$test->{'detached'} = coords($data[$idx]);

			push @{$test_set}, $test;
			$test_count++;
		}
		$idx++;
	}
	return $results;
}

### Check if two vectors are equal within tolerance
sub equal {
	my $gv = shift;
	my $tv = shift;

	### 3 elements in the vector
	for (my $i=0; $i<3; $i++) {
		### Error!
		if(abs($tv->[$i] - $gv->[$i]) > $tolerance) {
			return 0;
		}
	}
	return 1;
}

### Return a printable vector
sub pv {
	my $vec = shift;
	return "(" . $vec->[0] . "," . $vec->[1] . "," . $vec->[2] . ")";
}

### Compare the results between two tests
sub compare_results {
	my $attached_errors = 0;
	my $detached_errors = 0;
	my $print_line = 0;
	### Good vector list
	my %gv = %{shift(@_)};
	### Test vector list
	my %tv = %{shift(@_)};
	my $testrun;

	foreach $testrun (keys(%gv)) {
		print "Checking ",$testrun,"\n";
		$attached_errors = 0;
		$detached_errors = 0;
		my @g_tests = @{$gv{$testrun}};
		my @t_tests = @{$tv{$testrun}};

		my $test_idx = 0;
		foreach my $t (@g_tests) {
			my %gold = %{$t};
			my %test = %{$t_tests[$test_idx]};

			### Check that the tests match
			if (not (equal($gold{'actor0'}, $test{'actor0'}) and equal($gold{'actor1'}, $test{'actor1'}) and equal($gold{'actor2'}, $test{'actor2'}))) {
				print "Test files don't test the same thing: Error with test $test_idx\n";
				exit;
			}

			### Check that the attached matches
			if (not equal($gold{'attached'}, $test{'attached'})) {
				$attached_errors++;
				print ("Error in Test " . ($test_idx + 1) . " Attached: A1:" . pv($gold{'actor0'}) . " A2: " . pv($gold{'actor1'}) . " A3: " . pv($gold{'actor2'}). "\n\t". pv($gold{'attached'}) . " != " . pv($test{'attached'}). "\n");
			}

			### Check that the detached matches
			if (not equal($gold{'detached'}, $test{'detached'})) {
				$detached_errors++;
				print("Error in Test " . ($test_idx + 1) . " Detached: A1:" . pv($gold{'actor0'}) . " A2: " . pv($gold{'actor1'}) . " A3: " . pv($gold{'actor2'}). "\n\t". pv($gold{'detached'}) . " != " . pv($test{'detached'}). "\n");
			}
			$test_idx++;
		}
		print "$testrun completed with $attached_errors attachment errors and $detached_errors detachment errors.\n";
	}
}
