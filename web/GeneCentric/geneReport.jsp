<%@ include file="/web/common/anon_session_vars.jsp" %>
<%@ page import="java.util.stream.Collectors"
         import="java.util.Comparator"
         %>

<jsp:useBean id="gdt" class="edu.ucdenver.ccp.PhenoGen.tools.analysis.GeneDataTools" scope="session"></jsp:useBean>
<%

    gdt.setSession(session);
    ArrayList<edu.ucdenver.ccp.PhenoGen.data.Bio.Gene> fullGeneList = new ArrayList<edu.ucdenver.ccp.PhenoGen.data.Bio.Gene>();
    String myOrganism = "";
    String id = "";
    String chromosome = "";

    String[] selectedLevels = null;
    String levelString = "core;extended;full";
    String fullOrg = "";
    String panel = "";
    String gcPath = "";
    String genomeVer = "";
    String defaultGenomeVer = "";
    boolean isSmall = false;
    boolean isNovel = false;
    int selectedGene = 0;
    ArrayList<String> geneSymbol = new ArrayList<String>();
    LinkGenerator lg = new LinkGenerator(session);


    if (request.getParameter("levels") != null && !request.getParameter("levels").equals("")) {
        String tmpSelectedLevels = FilterInput.getFilteredInput(request.getParameter("levels"));
        selectedLevels = tmpSelectedLevels.split(";");
        log.debug("Getting selected levels:" + tmpSelectedLevels);
        levelString = "";
        //selectedLevelError = true;
        for (int i = 0; i < selectedLevels.length; i++) {
            //selectedLevelsError = false;
            levelString = levelString + selectedLevels[i] + ";";
        }
    } else {
        log.debug("Getting selected levels: NULL Using defaults.");
        selectedLevels = levelString.split(";");
    }
    if (request.getParameter("species") != null) {
        myOrganism = FilterInput.getFilteredInput(request.getParameter("species").trim());
        if (myOrganism.equals("Rn")) {
            panel = "BNLX/SHRH";
            fullOrg = "Rattus_norvegicus";
            defaultGenomeVer = "rn6";
        } else {
            panel = "ILS/ISS";
            fullOrg = "Mus_musculus";
            defaultGenomeVer = "mm10";
        }
    }
    if (request.getParameter("chromosome") != null) {
        chromosome = FilterInput.getFilteredInput(request.getParameter("chromosome"));
    }


    if (request.getParameter("geneSymbol") != null) {
        geneSymbol.add(FilterInput.getFilteredInput(request.getParameter("geneSymbol")));
    } else {
        geneSymbol.add("None");
    }
    if (request.getParameter("id") != null) {
        id = FilterInput.getFilteredInput(request.getParameter("id"));
    }
    if (id.startsWith("PRN") || id.startsWith("PMM")) {
        isNovel = true;
    }
    if (request.getParameter("genomeVer") != null) {
        genomeVer = FilterInput.getFilteredInputGenomeVer(request.getParameter("genomeVer"));
        if (genomeVer.startsWith("rn") || genomeVer.startsWith("mm")) {

        } else {
            genomeVer = defaultGenomeVer;
        }
    }
    log.debug("after params");
    gcPath = applicationRoot + contextRoot + "tmpData/browserCache/" + genomeVer + "/geneData/" + id + "/";

    String[] tissuesList1 = new String[1];
    String[] tissuesList2 = new String[1];
    if (myOrganism.equals("Rn")) {
        tissuesList1 = new String[4];
        tissuesList2 = new String[4];
        if (genomeVer.equals("rn7")) {
            tissuesList1 = new String[3];
            tissuesList2 = new String[3];
            tissuesList1[0] = "Brain";
            tissuesList2[0] = "Whole Brain";
            tissuesList1[1] = "Liver";
            tissuesList2[1] = "Liver";
            tissuesList1[1] = "Kidney";
            tissuesList2[1] = "Kidney";
        } else if (genomeVer.equals("rn6")) {
            tissuesList1 = new String[2];
            tissuesList2 = new String[2];
            tissuesList1[0] = "Brain";
            tissuesList2[0] = "Whole Brain";
            tissuesList1[1] = "Liver";
            tissuesList2[1] = "Liver";
        } else {
            tissuesList1[0] = "Brain";
            tissuesList2[0] = "Whole Brain";
            tissuesList1[1] = "Heart";
            tissuesList2[1] = "Heart";
            tissuesList1[2] = "Liver";
            tissuesList2[2] = "Liver";
            tissuesList1[3] = "Brown Adipose";
            tissuesList2[3] = "Brown Adipose";
        }


    } else {
        tissuesList1[0] = "Brain";
        tissuesList2[0] = "Whole Brain";
    }
    int rnaDatasetID = 0;
    int arrayTypeID = 0;

    int[] tmp = gdt.getOrganismSpecificIdentifiers(myOrganism, genomeVer);
    if (tmp != null && tmp.length == 2) {
        rnaDatasetID = tmp[1];
        log.debug("REPORT DSID:" + rnaDatasetID);
        arrayTypeID = tmp[0];
    }
    String genURL = "";
    String urlPrefix = (String) session.getAttribute("mainURL");
    if (urlPrefix.endsWith(".jsp")) {
        urlPrefix = urlPrefix.substring(0, urlPrefix.lastIndexOf("/") + 1);
    }
    genURL = urlPrefix + "tmpData/browserCache/" + genomeVer + "/geneData/" + id + "/";
    ArrayList<edu.ucdenver.ccp.PhenoGen.data.Bio.Gene> tmpGeneList = gdt.getGeneCentricData(id, id, panel, myOrganism, genomeVer, rnaDatasetID, arrayTypeID, true);
    edu.ucdenver.ccp.PhenoGen.data.Bio.Gene curGene = null;
    for (int i = 0; i < tmpGeneList.size(); i++) {
        log.debug("check:" + tmpGeneList.get(i).getGeneID() + ":" + id);
        if (tmpGeneList.get(i).getGeneID().equals(id)) {
            log.debug("found:" + tmpGeneList.get(i).getGeneID());
            curGene = tmpGeneList.get(i);
        }
    }
    long len = curGene.getEnd() - curGene.getStart();
    if (len < 200 && !curGene.getBioType().equals("protein_coding")) {
        isSmall = true;
    }
    log.debug("end of init code");
