<%--
 *  Author: Spencer Mahaffey
 *  Created: August, 2012
 *  Description:  
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<style>
span.control{
		background:#DCDCDC;
		margin-left:2px;
		margin-right:2px;
		height:24px;
		/*padding:2px;*/
		display:inline-block;
		width:35px;
		border-style:solid;
		border-width:1px;
		border-color:#777777;
		-webkit-border-radius: 5px;
		-khtml-border-radius: 5px;
		-moz-border-radius: 5px;
		border-radius: 5px;
	}
	span.control:hover{
		background:#989898;
	}
</style>
<div class="whats_new version"><p><H3>Version 3.9.6</H3><BR> 8/23/2024</p></div>
	Genome Transcriptome Browser has HRDP v7.1 data
    <UL>
                                        <LI>HRDP v7.1 Tracks: Transcriptome, Splice Junction Tracks</LI>
                                        <LI>REST API updated with latest transcriptome</LI>
                                        <LI>UCSC Genome Browser links updated with latest transcriptome</LI>
                                        <LI>Coming soon: expression, eQTLs, and WGCNA - HRDP v6(rn7) is still available simply select the HRDP version to display.</LI>

                        </UL>

<HR>
<div class="whats_new version"><p><H3>Version 3.9.5</H3><BR> 5/14/2024</p></div>
	Genome Transcriptome Browser has HRDP v7 data
    <UL>
                                        <LI>HRDP v7 Tracks: Transcriptome, Splice Junction Tracks</LI>
                                        <LI>Expression: TPM summaries, detailed normalized expression at the region or gene level</LI>
                                        <LI>Coming soon: eQTLs and WGCNA - HRDP v6(rn7) is still available simply select the HRDP version to display.</LI>

                        </UL>

<HR>
<div class="whats_new version"><p><H3>Version 3.9.3</H3><BR> 4/11/2024</p></div>
	IsoSeq data updated
    <UL>
                    <LI>Brain/Liver/Merged IsoSeq Tracks showing IsoSeq Read alignments to rn7.</LI>
                    <LI>Created IsoSeq UCSC Genome Browser track hub</LI>
                    <LI>Fixed a gene display bug in the genome browser</LI>
                    <LI>Downloads Added(<a href="http://phenogen.org/web/sysbio/resources.jsp?section=rnaseq">RNA-Seq Downloads</a>):</LI>
                    <UL>
                    <li>IsoSeq samples high quality Isoform FASTQ files.</li>
                    <li>Rn7.2 merged genome alignment of FASTQ files</li>
                    <li>Rn7.2 merged transcriptome as GTF</li>
                    </UL>
    </UL>

<HR>
<div class="whats_new version"><p><H3>Version 3.9.3</H3><BR> 4/3/2024</p></div>
	HRDP v7 UCSC Genome Browser track hubs are available now.  <a href="http://phenogen.org/web/sysbio/resources.jsp?section=ucsc">Downloads -> UCSC</a>.
    <UL>
                    <LI>Tissue specific transcriptomes and merged transcriptomes</LI>
                    <LI>Tissue/strain specific read count tracks both total(sum of 3 replicates) or sampled( randomly sampled reads to match the strain with the fewest reads)</LI>
                    <LI>Merged across strain read counts and then sampled to represent 5 Billion reads.</LI>
                    <LI>Splice junctions from merged and 5 billion read sampled Bam files.</LI>
    </UL>

<HR>
<div class="whats_new version"><p><H3>Version 3.9.2</H3><BR> 2/8/2024</p></div>
    <UL>
        <LI>HRDP v6 TPM Data available via REST API and Downloads</LI>
        <LI>HRDP v7 TPM Data available via REST API and Downloads</LI>
        <LI>Added TPM and Heritablility summaries to gene reports.</LI>
        <LI>Bug Fixes</LI>
    </UL>

<HR>
<div class="whats_new version"><p><H3>Version 3.7.5</H3><BR> 12/11/2020</p></div>
    <UL>
        <LI>Sampled counts from every strain are now available as well as total counts.</LI>
        <LI>You can create a custom view and select total/sampled count and choos the density of the count tracks.</LI>
        <LI>Bug Fixes</LI>
    </UL>

<HR>

<div class="whats_new version"><p><H3>Version 3.7.4</H3><BR>11/18/2020</p></div>
    <UL>
        <LI>You can now create gene lists from Genome Browser tables - Filter tables from tracks, eQTLs, WGCNA based on expression/tissue and then use gene list tools on the list.</LI>
        <LI>Implemented a reasonable region restriction of 5Mbp for now. - We are working to create a less detailed view that will be displayed in larger regions.</LI>
        <LI>Bug Fixes</LI>
    </UL>
<HR>

<div class="whats_new version"><p><H3>Version 3.7.3</H3><BR>8/26/2020</p></div>

    <UL>
        <LI>Version 3.7.3 has been released with the following updates.
            <ul><LI>RNA-Seq eQTLs based on HRDP</LI>
                <LI>Heritability based on HRDP</LI>
                <LI>TPM summary</LI>
                <LI>Track Table filtering</LI>
                <LI>Table export to clipboard, csv, xls, and PDF</LI>
                <LI>Ensembl and Reconstruction based eQTLs/TPM/Heritability</LI>
            </ul>
    </UL>

<HR>

