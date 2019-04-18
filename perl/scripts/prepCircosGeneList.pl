#!/usr/bin/perl
use strict;
use POSIX;

#
#
my $debugLevel = 1;

sub replaceDot{
	my $text=shift;
	$text =~ s/\./_/g;
	return $text;
}

sub prepCircosGeneList
{
	# this routine creates configuration and data files for circos
	my($cutoff,$organism,$confDirectory,$dataDirectory,$chromosomeListRef,$tissueString,$genomeVer,$hostname,$type)=@_;
	my @chromosomeList = @{$chromosomeListRef};
	my $numberOfChromosomes = scalar @chromosomeList;
	# if probeChromosome is not in chromosomeList then we don't want to create a links file
	my $oneToCreateLinks = 1;
	my $interval=2000000;

	if ($debugLevel >= 2){
		print " In prepCircos \n";
		print "Cutoff: $cutoff \n";
		print "Organism: $organism \n";
		print "Conf Directory: $confDirectory \n";
		print "Data Directory: $dataDirectory \n";
		print "One to create links: $oneToCreateLinks \n";
		print "Hostname $hostname \n";
		for (my $i = 0; $i < $numberOfChromosomes; $i++){
			print " Chromosome ".$chromosomeList[$i]."\n";
		}
		print " Tissue ".$tissueString."\n";

	}

	my $genericConfLocation2 = '/usr/share/tomcat/webapps/PhenoGen/web/';
	my $genericConfLocation = '/usr/share/circos/etc/';
	my $karyotypeLocation = '/usr/share/circos/data/karyotype/';
	createCircosConfFile($confDirectory,$genericConfLocation,$genericConfLocation2,$karyotypeLocation,$organism,$genomeVer,$chromosomeListRef,$oneToCreateLinks,$oneToCreateLinks);
	createCircosIdeogramConfFiles($confDirectory,$organism,$chromosomeListRef);
	createCircosGenesTextConfFile($dataDirectory,$confDirectory);
	my $geneHashRef=createCircosGenesTextDataFile($dataDirectory,$organism,$type);
	createCircosEQTLCountConfFile($confDirectory,$dataDirectory,$cutoff,$organism,$tissueString,$type);
	createCircosEQTLCountLinkDataFiles($dataDirectory,$organism,$chromosomeListRef,$tissueString,$interval,$cutoff,$type,$geneHashRef);
	createCircosLinksConf($dataDirectory,$organism,$confDirectory,$tissueString);
	#createCircosLinksConfAndData($dataDirectory,$organism,$confDirectory,$cutoff,$tissueString);
	#*************************************************** TO FIX

	#my $eqtlAOHRef = readLocusSpecificPvaluesModule($module,$organism,$tissueString,$chromosomeListRef,$genomeVer,$dsn,$usr,$passwd,$type);
	#createCircosPvaluesDataFiles($dataDirectory,$module,$organism,$eqtlAOHRef,$chromosomeListRef,$tissueString);
	#if($oneToCreateLinks == 1){
	#	createCircosLinksConfAndData($dataDirectory,$organism,$confDirectory,$eqtlAOHRef,$cutoff,$tissueString,$chromosomeList[0]);
	#}
}