%>

<style>
    #psHeritTbl {
        width: 49%;
        vertical-align: top;
    }

    #psDABGTbl {
        width: 49%;
        vertical-align: top;
    }

    #genePart1Tbl {
        width: 49%;
        vertical-align: top;
    }

    #genePart2Tbl {
        width: 49%;
        vertical-align: top;
    }

    <%@ include file="/css/forGN2.css" %>

</style>


<!--<a href="web/GeneCentric/geneApplet.jsp?selectedID=<%=id%>" target="_blank">View Affy Probe Set Details</a>
<BR /><BR />
<div style="font-size:18px; font-weight:bold; background-color:#DEDEDE; color:#000000; text-align:left; width:100%; ">
<span class="trigger less" name="geneReport" style="margin-left:30px;">Gene Details</span>
<div class="inpageHelp" style="display:inline-block; "><img id="HelpUCSCImage" class="helpImage" src="<%=contextRoot%>/web/images/icons/help.png" /></div>
</div>
<div id="geneReport" >
Add report here.
</div>
<BR /><BR />
<div style="font-size:18px; font-weight:bold; background-color:#DEDEDE; color:#000000; text-align:left; width:100%; ">
<span class="triggerNoAction" name="geneReportEQTL" style="margin-left:30px;">Gene EQTLs (Circos Plot)</span>
<div class="inpageHelp" style="display:inline-block; "><img id="HelpUCSCImage" class="helpImage" src="<%=contextRoot%>/web/images/icons/help.png" /></div>
</div>
<div id="geneReportEQTL" style="display:none;"></div>

<BR /><BR />-->

<!--<script type="text/javascript">
$("span[name='geneReportEQTL']").click(function (){
var thisHidden = $("div#geneReportEQTL").is(":hidden");
if (thisHidden) {
$("div#geneReportEQTL").show();
$(this).addClass("less");
var jspPage="web/GeneCentric/geneEQTLAjax.jsp";
var params={
species: organism,
geneSymbol: selectedGeneSymbol,
chromosome: chr,
id:selectedID
};
loadDivWithPage("div#geneReportEQTL",jspPage,false,params,
"<span style=\"text-align:center;width:100%;\"><img src=\"web/images/ucsc-loading.gif\"><BR>Laoding...</span>");
} else {
$("div#geneReportEQTL").hide();
$(this).removeClass("less");
}
});
</script>-->

