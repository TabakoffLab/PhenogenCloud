#!/usr/bin/perl
use strict;
use POSIX qw(log10);

my $debugLevel = 2;
sub prepCircosReverse {
    # this routine creates configuration and data files for circos
    my ($inputFileName, $cutoff, $organism, $confDirectory, $dataDirectory, $chromosomeListRef, $tissueListRef, $hostname) = @_;
    my @chromosomeList = @{$chromosomeListRef};
    my $numberOfChromosomes = scalar @chromosomeList;
    my @tissueList = @{$tissueListRef};
    my $numberOfTissues = scalar @tissueList;
    my $genericConfLocation;
    my $genericConfLocation2;
    my $karyotypeLocation;

    $genericConfLocation = '/usr/share/circos/etc/';
    $genericConfLocation2 = '/usr/share/tomcat/webapps/PhenoGen/web/';
    $karyotypeLocation = '/usr/share/circos/data/karyotype/';

    createCircosConfFile($confDirectory, $genericConfLocation, $genericConfLocation2, $karyotypeLocation, $organism, $chromosomeListRef);
    createCircosIdeogramConfFiles($confDirectory, $organism, $chromosomeListRef);


    # Now read input file
    my $inputAOHRef = readInputFile($inputFileName, $organism);
    my @inputAOH = @{$inputAOHRef};

    createCircosPvaluesConfFile($confDirectory, $dataDirectory, $cutoff, $organism, $tissueListRef);

    createCircosProbesetTextConfFile($dataDirectory, $confDirectory);

    my $probeTextHashRef = createCircosLinksConfAndData($dataDirectory, $organism, $confDirectory, $inputAOHRef, $cutoff, $tissueListRef, $chromosomeListRef);
    createCircosPvaluesDataFiles($dataDirectory, $organism, $inputAOHRef, $chromosomeListRef, $tissueListRef, $cutoff, $probeTextHashRef);
}

sub readInputFile() {
    my ($inputFileName, $organism) = @_;
    my @inputAOH;
    my $i = 0;
    my $fileLine;
    my @fileLineArray;
    open(FILE, "<", $inputFileName) || die("Can't open $inputFileName:!\n");
    while (<FILE>) {
        chomp;
        $fileLine = $_;
        @fileLineArray = split('\t', $fileLine);
        $inputAOH[$i]{snp_id} = $fileLineArray[0];
        $inputAOH[$i]{snp_chromosome} = lc($organism) . $fileLineArray[1];
        $inputAOH[$i]{snp_start} = $fileLineArray[2];
        $inputAOH[$i]{probe_id} = $fileLineArray[3];
        $inputAOH[$i]{probe_chromosome} = lc($organism) . $fileLineArray[4];
        $inputAOH[$i]{probe_start} = $fileLineArray[5];
        $inputAOH[$i]{probe_stop} = $fileLineArray[6];
        $inputAOH[$i]{gene_symbol} = $fileLineArray[7];
        $inputAOH[$i]{tissue} = $fileLineArray[8];
        $inputAOH[$i]{pvalue} = $fileLineArray[9];
        #$inputAOH[$i]{pvalue} = -1*log10($fileLineArray[9]);
        $i++;
    }
    close(FILE);
    for (my $i = 0; $i < 3; $i++) {
        print "\nsnp_id: ";
        print $inputAOH[$i]{snp_id};
        print "\nsnp_chromosome: ";
        print $inputAOH[$i]{snp_chromosome};
        print "\nprobe_id: ";
        print $inputAOH[$i]{probe_id};
        print "\nprobe_chromosome: ";
        print $inputAOH[$i]{probe_chromosome};
        print "\npvalue: ";
        print $inputAOH[$i]{pvalue};
        print "\n";
    }
    print "\n";
    print " Number of input file lines read $i \n";
    return (\@inputAOH);
}

