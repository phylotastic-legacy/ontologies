use Bio::TreeIO;
use Getopt::Long;



my $verbose = ''; # option variable with default value (false)
my $all = ''; # option variable with default value (false)

GetOptions( 'input=s' => \$inputfile , 'output=s' => \$outputfile, 'tree=s' => \$treename);


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

if (!$treename)
{
	print 'Default tree name mytree';
	$treename = 'mytree';	
}

# GLOBAL FROM ontology
$ROOTEDTREE = '<http://purl.obolibrary.org/obo/CDAO_0000012>';
$HASROOT = '<http://purl.obolibrary.org/obo/CDAO_0000148>';
$TU = '<http://purl.obolibrary.org/obo/CDAO_0000138>';
$TERMINALNODE = '<http://purl.obolibrary.org/obo/CDAO_0000108>';
$ANCESTRALNODE = '<http://purl.obolibrary.org/obo/CDAO_0000026>';
$HASPARENT = '<http://purl.obolibrary.org/obo/CDAO_0000179>';
$REPRESENTSTU= '<http://purl.obolibrary.org/obo/CDAO_0000187>';
$EDGELENGTH = '<http://purl.obolibrary.org/obo/CDAO_0000046>';
$EdgeClass = "<http://purl.obolibrary.org/obo/CDAO_0000139>";
$EdgeToChildNode = '<http://purl.obolibrary.org/obo/CDAO_0000209>';
$EdgeToParentNode = '<http://purl.obolibrary.org/obo/CDAO_0000201>';
$HASANNOTATION = '<http://purl.obolibrary.org/obo/CDAO_0000193>';
$HASVALUE = '<http://purl.obolibrary.org/obo/CDAO_0000215>';

$nodecount = 0;
$lengthcount=0;
$tucount = 0;

# MAIN

# extract the megatree to be mapped


	my $treeio = new Bio::TreeIO(-format => 'newick', -file => $inputfile);

print "Reading input tree\n";

$tree = $treeio->next_tree;


unlink($outputfile);

print "Opening file.. \n", $inputfile;

open($MYFILE, '>>'.$outputfile);

#dump_header($MYFILE);
print " .. created headers ..";
dump_nodes($MYFILE);
print " .. created nodes ..";
dump_edges($MYFILE,$tree->get_root_node);

print ".. created edges ..";
dump_tree($MYFILE);

print " .. completed\n";
#dump_close($MYFILE);

close($MYFILE);


sub dump_header
{
	my ($filehandler) = @_;
	
	print $filehandler "<?xml version=\"1.0\"?>\n\n";
	
	print $filehandler "<!DOCTYPE rdf:RDF [\n";
	print $filehandler "\t<!ENTITY owl \"http://www.w3.org/2002/07/owl#\">\n";
	print $filehandler "\t<!ENTITY xsd \"http://www.w3.org/2001/XMLSchema#\" >\n";
    print $filehandler "\t<!ENTITY rdfs \"http://www.w3.org/2000/01/rdf-schema#\" >\n";
    print $filehandler "\t<!ENTITY rdf \"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" >\n";
    print $filehandler "\t<!ENTITY localspace \"http://purl.obolibrary.org/obo/cdao.owl#\" >\n";
	print $filehandler "\t<!ENTITY cdao \"http://purl.obolibrary.org/obo/cdao.owl#\" >\n";
	print $filehandler "]>\n\n";
	
	print $filehandler "<rdf:RDF xmlns=\"http://purl.obolibrary.org/obo/cdao.owl#\"\n";
	print $filehandler "\t xml:base=\"http://purl.obolibrary.org/obo/cdao.owl\"\n";
	print $filehandler "\t xmlns:rdfs=\"http://www.w3.org/2000/01/rdf-schema#\"\n";
	print $filehandler  "	     \t xmlns:cdao=\"http://purl.obolibrary.org/obo/cdao.owl#\"\n";
	print $filehandler "	     \t xmlns:owl=\"http://www.w3.org/2002/07/owl#\"\n";
	print $filehandler "	     \t xmlns:xsd=\"http://www.w3.org/2001/XMLSchema#\"\n";
	print $filehandler "	     \t xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\"\n";
	print $filehandler "         \t xmlns:localspace=\"http://purl.obolibrary.org/obo/cdao.owl#\">\n";
	print $filehandler "	    \t <owl:Ontology rdf:about=\"http://purl.obolibrary.org/obo/cdao.owl\"/>\n\n\n";	
}

sub dump_close
{
	$filehandler = $_[0];
	print $filehandler "</rdf:RDF>\n"
}

sub dump_tree
{
	$filehandler = $_[0];
	print $filehandler "<http://phylotastic.nescent.org/trees/Tree".$treename."> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ".$ROOTEDTREE." .\n";
	print $filehandler "<http://phylotastic.nescent.org/trees/Tree".$treename."> ".$HASROOT." _:Node".$tree->get_root_node->internal_id." .\n";
}

# Creating node elements
sub dump_nodes
{
	$filehandler = $_[0];
	

	for my $node ($tree->get_nodes)
	{
		if ($node->is_Leaf)
		{
			print $filehandler "_:TU".$tucount." <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ".$TU." .\n";
			print $filehandler "_:TU".$tucount." <http://www.w3.org/2000/01/rdf-schema#label> \"".$node->id."\".\n";
			$tucount++;
		}
		
		
		if ($node->is_Leaf)
		{
			print $filehandler "_:Node".$node->internal_id." <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ".$TERMINALNODE." .\n";	
		}
		else
		{
			print $filehandler "_:Node".$node->internal_id." <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ".$ANCESTRALNODE." .\n";	
		}

		if ($node != $tree->get_root_node)
		{
			print $filehandler "_:Node".$node->internal_id." ".$HASPARENT." _:Node".$node->ancestor->internal_id." .\n";			
		}
		if ($node->is_Leaf)
		{
			print $filehandler "_:Node".$node->internal_id." ".$REPRESENTSTU." _:TU".($tucount-1)." .\n";
		}
	}
}

# Creating edge elements
sub dump_edges
{
	$filehandler = $_[0];
	$current = $_[1];
	$nodecount++;
	
	
	for my $child ($current->each_Descendent)
	{
		if ($child->branch_length)
		{
			
			print $filehandler "_:Length".$lengthcount." <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ".$EDGELENGTH." .\n";
			print $filehandler "_:Length".$lengthcount." ".$HASVALUE." \"".$child->branch_length."\" .\n";
		}
		print $filehandler "_:Edge".$current->internal_id."v".$child->internal_id." <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ".$EdgeClass." .\n";
		print $filehandler "_:Edge".$current->internal_id."v".$child->internal_id." ".$EdgeToChildNode." _:Node".($child->internal_id)." .\n";
		print $filehandler "_:Edge".$current->internal_id."v".$child->internal_id." ".$EdgeToParentNode." _:Node".($current->internal_id)." .\n";	
		if ($child->branch_length)
		{
			print $filehandler "_:Edge".$current->internal_id."v".$child->internal_id." ".$HASANNOTATION." _:Length".$lengthcount." .\n";
			$lengthcount++;
		}	
		$edgecount = dump_edges($filehandler, $child);
	}
}







