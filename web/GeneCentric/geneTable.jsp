<%@ include file="/web/common/anon_session_vars.jsp" %>

<jsp:useBean id="gdt" class="edu.ucdenver.ccp.PhenoGen.tools.analysis.GeneDataTools" scope="session"></jsp:useBean>
<%

    gdt.setSession(session);
    ArrayList<edu.ucdenver.ccp.PhenoGen.data.Bio.Gene> fullGeneList = new ArrayList<edu.ucdenver.ccp.PhenoGen.data.Bio.Gene>();
    DecimalFormat dfC = new DecimalFormat("#,###");

    String myOrganism = "";
    String fullOrg = "";
    String panel = "";
    String chromosome = "";
    String folderName = "";
    String type = "";
    String source = "";
    String genomeVer = "";
    String track = "";
    LinkGenerator lg = new LinkGenerator(session);
    HashMap<String, Integer> geneHM = new HashMap<String, Integer>();
    double forwardPValueCutoff = 0.01;
    int rnaDatasetID = 0;
    int arrayTypeID = 0;
    int min = 0;
    int max = 0;
    if (request.getParameter("species") != null) {
        myOrganism = FilterInput.getFilteredInput(request.getParameter("species").trim());
        if (myOrganism.equals("Rn")) {
            panel = "BNLX/SHRH";
            fullOrg = "Rattus_norvegicus";
        } else {
            panel = "ILS/ISS";
            fullOrg = "Mus_musculus";
        }
    }
    String[] tissuesList1 = new String[1];
    String[] tissuesList2 = new String[1];
    if (myOrganism.equals("Rn")) {
        tissuesList1 = new String[4];
        tissuesList2 = new String[4];
        tissuesList1[0] = "Brain";
        tissuesList2[0] = "Whole Brain";
        tissuesList1[1] = "Heart";
        tissuesList2[1] = "Heart";
        tissuesList1[2] = "Liver";
        tissuesList2[2] = "Liver";
        tissuesList1[3] = "Brown Adipose";
        tissuesList2[3] = "Brown Adipose";
    } else {
        tissuesList1[0] = "Brain";
        tissuesList2[0] = "Whole Brain";
    }
    if (request.getParameter("forwardPvalueCutoff") != null) {
        forwardPValueCutoff = Double.parseDouble(request.getParameter("forwardPvalueCutoff"));
    }
    if (request.getParameter("rnaDatasetID") != null) {
        rnaDatasetID = Integer.parseInt(request.getParameter("rnaDatasetID"));
    }
    if (request.getParameter("arrayTypeID") != null) {
        arrayTypeID = Integer.parseInt(request.getParameter("arrayTypeID"));
    }
    if (request.getParameter("chromosome") != null) {
        chromosome = FilterInput.getFilteredInput(request.getParameter("chromosome"));
    }

    if (request.getParameter("minCoord") != null) {
        min = Integer.parseInt(request.getParameter("minCoord"));
    }
    if (request.getParameter("maxCoord") != null) {
        max = Integer.parseInt(request.getParameter("maxCoord"));
    }
    if (request.getParameter("type") != null) {
        type = FilterInput.getFilteredInput(request.getParameter("type"));
    }
    if (request.getParameter("source") != null) {
        source = FilterInput.getFilteredInput(request.getParameter("source"));
    }
    if (request.getParameter("genomeVer") != null) {
        genomeVer = FilterInput.getFilteredInputGenomeVer(request.getParameter("genomeVer"));
    }
    if (request.getParameter("track") != null) {
        track = FilterInput.getFilteredInput(request.getParameter("track"));
    }
    if (min < max) {
        if (min < 1) {
            min = 1;
        }
        if (track.startsWith("brainTotal") || track.startsWith("liverTotal") || track.startsWith("heartTotal") || track.startsWith("mergedTotal") || track.startsWith("kidneyTotal")) {
            fullGeneList = gdt.getTrackRegionData(chromosome, min, max, panel, myOrganism, genomeVer, rnaDatasetID, arrayTypeID, forwardPValueCutoff, true, true, track);
        } else {
            fullGeneList = gdt.getRegionData(chromosome, min, max, panel, myOrganism, genomeVer, rnaDatasetID, arrayTypeID, forwardPValueCutoff, true, true);

        }
        /*if (source.startsWith("merged")) {
            fullGeneList = gdt.getMergedRegionData(chromosome, min, max, panel, myOrganism, genomeVer, rnaDatasetID, arrayTypeID, forwardPValueCutoff, true, true);
        } */
        log.debug("Gene list size:" + fullGeneList.size());

        String tmpURL = gdt.getGenURL();//(String)session.getAttribute("genURL");
        int second = tmpURL.lastIndexOf("/", tmpURL.length() - 2);
        if (second > -1) {
            folderName = tmpURL.substring(second + 1, tmpURL.length() - 1);
        }
        if (!track.equals("")) {
            geneHM = gdt.getRegionTrackList(chromosome, min, max, panel, myOrganism, genomeVer, rnaDatasetID, arrayTypeID, track);
            log.debug("HM totalsize:" + geneHM.size());
        }
    }


%>

