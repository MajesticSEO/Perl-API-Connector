#!perl -T

use Test::More tests => 7;

use strict;
use MJ12::Remote::DataTable;


# xml::simple output.
my %data = (
	'Headers' => 'ReportName|ReportCode|ReportLocked|Domain|LastUpdated|Status|SubDomains|Pages|Links|TotalBackLinks|ExtBackLinks|ExtDomains|ExtUniqueIPs|MaxPageACRank|MaxRefACRank|FreshNewBackLinks|FreshNewRefDomains|HumanLastFreshUpdateDate|LastFreshUpdateDate|AnalysisProgressInfo|Expires',
	'Name' => 'xxx',
	'Row' => [
		'aston.ac.uk|38CAFFEFB0B93EF7|0|aston.ac.uk|23/09/2010 13:59:15|Analysed|6|0|12|220|205|8|8|1|0|0|0| | | | ',
		'google.com|270335686AF4C784|0| |23/09/2010 17:04:09|Analysed|1|1|0|527322|483148|3327|2553|11|7|0|0| | | | ',
				],
	'RowsCount' => 3,
			);


# create datatable.
my $table = new MJ12::Remote::DataTable('Data' => \%data);

# check it's all good.
is($table->tableName, 'xxx', 'wrong table name');
is($table->rowCount, 2, 'wrong row count');
is($table->paramForName('Name' => 'RowsCount'), 3, 'wrong rows count param');
is($table->paramForName('Name' => 'unknown'), undef, 'wrong unknown param');

my @expected_headers = qw|ReportName ReportCode ReportLocked Domain LastUpdated Status SubDomains Pages Links TotalBackLinks ExtBackLinks ExtDomains ExtUniqueIPs MaxPageACRank MaxRefACRank FreshNewBackLinks FreshNewRefDomains HumanLastFreshUpdateDate LastFreshUpdateDate AnalysisProgressInfo Expires|;
my @headers = $table->headers;
is_deeply(\@headers, \@expected_headers, 'wrong headers');

my @expected_rows = (
	{
	'ReportName' => 'aston.ac.uk',
	'ReportCode' => '38CAFFEFB0B93EF7',
	'ReportLocked' => 0,
	'Domain' => 'aston.ac.uk',
	'LastUpdated' => '23/09/2010 13:59:15',
	'Status' => 'Analysed',
	'SubDomains' => 6,
	'Pages' => 0,
	'Links' => 12,
	'TotalBackLinks' => 220,
	'ExtBackLinks' => 205,
	'ExtDomains' => 8,
	'ExtUniqueIPs' => 8,
	'MaxPageACRank' => 1,
	'MaxRefACRank' => 0,
	'FreshNewBackLinks' => 0,
	'FreshNewRefDomains' => 0,
	'HumanLastFreshUpdateDate' => '',
	'LastFreshUpdateDate' => '',
	'AnalysisProgressInfo' => '',
	'Expires' => '',
	},
	{
	'ReportName' => 'google.com',
	'ReportCode' => '270335686AF4C784',
	'ReportLocked' => 0,
	'Domain' => '',
	'LastUpdated' => '23/09/2010 17:04:09',
	'Status' => 'Analysed',
	'SubDomains' => 1,
	'Pages' => 1,
	'Links' => 0,
	'TotalBackLinks' => 527322,
	'ExtBackLinks' => 483148,
	'ExtDomains' => 3327,
	'ExtUniqueIPs' => 2553,
	'MaxPageACRank' => 11,
	'MaxRefACRank' => 7,
	'FreshNewBackLinks' => 0,
	'FreshNewRefDomains' => 0,
	'HumanLastFreshUpdateDate' => '',
	'LastFreshUpdateDate' => '',
	'AnalysisProgressInfo' => '',
	'Expires' => '',
	},
						);

is_deeply($table->rowsAsArrayRef, \@expected_rows, 'wrong rows as array ref');

my @rows = $table->rowsAsArray;
is_deeply(\@rows, \@expected_rows, 'wrong rows');
