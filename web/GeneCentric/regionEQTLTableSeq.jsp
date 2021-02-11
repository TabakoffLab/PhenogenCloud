<%@ include file="/web/common/anon_session_vars.jsp" %>

<jsp:useBean id="gdt" class="edu.ucdenver.ccp.PhenoGen.tools.analysis.GeneDataTools" scope="session"></jsp:useBean>
<%
    java.util.Date startDate = new java.util.Date();
    log.debug("Starting eQTL from region.");
    gdt.setSession(session);
    ArrayList<edu.ucdenver.ccp.PhenoGen.data.Bio.Gene> fullGeneList = new ArrayList<edu.ucdenver.ccp.PhenoGen.data.Bio.Gene>();
    DecimalFormat dfC = new DecimalFormat("#,###");
    String myOrganism = "";
    String fullOrg = "";
    String panel = "";
    String chromosome = "";
    String folderName = "";
    String type = "";
    String genomeVer = "";
    String dataSource="seq";
    String transcriptome = "ensembl";
    String cisOnly="all";
    LinkGenerator lg = new LinkGenerator(session);
    double pValueCutoff = 0.01;
    int rnaDatasetID = 0;
    int arrayTypeID = 0;
    int min = 0;
    int max = 0;
    if (request.getParameter("species") != null) {
        myOrganism = request.getParameter("species").trim();
        if (myOrganism.equals("Rn")) {
            panel = "BNLX/SHRH";
            fullOrg = "Rattus_norvegicus";
        } else {
            panel = "ILS/ISS";
            fullOrg = "Mus_musculus";
        }
    }
    String[] tissuesList1 = new String[1];
    String[] tissuesList2 = new String[1];
    if (myOrganism.equals("Rn")) {
        if(dataSource.equals("seq")){
            tissuesList1 = new String[2];
            tissuesList2 = new String[2];
            tissuesList1[0] = "Brain";
            tissuesList2[0] = "Whole Brain";
            tissuesList1[1] = "Liver";
            tissuesList2[1] = "Liver";
        }else {
            tissuesList1 = new String[4];
            tissuesList2 = new String[4];
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
    if (request.getParameter("pValueCutoff") != null) {
        pValueCutoff = Double.parseDouble(request.getParameter("pValueCutoff"));
    }
    if (request.getParameter("rnaDatasetID") != null) {
        rnaDatasetID = Integer.parseInt(request.getParameter("rnaDatasetID"));
    }
    if (request.getParameter("arrayTypeID") != null) {
        arrayTypeID = Integer.parseInt(request.getParameter("arrayTypeID"));
    }
    if (request.getParameter("chromosome") != null) {
        chromosome = request.getParameter("chromosome");
    }

    if (request.getParameter("minCoord") != null) {
        min = Integer.parseInt(request.getParameter("minCoord"));
    }
    if (request.getParameter("maxCoord") != null) {
        max = Integer.parseInt(request.getParameter("maxCoord"));
    }
    if (request.getParameter("type") != null) {
        type = request.getParameter("type");
    }
    if (request.getParameter("folderName") != null) {
        folderName = request.getParameter("folderName");
    }
    if (request.getParameter("genomeVer") != null) {
        genomeVer = FilterInput.getFilteredInputGenomeVer(request.getParameter("genomeVer"));
    }
    if (request.getParameter("dataSource") != null) {
        dataSource = request.getParameter("dataSource");
    }
    if (request.getParameter("transcriptome") != null) {
        transcriptome = request.getParameter("transcriptome");
    }
    if (request.getParameter("cisOnly") != null) {
        cisOnly = request.getParameter("cisOnly");
    }

    String[] selectedChromosomes = null;
    String[] selectedTissues = null;
    String[] selectedLevels = null;
    String chromosomeString = null;
    String tissueString = null;
    Boolean selectedChromosomeError = null;
    Boolean selectedTissueError = null;
    String levelString = "core;extended;full";





    //
    // Create chromosomeNameArray and chromosomeSelectedArray
    // These depend on the species
    //

    int numberOfChromosomes;
    String[] chromosomeNameArray = new String[25];

    String[] chromosomeDisplayArray = new String[25];
    String doubleQuote = "\"";
    String isSelectedText = " selected=" + doubleQuote + "true" + doubleQuote;
    String isNotSelectedText = " ";
    String chromosomeSelected = isNotSelectedText;
    String speciesGeneChromosome = myOrganism.toLowerCase() + chromosome.replace("chr", "");

    if (myOrganism.equals("Mm")) {
        numberOfChromosomes = 20;
        for (int i = 0; i < numberOfChromosomes - 1; i++) {
            chromosomeNameArray[i] = "mm" + Integer.toString(i + 1);
            chromosomeDisplayArray[i] = "Chr " + Integer.toString(i + 1);
        }
        chromosomeNameArray[numberOfChromosomes - 1] = "mmX";
        chromosomeDisplayArray[numberOfChromosomes - 1] = "Chr X";
    } else {
        numberOfChromosomes = 21;
        // assume if not mouse that it's rat
        for (int i = 0; i < numberOfChromosomes - 1; i++) {
            chromosomeNameArray[i] = "rn" + Integer.toString(i + 1);
            chromosomeDisplayArray[i] = "Chr " + Integer.toString(i + 1);
        }
        chromosomeNameArray[numberOfChromosomes - 1] = "rnX";
        chromosomeDisplayArray[numberOfChromosomes - 1] = "Chr X";
    }
    //
    // Create tissueNameArray and tissueSelectedArray
    // These are only defined for Rat
    //
    int numberOfTissues;
    String[] tissueNameArray = new String[4];
    String tissueSelected = isNotSelectedText;
    if (myOrganism.equals("Mm")) {
        tissueNameArray = new String[1];
        numberOfTissues = 1;
        tissueNameArray[0] = "Brain";
    } else {
        if(dataSource.equals("seq")){
            tissueNameArray = new String[2];
            numberOfTissues = 2;
            // assume if not mouse that it's rat
            tissueNameArray[0] = "Brain";
            tissueNameArray[1] = "Liver";
        }else {
            numberOfTissues = 4;
            // assume if not mouse that it's rat
            tissueNameArray[0] = "Brain";
            tissueNameArray[1] = "Heart";
            tissueNameArray[2] = "Liver";
            tissueNameArray[3] = "BAT";
        }
    }

    // Get information about which tissues to view -- easier for mouse

    if (myOrganism.equals("Mm")) {
        tissueString = "Brain;";
        selectedTissues = new String[1];
        selectedTissues[0] = "Brain";
    } else {
        // we assume if not mouse that it's rat
        if (request.getParameter("tissues") != null && !request.getParameter("tissues").equals("")) {
            String tmpSelectedTissues = request.getParameter("tissues");
            selectedTissues = tmpSelectedTissues.split(";");
            log.debug("Getting selected tissues:" + selectedTissues);
            tissueString = "";
            selectedTissueError = true;
            for (int i = 0; i < selectedTissues.length; i++) {
                selectedTissueError = false;
                tissueString = tissueString + selectedTissues[i] + ";";
            }
            log.debug(" Selected Tissues: " + tissueString);
            //log.debug(" selectedTissueError: " + selectedTissueError);
            // We insist that the tissue string be at least one long
        }
			/*else if(request.getParameter("chromosomeSelectionAllowed")!=null){
				// We previously allowed chromosome/tissue selection, but now we got no tissues back
				// Therefore we did not include any tissues
				selectedTissueError=true;
			}*/
        else {
            //log.debug("could not get selected tissues");
            //log.debug("and we did not previously allow chromosome selection");
            //log.debug("therefore include all tissues");
            // we are not allowing chromosome/tissue selection.  Include all tissues.
            selectedTissues = new String[numberOfTissues];
            selectedTissueError = false;
            tissueString = "";
            for (int i = 0; i < numberOfTissues; i++) {
                tissueString = tissueString + tissueNameArray[i] + ";";
                selectedTissues[i] = tissueNameArray[i];
            }
        }
    }


    // Get information about which chromosomes to view

    if (request.getParameter("chromosomes") != null && !request.getParameter("chromosomes").equals("")) {
        String tmpSelectedChromosomes = request.getParameter("chromosomes");
        selectedChromosomes = tmpSelectedChromosomes.split(";");
        //log.debug("selected chr count:"+selectedChromosomes.length+":"+selectedChromosomes[0].toString());
        chromosomeString = "";
        selectedChromosomeError = true;
        for (int i = 0; i < selectedChromosomes.length; i++) {
            chromosomeString = chromosomeString + selectedChromosomes[i] + ";";
            if (selectedChromosomes[i].equals(speciesGeneChromosome)) {
                selectedChromosomeError = false;
            }
        }
        log.debug(" Selected Chromosomes: " + chromosomeString);
        //log.debug(" selectedChromosomeError: " + selectedChromosomeError);
        // We insist that the chromosome string include speciesGeneChromosome
    } else if (request.getParameter("chromosomeSelectionAllowed") != null) {
        // We previously allowed chromosome selection, but now we got no chromosomes back
        // Therefore we did not include the desired chromosome
        selectedChromosomeError = true;
    } else {
        //log.debug("could not get selected chromosomes");
        //log.debug("and we did not previously allow chromosome selection");
        //log.debug("therefore include all chromosomes");
        // we are not allowing chromosome selection.  Include all chromosomes.
        selectedChromosomes = new String[numberOfChromosomes];
        selectedChromosomeError = false;
        chromosomeString = "";
        for (int i = 0; i < numberOfChromosomes; i++) {
            chromosomeString = chromosomeString + chromosomeNameArray[i] + ";";
            selectedChromosomes[i] = chromosomeNameArray[i];
        }
    }
    java.util.Date time = new java.util.Date();
    if(cisOnly.equals("cis")){
        String cisChr=chromosome;
        if(cisChr.startsWith("chr")){
            cisChr=cisChr.substring(3);
        }
        cisChr="rn"+cisChr;
        chromosomeString=cisChr+";";
        selectedChromosomes=new String[1];
        selectedChromosomes[0]=cisChr;
    }

    //String tmpOutput=gdt.getImageRegionData(chromosome,min,max,panel,myOrganism,rnaDatasetID,arrayTypeID,0.01,false);
    //int startInd=tmpOutput.lastIndexOf("/",tmpOutput.length()-2);
    //folderName=tmpOutput.substring(startInd+1,tmpOutput.length()-1);

	/*if(min<max){
			if(min<1){
				min=1;
			}
			/fullGeneList =gdt.getRegionData(chromosome,min,max,panel,myOrganism,rnaDatasetID,arrayTypeID,forwardPValueCutoff);
			String tmpURL =gdt.getGenURL();//(String)session.getAttribute("genURL");
			int second=tmpURL.lastIndexOf("/",tmpURL.length()-2);
			folderName=tmpURL.substring(second+1,tmpURL.length()-1);
					//String tmpGeneSymbol=gdt.getGeneSymbol();//(String)session.getAttribute("geneSymbol");
					//String tmpUcscURL =gdt.getUCSCURL();//(String)session.getAttribute("ucscURL");
					//String tmpUcscURLFiltered =gdt.getUCSCURLFiltered();//(String)session.getAttribute("ucscURLFiltered");
					/*if(tmpURL!=null){
						genURL.add(tmpURL);
						if(tmpGeneSymbol==null){
							geneSymbol.add("");
						}else{
							geneSymbol.add(tmpGeneSymbol);
						}
						if(tmpUcscURL==null){
							ucscURL.add("");
						}else{
							ucscURL.add(tmpUcscURL);
						}*/
						/*if(tmpUcscURLFiltered==null){
							ucscURLFiltered.add("");
						}else{
							ucscURLFiltered.add(tmpUcscURLFiltered);
						}*/
    //}
    //}

    time = new java.util.Date();

%>

<style>
    #circosDiv {
        display: inline-block;
        vertical-align: text-top;
        margin-left: 5%;
        width: 38%;
    }

    #qtlTableDiv {
        display: inline-block;
        vertical-align: text-top;
        margin-right: 5%;
        width: 51%;
    }
    @media screen and (max-width: 1600px) {
        #circosDiv {
            display: inline-block;
            vertical-align: text-top;
            margin-left: 3%;
            margin-right: 3%;
            width: 94%;
        }

        #qtlTableDiv {
            display: inline-block;
            vertical-align: text-top;
            margin-left: 3%;
            margin-right: 3%;
            width: 94%;
        }
    }

