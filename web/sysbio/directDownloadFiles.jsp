<%--
 *  Author: Cheryl Hornbaker
 *  Created: Jan, 2011
 *  Description:  The web page created by this file allows the user to download resource files.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<%@ include file="/web/sysbio/include/sysBioHeader.jsp" %>
<%
    int resource = (request.getParameter("resource") == null ? -99 : Integer.parseInt((String) request.getParameter("resource")));
    String type = (request.getParameter("type") == null ? "" : (String) request.getParameter("type"));

    log.info("in directDownloadFiles.jsp. user = " + user + ", resource = " + resource + ", type = :" + type + ":");

    log.debug("action = " + action);

    ArrayList<String> checkedList = new ArrayList<String>();
    Resource[] allResources = myResource.getAllResources();
    Resource thisResource = myResource.getResourceFromMyResources(allResources, resource);

    log.debug("thisResource=" + thisResource.getID() + " " + thisResource.getOrganism() + " " + thisResource.getSource());

    DataFile[] dataFiles = (type.equals("eQTL") ? thisResource.getEQTLDataFiles() :
            (type.equals("expression") ? thisResource.getExpressionDataFiles() :
                    (type.equals("heritability") ? thisResource.getHeritabilityDataFiles() :
                            (type.equals("marker") ? thisResource.getMarkerDataFiles() :
                                    (type.equals("rnaseq") ? thisResource.getSAMDataFiles() :
                                            (type.equals("genotype") ? thisResource.getGenotypeDataFiles() :
                                                    (type.equals("mask") ? thisResource.getMaskDataFiles() :
                                                            (type.equals("pub") ? thisResource.getPublicationFiles() :
                                                                    (type.equals("gtf") ? thisResource.getSAMDataFiles() :
                                                                            (type.equals("rsem") ? thisResource.getSAMDataFiles() :
                                                                                    null))))))))));
    log.debug("array size=" + dataFiles.length);
    String displayType = type;
    if (type.equals("gtf")) {
        displayType = "GTF";
    } else if (type.equals("rsem")) {
        displayType = "Normalized RSEM Results";
    }
%>
<style>
    a {
        color: #0000FF;
        text-decoration: underline;
    }
</style>
<BR>
<form method="post"
      action="downloadFiles.jsp"
      enctype="application/x-www-form-urlencoded"
      name="downloadFiles">
    <% if (type.equals("pub")) {%>
    <div class="leftTitle">Files That Can Be Downloaded For <%=thisResource.getDownloadHeader()%>:</div>
    <%} else {%>
    <div style="width:100%; text-align: center;" id="acknowledge">
        Please acknowledge you will properly cite downloaded PhenoGen Data when used in future publications. Additional information on citing PhenoGen can be
        found <a href="web/common/citation.jsp" style="color:#0000FF;">here</a>.<BR>
        <a href="https://doi.org/10.1007/978-1-4939-9581-3_10" style="color:#0000FF;">DOI: 10.1007/978-1-4939-9581-3_10</a></p><BR>

        <input type="button" value="I acknowledge the citation information" onClick="showDownloads()"> <input type="button" value="No I do not acknowledge"
                                                                                                              style="margin-left: 25px;"
                                                                                                              onClick="showAcceptCitation()">

    </div>
    <div id="acknowledgePopup" style="display: none;color:#FF0000;width:100%; text-align: center;">
        You must acknowledge that you will cite the data to proceed.<BR>
        <input type="button" value="Back" onClick="showAcknowledge()">
    </div>
    <div id="downloadListPopup" style="display: none;width:100%; text-align: center;">
        <div class="leftTitle">Files That Can Be Downloaded For <%=displayType%>:</div>
        <%}%>

        <table name="items" class="list_base" cellpadding="0" cellspacing="3" width="90%">
            <thead>
            <tr class="col_title">
                <th class="noSort"></th>
                <%
                    if (type.equals("rnaseq") || type.equals("expression") || type.equals("mask")
                            || type.equals("heritability") || type.equals("gtf")) {
                %>
                <th class="noSort">Genome Version</th>
                <%}%>
                <th class="noSort">File Type</th>
                <th class="noSort">File Name</th>
                <th class="noSort">MD5 Checksum</th>
            </tr>
            </thead>
            <tbody>
            <% int i = 0;
                for (DataFile dataFile : dataFiles) {
                    i++;
            %>
            <tr>
                <td class="<%if(i%2==0){%>alt_stripe<%}%>">
                    <center>
                        <a href="downloadLink.jsp?url=<%=dataFile.getFileName()%>" target="_blank"> <img src="../images/icons/download_g.png"/></a>
                    </center>
                </td>
                <%
                    if (type.equals("rnaseq") || type.equals("expression") || type.equals("mask")
                            || type.equals("heritability") || type.equals("gtf")) {
                %>
                <TD class="<%if(i%2==0){%>alt_stripe<%}%>"><%=dataFile.getGenome()%>
                </TD>
                <%}%>
                <td class="<%if(i%2==0){%>alt_stripe<%}%>"><%=dataFile.getType()%>
                </td>
                <td class="<%if(i%2==0){%>alt_stripe<%}%>"><%=dataFile.getFileName().substring(dataFile.getFileName().lastIndexOf("/") + 1)%>
                </td>
                <td class="<%if(i%2==0){%>alt_stripe<%}%>"><%if (dataFile.getChecksum() != null) {%><%=dataFile.getChecksum()%><%}%></td>
            </tr>
            <% } %>
            </tbody>
        </table>

        <BR>
        <% if (type.equals("expression")) { %>
        <center>*For the Affymetrix Exon Arrays, expression levels are estimated on the exon level (i.e., probe set) or gene level (i.e. transcript cluster) and
            inclusion in the data set is determined based on confidence in annotation (core,extended, and full). For more details, see the Affymetrix GeneChip �
            Exon Array whitepaper, Exon Probeset Annotations and Transcript Cluster Groupings (2005).
        </center>
        <% } %>

        <% if (!type.equals("pub")) {%>
    </div>
    <%}%>
    <input type="hidden" name="resource" value=<%=resource%>/>
    <input type="hidden" name="type" value=<%=type%>/>
</form>


<script>
    $(document).ready(function () {
        $("input[name='action']").click(
            function () {
                downloadModal.dialog("close");
            });
    });
    showDownloads = function () {
        $("#downloadListPopup").show();
        $("#acknowledge").hide();
    }
    showAcceptCitation = function () {
        $("#acknowledgePopup").show();
        $("#acknowledge").hide();
    }
    showAcknowledge = function () {
        $("#acknowledge").show();
        $("#acknowledgePopup").hide();
    }
</script>