<div style="font-size:18px; font-weight:bold; background-color:#FFFFFF; color:#000000; text-align:center; width:100%; padding-top:3px;">
    <span class="selectdetailMenu selected" name="geneDetail">Gene Details<div class="inpageHelp"
                                                                               style="display:inline-block; "><img
            id="HelpGeneDetailTab"
            class="helpGeneRpt"
            src="/web/images/icons/help.png"/></div></span>
    <span class="selectdetailMenu" name="geneApp">Expression Data<div class="inpageHelp" style="display:inline-block; "><img
            id="HelpGenePSTab"
            class="helpGeneRpt"
            src="/web/images/icons/help.png"/></div></span>

    <%if (!isSmall) {%>
    <span class="selectdetailMenu" name="geneEQTL">Gene eQTLs<div class="inpageHelp" style="display:inline-block; "><img
            id="HelpGeneEqtlTab"
            class="helpGeneRpt"
            src="/web/images/icons/help.png"/></div></span>
    <span class="selectdetailMenu" name="geneMIrna">miRNA Targeting Gene(multiMiR)<div class="inpageHelp"
                                                                                       style="display:inline-block; "><img
            id="HelpMirTargetTab" class="helpGeneRpt" src="/web/images/icons/help.png"/></div></span>
    <!--<span class="selectdetailMenu" name="geneGO">GO<div class="inpageHelp" style="display:inline-block; "><img id="HelpUCSCImage" class="helpImage" src="/web/images/icons/help.png" /></div></span>-->
    <span class="selectdetailMenu" name="geneWGCNA">WGCNA<div class="inpageHelp" style="display:inline-block; "><img
            id="HelpGeneWGCNATab" class="helpGeneRpt"
            src="/web/images/icons/help.png"/></div></span>
    <!--<span class="selectdetailMenu" name="chilibot">Gene Interactions<div class="inpageHelp" style="display:inline-block; "><img id="HelpGeneChilibotTab" class="helpGeneRpt" src="/web/images/icons/help.png" /></div></span>-->
    <%
    } else {
        if (myOrganism.equals("Rn") && genomeVer.equals("rn6")) {
    %>
    <span class="selectdetailMenu" name="geneApp">Expression Data<div class="inpageHelp" style="display:inline-block; "><img
            id="HelpGenePSTab"
            class="helpGeneRpt"
            src="/web/images/icons/help.png"/></div></span>
    <%
        }
        if (curGene.getGeneSymbol().toLowerCase().startsWith("mir") || curGene.getDescription().toLowerCase().startsWith("microrna") || curGene.getBioType().toLowerCase().indexOf("mirna") > -1) {
            if (curGene.getGeneID().startsWith("ENS")) {%>
    <span class="selectdetailMenu" name="miGenerna">Genes Targeted by this miRNA(multiMiR)<div class="inpageHelp"
                                                                                               style="display:inline-block; "><img
            id="HelpGeneMirTargetTab" class="helpGeneRpt" src="/web/images/icons/help.png"/></div></span>
    <%}%>
    <!--<span class="selectdetailMenu" name="miGenernaPred">Predict Genes Targeted by this miRNA(PITA)<div class="inpageHelp" style="display:inline-block; "><img id="HelpPredictGeneMirTargetTab" class="helpGeneRpt" src="<%=contextRoot%>/web/images/icons/help.png" /></div></span>
                        -->
    <%

            }
        }
    %>
</div>

<div style="font-size:18px; font-weight:bold; background-color:#47c647; color:#FFFFFF; text-align:left; width:100%; ">
    <span class="trigger triggerEC less" name="geneDiv" style="margin-left:30px;">Selected Feature Summary</span>
</div>

