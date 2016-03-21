#!perl -T

use Test::More tests => 8;

use strict;
use MJ12::Remote::Response;


# remote response.
my $remote_response = <<'REMOTE';
<?xml version="1.0" encoding="utf-8"?>
<Result Code="OK" ErrorMessage="" FullError="">
	<GlobalVars FirstBackLinkDate="2012-05-01" IndexBuildDate="2015-11-20 21:08:49" IndexType="0" MostRecentBackLinkDate="2015-10-21" ServerBuild="2015-10-23 14:17:16" ServerName="DAVE" ServerVersion="1.0.5774.23918" UniqueIndexID="20151120210849-HISTORICAL"/>
	<DataTables Count="1">
		<DataTable Name="Results" RowsCount="2" Headers="ItemNum|Item|ResultCode|Status|ExtBackLinks|RefDomains|AnalysisResUnitsCost|ACRank|ItemType|IndexedURLs|GetTopBackLinksAnalysisResUnitsCost|DownloadBacklinksAnalysisResUnitsCost|DownloadRefDomainBacklinksAnalysisResUnitsCost|RefIPs|RefSubNets|RefDomainsEDU|ExtBackLinksEDU|RefDomainsGOV|ExtBackLinksGOV|RefDomainsEDU_Exact|ExtBackLinksEDU_Exact|RefDomainsGOV_Exact|ExtBackLinksGOV_Exact|CrawledFlag|LastCrawlDate|LastCrawlResult|RedirectFlag|FinalRedirectResult|OutDomainsExternal|OutLinksExternal|OutLinksInternal|LastSeen|Title|RedirectTo|CitationFlow|TrustFlow|TrustMetric|TopicalTrustFlow_Topic_0|TopicalTrustFlow_Value_0|TopicalTrustFlow_Topic_1|TopicalTrustFlow_Value_1|TopicalTrustFlow_Topic_2|TopicalTrustFlow_Value_2" MaxTopicsRootDomain="30" MaxTopicsSubDomain="20" MaxTopicsURL="10" TopicsCount="3">
			<Row>0|http://majestic.com/|OK|Found|8|7|8|3|3|1|5000|25000|25000|4|4|0|0|0|0|0|0|0|0|False| | |False| |0|0|0|2015-10-21| | |0|0|0| | | | | | </Row>
			<Row>1|majestic.com|OK|Found|4516|48|4516|-1|1|153152|5000|157668|50960|45|43|0|0|0|0|0|0|0|0|False| | |False| |0|0|0| |Majestic®: Marketing Search Engine and SEO Backlink Checker| |81|23|23|Computers/Software/Online Training|22|Computers/Computer Science/Distributed Computing|18|Computers/Programming/Internet|8</Row>
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
	'FirstBackLinkDate' => '2012-05-01',
	'IndexBuildDate' => '2015-11-20 21:08:49',
	'IndexType' => 0,
	'MostRecentBackLinkDate' => '2015-10-21',
	'ServerBuild' => '2015-10-23 14:17:16',
	'ServerName' => 'DAVE',
	'ServerVersion' => '1.0.5774.23918',
	'UniqueIndexID' => '20151120210849-HISTORICAL',
}, 'wrong params');

is($response->paramForName('Name' => 'ServerName'), 'DAVE', 'wrong ServerName param');
is($response->paramForName('Name' => 'unknown'), undef, 'wrong unknown param');

my $advanced_reports_table = $response->tableForName('Name' => 'Results');
is($advanced_reports_table->rowCount, 2, 'wrong number of result rows');

my $unknown_table = $response->tableForName('Name' => 'unknown');
is($unknown_table->rowCount, 0, 'wrong number of unknown rows ... should return empty datatable instance');