<div class="whats_new version"><p><h3>Version: v3.7.2</h3><BR />7/8/2020</p></div>

    <UL>
        <LI>Version 3.7.2 has been released with the following updates.
            <ul><LI>RNA-Seq eQTLs
                <UL>
                    <LI>Gene Track Summaries now include RNA-Seq based eQTL summaries</LI>
                    <LI>Modules for a region can be selected base on overlap of the module QTL with the region.</LI>
                    <LI>Genes with an eQTL that overlaps the region are now available based on RNA-Seq and Microarrays</LI>
                </UL>
            </LI>
                <LI>Custom Views
                    <UL>
                        <LI>Total Counts for all 45 strains to date are available.</LI>
                    </UL>
                </LI>
                <LI>Read counts for all 45 strains are available to add as browser tracks.</LI>
                <LI>Bug Fixes</LI>
            </ul>
    </UL>
<HR>
<div class="whats_new version"><p><h3>Version: v3.7.1</h3><BR />2/27/2020</p></div>
<UL>
    <LI>Version 3.7.1 has been released with the following updates.
        <ul><LI>Downloads
            <UL>
                <LI>Tissue Specific/Merged Reconstruction GTFs</LI>
                <LI>Normalized Expression Values for Ensembl/Reconstruction, Gene/Transcript, Strain Means/Individual values</LI>
            </UL>
        </LI>
            <LI>Custom Views
                <UL>
                    <LI>Build a custom view on the fly by selecting a few check boxes simply select sissue and track types.</LI>
                    <LI>Views can be named and saved for future use</LI>
                </UL>
            </LI>

        </ul>
</UL>
<HR>
<div class="whats_new version"><p><h3>Version: v3.7</h3>1/12/2020<BR /></p></div>
<UL>
    <LI>Version 3.7 has been released with HRDP v5.
        <ul><LI>Transcriptomes are now based on the full HXB/BXH RI panel in brain and liver and available inbred strains now including the F344/Stm and LE/Stm strains. </LI>
            <LI>Updated WGCNA, expression values, eQTLs, and transcriptomes are available.</LI>
            <LI>Transcript level expression is available for the full panel.</LI>
            <LI>Transcript level eQTLs are now available once you've selected a gene.</LI>
            <LI> Transcript level WGCNA is coming in the next 1-2 months. </LI>
        </ul>
    <LI>CircularRNA data is availble now. This includes predictions from BNLx/SHR in Brain/Heart/Liver using CIRI 2.0 and CircExplorer2.  Also Heart left ventricle includes data from more than 12,000 previously described cirRNAs using cirRNA arrays.  Full reports are coming soon but the browser includes tracks with annotation and structure all available data.</LI>
</UL>
<HR>
<div class="whats_new version"><p><h3>Version: v3.6</h3><BR />7/23/2019</p></div>
<ul>
    <li><span class="highlight-dark"> HRDP v4 Data is available</span>
        <UL>
            <LI>Transcriptomes are now based on the full HXB/BXH RI panel in brain and liver and available inbred strains except for the F344/Stm and LE/Stm.  The FXLE/LEXF parents will be included in HRDP v5.</LI>
            <LI>Updated WGCNA, expression values, eQTLs, and transcriptomes are available.</LI>
            <LI>Transcript level expression is available again now for the full panel.</LI>
            <LI>Transcript level WGCNA is coming in the next 1-2 months.</LI>
        </UL>
    </li>
    <LI><span class="highlight-dark">New gene list circos plot eQTL image/browser.</span></LI>
    <li><span class="highlight-dark">Genome Browser Section shortcuts</span> </li>
    <li><span class="highlight-dark">Links to Gene Relationship Literature Search, Gene and Addiction Literature Searches, GeneNetwor SNP Browser</span></li>
</ul>
<hr/>
    <div class="whats_new version"><p><h3>Version: v3.5</h3><BR />11/12/2018</p></div>
    <ul>
                <li><span class="highlight-dark">Beta Testing cloud version now</span></li>
                <li> Most of the changes occurred behind the scenes and users will not see much of a difference with 2 exceptions.
                    <UL>
                        <LI>The domain is now going to be <a href="https://phenogen.org">phenogen.org</a>.</LI>
                        <LI>Microarray analysis will not be available in this version.  You should still have access to previously uploaded arrays and any analysis performed.</LI>
                    </UL>
                </li>
                <li>The major changes should provide better reliability and performance while reducing maintenance time to allow for development of new tools.  Write us and let us know what you would find useful.</li>
                <li> New Features and data are coming soon so keep checking back on the new site.</li>
    </ul>
    <hr/>
    <div class="whats_new version"><p><h3>Version: v3.4.2</h3><BR /> Updated:3/9/2018</p></div>
       <ul>
                                    <li><span class="highlight-dark">Inbred Read Depth Tracks</span>
                                        <UL>
                                            <LI>Added Read Depth Tracks in Brain and Liver for the new inbred strains:
                                                ACI, Dark-Agouti, Cop, F344-NCl, F344-NHsd, LEW-Crl, LEW-SsNHsd, SHRSP, SR-JrHsd, SS-JrHsd, and WKY
                                            </LI>
                                            
                                        </UL>
                                    </li>
        </ul>
        <hr/>
    <div class="whats_new version"><p><h3>Version: v3.4.1</h3><BR /> Updated:2/16/2018</p></div>
       <ul>
                                    <li><span class="highlight-dark">PhenoGen IDs</span>
                                        <UL>
                                            <LI>The Genome/Transcriptome Data Browser can now look up genes by either their gene or transcript PhenoGen ID.</LI>
                                            <LI>Updated External Database IDs <a href=""></a></LI>
                                        </UL>
                                    </li>
        </ul>
        <hr/>
    <div class="whats_new version"><p><h3>Version: v3.4</h3><BR /> Updated:12/10/2017</p></div>
       <ul>
                                    <li><span class="highlight-dark">Recombinant Inbred Small RNA</span>
                                        <UL>
                                            <LI>Expression - The expression tab now will summarize small RNA-Seq expression for the RI panel in both Whole Brain and Liver.  There is both a heatmap and scatter plot available to display the values.</LI>
                                           
                                        </UL>
                                    </li>
        </ul>
        <hr/>
    <div class="whats_new version"><p><h3>Version: v3.3</h3><BR /> Updated:4/30/2017</p></div>
       <ul>
                                    <li><span class="highlight-dark">Recombinant Inbred Total RNA</span>
                                        <UL>
                                            <LI>Expression - The expression tab now will summarize RNA-Seq expression and heritability for the RI panel in both Whole Brain and Liver.  There is both a heatmap and scatter plot available to display the values.</LI>
                                            <LI>WGCNA - New WGCNA data is available based on RNA-Seq reconstructed transcripts in Whole Brain and Liver.<BR>
                                                <UL>
                                                    <LI>You now have the option to view RNA-Seq or Array based WGCNA modules.</LI>
                                                    <LI>Meta modules have be generated to allow browsing related modules.</LI>
                                                </UL> 
                                            </LI>
                                        </UL>
                                    </li>
        </ul>
        <hr/>
    <div class="whats_new version"><p><h3>Version: v3.2</h3><BR /> Updated:11/10/2016</p></div>
       <ul>
                                    <li><span class="highlight-dark">Small RNA</span>
                                        Rat small RNA tracks from Brain, Heart, Liver based on the small RNA-Seq.  Including counts from the parental strains.  Tracks include known and novel small RNAs.  Novel RNA's were predicted by MiRDeep and SNOSeeker.
                                    </li>
                                    <li><span class="highlight-dark">Merged Total RNA Transcriptome</span>
                                        Added a track with the merged transcriptome from the 3 available tissues and assigned new unique PhenoGen IDs to all novel transcripts.
                                    </li>
                                    
        </ul>
        <hr/>
    <div class="whats_new version"><p><h3>Version: v3.1</h3><BR /> Updated:6/22/2016</p></div>
       <ul>
                                    <li><span class="highlight-dark">Rn6</span>
                                        All four tissues of the HXB Mircoarray datasets are available with Rn6 versions.  The genome browser will now let you select either Rn5 or Rn6.  Gene list tools that depend on the genome version now allow selection of Rn5 or Rn6 based on the version that you want.
                                    </li>
                                    <li><span class="highlight-dark">WGCNA</span>
                                        Heart and Liver modules are now available based on the Rn6 version of the data. Whole Brain has an updated version using Rn6.
                                    </li>
                                    <li><span class="highlight-dark">Site wide search</span>
                                        You can now use google on the site to search on PhenoGen.
                                    </li>
                                    <li><span class="highlight-dark">Repeat Mask Track in the Genome Browser</span>
                                        We've made the UCSC repeat mask data available as a track in the browser.
                                    </li>
                                    
        </ul>
        <hr/>
        <div class="whats_new version"><p><h3>Version: v3.0</h3><BR /> Updated:5/31/2016</p></div>
       <ul>
                                    <li><span class="highlight-dark">Anonymous Gene Lists</span>
                                        You now can bring in a Gene List and use our tools without a login.  You should remember that we are storing a unique id in your browser so you can return to your list 
                                        on subsequent visits.  If you loose this the only way to recover the gene lists linked to that ID is by email recovery.  This only works if you link your email.  If you don't
                                        link an email there is potential that you will loose access to your list/analysis.
                                    </li>
                                    
        </ul>
        <hr/>
         <div class="whats_new version"><p><h3>Version: v2.16.1</h3><BR /> Updated:11/10/2015</p></div>
       <ul>
                                    <li><span class="highlight-dark">Security Enhancements</span>
                                        The biggest change that you will see is that we've redirected you to https://phenogen.ucdenver.edu . Please update your bookmarks as we're now requiring use of HTTPS.  This will encrypt all of the data sent between you and our server.
                                        <BR><BR>We're hoping to be able to offer new features such as registering and/or signing in using a Google account or allowing users to store data on Google Drive.
                                        Our next major update will include microarrays and RNA-Seq all updated to Rn6, although in the browser both Rn5 and Rn6 will be available.
                                    </li>
                                    
        </ul>
        <hr/>
       <div class="whats_new version"><p><h3>Version: v2.16.0</h3><BR /> Updated:7/21/2015</p></div>
       <ul>
                                    <li><span class="highlight-dark">Gene Lists</span>
                                        <UL>
                                            <li><span class="highlight-dark">Updated tab format</span> - the new format allows you to submit a new analysis, view previous results, and see the current status of running analyses.</li>
                                            <li><span class="highlight-dark">Gene Ontology Summaries</span> - summaries similar to the WGCNA module summaries can now be run on a Gene List.</li>
                                            <li><span class="highlight-dark">MultiMiR</span> - MultiMiR supports rat miRNAs now so you can view miRNAs predicted and validated to target a gene.</li>
                                        </ul>
                                    </li>
                                    <li><span class="highlight-dark">Genome/Transcriptome Data Browser</span>
                                        <UL>
                                        <li> <span class="highlight-dark">MultiMiR</span> - you can now view a summary for selected Rat genes.</li>         
                                        </ul>
                                    </li>
        </ul>
        <hr/>
    <div class="whats_new version"><p><h3>Version: v2.15.0</h3><BR /> Updated:3/7/2015</p></div>
                                 <ul>
                                    <li><span class="highlight-dark">New Weighted Gene Co-expression Network Analysis(WGCNA) Views</span>.
                                                    <ul>
                                                        <li>Gene Ontology View:
                                                            <ul>
                                                                <li>View an interactive expandable sunburst plot of each GO Domain(Biological Process, Molecular Function, and Cellular Component). Provides a summary of all the GO terms assigned to genes in the module.</li>
                                                                <li>View graphic form and CSV exportable table form.  Both are interactive and can be used to explore the GO term tree.</li>
                                                            </ul>
                                                        </li>
                                                        <li>miRNA targeting (multiMiR) View:
                                                            <ul>
                                                                <li>View/Filter miRNAs that target genes in the module.  Visualize targets of miRNAs and the correlation between genes targeted.  Filter to look at specific miRNAs or miRNAs targeting specific genes.</li>
                                                                <li>View graphic form and CSV exportable table form.</li>
                                                            </ul>
                                                        </li>
                                                    </ul>
                                    </li>
                                    <li><span class="highlight-dark">Rat Transcriptomes Updated Brain, Liver, and Heart(New)</span>
                                        <UL>
                                        <li> <span class="highlight-dark">Strain Specific Transcripts</span> - Now transcripts specific to a strain are color coded to quickly visualize splicing differences between strains.</li>
                                        <li> <span class="highlight-dark">Updated Brian and Liver Transcriptome</span> - New versions of the brain and liver transcriptome are available.</li>
                                        <li> <span class="highlight-dark">Added Heart Transcriptome</span> - We've added the first version of the heart transcriptome.</li>
                                        <li> <span class="highlight-dark">Transcriptome Versioning</span> - Missing a transcript of interest in the new transcriptome?  You can view previous version of the transcriptome now by selecting a previous version in the track settings.</li>
                                        </ul>
                                    </li>
                                </ul>
				
    <hr/>
    <div class="whats_new version"><p><h3>Version: v2.14.0</h3><BR /> Updated:1/11/2015</p></div>
                                 <ul>
                                    <li><span class="highlight-dark">Weighted Gene Co-expression Network Analysis(WGCNA) Results</span>.
                                                    <ul>
                                                        <li>Available for both Mouse and Rat Brain.</li>
                                                        <li>Module View:
                                                            <ul>
                                                                <li>Transcripts both Ensembl Annotated and RNA-Seq reconstructed</li>
                                                                <li>Transcripts connectedness showing positive and negative correlation of transcript expression.</li>
                                                                <li>View graphic form and CSV exportable table form.</li>
                                                            </ul>
                                                        </li>
                                                        <li>eQTL Module View:
                                                            <ul>
                                                                <li>View CIRCOS plot:
                                                                    <ul>
                                                                        <li>Genome with regions below the selected P-value cutoff highlighted.</li>
                                                                        <li>Customizable with include/exclude chromosomes and adjust P-value cutoff.</li>
                                                                        <li>View graphic form and CSV exportable table form.</li>
                                                                    </ul>
                                                                </li>
                                                                <li>CSV exportable table form with SNP name/location and P-value.</li>
                                                            </ul>
                                                        </li>
                                                    </ul>
                                    </li>
                                    <li><span class="highlight-dark">Where to find WGCNA Data</span>
                                        <UL>
                                        <li> <span class="highlight-dark">Genome/Transcriptome Data Browser</span> - Modules can be viewed for all genes in a region of interest or for a single gene.</li>
                                        <li> <span class="highlight-dark">Gene Lists</span> - Modules can be viewed for all genes in the gene list along with a summary of modules containing the most genes from the list.</li>
                                        </ul>
                                    </li>
                                </ul>
				
    <hr/>
<div class="whats_new version">        
    <p><h3>Version: v2.13.0</h3><BR /> Updated:9/27/2014</p></div>
				<ul>
					<li> <span class="highlight-dark">Genome/Transcriptome Data Browser</span>
                    	<ul>
                        	<li><span class="highlight-dark">Views have been completely updated</span> to allow us to offer multiple views that change based on the species viewed, and now you can <span class="highlight-dark">build your own view</span>.
                            	<ul>
                                	<li>Easily view different types of data in the same region by switching between views with only 3 clicks.</li>
                                    <li>Build your own view by from a blank view or copy a view and modify it.  You can control the included tracks, track settings, and track order.</li>
                                    <li>Bring in your own data and include custom tracks in views.  Now supporting Bed, BedGraph, BigBed, and BigWig files.</li>
                                    <li>Save views/tracks to the server for portability.(See below for more information)</li>
                                </ul>
                            </li>
                            <li><span class="highlight-dark">Updated Data:</span>
                            	<ul>
                                <li><span class="highlight-dark">Mouse Brain RNA-Seq</span> - We've added a transcriptome reconstruction, splice junctions, and stranded RNA-Seq read depth tracks for the parental strains of the LXS panel(ILS/ISS).</li>
                                <li><span class="highlight-dark">Rat Heart RNA-Seq</span> - Splice juctions, stranded RNA-Seq read depth tracks are available now for the parental strains of the HXB/BXH panel(BN-Lx/SHR).  The transcriptome reconstruction will be available later.</li>
                                <li><span class="highlight-dark">Rat Brain/Liver RNA-Seq</span> -Updated splice juctions and stranded(Liver) or polyA+/total(Brain)  RNA-Seq read depth tracks are available now.  Updated transcriptome reconstructions will be available later.</li>
                                </li>
                                </ul>
                            </li>
                            <li><span class="highlight-dark">New custom track file support:</span>
                            	<ul>
                                	<li><span class="highlight-dark">bedGraph</span> - uploaded 20MB size limit</li>
                                    <li><span class="highlight-dark">bigBed</span> - remotely hosted, no size limit</li>
                                    <li><span class="highlight-dark">bigWig</span> - remotely hosted, no size limit</li>
                                    <li>bed - we still support bed files, uploaded, 20MB size limit</li>
                                </ul>
                            </li>
                            <li><span class="highlight-dark">Custom View/Tracks will save to the server</span> if you login to the site before creating them.  If you have logged into the site any views or tracks will save to the server so you can view them on any device that you login from and can reduce the risk of loosing them.</li>
                            <li><span class="highlight-dark">Don't want to register or login, don't worry everything will still work</span>, custom tracks and views are saved locally via one of two mechanisms, either local storage or cookies in older browsers.  If you clear these you will loose your custom views or tracks.</li>
                            
                    	</ul>
                	</li>         
				</ul>
				<hr/>
<div class="whats_new version"><p><h3>Version: v2.12.3</h3><BR /> Updated:7/17/2014</p></div>
				<ul>
					<li> <span class="highlight-dark">Genome/Transcriptome Data Browser</span>
                    	<ul>
                        	<li>Rearranged Ensembl and Rat Brain Transcriptome Reconstruction Tracks into a seperate track for each source.
                            	<ul>
                                	<li>Brain transcripts were removed from Ensembl tracks and added to their own track to mirror the additional tissue tracks to be added in the next few months.</li>
                                    <li>Region summary tables now include Liver transcripts</li>
                                </ul>
                            </li>
                            <li>Improved the feature selection
                            	<ul>
                                	<li>Changed how sections are displayed and now hide the region section completely when a feature is selected</li>
                                    <li>Now the selected area is highlighted in the top graphic.</li>
                                </ul>
                            </li>
                            <li>Improved navigation by adding a back button to step back through zooming and panning allowing better control than just resetting to the original region when the page loaded.</li>
                            <li>Improved tool tip images for RNA-Seq read depth count tracks- the image will now refresh with higher resolution count data if you pause for a fraction of a second.
                            </li>
                            
                    	</ul>
                	</li>         
				</ul>
				<hr/>
<div class="whats_new version"><p><h3>Version: v2.12.2</h3><BR /> Updated:6/27/2014</p></div>
				<ul>
					<li> <span class="highlight-dark">Gene List Analysis</span>
                    	<ul>
                        	<li>Incorporated multiMiR(an R package available <a href="http://multimir.ucdenver.edu/" target="_blank">here</a>) to summarize validated and predicted targets of miRNA from 14 databases.
                            	<ul>
                                	<li>After selecting a mouse Gene List (support for Rat will be available in the future), you will see a new miRNA Targeting Gene(multiMiR) tab.</li>
                                    <li>You may run a new analysis</li>
                                    <li>Select a previous analysis:
                                    <UL>
                                    	<li>
                                        	View:
                                            <UL>
                                                <li>a small table sumarizing the number of validated/predicted genes targeted.</li>
                                                <li>a larger table with further detail about all the validated/predicted genes and databases.</li>
                                            </UL>
                                        </li>
                                    	<li>Select an miRNA to view details:
                                            <UL>
                                                <li>view a list of all predicted database hits and scores</li>
                                                <li>view a list of all validated database hits with experiment details and pubmed reference</li>
                                            </UL>
                                        </li>
                                    </li>
                                    </UL>
                                    <li>Future additions:
                                    	<UL>
                                        	<li>run multiMiR with disease/drug targeting</li>
                                            <li>in the browser run multiMiR on genes or miRNA in a region of interest</li>
                                        </UL>
                                    </li>
                                </ul>
                            </li>
                    	</ul>
                	</li>         
				</ul>
				<hr/>
<div class="whats_new version"><p><h3>Version: v2.12</h3><BR /> Updated:6/11/2014</p></div>
				<ul>
					<li> <span class="highlight-dark">Genome/Transcriptome Data Browser:</span>
                    	<ul>
                        	<li>Incorporated multiMiR(an R package available <a href="http://multimir.ucdenver.edu/" target="_blank">here</a>) to summarize validated and predicted targets of miRNA from 14 databases.
                            	<ul>
                                	<li>To use start with a mouse gene (rat will be available in the future) in the Genome/Transcriptome Browser.  You will see a new miRNA Targeting Gene(multiMiR) tab.</li>
                                    <li>View a list of validated and predicted miRNAs targeting the selected gene.</li>
                                    <li>Select a miRNA:
                                    	<UL>
                                        	<li>view a list of all predicted database hits and scores</li>
                                            <li>view a list of all validated database hits with experiment details and pubmed reference</li>
                                        	<li>view a list of all genes targeted by that miRNA</li>
                                        </UL>
                                    </li>
                                    <li>Future additions:
                                    	<UL>
                                        	<li>run multiMiR on a Gene List</li>
                                            <li>run multiMiR on genes or miRNA in a region of interest</li>
                                        	<li>run multiMiR with disease/drug targeting</li>
                                        </UL>
                                    </li>
                                </ul>
                            </li>
                            
                        	<li style="list-style-type:none;"><a href="<%=accessDir%>createAnnonymousSession.jsp?url=<%=contextRoot%>gene.jsp" class="button" style="width:140px;">Try it out</a>
                    	</ul>
                	</li>         
				</ul>
				<hr/>
<div class="whats_new version"><p><h3>Version: v2.11</h3><BR /> Updated:5/11/2014</p></div>
				<ul>
					<li> <span class="highlight-dark">Genome/Transcriptome Data Browser:</span>
                    	<ul>
                        	<li>Liver RNA-Seq Data
                            	<ul>
                                	<li>Added Liver RNA-Seq transcriptome reconstruction track (BN-Lx only for now - SHR will be added soon)</li>
                                    <li>Added Liver RNA-Seq splice junction track (BN-Lx only for now - SHR will be added soon)</li>
                                    <li>Added Liver RNA-Seq stranded read depth count track (BN-Lx only for now - SHR will be added soon)</li>
                                </ul>
                            </li>
                            <li>PolyA sites
                            	<ul><li style="list-style-type:none;">
                                	A new track indicating polyadenylation sites.  For now only known sites are included, but soon predicted sites will be included.
                                </li></ul>
                            </li>
                            <li>Other changes since v2.10:
                            	<ul>
                                	<li> Previews of many features in the information windows that open when you hover over a feature.</li>
                                    <li> Saving an browser image directly to your computer is now possible look for the <span class="saveImage control" style="display: inline-block; cursor: pointer;"><img src="/web/images/icons/savePic_dark.png" cursor="pointer"></span> icon.</li>	
                                    <li> Improved navigation.  This tool bar <div class="defaultMouse" style="display:inline-block;"><span style="height: 24px; display: inline-block; cursor: pointer; background-color: rgb(220, 220, 220); background-position: initial initial; background-repeat: initial initial;"><img class="mouseOpt dragzoom" src="/web/images/icons/dragzoom_dark.png" pointer-events="all"></span><span id="pan0" style="height: 24px; display: inline-block; cursor: pointer; background-color: rgb(152, 152, 152); background-position: initial initial; background-repeat: initial initial;"><img class="mouseOpt pan" src="/web/images/icons/pan_white.png" pointer-events="all"></span><span id="reorder0" style="height: 24px; display: inline-block; cursor: pointer; background-color: rgb(220, 220, 220); background-position: initial initial; background-repeat: initial initial;"><img class="mouseOpt pan" src="/web/images/icons/reorder_dark.png" pointer-events="all"></span></div> now allows you to control the default mouse function when you click making it easier to move along the genome, zoom by selecting a region, and reorder tracks without moving left or right.</li>
                                    <li> Support for small custom tracks.  You may upload small <20MB custom track files and display them along with changing the display type and coloring.</li>
                                    <li> Added Rat/Mouse RefSeq tracks.</li>
                                    <li> The browser adjusts to the size of the window.  Before you were limited to 1000pixel width, now it will redraw to fit any width window including spanning monitors.</li>
                                    <li> Transcripts from Ensembl/RefSeq now indicate any annotated untranslated region.</li>
                                    <li> Detailed probe set view had a bug on Mac OS X, now that is fixed in the Oracle runtime environment.  If you update Java this bug will be corrected.</li>
                                    <li> In large regions transcripts are grouped into genes.  In smaller regions transcripts are drawn separately, but the user can force drawing transcripts if desired.</li>
                                    <li> View genome sequence and 3 possible amino acid sequences when zoomed in below 3000bp.</li>
                                </ul>
                            </li>
                        	<li style="list-style-type:none;"><a href="<%=accessDir%>createAnnonymousSession.jsp?url=<%=contextRoot%>gene.jsp" class="button" style="width:140px;">Try it out</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <a href="<%=contextRoot%>web/demo/largerDemo.jsp?demoPath=web/demo/BrowserNavDemo" class="button" style="width:140px;" target="_blank">View Demonstration</a></li>
                    	</ul>
                	</li>         
				</ul>
				<hr/>

<div class="whats_new version"><p><h3>Version: v2.10</h3><BR /> Updated:12/1/2013</p></div>
				<ul>
                <li>
					<span class="highlight-dark">New Mouse Genome:</span> Our public data has been updated to Mm10.  Probes were aligned to the mouse genome version 10 and then new masks were generated.  The Public LXS data uses a strain specific mask with only Parental ILS and ISS SNPs included. All of three versions of the dataset were renormalized to use the new masks.  Previous results are still available, but new analyses will use the new versions of the dataset. 
                </li><BR /> 
				<li> 
                    <span class="highlight-dark">Detailed Transcription Information renamed to Genome/Transcriptome Data Browser</span>
                    <ul >
                    	<li>The page is now centered around a new D3/SVG graphic that makes the page more like a genome browser:
                        	<ul style="padding-left:30px;">
                                        <li><div class="clicker" name="branch7">The graphics are interactive &nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                                        <span class="branch" id="branch7">
                                        	You can easily zoom and move along the genome to browse features.  You can select a feature to pull up a detailed another detailed interactive image of that feature or a report summarizing the data available for the feature.
                                        </span>
                                        <li><div  class="clicker" name="branch8">Three different customizable views&nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                                        <span class="branch" id="branch8">
                                        	You can view Genomic Features<BR />
                                            	<ul>
                                                </ul>
                                            You can view Transcriptome Features
                                            	<ul>
                                                </ul>
                                            You can view a combination of both types of features.<BR />
                                            With all views the tracks displayed are saved so you can move around the genome viewing with the same view or you can flip between two or three views looking at different tracks.
                                        </span>
                                        
                                     </ul>
                        </li>
                        <li>The Gene and Region views have been unified to provide a similar interface whether you enter a gene or browse a region.</li>
                        <li>New Demos:
                        	<UL>
                            	<li>A new short demonstration of navigating using the Genome/Transcriptome Data Browser</li>
                                <li>A new version of the previous demonstration showing how to use the Genome/Trascriptome Data Browser to look at regions of interest</li>
                            </UL>
                        </li>
                        <li style="list-style-type:none;"><a href="<%=accessDir%>createAnnonymousSession.jsp?url=<%=contextRoot%>gene.jsp" class="button" style="width:140px;">Try it out</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <a href="<%=contextRoot%>web/demo/largerDemo.jsp?demoPath=web/demo/BrowserNavDemo" class="button" style="width:140px;" target="_blank">View Demonstration</a></li>
                    </ul>
                </li>         
				</ul>


				<hr/>


<div class="whats_new version"><p><h3>Version: v2.9</h3><BR /> Updated:5/21/2013</p></div>
				<ul>
                <li>
					<span class="highlight-dark">New Rat Genome:</span> All of our public data has been updated to Rn5.  Probes were aligned to the rat genome version 5 and then new masks were generated.  All of the datasets were renormalized to use the new masks.  Previous results are still available, but new analyses will use the new versions of the datasets. 
                </li><BR /> 
				<li> 
                    <span class="highlight-dark">Detailed Transcription Information:</span>
                    <ul >
                    	<li>Regions have been updated to include more RNA-Seq data(Rat only):
                        	<ul style="padding-left:30px;">
                                        <li><div class="clicker" name="branch7">UCSC Image allows control of individual tracks  &nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                                        <span class="branch" id="branch7">
                                        	The image now allows you to turn tracks off and on individually as well as gives you control of the density of the track.
                                        </span>
                                        <li><div  class="clicker" name="branch8">Several New Image Tracks(Rat only)&nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                                        <span class="branch" id="branch8">
                                        	There are new tracks available for the Rat:
                                            	<ul>
                                                	<li>Small RNAs from Brain RNA-Seq.</li>
                                                    <li>Long Non-Coding RNAs from Brain RNA-Seq</li>
                                                    <li>SNP/Indels- from DNA Sequencing of the BN-Lx and SHR strains.</li>
                                                    <li>Helicos Read Counts - Read Counts from the Helicos Brain RNA-Seq</li>
                                                </ul>
                                        </span>
                                        <li><div  class="clicker" name="branch9">Features located in region table includes additional information &nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                                        <span class="branch" id="branch9">
                                        	The table includes the following changes:
                                            <ol type="1">
                                            	<li>IDs used in the image are listed in the table</li>
                                                <li>Columns were added to allow the user to sort the table based on tracks in the image.</li>
                                                <li>Rows in the table are color coded to match the track in the image.</li>
                                                <li>SNP/indel counts within an exon for each gene (rat only) were added.</li>
                                                <li>Small RNA information such as read sequence and total read counts were added (rat only).</li>
                                                <li>Links have been added for NCBI, UniProt, RGD, MGI, and Allen Brain Atlas for each gene listed in the table.</li>
                                            </ol>
                                       </span>
                                        
                                     </ul>
                        </li>
                        <li>Gene views have been updated to include the following:
                        	<ul style="padding-left:30px;">
                            			<li><div class="clicker" name="branch10">The list of features in a region is now displayed for the region of a gene. &nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                                        <span class="branch" id="branch10">
                                        	All features within the genomic region of the gene will be listed in the table.  This includes long non-coding RNAs and small RNA.  
                                        </span>
                                        <li><div class="clicker" name="branch11">UCSC Image allows control of individual tracks  &nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                                        <span class="branch" id="branch11">
                                        	The image now allows you to turn tracks off and on individually as well as gives you control of the density of the track.
                                        </span>
                                        <li><div  class="clicker" name="branch12">New Several Image Tracks(Rat only)&nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                                        <span class="branch" id="branch12">
                                        	There are new tracks available for the Rat:
                                            	<ul>
                                                	<li>Small RNAs from Brain RNA-Seq.</li>
                                                    <li>Long Non-Coding RNAs from Brain RNA-Seq</li>
                                                    <li>SNP/Indels- from DNA Sequencing of the BN-Lx and SHR strains.</li>
                                                    <li>Helicos Read Counts - Read Counts from the Helicos Brain RNA-Seq</li>
                                                </ul>
                                        </span>
                                        <li><div  class="clicker" name="branch13">eQTLs for a gene are displayed on the same page&nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                                        <span class="branch" id="branch13">
                                        	Instead of opening in a seperate page you can now navigate between features found in the gene region, eQTLs and Detailed Affy Probeset information using tabs on the page.
                                        </span>
                                     </ul>
                        </li>
                        <li style="list-style-type:none;"><a href="<%=accessDir%>createAnnonymousSession.jsp?url=<%=contextRoot%>gene.jsp" class="button" style="width:140px;">Try it out</a></li>
                    </ul>
                </li><BR />
                
                <li>
					<span class="highlight-dark">Rat Parental Strian DNA Sequence Available:</span> DNA sequence information from parental strain (BN-Lx and SHR) of the HXB/BXH recombinant inbred panel is available:  The strain-specific genome of parental strains of the Public Rat Array/RNA-Seq datasets is available for download and the SNPs/indels can be displayed in the image on the Detailed Transcriptome Information page. <a href="<%=accessDir%>createAnnonymousSession.jsp?url=<%=sysBioDir%>resources.jsp" class="button" style="width:180px;">View in downloads</a>
                </li><BR />           
				</ul>


				<hr/>

<div class="whats_new version"><p><h3>Version: v2.8</h3><BR /> Updated:12/16/2012</p></div>

				<ul>
				<li> 
					<span class="highlight-dark">Detailed Transcription Information:</span>
                    <ul >
                    	<li>Now you can view regions too(instead of entering a gene symbol, enter a region chr1:1-50,000)
                        	<ul style="padding-left:50px;">
                                        <li><div class="clicker" name="branch1">View UCSC Image of region  &nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                                        <span class="branch" id="branch1">
                                        	The image shows genes in the region and bQTLs.  Optionally you may view additional information such as Ensembl transcripts and RNA-Seq transcripts(Rat only), UCSC/Affymetrix exon expression data, and homologus human chromosome regions and proteins.
                                        </span>
                                        <li><div  class="clicker" name="branch2">For Rat RNA-Seq transcripts from Brain are included<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                                        <span class="branch" id="branch2">
                                        	RNA-Seq data(Available in the downloads section) was used to create a reconstructed transcriptome.  Those transcripts can be displayed and the number of transcripts found can be compared to the Ensembl transcript annotations.  When viewing Detailed Transcription Information at the gene level more information is available.
                                        </span>
                                        <li><div  class="clicker" name="branch3">View Heritability and Detection Above Background across tissues availble for genes in the region&nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                                        <span class="branch" id="branch3">
                                        	We have exon array data for 2 recombinant inbred panels and various tissues (ILSXISS Mice(Whole Brain) and HXB/BXH Rats(Whole Brain, Heart, Liver, Brown Adipose).  This data is summarized for each region to include the # and avgerage heritability of probesets with a significant heritability and # and average percentage of samples where probesets were detected above background.  These are summarized for each gene in each tissue.                                         </span>
                                        <li><div  class="clicker" name="branch4">View eQTLs for genes in the region&nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                                        <span class="branch" id="branch4">
                                        	For genes in the region eQTL with the minimum P-value and its location is summarized across tissues.  All locations and tissues can be summarized in a circos plot.
                                        </span>
                                        <li><div  class="clicker" name="branch5">View bQTLs overlapping the region&nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                                        <span class="branch" id="branch5">
                                            All public bQTLs from MGI and RGD with a defined location that overlaps the current region are displayed in summary table that also links to the associated databases.
                                        </span>
                                        <li><div  class="clicker" name="branch6">View genes controlled from the region&nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                                        <span class="branch" id="branch6">
                                        	eQTLs are calculated for the recombinant inbred panels at the Gene level(Affy Exon Transcript Clusters having a core annotation)).  This is used to return a list of genes that have a core transcript cluster and an eQTL that overlaps the region.
                                        </span>
                                     </ul>
                        </li>
                        
                        <li>Translate a region of interest from Human/Mouse/Rat to Mouse/Rat to view PhenoGen data.</li>
                        <li style="list-style-type:none;"><a href="<%=accessDir%>createAnnonymousSession.jsp?url=<%=contextRoot%>gene.jsp" class="button" style="width:140px;">Try it out</a></li>
                        
                    </ul>
                </li><BR />
				<li>
					<span class="highlight-dark">Demos:</span> View the video demo of our Detailed Transcription Information features, with more demos coming soon. <a href="<%=contextRoot%>web/demo/largerDemo.jsp?demoPath=web/demo/detailed_transcript_fullv3" class="button" style="width:100px;" target="_blank" >View Demo</a>
                </li><BR />
                <li>
					<span class="highlight-dark">MEME Updated to v4.9:</span> MEME v4.9 is now available.  Old results are still avialable, but new analysis will use 4.9 which will also have better graphics display and will link to the main meme server for further analysis.  Available in <a href="<%=accessDir%>checkLogin.jsp?url=<%=geneListsDir%>listGeneLists.jsp" class="button" style="width:180px;">Gene List Analysis</a>  
                </li><BR />
                <li>
					<span class="highlight-dark">Human Genotyping Data Available:</span> Affymetrix Genome-Wide Human SNP Array 6.0 data for alcohol dependent subjects receiving outpatient treatment at the Medical University of Vienna (Austria). <a href="<%=accessDir%>createAnnonymousSession.jsp?url=<%=sysBioDir%>resources.jsp" class="button" style="width:180px;">View in downloads</a>
                </li><BR />           
				</ul>

				<hr/>
            			
                        
<div class="whats_new version"><p><h3>Version: v2.7</h3><BR /> Updated:9/1/2012</p></div>

				<ul>
				<li> 
					<span class="highlight-dark">Detailed Transcription Information:</span>
                    <ul >
                    	<li><div>View Parental Strain Differential Expression</li>
                        
                        <li><div  >View Parental Strain(Rat) Transcriptome Reconstruction</li>
                        
                        <li><div  >View Panel Heritability/Detection Above Background accross tissues</li>
                        
                        <li><div >View Panel Expression accross tissues</li>
                        
                        <li><div >View Exon Correlation Tool</li>
                        	
                        	<ul	 style="padding-left:50px;">
                                <li>Identify exons within a gene that are not expressed</li>
                                <li>Identify exons within a gene with low heritability</li>
                                <li>Use correlation patterns among exons to identify expressed isoforms.</li>
                            </ul>
                            </span>
                        <li><div >View eQTL information</li>
                        
                    </ul>
				<li>
					<span class="highlight-dark">New Menu Navigation:</span> The new Menu system allows users to easily get between functions that previously required clicking through multiple pages.  
				
				<li> 
					<span class="highlight-dark">Download Resources without Logging in:</span> Resources that used to require a login are now available without logging in.
                
				</ul>

				<br/>
                        
<div class="whats_new version"><p><h3>Version: v2.6</h3><BR /> Updated:5/22/2012</p></div>

				<ul>
				<li> 
					<span class="highlight-dark">Exon level analysis tools:</span>Analyze probeset-level data for the public exon arrays.
				<li>
					<span class="highlight-dark">Exon-exon correlation heatmaps:</span> Perform exon-exon correlation within a gene:  	
                    <ol type="a">
                    <li> Select a gene (from a gene list or enter your own). and 
                    <li> Select an exon dataset (from Rats or Mice).
                    <li> Select Brain(Mouse or Rat), Heart(Rat), Liver(Rat), or Brown Adipose tissues(Rat). 
                    <li> View any Ensembl transcript for the gene, or compare two 
                    transcripts side by side.
                    </ol>
				
				<li> 
					<span class="highlight-dark">Download RNA-sequencing:</span>SAM files from three replicates of polyA+ 
                    RNA from whole brain of two rat strains and three replicates of total RNA from whole
                    brain of the same two rat strains can now be downloaded in the Download Resources tab.
                <li> 
					<span class="highlight-dark">Data storage format:</span>A new system for storing data in the database and HDF5 files speeds up normalization, filtering, and statistics.  This is currently implemented 
                    to support analysis on Affymetrix Exon arrays, but future updates will implement the new storage methods for the 
                    remaining array types.
				</ul>

				<br/>


 