<div id="geneDiv" style="display:inline-block;text-align:left; width:100%;">
    <div style="display:inline-block; text-align:left;width:100%;" id="geneDetail">

        <% DecimalFormat df2 = new DecimalFormat("#.##");
            DecimalFormat df0 = new DecimalFormat("###");
            DecimalFormat df4 = new DecimalFormat("#.####");
            DecimalFormat dfC = new DecimalFormat("#,###");

            TranscriptCluster tc = curGene.getTranscriptCluster();

            HashMap hCount = curGene.getHeritCounts();
            HashMap dCount = curGene.getDabgCounts();
            HashMap hSum = curGene.getHeritAvg();
            HashMap hMin = curGene.getHeritMin();
            HashMap hMax = curGene.getHeritMax();
            HashMap dSum = curGene.getDabgAvg();
            HashMap dMin = curGene.getDabgMin();
            HashMap dMax = curGene.getDabgMax();

            String chr = curGene.getChromosome();
            String phenogenID = curGene.getGeneID();
            ArrayList<edu.ucdenver.ccp.PhenoGen.data.Bio.Transcript> tmpTrx = curGene.getTranscripts();
            HashMap<String,HashMap<String,String>> uniqueTrxList=new HashMap<String,HashMap<String,String>>();
			for(int l=0;l<tmpTrx.size();l++) {
				String tmpID=tmpTrx.get(l).getID();
				if(!uniqueTrxList.containsKey(tmpID)) {
					String idHTML=tmpTrx.get(l).getIDwToolTip();
					String matched=tmpTrx.get(l).getMatchReason();
					HashMap<String,String>
							tmpHM=new HashMap<String,String>();
					tmpHM.put("html",idHTML);
					tmpHM.put("match",matched);
					uniqueTrxList.put(tmpID,tmpHM);

				}
			}
            if (!chr.startsWith("chr")) {
                chr = "chr" + chr;
            }
        %>

        <div class="adapt2Col" style="vertical-align: top;">
            <table id="genePart1Tbl" class="geneReport adapt2Col" style="display:inline-block;">
                <TR>
                    <TD style="width:20%;">
                        Gene Symbol:
                    </TD>
                    <TD style="width:78%;">
                        <%if (curGene.getGeneSymbol() != null && !curGene.getGeneSymbol().equals("")) {%>
                        <%=curGene.getGeneSymbol()%>
                        <%} else {%>
                        No Gene Symbol Found
                        <%}%>
                    </TD>
                </TR>
                <TR>
                    <TD style="width:20%;">
                        Phenogen ID:
                    </TD>
                    <TD style="width:78%;">

                        <%=phenogenID%>

                    </TD>
                </TR>
                <TR>
                    <TD>
                        Location:
                    </TD>
                    <TD>
                        <%=chr + ": " + dfC.format(curGene.getStart()) + "-" + dfC.format(curGene.getEnd())%>
                    </TD>
                </TR>
                <TR>
                    <TD>
                        Strand:
                    </TD>
                    <TD>
                        <%=curGene.getStrand()%>
                    </TD>
                </TR>

                <TR>
                    <TD> Description:</TD>
                    <TD>

                        <%
                            String description = curGene.getDescription();
                            String shortDesc = description;
                            String remain = "";
                            if (description.indexOf("[") > 0) {
                                shortDesc = description.substring(0, description.indexOf("["));
                                remain = description.substring(description.indexOf("[") + 1, description.indexOf("]"));
                            }
                        %>
                        <span title="Description <%=remain%>">
                                	<%String bioType = curGene.getBioType();%>
                                        <%if (!isSmall) {%>
                                            <%=shortDesc%>
                                        <%} else {%>
                                            <%=bioType%>
                                        <%}%>
                                    <% HashMap displayed = new HashMap();
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
                                        while (itr.hasNext()) {
                                            String source = itr.next().toString();
                                            String values = bySource.get(source).toString();
                                    %>
                                        <%="<BR>" + source + ":" + values%>
                                    <%}%>
                                    </span>

                    </TD>
                </TR>
                <TR></TR>
                <TR>
                    <TD> Links:</TD>
                    <TD>

                        <%if (curGene.getGeneID().startsWith("ENS")) {%>
                        <a href="<%=LinkGenerator.getEnsemblLinkEnsemblID(curGene.getGeneID(),fullOrg)%>"
                           target="_blank"
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
                                        <a href="<%=LinkGenerator.getUniProtLinkGene(tmpGS)%>"
                                           target="_blank">UniProt</a> <BR/>
                                       <%=shortOrg%>: <a href="<%=LinkGenerator.getNCBILink(tmpGS,myOrganism)%>"
                                                         target="_blank">NCBI</a> | <a
                                href="<%=LinkGenerator.getUniProtLinkGene(tmpGS,myOrganism)%>"
                                target="_blank">UniProt</a> |
                                        <%if (myOrganism.equals("Mm")) {%>
                                            <a href="<%=LinkGenerator.getMGILink(tmpGS)%>" target="_blank">MGI</a> 
                                            <%if (!allenID.equals("")) {%>
                                                | <a href="<%=LinkGenerator.getBrainAtlasLink(allenID)%>"
                                                     target="_blank">Allen Brain Atlas</a>
                                            <%}%>
                                        <%} else {%>
                                            <a href="<%=LinkGenerator.getRGDLink(tmpGS,myOrganism)%>" target="_blank">RGD</a>
                                        <%}%>
                                     </span>
                        <%} else {%>
                        <%=curGene.getGeneID()%>
                        <%}%>
                    </TD>

                </TR>
                <%if (myOrganism.equals("Rn")) {%>
                <TR>
                    <TD style="width:20%;">Exonic Variants:</TD>
                    <TD style="width:78%;">

                        <B>Common:</B> <%=curGene.getSnpCount("common", "SNP")%> (SNPs)
                        / <%=curGene.getSnpCount("common", "Indel")%>(Insertions/Deletions)<BR/>

                        <B>BN-Lx/CubPrin:</B> <%=curGene.getSnpCount("BNLX", "SNP")%> (SNPs)
                        / <%=curGene.getSnpCount("BNLX", "Indel")%>
                        (Insertions/Deletions)<BR/>

                        <B>SHR/OlaPrin:</B> <%=curGene.getSnpCount("SHRH", "SNP")%> (SNPs)
                        / <%=curGene.getSnpCount("SHRH", "Indel")%>
                        (Insertions/Deletions)<BR/>

                        <B>SHR/NCrlPrin:</B> <%=curGene.getSnpCount("SHRJ", "SNP")%> (SNPs)
                        / <%=curGene.getSnpCount("SHRJ", "Indel")%>
                        (Insertions/Deletions)<BR/>

                        <B>F344:</B> <%=curGene.getSnpCount("F344", "SNP")%> (SNPs)
                        / <%=curGene.getSnpCount("F344", "Indel")%> (Insertions/Deletions)<BR/>
                        <span class="GN2Snps button" style="width:275px;height:37px;cursor: pointer;color:#658cb2;">GN2 SNP Browser (Additional Strains/Functional Annotation)</span>

                    </TD>

                </TR>
                <%}%>
                <TR>
                    <TD style="width:20%;">
                        Literature Based Searches:
                    </TD>
                    <TD><span class="button" style="width:275px;height:37px;pointer;color:#658cb2;" id="chilibotLink">Gene Relationships / Interactions (Chilibot.net)</span><BR>
                        <span class="button" style="width:275px;height:37px;cursor: pointer;color:#658cb2;"
                              id="ratsPubLink">Gene Relationships for Addiction (genecup.org)</span>
                    </TD>
                </TR>
                <TR>
                    <TD></TD>
                    <TD></TD>
                </TR>
            </table>
            <table id="genePart2Tbl" class="geneReport adapt2Col" style="display:inline-block;">
                <TR>
                    <TD style="width:20%;">
                        Transcripts:
                    </TD>
                    <TD style="width:78%;">
                        <% Set<String> keySet = uniqueTrxList.keySet();
                        ArrayList<String> list=new ArrayList<String>(keySet);

                        Collections.sort(list,new Comparator<String>() {
                                    public int compare(String a, String b) {
                                        if (a.equals(b)) {
                                            return 0;
                                        }
                                        return a.compareTo(b);
                                    }
                                });
                        for(Object key : list ) {
                                HashMap<String,String> cur = uniqueTrxList.get(key);%>
                        		<B><%=cur.get("html")%></B>
                        		<%if(cur.containsKey("match") && !cur.get("match").equals("")) {%>
                        			-  <%=cur.get("match")%>
                        		<%}%>
                        		<BR>
                        <%}%>
                    </TD>
                </TR>

            </table>
        </div>

        <%if (genomeVer.equals("rn5") || genomeVer.equals("rn6")) {%>
        <div>

            <div class="geneReport header" style="width:100%;">
                Affy Probe Set Data: Overlapping Probe Set Count:<%=curGene.getProbeCount()%>
                <span class="reporttooltip"
                      title="Summary of probe sets that overlap with an exon or intron of any Ensembl or RNA-Seq transcript for this gene and probe the same strand as the transcript.<BR>Note: The probe set track if displayed shows all non-masked probe sets in the region including the opposite strand.">
                                <img src="<%=contextRoot%>/web/images/icons/info.gif"/></span>
            </div>
            <%if (curGene.getProbeCount() > 0) {%>
            <div class='adapt2Col'>
                <table id="psDABGTbl" class="geneReport" style="display:inline-block;">
                    <TR>
                        <TD colspan="2"><B>Probe sets detected above background*:</B></TD>
                    </TR>
                    <TR>
                        <TD colspan="2">
                            <table id="tblGeneDabg" name="items" class="list_base"
                                   style="width:100%; text-align:center;">
                                <thead>
                                <tr class="col_title">
                                    <TH style="color:#000000;">Tissue</TH>
                                    <TH style="color:#000000;">Number of probe sets detected above background* in more
                                        than 1% of samples (out
                                        of <%=curGene.getProbeCount()%> probe sets for this gene)
                                    </TH>
                                    <TH style="color:#000000;">Avg % of samples DABG*</TH>
                                    <TH style="color:#000000;">Range</TH>

                                </tr>
                                </thead>
                                <tbody>
                                <%
                                    for (int j = 0; j < tissuesList1.length; j++) {
                                        Object tmpD = dCount.get(tissuesList1[j]);
                                        Object tmpDa = dSum.get(tissuesList1[j]);
                                        Object tmpDl = dMin.get(tissuesList1[j]);
                                        Object tmpDh = dMax.get(tissuesList1[j]);
                                %>
                                <TR>
                                    <%
                                        if (tmpD != null) {
                                            int count = Integer.parseInt(tmpD.toString());
                                            double sum = Double.parseDouble(tmpDa.toString());
                                            double min = Double.parseDouble(tmpDl.toString());
                                            double max = Double.parseDouble(tmpDh.toString());
                                    %>
                                    <TD><%=tissuesList1[j]%>
                                    </TD>
                                    <TD><%=count%>
                                    </TD>
                                    <%if (count > 0) {%>
                                    <TD><%=df0.format(sum / count)%> %</TD>
                                    <TD><%=df2.format(min)%> - <%=df2.format(max)%> %</TD>
                                    <%} else {%>
                                    <TD>0</TD>
                                    <TD></TD>
                                    <%}%>

                                    <%} else {%>
                                    <TD><%=tissuesList1[j]%>
                                    </TD>
                                    <TD></TD>
                                    <TD></TD>
                                    <TD></TD>
                                    <%}%>
                                </TR>
                                <%}%>
                                </tbody>
                            </table>
                        </TD>
                    </TR>
                    <TR>
                        <TD colspan="2">*DABG is based on Affymetrix software that assigns a P-value to the probe sets
                            detection above background. Using a
                            comparison of RNA-Seq data probe sets that overlap a high confidence exon in the
                            transcriptome are not detected above background
                            roughly 5% of the time. Increasing the P-value cutoff of 0.0001 can reduce this but only at
                            the expense of greatly elevated false
                            positives.
                        </TD>
                    </TR>
                </table>
                <table id="psHeritTbl" class="geneReport" style="display:inline-block;">
                    <TR>
                        <TD colspan="2"><B>Probe Set Heritability:</B></TD>

                    </TR>
                    <TR>
                        <TD colspan="2">
                            <table id="tblGeneHerit" name="items" class="list_base"
                                   style="width:100%; text-align:center;">
                                <thead>

                                <tr class="col_title">
                                    <TH style="color:#000000;">Tissue</TH>
                                    <TH style="color:#000000;">Number of probe sets with a heritability greater than
                                        0.33 (out of <%=curGene.getProbeCount()%>
                                        probe sets for this gene)
                                    </TH>
                                    <TH style="color:#000000;">Avg Herit</TH>
                                    <TH style="color:#000000;">Range</TH>
                                </tr>
                                </thead>
                                <tbody>
                                <%
                                    for (int j = 0; j < tissuesList1.length; j++) {
                                        Object tmpH = hCount.get(tissuesList1[j]);
                                        Object tmpHa = hSum.get(tissuesList1[j]);
                                        Object tmpHl = hMin.get(tissuesList1[j]);
                                        Object tmpHh = hMax.get(tissuesList1[j]);
                                %>
                                <TR>
                                    <%
                                        if (tmpH != null) {
                                            int count = Integer.parseInt(tmpH.toString());
                                            double sum = Double.parseDouble(tmpHa.toString());
                                            double min = Double.parseDouble(tmpHl.toString());
                                            double max = Double.parseDouble(tmpHh.toString());
                                    %>

                                    <TD><%=tissuesList1[j]%>
                                    </TD>
                                    <TD><%=count%>
                                    </TD>
                                    <%if (count > 0) {%>
                                    <TD><%=df2.format(sum / count)%>
                                    </TD>
                                    <TD><%=df2.format(min)%> - <%=df2.format(max)%>
                                    </TD>
                                    <%} else {%>
                                    <TD>0</TD>
                                    <TD></TD>

                                    <%}%>
                                    <%} else {%>
                                    <TD><%=tissuesList1[j]%>
                                    </TD>
                                    <TD></TD>
                                    <TD></TD>
                                    <TD></TD>
                                    <%}%>
                                </TR>
                                <%}%>
                                </tbody>
                            </table>
                        </TD>
                    </TR>
                </table>
            </div>
            <%}%>

            <% if (tc != null && !isSmall) {


                //String[] curTissues=tc.getTissueList();%>
            <div style="width:100%;">
                <div class="geneReport header" style="width:100%;">
                    EQTLs Affymetrix Transcript Cluster(Confidence Level): <%=tc.getTranscriptClusterID()%>
                    (<%=tc.getLevel()%>)
                </div>
                <table style="width:100%;">
                    <!--<TR>
                                         <TD class="header">EQTLs</TD>
                                         <TD class="header">Affymetrix Transcript Cluster(Confidence Level): <%=tc.getTranscriptClusterID()%> (<%=tc.getLevel()%>)</TD>
                                     </TR>
                                     
                                    <TR>-->
                    <TD colspan="2">
                        <table id="tblGeneEQTL" name="items" class="list_base" style="width:100%; text-align:center;">
                            <thead>
                            <tr class="col_title">
                                <TH colspan="2"></TH>
                                <TH colspan="2" style="color:#000000;">Minimum P-value EQTL</TH>
                            </tr>
                            <tr class="col_title">
                                <TH style="color:#000000;">Tissue</TH>
                                <TH style="color:#000000;">Number of eQTLs</TH>
                                <TH style="color:#000000;">P-value</TH>
                                <TH style="color:#000000;">Location</TH>
                            </tr>
                            </thead>
                            <tbody>
                            <%
                                for (int j = 0; j < tissuesList2.length; j++) {
                                    //log.debug("TABLE1:"+tissuesList2[j]);
                                    ArrayList<EQTL> qtlList = tc.getTissueEQTL(tissuesList2[j]);
                                    if (qtlList != null) {
                                        EQTL maxEQTL = qtlList.get(0);
                            %>
                            <TR>
                                <TD><%=tissuesList2[j]%>
                                </TD>
                                <TD><%=qtlList.size()%>
                                </TD>

                                <TD>
                                    <%if (maxEQTL.getPVal() < 0.0001) {%>
                                    < 0.0001
                                    <%} else {%>
                                    <%=df4.format(maxEQTL.getPVal())%>
                                    <%}%>
                                </TD>
                                <TD>
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
                                    <a href="<%=lg.getRegionLink(maxEQTL.getMarkerChr(),start,stop,myOrganism,true,true,false)%>"
                                       target="_blank"
                                       title="View Detailed Transcription Information for a region +- 500,000bp around the SNP location.">
                                        chr<%=maxEQTL.getMarkerChr() + ":" + dfC.format(maxEQTL.getMarker_start())%>
                                    </a>
                                    <%}%>
                                </TD>
                            </TR>
                            <%} else {%>
                            <TR>
                                <TD><%=tissuesList2[j]%>
                                </TD>
                                <TD></TD>
                                <TD></TD>
                                <TD></TD>
                            </TR>
                            <%}%>
                            <%}%>
                            </tbody>
                        </table>
                    </TD>
                    </TR>
                </table>
                Click the Gene eQTLs Tab above to view a Circos Plot of the eQTLs listed above.
            </div>
            <%}%>


        </div>
        <%}%>
    </div>

    <div style="display:none;" id="geneEQTL">
    </div>

    <div style="display:none;" id="geneApp">
        <div id="geneAppsrcCtrl" class="srcCtrl" style="text-align:center;"></div>
        <div class="help" style="width:100%;display:inline-block;text-align:center;"></div>
        <div class="exprCol" id="expBrain" style="display:inline-block;">
            <div style="width:100%;text-align: center;"><H2><span id="geneAppTitleb"></span></h2></div>
            <BR>
            <div id="chartBraingeneApp" style="width:98%;"></div>

        </div>
        <div class="exprCol" id="expLiver" style="display:inline-block;">
            <div style="width:100%;text-align: center;"><H2><span id="geneAppTitlel"></span></h2></div>
            <BR>
            <div id="chartLivergeneApp" style="width:98%;"></div>
        </div>
        <div class="exprCol" id="expKidney" style="display:inline-block;">
            <div style="width:100%;text-align: center;"><H2><span id="geneAppTitlek"></span></h2></div>
            <BR>
            <div id="chartKidneygeneApp" style="width:98%;"></div>
        </div>
    </div>

    <div style="display:none;" id="geneMIrna">
    </div>

    <div style="display:none;" id="miGenerna">
    </div>
    <div style="display:none;" id="geneWGCNA">
    </div>
    <div style="display:none;" id="chilibot">
        <table>
            <TR>
                <TD>
                    <H3 style="text-align: left;">2 Term search:</H3><BR>
                    <div style="padding-top:10px;padding-bottom:10px;text-align:center;">Current Gene: <input
                            type="text" id="chiliterm1"
                            value="<%=geneSymbol.get(0)%>"> & <input
                            type="text" id="chiliterm2"><input type="button" class="GNButton" value="Go To Chilibot.net"
                                                               onclick="linkChilibot2term()"><BR>Term2
                        can be another gene/phenotype/other keyword/protein.
                    </div>
                </TD>
            </TR>
            <TR>
                <TD><H3 style="text-align: left;padding-top: 10px;padding-bottom: 10px;">Or</H3></TD>
            </TR>
            <TR>
                <TD>
                    <H3 style="text-align: left;">Multiterm search:</H3><BR>
                    <div style="padding-top:10px;padding-bottom:10px;text-align: center;">Multiterm list(2-10, one per
                        line):<BR><textarea rows="5" cols="30"
                                            id="chililist"><%=geneSymbol.get(0)%></textarea>
                        <BR><input type="button" class="GNButton" value="Go To Chilibot.net"
                                   onclick="linkChilibotGeneList()"></div>
                </TD>
            </TR>
        </table>
    </div>
    <div style="display:none;" id="GN2SNPBrowserForm">
        <%@ include file="/web/GeneCentric/includeGNSNPs.jsp" %>
    </div>

