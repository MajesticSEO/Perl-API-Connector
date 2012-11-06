package MJ12::Remote::DataTable;


use strict;
use warnings;


=head1 NAME

MJ12::Remote::DataTable - Formats return values from server


=head1 VERSION

Version 0.9.3

=cut

our $VERSION = '0.9.3';

=head1 SYNOPSIS

MJ12::Remote::DataTable


=head1 FUNCTIONS

new - returns an instance of the object

=cut

sub new()
{

	my $ref = shift;

	my %args = (
		Data => undef,
		@_
		);

	my $class = ref( $ref ) || $ref;

	my $self = {
		'Name' => "",
		'Headers' => [],
		'Rows' => [],
		'Params' => {},
	};

	bless $self, $class;

	$self -> importData( %args );

	return $self;
}


=head2 importData

Converts the data from XML::Simples output format to something usable

=cut

sub importData
{

	my $self = shift;

	my %args = (
		Data => undef,
		@_
	);

	if ( ref $args{Data} eq "HASH" )
	{
		$self -> {Name} = $args{Data} -> {Name};
		$self -> {Headers} = [$self -> _split ( $args{Data} -> {Headers} )];

		if ( "ARRAY" eq ref $args{Data} -> {Row} )
		{
			$self -> {Rows} = [];
			foreach my $el ( @{ $args{Data} -> {Row} } )
			{
				# extract row data and use a hash slice to convert it to a hash using the headers
				my @els = $self -> _split ( $el );
				my %row;
				@row{ @{ $self -> {Headers} } } = @els;

				push @{ $self -> {Rows} }, \%row;

				while ( my ($k,$v) = each %row )
				{
					if ($v eq " ")
					{
						$row{$k} = "";
					}
				}
			}
		}

		LOOP: foreach my $key ( keys %{ $args{Data} } )
		{
			next LOOP if ( $key eq "Name" );
			next LOOP if ( $key eq "Headers" );
			next LOOP if ( ref $args{Data} -> {$key} );

			$self -> {Params} -> {$key} = $args{Data} -> {$key};

		}
	}
}


=head2 _split

Splits the input from pipe seperated form into an array.

RPC code splits on pipe chars, and double pipes are intended to be quoted.

=cut

sub _split
{

	my $self = shift;
	my $text = shift;

	my @ar = split /(?<!\|)\|(?!\|)/, $text,-1;

	foreach my $v ( @ar )
	{
		$v =~s/\|\|/\|/g;
	}

	return @ar;

}


=head2 headers

Returns the table headers as an array

=cut

sub headers
{
	my $self = shift;

	return @{ $self -> {Headers} };

}


=head2 paramForName

Returns a table parameter for a given Name.

=cut

sub paramForName
{

	my $self = shift;

	my %args = (
		Name => undef,
		@_
	);

	my $key = $args{"Name"};

	if ( exists $self -> {Params} -> {$key} )
	{
		return $self -> {Params} -> {$key};
	}
	else
	{
		return undef;
	}

}


=head2 asHashPairs

Converts data where only two headers are present into key value pairs

=cut

sub asHashPairs()
{

	my $self = shift;

	my %hash;

	my ($keyfield,$valuefield) = @{ $self };

	foreach my $row ( @{ $self -> {Rows} = [] } )
	{
		$hash{ $row -> { $keyfield } } = $row -> { $valuefield };
	}

	return %hash;

}


=head2 rowCount

returns number of rows

=cut

sub rowCount
{
	my $self = shift;

	return scalar @{ $self -> {Rows} };
}


=head2 rowsAsArrayRef

returns an the raw array ref of the row data

=cut

sub rowsAsArrayRef
{

	my $self = shift;

	return $self -> {Rows};

}


=head2 rowsAsArray

returns the rows as an array - note - the underlying hashes are references and hence changes are persisted.

=cut

sub rowsAsArray
{

	my $self = shift;

	return @{ $self -> {Rows} };

}


=head2 tableName

returns the table name

=cut

sub tableName
{
	my $self = shift;
	return $self -> {Name};
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

1; # End of MJ12::Remote::DataTable
