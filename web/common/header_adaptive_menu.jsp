<%@ include file="adaptive_headTags.jsp" %>
	<body style="min-width:980px;text-align:center;" class="noPrint">
	<style>
		.search{
			position:relative;
			top:-16px;
		}
	</style>

		<%@ include file="/web/common/menu.jsp"%>

		<div id="body_wrapper_plain">
		<div id="main_body_plain" >
			<div id="wait1" style="background:#FFFFFF;"><img src="<%=imagesDir%>wait.gif" alt="Working..."/><BR/>Working...Genes
				should load within 5-10 seconds. Regions depend on the size(ex. 10 Megabases may take ~1 minute).
			</div>

	<%@ include file="/web/common/alertMsgDisplay.jsp"  %>
	<%@ include file="/web/common/toolbarStuff.jsp" %>