<div id="geneList" style="position:relative;top:56px;border-color:#CCCCCC; border-width:1px 0px 0px 0px; border-style:inset;margin-bottom: 80px;">

    <table class="geneFilter">
        <thead>
        <TR>
            <TH style="width:50%"><span class="trigger triggerEC" id="geneListFilter1" name="geneListFilter" style=" position:relative;text-align:left;">Filter List</span><span
                    class="geneListToolTip" title="Click the + icon to view filtering Options."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
            <TH style="width:50%"><span class="trigger triggerEC" id="geneListFilter2" name="geneListFilter" style=" position:relative;text-align:left;">View Columns</span><span
                    class="geneListToolTip" title="Click the + icon to view Columns you can show/hide in the table below."><img
                    src="<%=imagesDir%>icons/info.gif"></span></TH>

        </TR>

        </thead>
        <tbody id="geneListFilter" style="display:none;">
        <TR>
            <td>
                Median TPM >= : <input type="text" id="filterTPM"><BR>
                Heritibility >=: <input type="text" id="filterHerit"><BR>
                Has cis-eQTL:<input type="checkbox" id="filterCis"> <BR>
                Has trans-eQTL: <input type="checkbox" id="filterTrans"><BR>

            </td>
            <td>
                <div class="columnLeft">
                    <%if (myOrganism.equals("Rn")) {%>
                    <input name="chkbox" type="checkbox" id="matchesCBX" value="matchesCBX" checked="checked"/> RNA-Seq Transcript Matches <span
                        class="geneListToolTip"
                        title="Shows/Hides a description of the reason the RNA-Seq transcript was matched to the Ensembl Gene/Transcript."><img
                        src="<%=imagesDir%>icons/info.gif"></span><BR/>
                    <%}%>

                    <input name="chkbox" type="checkbox" id="geneIDCBX" value="geneIDCBX" checked="checked"/> Gene ID <span class="geneListToolTip"
                                                                                                                            title="Shows/Hides the Gene ID column containing the Ensembl Gene ID and links to external Databases when available."><img
                        src="<%=imagesDir%>icons/info.gif"></span><BR/>

                    <input name="chkbox" type="checkbox" id="geneDescCBX" value="geneDescCBX" checked="checked"/> Description <span class="geneListToolTip"
                                                                                                                                    title="Shows/Hides Gene Description column whichcontains the Ensembl Description or any annotations for RNA-Seq transcripts not associated with an Ensembl Gene/Transcript"><img
                        src="<%=imagesDir%>icons/info.gif"></span><BR/>

                    <input name="chkbox" type="checkbox" id="geneLocCBX" value="geneLocCBX" checked="checked"/> Location and Strand <span
                        class="geneListToolTip" title="Shows/Hides the Chromosome, Start base pair, End base pair, and strand columns for the feature."><img
                        src="<%=imagesDir%>icons/info.gif"></span><BR/>


                </div>
                <div class="columnRight">
                    <input name="chkbox" type="checkbox" id="ensCBX" value="ensCBX"/> Ensembl Transcriptome Data <span class="geneListToolTip"
                                                                                                                       title="Shows/Hides all of the Affymetrix Probeset data."><img
                        src="<%=imagesDir%>icons/info.gif"></span><BR/>
                    <input name="chkbox" type="checkbox" id="reconstCBX" value="reconstCBX"/> Reconstruction Transcriptome Data <span
                        class="geneListToolTip" title="Shows/Hides all of the Affymetrix Probeset data."><img src="<%=imagesDir%>icons/info.gif"></span><BR/>
                    <input name="chkbox" type="checkbox" id="arrayCBX" value="arrayCBX"/> All Array Data <span class="geneListToolTip"
                                                                                                               title="Shows/Hides all of the Affymetrix Probeset data."><img
                        src="<%=imagesDir%>icons/info.gif"></span><BR/>
                    <!--<input name="chkbox" type="checkbox" id="heritCBX" value="heritCBX" checked="checked" /> Array Heritability <span class="geneListToolTip" title="Shows/Hides all of the Affymetrix Probeset Heritability data."><img src="<%=imagesDir%>icons/info.gif"></span><BR />
                                	
                                	<input name="chkbox" type="checkbox" id="dabgCBX" value="dabgCBX" checked="checked" /> Array Detection Above Background <span class="geneListToolTip" title="Shows/Hides all of the Affymetrix Probeset Detection Above Background data."><img src="<%=imagesDir%>icons/info.gif"></span><BR />
                                    
                                    <input name="chkbox" type="checkbox" id="eqtlAllCBX" value="eqtlAllCBX" checked="checked" /> Array eQTLs All <span class="geneListToolTip" title="Shows/Hides all of the eQTL columns."><img src="<%=imagesDir%>icons/info.gif"></span><BR />
                                    
                                    <input name="chkbox" type="checkbox" id="eqtlCBX" value="eqtlCBX" checked="checked" />Array eQTLs Tissues <span class="geneListToolTip" title="Shows/Hides all of the eQTL tissue specific columns while preserving a list of transcript clusters with a link to the circos plot."><img src="<%=imagesDir%>icons/info.gif"></span>-->
                </div>

            </TD>

        </TR>
        </tbody>

    </table>


    <%
        String[] hTissues = new String[0];
        String[] dTissues = new String[0];
        if (fullGeneList.size() > 0) {
            edu.ucdenver.ccp.PhenoGen.data.Bio.Gene tmpGene = fullGeneList.get(0);
    %>
    <div class="downloadBtns" style="text-align: left;margin-bottom: 10px;">Export As:</div>
    <TABLE name="items" id="tblGenes<%=type%>" class="list_base downloadTbl" cellpadding="0" cellspacing="0">
        <THEAD>
        <tr>
            <th
                    <%if (myOrganism.equals("Rn")) {%>
                    colspan="8"
                    <%} else {%>
                    colspan="6"
                    <%}%>
                    class="topLine noSort noBox" style="text-align:left;">
                <!--<span class="legendBtn"><img src="../web/images/icons/legend_7.png"><span style="position:relative;top:-7px;">Legend</span></span>--></th>
            <th
                    <%if (myOrganism.equals("Rn")) {%>
                    colspan="2"
                    <%} else {%>
                    colspan="2"
                    <%}%>
                    class="center noSort topLine">Transcript Information
            </th>
            <%if (myOrganism.equals("Rn")) {%>
            <th colspan="15" class="center noSort topLine" title="Ensembl Transcriptome HRDP v5 Ribosome Depleted TotalRNA Data">Ensembl Transcriptome HRDP v5
                Ribosome Depleted TotalRNA
                <div class="inpageHelp" style="display:inline-block; "><img id="HelpRNASeqSummary" class="helpImage" src="../web/images/icons/help.png"/></div>
            </th>
            <th colspan="15" class="center noSort topLine" title="Reconstruction Transcriptome HRDP v5 Ribosome Depleted TotalRNA Data">Reconstruction
                Transcriptome HRDP v5 Ribosome Depleted TotalRNA
                <div class="inpageHelp" style="display:inline-block; "><img id="HelpRNASeqSummary" class="helpImage" src="../web/images/icons/help.png"/></div>
            </th>
            <%}%>
            <th colspan="<%=4+tissuesList1.length*2+tissuesList2.length*2%>" class="center noSort topLine"
                title="Dataset is available by going to Microarray Analysis Tools -> Analyze Precompiled Dataset or Downloads.">Affy Exon 1.0 ST PhenoGen Public
                Dataset(
                <%if (myOrganism.equals("Mm")) {%>
                Public ILSXISS RI Mice
                <%} else {%>
                Public HXB/BXH RI Rats (Tissue, Exon Arrays)
                <%}%>
                )
                <div class="inpageHelp" style="display:inline-block; "><img id="HelpAffyExon" class="helpImage" src="../web/images/icons/help.png"/></div>
            </th>
        </tr>
        <tr style="text-align:center;">
            <th
                    <%if (myOrganism.equals("Rn")) {%>
                    colspan="8"
                    <%} else {%>
                    colspan="6"
                    <%}%>
                    class="topLine noSort noBox"></th>
            <th colspan="1" class="leftBorder noSort"></th>
            <th colspan="1" class="rightBorder noSort"></th>
            <th colspan="5" class="leftBorder rightBorder topLine noSort">Whole Brain</th>
            <th colspan="5" class="leftBorder rightBorder topLine noSort">Liver</th>
            <th colspan="5" class="rightBorder topLine noSort">Kidney</th>
            <th colspan="5" class="leftBorder rightBorder topLine noSort">Whole Brain</th>
            <th colspan="5" class="leftBorder rightBorder topLine noSort">Liver</th>
            <th colspan="5" class="rightBorder topLine noSort">Kidney</th>
            <th colspan="1" class="leftBorder rightBorder noSort"></th>
            <th colspan="<%=tissuesList1.length%>" class="center noSort topLine">Probe Sets > 0.33 Heritability
                <div class="inpageHelp" style="display:inline-block; "><img id="HelpProbeHerit" class="helpImage" src="../web/images/icons/help.png"/></div>
            </th>
            <th colspan="<%=tissuesList1.length%>" class="center noSort topLine">Probe Sets > 1% DABG
                <div class="inpageHelp" style="display:inline-block; "><img id="HelpProbeDABG" class="helpImage" src="../web/images/icons/help.png"/></div>
            </th>
            <th colspan="<%=3+tissuesList2.length*2%>" class="center noSort topLine">eQTLs(Gene/Transcript Cluster ID)
                <div class="inpageHelp" style="display:inline-block; "><img id="HelpeQTL" class="helpImage" src="../web/images/icons/help.png"/></div>
            </th>
        </tr>
        <tr style="text-align:center;">
            <th
                    <%if (myOrganism.equals("Rn")) {%>
                    colspan="5"
                    <%} else {%>
                    colspan="4"
                    <%}%>
                    class="topLine noSort noBox"></th>

            <th
                    <%if (myOrganism.equals("Rn")) {%>
                    colspan="3"
                    <%} else {%>
                    colspan="2"
                    <%}%>
                    class="topLine noSort noBox"></th>
            <th
                    <%if (myOrganism.equals("Rn")) {%>
                    colspan="2"
                    <%} else {%>
                    colspan="1"
                    <%}%>
                    class="topLine leftBorder rightBorder noSort"># Transcripts <span class="geneListToolTip"
                                                                                      title="The number of transcripts assigned to this gene.  Ensembl is the number of ensembl annotated transcripts.  RNA-Seq is the number of RNA-Seq transcripts assigned to this gene.  The RNA-Seq Transcript Matches column contains additional details about why transcripts were or were not matched to a particular gene."><img
                    src="<%=imagesDir%>icons/info.gif"></span></th>
            <th colspan="2" class="leftBorder rightBorder noSort noBox">TPM</th>
            <th colspan="1" class="leftBorder rightBorder noSort noBox"></th>
            <th colspan="2" class="leftBorder rightBorder noSort noBox">eQTL</th>
            <th colspan="2" class="leftBorder rightBorder noSort noBox">TPM</th>
            <th colspan="1" class="leftBorder rightBorder noSort noBox"></th>
            <th colspan="2" class="leftBorder rightBorder noSort noBox">eQTL</th>
            <th colspan="2" class="leftBorder rightBorder noSort noBox">TPM</th>
            <th colspan="1" class="leftBorder rightBorder noSort noBox"></th>
            <th colspan="2" class="leftBorder rightBorder noSort noBox">eQTL</th>
            <th colspan="2" class="leftBorder rightBorder noSort noBox">TPM</th>
            <th colspan="1" class="leftBorder rightBorder noSort noBox"></th>
            <th colspan="2" class="leftBorder rightBorder noSort noBox">eQTL</th>
            <th colspan="2" class="leftBorder rightBorder noSort noBox">TPM</th>
            <th colspan="1" class="leftBorder rightBorder noSort noBox"></th>
            <th colspan="2" class="leftBorder rightBorder noSort noBox">eQTL</th>
            <th colspan="2" class="leftBorder rightBorder noSort noBox">TPM</th>
            <th colspan="1" class="leftBorder rightBorder noSort noBox"></th>
            <th colspan="2" class="leftBorder rightBorder noSort noBox">eQTL</th>
            <th colspan="1" class="leftBorder rightBorder noSort"></th>
            <th colspan="<%=tissuesList1.length%>" class="leftBorder rightBorder noSort noBox"></th>
            <th colspan="<%=tissuesList1.length%>" class="leftBorder rightBorder noSort noBox"></th>
            <th colspan="1" class="leftBorder noSort"></th>
            <th colspan="2" class="noBox noSort"></th>
            <%for (int i = 0; i < tissuesList2.length; i++) {%>
            <TH colspan="2" class="center noSort topLine"><%=tissuesList2[i]%>
            </TH>
            <%}%>
        </tr>

        <tr class="col_title">
            <TH>Image ID (Transcript/Feature ID) <span class="geneListToolTip"
                                                       title="Feature IDs that correspond to features in the various image tracks above.<%if(myOrganism.equals("Rn")){%> In addition to Ensembl transcripts, RNA-Seq transcripts, that begin with the tissue where they were identified, will be listed in this column, when they partially or fully match to an Ensembl transcript.  If none are listed there was not a match that met our matching criteria. Please refer to the next column for a description of matching criteria.<%}%>"><img
                    src="<%=imagesDir%>icons/info.gif"></span></TH>
            <%if (myOrganism.equals("Rn")) {%>
            <TH>RNA-Seq Transcript Matches <span class="geneListToolTip"
                                                 title="Information about how a RNA-Seq transcript was matched to an Ensembl Gene/Transcript.  Click if a + icon is present to view the remaining transcripts.<BR><BR>Any partial matches first list the percentage of exons matched and the transcript that was the closest match.<BR> An exon for exon match to a transcript lists the Ensembl Transcript ID and then the # of exons matching each rule. <BR><BR> Rules:<BR>-Perfect Match-the start and stop base pairs exactly align.<BR>-Fuzzy Match-the start and stop base pairs are within 5bp.<BR>-3'/5' Extended/truncated the 3'/5' end of the RNA-Seq transcript is extended or truncated.<BR>-Internal Exon extended/shifted exons not at the begining or end of the transcript and are noted as either extended at a single end or both ends or shifted in one direction.<BR><BR>Additional Rules:<BR>Cufflinks assigns transcripts to genes and on occassion transcripts in the same Cufflinks gene will match to transcripts from different genes.  In this instance the message will reflect that the transcript was assigned to a different gene but changed assignment based on another transcript belonging to the same Cufflinks gene matching a different Ensembl gene.<BR>In other instances Cufflinks created a transcript that spans multiple genes.  It can either be assigned to a specific gene based on other transcripts in the Cufflinks gene or not assigned to a gene.  In either instance it will be noted that the transcript spans multiple genes."><img
                    src="<%=imagesDir%>icons/info.gif"></span></th>
            <%}%>
            <TH>Gene Symbol<span class="geneListToolTip"
                                 title="The Gene Symbol from Ensembl if available.  Click to view detailed information for that gene."><img
                    src="<%=imagesDir%>icons/info.gif"></span></TH>
            <TH>Gene ID</TH>
            <TH width="10%">Gene Description <span class="geneListToolTip"
                                                   title="The description from Ensembl or annotations from various sources if the feature is not found in Ensembl."><img
                    src="<%=imagesDir%>icons/info.gif"></span></TH>
            <TH>Location</TH>
            <TH>Strand</TH>
            <%if (myOrganism.equals("Rn")) {%>
            <TH>Exon SNPs / Indels <span class="geneListToolTip"
                                         title="A count of SNPs and indels identified in the DNA-Seq data for the BN-Lx and SHR strains that fall within an exon (including untranslated regions) of at least one transcript.  Number of SNPs is on the left side of the / number of indels is on the right.  Counts are summarized for each strain when compared to the BN reference genome (Rn5).  When the same SNP/indel occurs in both, a count of the common SNPs/indels is included.  When these common counts occur they have been subtracted from the strain specific counts."><img
                    src="<%=imagesDir%>icons/info.gif"></span></TH>
            <%}%>
            <TH>Ensembl</TH>
            <%if (myOrganism.equals("Rn")) {%>
            <TH>RNA-Seq</TH>
            <TH>Median</TH>
            <TH>Range</TH>
            <TH>Heritibility</TH>
            <TH>cis</TH>
            <TH>trans</TH>
            <TH>Median</TH>
            <TH>Range</TH>
            <TH>Heritibility</TH>
            <TH>cis</TH>
            <TH>trans</TH>
            <TH>Median</TH>
            <TH>Range</TH>
            <TH>Heritibility</TH>
            <TH>cis</TH>
            <TH>trans</TH>
            <TH>Median</TH>
            <TH>Range</TH>
            <TH>Heritibility</TH>
            <TH>cis</TH>
            <TH>trans</TH>
            <TH>Median</TH>
            <TH>Range</TH>
            <TH>Heritibility</TH>
            <TH>cis</TH>
            <TH>trans</TH>
            <TH>Median</TH>
            <TH>Range</TH>
            <TH>Heritibility</TH>
            <TH>cis</TH>
            <TH>trans</TH>
            <%}%>

            <TH>Total Probe Sets <span class="geneListToolTip"
                                       title="The total number of non-masked probesets that overlap with any region of an Ensembl transcript<%if(myOrganism.equals("Rn")){%> or an RNA-Seq transcript<%}%>."><img
                    src="<%=imagesDir%>icons/info.gif"></span></TH>

            <%for (int i = 0; i < tissuesList1.length; i++) {%>
            <TH><%=tissuesList1[i]%> Count
                <HR/>
                (Avg)</span></TH>
            <%}%>
            <%for (int i = 0; i < tissuesList1.length; i++) {%>
            <TH><%=tissuesList1[i]%> Count
                <HR/>
                (Avg)</span></TH>
            <%}%>
            <TH>Transcript Cluster ID <span class="geneListToolTip"
                                            title="Transcript Cluster ID- The unique ID assigned by Affymetrix.  eQTLs are calculated for this annotation at the gene level by combining probe set data across the gene."><img
                    src="<%=imagesDir%>icons/info.gif"></span></TH>
            <TH>Annotation Level <span class="geneListToolTip"
                                       title="The annotation level of the Transcript Cluster.  This denotes the confidence in the annotation by Affymetrix.  The confidence decreases from highest to lowest in the following order: Core,Extended,Full,Ambiguous."><img
                    src="<%=imagesDir%>icons/info.gif"></span></TH>
            <TH>View Genome-Wide Associations<span class="geneListToolTip"
                                                   title="Genome Wide Associations- Shows all the locations with a P-value below the cutoff selected.  Circos is used to create a plot of each region in each tissue associated with expression of the gene selected."><img
                    src="<%=imagesDir%>icons/info.gif"></span></TH>
            <%for (int i = 0; i < tissuesList2.length; i++) {%>
            <TH># of eQTLs with p-value < <%=forwardPValueCutoff%> <span class="geneListToolTip"
                                                                         title="The number of regions in the genome significantly associated with transcript cluster expression (p-value < currently selected cut-off(see Filter List)), i.e. the number of eQTL."><img
                    src="<%=imagesDir%>icons/info.gif"></span></TH>
            <TH>Minimum<BR/> P-Value
                <HR/>
                Location <span class="geneListToolTip"
                               title="The genomic location of the most significant eQTL for this transcript clusters.  Click the location to view that region."><img
                        src="<%=imagesDir%>icons/info.gif"></span></TH>
            <%}%>
        </tr>
        </thead>

        <tbody style="text-align:center;">


        <%
            DecimalFormat df2 = new DecimalFormat("#.##");
            DecimalFormat df0 = new DecimalFormat("###");
            DecimalFormat df4 = new DecimalFormat("#.####");
            DecimalFormat dfe = new DecimalFormat("0.##E0");
            Object[] geneIDs = geneHM.keySet().toArray();
            StringBuilder geneIDList = new StringBuilder();
            for (int i = 0; i < geneIDs.length; i++) {
                geneIDList.append(",'" + geneIDs[i] + "'");
            }
            HashMap<String, HashMap<String, HashMap<String, Double>>> tpm = new HashMap<String, HashMap<String, HashMap<String, Double>>>();
            if (geneIDList.length() > 1) {
                tpm = gdt.getTPM(geneIDList.substring(1), "97,98");
            }
            for (int i = 0; i < fullGeneList.size(); i++) {
                edu.ucdenver.ccp.PhenoGen.data.Bio.Gene curGene = fullGeneList.get(i);
                if (geneHM.containsKey(curGene.getGeneID())) {
                    TranscriptCluster tc = curGene.getTranscriptCluster();
                    HashMap hCount = curGene.getHeritCounts();
                    HashMap dCount = curGene.getDabgCounts();
                    HashMap hSum = curGene.getHeritAvg();
                    HashMap dSum = curGene.getDabgAvg();
                    String chr = curGene.getChromosome();
                    String viewClass = "codingRNA";
                    ArrayList<edu.ucdenver.ccp.PhenoGen.data.Bio.Transcript> tmpTrx = curGene.getTranscripts();
                    if (!chr.startsWith("chr")) {
                        chr = "chr" + chr;
                    }

                    if ((curGene.getBioType().equals("protein_coding") && curGene.getLength() >= 200 && type.equals("coding")) ||
                            (!curGene.getBioType().equals("protein_coding") && curGene.getLength() >= 200 && type.equals("noncoding")) ||
                            (type.equals("all"))
                    ) {


                        if ((source.equals("ensembl") && curGene.getGeneID().startsWith("ENS")) ||    //ensembl track


                                source.equals("merged") || // merged track
                                source.equals("brain") ||    //Brain track
                                source.equals("liver") ||    //Liver track
                                source.equals("heart")
                                                                /*source.equals("merged") || // merged track
								(source.equals("brain")&&(curGene.getGeneID().toLowerCase().startsWith("brain")||curGene.containsTranscripts("brain")))||	//Brain track
								(source.equals("liver")&&(curGene.getGeneID().toLowerCase().startsWith("liver")||curGene.containsTranscripts("liver")))||	//Liver track
								(source.equals("heart")&&(curGene.getGeneID().toLowerCase().startsWith("heart")||curGene.containsTranscripts("heart")))*/
                        ) {
        %>

        <TR class="
                            <% String geneID="";
                            if(curGene.getSource().equals("RNA Seq")&&curGene.isSingleExon()){%>
                                singleExon
                            <%}
                            if(tc!=null){%>
                                eqtl
                            <%}
                            if(curGene.getBioType().equals("protein_coding") && curGene.getLength()>=200){%>
                                coding
                            <%}else if(!curGene.getBioType().equals("protein_coding") && curGene.getLength()>=200){
									if(curGene.getGeneID().toLowerCase().startsWith("liver")){%>
										liver
									<%}else if(curGene.getGeneID().toLowerCase().startsWith("heart")){%>
										heart
									<%}else{
                                    	viewClass="longRNA";%>
                                    	noncoding
                                    <%}%>
                             <%}else if(curGene.getLength()<200){
                                    viewClass="smallRNA";%>
                                    smallnc
                            <%}%>
                            <%if(curGene.getGeneID().startsWith("ENS")){%>
                                ensembl
                            <%}%>
                            ">
            <TD>
                <% String tmpList = "";
                    if ((curGene.getTranscriptCountRna() + curGene.getTranscriptCountEns()) > 5) {
                        tmpList = "<span class=\"tblTrigger\" name=\"fg_" + i + "\">";
                        for (int l = 0; l < tmpTrx.size(); l++) {
                            if (l < 5) {
                                tmpList = tmpList + tmpTrx.get(l).getIDwToolTip() + "<BR>";
                            } else if (l == 5) {
                                tmpList = tmpList + "</span><span id=\"fg_" + i + "\" style=\"display:none;\">" + tmpTrx.get(l).getIDwToolTip() + "<BR>";
                            } else {
                                tmpList = tmpList + tmpTrx.get(l).getIDwToolTip() + "<BR>";
                            }
                        }
                        tmpList = tmpList + "</span>";
                    } else {
                        for (int l = 0; l < tmpTrx.size(); l++) {
                            if (l == 0) {
                                tmpList = tmpTrx.get(l).getIDwToolTip() + "<BR>";
                            } else {
                                tmpList = tmpList + tmpTrx.get(l).getIDwToolTip() + "<BR>";
                            }
                        }
                    }%>
                <%=tmpList%>
            </TD>
            <%if (myOrganism.equals("Rn")) {%>
            <TD>
                <% String tmpList2 = "";
                    if (curGene.getGeneID().startsWith("ENS")) {
                        tmpList2 = "";
                        int idx = 0;
                        for (int l = 0; l < tmpTrx.size(); l++) {
                            if (!tmpTrx.get(l).getID().startsWith("ENS")) {
                                tmpList2 = tmpList2 + "<B>" + tmpTrx.get(l).getID() + "</B> - <BR>" + tmpTrx.get(l).getMatchReason() + "<BR>";
                                idx++;
                            }
                        }
                        if (idx > 1) {
                            tmpList2 = "<span class=\"tblTrigger\" name=\"rg_" + i + "\">" + tmpList2;
                            int ind1 = tmpList2.indexOf("<BR>");
                            int ind2 = tmpList2.indexOf("<BR>", ind1 + 4);
                            String newTmp = tmpList2.substring(0, ind2);
                            tmpList2 = newTmp + "</span><BR><span id=\"rg_" + i + "\" style=\"display:none;\">" + tmpList2.substring(ind2 + 4);
                            tmpList2 = tmpList2 + "</span>";
                        }

                    }
                %>
                <%=tmpList2%>
            </TD>
            <%}%>
            <TD title="View detailed transcription information for gene in a new window."><!--Gene Symbol-->
                <%if (curGene.getGeneID().startsWith("ENS")) {%>
                <a href="<%=lg.getGeneLink(curGene.getGeneID(),myOrganism,true,true,false)%>" target="_blank">
                        <%}else{%>
                    <a href="<%=lg.getRegionLink(chr,curGene.getStart(),curGene.getEnd(),myOrganism,true,true,false)%>" target="_blank">
                        <%}%>
                        <%
                            if (curGene.getGeneSymbol() != null && !curGene.getGeneSymbol().equals("")) {
                                geneID = curGene.getGeneSymbol();
                        %>
                        <%=curGene.getGeneSymbol()%>
                        <%
                        } else {
                            geneID = curGene.getGeneID();
                        %>
                        No Gene Symbol
                        <%}%>
                    </a>
            </TD>
            <%
                String description = curGene.getDescription();
                String shortDesc = description;

                String remain = "";
                if (description.indexOf("[") > 0) {
                    shortDesc = description.substring(0, description.indexOf("["));
                    remain = description.substring(description.indexOf("[") + 1, description.indexOf("]"));
                }
            %>
            <TD><!--Gene ID-->
                <%if (curGene.getGeneID().startsWith("ENS")) {%>
                <a href="<%=LinkGenerator.getEnsemblLinkEnsemblID(curGene.getGeneID(),fullOrg)%>" target="_blank"
                   title="View Ensembl Gene Details"><%=curGene.getGeneID()%>
                </a><BR/>
                <span style="font-size:10px;">
                                        <%

                                            String tmpGS = curGene.getGeneID();
                                            String shortOrg = "Mouse";
                                            String allenID = "";
                                            if (myOrganism.equals("Rn")) {
                                                shortOrg = "Rat";
                                            }
                                            if (curGene.getGeneSymbol() != null && !curGene.getGeneSymbol().equals("")) {
                                                tmpGS = curGene.getGeneSymbol();
                                                allenID = curGene.getGeneSymbol();
                                            }
                                            if (allenID.equals("") && !shortDesc.equals("")) {
                                                allenID = shortDesc;
                                            }%>
                                            All Organisms:<a href="<%=LinkGenerator.getNCBILink(tmpGS)%>" target="_blank">NCBI</a> |
                                            <a href="<%=LinkGenerator.getUniProtLinkGene(tmpGS)%>" target="_blank">UniProt</a> <BR/>
                                           <%=shortOrg%>: <a href="<%=LinkGenerator.getNCBILink(tmpGS,myOrganism)%>" target="_blank">NCBI</a> | <a
                        href="<%=LinkGenerator.getUniProtLinkGene(tmpGS,myOrganism)%>" target="_blank">UniProt</a> |
                                            <%if (myOrganism.equals("Mm")) {%>
                                                <a href="<%=LinkGenerator.getMGILink(tmpGS)%>" target="_blank">MGI</a> 
                                                <%if (!allenID.equals("")) {%>
                                                    | <a href="<%=LinkGenerator.getBrainAtlasLink(allenID)%>" target="_blank">Allen Brain Atlas</a>
                                                <%}%>
                                            <%} else {%>
                                                <a href="<%=LinkGenerator.getRGDLink(tmpGS,myOrganism)%>" target="_blank">RGD</a>
                                            <%}%>
                                         </span>
                <%} else {%>
                <%=curGene.getGeneID()%>
                <%}%>
            </TD>

            <%
                String bioType = curGene.getBioType();
                HashMap displayed = new HashMap();
                HashMap bySource = new HashMap();
                for (int k = 0; k < tmpTrx.size(); k++) {
                    ArrayList<edu.ucdenver.ccp.PhenoGen.data.Bio.Annotation> annot = tmpTrx.get(k).getAnnotation();
                    if (annot != null && annot.size() > 0) {
                        for (int j = 0; j < annot.size(); j++) {
                            if (!annot.get(j).getSource().equals("AKA") && !annot.get(j).getSource().equals("AlignedSequences")) {
                                String tmpHTML = annot.get(j).getDisplayHTMLString(true);
                                if (!displayed.containsKey(tmpHTML)) {
                                    displayed.put(tmpHTML, 1);
                                    if (bySource.containsKey(annot.get(j).getSource())) {
                                        String list = bySource.get(annot.get(j).getSource()).toString();
                                        list = list + ", " + tmpHTML;
                                        bySource.put(annot.get(j).getSource(), list);
                                    } else {
                                        bySource.put(annot.get(j).getSource(), tmpHTML);
                                    }

                                }
                            }
                        }
                    }
                }
                Set keys = bySource.keySet();
                Iterator itr = keys.iterator();
            %>
            <TD title="<%=remain%>"><!--DEscription -->
                <%=shortDesc.trim().replaceAll("-", "&nbsp;")%>
                <%
                    while (itr.hasNext()) {
                        String sourceItr = itr.next().toString();
                        String values = bySource.get(sourceItr).toString();
                %>
                <BR>
                <%=sourceItr.trim() + ":" + values.trim()%>
                <%}%>
            </TD>

            <TD><%=chr + ": " + dfC.format(curGene.getStart()) + "-" + dfC.format(curGene.getEnd())%>
            </TD><!--location-->
            <TD><%=curGene.getStrand()%>
            </TD><!--Strand-->
            <%if (myOrganism.equals("Rn")) {%>
            <TD><!--SNPS-->
                <%if (curGene.getSnpCount("common", "SNP") > 0 || curGene.getSnpCount("common", "Indel") > 0) {%>
                Common:<BR/><%=curGene.getSnpCount("common", "SNP")%> / <%=curGene.getSnpCount("common", "Indel")%><BR/>
                <%}%>
                <%if (curGene.getSnpCount("BNLX", "SNP") > 0 || curGene.getSnpCount("BNLX", "Indel") > 0) {%>
                BN-Lx:<BR/><%=curGene.getSnpCount("BNLX", "SNP")%> / <%=curGene.getSnpCount("BNLX", "Indel")%><BR/>
                <%}%>
                <%if (curGene.getSnpCount("SHRH", "SNP") > 0 || curGene.getSnpCount("SHRH", "Indel") > 0) {%>
                SHR:<BR/><%=curGene.getSnpCount("SHRH", "SNP")%> / <%=curGene.getSnpCount("SHRH", "Indel")%><BR/>
                <%}%>
                <%if (curGene.getSnpCount("SHRJ", "SNP") > 0 || curGene.getSnpCount("SHRJ", "Indel") > 0) {%>
                SHRJ:<BR/><%=curGene.getSnpCount("SHRJ", "SNP")%> / <%=curGene.getSnpCount("SHRJ", "Indel")%><BR/>
                <%}%>
                <%if (curGene.getSnpCount("F344", "SNP") > 0 || curGene.getSnpCount("F344", "Indel") > 0) {%>
                F344:<BR/><%=curGene.getSnpCount("F344", "SNP")%> / <%=curGene.getSnpCount("F344", "Indel")%><BR/>
                <%}%>
            </TD>
            <%}%>
            <TD class="leftBorder"><%=curGene.getTranscriptCountEns()%>
            </TD><!--#transcripts-->
            <%if (myOrganism.equals("Rn")) {%>
            <TD><!--RNA Transcript count-->
                <%=curGene.getTranscriptCountRna()%>
            </TD>
            <%
                RNASeqHeritQTLData rna = curGene.getRNASeq();

                if (rna != null) {
                    String bHerit = "";
                    String lHerit = "";
                    String kHerit = "";
                    if (rna.getHerit("Whole Brain") >= 0) {
                        bHerit = df2.format(rna.getHerit("Whole Brain"));
                    }
                    if (rna.getHerit("Liver") >= 0) {
                        lHerit = df2.format(rna.getHerit("Liver"));
                    }
                    if (rna.getHerit("Kidney") >= 0) {
                        kHerit = df2.format(rna.getHerit("Kidney"));
                    }
                                    /*Double bPv=0.0;
                                    Double lPv=0.0;
                                    String bMax=rna.getMaxQTL("Whole Brain");
                                    if(!bMax.equals("")){
                                        bPv=Double.parseDouble(bMax.substring(0,bMax.indexOf(":")));
                                        bPv=Math.pow(10.0,-1*bPv);
                                        bMax="chr"+bMax.substring(bMax.indexOf(":")+1);
                                    }
                                    String lMax=rna.getMaxQTL("Liver");
                                    if(!lMax.equals("")){
                                        lPv=Double.parseDouble(lMax.substring(0,lMax.indexOf(":")));
                                        lPv=Math.pow(10.0,-1*lPv);
                                        lMax="chr"+lMax.substring(lMax.indexOf(":")+1);
                                    }*/

                    HashMap<String, Double> brain = null;
                    HashMap<String, Double> liver = null;
                    HashMap<String, Double> kidney = null;
                    if (tpm.containsKey("Brain") && tpm.get("Brain").containsKey(curGene.getGeneID())) {
                        brain = tpm.get("Brain").get(curGene.getGeneID());
                    }
                    if (tpm.containsKey("Liver") && tpm.get("Liver").containsKey(curGene.getGeneID())) {
                        liver = tpm.get("Liver").get(curGene.getGeneID());
                    }
                    if (tpm.containsKey("Kidney") && tpm.get("Kidney").containsKey(curGene.getGeneID())) {
                        kidney = tpm.get("Kidney").get(curGene.getGeneID());
                    }
                    String cisValueB = rna.getMinCisQTL("Whole Brain", "ensembl");
                    double cisPvalB = -1;
                    String cisLocationB = "";
                    if (cisValueB != null && !cisValueB.equals("")) {
                        cisPvalB = Double.parseDouble(cisValueB.substring(0, cisValueB.indexOf(":")));
                        cisLocationB = "chr" + cisValueB.substring(cisValueB.indexOf(":") + 1);
                    }
                    String transValueB = rna.getMinTransQTL("Whole Brain", "ensembl");
                    double transPvalB = -1;
                    String transLocationB = "";
                    if (transValueB != null && !transValueB.equals("")) {
                        transPvalB = Double.parseDouble(transValueB.substring(0, transValueB.indexOf(":")));
                        transLocationB = "chr" + transValueB.substring(transValueB.indexOf(":") + 1);
                    }
                    String cisValueL = rna.getMinCisQTL("Liver", "ensembl");
                    double cisPvalL = -1;
                    String cisLocationL = "";
                    if (cisValueL != null && !cisValueL.equals("")) {
                        cisPvalL = Double.parseDouble(cisValueL.substring(0, cisValueL.indexOf(":")));
                        cisLocationL = "chr" + cisValueL.substring(cisValueL.indexOf(":") + 1);
                    }
                    String transValueL = rna.getMinTransQTL("Liver", "ensembl");
                    double transPvalL = -1;
                    String transLocationL = "";
                    if (transValueL != null && !transValueL.equals("")) {
                        transPvalL = Double.parseDouble(transValueL.substring(0, transValueL.indexOf(":")));
                        transLocationL = "chr" + transValueL.substring(transValueL.indexOf(":") + 1);
                    }
                    String cisValueK = rna.getMinCisQTL("Kidney", "ensembl");
                    double cisPvalK = -1;
                    String cisLocationK = "";
                    if (cisValueK != null && !cisValueK.equals("")) {
                        cisPvalK = Double.parseDouble(cisValueK.substring(0, cisValueK.indexOf(":")));
                        cisLocationK = "chr" + cisValueK.substring(cisValueK.indexOf(":") + 1);
                    }
                    String transValueK = rna.getMinTransQTL("Kidney", "ensembl");
                    double transPvalK = -1;
                    String transLocationK = "";
                    if (transValueK != null && !transValueK.equals("")) {
                        transPvalK = Double.parseDouble(transValueK.substring(0, transValueK.indexOf(":")));
                        transLocationK = "chr" + transValueK.substring(transValueK.indexOf(":") + 1);
                    }
            %>
            <TD class="leftBorder"><%if (brain != null && brain.containsKey("ensmed")) {%><%=brain.get("ensmed")%><%}%></TD>
            <TD><%if (brain != null && brain.containsKey("ensmed")) {%><%=brain.get("ensmin")%>-<%=brain.get("ensmax")%><%}%></TD>
            <TD><%if (brain != null && brain.containsKey("geneHerit") && brain.get("geneHerit") > 0) {%><%=df2.format(brain.get("geneHerit"))%><%}%></TD>
            <TD><%if (cisPvalB > -1) {%><%=dfe.format(cisPvalB)%><BR><%=cisLocationB%><%}%></TD>
            <TD><%if (transPvalB > -1) {%><%=dfe.format(transPvalB)%><BR><%=transLocationB%><%}%></TD>
            <TD class="leftBorder"><%if (liver != null && liver.containsKey("ensmed")) {%><%=liver.get("ensmed")%><%}%></TD>
            <TD><%if (liver != null && liver.containsKey("ensmed")) {%><%=liver.get("ensmin")%>-<%=liver.get("ensmax")%><%}%></TD>
            <TD><%if (liver != null && liver.containsKey("geneHerit") && liver.get("geneHerit") > 0) {%><%=df2.format(liver.get("geneHerit"))%><%}%></TD>
            <TD><%if (cisPvalL > -1) {%><%=dfe.format(cisPvalL)%><BR><%=cisLocationL%><%}%></TD>
            <TD><%if (transPvalL > -1) {%><%=dfe.format(transPvalL)%><BR><%=transLocationL%><%}%></TD>
            <TD class="leftBorder"><%if (kidney != null && kidney.containsKey("ensmed")) {%><%=kidney.get("ensmed")%><%}%></TD>
            <TD><%if (kidney != null && kidney.containsKey("ensmed")) {%><%=kidney.get("ensmin")%>-<%=kidney.get("ensmax")%><%}%></TD>
            <TD><%if (kidney != null && kidney.containsKey("geneHerit") && kidney.get("geneHerit") > 0) {%><%=df2.format(kidney.get("geneHerit"))%><%}%></TD>
            <TD><%if (cisPvalK > -1) {%><%=dfe.format(cisPvalK)%><BR><%=cisLocationK%><%}%></TD>
            <TD><%if (transPvalK > -1) {%><%=dfe.format(transPvalK)%><BR><%=transLocationK%><%}%></TD>
            <%
                cisValueB = rna.getMinCisQTL("Whole Brain", "reconst");
                cisPvalB = -1;
                cisLocationB = "";
                if (cisValueB != null && !cisValueB.equals("")) {
                    cisPvalB = Double.parseDouble(cisValueB.substring(0, cisValueB.indexOf(":")));
                    cisLocationB = "chr" + cisValueB.substring(cisValueB.indexOf(":") + 1);
                }
                transValueB = rna.getMinTransQTL("Whole Brain", "reconst");
                transPvalB = -1;
                transLocationB = "";
                if (transValueB != null && !transValueB.equals("")) {
                    transPvalB = Double.parseDouble(transValueB.substring(0, transValueB.indexOf(":")));
                    transLocationB = "chr" + transValueB.substring(transValueB.indexOf(":") + 1);
                }
                cisValueL = rna.getMinCisQTL("Liver", "reconst");
                cisPvalL = -1;
                cisLocationL = "";
                if (cisValueL != null && !cisValueL.equals("")) {
                    cisPvalL = Double.parseDouble(cisValueL.substring(0, cisValueL.indexOf(":")));
                    cisLocationL = "chr" + cisValueL.substring(cisValueL.indexOf(":") + 1);
                }
                transValueL = rna.getMinTransQTL("Liver", "reconst");
                transPvalL = -1;
                transLocationL = "";
                if (transValueL != null && !transValueL.equals("")) {
                    transPvalL = Double.parseDouble(transValueL.substring(0, transValueL.indexOf(":")));
                    transLocationL = "chr" + transValueL.substring(transValueL.indexOf(":") + 1);
                }
                cisValueK = rna.getMinCisQTL("Kidney", "reconst");
                cisPvalK = -1;
                cisLocationK = "";
                if (cisValueK != null && !cisValueK.equals("")) {
                    cisPvalK = Double.parseDouble(cisValueK.substring(0, cisValueK.indexOf(":")));
                    cisLocationK = "chr" + cisValueK.substring(cisValueK.indexOf(":") + 1);
                }
                transValueK = rna.getMinTransQTL("Kidney", "reconst");
                transPvalK = -1;
                transLocationK = "";
                if (transValueK != null && !transValueK.equals("")) {
                    transPvalK = Double.parseDouble(transValueK.substring(0, transValueK.indexOf(":")));
                    transLocationK = "chr" + transValueK.substring(transValueK.indexOf(":") + 1);
                }
            %>

            <TD class="leftBorder"><%if (brain != null && brain.containsKey("reconmed")) {%><%=brain.get("reconmed")%><%}%></TD>
            <TD><%if (brain != null && brain.containsKey("reconmed")) {%><%=brain.get("reconmin")%>-<%=brain.get("reconmax")%><%}%></TD>
            <TD><%=bHerit%>
            </TD>
            <TD><%if (cisPvalB > -1) {%><%=dfe.format(cisPvalB)%><BR><%=cisLocationB%><%}%></TD>
            <TD><%if (transPvalB > -1) {%><%=dfe.format(transPvalB)%><BR><%=transLocationB%><%}%></TD>
            <TD class="leftBorder"><%if (liver != null && liver.containsKey("reconmed")) {%><%=liver.get("reconmed")%><%}%></TD>
            <TD><%if (liver != null && liver.containsKey("reconmed")) {%><%=liver.get("reconmin")%>-<%=liver.get("reconmax")%><%}%></TD>
            <TD><%=lHerit%>
            </TD>
            <TD><%if (cisPvalL > -1) {%><%=dfe.format(cisPvalL)%><BR><%=cisLocationL%><%}%></TD>
            <TD><%if (transPvalL > -1) {%><%=dfe.format(transPvalL)%><BR><%=transLocationL%><%}%></TD>
            <TD class="leftBorder"><%if (kidney != null && kidney.containsKey("reconmed")) {%><%=kidney.get("reconmed")%><%}%></TD>
            <TD><%if (kidney != null && kidney.containsKey("reconmed")) {%><%=kidney.get("reconmin")%>-<%=kidney.get("reconmax")%><%}%></TD>
            <TD><%=kHerit%>
            </TD>
            <TD><%if (cisPvalK > -1) {%><%=dfe.format(cisPvalK)%><BR><%=cisLocationK%><%}%></TD>
            <TD><%if (transPvalK > -1) {%><%=dfe.format(transPvalK)%><BR><%=transLocationK%><%}%></TD>
            <%} else {%>
            <TD class="leftBorder"></TD>
            <TD></TD>
            <TD></TD>
            <TD></TD>
            <TD></TD>
            <TD class="leftBorder"></TD>
            <TD></TD>
            <TD></TD>
            <TD></TD>
            <TD></TD>
            <TD class="leftBorder"></TD>
            <TD></TD>
            <TD></TD>
            <TD></TD>
            <TD></TD>
            <TD class="leftBorder"></TD>
            <TD></TD>
            <TD></TD>
            <TD></TD>
            <TD></TD>
            <TD class="leftBorder"></TD>
            <TD></TD>
            <TD></TD>
            <TD></TD>
            <TD></TD>
            <TD class="leftBorder"></TD>
            <TD></TD>
            <TD></TD>
            <TD></TD>
            <TD></TD>
            <%
                    }
                }
            %>

            <TD class="leftBorder"><%=curGene.getProbeCount()%>
            </TD>

            <%
                for (int j = 0; j < tissuesList1.length; j++) {
                    Object tmpH = hCount.get(tissuesList1[j]);
                    Object tmpHa = hSum.get(tissuesList1[j]);
                    if (tmpH != null) {
                        int count = Integer.parseInt(tmpH.toString());
                        double sum = Double.parseDouble(tmpHa.toString());
            %>
            <TD <%if(j==0){%>class="leftBorder"<%}%>>
                <%=count%>
                <%if (count > 0) {%>
                <BR/>
                (<%=df2.format(sum / count)%>)
                <%}%>
            </TD>
            <%} else {%>
            <TD <%if(j==0){%>class="leftBorder"<%}%>>
                N/A
            </TD>
            <%}%>
            <%}%>
            <%
                for (int j = 0; j < tissuesList1.length; j++) {
                    Object tmpD = dCount.get(tissuesList1[j]);
                    Object tmpDa = dSum.get(tissuesList1[j]);
                    if (tmpD != null) {
                        int count = Integer.parseInt(tmpD.toString());
                        double sum = Double.parseDouble(tmpDa.toString());
            %>
            <TD <%if(j==0){%>class="leftBorder"<%}%>><%=count%>
                <%if (count > 0) {%><BR/>(<%=df0.format(sum / count)%>%)<%}%>
            </TD>
            <%} else {%>
            <TD <%if(j==0){%>class="leftBorder"<%}%>>N/A</TD>
            <%}%>
            <%}%>
            <% if (tc != null) {%>
            <TD class="leftBorder"><%=tc.getTranscriptClusterID()%>
            </TD>
            <TD><%=tc.getLevel()%>
            </TD>
            <TD>
                <a href="web/GeneCentric/setupLocusSpecificEQTL.jsp?geneSym=<%=curGene.getGeneSymbol()%>&ensID=<%=curGene.getGeneID()%>&chr=<%=tc.getChromosome()%>&start=<%=tc.getStart()%>&stop=<%=tc.getEnd()%>&level=<%=tc.getLevel()%>&tcID=<%=tc.getTranscriptClusterID()%>&curDir=<%=folderName%>"
                   target="_blank" title="View the circos plot for transcript cluster eQTLs">View Location Plot</a>
            </TD>

            <%
                for (int j = 0; j < tissuesList2.length; j++) {
                    //log.debug("TABLE1:"+tissuesList2[j]);
                    ArrayList<EQTL> qtlList = tc.getTissueEQTL(tissuesList2[j]);
                    if (qtlList != null) {
                        EQTL maxEQTL = qtlList.get(0);
            %>
            <TD class="leftBorder"><%=qtlList.size()%>
            </TD>
            <TD>
                <%if (maxEQTL.getPVal() < 0.0001) {%>
                < 0.0001
                <%} else {%>
                <%=df4.format(maxEQTL.getPVal())%>
                <%}%>
                <BR/>
                <%if (maxEQTL.getMarker_start() != maxEQTL.getMarker_end()) {%>
                <a href="<%=lg.getRegionLink(maxEQTL.getMarkerChr(),maxEQTL.getMarker_start(),maxEQTL.getMarker_end(),myOrganism,true,true,false)%>"
                   target="_blank" title="View Detailed Transcription Information for this region.">
                    chr<%=maxEQTL.getMarkerChr() + ":" + dfC.format(maxEQTL.getMarker_start()) + "-" + dfC.format(maxEQTL.getMarker_end())%>
                </a>
                <%
                } else {
                    long start = maxEQTL.getMarker_start() - 500000;
                    long stop = maxEQTL.getMarker_start() + 500000;
                    if (start < 1) {
                        start = 1;
                    }
                %>
                <a href="<%=lg.getRegionLink(maxEQTL.getMarkerChr(),start,stop,myOrganism,true,true,false)%>" target="_blank"
                   title="View Detailed Transcription Information for a region +- 500,000bp around the SNP location.">
                    chr<%=maxEQTL.getMarkerChr() + ":" + dfC.format(maxEQTL.getMarker_start())%>
                </a>
                <%}%>
            </TD>
            <%} else {%>
            <TD class="leftBorder"></TD>
            <TD></TD>
            <%}%>
            <%}%>
            <%} else {%>
            <TD class="leftBorder"></TD>
            <TD></TD>
            <TD></TD>
            <%for (int j = 0; j < tissuesList2.length; j++) {%>
            <TD class="leftBorder"></TD>
            <TD></TD>
            <%}%>
            <%}%>
        </TR>
        <%}%>
        <%}%>
        <%}%>
        <%}%>

        </tbody>
    </table>
    <div class="downloadBtns" style="text-align: left;margin-top:10px;">Export As:</div>
    <script type="text/javascript">
        <%@ include file="/javascript/Anon_session.js"%>
    </script>
    <script type="text/javascript">
        var spec = "<%=myOrganism%>";

        /*
        $('.viewSMNC').click( function(event){
            var tmpID=$(this).attr('id');
            var id=tmpID.substr(0,tmpID.indexOf(":"));
            var name=tmpID.substr(tmpID.indexOf(":")+1);
            openSmallNonCoding(id,name);
            $('#viewTrxDialog').dialog( "option", "position",{ my: "center bottom", at: "center top", of: $(this) });
            $('#viewTrxDialog').dialog("open").css({'font-size':12});
        });*/


        var buttonCommon = {
            exportOptions: {
                format: {
                    /*header: function(data,row,column,node){
                      if(column<30){
                          return data;
                      }else{
                          return "";
                      }
                    },*/
                    body: function (data, row, column, node) {
                        data = data.replace(/(<.*?>)*/g, '');
                        if (column !== 0 && column !== 3) {
                            data = data.replace(/\s*/g, '');
                        } else if (column === 3) {
                            data = data.replace(/&nbsp;/g, ' ');
                        } else if (column === 0) {
                            data = data.replace(/PRN/g, ";PRN");
                            data = data.replace(/ENS/g, ";ENS");
                            data = data.substring(1);
                        }
                        if (data.indexOf("ENS") === 0 && data.indexOf("AllOrganisms:") > 0) {
                            data = data.substring(0, data.indexOf("AllOrganisms:"));
                        }
                        if (column === 7 || column === 8 || column === 9 || column === 11 || column === 14 || column === 16 || column === 19 || column === 21 || column === 24 || column === 26) {
                            data = '\u200C' + data;

                        } else if (column === 12 || column === 13 || column === 17 || column === 18 || column === 22 || column === 23 || column === 27 || column === 28) {
                            data = data.replace(/chr/g, ' ');
                        }
                        /*if(column>29){
                             data="";
                         }*/
                        return data;
                    }
                },
                columns: [0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29]
            }
        };

        //var geneTargets=[1];
        var sortCol = 5;
        if (spec == "Mm") {
            sortCol = 4;
        }
        var tblGenes = $('#tblGenes<%=type%>').DataTable({
            columnDefs: [
                <%if(track.contains("brain")){%>
                {
                    targets: [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59],
                    visible: false
                }
                <%}else if(track.contains("liver")){%>
                {
                    targets: [10, 11, 12, 13, 14, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59],
                    visible: false
                }
                <%}else if(track.contains("kidney")){%>
                {
                    targets: [10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59],
                    visible: false
                }
                <%}else if(track.contains("merged")){%>
                {
                    targets: [10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59],
                    visible: false
                }
                <%}else {%>
                {
                    targets: [25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59],
                    visible: false
                }
                <%}%>
            ],
            bPaginate: false,
            bProcessing: true,
            bStateSave: false,
            bAutoWidth: false,
            bDeferRender: false,
            sScrollX: "100%",
            sScrollY: "500px",
            aaSorting: [[sortCol, "desc"]],

            sDom: '<"leftSearch"fr><"rightSearch"i><t>',
            buttons: [
                $.extend(true, {}, buttonCommon, {
                    extend: 'copyHtml5'
                }),
                $.extend(true, {}, buttonCommon, {
                    extend: 'csvHtml5'
                }),
                $.extend(true, {}, buttonCommon, {
                    extend: 'excelHtml5'
                })
            ]
            /*"oTableTools": {
                    "sSwfPath": "/css/swf/copy_csv_xls_pdf.swf"
                }*/

        });
        $.fn.dataTable.ext.search.push(
            function (settings, data, dataIndex) {
                var ret = true;
                var minTPM = parseFloat($('#filterTPM').val());
                var minHerit = parseFloat($('#filterHerit').val());
                var tpm1 = parseFloat(data[10]) || 0;
                var tpm2 = parseFloat(data[15]) || 0;
                var tpm3 = parseFloat(data[20]) || 0;
                var tpm4 = parseFloat(data[25]) || 0;
                var h1 = parseFloat(data[12]) || 0;
                var h2 = parseFloat(data[17]) || 0;
                var h3 = parseFloat(data[22]) || 0;
                var h4 = parseFloat(data[27]) || 0;

                var cis1 = data[13];
                var cis2 = data[18];
                var cis3 = data[23];
                var cis4 = data[28];

                var trans1 = data[14];
                var trans2 = data[19];
                var trans3 = data[24];
                var trans4 = data[29];

                if (isNaN(minTPM) || (tpm1 >= minTPM || tpm2 >= minTPM || tpm3 >= minTPM || tpm4 >= minTPM)) {

                } else {
                    ret = false;
                }
                if (isNaN(minHerit) || (h1 >= minHerit || h2 >= minHerit || h3 >= minHerit || h4 >= minHerit)) {

                } else {
                    ret = false;
                }
                if (!$("#filterCis").is(":checked") || (cis1 != "" || cis2 != "" || cis3 != "" || cis4 != "")) {

                } else {
                    return false;
                }
                if (!$("#filterTrans").is(":checked") || (trans1 != "" || trans2 != "" || trans3 != "" || trans4 != "")) {

                } else {
                    return false;
                }
                return ret;
            }
        );
        $('#filterCis, #filterTrans').click(function () {
            tblGenes.draw();
        });
        $('#filterTPM, #filterHerit').keyup(function () {
            tblGenes.draw();
        });


        $('#tblGenes_wrapper').css({position: 'relative', top: '-56px'});

        $('#ensCBX').click(function () {
            var tmpCol = 10;
            var tmpEnd = 15;
            displayColumns(tblGenes, tmpCol, tmpEnd, $('#ensCBX').is(":checked"));
        });
        $('#reconstCBX').click(function () {
            var tmpCol = 25;
            var tmpEnd = 15;
            displayColumns(tblGenes, tmpCol, tmpEnd, $('#reconstCBX').is(":checked"));
        });
        $('#arrayCBX').click(function () {
            var tmpCol = 40;
            var tmpEnd = 20;
            if (spec == "Mm") {
                tmpCol = 7;
            }
            displayColumns(tblGenes, tmpCol, tmpEnd, $('#arrayCBX').is(":checked"));
        });
        $('#heritCBX').click(function () {
            var tmpCol = 11;
            if (spec == "Mm") {
                tmpCol = 7;
            }
            displayColumns(tblGenes, tmpCol, tisLen, $('#heritCBX').is(":checked"));
        });
        $('#dabgCBX').click(function () {
            var tmpCol = 11 + tisLen;
            if (spec == "Mm") {
                tmpCol = 7 + tisLen;
            }
            displayColumns(tblGenes, tmpCol, tisLen, $('#dabgCBX').is(":checked"));
        });
        $('#eqtlAllCBX').click(function () {
            var tmpCol = 11 + tisLen * 2;
            if (spec == "Mm") {
                tmpCol = 7 + tisLen * 2;
            }
            displayColumns(tblGenes, tmpCol, tisLen * 2 + 3, $('#eqtlAllCBX').is(":checked"));
        });
        $('#eqtlCBX').click(function () {
            var tmpCol = 11 + tisLen * 2 + 3;
            if (spec == "Mm") {
                tmpCol = 7 + tisLen * 2 + 3;
            }
            displayColumns(tblGenes, tmpCol, tisLen * 2, $('#eqtlCBX').is(":checked"));
        });
        $('#matchesCBX').click(function () {
            displayColumns(tblGenes, 1, 1, $('#matchesCBX').is(":checked"));
        });
        $('#geneIDCBX').click(function () {
            var tmpCol = 3;
            if (spec == "Mm") {
                tmpCol = 2;
            }
            displayColumns(tblGenes, tmpCol, 1, $('#geneIDCBX').is(":checked"));
        });
        $('#geneDescCBX').click(function () {
            var tmpCol = 4;
            if (spec == "Mm") {
                tmpCol = 3;
            }
            displayColumns(tblGenes, tmpCol, 1, $('#geneDescCBX').is(":checked"));
        });


        $('#geneLocCBX').click(function () {
            var tmpCol = 5;
            if (spec == "Mm") {
                tmpCol = 4;
            }
            displayColumns(tblGenes, tmpCol, 2, $('#geneLocCBX').is(":checked"));
        });

        $('#pvalueCutoffSelect1').change(function () {
            $("#wait1").show();
            $('#forwardPvalueCutoffInput').val($(this).val());
            //alert($('#pvalueCutoffInput').val());
            //$('#geneCentricForm').attr("action","Get Transcription Details");
            $('#geneCentricForm').submit();
        });
        $('#exclude1Exon').click(function () {
            if ($('#exclude1Exon').is(":checked")) {
                $('.singleExon').hide();
            } else {
                $('.singleExon').show();
            }
        });

        $("span.tblTrigger").click(function () {
            var baseName = $(this).attr("name");
            var thisHidden = $("span#" + baseName).is(":hidden");
            $(this).toggleClass("less");
            if (thisHidden) {
                $("span#" + baseName).show();
            } else {
                $("span#" + baseName).hide();
            }
        });

        $('.geneListToolTip').tooltipster({
            position: 'top-right',
            maxWidth: 450,
            offsetX: 8,
            offsetY: 5,
            contentAsHTML: true,
            //arrow: false,
            interactive: true,
            interactiveTolerance: 350
        });

        //below fixes a bug in IE9 where some whitespace may cause an extra column in random rows in large tables.
        //simply remove all whitespace from html in a table and put it back.
        if (/MSIE (\d+\.\d+);/.test(navigator.userAgent)) { //test for MSIE x.x;
            var ieversion = new Number(RegExp.$1) // capture x.x portion and store as a number
            if (ieversion < 10) {
                var expr = new RegExp('>[ \t\r\n\v\f]*<', 'g');
                var tbhtml = $('#tblGenes<%=type%>').html();
                $('#tblGenes<%=type%>').html(tbhtml.replace(expr, '><'));

            }
        }

        var tmpContainer = tblGenes;

    </script>
    <%@ include file="/web/GeneCentric/include/saveToGeneList.jsp" %>

    <script>
        var creategeneList = PhenoGenGeneList(tblGenes, 3);
    </script>

    <%} else {%>
    No genes found in this region. Please expand the region and try again.
    <%}%>

</div>
<!-- end GeneList-->



