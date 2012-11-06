#!perl -T

use Test::More tests => 1;

BEGIN
{
	use_ok('MJ12::Remote::DataTable') || print "Bail out!";
}

diag("Testing MJ12::Remote::DataTable $MJ12::Remote::DataTable::VERSION, Perl $], $^X");