sub createCircosConfFile{
	# Create main circos configuration file
	my ($confDirectory,$genericConfLocation,$genericConfLocation2,$karyotypeLocation,$organism,$genomeVer,$chromosomeListRef,$oneToCreateLinks) = @_;
	my @chromosomeList = @{$chromosomeListRef};
	my $numberOfChromosomes = scalar @chromosomeList;
	if($debugLevel >= 2){
		print " In createCircosConfFile \n";
	}
	my $fileName = $confDirectory.'circos.conf';
	open(CONFFILE,'>',$fileName) || die ("Can't open $fileName:$!");

	print CONFFILE '<<include '.$genericConfLocation.'colors_fonts_patterns.conf>>'."\n";

	print CONFFILE '<<include '.$confDirectory.'ideogram.conf>>'."\n";
	print CONFFILE '<<include '.$genericConfLocation2.'ticks.conf>>'."\n";

	if( $genomeVer eq 'rn5'){
		print CONFFILE 'karyotype   = '.$karyotypeLocation.'karyotype.rat.rn5.txt'."\n";
	}elsif( $genomeVer eq 'rn6'){
		print CONFFILE 'karyotype   = '.$karyotypeLocation.'karyotype.rat.rn6.txt'."\n";
	}elsif($organism eq 'Mm'){
		print CONFFILE 'karyotype   = '.$karyotypeLocation.'karyotype.mouse.mm10.txt'."\n";
	}
	else{
		die (" Organism is neither mouse nor rat :!\n");
	}

	print CONFFILE '<image>'."\n";
	print CONFFILE '<<include '.$genericConfLocation.'image.conf>>'."\n";
	print CONFFILE '</image>'."\n";

	print CONFFILE 'chromosomes_units = 1000000'."\n";

	print CONFFILE 'chromosomes = ';
	for(my $i = 0; $i < $numberOfChromosomes-1; $i++){
		print CONFFILE $chromosomeList[$i].';';
	}
	print CONFFILE $chromosomeList[$numberOfChromosomes-1]."\n";
	print CONFFILE 'chromosomes_display_default = no'."\n";

	print CONFFILE '<plots>'."\n";

	print CONFFILE '<<include '.$confDirectory.'circosGenesText.conf>>'."\n";


	print CONFFILE '<<include '.$confDirectory.'circosQTLCount.conf>>'."\n";

	print CONFFILE '</plots>'."\n";

	if($oneToCreateLinks == 1){
		print CONFFILE '<links>'."\n";

		print CONFFILE '<<include '.$confDirectory.'circosLinks.conf>>'."\n";

		print CONFFILE '</links>'."\n";
	}
	print CONFFILE '<<include '.$genericConfLocation.'housekeeping.conf>>'."\n";
	close(CONFFILE);

}


sub createCircosIdeogramConfFiles{
	my ($confDirectory,$organism,$chromosomeListRef) = @_;
	# This routine will create the ideogram.conf file in the $confDirectory location
	my @chromosomeList = @{$chromosomeListRef};
	my $numberOfChromosomes = scalar @chromosomeList;
	my $fileName = $confDirectory.'ideogram.conf';
	open(CONFFILE,'>',$fileName) || die ("Can't open $fileName:$!");
	print CONFFILE '<ideogram>'."\n";
	print CONFFILE '<spacing>'."\n";
	print CONFFILE 'default = 0.01r'."\n";
	print CONFFILE 'break   = 0.25r'."\n";
	print CONFFILE '<pairwise '.$chromosomeList[0].','.$chromosomeList[$numberOfChromosomes-1].'>'."\n";
	print CONFFILE 'spacing = 5.0r'."\n";
	print CONFFILE '</pairwise>'."\n";
	print CONFFILE '</spacing>'."\n";
	print CONFFILE '# Position'."\n";
	print CONFFILE 'radius           = 0.775r'."\n";
	print CONFFILE 'thickness        = 30p'."\n";
	print CONFFILE 'fill             = yes'."\n";
	print CONFFILE 'fill_color       = black'."\n";
	print CONFFILE 'stroke_thickness = 2'."\n";
	print CONFFILE 'stroke_color     = black'."\n";
	print CONFFILE '# Label'."\n";
	print CONFFILE 'show_label       = yes'."\n";
	print CONFFILE 'label_font       = default'."\n";
	print CONFFILE 'label_radius = dims(ideogram,radius_inner) - 75p'."\n";
	print CONFFILE 'label_size       = 60'."\n";
	print CONFFILE 'label_parallel   = yes'."\n";
	print CONFFILE 'label_case       = upper'."\n";
	print CONFFILE '# Bands'."\n";
	print CONFFILE 'show_bands            = yes'."\n";
	print CONFFILE 'fill_bands            = yes'."\n";
	print CONFFILE 'band_stroke_thickness = 2'."\n";
	print CONFFILE 'band_stroke_color     = white'."\n";
	print CONFFILE 'band_transparency     = 0'."\n";
	print CONFFILE 'radius*       = 0.825r'."\n";
	print CONFFILE '</ideogram>'."\n";
	close(CONFFILE);
}

