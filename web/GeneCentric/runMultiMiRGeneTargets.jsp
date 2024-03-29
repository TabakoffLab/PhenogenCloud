<%@ include file="/web/common/anon_session_vars.jsp" %>
<jsp:useBean id="miRT" class="edu.ucdenver.ccp.PhenoGen.tools.mir.MiRTools" scope="session"> </jsp:useBean>
<%

	String myOrganism="";
	String fullOrg="";
	String id="";
	String table="all";
	String predType="p";
	int cutoff=5;
	String selectedID="";
	
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
	ArrayList<MiRResult> targetList=new ArrayList<MiRResult>();
	
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
	if(request.getParameter("selectedID")!=null){
		selectedID=request.getParameter("selectedID");
	}
	if(request.getParameter("cutoff")!=null){
		cutoff=Integer.parseInt(request.getParameter("cutoff"));
	}
	targetList=miRT.getGenesTargetedByMir(myOrganism,selectedID,table,predType,cutoff);
%>
<BR /><BR />
<div style="text-align:center;">	
        <div><div style="text-align:left;font-size:18px; font-weight:bold;width:100%;"> All Genes Targeted by <%=selectedID%></div><BR />
              <table id="mirGeneTbl" name="items" class="list_base" style="text-align:center;width:100%;">
					
                        <thead>
                            <TR class="col_title">
                                <TH colspan="5"></TH>
                                <TH colspan="3" style="color:#000000;">Validated</TH>
                                <TH colspan="8" style="color:#000000;">Predicted</TH>
                                <TH colspan="3" style="color:#000000;">Total</TH>
                            </TR>
                            <TR class="col_title">
                            <TH style="color:#000000;">Mature miRNA Accession</TH>
                            <TH style="color:#000000;">Mature miRNA ID</TH>
                            <TH style="color:#000000;">Target Gene Symbol</TH>
                            <TH style="color:#000000;">Target Entrez ID</TH>
                            <TH style="color:#000000;">Target Ensembl ID</TH>
                            
                            <%for(int i=0;i<validated.length;i++){         
                            %>
                                        <TH><a href="<%=validated[i][2]%>" target="_blank"><%=validated[i][1]%></a></TH>
                                
                            <%}%>
                            <%	for(int i=0;i<predicted.length;i++){
                            %>
                                        <TH><a href="<%=predicted[i][2]%>" target="_blank"><%=predicted[i][1]%></a></TH>
                                
                            <%}%>
                             <%	for(int i=0;i<total.length;i++){
                             %>
                                		<TH style="color:#000000;"><%=total[i][1]%></TH>
                                
                            <%}%>
                            </TR>
                        </thead>
                        
                        <tbody>
                        <%if(targetList.size()>0){
                        Set sourceKey=targetList.get(0).getSourceCount().keySet();
                        %>
                        <%for (int i=0;i<targetList.size();i++){
                            MiRResult tmp=targetList.get(i);
                            HashMap tmpSC=tmp.getSourceCount();
                            %>
                            <TR>
                            <TD><a href="http://www.mirbase.org/cgi-bin/mature.pl?mature_acc=<%=tmp.getAccession()%>" target="_blank" title="Link to miRBase."><%=tmp.getAccession()%></a></TD>
                            <TD><%=tmp.getId()%></TD>
                            <TD><%=tmp.getTargetSym()%></TD>
                            <TD><a href="http://www.ncbi.nlm.nih.gov/gene/?term=<%=tmp.getTargetEntrez()%>" target="_blank"><%=tmp.getTargetEntrez()%></a></TD>
                            <TD><a href="<%=LinkGenerator.getEnsemblLinkEnsemblID(tmp.getTargetEnsembl(),fullOrg)%>" target="_blank" title="View Ensembl Gene Details"><%=tmp.getTargetEnsembl()%></a></TD>
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
                            <% 	}%>
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
                            <%    }%>
                             <%	for(int j=0;j<total.length;j++){
                                    if(sourceKey.contains(total[j][0])){
                                        
                            %>
                                        <TD><%=tmpSC.get(total[j][0])%></TD>
                                
                            <%		}else{%>
                            			<TD>0</TD>
                            		<%}%>
                            <%    }%>
                            </TR>
                        <%}%>
                       
                    <%}%>
                     </tbody>
                </table>
       </div>
    
    
  
</div>
</div>

 
<script type="text/javascript">
	$('#wait2').hide();
	$(".mirtooltip3").tooltipster({
				position: 'top-right',
				maxWidth: 250,
				offsetX: 10,
				offsetY: 5,
				contentAsHTML:true,
				//arrow: false,
				interactive: true,
				interactiveTolerance: 350
			});
	
	
	var tblMirGene=$('#mirGeneTbl').DataTable({
			bPaginate: false,
			//"sScrollX": "100%",
			//"sScrollY": "350px",
			bDeferRender: true,
			aaSorting: [[ 16, "desc" ]],
			sDom: '<"leftSearch"fr><t><i>'
	});
</script>