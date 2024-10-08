<%--
 *  Author: Spencer Mahaffey
 *  Created: June, 2015
 *  Description:  Views GO term and starts an analysis pulling all GO terms from the ensembl DB.
 *  Todo: 
 *      
--%>
<%@ include file="/web/geneLists/include/geneListHeader.jsp"%>

<jsp:useBean id="thisIDecoderClient" class="edu.ucdenver.ccp.PhenoGen.tools.idecoder.IDecoderClient"> </jsp:useBean>
<jsp:useBean id="myEnsembl" class="edu.ucdenver.ccp.PhenoGen.data.external.Ensembl"> </jsp:useBean>

<%
    extrasList.add("datatables.1.10.21.min.js");
    //extrasList.add("jquery.dataTables.1.10.9.min.js");
        extrasList.add("d3.v4.8.0.min.js");
	log.info("in go.jsp. user = " + user);
	log.debug("action = " +action);
	request.setAttribute( "selectedTabId", "go" );
	optionsList.add("geneListDetails");
	optionsList.add("chooseNewGeneList");
        if(userLoggedIn.getUser_name().equals("anon")){
            optionsListModal.add("linkEmail");
        }
        
        
	String myOrganism=selectedGeneList.getOrganism();

        String id="";
	
	if(request.getParameter("geneListID")!=null){
		id=request.getParameter("geneListID");
	}


        String [] officialSymbolTargets = {"Gene Symbol"};
	String [] affyTargets = {"Affymetrix ID"};
	String [] chipTargets = {"Affymetrix ID", "CodeLink ID"};
	String [] eQTLTargets = {"Affymetrix ID", "CodeLink ID", "Gene Symbol"};

	String ucscOrganism = null;
	String snpOrganism = null;
	HashMap arrayInfo = null;
	Hashtable ensemblHash = new Hashtable();


	formName = "go.jsp";

        tall="100em";
	
%>
<%@ include file="/web/geneLists/include/geneListJS.jsp"  %>
<%@ include file="/web/common/header_adaptive_menu.jsp" %>


	<%@ include file="/web/geneLists/include/viewingPane.jsp" %>

        <div class="page-intro">
                <p> This page allows you to retrieve all GO terms assigned to gene in the selected gene list.  You can retrieve results from previous runs.</p>
        </div> <!-- // end page-intro -->
	<%@ include file="/web/geneLists/include/geneListToolsTabs.jsp" %>
	

	<%  if (selectedGeneList.getGene_list_id() != -99) { %>
        <div id="container">
        <div id="toolsAccord" style="text-align:left;">
                            <H2>Run New GO Analysis on Gene List</H2>

                            <div id="newAnalysis" style="font-size:12px;min-height: 80px;">
                                Save Results as: <BR>
                                <input id="name" type="text" size="30"/><BR>
                                <BR>
                                Genome Version to use:<BR>
                                <select id="genomeVer">
                                    <%if(myOrganism.equals("Rn")){%>
                                    	<option value="rn7">rn7</option>
                                        <option value="rn6">rn6</option>
                                        <option value="rn5">rn5</option>
                                    <%}else{%>
                                        <option value="mm10">mm10</option>
                                    <%}%>
                                </select>

                                <HR />
                                <input type="button" id="runBtn"  value="Run GO" onclick="runGO()"/><span id="runStatus"></span>
                            </div>
                            <H2>GO Results</H2>
                            <div id="resultsTable" style="min-height: 250px;">
                                <span style="font-size:10px;">Select a row below to view full results</span>
                                <div id="resultList">
                                </div>
                            </div>
                
            </div>
            <div id="topResultData">

                               <div id="resultLoading" style="display:none;width:100%;text-align:center;">
                                       <img src="<%=imagesDir%>wait.gif" alt="Loading Results..." text-align="center" ><BR />Loading Results...
                               </div>
                               <div id="goResult" style="width:100%;text-align: left;">
                                   <H2>Results</H2>
                                  Select previous results from the GO Results section at the left or enter new parameters on the left or top to run a GO analysis.<BR />
                               </div>

            </div>
        </div>
          <div id="dialog-delete-confirm" title="Permanently Delete this analysis?">
            <p><span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 20px 0;"></span>This analysis will be permanently deleted and cannot be recovered. Are you sure?</p>
        </div>
        <div id="dialog-delete-error" title="Error">
            <p>
                The analysis was not deleted see error below.
            </p>
            <p>
                <span id="delete-errmsg" style="color:#FF0000;"></span>
            </p>
        </div>
	<% } %>
 
	<%@ include file="/web/geneLists/include/setupJS.jsp" %>
	<script type="text/javascript">
        $("div#wait1").hide();
                var goBrwsr=0;
                var idToDelete=-99;
                var analysisPath="include/getGOAnalyses.jsp";
		$(document).ready(function() {
			setTimeout("setupMain()", 100); 
			setupExpandCollapse();
			runGetResults(-1);
			$(".gotooltip").tooltipster({
				position: 'top-left',
				maxWidth: 350,
				offsetX: -10,
				offsetY: 5,
				contentAsHTML:true,
				//arrow: false,
				interactive: true,
				interactiveTolerance: 350
			});
                        $( "#dialog-delete-confirm" ).dialog({
                                  autoOpen: false,
                                  resizable: false,
                                  height:175,
                                  width:"40%",
                                  modal: true,
                                  buttons: {
                                    "Delete analysis": function() {
                                      $( this ).dialog( "close" );
                                      runDeleteGeneListAnalysis(idToDelete);
                                      idToDelete=-99;
                                    },
                                    Cancel: function() {
                                      $( this ).dialog( "close" );
                                      idToDelete=-99;
                                    }
                                  }
                        });
                        $( "#dialog-delete-error" ).dialog({
                          autoOpen: false,
                          modal: true,
                          width:"40%",
                          buttons: {
                            Ok: function() {
                              $( this ).dialog( "close" );
                            }
                          }
                        });
		});
		
		
		
		function runGO(){
			var species="<%=myOrganism%>";
			var id=<%=selectedGeneList.getGene_list_id()%>;
			var name=$('input#name').val();
                        var selGV=$('select#genomeVer').val();
			$('#wait2').show();
			$('#runStatus').html("");
			$.ajax({
				url: "/web/geneLists/include/runGO.jsp",
   				type: 'GET',
				data: {species:species,geneListID:id,name:name,genomeVer:selGV},
				dataType: 'html',
				beforeSend: function(){
					$('#runStatus').html("Submitting...");
				},
				complete: function(){
					$('#runStatus').show();
					setTimeout(function (){
						$('#runStatus').html("");
					},20000);
					runGetResults(0);
					$('input#name').val("");
				},
    			success: function(data2){ 
        			$('#runStatus').html(data2);
    			},
    			error: function(xhr, status, error) {
        			$('#runStatus').html("An error occurred Try submitting again. Error:"+error);
    			}
			});
		}
		
		
</script>

<script src="<%=contextRoot%>javascript/goBrowser1.2.0.js" type="text/javascript"></script>
<%@ include file="/web/common/footer_adaptive.jsp" %>