sub createCircosConfFile {
    # Create main circos configuration file
    my ($confDirectory, $genericConfLocation, $genericConfLocation2, $karyotypeLocation, $organism, $chromosomeListRef) = @_;
    my @chromosomeList = @{$chromosomeListRef};
    my $numberOfChromosomes = scalar @chromosomeList;
    if ($debugLevel >= 2) {
        print " In createCircosConfFile \n";
    }
    my $fileName = $confDirectory . 'circos.conf';
    open(CONFFILE, '>', $fileName) || die("Can't open $fileName:$!");

    print CONFFILE '<<include ' . $genericConfLocation . 'colors_fonts_patterns.conf>>' . "\n";

    print CONFFILE '<<include ' . $confDirectory . 'ideogram.conf>>' . "\n";
    print CONFFILE '<<include ' . $genericConfLocation2 . 'ticks.conf>>' . "\n";

    if ($organism eq 'Rn') {
        print CONFFILE 'karyotype   = ' . $karyotypeLocation . 'karyotype.rat.rn5.txt' . "\n";
    }
    elsif ($organism eq 'Mm') {
        print CONFFILE 'karyotype   = ' . $karyotypeLocation . 'karyotype.mouse.mm10.txt' . "\n";
    }
    else {
        die(" Organism is neither mouse nor rat :!\n");
    }

    print CONFFILE '<image>' . "\n";
    print CONFFILE '<<include ' . $genericConfLocation . 'image.conf>>' . "\n";
    print CONFFILE '</image>' . "\n";

    print CONFFILE 'chromosomes_units = 1000000' . "\n";

    print CONFFILE 'chromosomes = ';
    for (my $i = 0; $i < $numberOfChromosomes - 1; $i++) {
        print CONFFILE $chromosomeList[$i] . ';';
    }
    print CONFFILE $chromosomeList[$numberOfChromosomes - 1] . "\n";
    print CONFFILE 'chromosomes_display_default = no' . "\n";

    print CONFFILE '<plots>' . "\n";
    #print CONFFILE '<<include '.$confDirectory.'circosTiles.conf>>'."\n";
    print CONFFILE '<<include ' . $confDirectory . 'circosProbesetText.conf>>' . "\n";
    print CONFFILE '<<include ' . $confDirectory . 'circosPValues.conf>>' . "\n";

    print CONFFILE '</plots>' . "\n";

    print CONFFILE '<links>' . "\n";

    print CONFFILE '<<include ' . $confDirectory . 'circosLinks.conf>>' . "\n";

    print CONFFILE '</links>' . "\n";

    print CONFFILE '<<include ' . $genericConfLocation . 'housekeeping.conf>>' . "\n";
    close(CONFFILE);

}

sub createCircosIdeogramConfFiles {
    my ($confDirectory, $organism, $chromosomeListRef) = @_;
    # This routine will create the ideogram.conf file in the $confDirectory location
    my @chromosomeList = @{$chromosomeListRef};
    my $numberOfChromosomes = scalar @chromosomeList;
    my $fileName = $confDirectory . 'ideogram.conf';
    open(CONFFILE, '>', $fileName) || die("Can't open $fileName:$!");
    print CONFFILE '<ideogram>' . "\n";
    print CONFFILE '<spacing>' . "\n";
    print CONFFILE 'default = 0.01r' . "\n";
    print CONFFILE 'break   = 0.25r' . "\n";
    print CONFFILE '<pairwise ' . $chromosomeList[0] . ',' . $chromosomeList[$numberOfChromosomes - 1] . '>' . "\n";
    print CONFFILE 'spacing = 5.0r' . "\n";
    print CONFFILE '</pairwise>' . "\n";
    print CONFFILE '</spacing>' . "\n";
    print CONFFILE '# Position' . "\n";
    print CONFFILE 'radius           = 0.775r' . "\n";
    print CONFFILE 'thickness        = 30p' . "\n";
    print CONFFILE 'fill             = yes' . "\n";
    print CONFFILE 'fill_color       = black' . "\n";
    print CONFFILE 'stroke_thickness = 2' . "\n";
    print CONFFILE 'stroke_color     = black' . "\n";
    print CONFFILE '# Label' . "\n";
    print CONFFILE 'show_label       = yes' . "\n";
    print CONFFILE 'label_font       = default' . "\n";
    print CONFFILE 'label_radius = dims(ideogram,radius_inner) - 75p' . "\n";
    print CONFFILE 'label_size       = 60' . "\n";
    print CONFFILE 'label_parallel   = yes' . "\n";
    print CONFFILE 'label_case       = upper' . "\n";
    print CONFFILE '# Bands' . "\n";
    print CONFFILE 'show_bands            = yes' . "\n";
    print CONFFILE 'fill_bands            = yes' . "\n";
    print CONFFILE 'band_stroke_thickness = 2' . "\n";
    print CONFFILE 'band_stroke_color     = white' . "\n";
    print CONFFILE 'band_transparency     = 0' . "\n";
    print CONFFILE 'radius*       = 0.825r' . "\n";
    print CONFFILE '</ideogram>' . "\n";
    close(CONFFILE);
}

