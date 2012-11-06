package MJ12::Remote::Response;


use strict;
use warnings;

use XML::Simple;

use MJ12::Remote::DataTable;


=head1 NAME

MJ12::Remote::Response - Formats return values from server


=head1 VERSION

Version 0.9.3

=cut

our $VERSION = '0.9.3';

# template for a parsing error

	my %parseError = (
		Code => "??",
		ErrorMessage => "ParseError",
		FullError => ""
	);

=head1 SYNOPSIS

MJ12::Remote::Response


=head1 FUNCTIONS

new - returns an instance of the object
You can pass in a message to parse if you want

=cut

sub new_ok
{
	my $ref = shift;
	my %args = (
		'RemoteResponse' => undef,
		@_
		);

	my $class = ref( $ref ) || $ref;
	my $self = {
		'Params' => {},
		'RawXml' => '',
		'Response' => {
			'Code' => '',
			'ErrorMessage' => '',
			'FullError' => '',
						},
				};

	bless $self, $class;

	if ( $args{'RemoteResponse'} )
	{
		$self -> {'RawXml'} = $args{'RemoteResponse'};
		$self -> importData( %args );
	}

	return $self;
}


sub new_failed
{
	my $ref = shift;
	my $class = ref( $ref ) || $ref;

	my %args = (
		'Code' => undef,
		'ErrorMessage' => undef,
		@_
		);

	my $self = {
		'Params' => {},
		'RawXml' => '',
		'Response' => {
			'Code' => $args{'Code'},
			'ErrorMessage' => $args{'ErrorMessage'},
			'FullError' => $args{'ErrorMessage'},
						},
				};

	bless $self, $class;
	return $self;
}


sub rawXml
{
	my $self = shift;
	return $self->{'RawXml'};
}


=head2 importData

Takes named argument Message, which is the xml document which contains the xml message and parses it, storing the result internally

=cut

sub importData
{
	my $self = shift;

	my %args = (
		'RemoteResponse' => undef,
		@_
	);

	# parse message using xml::simple

	my $xml;

	eval
	{
		my $xs = XML::Simple -> new();

		$xml = $xs ->  XMLin( $args{'RemoteResponse'} , ForceArray => 1 );
	};

	if ( $@ )
	{
		$self -> {'Response'} = { %parseError };
		$self -> {'Response'} -> {'FullError'} = $@;
		return;
	}

	$self -> {'Response'} -> {'Code'} = $xml -> {'Code'};
	$self -> {'Response'} -> {'ErrorMessage'} = $xml -> {'ErrorMessage'};
	$self -> {'Response'} -> {'FullError'} = $xml -> {'FullError'};

	# The oddly named "Global Vars"
	if ( ref $xml -> {'GlobalVars'} eq "ARRAY" )
	{
		# get the first item off of the array
		my $ref = shift @{ $xml -> {GlobalVars} };

		# and copy all the items into params
		$self -> {'Params'} = {};

		while ( my ($k,$v) = each %{$ref} )
		{
			if ( ! ref $v )
			{
				$self -> {'Params'} -> {$k} = $v;
			}
		}
	}

	if ( ref $xml -> {'DataTables'} eq "ARRAY" )
	{
		my $ref = shift @{ $xml -> {DataTables} };
		foreach my $d ( @{ $ref -> {DataTable} } )
		{
			my $dt = new MJ12::Remote::DataTable ( Data => $d );
			$self -> {'Tables'} -> { $dt -> tableName } = $dt;
		}
	}

	return;

}


=head2 isOK

Indicates whether this response is ok.

=cut

sub isOK
{
	my $self = shift;
	return $self -> {'Response'} -> {'Code'} eq 'OK';
}


=head2 code

Returns the message code - "OK" represents predicted state, all else represents an error.

=cut

sub code
{
	my $self = shift;
	return $self -> {'Response'} -> {'Code'};
}


=head2 errorMessage

Returns the Error message ( if present ) from the message

=cut

sub errorMessage
{
	my $self = shift;
	return $self -> {'Response'} -> {'ErrorMessage'};
}


=head2 fullError

Returns the Full Error message ( if present ) from the message

=cut

sub fullError
{
	my $self = shift;
	return $self -> {'Response'} -> {'FullError'};
}


=head2 globalParams

Exposes a hash of all global parameters.

=cut

sub globalParams
{
	my $self = shift;
	return %{$self->{'Params'}};
}


=head2 paramForName

Takes named argument "Name" - representing the name of the parameter to be quried

usage:

  my $setting = $response -> paramForName( Name => "setting" );

=cut

sub paramForName
{
	my $self = shift;

	my %args = (
		'Name' => undef,
		@_
	);

	if ( ref $self -> {'Params'} eq "HASH" )
	{
		return $self -> {'Params'} -> {$args{Name}};
	}

	return;
}


=head2 tableForName

Takes named argument "Name" - representing the name of the table - if it exists a table object is returned

usage:

  my $table = $response -> tableForName( Name => "table" );

=cut

sub tableForName
{
	my $self = shift;

	my %args = (
		'Name' => undef,
		@_
	);

	if ( ! defined $args{'Name'} )	# more null objectish
	{
		return new MJ12::Remote::DataTable ();
	}

	if ( ! exists $self -> {'Tables'} -> { $args{'Name'} } )
	{
		return new MJ12::Remote::DataTable ();
	}

	return $self -> {'Tables'} -> { $args{'Name'} };

}


=head1 LICENSE

Version 0.9.3
Copyright (c) 2011, Majestic-12 Ltd
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.

    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.

    * Neither the name of the Majestic-12 Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.


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

1; # End of MJ12::Remote::Response
