


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
String id="",chromosome="",organism="",genomeVer="";
int min=0,max=0,rnaDatasetID=0,arrayTypeID=0;
if(request.getParameter("chromosome")!=null){
		chromosome=FilterInput.getFilteredInput(request.getParameter("chromosome").trim());
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
if(request.getParameter("id")!=null){
	id=FilterInput.getFilteredInput(request.getParameter("id").trim());
}
if(request.getParameter("organism")!=null){
	organism=FilterInput.getFilteredInput(request.getParameter("organism").trim());
}
if(request.getParameter("genomeVer")!=null){
	genomeVer=FilterInput.getFilteredInputGenomeVer(request.getParameter("genomeVer"));
}
%>


<% 
	boolean error1=gdt.callWriteXML(id,organism,genomeVer,chromosome,min,max,arrayTypeID,rnaDatasetID);
	//boolean error2=gdt.callPanelExpr(id,chromosome,min,max,genomeVer,arrayTypeID,rnaDatasetID,null);
	JSONObject genejson;
	genejson = new JSONObject();
    genejson.put("success" , error1&&error2);
	response.setContentType("application/json");
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setDateHeader("Expires", 0);
	response.getWriter().write(genejson.toString());
%>