sub createCircosProbesetTextConfFile {
    # Create the circos configuration file that allows labeling of the probeset ID
    my ($dataDirectory, $confDirectory) = @_;
    if ($debugLevel >= 2) {
        print " In createCircosProbesetTextConfFile \n";
    }
    my $fileName = $confDirectory . 'circosProbesetText.conf';
    open(CONFFILE, '>', $fileName) || die("Can't open $fileName:!\n");
    print CONFFILE '<plot>' . "\n";
    print CONFFILE 'type             = text' . "\n";
    print CONFFILE 'color            = black' . "\n";
    print CONFFILE 'file = ' . $dataDirectory . 'probesets.txt' . "\n";
    print CONFFILE 'r0 = 1.07r' . "\n";
    print CONFFILE 'r1 = 1.07r+1500p' . "\n";
    print CONFFILE 'show_links     = yes' . "\n";
    print CONFFILE 'link_dims      = 0p,0p,20p,0p,10p' . "\n";
    print CONFFILE 'link_thickness = 5p' . "\n";
    print CONFFILE 'link_color     = red' . "\n";
    print CONFFILE 'label_size   = 18p' . "\n";
    print CONFFILE 'label_font   = default' . "\n";
    print CONFFILE 'padding  = 0p' . "\n";
    print CONFFILE 'rpadding = 0p' . "\n";
    print CONFFILE '</plot>' . "\n";
    close(CONFFILE);
}

sub DeleteThisSubcreateCircosProbesetTextDataFile {
    # Create the circos data file that allows labeling of the probeset ID
    my ($inputAOHRef, $dataDirectory, $organism) = @_;
    if ($debugLevel >= 2) {
        print " In createCircosProbesetTextDataFile \n";
    }
    my @inputAOH = @{$inputAOHRef};
    my $inputFileCount = scalar @inputAOH;
    my $fileName = $dataDirectory . 'probesets.txt';
    open(DATAFILE, '>', $fileName) || die("Can't open $fileName:!\n");
    # Example of data in this file:  rn12	34947771	34947875	P2rx4-5731411
    # Probably do away with the P2rx4- since that information will appear elsewhere on the page??
    #print DATAFILE $probeChromosome, " ",$probeStart, " ",$probeStop, " ",$probeID, "\n";
    my %probeTextHash;
    my $gene_symbol;
    for (my $i = 0; $i < $inputFileCount; $i++) {
        $gene_symbol = $inputAOH[$i]{gene_symbol};
        $probeTextHash{$gene_symbol}{chromosome} = $inputAOH[$i]{probe_chromosome};
        $probeTextHash{$gene_symbol}{probe_start} = $inputAOH[$i]{probe_start};
        $probeTextHash{$gene_symbol}{probe_stop} = $inputAOH[$i]{probe_stop};
    }

    foreach my $key (keys %probeTextHash) {
        print DATAFILE $probeTextHash{$key}{chromosome}, " ", $probeTextHash{$key}{probe_start}, " ", $probeTextHash{$key}{probe_stop}, " ", $key, "\n";
        #print DATAFILE $inputAOH[$i]{probe_chromosome}," ",$inputAOH[$i]{probe_start}," ",$inputAOH[$i]{probe_stop}," ",$inputAOH[$i]{gene_symbol},"\n";
    }
    close(DATAFILE);
}

