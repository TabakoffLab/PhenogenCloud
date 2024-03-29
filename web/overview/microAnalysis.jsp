<%@ include file="/web/common/headerOverview.jsp" %>
<%--
 *  Author: Spencer Mahaffey
 *  Created: May, 2013
 *  Description:  
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

    
	<H2>View datasets previously analized</H2>
                   <div  style="overflow:auto;height:92%;">
                    	<H3>Demo/Screen Shots</H3>
                        <div style="overflow:auto;display:inline-block;height:27%;width:100%;">
                        	<table>
                            <TR>
                            <TD>
                            <span class="tooltip"  title="List of datasets available.  Start analysis of existing datasets by clicking on the dataset or you can create a new dataset from this page.<BR>Click to view a larger image.">
                        	<a class="fancybox" rel="fancybox-thumb" href="web/overview/microAnalysis_list.jpg" title="List of datasets available.  Start analysis of existing datasets by clicking on the dataset or you can create a new dataset from this page.">
                                    <img src="web/overview/microAnalysis_list_150.jpg" title="Click to view a larger image"/></a></span>
                            </TD>
                            <TD>
                            <span class="tooltip"  title="For some array types analysis takes a little longer, in those instances after you've selected a dataset and normalized version, you can view previous analyses and resume them or start a new analysis.<BR>Click to view a larger image.">
                            <a class="fancybox" rel="fancybox-thumb" href="web/overview/microAnalysis_type.jpg" title="For some array types analysis takes a little longer, in those instances after you've selected a dataset and normalized version, you can view previous analyses and resume them or start a new analysis.">
                                <img src="web/overview/microAnalysis_type_150.jpg" title="Click to view a larger image"/></a></span>
                            </TD>
                            <TD>
                            <span class="tooltip"  title="For most analysis types filtering is the first step after you've chosen to start a new analysis.  You can sequentially apply as many filters as desired and can undo the last filter applied.<BR>Click to view a larger image.">
                            <a class="fancybox" rel="fancybox-thumb" href="web/overview/microAnalysis_filter.jpg" title="For most analysis types filtering is the first step after you've chosen to start a new analysis.  You can sequentially apply as many filters as desired and can undo the last filter applied.">
                                <img src="web/overview/microAnalysis_filter_150.jpg" title="Click to view a larger image" /></a></span>
                            </TD>
                            <TD>
                            <span class="tooltip"  title="Next you can perform statistics.  Based on the analysis type and number of groups you will be given the most relevant choices of statistical methods.<BR>Click to view a larger image.">
                            <a class="fancybox" rel="fancybox-thumb" href="web/overview/microAnalysis_stats.jpg" title="Next you can perform statistics.  Based on the analysis type and number of groups you will be given the most relevant choices of statistical methods.">
                                <img src="web/overview/microAnalysis_stats_150.jpg"  title="Click to view a larger image" /></a></span>
                            </TD>
                            <TD>
                            <span class="tooltip"  title="After statistics are calculated you select the statistical test threshold to keep and also apply any multiple testing correction.  You can repeat this as many times as needed until you are happy with the results.<BR>Click to view a larger image.">
                            <a class="fancybox" rel="fancybox-thumb" href="web/overview/microAnalysis_multtest.jpg" title="After statistics are calculated you select the statistical test threshold to keep and also apply any multiple testing correction.  You can repeat this as many times as needed until you are happy with the results.">
                                <img src="web/overview/microAnalysis_multtest_150.jpg" title="Click to view a larger image" /></a></span>
                            </TD>
                            <TD>
                            <span class="tooltip"  title="The last step is saving the probes to a gene list which will allow you to perform the other gene list analyses on the probes(genes) found in your analysis.<BR>Click to view a larger image.">
                            <a class="fancybox" rel="fancybox-thumb" href="web/overview/microAnalysis_save.jpg" title="The last step is saving the probes to a gene list which will allow you to perform the other gene list analyses on the probes(genes) found in your analysis.">
                                <img src="web/overview/microAnalysis_save_150.jpg" title="Click to view a larger image" /></a></span>
                            </TD>
                            </TR>
                            </table>
                            </div>
                    	<H3>Feature List</H3>
                        <div>
                        	General analysis flow chart
                   			<a class="fancybox" rel="fancybox-thumb2" href="web/overview/microAnalysis_flowchart.jpg" title="General analysis flow chart"><img src="web/overview/microAnalysis_flowchart.jpg"  style="width:100%;"  title="Click to view a larger image"/></a>
                        <ul>
                        	<li>Create Dataset</li>
                            	<ul>
                                	<li>Datasets can be created from any public arrays on the site.</li>
                                    <li>Datasets can be created from any private arrays that you have been given access to.</li>
                                </ul> 
                            <li>Run Quality Control</li>
                            	<ul>
                                	<li>Quality Control allows you the opportunity to evaluate each array included in the dataset.</li>
                                    <li>Once you approve you may continue to normalization.</li>
                                    <li>This is the only point where you may remove arrays if you wish at which time you'll need to rerun QC.</li>
                                </ul> 
                            <li>Normalize</li>
                            	<ul>
                                	<li>You need to create at least one normalized version.  This lets you choose the normalization method.</li>
                                    <li>You may always create additional normalized versions.  For analysis you will be able to choose from any normalized version.</li>
                                    <li>You will also need to decide how to group the arrays.  For example you might group a dataset made up of different strains by strain.  Although you may always create another grouping and normalized version at a later time.</li>
                                    <li>For some arrays you may have to decide on the confidence level of probes you want to include and/or what level(Gene vs Exon) of them to include.  For example the Affy Rat or Mouse Exon array can be analyzed at the Gene or Exon level and including probe sets with varying levels of confidence in their annotation.</li>
                                </ul> 
                            <li>Filter</li>
                            	<ul>
                                	<li>To save time and reduce the list of probes at the end of the analysis it is recommended to perform some filtering.</li>
                                    <li>Filters vary based on the type of array used however they generally include:</li>
                                    	<ul>
                                        	<li>Control Probe Filter - Remove control probes.</li>
                                            <li>Detection Above Background Filter - Keep/Remove probes not detected above background in the combination of samples you specify.</li>
                                            <li>Heritability Filter - If available removes probes below a given threshold of heritability in one of the available Recombinant Inbred Panels.</li>
                                            <li>Gene List Filter - Removes probes not found in a given gene list.</li>
                                            <li>QTL Filter - If available removes probes not located in the bQTL or eQTL regions of the list.</li>
                                        </ul>
                                </ul> 
                            <li>Statistics</li>
                            	<ul>
                                	<li>Correlation-Correlation of expression to phenotype data.</li>
                                    <li>Differential Expression-Differential expression between groups used for normalization.</li>
                                    <li>Clustering-Supports a number of clustering methods so you can find clusters of interest.</li>
                                </ul> 
                            <li>Gene List</li>
                            	<ul>
                                	<li>Finally from the results of the statistical analysis you can save gene lists.</li>
                                    <li>From gene lists a number of additional tools are available.  Please see the gene list section for a detailed description of each tool.</li>
                                </ul>                            
                        </ul>
                        </div>
                    	<BR /><BR />
                        <div style="text-align:center;width:100%;">
                        	<a href="<%=accessDir%>checkLogin.jsp?url=<%=datasetsDir%>listDatasets.jsp" class="button" style="width:200px;color:#666666;">Login to Start an Analysis</a><BR />or<BR /><a href="<%=accessDir%>registration.jsp" class="button" style="width:140px;color:#666666;">Register Here</a>
                        </div>
                        
                   </div>

<%@ include file="/web/overview/ovrvw_js.jsp" %>