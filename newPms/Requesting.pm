#!/usr/bin/perl
package Requesting;

use warnings; 					#good practice
use strict;						#good practice
use HTTP::Tiny;
use Time::HiRes qw/sleep/;
use JSON qw/decode_json/;
use Moose;

sub request{
    my ($self, $url) = @_;
	my $headers = { accept => 'application/json' };
    my $attempts //= 0;						
    my $http = HTTP::Tiny->new();
    my $response = $http->get($url, {headers => $headers});
    
    if($response->{success}) {
        my $content = $response->{content};   
        return $content;       
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
		return request($url, $headers, $attempts);
	}
}

1;