sub createCircosLinksConfAndData {
    # Create configuration and data file for circos links
    # This is more complicated since there will be a varying number of data files
    # Therefore, keeping the configuration and data file creation together
    my ($dataDirectory, $organism, $confDirectory, $inputAOHRef, $cutoff, $tissueListRef, $chromosomeListRef) = @_;
    my @chromosomeList = @{$chromosomeListRef};
    my $numberOfChromosomes = scalar @chromosomeList;
    my @tissueList = @{$tissueListRef};
    my $numberOfTissues = scalar @tissueList;
    if ($debugLevel >= 2) {
        print " In createCircosLinksConfAndData \n";
    }
    my @linkAOH; # this is an array of hashes to store required data
    my @inputAOH = @{$inputAOHRef};
    my $arrayLength = scalar @inputAOH;
    my $i;
    my $linkCount = -1;
    my $numberString;
    my $tissue;
    my $chromosome;
    my $linkColor;
    my $keepLink;
    my $keepLink2;
    my %probeTextHash;
    my $gene_symbol;
    for ($i = 0; $i < $arrayLength; $i++) {
        if ($inputAOH[$i]{pvalue} > $cutoff) {
            # Check whether we want this type of link
            $tissue = $inputAOH[$i]{tissue};
            $chromosome = $inputAOH[$i]{probe_chromosome};
            if ($tissue eq "Whole Brain") {
                $linkColor = 'blue';
                $tissue = "Brain";
            }
            elsif ($tissue eq "Liver") {
                $linkColor = 'green';
            }
            elsif ($tissue eq "Heart") {
                $linkColor = 'red';
            }
            elsif ($tissue eq "Brown Adipose") {
                $linkColor = 'purple';
                $tissue = "BAT";
            }
            elsif ($tissue eq "Kidney") {
                $linkColor = 'orange';
            }
            $keepLink = 0;
            for (my $j = 0; $j < $numberOfTissues; $j++) {
                if ($tissueList[$j] eq $tissue) {
                    $keepLink = 1;
                }
            }
            $keepLink2 = 0;
            for (my $j = 0; $j < $numberOfChromosomes; $j++) {
                if ($chromosomeList[$j] eq $chromosome) {
                    $keepLink2 = 1;
                }
            }
            if (($keepLink == 1) && ($keepLink2 == 1)) {
                #
                # Add to the hash of probeset names
                #
                $gene_symbol = $inputAOH[$i]{gene_symbol};
                $probeTextHash{$gene_symbol}{chromosome} = $inputAOH[$i]{probe_chromosome};
                $probeTextHash{$gene_symbol}{probe_start} = $inputAOH[$i]{probe_start};
                $probeTextHash{$gene_symbol}{probe_stop} = $inputAOH[$i]{probe_stop};
                $linkCount++;
                # We want a link here between the probeset and this SNP.
                $linkAOH[$linkCount]{tissue} = $tissue;
                $linkAOH[$linkCount] = $inputAOH[$i];
                $linkAOH[$linkCount]{color} = $linkColor;
                $numberString = sprintf "%05d", $linkCount;
                $linkAOH[$linkCount]{linkname} = "Link_" . $tissue . "_" . $numberString;
                $linkAOH[$linkCount]{linknumber} = $linkCount;
            }
        }
    }
    my $totalLinks = scalar @linkAOH;
    if ($debugLevel >= 2) {
        print "Total Links: $totalLinks \n";
    }

    # Create the probeset text data file
    my $probesetTextFileName = $dataDirectory . 'probesets.txt';
    open(DATAFILE, '>', $probesetTextFileName) || die("Can't open $probesetTextFileName:!\n");

    foreach my $key (keys %probeTextHash) {
        print DATAFILE $probeTextHash{$key}{chromosome}, " ", $probeTextHash{$key}{probe_start}, " ", $probeTextHash{$key}{probe_stop}, " ", $key, "\n";
    }
    close(DATAFILE);

    # Now create data files for links
    # Also create tool tip file
    my $toolTipFileName = $dataDirectory . "LinkToolTips.txt";
    open(TOOLTIPFILE, '>', $toolTipFileName) || die("Can't open $toolTipFileName:!\n");
    my $linkFileName;
    my $linkName;
    for ($i = 0; $i < $totalLinks; $i++) {
        if ($debugLevel >= 3) {
            print " i $i \n";
            print " Link number: $linkAOH[$i]{linknumber} \n";
            print " Link Name: $linkAOH[$i]{linkname} \n";
            print " Tissue: $linkAOH[$i]{tissue} \n";
            print " Chromosome: $linkAOH[$i]{snp_chromosome} \n";
            print " Location: $linkAOH[$i]{snp_start} \n";
            print " SNP Name: $linkAOH[$i]{snp_id} \n";
            print " Link Color: $linkAOH[$i]{color} \n";
            print " Probe ID: $linkAOH[$i]{probe_id} \n";
            print " Probe Chromosome: $linkAOH[$i]{probe_chromosome} \n";
            print " Probe Start: $linkAOH[$i]{probe_start} \n";
            print " Probe Stop: $linkAOH[$i]{probe_stop} \n";
            print " Gene Symbol: $linkAOH[$i]{gene_symbol} \n";
            print " P Value: 	$linkAOH[$i]{pvalue} \n";
            print "\n";
        }
        print TOOLTIPFILE $linkAOH[$i]{linkname} . "\t" . substr($linkAOH[$i]{snp_chromosome}, 2) . "\t" . $linkAOH[$i]{snp_start} . "\t";
        print TOOLTIPFILE substr($linkAOH[$i]{probe_chromosome}, 2) . "\t" . $linkAOH[$i]{probe_start} . "\t" . $linkAOH[$i]{pvalue} . "\n";
        $linkFileName = $dataDirectory . $linkAOH[$i]{linkname} . ".txt";
        open(LINKFILE, '>', $linkFileName) || die("Can't open $linkFileName:!\n");
        print LINKFILE $linkAOH[$i]{snp_id} . "_" . $linkAOH[$i]{gene_symbol} . " " . $linkAOH[$i]{snp_chromosome} . " " . $linkAOH[$i]{snp_start} . " " . $linkAOH[$i]{snp_start} . "\n";
        print LINKFILE $linkAOH[$i]{snp_id} . "_" . $linkAOH[$i]{gene_symbol} . " " . $linkAOH[$i]{probe_chromosome} . " " . $linkAOH[$i]{probe_start} . " " . $linkAOH[$i]{probe_stop} . "\n";
        close(LINKFILE);
    }
    close(TOOLTIPFILE);
    # Now create the conf file
    my $confFileName = $confDirectory . "circosLinks.conf";
    open my $CONFFILEHANDLE, '>', $confFileName || die("Can't open $confFileName:!\n");

    for ($i = 0; $i < $totalLinks; $i++) {
        $linkFileName = $dataDirectory . $linkAOH[$i]{linkname} . ".txt";
        $linkName = $linkAOH[$i]{linkname};
        $linkColor = $linkAOH[$i]{color};
        writeLink($CONFFILEHANDLE, $linkFileName, $linkName, $linkColor, $organism, $numberOfTissues, $linkAOH[$i]{tissue});
    }
    close(CONFFILE);
    print " Finished with createCircosLinksConfAndData \n";
    return (\%probeTextHash);
}