</div>


<script type="text/javascript">
    var idStr = "<%=id%>";
    var geneSymStr = "<%=curGene.getGeneSymbol()%>";
    var version = <%if(genomeVer.equals("rn7")){%>6<%}else{%>5<%}%>;

    var rows = $("table#tblGeneDabg tr");
    stripeTable(rows);
    rows = $("table#tblGeneHerit tr");
    stripeTable(rows);
    rows = $("table#tblGeneEQTL tr");
    stripeTable(rows);

    $(".reporttooltip").tooltipster({
        position: 'top-right',
        maxWidth: 250,
        offsetX: 0,
        offsetY: 5,
        contentAsHTML: true,
        //arrow: false,
        interactive: true,
        interactiveTolerance: 350
    });
    $('.selectdetailMenu').click(function () {
        var oldID = $('.selectdetailMenu.selected').attr("name");
        $("#" + oldID).hide();
        $('.selectdetailMenu.selected').removeClass("selected");
        $(this).addClass("selected");
        var id = $(this).attr("name");
        $("#" + id).show();
        loadGeneReportTabs(id, false);
    });
    $('.helpGeneRpt').on('click', function (event) {
            var id = $(this).attr('id');
            $('#' + id + 'Content').dialog("option", "position", {my: "right top", at: "left bottom", of: $(this)});
            $('#' + id + 'Content').dialog("open").css({'font-size': 12});
            event.stopPropagation();
            //return false;
        }
    );

    function setSelectedTab(scrollToDiv) {
        if (typeof section !== 'undefined' && section !== "") {
            var oldID = $('.selectdetailMenu.selected').attr("name");
            $("#" + oldID).hide();
            $('.selectdetailMenu.selected').removeClass("selected");
            $(".selectdetailMenu[name=\"" + section + "\"]").addClass("selected");
            $("#" + section).show();
            loadGeneReportTabs(section, scrollToDiv);
        }
    }

    function loadGeneReportTabs(id, scrollToDiv) {
        if (id === "geneEQTL") {
            var jspPage = contextRoot + "web/GeneCentric/geneEQTLAjax.jsp";
            var params = {
                species: organism,
                geneSymbol: selectedGeneSymbol,
                chromosome: chr,
                id: selectedID,
                genomeVer: genomeVer,
                version: version
            };
            loadDivWithPage("div#geneEQTL", jspPage, scrollToDiv, params,
                "<span style=\"text-align:center;width:100%;\"><img src=\"web/images/ucsc-loading.gif\"><BR>Loading...</span>");
        } else if (id === "geneApp") {
            setTimeout(function () {
                $('html, body').animate({
                    scrollTop: $("#geneApp").offset().top
                }, 200);
            }, 300);
            /*$.ajax({
                            url: contextRoot+"web/GeneCentric/callPanelExpr.jsp",
                            type: 'GET',
                            cache: 'false',
                            data: {id:idStr,organism: organism,genomeVer:genomeVer,chromosome: chr,minCoord:svgList[1].xScale.domain()[0],maxCoord:svgList[1].xScale.domain()[1],rnaDatasetID:rnaDatasetID,arrayTypeID: arrayTypeID},
                            dataType: 'json',
                    error: function(xhr, status, error) {console.log(error);}
                    });*/
        } else if (id === "geneMIrna") {
            var jspPage = contextRoot + "web/GeneCentric/geneMiRnaAjax.jsp";
            var params = {
                species: organism,
                id: selectedID
            };
            loadDivWithPage("div#geneMIrna", jspPage, scrollToDiv, params,
                "<span style=\"text-align:center;width:100%;\"><img src=\"web/images/ucsc-loading.gif\"><BR>Loading...</span>");
        } else if (id === "miGenerna") {
            var jspPage = contextRoot + "web/GeneCentric/miGeneRnaAjax.jsp";
            var params = {
                species: organism,
                id: geneSymStr
            };
            loadDivWithPage("div#miGenerna", jspPage, scrollToDiv, params,
                "<span style=\"text-align:center;width:100%;\"><img src=\"web/images/ucsc-loading.gif\"><BR>Loading...</span>");
        } else if (id === "geneWGCNA") {
            $("div#regionWGCNAEQTL").html("");
            var jspPage = contextRoot + "web/GeneCentric/wgcnaGene.jsp";
            var params = {
                species: organism,
                id: selectedID,
                genomeVer: genomeVer
            };
            loadDivWithPage("div#geneWGCNA", jspPage, scrollToDiv, params,
                "<span style=\"text-align:center;width:100%;\"><img src=\"web/images/ucsc-loading.gif\"><BR>Loading...</span>");
        }
    }

    function linkChilibot2term() {
        var t1 = encodeURIComponent($('#chiliterm1').val());
        var t2 = encodeURIComponent($('#chiliterm2').val());
        var url = "http://chilibot.net/cgi-bin/chilibot/chili2terms?term1=" + t1 + "&term2=" + t2;
        window.open(url, 'Chilibot', '');
    }

    function linkChilibotGeneList() {
        var t1 = encodeURIComponent($('#chililist').val());
        var url = "http://chilibot.net/cgi-bin/chilibot/chilibot.cgi?NEW=t&name=&list=" + t1 + "&IN=Search";
        window.open(url, 'Chilibot', '');
    }

    setTimeout(function () {
        setSelectedTab(true);
        //setTimeout(function(){
        //    $("#geneDiv").scrollTop($("#geneDiv")[0].scrollHeight);
        //},500);
    }, 200);

    <%@ include file="/javascript/chart.js" %>
    <%@ include file="include/js_addExprSrcCtrl.js" %>
    <%@ include file="include/linkGN.js" %>
    var peGR;
    setTimeout(function () {
        var tmpURL = "<%=genURL%>";
        console.log(location.protocol);
        if (location.protocol == 'http:') {
            tmpURL = tmpURL.replace("https://", "http://");
        }
        console.log("tmpURL:" + tmpURL);
        peGR = PhenogenExpr({
            "dataPrefix": tmpURL,
            "div": "geneApp",
            "genomeBrowser": gs,
            "type": "scatter",
            "featureType": "Long",
            "displayCtrl": false
        });
        if ($(window).width() < 1500 && peGR) {
            if (peGR.rbChart) {
                peGR.rbChart.setWidth("98%");
            }
            if (peGR.rlChart) {
                peGR.rlChart.setWidth("98%");
            }
            if (peGR.rkChart) {
                peGR.rkChart.setWidth("98%");
            }
        }
        createDialog("#GN2SNPBrowserForm", {
            width: 900,
            height: 375,
            title: "Link to GeneNetwork SNP Browser",
            zIndex: 999
        });
        createDialog("div#chilibot", {width: 600, height: 375, title: "Link to Chilibot", zIndex: 999});
        $('span.GN2Snps').on('click', function () {
            $('#GN2SNPBrowserForm [name=gene_name]').val(gs.selectedGeneSymbol);
            //TODO need to set species/strains

            $('#GN2SNPBrowserForm').dialog("open").css({'font-size': 12});
        });
        $('span#chilibotLink').on('click', function () {
            console.log("click chilibot link");
            $('div#chilibot').dialog("open").css({'font-size': 12});
        });
    }, 5000);
    setTimeout(function () {
        $('span#ratsPubLink').on('click', function () {
            window.open("https://genecup.org/progress?query=%09<%=curGene.getGeneSymbol()%>+", "_blank");
        });
    }, 10);
    $(window).resize(function () {
        if ($(window).width() < 1500 && peGR) {
            if (peGR.rbChart) {
                peGR.rbChart.setWidth("98%");
            }
            if (peGR.rlChart) {
                peGR.rlChart.setWidth("98%");
            }
            if (peGR.rkChart) {
                peGR.rkChart.setWidth("98%");
            }
        } else {
            if (peGR && peGR.rbChart) {
                peGR.rbChart.setWidth("46%");
            }
            if (peGR && peGR.rlChart) {
                peGR.rlChart.setWidth("46%");
            }
            if (peGR && peGR.rkChart) {
                peGR.rkChart.setWidth("46%");
            }
        }
    });
</script>

