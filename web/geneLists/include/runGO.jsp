<%@ include file="/web/common/anon_session_vars.jsp" %>
<jsp:useBean id="goT" class="edu.ucdenver.ccp.PhenoGen.tools.go.GOTools" scope="session"> </jsp:useBean>
<jsp:useBean id="gdt" class="edu.ucdenver.ccp.PhenoGen.tools.analysis.GeneDataTools" scope="session"> </jsp:useBean>
<jsp:useBean id="myGeneList" class="edu.ucdenver.ccp.PhenoGen.data.GeneList"/>
<jsp:useBean id="myGeneListAnalysis" class="edu.ucdenver.ccp.PhenoGen.data.GeneListAnalysis"/>
<jsp:useBean id="myParameterValue" class="edu.ucdenver.ccp.PhenoGen.data.ParameterValue"> </jsp:useBean>
<jsp:useBean id="anonU" class="edu.ucdenver.ccp.PhenoGen.data.AnonUser" scope="session" />
    
<%
        
	String myOrganism="";
	String fullOrg="";
	String id="";
	String result="";
	String name="";
        String genomeVer="";
    
	goT.setup(pool,session);
	if(userLoggedIn.getUser_name().equals("anon")){
            goT.setAnonUser(anonU);
        }
	
	if(request.getParameter("species")!=null){
		myOrganism=request.getParameter("species").trim();
		if(myOrganism.equals("Mm")){
			fullOrg="Mus_musculus";
		}else if(myOrganism.equals("Rn")){
			fullOrg="Rattus_norvegicus";
		}
	}
	
	if(request.getParameter("geneListID")!=null){
		id=request.getParameter("geneListID");
	}
	if(request.getParameter("name")!=null){
		name=request.getParameter("name");
	}
        if(request.getParameter("genomeVer")!=null){
		genomeVer=FilterInput.getFilteredInputGenomeVer(request.getParameter("genomeVer"));
	}
	
	String now = myObjectHandler.getNowAsMMddyyyy_HHmmss();
	java.sql.Timestamp timeNow = myObjectHandler.getNowAsTimestamp();
	
	int parameter_group_id = myParameterValue.createParameterGroup(pool);
        if(userID==-99 && userLoggedIn.getUser_name().equals("anon")){
            userID=-20;
        }
		
	myGeneListAnalysis.setGene_list_id(selectedGeneList.getGene_list_id());
	myGeneListAnalysis.setUser_id(userID);
	myGeneListAnalysis.setCreate_date(timeNow);
	myGeneListAnalysis.setAnalysis_type("GO");
	myGeneListAnalysis.setDescription(name+" \n Genome Version: "+genomeVer);
	myGeneListAnalysis.setAnalysisGeneList(selectedGeneList);
	myGeneListAnalysis.setVisible(1);
	myGeneListAnalysis.setStatus("Running");
	myGeneListAnalysis.setName(name);
	myGeneListAnalysis.setParameter_group_id(parameter_group_id);
		
	ParameterValue[] myParameterValues = new ParameterValue[2];
	for (int i=0; i<myParameterValues.length; i++) {
		myParameterValues[i] = new ParameterValue();
		myParameterValues[i].setCreate_date();
		myParameterValues[i].setParameter_group_id(parameter_group_id);
		myParameterValues[i].setCategory("GO");
	}
	myParameterValues[0].setParameter("Name");
	myParameterValues[0].setValue(name);
        myParameterValues[1].setParameter("Genome Version");
	myParameterValues[1].setValue(genomeVer);
	myGeneListAnalysis.setParameterValues(myParameterValues);
	int glaID=myGeneListAnalysis.createGeneListAnalysis(pool);
	
	mySessionHandler.createGeneListActivity("Ran GO on Gene List", pool);
	
	
	
	result=goT.runGOGeneList(selectedGeneList,myOrganism,genomeVer,name,glaID);
%>


<%=result%>