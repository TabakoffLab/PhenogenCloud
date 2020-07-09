<%--
 *  Author: Spencer Mahaffey
 *  Created: Jan, 2020
 *  Description:  This file takes the input from an ajax request and returns a json object with genes.
 *
 *  Todo:
 *  Modification Log:
 *
--%>

<%@ page language="java" %>
<%@ include file="/web/common/anon_session_vars.jsp"  %>
<jsp:useBean id="gdt" class="edu.ucdenver.ccp.PhenoGen.tools.analysis.GeneDataTools" scope="session"> </jsp:useBean>
<jsp:useBean id="bt" class="edu.ucdenver.ccp.PhenoGen.tools.analysis.BrowserTools" scope="session"> </jsp:useBean>

<%
    String trackString="";
    String genomeVer="rn6";
    int viewID=-1;
    int dsVer=0;
    String viewName="";
    String assocEmail="";
    String countDefault="total";
    String strainList="";
    int tmpuserID=-1;

    bt.setSession(session);

    if(userLoggedIn!=null){
        tmpuserID=userLoggedIn.getUser_id();
    }
    if(request.getParameter("tracks")!=null){
        trackString=FilterInput.getFilteredInput(request.getParameter("tracks"));
    }
    if(request.getParameter("genomeVer")!=null){
        genomeVer=FilterInput.getFilteredInput(request.getParameter("genomeVer"));
    }
    if(request.getParameter("version")!=null){
        dsVer=Integer.parseInt(FilterInput.getFilteredInput(request.getParameter("version")));
    }
    if(request.getParameter("viewID")!=null){
        viewID=Integer.parseInt(FilterInput.getFilteredInput(request.getParameter("viewID")));
    }
    if(request.getParameter("name")!=null){
        viewName=FilterInput.getFilteredInput(request.getParameter("name"));
    }
    if(request.getParameter("email")!=null){
        assocEmail=FilterInput.getFilteredInput(request.getParameter("email"));
    }
    if(request.getParameter("countDefault")!=null){
        countDefault=FilterInput.getFilteredInput(request.getParameter("countDefault"));
    }
    if(request.getParameter("countStrains")!=null){
        strainList=FilterInput.getFilteredInput(request.getParameter("countStrains"));
    }
    //getCurrentView
    boolean updated=bt.editCustomView(trackString,viewID,tmpuserID,viewName,assocEmail,genomeVer,dsVer,countDefault,strainList);
    response.setContentType("application/json");
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setDateHeader("Expires", 0);
%>
{"Success":"<%=updated%>"}