package MJ12::Remote::ApiService;


use strict;
use warnings;

use MJ12::Remote::Response;

use HTTP::Request;
use LWP::UserAgent;
use URI::Escape;


=head1 NAME

MJ12::Remote::ApiService - Acts as a facade to the majesticseo api service.


=head1 VERSION

Version 0.9.4

=cut

our $VERSION = '0.9.4';

=head1 SYNOPSIS

MJ12::Remote::ApiService




=head1 METHODS

=head2 new

This method returns a new instance of MJ12::Remote::ApiService.

'ApplicationId' is the unique identifier for your application - for api requests, this is your "api key" ... for OpenApp request, this is your "private key".
'Endpoint' is required and must point to the url you wish to target; ie: enterprise or developer.

    my $api_service = new MJ12::Remote::ApiService('ApplicationId' => '9A7R8Q4T8FA7GBYA4', 'Endpoint' => 'http://developer.majesticseo.com/api_command');

=cut

sub new
{
	my $ref = shift;
	my %args = @_;

	$args{'ApplicationId'} = $args{'ApplicationApiKey'} if (defined $args{'ApplicationApiKey'} and !defined $args{'ApplicationId'});	# backward compat.

	foreach my $arg_name (qw/ApplicationId Endpoint/)
	{
		die "constructor args must contain '$arg_name' parameter" unless defined ($args{$arg_name});
	}

	my $class = ref($ref) || $ref;
	my $self = {
		'ApplicationId' => $args{'ApplicationId'},
		'Endpoint' => $args{'Endpoint'},
				};

	bless ($self, $class);
	return $self;
}


=head2 executeCommand

This method will execute the specified command as an api request.

'Name' is the name of the command you wish to execute, eg: GetIndexItemInfo
'Params' is a reference to a hash containing the command parameters.
'Timeout' specifies the amount of time to wait before aborting the transaction. This defaults to 5 seconds which should be plenty for most requests.

	my $response = $api_service->executeCommand(
									'Name' => 'GetIndexItemInfo',
									'Params' => {
										'items' => 1,
										'item0' => 'majesticseo.com',
												},
									'Timeout' => 10);

=cut

sub executeCommand
{
	my $self = shift;
	my %args = (
		'Name' => undef,
		'Params' => {},
		'Timeout' => 5,
			@_
	);

	my %params = %{$args{'Params'}};

	$params{'app_api_key'} = $self->{'ApplicationId'};
	$params{'cmd'} = $args{'Name'};

	return $self->_executeRequest('Params' => \%params, 'Timeout' => $args{'Timeout'});
}


=head2 executeOpenAppRequest

This will execute the specified command as an OpenApp request.

'AccessToken' is the token provided by the user to access their resources.
'CommandName' is the name of the command you wish to execute, eg: GetIndexItemInfo
'Params' is a reference to a hash containing the command parameters.
'Timeout' specifies the amount of time to wait before aborting the transaction. This defaults to 5 seconds which should be plenty for most requests.

	my $response = $api_service->executeCommand(
									'AccessToken' => 'F3FFBM7H3KXB',
									'CommandName' => 'GetIndexItemInfo',
									'Params' => {
										'items' => 1,
										'item0' => 'majesticseo.com',
												},
									'Timeout' => 10);

=cut

sub executeOpenAppRequest
{
	my $self = shift;
	my %args = (
		'AccessToken' => undef,
		'CommandName' => undef,
		'Params' => {},
		'Timeout' => 5,
			@_
				);

	my %params = %{$args{'Params'}};

	$params{'accesstoken'} = $args{'AccessToken'};
	$params{'privatekey'} = $self->{'ApplicationId'};
	$params{'cmd'} = $args{'CommandName'};

	return $self->_executeRequest('Params' => \%params, 'Timeout' => $args{'Timeout'});
}


=head2 _executeRequest

This will execute the specified command as an OpenApp request.

'Params' is a reference to a hash containing the command parameters.
'Timeout' specifies the amount of time to wait before aborting the transaction. This defaults to 5 seconds which should be plenty for most requests.

	my $response = $self->_executeRequest(
									'Params' => {
										'items' => 1,
										'item0' => 'majesticseo.com',
												},
									'Timeout' => 10);

=cut

sub _executeRequest
{
	my $self = shift;
	my %args = (
		'Params' => {},
		'Timeout' => undef,
			@_
				);

	my %params = %{$args{'Params'}};

	my $request = new HTTP::Request('POST' => $self->{'Endpoint'});
	$request->content_type('application/x-www-form-urlencoded');
	$request->content(join('&', map { $_ = $_.'='.URI::Escape::uri_escape_utf8($params{$_}) } keys %params));

	my $agent = new LWP::UserAgent();
	$agent->agent('MJ12-Remote-ApiService');
	$agent->default_header('Accept-Charset' => 'utf-8');
	$agent->timeout($args{'Timeout'});

	my $http_response = $agent->request($request);

	if ($http_response->is_success())
	{
		my $response_xml = $http_response->content;

		# ensure utf-8 flag is set on response.
		utf8::decode($response_xml);

		# process response.
		return MJ12::Remote::Response->new_ok('RemoteResponse' => $response_xml);
	}
	else
	{
		return MJ12::Remote::Response->new_failed('Code' => 'ConnectionError', 'ErrorMessage' => 'Problem connecting to data source');
	}
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

1; # End of MJ12::Remote::ApiService
