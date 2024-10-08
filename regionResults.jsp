<script type="text/javascript">
    var section = "<%=section%>";
    var urlprefix = "<%=host+contextRoot%>";
    var trackString = "coding,noncoding,snp,smallnc";
    var minCoord =<%=min%>;
    var maxCoord =<%=max%>;

    var initMin =<%=min%>;
    var initMax =<%=max%>;

    var chr = "<%=chromosome%>";
    var rnaDatasetID =<%=rnaDatasetID%>;
    var arrayTypeID =<%=arrayTypeID%>;
    var panel = "<%=panel%>";
    var forwardPValueCutoff =<%=forwardPValueCutoff%>;
    var pValueCutoff =<%=pValueCutoff%>;
    var transcriptome = "<%=transcriptome%>";
    var cisOnly = "<%=cisOnly%>";
    var filterExpanded = 0;
    var tblBQTLAdjust = false;
    var tblFromAdjust = false;
    var tblFrom;
    var ucsctype = "region";
    var ucscgeneID = "";
    var defaultView = "<%=defView%>";
    <%if(region){%>
    var selectGene = "";
    <%}else{%>
    var selectGene = "<%=selectedEnsemblID%>";
    <%}%>

    var contextRoot = "<%=contextRoot%>";
    var dataPrefix = "";
    var skipSetSelection = 0;
    var iconPath = "<%=imagesDir%>icons/";
    var trackMenu = [];
    var viewMenu = [];
    var fixedWidth = -1;
    console.log("urlprefix:" + urlprefix);
</script>

<style>
    #trackListDiv {
        display: inline-block;
        vertical-align: text-top;
        width: 20%;
    }

    #regionTableDiv {
        display: inline-block;
        vertical-align: text-top;
        width: 79%;
    }

    #trackContent {
        text-align: center;
    }

    @media screen and (max-width: 1450px) {
        #trackListDiv {
            width: 100%;
            text-align: left;
        }

        #trackList {
            display: inline-block;
            vertical-align: text-top;
            width: 48%;
        }

        #trackContent {
            display: inline-block;
            vertical-align: text-top;
            width: 47%;
        }

        #regionTableDiv {
            width: 100%;
        }

        #mouseHelp {
            font-size: 12px;
        }
    }

    .ui-widget {
        font-size: 0.8em;
    }

    ul#viewSelectMenu0 li, ul#viewSelectMenu1 li, ul#zoomSelectMenu0 li, ul#zoomSelectMenu1 li {
        cursor: pointer;
    }
</style>


