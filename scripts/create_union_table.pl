use Data::PowerSet 'powerset';
use DBI;
use Data::Dumper;

# Usage: create_combined_table host port user password desttbl table1 table2 table3 ..

$" = ',';

my @tables;

my $db;
my $st;

# table2, 3, 4, ... are put into a list. table1 is used below to create the new table (and populate it) in the first place
for ( $i = 6 ; $i <= $#ARGV ; $i++ ) {

	push(@tables, "$ARGV[$i]");

}

$db = DBI->connect( "DBI:mysql:martscript:$ARGV[0]:$ARGV[1]", $ARGV[2], $ARGV[3] );

$st = $db->prepare( "DROP TABLE $ARGV[4]" );
$st->execute();
$st->finish;

$st = $db->prepare( "CREATE TABLE $ARGV[4] SELECT * FROM $ARGV[5]" );
$st->execute();
$st->finish;

foreach ( @tables ) {

	$st = $db->prepare( "INSERT INTO $ARGV[4] SELECT * FROM $_" );
	$st->execute();
	$st->finish;

}

$db->disconnect;

