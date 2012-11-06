#!perl -T

use Test::More tests => 4;

use strict;
use MJ12::Remote::Response;


# create response.
my $response = MJ12::Remote::Response->new_failed('Code' => 'xxx', 'ErrorMessage' => 'something has gone wrong');

# check response.
is($response->code, 'xxx', 'wrong response code');
is($response->errorMessage, 'something has gone wrong', 'wrong error message');

my %params = $response->globalParams;
is_deeply(\%params, {}, 'wrong params');

my $unknown_table = $response->tableForName('Name' => 'unknown');
is($unknown_table->rowCount, 0, 'wrong number of unknown rows ... should return empty datatable instance');


