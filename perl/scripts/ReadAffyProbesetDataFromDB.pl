#!/usr/bin/perl
# Subroutine to read information from pre-loaded database files
# The information is about Affy probesets and probes
# Inputs are geneChrom, geneStart, geneStop
# This routine returns array references ...
# we return information about any Affy probesets that overlap
# geneStart to geneStop on the chromosome geneChrom


# PERL MODULES WE WILL BE USING
use Bio::SeqIO;
use Data::Dumper qw(Dumper);

use Text::CSV;
#use strict; Fix this

sub addChr{


	#Second input variable should be "add" or "subtract".  Default is "add"
	# if second input variable is "add" then add the letters "chr"
	# if the second input variable is "subtract", take away the letters "chr"

	my ($chromosomeNumber,$addOrSubtract)=@_;
	if ($addOrSubtract eq "subtract"){
		my $newChrom = substr($chromosomeNumber,3,length($chromosomeNumber));
		# get rid of first 3 characters
		return $newChrom;
	}
	else {
		# add chr
		my $newChrom = "chr$chromosomeNumber";
		return $newChrom;
	}
}
1;


sub readAffyProbesetDataFromDB{


	#INPUT VARIABLES
	# Chromosome for example chr12
	# Start position on the chromosome
	# Stop position on the chromosome

	# Read inputs
	my($geneChrom,$geneStart,$geneStop,$arrayTypeID,$dataSetID,$genomeVer,$dsn,$usr,$passwd)=@_;   
	
	#open PSFILE, $psOutputFileName;//Added to output for R but now not needed.  R will read in XML file
	print "read probesets chr:$geneChrom\n";
	#Initializing Arrays

	my @probesetHOH; # giant array of hashes and arrays containing probeset data
	

	$probesetTablename = 'Affy_Exon_ProbeSet';
	$probeTablename = 'Affy_Exon_Probes';
	$heritTablename = 'Probeset_Herit_Dabg';
	$chromosomeTablename = 'Chromosomes';
	if(length($geneChrom)<5) {
		# DATA SOURCE NAME
		#$dsn = "dbi:$platform:$service_name";


		# PERL DBI CONNECT
		$connect = DBI->connect($dsn, $usr, $passwd) or die($DBI::errstr . "\n");

		my $geneChromNumber = addChr($geneChrom, "subtract");
		my $org = "Rn";
		if ($genomeVer eq "mm10") {
			$org = "Mm";
		}
		$chrQ = "select chromosome_id from chromosomes where name='" . uc($geneChromNumber) . "' and organism='" . $org . "'";
		$query_handle1 = $connect->prepare($chrQ) or die(" Probeset query prepare failed \n");

		# EXECUTE THE QUERY
		$query_handle1->execute() or die("Probeset query execute failed \n");
		$query_handle1->bind_columns(\$chrID);
		$query_handle1->fetch();

		# PREPARE THE QUERY for probesets
		$query = "select s.Probeset_ID, s.psstart, s.psstop, s.strand, s.pslevel, s.pssequence, s.updatedlocation, h.herit, h.dabg, p.PROBE_ID, p.STRAND, p.PROBESEQUENCE
        from  $probesetTablename s
        left outer join $heritTablename h on s.probeset_id = h.probeset_id and h.genome_id=s.genome_id
        left outer join $probeTablename p on p.probeset_id = s.probeset_id and p.genome_id=s.genome_id
        where s.chromosome_id =  " . $chrID . "
        and s.genome_id='" . $genomeVer . "'
        and 
        ((s.psstart >= $geneStart and s.psstart <=$geneStop) OR
        (s.psstop >= $geneStart and s.psstop <= $geneStop))
        and s.psannotation <> 'transcript'
        and s.Array_TYPE_ID = $arrayTypeID
        and h.dataset_id = $dataSetID
        and s.updatedlocation='Y'
        order by s.probeset_id";

		print $query . "\n";
		$query_handle = $connect->prepare($query) or die(" Probeset query prepare failed \n");

		# EXECUTE THE QUERY
		$query_handle->execute() or die("Probeset query execute failed \n");

		# BIND TABLE COLUMNS TO VARIABLES

		$query_handle->bind_columns(undef, \$dbname, \$dbchromStart, \$dbchromStop, \$dbstrand, \$dbtype, \$dbsequence, \$dbupdloc, \$dbherit, \$dbdabg, \$dbprobename, \$dbprobestrand, \$dbprobesequence);
		# Loop through results, adding to array of hashes.
		my $continue = 1;
		my @tmpArr = ();
		my @probeArray = @tmpArr;
		my $cntProbes = 0;
		my $previousdbName = "";
		my $tmpType = "";
		my $tmpStop = 0;
		my $tmpID = "";
		my $tmpStart = 0;
		my $tmpStrand = "";
		my $tmpSequence = "";
		my $tmpChromosome = 0;
		my $tmpUpdatedLocation = 'N';
		my $tmpHeritability = 0;
		my $tmpDABG = 0;

		while ($query_handle->fetch()) {
			if ($dbname eq $previousdbName) {
				#print "Adding probe $dbname\n";
				$$probeArray[$cntProbes]{ID} = $dbprobename;
				$$probeArray[$cntProbes]{start} = $dbprobeStart;
				$$probeArray[$cntProbes]{stop} = $dbprobeStop;
				$$probeArray[$cntProbes]{strand} = $dbprobestrand;
				$$probeArray[$cntProbes]{sequence} = $dbprobesequence;
				$cntProbes++;
				#print Data::Dumper->Dump(\@probeArray);
			}
			else {
				#print "done $tmpID\n";
				#print " Number of probes $cntProbes \n";
				#print Data::Dumper->Dump(\@$probeArray);
				push @probesetHOH,
					{
						type            => $tmpType,
						stop            => $tmpStop,
						ID              => $tmpID,
						start           => $tmpStart,
						strand          => $tmpStrand,
						sequence        => $tmpSequence,
						chromosome      => $tmpChromosome,
						updatedlocation => $tmpUpdatedLocation,
						heritability    => $tmpHeritability,
						DABG            => $tmpDABG,
						ProbeList       => { Probe => \@$probeArray }
					};
				my @tmpArray = ();
				$probeArray = \@tmpArray;
				$cntProbes = 0;

				$tmpType = $dbtype;
				$tmpStop = $dbchromStop;
				$tmpID = $dbname;
				$tmpStart = $dbchromStart;
				$tmpStrand = $dbstrand;
				$tmpSequence = $dbsequence;
				$tmpChromosome = $geneChrom;
				$tmpUpdatedLocation = $dbupdloc;
				$tmpHeritability = $dbherit;
				$tmpDABG = $dbdabg;

				$$probeArray[$cntProbes]{ID} = $dbprobename;
				$$probeArray[$cntProbes]{start} = $dbprobeStart;
				$$probeArray[$cntProbes]{stop} = $dbprobeStop;
				$$probeArray[$cntProbes]{strand} = $dbprobestrand;
				$$probeArray[$cntProbes]{sequence} = $dbprobesequence;
				$cntProbes++;

				#print "starting $dbname: $cntProbes probes\n";

				$previousdbName = $dbname;
			}
		}
		$query_handle1->finish();
		$query_handle->finish();
		#$connect->disconnect();
		push @probesetHOH,
			{
				type            => $tmpType,
				stop            => $tmpStop,
				ID              => $tmpID,
				start           => $tmpStart,
				strand          => $tmpStrand,
				sequence        => $tmpSequence,
				chromosome      => $tmpChromosome,
				updatedlocation => $tmpUpdatedLocation,
				heritability    => $tmpHeritability,
				DABG            => $tmpDABG,
				ProbeList       => { Probe => \@$probeArray }
			};
	}
	#close PSFILE;
	return (\@probesetHOH);
}

