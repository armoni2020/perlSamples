#!/user/bin/perl
use strict;
use 5.018;
use JSON::MaybeXS qw(encode_json decode_json);
use JSON::Repair 'repair_json';

local $/;

my $filename = "input.txt";
my $outputFilename = "output.txt";

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

		$line =~ s/ms\s*\z//;
		$line =~ s/^.*{ find/{ find/;
		$line =~ s/\"([^\" ]* *)+\"/0/g;
		$line =~ s/\\[^\\]*\\//g;
		$line =~ s/new Date\(\d*\)/0/g;
	
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
		
		if ($line =~ /^.*{ find/) {
			print FILEOUT "$key,";
			my $newLine = $cleanedLine;
			
			if ($time > $worstTime) {
				$worstTime = $time;
				$worstOffender = $newLine;
			}
			
			my $myHashEncoded = repair_json($newLine);
			my $myHashRefDecoded = decode_json($myHashEncoded);
			my %myHashDecoded = %$myHashRefDecoded;
	
			foreach my $key (sort keys %myHashDecoded) {
				print FILEOUT "$key,";
			}
			print FILEOUT "ms: $time\n";
		}
		$count++;
	}
}

close(FILEOUT);
print $worstOffender;


exit 0;