sub createCircosPvaluesConfFile {
    # Create the circos configuration file that allows displaying pvalue histograms
    my ($confDirectory, $dataDirectory, $cutoff, $organism, $tissueListRef) = @_;
    my @tissueList = @{$tissueListRef};
    my $numberOfTissues = scalar @tissueList;
    if ($debugLevel >= 2) {
        print " In createCircosPvaluesConfFile \n";
    }

    my $fileName = $confDirectory . 'circosPValues.conf';
    #open(CONFFILE,'>',$fileName) || die ("Can't open $fileName:!\n");


    open my $PLOTFILEHANDLE, '>', $fileName || die("Can't open $fileName:!\n");

    print $PLOTFILEHANDLE 'extend_bin = no' . "\n";
    print $PLOTFILEHANDLE 'fill_under = yes' . "\n";
    print $PLOTFILEHANDLE 'stroke_thickness = 1p' . "\n";

    my $plotColor;
    my $innerRadius;
    my $outerRadius;
    my $plotFileName;
    my %colorHash;

    $colorHash{'Heart'} = 'red';
    $colorHash{'Brain'} = 'blue';
    $colorHash{'Liver'} = 'green';
    $colorHash{'BAT'} = 'purple';
    $colorHash{'Kidney'} = 'orange';
    my %filenameHash;

    $filenameHash{'Heart'} = 'circosHeartPValues.txt';
    $filenameHash{'Brain'} = 'circosBrainPValues.txt';
    $filenameHash{'Liver'} = 'circosLiverPValues.txt';
    $filenameHash{'BAT'} = 'circosBATPValues.txt';
    $filenameHash{'Kidney'} = 'circosKidneyPValues.txt';

    foreach my $key (keys(%colorHash)) {

        print " key $key $colorHash{$key} \n";

    }

    my @innerRadiusArray = ('0.80r', '0.65r', '0.50r', '0.35r');
    my @outerRadiusArray = ('0.80r + 150p', '0.65r + 150p', '0.50r + 150p', '0.35r + 150p');

    for (my $i = 0; $i < $numberOfTissues; $i++) {
        $plotColor = $colorHash{$tissueList[$i]};
        $plotFileName = $dataDirectory . $filenameHash{$tissueList[$i]};
        $innerRadius = $innerRadiusArray[$i];
        $outerRadius = $outerRadiusArray[$i];

        writePlot($PLOTFILEHANDLE, $plotFileName, $plotColor, $innerRadius, $outerRadius, $cutoff);
    }

    close($PLOTFILEHANDLE);
}

