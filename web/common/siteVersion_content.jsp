<%--
 *  Author: Cheryl Hornbaker
 *  Created: March, 2009
 *  Description:  The web page created by this file displays info on the versions the site is running.        
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>


<jsp:useBean id="myDbUtils" class="edu.ucdenver.ccp.PhenoGen.util.DbUtils"></jsp:useBean>
<%
    extrasList.add("normalize.css");
    extrasList.add("index.css");
    String dbVersion = "";
    String dbUpdateDate = "";

    if (pool != null) {
        String[] versionValues = myDbUtils.getDBVersion(pool);
        dbVersion = versionValues[0];
        dbUpdateDate = versionValues[1];
    }
    //mySessionHandler.createSessionActivity(session.getId(), "Looked at site version page", dbConn);

%>


<h2>PhenoGen Website Version</h2>
<%if (dbVersion.equals("") && dbUpdateDate.equals("")) {%>
<p>
    Version: Temporarily Unavailable <BR>
    Last updated: Temporarily Unavailable
</p>
<%} else {%>
<p>
    Version: &nbsp; <%=dbVersion%> <BR>
    Last updated: &nbsp; <%=dbUpdateDate%>
</p>
<%}%>
<BR><BR>
<h2>Tools Used on This Website</h2>
<p><a href="http://www.cisreg.ca/cgi-bin/oPOSSUM/opossum" target="POSSUM Master">Promoter (oPOSSUM)</a>:&nbsp;&nbsp; version 2.0</p>
<p><a href="http://meme.nbcr.net/meme" target="MEME Master">Promoter (MEME)</a>:&nbsp;&nbsp; version 4.10 patch 4</p>
<p><a href="http://www.r-project.org/" target="R Master">R</a>:&nbsp;&nbsp;version 3.4.1</p>
<p><a href="http://www.bioconductor.org/" target="R Master">BioConductor</a>:&nbsp;&nbsp;version 3.0</p>
<p><a href="http://multimir.ucdenver.edu/" target="_blank">multiMiR</a>:&nbsp;&nbsp;version 1.12.0 and Database version 2.3</p>
<p><a href="http://circos.ca/" target="_blank">CIRCOS</a>:&nbsp;&nbsp;version 0.69-4</p>
<p><a href="http://d3js.org/" target="_blank">D3js</a>:&nbsp;&nbsp;version 4.8</p>
<p><a href="http://jquery.com/" target="_blank">jQuery & jQuery UI</a>:&nbsp;&nbsp;version 1.11.2 and 1.11.3</p>

<!-- <p><a href="http://www.atlassian.com/" target="JIRA">JIRA</a>: &nbsp;&nbsp;version 3.1.1-#81 Professional Edition</p> -->
<BR><BR>
<h2>Genome Data Browser Annotations</h2>
<ul>
    <li>Ensembl v111,Rn6-Ensembl v105, except Rn5-v79</li>
    <li>RefSeq(source:UCSC Genome Browser): Downloaded 2/2022 except rn6- ,rn5 - 7/2015</li>
    <!--<li>RGD QTL information: Downloaded </li>-->
</ul>
<BR><BR>
<h2>Annotations/Gene ID Matching</h2>
<p><a href="<%=helpDir%>Annotation_Overview.htm">iDecoder</a>: &nbsp;&nbsp;Last updated on February 25th, 2022 with annotation data from the following sources:
</p>
<div>
    <ul>
        <li>Annotation file for Affymetrix Genechip Drosophila Genome [DrosGenome1] na32</li>
        <li>Annotation file for Affymetrix GeneChip Human Genome U133 Plus 2.0[HG-U133_Plus_2], na32</li>
        <!-- <li>Annotation file for Affymetrix Genechip Human Genome U95Av2 [HG_U95Av2], na28 -->
        <li>Annotation file for Affymetrix Genechip Mouse Exon 1.0 ST Array, na32</li>
        <li>Annotation file for Affymetrix GeneChip Mouse Expression Array MOE430A [MOE430A], na32</li>
        <li>Annotation file for Affymetrix GeneChip Mouse Expression Array MOE430B [MOE430B], na32</li>
        <li>Annotation file for Affymetrix GeneChip Mouse Genome 430A 2.0 [Mouse430A_2], na32</li>
        <li>Annotation file for Affymetrix GeneChip Mouse Genome 430 2.0 [Mouse430_2], na32</li>
        <li>Annotation file for Affymetrix Genechip Murine Genome U74A [MG_U74A], <B>na20</B></li>
        <li>Annotation file for Affymetrix Genechip Murine Genome U74Av2 [MG_U74Av2], <b>na22</b></li>
        <li>Annotation file for Affymetrix Genechip Murine Genome U74Bv2 [MG_U74Bv2], <b>na22</b></li>
        <li>Annotation file for Affymetrix Genechip Murine Genome U74Cv2 [MG_U74Cv2], <b>na22</b></li>
        <li>Annotation file for Affymetrix Genechip Rat Exon 1.0 ST Array, na32</li>
        <li>Annotation file for Affymetrix GeneChip Rat Expression Array RAE230A [RAE230A], na32</li>
        <li>Annotation file for Affymetrix Genechip Rat Genome U34A [RG_U34A], na32</li>
        <!-- <li>Annotation file for Affymetrix Genechip Rat Genome U34C [RG_U34C], na23 -->
        <li>Annotation file for Amersham Codelink UniSet Mouse I</li>
        <li>Annotation file for Codelink Rat Whole Genome</li>
        <li>Annotation file for Codelink Mouse Whole Genome</li>

        <li>Location data from Ensembl for Mouse, Human, and Rat from Ensembl Genes v105</li>
        <li>FlyBase gene_map_table_fb_2022_01.tsv file and fbgn_NAseq_Uniprot_fb_2021_01.tsv</li>
        <li>MGI database links file generated from the ACC_Accession table on 2/25/2022</li>
        <li>MGI_Coordinate.rpt links file, downloaded 2/25/2022</li>
        <li>NCBI gene2accession file, downloaded 2/25/2022</li>
        <li>NCBI gene2unigene file, downloaded 2/25/2022</li>
        <li>NCBI gene_info file, downloaded 2/25/2022</li>
        <li>NCBI homologene.data file, downloaded 2/25/2022</li>
        <li>RGD GENES file, last updated on 2/25/2022</li>
        <li>SwissProt uniprot_sprot.dat file, last updated on 2/25/2022</li>
        <li>PhenoGen Merged Transcriptome v6 with known gene/transcript annotation from Ensembl v105.</li>
    </ul>
</div>