sub createCircosGenesTextConfFile{
	# Create the circos configuration file that allows labeling of the probeset ID
	my ($dataDirectory,$confDirectory) = @_;
	if($debugLevel >= 2){
		print " In createCircosGeneListTextConfFile \n";
	}
	my $fileName = $confDirectory.'circosGenesText.conf';
	open(CONFFILE,'>',$fileName) || die ("Can't open $fileName:!\n");
	print CONFFILE '<plot>'."\n";

	print CONFFILE 'type             = text'."\n";
	print CONFFILE 'color            = red'."\n";
	print CONFFILE 'file = '.$dataDirectory.'genes.txt'."\n";
	print CONFFILE 'r0 = 1.07r'."\n";
	print CONFFILE 'r1 = 1.07r+900p'."\n";
	print CONFFILE 'show_links     = no'."\n";
	print CONFFILE 'link_dims      = 0p,0p,20p,0p,5p'."\n";
	print CONFFILE 'link_thickness = 2p'."\n";
	print CONFFILE 'link_color     = red'."\n";
	print CONFFILE 'label_size   = 20p'."\n";
	#print CONFFILE 'label_font=glyph'."\n";
	print CONFFILE 'label_font   = default'."\n";
	print CONFFILE 'padding  = 1p'."\n";
	print CONFFILE 'rpadding = 1p'."\n";
	print CONFFILE 'max_snuggle_distance = 2r'."\n";
	print CONFFILE '<rules>'."\n";
	print CONFFILE '<rule>'."\n";
	print CONFFILE 'condition = 1'."\n";
	print CONFFILE 'value=X'."\n";
	print CONFFILE 'flow = continue # if this rule passes, continue testing'."\n";
	print CONFFILE '</rule>'."\n";
	print CONFFILE '<rule>'."\n";
	print CONFFILE 'condition = var(svgclass)'."\n";
	print CONFFILE 'svgclass  = eval(my $x = var(svgclass); $x =~ s/\./ /g; $x)'."\n";
	print CONFFILE 'flow = continue # if this rule passes, continue testing'."\n";
	print CONFFILE '</rule>'."\n";
	print CONFFILE '<rule>'."\n";
	print CONFFILE 'condition = eval(my $x=index(var(value),"ENS")+1; $x==1)'."\n";
	print CONFFILE 'color = green'."\n";
	print CONFFILE '</rule>'."\n";
	print CONFFILE '</rules>'."\n";
	print CONFFILE '</plot>'."\n";
	close(CONFFILE);
}


sub createCircosGenesTextDataFile{
	# Create the circos data file that allows labeling of the genes in the module
 	my ($dataDirectory,$organism,$type)=@_;
	my %geneHash={};
	my $end=rindex($dataDirectory,"/",rindex($dataDirectory,"/",rindex($dataDirectory,"/")-1)-1);
	my $inputFile=substr($dataDirectory,0,$end)."/geneListLocations.txt";
    print "INPUT ".$inputFile."\n";

 	if($debugLevel >= 2){
 		print " In createCircosProbesetTextDataFile \n";
 	}

    my $fileName = $dataDirectory.'genes.txt';
    open(DATAFILE,'>',$fileName) || die ("Can't open $fileName:!\n");
	open(INFILE,'<',$inputFile) || die ("Can't open $inputFile:!\n");
	while(<INFILE>){
		my @cols=split("\t",$_);
		my @gs=split(",",$cols[2]);
		my @trx=split(",",$cols[3]);
		my @phid=split(",",$cols[4]);
		my $id="";
		if($type eq "array"){
			$id=$trx[0];
		}else{
			$id=$phid[0];
		}
		$id =~ s/\s+$//;
		$geneHash{$id}={chromosome => $cols[0],start=>$cols[1],stop=>$cols[1]+20000,geneSymbol=>$gs[0],id=>$id};
		my $colorGene="96,151,184";
		if(index($gs[0],"P")==0){
			$colorGene="193,163,102";
		}
		print DATAFILE $cols[0], " ",$cols[1], " ",$cols[1]+20000, " ",$gs[0]," svgclass=circosGene.",replaceDot($gs[0]),",color=",$colorGene,",svgid=",replaceDot($id), "\n";
	}
 	close(INFILE);
 	close(DATAFILE);
	return (\%geneHash);
 }


