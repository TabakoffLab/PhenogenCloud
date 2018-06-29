
<%--
 *  Author: Cheryl Hornbaker
 *  Created: June, 2004
 *  Description:  This file releases resources when a user logs out.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/common/session_vars.jsp" %>

<%
	log.info("In logout.jsp. user = " + user);
	actionForm =contextRoot + "index.jsp";
	formName = "logout.jsp";
	mySessionHandler.setSession_id(session.getId());
	mySessionHandler.logoutSession(pool);
	session.invalidate();
	loggedIn = false;
	response.sendRedirect(contextRoot+"index.jsp");
%>