sub createCircosPvaluesConfFile {
    # Create the circos configuration file that allows displaying pvalue histograms
    my ($confDirectory, $dataDirectory, $cutoff, $organism, $tissueListRef) = @_;
    my @tissueList = @{$tissueListRef};
    my $numberOfTissues = scalar @tissueList;

    if ($debugLevel >= 2) {
        print " In createCircosPvaluesConfFile \n";
    }

    my $fileName = $confDirectory . 'circosPValues.conf';
    #open(CONFFILE,'>',$fileName) || die ("Can't open $fileName:!\n");


    open my $PLOTFILEHANDLE, '>', $fileName || die("Can't open $fileName:!\n");

    print $PLOTFILEHANDLE 'extend_bin = no' . "\n";
    print $PLOTFILEHANDLE 'fill_under = yes' . "\n";
    print $PLOTFILEHANDLE 'stroke_thickness = 1p' . "\n";

    my $plotColor;
    my $innerRadius;
    my $outerRadius;
    my $plotFileName;
    my %colorHash;

    $colorHash{'Heart'} = 'red';
    $colorHash{'Brain'} = 'blue';
    $colorHash{'Liver'} = 'green';
    $colorHash{'BAT'} = 'purple';
    $colorHash{'Kidney'} = 'orange';
    my %filenameHash;

    $filenameHash{'Heart'} = 'circosHeartPValues.txt';
    $filenameHash{'Brain'} = 'circosBrainPValues.txt';
    $filenameHash{'Liver'} = 'circosLiverPValues.txt';
    $filenameHash{'BAT'} = 'circosBATPValues.txt';
    $filenameHash{'Kidney'} = 'circosKidneyPValues.txt';

    foreach my $key (keys(%colorHash)) {

        print " key $key $colorHash{$key} \n";

    }

    my @innerRadiusArray = ('0.80r', '0.65r', '0.50r', '0.35r');
    my @outerRadiusArray = ('0.80r + 150p', '0.65r + 150p', '0.50r + 150p', '0.35r + 150p');

    for (my $i = 0; $i < $numberOfTissues; $i++) {
        $plotColor = $colorHash{$tissueList[$i]};
        $plotFileName = $dataDirectory . $filenameHash{$tissueList[$i]};
        $innerRadius = $innerRadiusArray[$i];
        $outerRadius = $outerRadiusArray[$i];

        writePlot($PLOTFILEHANDLE, $plotFileName, $plotColor, $innerRadius, $outerRadius, $cutoff);
    }

    close($PLOTFILEHANDLE);
}