sub readAffyProbesetDataFromDBwoHeritDABG{


	#INPUT VARIABLES
	# Chromosome for example chr12
	# Start position on the chromosome
	# Stop position on the chromosome

	# Read inputs
	my($geneChrom,$geneStart,$geneStop,$arrayTypeID,$genomeVer,$connect)=@_;
	
	#open PSFILE, $psOutputFileName;//Added to output for R but now not needed.  R will read in XML file
	print "read probesets chr:$geneChrom\n";
	#Initializing Arrays

	my @probesetHOH; # giant array of hashes and arrays containing probeset data
	

	
	
	$probesetTablename = 'Affy_Exon_ProbeSet';
	$probeTablename = 'Affy_Exon_Probes';
	
	# DATA SOURCE NAME
	#$dsn = "dbi:$platform:$service_name";
	
	# PERL DBI CONNECT
	#$connect = DBI->connect($dsn, $usr, $passwd) or die ($DBI::errstr ."\n");
	
	my $geneChromNumber = addChr($geneChrom,"subtract");
    $org="Rn";
    if($genomeVer eq "mm10"){
    	    $org="Mm";
    }
    $chrQ="select chromosome_id from chromosomes where name='".uc($geneChromNumber)."' and organism='".$org."'";
    $query_handle1 = $connect->prepare($chrQ) or die (" Probeset query prepare failed \n");

    # EXECUTE THE QUERY
    $query_handle1->execute() or die ( "Probeset query execute failed \n");
    $query_handle1->bind_columns(\$chrID);
    $query_handle1->fetch();
	# PREPARE THE QUERY for probesets
		
		$query = "select s.Probeset_ID, s.psstart, s.psstop, s.strand, s.pslevel, s.pssequence, s.updatedlocation, p.PROBE_ID, p.STRAND, p.PROBESEQUENCE
		from  $probesetTablename s
		left outer join $probeTablename p on p.probeset_id = s.probeset_id and p.genome_id=s.genome_id
		where s.chromosome_id =  ".$chrID."
        and s.genome_id='".$genomeVer."'
		and 
		((s.psstart >= $geneStart and s.psstart <=$geneStop) OR
		(s.psstop >= $geneStart and s.psstop <= $geneStop))
		and s.psannotation <> 'transcript'
		and s.Array_TYPE_ID = $arrayTypeID 
		and s.updatedlocation='Y' 
		order by s.probeset_id";

	print $query."\n";
	$query_handle = $connect->prepare($query) or die (" Probeset query prepare failed \n");

# EXECUTE THE QUERY
	$query_handle->execute() or die ( "Probeset query execute failed \n");

# BIND TABLE COLUMNS TO VARIABLES

	$query_handle->bind_columns(undef ,\$dbname, \$dbchromStart, \$dbchromStop,\$dbstrand, \$dbtype, \$dbsequence, \$dbupdloc, \$dbprobename, \$dbprobestrand, \$dbprobesequence);
# Loop through results, adding to array of hashes.
	my $continue=1;
	my @tmpArr=();
	my @probeArray = @tmpArr ;
	my $cntProbes=0;
	my $previousdbName="";
	my $tmpType = "";
	my $tmpStop = 0;
	my $tmpID = "";
	my $tmpStart = 0;
	my $tmpStrand = "";
	my $tmpSequence = "";
	my $tmpChromosome = 0;
	my $tmpUpdatedLocation = 'N';

	
	while($query_handle->fetch()) {
		if($dbname eq $previousdbName){
			#print "Adding probe $dbname\n";
			$$probeArray[$cntProbes]{ID}=$dbprobename;
			$$probeArray[$cntProbes]{strand}=$dbprobestrand;
			$$probeArray[$cntProbes]{sequence}=$dbprobesequence;
			$cntProbes++;
			#print Data::Dumper->Dump(\@probeArray);
		}else{	
			#print "done $tmpID\n";
			#print " Number of probes $cntProbes \n";
			#print Data::Dumper->Dump(\@$probeArray);
			push @probesetHOH,
			{
				type => $tmpType,
				stop => $tmpStop,
				ID => $tmpID,
				start => $tmpStart,
				strand => $tmpStrand,
				sequence => $tmpSequence,
				chromosome => $tmpChromosome,
				updatedlocation => $tmpUpdatedLocation,
				ProbeList => {Probe => \@$probeArray}
			};
			my @tmpArray=();
			$probeArray=\@tmpArray;
			$cntProbes=0;
			
			$tmpType = $dbtype;
			$tmpStop = $dbchromStop;
			$tmpID = $dbname;
			$tmpStart = $dbchromStart;
			$tmpStrand = $dbstrand;
			$tmpSequence = $dbsequence;
			$tmpChromosome = $geneChrom;
			$tmpUpdatedLocation = $dbupdloc;
			
			
			
			$$probeArray[$cntProbes]{ID}=$dbprobename;
			$$probeArray[$cntProbes]{strand}=$dbprobestrand;
			$$probeArray[$cntProbes]{sequence}=$dbprobesequence;
			$cntProbes++;
			
			#print "starting $dbname: $cntProbes probes\n";
			
			$previousdbName=$dbname;
		}
	}
	$query_handle1->finish();
	$query_handle->finish();
	#$connect->disconnect();
	push @probesetHOH,
			{
				type => $tmpType,
				stop => $tmpStop,
				ID => $tmpID,
				start => $tmpStart,
				strand => $tmpStrand,
				sequence => $tmpSequence,
				chromosome => $tmpChromosome,
				updatedlocation => $tmpUpdatedLocation,
				ProbeList => {Probe => \@$probeArray}
			};
	#close PSFILE;
	return (\@probesetHOH);
}

