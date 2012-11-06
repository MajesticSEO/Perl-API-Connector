#!perl -T

use Test::More tests => 1;

BEGIN
{
	use_ok('MJ12::Remote::Response') || print "Bail out!";
}

diag("Testing MJ12::Remote::Response $MJ12::Remote::Response::VERSION, Perl $], $^X");
