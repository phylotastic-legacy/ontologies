use Bio::TreeIO;
use Getopt::Long;

my $verbose = ''; # option variable with default value (false)
my $all = ''; # option variable with default value (false)

GetOptions( 'input=s' => \$inputfile , 'output=s' => \$outputfile );

if (!$inputfile)
{
	print 'Default input file defaultinput.txt';
	$inputfile = 'defaultinput.txt';
}

if (!$outputfile)
{
	print 'Default output file defaultoutput.rdf';
	$outputfile = 'defaultoutput.rdf';
}


my $treeio = new Bio::TreeIO(-format => 'nhx', -file => $inputfile);
my $tree = $treeio->next_tree;

my @leaves = $tree->get_leaf_nodes();

open($OUT, '>>'.$outputfile);

foreach $x (@leaves) {
	print $OUT $x->id;
	print $OUT "\n";
}

close($OUT);


