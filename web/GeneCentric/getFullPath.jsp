


<%--
 *  Author: Spencer Mahaffey
 *  Created: May, 2013
 *  Description:  This file takes the input from an ajax request and returns a json object with genes.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ page language="java"
import="org.json.*" %>

<%@ include file="/web/common/anon_session_vars.jsp"  %>

<jsp:useBean id="gdt" class="edu.ucdenver.ccp.PhenoGen.tools.analysis.GeneDataTools" scope="session"> </jsp:useBean>


<%
gdt.setSession(session);
String chromosome="",panel="",myOrganism="Rn",genomeVer="",dataVer="";
int min=0,max=0,rnaDatasetID=0,arrayTypeID=0;
double forwardPValueCutoff=0;
if(request.getParameter("chromosome")!=null){
		chromosome=request.getParameter("chromosome").trim();
}
if(request.getParameter("minCoord")!=null){
	try{
		min=Integer.parseInt(request.getParameter("minCoord").trim());
	}catch(NumberFormatException e){
		log.error("Number format exception:Min\n",e);
	}
}
if(request.getParameter("maxCoord")!=null){
	try{
		max=Integer.parseInt(request.getParameter("maxCoord").trim());
	}catch(NumberFormatException e){
		log.error("Number format exception:Max\n",e);
	}
}
if(request.getParameter("panel")!=null){
		panel=request.getParameter("panel").trim();
}
if(request.getParameter("myOrganism")!=null){
		myOrganism=request.getParameter("myOrganism").trim();
}
if(request.getParameter("rnaDatasetID")!=null){
	try{
		rnaDatasetID=Integer.parseInt(request.getParameter("rnaDatasetID").trim());
	}catch(NumberFormatException e){
		log.error("Number format exception:rnaDatasetID\n",e);
	}
}
if(request.getParameter("arrayTypeID")!=null){
	try{
		arrayTypeID=Integer.parseInt(request.getParameter("arrayTypeID").trim());
	}catch(NumberFormatException e){
		log.error("Number format exception:arrayTypeID\n",e);
	}
}
if(request.getParameter("forwardPValueCutoff")!=null){
	try{
		forwardPValueCutoff=Double.parseDouble(request.getParameter("forwardPValueCutoff").trim());
	}catch(NumberFormatException e){
		log.error("Number format exception:forwardPValueCutoff\n",e);
	}
}

if(request.getParameter("genomeVer")!=null){
    genomeVer=FilterInput.getFilteredInputGenomeVer(request.getParameter("genomeVer"));
}

if(request.getParameter("dataVer")!=null){
    dataVer=FilterInput.getFilteredInput(request.getParameter("dataVer"));
}

%>


<% 
	String tmpOutput=gdt.getImageRegionData(chromosome,min,max,panel,myOrganism,genomeVer,rnaDatasetID,arrayTypeID,forwardPValueCutoff,false,dataVer);
	String foldername=chromosome+"/img_"+min+"_"+max;
	JSONObject genejson;
	genejson = new JSONObject();
        genejson.put("folderName" , foldername);
	response.setContentType("application/json");
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setDateHeader("Expires", 0);
	response.getWriter().write(genejson.toString());
%>





