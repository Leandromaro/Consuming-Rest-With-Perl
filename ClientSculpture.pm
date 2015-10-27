#!/usr/bin/perl
use strict;
use warnings;
use HTTP::Tiny;
use Time::HiRes qw/sleep/;
use JSON qw/decode_json/;
use Moose;
#
#my $server = 'http://resistenciarte.org/api/v1/';
#my $ping_endpoint = 'node?parameters[type]=autores';
#my $url = $server.$ping_endpoint;
#my $headers = { accept => 'application/json' };

#my $response = rest_request($url, $headers);
#my $status = ($response->{ping}) ? 'up' : 'down';
#print "Service is ${status}\n";
has name=> (is=>'rw' , isa => 'Str');


sub request_author {
	my $server = 'http://resistenciarte.org/api/v1/';
	my $ping_endpoint = 'node?parameters[type]=autores';
	my $url = $server.$ping_endpoint;
	my $headers = { accept => 'application/json' };
  	#my ($url, $headers, $attempts) = @_;
  	my $attempts //= 0;
  	my $http = HTTP::Tiny->new();
  	my $response = $http->get($url, {headers => $headers});
  	if($response->{success}) {
	    my $content = $response->{content};
	    my $json = decode_json($content);
	    ##
	    my $arrayref = decode_json $json;
		my $name = shift;
		foreach my $item( @$arrayref ) { 
		    # fields are in $item->{Year}, $item->{Quarter}, etc.
	    	my $author= $item->{title};
		    if ($author =~ /$name/) {
				return $json;    
		    }
		}      
	    ##
  	}
  	$attempts++;
  	my $reason = $response->{reason};
	  if($attempts > 3) {
	    warn 'Failure with request '.$reason;
	    die "Attempted to submit the URL $url more than 3 times without success";
	  }
  	my $response_code = $response->{status};
  # we were rate limited
  if($response_code == 429) {
    my $sleep_time = $response->{headers}->{'retry-after'};
    sleep($sleep_time);
    return rest_request($url, $headers, $attempts);
  }

  die "Cannot do request because of HTTP reason: '${reason}' (${response_code})";
}
1;