sub readTissueAffyProbesetDataFromDB{


	#INPUT VARIABLES
	# Chromosome for example chr12
	# Start position on the chromosome
	# Stop position on the chromosome

	# Read inputs
	my($geneChrom,$geneStart,$geneStop,$arrayTypeID,$rnaDatasetID,$percCutoff,$genomeVer,$connect)=@_;
	
	#open PSFILE, $psOutputFileName;//Added to output for R but now not needed.  R will read in XML file
	print "read tissue probesets chr:$geneChrom\n$arrayTypeID\n$rnaDatasetID\n$percCutoff";
	#Initializing Arrays

	my %probesetHOH; # giant array of hashes and arrays containing probeset data
	
	$probesetTablename = 'Affy_Exon_ProbeSet';
	$rnaTissueTablename = 'rnadataset_dataset';
	$heritTablename = 'Probeset_Herit_Dabg';
	$chromosomeTablename = 'Chromosomes';
	
	# DATA SOURCE NAME
	#$dsn = "dbi:$platform:$service_name";
	
	# PERL DBI CONNECT
	#$connect = DBI->connect($dsn, $usr, $passwd) or die ($DBI::errstr ."\n");
	
	my $geneChromNumber = $geneChrom;
	if(length($geneChromNumber)>2){
	    $geneChromNumber = addChr($geneChrom,"subtract");
	}

    $org="Rn";
    if($genomeVer eq "mm10"){
        	    $org="Mm";
    }
        $chrQ="select chromosome_id from chromosomes where name='".uc($geneChromNumber)."' and organism='".$org."'";
        $query_handle1 = $connect->prepare($chrQ) or die (" Probeset query prepare failed \n");

        # EXECUTE THE QUERY
        $query_handle1->execute() or die ( "Probeset query execute failed \n");
        $query_handle1->bind_columns(\$chrID);
        $query_handle1->fetch();
	# PREPARE THE QUERY for probesets
		
		$query = "select s.Probeset_ID, s.psstart, s.psstop, s.strand, s.pslevel, h.dabg, rd.tissue
		from $probesetTablename s
		left outer join $heritTablename h on s.probeset_id = h.probeset_id and h.genome_id=s.genome_id
        left outer join $rnaTissueTablename rd on h.dataset_id=rd.dataset_id
		where s.chromosome_id = ".$chrID."
        and s.genome_id='".$genomeVer."'
		and 
		((s.psstart >= $geneStart and s.psstart <=$geneStop) OR
		(s.psstop >= $geneStart and s.psstop <= $geneStop))
		and s.psannotation <> 'transcript'
		and s.Array_TYPE_ID = $arrayTypeID
		and rd.rna_dataset_id=$rnaDatasetID
                and h.dabg>$percCutoff
		and s.updatedlocation='Y'
		order by s.probeset_id";
                
	print $query."\n";
	$query_handle = $connect->prepare($query) or die (" Probeset query prepare failed \n");

# EXECUTE THE QUERY
	$query_handle->execute() or die ( "Probeset query execute failed \n");

# BIND TABLE COLUMNS TO VARIABLES

	$query_handle->bind_columns(\$dbpsID ,\$dbchromStart, \$dbchromStop,\$dbstrand, \$dblevel, \$dbdabg, \$dbtissue);
# Loop through results, adding to array of hashes.	
	while($query_handle->fetch()) {
		my $tmpcount=$probesetHOH{$dbtissue}{count};
		if($tmpcount<0){
			$tmpcount=0;
		}
		$probesetHOH{$dbtissue}{pslist}[$tmpcount]{ID}=$dbpsID;
		$probesetHOH{$dbtissue}{pslist}[$tmpcount]{start}=$dbchromStart;
		$probesetHOH{$dbtissue}{pslist}[$tmpcount]{stop}=$dbchromStop;
		$probesetHOH{$dbtissue}{pslist}[$tmpcount]{strand}=$dbstrand;
		$probesetHOH{$dbtissue}{pslist}[$tmpcount]{level}=$dblevel;
		$probesetHOH{$dbtissue}{pslist}[$tmpcount]{dabg}=$dbdabg;
		$tmpcount++;
		$probesetHOH{$dbtissue}{count}=$tmpcount;
	}
	$query_handle->finish();
	#$connect->disconnect();
	
	#close PSFILE;
	return (\%probesetHOH);
}

