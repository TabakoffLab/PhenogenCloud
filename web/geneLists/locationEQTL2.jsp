<%@ include file="/web/geneLists/include/geneListHeader.jsp"  %>

<jsp:useBean id="myQTL" class="edu.ucdenver.ccp.PhenoGen.data.QTL"> </jsp:useBean>
<jsp:useBean id="myOrganism" class="edu.ucdenver.ccp.PhenoGen.data.Organism"> </jsp:useBean>
<jsp:useBean id="thisIDecoderClient" class="edu.ucdenver.ccp.PhenoGen.tools.idecoder.IDecoderClient"> </jsp:useBean>
<jsp:useBean id="gdt" class="edu.ucdenver.ccp.PhenoGen.tools.analysis.GeneDataTools" scope="session"> </jsp:useBean>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setDateHeader("Expires", 0);
    extrasList.add("jquery.twosidedmultiselect.js");
    extrasList.add("tsmsselect.css");
    optionsList.add("geneListDetails");
    optionsList.add("chooseNewGeneList");
    if(userLoggedIn.getUser_name().equals("anon")){
        optionsListModal.add("linkEmail");
    }
    LinkedHashSet iDecoderSetForGenes = (session.getAttribute("iDecoderSet") != null ?
            new LinkedHashSet((Set) session.getAttribute("iDecoderSet")) : null);

%>
<%@ include file="/web/geneLists/include/geneListJS.jsp"  %>
<%@ include file="/web/common/header_adaptive_menu.jsp" %>
<%@ include file="/web/geneLists/include/viewingPane.jsp" %>
<div class="page-intro">
    <p>&nbsp;  </p>
</div> <!-- // end page-intro -->

<% if (fromQTL.equals("")) { %>
<%@ include file="/web/geneLists/include/geneListToolsTabs.jsp" %>
<% } %>

<%
    gdt.setSession(session);
    String uuid="";

    String org=selectedGeneList.getOrganism();
    String id="";
    String chromosome="";
    String genomeVer="";

    String[] selectedLevels=null;
    String levelString="core;extended;full";
    String fullOrg="";
    String panel="";
    String gcPath="";
    String source="seq";
    int selectedGene=0;
    ArrayList<String>geneSymbol=new ArrayList<String>();


    if(request.getParameter("uuid") !=null){
        uuid=FilterInput.getFilteredInput(request.getParameter("uuid"));
    }
    if(request.getParameter("levels")!=null && !request.getParameter("levels").equals("") && !request.getParameter("levels").equals("null")){
        String tmpSelectedLevels = FilterInput.getFilteredInput(request.getParameter("levels"));
        selectedLevels=tmpSelectedLevels.split(";");
        log.debug("Getting selected levels:"+tmpSelectedLevels);
        levelString = "";
        //selectedLevelError = true;
        for(int i=0; i< selectedLevels.length; i++){
            //selectedLevelsError = false;
            levelString = levelString + selectedLevels[i] + ";";
        }
    }else{
        log.debug("Getting selected levels: NULL Using defaults.");
        selectedLevels=levelString.split(";");
    }
    log.debug("Getting species:"+request.getParameter("species"));
    if(request.getParameter("species")!=null && !request.getParameter("species").equals("null") ){
        org=FilterInput.getFilteredInput(request.getParameter("species").trim());
        if(org.equals("Rn")){
            panel="BNLX/SHRH";
            fullOrg="Rattus_norvegicus";
            genomeVer="rn6";
        }else{
            panel="ILS/ISS";
            fullOrg="Mus_musculus";
            genomeVer="mm10";
        }
    }else{
        if(org.equals("Rn")){
            panel="BNLX/SHRH";
            fullOrg="Rattus_norvegicus";
            genomeVer="rn6";
        }else{
            panel="ILS/ISS";
            fullOrg="Mus_musculus";
            genomeVer="mm10";
        }
    }
    log.debug("Getting chromosomes:"+request.getParameter("chromosome"));
    if(request.getParameter("chromosome")!=null && !request.getParameter("chromosome").equals("null")){
        chromosome=FilterInput.getFilteredInput(request.getParameter("chromosome"));
    }

    if(request.getParameter("id")!=null){
        id=FilterInput.getFilteredInput(request.getParameter("id"));
    }
    if(request.getParameter("source")!=null){
        source=FilterInput.getFilteredInput(request.getParameter("source"));
    }
    if(request.getParameter("genomeVer")!=null){
        genomeVer=request.getParameter("genomeVer");
    }

    gcPath=applicationRoot + contextRoot+"tmpData/"+userLoggedIn.getUser_name()+"/GeneLists/";
    if(userLoggedIn.getUser_name().equals("anon")){
        gcPath=gcPath+uuid+"/"+selectedGeneList.getGene_list_id()+"/";
    }

    String[] tissuesList1=new String[1];
    String[] tissuesList2=new String[1];
    if(org.equals("Rn")){
        if(source.equals("seq")){
            tissuesList1=new String[2];
            tissuesList2=new String[2];
            tissuesList1[0]="Brain";
            tissuesList2[0]="Whole Brain";
            tissuesList1[1]="Liver";
            tissuesList2[1]="Liver";
        }else{
            tissuesList1=new String[4];
            tissuesList2=new String[4];
            tissuesList1[0]="Brain";
            tissuesList2[0]="Whole Brain";
            tissuesList1[1]="Heart";
            tissuesList2[1]="Heart";
            tissuesList1[2]="Liver";
            tissuesList2[2]="Liver";
            tissuesList1[3]="Brown Adipose";
            tissuesList2[3]="Brown Adipose";
        }
    }else{
        source="array";
        tissuesList1[0]="Brain";
        tissuesList2[0]="Whole Brain";
    }