sub createCircosEQTLCountConfFile{
	# Create the circos configuration file that allows displaying pvalue histograms
	my ($confDirectory,$dataDirectory,$cutoff,$organism,$tissue,$type)=@_;
	my @tissueList=split(";",$tissue);
	my $numberOfTissues =scalar @tissueList;
	if($debugLevel >= 2){
		print " In createCircosPvaluesConfFile \n";
	}

	my $fileName = $confDirectory.'circosQTLCount.conf';
	#open(CONFFILE,'>',$fileName) || die ("Can't open $fileName:!\n");


	open my $PLOTFILEHANDLE,'>',$fileName || die ("Can't open $fileName:!\n");


	print $PLOTFILEHANDLE 'extend_bin = no'."\n";
	print $PLOTFILEHANDLE 'fill_under = yes'."\n";
	print $PLOTFILEHANDLE 'stroke_thickness = 1p'."\n";


	my $plotColor;
	my $innerRadius;
	my $outerRadius;
	my $plotFileName;
	my %colorHash;
	$colorHash{'Brain'}='blues-5-seq';
	$colorHash{'Liver'}='greens-5-seq';

	my %filenameHash;
	$filenameHash{'Brain'}='circosBrainCount.txt';
	$filenameHash{'Liver'}='circosLiverCount.txt';

	if($type eq "array") {
		$colorHash{'Heart'}='reds-5-seq';
		$colorHash{'BAT'}='purples-5-seq';
		$filenameHash{'Heart'} = 'circosHeartCount.txt';
		$filenameHash{'BAT'} = 'circosBATCount.txt';
	}

	if($debugLevel >= 2){
		foreach my $key (keys(%colorHash)){
			print " key $key $colorHash{$key} \n";
		}
	}
	my @innerRadiusArray = ('0.85r','0.75r','0.65r','0.55r');
	my @outerRadiusArray = ('0.85r + 100p','0.75r + 100p','0.65r + 100p','0.55r + 100p');

	for(my $i=0; $i<$numberOfTissues; $i++){
		$plotColor = $colorHash{$tissueList[$i]};
		$plotFileName = $dataDirectory.$filenameHash{$tissueList[$i]};
		$innerRadius=$innerRadiusArray[$i];
		$outerRadius=$outerRadiusArray[$i];
		writePlot($PLOTFILEHANDLE,$plotFileName,$plotColor,$innerRadius,$outerRadius,$cutoff);
	}
	close($PLOTFILEHANDLE);
}