sub readAffyProbesetDataFromDBwoProbes{


	#INPUT VARIABLES
	# Chromosome for example chr12
	# Start position on the chromosome
	# Stop position on the chromosome

	# Read inputs
	my($geneChrom,$geneStart,$geneStop,$arrayTypeID,$genomeVer,$connect)=@_;
	
	#open PSFILE, $psOutputFileName;//Added to output for R but now not needed.  R will read in XML file
	print "read probesets chr:$geneChrom\n";
	#Initializing Arrays

	my @probesetHOH; # giant array of hashes and arrays containing probeset data
	
	my %probesetH;
	
	$probesetTablename = 'Affy_Exon_ProbeSet';
	
	$chromosomeTablename = 'Chromosomes';
	
	# DATA SOURCE NAME
	#$dsn = "dbi:$platform:$service_name";
	
	# PERL DBI CONNECT
	#$connect = DBI->connect($dsn, $usr, $passwd) or die ($DBI::errstr ."\n");
	
	my $geneChromNumber = $geneChrom;
    if(length($geneChromNumber)>2){
        $geneChromNumber = addChr($geneChrom,"subtract");
    }
	$org="Rn";
            if($genomeVer eq "mm10"){
            	    $org="Mm";
            }
            $chrQ="select chromosome_id from chromosomes where name='".uc($geneChromNumber)."' and organism='".$org."'";
            $query_handle1 = $connect->prepare($chrQ) or die (" Probeset query prepare failed \n");

            # EXECUTE THE QUERY
            $query_handle1->execute() or die ( "Probeset query execute failed \n");
            $query_handle1->bind_columns(\$chrID);
            $query_handle1->fetch();
	$query = "select s.Probeset_ID, s.psstart, s.psstop, s.strand, s.pslevel, s.pssequence, s.updatedlocation
		from  $probesetTablename s
		where s.chromosome_id =  ".$chrID."
		and s.genome_id='".$genomeVer."' 
                and
		((s.psstart >= $geneStart and s.psstart <=$geneStop) OR
		(s.psstop >= $geneStart and s.psstop <= $geneStop))
		and s.psannotation <> 'transcript'
		and s.Array_TYPE_ID = $arrayTypeID
		and s.updatedlocation='Y'
		order by s.probeset_id";
	
	print $query."\n";
	$query_handle = $connect->prepare($query) or die (" Probeset query prepare failed \n");

# EXECUTE THE QUERY
	$query_handle->execute() or die ( "Probeset query execute failed \n");

# BIND TABLE COLUMNS TO VARIABLES

	$query_handle->bind_columns(undef,\$dbname, \$dbchromStart, \$dbchromStop,\$dbstrand, \$dbtype, \$dbsequence, \$dbupdloc);
# Loop through results, adding to array of hashes.
	my $continue=1;
	my $cntProbes=0;
	my $previousdbName="";
	my $tmpType = "";
	my $tmpStop = 0;
	my $tmpID = "";
	my $tmpStart = 0;
	my $tmpStrand = "";
	my $tmpSequence = "";
	my $tmpChromosome = 0;
	my $tmpUpdatedLocation = 'N';
	my $count=0;

	
	while($query_handle->fetch()) {
			#print "done $tmpID\n";
			#print " Number of probes $cntProbes \n";
			#print Data::Dumper->Dump(\@$probeArray);
			push @probesetHOH,
			{
				type => $dbtype,
				stop => $dbchromStop,
				ID => $dbname,
				start => $dbchromStart,
				strand => $dbstrand,
				sequence => $dbsequence,
				chromosome => $geneChrom,
				updatedlocation => $dbupdloc,
				herit => {},
				dabg => {}
			};
			$probesetH{$dbname}=$count;
			$count++;
	}

	$query_handle->finish();
	
	my $org="Mm";
	if($arrayTypeID==22){
		$org="Rn";
	}
	
	$query = "select p.probeset_id,t.tissue,p.dabg, p.herit from probeset_herit_dabg p , rnadataset_dataset t, $probesetTablename s
			where s.chromosome_id =  ".$chrID."
			and t.dataset_id = p.dataset_id
			and s.probeset_id=p.PROBESET_ID
			and s.psannotation <> 'transcript'
			and s.Array_TYPE_ID = $arrayTypeID
			and s.updatedlocation='Y'
			and ((s.psstart >= $geneStart and s.psstart <=$geneStop) OR
				(s.psstop >= $geneStart and s.psstop <= $geneStop))
            and p.genome_id='".$genomeVer."'
			and t.organism = '".$org."'";
	
	$query_handle = $connect->prepare($query) or die (" Probeset query prepare failed \n");

	# EXECUTE THE QUERY
	$query_handle->execute() or die ( "Probeset query execute failed \n");
	
	$query_handle->bind_columns(\$probeset,\$tissue,\$dabg,\$herit);
	while($query_handle->fetch()) {
		$tissue =~ s/ //g;
		$probesetHOH[$probesetH{$probeset}]{herit}{$tissue}=$herit;
		$probesetHOH[$probesetH{$probeset}]{dabg}{$tissue}=$dabg;
	}
	$query_handle1->finish();
	$query_handle->finish();

	#close PSFILE;
	return (\@probesetHOH);
}


