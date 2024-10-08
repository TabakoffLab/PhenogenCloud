<style type="text/css">
    /* Recommended styles for two sided multi-select*/
    .tsmsselect {
        width: 40%;
        float: left;
    }

    .tsmsselect select {
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
    var source = "<%=source%>";
    var version = "<%=version%>";
    var geneSymbolTmp = "<%=geneSymbol.get(0)%>";
    var idTmp = "<%=id%>";
    var tcID = idTmp;
    var path = "<%=gcPath%>";

    function displayWorkingCircos() {
        document.getElementById("wait2").style.display = 'block';
        //document.getElementById("circosError1").style.display = 'none';
    }

    function hideWorkingCircos() {
        document.getElementById("wait2").style.display = 'none';
        //document.getElementById("circosError1").style.display = 'none';
    }

    function runCircos() {
        console.log("runCircos()");
        $('#wait2').show();
        var chrList = "";
        $("#chromosomesMS option").each(function () {
            chrList += $(this).val() + ";";
        });

        var tisList = "";
        $("#tissuesMS option").each(function () {
            tisList += $(this).val() + ";";
        });

        var pval = $('#cutoffValue').val();
        if ($('#transcriptClusterID').val()) {
            tcID = $('#transcriptClusterID').val();
        }
        if ($("#hiddenGeneCentricPath").val()) {
            path = $("#hiddenGeneCentricPath").val();
        }
        var version = $('#version').val();
        if ($("#hiddenGeneSymbol").val()) {
            geneSymbolTmp = $("#hiddenGeneSymbol").val();
        }
        var transcriptome = $('#transriptome').val();
        var cisOnly = $('#cisTrans').val();

        if ($('#trxCB').val() && $('#trxCB').val() !== "gene") {
            geneSymbol = $('#trxCB').val();
            tcID = $('#trxCB').val();
        }
        $.ajax({
            url: "/web/GeneCentric/runCircos.jsp",
            type: 'GET',
            cache: false,
            data: {
                cutoffValue: pval,
                geneSymbol: geneSymbolTmp,
                transcriptClusterID: tcID,
                tissues: tisList,
                chromosomes: chrList,
                geneCentricPath: path,
                genomeVer: genomeVer,
                source: source,
                version: version,
                transcriptome: transcriptome,
                cisOnly: cisOnly
            },
            dataType: 'html',
            beforeSend: function () {
            },
            complete: function () {
                displayType = "RNA-Seq";
                if (source === "array") {
                    displayType = "Microarray";
                }
                $('span#typeLabel').html(displayType);
                $('#wait2').hide();
                $('#forIframe').show();
            },
            success: function (data2) {
                $('#forIframe').html(data2);
            },
            error: function (xhr, status, error) {
                $('#forIframe').html("<div>An error occurred generating this image.  Please try back later.</div>");
            }
        });
        //$('.allowChromSelection').show();
    }

    function changeSource() {
        console.log("changeSource");
        tmpSrc = $('#sourceCB').val();
        if (tmpSrc === "seq") {
            $("#tissuesMS option[value='Heart']").remove();
            $("#tissuesMStsms option[value='Heart']").remove();
            $("#tissuesMS option[value='BAT']").remove();
            $("#tissuesMStsms option[value='BAT']").remove();
            $("#tissuesMS").append('<option value="Kidney">Kidney</option>')
            $("td#trxClusterCB").hide();
            $("span#versionSelect").show();
        } else {
            $("#tissuesMS").append('<option value="Heart" selected>Heart</option>');
            $("#tissuesMS").append('<option value="BAT" selected>Brown Adipose</option>');
            $("#tissuesMS option[value='Kidney']").remove();
            $("#tissuesMStsms option[value='Kidney']").remove();
            $("td#trxClusterCB").show();
            $("span#versionSelect").hide();
        }
        source = tmpSrc;
        //$("#tissuesMS").twosidedmultiselect();
    }
</script>
<%
    String selectedCutoffValue = null;
    String transcriptClusterFileName = null;
    String geneSymbolinternal = geneSymbol.get(selectedGene);
    String geneCentricPath = gcPath;
    String[] selectedChromosomes = null;
    String[] selectedTissues = null;
    String chromosomeString = null;
    String tissueString = null;
    String[] transcriptClusterArray = null;
    int[] transcriptClusterArrayOrder = null;
    Boolean transcriptError = false;
    String species = myOrganism;
    String selectedTranscriptValue = null;
    Boolean selectedChromosomeError = null;
    Boolean selectedTissueError = null;
    Boolean circosReturnStatus = null;
    Boolean allowChromosomeSelection = false; // This variable now controls both tissue and chromosome selection
    String iframeURL = null;
    String svgPdfFile = null;
    if (request.getParameter("cutoffValue") != null) {
        selectedCutoffValue = FilterInput.getFilteredInput(request.getParameter("cutoffValue"));
        log.debug(" Selected Cutoff Value " + selectedCutoffValue);

    }
    transcriptClusterFileName = geneCentricPath.concat("tmp_psList_transcript.txt");
    //
    // Read in transcriptClusterID information from file
    // Also get the chromosome that corresponds to the gene symbol
    //
    boolean fileError = false;
    try {
        log.debug("readFile:" + transcriptClusterFileName);
        transcriptClusterArray = myFileHandler.getFileContents(new File(transcriptClusterFileName));
        log.debug("TranscriptClusterArray:\n" + transcriptClusterArray.length);
    } catch (IOException e) {
        fileError = true;
    }
    String[] columns;
    //log.debug("transcriptClusterArray length = " + transcriptClusterArray.length);
    // If the length of the transcript Cluster Array is 0, return an error.
    if (source.equals("seq")) {

    } else {
        if (transcriptClusterArray == null || transcriptClusterArray.length == 0) {
            log.debug(" the transcript cluster file is empty ");
            transcriptClusterArray = new String[1];
            transcriptClusterArray[0] = "No Available	xx	xxxxxxxx	xxxxxxxx	Transcripts";
            log.debug(transcriptClusterArray[0]);
            transcriptError = null;
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
    }
    // Populate the variable geneChromosome with the chromosome in the first line
    // The chromosome should always be the same for every line in this file
    String geneChromosome = "Y";
    //columns = transcriptClusterArray[0].split("\t");
    geneChromosome = chromosome;
    if (geneChromosome.toLowerCase().startsWith("chr")) {
        geneChromosome.substring(3);
    }
    log.debug(" geneChromosome " + geneChromosome);
    String speciesGeneChromosome = species.toLowerCase() + geneChromosome;

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

    //
    // Create tissueNameArray and tissueSelectedArray
    // These are only defined for Rat
    //
    int numberOfTissues;
    String[] tissueNameArray = new String[4];

    String[] tissueDisplayArray = new String[4];

    String tissueSelected = isNotSelectedText;

    if (species.equals("Mm")) {
        numberOfTissues = 1;
        tissueNameArray[0] = "Brain";
        tissueDisplayArray[0] = "Whole Brain";
    } else {
        if (source.equals("seq")) {
            numberOfTissues = 3;
            // assume if not mouse that it's rat
            tissueNameArray[0] = "Brain";
            tissueDisplayArray[0] = "Whole Brain";
            tissueNameArray[1] = "Liver";
            tissueDisplayArray[1] = "Liver";
            tissueNameArray[2] = "Kidney";
            tissueDisplayArray[2] = "Kidney";
        } else {
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
        }
    }

    log.debug("END Initialization: geneEQTLPart.jsp");
%>


<div style="text-align:center;">

    <%if (transcriptError == null) { // check before adding the transcript cluster id to the form.  If there is an error, end the form here.%>
    </tbody>
    </table>
    <div style="display:block; color:#FF0000;">There was an error retrieving transcripts for <%=geneSymbolinternal%>. The website administrator has been
        informed.
    </div>
    <%} else if (transcriptError) { // check before adding the transcript cluster id to the form.  If there is an error, end the form here.%>
    </tbody>
    </table>
    <div style="display:block; color:#FF0000;">There are no available transcript cluster IDs for <%=geneSymbolinternal%>. Please choose a different gene to view
        eQTL.
    </div>
    <%} else { // go ahead and make the rest of the form for entering options%>
    <div style="font-size:18px; font-weight:bold; background-color:#47c647; color:#FFFFFF;width:100%;text-align:left;">
        <span class="trigger less triggerEC" id="circosOption1" name="circosOption">eQTL Image Options</span>
        <span class="eQTLtooltip"
              title="The controls in this section allow you to change the chromosomes and tissues included in the image as well as the P-value threshold.  If you can't see them click on the + icon.  Once you make changes click on the Click to Run Circos button."><img
                src="<%=imagesDir%>icons/info.gif"></span>
    </div>
    <table id="circosOptTbl" name="items" class="list_base" cellpadding="0" cellspacing="3" style="width:100%;text-align:left;">
        <tbody id="circosOption">
        <tr>
            <td>
                <strong>Data Source:</strong>
                <span class="eQTLtooltip"
                      title="RNA-Seq eQTLs and Microarray eQTLs are available at the gene/transcript cluster level.  Please note the label at the top of the image will indicate the data source for the image displayed."><img
                        src="<%=imagesDir%>icons/info.gif"></span>
                <%
                    selectName = "sourceCB";

                    selectedOption = source;
                    onChange = "changeSource()";
                    style = "";
                    optionHash = new LinkedHashMap();
                    optionHash.put("seq", "RNA-Seq");
                    //optionHash.put("array", "Microarrays");
                %>
                <%@ include file="/web/common/selectBox.jsp" %>
                <BR>
                <span id="versionSelect" style="display:inline-block;">
							<strong>Version:</strong>
						<span class="eQTLtooltip" title="HRDP data version to use."><img src="<%=imagesDir%>icons/info.gif"></span>
						<%
                            selectName = "version";
                            if (version.equals("")) {
                                if (genomeVer.equals("rn7")) {
                                    selectedOption = "6";
                                } else {
                                    selectedOption = "5";
                                }
                            } else {
                                selectedOption = version;
                            }
                            style = "";
                            optionHash = new LinkedHashMap();
                            //optionHash.put("1", "HRDP v3");
                            if (genomeVer.equals("rn6")) {
                                //optionHash.put("3", "HRDP v4");
                                optionHash.put("5", "HRDP v5");
                            } else if (genomeVer.equals("rn7")) {
                                optionHash.put("6", "HRDP v6");
                            }
                        %><%@ include file="/web/common/selectBox.jsp" %>

                    	<BR><strong>Gene/Transcript:</strong>
						<span class="eQTLtooltip" title="Select Gene level or individual transcripts."><img src="<%=imagesDir%>icons/info.gif"></span>
						<%
                            selectName = "trxCB";
                            if (trxID.equals("")) {
                                selectedOption = "gene";
                            } else {
                                selectedOption = trxID;
                            }
                            style = "";
                            optionHash = new LinkedHashMap();
                            optionHash.put("gene", geneSymbol + " - Gene level");
                            for (int i = 0; i < trxList.size(); i++) {
                                optionHash.put(trxList.get(i), trxList.get(i));
                            }
                        %><%@ include file="/web/common/selectBox.jsp" %>
						</span>
                <BR>
                <strong>Transcriptome Data:</strong>
                <select name="transcriptome" id="transriptome">
                    <option value="ensembl" <%if(transcriptome.equals("ensembl")){%>selected<%}%>>Ensembl</option>
                    <option value="reconst" <%if(transcriptome.equals("reconst")){%>selected<%}%>>Reconstruction</option>
                </select>
                <span class="eQTLListToolTip"
                      title="Select the transriptome used for quantification."><img
                        src="<%=imagesDir%>icons/info.gif"></span>
            </td>
            <td style="text-align:center;">
                <strong>P-value Threshold for Highlighting:</strong>
                <span class="eQTLtooltip"
                      title="Loci with p-values below the chosen threshold are highlighted on the Circos plot in yellow; a line connects the significant loci with the physical location of the gene. All p-values are displayed on the Circos graphic as the negative log base 10 of the p-value."><img
                        src="<%=imagesDir%>icons/info.gif"></span>

                <%
                    selectName = "cutoffValue";
                    if (selectedCutoffValue != null) {
                        selectedOption = selectedCutoffValue;
                    } else {
                        selectedOption = "0.000001";
                    }
                    onChange = "";
                    style = "";
                    optionHash = new LinkedHashMap();
                    optionHash.put("0.000001", "0.000001");
                    optionHash.put("0.0000001", "0.0000001");
                    optionHash.put("0.00000001", "0.00000001");
                    optionHash.put("0.000000001", "0.000000001");
                    optionHash.put("0.0000000001", "0.0000000001");
                %>
                <%@ include file="/web/common/selectBox.jsp" %>
                <%log.debug("after pval select");%>
                <BR>
                <BR>
                <strong>Genome Wide eQTLs:</strong>
                <select name="cisTrans" id="cisTrans">
                    <option value="cis" <%if(cisOnly.equals("cis")){%>selected<%}%>>Cis eQTLs Only</option>
                    <option value="all" <%if(cisOnly.equals("all")){%>selected<%}%>>Genome Wide</option>
                </select>
                <span class="eQTLListToolTip"
                      title="Display cis eQTLs only or genome wide eQTLs."><img
                        src="<%=imagesDir%>icons/info.gif"></span>
                <%log.debug("after cis select");%>
            </td>


            <td id="trxClusterCB" style="text-align:center;<%if(source.equals("seq")){%>display:none;<%}%>">
                <strong>Transcript Cluster ID:</strong>
                <span class="eQTLtooltip" title="On the Affymetrix Exon Array, gene level expression summaries are labeled as transcript clusters.
    Each gene may have more than one transcript cluster associated with it, due to differences in annotation among databases and therefore, differences in which individual exons (probe sets) are included in the transcript cluster.  <BR><BR>
    Transcript clusters given the designation of &ldquo;core&rdquo; are based on well-curated annotation on the gene.  
    &ldquo;Extended&rdquo; and &ldquo;full&rdquo; transcript clusters are based on gene properties that are less thoroughly curated and more putative, respectively.  
    Transcript clusters labeled as &ldquo;free&rdquo; or &ldquo;ambiguous&rdquo; have are highly putative for several reasons and therefore are only included in the drop-down menu if no other transcript clusters are available."><img
                        src="<%=imagesDir%>icons/info.gif"></span>
                <!--<div class="inpageHelp" style="display:inline-block;">
                <img id="Help9b" src="/web/images/icons/help.png"/>
                </div>-->

                <%
                    // Set up the select box:
                    selectName = "transcriptClusterID";
                    if (selectedTranscriptValue != null && !selectedTranscriptValue.equals("")) {
                        log.debug(" selected Transcript Value " + selectedTranscriptValue);
                        selectedOption = selectedTranscriptValue;
                    }
                    onChange = "";
                    style = "";
                    optionHash = new LinkedHashMap();
                    String transcriptClusterString = null;
                    if (transcriptClusterArray != null) {
                        for (int i = 0; i < transcriptClusterArray.length; i++) {

                            if (transcriptClusterArrayOrder[i] > -1) {


                                columns = transcriptClusterArray[transcriptClusterArrayOrder[i]].split("\t");
                                transcriptClusterString = transcriptClusterArray[transcriptClusterArrayOrder[i]];
                                String tmpGeneSym = "";
                                if (columns.length > 5) {
                                    tmpGeneSym = " (" + columns[5] + ")";
                                }
                                optionHash.put(transcriptClusterString, columns[0] + " " + columns[4] + tmpGeneSym);
                            }
                        }
                    }
                    //log.debug(" optionHash for Transcript Cluster ID: "+optionHash);

                %>
                <%@ include file="/web/common/selectBox.jsp" %>
            </td>

        </tr>
        <%log.debug("after trx select");%>
        <input type="hidden" id="hiddenGeneCentricPath" name="hiddenGeneCentricPath" value="<%=geneCentricPath%>"/>
        <input type="hidden" id="hiddenGeneSymbol" name="hiddenGeneSymbol" value="<%=geneSymbolinternal%>"/>

        <%log.debug("before chr select");%>
        <TR class="allowChromSelection">
            <%if (myOrganism.equals("Rn")) {%>
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

                                    for (int i = 0; i < numberOfTissues; i++) {
                                        tissueSelected = isNotSelectedText;
                                        if (selectedTissues != null) {
                                            for (int j = 0; j < selectedTissues.length; j++) {
                                                if (selectedTissues[j].equals(tissueNameArray[i])) {
                                                    tissueSelected = isSelectedText;
                                                }
                                            }
                                        }


                                %>

                                <option value="<%=tissueNameArray[i]%>" <%if(tissueNameArray[i].equals("Kidney")){%>disabled
                                        <%}else{%>selected<%}%>><%=tissuesList1[i]%>
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

                                    for (int i = 0; i < numberOfChromosomes; i++) {
                                        chromosomeSelected = isNotSelectedText;
                                        if (chromosomeDisplayArray[i].substring(4).equals(chromosome)) {
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

                                <option value="<%=chromosomeNameArray[i]%>" selected><%=chromosomeDisplayArray[i]%>
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
        <%log.debug("after chr select");%>
        <tr>

            <td colspan="3" style="text-align:center;">
                <INPUT TYPE="submit" NAME="action" id="clickToRunCircos" Value="Click to run Circos" onClick="return runCircos()" style="display:inline-block;">
                <div style="float: right;display:inline-block"><a href="http://genome.cshlp.org/content/early/2009/06/15/gr.092759.109.abstract" target="_blank"
                                                                  style="text-decoration: none">Circos: an Information Aesthetic for Comparative Genomics.</a>
                </div>
            </td>


        </tr>
        </tbody>
    </table>


    <BR>
    <BR/><BR/><BR/>


    <%
        } // end of if(transcriptError)
    %>


    <div id="wait2" align="center" style="position:relative;top:-50px;"><img src="<%=imagesDir%>wait.gif" alt="Working..." text-align="center">
        <BR/>Preparing to run Circos...
    </div>


    <script>
        document.getElementById("wait2").style.display = 'none';
    </script>
    <div style="position:relative;top:-50px;width:100%;"><h2><span id="typeLabel">RNA-Seq</span> Based Gene Level eQTLs</h2></div>
    <div id="forIframe" style="position:relative;top:-50px;width:100%;">
    </div>


</div>


<script>

    $(document).ready(function () {

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
            contentAsHTML: true,
            //arrow: false,
            interactive: true,
            interactiveTolerance: 350
        });
        setTimeout(function () {
            if ($('#transcriptClusterID').length === 1) {
                runCircos();
            } else if (source === "seq") {
                runCircos();
            }
            $('#circosIFrame').attr('width', $(window).width() - 50);
            $(window).resize(function () {
                $('#circosIFrame').attr('width', $(window).width() - 50);
            });
        }, 1500);


    });

</script>


 
