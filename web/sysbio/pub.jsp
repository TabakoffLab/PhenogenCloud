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
    String pubIdent = "";

    log.info("in resources.jsp. user =  " + user);

    log.debug("action = " + action);
    extrasList.add("tooltipster.min.css");
    extrasList.add("tabs.css");
    extrasList.add("resources1.0.js");
    extrasList.add("jquery.tooltipster.min.js");

    extrasList.add("datatables.1.10.21.min.js");
    //    extrasList.add("jquery.dataTables.1.10.9.min.js");

    if (request.getParameter("id") != null) {
        pubIdent = FilterInput.getFilteredInput(request.getParameter("id").trim()).toLowerCase(Locale.ROOT);
    }
    mySessionHandler.createSessionActivity(session.getId(), "Looked at publication:" + pubIdent, pool);


    HashMap<String, Resource[]> pubHash = myResource.getPublicationHash();

    Resource[] pubResources = pubHash.get(pubIdent);


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
</style>
<%
    pageTitle = "Download Resources";
    pageDescription = "Data resources available for downloading includes Microarrays, Sequencing, and GWAS data";
%>
<%@ include file="/web/common/header_noBorder.jsp" %>
<script>
    $("#wait1").hide();
</script>
<div id="public" style='min-height:1030px;'>
    <h2>Select the download icon(<img src="<%=imagesDir%>icons/download_g.png"/>) to download data from any of the datasets below. For some data types multiple
        options may be available. For these types, a window displays that allows you to choose specific files.</h2>
    <div style="width:100%;">
        <div style="font-size:18px; font-weight:bold;  color:#FFFFFF; text-align:center; width:100%; padding-top: 3px; ">
            <span id="d2" class="detailMenu" name="rnaseq"><a href="/web/sysbio/resources.jsp?section=rnaseq">RNA-Seq</a></span>
            <span id="d6" class="detailMenu" name="dnaseq"><a href="/web/sysbio/resources.jsp?section=dnaseq">DNA-Seq</a></span>
            <span id="d1" class="detailMenu" name="array"><a href="/web/sysbio/resources.jsp?section=array">Microarray</a></span>
            <span id="d3" class="detailMenu" name="marker"><a href="/web/sysbio/resources.jsp?section=marker">Genomic Marker</a></span>
            <span id="d4" class="detailMenu selected" name="pub">Publications</span>

        </div>
    </div>


    <div id="pub" style="border-top:1px solid black;"><BR>
        <div>
            <span class="button" style="width:180px;"><a href="/web/sysbio/resources.jsp?section=pub">Back to all Publications</a></span>
        </div>
        <BR><BR>
        <form method="post"
              action="resources.jsp"
              enctype="application/x-www-form-urlencoded"
              name="resources">


            <%Resource title = pubResources[0];%>
            <div class="title"><span style="font-size:larger;"><%=title.getTitle()%></span><BR><%=title.getAuthor()%><BR>
                    <%if(!title.getAbstractURL().equals("")){%>
                <a href="<%=title.getAbstractURL()%>">Abstract</a>
                    <%}%>
                <table id="pubFiles" class="list_base tablesorter" name="items" cellpadding="0" cellspacing="3" width="85%">
                    <thead>
                    <tr class="col_title">
                        <%if (pubResources[1].getPanel() != null && !pubResources[1].getPanel().equals("N/A") && !pubResources[1].getPanel().equals("")) {%>
                        <th>Population</th>
                        <%}%>
                        <th>Data</th>
                        <TH>Files</TH>
                    </tr>
                    </thead>
                    <tbody>
                    <% for (int j = 1; j < pubResources.length; j++) {
                        Resource resource = pubResources[j];
                        if (resource.getID() != -1) {
                    %>
                    <tr id="<%=resource.getID()%>">
                        <%if (pubResources[1].getPanel() != null && !pubResources[1].getPanel().equals("N/A") && !pubResources[1].getPanel().equals("")) {%>
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
                        <td colspan="3"><a href="<%=resource.getAbstractURL()%>" target="_blank"><%=resource.getTitle()%>
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
        </form>
    </div>

</div>
<!-- END PUBLIC DIV-->


<div class="downloadItem"></div>


<%@ include file="/web/common/footer.jsp" %>
<script type="text/javascript">
    var publicationID =<%=pubID%>;

    $(document).ready(function () {
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


</script>

