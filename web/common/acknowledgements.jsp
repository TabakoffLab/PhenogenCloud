<%--
 *  Author: Spencer Mahaffey
 *  Created: April, 2013
 *  Description:  The web page created by this file displays acknowledgements for the site and data.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/access/include/login_vars.jsp" %>

<% extrasList.add("normalize.css");
    extrasList.add("index.css");
%>

<%
    pageTitle = "Acknowledgements";
    pageDescription = "Acknowledgements for providing funding and resources";
%>

<%@ include file="/web/common/header_adaptive_menu.jsp" %>

<div id="overview-content" style="width: 98%;padding-left: 10px;">
    <div id="welcome" style="min-height:780px;">

        <%@ include file="/web/common/acknowledgement_content.jsp" %>

        <%@ include file="/web/common/footer_adaptive.jsp" %>