<%if (genURL.get(0) != null && !genURL.get(0).startsWith("ERROR:")) {%>


<%
    String tmpURL = genURL.get(0);
    int second = tmpURL.lastIndexOf("/", tmpURL.length() - 2);
    String folderName = tmpURL.substring(second + 1, tmpURL.length() - 1);
    DecimalFormat dfC = new DecimalFormat("#,###");
%>

<script>
    hideWorking();
    var tisLen =<%=tissuesList1.length%>;
    var regionfolderName = "<%=folderName%>";
    $('#inst').hide();
    $(document).on('click', '.triggerEC', function (event) {
        var baseName = $(this).attr("name");
        $(this).toggleClass("less");
        if ($("#" + baseName).is(":hidden")) {
            $("#" + baseName).show();
        } else {
            $("#" + baseName).hide();
        }

    });

    $(document).on('click', '.helpImage', function (event) {
            var id = $(this).attr('id');
            $('#' + id + 'Content').dialog("option", "position", {my: "right top", at: "left bottom", of: $(this)});
            $('#' + id + 'Content').dialog("open").css({'font-size': 12});
            event.stopPropagation();
            //return false;
        }
    );

    $(document).on('click', '.legendBtn', function (event) {
        $('#legendDialog').dialog("option", "position", {my: "left top", at: "left bottom", of: $(this)});
        $('#legendDialog').dialog("open");
    });
</script>
<div id="page" style="min-height:1050px;text-align:center;">
    <BR>
    <div style="width:100%;text-align:left;"><span class="trigger less triggerEC" name="shortcutButtons"
                                                   style="font-weight: bold;font-size:16px;">Shortcuts:</span>
        <div id="shortcutButtons">
        <span>
            <span class="shrt-button region" name="detail1">Region Summary</span>
            <%if (myOrganism.equals("Rn") && genomeVer.equals("rn6")) {%>
                <span class="shrt-button region" name="detail4">Region Gene Expression</span>
            <%}%>
            <span class="shrt-button region" name="detail2">Region Gene eQTLs</span>
            <span class="shrt-button region" name="detail3">Region WGCNA</span>

            <span class="shrt-button gene" name="geneDetail">Gene Summary</span>
            <span class="shrt-button gene" name="geneEQTL">Gene eQTLs</span>
            <span class="shrt-button gene" name="geneApp">Gene Tissue Expression</span>
            <span class="shrt-button gene" name="geneWGCNA">Gene WGCNA</span>
            <span class="shrt-button gene" name="miGenerna">Gene miRNA targeting</span>
            <!--<span class="shrt-button gene" name="geneGO">Gene GO Summary</span>-->
        </span>
        </div>
    </div>
    <div style="width:100%;text-align:left;">
        Not sure where to start: <a href="web/demo/largerDemo.jsp?demoPath=web/demo/BrowserNavDemo" target="_blank">watch
        a quick navigation demonstration</a>
        or <a id="fbhelp1" class="fancybox" rel="fancybox-thumb" href="web/GeneCentric/help1.1.jpg"
              title="Navigation Help<BR>Basic Controls on the main image."> view the help images again</a><a
            id="fbhelp2" class="fancybox" rel="fancybox-thumb"
            href="web/GeneCentric/help2.jpg"
            title="Controls to select and edit views."></a><a
            id="fbhelp3" class="fancybox" rel="fancybox-thumb" href="web/GeneCentric/help3.jpg"
            title="Controls to select and edit views."></a>
    </div>

    <div id="imageMenu"></div>
    <div id="viewMenu"></div>
    <div id="trackMenu"></div>

    <div id="warningOldVersion" style="display: none;"><span style="color: #ff0000">NOTE:</span> This is not the latest version of PhenoGen datasets.  Rn7/HRDP v7.1 is the latest version.  You can select it above or <a href="https://phenogen.org/gene.jsp?speciesCB=Rn&geneTxt=<%=chromosome%>:<%=min%>-<%=max%>&overideGV=Y&genomeVer=rn7&dataVer=hrdp7.1&auto=Y">click here</a>, unless you need a specific genome version we recommend using the most current dataset.</div>
    <div style=" background-color:#DEDEDE; color:#000000; text-align:left; width:100%;">
        <table style="width:100%;" cellpadding="0" cellspacing="0">
            <tbody>
            <TR>
                <TD style="background-color:#DEDEDE;font-size:18px; font-weight:bold;">
                    <span class="trigger less triggerEC" name="collapsableImage">Region Image</span>
                    <div class="inpageHelp" style="display:inline-block; "><img id="HelpRegionImage" class="helpImage"
                                                                                src="../web/images/icons/help.png"/>
                    </div>
                </TD>
                <TD style="background-color:#DEDEDE; text-align:center; width:50%;font-size:18px; font-weight:bold; vertical-align: middle;">
                    <span id="viewLbl0">View:</span>
                    <span id="viewModifiedCtl0" style="display:none;">
                            (Modified <span class="Imagetooltip"
                                            title="This view has been modified.  To save this change you should use the arrow next to Select/Edit Views to Save or Save As..  Otherwise your change will persist only while this window is not refreshed and not left inactive for more than 59 minutes.">
                                        <img src="../web/images/icons/info.gif"/>)
                                       </span>
                        </span>
                </TD>
                <TD style="background-color:#DEDEDE;">
                    <div id="imageHeader" style=" font-size:12px; float:right;"></div>
                </TD>
            </TR>
            </tbody>
        </table>
    </div>

    <div style="border-color:#CCCCCC; border-width:1px; border-style:inset; text-align:center;">
        <span id="mouseHelp" style=" min-height:20px;">Navigation Hints: Hold mouse over areas of the image for available actions.</span>
        <BR/>
        <div id="collapsableImage" class="geneimage">
            <div id="geneImage" class="ucscImage" style="display:inline-block;width:100%;">

                <script src="javascript/gdb.2.9.25.min.js" type="text/javascript"></script>
                <!--<script src="javascript/GenomeDataBrowser2.9.7.js" type="text/javascript"></script>
                <script src="javascript/GenomeReport2.7.3.js" type="text/javascript"></script>
                <script src="javascript/GenomeViewMenu2.6.3.js" type="text/javascript"></script>
                <script src="javascript/GenomeTrackMenu2.6.2.js" type="text/javascript"></script>
                <script src="javascript/wgcnaBrowser1.4.0.js" type="text/javascript"></script>-->
            </div>
        </div>

    </div><!--end Border Div -->
    <div id="regionDiv">
        <BR/>
        <div style="width:100%;">
            <div style="font-size:18px; font-weight:bold;  color:#FFFFFF; text-align:center; width:100%; padding-top: 3px; ">
                <span id="detail1" class="detailMenu selected" name="regionSummary">Track Details<div class="inpageHelp"
                                                                                                      style="display:inline-block; "><img
                        id="HelpTrackDetails" class="helpImage" src="../web/images/icons/help.png"/></div></span>
                <%if (myOrganism.equals("Rn") && (genomeVer.equals("rn6") || genomeVer.equals("rn7"))) {%>
					<span id="detail2" class="detailMenu" name="regionEQTLTable">Genes with an eQTL in this region<div
							class="inpageHelp" style="display:inline-block;"><img
							id="HelpeQTLTab" class="helpImage" src="../web/images/icons/help.png"/></div></span>
					<span id="detail3" class="detailMenu" name="regionWGCNAEQTL">WGCNA<div class="inpageHelp"
																						   style="display:inline-block; "><img
							id="HelpRegionWGCNATab" class="helpImage" src="../web/images/icons/help.png"/></div></span>
					<span id="detail4" class="detailMenu" name="regionExpr">Expression<div class="inpageHelp"
																						   style="display:inline-block; "><img
							id="HelpRegionExprTab" class="helpImage" src="../web/images/icons/help.png"/></div></span>
                <%}%>
            </div>
        </div>
        <div style="font-size:18px; font-weight:bold; background-color:#3f92d2; color:#FFFFFF; text-align:left; width:100%;">
            <span class="trigger triggerEC less" name="collapsableReport">Region Summary</span>
            <div class="inpageHelp" style="display:inline-block; "><img id="HelpRegionSummary" class="helpImage"
                                                                        src="../web/images/icons/help.png"/></div>
        </div>
        <div id="collapsableReport" style="width:100%;">
            <div style="display:inline-block;width:100%;" id="regionSummary">
                <div id="trackListDiv">
                    <div id="trackList" style="text-align:left;">
                        <span style="color:#000000; font-weight:bold;">Track List:</span>
                        <UL id="collapsableReportList" style="list-style:none; margin:10px;">
                        </UL>
                    </div>
                    <div id="trackContent">
                        <span style="font-weight:bold;">Break down of track count*</span><BR/><BR/>
                        <div id="trackGraph">
                        </div>
                        <span>*Note: Depending on the track settings some features may not be displayed and will not be reflected in the image above.</span>
                    </div>
                </div>
                <div id="regionTableDiv">
                    <div id="regionTableSubHeader" class="regionSubHeader"
                         style="font-size:18px; font-weight:bold; text-align:left; width:100%; ">
                        <!--<span class="trigger triggerRegionTable" name="regionTable"  style="margin-left:30px;"></span>-->
                        <span style="margin-left:30px;">Features in Selected Track<div class="inpageHelp"
                                                                                       style="display:inline-block; "><img
                                id="HelpUCSCImage"
                                class="helpImage"
                                src="../web/images/icons/help.png"/></div></span>
                    </div>
                    <div id="regionTable" style="display:none;">


                    </div>
                </div>
            </div>
            <div style="display:none;" id="regionEQTLTable">

            </div>
            <div style="display:none;" id="regionWGCNAEQTL">

            </div>
            <div style="display:none;overflow: auto;" id="regionExpr" class="exprDiv">
                <div id="regionExprsrcCtrl" class="srcCtrl" style="text-align:center;"></div>
                <div class="help" style="width:100%;display:inline-block;text-align:center;"></div>
                <div class="exprCol" id="expRegionLeft" style="display:inline-block;">
                    <div style="width:100%;text-align: center;"><H2><span id="regionExprTitlel"></span></h2></div>
                    <BR>
                    <div id="chartLeftregionExpr" style="width:98%;">
                        <div id="leftExprLoading" style="text-align: center;">
                            <img src="/web/images/wait.gif"><BR>
                            Loading...
                        </div>
                    </div>

                </div>
                <div class="exprCol" id="expRegionRight" style="display:none;">
                    <div style="width:100%;text-align: center;"><H2><span id="regionExprTitler"></span></h2></div>
                    <BR>
                    <div id="chartRightregionExpr" style="width:98%;">
                        <div id="rightExprLoading" style="text-align: center;">
                            <img src="/web/images/wait.gif"><BR>
                            Loading...
                        </div>
                    </div>

                </div>
                <!--<div class="exprCol" id="expRegionBrain" style="display:inline-block;">
                    <div style="width:100%;text-align: center;"><H2><span id="regionExprTitleb"></span></h2></div>
                    <BR>
                    <div id="chartBrainregionExpr" style="width:98%;">
                        <div id="brainExprLoading" style="text-align: center;">
                            <img src="/web/images/wait.gif"><BR>
                            Loading...
                        </div>
                    </div>

                </div>
                <div class="exprCol" id="expRegionLiver" style="display:inline-block;">
                    <div style="width:100%;text-align: center;"><H2><span id="regionExprTitlel"></span></h2></div>
                    <BR>
                    <div id="chartLiverregionExpr" style="width:98%;">
                        <div id="liverExprLoading" style="text-align: center;">
                            <img src="/web/images/wait.gif"><BR>
                            Loading...
                        </div>
                    </div>
                </div>
                <div class="exprCol" id="expRegionKidney" style="display:inline-block;">

                    <div style="width:100%;text-align: center;"><H2><span id="regionExprTitlek"></span></h2></div>
                    <BR>
                    <div id="chartKidneyregionExpr" style="width:98%;">
                        <div id="kidneyExprLoading" style="text-align: center;">
                            <img src="/web/images/wait.gif"><BR>
                            Loading...
                        </div>
                    </div>
                </div>
                <%if (genomeVer.equals("rn7")) {%>
                <div class="exprCol" id="expRegionHeart" style="display:inline-block;">

                    <div style="width:100%;text-align: center;"><H2><span id="regionExprTitleh"></span></h2></div>
                    <BR>
                    <div id="chartHeartregionExpr" style="width:98%;">
                        <div id="heartExprLoading" style="text-align: center;">
                            <img src="/web/images/wait.gif"><BR>
                            Loading...
                        </div>
                    </div>
                </div>
                <%}%>-->
            </div>
        </div><!--collapsableReport end-->
    </div>

    <div id="selectedDetailHeader"
         style=" display:none; font-size:18px; font-weight:bold; background-color:#00992D; color:#FFFFFF; text-align:left; width:100%;">
        <span class="trigger less triggerEC" name="selectedDetail">Selected Feature Image</span>
        <div class="inpageHelp" style="display:inline-block; "><img id="HelpUCSCImage" class="helpImage"
                                                                    src="../web/images/icons/help.png"/></div>
        <span class="closeDetail" style="float:right;margin-right: 8px;"><img
                src="../web/images/icons/close.png"/></span>
    </div>
    <div id="selectedDetail" style="display:none;">
        <div id="selectedImage" style="text-align:center;">
        </div>
        <div id="selectedReport">
        </div>
    </div>
    <div style="display:none">
        <a id="helpExampleNav" class="fancybox fancybox.iframe" href="web/GeneCentric/example.jsp"
           title="Browser Navigation"></a>
    </div>

    <BR/><BR/><BR/>

    <a href="" target="_blank" style="display:none;" id="fileDownload"></a>

</div>
<!-- ends page div -->

<script type="text/javascript">
    $("span[name='" + defaultView + "']").addClass("selected");

    $(document).on('click', 'span.closeDetail', function () {
        $('div#selectedDetail').hide();
        $('div#selectedDetailHeader').hide();
        $('div.viewsLevel1').hide();
        $('div.trackLevel1').hide();
        svgList[0].clearSelection();
        if (!$('div#collapsableReport').is(':visible')) {
            $('div#collapsableReport').show();
            $("span[name='collapsableReport']").addClass("less");
        }
        //check for selected region tab , some need to be reloaded (WGCNA for example)
        if ($('span.detailMenu.selected').size() > 0) {
            var name = $('span.detailMenu.selected').attr("name");
            if (name === "regionWGCNAEQTL") {
                loadRegionWGCNA();
            }
        }
    });

    /*$('.regionDetailMenu').click(function (){
        var oldID=$('.regionDetailMenu.selected').attr("name");
        $("#"+oldID).hide();
        $('.regionDetailMenu.selected').removeClass("selected");
        $(this).addClass("selected");
        var id=$(this).attr("name");
        $("#"+id).show();
        if(id==="geneEQTL"){
            var jspPage="web/GeneCentric/geneEQTLAjax.jsp";
            var params={
                species: organism,
                geneSymbol: selectedGeneSymbol,
                chromosome: chr,
                id:selectedID
            };
            loadDivWithPage("div#geneEQTL",jspPage,false,params,
                    "<span style=\"text-align:center;width:100%;\"><img src=\"web/images/ucsc-loading.gif\"><BR>Loading...</span>");
        }

    });*/

    $(".Imagetooltip").tooltipster({
        position: 'top-right',
        maxWidth: 250,
        offsetX: 24,
        offsetY: 5,
        contentAsHTML: true,
        //arrow: false,
        interactive: true,
        interactiveTolerance: 350
    });


    //Setup Fancy box for example
    $('.fancybox').fancybox({
        width: "800px",
        //height:$(document).height(),
        scrollOutside: false
        /*afterClose: function(){
                $('body.noPrint').css("margin","5px auto 60px");
                return;
        }*/
    });

    <%@ include file="/javascript/chart.js" %>
    <%@ include file="/web/GeneCentric/include/js_addExprSrcCtrl.js" %>
    var gs;
    $(document).ready(function () {
        setTimeout(function () {
            gs = GenomeSVG(".ucscImage", $(window).width() - 25, minCoord, maxCoord, 0, chr, "gene");
            displayHelpFirstTime();
        }, 20);
        var pe;
        setTimeout(function () {
            if(dataVer==="hrdp7.1"){
                $("#regionExpr").html("<span style=\"text-align:center;width:100%;color:#FF0000;font-size:20pt;\">Coming soon for HRDP v7.1. HRDP v6(rn7) does have WGCNA modules if you would like to switch please change the drop down list at the top of the page.</span>");
            }else{
            	pe = PhenogenExpr({
					"div": "regionExpr",
					"genomeBrowser": gs,
					"type": "heatmap",
					"featureType": "Long"
            	});
            }
            /*if ($(window).width() < 1200) {
                pe.rlChart.setWidth("98%");
                pe.rrChart.setWidth("98%");
                pe.rkChart.setWidth("98%");
            }*/
        }, 5000);
        //svgList[1].updateLinks();
        $(window).resize(function () {
            if ($(window).width() < 1200 && pe) {
                if (pe.rrChart) {
                    pe.rrChart.setWidth("98%");
                }
                if (pe.rlChart) {
                    pe.rlChart.setWidth("98%");
                }
                /*if (pe.rbChart) {
                    pe.rbChart.setWidth("98%");
                }
                if (pe.rlChart) {
                    pe.rlChart.setWidth("98%");
                }
                if (pe.rkChart) {
                    pe.rkChart.setWidth("98%");
                }*/
            } else {
                if (pe.rrChart) {
                    pe.rrChart.setWidth("45%");
                }
                if (pe.rlChart) {
                    pe.rlChart.setWidth("45%");
                }
                /*if (pe && pe.rbChart) {
                    pe.rbChart.setWidth("45%");
                }
                if (pe && pe.rlChart) {
                    pe.rlChart.setWidth("45%");
                }
                if (pe && pe.rkChart) {
                    pe.rkChart.setWidth("45%");
                }*/
            }
        });
    });


</script>


<%
} else {
    if (myGene.startsWith("ENS")) {
        if (genURL.get(0).startsWith("ERROR:")) {
%>
<div class="error"><%=genURL.get(selectedGene)%><BR/>The administrator has been notified of the problem and we will work
    on supporting contigs. We apologize for
    any inconvenience.
</div>
<BR/><BR/><BR/><BR/><BR/><BR/><BR/><BR/><BR/><BR><BR>
<%} else {%>
<div class="error">ERROR: The Ensembl ID entered is not present in the current version of the Ensembl database being
    used
    for your selected genome version (<%=genomeVer%>).
    <BR><BR>
    <%
        if (genomeVer.startsWith("rn")) {
            int port = request.getServerPort();
            String prefix = "http";
            if (port == 443) {
                prefix += "s";
            }
            String newGenomeVer = "rn5";
    %>
    We recommend trying again after switching genome versions to <% if (genomeVer.equals("rn5")) {
        newGenomeVer = "rn6";%>Rn6<%} else {%>Rn5<%}%> by <a
            href="<%=prefix+"://"+host+contextRoot+"gene.jsp?geneTxt="+myGene+"&genomeVer="+newGenomeVer+"&auto=Y&overideGV=Y"%>">following
        this link</a>.
    <BR><BR>
    It is possible that the ID is from an older ensembl/genome version or an intermediate version of the ensembl
    database that is not supported on PhenoGen. We
    only support the latest
    version of the Ensembl database for each genome version. Currently v79 for rn5 and v105 for rn6 and v111 for rn7.

    <%}%>
</div>
<BR><BR><BR/><BR><BR>
<%}%>
<%} else {%>
<div class="error"><%=genURL.get(selectedGene)%><BR/>The administrator has been notified of the problem and will
    investigate the error. We apologize for any
    inconvenience.
</div>
<BR/><BR/><BR/><BR/><BR/><BR/><BR/><BR/><BR/><BR><BR>
<%}%>
<%}%>


<script>
    if(dataVer !="hrdp7.1"){
             $("div#warningOldVersion").show();
    }
</script>