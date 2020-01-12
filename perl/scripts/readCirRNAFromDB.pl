#!/usr/bin/perl
use DBI;

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

sub getCirDataset{
    my ($organism,$tissue,$genomeVer,$version,$dsn,$usr,$passwd)=@_;
    my %ret;
    if($tissue eq "Brain"){
        $tissue="Whole Brain";
    }
    if($organism eq "Rat"){
        $organism="Rn";
    }elsif($organism eq "Mouse"){
        $organism="Mm";
    }
    my $connect = DBI->connect($dsn, $usr, $passwd) or die ($DBI::errstr ."\n");
    my $query="select cd.CDSID,cdv.version from cirrna_dataset cd left outer join cirrna_dataset_version cdv on cd.CDSID=cdv.CDSID ";
    if(!($tissue eq "Any")){
        $query=$query." where cd.tissue = '".$tissue."' ";
    }
    if($version==0 || $version eq ""){
        $query=$query." order by cdv.version DESC";
    }else{
        if(index($query,"where")>0) {
            $query = $query . " and cdv.version=" . $version;
        }else{
            $query = $query . " where cdv.version=" . $version;
        }
    }
    print $query."\n";
    $query_handle = $connect->prepare($query) or die (" CirRNA query prepare failed \n");

    # EXECUTE THE QUERY
    $query_handle->execute() or die ( "CirRNA query execute failed \n");
    my $dsid;
    my $ver;

    # BIND TABLE COLUMNS TO VARIABLES
    $query_handle->bind_columns(\$dsid,\$ver);
    if($query_handle->fetch()){
        print("save:".$dsid.":".$ver."\n");
        $ret{$dsid}={ 'ver'=> $ver};
    }else{
        $ret{0}={'ver'=>0};
    }
    $query_handle->finish();
    $connect->disconnect();
    return \%ret;
}

1;

