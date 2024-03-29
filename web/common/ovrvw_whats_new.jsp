<%--
 *  Author: Spencer Mahaffey
 *  Created: August, 2012
 *  Description:  
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/access/include/login_vars.jsp" %>

<%

    extrasList.add("fancyBox/helpers/jquery.fancybox-thumbs.js");
    extrasList.add("fancyBox/jquery.fancybox.js");
    extrasList.add("index.css");
    extrasList.add("normalize.css");
    extrasList.add("jquery.fancybox-thumbs.css");
    extrasList.add("jquery.fancybox.css");
%>

<% pageTitle = "Overview What's New";
    pageDescription = "Description of new features on PhenoGen";
%>

<%@ include file="/web/common/header_adaptive_menu.jsp" %>

<div id="welcome">

    <h2>What's New</h2>
    <div id="overview-wrap">
        <div id="overview-content-wide" style="display:inline-block;">
            <%@ include file="/web/common/whats_new_content.jsp" %>
        </div>
        <div style="display:inline-block;width:40%;float:right;">
            Informatics Workshop Overview:<BR>
            <video id="demoVideo" width="95%" controls="controls" poster="<%=webDir%>demo/slides2_350.png" preload="none">
                <source src="<%=webDir%>demo/workshop.mp4" type="video/mp4">
                <source src="<%=webDir%>demo/workshop.webm" type="video/webm">
                <object data="<%=webDir%>demo/workshop.mp4" width="100%">
                </object>
                Your browser is not likely to work with the Genome Browser if you are seeing this message. Please see <a
                    href="<%=commonDir%>siteRequirements.jsp">Browser Support/Site Requirements</a>
            </video>
            <BR><BR>
            Example WGCNA miRNA targeting View:
            <a class="fancybox" rel="fancybox-thumb" href="<%=webDir%>overview/browseWGCNA_mir.png" title="Example WGCNA miRNA targeting View">
                <img src="<%=webDir%>overview/browseWGCNA_mir.png" alt="Example WGCNA miRNA targeting View" style="width:95%;">
            </a>
            <BR/><BR/>
            Example WGCNA Gene Ontology View:
            <a class="fancybox" rel="fancybox-thumb" href="<%=webDir%>overview/browseWGCNA_go.png" title="Example WGCNA Gene Ontology View">
                <img src="<%=webDir%>overview/browseWGCNA_go.png" alt="Example WGCNA Gene Ontology View" style="width:95%;">
            </a>
            <BR/><BR/>
            Example WGCNA Module View:
            <a class="fancybox" rel="fancybox-thumb" href="<%=webDir%>overview/browseWGCNA.png" title="Example WGCNA Module View">
                <img src="<%=webDir%>overview/browseWGCNA.png" alt="Example WGCNA Module View" style="width:95%;">
            </a>
            <BR/><BR/>

            Example WGCNA eQTL Module View:
            <a class="fancybox" rel="fancybox-thumb" href="<%=webDir%>overview/browseWGCNA_eQTL.png" title="Example WGCNA eQTL Module View">
                <img src="<%=webDir%>overview/browseWGCNA_eQTL.png" alt="Example WGCNA eQTL Module View" style="width:95%;">
            </a>
            <BR/><BR/>

            Example Region View:
            <a class="fancybox" rel="fancybox-thumb" href="<%=webDir%>overview/browser_region.jpg" title="Example Region View">
                <img src="<%=webDir%>overview/browser_region.jpg" alt="Detailed Region Example" style="width:95%;">
            </a>
            <BR/><BR/>
            Example Tissue View showing Array and RNA-Seq Data and a zoomed in view from holding the mouse over a region:
            <a class="fancybox" rel="fancybox-thumb" href="<%=webDir%>overview/browser_ttRNACount.jpg"
               title="Example Tissue View with liver, showing Affymetrix Probe Set Array Data and RNA-Seq Data and the tool tip view showing a zoomed in view from holding the mouse over a region of the RNA-Seq Read Depth track.">
                <img src="<%=webDir%>overview/browser_ttRNACount.jpg" alt="Detailed Region Example" style="width:95%;">
            </a>


        </div>
    </div> <!-- // end overview-wrap -->
</div>
<!-- // end welcome -->

<script type="text/javascript">
    $(document).ready(function () {


        $('.fancybox').fancybox({
            helpers: {
                title: {
                    type: 'inside',
                    position: 'top'
                },
                thumbs: {
                    width: 200,
                    height: 100
                }
            },
            nextEffect: 'fade',
            prevEffect: 'fade'
        });


        $("div.clicker").click(function () {
            var thisHidden = $("span#" + $(this).attr("name")).is(":hidden");
            var tabTriggers = $(this).parents("ul").find("span.branch").hide();
            var baseName = $(this).attr("name");
            $("span#" + baseName).removeClass("clickerLess");
            if (thisHidden) {
                $("span#" + baseName).show().addClass("clickerLess");
            }
            $("div." + baseName).removeClass("clicker");
            $("div." + baseName).addClass("clickerLess");
        });

    });

</script>

<%@ include file="/web/common/footer.jsp" %>