sub createCircosEQTLCountLinkDataFiles{
	# Create data files for pvalues
	# The number of data files will depend on the species and the variable "tissue"
	# If species is rat and tissue is "all" then
	# To simplify, create all 4 data files in all cases
	# TBD fix this later.
	# the configuration file will tell which of the data files to use
	# The data looks like this:
	# rn1 15538471 20538471 0.646468441
	# The 2nd column is the location of the SNP
	# The 3rd column has been modified so the histogram shows up better.
	# The 3rd column might be modified by adding 5000000
	my ($dataDirectory,$organism, $chromosomeListRef,$tissueString,$interval,$cutoff,$type,$geneHashRef) = @_;
	my @innerRadiusArray = ('0.85r','0.75r','0.65r','0.55r');
	my %geneHash=%{$geneHashRef};
	my @tissueList=split(";",$tissueString);
	my $numberOfTissues = scalar @tissueList;
	my @chromosomeList = @{$chromosomeListRef};
	my $numberOfChromosomes = scalar @chromosomeList;

	my $end=rindex($dataDirectory,"/",rindex($dataDirectory,"/",rindex($dataDirectory,"/")-1)-1);
	my $inputFile=substr($dataDirectory,0,$end)."/geneListEQTLs_".$type.".txt";
	open(INPUT,'<',$inputFile) || die ("Can't open $inputFile:!\n");
	my %eQTLsHOH={};
	my %outfileHash;
	open($outfileHash{'Brain'},'>',$dataDirectory.'links_brain.txt');
	open($outfileHash{'Liver'},'>',$dataDirectory.'links_liver.txt');
	open($outfileHash{'Heart'},'>',$dataDirectory.'links_heart.txt');
	open($outfileHash{'BAT'},'>',$dataDirectory.'links_bat.txt');
	my %tissueRadius={};
	for(my $i=0; $i<$numberOfTissues; $i++) {
		$tissueRadius{$tissueList[$i]}=$innerRadiusArray[$i];
	}

	my $count=0;
	while(<INPUT>) {
		my @cols = split("\t", $_);
		if($cols[3] >= $cutoff) {
			if (exists $eQTLsHOH{$cols[2]}) {

			}
			else {
				#print "adding tissue:" . $cols[2] . "\n";
				$eQTLsHOH{$cols[2]} = {};
			}
			if (exists $eQTLsHOH{$cols[2]}{$cols[0]}) {

			}
			else {
				#print "adding chr:" . $cols[0] . "\n";
				$eQTLsHOH{$cols[2]}{$cols[0]} = {};
			}
			my $ind = "";
			#calculate index
			my $base = floor($cols[1] / $interval);
			my $start = $base * $interval + 1;
			my $end = $start + $interval - 1;
			$ind = $start . "-" . $end;
			#print($cols[1] . ":" . $base . ":" . $start . ":" . $end . ":" . $ind . "\n");
			if (exists $eQTLsHOH{$cols[2]}{$cols[0]}{$ind}) {
				$eQTLsHOH{$cols[2]}{$cols[0]}{$ind} = $eQTLsHOH{$cols[2]}{$cols[0]}{$ind} + 1;
			}
			else {
				$eQTLsHOH{$cols[2]}{$cols[0]}{$ind} = 1;
			}

			my $tissue=$cols[2];
			if($tissue eq "Whole Brain"){
				$tissue="Brain";
			}elsif($tissue eq "Brown Adipose"){
				$tissue="BAT";
			}
			my $curID=$cols[4];
			$curID =~ s/\s+$//;
			#print $curID.":".$geneHash{$curID}{'id'}.":\n";
			print {$outfileHash{$tissue}} $organism.$cols[0]." ".$cols[1]." ".($cols[1]+20000)." ".$geneHash{$curID}{'chromosome'}." ".$geneHash{$curID}{'start'}." ".$geneHash{$curID}{'stop'}." thickness=".(floor($cols[3])+1)."p,radius2=1.05r,radius1=".$tissueRadius{$tissue}.",svgid=".$curID."_".$tissue."_".$cols[0]."_".$base.",svgclass=".$curID."_".$tissue."-".$cols[0]."-".$base."\n";
			#print {$outfileHash{$tissue}} $tissue."_".$count." ".$organism.$cols[0]." ".$cols[1]." ".($cols[1]+20000)." thickness=".(floor($cols[3])+1)."p,class=\"".$tissue." ".$curID."\"\n";
			#print {$outfileHash{$tissue}} $tissue."_".$count." ".$geneHash{$curID}{'chromosome'}." ".$geneHash{$curID}{'start'}." ".$geneHash{$curID}{'stop'}." thickness=".(floor($cols[3])+1)."p,class=\"".$tissue." ".$curID."\"\n";
			$count=$count+1;
		}
	}
	close(INPUT);
	close($outfileHash{'Brain'});
	close($outfileHash{'Liver'});
	close($outfileHash{'Heart'});
	close($outfileHash{'BAT'});

	my %filenameHash;
	$filenameHash{'Brain'}='circosBrainCount.txt';
	$filenameHash{'Liver'}='circosLiverCount.txt';
	$filenameHash{'Heart'}='circosHeartCount.txt';
	$filenameHash{'BAT'}='circosBATCount.txt';
	for(my $i=0; $i<$numberOfTissues; $i++){
		my $outFileName =  $dataDirectory.$filenameHash{$tissueList[$i]};
		open(OUTFILE,'>',$outFileName) || die ("Can't open $outFileName:!\n");
		my $curTissue=$tissueList[$i];
		if($curTissue eq "Brain"){
			$curTissue="Whole Brain";
		}elsif($curTissue eq "BAT"){
			$curTissue="Brown Adipose";
		}
		if(exists $eQTLsHOH{$curTissue}) {
			#print "tissue:".$curTissue."\n";
			my %tissueHOH = %{$eQTLsHOH{$curTissue}};

			my @chrKeys = keys %tissueHOH;
			foreach ( @chrKeys) {
				my $chr = $_;
				#print "chr:".$chr.":\n";
				if(exists $tissueHOH{$chr}) {
					my %rangeH = %{$tissueHOH{$chr}};
					my @rangeKeys = keys %rangeH;
					foreach ( @rangeKeys) {
						my $range=$_;
						my @splitRange = split("-", $range);
						my $base=($splitRange[0]-1)/$interval;
						print OUTFILE $organism . $chr . " " . $splitRange[0] . " " . $splitRange[1] . " " . $rangeH{$range} ." svgid=".$tissueList[$i]."-".$chr."-".$base.",svgclass=heatmap\n";
					}
				}
			}
		}
		close(OUTFILE);
	}

	 #my $brainFileName =  $dataDirectory.$filenameHash{$tissueString};
	 #open(BRAINFILE,'>',$brainFileName) || die ("Can't open $brainFileName:!\n");

	 #my $liverFileName = $dataDirectory.'circosLiverPValues.txt';
	 #open(LIVERFILE,'>',$liverFileName) || die ("Can't open $liverFileName:!\n");

	 #my $heartFileName = $dataDirectory.'circosHeartPValues.txt';
	 #open(HEARTFILE,'>',$heartFileName) || die ("Can't open $heartFileName:!\n");

	 #my $BATFileName = $dataDirectory.'circosBATPValues.txt';
	 #open(BATFILE,'>',$BATFileName) || die ("Can't open $BATFileName:!\n");

	 #my $sp="mm";
	 #if ($organism eq "Rn") {
	 #	$sp="rn";
	 #}


	# close(BRAINFILE);
	#close(HEARTFILE);
	#close(LIVERFILE);
	#close(BATFILE);
}

