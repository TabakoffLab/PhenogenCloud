#!/usr/bin/perl
use strict; 
use DBI;
use Sys::Hostname;
use List::Util qw[min max];


sub renameChromosome{
	# For circos, the chromosome number or letter (1,2,X,Y etc.) needs to be preceeded by 'mm' or 'rn'
	# depending on the species
	my ($chromosomeNumber,$organism)=@_;
	my $newChrom = lc($organism).$chromosomeNumber;
	return $newChrom;
}
1;


sub readLocusSpecificPvaluesModule{


	#INPUT VARIABLES: $probeID, $organism

	# Read inputs
	my($module,$organism,$tissue,$chromosomeListRef,$genomeVer,$rnaDSID,$level,$dsn,$usr,$passwd,$type)=@_;
	my @chromosomeList = @{$chromosomeListRef};
	my $numberOfChromosomes = scalar @chromosomeList;
	# $hostname is used to determine the connection to the database.
	#my $hostname = hostname;

	
	if ($tissue eq "Brain") {
		$tissue="Whole Brain";
	}
	
	#Initializing Array

	my @eqtlAOH; # array of hashes containing location specific eqtl data
	

	#print "readModuleData.pl:type:$type\n";

	# PERL DBI CONNECT
	my $connect = DBI->connect($dsn, $usr, $passwd) or die ($DBI::errstr ."\n");
	#print "readModuleData.pl:type:$type\n";
	my $wdsidlist="";
	my $wdsidQ="Select wd.wdsid from wgcna_dataset wd where wd.organism='$organism' and wd.tissue='$tissue' and wd.genome_id='$genomeVer' and wd.visible=1";
	if($type eq 'seq') {
    		$wdsidQ = $wdsidQ . " and wd.rna_dataset_id=" . $rnaDSID;
    		if($genomeVer  eq 'rn7'){
    		    $wdsidQ = $wdsidQ . " and wd.level='" . $level."'";
    		}
    	}

    my $wdQH = $connect->prepare($wdsidQ) or die (" Location Specific EQTL query prepare failed $!");

    # EXECUTE THE QUERY
    $wdQH->execute() or die ( "WGCNA id  query execute failed $!");

    # BIND TABLE COLUMNS TO VARIABLES
    my ($wdsidVal);
  	$wdQH->bind_columns(\$wdsidVal);
  	my $wdCount=0;
    while($wdQH->fetch()) {
        if($wdCount==0){
            $wdsidlist="$wdsidVal";
        }else{
            $wdsidlist=$wdsidlist.",$wdsidlist";
        }
        $wdCount=$wdCount+1;
    }
    $wdQH->finish();


	# PREPARE THE QUERY for pvalues
    my $query = "select  s.SNP_NAME, c.name,  s.COORD, e.PVALUE
                        from wgcna_location_eqtl e
                        left outer join snps_hrdp s on s.snp_id=e.snp_id
                        left outer join chromosomes c on c.chromosome_id=s.chromosome_id
                        where s.genome_id='".$genomeVer."'
                        and s.type='$type'";
	if($type eq 'seq') {
		$query = $query . " and s.rna_dataset_id=" . $rnaDSID;
	}else{
	    $query = $query . " and s.organism='$organism'
                           and s.tissue='$tissue'";
	}
	$query=$query." and c.chromosome_id=s.chromosome_id and e.pvalue>=1 and e.wdsid in (".$wdsidlist.")";
	$query=$query." and e.module_id in (Select wi.module_id from wgcna_module_info wi where wi.wdsid in (".$wdsidlist.") ";
	$query=$query." and wi.module='$module' ) order by e.pvalue";
    #print "$query\n";
                      
	my $query_handle = $connect->prepare($query) or die (" Location Specific EQTL query prepare failed $!");

# EXECUTE THE QUERY
	$query_handle->execute() or die ( "Location Specific EQTL query execute failed $!");

# BIND TABLE COLUMNS TO VARIABLES
	my ($dbsnp_name, $dbchrom_name, $dbsnp_location,  $dbpvalue);
	$query_handle->bind_columns(\$dbsnp_name ,\$dbchrom_name, \$dbsnp_location,\$dbpvalue);
	my $counter = -1;
	my $currentChromosome;
	my $keepThisChromosome;
# Loop through results, adding to array of hashes.	
	while($query_handle->fetch()) {
		#Only populate hash for chromosomes in the chromosome list
		$currentChromosome = renameChromosome($dbchrom_name,$organism);
		$keepThisChromosome = 0;
		for(my $i=0;$i<$numberOfChromosomes;$i++){
			if($currentChromosome eq $chromosomeList[$i]){
				$keepThisChromosome = 1;
			}
		}
		if( $keepThisChromosome == 1 ){
			$counter++;
			$eqtlAOH[$counter]{name}=$dbsnp_name;
			$eqtlAOH[$counter]{chromosome}=renameChromosome($dbchrom_name,$organism);
			$eqtlAOH[$counter]{location}=$dbsnp_location;
			$eqtlAOH[$counter]{tissue}=$tissue;
			$eqtlAOH[$counter]{pvalue}=$dbpvalue;
		}
	}
	$query_handle->finish();
	$connect->disconnect();
	#print "count".$counter."\n";
	return (\@eqtlAOH);
}
1;