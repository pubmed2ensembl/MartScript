
use IPC::Open2;
use POSIX ":sys_wait_h";
use File::Basename;

my $dbg_counter = 1;

local(*IN, *OUT);

my $pid;

print "gathering all MANIFEST.txt\n";

$pid = open2(*OUT, *IN, '/bin/bash -c "for i in \`find . -name MANIFEST.txt\` ; do cat \$i ; done"');

my @sorted_manifests = <OUT>;

waitpid($pid, 0);

close IN;
close OUT;

my @manifests;
my $last_species = "";
my $species_count = 0;

foreach my $sample (@sorted_manifests) {

    my @species = split(/_/, $sample);

    if($species[0] ne $last_species) {

	$species_count = $species_count + 1;
	
	$last_species = $species[0];

    }

}

print "found ".($#sorted_manifests + 1)." manifests\n";

if ($species_count > 1) {
    
    print "optimizing manifest order\n";
    
    # Interleave the manifest files of the various species.
    # Obviously, there is little chance that manifest files for one species can be executed
    # in parallel -- even though this is not impossible and it is something this script is
    # supposed to pick up. Anyway, by interleaving it is possible to make the decision process
    # of picking 'executable candidates' quicker.
    while ($#sorted_manifests >= 0) {

	my $manifests_before_splicing = $#sorted_manifests;
	
	for (my $manifest_index = 0; $manifest_index <= $#sorted_manifests; $manifest_index++) {
	    
	    my $unchomped_manifest = $sorted_manifests[$manifest_index];
	    my $manifest = $unchomped_manifest;
	    
	    chomp($manifest);
	    
	    my @species = split(/_/, $manifest);
	    
	    if ($species[0] ne $last_species) {
		
		push @manifests, $manifest;
		
		splice(@sorted_manifests, $manifest_index, 1);
		
		$last_species = $species[0];
		
		$manifest_index = $manifest_index - 1;
		
	    }
	    
	}

	# For some species there might exist more tables than for others. As such, the
	# manifests cannot be evenly distributed among the species. If we only have one
	# species left, then we cannot do any more interleaving.
	if ($manifests_before_splicing == $#sorted_manifests) {

            while ($#sorted_manifests >= 0) {
      
                my $unchomped_manifest = $sorted_manifests[0];
		my $manifest = $unchomped_manifest;

		chomp($manifest);

		push @manifests, $manifest;

		splice(@sorted_manifests, 0, 1);

	    }

	}

    }

} else {

    @manifests = @sorted_manifests;

}

my @todo;
my @sql_file;
my @altered_tables;

print "0/".($#manifests + 1)."\n";

foreach my $path (@manifests) {

    my $base = basename($path, (".sql"));

    chomp($base);

    push @todo, $base;

    $pid = open2(*OUT, *IN, "/bin/bash -c \"find . -name $path\"");

    my @find_path = <OUT>;

    waitpid($pid, 0);

    close IN;
    close OUT;

    my $file_path = $find_path[0];

    chomp($file_path);

    push @sql_file, $file_path;

    open (SQL_FILE, $file_path);

    my @sql_statements = <SQL_FILE>;
    
    close SQL_FILE;

    my $altering = "";
    
    my @alter_statements = grep(/alter table/, @sql_statements);
    
    foreach my $alter_statement (@alter_statements) {
	
	my @space_sep = split(/ /, $alter_statement);
	my @table_address = split(/\./,$space_sep[2]);
	
	if ($table_address[1] =~ m/^TEMP/) {
	    
	    # temporary table
	    
	    # Temporary tables are always local to one SQL file and do not appear in other SQL files.

	} else {
	    
	    if ($altering eq "") {
		
		$altering = $table_address[1];
		
	    } else {
		
		$altering = $altering.",".$table_address[1];
		
	    }
	    
	}
	
    }

    # my $x = "update ensembl_mart_55.hsapiens_gene_ensembl__translation__main a set interpro_bool=(select case count(1) when 0 then null else 1 end";
    # my @space_sep = split(/ /, $x);
    # my @table_address = split(/\./, $space_sep[1]);
    # print $table_address[1];

    push @altered_tables, $altering;

    if ((($#todo + 1) % (($#manifests + 1)/ ($#manifests < 10 ? 1 : 10))) == 0) {

	print "".($#todo + 1)."/".($#manifests + 1)."\n";

    }

}

#print "".($#manifests + 1)."/".($#manifests + 1)."\n";


my @pool;
my @pool_filename;

while ($#manifests >= 0) {

    print "manifests: ".($#manifests+1)."\t pool: ".($#pool+1)."\n";

    #print "TODO: @todo\n";

    MANIFEST_LOOP: for (my $manifest_entry = 0; $manifest_entry <= ($#manifests < 100 ? $#manifests : 100); $manifest_entry++) {

	my $path = $manifests[$manifest_entry];

	chomp($path);

	my $preliminaries_satisfied = 1;

	open (SQL_FILE, $sql_file[$manifest_entry]);
	
	my @sql_statements = <SQL_FILE>;

	close SQL_FILE;

	my @currently_altered_tables = ();

	# item 0 contains the species name
	my @path_chops = split(/_/, $path);

	# if a to-be-processed table is in the SQL file, then we cannot carry on
	CHECK_TODOS: foreach my $table_todo (@todo) {

	    if (($table_todo.".sql" ne $path) &&
		($table_todo =~ m/^$path_chops[0]/)) {

		if (grep(/$table_todo/, @sql_statements) != 0) {

		    $preliminaries_satisfied = 0;
		    last CHECK_TODOS;

		}

	    }

	}

	if ($preliminaries_satisfied == 1) {
	    
	    CHECK_ALTERED: foreach my $currently_altered_tables (@altered_tables) {
		
		my @altered_table_names = split(/,/,$currently_altered_tables);
		
		foreach my $altered_table_name (@altered_table_names) {
		    
		    if ($altered_table_name.".sql" ne $path) {

			my @create_statements = grep(/^create/, @sql_statements);
			my @alter_statements = grep(/^alter table/, @sql_statements);

			if (grep(/$altered_table_name/, @create_statements) != 0) {

			    if (grep(/$altered_table_name/, @alter_statements) != 0) {

				my @critical_statements = grep(/$altered_table_name/, @create_statements);

				foreach my $critical_statement (@critical_statements) {

				    if ($critical_statement =~ /.*\W(.)\.\w+_key\W.*/) {

					my $identifier = $1;

					my $cropped_statement = $critical_statement;
					$cropped_statement =~ s/($identifier)\.\w+_key//g;

					if ($cropped_statement =~ /.*(\s|,)($identifier)\.\w+\W(\s|,).*/) {

					#print "refused: ".$path." due to ".$cropped_statement."\n";
					    
					    my @altered_table_occurrences = grep(/$altered_table_name/,@altered_tables);

					    #print "waitees: ".($#altered_table_occurrences + 1)."\n";

					    # if there is only one occurrence (i.e. $#altered_table_occurrences == 0), then
					    # the table entry is due to our 'alter table' statement in the SQL
					    if ($#altered_table_occurrences > 0) {

						$preliminaries_satisfied = 0;
						last CHECK_ALTERED;

					    }

					}

				    }

				}

			    } else {

				#print "refused: ".$path." due to ".$altered_table_name."\n";
				$preliminaries_satisfied = 0;
				last CHECK_ALTERED;

			    }
			
			}

		    }
		    
		}

	    }
	    
	}

	if ($preliminaries_satisfied == 1) {

	    my $tmp_out, $tmp_in;

	    my $dbg_output = basename($sql_file[$manifest_entry], (".sql"));
	    chomp($dbg_output);

	    # if you are using the debugging output, make sure the directory /tmp/dbg exists or the execution WILL fail!
	    # $pid = open2($tmp_out, $tmp_in, "/bin/bash -c \"mysql -h $ARGV[2] -P $ARGV[3] -u $ARGV[0] --password=$ARGV[1] < $sql_file[$manifest_entry] > /tmp/dbg/$dbg_output.$dbg_counter.out 2> /tmp/dbg/$dbg_output.$dbg_counter.err\"");
	    $pid = open2($tmp_out, $tmp_in, "/bin/bash -c \"mysql -h $ARGV[2] -P $ARGV[3] -u $ARGV[0] --password=$ARGV[1] < $sql_file[$manifest_entry]\"");

	    $dbg_counter = $dbg_counter + 1;

	    print "spawning: $path ($pid)\n";

	    splice(@manifests, $manifest_entry, 1);
	    splice(@sql_file, $manifest_entry, 1);

	    push @pool, $pid;
	    push @pool_filename, $path;

	    $manifest_entry = $#manifests + 1;

	}
	
	if ($#pool > 31 || ($manifest_entry <= $#manifests && ($manifest_entry % 4) == 0)) {

	    my $pool_full = $#pool > 31 ? 1 : 0;
	    my $pool_modified;

	    do {

		$pool_modified = 0;

		POOL_ITER: for (my $pool_entry = 0; $pool_entry <= $#pool; $pool_entry++) {
	
		    my $status = waitpid($pool[$pool_entry], WNOHANG);

		    if ($status != 0) {

		        print "status: $pool_filename[$pool_entry] = $status (${^CHILD_ERROR_NATIVE}, $?)\n";

			TODO_SEARCH: for (my $todo_search = 0; $todo_search <= $#todo; $todo_search++) {

			    if ($todo[$todo_search].".sql" eq $pool_filename[$pool_entry]) {

			        print "todo removal: $todo[$todo_search]\n";

				splice(@todo, $todo_search, 1);
				splice(@altered_tables, $todo_search, 1);
				last TODO_SEARCH;

			    }

			}

			splice(@pool, $pool_entry, 1);
			splice(@pool_filename, $pool_entry, 1);
			$pool_full = 0;
			$pool_modified = 1;
			last POOL_ITER;

		    }

		}

		if ($pool_full == 1) {

		    sleep 1;

		}

	    } while($pool_full == 1 || $pool_modified == 1);

	}

    }

}

while ($#pool >= 0) {

    my $pool_changed = 0;

    for (my $pool_entry = 0; $pool_entry <= $#pool; $pool_entry++) {

	my $status = waitpid($pool[$pool_entry], WNOHANG);

	if ($status != 0) {

	    print "status: $pool_filename[$pool_entry] = $status (${^CHILD_ERROR_NATIVE}, $?)\n";
	    
	    splice(@pool, $pool_entry, 1);
	    splice(@pool_filename, $pool_entry, 1);
	    $pool_changed = 1;
	    $pool_entry = $#pool + 1;

	}

    }

    if ($pool_changed != 1) {

	sleep 1;

    }

}