sub readTissueEQTLProbesetDataFromDB{


	#INPUT VARIABLES
	# Chromosome for example chr12
	# Start position on the chromosome
	# Stop position on the chromosome

	# Read inputs
	my($geneChrom,$geneStart,$geneStop,$arrayTypeID,$rnaDatasetID,$lodCutoff,$genomeVer,$connect)=@_;
	
	#open PSFILE, $psOutputFileName;//Added to output for R but now not needed.  R will read in XML file
	print "read tissue probesets chr:$geneChrom\n$arrayTypeID\n$rnaDatasetID\n$lodCutoff";
	#Initializing Arrays

	my %probesetHOH; # giant array of hashes and arrays containing probeset data
	
	$probesetTablename = 'Affy_Exon_ProbeSet';
	$rnaTissueTablename = 'rnadataset_dataset';
	$heritTablename = 'Probeset_Herit_Dabg';
	$chromosomeTablename = 'Chromosomes';
	
	# DATA SOURCE NAME
	#$dsn = "dbi:$platform:$service_name";
	
	# PERL DBI CONNECT
	$connect = DBI->connect($dsn, $usr, $passwd) or die ($DBI::errstr ."\n");
	
	my $geneChromNumber = $geneChrom;
    if(length($geneChromNumber)>2){
    	    $geneChromNumber = addChr($geneChrom,"subtract");
    }
    $org="Rn";
    if($genomeVer eq "mm10"){
       $org="Mm";
    }
    $chrQ="select chromosome_id from chromosomes where name='".uc($geneChromNumber)."' and organism='".$org."'";
    $query_handle1 = $connect->prepare($chrQ) or die (" Probeset query prepare failed \n");

    # EXECUTE THE QUERY
    $query_handle1->execute() or die ( "Probeset query execute failed \n");
    $query_handle1->bind_columns(\$chrID);
    $query_handle1->fetch();
	# PREPARE THE QUERY for probesets
		
		$query = "select s.Probeset_ID, s.psstart, s.psstop, s.strand, s.pslevel, h.dabg, rd.tissue
		from $probesetTablename s
		left outer join $heritTablename h on s.probeset_id = h.probeset_id  and h.genome_id=s.genome_id
        left outer join $rnaTissueTablename rd on h.dataset_id=rd.dataset_id
		where s.chromosome_id = ".$chrID."
        and s.genome_id='".$genomeVer."'
		and 
		((s.psstart >= $geneStart and s.psstart <=$geneStop) OR
		(s.psstop >= $geneStart and s.psstop <= $geneStop))
		and s.psannotation <> 'transcript'
		and s.Array_TYPE_ID = $arrayTypeID
		and rd.rna_dataset_id=$rnaDatasetID
        and h.dabg>$percCutoff
		and s.updatedlocation='Y'
		order by s.probeset_id";

	print $query."\n";
	$query_handle = $connect->prepare($query) or die (" Probeset query prepare failed \n");

# EXECUTE THE QUERY
	$query_handle->execute() or die ( "Probeset query execute failed \n");

# BIND TABLE COLUMNS TO VARIABLES

	$query_handle->bind_columns(\$dbpsID ,\$dbchromStart, \$dbchromStop,\$dbstrand, \$dblevel, \$dbdabg, \$dbtissue);
# Loop through results, adding to array of hashes.	
	while($query_handle->fetch()) {
		my $tmpcount=$probesetHOH{$dbtissue}{count};
		if($tmpcount<0){
			$tmpcount=0;
		}
		$probesetHOH{$dbtissue}{pslist}[$tmpcount]{ID}=$dbpsID;
		$probesetHOH{$dbtissue}{pslist}[$tmpcount]{start}=$dbchromStart;
		$probesetHOH{$dbtissue}{pslist}[$tmpcount]{stop}=$dbchromStop;
		$probesetHOH{$dbtissue}{pslist}[$tmpcount]{strand}=$dbstrand;
		$probesetHOH{$dbtissue}{pslist}[$tmpcount]{level}=$dblevel;
		$probesetHOH{$dbtissue}{pslist}[$tmpcount]{dabg}=$dbdabg;
		$tmpcount++;
		$probesetHOH{$dbtissue}{count}=$tmpcount;
	}
	$query_handle1->finish();
	$query_handle->finish();
	#$connect->disconnect();
	
	#close PSFILE;
	return (\%probesetHOH);
}
1;

