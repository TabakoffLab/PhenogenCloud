<%@ include file="/web/common/anon_session_vars.jsp" %>
<jsp:useBean id="gdt" class="edu.ucdenver.ccp.PhenoGen.tools.analysis.GeneDataTools" scope="session"> </jsp:useBean>
<%
    log.debug("top run circos:\n");
    //
    // Initialize some variables
    //
    String iframeURL = null;
    String species="Mm";
    String genomeVer="mm10";
    String selectedCutoffValue="2";
    int geneListID=-99;
    String chromosomeString="";
    String tissueString="";
    String source="";
    String message="";
    String path="";
    String HRDPversion="3";
    String rnaDSIDs="93,94";


    //String contextRoot = (String) session.getAttribute("contextRoot");
    //String host = (String) session.getAttribute("host");
    //String appRoot = (String) session.getAttribute("applicationRoot");
    String fullPath = applicationRoot + contextRoot;

    log.debug("FULL PATH:"+fullPath);

    // Get parameters
    if(request.getParameter("cutoffValue")!=null){
        selectedCutoffValue = request.getParameter("cutoffValue");
    }
    if(request.getParameter("organism")!=null){
        species = request.getParameter("organism");
    }
    if(request.getParameter("source")!=null){
        source = request.getParameter("source");
    }
    if(request.getParameter("chrList")!=null){
        chromosomeString = request.getParameter("chrList");
    }
    if(request.getParameter("genomeVer")!=null){
        genomeVer = FilterInput.getFilteredInputGenomeVer(request.getParameter("genomeVer"));
    }
    if(request.getParameter("path")!=null){
        path = request.getParameter("path");
    }
    if(request.getParameter("chromosomes")!=null){
        chromosomeString = request.getParameter("chromosomes");
    }
    if(request.getParameter("version")!=null){
        HRDPversion = request.getParameter("version");
        if(HRDPversion.equals("1")){
            rnaDSIDs="21,23";
        }
    }
    if(request.getParameter("tissues")!=null){
        tissueString = request.getParameter("tissues");
    }else {
        if (species.equals("Mm")) {
            tissueString = "Brain";
        } else {
            // we assume if not mouse that it's rat
            if(source.equals("seq")) {
                tissueString = "Brain;Liver";
            }else{
                tissueString = "Brain;Liver;Heart;BAT";
            }

        }
    }

    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setDateHeader("Expires", 0);
%>
<H2>eQTLs</H2>
<table>
    <thead>

    </thead>
    <tbody>
    <TR>
        <TD></TD>
        <TD></TD>
    </TR>
    </tbody>
</table>

