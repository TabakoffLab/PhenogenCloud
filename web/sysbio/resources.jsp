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

    div {
        font-size: 16px;
    }
</style>
<%
    pageTitle = "Download Resources";
    pageDescription = "Data resources available for downloading includes Microarrays, Sequencing, and GWAS data";
%>
<%@ include file="/web/common/header_adaptive_menu.jsp" %>
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
        <H1 style="background: #3c3c3c;text-align: center;"> HRDP v6 - rn7 - Sept 2022</H1>
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

