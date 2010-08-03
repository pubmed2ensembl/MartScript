use Data::PowerSet 'powerset';
use DBI;
use Data::Dumper;

# Usage: create_combined_table host port user password namedmp species database version desttbl columnname table1 table2 table3 ..

# NOTE: gene ids are Entrez gene IDs and stable ids are Ensembl gene IDs!
# Stable IDs are prioritised before dbprimary_acc.

my $has_stable_id = 0;

# If the first table has a stable_id, then we assume that all tables come with a stable_id
my @table_cols = `echo "SHOW COLUMNS FROM martscript.$ARGV[10];" | mysql -h $ARGV[0] -P $ARGV[1] -u $ARGV[2] --password=$ARGV[3]`;

foreach $table_row (@table_cols) {

	my @row_cols = split (/\t/, $table_row);

	my $column_name = $row_cols[0];

	chomp ($column_name);

	if ($column_name eq "stable_id") {

		$has_stable_id = 1;

	}

}

$" = ',';

my @species;
my @species_ids;

if ($ARGV[5] eq "ALL_SPECIES") {

	my @species_dbs = `echo "SHOW DATABASES" | mysql -h $ARGV[0] -P $ARGV[1] -u $ARGV[2] --password=$ARGV[3] | grep _$ARGV[6]_$ARGV[7]`;

	foreach my $species_db (@species_dbs) {

		chomp ( $species_db );

		my @species_chops = split (/_/, $species_db);

		my $species_name = $species_chops[0]."_".$species_chops[1];

		my $species_id = `./findspeciesid.sh "$ARGV[4]" $species_name`;

		chomp ( $species_id );

		push (@species, $species_db);
		push (@species_ids, $species_id);

		#print "ID: ".$species_id."\n";

	}

} else {

	my $species_db = `echo "SHOW DATABASES" | mysql -h $ARGV[0] -P $ARGV[1] -u $ARGV[2] --password=$ARGV[3] | grep ^$ARGV[5]_$ARGV[6]_$ARGV[7]`;
	my $species_id = `./findspeciesid.sh "$ARGV[4]" $ARGV[5]`;

	chomp ( $species_db );
	chomp ( $species_id );

	@species = ( $species_db );
	@species_ids = ( $species_id );

}

my @tables;

my $db;
my $sep_table;

my $st; 

my $data;

for ( $i = 10; $i <= $#ARGV ; $i++ ) {

	push(@tables, "$ARGV[$i]");

}

foreach my $species_id (@species_ids) {

	foreach ( @tables ) {

		$db = DBI->connect( "DBI:mysql:martscript:$ARGV[0]:$ARGV[1]", $ARGV[2], $ARGV[3] );

		# Since this implementation only addresses one species, I can cheat and select only the entries for that fella.
		if ($has_stable_id) {

			$st = $db->prepare( "SELECT DISTINCT taxonomy_id,stable_id,$ARGV[9] FROM $_ WHERE taxonomy_id=$species_id AND NOT LENGTH($ARGV[9])=0" );

		} else {

			$st = $db->prepare( "SELECT DISTINCT taxonomy_id,dbprimary_acc,$ARGV[9] FROM $_ WHERE taxonomy_id=$species_id AND NOT LENGTH($ARGV[9])=0" );

		}

		$st->execute();

		while ( @data = $st->fetchrow_array()) {

			$sep_table->{ $_ }->{ $data[0] }->{ $data[1] } .= $data[2]." ";
			#print "populating.. ".$data[2]."\n";

		}

		$st->finish;
		$db->disconnect;

	}

}

my $powerset = powerset @tables;

my $comb_table;