sub createCircosLinksConf{
	# Create configuration and data file for circos links
	# This is more complicated since there will be a varying number of data files
	# Therefore, keeping the configuration and data file creation together
	my ($dataDirectory,$organism,$confDirectory,$tissueString) = @_;
	my @tissueList=split(";",$tissueString);
	my $numberOfTissues = scalar @tissueList;
	# Now create the conf file
	my $confFileName = $confDirectory."circosLinks.conf";
	open CONFFILEHANDLE,'>',$confFileName || die ("Can't open $confFileName:!\n");


	my %colorHash;
	$colorHash{'Brain'}="107,174,214,0.0";
	$colorHash{'Liver'}="116,196,118,0.0";
	$colorHash{'Heart'}="251,106,74,0.0";
	$colorHash{'BAT'}="158,154,200,0.0";
	my $radius="0.75r";
	if($numberOfTissues==1){
		$radius="0.85r";
	}elsif($numberOfTissues==3){
		$radius="0.65r";
	}elsif($numberOfTissues==4){
		$radius="0.55r";
	}
	for(my $i=0;$i<$numberOfTissues;$i++){
		#$linkFileName = $dataDirectory."links_".tolower($tissueList[$i]).".txt";
		print CONFFILEHANDLE "<link>\n";
		print CONFFILEHANDLE "file = data/links_".tolower($tissueList[$i]).".txt\n";
		print CONFFILEHANDLE "color = ".$colorHash{$tissueList[$i]}."\n";
		print CONFFILEHANDLE "radius = ".$radius."\n";
		print CONFFILEHANDLE "bezier_radius = 0.1r \n";
		print CONFFILEHANDLE "thickness = 1\n";
		print CONFFILEHANDLE "<rules>\n";
		print CONFFILEHANDLE "<rule>\n";
		print CONFFILEHANDLE "condition = 1\n";
		print CONFFILEHANDLE "svgclass  = eval(my \$x = var(svgclass); \$x =~ s/_/ /g; \$x)\n";
		print CONFFILEHANDLE "</rule>\n";
		print CONFFILEHANDLE "</rules>\n";

		print CONFFILEHANDLE "</link>\n";


	}
	close(CONFFILEHANDLE);
	#print " Finished with createCircosLinksConfAndData \n";
}





sub writePlot{
	my ($FILEHANDLE,$plotFileName,$plotColor,$innerRadius,$outerRadius) = @_;
	 print $FILEHANDLE '<plot>'."\n";
	 print $FILEHANDLE 'show = yes'."\n";
	 print $FILEHANDLE 'type = heatmap'."\n";
	 print $FILEHANDLE 'color = '.$plotColor."\n";
	 print $FILEHANDLE 'r0 = '.$innerRadius."\n";
	 print $FILEHANDLE 'r1 = '.$outerRadius."\n";
	#
	print $FILEHANDLE 'file = '.$plotFileName."\n";
	#
	# #print $FILEHANDLE 'file = '.$dataDirectory.'circosBrainPValues.txt'."\n";
	#
	print $FILEHANDLE '</plot>'."\n";

}

1;
