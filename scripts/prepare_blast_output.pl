
# prepare_blast_output.pl blast_output_file

open(BLAST, $ARGV[0]);

while (<BLAST>) {

	my @cols = split(' ');

	chomp(@cols);

	# first column has to be of the form ID1|TAXID|ID2. ID1 and ID2 can be anything
	my @sub_cols = split(/\|/, shift @cols);
	print $sub_cols[1]."\t".$sub_cols[0]."\t".$sub_cols[2];

	foreach my $x (@cols) {
		print "\t".$x;
	}

	print "\n";

}

close(BLAST);