for ( $i = 0; $i < @species; $i++ ) {

	$db = DBI->connect( "DBI:mysql:$species[$i]:$ARGV[0]:$ARGV[1]", $ARGV[2], $ARGV[3] );

	if ($has_stable_id) {

		$st = $db->prepare( 'SELECT stable_id FROM gene_stable_id' );

	} else {

		$st = $db->prepare( 'SELECT dbprimary_acc FROM xref WHERE external_db_id=1300' );

	}

	$st->execute();

	while ( @data = $st->fetchrow_array()) {

		my $gene_id = $data[0];

		my @assembly;
		my @so_far = ();

		for my $p ( reverse sort { (@$a.length) <=> (@$b.length) } @$powerset ) {

			@assembly = ();

                        foreach ( @$p ) {

				if ( @assembly == () ) {

					@assembly = split(/ /, $sep_table->{ $_ }->{ $species_ids[$i] }->{ $gene_id });

				} else {

					my @x = split(/ /, $sep_table->{ $_ }->{ $species_ids[$i] }->{ $gene_id });
					my %x_hash = map {$_ => 1} @x;
					
					@assembly = grep ( $x_hash{$_}, @assembly );

				}

			}

			my %y_hash = map {$_ => 1} @so_far;

			@assembly = grep (!defined $y_hash{$_}, @assembly);

			@so_far = (@so_far, @assembly);

			$comb_table->{ $species_ids[$i] }->{ $gene_id }->{ $p } = join( ' ', @assembly );
			#print "combining...".@assembly."\n";

		}

	}

	$st->finish;
	$db->disconnect;

}

$db = DBI->connect( "DBI:mysql:martscript:$ARGV[0]:$ARGV[1]", $ARGV[2], $ARGV[3] );

$st = $db->prepare( "DROP TABLE IF EXISTS $ARGV[8]" );
$st->execute();
$st->finish;

for my $p ( reverse sort { (@$a.length) <=> (@$b.length) } @$powerset ) {

	my $tblext = join( "_", @$p );

	$st = $db->prepare( "DROP TABLE $ARGV[8]_$tblext" );
	$st->execute();
	$st->finish;

	if ($has_stable_id) {

		$st = $db->prepare( "CREATE TABLE $ARGV[8]_$tblext (taxonomy_id INTEGER NOT NULL,stable_id VARCHAR(128) NOT NULL,$ARGV[8]_$tblext"."_$ARGV[9] LONGTEXT)" );

	} else {

		$st = $db->prepare( "CREATE TABLE $ARGV[8]_$tblext (taxonomy_id INTEGER NOT NULL,dbprimary_acc VARCHAR(20) NOT NULL,$ARGV[8]_$tblext"."_$ARGV[9] LONGTEXT)" );

	}

	$st->execute();
	$st->finish;

}

foreach my $species_id (@species_ids) {

	for my $p ( reverse sort { (@$a.length) <=> (@$b.length) } @$powerset ) {

		foreach $gene_maps ( $comb_table->{ $species_id } ) {
		
			foreach $gene ( keys %$gene_maps ) {

				my $x = $gene_maps->{ $gene }->{ $p };

				# if ( $x.length > 0 ) {
				if (!($x eq "")) {

					my $tblext = join( "_", @$p );
					# my $formatted = join( ",", @$p ) . ": " . join(",", split(/ /,$x));
					my $formatted = join(",&thinsp\;", split(/ /,$x));

					$formatted =~ s/\'/&#39;/g;

					#print "$species_id\t$gene\t\"$formatted\"\n";
					if ($has_stable_id) {

						$st = $db->prepare( "INSERT INTO $ARGV[8]_$tblext (taxonomy_id,stable_id,$ARGV[8]_$tblext"."_$ARGV[9]) VALUES($species_id,'$gene','$formatted')" );
						#print "aINSERT INTO $ARGV[8]_$tblext (taxonomy_id,stable_id,$ARGV[8]_$tblext"."_$ARGV[9]) VALUES($species_id,'$gene','$formatted')\n";

					} else {

						$st = $db->prepare( "INSERT INTO $ARGV[8]_$tblext (taxonomy_id,dbprimary_acc,$ARGV[8]_$tblext"."_$ARGV[9]) VALUES($species_id,$gene,'$formatted')" );
						#print "bINSERT INTO $ARGV[8]_$tblext (taxonomy_id,dbprimary_acc,$ARGV[8]_$tblext"."_$ARGV[9]) VALUES($species_id,$gene,'$formatted')\n";

					}

					$st->execute();
					$st->finish;

				}

			}

		}

	}

}

$db->disconnect;

