#!/usr/bin/perl
use strict;
use warnings;
use Cwd;
use File::Copy;
use Sys::Hostname;

require 'prepCircosReverse.pl';
require 'postprocessCircosReverse.pl';



sub setupDirectories{
	# Check if these directories exist.
	# If they don't exist, create them.
	# To do: handle pre-existing files better
	my($baseDirectory,$confDirectory,$dataDirectory,$svgDirectory)=@_;

	unless(-d $baseDirectory)
	{
		print " Creating base directory $baseDirectory \n";
		mkdir "$baseDirectory", 0777  || die(" Cannot create directory $baseDirectory $! \n");
	}
	unless(-d $confDirectory)
	{
		print " Creating conf directory $confDirectory \n"; 
		mkdir "$confDirectory", 0777  || die(" Cannot create directory $confDirectory $! \n");
	}
	unless(-d $dataDirectory)
	{
		print " Creating data directory $dataDirectory \n"; 
		mkdir "$dataDirectory", 0777  || die(" Cannot create directory $dataDirectory $! \n");
	}
	unless( -d $svgDirectory )
	{
		print " Creating svg directory $svgDirectory \n"; 
		mkdir "$svgDirectory", 0777 || die(" Cannot create directory $svgDirectory $! \n");
	}
}



sub callCircosReverse{
	my($cutoff,$organism,$geneCentricPath,$tissueString,$chromosomeString,$source)=@_;
	#
	# General outline of process:
	# First, prep circos conf and data files
	# Second, call circos
	# Third, massage the svg output file created by circos
	#
	my $cutoffString = sprintf "%d", $cutoff*10;
	my $baseDirectory = $geneCentricPath.'/circos'.$cutoffString.'/';
	my $inputFileName = $geneCentricPath.'/'.$source.'_geneQTLDetails.txt';
	print " base directory $baseDirectory \n";
	my $dataDirectory = $baseDirectory.'data/';
	print " data directory $dataDirectory \n";
	my $svgDirectory = $baseDirectory.'svg/';
	print " svg directory $svgDirectory \n";
	my $confDirectory = $baseDirectory.'conf/';
	print " conf directory $confDirectory \n";

	if(!defined($chromosomeString)){
		if($organism eq 'Rn'){
			$chromosomeString = "rn1;rn2;rn3;rn4;rn5;rn6;rn7;rn8;rn9;rn10;rn11;rn12;rn13;rn14;rn15;rn16;rn17;rn18;rn19;rn20;rnX";
		}
		else
		{
			$chromosomeString = "mm1;mm2;mm3;mm4;mm5;mm6;mm7;mm8;mm9;mm10;mm11;mm12;mm13;mm14;mm15;mm16;mm17;mm18;mm19;mmX";
		}
	}
	if(!defined($tissueString)){
		if($organism eq 'Rn'){
		    if($source eq 'seq'){
		        $tissueString='Brain;Liver;Kidney;';
		    }else{
			    $tissueString='Brain;Heart;Liver;BAT;';
			}
			#$tissueString='Brain;Liver;BAT;';
		}
		else{
			$tissueString='Brain;';
		}
	}
	print " Chromosome String: $chromosomeString \n";
	print " Tissue String: $tissueString \n";
	#
	# Create necessary directories if they do not already exist
	#	
	setupDirectories($baseDirectory,$dataDirectory,$confDirectory,$svgDirectory);
	my @chromosomeList = split(/;/, $chromosomeString);
	my $chromosomeListRef = (\@chromosomeList);
	my @tissueList = split(/;/, $tissueString);
	my $tissueListRef = (\@tissueList);
	my $hostname = hostname;
	print " Ready to call prepCircos \n";
	prepCircosReverse($inputFileName,$cutoff,$organism,$confDirectory,$dataDirectory,$chromosomeListRef,$tissueListRef,$hostname);
	print " Finished prepCircos \n";	

	#-- get current directory
	my $pwd = getcwd();
	print " Current directory is $pwd \n";
 
	#-- change dir to svg directory
	chdir($svgDirectory);
	my $newpwd = getcwd();
	print " New directory is $newpwd \n";
	
	print " Calling Circos \n";

	my $circosBinary;
	my $perlBinary;
	my $inkscapeBinary;

	$circosBinary = '/usr/share/circos/bin/circos';
	$perlBinary = '/usr/bin/perl';
	$inkscapeBinary = '/usr/bin/inkscape';

    my @systemArgs = ($perlBinary,$circosBinary, "-conf", $confDirectory."circos.conf", "-noparanoid");

    print " System call with these arguments: @systemArgs \n";
    system(@systemArgs);

    if ( $? == -1 )
	{
  		print "System Call failed: $!\n";
	}
	else
	{
  		printf "System Call exited with value %d", $? >> 8;
	}

	#-- go back to original directory
	chdir($pwd);

	print " Finished running Circos \n";
	
	

	print " Ready to call postprocessCircos \n";
	postprocessCircosReverse($cutoff,$organism,$dataDirectory,$svgDirectory,$hostname,$tissueListRef);
	print " Finished with Circos \n";
			
	#
	# Now convert circos_new.svg to circos_new.pdf
	#

	
	@systemArgs=($inkscapeBinary,'-z','-f',$svgDirectory."circos_new.svg",'-A',$svgDirectory."circos_new.pdf",'-b','rgb(255,255,255)','-i','notooltips','-j','-C');
	print " System call with these arguments: @systemArgs \n";
	
    system(@systemArgs);
    if ( $? == -1 )
	{
  		print "System Call failed: $!\n";
	}
	else
	{
  		printf "System Call exited with value %d", $? >> 8;
	}
	#-- go back to original directory
	chdir($pwd);
	
    exit 0;
}

	my $arg1 = $ARGV[0]; # Cutoff
	my $arg2 = $ARGV[1]; # Organism
	my $arg3 = $ARGV[2]; #	Region Centric Path
	my $arg4 = $ARGV[3]; #	Tissue String
	my $arg5 = $ARGV[4]; # Chromosome String
	my $arg6 = $ARGV[5]; # source

	callCircosReverse($arg1, $arg2, $arg3, $arg4, $arg5,$arg6);



1;