</style>

<div id="eQTLListFromRegion" style="width:100%;">

    <div id="filterdivEQTL" class="filterdivEQTL"
         style="background-color:#F8F8F8;display:none;position:absolute;z-index:999; border:solid;border-color:#000000;border-width:1px;width:75%;">
        <span style="color:#000000;">Filter Settings</span>
        <span class="closeBtn" id="close_filterdivEQTL" style="position:relative;top:1px;left:215px;"><img
                src="<%=imagesDir%>icons/close.png"></span>
        <table style="width:100%;">
            <tbody>
            <TR>
                <TD  style="text-align:center;">
                    Data Source:
                    <select name="dataSource" id="dataSource">
                        <!--<option value="array" <%if(dataSource.equals("array")){%>selected<%}%>>Microarray</option>-->
                        <option value="seq" <%if(dataSource.equals("seq")){%>selected<%}%>>RNA-Seq</option>
                    </select>
                    <span class="eQTLListToolTip"
                          title="Select the data source used to calculate QTLs.  Array - Affy Exon arrays, RNA-Seq is ribosome depleted totalRNA and reconstructed transcriptome."><img
                            src="<%=imagesDir%>icons/info.gif"></span>
                    <BR>
                    Transcriptome Data:
                    <select name="transcriptome" id="transriptome">
                        <option value="ensembl" <%if(transcriptome.equals("ensembl")){%>selected<%}%>>Ensembl</option>
                        <option value="reconst" <%if(transcriptome.equals("reconst")){%>selected<%}%>>Reconstruction</option>
                    </select>
                    <span class="eQTLListToolTip"
                          title="Select the transriptome used for quantification."><img
                            src="<%=imagesDir%>icons/info.gif"></span>
                </TD>
                <TD style="text-align:center;">
                    eQTL P-Value Cut-off:
                    <select name="pvalueCutoffSelect2" id="pvalueCutoffSelect2">
                        <option value="0.000001" <%if(pValueCutoff==  0.000001){%>selected<%}%>>0.000001</option>
                        <option value="0.0000001" <%if(pValueCutoff== 0.0000001){%>selected<%}%>>0.0000001</option>
                        <option value="0.00000001" <%if(pValueCutoff== 0.00000001){%>selected<%}%>>0.00000001</option>
                        <option value="0.000000001" <%if(pValueCutoff==0.000000001){%>selected<%}%>>0.000000001</option>
                    </select>
                    <span class="eQTLListToolTip"
                          title="Remove Genes from both the image(Circos Plot) and table which don't have P-value less than the selected cut-off in one of the included tissues."><img
                            src="<%=imagesDir%>icons/info.gif"></span>
                    <BR>
                    Genome Wide eQTLs:
                    <select name="cisTrans" id="cisTrans">
                        <option value="cis" <%if(cisOnly.equals("cis")){%>selected<%}%>>Cis eQTLs Only</option>
                        <option value="all" <%if(cisOnly.equals("all")){%>selected<%}%>>Genome Wide</option>
                    </select>
                    <span class="eQTLListToolTip"
                          title="Display cis eQTLs only or genome wide eQTLs."><img
                            src="<%=imagesDir%>icons/info.gif"></span>
                </TD>
            </TR>
            <TR>
                <%if (myOrganism.equals("Rn")) {%>
                <TD style="text-align:left; width:50%;">
                    <table style="width:100%;">
                        <tbody>
                        <tr>
                            <td style="text-align:center;">
                                <strong>Tissues: Include at least one tissue.</strong>
                                <span class="eQTLListToolTip"
                                      title="Removes excluded tissues from the image(Circos Plot), does not remove the column for the tissue in the table(see View Columns for that option), but will remove rows where only the excluded tissue met the p-value cut-off."><img
                                        src="<%=imagesDir%>icons/info.gif"></span>
                            </td>
                        </tr>
                        <TR>
                            <td style="text-align:center;">
                                <strong>Excluded</strong><%=tenSpaces%><%=twentyFiveSpaces%><%=twentySpaces%><strong>Included</strong>
                            </td>
                        </TR>
                        <tr>
                            <td>

                                <select name="tissuesMS" id="tissuesMS" class="multiselect" size="6" multiple="true">

                                    <%

                                        for (int i = 0; i < tissueNameArray.length; i++) {
                                            tissueSelected = isNotSelectedText;
                                            if (selectedTissues != null) {
                                                for (int j = 0; j < selectedTissues.length; j++) {
                                                    if (selectedTissues[j].equals(tissueNameArray[i])) {
                                                        tissueSelected = isSelectedText;
                                                    }
                                                }
                                            }


                                    %>

                                    <option value="<%=tissueNameArray[i]%>"<%=tissueSelected%>><%=tissuesList1[i]%>
                                    </option>

                                    <%
                                        } // end of for loop
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
                                <span class="eQTLListToolTip"
                                      title="Remove/Adds Chromosomes to the image(Circos Plot) and will remove or add Genes in the table so only genes located on included chromosomes are displayed."><img
                                        src="<%=imagesDir%>icons/info.gif"></span>
                            </td>
                        </tr>
                        <tr>
                            <td style="text-align:center;">
                                <strong>Excluded</strong><%=tenSpaces%><%=twentyFiveSpaces%><%=twentySpaces%><strong>Included</strong>
                            </td>
                        </tr>
                        <tr>
                            <td>

                                <select name="chromosomesMS" id="chromosomesMS" class="multiselect" size="6"
                                        multiple="true">

                                    <%
                                        log.debug("MADE IT TO: chromosomesMS");
                                        String tmpChromosome = chromosome;
                                        if (tmpChromosome.toLowerCase().startsWith("chr")) {
                                            tmpChromosome.substring(3);
                                        }
                                        for (int i = 0; i < numberOfChromosomes; i++) {
                                            chromosomeSelected = isNotSelectedText;

                                            if (chromosomeDisplayArray[i].substring(4).equals(tmpChromosome)) {
                                                chromosomeSelected = isSelectedText;
                                            } else {
                                                if (selectedChromosomes != null) {
                                                    for (int j = 0; j < selectedChromosomes.length; j++) {
                                                        //log.debug(" selectedChromosomes element "+selectedChromosomes[j]+" "+chromosomeNameArray[i]);
                                                        if (selectedChromosomes[j].equals(chromosomeNameArray[i])) {
                                                            chromosomeSelected = isSelectedText;
                                                        }
                                                    }
                                                }
                                            }


                                    %>

                                    <option value="<%=chromosomeNameArray[i]%>"<%=chromosomeSelected%>><%=chromosomeDisplayArray[i]%>
                                    </option>

                                    <%
                                        } // end of for loop
                                    %>

                                </select>

                            </td>
                        </tr>
                        </tbody>
                    </table>
                </TD>
            </TR>

            <TR>
                <TD colspan="2" style="text-align:center;">
                    <input type="button" name="filterBTN" id="filterBTN" value="Run Filter" onClick="runFilter()">
                </TD>
            </TR>
            </tbody>
        </table>
    </div>


    <%  session.removeAttribute("getTransControllingEQTL");
        session.removeAttribute("getTransControllingEQTLCircos");
        log.debug("before eQTL table constr");
        log.debug("loc:" + chromosome + ":" + min + "-" + max + "::" + folderName);
        log.debug("get EQTLs");
        java.util.Date tmpStart = new java.util.Date();
        HashMap<String, TranscriptomeQTL> transOutQTLs = gdt.getRegionEQTLs(min, max, chromosome, arrayTypeID, rnaDatasetID, pValueCutoff, myOrganism, genomeVer, tissueString, chromosomeString,transcriptome,cisOnly);//this region controls what genes
        String errorMessage=gdt.getRegionEQTLMessage();
        time = new java.util.Date();
        log.debug("Setup after getcontrolling eqtls:\n" + (time.getTime() - tmpStart.getTime()));
        tmpStart = new java.util.Date();

        log.debug("*********\n:"+session.getAttribute("getTransControllingEQTL")+"*::");
        if (errorMessage.equals("") && (session.getAttribute("getTransControllingEQTL") == null || ((String)session.getAttribute("getTransControllingEQTL")).equals("") ) ) {
            //log.debug("after check session var");
            if (transOutQTLs != null && transOutQTLs.size() > 0) {
                //log.debug("after check transOutQTLs");

                String shortRegionCentricPath;
                String cutoffTimesTen;
                if (pValueCutoff == 0.1) {
                    cutoffTimesTen = "10";
                } else if (pValueCutoff == 0.01) {
                    cutoffTimesTen = "20";
                } else if (pValueCutoff == 0.001) {
                    cutoffTimesTen = "30";
                } else if (pValueCutoff == 0.0001) {
                    cutoffTimesTen = "40";
                } else if (pValueCutoff == 0.00001) {
                    cutoffTimesTen = "50";
                } else {
                    double tmpD = -1 * Math.log10(pValueCutoff) * 10;
                    int tmp = (int) tmpD;
                    cutoffTimesTen = Integer.toString(tmp);
                }


                String tmpFolder = chromosome+"/"+ gdt.getFolder(min, max, chromosome, myOrganism, genomeVer);
                log.debug("tmpFolder:"+tmpFolder);
                String regionCentricPath = applicationRoot + contextRoot + "tmpData/browserCache/" + genomeVer + "/regionData/" + tmpFolder;
                shortRegionCentricPath = regionCentricPath.substring(regionCentricPath.indexOf("/tmpData/"));

                String iframeURL = shortRegionCentricPath + "/circos" + cutoffTimesTen + "/svg/circos_new.svg";
                String svgPdfFile = shortRegionCentricPath + "/circos" + cutoffTimesTen + "/svg/circos.png";
                //log.debug("MADE IT TO:path");
                log.debug("iframe:\n"+iframeURL);
                int tissueColumnCount=1;
                if(dataSource.equals("array")){
                    tissueColumnCount=2;
                }
    %>


    <div id="circosDiv">
        <div class="regionSubHeader" style="font-size:18px; font-weight:bold; text-align:center; width:100%;">
            Genes with an eQTL overlaping this region(HRDP v5 RNA-Seq <%=transcriptome%> Data(<%if(cisOnly.equals("cis")){%>Cis eQTLs<%}else{%>Cis and Trans eQTLS<%}%>))
            <div class="inpageHelp" style="display:inline-block;"><img id="HelpRevCircos" class="helpImage"
                                                                       src="../web/images/icons/help.png"/></div>
            <!--<span style="font-size:12px; font-weight:normal;">
            Adjust Vertical Viewable Size:
            <select name="circosSizeSelect" id="circosSizeSelect">
                    <option value="200" >Smallest</option>
                    <option value="475" >Half</option>
                    <option value="950" selected="selected">Full</option>
                    <option value="1000" >Maximized</option>
                </select>
            </span>
            <span class="eQTLListToolTip" title="To control the viewable area of the Circos Plot below simply select your prefered size."><img src="<%=imagesDir%>icons/info.gif"></span>-->

        </div>

                <%  //log.debug("getTranscontrollingEQTLCircos\n"+session.getAttribute("getTransControllingEQTLCircos"));
                    if (session.getAttribute("getTransControllingEQTLCircos") == null  ) {%>
                        <div id="circosPlot" style="text-align:center;">
                            <div style="display:inline-block;text-align:center; width:100%;">
                                <!--<span id="circosMinMax" style="cursor:pointer;"><img src="web/images/icons/circos_min.jpg"></span>-->
                                <a href="<%=svgPdfFile%>" target="_blank">
                                    <img src="/web/images/icons/download_g.png" title:"Download Circos Image">
                                </a>
                                Inside of border below, the mouse wheel zooms. Outside of the border, the mouse wheel scrolls.
                                <span id="filterBtn1" class="filter button">Filter eQTLs</span>
                            </div>


                            <div id="iframe_parent" align="center" style="width:100%; scroll-behavior: unset;overscroll-behavior: none;">
                                <iframe id="circosIFrame" src="<%=iframeURL%>" height="950px" width="98%" position="absolute" scrolling="no"
                                        style="border-style:solid; border-color:rgb(139,137,137); border-radius:15px; -moz-border-radius: 15px; border-width:1px">
                                </iframe>
                            </div>
                            <a href="http://genome.cshlp.org/content/early/2009/06/15/gr.092759.109.abstract" target="_blank"
                               style="text-decoration: none">Circos: an Information Aesthetic for Comparative Genomics.</a>
                        </div><!-- end CircosPlot -->
                    <%} else {%>
                        <div id="circosPlot" style="text-align:center;">
                            <strong><%=session.getAttribute("getTransControllingEQTLCircos")%>
                            </strong><BR/><BR/><BR/>
                        </div><!-- end CircosPlot -->
                    <%}
                    //log.debug("After iFrame");%>
    </div>
    <div id="qtlTableDiv" style="display:inline-block;">
        <div class="regionSubHeader" style="font-size:18px; font-weight:bold; text-align:center; width:100%;">
            List of Genes
            <span class="eQTLListToolTip" title=""><img src="<%=imagesDir%>icons/info.gif"></span>
        </div>
        <%
            //StringBuilder idList = new StringBuilder();
            StringBuilder idc=new StringBuilder();
            HashMap<String,String> probeToGS=new HashMap<String,String>();
            int idListCount = 0;
            //log.debug("before outer");
            //Set<String> qtlSet
            String[] list= transOutQTLs.keySet().toArray(new String[transOutQTLs.size()]);
            //String[] list= (String[]) qtlSet.toArray();
            for (int i = 0; i < list.length; i++) {
                TranscriptomeQTL tQ = transOutQTLs.get(list[i]);
                String tcChr = myOrganism.toLowerCase() + tQ.getChromosome();
                //log.debug("after chr outer");
                boolean include = false;
                boolean tissueInclude = false;
                for (int z = 0; z < selectedChromosomes.length && !include; z++) {
                    if (selectedChromosomes[z].equals(tcChr)) {
                        include = true;
                    }
                }
                //log.debug("after chr loop");
                for (int j = 0; j < tissuesList2.length && include && !tissueInclude; j++) {
                    //log.debug("jTis:"+tissueNameArray[j]);
                    boolean isTissueSelected = false;
                    for (int k = 0; k < selectedTissues.length; k++) {
                        //log.debug("ktis:"+selectedTissues[k]);
                        if (selectedTissues[k].equals(tissueNameArray[j])) {
                            isTissueSelected = true;
                        }
                    }
                    if (isTissueSelected) {
                        ArrayList<TrxQTL> regionQTL = tQ.getQTLList(tissuesList2[j],transcriptome);
                        if (regionQTL != null) {
                            TrxQTL regQTL = regionQTL.get(0);
                            if (regQTL.getPValue() <= pValueCutoff) {
                                tissueInclude = true;
                            }
                        }
                    }
                }
                //log.debug("after tissue loop");
                if (include && tissueInclude) {
                    //idList.append(","+tQ.getProbeID());
                    idc.append(",'"+tQ.getProbeID()+"'");
                    idListCount++;
                }
            }
            IDecoderClient myIDecoderClient = new IDecoderClient();
            myIDecoderClient.setNum_iterations(0);
            String[] targets = new String[]{"Gene Symbol",  "Ensembl ID", "PhenoGen ID"};
            log.debug("test:\n"+idc.substring(1));
            Set<Identifier> ids=myIDecoderClient.getIdentifiersByInputIDAndTarget(idc.substring(1),myOrganism,targets,pool);
            if (ids.size() > 0) {
                Iterator itr = ids.iterator();
                while (((Iterator) itr).hasNext()) {
                    Identifier thisIdentifier = (Identifier) itr.next();
                    HashMap<String, Set<Identifier>> targetHM = thisIdentifier.getTargetHashMap();
                    if (targetHM.containsKey("Gene Symbol")) {
                        Set<Identifier> gs = targetHM.get("Gene Symbol");
                        Iterator gsItr = gs.iterator();
                        if(gsItr.hasNext()) {
                            Identifier gsID = (Identifier) gsItr.next();
                            probeToGS.put(thisIdentifier.getIdentifier(),gsID.getIdentifier());
                        }
                    }
                }
            }
            //log.debug("after outer for loop");
        %>
        <div style=" float:right; ">
            <%
                time = new java.util.Date();
                //log.debug("before setting up tables:" + (time.getTime() - startDate.getTime()));
            %>
            <BR/>
            <span id="viewBtn1" class="view button">Edit Columns</span>
            <span id="filterBtn2" class="filter button">Filter Rows</span>
        </div>
        <BR/>
        <div class="downloadBtns" style="text-align: left;margin-bottom: 10px;">Export As:</div>
        <TABLE name="items" id="tblFrom" class="list_base" cellpadding="0" cellspacing="0" border="0" width="100%">
            <THEAD>
            <tr>
                <th colspan="3" class="topLine noSort noBox"></th>
                <%if(dataSource.equals("array")){%>
                <th colspan="<%=tissuesList2.length*tissueColumnCount+2%>" class="center noSort topLine"
                    title="Dataset is available by going to Microarray Analysis Tools -> Analyze Precompiled Dataset or Downloads.">
                    Affy Exon 1.0 ST PhenoGen Public Dataset(
                    <%if (myOrganism.equals("Mm")) {%>
                    Public ILSXISS RI Mice
                    <%} else {%>
                    Public HXB/BXH RI Rats (Tissue, Exon Arrays)
                    <%}%>
                    )
                    <div class="inpageHelp" style="display:inline-block;"><img id="HelpeQTLAffy" class="helpImage"
                                                                               src="../web/images/icons/help.png"/>
                    </div>
                </th>
                <%}else{%>
                <th colspan="<%=tissuesList2.length*tissueColumnCount+4%>" class="center noSort topLine"
                    title="">
                    HRDP v5 Ribosome Depleted TotalRNA Sequencing Dataset
                    <div class="inpageHelp" style="display:inline-block;"><img id="HelpeQTLRNA" class="helpImage"
                                                                               src="../web/images/icons/help.png"/>
                    </div>
                </th>
                <%}%>
            </tr>
            <tr>
                <th colspan="3" class="topLine noSort noBox"></th>
                <th colspan="2" class="leftBorder noSort noBox"></th>
                <%for (int i = 0; i < tissuesList2.length; i++) {%>
                <th colspan="<%=tissueColumnCount%>" class="center noSort topLine">Tissue:<%=tissuesList2[i]%>
                </th>
                <%}%>
            </tr>
            <TR class="col_title">
                <TH>Gene Symbol<BR/>(click for detailed transcription view) <span class="eQTLListToolTip"
                                                                                  title="The Gene Symbol from Ensembl if available.  Click to view detailed information for that gene."><img
                        src="<%=imagesDir%>icons/info.gif"></span></TH>
                <TH>Gene ID</TH>

                <TH>Description <span class="eQTLListToolTip" title="The description from Ensembl if available."><img
                        src="<%=imagesDir%>icons/info.gif"></span></TH>

                <TH>Physical Location <span class="eQTLListToolTip"
                                            title="This is the location of the gene in the genome.  It includes the chromosome and the starting basepair and end base pair for the gene."><img
                        src="<%=imagesDir%>icons/info.gif"></span></TH>
                <TH>View Genome-Wide Associations <span class="eQTLListToolTip"
                                                        title="Genome Wide Associations- Shows all the locations with a P-value below the cutoff selected. Circos is used to create a plot of each region in each tissue associated with expression of the gene selected."><img
                        src="<%=imagesDir%>icons/info.gif"></span></TH>
                <%for (int i = 0; i < tissuesList2.length; i++) {%>
                <TH title="Highlighted indicates a value less than or equal to the cutoff.">P-Value from region <span
                        class="eQTLListToolTip"
                        title="The P-value associated with this region.  Note that this region may only partially overlap with the region this P-value refers to or may be much larger."><img
                        src="<%=imagesDir%>icons/info.gif"></span></TH>

                <%}%>

            </TR>
            </thead>
            <tbody style="text-align:center;">
            <%
               // log.debug("EQTL TABLE\n\n");
                DecimalFormat df4 = new DecimalFormat("0.##E0");
                for (int i = 0; i < transOutQTLs.size(); i++) {
                    TranscriptomeQTL tQ = transOutQTLs.get(list[i]);
                    if(tQ!=null){
                        //log.debug("got tQ"+tQ);
                        String tcChr = myOrganism.toLowerCase() + tQ.getChromosome();
                        boolean include = false;
                        boolean tissueInclude = false;
                        //log.debug("loop over chr");
                        for (int z = 0; z < selectedChromosomes.length && !include; z++) {
                            if (selectedChromosomes[z].equals(tcChr)) {
                                include = true;
                            }
                        }
                        //log.debug("first loop");
                        for (int j = 0; j < tissuesList2.length && include && !tissueInclude; j++) {
                            boolean isTissueSelected = false;
                            for (int k = 0; k < selectedTissues.length; k++) {
                                if (selectedTissues[k].equals(tissueNameArray[j])) {
                                    isTissueSelected = true;
                                }
                            }
                            if (isTissueSelected) {
                                ArrayList<TrxQTL> regionQTL = tQ.getQTLList(tissuesList2[j],transcriptome);
                                if (regionQTL != null && regionQTL.size()>0) {
                                    TrxQTL regQTL = regionQTL.get(0);
                                    if (regQTL.getPValue() <= pValueCutoff) {
                                        tissueInclude = true;
                                    }
                                }
                            }
                        }
                        //log.debug("second loop");
                        if (include && tissueInclude) {
                            String description = ""; //tQ.getDescription();
                            String shortDesc = description;
                            String remain = "";
                            if (description.indexOf("[") > 0) {
                                shortDesc = description.substring(0, description.indexOf("["));
                                if (description.indexOf("]") > 0) {
                                    remain = description.substring(description.indexOf("[") + 1, description.indexOf("]"));
                                } else {
                                    remain = description.substring(description.indexOf("[") + 1);
                                }

                            }

                            //log.debug("data row");
                            if((transcriptome.equals("ensembl")&& tQ.getProbeID().startsWith("ENS")) || (transcriptome.equals("reconst")&& tQ.getProbeID().startsWith("PRN")) ){
            %>

                <TR>
                    <TD>
                        <%if (!tQ.getProbeID().equals("")) {%>
                        <a href="<%=lg.getGeneLink(tQ.getEnsemblID(),myOrganism,true,true,false)%>" target="_blank"
                           title="View Detailed Transcription Information for gene.">

                            <%if (tQ.getGeneSymbol().equals("")) {
                                if(probeToGS.containsKey(tQ.getProbeID())){
                            %>
                                    <%=probeToGS.get(tQ.getProbeID())%>
                                <%}else{%>
                                    No Gene Symbol
                                <%}
                            } else {%>
                            <%=tQ.getGeneSymbol()%>
                            <%}%>
                        </a>
                        <%} else {%>
                        No Gene Symbol
                        <%}%>
                    </TD>

                    <TD>
                        <%if (!tQ.getEnsemblID().equals("")) {%>
                        <a href="<%=LinkGenerator.getEnsemblLinkEnsemblID(tQ.getEnsemblID(),fullOrg)%>" target="_blank"
                           title="View Ensembl Gene Details"><%=tQ.getEnsemblID()%>
                        </a><BR/>
                        <span style="font-size:10px;">
                                    <%
                                        String tmpGS = tQ.getEnsemblID();
                                        String shortOrg = "Mouse";
                                        String allenID = "";
                                        if (myOrganism.equals("Rn")) {
                                            shortOrg = "Rat";
                                        }
                                        if (tQ.getGeneSymbol() != null && !tQ.getGeneSymbol().equals("")) {
                                            tmpGS = tQ.getGeneSymbol();
                                            allenID = tQ.getGeneSymbol();
                                        }
                                        if (allenID.equals("") && !shortDesc.equals("")) {
                                            allenID = shortDesc;
                                        }
                                    %>
                                        All Organisms:<a href="<%=LinkGenerator.getNCBILink(tmpGS)%>"
                                                         target="_blank">NCBI</a> |
                                        <a href="<%=LinkGenerator.getUniProtLinkGene(tmpGS)%>"
                                           target="_blank">UniProt</a> <BR/>
                                       <%=shortOrg%>: <a href="<%=LinkGenerator.getNCBILink(tmpGS,myOrganism)%>"
                                                         target="_blank">NCBI</a> | <a
                                href="<%=LinkGenerator.getUniProtLinkGene(tmpGS,myOrganism)%>" target="_blank">UniProt</a> |
                                        <%if (myOrganism.equals("Mm")) {%>
                                            <a href="<%=LinkGenerator.getMGILink(tmpGS)%>" target="_blank">MGI</a>
                                            <%if (!allenID.equals("")) {%>
                                                | <a href="<%=LinkGenerator.getBrainAtlasLink(allenID)%>" target="_blank">Allen Brain Atlas</a>
                                            <%}%>
                                        <%} else {%>
                                            <a href="<%=LinkGenerator.getRGDLink(tmpGS,myOrganism)%>"
                                               target="_blank">RGD</a>
                                        <%}%>
                                     </span>
                        <%}else{%>
                        <%=tQ.getPhenogenID()%>
                        <%}%>
                    </TD>


                    <TD title="<%=remain%>"><%=shortDesc%>
                    </TD>



                    <TD>chr<%=tQ.getChromosome() + ":" + dfC.format(tQ.getStart()) + "-" + dfC.format(tQ.getEnd())%>
                    </TD>
                    <TD>
                        <a href="web/GeneCentric/setupLocusSpecificEQTL.jsp?geneSym=<%=tQ.getGeneSymbol()%>&ensID=<%=tQ.getEnsemblID()%>&chr=<%=tQ.getChromosome()%>&start=<%=tQ.getStart()%>&stop=<%=tQ.getEnd()%>&curDir=<%=folderName%>"
                           target="_blank" title="View the circos plot for transcript cluster eQTLs">View Location Plot</a>
                    </TD>
                    <%
                        //String[] curTissues=tc.getTissueList();
                        for (int j = 0; j < tissuesList2.length; j++) {
                            //log.debug("TABLE2:"+tissuesList2[j]);
                            ArrayList<TrxQTL> regionQTL = tQ.getQTLList(tissuesList2[j],transcriptome);
                            TrxQTL regEQTL = null;
                            if (regionQTL != null && regionQTL.size() > 0) {
                                regEQTL = regionQTL.get(0);
                            }
                        %>

                        <%
                            if (regEQTL == null) {
                                if (myOrganism.equals("Mm")) {
                        %>
                        <TD class="leftBorder">-</TD>
                                <%} else {%>
                        <TD class="leftBorder">-</TD>
                                <%}%>
                            <%} else{%>
                        <TD class="leftBorder"
                                <%if (regEQTL.getPValue() <= pValueCutoff) {%>
                            style="background-color:#6e99bc; color:#FFFFFF;"
                                <%}%>
                        >
                            <%=df4.format(regEQTL.getPValue())%>
                            <%}%>
                            </TD>
                            <%if(dataSource.equals("array")){%>
                            <TD title="Click on View Location Plot to see all locations below the cutoff.">

                            </TD>
                            <%}
                        }%>

                </TR>
            <%          }
                        }
                    } //end if
                }//end for tcOutQTLs
                time = new java.util.Date();
                log.debug("Total time:" + (time.getTime() - startDate.getTime()));
            %>

            </tbody>
        </table>
        <div class="downloadBtns" style="text-align: left;margin-bottom: 10px;">Export As:</div>
    </div>
    <BR/><BR/><BR/>

    <script type="text/javascript">
        var buttonCommon = {
            exportOptions: {
                format: {
                    body: function ( data, row, column, node ) {
                        data=data.replace(/(<.*?>)*/g,'');
                        if(data.indexOf("ENS")===0 && data.indexOf("All Organisms:")>0){
                            data = data.replace(/\s*/g, '');
                            data=data.substring(0,data.indexOf("AllOrganisms:"));
                        }
                        if(column===5||column===6){
                            data='\u200C' +data;

                        }
                        return data;
                    }
                },
                columns:[0,1,3,5,6]
            }
        };
        var tblFrom = $('#tblFrom').DataTable({
            bAutoWidth: false,
            bPaginate: false,
            bProcessing: true,
            sScrollX: "100%",
            sScrollY: "100%",
            bDeferRender: false,
            sDom: '<"leftSearch"fr><"rightSearch"i><t>',
            buttons: [
                $.extend( true, {}, buttonCommon, {
                    extend: 'copyHtml5'
                } ),
                $.extend( true, {}, buttonCommon, {
                    extend: 'csvHtml5'
                } ),
                $.extend( true, {}, buttonCommon, {
                    extend: 'excelHtml5'
                } )
            ]
        });
        $('#geneIDFCBX').click(function () {
            if (typeof tblFrom != 'undefined') {
                displayColumns(tblFrom, 1, 1, $('#geneIDFCBX').is(":checked"));
            }
        });
        $('#geneDescFCBX').click(function () {
            if (typeof tblFrom != 'undefined') {
                displayColumns(tblFrom, 2, 1, $('#geneDescFCBX').is(":checked"));
            }
        });

        $('#transAnnotCBX').click(function () {
            if (typeof tblFrom != 'undefined') {
                displayColumns(tblFrom, 3, 2, $('#transAnnotCBX').is(":checked"));
            }
        });
        $('#allPvalCBX').click(function () {
            if (typeof tblFrom != 'undefined') {
                for (var i = 0; i < tisLen; i++) {
                    displayColumns(tblFrom, i * 2 + 7, 1, $('#allPvalCBX').is(":checked"));
                }
            }
        });
        $('#allLocCBX').click(function () {
            if (typeof tblFrom != 'undefined') {
                for (var i = 0; i < tisLen; i++) {
                    displayColumns(tblFrom, i * 2 + 8, 1, $('#allLocCBX').is(":checked"));
                }
            }
        });
        $('#fromBrainCBX').click(function () {
            if (typeof tblFrom != 'undefined') {
                displayColumns(tblFrom, 7, 2, $('#fromBrainCBX').is(":checked"));
            }
        });
        $('#fromHeartCBX').click(function () {
            if (typeof tblFrom != 'undefined') {
                displayColumns(tblFrom, 9, 2, $('#fromHeartCBX').is(":checked"));
            }
        });
        $('#fromLiverCBX').click(function () {
            if (typeof tblFrom != 'undefined') {
                displayColumns(tblFrom, 11, 2, $('#fromLiverCBX').is(":checked"));
            }
        });
        $('#fromBATCBX').click(function () {
            if (typeof tblFrom != 'undefined') {
                displayColumns(tblFrom, 13, 2, $('#fromBATCBX').is(":checked"));
            }
        });


        $('#circosSizeSelect').change(function () {
            var size = $(this).val();
            $('#circosIFrame').attr("height", size);
            tblFrom.fnSettings().oScroll.sY = size;
            tblFrom.fnDraw();
            /*if(size<=950){
                $('#circosIFrame').attr("width",950);
            }else{
                $('#circosIFrame').attr("width",size-2);
            }*/
        });
        $('.eQTLListToolTip').tooltipster({
            position: 'top-right',
            maxWidth: 250,
            offsetX: 8,
            offsetY: 5,
            contentAsHTML: true,
            //arrow: false,
            interactive: true,
            interactiveTolerance: 350
        });


    </script>
    <%} else {%>
        No genes to display. Try changing the filtering parameters.
    <%}%>
    <%} else {%>
        <div id="circosDiv">
            <div class="regionSubHeader" style="font-size:18px; font-weight:bold; text-align:center; width:100%;">
                Genes with an eQTL overlaping this region(HRDP v5 RNA-Seq <%=transcriptome%> Data(<%if(cisOnly.equals("cis")){%>Cis eQTLs<%}else{%>Cis and Trans eQTLS<%}%>))
                <div class="inpageHelp" style="display:inline-block;"><img id="HelpRevCircos" class="helpImage"
                                                                           src="../web/images/icons/help.png"/></div>
                <!--<span style="font-size:12px; font-weight:normal;">
                Adjust Vertical Viewable Size:
                <select name="circosSizeSelect" id="circosSizeSelect">
                        <option value="200" >Smallest</option>
                        <option value="475" >Half</option>
                        <option value="950" selected="selected">Full</option>
                        <option value="1000" >Maximized</option>
                    </select>
                </span>
                <span class="eQTLListToolTip" title="To control the viewable area of the Circos Plot below simply select your prefered size."><img src="<%=imagesDir%>icons/info.gif"></span>-->

            </div><BR>
            <span id="filterBtn1" class="filter button">Filter eQTLs</span>
            <BR>
            <span style="color:#FF0000;"></span><strong><%=errorMessage%></strong></span>
        </div>
    <%}%>

</div>
<!-- end eQTL List-->




<div id="viewEQTL" class="viewEQTL"
     style="background-color:#FFFFFF;display:none;position:absolute;z-index:999; top:660px; left:451px; border:solid;border-color:#000000;border-width:1px; width:450px;">
    <div style=" text-align:center; background-color:#F8F8F8;">
        <span style="color:#000000;">Show/Hide Columns</span>
        <span class="closeBtn" id="close_viewEQTL" style="position:relative;top:1px;left:150px;"><img
                src="<%=imagesDir%>icons/close.png"></span>
    </div>
    <div style="width:100%;">
        <div class="columnLeft" style="width:60%;">

            <input name="chkbox" type="checkbox" id="geneIDFCBX" value="geneIDFCBX" checked="checked"/> Gene ID <span
                class="eQTLListToolTip" title="Shows/Hides the Gene ID and links"><img
                src="<%=imagesDir%>icons/info.gif"></span><BR/>

            <input name="chkbox" type="checkbox" id="geneDescFCBX" value="geneDescFCBX" checked="checked"/> Description
            <span class="eQTLListToolTip" title="Shows/Hides the gene description from Ensembl."><img
                    src="<%=imagesDir%>icons/info.gif"></span><BR/>

            <input name="chkbox" type="checkbox" id="transAnnotCBX" value="transAnnotCBX" checked="checked"/> Transcript
            ID and Annot. <span class="eQTLListToolTip"
                                title="Shows/Hides the Affymetrix transcript cluster id and annotation level."><img
                src="<%=imagesDir%>icons/info.gif"></span><BR/>

            <input name="chkbox" type="checkbox" id="allPvalCBX" value="allPvalCBX" checked="checked"/> All Tissues
            P-values <span class="eQTLListToolTip" title="Shows/Hides the P-value from the region for each tissue."><img
                src="<%=imagesDir%>icons/info.gif"></span><BR/>

            <input name="chkbox" type="checkbox" id="allLocCBX" value="allLocCBX" checked="checked"/> All Tissues #
            Locations <span class="eQTLListToolTip"
                            title="Shows/Hides the count of the other eQTLs for the gene with a P-value below the cutoff."><img
                src="<%=imagesDir%>icons/info.gif"></span><BR/>
        </div>
        <div class="columnRight" style="width:39%;">
            <h3>Specific Tissues:</h3>

            <input name="chkbox" type="checkbox" id="fromBrainCBX" value="fromBrainCBX" checked="checked"/> Whole Brain
            <span class="eQTLListToolTip" title="Shows/Hides columns associated with brain tissue."><img
                    src="<%=imagesDir%>icons/info.gif"></span><BR/>
            <%if (myOrganism.equals("Rn")) {%>

            <input name="chkbox" type="checkbox" id="fromHeartCBX" value="fromHeartCBX" checked="checked"/> Heart <span
                class="eQTLListToolTip" title="Shows/Hides columns associated with heart tissue."><img
                src="<%=imagesDir%>icons/info.gif"></span><BR/>

            <input name="chkbox" type="checkbox" id="fromLiverCBX" value="fromLiverCBX" checked="checked"/> Liver <span
                class="eQTLListToolTip" title="Shows/Hides columns associated with liver tissue."><img
                src="<%=imagesDir%>icons/info.gif"></span><BR/>

            <input name="chkbox" type="checkbox" id="fromBATCBX" value="fromBATCBX" checked="checked"/> Brown Adipose
            <span class="eQTLListToolTip" title="Shows/Hides columns associated with brown adipose tissue."><img
                    src="<%=imagesDir%>icons/info.gif"></span><BR/>
            <%}%>
        </div>
    </div>
</div>


<script type="text/javascript">
    //$(document).ready(function() {
    $(".multiselect").twosidedmultiselect();

    /*if (typeof tblFrom != 'undefined') {
        tblFrom.fnAdjustColumnSizing();
        tblFrom.fnDraw();
    }*/

    var pW = $('#iframe_parent').width();
    $('#circosIFrame').attr('width', pW - 25);
    //console.log("parent size(init):"+pW);
    $(window).resize(function () {
        var pW = $('#iframe_parent').width();
        $('#circosIFrame').attr('width', pW - 25);
       /* if (typeof tblFrom != 'undefined') {
            tblFrom.fnAdjustColumnSizing();
            tblFrom.fnDraw();
        }*/
    });

    $(document).on("click", "span.filter", function () {
        var id = new String($(this).attr("id"));
        if (!$("div#filterdivEQTL").is(":visible")) {
            var p = $(this).position();
            //var left = p.left;
            //if (left > $(window).width() / 2) {
            //    left = left - $("#filterdivEQTL").width() + 130;
           // }
            //console.log("top:" + top + " left:" + left);
            //$("#filterdivEQTL").css("display", "inline-block");
            $("#filterdivEQTL").css("top", p.top).css("left", "50px");
            $("#filterdivEQTL").show();
        } else {
            $("#filterdivEQTL").fadeOut("fast");
            var p = $(this).position();
            /*var left = p.left;
            if (left > $(window).width() / 2) {
                left = left - $("#filterdivEQTL").width() + 130;
            }*/
            $("#filterdivEQTL").css("top", p.top).css("left", "50px");
        }
        //this.preventDefault();
        return true;
    });

    $(document).on("click", "span.view", function () {
        var id = new String($(this).attr("id"));
        if (!$("div#viewEQTL").is(":visible")) {
            var p = $(this).position();
            $("#viewEQTL").css("display", "inline-block");
            $("#viewEQTL").css("top", p.top).css("left", p.left - 226);
            $("#viewEQTL").show();
            //$("#viewEQTL").fadeIn("fast");
        } else {
            $("#viewEQTL").fadeOut("fast");
        }
        return false;
    });
    //below fixes a bug in IE9 where some whitespace may cause an extra column in random rows in large tables.
    //simply remove all whitespace from html in a table and put it back.
    if (/MSIE (\d+\.\d+);/.test(navigator.userAgent)) { //test for MSIE x.x;
        var ieversion = new Number(RegExp.$1) // capture x.x portion and store as a number
        if (ieversion < 10) {
            var expr = new RegExp('>[ \t\r\n\v\f]*<', 'g');
            var tbhtml = $('#tblFrom').html();
            $('#tblFrom').html(tbhtml.replace(expr, '><'));
        }
    }

    //}
</script>

