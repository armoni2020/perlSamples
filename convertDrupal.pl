#!/user/bin/perl

local $/;

my $directory = shift;  #get directory from command line.
opendir(DH, $directory);
my @files = readdir(DH);  #get a list of files
closedir(DH);

my $outputdir = $directory . "_drupal";
mkdir $outputdir unless -d $outputdir;  #build directory for results without disturbing orgiginals

foreach my $file (@files) {
  # skip . and ..
  next if($file =~ /^\.$/);
  next if($file =~ /^\.\.$/);  

  chdir $directory;   #open input directory
  my $filename = $file;   #just to make the code more readable
  open(FILE, $filename) or die "Can't open $filename: $!";  #create a filehandle called FILE and connect to the file.
  my $string = <FILE>;  #read the entire file into an array in memory.
  close(FILE);

  $test = $string;
  $test =~ m/<title.*title>/i;  #grab the title of the page   -- strip out <title> tags
  my $title = "$&\n";   #set the $title variable for rebuilding phase

  $test2 = $string;
  $test2 =~ m/<body(.*)body>/is;    #grab the body of the page  -- strip out <body> tags
  my $content = "$&\n";
  
  #strip out remaining unwanted text
  $content =~ s/(.*)www.place.yoururl.com(.*)//;
  $content =~ s/(.*)www.yoururl.com(.*)//;
  $content =~ s/<body(.*)//i;
  $content =~ s/(.*)body>//i;

  chdir("..");
  chdir $outputdir; #open output directory
  #build output file
  $filename = $file;
  open(FILE2, ">>$filename") or die "Can't open $filename: $!";
  print FILE2 $title;
  print FILE2 $content;
  close (FILE2);
  chdir("..");

}


