
# count_columns.pl tab_separated_file

open(TSV, $ARGV[0]);

while (<TSV>) {

        my @cols = split("\t");

        chomp(@cols);

	if ($cols[0] =~ m/^#.*/) {

		# comment line

	} else {
		
		print $#cols + 1;
		close(TSV);
		exit(0);

	}

}

close(TSV);