sub readCirRNA {
    # Read in the arguments for the subroutine
    my ( $species, $chromosome, $minCoord, $maxCoord, $tissue, $genomeVer, $withArrays, $withPredicted,$version, $dsn, $usr, $passwd) = @_;
    print($dsn."\n");
    my $connect = DBI->connect($dsn, $usr, $passwd) or die($DBI::errstr . "\n");

    my $dsRef=getCirDataset($species, $tissue, $genomeVer, $version, $dsn, $usr, $passwd);
    my %ds=%$dsRef;
    my @dsids=keys %ds;
    my $dsid=0;
    if(@dsids>0){
        $dsid=$dsids[0];
        print("DSID returned:".$dsid."\n");
    }
    my $dsver=$ds{$dsid}{'ver'};
    print("ver:".$dsver."\n");

    my %geneHOH;
    my $chrID;

    my $geneChromNumber = $chromosome;
    if (length($geneChromNumber) <= 2) {
        $geneChromNumber = addChr($geneChrom, "add");
    }



    my $select="select CFID,PHENOGEN_ID,NAME,CHROMOSOME,START,END,STRAND,SOURCE,CIRI,CIRCEXPLORER,ARRAY,TYPE,PROBESEQ,PROBE_ID from cirrna_features where cdsid=".$dsid." and version=".$dsver." and chromosome='".$geneChromNumber."' and (";

    $select=$select." (START>=$minCoord and START<=$maxCoord) OR (END>=$minCoord and END<=$maxCoord) OR (START<=$minCoord and END>=$maxCoord) ) order by cfid";
    print($select);
    print("\n\n\n");
    $query_handle = $connect->prepare($select) or die (" CirRNA query prepare failed \n");

    # EXECUTE THE QUERY
    $query_handle->execute() or die ( "CirRNA query execute failed \n");
    my $cfid;
    my $phenID;
    my $name;
    my $chr;
    my $start;
    my $end;
    my $strand;
    my $source;
    my $ciri;
    my $circExplorer;
    my $array;
    my $type;
    my $probeseq;
    my $probeID;
    my $geneCnt=0;

    # BIND TABLE COLUMNS TO VARIABLES
    $query_handle->bind_columns(\$cfid,\$phenID,\$name,\$chr,\$start,\$end,\$strand,\$source,\$ciri,\$circExplorer,\$array,\$type,\$probeseq,\$probeID);
    while($query_handle->fetch()){
        $geneHOH{'Gene'}[$geneCnt]={ 'ID' => $cfid,
            'PhenoGenID'       => $phenID,
            'Name'             => $name,
            'Chromosome'       => $chr,
            'start'            => $start,
            'stop'              => $end,
            'Strand'           => $strand,
            'Source'           => $source,
            'Ciri'             => $ciri,
            'Circexplorer'     => $circExplorer,
            'Array'            => $array,
            'Type'             => $type,
            'Probeseq'         => $probeseq,
            'ProbeID'          => $probeID
        };
        $geneCnt+=1;
    }
    $query_handle->finish();

    my $selectExpr="select cfid,strain,source,mean,sample1,sample2,sample3,sample1value,sample2value,sample3value,sample1dabg,sample2dabg,sample3dabg from cirrna_feature_expression where CFID in (select cfid from cirrna_features where cdsid=".$dsid." and version=".$dsver." and chromosome='".$geneChromNumber."' and ((START>=$minCoord and START<=$maxCoord) OR (END>=$minCoord and END<=$maxCoord) OR (START<=$minCoord and END>=$maxCoord))) order by cfid";
    $query_handle = $connect->prepare($selectExpr) or die (" CirRNA query prepare failed \n");
    # EXECUTE THE QUERY
    $query_handle->execute() or die ( "CirRNA query execute failed \n");
    my $cfid;
    my $strain;
    my $source;
    my $mean;
    my $s1;
    my $s2;
    my $s3;
    my $s1v;
    my $s2v;
    my $s3v;
    my $s1d;
    my $s2d;
    my $s3d;

    my $genePntr=0;
    my $strainCnt=0;

    # BIND TABLE COLUMNS TO VARIABLES
    $query_handle->bind_columns(\$cfid,\$strain,\$source,\$mean,\$s1,\$s2,\$s3,\$s1v,\$s2v,\$s3v,\$s1d,\$s2d,\$s3d);
    while($query_handle->fetch()){
        while($geneHOH{'Gene'}[$genePntr]{'ID'} != $cfid){
            $genePntr+=1;
            $strainCnt=0;
        }
        if($geneHOH{'Gene'}[$genePntr]{'ID'} == $cfid){
            $geneHOH{'Gene'}[$genePntr]{'ExpressionList'}{'Expression'}[$strainCnt]={ 'Strain'=>$strain,'Source'=>$source,'Mean'=>$mean};
            $geneHOH{'Gene'}[$genePntr]{'ExpressionList'}{'Expression'}[$strainCnt]{'Sample'}[0]={'Sample'=>$s1,'Value'=>$s1v,'DABG'=>$s1d};
            $geneHOH{'Gene'}[$genePntr]{'ExpressionList'}{'Expression'}[$strainCnt]{'Sample'}[1]={'Sample'=>$s2,'Value'=>$s2v,'DABG'=>$s2d};
            $geneHOH{'Gene'}[$genePntr]{'ExpressionList'}{'Expression'}[$strainCnt]{'Sample'}[2]={'Sample'=>$s3,'Value'=>$s3v,'DABG'=>$s3d};
        }
        $strainCnt+=1;
    }
    $query_handle->finish();

    my $selectBlocks="select cfid,blk_start,blk_end,Source,Struct_ver from cirrna_structure where CFID in (select cfid from cirrna_features where cdsid=".$dsid." and version=".$dsver." and chromosome='".$geneChromNumber."' and ((START>=$minCoord and START<=$maxCoord) OR (END>=$minCoord and END<=$maxCoord) OR (START<=$minCoord and END>=$maxCoord))) order by cfid";

    $query_handle = $connect->prepare($selectBlocks) or die (" CirRNA query prepare failed \n");
    # EXECUTE THE QUERY
    $query_handle->execute() or die ( "CirRNA query execute failed \n");
    my $cfid;
    my $blkStart;
    my $blkEnd;
    my $src;
    my $structver;

    $genePntr=0;
    my $blkCnt=0;
    # BIND TABLE COLUMNS TO VARIABLES
    $query_handle->bind_columns(\$cfid,\$blkStart,\$blkEnd,\$src,\$structver);
    while($query_handle->fetch()){
        while($geneHOH{'Gene'}[$genePntr]{'ID'} != $cfid){
            $genePntr+=1;
            $blkCnt=0;
        }
        if($geneHOH{'Gene'}[$genePntr]{'ID'} == $cfid){
            $geneHOH{'Gene'}[$genePntr]{'BlockList'}{'Block'}[$blkCnt] = {
                'start'=>$blkStart,
                'stop'=>$blkEnd,
                'Source'=>$src,
                'Ver'=>$structver
            };
            $blkCnt+=1;
        }
    }

    $query_handle->finish();

    $connect->disconnect();

    return (\%geneHOH);
}

1;
