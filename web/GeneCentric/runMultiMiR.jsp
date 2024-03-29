<%@ include file="/web/common/anon_session_vars.jsp" %>
<jsp:useBean id="miRT" class="edu.ucdenver.ccp.PhenoGen.tools.mir.MiRTools" scope="session"> </jsp:useBean>

<style>
	table#mirTbl tr.selected td{
		background:	#67e667;
	}
</style>

<%

	String myOrganism="";
	String fullOrg="";
	String id="";
	String table="all";
	String predType="p";
	int cutoff=20;
	
	String [][] validated=new String[3][3];
	validated[0][0]="mirecords";
	validated[0][1]="miRecords";
	validated[0][2]="http://mirecords.biolead.org/download.php";
	validated[1][0]="mirtarbase";
	validated[1][1]="miRTarBase";
	validated[1][2]="http://mirtarbase.mbc.nctu.edu.tw/php/download.php";
	validated[2][0]="tarbase";
	validated[2][1]="TarBase";
	validated[2][2]="http://diana.imis.athena-innovation.gr/DianaTools/index.php?r=tarbase/index";
	String [][] predicted=new String[8][3];
	predicted[0][0]="diana_microt";
	predicted[0][1]="DIANA-microT-CDS";
	predicted[0][2]="http://diana.cslab.ece.ntua.gr/data/public/";
	predicted[1][0]="elmmo";
	predicted[1][1]="ElMMo";
	predicted[1][2]="http://www.mirz.unibas.ch/miRNAtargetPredictionBulk.php";
	predicted[2][0]="microcosm";
	predicted[2][1]="MicroCosm";
	predicted[2][2]="http://www.ebi.ac.uk/enright-srv/microcosm/cgi-bin/targets/v5/download.pl";
	predicted[3][0]="miranda";
	predicted[3][1]="miRanda";
	predicted[3][2]="http://www.microrna.org/microrna/getDownloads.do";
	predicted[4][0]="mirdb";
	predicted[4][1]="miRDB";
	predicted[4][2]="http://mirdb.org/miRDB/";
	predicted[5][0]="pictar";
	predicted[5][1]="PicTar";
	predicted[5][2]="http://dorina.mdc-berlin.de/rbp_browser/dorina.html";
	predicted[6][0]="pita";
	predicted[6][1]="PITA";
	predicted[6][2]="http://genie.weizmann.ac.il/pubs/mir07/mir07_data.html";
	predicted[7][0]="targetscan";
	predicted[7][1]="TargetScan";
	predicted[7][2]="http://www.targetscan.org/cgi-bin/targetscan/data_download.cgi?db=vert_61";
	/*String [][] disease=new String[3][3];
	disease[0][0]="mir2disease";
	disease[0][1]="mir2disease";
	disease[0][2]="mir2disease";
	disease[1][0]="pharmaco_mir";
	disease[1][1]="pharmaco_mir";
	disease[1][2]="pharmaco_mir";
	disease[2][0]="phenomir";
	disease[2][1]="phenomir";
	disease[2][2]="phenomir";*/
	String[][] total=new String[3][2];
	total[0][0]="validated.sum";
	total[0][1]="Total Validated";
	total[1][0]="predicted.sum";
	total[1][1]="Total Predicted";
	total[2][0]="all.sum";
	total[2][1]="Total All";
	
	LinkGenerator lg=new LinkGenerator(session);
	
	miRT.setup(pool,session);
	
	ArrayList<MiRResult> mirList=new ArrayList<MiRResult>();
	
	if(request.getParameter("species")!=null){
		myOrganism=request.getParameter("species").trim();
		if(myOrganism.equals("Mm")){
			fullOrg="Mus_musculus";
		}else if(myOrganism.equals("Rn")){
			fullOrg="Rattus_norvegicus";
		}
	}
	
	if(request.getParameter("id")!=null){
		id=request.getParameter("id");
	}
	
	if(request.getParameter("table")!=null){
		table=request.getParameter("table");
	}
	
	if(request.getParameter("predType")!=null){
		predType=request.getParameter("predType");
	}
	if(request.getParameter("cutoff")!=null){
		cutoff=Integer.parseInt(request.getParameter("cutoff"));
	}
	
	mirList=miRT.getMirTargetingGene(myOrganism,id,table,predType,cutoff);
