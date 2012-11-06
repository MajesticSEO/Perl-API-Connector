#!perl -T

use Test::More tests => 1;

BEGIN
{
	use_ok('MJ12::Remote::ApiService') || print "Bail out!";
}

diag("Testing MJ12::Remote::ApiService $MJ12::Remote::ApiService::VERSION, Perl $], $^X");