sub createCircosPvaluesDataFiles {
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
    my ($dataDirectory, $organism, $inputAOHRef, $chromosomeListRef, $tissueListRef, $cutoff, $probeTextHashRef) = @_;
    my %probeTextHash = %{$probeTextHashRef};
    my @chromosomeList = @{$chromosomeListRef};
    my $numberOfChromosomes = scalar @chromosomeList;
    my @tissueList = @{$tissueListRef};
    my $numberOfTissues = scalar @tissueList;
    if ($debugLevel >= 2) {
        print " In createCircosPvaluesDataFiles \n";
    }
    my @inputAOH = @{$inputAOHRef};
    my $arrayLength = scalar @inputAOH;
    if ($debugLevel >= 2) {
        print " Length of array $arrayLength \n";
    }
    my $brainFileName = $dataDirectory . 'circosBrainPValues.txt';
    open(BRAINFILE, '>', $brainFileName) || die("Can't open $brainFileName:!\n");
    if ($organism eq 'Rn') {

        # We'll write out these files even though they may not all be needed.  Change later?

        my $liverFileName = $dataDirectory . 'circosLiverPValues.txt';
        open(LIVERFILE, '>', $liverFileName) || die("Can't open $liverFileName:!\n");

        my $heartFileName = $dataDirectory . 'circosHeartPValues.txt';
        open(HEARTFILE, '>', $heartFileName) || die("Can't open $heartFileName:!\n");

        my $BATFileName = $dataDirectory . 'circosBATPValues.txt';
        open(BATFILE, '>', $BATFileName) || die("Can't open $BATFileName:!\n");
        my $kidneyFileName = $dataDirectory . 'circosKidneyPValues.txt';
        open(KIDNEYFILE, '>', $kidneyFileName) || die("Can't open $BATFileName:!\n");
    }
    # Determine the gene symbols to keep

    # Go through the eqtl array of hashes and write data to appropriate files
    my $tissue;
    my $stopLocation;
    my $currentGeneSymbol;
    for (my $i = 0; $i < $arrayLength; $i++) {
        $tissue = $inputAOH[$i]{tissue};
        $stopLocation = $inputAOH[$i]{probe_start} + 50000 * $numberOfChromosomes;
        $currentGeneSymbol = $inputAOH[$i]{gene_symbol};
        if (exists $probeTextHash{$currentGeneSymbol}) {
            if ($tissue eq 'Whole Brain') {
                print BRAINFILE $inputAOH[$i]{probe_chromosome} . " " . $inputAOH[$i]{probe_start} . " " . $stopLocation . " " . $inputAOH[$i]{pvalue} . "\n";
            }
            elsif ($tissue eq 'Liver') {
                print LIVERFILE $inputAOH[$i]{probe_chromosome} . " " . $inputAOH[$i]{probe_start} . " " . $stopLocation . " " . $inputAOH[$i]{pvalue} . "\n";
            }
            elsif ($tissue eq 'Heart') {
                print HEARTFILE $inputAOH[$i]{probe_chromosome} . " " . $inputAOH[$i]{probe_start} . " " . $stopLocation . " " . $inputAOH[$i]{pvalue} . "\n";
            }
            elsif ($tissue eq 'Brown Adipose') {
                print BATFILE $inputAOH[$i]{probe_chromosome} . " " . $inputAOH[$i]{probe_start} . " " . $stopLocation . " " . $inputAOH[$i]{pvalue} . "\n";
            }
            elsif ($tissue eq 'Kidney') {
                print KIDNEYFILE $inputAOH[$i]{probe_chromosome} . " " . $inputAOH[$i]{probe_start} . " " . $stopLocation . " " . $inputAOH[$i]{pvalue} . "\n";
            }
            else {
                die(" Invalid Tissue in createCircosPvaluesDataFiles.  Organism: $organism  Tissue: $tissue\n");
            }
        }
    }
    close(BRAINFILE);
    if ($organism eq 'Rn') {
        close(HEARTFILE);
        close(LIVERFILE);
        close(BATFILE);
        close(KIDNEYFILE);
    }
}

