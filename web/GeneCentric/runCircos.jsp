<%@ include file="/web/common/anon_session_vars.jsp" %>
<jsp:useBean id="gdt" class="edu.ucdenver.ccp.PhenoGen.tools.analysis.GeneDataTools" scope="session"></jsp:useBean>
<%
    //
    // Initialize some variables
    //
    String iframeURL = null;
    String svgPdfFile = null;
    String geneSymbolinternal = null;
    String geneCentricPath = null;
    String ensemblIdentifier = null;
    String transcriptClusterFileName = null;
    String species = null;
    String longSpecies = null;
    String selectedTranscriptValue = null;
    String transcriptClusterID = null;
    String transcriptClusterChromosome = null;
    String transcriptClusterStart = null;
    String transcriptClusterStop = null;
    String selectedCutoffValue = null;
    String[] selectedChromosomes = null;
    String[] selectedTissues = null;
    String chromosomeString = null;
    String tissueString = null;
    String[] transcriptClusterArray = new String[0];
    int[] transcriptClusterArrayOrder = null;
    Boolean transcriptError = null;
    Boolean selectedChromosomeError = null;
    Boolean selectedTissueError = null;
    Boolean circosReturnStatus = null;
    Boolean missingPhenoGenIDError = false;
    String timeStampString = null;
    String genomeVer = "";
    String source = "seq";
    String dataVer = "";
    String transcriptome = "ensembl";
    String cisOnly = "all";
    FileHandler myFH = new FileHandler();
    //
    //Configure Inputs from session variables, unless they are already defined on the page.
    //

    LinkedHashMap inputHash = new LinkedHashMap();
    if (request.getParameter("geneCentricPath") != null) {
        geneCentricPath = (String) request.getParameter("geneCentricPath");
    }
    if (request.getParameter("geneSymbol") != null) {
        // The top of the form has already been filled in so get information from form
        geneSymbolinternal = (String) request.getParameter("geneSymbol");

        log.debug("Got geneCentricPath and geneSymbol from form " + geneSymbolinternal + "  " + geneCentricPath);
    }
    if (request.getParameter("source") != null) {
        source = FilterInput.getFilteredInput(request.getParameter("source"));
    }
    if (request.getParameter("genomeVer") != null) {
        genomeVer = FilterInput.getFilteredInputGenomeVer(request.getParameter("genomeVer"));
    }
    if (request.getParameter("dataVer") != null) {
        dataVer = FilterInput.getFilteredInput(request.getParameter("dataVer"));
    }
    if (request.getParameter("transcriptome") != null) {
        transcriptome = FilterInput.getFilteredInput(request.getParameter("transcriptome"));
    }
    if (request.getParameter("cisOnly") != null) {
        cisOnly = FilterInput.getFilteredInput(request.getParameter("cisOnly"));
    }
    log.debug("before geneCentricPath");
    inputHash.put("geneSymbol", geneSymbolinternal);
    log.debug("after geneSymbol:" + geneSymbolinternal);
    if (geneCentricPath != null && !geneCentricPath.equals("")) {
        inputHash.put("geneCentricPath", geneCentricPath);
        log.debug("after geneCentricPath\n" + geneCentricPath);
        Integer tmpIndex = geneCentricPath.substring(1, geneCentricPath.length() - 1).lastIndexOf('/');
        log.debug("after tmpIndex");
        log.debug(geneCentricPath);
        inputHash.put("length", tmpIndex);
        log.debug("after geneCentricPath");

        ensemblIdentifier = geneCentricPath.substring(tmpIndex + 2, geneCentricPath.length() - 1);
        log.debug("ensembl:" + ensemblIdentifier);
        inputHash.put("ensemblIdentifier", ensemblIdentifier);
        inputHash.put("transcriptClusterFileName", geneCentricPath + "tmp_psList_transcript.txt");
        transcriptClusterFileName = geneCentricPath.concat("tmp_psList_transcript.txt");
    } else {
        if (request.getParameter("transcriptClusterID") != null) {
            transcriptClusterID = request.getParameter("transcriptClusterID");
        }
        ensemblIdentifier = transcriptClusterID;
        geneCentricPath = applicationRoot + contextRoot + "tmpData/browserCache/" + genomeVer + "/geneData/" + ensemblIdentifier + "/";
        inputHash.put("ensemblIdentifier", ensemblIdentifier);
        inputHash.put("transcriptClusterFileName", geneCentricPath + "tmp_psList_transcript.txt");
        transcriptClusterFileName = geneCentricPath.concat("tmp_psList_transcript.txt");
    }


    if (ensemblIdentifier.substring(0, 7).equals("ENSRNOG") || ensemblIdentifier.substring(0, 3).equals("PRN")) {
        species = "Rn";
        longSpecies = "Rattus norvegicus";
    } else if (ensemblIdentifier.substring(0, 7).equals("ENSMUSG") || ensemblIdentifier.substring(0, 3).equals("PMM")) {
        species = "Mm";
        longSpecies = "Mus musculus";
    }
    log.debug("after species");
    String[] columns;
    //Check for gene with data
    String geneChromosome = "Z";
    String speciesGeneChromosome = species.toLowerCase() + geneChromosome;
    if (source.equals("array") && ensemblIdentifier.substring(0, 3).equals("ENS")) {
        //
        // Read in transcriptClusterID information from file
        // Also get the chromosome that corresponds to the gene symbol
        //

        transcriptClusterArray = myFileHandler.getFileContents(new File(transcriptClusterFileName));

        log.debug("transcriptClusterArray length = " + transcriptClusterArray.length);
        // If the length of the transcript Cluster Array is 0, return an error.
        if (transcriptClusterArray.length == 0) {
            log.debug(" the transcript cluster file is empty ");
            transcriptClusterArray = new String[1];
            transcriptClusterArray[0] = "No Available	xx	xxxxxxxx	xxxxxxxx	Transcripts";
            log.debug(transcriptClusterArray[0]);
            transcriptError = true;
        } else {
            transcriptError = false;
            // Need to change the transcript Cluster Array
            // Only include ambiguous if there are no other transcript clusters
            // Order the transcript cluster array so core is first, full is next, then extended, then ambiguous
            transcriptClusterArrayOrder = new int[transcriptClusterArray.length];
            for (int i = 0; i < transcriptClusterArray.length; i++) {
                transcriptClusterArrayOrder[i] = -1;
            }
            int numberOfTranscriptClusters = 0;
            for (int i = 0; i < transcriptClusterArray.length; i++) {
                columns = transcriptClusterArray[i].split("\t");
                if (columns[4].equals("core")) {
                    transcriptClusterArrayOrder[numberOfTranscriptClusters] = i;
                    numberOfTranscriptClusters++;
                }
            }
            for (int i = 0; i < transcriptClusterArray.length; i++) {
                columns = transcriptClusterArray[i].split("\t");
                if (columns[4].equals("extended")) {
                    transcriptClusterArrayOrder[numberOfTranscriptClusters] = i;
                    numberOfTranscriptClusters++;
                }
            }
            for (int i = 0; i < transcriptClusterArray.length; i++) {
                columns = transcriptClusterArray[i].split("\t");
                if (columns[4].equals("full")) {
                    transcriptClusterArrayOrder[numberOfTranscriptClusters] = i;
                    numberOfTranscriptClusters++;
                }
            }
            if (numberOfTranscriptClusters < 1) {
                for (int i = 0; i < transcriptClusterArray.length; i++) {
                    columns = transcriptClusterArray[i].split("\t");
                    if (columns[4].equals("ambiguous")) {
                        transcriptClusterArrayOrder[numberOfTranscriptClusters] = i;
                        numberOfTranscriptClusters++;
                    }
                }
                for (int i = 0; i < transcriptClusterArray.length; i++) {
                    columns = transcriptClusterArray[i].split("\t");
                    if (columns[4].equals("free")) {
                        transcriptClusterArrayOrder[numberOfTranscriptClusters] = i;
                        numberOfTranscriptClusters++;
                    }
                }
            }
        }
        columns = transcriptClusterArray[0].split("\t");
        geneChromosome = columns[1];
        log.debug(" geneChromosome " + geneChromosome);
        speciesGeneChromosome = species.toLowerCase() + geneChromosome;
        if (request.getParameter("transcriptClusterID") != null) {
            selectedTranscriptValue = request.getParameter("transcriptClusterID");
            String[] transcriptArray = selectedTranscriptValue.split("\t");
            transcriptClusterID = transcriptArray[0];
            transcriptClusterChromosome = species.toLowerCase() + transcriptArray[1];
            transcriptClusterStart = transcriptArray[2];
            transcriptClusterStop = transcriptArray[3];
            log.debug(" Transcript Cluster ID: " + transcriptClusterID);
            log.debug(" Transcript Cluster Chromosome: " + transcriptClusterChromosome);
            log.debug(" Transcript Cluster Start: " + transcriptClusterStart);
            log.debug(" Transcript Cluster Stop: " + transcriptClusterStop);
        }
    } else if (source.equals("seq")) {
        log.debug("seq");
        String[] loc = null;
        if (request.getParameter("transcriptClusterID") != null) {
            transcriptClusterID = request.getParameter("transcriptClusterID");
        } else if (ensemblIdentifier != null && !ensemblIdentifier.equals("")) {
            transcriptClusterID = ensemblIdentifier;
        }
        log.debug("transcriptClusterID:seq:" + transcriptClusterID);
        if (transcriptClusterID.startsWith("ENS") && transcriptome.equals("reconst")) {
            // find the corresponding Reconstruction Gene
            try {
                ArrayList<String> idlist = gdt.getPhenoGenID(transcriptClusterID, genomeVer, version);
                if (idlist.size() == 1) {
                    transcriptClusterID = idlist.get(0);
                    log.debug("ID list:" + idlist);
                } else if (idlist.size() > 1) {
                    transcriptClusterID = idlist.get(0);
                    log.debug("ID list >1:" + idlist);
                }
            } catch (SQLException e) {
                log.error("PhenoGenID list error:", e);
            }
            //Return error if no corresponding gene
            if (transcriptClusterID.startsWith("ENS")) {
                missingPhenoGenIDError = true;
            }
        }
        try {
            loc = myFH.getFileContents(new File(geneCentricPath.concat("location.txt")));
        } catch (IOException e) {
            log.error("Couldn't load location for gene.", e);
        }
        if (loc != null) {
            geneChromosome = loc[0];
            if (loc[0].startsWith("chr")) {
                geneChromosome = loc[0].substring(3);

            }
            transcriptClusterChromosome = species.toLowerCase() + geneChromosome;
            transcriptClusterStart = loc[1];
            transcriptClusterStop = loc[2];
        }
        speciesGeneChromosome = species.toLowerCase() + geneChromosome;
    }
    log.debug("after setting up source");
    // Populate the variable geneChromosome with the chromosome in the first line
    // The chromosome should always be the same for every line in this file


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

    if (species.equals("Mm")) {
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
    log.debug("after setup chromosomes");
    //
    // Create tissueNameArray and tissueSelectedArray
    // These are only defined for Rat
    //
    int numberOfTissues = 0;
    String[] tissueNameArray = new String[4];

    String[] tissueDisplayArray = new String[4];

    String tissueSelected = isNotSelectedText;

    if (species.equals("Mm")) {
        numberOfTissues = 1;
        tissueNameArray[0] = "Brain";
        tissueDisplayArray[0] = "Whole Brain";
    } else if (species.equals("Rn") && source.equals("array")) {
        numberOfTissues = 4;
        // assume if not mouse that it's rat
        tissueNameArray[0] = "Brain";
        tissueDisplayArray[0] = "Whole Brain";
        tissueNameArray[1] = "Heart";
        tissueDisplayArray[1] = "Heart";
        tissueNameArray[2] = "Liver";
        tissueDisplayArray[2] = "Liver";
        tissueNameArray[3] = "BAT";
        tissueDisplayArray[3] = "Brown Adipose";
    } else if (species.equals("Rn") && source.equals("seq")) {
        numberOfTissues = 2;
        // assume if not mouse that it's rat
        tissueNameArray[0] = "Brain";
        tissueDisplayArray[0] = "Whole Brain";
        tissueNameArray[1] = "Liver";
        tissueDisplayArray[1] = "Liver";
    }
    // Get information about the cutoff value
    if (request.getParameter("cutoffValue") != null) {
        selectedCutoffValue = request.getParameter("cutoffValue");
        log.debug(" Selected Cutoff Value " + selectedCutoffValue);
        double tmpPval = Double.parseDouble(selectedCutoffValue);
        if (tmpPval < 1) {
            tmpPval = -1 * Math.log10(tmpPval);
            selectedCutoffValue = Double.toString(tmpPval);
        }

    } else {
        selectedCutoffValue = "3.0";
    }

    // Get information about which tissues to view -- easier for mouse

    if (species.equals("Mm")) {
        tissueString = "Brain;";
        selectedTissueError = false;
    } else {
        // we assume if not mouse that it's rat
        if (request.getParameter("tissues") != null && !request.getParameter("tissues").equals("")) {
            String tmpSelectedTissues = request.getParameter("tissues");
            selectedTissues = tmpSelectedTissues.split(";");
            log.debug("Getting selected tissues");
            tissueString = "";
            selectedTissueError = true;
            for (int i = 0; i < selectedTissues.length; i++) {
                selectedTissueError = false;
                tissueString = tissueString + selectedTissues[i] + ";";
            }
            log.debug(" Selected Tissues: " + tissueString);
            log.debug(" selectedTissueError: " + selectedTissueError);
            // We insist that the tissue string be at least one long
        } else {
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
        log.debug("Getting selected chromosomes");
        chromosomeString = "";
        selectedChromosomeError = true;
        for (int i = 0; i < selectedChromosomes.length; i++) {
            log.debug("chr: " + selectedChromosomes[i] + "::" + speciesGeneChromosome);
            chromosomeString = chromosomeString + selectedChromosomes[i] + ";";
            if (selectedChromosomes[i].equals(speciesGeneChromosome)) {
                selectedChromosomeError = false;
            }
        }
        log.debug(" Selected Chromosomes: " + chromosomeString);
        log.debug(" selectedChromosomeError: " + selectedChromosomeError);
        // We insist that the chromosome string include speciesGeneChromosome
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
    log.debug("chrStr:" + chromosomeString);
    log.debug(("tisStr:") + tissueString);
    if ((!selectedChromosomeError) && (!selectedTissueError)) {
        //
        // Initialize variables for calling perl scripts (which will call Circos executable)
        //

        String perlScriptDirectory = (String) session.getAttribute("perlDir") + "scripts/";
        String perlEnvironmentVariables = (String) session.getAttribute("perlEnvVar");

        String hostName = request.getServerName();
        perlEnvironmentVariables += ":/usr/bin:/usr/share/circos/lib:/usr/share/circos/bin";
            /*if(hostName.equals("phenogen.ucdenver.edu")){
                    perlEnvironmentVariables += ":/usr/bin/perl5.10.1:/usr/local/circos-0.69-4/lib:/usr/local/circos-0.69-4/bin";
            }
            else if(hostName.equals("140.226.114.31")){
                    perlEnvironmentVariables += ":/bin:/usr/bin:/usr/bin/perl:/usr/local/circos-0.69-4/lib:/usr/local/circos-0.69-4/bin";
            }
            else{
                    perlEnvironmentVariables += ":/usr/bin/perl5.10.1:/usr/local/circos-0.69-4/lib:/usr/local/circos-0.69-4/bin";
            }*/
        log.debug("Host Name " + hostName);
        String filePrefixWithPath = "";
        if (request.getParameter("geneCentricPath") != null && source.equals("array")) {
            filePrefixWithPath = (String) request.getParameter("geneCentricPath") + transcriptClusterID + "_circos";
        } else if (source.equals("seq")) {
            filePrefixWithPath = (String) request.getParameter("geneCentricPath") + "default_circos";
        }
        // create the short svg directory name which incoporates the date for uniqueness
        java.util.Date dNow = new java.util.Date();
        SimpleDateFormat ft = new SimpleDateFormat("yyyyMMddhhmmss");
        timeStampString = ft.format(dNow);
        //
        // Get the database connection properties
        //
        Properties myProperties = new Properties();
        File myPropertiesFile = new File(dbPropertiesFile);
        myProperties.load(new FileInputStream(myPropertiesFile));
        String port = myProperties.getProperty("PORT");
        String dsn = "dbi:mysql:database=" + myProperties.getProperty("DATABASE") + ";host=" + myProperties.getProperty("HOST") + ";port=" + port;
        //String dsn = "dbi:"+ myProperties.getProperty("PLATFORM")+ ":" + myProperties.getProperty("DATABASE");
        String OracleUserName = myProperties.getProperty("USER");
        String password = myProperties.getProperty("PASSWORD");

        String rnaDSIDs = "";
        String prnID = "";
        if (source.equals("seq")) {
            rnaDSIDs = gdt.getRNADatasetIDsforTissues(species, tissueString, genomeVer, version);
            String[] tmpID = rnaDSIDs.split(",");
            prnID = gdt.translateENStoPRN(tmpID[0], ensemblIdentifier);
            if (prnID.contains("PRN")) {
                missingPhenoGenIDError = false;
            }
        }


        log.debug("\n******* Create Perl Arguments");
        String[] perlScriptArguments = new String[24];
        // the 0 element in the perlScriptArguments array must be "perl" ??
        perlScriptArguments[0] = "perl";
        // the 1 element in the perlScriptArguments array must be the script name including path
        perlScriptArguments[1] = perlScriptDirectory + "callCircos.pl";
        perlScriptArguments[2] = ensemblIdentifier;
        perlScriptArguments[3] = geneSymbolinternal;
        perlScriptArguments[4] = transcriptClusterID;
        perlScriptArguments[5] = "transcript";
        perlScriptArguments[6] = transcriptClusterChromosome;
        perlScriptArguments[7] = transcriptClusterStart;
        perlScriptArguments[8] = transcriptClusterStop;
        perlScriptArguments[9] = selectedCutoffValue;
        perlScriptArguments[10] = species;
        perlScriptArguments[11] = genomeVer;
        perlScriptArguments[12] = chromosomeString;
        perlScriptArguments[13] = geneCentricPath;
        perlScriptArguments[14] = timeStampString;
        perlScriptArguments[15] = tissueString;
        //perlScriptArguments[14]="All";
        perlScriptArguments[16] = dsn;
        perlScriptArguments[17] = OracleUserName;
        perlScriptArguments[18] = password;
        perlScriptArguments[19] = source;
        perlScriptArguments[20] = rnaDSIDs;
        perlScriptArguments[21] = prnID;
        perlScriptArguments[22] = transcriptome;
        perlScriptArguments[23] = cisOnly;
        log.debug("\n******* Create Perl Arguments[20]");

        log.debug("\n*** Calling createCircosFiles from GeneDataTools");
        //log.debug(" filePrefixWithPath "+filePrefixWithPath);
        //
        // call perl script
        //
        //GeneDataTools gdtCircos=new GeneDataTools();
        //gdtCircos.setSession(session);
        circosReturnStatus = gdt.createCircosFiles(perlScriptDirectory, perlEnvironmentVariables, perlScriptArguments, filePrefixWithPath);
        if (circosReturnStatus) {
            log.debug("Circos run completed successfully");
            String shortGeneCentricPath;
            //if(geneCentricPath.indexOf("/PhenoGen/") > 0){
            shortGeneCentricPath = geneCentricPath.substring(geneCentricPath.indexOf("/tmpData/"));
                /*}
                else{
                        shortGeneCentricPath = geneCentricPath.substring(geneCentricPath.indexOf("/PhenoGenTEST/"));
                }*/
            String svgFile = shortGeneCentricPath + transcriptClusterID + "_" + timeStampString + "/svg/circos_new.svg";
            svgPdfFile = shortGeneCentricPath + transcriptClusterID + "_" + timeStampString + "/svg/circos.png";
            iframeURL = svgFile;
        } else {
            log.debug("Circos run failed");
            // be sure iframeURL is still null
            iframeURL = null;
        } // end of if(circosReturnStatus)

    } // end of if((!selectedChromosomeError)&&(!selectedTissueError)){
    // This is the end of the first big scriptlet
    response.setDateHeader("Expires", 0);
%>


<%
    if ((circosReturnStatus != null) && (!circosReturnStatus)) {
%>
<div style="color:#FF0000;">There was an error running Circos. The web site administrator has been informed. Occasionally these errors can be fixed by running
    Circos a second time.
</div>
<%
    } // end of checking circosReturnStatus
%>


<%if (missingPhenoGenIDError) {%>
<div style="color:#FF0000;">RNA-Seq based eQTLs are not available for this Ensembl gene as none of the reconstruction transcripts matched a transcript in this
    gene.
</div>
<%} else if ((selectedTissueError != null) && (selectedTissueError)) {%>
<div style="color:#FF0000;">Select at least one tissue.</div>
<%
} // end of checking selectedTissueError
else if ((selectedChromosomeError != null) && (selectedChromosomeError)) {
%>
<div style="color:#FF0000;">Chromosome <%=geneChromosome%> must be selected.</div>
<%
    } // end of checking selectedChromosomeError
%>


<%if (iframeURL != null) {%>
<div align="center">
    Inside of border below, the mouse wheel zooms. Outside of the border, the mouse wheel scrolls.
    Download Circos image:
    <a href="<%=svgPdfFile%>" target="_blank">
        <img src="/web/images/icons/download_g.png">
    </a>
    <div id="iframe_parent" align="center">
        <iframe id="circosIFrame" src=<%=iframeURL%> height=950 width=950 position=absolute scrolling="no"
                style="border-style:solid; border-color:rgb(139,137,137); border-radius:15px; -moz-border-radius: 15px; border-width:1px">
        </iframe>
    </div>
</div>
<%
    }// end of if iframeURL != null
%>	




