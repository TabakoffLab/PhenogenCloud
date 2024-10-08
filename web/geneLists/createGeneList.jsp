<%--
 *  Author: Cheryl Hornbaker
 *  Created: Mar, 2009
 *  Description:  The web page created by this file allows the user to either manually input 
 *		genes or upload a file to create a gene list 
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<%@ include file="/web/geneLists/include/geneListHeader.jsp"%>
<jsp:useBean id="anonU" class="edu.ucdenver.ccp.PhenoGen.data.AnonUser" scope="session" />
<%
        log.debug("after header in createGeneList");
	log.info("in createGeneList.jsp. user = " + user);
	if (userLoggedIn.getUser_name().equals("anon")) {
		log.debug("\nCREATE GENELIST.jsp anon user:" + anonU.getUUID());
	}

	boolean fromMain = (request.getParameter("fromMain") != null);
	extrasList.add("createGeneList.js");
        
	GeneList[] myGeneLists = new GeneList[0];
        if(! userLoggedIn.getUser_name().equals("anon")){
                myGeneLists = myGeneList.getGeneLists(userLoggedIn.getUser_id(), "All", "All", pool);
        }else if (userLoggedIn.getUser_name().equals("guest")) {
                //Error - "Feature not allowed for guests"
                session.setAttribute("errorMsg", "GST-004");
                response.sendRedirect(commonDir + "errorMsg.jsp");
        }else{
                myGeneLists = myAnonGeneList.getGeneLists(anonU.getUUID(), "All", pool);
        }
        myGeneLists = myGeneList.sortGeneLists(myGeneLists, "geneListName", "A");

        
        fieldNames.add("gene_list_name");
        fieldNames.add("organism");
        fieldNames.add("description");
        fieldNames.add("inputGeneList");
        fieldNames.add("filename");

	mySessionHandler.createSessionActivity(session.getId(), "On create genelist page", pool);
        log.debug("top");
%>
	<%@ include file="/web/geneLists/include/geneListJS.jsp"  %>
	<% if (fromMain) { %>
    	<%pageTitle="Create gene list";%>
                
		<%@ include file="/web/common/header_adaptive_menu.jsp" %>
	<% } else { %>
        
		<%@ include file="/web/common/includeExtras.jsp" %>
	<% } 
        log.debug("after includeExtras.jsp");%>
        <!--  
	most of the form processing is done in createGeneList2.jsp
	because this is a multi-part form 
	--> 
	<BR>
	<div style="margin-left: 20px"><h2>Create a New Gene List</h2></div>

	<form   name="createGeneList" 
        	method="post" 
        	onSubmit="return IsCreateGeneListFormComplete()" 
        	action="createGeneList2.jsp" 
        	enctype="multipart/form-data">

		<div class="page-intro">
			<p>Step 1. Name the gene list and provide a description of it. 
			</p>
		</div> <!-- // end page-intro -->
		<div class="brClear"></div>
		<table style="margin-left:70px">
		<tr>
			<td valign="top"> <strong>Name your gene list:</strong> </td>
			<td> <input type="text" name="gene_list_name" size="30" tabindex="1"> </td>

		</tr> <tr>
			<td> <strong>Organism:</strong> </td>
			<td>
			<%
                            log.debug("before org");
			selectName = "organism";
			selectedOption = "";
			onChange = "";
			tabindex="2";

			optionHash = new LinkedHashMap();
			optionHash.put("-99", "-- Select an option --");
			optionHash.putAll(new Organism().getOrganismsAsSelectOptions(pool));
                        log.debug("after org");
			%>
                	<%@ include file="/web/common/selectBox.jsp" %>
			</td>
		</tr> <tr>
			<td> <strong>Gene List Description:</strong> </td>
			<td> <textarea  name="description" cols="35" rows="5" tabindex="3"></textarea> </td>
		</tr>
		</table>
		<div class="page-intro">
			<p>Step 2. Choose whether you are going to upload a file containing the gene identifiers, enter the list manually, or copy 
			an existing list and make changes to it.
			<strong>Note that gene identifiers are case-sensitive!</strong></p>
		</div> <!-- // end page-intro -->
		<div class="brClear"></div>

                <div id="choice_div">
                        <table style="margin-left:70px" >
                        <tr>
                                <td>
                                <%
                                optionHash = new LinkedHashMap();
                                optionHash.put("upload", "Upload Gene List File"+ twentyFiveSpaces);
                                optionHash.put("new", "Enter Gene Identifiers"+ twentyFiveSpaces);
                                optionHash.put("copy", "Copy Existing Gene List");

                                radioName = "choice";
                                selectedOption = "new";
                                onClick = "showGeneListFields()";
                                %>
                                <%@ include file="/web/common/radio.jsp" %>
                                </td>
                        </tr>
                        </table>
                </div>

                <div id="upload_div">
                        <p style="margin:10px 70px;"><strong>Note:</strong> The gene list file should be a text file
                         with no column headers and one gene identifier per line.   <BR><BR>
                                <strong>File Name :</strong>
                                <input type="file" name="filename" size="20">
                        </p>
                </div>

		<div class="brClear"></div>

                <div id="copyGeneLists">
                        <h2 style="margin:10px 10px 0px 70px">Copy gene list from:</h2>
                        <table style="margin-left:70px">
                                <%
                                    log.debug("before copy");
                                selectName = "copyFromID";
                                selectedOption = "None";
                                onChange = "displayGeneList()";

                                optionHash = new LinkedHashMap();
                                optionHash.put("None", "-- Select a gene list --");

				for (int i=0; i<myGeneLists.length; i++) {
                                	optionHash.put(Integer.toString(myGeneLists[i].getGene_list_id()),
                                        		myGeneLists[i].getGene_list_name() + 
                                        		" (" + 
							myGeneLists[i].getNumber_of_genes() + " " + 
							myGeneLists[i].getOrganism() + 
							(myGeneLists[i].getNumber_of_genes() == 1 ? " gene)" :
							" genes)"));
				}
                                log.debug("after copy");
                                %>
                                <tr> <td> <%@ include file="/web/common/selectBox.jsp" %> </td></tr>
                        </table>
                </div>

		<div class="brClear"></div>

		<div id="enterList" style="margin:10px 0px 10px 70px">Enter identifiers below(1 per line):</div>
		<div id="whatToDo" style="margin:10px 0px 10px 70px">Add or remove identifiers from the list below:</div>
                <div id="new_div" style="margin-left:70px;"> 
		<textarea name="inputGeneList" rows="10" cols="40"><%=(String)fieldValues.get("inputGeneList")%></textarea> 
		</div>

		<div class="page-intro">
			<p>Step 3. Save the data.  </p>
		</div> <!-- // end page-intro -->

		<div class="brClear"></div>

	<div style="margin-left:100px">
	<input type="reset" value="Reset"> <%=tenSpaces%>
	<input type="submit" name="action" value="Create Gene List">
	</div>
	<BR> <BR>
	<input type="hidden" name="fromMain" value="<%=fromMain%>">
</form>
        <%log.debug("end form");%>
	<% if (fromMain) { %>
		<%@ include file="/web/common/footer_adaptive.jsp" %>
	<% } %>
	<script type="text/javascript">
		$(document).ready(function() {
			setupCreateGeneListPage();
			showGeneListFields();
			document.createGeneList.gene_list_name.focus();
		});
	</script> 