sub writeLink {
    my ($FILEHANDLE, $LinkFileName, $linkName, $linkColor, $organism, $numberOfTissues, $tissue) = @_;

    print $FILEHANDLE "<link " . $linkName . ">" . "\n";
    print $FILEHANDLE  "z = 0" . "\n";

    if ($numberOfTissues == 4) {
        print $FILEHANDLE  "radius = 0.55r" . "\n";
    }
    elsif ($numberOfTissues == 3) {
        print $FILEHANDLE  "radius = 0.65r" . "\n";
    }
    elsif ($numberOfTissues == 2) {
        print $FILEHANDLE  "radius = 0.75r" . "\n";
    }
    else {
        print $FILEHANDLE "radius = 0.85r" . "\n";
    }

    print $FILEHANDLE  "bezier_radius = .1r" . "\n";
    print $FILEHANDLE  "show = yes" . "\n";
    print $FILEHANDLE  "color = " . $linkColor . "\n";
    print $FILEHANDLE  "thickness = 5" . "\n";
    print $FILEHANDLE  "file = " . $LinkFileName . "\n";
    print $FILEHANDLE  "</link>" . "\n";
}

sub writePlot {
    my ($FILEHANDLE, $plotFileName, $plotColor, $innerRadius, $outerRadius, $cutoff) = @_;
    print $FILEHANDLE '<plot>' . "\n";
    print $FILEHANDLE 'show = yes' . "\n";
    print $FILEHANDLE 'type = histogram' . "\n";
    print $FILEHANDLE 'stroke_color = ' . $plotColor . "\n";
    print $FILEHANDLE 'fill_color = ' . $plotColor . "\n";
    print $FILEHANDLE 'min = 0' . "\n";
    print $FILEHANDLE 'max = 15' . "\n";
    print $FILEHANDLE 'r0 = ' . $innerRadius . "\n";
    print $FILEHANDLE 'r1 = ' . $outerRadius . "\n";
    print $FILEHANDLE '<axes>' . "\n";
    print $FILEHANDLE '<axis>' . "\n";
    print $FILEHANDLE 'thickness = 1' . "\n";
    print $FILEHANDLE 'spacing = 0.15r' . "\n";
    #print $FILEHANDLE 'spacing = 1.0r'."\n";
    print $FILEHANDLE 'color = black' . "\n";
    #print $FILEHANDLE 'axis           = yes'."\n";
    #print $FILEHANDLE 'axis_color     = black'."\n";
    #print $FILEHANDLE 'axis_thickness = 1'."\n";
    #print $FILEHANDLE 'axis_spacing   = 2.0'."\n";
    print $FILEHANDLE '</axis>' . "\n";
    print $FILEHANDLE '</axes>' . "\n";

    print $FILEHANDLE '<backgrounds>' . "\n";
    print $FILEHANDLE '<background>' . "\n";
    print $FILEHANDLE 'color = l' . $plotColor . "\n";
    #print $FILEHANDLE 'background       = yes'."\n";
    #print $FILEHANDLE 'background_color = l'.$plotColor."\n";
    #print $FILEHANDLE 'background_stroke_color = black'."\n";
    #print $FILEHANDLE 'background_stroke_thickness = 2'."\n";
    print $FILEHANDLE '</background>' . "\n";
    print $FILEHANDLE '</backgrounds>' . "\n";

    print $FILEHANDLE '<rules>' . "\n";
    print $FILEHANDLE '<rule>' . "\n";
    print $FILEHANDLE 'importance = 100' . "\n";
    print $FILEHANDLE 'condition  = var(value) > ' . $cutoff . "\n";
    #print $FILEHANDLE 'condition  = _VALUE_ > '.$cutoff."\n";
    print $FILEHANDLE 'fill_color = yellow' . "\n";
    print $FILEHANDLE 'color = dyellow' . "\n";
    print $FILEHANDLE '</rule>' . "\n";
    print $FILEHANDLE '</rules>' . "\n";

    print $FILEHANDLE 'file = ' . $plotFileName . "\n";

    print $FILEHANDLE '</plot>' . "\n";

}

1;

