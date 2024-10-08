<%--
 *  Author: Spencer Mahaffey
 *  Created: December, 2011
 *  Description:  The web page created by this file allows the user to
 *              select data to compute exon to exon correlations to look by eye for alternate splicing.
 *  Todo:
 *  Modification Log:
 *
--%>

<%@ include file="/web/geneLists/include/geneListHeader.jsp" %>

<%
    extrasList.add("datatables.1.10.21.min.js");
    extrasList.add("d3.v4.8.0.min.js");
    //extrasList.add("jquery.dataTables.1.10.9.min.js");
    extrasList.add("wgcnaBrowser1.4.0.js");
    extrasList.add("svg-pan-zoom.3.5.1.min.js");

    //extrasList.add("tableExport/tableExport.js");
    //extrasList.add("tableExport/jquery.base64.js");
    //extrasList.add("jquery.dataTables.min.css");

    //extrasList.add("smoothness/jquery-ui.1.11.3.min.css");

    log.info("in wgcna.jsp. user =  " + user);
    optionsList.add("geneListDetails");
    optionsList.add("chooseNewGeneList");
    if (userLoggedIn.getUser_name().equals("anon")) {
        optionsListModal.add("linkEmail");
    }

    request.setAttribute("selectedTabId", "wgcna");

    mySessionHandler.createGeneListActivity("Looked at WGCNA a GeneList", pool);
    String myOrganism = selectedGeneList.getOrganism();
    String genomeVer = "rn7";
    if (myOrganism.equals("Mm")) {
        genomeVer = "mm10";
    }
%>

<%@ include file="/web/GeneCentric/browserCSS.jsp" %>
<%@ include file="/web/geneLists/include/geneListJS.jsp" %>
<%@ include file="/web/common/header_adaptive_menu.jsp" %>
<%@ include file="/web/geneLists/include/viewingPane.jsp" %>

<script>
    var organism = "<%=selectedGeneList.getOrganism()%>";
    var genomeVer = "<%=genomeVer%>";
    var pathPrefix = "../GeneCentric/";
    var contextRoot = "<%=contextRoot%>";
    var tt = d3.select("body").append("div")
        .attr("class", "testToolTip")
        .style("z-index", 1001)
        .attr("pointer-events", "all")
        .style("opacity", 0);
    var fixedWidth = 1000;
    var testChrome = /chrom(e|ium)/.test(navigator.userAgent.toLowerCase());
    var testSafari = /safari/.test(navigator.userAgent.toLowerCase());
    var testFireFox = /firefox/.test(navigator.userAgent.toLowerCase());
    var testIE = /(wow|.net|ie)/.test(navigator.userAgent.toLowerCase());
    if (testChrome && testSafari) {
        testSafari = false;
    }
</script>

<div class="page-intro">
    <p> Select modules below that contain genes from the selected Gene List to view additional details.</p>
</div>
<!-- // end page-intro -->

<%@ include file="/web/geneLists/include/geneListToolsTabs.jsp" %>
<div class="leftTitle">WGCNA<span class="helpImage" id="HelpGeneListWGCNATab"><img src="<%=imagesDir%>icons/help.png" </span></div>
<%if (myOrganism.equals("Rn")) {%>
<div class="right">Genome Version:<select id="genomeVer">
	<option value="rn7">rn7</option>
    <option value="rn6">rn6</option>
    <option value="rn5">rn5</option>
</select></div>
<%}%>
<div style="font-size:14px">
    <%@ include file="/web/GeneCentric/wgcnaGeneCommon.jsp" %>
</div>
<!-- end primary content-->


<%@ include file="/web/GeneCentric/resultsHelp.jsp" %>
<script type="text/javascript">
    $("div#wait1").hide();
    $('.helpImage').on('click', function (event) {
            var id = $(this).attr('id');
            $('#' + id + 'Content').dialog("option", "position", {my: "right top", at: "left bottom", of: $(this)});
            $('#' + id + 'Content').dialog("open").css({'font-size': 12});
            event.stopPropagation();
            //return false;
        }
    );
    $('#genomeVer').on('change', function () {
        genomeVer = $(this).val();
        wgcna.requestModuleList();
    });
</script>

<%@ include file="/web/common/footer_adaptive.jsp" %>


