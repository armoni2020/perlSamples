#!/user/bin/perl
use strict;
use 5.018;
use JSON::MaybeXS qw(encode_json decode_json);
use JSON::Repair 'repair_json';

local $/;


#################################################
# Takes in a prepared file from a mongodb log	#
# parses input file and discovers query shapes	#
# creates output file for use in aggregation	#
#################################################

my $filename = "input.txt";		#file created by another script
my $outputFilename = "output.txt";	#output file to be used by aggregation function

open(FILE, $filename) or die "Can't open $filename: $!";  #create a filehandle called FILE and connect to the file.
my $string = <FILE>;  #read the entire file into an array in memory.
close(FILE);

my @lines = split("\n",$string);

my $count = 1;
my $worstOffender = "";
my $worstTime = 0;

open(FILEOUT, ">$outputFilename") or die "Can't open $outputFilename: $!";  #create a filehandle called FILEOUT and connect to the file.


		print "Highest cost query:";
foreach my $line (@lines) {

	if ($line =~ /(\d*)ms$/) {
		my $time = $1;

		#remove extra data, special characters, and date() function to prepare for JSON conversion
		$line =~ s/ms\s*\z//;
		$line =~ s/^.*{ find/{ find/;
		$line =~ s/\"([^\" ]* *)+\"/0/g;
		$line =~ s/\\[^\\]*\\//g;
		$line =~ s/new Date\(\d*\)/0/g;
	
		#split by whitespace to retrieve key and scrub line for additional unwanted characters
		my @words = split(/\s+/, $line);
		my $key = $words[1];
		
		my $cleanedLine = "";
		my $last = 0;
		foreach my $word (@words) {
			if ($word =~ /[\\\/\(\)]/) {
				if ($last == 1) {
					$last = 1;
				} else {
					$cleanedLine = $cleanedLine . "0";
					$last = 1;
				}
			} else {
				$last = 0;
				$cleanedLine = $cleanedLine . " " . $word;
			}
		}
		
		#work with only find function
		if ($line =~ /^.*{ find/) {
			print FILEOUT "$key,";	#placeholder for future expansion to multiple functions
			my $newLine = $cleanedLine;	#copy to new variable for readability
			
			if ($time > $worstTime) {	#keep track of worst offender (highest cost query)
				$worstTime = $time;
				$worstOffender = $newLine;
			}
			
			my $myHashEncoded = repair_json($newLine);	#identify JSON from input line and convert to uniform format
			my $myHashRefDecoded = decode_json($myHashEncoded);	#decode JSON and save to HASH table
			my %myHashDecoded = %$myHashRefDecoded;		#convert HashRef to Hash for traverse
			
			#sort hash to identify query shape and print to output
			foreach my $key (sort keys %myHashDecoded) {
				print FILEOUT "$key,";
			}
			print FILEOUT "ms: $time\n";	#print time cost of query
		}
		$count++;	#increment counter ... can be deprecated
	}
}

close(FILEOUT);
print $worstOffender;	#display worst offender to the console


exit 0;
