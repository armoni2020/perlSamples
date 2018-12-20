#!/user/bin/perl

local $/;

my $directory = shift;  #get directory from command line.
opendir(DH, $directory);
my @files = readdir(DH);
closedir(DH);

my $outputdir = $directory . "_drupal";
mkdir $outputdir unless -d $outputdir;

foreach my $file (@files) {
  # skip . and ..
  next if($file =~ /^\.$/);
  next if($file =~ /^\.\.$/);  

  chdir $directory;
  my $filename = $file;
  open(FILE, $filename) or die "Can't open $filename: $!";  #create a filehandle called FILE and connect to the file.
  my $string = <FILE>;  #read the entire file into an array in memory.
  close(FILE);

  $test = $string;
  $test =~ m/<title.*title>/i;
  my $title = "$&\n";

  $test2 = $string;
  $test2 =~ m/<body(.*)body>/is;
  my $content = "$&\n";
  $content =~ s/(.*)www.place.yoururl.com(.*)//;
  $content =~ s/(.*)www.yoururl.com(.*)//;
  $content =~ s/<body(.*)//i;
  $content =~ s/(.*)body>//i;

  chdir("..");
  chdir $outputdir;
  $filename = $file;
  open(FILE2, ">>$filename") or die "Can't open $filename: $!";
  print FILE2 $title;
  print FILE2 $content;
  close (FILE2);
  chdir("..");

}


