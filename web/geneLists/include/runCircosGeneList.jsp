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
        genomeVer = request.getParameter("genomeVer");
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
    if(selectedCutoffValue.indexOf(".")>-1) {
        selectedCutoffValue = selectedCutoffValue.substring(0, selectedCutoffValue.indexOf("."));
    }
    int cutoff=Integer.parseInt(selectedCutoffValue);
    CircosDataTools cdt=new CircosDataTools(session,path);
    cdt.runCircosGeneList(selectedGeneList.getGene_list_id(),chromosomeString,tissueString,source,genomeVer,rnaDSIDs,cutoff);
    //
    // call perl script
    //
    //String filePrefixWithPath=cdt.getPath();
    if(cdt.isSuccess()){
        log.debug("Circos run completed successfully");
        String svgFile = cdt.getURL();
        iframeURL = svgFile;
    }
    else{
        //log.debug("Circos run failed");
        // be sure iframeURL is still null
        iframeURL = null;
        message="There was an error running Circos.  Please try again later.  The administrator has been notified of the error.<BR>"+cdt.getMessage();
    } // end of if(circosReturnStatus)

    //response.setContentType("application/json");
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setDateHeader("Expires", 0);
%>


{
    "path":"<%=iframeURL%>"
}