%>
<div style="text-align:center;">
		
	<%
		if(mirList.size()>0){
		MiRResult firstMir=mirList.get(0);
	%>
    <div style="font-size:18px; font-weight:bold;width:100%; text-align:left;">
    	Target Information
	</div>
	<div >
    	<table style="text-align:center;width:100%;">
        <tbody>
        	<TR>
            	<TD style="font-size:16px;"> Gene Symbol: <%=firstMir.getTargetSym()%></TD>
                <TD style="font-size:16px;"> Gene Entrez ID: <a href="http://www.ncbi.nlm.nih.gov/gene/?term=<%=firstMir.getTargetEntrez()%>" target="_blank"><%=firstMir.getTargetEntrez()%></a></TD>
                <TD style="font-size:16px;"> Gene Ensembl ID: <a href="<%=LinkGenerator.getEnsemblLinkEnsemblID(firstMir.getTargetEnsembl(),fullOrg)%>" target="_blank" title="View Ensembl Gene Details"><%=firstMir.getTargetEnsembl()%></a></TD>
            </TR>
        </tbody>
        </table>
    </div>
    <BR />
    <%}%>
    <div style="font-size:18px; font-weight:bold;width:100%; text-align:left;">
    	multiMiR Results
	</div>
<table id="mirTbl" name="items" class="list_base" style="text-align:center;width:100%;">
	<%if(mirList.size()>0){
		Set sourceKey=mirList.get(0).getSourceCount().keySet();
		%>
        <thead>
        	<TR class="col_title">
            	<TH colspan="2"></TH>
                <TH colspan="3" style="color:#000000;">Validated</TH>
                <TH colspan="8" style="color:#000000;">Predicted</TH>
                <TH colspan="3" style="color:#000000;">Total</TH>
            </TR>
        	<TR class="col_title">
            <TH style="color:#000000;">Mature miRNA Accession <span class="mirtooltip2"  title="Click to view miRBase page for the miRNA."><img src="<%=imagesDir%>icons/info.gif"></span><BR />(click for miRBase)</TH>
            <TH style="color:#000000;">Mature miRNA ID <span class="mirtooltip2"  title="Click to view additional informat on validated/predicted results and all genes targeted by miRNA."><img src="<%=imagesDir%>icons/info.gif"></span><BR />(click to view details)</TH>
            <!--<TH style="color:#000000;">Target Gene Symbol</TH>
            <TH style="color:#000000;">Target Entrez ID</TH>
            <TH style="color:#000000;">Target Ensembl ID</TH>-->
            
            <%for(int i=0;i<validated.length;i++){%>
            	<TH><a href="<%=validated[i][2]%>" target="_blank"><%=validated[i][1]%></a></TH>
                
            <%}%>
            <%for(int i=0;i<predicted.length;i++){%>
            	<TH><a href="<%=predicted[i][2]%>" target="_blank"><%=predicted[i][1]%></a></TH>
            <%}%>
             <%	for(int i=0;i<total.length;i++){%>
            	<TH style="color:#000000;"><%=total[i][1]%></TH>
                
            <%}%>
           	</TR>
        </thead>
        
        <tbody>
        <%for (int i=0;i<mirList.size();i++){
            MiRResult tmp=mirList.get(i);
            HashMap tmpSC=tmp.getSourceCount();
            String rowID=tmp.getAccession();
            if(tmp.getAccession().equals("")){
                    rowID=tmp.getId();
            }
			%>
                <TR class="<%=rowID.replace("*","")%>">
                <TD>
                    <%if(tmp.getAccession().equals("")){%>
                            <a href="http://www.mirbase.org/cgi-bin/query.pl?terms=<%=tmp.getId().replace("*","")%>" target="_blank" title="Link to miRBase.">Accession # Missing</a>
                                    <%}else{%>
                            <a href="http://www.mirbase.org/cgi-bin/mature.pl?mature_acc=<%=tmp.getAccession()%>" target="_blank" title="Link to miRBase."><%=tmp.getAccession()%></a>
                    <%}%>
                </TD>
                <TD><span id="mirDetail<%=rowID%>" class="mirViewDetail" style="cursor:pointer; text-decoration:underline; color:688eb3;"><%=tmp.getId()%></span></TD>
                <%	for(int j=0;j<validated.length;j++){
                                            if(sourceKey.contains(validated[j][0])){
                                                    String x="-";
                                                    int count=Integer.parseInt((String) tmpSC.get(validated[j][0]));
                                                    if(count>0){
                                                            x="X";
                                                    }
                            %>
                                    <TD><%=x%></TD>

                <%		}else{%>
                                    <TD>-</TD>
                            <%}%>
                            <%	}%>
                <%	for(int j=0;j<predicted.length;j++){
                                            if(sourceKey.contains(predicted[j][0])){
                                                    String x="-";
                                                    int count=Integer.parseInt((String) tmpSC.get(predicted[j][0]));
                                                    if(count>0){
                                                            x="X";
                                                    }
                            %>
                                    <TD><%=x%></TD>

                <%		}else{%>
                                    <TD>-</TD>
                            <%}%>
                            <%	}%>
                 <%	for(int j=0;j<total.length;j++){
                                            if(sourceKey.contains(total[j][0])){

                            %>
                                    <TD><%=tmpSC.get(total[j][0])%></TD>

                <%		}else{%>
                            <TD>0</TD>
                            <%}%>
                            <%	}%>
                </TR>
            <%}%>
        </tbody>
	<%}else{%>
    	<tbody>
        <TR><TD>No results to display for this gene.</TD>
        </TR>
    	</tbody>
    <%}%>
