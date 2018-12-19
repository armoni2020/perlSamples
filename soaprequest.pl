#!/user/bin/perl
use strict;
use LWP::UserAgent;
use HTTP::Request;

local $/;

#names have been changed to remove reference to actual data

my $filename = "images.csv";

  open(FILE, $filename) or die "Can't open $filename: $!";  #create a filehandle called FILE and connect to the file.
  my $string = <FILE>;  #read the entire file into an array in memory.
  close(FILE);

my @lines = split("\n",$string);

foreach my $line (@lines) {
	my @values = split(",",$line);
	my $PARAM1 = @values[0];
	my $PARAM2 = @values[1];
	my $PARAM3 = @values[2];
	if (length($PARAM3) == 9) {
		$PARAM3 = "<ns3:nine>$PARAM3</ns3:nine>";
	} else {
		$PARAM3 = "<ns3:seven>$PARAM3</ns3:seven>";
	}
	
	my $message = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\">
	<soapenv:Header>
      <ns5:MYHeader xmlns:ns2=\"http://myhome.net/schema/project\" xmlns:ns3=\"http://myhome.net/schema/tproject\" xmlns:ns4=\"http://myhome.state.net/exception/V1.1\" xmlns:ns5=\"http://myhome.net/schema/common/MyHeader/v1\">
         <ServiceName>project</ServiceName>
         <ServiceVersion>1.0</ServiceVersion>
         <TimeStamp>2018-05-09T14:46:40.914-04:00</TimeStamp>
         <RequestID>53D921AF5FF96F7A5AAFE5NR667347F9</RequestID>
        <UserID>testser</UserID>
         <InitiateTransaction>true</InitiateTransaction>
      </ns5:MyHeader>
	</soapenv:Header>
	<soapenv:Body>
      <ns3:ImageRequest xmlns:ns2=\"http://myhome.net/schema/project\" xmlns:ns3=\"http://myhome.net/schema/project\" xmlns:ns4=\"http://myhome.net/exception/V1.1\" xmlns:ns5=\"http://myhome.net/schema/common/MyHeader/v1\">
         <ns3:messageId>$PARAM1</ns3:correspondenceId>
         <ns3:imageProcess>
            <ns3:docTypeCd>$PARAM2</ns3:docTypeCd>
            $PARAM3
         </ns3:imageProcess>
      </ns3:ImageRequest>
	</soapenv:Body>
	</soapenv:Envelope>";

	my $userAgent = LWP::UserAgent->new(ssl_opts => { verify_hostname => 0});
	$userAgent->agent('Apache-HttpClient/4.1.1 (java 1.5)');
	my $request = HTTP::Request->new(POST => 'https://127.0.0.1:1234/project/sca/projectWSExport');
	$request->header(SOAPAction => '""');
	$request->content($message);
	$request->header(Host => "127.0.0.1:1234");
	$request->header(Connection => "Keep-Alive");
	$request->content_type("text/xml; charset=utf-8");
	my $response = $userAgent->request($request);

	if($response->code == 200)
	{
		print $response->as_string;
	}

	else {
		my $test = $response->code;
		print "error: $test";
	}

}
use POSIX qw(strftime);
print strftime "%Y-%m-%d %H:%M:%S", localtime $^T;

exit 0;