%>
<BR />

<script type="text/javascript">
    $('#geneEQTL table#circosOptTbl').css("top","0px");
    $("span[name='circosOption']").css("margin-left","60px");
    //runCircos();
</script>

<style type="text/css">
    /* Recommended styles for two sided multi-select*/
    .genemultiselect {
        width: 40%;
        float: left;
    }

    .genemultiselect select {
        width: 100%;
    }

    .tsmsoptions {
        width: 20%;
        float: left;
    }

    .tsmsoptions p {
        margin: 2px;
        text-align: center;
        font-size: larger;
        cursor: pointer;
    }

    .tsmsoptions p:hover {
        color: White;
        background-color: Silver;
    }
</style>
<script type="text/javascript">
    var source="<%=source%>";
    function displayWorkingCircos(){
        document.getElementById("wait2").style.display = 'block';
        //document.getElementById("circosError1").style.display = 'none';
    }
    function hideWorkingCircos(){
        document.getElementById("wait2").style.display = 'none';
        //document.getElementById("circosError1").style.display = 'none';
    }
    function runCircos(){
        $('#wait2').show();
        var chrList = "";
        $("#chromosomesMS option").each(function () {
            chrList += $(this).val() + ";";
        });

        var tisList = "";
        $("#tissuesMS option").each(function () {
            tisList += $(this).val() + ";";
        });

        var pval=$('#cutoffValue').val();
        var tcID=$('#transcriptClusterID').val();
        if(source==="seq"){
            tcID=idStr;
        }
        var path="<%=gcPath%>";

        $.ajax({
            url: "/web/geneLists/runCircosGeneList.jsp",
            type: 'GET',
            cache: false,
            data: {cutoffValue:pval,transcriptClusterID:tcID,tissues:tisList,chromosomes:chrList,geneCentricPath:path,genomeVer:genomeVer,source:source},
            dataType: 'html',
            beforeSend: function(){
            },
            complete: function(){
                displayType="RNA-Seq";
                if(source==="array"){
                    displayType="Microarray";
                }
                $('span#typeLabel').html(displayType);
                $('#wait2').hide();
                $('#forIframe').show();
            },
            success: function(data2){
                $('#forIframe').html(data2);
            },
            error: function(xhr, status, error) {
                $('#forIframe').html("<div>An error occurred generating this image.  Please try back later.</div>");
            }
        });
        //$('.allowChromSelection').show();
    }
    function changeSource(){
        console.log("changeSource");
        tmpSrc=$('#sourceCB').val();
        if(tmpSrc==="seq"){
            $("#tissuesMS option[value='Heart']").remove();
            $("#tissuesMStsms option[value='Heart']").remove();
            $("#tissuesMS option[value='BAT']").remove();
            $("#tissuesMStsms option[value='BAT']").remove();
            $("td#trxClusterCB").hide();
        }else{
            $("#tissuesMS").append('<option value="Heart" selected>Heart</option>');
            $("#tissuesMS").append('<option value="BAT" selected>Brown Adipose</option>');
            $("td#trxClusterCB").show();
        }
        source=tmpSrc;
        //$("#tissuesMS").twosidedmultiselect();
    }
