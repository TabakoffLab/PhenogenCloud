<%@ include file="/web/common/anon_session_vars.jsp" %>


<jsp:useBean id="gdt" class="edu.ucdenver.ccp.PhenoGen.tools.analysis.GeneDataTools" scope="session"> </jsp:useBean>

<%

	String myOrganism="Rn";
	String defaultGenomeVer="rn6";
	String id="";
	String chromosome="";
	String genomeVer="";
	
	String[] selectedLevels=null;
	String levelString="core;extended;full";
	String fullOrg="";
		String panel="";
	String gcPath="";
        String source="seq";
        String version="";
        String trxID="";
	int selectedGene=0;
	String transcriptome="ensembl";
	String cisOnly="all";
	ArrayList<String>geneSymbol=new ArrayList<String>();
	ArrayList<String>trxList=new ArrayList<String>();
	
	if(!gdt.isSessionSet()){
		gdt.setSession(session);
	}
	
	if(request.getParameter("levels")!=null && !request.getParameter("levels").equals("")){			
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
	if(request.getParameter("species")!=null){
		myOrganism=FilterInput.getFilteredInput(request.getParameter("species").trim());
		if(myOrganism.equals("Rn")){
			panel="BNLX/SHRH";
			fullOrg="Rattus_norvegicus";
			defaultGenomeVer="rn6";
		}else{
                    defaultGenomeVer="mm10";
                    panel="ILS/ISS";
                    fullOrg="Mus_musculus";
		}
	}
	if(request.getParameter("chromosome")!=null || request.getParameter("chromosome")!=""){
		chromosome=FilterInput.getFilteredInput(request.getParameter("chromosome"));
	}
	
		
	if(request.getParameter("geneSymbol")!=null){
		geneSymbol.add(FilterInput.getFilteredInput(request.getParameter("geneSymbol")));
	}else{
		geneSymbol.add("None");
	}
	if(request.getParameter("id")!=null){
		id=FilterInput.getFilteredInput(request.getParameter("id"));
	}
	if(request.getParameter("source")!=null){
		source=FilterInput.getFilteredInput(request.getParameter("source"));
	}

	if(request.getParameter("genomeVer")!=null){
		genomeVer=FilterInput.getFilteredInputGenomeVer(request.getParameter("genomeVer"));
		if(genomeVer.startsWith("rn")||genomeVer.startsWith("mm")){

		}else{
			genomeVer=defaultGenomeVer;
		}
	}
	if(request.getParameter("version")!=null){
		version=FilterInput.getFilteredInput(request.getParameter("version"));
	}
	if(request.getParameter("trxCB")!=null){
		trxID=FilterInput.getFilteredInput(request.getParameter("trxCB"));
	}
	if(request.getParameter("transcriptome")!=null){
		transcriptome=FilterInput.getFilteredInput(request.getParameter("transcriptome"));
	}
	if(request.getParameter("cisOnly")!=null){
		cisOnly=FilterInput.getFilteredInput(request.getParameter("cisOnly"));
	}

	if(source.equals("seq")) {
		trxList = gdt.getTranscriptList(id, myOrganism, "Merged", genomeVer,version);
	}

	gcPath=applicationRoot + contextRoot+"tmpData/browserCache/"+genomeVer+"/geneData/" +id+"/";
	
	String[] tissuesList1=new String[1];
	String[] tissuesList2=new String[1];
	if(myOrganism.equals("Rn")){
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
	int rnaDatasetID=0;
	int arrayTypeID=0;

	
	int[] tmp=gdt.getOrganismSpecificIdentifiers(myOrganism,genomeVer);
        if(tmp!=null&&tmp.length==2){
                rnaDatasetID=tmp[1];
                arrayTypeID=tmp[0];
        }
	ArrayList<edu.ucdenver.ccp.PhenoGen.data.Bio.Gene> tmpGeneList=gdt.getGeneCentricData(id,id,panel,myOrganism,genomeVer,rnaDatasetID,arrayTypeID,true);

	log.debug("OPENED GENE:"+id);

        //response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        //response.setDateHeader("Expires", 0);

        %>
<BR />

<%@ include file="/web/GeneCentric/geneEQTLPart.jsp" %>

<script type="text/javascript">
	$('#geneEQTL table#circosOptTbl').css("top","0px");
	$("span[name='circosOption']").css("margin-left","60px");
	//runCircos();
</script>


