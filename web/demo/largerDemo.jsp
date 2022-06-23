<%@ include file="/web/access/include/login_vars.jsp" %>


<%@ include file="/web/common/header_adaptive_noMenu.jsp" %>

<%
    String mainFilePart = "web/demo/detailed_transcript_fullv3";
    if (request.getParameter("demoPath") != null) {
        mainFilePart = FilterInput.getFilteredURLInput(request.getParameter("demoPath"));
    }
%>

<div style="text-align:center;">
    <video width="95%" controls="controls">
        <source src="<%=mainFilePart%>.mp4" type="video/mp4">
        <source src="<%=mainFilePart%>.webm" type="video/webm">
        <object data="<%=mainFilePart%>.mp4" width="95%" height="95%">
        </object>
    </video>
    <BR><BR><BR><BR>
</div>
<%@ include file="/web/common/footer_adaptive.jsp" %>

 
