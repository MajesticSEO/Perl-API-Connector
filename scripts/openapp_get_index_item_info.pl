
use strict;
use warnings;
use lib '../lib';

use MJ12::Remote::ApiService;


# check input.
my $script = __FILE__;
die "usage: $script privatekey accesstoken item1 item2 item3 (where item is a domain,subdomain or url)" unless scalar(@ARGV > 2);

my $endpoint = "http://enterprise.majesticseo.com/api_command";

# credentials.
my $private_key = shift @ARGV;
my $access_token = shift @ARGV;

# create query parameters.
my %params = (
	'items' => scalar(@ARGV),
	'datasource' => 'fresh',
				);

for (my $i = 0; $i < scalar(@ARGV); $i++)
{
	$params{'item'.$i} = $ARGV[$i];
}

my $api_service = new MJ12::Remote::ApiService('ApplicationId' => $private_key, 'Endpoint' => $endpoint);
my $response = $api_service->executeOpenAppRequest('AccessToken' => $access_token, 'CommandName' => 'GetIndexItemInfo', 'Params' => \%params);

# check the response code.
if($response->isOK())
{
	# dump results table.
	my $results = $response->tableForName('Name' => 'Results');

	foreach my $row (@{$results->rowsAsArrayRef()})
	{
		my $item = $row->{'Item'};
		print "\n<$item>\n";

		# each row is a hashref.
		foreach my $key (sort keys %{$row})
		{
			unless ($key eq 'Item')
			{
				my $value = $row->{$key};
				print " $key ... $value\n";
			}
		}
	}

	if("http://developer.majesticseo.com/api_command" eq $endpoint)
	{
        print "\n\n***********************************************************" .
            "*****************";

        print "\n\nEndpoint: " . $endpoint;

        print "\n\nThis program is hard-wired to the Developer API " .
            "and hence the subset of data \nreturned will be substantially " .
            "smaller than that which will be returned from \neither the " .
            "Enterprise API or the Majestic SEO website.";

        print "\n\nTo make this program use the Enterprise API, change " .
            "the endpoint to: \nhttp://enterprise.majesticseo.com/api_command.";

        print "\n\n***********************************************************" .
            "*****************\n";
    }
}
else
{
	print "\n\nERROR MESSAGE:";
    print "\n" . $response->errorMessage;

    print "\n\n\n***********************************************************" .
        "*****************";

    print "\n\nDebugging Info:";
    print "\n\n  Endpoint: \t" . $endpoint;
    print "\n  OpenApp \"private key\": \t" . $private_key;
    print "\n  Access Token: \t" . $access_token;

    if("http://enterprise.majesticseo.com/api_command" eq $endpoint)
	{
        print "\n\n  Is this API Key valid for this Endpoint?";

        print "\n\n  This program is hard-wired to the Enterprise API.";

        print "\n\n  If you do not have access to the Enterprise API, " .
            "change the endpoint to: \n  http://developer.majesticseo.com/api_command.";
    }

    print "\n\n***********************************************************" .
        "*****************\n";
}



=head1 LICENSE

Copyright 2015, Majestic-12 Ltd trading as Majestic
https://majestic.com

All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.

    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.

    * Neither the name of Majestic-12 Ltd, its trademarks, nor any contributors
      to the software may be used to endorse or promote products derived from
      this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Majestic-12 Ltd BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut


