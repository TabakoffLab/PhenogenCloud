<%--
 *  Author: Cheryl Hornbaker
 *  Created: Dec, 2010
 *  Description:  The web page created by this file allows the user to 
 *		download files useful for doing systems biology
 *  Todo: 
 *  Modification Log:
 *      
--%>


<%@ include file="/web/sysbio/include/sysBioHeader.jsp" %>
<%

    RNADataset myRNADataset = new RNADataset();
    int pubID = 0;
    String section = "rnaseq";
    log.info("in resources.jsp. user =  " + user);

    log.debug("action = " + action);
    extrasList.add("tooltipster.min.css");
    extrasList.add("tabs.css");
    extrasList.add("resources1.0.js");
    extrasList.add("jquery.tooltipster.min.js");
    extrasList.add("d3.v3.5.16.min.js");
    extrasList.add("datatables.1.10.21.min.js");
    //    extrasList.add("jquery.dataTables.1.10.9.min.js");

    mySessionHandler.createSessionActivity(session.getId(), "Looked at download systems biology resources page", pool);

    Resource[] myExpressionResources = myResource.getExpressionResources();
    log.debug("after expr");
    Resource[] myMarkerResources = myResource.getMarkerResources();
    log.debug("after marker");
    Resource[] myRNASeqResources = myResource.getRNASeqResources();
    log.debug("after rna");
    Resource[] myDNASeqResources = myResource.getDNASeqResources();
    log.debug("after dnaSeq");
    Resource[] rsemResources = myResource.getRNASeqExpressionResources();
    log.debug("after genotype");

    ArrayList<Resource[]> pubList = myResource.getPublications();

    Resource[] myGTFResources = myResource.getGTFResources();
    // Sort by organism first, dataset second (seems backwards!)
    myExpressionResources = myResource.sortResources(myResource.sortResources(myExpressionResources, "dataset"), "organism");
    ArrayList checkedList = new ArrayList();
    ArrayList<RNADataset> publicRNADatasets = myRNADataset.getRNADatasetsByPublic(true, "All", pool);
    if (request.getParameter("section") != null) {
        section = FilterInput.getFilteredInput(request.getParameter("section").trim());
    }
    if (request.getParameter("publication") != null) {
        pubID = Integer.parseInt(FilterInput.getFilteredInput(request.getParameter("publication").trim()));
    }
%>

<%
    pageTitle = "Download Resources";
    pageDescription = "Data resources available for downloading includes Microarrays, Sequencing, and GWAS data";
%>
<%@ include file="/web/common/header_adaptive_menu.jsp" %>

<style>
    span.detailMenu {
        border-color: #CCCCCC;
        border: solid;
        border-width: 1px 1px 0px 1px;
        border-radius: 5px 5px 0px 0px;
        padding-top: 2px;
        padding-bottom: 2px;
        padding-left: 15px;
        padding-right: 15px;
        cursor: pointer;
        color: #000000;

    }

    span.detailMenu {
        background-color: #AEAEAE;
        border-color: #000000;

    }

    span.detailMenu.selected {
        background-color: #FEFEFE;
        /*background:#86C3E2;*/
        color: #000000;
    }

    span.detailMenu:hover {
        background-color: #FEFEFE;
        /*background:#86C3E2;*/
        color: #000000;
    }

    div#public, div#members {
        border-color: #CCCCCC;
        border: solid;
        border-width: 1px 1px 1px 1px;
        background: #FEFEFE;
        padding-left: 5px;
        padding-right: 5px;
    }

    span.action {
        cursor: pointer;
    }

    span.button{
    	width: 300px;
    }

    div {
        font-size: 16px;
    }

    td, th{
    	font-size: 15px;
    }

    table{
    text-align: center;
    min-width: 50%;
    max-width:75%;
    }

    table.list_base td{
		padding-top:5px;
		padding-bottom:5px;
    }
    table.ucscTracks td{
    	padding-top:12px;
        padding-bottom:12px;
    }

</style>


<% if (loggedIn && !(userLoggedIn.getUser_name().equals("anon"))) {%>
<div style="width:100%;">
    <div style="font-size:18px; font-weight:bold;  color:#FFFFFF; text-align:center; width:100%; padding-top: 3px; ">
        <span id="detail1" class="detailMenu selected" name="public">Public Files</span>

        <span id="detail2" class="detailMenu" name="members">Members Files</span>

    </div>
</div>
<%}%>
<script>
    $("#wait1").hide();
</script>
<div id="public" style='min-height:1030px;'>
    <h2>Select the download icon(<img src="<%=imagesDir%>icons/download_g.png"/>) to download data from any of the
        datasets below. For some data types multiple
        options may be available. For these types, a window displays that allows you to choose specific files.</h2>
    <div style="width:100%;">
        <div style="font-size:18px; font-weight:bold;  color:#FFFFFF; text-align:center; width:100%; padding-top: 3px; ">
            <span id="d8" class="detailMenu <%if(section.equals("ucsc")){%>selected<%}%>"
                  name="ucsc">UCSC Track Hubs</span>
            <span id="d7" class="detailMenu <%if(section.equals("rest")){%>selected<%}%>"
                  name="rest">REST API / R</span>
            <span id="d2" class="detailMenu <%if(section.equals("rnaseq")){%>selected<%}%>" name="rnaseq">RNA-Seq</span>
            <span id="d6" class="detailMenu <%if(section.equals("dnaseq")){%>selected<%}%>" name="dnaseq">DNA-Seq</span>
            <span id="d1" class="detailMenu <%if(section.equals("array")){%>selected<%}%>"
                  name="array">Microarray</span>
            <span id="d3" class="detailMenu <%if(section.equals("marker")){%>selected<%}%>"
                  name="marker">Genomic Marker</span>
            <span id="d4" class="detailMenu <%if(section.equals("pub")){%>selected<%}%>" name="pub">Publications</span>

        </div>
    </div>
    <div id="ucsc" style="<%if(!section.equals("ucsc")){%>display:none;<%}%>border-top:1px solid black;">
        <H1 style="background: #3c3c3c;">PhenoGen UCSC Genome Browser Track Hubs</H1>
        <BR>
        <div>
            In addition to making the tracks available in our browser most tracks are available in a format to use with
            the <a href="https://genome.ucsc.edu/"
                   target="_blank">UCSC Genome
            Browser</a>. Please click on
            any link below to visit the UCSC Genome Browser with PhenoGen tracks. Tracks below are added as a track hub
            with multiple tracks you
            can adjust through the genome browser.
            Track hubs should remain linked to your UCSC rn7 genome view until you disconnect the track hub.<BR>
            Note: Many tracks may not be displayed by default as strain specific read counts in a tissue may have more
            than 100 tracks. If you are unfamiliar
            with the UCSC Genome browser you can select tracks to display below the image.
        </div>
        <BR><BR>
        <H1 style="background: #3c3c3c;text-align: center;"> HRDP v7.1 - rn7 - Aug 2024</H1>
        <span style="text-align: center;">
        		<H2>IsoSeq Alignments:</H2>
                        <BR>
                        <div>
                            <a href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hubUrl=https://phenogen.org/public_ucsc/rn7/v7/isoTrack/hub.txt"
                               target="_blank">Brain/Liver High Quality IsoSeq Alignment Track Hub</a> - <span name="isoSeqv7" class="showTracks button" style="width:190px;">Show Individual Tracks</span><BR>
                               <div id="isoSeqv7" style="display: none;">
                               		<table name="items" class="list_base ucscTracks">
                               		<thead><TR class="col_title"><TH>Track Name (UCSC Track Link)</TH><TH>Description</TH></TR></thead>
                               		<tbody>
                               		<TR>
                               		<TD><a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22PhenoGen%20Whole%20Brain%20HRDPv7%20IsoSeq%22%20type=bigBed%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/Brain.IsoSeq.rn7.v7.merged.HQ.bb%20description=%22PhenoGen%20Whole%20Brain%20HRDPv7%20IsoSeq%20(high%20quality%20concensous%20isoforms)%22%20color=126,181,214%20visibility=squish">Whole Brain IsoSeq</a></TD><TD> High Quality IsoSeq Concensus Sequences aligned to the HRDPv7 genomes. Following alignment 4 strains were merged into a single alignment(BAM) deduplicated transcripts with exactly matching introns and within 10bp at 5' end and 30bp at 3' end, assigned transcript IDs by matching across tissues, and then assigned to genes by matching isoforms with a shared exact match for a splice junction or overlapping single exons.</TD>
                               		</TR>
                               		<TR>
                               		<TD><a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22PhenoGen%20Liver%20HRDPv7%20IsoSeq%22%20type=bigBed%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/Liver.IsoSeq.rn7.v7.merged.HQ.bb%20description=%22PhenoGen%20Liver%20HRDPv7%20IsoSeq%20(high%20quality%20concensous%20isoforms)%22%20color=187,190,221%20visibility=squish">Liver IsoSeq</a></TD><TD>High Quality IsoSeq Concensus Sequences aligned to the HRDPv7 genomes. Following alignment 4 strains were merged into a single alignment(BAM) deduplicated transcripts with exactly matching introns and within 10bp at 5' end and 30bp at 3' end, assigned transcript IDs by matching across tissues, and then assigned to genes by matching isoforms with a shared exact match for a splice junction or overlapping single exons.</TD>
                               		</TR>
                               		<TR>
                               		<TD><a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22PhenoGen%20Merged%20HRDPv7%20IsoSeq%22%20type=bigBed%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/isoTrack/Merge.IsoSeq.rn7.v7.HQ.bb%20description=%22PhenoGen%20Merged%20HRDPv7%20IsoSeq%20(high%20quality%20concensous%20isoforms)%22%20color=139,59,126%20visibility=hide">Merged IsoSeq</a></TD><TD>Complete transcriptome of unique IsoSeq transcripts from Whole Brain and Liver as matched between tissues.</TD>
                               		</TR>
									</tbody>
									</table>
								</div>
                               <BR>
                         </div>
                <H2>RNA-Seq Reconstructed Transcriptomes with Merged Tissue Specific Read Counts:</H2>
                <BR>
                <div>
                	<a href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hubUrl=https://phenogen.org/public_ucsc/rn7/v7/femaleTrack/hub.txt"
                       target="_blank">Female Whole Brain/Liver Transcriptome Track Hub</a> - <span name="trxomeFMultiv7" class="showTracks button" style="width:190px;">Show Individual Tracks</span><BR>
					 <div id="trxomeFMultiv7" style="display: none;">
							<table name="items" class="list_base tablesorter ucscTracks">
							<thead>
							<TR class="col_title"><TH colspan="2">Whole Brain</TH><TH colspan="2">Liver</TH> </TR>
							<TR class="col_title"><TH>Track Name (UCSC Track Link)</TH><TH>Description</TH><TH>Track Name (UCSC Track Link)</TH><TH>Description</TH></TR>
							</thead>
							<tbody>
							<TR>
							<TD><a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22PhenoGen%20Brain%20HRDPv7%20Transcriptome%22%20type=bigBed%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/HRDP.v7.1.Brain.MF.bb%20description=%22PhenoGen%20Whole%20Brain%20HRDPv7%20Transcriptome%22%20color=126,181,214%20visibility=pack">PhenoGen Whole Brain HRDPv7 Transcriptome</a></TD>
							<TD>Whole brain ribosome depleted totalRNA transcriptome reconstruction. (73 strains) v7.1 includes male data and female data at Pre-Estrous, Estrous, and Post-Estrous time points.</TD>
							<TD><a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22PhenoGen%20Liver%20HRDPv7%20Transcriptome%20(HRDPv7)%22%20type=bigBed%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/HRDP.v7.1.Liver.MF.bb%20description=%22PhenoGen%20Liver%20HRDPv7%20Transcriptome%20(HRDPv7)%22%20color=187,190,221%20visibility=pack">PhenoGen Liver HRDPv7 Transcriptome (HRDPv7)</a></TD>
							<TD>Liver ribosome depleted totalRNA transcriptome reconstruction. (62 strains) v7.1 includes male data and female data at Pre-Estrous, Estrous, and Post-Estrous time points.</TD>
							</TR>

							<TR>
								<TD><a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22PhenoGen%20Female%20Whole%20Brain%20HRDPv7%20Merged%20Splice%20Junctions%22%20type=bigBed%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain.female/Merge.Brain.bb%20description=%22PhenoGen%20Female%20Whole%20Brain%20HRDPv7%20Merged%20Splice%20Junctions%22%20visibility=squish">Splice junctions Merged BNLx/SHR</a></TD>
								<TD>Splice junctions from the merged BNLx/SHR samples at PreE,E,PostE time points generated by <a href="https://regtools.readthedocs.io/en/latest/">regtools - v1.0.0</a>.</TD>
								<TD><a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22PhenoGen%20Female%20Liver%20HRDPv7%20Merged%20Splice%20Junctions%22%20type=bigBed%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver.female/Merge.Liver.bb%20description=%22PhenoGen%20Female%20Liver%20HRDPv7%20Merged%20Splice%20Junctions%22%20visibility=squish">Splice junctions Merged BNLx/SHR</a></TD>
								<TD>Splice junctions from the merged BNLx/SHR samples at PreE,E,PostE time points generated by <a href="https://regtools.readthedocs.io/en/latest/">regtools - v1.0.0</a>.</TD>
							</TR>
							<TR>
							<TD><a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22PhenoGen%20Female%20Whole%20Brain%20HRDPv7%20Merged%20Pre-E%20Splice%20Junctions%22%20type=bigBed%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain.female/Merge-PreE.Brain.bb%20description=%22PhenoGen%20Female%20Whole%20Brain%20HRDPv7%20Merged%20Pre-Estrous%20Splice%20Junctions%22%20visibility=squish">Splice junctions Pre-Estrous BNLx/SHR</a></TD>
							<TD>Splice junctions from the merged Pre-Estrous BNLx/SHR samples generated by <a href="https://regtools.readthedocs.io/en/latest/">regtools - v1.0.0</a>.</TD>
							<TD><a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22PhenoGen%20Female%20Liver%20HRDPv7%20Merged%20Pre-E%20Splice%20Junctions%22%20type=bigBed%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver.female/Merge-PreE.Liver.bb%20description=%22PhenoGen%20Female%20Liver%20HRDPv7%20Merged%20Pre-Estrous%20Splice%20Junctions%22%20visibility=squish">Splice junctions Pre-Estrous BNLx/SHR</a></TD>
							<TD>Splice junctions from the merged Pre-Estrous BNLx/SHR samples generated by <a href="https://regtools.readthedocs.io/en/latest/">regtools - v1.0.0</a>.</TD>
							</TR>
							<TR>
								<TD><a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22PhenoGen%20Female%20Whole%20Brain%20HRDPv7%20Merged%20E%20Splice%20Junctions%22%20type=bigBed%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain.female/Merge-E.Brain.bb%20description=%22PhenoGen%20Female%20Whole%20Brain%20HRDPv7%20Merged%20Estrous%20Splice%20Junctions%22%20visibility=squish">Splice junctions Estrous BNLx/SHR</a></TD>
								<TD>Splice junctions from the merged Estrous BNLx/SHR samples generated by <a href="https://regtools.readthedocs.io/en/latest/">regtools - v1.0.0</a>.</TD>
								<TD><a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22PhenoGen%20Female%20Liver%20HRDPv7%20Merged%20E%20Splice%20Junctions%22%20type=bigBed%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver.female/Merge-E.Liver.bb%20description=%22PhenoGen%20Female%20Liver%20HRDPv7%20Merged%20Estrous%20Splice%20Junctions%22%20visibility=squish">Splice junctions Estrous BNLx/SHR</a></TD>
								<TD>Splice junctions from the merged Estrous BNLx/SHR samples generated by <a href="https://regtools.readthedocs.io/en/latest/">regtools - v1.0.0</a>.</TD>
							</TR>
                           	<TR>
								<TD><a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22PhenoGen%20Female%20Whole%20Brain%20HRDPv7%20Merged%20Post-E%20Splice%20Junctions%22%20type=bigBed%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain.female/Merge-PostE.Brain.bb%20description=%22PhenoGen%20Female%20Whole%20Brain%20HRDPv7%20Merged%20Post-Estrous%20Splice%20Junctions%22%20visibility=squish">Splice junctions Post-Estrous BNLx/SHR</a></TD>
								<TD>Splice junctions from the merged Post-Estrous BNLx/SHR samples generated by <a href="https://regtools.readthedocs.io/en/latest/">regtools - v1.0.0</a>.</TD>
								<TD><a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22PhenoGen%20Female%20Liver%20HRDPv7%20Merged%20Post-E%20Splice%20Junctions%22%20type=bigBed%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver.female/Merge-PostE.Liver.bb%20description=%22PhenoGen%20Female%20Liver%20HRDPv7%20Merged%20Post-Estrous%20Splice%20Junctions%22%20visibility=squish">Splice junctions Post-Estrous BNLx/SHR</a></TD>
								<TD>Splice junctions from the merged Post-Estrous BNLx/SHR samples generated by <a href="https://regtools.readthedocs.io/en/latest/">regtools - v1.0.0</a>.</TD>
							</TR>
							<TR>
								<TD>Whole Brain Female Merged(BNLx/SHR) totalRNA (HRDPv7) <BR><a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22PhenoGen%20Female%20Whole%20Brain%20HRDPv7%20Merged%20Reads%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain.female/total/Merge.Brain.plus.bw%20description=%22PhenoGen%20Female%20Whole%20Brain%20HRDPv7%20Merged%20Reads%20(HRDPv7)%22%20color=126,181,214%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22PhenoGen%20Female%20Whole%20Brain%20HRDPv7%20Merged%20Reads%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain.female/total/Merge.Brain.minus.bw%20description=%22PhenoGen%20Female%20Whole%20Brain%20HRDPv7%20Merged%20Reads%20(HRDPv7)%22%20color=126,181,214%20autoScale=on%20visibility=full">- strand </a></TD>
								<TD>Whole brain ribosome depleted totalRNA read depth track includes female data at Pre-Estrous, Estrous, and Post-Estrous time points.</TD>
								<TD>Liver Female Merged(BNLx/SHR) totalRNA (HRDPv7) <BR><a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22PhenoGen%20Female%20Liver%20HRDPv7%20Merged%20Reads%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver.female/total/Merge.Liver.plus.bw%20description=%22PhenoGen%20Female%20Liver%20HRDPv7%20Merged%20Reads%20(HRDPv7)%22%20color=187,190,221%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22PhenoGen%20Female%20Liver%20HRDPv7%20Merged%20Reads%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver.female/total/Merge.Liver.minus.bw%20description=%22PhenoGen%20Female%20Liver%20HRDPv7%20Merged%20Reads%20(HRDPv7)%22%20color=187,190,221%20autoScale=on%20visibility=full">- strand </a></TD>
								<TD>Liver ribosome depleted totalRNA read depth track includes female data at Pre-Estrous, Estrous, and Post-Estrous time points.</TD>
								</TR>
							<TR>
								<TD>Whole Brain Female Merged(BNLx/SHR) totalRNA Estrous (HRDPv7) <BR><a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22PhenoGen%20Female%20Whole%20Brain%20HRDPv7%20Merged%20E%20Reads%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain.female/total/Merge-E.Brain.plus.bw%20description=%22PhenoGen%20Female%20Whole%20Brain%20HRDPv7%20Merged%20Estrous%20Reads%20(HRDPv7)%22%20color=126,181,214%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22PhenoGen%20Female%20Whole%20Brain%20HRDPv7%20Merged%20E%20Reads%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain.female/total/Merge-E.Brain.minus.bw%20description=%22PhenoGen%20Female%20Whole%20Brain%20HRDPv7%20Merged%20Estrous%20Reads%20(HRDPv7)%22%20color=126,181,214%20autoScale=on%20visibility=full">- strand </a></TD>
								<TD>Whole brain ribosome depleted totalRNA read depth track includes female data at Estrous time points.</TD>
								<TD>Liver Female Merged(BNLx/SHR) totalRNA Estrous (HRDPv7) <BR><a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22PhenoGen%20Female%20Liver%20HRDPv7%20Merged%20E%20Reads%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver.female/total/Merge-E.Liver.plus.bw%20description=%22PhenoGen%20Female%20Liver%20HRDPv7%20Merged%20Estrous%20Reads%20(HRDPv7)%22%20color=187,190,221%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22PhenoGen%20Female%20Liver%20HRDPv7%20Merged%20E%20Reads%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver.female/total/Merge-E.Liver.minus.bw%20description=%22PhenoGen%20Female%20Liver%20HRDPv7%20Merged%20Estrous%20Reads%20(HRDPv7)%22%20color=187,190,221%20autoScale=on%20visibility=full">- strand </a></TD>
								<TD>Liver ribosome depleted totalRNA read depth track includes female data at Estrous time points.</TD>
								</TR>

                           	<TR>
								<TD>Whole Brain Female Merged(BNLx/SHR) totalRNA Pre-Estrous (HRDPv7) <BR><a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22PhenoGen%20Female%20Whole%20Brain%20HRDPv7%20Merged%20Pre-E%20Reads%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain.female/total/Merge-PreE.Brain.plus.bw%20description=%22PhenoGen%20Female%20Whole%20Brain%20HRDPv7%20Merged%20Pre-Estrous%20Reads%20(HRDPv7)%22%20color=126,181,214%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22PhenoGen%20Female%20Whole%20Brain%20HRDPv7%20Merged%20Pre-E%20Reads%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain.female/total/Merge-PreE.Brain.minus.bw%20description=%22PhenoGen%20Female%20Whole%20Brain%20HRDPv7%20Merged%20Pre-Estrous%20Reads%20(HRDPv7)%22%20color=126,181,214%20autoScale=on%20visibility=full">- strand </a></TD>
								<TD>Whole brain ribosome depleted totalRNA read depth track includes female data at Pre-Estrous time points.</TD>
								<TD>Liver Female Merged(BNLx/SHR) totalRNA Pre-Estrous (HRDPv7) <BR><a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22PhenoGen%20Female%20Liver%20HRDPv7%20Merged%20Pre-E%20Reads%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver.female/total/Merge-PreE.Liver.plus.bw%20description=%22PhenoGen%20Female%20Liver%20HRDPv7%20Merged%20Pre-Estrous%20Reads%20(HRDPv7)%22%20color=187,190,221%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22PhenoGen%20Female%20Liver%20HRDPv7%20Merged%20Pre-E%20Reads%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver.female/total/Merge-PreE.Liver.minus.bw%20description=%22PhenoGen%20Female%20Liver%20HRDPv7%20Merged%20Pre-Estrous%20Reads%20(HRDPv7)%22%20color=187,190,221%20autoScale=on%20visibility=full">- strand </a></TD>
								<TD>Liver ribosome depleted totalRNA read depth track includes female data at Pre-Estrous time points.</TD>
								</TR>

                            <TR>
								<TD>Whole Brain Female Merged(BNLx/SHR) totalRNA Post-Estrous (HRDPv7) <BR><a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22PhenoGen%20Female%20Whole%20Brain%20HRDPv7%20Merged%20Post-E%20Reads%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain.female/total/Merge-PostE.Brain.plus.bw%20description=%22PhenoGen%20Female%20Whole%20Brain%20HRDPv7%20Merged%20Post-Estrous%20Reads%20(HRDPv7)%22%20color=126,181,214%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22PhenoGen%20Female%20Whole%20Brain%20HRDPv7%20Merged%20Post-E%20Reads%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain.female/total/Merge-PostE.Brain.minus.bw%20description=%22PhenoGen%20Female%20Whole%20Brain%20HRDPv7%20Merged%20Post-Estrous%20Reads%20(HRDPv7)%22%20color=126,181,214%20autoScale=on%20visibility=full">- strand </a></TD>
								<TD>Whole brain ribosome depleted totalRNA read depth track includes female data at Post-Estrous time points.</TD>
								<TD>Liver Female Merged(BNLx/SHR) totalRNA Post-Estrous (HRDPv7) <BR><a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22PhenoGen%20Female%20Liver%20HRDPv7%20Merged%20Post-E%20Reads%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver.female/total/Merge-PostE.Liver.plus.bw%20description=%22PhenoGen%20Female%20Liver%20HRDPv7%20Merged%20Post-Estrous%20Reads%20(HRDPv7)%22%20color=187,190,221%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22PhenoGen%20Female%20Liver%20HRDPv7%20Merged%20Post-E%20Reads%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver.female/total/Merge-PostE.Liver.minus.bw%20description=%22PhenoGen%20Female%20Liver%20HRDPv7%20Merged%20Post-Estrous%20Reads%20(HRDPv7)%22%20color=187,190,221%20autoScale=on%20visibility=full">- strand </a></TD>
								<TD>Liver ribosome depleted totalRNA read depth track includes female data at Post-Estrous time points.</TD>
								</TR>

						</tbody>
						</table>
					</div><BR>
                    <a href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hubUrl=https://phenogen.org/public_ucsc/rn7/v7/hub.txt"
                       target="_blank">MultiTissue
                        Transcriptome Track Hub</a> - <span name="trxomeMultiv7" class="showTracks button" style="width:190px;">Show Individual Tracks</span><BR>
                                                                                     <div id="trxomeMultiv7" style="display: none;">
                                                                                     		<table name="items" class="list_base ucscTracks">
                                                                                     		<thead><TR class="col_title"><TH>Track Name (UCSC Track Link)</TH><TH>Description</TH></TR></thead>
                                                                                     		<tbody>
                                                                                     		<TR>
                                                                                     		<TD><a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22PhenoGen%20Brain%20HRDPv7%20Transcriptome%22%20type=bigBed%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/HRDP.v7.1.Brain.MF.bb%20description=%22PhenoGen%20Whole%20Brain%20HRDPv7%20Transcriptome%22%20color=126,181,214%20visibility=pack">PhenoGen Whole Brain HRDPv7 Transcriptome</a></TD><TD>Whole brain ribosome depleted totalRNA transcriptome reconstruction. (73 strains) v7 includes male data and female data at Pre-Estrous, Estrous, and Post-Estrous time points.</TD>
                                                                                     		</TR>

                                                                                     		<TR>
                                                                                     		<TD><a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22Brain%20TotalRNA%20Plus%205%20Billion%20Reads%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/Merged.5bReads.plus.bw%20description=%22Brain%20TotalRNA%20Plus%205%20Billion%20Reads%20(HRDPv7)%22%20color=106,161,194%20autoScale=on%20visibility=full">Brain TotalRNA Plus 5 Billion Reads (HRDPv7)</a></TD><TD>Whole brain plus strand read depth using 5 billion reads randomly sampled from all of the samples merged together.</TD>
                                                                                     		</TR>

                                                                                     		<TR>
                                                                                     		<TD><a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22Brain%20TotalRNA%20Minus%205%20Billion%20Reads%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/Merged.5bReads.minus.bw%20description=%22Brain%20TotalRNA%20Minus%205%20Billion%20Reads%20(HRDPv7)%22%20color=146,201,234%20autoScale=on%20visibility=full">Brain TotalRNA Minus 5 Billion Reads (HRDPv7)</a></TD><TD>Whole brain minus strand read depth using 5 billion reads randomly sampled from all of the samples merged together.</TD>
                                                                                     		</TR>

                                                                                     		<TR>
																							<TD><a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22PhenoGen%20Liver%20HRDPv7%20Transcriptome%20(HRDPv7)%22%20type=bigBed%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/HRDP.v7.1.Liver.MF.bb%20description=%22PhenoGen%20Liver%20HRDPv7%20Transcriptome%20(HRDPv7)%22%20color=187,190,221%20visibility=pack">PhenoGen Liver HRDPv7 Transcriptome (HRDPv7)</a></TD><TD>Liver ribosome depleted totalRNA transcriptome reconstruction. (62 strains) v7 includes male data and female data at Pre-Estrous, Estrous, and Post-Estrous time points.</TD>
																							</TR>

																							<TR>
																							<TD><a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22Liver%20TotalRNA%20Plus%205%20Billion%20Reads%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/Merged.5bReads.plus.bw%20description=%22Liver%20TotalRNA%20Plus%205%20Billion%20Reads%20(HRDPv7)%22%20color=167,170,201%20autoScale=on%20visibility=full">Liver TotalRNA Plus 5 Billion Reads (HRDPv7)</a></TD><TD>Liver plus strand read depth using 5 billion reads randomly sampled from all of the samples merged together.</TD>
																							</TR>

																							<TR>
																							<TD><a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22Liver%20TotalRNA%20Minus%205%20Billion%20Reads%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/Merged.5bReads.minus.bw%20description=%22Liver%20TotalRNA%20Minus%205%20Billion%20Reads%20(HRDPv7)%22%20color=207,210,241%20autoScale=on%20visibility=full">Liver TotalRNA Minus 5 Billion Reads (HRDPv7)</a></TD><TD>Liver minus strand read depth using 5 billion reads randomly sampled from all of the samples merged together.</TD>
																							</TR>

																							<TR>
																							<TD><a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22PhenoGen%20Heart%20HRDPv7%20Transcriptome%22%20type=bigBed%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/HRDP.v7.1.Heart.bb%20description=%22PhenoGen%20Heart%20HRDPv7%20Transcriptome%22%20color=220,114,82%20visibility=pack">PhenoGen Heart HRDPv7 Transcriptome</a></TD><TD>Heart ribosome depleted totalRNA transcriptome reconstruction (21 strains)</TD>
																							</TR>

																							<TR>
																							<TD><a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22Heart%20TotalRNA%20Plus%20Reads%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/total/Merged.plus.bw%20description=%22Heart%20TotalRNA%20Plus%20Reads%20(HRDPv7)%22%20color=200,94,62%20autoScale=on%20visibility=full">Heart TotalRNA Plus Reads (HRDPv7)</a></TD><TD>Heart plus strand read depth using all of the samples merged together.</TD>
																							</TR>

																							<TR>
																							<TD><a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22Heart%20TotalRNA%20Minus%20Reads%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/total/Merged.minus.bw%20description=%22Heart%20TotalRNA%20Minus%20Reads%20(HRDPv7)%22%20color=240,134,102%20autoScale=on%20visibility=full">Heart TotalRNA Minus Reads (HRDPv7)</a></TD><TD>Heart minus strand read depth using all of the samples merged together.</TD>
																							</TR>

																							<TR>
																							<TD><a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22PhenoGen%20Kidney%20HRDPv7%20Transcriptome%22%20type=bigBed%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kidney/HRDP.v7.1.Kidney.bb%20description=%22PhenoGen%20Kidney%20HRDPv7%20Transcriptome%22%20color=253,180,98%20visibility=pack">PhenoGen Kidney HRDPv7 Transcriptome</a></TD><TD>Kidney ribosome depleted totalRNA transcriptome reconstruction. (28 strain)</TD>
																							</TR>

																							<TR>
																							<TD><a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22Kidney%20TotalRNA%20Plus%205%20Billion%20Reads%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kidney/sampled/Merged.5bReads.plus.bw%20description=%22Kidney%20TotalRNA%20Plus%205%20Billion%20Reads%20(HRDPv7)%22%20color=233,160,78%20autoScale=on%20visibility=full">Kidney TotalRNA Plus 5 Billion Reads (HRDPv7)</a></TD><TD>Liver plus strand read depth using 5 billion reads randomly sampled from all of the samples merged together.</TD>
																							</TR>
																							<TR>
																							<TD><a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22Kidney%20TotalRNA%20Minus%205%20Billion%20Reads%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kidney/sampled/Merged.5bReads.minus.bw%20description=%22Kidney%20TotalRNA%20Minus%205%20Billion%20Reads%20(HRDPv7)%22%20color=255,200,118%20autoScale=on%20visibility=full">Kidney TotalRNA Minus 5 Billion Reads (HRDPv7)</a></TD><TD>Liver minus strand read depth using 5 billion reads randomly sampled from all of the samples merged together.</TD>
																							</TR>
																							<TR>
																							<TD><a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22PhenoGen%20MultiTissue%20HRDPv7%20Transcriptome%20(HRDPv7)%22%20type=bigBed%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/HRDP.v7.1.Merged.bb%20description=%22PhenoGen%20MultiTissue%20HRDPv7%20Transcriptome%20(HRDPv7)%22%20color=159,79,146%20visibility=hide">PhenoGen MultiTissue HRDPv7 Transcriptome (HRDPv7)</a></TD><TD>Merged across tissues/strains/sex ribosome depleted totalRNA transcriptome reconstruction (73 strains/Male and Female data).</TD>
																							</TR>


                                                      									</tbody>
                                                      									</table>
                                                      								</div><BR>
                    <a href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hubUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/hub.txt"
                       target="_blank">Whole Brain Transcriptome Track Hub</a> -
                       <span name="trxomeBrainv7" class="showTracks button" style="width:190px;">Show Individual Tracks</span><BR>
					 	<div id="trxomeBrainv7" style="display: none;">
                                                                                     		<table name="items" class="list_base ucscTracks">
																							<thead><TR class="col_title"><TH>Track Name (UCSC Track Link)</TH><TH>Description</TH></TR></thead>
																							<tbody>
																							<TR>
																							<TD><a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22PhenoGen%20Brain%20HRDPv7%20Transcriptome%22%20type=bigBed%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/HRDP.v7.1.Brain.MF.bb%20description=%22PhenoGen%20Whole%20Brain%20HRDPv7%20Transcriptome%22%20color=126,181,214%20visibility=pack">PhenoGen Whole Brain HRDPv7 Transcriptome</a></TD><TD>Whole brain ribosome depleted totalRNA transcriptome reconstruction. (73 strains) v7 includes male data and female data at Pre-Estrous, Estrous, and Post-Estrous time points.</TD>
																							</TR>

																							<TR>
																							<TD><a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22Brain%20TotalRNA%20Plus%205%20Billion%20Reads%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/Merged.5bReads.plus.bw%20description=%22Brain%20TotalRNA%20Plus%205%20Billion%20Reads%20(HRDPv7)%22%20color=106,161,194%20autoScale=on%20visibility=full">Whole Brain TotalRNA Plus 5 Billion Reads (HRDPv7)</a></TD><TD>Whole brain plus strand read depth using 5 billion reads randomly sampled from all of the samples merged together.</TD>
																							</TR>

																							<TR>
																							<TD><a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22Brain%20TotalRNA%20Minus%205%20Billion%20Reads%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/Merged.5bReads.minus.bw%20description=%22Brain%20TotalRNA%20Minus%205%20Billion%20Reads%20(HRDPv7)%22%20color=146,201,234%20autoScale=on%20visibility=full">Whole Brain TotalRNA Minus 5 Billion Reads (HRDPv7)</a></TD><TD>Whole brain minus strand read depth using 5 billion reads randomly sampled from all of the samples merged together.</TD>
																							</TR>
																							<TR>
																							<TD><a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22PhenoGen%20Brain%20HRDPv7%20Splice%20Junctions%22%20type=bigBed%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/Merged.5bReads.bb%20description=%22PhenoGen%20Whole%20Brain%20HRDPv7%20Splice%20Junctions%22%20itemRgb=on%20visibility=squish">Whole Brain TotalRNA Splice Junctions (HRDPv7)</a></TD><TD>Splice junctions generated by <a href="https://regtools.readthedocs.io/en/latest/">regtools - v1.0.0</a> from the merged 5 billion read sampled file.</TD>
																							</TR>
																						</tbody>
																						</table>
                                                      								</div><BR>
                    <a href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hubUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/hub.txt"
                       target="_blank">Liver Transcriptome Track Hub</a> -
                         <span name="trxomeLiverv7" class="showTracks button" style="width:190px;">Show Individual Tracks</span><BR>
                                                                                     <div id="trxomeLiverv7" style="display: none;">
                                                                                     		<table name="items" class="list_base ucscTracks">
																								<thead><TR class="col_title"><TH>Track Name (UCSC Track Link)</TH><TH>Description</TH></TR></thead>
																								<tbody>
																								<TR>
																								<TD><a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22PhenoGen%20Liver%20HRDPv7%20Transcriptome%22%20type=bigBed%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/HRDP.v7.1.Liver.MF.bb%20description=%22PhenoGen%20Liver%20HRDPv7%20Transcriptome%22%20color=187,190,221%20visibility=pack">PhenoGen Liver HRDPv7 Transcriptome</a></TD><TD>Liver ribosome depleted totalRNA transcriptome reconstruction. (62 strains) v7 includes male data and female data at Pre-Estrous, Estrous, and Post-Estrous time points.</TD>
																								</TR>

																								<TR>
																								<TD><a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22Liver%20TotalRNA%20Plus%205%20Billion%20Reads%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/Merged.5bReads.plus.bw%20description=%22Liver%20TotalRNA%20Plus%205%20Billion%20Reads%20(HRDPv7)%22%20color=187,190,221%20autoScale=on%20visibility=full">Liver TotalRNA Plus 5 Billion Reads (HRDPv7)</a></TD><TD>Liver plus strand read depth using 5 billion reads randomly sampled from all of the samples merged together.</TD>
																								</TR>

																								<TR>
																								<TD><a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22Liver%20TotalRNA%20Minus%205%20Billion%20Reads%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/Merged.5bReads.minus.bw%20description=%22Liver%20TotalRNA%20Minus%205%20Billion%20Reads%20(HRDPv7)%22%20color=217,220,251%20autoScale=on%20visibility=full">Liver TotalRNA Minus 5 Billion Reads (HRDPv7)</a></TD><TD>Liver minus strand read depth using 5 billion reads randomly sampled from all of the samples merged together.</TD>
																								</TR>
																								<TR>
																								<TD><a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22PhenoGen%20Liver%20HRDPv7%20Splice%20Junctions%22%20type=bigBed%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/Merged.5bReads.bb%20description=%22PhenoGen%20Liver%20HRDPv7%20Splice%20Junctions%22%20itemRgb=on%20visibility=squish">Liver TotalRNA Splice Junctions (HRDPv7)</a></TD><TD>Splice junctions generated by <a href="https://regtools.readthedocs.io/en/latest/">regtools - v1.0.0</a> from the merged 5 billion read sampled file.</TD>
																								</TR>
																							</tbody>
																							</table>
                                                      								</div><BR>
                    <a href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hubUrl=https://phenogen.org/public_ucsc/rn7/v7/kidney/hub.txt"
                       target="_blank">Kidney
                        Transcriptome Track Hub</a> - <span name="trxomeKidneyv7" class="showTracks button" style="width:190px;">Show Individual Tracks</span><BR>
                                                                                     <div id="trxomeKidneyv7" style="display: none;">
                                                                                     		<table name="items" class="list_base ucscTracks">
																								<thead><TR class="col_title"><TH>Track Name (UCSC Track Link)</TH><TH>Description</TH></TR></thead>
																								<tbody>
																								<TR>
																								<TD><a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22PhenoGen%20Kidney%20HRDPv7%20Transcriptome%22%20type=bigBed%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kidney/HRDP.v7.1.Kidney.bb%20description=%22PhenoGen%20Kidney%20HRDPv7%20Transcriptome%22%20color=253,180,98%20visibility=pack">PhenoGen Kidney HRDPv7 Transcriptome</a></TD><TD>Kidney ribosome depleted totalRNA transcriptome reconstruction. (28 strains)</TD>
																								</TR>

																								<TR>
																								<TD><a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22Kidney%20TotalRNA%20Plus%205%20Billion%20Reads%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kidney/sampled/Merged.5bReads.plus.bw%20description=%22Kidney%20TotalRNA%20Plus%205%20Billion%20Reads%20(HRDPv7)%22%20color=253,180,98%20autoScale=on%20visibility=full">Kidney TotalRNA Plus 5 Billion Reads (HRDPv7)</a></TD><TD>Kidney plus strand read depth using 5 billion reads randomly sampled from all of the samples merged together.</TD>
																								</TR>

																								<TR>
																								<TD><a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22Kidney%20TotalRNA%20Minus%205%20Billion%20Reads%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kidney/sampled/Merged.5bReads.minus.bw%20description=%22Kidney%20TotalRNA%20Minus%205%20Billion%20Reads%20(HRDPv7)%22%20color=255,210,128%20autoScale=on%20visibility=full">Kidney TotalRNA Minus 5 Billion Reads (HRDPv7)</a></TD><TD>Kidney minus strand read depth using 5 billion reads randomly sampled from all of the samples merged together.</TD>
																								</TR>
																								<TR>
																								<TD><a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22PhenoGen%20Kidney%20HRDPv7%20Splice%20Junctions%22%20type=bigBed%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kidney/sampled/Merged.5bReads.bb%20description=%22PhenoGen%20Kidney%20HRDPv7%20Splice%20Junctions%22%20itemRgb=on%20visibility=squish">Kidney TotalRNA Splice Junctions (HRDPv7)</a></TD><TD>Splice junctions generated by <a href="https://regtools.readthedocs.io/en/latest/">regtools - v1.0.0</a> from the merged 5 billion read sampled file.</TD>
																								</TR>
																							</tbody>
																							</table>
                                                      								</div><BR>
                    <a href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hubUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/hub.txt"
                       target="_blank">Heart
                        Transcriptome Track Hub</a> - <span name="trxomeHeartv7" class="showTracks button" style="width:190px;">Show Individual Tracks</span><BR>
                                                                                     <div id="trxomeHeartv7" style="display: none;">
                                                                                     		<table name="items" class="list_base ucscTracks">
																								<thead><TR class="col_title"><TH>Track Name (UCSC Track Link)</TH><TH>Description</TH></TR></thead>
																								<tbody>
																								<TR>
																								<TD><a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22PhenoGen%20Heart%20HRDPv7%20Transcriptome%22%20type=bigBed%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/HRDP.v7.1.Heart.bb%20description=%22PhenoGen%20Heart%20HRDPv7%20Transcriptome%22%20color=220,114,82%20visibility=pack">PhenoGen Heart HRDPv7 Transcriptome</a></TD><TD>Heart ribosome depleted totalRNA transcriptome reconstruction. (21 strains)</TD>
																								</TR>

																								<TR>
																								<TD><a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22Heart%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/total/Merged.plus.bw%20description=%22Heart%20TotalRNA%20Plus%20(HRDPv7)%22%20color=204,98,66%20autoScale=on%20visibility=full">Heart TotalRNA Plus 5 Billion Reads (HRDPv7)</a></TD><TD>Heart plus strand read depth using 5 billion reads randomly sampled from all of the samples merged together.</TD>
																								</TR>

																								<TR>
																								<TD><a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22Heart%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/total/Merged.minus.bw%20description=%22Heart%20TotalRNA%20Minus%20(HRDPv7)%22%20color=252,146,114%20autoScale=on%20visibility=full">Heart TotalRNA Minus 5 Billion Reads (HRDPv7)</a></TD><TD>Heart minus strand read depth using 5 billion reads randomly sampled from all of the samples merged together.</TD>
																								</TR>
																								<TR>
																								<TD><a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22PhenoGen%20Heart%20HRDPv7%20Splice%20Junctions%22%20type=bigBed%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/total/Merged.bb%20description=%22PhenoGen%20Heart%20HRDPv7%20Splice%20Junctions%22%20itemRgb=on%20visibility=squish">Heart TotalRNA Splice Junctions (HRDPv7)</a></TD><TD>Splice junctions generated by <a href="https://regtools.readthedocs.io/en/latest/">regtools - v1.0.0</a> from the merged 5 billion read sampled file.</TD>
																								</TR>
																							</tbody>
																							</table>
                                                      								</div><BR>
                </div>
                <BR>
				<H2>Strain/Tissue Specific Read Counts (Sampled):</H2>
				<div style="text-align: center;">Randomly sampled to even total counts between strains to match the lowest strain.</div>
                <BR>
                <div>
                            <a href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hubUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/hub.txt"
                               target="_blank">Whole Brain Strain Specific Reads Counts (Sampled)</a> -
                               <span name="brainCountSampv7" class="showTracks button" style="width:190px;">Show Individual Tracks</span><BR>
                                                                                                               <div id="brainCountSampv7" style="display: none;">
                                                                                                               		<table name="items" class="list_base ucscTracks">
																													<THEAD>
																													<TR class="col_title">
																														<TH colspan="2">Inbred Strains</TH>
																														<TH colspan="2">HXB/BXH Strains</TH>
																														<TH colspan="2">FXLE/LEXF Strains</TH>
																													</TR>
																													</THEAD>
                                                                                                               		<tbody>
                                                                                                               		<TR>
                                                                                                               		<TD>ACI/EurMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22ACI%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/ACI.plus.bw%20description=%22ACI%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22ACI%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/ACI.minus.bw%20description=%22ACI%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                               		<TD>LEW/Crl <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEW-NCrl%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/LEW-NCrl.plus.bw%20description=%22LEW-NCrl%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEW-NCrl%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/LEW-NCrl.minus.bw%20description=%22LEW-NCrl%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                               		<TD>BXH2/CubMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH2%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/BXH2.plus.bw%20description=%22BHX2%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH2%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/BXH2.minus.bw%20description=%22BHX2%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                               		<TD>HXB7/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB7%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/HBX7.plus.bw%20description=%22HXB7%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB7%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/HBX7.minus.bw%20description=%22HXB7%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                               		<TD>FXLE12/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22FXLE12%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/FXLE12.plus.bw%20description=%22FXLE12%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22FXLE12%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/FXLE12.minus.bw%20description=%22FXLE12%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                               		<TD>LEXF1A/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF1A%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/LEXF1A.plus.bw%20description=%22LEXF1A%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF1A%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/LEXF1A.minus.bw%20description=%22LEXF1A%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                               		</TR>
                                                                                                               		<TR>
                                                                                                               		<TD>BDIX/NemOda <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BDIX%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/BDIX.plus.bw%20description=%22BDIX%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BDIX%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/BDIX.minus.bw%20description=%22BDIX%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                               		<TD>LEW/SsNHsd <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEW-SsNHsd%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/LEW-SsNHsd.plus.bw%20description=%22LEW-SsNHsd%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEW-SsNHsd%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/LEW-SsNHsd.minus.bw%20description=%22LEW-SsNHsd%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                               		<TD>BXH3/CubMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH3%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/BXH3.plus.bw%20description=%22BHX3%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH3%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/BXH3.minus.bw%20description=%22BHX3%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>

                                                                                                               		<TD>HXB10/IpcvMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB10%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/HBX10.plus.bw%20description=%22HXB10%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB10%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/HBX10.minus.bw%20description=%22HXB10%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                               		<TD>FXLE13/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22FXLE13%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/FXLE13.plus.bw%20description=%22FXLE13%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22FXLE13%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/FXLE13.minus.bw%20description=%22FXLE13%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a> </TD>

                                                                                                               		<TD>LEXF1C/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF1C%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/LEXF1C.plus.bw%20description=%22LEXF1C%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF1C%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/LEXF1C.minus.bw%20description=%22LEXF1C%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                               		</TR>
                                                                                                               		<TR>
                                                                                                               		<TD>BN/NHsdMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BN%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/BN.plus.bw%20description=%22BN%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BN%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/BN.minus.bw%20description=%22BN%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                               		<TD>LH/MavRrrc <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LH%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/LH.plus.bw%20description=%22LH%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LH%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/LH.minus.bw%20description=%22LH%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                               		<TD>BXH5/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH5%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/BXH5.plus.bw%20description=%22BHX5%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH5%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/BXH5.minus.bw%20description=%22BHX5%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>


                                                                                                               		<TD>HXB13/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB13%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/HBX13.plus.bw%20description=%22HXB13%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB13%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/HBX13.minus.bw%20description=%22HXB13%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                               		<TD>FXLE14/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22FXLE14%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/FXLE14.plus.bw%20description=%22FXLE14%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22FXLE14%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/FXLE14.minus.bw%20description=%22FXLE14%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                               		<TD>LEXF2B/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF2B%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/LEXF2B.plus.bw%20description=%22LEXF2B%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF2B%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/LEXF2B.minus.bw%20description=%22LEXF2B%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                               		</TR>
                                                                                                               		<TR>
																													<TD>BN-Lx/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BNLx%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/BNLx.plus.bw%20description=%22BNLx%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=dense">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BNLx%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/BNLx.minus.bw%20description=%22BNLx%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=dense">- strand</a></TD>
																													<TD>M520/N <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22M520%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/M520.plus.bw%20description=%22M520%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22M520%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/M520.minus.bw%20description=%22M520%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
																													<TD>BXH6/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH6%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/BXH6.plus.bw%20description=%22BHX6%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH6%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/BXH6.minus.bw%20description=%22BHX6%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
																													<TD>HXB15/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB15%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/HBX15.plus.bw%20description=%22HXB15%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB15%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/HBX15.minus.bw%20description=%22HXB15%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>

																													<TD>FXLE15/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22FXLE15%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/FXLE15.plus.bw%20description=%22FXLE15%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22FXLE15%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/FXLE15.minus.bw%20description=%22FXLE15%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
																													<TD>LEXF2C/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF2C%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/LEXF2C.plus.bw%20description=%22LEXF2C%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF2C%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/LEXF2C.minus.bw%20description=%22LEXF2C%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>

																													</TR>
																													<TR>
																														<TD>BUF/Mna <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BUF%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/BUF.plus.bw%20description=%22BUF%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BUF%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/BUF.minus.bw%20description=%22BUF%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
																														<TD>MWF/Hsd <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22MWF%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/MWF.plus.bw%20description=%22MWF%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22MWF%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/MWF.minus.bw%20description=%22MWF%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
																														<TD>BXH8/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH8%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/BXH8.plus.bw%20description=%22BHX8%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH8%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/BXH8.minus.bw%20description=%22BHX8%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>


																														<TD>HXB17/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB17%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/HBX17.plus.bw%20description=%22HXB17%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB17%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/HBX17.minus.bw%20description=%22HXB17%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
																														<TD>FXLE17/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22FXLE17%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/FXLE17.plus.bw%20description=%22FXLE17%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22FXLE17%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/FXLE17.minus.bw%20description=%22FXLE17%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
																														<TD>LEXF5/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF5%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/LEXF5.plus.bw%20description=%22LEXF5%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF5%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/LEXF5.minus.bw%20description=%22LEXF5%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>

																													</TR>
																													<TR>
																														<TD>COP/CrCrl <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22Cop%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/Cop.plus.bw%20description=%22Cop%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22Cop%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/Cop.minus.bw%20description=%22Cop%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
																														<TD>PVG/Seac <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22PVG%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/PVG.plus.bw%20description=%22PVG%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22PVG%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/PVG.minus.bw%20description=%22PVG%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
																														<TD>BXH9/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH9%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/BXH9.plus.bw%20description=%22BHX9%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH9%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/BXH9.minus.bw%20description=%22BHX9%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>


																														<TD>HXB18/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB18%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/HBX18.plus.bw%20description=%22HXB18%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB18%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/HBX18.minus.bw%20description=%22HXB18%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
																														<TD>FXLE18/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22FXLE18%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/FXLE18.plus.bw%20description=%22FXLE18%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22FXLE18%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/FXLE18.minus.bw%20description=%22FXLE18%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
																														<TD>LEXF6B/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF6B%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/LEXF6B.plus.bw%20description=%22LEXF6B%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF6B%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/LEXF6B.minus.bw%20description=%22LEXF6B%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>

																													</TR>
																													<TR>
																														<TD>DA/OlaHsd <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22DA%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/DA.plus.bw%20description=%22DA%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22DA%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/DA.minus.bw%20description=%22DA%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
																														<TD>SHR/OlaIpcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22SHR%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/SHR.plus.bw%20description=%22SHR%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=dense">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22SHR%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/SHR.minus.bw%20description=%22SHR%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=dense">- strand</a></TD>
																														<TD>BXH10/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH10%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/BXH10.plus.bw%20description=%22BHX10%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH10%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/BXH10.minus.bw%20description=%22BHX10%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>


																														<TD>HXB20/IpcvMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB20%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/HBX20.plus.bw%20description=%22HXB20%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB20%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/HBX20.minus.bw%20description=%22HXB20%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
																														<TD>FXLE20/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22FXLE20%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/FXLE20.plus.bw%20description=%22FXLE20%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22FXLE20%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/FXLE20.minus.bw%20description=%22FXLE20%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
																														<TD>LEXF7B/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF7B%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/LEXF7B.plus.bw%20description=%22LEXF7B%20Brain%20TotalRNA%20Plus%Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF7B%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/LEXF7B.minus.bw%20description=%22LEXF7B%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>

																													</TR>
																													<TR>
																														<TD>F344/NCrl <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22F344-NCl%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/F344-NCl.plus.bw%20description=%22F344-NCl%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22F344-NCl%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/F344-NCl.minus.bw%20description=%22F344-NCl%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
																														<TD>SHRSP/A3NCrl<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22SHRSP%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/SHRSP.plus.bw%20description=%22SHRSP%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22SHRSP%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/SHRSP.minus.bw%20description=%22SHRSP%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
																														<TD>BXH11/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH11%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/BXH11.plus.bw%20description=%22BHX11%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH11%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/BXH11.minus.bw%20description=%22BHX11%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22">- strand</a></TD>
																														<TD>HXB21/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB21%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/HBX21.plus.bw%20description=%22HXB21%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB21%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/HBX21.minus.bw%20description=%22HXB21%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>

																														<TD></TD>
																														<TD>LEXF8A/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF8A%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/LEXF8A.plus.bw%20description=%22LEXF8A%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF8A%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/LEXF8A.minus.bw%20description=%22LEXF8A%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>

																													</TR>
																													<TR>
																														<TD>F344/NHsd <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22F344-NHsd%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/F344-NHsd.plus.bw%20description=%22F344-NHsd%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22F344-NHsd%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/F344-NHsd.minus.bw%20description=%22F344-NHsd%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
																														<TD>SR/JrHsd <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22SR%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/SR.plus.bw%20description=%22SR%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22SR%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/SR.minus.bw%20description=%22SR%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
																														<TD>BXH12/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH12%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/BXH12.plus.bw%20description=%22BHX12%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH12%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/BXH12.minus.bw%20description=%22BHX12%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>


																														<TD>HXB22/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB22%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/HBX22.plus.bw%20description=%22HXB22%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB22%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/HBX22.minus.bw%20description=%22HXB22%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
																														<TD></TD>
																														<TD>LEXF9/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF9%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/LEXF9.plus.bw%20description=%22LEXF9%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF9%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/LEXF9.minus.bw%20description=%22LEXF9%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>

																													</TR>
																													<TR>
																														<TD>F344/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22F344-Stm%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/F344-Stm.plus.bw%20description=%22F344-Stm%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=dense">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22F344-Stm%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/F344-Stm.minus.bw%20description=%22F344-Stm%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=dense">- strand</a></TD>
																														<TD>SS/JrHsdMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22SS%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/SS.plus.bw%20description=%22SS%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22SS%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/SS.minus.bw%20description=%22SS%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
																														<TD>BXH13/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH13%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/BXH13.plus.bw%20description=%22BHX13%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH13%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/BXH13.minus.bw%20description=%22BHX13%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>


																														<TD>HXB23/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB23%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/HBX23.plus.bw%20description=%22HXB23%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB23%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/HBX23.minus.bw%20description=%22HXB23%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
																														<TD></TD>
																														<TD>LEXF10A/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF10A%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/LEXF10A.plus.bw%20description=%22LEXF10A%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF10A%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/LEXF10A.minus.bw%20description=%22LEXF10A%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>

																													</TR>
																													<TR>
																														<TD>FHH/EurMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22FHH%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/FHH.plus.bw%20description=%22FHH%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22FHH%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/FHH.minus.bw%20description=%22FHH%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
																														<TD>WAG/RijCrl <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22WAG%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/WAG.plus.bw%20description=%22WAG%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22WAG%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/WAG.minus.bw%20description=%22WAG%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
																														<TD>HXB1/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB1%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/HBX1.plus.bw%20description=%22HXB1%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB1%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/HBX1.minus.bw%20description=%22HXB1%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>


																														<TD>HXB24/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB24%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/HBX24.plus.bw%20description=%22HXB24%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB24%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/HBX24.minus.bw%20description=%22HXB24%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
																														<TD></TD>
																														<TD>LEXF10B/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF10B%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/LEXF10B.plus.bw%20description=%22LEXF10B%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF10B%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/LEXF10B.minus.bw%20description=%22LEXF10B%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>

																													</TR>
																													<TR>
																														<TD>GK/FarMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22GK%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/GK.plus.bw%20description=%22GK%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22GK%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/GK.minus.bw%20description=%22GK%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
																														<TD>WKY/NCrl <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22WKY%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/WKY.plus.bw%20description=%22WKY%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22WKY%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/WKY.minus.bw%20description=%22WKY%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
																														<TD>HXB2/IpcvMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB2%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/HBX2.plus.bw%20description=%22HXB2%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB2%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/HBX2.minus.bw%20description=%22HXB2%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>


																														<TD>HXB25/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB25%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/HBX25.plus.bw%20description=%22HXB25%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB25%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/HBX25.minus.bw%20description=%22HXB25%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
																														<TD></TD>
																														<TD>LEXF11/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF11%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/LEXF11.plus.bw%20description=%22LEXF11%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF11%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/LEXF11.minus.bw%20description=%22LEXF11%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
																													</TR>
																													<TR>
																														<TD>LE/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LE-Stm%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/LE-Stm.plus.bw%20description=%22LE-Stm%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=dense">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LE-Stm%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/LE-Stm.minus.bw%20description=%22LE-Stm%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=dense">- strand</a></TD>
																														<TD></TD>
																														<TD>HXB3/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB3%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/HBX3.plus.bw%20description=%22HXB3%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB3%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/HBX3.minus.bw%20description=%22HXB3%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
																														<TD>HXB27/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB27%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/HBX27.plus.bw%20description=%22HXB27%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB27%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/HBX27.minus.bw%20description=%22HXB27%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
																														<TD></TD>
																														<TD></TD>
																													</TR>
																													<TR>
																													<TD></TD>
																													<TD></TD>
																													<TD>HXB4/IpcvMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB4%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/HBX4.plus.bw%20description=%22HXB4%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB4%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/HBX4.minus.bw%20description=%22HXB4%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
																													<TD>HXB29/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB29%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/HBX29.plus.bw%20description=%22HXB29%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB29%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/HBX29.minus.bw%20description=%22HXB29%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
																													<TD></TD>
																													<TD></TD>
																													</TR>
																													<TR>
                                                                                                                    	<TD></TD>
                                                                                                                    	<TD></TD>
                                                                                                                    	<TD>HXB5/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB5%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/HBX5.plus.bw%20description=%22HXB5%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB5%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/HBX5.minus.bw%20description=%22HXB5%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                                    	<TD>HXB31/IpcvMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB31%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/HBX31.plus.bw%20description=%22HXB31%20Brain%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB31%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/sampled/HBX31.minus.bw%20description=%22HXB31%20Brain%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                                        <TD></TD>
                                                                                                                        <TD></TD>
                                                                                                                    </TR>
                                                                                									</tbody>
                                                                                									</table>
                                                                                								</div>
                                                                                                               <BR>
                            <a href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hubUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/hub.txt"
                               target="_blank">Liver Strain Specific Reads Counts (Sampled)</a> -
									<span name="liverCountSampv7" class="showTracks button" style="width:190px;">Show Individual Tracks</span><BR>
										  <div id="liverCountSampv7" style="display: none;">
												<table name="items" class="list_base  ucscTracks">
											<THEAD>
											<TR class="col_title">
												<TH colspan="2">Inbred Strains</TH>
												<TH colspan="2">HXB/BXH Strains</TH>
												<TH colspan="2">FXLE/LEXF Strains</TH>
											</TR>
											</THEAD>
												<tbody>
												<TR>
												<TD>ACI/EurMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22ACI%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/ACI.plus.bw%20description=%22ACI%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22ACI%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/ACI.minus.bw%20description=%22ACI%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
												<TD>LEW/Crl <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEW-NCrl%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/LEW-NCrl.plus.bw%20description=%22LEW-NCrl%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEW-NCrl%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/LEW-NCrl.minus.bw%20description=%22LEW-NCrl%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
												<TD>BXH2/CubMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH2%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/BXH2.plus.bw%20description=%22BHX2%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH2%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/BXH2.minus.bw%20description=%22BHX2%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
												<TD>HXB7/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB7%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/HBX7.plus.bw%20description=%22HXB7%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB7%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/HBX7.minus.bw%20description=%22HXB7%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
												<TD>FXLE12/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22FXLE12%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/FXLE12.plus.bw%20description=%22FXLE12%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22FXLE12%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/FXLE12.minus.bw%20description=%22FXLE12%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
												<TD>LEXF1C/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF1C%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/LEXF1C.plus.bw%20description=%22LEXF1C%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF1C%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/LEXF1C.minus.bw%20description=%22LEXF1C%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>

												</TR>
												<TR>
												<TD>BDIX/NemOda <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BDIX%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/BDIX.plus.bw%20description=%22BDIX%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BDIX%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/BDIX.minus.bw%20description=%22BDIX%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
												<TD>LEW/SsNHsd <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEW-SsNHsd%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/LEW-SsNHsd.plus.bw%20description=%22LEW-SsNHsd%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEW-SsNHsd%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/LEW-SsNHsd.minus.bw%20description=%22LEW-SsNHsd%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
												<TD>BXH3/CubMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH3%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/BXH3.plus.bw%20description=%22BHX3%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH3%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/BXH3.minus.bw%20description=%22BHX3%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
												<TD>HXB10/IpcvMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB10%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/HBX10.plus.bw%20description=%22HXB10%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB10%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/HBX10.minus.bw%20description=%22HXB10%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
												<TD>FXLE15/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22FXLE15%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/FXLE15.plus.bw%20description=%22FXLE15%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22FXLE15%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/FXLE15.minus.bw%20description=%22FXLE15%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
												<TD>LEXF5/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF5%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/LEXF5.plus.bw%20description=%22LEXF5%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF5%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/LEXF5.minus.bw%20description=%22LEXF5%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
												</TR>
												<TR>
												<TD>BN/NHsdMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BN%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/BN.plus.bw%20description=%22BN%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BN%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/BN.minus.bw%20description=%22BN%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
												<TD>LH/MavRrrc <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LH%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/LH.plus.bw%20description=%22LH%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LH%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/LH.minus.bw%20description=%22LH%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
												<TD>BXH5/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH5%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/BXH5.plus.bw%20description=%22BHX5%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH5%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/BXH5.minus.bw%20description=%22BHX5%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
												<TD>HXB13/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB13%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/HBX13.plus.bw%20description=%22HXB13%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB13%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/HBX13.minus.bw%20description=%22HXB13%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
												<TD>FXLE20/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22FXLE20%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/FXLE20.plus.bw%20description=%22FXLE20%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22FXLE20%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/FXLE20.minus.bw%20description=%22FXLE20%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>

												<TD>LEXF8A/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF8A%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/LEXF8A.plus.bw%20description=%22LEXF8A%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF8A%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/LEXF8A.minus.bw%20description=%22LEXF8A%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>

												</TR>
												<TR>
												<TD>BN-Lx/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BNLx%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/BNLx.plus.bw%20description=%22BNLx%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=dense">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BNLx%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/BNLx.minus.bw%20description=%22BNLx%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=dense">- strand</a></TD>
												<TD>M520/N <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22M520%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/M520.plus.bw%20description=%22M520%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22M520%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/M520.minus.bw%20description=%22M520%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
												<TD>BXH6/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH6%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/BXH6.plus.bw%20description=%22BHX6%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH6%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/BXH6.minus.bw%20description=%22BHX6%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
												<TD>HXB15/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB15%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/HBX15.plus.bw%20description=%22HXB15%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB15%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/HBX15.minus.bw%20description=%22HXB15%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
												<TD></TD>
												<TD>LEXF10A/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF10A%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/LEXF10A.plus.bw%20description=%22LEXF10A%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF10A%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/LEXF10A.minus.bw%20description=%22LEXF10A%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
											</TR>
											<TR>
												<TD>COP/CrCrl <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22Cop%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/Cop.plus.bw%20description=%22Cop%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22Cop%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/Cop.minus.bw%20description=%22Cop%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
												<TD>MWF/Hsd <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22MWF%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/MWF.plus.bw%20description=%22MWF%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22MWF%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/MWF.minus.bw%20description=%22MWF%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
												<TD>BXH8/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH8%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/BXH8.plus.bw%20description=%22BHX8%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH8%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/BXH8.minus.bw%20description=%22BHX8%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
												<TD>HXB17/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB17%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/HBX17.plus.bw%20description=%22HXB17%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB17%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/HBX17.minus.bw%20description=%22HXB17%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
												<TD></TD>
												<TD>LEXF10B/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF10B%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/LEXF10B.plus.bw%20description=%22LEXF10B%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF10B%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/LEXF10B.minus.bw%20description=%22LEXF10B%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
											</TR>
											<TR>
												<TD>DA/OlaHsd <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22DA%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/DA.plus.bw%20description=%22DA%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22DA%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/DA.minus.bw%20description=%22DA%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
												<TD>PVG/Seac <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22PVG%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/PVG.plus.bw%20description=%22PVG%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22PVG%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/PVG.minus.bw%20description=%22PVG%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
												<TD>BXH9/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH9%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/BXH9.plus.bw%20description=%22BHX9%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH9%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/BXH9.minus.bw%20description=%22BHX9%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
												<TD>HXB18/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB18%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/HBX18.plus.bw%20description=%22HXB18%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB18%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/HBX18.minus.bw%20description=%22HXB18%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
												<TD></TD>
												<TD></TD>
											</TR>
											<TR>
												<TD>F344/NCrl <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22F344-NCl%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/F344-NCl.plus.bw%20description=%22F344-NCl%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22F344-NCl%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/F344-NCl.minus.bw%20description=%22F344-NCl%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>

												<TD>SHR/OlaIpcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22SHR%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/SHR.plus.bw%20description=%22SHR%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=dense">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22SHR%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/SHR.minus.bw%20description=%22SHR%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=dense">- strand</a></TD>
												<TD>BXH10/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH10%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/BXH10.plus.bw%20description=%22BHX10%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH10%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/BXH10.minus.bw%20description=%22BHX10%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
												<TD>HXB20/IpcvMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB20%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/HBX20.plus.bw%20description=%22HXB20%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB20%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/HBX20.minus.bw%20description=%22HXB20%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
												<TD></TD>
												<TD></TD>
											</TR>
											<TR>
												<TD>F344/NHsd <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22F344-NHsd%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/F344-NHsd.plus.bw%20description=%22F344-NHsd%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22F344-NHsd%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/F344-NHsd.minus.bw%20description=%22F344-NHsd%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
												<TD>SHRSP/A3NCrl<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22SHRSP%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/SHRSP.plus.bw%20description=%22SHRSP%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22SHRSP%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/SHRSP.minus.bw%20description=%22SHRSP%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
												<TD>BXH11/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH11%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/BXH11.plus.bw%20description=%22BHX11%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH11%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/BXH11.minus.bw%20description=%22BHX11%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22">- strand</a></TD>
												<TD>HXB21/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB21%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/HBX21.plus.bw%20description=%22HXB21%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB21%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/HBX21.minus.bw%20description=%22HXB21%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>

												<TD></TD>
												<TD></TD>
											</TR>
											<TR>
												<TD>F344/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22F344-Stm%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/F344-Stm.plus.bw%20description=%22F344-Stm%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=dense">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22F344-Stm%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/F344-Stm.minus.bw%20description=%22F344-Stm%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=dense">- strand</a></TD>
												<TD>SR/JrHsd <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22SR%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/SR.plus.bw%20description=%22SR%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22SR%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/SR.minus.bw%20description=%22SR%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
												<TD>BXH12/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH12%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/BXH12.plus.bw%20description=%22BHX12%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH12%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/BXH12.minus.bw%20description=%22BHX12%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
												<TD>HXB22/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB22%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/HBX22.plus.bw%20description=%22HXB22%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB22%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/HBX22.minus.bw%20description=%22HXB22%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
												<TD></TD>
												<TD></TD>
											</TR>
											<TR>
												<TD>FHH/EurMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22FHH%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/FHH.plus.bw%20description=%22FHH%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22FHH%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/FHH.minus.bw%20description=%22FHH%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
												<TD>SS/JrHsdMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22SS%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/SS.plus.bw%20description=%22SS%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22SS%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/SS.minus.bw%20description=%22SS%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
												<TD>BXH13/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH13%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/BXH13.plus.bw%20description=%22BHX13%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH13%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/BXH13.minus.bw%20description=%22BHX13%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
												<TD>HXB23/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB23%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/HBX23.plus.bw%20description=%22HXB23%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB23%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/HBX23.minus.bw%20description=%22HXB23%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
												<TD></TD>
												<TD></TD>
											</TR>
											<TR>

												<TD>GK/FarMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22GK%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/GK.plus.bw%20description=%22GK%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22GK%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/GK.minus.bw%20description=%22GK%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>

												<TD>WAG/RijCrl <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22WAG%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/WAG.plus.bw%20description=%22WAG%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22WAG%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/WAG.minus.bw%20description=%22WAG%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
												<TD>HXB1/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB1%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/HBX1.plus.bw%20description=%22HXB1%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB1%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/HBX1.minus.bw%20description=%22HXB1%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>


												<TD>HXB24/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB24%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/HBX24.plus.bw%20description=%22HXB24%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB24%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/HBX24.minus.bw%20description=%22HXB24%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
												<TD></TD>
												<TD></TD>
											</TR>
											<TR>
												<TD>LE/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LE-Stm%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/LE-Stm.plus.bw%20description=%22LE-Stm%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=dense">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LE-Stm%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/LE-Stm.minus.bw%20description=%22LE-Stm%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=dense">- strand</a></TD>
												<TD>WKY/NCrl <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22WKY%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/WKY.plus.bw%20description=%22WKY%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22WKY%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/WKY.minus.bw%20description=%22WKY%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
												<TD>HXB2/IpcvMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB2%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/HBX2.plus.bw%20description=%22HXB2%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB2%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/HBX2.minus.bw%20description=%22HXB2%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>


												<TD>HXB25/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB25%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/HBX25.plus.bw%20description=%22HXB25%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB25%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/HBX25.minus.bw%20description=%22HXB25%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
												<TD></TD>
												<TD></TD>
																							</TR>
											<TR>
												<TD></TD>
												<TD></TD>
												<TD>HXB3/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB3%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/HBX3.plus.bw%20description=%22HXB3%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB3%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/HBX3.minus.bw%20description=%22HXB3%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
												<TD>HXB27/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB27%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/HBX27.plus.bw%20description=%22HXB27%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB27%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/HBX27.minus.bw%20description=%22HXB27%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
												<TD></TD>
												<TD></TD>
											</TR>
											<TR>
											<TD></TD>
											<TD></TD>
											<TD>HXB4/IpcvMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB4%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/HBX4.plus.bw%20description=%22HXB4%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB4%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/HBX4.minus.bw%20description=%22HXB4%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
											<TD>HXB29/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB29%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/HBX29.plus.bw%20description=%22HXB29%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB29%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/HBX29.minus.bw%20description=%22HXB29%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
											<TD></TD>
											<TD></TD>
											</TR>
											<TR>
												<TD></TD>
												<TD></TD>
												<TD>HXB5/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB5%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/HBX5.plus.bw%20description=%22HXB5%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB5%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/HBX5.minus.bw%20description=%22HXB5%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
												<TD>HXB31/IpcvMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB31%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/HBX31.plus.bw%20description=%22HXB31%20Liver%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB31%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/sampled/HBX31.minus.bw%20description=%22HXB31%20Liver%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
												   <TD></TD>
												   <TD></TD>
											   </TR>
											</tbody>
											</table>
										</div>
                               <BR><BR>
                            <a href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hubUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/sampled/hub.txt"
                               target="_blank">Heart Strain Specific Reads Counts (Sampled)</a>
                               - <span name="heartCountSampv7" class="showTracks button" style="width:190px;">Show Individual Tracks</span><BR>
                               										  <div id="heartCountSampv7" style="display: none;">
                               												<table name="items" class="list_base  ucscTracks">
                               											<THEAD>
                               											<TR class="col_title">
                               												<TH colspan="4">HXB/BXH Strains</TH>
                               											</TR>
                               											</THEAD>
                               											<tbody>
                               											<TR>
                               												<TD>BN-Lx/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BNLx%20Heart%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/sampled/BNLx.plus.bw%20description=%22BNLx%20Heart%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=dense">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BNLx%20Heart%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/sampled/BNLx.minus.bw%20description=%22BNLx%20Heart%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=dense">- strand</a></TD>
																			<TD>BXH9/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH9%20Heart%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/sampled/BXH9.plus.bw%20description=%22BHX9%20Heart%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH9%20Heart%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/sampled/BXH9.minus.bw%20description=%22BHX9%20Heart%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
																			<TD>HXB3/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB3%20Heart%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/sampled/HBX3.plus.bw%20description=%22HXB3%20Heart%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB3%20Heart%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/sampled/HBX3.minus.bw%20description=%22HXB3%20Heart%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                            <TD>HXB20/IpcvMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB20%20Heart%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/sampled/HBX20.plus.bw%20description=%22HXB20%20Heart%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB20%20Heart%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/sampled/HBX20.minus.bw%20description=%22HXB20%20Heart%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>

																		</TR>
                               											<TR>
                               												<TD>SHR/OlaIpcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22SHR%20Heart%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/sampled/SHR.plus.bw%20description=%22SHR%20Heart%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=dense">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22SHR%20Heart%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/sampled/SHR.minus.bw%20description=%22SHR%20Heart%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=dense">- strand</a></TD>
																			<TD>BXH10/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH10%20Heart%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/sampled/BXH10.plus.bw%20description=%22BHX10%20Heart%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH10%20Heart%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/sampled/BXH10.minus.bw%20description=%22BHX10%20Heart%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                            <TD>HXB5/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB5%20Heart%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/sampled/HBX5.plus.bw%20description=%22HXB5%20Heart%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB5%20Heart%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/sampled/HBX5.minus.bw%20description=%22HXB5%20Heart%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
              																<TD>HXB21/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB21%20Heart%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/sampled/HBX21.plus.bw%20description=%22HXB21%20Heart%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB21%20Heart%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/sampled/HBX21.minus.bw%20description=%22HXB21%20Heart%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>

                               											</TR>
                               											<TR>
                               												<TD>BXH2/CubMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH2%20Heart%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/sampled/BXH2.plus.bw%20description=%22BHX2%20Heart%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH2%20Heart%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/sampled/BXH2.minus.bw%20description=%22BHX2%20Heart%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
																			<TD>BXH11/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH11%20Heart%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/sampled/BXH11.plus.bw%20description=%22BHX11%20Heart%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH11%20Heart%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/sampled/BXH11.minus.bw%20description=%22BHX11%20Heart%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22">- strand</a></TD>
                                                                            <TD>HXB7/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB7%20Heart%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/sampled/HBX7.plus.bw%20description=%22HXB7%20Heart%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB7%20Heart%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/sampled/HBX7.minus.bw%20description=%22HXB7%20Heart%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                             <TD>HXB24/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB24%20Heart%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/sampled/HBX24.plus.bw%20description=%22HXB24%20Heart%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB24%20Heart%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/sampled/HBX24.minus.bw%20description=%22HXB24%20Heart%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>

                               											</TR>
                               											<TR>
                               												<TD>BXH5/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH5%20Heart%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/sampled/BXH5.plus.bw%20description=%22BHX5%20Heart%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH5%20Heart%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/sampled/BXH5.minus.bw%20description=%22BHX5%20Heart%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
																			<TD>BXH12/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH12%20Heart%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/sampled/BXH12.plus.bw%20description=%22BHX12%20Heart%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH12%20Heart%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/sampled/BXH12.minus.bw%20description=%22BHX12%20Heart%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                            <TD>HXB13/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB13%20Heart%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/sampled/HBX13.plus.bw%20description=%22HXB13%20Heart%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB13%20Heart%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/sampled/HBX13.minus.bw%20description=%22HXB13%20Heart%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                            <TD>HXB25/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB25%20Heart%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/sampled/HBX25.plus.bw%20description=%22HXB25%20Heart%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB25%20Heart%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/sampled/HBX25.minus.bw%20description=%22HXB25%20Heart%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>


                               											</TR>

                               											<TR>
                               												<TD>BXH6/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH6%20Heart%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/sampled/BXH6.plus.bw%20description=%22BHX6%20Heart%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH6%20Heart%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/sampled/BXH6.minus.bw%20description=%22BHX6%20Heart%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                               												<TD>HXB1/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB1%20Heart%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/sampled/HBX1.plus.bw%20description=%22HXB1%20Heart%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB1%20Heart%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/sampled/HBX1.minus.bw%20description=%22HXB1%20Heart%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                               												<TD>HXB17/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB17%20Heart%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/sampled/HBX17.plus.bw%20description=%22HXB17%20Heart%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB17%20Heart%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/sampled/HBX17.minus.bw%20description=%22HXB17%20Heart%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                             <TD>HXB29/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB29%20Heart%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/sampled/HBX29.plus.bw%20description=%22HXB29%20Heart%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB29%20Heart%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/sampled/HBX29.minus.bw%20description=%22HXB29%20Heart%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>

                               											</TR>
                               											<TR>
                               												<TD>BXH8/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH8%20Heart%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/sampled/BXH8.plus.bw%20description=%22BHX8%20Heart%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH8%20Heart%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/sampled/BXH8.minus.bw%20description=%22BHX8%20Heart%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                               											</TR>

                               											
                               											</tbody>
                               											</table>
                               										</div>
                                <BR><BR>
                            <a href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hubUrl=https://phenogen.org/public_ucsc/rn7/v7/kidney/sampled/hub.txt"
                               target="_blank">Kidney Strain Specific Reads Counts (Sampled)</a> -
                                    <span name="kidneyCountSampv7" class="showTracks button" style="width:190px;">Show Individual Tracks</span><BR>
								  <div id="kidneyCountSampv7" style="display: none;">
										<table name="items" class="list_base  ucscTracks">
									<THEAD>
									<TR class="col_title">
										<TH colspan="4">HXB/BXH Strains</TH>
									</TR>
									</THEAD>
										<tbody>
										<TR>
										<TD>BN-Lx/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BNLx%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/BNLx.plus.bw%20description=%22BNLx%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=dense">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BNLx%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/BNLx.minus.bw%20description=%22BNLx%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=dense">- strand</a></TD>
										<TD>BXH11/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH11%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/BXH11.plus.bw%20description=%22BHX11%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH11%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/BXH11.minus.bw%20description=%22BHX11%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22">- strand</a></TD>
										<TD>HXB7/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB7%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/HBX7.plus.bw%20description=%22HXB7%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB7%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/HBX7.minus.bw%20description=%22HXB7%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
										<TD>HXB23/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB23%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/HBX23.plus.bw%20description=%22HXB23%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB23%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/HBX23.minus.bw%20description=%22HXB23%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>

									</TR>
									<TR>
										<TD>SHR/OlaIpcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22SHR%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/SHR.plus.bw%20description=%22SHR%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=dense">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22SHR%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/SHR.minus.bw%20description=%22SHR%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=dense">- strand</a></TD>
                                        <TD>BXH12/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH12%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/BXH12.plus.bw%20description=%22BHX12%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH12%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/BXH12.minus.bw%20description=%22BHX12%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                        <TD>HXB10/IpcvMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB10%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/HBX10.plus.bw%20description=%22HXB10%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB10%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/HBX10.minus.bw%20description=%22HXB10%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                        <TD>HXB24/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB24%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/HBX24.plus.bw%20description=%22HXB24%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB24%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/HBX24.minus.bw%20description=%22HXB24%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>

										</TR>
									<TR>
										<TD>BXH2/CubMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH2%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/BXH2.plus.bw%20description=%22BHX2%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH2%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/BXH2.minus.bw%20description=%22BHX2%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                        <TD>BXH13/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH13%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/BXH13.plus.bw%20description=%22BHX13%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH13%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/BXH13.minus.bw%20description=%22BHX13%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                        <TD>HXB13/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB13%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/HBX13.plus.bw%20description=%22HXB13%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB13%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/HBX13.minus.bw%20description=%22HXB13%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
							            <TD>HXB25/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB25%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/HBX25.plus.bw%20description=%22HXB25%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB25%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/HBX25.minus.bw%20description=%22HXB25%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>

									</TR>
									<TR>
										<TD>BXH3/CubMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH3%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/BXH3.plus.bw%20description=%22BHX3%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH3%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/BXH3.minus.bw%20description=%22BHX3%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
										<TD>HXB1/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB1%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/HBX1.plus.bw%20description=%22HXB1%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB1%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/HBX1.minus.bw%20description=%22HXB1%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
										<TD>HXB15/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB15%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/HBX15.plus.bw%20description=%22HXB15%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB15%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/HBX15.minus.bw%20description=%22HXB15%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
										<TD>HXB27/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB27%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/HBX27.plus.bw%20description=%22HXB27%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB27%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/HBX27.minus.bw%20description=%22HXB27%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>

										</TR>
									<TR>
										<TD>BXH6/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH6%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/BXH6.plus.bw%20description=%22BHX6%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH6%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/BXH6.minus.bw%20description=%22BHX6%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
										<TD>HXB2/IpcvMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB2%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/HBX2.plus.bw%20description=%22HXB2%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB2%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/HBX2.minus.bw%20description=%22HXB2%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                        <TD>HXB17/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB17%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/HBX17.plus.bw%20description=%22HXB17%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB17%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/HBX17.minus.bw%20description=%22HXB17%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                        <TD>HXB29/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB29%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/HBX29.plus.bw%20description=%22HXB29%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB29%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/HBX29.minus.bw%20description=%22HXB29%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>

									</TR>
									<TR>
										<TD>BXH8/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH8%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/BXH8.plus.bw%20description=%22BHX8%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH8%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/BXH8.minus.bw%20description=%22BHX8%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                        <TD>HXB3/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB3%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/HBX3.plus.bw%20description=%22HXB3%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB3%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/HBX3.minus.bw%20description=%22HXB3%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                        <TD>HXB18/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB18%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/HBX18.plus.bw%20description=%22HXB18%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB18%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/HBX18.minus.bw%20description=%22HXB18%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
								         <TD>HXB31/IpcvMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB31%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/HBX31.plus.bw%20description=%22HXB31%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB31%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/HBX31.minus.bw%20description=%22HXB31%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                    </TR>
									<TR>
										<TD>BXH9/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH9%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/BXH9.plus.bw%20description=%22BHX9%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH9%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/BXH9.minus.bw%20description=%22BHX9%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
										<TD>HXB4/IpcvMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB4%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/HBX4.plus.bw%20description=%22HXB4%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB4%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/HBX4.minus.bw%20description=%22HXB4%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
										<TD>HXB21/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB21%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/HBX21.plus.bw%20description=%22HXB21%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB21%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/HBX21.minus.bw%20description=%22HXB21%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
										<TD></TD>
									</TR>
									<TR>
										<TD>BXH10/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH10%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/BXH10.plus.bw%20description=%22BHX10%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH10%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/BXH10.minus.bw%20description=%22BHX10%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
										<TD>HXB5/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB5%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/HBX5.plus.bw%20description=%22HXB5%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB5%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/HBX5.minus.bw%20description=%22HXB5%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
										<TD>HXB22/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB22%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/HBX22.plus.bw%20description=%22HXB22%20Kidney%20TotalRNA%20Plus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB22%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/sampled/HBX22.minus.bw%20description=%22HXB22%20Kidney%20TotalRNA%20Minus%20Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                        <TD></TD>
									</TR>
									</tbody>
									</table>
								</div>
                               <BR><BR>
                        </div>
                <BR>
                <H2>Strain/Tissue Specific Read Counts (Total):</H2>
                <div style="text-align: center;">Not sampled: Each strain contains the total reads from all 3 biological replicates.</div>
				<BR>
				<div>
                            <a href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hubUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/hub.txt"
                               target="_blank">Whole Brain Strain Specific Reads Counts (Total/Not Sampled)</a> - <span name="brainCountTotalv7" class="showTracks button" style="width:190px;">Show Individual Tracks</span><BR>
                                                                                                                                                                                                                               <div id="brainCountTotalv7" style="display: none;">
                                                                                                                                                                                                                               		<table name="items" class="list_base ucscTracks">
                                                                                                                																													<THEAD>
                                                                                                                																													<TR class="col_title">
                                                                                                                																														<TH colspan="2">Inbred Strains</TH>
                                                                                                                																														<TH colspan="2">HXB/BXH Strains</TH>
                                                                                                                																														<TH colspan="2">FXLE/LEXF Strains</TH>
                                                                                                                																													</TR>
                                                                                                                																													</THEAD>
                                                                                                                                                                                                                               		<tbody>
                                                                                                                                                                                                                               		<TR>
                                                                                                                                                                                                                               		<TD>ACI/EurMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22ACI%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/ACI.plus.bw%20description=%22ACI%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22ACI%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/ACI.minus.bw%20description=%22ACI%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                                                                                                                                               		<TD>LEW/Crl <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEW-NCrl%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/LEW-NCrl.plus.bw%20description=%22LEW-NCrl%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEW-NCrl%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/LEW-NCrl.minus.bw%20description=%22LEW-NCrl%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                                                                                                                                               		<TD>BXH2/CubMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH2%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/BXH2.plus.bw%20description=%22BHX2%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH2%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/BXH2.minus.bw%20description=%22BHX2%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                                                                                                                                               		<TD>HXB7/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB7%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/HBX7.plus.bw%20description=%22HXB7%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB7%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/HBX7.minus.bw%20description=%22HXB7%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                                                                                                                                               		<TD>FXLE12/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22FXLE12%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/FXLE12.plus.bw%20description=%22FXLE12%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22FXLE12%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/FXLE12.minus.bw%20description=%22FXLE12%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                                                                                                                                               		<TD>LEXF1A/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF1A%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/LEXF1A.plus.bw%20description=%22LEXF1A%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF1A%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/LEXF1A.minus.bw%20description=%22LEXF1A%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                                                                                                                                               		</TR>
                                                                                                                                                                                                                               		<TR>
                                                                                                                                                                                                                               		<TD>BDIX/NemOda <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BDIX%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/BDIX.plus.bw%20description=%22BDIX%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BDIX%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/BDIX.minus.bw%20description=%22BDIX%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                                                                                                                                               		<TD>LEW/SsNHsd <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEW-SsNHsd%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/LEW-SsNHsd.plus.bw%20description=%22LEW-SsNHsd%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEW-SsNHsd%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/LEW-SsNHsd.minus.bw%20description=%22LEW-SsNHsd%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                                                                                                                                               		<TD>BXH3/CubMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH3%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/BXH3.plus.bw%20description=%22BHX3%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH3%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/BXH3.minus.bw%20description=%22BHX3%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>

                                                                                                                                                                                                                               		<TD>HXB10/IpcvMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB10%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/HBX10.plus.bw%20description=%22HXB10%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB10%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/HBX10.minus.bw%20description=%22HXB10%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                                                                                                                                               		<TD>FXLE13/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22FXLE13%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/FXLE13.plus.bw%20description=%22FXLE13%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22FXLE13%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/FXLE13.minus.bw%20description=%22FXLE13%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a> </TD>

                                                                                                                                                                                                                               		<TD>LEXF1C/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF1C%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/LEXF1C.plus.bw%20description=%22LEXF1C%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF1C%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/LEXF1C.minus.bw%20description=%22LEXF1C%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                                                                                                                                               		</TR>
                                                                                                                                                                                                                               		<TR>
                                                                                                                                                                                                                               		<TD>BN/NHsdMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BN%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/BN.plus.bw%20description=%22BN%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BN%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/BN.minus.bw%20description=%22BN%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                                                                                                                                               		<TD>LH/MavRrrc <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LH%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/LH.plus.bw%20description=%22LH%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LH%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/LH.minus.bw%20description=%22LH%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                                                                                                                                               		<TD>BXH5/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH5%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/BXH5.plus.bw%20description=%22BHX5%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH5%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/BXH5.minus.bw%20description=%22BHX5%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>


                                                                                                                                                                                                                               		<TD>HXB13/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB13%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/HBX13.plus.bw%20description=%22HXB13%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB13%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/HBX13.minus.bw%20description=%22HXB13%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                                                                                                                                               		<TD>FXLE14/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22FXLE14%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/FXLE14.plus.bw%20description=%22FXLE14%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22FXLE14%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/FXLE14.minus.bw%20description=%22FXLE14%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                                                                                                                                               		<TD>LEXF2B/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF2B%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/LEXF2B.plus.bw%20description=%22LEXF2B%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF2B%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/LEXF2B.minus.bw%20description=%22LEXF2B%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                                                                                                                                               		</TR>
                                                                                                                                                                                                                               		<TR>
                                                                                                                																													<TD>BN-Lx/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BNLx%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/BNLx.plus.bw%20description=%22BNLx%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=dense">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BNLx%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/BNLx.minus.bw%20description=%22BNLx%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=dense">- strand</a></TD>
                                                                                                                																													<TD>M520/N <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22M520%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/M520.plus.bw%20description=%22M520%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22M520%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/M520.minus.bw%20description=%22M520%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                                																													<TD>BXH6/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH6%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/BXH6.plus.bw%20description=%22BHX6%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH6%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/BXH6.minus.bw%20description=%22BHX6%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                                																													<TD>HXB15/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB15%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/HBX15.plus.bw%20description=%22HXB15%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB15%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/HBX15.minus.bw%20description=%22HXB15%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>

                                                                                                                																													<TD>FXLE15/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22FXLE15%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/FXLE15.plus.bw%20description=%22FXLE15%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22FXLE15%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/FXLE15.minus.bw%20description=%22FXLE15%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                                																													<TD>LEXF2C/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF2C%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/LEXF2C.plus.bw%20description=%22LEXF2C%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF2C%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/LEXF2C.minus.bw%20description=%22LEXF2C%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>

                                                                                                                																													</TR>
                                                                                                                																													<TR>
                                                                                                                																														<TD>BUF/Mna <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BUF%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/BUF.plus.bw%20description=%22BUF%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BUF%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/BUF.minus.bw%20description=%22BUF%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                                																														<TD>MWF/Hsd <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22MWF%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/MWF.plus.bw%20description=%22MWF%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22MWF%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/MWF.minus.bw%20description=%22MWF%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                                																														<TD>BXH8/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH8%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/BXH8.plus.bw%20description=%22BHX8%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH8%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/BXH8.minus.bw%20description=%22BHX8%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>


                                                                                                                																														<TD>HXB17/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB17%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/HBX17.plus.bw%20description=%22HXB17%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB17%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/HBX17.minus.bw%20description=%22HXB17%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                                																														<TD>FXLE17/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22FXLE17%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/FXLE17.plus.bw%20description=%22FXLE17%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22FXLE17%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/FXLE17.minus.bw%20description=%22FXLE17%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                                																														<TD>LEXF5/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF5%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/LEXF5.plus.bw%20description=%22LEXF5%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF5%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/LEXF5.minus.bw%20description=%22LEXF5%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>

                                                                                                                																													</TR>
                                                                                                                																													<TR>
                                                                                                                																														<TD>COP/CrCrl <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22Cop%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/Cop.plus.bw%20description=%22Cop%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22Cop%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/Cop.minus.bw%20description=%22Cop%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                                																														<TD>PVG/Seac <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22PVG%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/PVG.plus.bw%20description=%22PVG%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22PVG%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/PVG.minus.bw%20description=%22PVG%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                                																														<TD>BXH9/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH9%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/BXH9.plus.bw%20description=%22BHX9%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH9%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/BXH9.minus.bw%20description=%22BHX9%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>


                                                                                                                																														<TD>HXB18/Ipcv<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB18%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/HBX18.plus.bw%20description=%22HXB18%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB18%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/HBX18.minus.bw%20description=%22HXB18%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                                																														<TD>FXLE18/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22FXLE18%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/FXLE18.plus.bw%20description=%22FXLE18%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22FXLE18%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/FXLE18.minus.bw%20description=%22FXLE18%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                                																														<TD>LEXF6B/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF6B%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/LEXF6B.plus.bw%20description=%22LEXF6B%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF6B%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/LEXF6B.minus.bw%20description=%22LEXF6B%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>

                                                                                                                																													</TR>
                                                                                                                																													<TR>
                                                                                                                																														<TD>DA/OlaHsd <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22DA%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/DA.plus.bw%20description=%22DA%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22DA%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/DA.minus.bw%20description=%22DA%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                                																														<TD>SHR/OlaIpcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22SHR%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/SHR.plus.bw%20description=%22SHR%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=dense">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22SHR%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/SHR.minus.bw%20description=%22SHR%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=dense">- strand</a></TD>
                                                                                                                																														<TD>BXH10/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH10%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/BXH10.plus.bw%20description=%22BHX10%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH10%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/BXH10.minus.bw%20description=%22BHX10%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>


                                                                                                                																														<TD>HXB20/IpcvMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB20%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/HBX20.plus.bw%20description=%22HXB20%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB20%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/HBX20.minus.bw%20description=%22HXB20%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                                																														<TD>FXLE20/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22FXLE20%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/FXLE20.plus.bw%20description=%22FXLE20%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22FXLE20%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/FXLE20.minus.bw%20description=%22FXLE20%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                                																														<TD>LEXF7B/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF7B%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/LEXF7B.plus.bw%20description=%22LEXF7B%20Brain%20TotalRNA%20Plus%Sampled%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF7B%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/LEXF7B.minus.bw%20description=%22LEXF7B%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>

                                                                                                                																													</TR>
                                                                                                                																													<TR>
                                                                                                                																														<TD>F344/NCrl <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22F344-NCl%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/F344-NCl.plus.bw%20description=%22F344-NCl%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22F344-NCl%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/F344-NCl.minus.bw%20description=%22F344-NCl%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                                																														<TD>SHRSP/A3NCrl<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22SHRSP%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/SHRSP.plus.bw%20description=%22SHRSP%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22SHRSP%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/SHRSP.minus.bw%20description=%22SHRSP%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                                																														<TD>BXH11/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH11%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/BXH11.plus.bw%20description=%22BHX11%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH11%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/BXH11.minus.bw%20description=%22BHX11%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22">- strand</a></TD>
                                                                                                                																														<TD>HXB21/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB21%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/HBX21.plus.bw%20description=%22HXB21%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB21%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/HBX21.minus.bw%20description=%22HXB21%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>

                                                                                                                																														<TD></TD>
                                                                                                                																														<TD>LEXF8A/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF8A%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/LEXF8A.plus.bw%20description=%22LEXF8A%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF8A%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/LEXF8A.minus.bw%20description=%22LEXF8A%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>

                                                                                                                																													</TR>
                                                                                                                																													<TR>
                                                                                                                																														<TD>F344/NHsd <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22F344-NHsd%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/F344-NHsd.plus.bw%20description=%22F344-NHsd%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22F344-NHsd%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/F344-NHsd.minus.bw%20description=%22F344-NHsd%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                                																														<TD>SR/JrHsd <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22SR%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/SR.plus.bw%20description=%22SR%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22SR%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/SR.minus.bw%20description=%22SR%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                                																														<TD>BXH12/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH12%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/BXH12.plus.bw%20description=%22BHX12%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH12%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/BXH12.minus.bw%20description=%22BHX12%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>


                                                                                                                																														<TD>HXB22/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB22%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/HBX22.plus.bw%20description=%22HXB22%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB22%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/HBX22.minus.bw%20description=%22HXB22%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                                																														<TD></TD>
                                                                                                                																														<TD>LEXF9/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF9%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/LEXF9.plus.bw%20description=%22LEXF9%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF9%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/LEXF9.minus.bw%20description=%22LEXF9%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>

                                                                                                                																													</TR>
                                                                                                                																													<TR>
                                                                                                                																														<TD>F344/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22F344-Stm%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/F344-Stm.plus.bw%20description=%22F344-Stm%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=dense">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22F344-Stm%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/F344-Stm.minus.bw%20description=%22F344-Stm%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=dense">- strand</a></TD>
                                                                                                                																														<TD>SS/JrHsdMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22SS%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/SS.plus.bw%20description=%22SS%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22SS%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/SS.minus.bw%20description=%22SS%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                                																														<TD>BXH13/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH13%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/BXH13.plus.bw%20description=%22BHX13%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH13%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/BXH13.minus.bw%20description=%22BHX13%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>


                                                                                                                																														<TD>HXB23/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB23%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/HBX23.plus.bw%20description=%22HXB23%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB23%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/HBX23.minus.bw%20description=%22HXB23%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                                																														<TD></TD>
                                                                                                                																														<TD>LEXF10A/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF10A%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/LEXF10A.plus.bw%20description=%22LEXF10A%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF10A%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/LEXF10A.minus.bw%20description=%22LEXF10A%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>

                                                                                                                																													</TR>
                                                                                                                																													<TR>
                                                                                                                																														<TD>FHH/EurMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22FHH%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/FHH.plus.bw%20description=%22FHH%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22FHH%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/FHH.minus.bw%20description=%22FHH%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                                																														<TD>WAG/RijCrl <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22WAG%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/WAG.plus.bw%20description=%22WAG%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22WAG%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/WAG.minus.bw%20description=%22WAG%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                                																														<TD>HXB1/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB1%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/HBX1.plus.bw%20description=%22HXB1%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB1%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/HBX1.minus.bw%20description=%22HXB1%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>


                                                                                                                																														<TD>HXB24/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB24%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/HBX24.plus.bw%20description=%22HXB24%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB24%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/HBX24.minus.bw%20description=%22HXB24%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                                																														<TD></TD>
                                                                                                                																														<TD>LEXF10B/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF10B%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/LEXF10B.plus.bw%20description=%22LEXF10B%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF10B%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/LEXF10B.minus.bw%20description=%22LEXF10B%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>

                                                                                                                																													</TR>
                                                                                                                																													<TR>
                                                                                                                																														<TD>GK/FarMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22GK%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/GK.plus.bw%20description=%22GK%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22GK%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/GK.minus.bw%20description=%22GK%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                                																														<TD>WKY/NCrl <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22WKY%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/WKY.plus.bw%20description=%22WKY%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22WKY%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/WKY.minus.bw%20description=%22WKY%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                                																														<TD>HXB2/IpcvMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB2%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/HBX2.plus.bw%20description=%22HXB2%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB2%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/HBX2.minus.bw%20description=%22HXB2%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>


                                                                                                                																														<TD>HXB25/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB25%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/HBX25.plus.bw%20description=%22HXB25%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB25%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/HBX25.minus.bw%20description=%22HXB25%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                                																														<TD></TD>
                                                                                                                																														<TD>LEXF11/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF11%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/LEXF11.plus.bw%20description=%22LEXF11%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF11%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/LEXF11.minus.bw%20description=%22LEXF11%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                                																													</TR>
                                                                                                                																													<TR>
                                                                                                                																														<TD>LE/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LE-Stm%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/LE-Stm.plus.bw%20description=%22LE-Stm%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=dense">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LE-Stm%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/LE-Stm.minus.bw%20description=%22LE-Stm%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=dense">- strand</a></TD>
                                                                                                                																														<TD></TD>
                                                                                                                																														<TD>HXB3/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB3%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/HBX3.plus.bw%20description=%22HXB3%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB3%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/HBX3.minus.bw%20description=%22HXB3%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>


                                                                                                                																														<TD>HXB27/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB27%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/HBX27.plus.bw%20description=%22HXB27%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB27%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/HBX27.minus.bw%20description=%22HXB27%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                                																														<TD></TD>
                                                                                                                																														<TD></TD>
                                                                                                                																													</TR>
                                                                                                                																													<TR>
                                                                                                                																													<TD></TD>
                                                                                                                																													<TD></TD>
                                                                                                                																													<TD>HXB4/IpcvMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB4%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/HBX4.plus.bw%20description=%22HXB4%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB4%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/HBX4.minus.bw%20description=%22HXB4%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                                																													<TD>HXB29/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB29%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/HBX29.plus.bw%20description=%22HXB29%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB29%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/HBX29.minus.bw%20description=%22HXB29%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                                																													<TD></TD>
                                                                                                                																													</TR>
                                                                                                                																													<TR>
                                                                                                                                                                                                                                    	<TD></TD>
                                                                                                                                                                                                                                    	<TD></TD>
                                                                                                                                                                                                                                    	<TD>HXB5/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB5%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/HBX5.plus.bw%20description=%22HXB5%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB5%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/HBX5.minus.bw%20description=%22HXB5%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                                                                                                                                                    	<TD>HXB31/IpcvMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB31%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/HBX31.plus.bw%20description=%22HXB31%20Brain%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB31%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/brain/total/HBX31.minus.bw%20description=%22HXB31%20Brain%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                                                                                                                                                                                        <TD></TD>
                                                                                                                                                                                                                                        <TD></TD>
                                                                                                                                                                                                                                    </TR>
                                                                                                                                                                                                									</tbody>
                                                                                                                                                                                                									</table>
                                                                                                                                                                                                								</div>
                                <BR><BR>
                            <a href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hubUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/hub.txt"
                               target="_blank">Liver Strain Specific Reads Counts (Total/Not Sampled)</a>
                                -
                               									<span name="liverCountTotalv7" class="showTracks button" style="width:190px;">Show Individual Tracks</span><BR>
                               										  <div id="liverCountTotalv7" style="display: none;">
                               												<table name="items" class="list_base ucscTracks">
                               											<THEAD>
                               											<TR class="col_title">
                               												<TH colspan="2">Inbred Strains</TH>
                               												<TH colspan="2">HXB/BXH Strains</TH>
                               												<TH colspan="2">FXLE/LEXF Strains</TH>
                               											</TR>
                               											</THEAD>
                               												<tbody>
                               												<TR>
                               												<TD>ACI/EurMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22ACI%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/ACI.plus.bw%20description=%22ACI%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22ACI%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/ACI.minus.bw%20description=%22ACI%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                               												<TD>LEW/Crl <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEW-NCrl%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/LEW-NCrl.plus.bw%20description=%22LEW-NCrl%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEW-NCrl%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/LEW-NCrl.minus.bw%20description=%22LEW-NCrl%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                               												<TD>BXH2/CubMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH2%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/BXH2.plus.bw%20description=%22BHX2%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH2%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/BXH2.minus.bw%20description=%22BHX2%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                               												<TD>HXB7/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB7%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/HBX7.plus.bw%20description=%22HXB7%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB7%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/HBX7.minus.bw%20description=%22HXB7%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                               												<TD>FXLE12/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22FXLE12%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/FXLE12.plus.bw%20description=%22FXLE12%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22FXLE12%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/FXLE12.minus.bw%20description=%22FXLE12%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                               												<TD>LEXF1C/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF1C%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/LEXF1C.plus.bw%20description=%22LEXF1C%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF1C%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/LEXF1C.minus.bw%20description=%22LEXF1C%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>

                               												</TR>
                               												<TR>
                               												<TD>BDIX/NemOda <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BDIX%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/BDIX.plus.bw%20description=%22BDIX%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BDIX%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/BDIX.minus.bw%20description=%22BDIX%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                               												<TD>LEW/SsNHsd <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEW-SsNHsd%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/LEW-SsNHsd.plus.bw%20description=%22LEW-SsNHsd%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEW-SsNHsd%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/LEW-SsNHsd.minus.bw%20description=%22LEW-SsNHsd%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                               												<TD>BXH3/CubMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH3%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/BXH3.plus.bw%20description=%22BHX3%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH3%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/BXH3.minus.bw%20description=%22BHX3%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                               												<TD>HXB10/IpcvMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB10%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/HBX10.plus.bw%20description=%22HXB10%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB10%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/HBX10.minus.bw%20description=%22HXB10%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                               												<TD>FXLE15/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22FXLE15%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/FXLE15.plus.bw%20description=%22FXLE15%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22FXLE15%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/FXLE15.minus.bw%20description=%22FXLE15%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                               												<TD>LEXF5/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF5%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/LEXF5.plus.bw%20description=%22LEXF5%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF5%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/LEXF5.minus.bw%20description=%22LEXF5%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                               												</TR>
                               												<TR>
                               												<TD>BN/NHsdMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BN%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/BN.plus.bw%20description=%22BN%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BN%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/BN.minus.bw%20description=%22BN%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                               												<TD>LH/MavRrrc <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LH%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/LH.plus.bw%20description=%22LH%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LH%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/LH.minus.bw%20description=%22LH%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                               												<TD>BXH5/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH5%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/BXH5.plus.bw%20description=%22BHX5%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH5%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/BXH5.minus.bw%20description=%22BHX5%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                               												<TD>HXB13/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB13%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/HBX13.plus.bw%20description=%22HXB13%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB13%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/HBX13.minus.bw%20description=%22HXB13%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                               												<TD>FXLE20/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22FXLE20%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/FXLE20.plus.bw%20description=%22FXLE20%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22FXLE20%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/FXLE20.minus.bw%20description=%22FXLE20%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>

                               												<TD>LEXF8A/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF8A%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/LEXF8A.plus.bw%20description=%22LEXF8A%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF8A%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/LEXF8A.minus.bw%20description=%22LEXF8A%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>

                               												</TR>
                               												<TR>
                               												<TD>BN-Lx/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BNLx%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/BNLx.plus.bw%20description=%22BNLx%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=dense">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BNLx%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/BNLx.minus.bw%20description=%22BNLx%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=dense">- strand</a></TD>
                               												<TD>M520/N <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22M520%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/M520.plus.bw%20description=%22M520%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22M520%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/M520.minus.bw%20description=%22M520%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                               												<TD>BXH6/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH6%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/BXH6.plus.bw%20description=%22BHX6%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH6%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/BXH6.minus.bw%20description=%22BHX6%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                               												<TD>HXB15/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB15%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/HBX15.plus.bw%20description=%22HXB15%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB15%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/HBX15.minus.bw%20description=%22HXB15%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                               												<TD></TD>
                               												<TD>LEXF10A/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF10A%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/LEXF10A.plus.bw%20description=%22LEXF10A%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF10A%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/LEXF10A.minus.bw%20description=%22LEXF10A%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                               											</TR>
                               											<TR>
                               												<TD>COP/CrCrl <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22Cop%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/Cop.plus.bw%20description=%22Cop%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22Cop%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/Cop.minus.bw%20description=%22Cop%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                               												<TD>MWF/Hsd <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22MWF%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/MWF.plus.bw%20description=%22MWF%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22MWF%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/MWF.minus.bw%20description=%22MWF%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                               												<TD>BXH8/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH8%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/BXH8.plus.bw%20description=%22BHX8%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH8%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/BXH8.minus.bw%20description=%22BHX8%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                               												<TD>HXB17/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB17%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/HBX17.plus.bw%20description=%22HXB17%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB17%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/HBX17.minus.bw%20description=%22HXB17%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                               												<TD></TD>
                               												<TD>LEXF10B/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF10B%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/LEXF10B.plus.bw%20description=%22LEXF10B%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LEXF10B%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/LEXF10B.minus.bw%20description=%22LEXF10B%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                               											</TR>
                               											<TR>
                               												<TD>DA/OlaHsd <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22DA%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/DA.plus.bw%20description=%22DA%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22DA%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/DA.minus.bw%20description=%22DA%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                               												<TD>PVG/Seac <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22PVG%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/PVG.plus.bw%20description=%22PVG%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22PVG%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/PVG.minus.bw%20description=%22PVG%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                               												<TD>BXH9/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH9%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/BXH9.plus.bw%20description=%22BHX9%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH9%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/BXH9.minus.bw%20description=%22BHX9%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                               												<TD>HXB18/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB18%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/HBX18.plus.bw%20description=%22HXB18%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB18%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/HBX18.minus.bw%20description=%22HXB18%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                               												<TD></TD>
                               												<TD></TD>
                               											</TR>
                               											<TR>
                               												<TD>F344/NCrl <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22F344-NCl%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/F344-NCl.plus.bw%20description=%22F344-NCl%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22F344-NCl%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/F344-NCl.minus.bw%20description=%22F344-NCl%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>

                               												<TD>SHR/OlaIpcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22SHR%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/SHR.plus.bw%20description=%22SHR%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=dense">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22SHR%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/SHR.minus.bw%20description=%22SHR%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=dense">- strand</a></TD>
                               												<TD>BXH10/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH10%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/BXH10.plus.bw%20description=%22BHX10%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH10%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/BXH10.minus.bw%20description=%22BHX10%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                               												<TD>HXB20/IpcvMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB20%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/HBX20.plus.bw%20description=%22HXB20%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB20%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/HBX20.minus.bw%20description=%22HXB20%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                               												<TD></TD>
                               												<TD></TD>
                               											</TR>
                               											<TR>
                               												<TD>F344/NHsd <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22F344-NHsd%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/F344-NHsd.plus.bw%20description=%22F344-NHsd%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22F344-NHsd%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/F344-NHsd.minus.bw%20description=%22F344-NHsd%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                               												<TD>SHRSP/A3NCrl<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22SHRSP%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/SHRSP.plus.bw%20description=%22SHRSP%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22SHRSP%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/SHRSP.minus.bw%20description=%22SHRSP%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                               												<TD>BXH11/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH11%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/BXH11.plus.bw%20description=%22BHX11%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH11%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/BXH11.minus.bw%20description=%22BHX11%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22">- strand</a></TD>
                               												<TD>HXB21/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB21%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/HBX21.plus.bw%20description=%22HXB21%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB21%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/HBX21.minus.bw%20description=%22HXB21%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>

                               												<TD></TD>
                               												<TD></TD>
                               											</TR>
                               											<TR>
                               												<TD>F344/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22F344-Stm%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/F344-Stm.plus.bw%20description=%22F344-Stm%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=dense">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22F344-Stm%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/F344-Stm.minus.bw%20description=%22F344-Stm%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=dense">- strand</a></TD>
                               												<TD>SR/JrHsd <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22SR%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/SR.plus.bw%20description=%22SR%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22SR%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/SR.minus.bw%20description=%22SR%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                               												<TD>BXH12/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH12%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/BXH12.plus.bw%20description=%22BHX12%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH12%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/BXH12.minus.bw%20description=%22BHX12%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                               												<TD>HXB22/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB22%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/HBX22.plus.bw%20description=%22HXB22%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB22%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/HBX22.minus.bw%20description=%22HXB22%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                               												<TD></TD>
                               												<TD></TD>
                               											</TR>
                               											<TR>
                               												<TD>FHH/EurMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22FHH%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/FHH.plus.bw%20description=%22FHH%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22FHH%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/FHH.minus.bw%20description=%22FHH%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                               												<TD>SS/JrHsdMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22SS%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/SS.plus.bw%20description=%22SS%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22SS%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/SS.minus.bw%20description=%22SS%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                               												<TD>BXH13/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH13%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/BXH13.plus.bw%20description=%22BHX13%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH13%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/BXH13.minus.bw%20description=%22BHX13%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                               												<TD>HXB23/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB23%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/HBX23.plus.bw%20description=%22HXB23%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB23%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/HBX23.minus.bw%20description=%22HXB23%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                               												<TD></TD>
                               												<TD></TD>
                               											</TR>
                               											<TR>

                               												<TD>GK/FarMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22GK%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/GK.plus.bw%20description=%22GK%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22GK%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/GK.minus.bw%20description=%22GK%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>

                               												<TD>WAG/RijCrl <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22WAG%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/WAG.plus.bw%20description=%22WAG%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22WAG%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/WAG.minus.bw%20description=%22WAG%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                               												<TD>HXB1/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB1%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/HBX1.plus.bw%20description=%22HXB1%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB1%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/HBX1.minus.bw%20description=%22HXB1%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>


                               												<TD>HXB24/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB24%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/HBX24.plus.bw%20description=%22HXB24%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB24%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/HBX24.minus.bw%20description=%22HXB24%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                               												<TD></TD>
                               												<TD></TD>
                               											</TR>
                               											<TR>
                               												<TD>LE/Stm <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LE-Stm%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/LE-Stm.plus.bw%20description=%22LE-Stm%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=dense">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22LE-Stm%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/LE-Stm.minus.bw%20description=%22LE-Stm%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=dense">- strand</a></TD>
                               												<TD>WKY/NCrl <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22WKY%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/WKY.plus.bw%20description=%22WKY%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22WKY%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/WKY.minus.bw%20description=%22WKY%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                               												<TD>HXB2/IpcvMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB2%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/HBX2.plus.bw%20description=%22HXB2%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB2%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/HBX2.minus.bw%20description=%22HXB2%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>


                               												<TD>HXB25/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB25%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/HBX25.plus.bw%20description=%22HXB25%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB25%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/HBX25.minus.bw%20description=%22HXB25%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                               												<TD></TD>
                               												<TD></TD>
                               																							</TR>
                               											<TR>
                               												<TD></TD>
                               												<TD></TD>
                               												<TD>HXB3/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB3%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/HBX3.plus.bw%20description=%22HXB3%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB3%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/HBX3.minus.bw%20description=%22HXB3%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                               												<TD>HXB27/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB27%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/HBX27.plus.bw%20description=%22HXB27%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB27%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/HBX27.minus.bw%20description=%22HXB27%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                               												<TD></TD>
                               												<TD></TD>
                               											</TR>
                               											<TR>
                               											<TD></TD>
                               											<TD></TD>
                               											<TD>HXB4/IpcvMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB4%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/HBX4.plus.bw%20description=%22HXB4%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB4%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/HBX4.minus.bw%20description=%22HXB4%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                               											<TD>HXB29/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB29%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/HBX29.plus.bw%20description=%22HXB29%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB29%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/HBX29.minus.bw%20description=%22HXB29%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                               											<TD></TD>
                               											<TD></TD>
                               											</TR>
                               											<TR>
                               												<TD></TD>
                               												<TD></TD>
                               												<TD>HXB5/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB5%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/HBX5.plus.bw%20description=%22HXB5%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB5%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/HBX5.minus.bw%20description=%22HXB5%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                               												<TD>HXB31/IpcvMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB31%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/HBX31.plus.bw%20description=%22HXB31%20Liver%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB31%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/liver/total/HBX31.minus.bw%20description=%22HXB31%20Liver%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                               												   <TD></TD>
                               												   <TD></TD>
                               											   </TR>
                               											</tbody>
                               											</table>
                               										</div>
                                <BR><BR>
                            <a href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hubUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/total/hub.txt"
                               target="_blank">Heart
                                Strain Specific Reads Counts (Total/Not Sampled)</a>
                                - <span name="heartCountTotalv7" class="showTracks button" style="width:190px;">Show Individual Tracks</span><BR>
									  <div id="heartCountTotalv7" style="display: none;">
											<table name="items" class="list_base ucscTracks">
										<THEAD>
										<TR class="col_title">
											<TH colspan="4">HXB/BXH Strains</TH>
										</TR>
										</THEAD>
										<tbody>
										<TR>
											<TD>BN-Lx/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BNLx%20Heart%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/total/BNLx.plus.bw%20description=%22BNLx%20Heart%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=dense">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BNLx%20Heart%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/total/BNLx.minus.bw%20description=%22BNLx%20Heart%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=dense">- strand</a></TD>
											<TD>BXH9/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH9%20Heart%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/total/BXH9.plus.bw%20description=%22BHX9%20Heart%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH9%20Heart%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/total/BXH9.minus.bw%20description=%22BHX9%20Heart%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
											<TD>HXB3/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB3%20Heart%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/total/HBX3.plus.bw%20description=%22HXB3%20Heart%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB3%20Heart%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/total/HBX3.minus.bw%20description=%22HXB3%20Heart%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
											<TD>HXB20/IpcvMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB20%20Heart%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/total/HBX20.plus.bw%20description=%22HXB20%20Heart%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB20%20Heart%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/total/HBX20.minus.bw%20description=%22HXB20%20Heart%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>

										</TR>
										<TR>
											<TD>SHR/OlaIpcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22SHR%20Heart%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/total/SHR.plus.bw%20description=%22SHR%20Heart%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=dense">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22SHR%20Heart%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/total/SHR.minus.bw%20description=%22SHR%20Heart%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=dense">- strand</a></TD>
											<TD>BXH10/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH10%20Heart%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/total/BXH10.plus.bw%20description=%22BHX10%20Heart%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH10%20Heart%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/total/BXH10.minus.bw%20description=%22BHX10%20Heart%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
											<TD>HXB5/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB5%20Heart%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/total/HBX5.plus.bw%20description=%22HXB5%20Heart%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB5%20Heart%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/total/HBX5.minus.bw%20description=%22HXB5%20Heart%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
											<TD>HXB21/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB21%20Heart%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/total/HBX21.plus.bw%20description=%22HXB21%20Heart%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB21%20Heart%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/total/HBX21.minus.bw%20description=%22HXB21%20Heart%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>

										</TR>
										<TR>
											<TD>BXH2/CubMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH2%20Heart%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/total/BXH2.plus.bw%20description=%22BHX2%20Heart%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH2%20Heart%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/total/BXH2.minus.bw%20description=%22BHX2%20Heart%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
											<TD>BXH11/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH11%20Heart%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/total/BXH11.plus.bw%20description=%22BHX11%20Heart%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH11%20Heart%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/total/BXH11.minus.bw%20description=%22BHX11%20Heart%20TotalRNA%20Minus%20(HRDPv7)%22">- strand</a></TD>
											<TD>HXB7/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB7%20Heart%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/total/HBX7.plus.bw%20description=%22HXB7%20Heart%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB7%20Heart%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/total/HBX7.minus.bw%20description=%22HXB7%20Heart%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
											 <TD>HXB24/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB24%20Heart%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/total/HBX24.plus.bw%20description=%22HXB24%20Heart%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB24%20Heart%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/total/HBX24.minus.bw%20description=%22HXB24%20Heart%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>

										</TR>
										<TR>
											<TD>BXH5/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH5%20Heart%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/total/BXH5.plus.bw%20description=%22BHX5%20Heart%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH5%20Heart%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/total/BXH5.minus.bw%20description=%22BHX5%20Heart%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
											<TD>BXH12/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH12%20Heart%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/total/BXH12.plus.bw%20description=%22BHX12%20Heart%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH12%20Heart%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/total/BXH12.minus.bw%20description=%22BHX12%20Heart%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
											<TD>HXB13/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB13%20Heart%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/total/HBX13.plus.bw%20description=%22HXB13%20Heart%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB13%20Heart%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/total/HBX13.minus.bw%20description=%22HXB13%20Heart%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
											<TD>HXB25/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB25%20Heart%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/total/HBX25.plus.bw%20description=%22HXB25%20Heart%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB25%20Heart%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/total/HBX25.minus.bw%20description=%22HXB25%20Heart%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>


										</TR>

										<TR>
											<TD>BXH6/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH6%20Heart%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/total/BXH6.plus.bw%20description=%22BHX6%20Heart%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH6%20Heart%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/total/BXH6.minus.bw%20description=%22BHX6%20Heart%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
											<TD>HXB1/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB1%20Heart%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/total/HBX1.plus.bw%20description=%22HXB1%20Heart%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB1%20Heart%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/total/HBX1.minus.bw%20description=%22HXB1%20Heart%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
											<TD>HXB17/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB17%20Heart%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/total/HBX17.plus.bw%20description=%22HXB17%20Heart%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB17%20Heart%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/total/HBX17.minus.bw%20description=%22HXB17%20Heart%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
											 <TD>HXB29/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB29%20Heart%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/total/HBX29.plus.bw%20description=%22HXB29%20Heart%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB29%20Heart%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/total/HBX29.minus.bw%20description=%22HXB29%20Heart%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>

										</TR>
										<TR>
											<TD>BXH8/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH8%20Heart%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/total/BXH8.plus.bw%20description=%22BHX8%20Heart%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH8%20Heart%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/heart/total/BXH8.minus.bw%20description=%22BHX8%20Heart%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
										</TR>

										
										</tbody>
										</table>
									</div>
									<BR><BR>
                            <a href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hubUrl=https://phenogen.org/public_ucsc/rn7/v7/kidney/total/hub.txt"
                               target="_blank">Kidney
                                Strain Specific Reads Counts (Total/Not Sampled)</a>
                                -
                                                                    <span name="kidneyCountTotalv7" class="showTracks button" style="width:190px;">Show Individual Tracks</span><BR>
                                								  <div id="kidneyCountTotalv7" style="display: none;">
                                										<table name="items" class="list_base  ucscTracks">
                                									<THEAD>
                                									<TR class="col_title">
                                										<TH colspan="4">HXB/BXH Strains</TH>
                                									</TR>
                                									</THEAD>
                                										<tbody>
                                										<TR>
                                										<TD>BN-Lx/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BNLx%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/BNLx.plus.bw%20description=%22BNLx%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=dense">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BNLx%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/BNLx.minus.bw%20description=%22BNLx%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=dense">- strand</a></TD>
                                										<TD>BXH11/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH11%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/BXH11.plus.bw%20description=%22BHX11%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH11%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/BXH11.minus.bw%20description=%22BHX11%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22">- strand</a></TD>
                                										<TD>HXB7/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB7%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/HBX7.plus.bw%20description=%22HXB7%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB7%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/HBX7.minus.bw%20description=%22HXB7%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                										<TD>HXB23/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB23%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/HBX23.plus.bw%20description=%22HXB23%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB23%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/HBX23.minus.bw%20description=%22HXB23%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                
                                									</TR>
                                									<TR>
                                										<TD>SHR/OlaIpcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22SHR%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/SHR.plus.bw%20description=%22SHR%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=dense">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22SHR%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/SHR.minus.bw%20description=%22SHR%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=dense">- strand</a></TD>
                                                                        <TD>BXH12/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH12%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/BXH12.plus.bw%20description=%22BHX12%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH12%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/BXH12.minus.bw%20description=%22BHX12%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                        <TD>HXB10/IpcvMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB10%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/HBX10.plus.bw%20description=%22HXB10%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB10%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/HBX10.minus.bw%20description=%22HXB10%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                        <TD>HXB24/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB24%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/HBX24.plus.bw%20description=%22HXB24%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB24%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/HBX24.minus.bw%20description=%22HXB24%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                
                                										</TR>
                                									<TR>
                                										<TD>BXH2/CubMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH2%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/BXH2.plus.bw%20description=%22BHX2%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH2%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/BXH2.minus.bw%20description=%22BHX2%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                        <TD>BXH13/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH13%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/BXH13.plus.bw%20description=%22BHX13%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH13%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/BXH13.minus.bw%20description=%22BHX13%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                        <TD>HXB13/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB13%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/HBX13.plus.bw%20description=%22HXB13%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB13%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/HBX13.minus.bw%20description=%22HXB13%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                							            <TD>HXB25/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB25%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/HBX25.plus.bw%20description=%22HXB25%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB25%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/HBX25.minus.bw%20description=%22HXB25%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                
                                									</TR>
                                									<TR>
                                										<TD>BXH3/CubMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH3%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/BXH3.plus.bw%20description=%22BHX3%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH3%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/BXH3.minus.bw%20description=%22BHX3%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                										<TD>HXB1/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB1%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/HBX1.plus.bw%20description=%22HXB1%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB1%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/HBX1.minus.bw%20description=%22HXB1%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                										<TD>HXB15/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB15%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/HBX15.plus.bw%20description=%22HXB15%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB15%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/HBX15.minus.bw%20description=%22HXB15%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                										<TD>HXB27/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB27%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/HBX27.plus.bw%20description=%22HXB27%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB27%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/HBX27.minus.bw%20description=%22HXB27%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                
                                										</TR>
                                									<TR>
                                										<TD>BXH6/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH6%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/BXH6.plus.bw%20description=%22BHX6%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH6%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/BXH6.minus.bw%20description=%22BHX6%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                										<TD>HXB2/IpcvMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB2%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/HBX2.plus.bw%20description=%22HXB2%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB2%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/HBX2.minus.bw%20description=%22HXB2%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                        <TD>HXB17/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB17%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/HBX17.plus.bw%20description=%22HXB17%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB17%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/HBX17.minus.bw%20description=%22HXB17%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                        <TD>HXB29/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB29%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/HBX29.plus.bw%20description=%22HXB29%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB29%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/HBX29.minus.bw%20description=%22HXB29%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                
                                									</TR>
                                									<TR>
                                										<TD>BXH8/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH8%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/BXH8.plus.bw%20description=%22BHX8%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH8%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/BXH8.minus.bw%20description=%22BHX8%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                        <TD>HXB3/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB3%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/HBX3.plus.bw%20description=%22HXB3%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB3%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/HBX3.minus.bw%20description=%22HXB3%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                        <TD>HXB18/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB18%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/HBX18.plus.bw%20description=%22HXB18%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB18%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/HBX18.minus.bw%20description=%22HXB18%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                								         <TD>HXB31/IpcvMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB31%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/HBX31.plus.bw%20description=%22HXB31%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB31%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/HBX31.minus.bw%20description=%22HXB31%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                    </TR>
                                									<TR>
                                										<TD>BXH9/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH9%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/BXH9.plus.bw%20description=%22BHX9%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH9%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/BXH9.minus.bw%20description=%22BHX9%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                										<TD>HXB4/IpcvMcwi <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB4%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/HBX4.plus.bw%20description=%22HXB4%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB4%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/HBX4.minus.bw%20description=%22HXB4%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                										<TD>HXB21/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB21%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/HBX21.plus.bw%20description=%22HXB21%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB21%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/HBX21.minus.bw%20description=%22HXB21%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                										<TD></TD>
                                									</TR>
                                									<TR>
                                										<TD>BXH10/Cub <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH10%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/BXH10.plus.bw%20description=%22BHX10%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22BXH10%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/BXH10.minus.bw%20description=%22BHX10%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                										<TD>HXB5/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB5%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/HBX5.plus.bw%20description=%22HXB5%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB5%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/HBX5.minus.bw%20description=%22HXB5%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                										<TD>HXB22/Ipcv <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB22%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/HBX22.plus.bw%20description=%22HXB22%20Kidney%20TotalRNA%20Plus%20(HRDPv7)%22%20autoScale=on%20visibility=full">+ strand</a>&nbsp;&nbsp;&nbsp;<a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hgct_customText=track%20name=%22HXB22%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20type=bigWig%20bigDataUrl=https://phenogen.org/public_ucsc/rn7/v7/kideny/total/HBX22.minus.bw%20description=%22HXB22%20Kidney%20TotalRNA%20Minus%20(HRDPv7)%22%20autoScale=on%20visibility=full">- strand</a></TD>
                                                                        <TD></TD>
                                									</TR>
                                									</tbody>
                                									</table>
                                								</div>
                                <BR><BR>
                        </div>
				<BR>
        </span>
        <BR><BR>
        <H1 style="background: #3c3c3c;text-align: center;">HRDP v6 - rn7 - Sept 2022</H1>
        <div id="hrdpv6" >
        <span style="text-align: center;">
        <H2>Transcriptomes with Merged Tissue Specific Read Counts:</H2>
        <BR>
        <div>
            <a href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hubUrl=https://phenogen.org/public_ucsc/rn7/v6/hub.txt"
               target="_blank">MultiTissue
                Transcriptome</a><BR><BR>
            <a href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hubUrl=https://phenogen.org/public_ucsc/rn7/v6/brain/hub.txt"
               target="_blank">Whole Brain
                Transcriptome</a><BR><BR>
            <a href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hubUrl=https://phenogen.org/public_ucsc/rn7/v6/liver/hub.txt"
               target="_blank">Liver
                Transcriptome</a><BR><BR>
            <a href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hubUrl=https://phenogen.org/public_ucsc/rn7/v6/kidney/hub.txt"
               target="_blank">Kidney
                Transcriptome</a><BR><BR>
            <a href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hubUrl=https://phenogen.org/public_ucsc/rn7/v6/heart/hub.txt"
               target="_blank">Heart
                Transcriptome</a><BR><BR>
        </div><BR>
            <H2>Strain/Tissue Specific Read Counts (Sampled):</H2>
            <div style="text-align: center;">Randomly sampled to even total counts between strains to match the lowest strain.</div>
        <BR>
        <div>
            <a href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hubUrl=https://phenogen.org/public_ucsc/rn7/v6/brain/sampled/hub.txt"
               target="_blank">Whole
                Brain Strain Specific Reads Counts (Sampled)</a><BR><BR>
            <a href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hubUrl=https://phenogen.org/public_ucsc/rn7/v6/liver/sampled/hub.txt"
               target="_blank">Liver
                Strain Specific Reads Counts (Sampled)</a><BR><BR>
            <a href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hubUrl=https://phenogen.org/public_ucsc/rn7/v6/heart/sampled/hub.txt"
               target="_blank">Heart
                Strain Specific Reads Counts (Sampled)</a><BR><BR>
            <a href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hubUrl=https://phenogen.org/public_ucsc/rn7/v6/kidney/sampled/hub.txt"
               target="_blank">Kidney
                Strain Specific Reads Counts (Sampled)</a><BR><BR>
        </div>
        <H2>Strain/Tissue Specific Read Counts (Total):</H2>
            <div style="text-align: center;">Not sampled: Each strain contains the total reads from all 3 biological replicates.</div>
        <BR>
        <div>
            <a href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hubUrl=https://phenogen.org/public_ucsc/rn7/v6/brain/total/hub.txt"
               target="_blank">Whole
                Brain Strain Specific Reads Counts (Total/Not Sampled)</a><BR><BR>
            <a href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hubUrl=https://phenogen.org/public_ucsc/rn7/v6/liver/total/hub.txt"
               target="_blank">Liver
                Strain Specific Reads Counts (Total/Not Sampled)</a><BR><BR>
            <a href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hubUrl=https://phenogen.org/public_ucsc/rn7/v6/heart/total/hub.txt"
               target="_blank">Heart
                Strain Specific Reads Counts (Total/Not Sampled)</a><BR><BR>
            <a href="http://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&hubUrl=https://phenogen.org/public_ucsc/rn7/v6/kidney/total/hub.txt"
               target="_blank">Kidney
                Strain Specific Reads Counts (Total/Not Sampled)</a><BR><BR>
        </div>
        </div>
            </span>

    </div>
    <div id="rest" style="<%if(!section.equals("rest")){%>display:none;<%}%>border-top:1px solid black;">
        <H1 style="background: #3c3c3c;">PhenoGen REST API</H1>
        <BR>
        <div>
            We are building a REST API to provide access to all public data. Eventually this will also
            include running most functions available through the website. Keep checking back for new functions.
        </div>
        <BR>
        <H2>Domains for Functions Calls:</H2>
        <BR>
        <div>
            Functions can be called at either:<BR>
            <a href="https://rest.phenogen.org" target="_blank">https://rest.phenogen.org</a><BR>
            or<BR>
            <a href="https://rest-test.phenogen.org" target="_blank">https://rest-test.phenogen.org</a><BR>
            Please note this is a development and testing version of the API. Please do not use this
            for actual data analysis. Only for development.
        </div>
        <BR>
        <H2>Help</H2>
        <BR>
        Documentation at <a href="https://rest-doc.phenogen.org" target="_blank">https://rest-doc.phenogen.org</a>
        <BR>
        All functions should include help as a response if you call the function with this appended to the
        end `?help=Y`. The response returns a JSON object with supported methods and then list of parameters
        and description of each parameter as well as a list of options if there is a defined list of values.
        <BR>
        <BR>
        <BR>
        <H1 style="background: #3c3c3c;">PhenoGenRESTR</H1><BR>
        An R package that we're maintaining as new REST API Functions are developed to download data directly into R.
        <BR>
        <a href="r_readme.html" target="_blank">R Package Documentation</a>


    </div>
    <div id="array" style="<%if(!section.equals("array")){%>display:none;<%}%>border-top:1px solid black;">
        <form method="post"
              action="resources.jsp"
              enctype="application/x-www-form-urlencoded"
              name="resources">
            <BR>
            <div class="brClear"></div>

            <div class="title"> Expression Data Files</div>
            <table id="expressionFiles" name="items" class="list_base tablesorter" cellpadding="0" cellspacing="3"
                   width="98%">
                <thead>
                <tr class="col_title">
                    <TH>Experiment Accession ID</TH>
                    <th>Organism</th>
                    <th>Dataset</th>
                    <th>Tissue</th>
                    <th>Array</th>
                    <th>Expression Values</th>
                    <th>eQTL</th>
                    <th>Heritability</th>
                    <TH>Masks <span class="toolTip"
                                    title="For Affymetrix exon array masks, individual probes were masked if they did not align uniquely to the rat/mouse genome (rn5/mm10) or if they aligned to a region that harbored a SNP between the reference genome and either of the RI panels parental strains(SHR/BN-Lx or ILS/ISS).  Entire probe sets were eliminated if less than three probes remained after masking.  To create masked transcript clusters, masked probe sets were removed from transcript clusters.  Remaining probe sets new locations were verified by checking that the location was still on the same strand, and within 1,000,000 base pairs of each other.  Transcript clusters with no probe sets remaining were masked."><img
                            src="<%=imagesDir%>icons/info.gif"></span></TH>
                    <!-- <th>Details</th> -->
                </tr>
                </thead>
                <tbody>
                <% for (Resource resource : myExpressionResources) {
                %>
                <tr id="<%=resource.getID()%>">
                    <TD><%=resource.getID()%>
                    </TD>
                    <td><%=resource.getOrganism()%>
                    </td>
                    <td><%=resource.getDataset().getName()%>
                    </td>
                    <td><%=resource.getTissue()%>
                    </td>
                    <td><%=resource.getArrayName()%>
                    </td>
                    <% if (resource.getDataset().getVisible()) {%>
                    <% if (resource.getExpressionDataFiles() != null && resource.getExpressionDataFiles().length > 0) { %>
                    <td class="actionIcons">
                        <div class="linkedImg download" type="expression">
                            <div>
                    </td>
                    <% } else { %>
                    <td>&nbsp;</td>
                    <% } %>
                    <% if (resource.getEQTLDataFiles() != null && resource.getEQTLDataFiles().length > 0) { %>
                    <td class="actionIcons">
                        <div class="linkedImg download" type="eQTL">
                            <div>
                    </td>
                    <% } else { %>
                    <td>&nbsp;</td>
                    <% } %>
                    <% if (resource.getHeritabilityDataFiles() != null && resource.getHeritabilityDataFiles().length > 0) { %>
                    <td class="actionIcons">
                        <div class="linkedImg download" type="heritability">
                            <div>
                    </td>
                    <% } else { %>
                    <td>&nbsp;</td>
                    <% } %>
                    <% if (resource.getMaskDataFiles() != null && resource.getMaskDataFiles().length > 0) { %>
                    <td class="actionIcons">
                        <div class="linkedImg download" type="mask">
                                <%if(resource.getDataset().getName().contains("Exon")&&resource.getOrganism().equals("Rat")){%>
                            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;*
                                <%}%>
                            <div>

                    </td>
                    <% } else { %>
                    <td>&nbsp;</td>
                    <% } %>
                    <%} else {%>
                    <td colspan="4"><%= resource.getDataset().getVisibleNote() %>
                    </td>
                    <% } %>
                </tr>
                <% } %>
                </tbody>
            </table>
        </form>
        <BR>
        *The mask files are the same for all of these datasets.
    </div>
    <div id="marker" style="<%if(!section.equals("marker")){%>display:none;<%}%>border-top:1px solid black;">
        <form method="post"
              action="resources.jsp"
              enctype="application/x-www-form-urlencoded"
              name="resources">
            <BR>
            <div class="title"> Genomic Marker Data Files</div>
            <table id="markerFiles" class="list_base tablesorter" name="items" cellpadding="0" cellspacing="3">
                <thead>
                <tr class="col_title">
                    <th>Organism</th>
                    <th>Panel</th>
                    <th>Genome Version</th>
                    <th>Source</th>
                    <th>Markers</th>
                    <th>eQTL</th>
                </tr>
                </thead>
                <tbody>
                <% for (Resource resource : myMarkerResources) { %>
                <tr id="<%=resource.getID()%>">
                    <td><%=resource.getOrganism()%>
                    </td>
                    <td><%=resource.getPanelString()%>
                    </td>
                    <td><%=resource.getGenome()%>
                    </td>
                    <td><%=resource.getSource()%>
                    </td>
                    <% if (resource.getMarkerDataFiles() != null && resource.getMarkerDataFiles().length > 0) { %>
                    <td class="actionIcons">
                        <div class="linkedImg download" type="marker">
                            <div>
                    </td>
                    <% } else { %>
                    <td>&nbsp;</td>
                    <% } %>
                    <% if (resource.getEQTLDataFiles() != null && resource.getEQTLDataFiles().length > 0) { %>
                    <td class="actionIcons">
                        <div class="linkedImg download" type="eQTL">
                            <div>
                    </td>
                    <% } else { %>
                    <td>&nbsp;</td>
                    <% } %>
                </tr>
                <% } %>
                </tbody>
            </table>
        </form>
    </div>
    <div id="rnaseq" style="<%if(!section.equals("rnaseq")){%>display:none;<%}%>border-top:1px solid black;">
        <div class="title"> New RNA Sequencing Datasets Experimental Details/Downloads</div>
        <form method="post"
              action="resources.jsp"
              enctype="application/x-www-form-urlencoded"
              name="resources">
            <table id="rnaseqTbl" class="list_base tablesorter" name="items" cellpadding="0" cellspacing="3">
                <thead>
                <tr class="col_title">

                    <TH>Description</TH>
                    <th>Organism</th>
                    <th>Strain</th>
                    <th>Tissue</th>
                    <th>Seq. Tech.</th>
                    <th>RNA Type</th>
                    <th>Read Type</th>
                    <TH>Genome<BR>Versions</th>
                    <th>Experimental<BR>Details</th>
                    <TH>Raw Data Downloads</TH>
                    <TH>Result Downloads</TH>
                </tr>
                </thead>
                <tbody>
                <% for (int i = 0; i < publicRNADatasets.size(); i++) {
                    String tech = "";
                    ArrayList<String> tmpTech = publicRNADatasets.get(i).getSeqTechFromSamples();
                    for (int j = 0; j < tmpTech.size(); j++) {
                        if (j > 0) {
                            tech += ", ";
                        }
                        tech += tmpTech.get(j);
                    }
                    String readType = "";
                    ArrayList<String> tmpType = publicRNADatasets.get(i).getReadTypeFromSamples();
                    for (int j = 0; j < tmpType.size(); j++) {
                        if (j > 0) {
                            readType += ", ";
                        }
                        readType += tmpType.get(j);
                    }
                    String genomeVer = "";
                    ArrayList<String> tmpGV = publicRNADatasets.get(i).getResultGenomeVer();
                    for (int j = 0; j < tmpGV.size(); j++) {
                        if (j > 0) {
                            genomeVer += ", ";
                        }
                        genomeVer += tmpGV.get(j);
                    }
                %>
                <TR id="<%=publicRNADatasets.get(i).getRnaDatasetID()%>">

                    <TD><%=publicRNADatasets.get(i).getDescription()%>
                    </TD>
                    <TD><%=publicRNADatasets.get(i).getOrganism()%>
                    </TD>
                    <TD><%=publicRNADatasets.get(i).getPanel()%>
                    </TD>
                    <TD><%=publicRNADatasets.get(i).getTissue()%>
                    </TD>
                    <TD><%=tech%>
                    </TD>
                    <TD><%=publicRNADatasets.get(i).getSeqType()%>
                    </TD>
                    <TD><%=readType%>
                    </TD>
                    <TD><%=genomeVer%>
                    </TD>
                    <td class="actionIcons">
                        <div class="linkedImg info" type="rnaseqMeta">
                            <div>
                    </td>
                    <td class="actionIcons">
                        <%if (publicRNADatasets.get(i).getRawDownloadFileCount() > 0) {%>
                        <div class="linkedImg download" type="rnaseqRaw">
                            <div>
                                    <%}%>
                    </td>
                    <td class="actionIcons">
                        <%if (publicRNADatasets.get(i).getResultDownloadCount() > 0) {%>
                        <div class="linkedImg download" type="rnaseqResults">
                            <div>
                                    <%}%>
                    </td>
                </TR>
                <%}%>
                </tbody>
            </table>
        </form>

        <!--<BR><BR><BR>
        <form method="post"
              action="resources.jsp"
              enctype="application/x-www-form-urlencoded"
              name="resources">
            <div class="title"> RNA-Seq Transcriptome Reconstruction<span class="toolTip"
                                                                          title="Reconstructed Transcriptome with high confidence transcripts from Stringtie/Cufflinks."><img
                    src="<%=imagesDir%>icons/info.gif"></span></div>
            <table id="gtfFiles" class="list_base tablesorter" name="items" cellpadding="0" cellspacing="3">
                <thead>
                <tr class="col_title">
                    <th>Organism</th>
                    <th>Strains</th>
                    <th>Tissue</th>
                    <th>Assembled by</th>
                    <th>.gtf Files</th>
                </tr>
                </thead>
                <% for (Resource resource : myGTFResources) { %>
                <tr id="<%=resource.getID()%>">

                    <TD><%=resource.getOrganism()%>
                    </TD>
                    <TD><%=resource.getSource()%>
                    </TD>
                    <TD><%=resource.getTechType()%>
                    </TD>
                    <TD><%=resource.getGenome()%>
                    </TD>
                    <td class="actionIcons">
                        <div class="linkedImg download" type="gtf">
                            <div>
                    </td>
                </tr>
                <% } %>
            </table>
            <BR>

            <BR>
            <div class="title">Transcriptome Quantitation(Gene/Transcript, Ensembl/Reconstruction)<span class="toolTip"
                                                                                                        title="Quantified/Normalized RSEM results for both Annotated (Ensembl) / Novel (Transcriptome reconstruction) genes and transcripts."><img
                    src="<%=imagesDir%>icons/info.gif"></span></div>
            <table id="gtfFiles" class="list_base tablesorter" name="items" cellpadding="0" cellspacing="3">
                <thead>
                <tr class="col_title">
                    <th>Organism</th>
                    <th>Strains</th>
                    <th>Tissue</th>
                    <th>.csv Files</th>
                </tr>
                </thead>
                <% for (Resource resource : rsemResources) { %>
                <tr id="<%=resource.getID()%>">

                    <TD><%=resource.getOrganism()%>
                    </TD>
                    <TD><%=resource.getSource()%>
                    </TD>
                    <TD><%=resource.getTechType()%>
                    </TD>
                    <td class="actionIcons">
                        <div class="linkedImg download" type="rsem">
                            <div>
                    </td>
                </tr>
                <% } %>
            </table>
            <BR>
            <BR>
            <div class="title"> RNA Sequencing BED/BAM Data Files</div>
            <table id="rnaFiles" class="list_base tablesorter" name="items" cellpadding="0" cellspacing="3">
                <thead>
                <tr class="col_title">
                    <th>Organism</th>
                    <th>Strain</th>
                    <th>Tissue</th>
                    <th>Seq. Tech.</th>
                    <th>RNA Type</th>
                    <th>Read Type</th>
                    <TH>Genome Versions</th>
                    <th>.BED/.BAM Files</th>
                </tr>
                </thead>
                <tbody>
                <% for (Resource resource : myRNASeqResources) { %>
                <tr id="<%=resource.getID()%>">
                    <td><%=resource.getOrganism()%>
                    </td>
                    <td><%=resource.getSource()%>
                    </td>
                    <td><%=resource.getTissue()%>
                    </td>
                    <td><%=resource.getTechType()%>
                    </td>
                    <td><%=resource.getRNAType()%>
                    </td>
                    <td><%=resource.getReadType()%>
                    </td>
                    <td><%=resource.getGenome()%>
                    </td>
                    <% if (resource.getSAMDataFiles() != null && resource.getSAMDataFiles().length > 0) { %>
                    <td class="actionIcons">
                        <div class="linkedImg download" type="rnaseq">
                            <div>
                    </td>
                    <% } else { %>
                    <td>&nbsp;</td>
                    <% } %>
                </tr>
                <% } %>
                </tbody>
            </table>

        </form>-->


    </div>
    <div id="dnaseq" style="<%if(!section.equals("dnaseq")){%>display:none;<%}%>border-top:1px solid black;">
        <form method="post"
              action="resources.jsp"
              enctype="application/x-www-form-urlencoded"
              name="resources">
            <!--<BR>
		<BR>
		
		      <table id="rnaFiles" class="list_base tablesorter" name="items" cellpadding="0" cellspacing="3">
            		<thead>
                               <tr class="col_title">
					<th>Organism</th>
					<th>Strain</th>
                    <th>Tissue</th>
                    <th>Seq. Tech.</th>
                    <th>RNA Type</th>
                    <th>Read Type</th>
                    <TH>Genome Versions</th>
					<th>.BED/.BAM Files</th>
				</tr>
			</thead>
			<tbody>
			<% for (Resource resource: myRNASeqResources) { %> 
				<tr id="<%=resource.getID()%>">  
				<td> <%=resource.getOrganism()%> </td>
				<td> <%=resource.getSource()%></td>
                <td> <%=resource.getTissue()%></td>
                <td> <%=resource.getTechType()%></td>
                <td> <%=resource.getRNAType()%></td>
                <td> <%=resource.getReadType()%></td>    
                <td> <%=resource.getGenome()%></td>
				<% if (resource.getSAMDataFiles() != null && resource.getSAMDataFiles().length > 0) { %>
					<td class="actionIcons">
						<div class="linkedImg download" type="rnaseq"><div>
					</td>
				<% } else { %>
                                	<td>&nbsp;</td>
				<% } %>
				</tr> 
			<% } %>
			</tbody>
		</table>
        
        
        <BR>
		<BR>-->
            <div class="title"> Strain-specific Rat Genomes<span class="toolTip"
                                                                 title="SNPs between the reference genome and the strain have been replaced with the nucleotide from the strain."><img
                    src="<%=imagesDir%>icons/info.gif"></span></div>
            <table id="dnaFiles" class="list_base tablesorter" name="items" cellpadding="0" cellspacing="3">
                <thead>
                <tr class="col_title">
                    <th>Organism</th>
                    <th>Strain</th>
                    <th>Seq. Tech.</th>
                    <th>Genome Version</th>
                    <th>.fasta Files</th>
                </tr>
                </thead>
                <tbody>
                <% for (Resource resource : myDNASeqResources) { %>
                <tr id="<%=resource.getID()%>">
                    <td><%=resource.getOrganism()%>
                    </td>
                    <td><%=resource.getSource()%>
                    </td>
                    <td><%=resource.getTechType()%>
                    </td>
                    <td><%=resource.getGenome()%>
                    </td>
                    <% if (resource.getSAMDataFiles() != null && resource.getSAMDataFiles().length > 0) { %>
                    <td class="actionIcons">
                        <div class="linkedImg download" type="rnaseq">
                            <div>
                    </td>
                    <% } else { %>
                    <td>&nbsp;</td>
                    <% } %>
                </tr>
                <% } %>

                </tbody>
            </table>
            <div style="text-align:center; padding-top:5px;">
                Links to Reference Rat Genome(Strain BN): <a href="ftp://ftp.ncbi.nlm.nih.gov/genomes/R_norvegicus/"
                                                             target="_blank">FTP NCBI-Rn6</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <a href="ftp://ftp.ensembl.org/pub/release-71/fasta/rattus_norvegicus/dna/" target="_blank">FTP
                    Ensembl-Rn5</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <a href="ftp://ftp.ensembl.org/pub/release-84/fasta/rattus_norvegicus/dna/" target="_blank">FTP
                    Ensembl-Rn6</a>
            </div>
            <!--<BR><BR>
        <div class="title"> RNA-Seq Transcriptome Reconstruction<span class="toolTip" title="Reconstructed Transcriptome with high confidence transcripts from Cufflinks."><img src="<%=imagesDir%>icons/info.gif"></span></div>
		      <table id="gtfFiles" class="list_base" name="items" cellpadding="0" cellspacing="3">
            		<thead>
                               <tr class="col_title">
					<th>Organism</th>
					<th>Strains</th>
                                        <th>Tissue</th>
                                        <th>Assembled by</th>
					<th>.gtf Files</th>
				</tr>
			</thead>
                        <% for (Resource resource: myGTFResources) { %> 
				<tr id="<%=resource.getID()%>">  
                                    
                                    <TD><%=resource.getOrganism()%></TD>
                                    <TD><%=resource.getSource()%></TD>
                                    <TD><%=resource.getTechType()%></TD>
                                    <TD><%=resource.getGenome()%></TD>
                                    <td class="actionIcons">
						<div class="linkedImg download" type="gtf"><div>
                                    </td>
				</tr> 
			<% } %>
                      </table>-->

        </form>
    </div>

    <div id="pub" style="<%if(!section.equals("pub")){%>display:none;<%}%>border-top:1px solid black;">
        <form method="post"
              action="resources.jsp"
              enctype="application/x-www-form-urlencoded"
              name="resources">
            <%
                for (int i = 0; i < pubList.size(); i++) {
                    Resource[] resources = pubList.get(i);
            %>
            <%Resource title = resources[0];%>
            <div class="title"><%=title.getTitle()%><BR><%=title.getAuthor()%><BR>
                    <%if(!title.getAbstractURL().equals("")){%>
                <a href="<%=title.getAbstractURL()%>">Abstract</a>
                    <%}%>
                <table id="pubFiles" class="list_base tablesorter" name="items" cellpadding="0" cellspacing="3"
                       width="85%">
                    <thead>
                    <tr class="col_title">
                        <%if (resources[1].getPanel() != null && !resources[1].getPanel().equals("N/A") && !resources[1].getPanel().equals("")) {%>
                        <th>Population</th>
                        <%}%>
                        <th>Data</th>
                        <TH>Files</TH>
                    </tr>
                    </thead>
                    <tbody>
                    <% for (int j = 1; j < resources.length; j++) {
                        Resource resource = resources[j];
                        if (resource.getID() != -1) {
                    %>
                    <tr id="<%=resource.getID()%>">
                        <%if (resources[1].getPanel() != null && !resources[1].getPanel().equals("N/A") && !resources[1].getPanel().equals("")) {%>
                        <TD><%=resource.getPanel()%>
                        </TD>
                        <%}%>
                        <TD><%=resource.getDescription()%>
                        </TD>
                        <td class="actionIcons">
                            <div class="linkedImg download" type="pub">
                                <div>
                        </td>
                    </tr>
                    <% } else if (resource.getAbstractURL() != null) {%>
                    <tr>
                        <td colspan="3"><a href="<%=resource.getAbstractURL()%>"
                                           target="_blank"><%=resource.getTitle()%>
                        </a></td>
                    </tr>

                    <%
                            }
                        }
                    %>
                    </tbody>
                </table>
                <BR>
                <BR>
                    <%}%>


                <BR>
                <BR>
        </form>
    </div>

</div>
<!-- END PUBLIC DIV-->
<div id="members" style="display:none;min-height: 780px;">
    <H2>My Files</h2>
    <div style="text-align: center;height: 350px;overflow:auto;">
        <table id="myFiles" name="items" style="width:100%;text-align: center;" class="list_base" cellpadding="0"
               cellspacing="0">
            <thead>
            <TR class="col_title">
                <TH>File Name(click to download)</TH>

                <TH>Description</TH>
                <TH>Date Uploaded</TH>
                <TH>Shared<BR>(click to edit)</TH>
                <TH>Shared with All<BR>Registered Users<BR>(click to edit)</TH>
                <TH>Delete</TH>
            </TR>
            </thead>
            <tbody>
            <TR id="myloading">
                <TD colspan="6"><img src="<%=imagesDir%>/icons/busy.gif"> Loading...</TD>
            </tr>
            </tbody>
        </table>
    </div>
    <BR><BR>
    <H2>Files Shared with Me</h2>
    <div style="text-align: center;height: 350px;overflow:auto;">
        <table id="sharedFiles" name="items" style="width:100%;text-align: center;" class="list_base" cellpadding="0"
               cellspacing="0">
            <thead>
            <TR class="col_title">
                <TH>File Owner</TH>
                <TH>File Name<BR>(click to download)</TH>
                <TH>Description</TH>
                <TH>Date Uploaded</TH>
            </TR>
            </thead>
            <tbody>
            <TR id="sharedloading">
                <TD colspan="4"><img src="<%=imagesDir%>/icons/busy.gif"> Loading...</TD>
            </tr>
            </tbody>
        </table>
    </div>
</div>
<!-- END MEMBERS DIV-->

<div class="downloadItem"></div>

<div class="metaData"></div>
<div class="pipelineData"></div>

<div style="width:500px;height:450px;position:absolute;display:none;top:100px;left:400px;background-color: #FFFFFF;border: #000000 1px solid;"
     id="userList">
    <div style="background-color: #CECECE;width:100%;height:18px;">Select Users to share file <span id="closeuserList"
                                                                                                    style="float:right; magin-top:2px;margin-right: 5px;"><img
            src="<%=imagesDir%>/icons/close.png"></span></div>
    <BR>
    <div id="userListContent" style="width:100%">
        <span id="fileName">File Name:</span>
        <BR><BR>
        <table id="myUsers" name="items" class="list_base" cellpadding="0" cellspacing="0" style="text-align: center;">
            <thead class="col_title">
            <TH>Check to Share file</th>
            <TH>First Name</th>
            <TH>Last Name</th>
            <TH>Institution</th>
            </thead>
            <tbody>

            </tbody>
        </table>
        <BR>
        <div><input type="button" value="Apply" onclick="updateSharedList()"><input type="hidden" value="-99"
                                                                                    id="fileID"><span
                id="status"></span></div>
    </div>
</div>

<%@ include file="/web/common/footer_adaptive.jsp" %>


<script type="text/javascript">
    var curUID =<%=userLoggedIn.getUser_id()%>;
    var section = "<%=section%>";
    var publicationID =<%=pubID%>;
    var pipelineModal;
    var metaModal;
    $(document).ready(function () {
        $(".search").css("position", "relative").css("top", -16);
        $('.toolTip').tooltipster({
            position: 'top-right',
            maxWidth: 250,
            offsetX: 24,
            offsetY: 5,
            //arrow: false,
            interactive: true,
            interactiveTolerance: 350
        });
        setupPage();
        setTimeout("setupMain()", 100);
        <% if(loggedIn && !(userLoggedIn.getUser_name().equals("anon")) ){%>
        setTimeout(getMyFiles, 50);
        setTimeout(getSharedFiles, 50);
        <%}%>
        $(".detailMenu").on("click", function () {
            var prev = $(".detailMenu.selected").attr("name");
            $(".detailMenu.selected").removeClass("selected");
            $("div#" + prev).hide();
            $(this).addClass("selected");
            var cur = $(this).attr("name");
            $("div#" + cur).show();
            rows = $("table.list_base tr");
            stripeTable(rows);
        });

        setTimeout(function () {
            var tmpH = $(window).height() * .85;
            var tmpW = $(window).width() * .85;
            metaModal = createDialog(".metaData", {
                height: tmpH,
                width: tmpW,
                position: {my: "center", at: "center", of: window},
                title: "Experiment Details"
            });
            pipelineModal = createDialog(".pipelineData", {
                height: tmpH,
                width: tmpW,
                position: {my: "center", at: "center", of: window},
                title: "Analysis Pipeline Details"
            });
        }, 10);

        /*setTimeout(function(){
            if(publicationID>0){
                console.log("pub:"+publicationID);
                $.ajax({
                    type: "POST",
                    url: contextPath + "/web/sysbio/directDownloadFiles.jsp",
                    dataType: "html",
                    data: { resource:publicationID, type: "pub" },
                    async: false,
                    success: function( html ){
                    downloadModal.html( html ).dialog( "open" );
                    },
                    error: function(XMLHttpRequest, textStatus, errorThrown) {
                            alert( "there was an error processing this request: " + textStatus + " " + errorThrown );
                    }
                });
            }
        },500);*/

    });

    $("#closeuserList").on("click", function () {
        $("div#userList").hide();
    });

    $(".showTracks").on("click",function(){
        name=$(this).attr("name");
       if($("div#"+name).is(":visible")){
           $("div#"+name).hide();
           $(this).html("Show Individual Tracks");
       }else{
           $("div#"+name).show();
           $(this).html("Hide Individual Tracks");
       }

    });

    var myFileDataTable;
    var myUserDataTable;
    var shareFileDataTable;

    function key(d) {
        return d.FileID;
    }

    function getMyFiles() {
        $.ajax({
            url: "getFiles.jsp",
            type: 'GET',
            data: {type: "myFiles"},
            dataType: 'json',
            success: function (data2) {
                try {
                    myFileDataTable.destroy();
                } catch (err) {

                }
                d3.select("table#myFiles").select("tbody").select('tr#myloading').remove();
                var tracktbl = d3.select("table#myFiles").select("tbody").selectAll('tr').data(data2, key);
                tracktbl.enter().append("tr")
                    .attr("id", function (d) {
                        return "fid" + d.FileID;
                    })
                    .attr("class", function (d, i) {
                        var ret = "odd";
                        if (i % 2 === 0) {
                            ret = "even";
                        }
                        return ret;
                    });
                tracktbl.exit().remove();
                tracktbl.each(function (d, i) {
                    d3.select(this).selectAll("td").remove();
                    var ind = d.Path.lastIndexOf("/");
                    var file = d.Path.substr(ind + 1);
                    var fileLink = "<a href=\"" + d.Path + "\" target=\"_blank\"> " + file + " </a>";
                    var timeShort = d.Time.substr(0, d.Time.lastIndexOf(":"));
                    var shared = "<span class=\"action shared\" id=\"share" + d.FileID + "\"><img src=\"../images/success.png\"></span>";
                    if (d.OwnerID === curUID) {
                        shared = shared + "<span class=\"action sharedUsers\" id=\"shareUser" + d.FileID + "\"><img src=\"../images/icons/user_32.png\"></span>";
                    }
                    if (d.Shared === "false") {
                        shared = "<span class=\"action shared\" id=\"share" + d.FileID + "\"><img src=\"../images/error.png\"></span>";
                        if (d.OwnerID === curUID) {
                            shared = shared + "<span class=\"action sharedUsers\" style=\"display:none;\" id=\"shareUser" + d.FileID + "\"><img src=\"../images/icons/user_32.png\"></span>";
                        }
                    }

                    var shareAll = "<span class=\"action shareAll\" id=\"shareAll" + d.FileID + "\"><img src=\"../images/success.png\"></span>";
                    if (d.ShareAll === "false") {
                        shareAll = "<span class=\"action shareAll\" id=\"shareAll" + d.FileID + "\"><img src=\"../images/error.png\"></span>";
                    }
                    d3.select(this).append("td").html(fileLink);
                    d3.select(this).append("td").html(d.Description);
                    d3.select(this).append("td").html(timeShort);
                    d3.select(this).append("td").html(shared);
                    d3.select(this).append("td").html(shareAll);
                    d3.select(this).append("td").html("<span class=\"action delete\" id=\"delete" + d.FileID + "\"><img src=\"../images/icons/delete_lg.png\"></span>");
                });

                myFileDataTable = $('table#myFiles').DataTable({
                    "bPaginate": false,
                    "aaSorting": [[2, "desc"]],

                    "sDom": '<"rightSearch"fr><t>'
                });

                //setup action buttons

                //changes the sharing status
                $(".action.shared").on("click", function () {
                    var fullID = $(this).attr("id");
                    var id = fullID.substr(5);
                    var type = fullID.substr(0, 5);
                    updateFiles(id, fullID, type);
                });

                //changes the share with all registered users
                $(".action.shareAll").on("click", function () {
                    var fullID = $(this).attr("id");
                    var id = fullID.substr(8);
                    var type = fullID.substr(0, 8);
                    updateFiles(id, fullID, type);
                });
                //lets user share with selected users
                $(".action.sharedUsers").on("click", function (event) {
                    var fullID = $(this).attr("id");
                    var id = fullID.substr(9);
                    $("input#fileID").val(id);
                    $("div#userList").css("top", event.pageY).css("left", event.pageX - 450);
                    var path = d3.select("table#myFiles").select("tbody").select('tr#fid' + id).data()[0].Path;
                    var file = path.substr(path.lastIndexOf("/") + 1);
                    $("span#fileName").html("File Name:" + file);
                    $("span#status").html("");
                    $("div#userList").show();

                    $.ajax({
                        url: "getAllUsers.jsp",
                        type: 'GET',
                        data: {},
                        dataType: 'json',
                        beforeSend: function () {

                        },
                        success: function (data2) {
                            try {
                                myUserDataTable.destroy();
                            } catch (err) {

                            }
                            d3.select("table#myUsers").select("tbody").selectAll('tr').remove();
                            var usertbl = d3.select("table#myUsers").select("tbody").selectAll('tr').data(data2);
                            usertbl.enter().append("tr")
                                .attr("id", function (d) {
                                    return "uid" + d.ID;
                                })
                                .attr("class", function (d, i) {
                                    var ret = "odd";
                                    if (i % 2 === 0) {
                                        ret = "even";
                                    }
                                    return ret;
                                });
                            usertbl.exit().remove();
                            usertbl.each(function (d, i) {
                                d3.select(this).selectAll("td").remove();
                                d3.select(this).append("td").html("<input class=\"inclUser\" id=\"uid" + d.ID + "\" type=\"checkbox\">");
                                d3.select(this).append("td").html(d.First);
                                d3.select(this).append("td").html(d.Last);
                                d3.select(this).append("td").html(d.Institution);
                            });

                            myUserDataTable = $('table#myUsers').DataTable({
                                "bPaginate": false,
                                "aaSorting": [[3, "asc"]],
                                "sScrollX": "460px",
                                "sScrollY": "300px",
                                "sDom": '<"rightSearch"fr><t>'
                            });
                            $.ajax({
                                url: "getSharedUsers.jsp",
                                type: 'GET',
                                data: {fid: id},
                                dataType: 'json',
                                success: function (data2) {
                                    var str = data2.UIDs;
                                    var list = str.split(",");
                                    for (var i = 0; i < list.length; i++) {
                                        var uid = list[i];
                                        //console.log($("input#uid"+uid));
                                        $("input#uid" + uid).prop('checked', true);
                                    }
                                }
                            });
                        },
                        error: function (xhr, status, error) {
                            console.log(error);

                        }
                    });
                });
                //deletes the file
                $(".action.delete").on("click", function () {
                    var fullID = $(this).attr("id");
                    var id = fullID.substr(6);
                    deleteFile(id, fullID);
                });

                //run again to keep file list up to date
                setTimeout(getMyFiles, 30000);
            },
            error: function (xhr, status, error) {
                console.log(error);
                setTimeout(getMyFiles, 240000);
            }
        });

    }

    function updateSharedList() {
        //working
        var idList = "";
        var fid = $("input#fileID").val();
        $('.inclUser:checked').each(function () {
            var id = $(this).attr("id").substr(3);
            if (idList === "") {
                idList = id;
            } else {
                idList = idList + "," + id;
            }
        });
        console.log(idList);
        $.ajax({
            url: "updateFiles.jsp",
            type: 'GET',
            data: {type: "updateSharedWith", idList: idList, fid: fid},
            dataType: 'json',
            beforeSend: function () {
                $("span#status").html("Working...Please wait");
            },
            success: function (data2) {
                $("span#status").html(" Completed Successfully");
                $("div#userList").hide();
            },
            error: function (xhr, status, error) {
                $("span#status").html("An error occurred please try again.");
                console.log(error);
            }
        });


    }

    function updateFiles(id, fullID, type) {
        $.ajax({
            url: "updateFiles.jsp",
            type: 'GET',
            data: {type: type, fid: id},
            dataType: 'json',
            beforeSend: function () {
                $("span#" + fullID).html("<img src=\"../images/icons/busy.gif\">");
                //d3.select("span#"+fullID).append("img").attr("src","../images/icons/busy.gif");
            },
            success: function (data2) {
                if (data2.success === "true") {
                    var img = "<img src=\"../images/success.png\">";
                    if (data2.status === "false") {
                        img = "<img src=\"../images/error.png\">";
                    }
                    $("span#" + fullID).html(img);
                    if (type === "share") {
                        if (data2.status === "false") {
                            $("span#shareUser" + id).hide();
                        } else {
                            $("span#shareUser" + id).show();
                        }
                    }
                } else {
                    d3.select("span#" + fullID).append("text").text(data2.Message);
                }
            },
            error: function (xhr, status, error) {
                console.log(error);

            }
        });
    }

    function deleteFile(id, fullID) {
        $.ajax({
            url: "updateFiles.jsp",
            type: 'GET',
            data: {type: "delete", fid: id},
            dataType: 'json',
            beforeSend: function () {
                $("span#" + fullID).html("<img src=\"../images/icons/busy.gif\">");
                //d3.select("span#"+fullID).append("img").attr("src","../images/icons/busy.gif");
            },
            success: function (data2) {
                if (data2.success === "true") {
                    d3.select("table#myFiles").select("tbody").select("tr#fid" + id).remove();
                } else {
                    $("span#" + fullID).html("<img src=\"../images/icons/delete_lg.png\">");
                    d3.select("span#" + fullID).append("text").text(data2.Message);
                }
            },
            error: function (xhr, status, error) {
                console.log(error);
            }
        });
    }

    function getSharedFiles() {
        $.ajax({
            url: "getFiles.jsp",
            type: 'GET',
            data: {type: "sharedFiles"},
            dataType: 'json',
            success: function (data2) {
                try {
                    shareFileDataTable.destroy();
                } catch (err) {

                }
                d3.select("table#sharedFiles").select("tbody").select('tr#sharedloading').remove();
                var tracktbl = d3.select("table#sharedFiles").select("tbody").selectAll('tr').data(data2, key);
                tracktbl.enter().append("tr")
                    .attr("id", function (d) {
                        return "fid" + d.FileID;
                    })
                    .attr("class", function (d, i) {
                        var ret = "odd";
                        if (i % 2 === 0) {
                            ret = "even";
                        }
                        return ret;
                    });
                tracktbl.exit().remove();
                tracktbl.each(function (d, i) {
                    d3.select(this).selectAll("td").remove();
                    var ind = d.Path.lastIndexOf("/");
                    var file = d.Path.substr(ind + 1);
                    var fileLink = "<a href=\"" + d.Path + "\" target=\"_blank\"> " + file + " </a>";
                    var timeShort = d.Time.substr(0, d.Time.lastIndexOf(":"));
                    d3.select(this).append("td").html(d.Owner);
                    d3.select(this).append("td").html(fileLink);
                    d3.select(this).append("td").html(d.Description);
                    d3.select(this).append("td").html(timeShort);

                });

                shareFileDataTable = $('table#sharedFiles').DataTable({
                    "bPaginate": false,
                    "aaSorting": [[3, "desc"]],
                    "sDom": '<"rightSearch"fr><t>'
                });
                setTimeout(getSharedFiles, 30000);
            },
            error: function (xhr, status, error) {
                console.log(error);
                setTimeout(getSharedFiles, 240000);
            }
        });

    }
</script>