</script>
<%
    String selectedCutoffValue = null;
    String transcriptClusterFileName = null;
    String geneCentricPath = gcPath;
    String[] selectedChromosomes = null;
    String[] selectedTissues = null;
    String chromosomeString = null;
    String tissueString = null;
    String[] transcriptClusterArray = null;
    int[] transcriptClusterArrayOrder = null;
    Boolean transcriptError = null;
    String species = org;
    String selectedTranscriptValue = null;
    Boolean selectedChromosomeError = null;
    Boolean selectedTissueError = null;
    Boolean circosReturnStatus = null;
    Boolean allowChromosomeSelection = false; // This variable now controls both tissue and chromosome selection
    String iframeURL = null;
    String svgPdfFile = null;
    if(request.getParameter("cutoffValue")!=null){
        selectedCutoffValue = FilterInput.getFilteredInput(request.getParameter("cutoffValue"));
        log.debug(" Selected Cutoff Value " + selectedCutoffValue);

    }



    //
    // Create chromosomeNameArray and chromosomeSelectedArray
    // These depend on the species
    //

    int numberOfChromosomes;
    String[] chromosomeNameArray = new String[25];

    String[] chromosomeDisplayArray = new String[25];
    String doubleQuote = "\"";
    String isSelectedText = " selected="+doubleQuote+"true"+doubleQuote;
    String isNotSelectedText = " ";
    String chromosomeSelected = isNotSelectedText;

    if(species.equals("Mm")){
        numberOfChromosomes = 20;
        for(int i=0;i<numberOfChromosomes-1;i++){
            chromosomeNameArray[i]="mm"+Integer.toString(i+1);
            chromosomeDisplayArray[i]="Chr "+Integer.toString(i+1);
        }
        chromosomeNameArray[numberOfChromosomes-1] = "mmX";
        chromosomeDisplayArray[numberOfChromosomes-1]="Chr X";
    }
    else{
        numberOfChromosomes = 21;
        // assume if not mouse that it's rat
        for(int i=0;i<numberOfChromosomes-1;i++){
            chromosomeNameArray[i]="rn"+Integer.toString(i+1);
            chromosomeDisplayArray[i]="Chr "+Integer.toString(i+1);
        }
        chromosomeNameArray[numberOfChromosomes-1] = "rnX";
        chromosomeDisplayArray[numberOfChromosomes-1]="Chr X";
    }

    //
    // Create tissueNameArray and tissueSelectedArray
    // These are only defined for Rat
    //
    int numberOfTissues;
    String[] tissueNameArray = new String[4];

    String[] tissueDisplayArray = new String[4];

    String tissueSelected = isNotSelectedText;

    if(species.equals("Mm")){
        numberOfTissues = 1;
        tissueNameArray[0]="Brain";
        tissueDisplayArray[0]="Whole Brain";
    }
    else{

        if(source.equals("seq")){
            numberOfTissues = 2;
            // assume if not mouse that it's rat
            tissueNameArray[0]="Brain";
            tissueDisplayArray[0]="Whole Brain";
            tissueNameArray[1]="Liver";
            tissueDisplayArray[1]="Liver";
        }else{
            numberOfTissues = 4;
            // assume if not mouse that it's rat
            tissueNameArray[0]="Brain";
            tissueDisplayArray[0]="Whole Brain";
            tissueNameArray[1]="Heart";
            tissueDisplayArray[1]="Heart";
            tissueNameArray[2]="Liver";
            tissueDisplayArray[2]="Liver";
            tissueNameArray[3]="BAT";
            tissueDisplayArray[3]="Brown Adipose";
        }
    }


%>


