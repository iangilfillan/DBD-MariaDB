use strict;
use warnings;

use DBI;
use Test::More;
use lib '.', 't';
require 'lib.pl';

use vars qw($test_dsn $test_user $test_password);

$test_dsn.= ";mariadb_server_prepare=1;mariadb_server_prepare_disable_fallback=1";
my $dbh = DbiTestConnect($test_dsn, $test_user, $test_password,
  { RaiseError => 1, AutoCommit => 1});

if ($dbh->{mariadb_clientversion} < 40103 or $dbh->{mariadb_serverversion} < 40103) {
    plan skip_all =>
        "SKIP TEST: You must have MySQL version 4.1.3 and greater for this test to run";
}
plan tests => 3;

# execute invalid SQL to make sure we get an error
my $q = "select select select";	# invalid SQL
$dbh->{PrintError} = 0;
$dbh->{PrintWarn} = 0;
my $sth;
eval {$sth = $dbh->prepare($q);};
$dbh->{PrintError} = 1;
$dbh->{PrintWarn} = 1;
ok defined($DBI::errstr);
cmp_ok $DBI::errstr, 'ne', '';

note "errstr $DBI::errstr\n" if $DBI::errstr;
ok $dbh->disconnect();
