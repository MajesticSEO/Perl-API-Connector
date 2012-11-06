#!perl -T

use Test::More tests => 8;

use strict;
use MJ12::Remote::Response;


# remote response.
my $remote_response = <<'REMOTE';
<?xml version="1.0" encoding="utf-8"?>
<Result Code="OK" ErrorMessage="" FullError="">
		<GlobalVars APIAccess="1" CustomerAdvancedReportsRemaining="20" CustomerAvailableAnalysisResUnits="100000000" CustomerCreditLimit="0" CustomerCredits="0.00" CustomerEmail="jamesl@majestic12.co.uk" CustomerIsAdmin="1" CustomerName="James Lee" CustomerStandardReportBacklinksShown="5000" CustomerStandardReportsRemaining="20" CustomerSubscriptions="1" DeveloperAPIAccess="1" ServerName="LEEPFROG" ThirdPartyAPIAccess="0"/>
	<DataTables Count="3">
		<DataTable Name="Folders" RowsCount="0" Headers="FolderName|Created|FoldersInside|DomainsInside">
		</DataTable>
		<DataTable Name="AdvancedReports" RowsCount="2" Headers="ReportName|ReportCode|ReportLocked|Domain|LastUpdated|Status|SubDomains|Pages|Links|TotalBackLinks|ExtBackLinks|ExtDomains|ExtUniqueIPs|MaxPageACRank|MaxRefACRank|FreshNewBackLinks|FreshNewRefDomains|HumanLastFreshUpdateDate|LastFreshUpdateDate|AnalysisProgressInfo|Expires">
			<Row>aston.ac.uk|38CAFFEFB0B93EF7|0|aston.ac.uk|23/09/2010 13:59:15|Analysed|6|0|12|220|205|8|8|1|0|0|0| | | | </Row>
			<Row>google.com|270335686AF4C784|0| |23/09/2010 17:04:09|Analysed|1|1|0|527322|483148|3327|2553|11|7|0|0| | | | </Row>
		</DataTable>
		<DataTable Name="StandardReports" RowsCount="3" Headers="ReportName|ReportCode|ReportLocked|Created|Status|URL|SubDomain|Domain|TotalUrlBackLinks|TotalSubDomainBackLinks|TotalDomainBackLinks|ExternalUrlBackLinks|ExternalSubDomainBackLinks|ExternalDomainBackLinks|AvailableUrlBackLinks|AvailableSubDomainBackLinks|AvailableDomainBackLinks|UrlRefDomains|SubDomainRefDomains|DomainRefDomains|AvailableUrlRefDomains|AvailableSubDomainRefDomains|AvailableDomainRefDomains">
			<Row>google.com|1B7D13BF0D527022|0|24/09/2010 15:44:22|Analysed|http://www.google.com|www.google.com|google.com|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0</Row>
			<Row>www.google.com|CB5FD1045B13C9D6|0|30/09/2010 10:14:15|Analysed|http://www.google.com|www.google.com|google.com|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0</Row>
			<Row>www.bbc.co.uk|425ECFA6F96DCC33|0|05/10/2010 14:55:51|Analysed|http://www.bbc.co.uk|www.bbc.co.uk|bbc.co.uk|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0</Row>
		</DataTable>
	</DataTables>
</Result>
REMOTE


# create response.
my $response = MJ12::Remote::Response->new_ok('RemoteResponse' => $remote_response);

# check response.
ok($response->isOK, 'should be ok response');
is($response->code, 'OK', 'wrong response code');
is($response->errorMessage, '', 'wrong error message');

my %params = $response->globalParams;
is_deeply(\%params, {
	'APIAccess' => 1,
	'CustomerAdvancedReportsRemaining' => 20,
	'CustomerAvailableAnalysisResUnits' => 100000000,
	'CustomerCreditLimit' => 0,
	'CustomerCredits' => '0.00',
	'CustomerEmail' => 'jamesl@majestic12.co.uk',
	'CustomerIsAdmin' => 1,
	'CustomerName' => 'James Lee',
	'CustomerStandardReportBacklinksShown' => 5000,
	'CustomerStandardReportsRemaining' => 20,
	'CustomerSubscriptions' => 1,
	'DeveloperAPIAccess' => 1,
	'ServerName' => 'LEEPFROG',
	'ThirdPartyAPIAccess' => 0,
			}, 'wrong params');

is($response->paramForName('Name' => 'CustomerStandardReportsRemaining'), 20, 'wrong CustomerStandardReportsRemaining param');
is($response->paramForName('Name' => 'unknown'), undef, 'wrong unknown param');

my $advanced_reports_table = $response->tableForName('Name' => 'AdvancedReports');
is($advanced_reports_table->rowCount, 2, 'wrong number of advanced report rows');

my $unknown_table = $response->tableForName('Name' => 'unknown');
is($unknown_table->rowCount, 0, 'wrong number of unknown rows ... should return empty datatable instance');


