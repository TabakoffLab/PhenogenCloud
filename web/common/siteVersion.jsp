<%--
 *  Author: Cheryl Hornbaker
 *  Created: March, 2009
 *  Description:  The web page created by this file displays info on the versions the site is running.        
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/access/include/login_vars.jsp" %>
<%
    pageTitle = "Version";
    pageDescription = "Current website version and external software versions";
%>
<%@ include file="/web/common/header_adaptive_menu.jsp" %>


<div id="overview-content">
    <div id="welcome" style="height:845px; width:962px;padding-left: 10px;">
        <%@ include file="/web/common/siteVersion_content.jsp" %>
    </div>
</div>

<%@ include file="/web/common/footer_adaptive.jsp" %>