</table>
</div>

<div id="mirDetailedView">

</div>
 
<script type="text/javascript">
	//var rows=$("table#mirTbl tr");
	//stripeTable(rows);
	
	$(".mirtooltip2").tooltipster({
				position: 'top-right',
				maxWidth: 250,
				offsetX: 10,
				offsetY: 5,
				contentAsHTML:true,
				//arrow: false,
				interactive: true,
				interactiveTolerance: 350
			});
	<%if(mirList.size()>0){%>
            var tblMir=$('#mirTbl').DataTable({
                            bPaginate: false,
                            //"sScrollX": "100%",
                            //"sScrollY": "350px",
                            bDeferRender: true,
                            aaSorting: [[ 15, "desc" ]],
                            sDom: '<"leftSearch"fr><t><i>'
            });
	<%}%>
	/*tblMir.fnAdjustColumnSizing();
	tblMir.draw();*/
	
	$('span.mirViewDetail').on('click',function(){
			var species="<%=myOrganism%>";
			var id="<%=id%>";
			var table="<%=table%>";
			var predType="<%=predType%>";
			var cutoff=<%=cutoff%>;
			var selectedID=(new String($(this).attr("id"))).substr(9);
			$('#mirDetailedView').html("<div id=\"wait3\" align=\"center\" style=\"position:relative;top:0px;\"><img src=\"<%=imagesDir%>wait.gif\" alt=\"Working...\" text-align=\"center\" ><BR />Running multiMiR to find genes targeted by "+selectedID+" (this will take a little longer)...</div>");
			$('html, body').animate({
				scrollTop: $( '#mirDetailedView' ).offset().top
			}, 200);
			$('table#mirTbl tr.selected').removeClass("selected");
			$('table#mirTbl tr.'+selectedID).addClass("selected");
			//$('#wait2').show();
			$.ajax({
				url:  "/web/GeneCentric/runMultiMiRDetail.jsp",
   				type: 'GET',
				data: {species:species,id:id,table:table,predType:predType,cutoff:cutoff,selectedID:selectedID},
				dataType: 'html',
				complete: function(){
					//$('#imgLoad').hide();
					//$('#wait2').hide();
					$('#mirDetailedView').show();
				},
    			success: function(data2){ 
        			$('#mirDetailedView').html(data2);
    			},
    			error: function(xhr, status, error) {
        			$('#mirDetailedView').html("<div>An error occurred generating this image.  Please try back later.</div>");
    			}
			});
	});
	
</script>