<div style="text-align:center;">

    <div style="font-size:18px; font-weight:bold; background-color:#47c647; color:#FFFFFF;width:100%;text-align:left;">
        <span class="trigger less triggerEC" id="circosOption1" name="circosOption" >eQTL Image Options</span>
        <span class="eQTLtooltip" title="The controls in this section allow you to change the chromosomes and tissues included in the image as well as the P-value threshold.  If you can't see them click on the + icon.  Once you make changes click on the Click to Run Circos button."><img src="<%=imagesDir%>icons/info.gif"></span>
    </div>
    <div id="circosOption">
        <div style="text-align: center;">
            <strong>Data Source:</strong>
            <span class="eQTLtooltip" title="RNA-Seq eQTLs and Microarray eQTLs are available at the gene/transcript cluster level.  Please note the label at the top of the image will indicate the data source for the image displayed."><img src="<%=imagesDir%>icons/info.gif"></span>
            <%
                selectName = "sourceCB";

                selectedOption =source;
                onChange = "changeSource()";
                style = "";
                optionHash = new LinkedHashMap();
                optionHash.put("seq", "RNA-Seq");
                optionHash.put("array", "Microarrays");
            %><%@ include file="/web/common/selectBox.jsp" %>
            <span style="padding-left:20px;"><strong>P-value Threshold for Highlighting:</strong></span>
            <span class="eQTLtooltip" title="Loci with p-values below the chosen threshold are highlighted on the Circos plot in yellow; a line connects the significant loci with the physical location of the gene. All p-values are displayed on the Circos graphic as the negative log base 10 of the p-value."><img src="<%=imagesDir%>icons/info.gif"></span>

            <%
                selectName = "cutoffValue";
                if(selectedCutoffValue!=null){
                    selectedOption = selectedCutoffValue;
                }
                else{
                    selectedOption = "2.0";
                }
                onChange = "";
                style = "";
                optionHash = new LinkedHashMap();
                optionHash.put("1.0", "0.10");
                optionHash.put("2.0", "0.01");
                optionHash.put("3.0", "0.001");
                optionHash.put("4.0", "0.0001");
                optionHash.put("5.0", "0.00001");
            %>
            <%@ include file="/web/common/selectBox.jsp" %>
        </div>
        <table id="circosOptTbl" name="items" class="list_base" cellpadding="0" cellspacing="3" style="width:100%;text-align:left;" >
            <tbody >
            <TR class="allowChromSelection" >
                <%if(org.equals("Rn")){%>
                <TD colspan="2" style="text-align:left; width:50%;">
                    <table style="width:100%;">
                        <tbody>
                        <tr>
                            <td style="text-align:center;">
                                <strong>Tissues: Include at least one tissue.</strong>
                                <span class="eQTLtooltip" title="Select tissues to be displayed in Circos plot by using arrows to move tissues to the box on the right.
    Moving tissues to the box on the left will eliminate them from the Circos plot.
    At least one tissue MUST be included in the Circos plot."><img src="<%=imagesDir%>icons/info.gif"></span>
                            </td>
                        </tr>
                        <TR>
                            <td style="text-align:center;">
                                <strong>Excluded</strong><%=tenSpaces%><%=twentyFiveSpaces%><%=twentySpaces%><strong>Included</strong>
                            </td>
                        </TR>
                        <tr>
                            <td>

                                <select name="tissuesMS" id="tissuesMS" class="genemultiselect" size="6" multiple="true">

                                    <%

                                        for(int i = 0; i < numberOfTissues; i ++){
                                            tissueSelected=isNotSelectedText;
                                            if(selectedTissues != null){
                                                for(int j=0; j< selectedTissues.length ;j++){
                                                    if(selectedTissues[j].equals(tissueNameArray[i])){
                                                        tissueSelected=isSelectedText;
                                                    }
                                                }
                                            }


                                    %>

                                    <option value="<%=tissueNameArray[i]%>" selected><%=tissuesList1[i]%></option>

                                    <%} // end of for loop
                                    %>

                                </select>

                            </td>
                        </tr>
                        </tbody>
                    </table>
                </TD>
                <%} // end of checking species is Rn %>
                <TD style="text-align:left; width:50%;">
                    <table style="width:100%;">
                        <tbody>
                        <tr>
                            <td style="text-align:center;">
                                <strong>Chromosomes: (<%=chromosome%> must be included)</strong>
                                <span class="eQTLtooltip" title="Select chromosomes to be displayed in Circos plot by using arrows to move chromosomes to the box on the right.
    Moving chromosomes to the box on the left will eliminate them from the Circos plot.
    The chromosome where the gene is physically located MUST be included in the Circos plot."><img src="<%=imagesDir%>icons/info.gif"></span>
                            </td>

                        </tr>
                        <tr>
                            <td style="text-align:center;">
                                <strong>Excluded</strong><%=tenSpaces%><%=twentyFiveSpaces%><%=twentySpaces%><strong>Included</strong>
                            </td>
                        </tr>
                        <tr>
                            <td>

                                <select name="chromosomesMS" id="chromosomesMS" class="genemultiselect" size="6" multiple="true">

                                    <%

                                        for(int i = 0; i < numberOfChromosomes; i ++){
                                            chromosomeSelected=isNotSelectedText;
                                            if(chromosomeDisplayArray[i].substring(4).equals(chromosome)){
                                                chromosomeSelected=isSelectedText;
                                            }
                                            else {
                                                if(selectedChromosomes != null){
                                                    for(int j=0; j< selectedChromosomes.length ;j++){
                                                        //log.debug(" selectedChromosomes element "+selectedChromosomes[j]+" "+chromosomeNameArray[i]);
                                                        if(selectedChromosomes[j].equals(chromosomeNameArray[i])){
                                                            chromosomeSelected=isSelectedText;
                                                        }
                                                    }
                                                }
                                            }


                                    %>

                                    <option value="<%=chromosomeNameArray[i]%>" selected><%=chromosomeDisplayArray[i]%></option>

                                    <%} // end of for loop
                                    %>

                                </select>

                            </td>
                        </tr>
                        </tbody>
                    </table>
                </TD>
            </TR>
            <tr>

                <td colspan="3" style="text-align:center;">
                    <input type="hidden" id="hiddenGeneCentricPath" name="hiddenGeneCentricPath" value=<%=geneCentricPath%> />
                    <INPUT TYPE="submit" NAME="action" id="clickToRunCircos" Value="Click to run Circos" onClick="return runCircos()" style="display:inline-block;">
                    <div style="float: right;display:inline-block"><a href="http://genome.cshlp.org/content/early/2009/06/15/gr.092759.109.abstract" target="_blank" style="text-decoration: none">Circos: an Information Aesthetic for Comparative Genomics.</a></div>
                </td>



            </tr>
            </tbody>
        </table>
    </div>
    <BR>
    <BR /><BR /><BR />
    <div id="wait2" align="center" style="position:relative;top:-50px;"><img src="<%=imagesDir%>wait.gif" alt="Working..." text-align="center" >
        <BR />Preparing to run Circos...</div>


    <script>
        document.getElementById("wait2").style.display = 'none';
    </script>
    <div style="position:relative;top:-50px;width:100%;"><h2><span id="typeLabel">RNA-Seq</span> Based Gene Level eQTLs</h2></div>
    <div id="forIframe" style="position:relative;top:-50px;width:100%;">
    </div>


</div>




<script>

    $(document).ready(function() {

        $(".genemultiselect").twosidedmultiselect();
        var selectedChromosomes = $("#chromosomes")[0].options;
        //document.getElementById("circosError1").style.display = 'none';
        /*$(".triggerEQTL").click(function(){
        var baseName = $(this).attr("name");
        $(this).toggleClass("less");
        expandCollapse(baseName);
    });*/

        $('.eQTLtooltip').tooltipster({
            position: 'top-right',
            maxWidth: 350,
            offsetX: 8,
            offsetY: 5,
            contentAsHTML:true,
            //arrow: false,
            interactive: true,
            interactiveTolerance: 350
        });

        runCircos();

        $('#circosIFrame').attr('width',$(window).width()-50);
        $(window).resize(function (){
            $('#circosIFrame').attr('width',$(window).width()-50);
        });
    });

</script>









<script type="text/javascript">
    $("div#wait1").hide();
    $(document).ready(function(){
        setupPage();
    }); // document ready
</script>

<%@ include file="/web/common/footer_adaptive.jsp" %>