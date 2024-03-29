<%@ include file="/web/access/include/login_vars.jsp" %>
<%--
 *  Author: Spencer Mahaffey
 *  Created: May, 2013
 *  Description:  
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

    

                	<H2>Statistics/Expression Values</H2>
                   <div  style="overflow:auto;height:92%;">
                    	<H3>Demo/Screen Shots</H3>
                        <div style="overflow:auto;display:inline-block;height:25%;width:100%;">
                        	<table>
                            <TR>
                            <TD>
                            <span class="tooltip"  title="Example output for analysis statistics from analysis that generated this list.<BR>Click to view a larger image.">
                            <a class="fancybox" rel="fancybox-thumb" href="web/overview/glValues_stats.jpg" title="Example output for analysis statistics from analysis that generated this list.">
                                <img src="web/overview/glValues_stats_200.jpg"  title="Click to view a larger image"/></a></span>
                            </TD>
                            <TD>
                   			<span class="tooltip"  title="Example of method to view expression values.   Unlike analysis statistics you may extract expression values from any dataset using the same arrays.<BR>Click to view a larger image.">
                        	<a class="fancybox" rel="fancybox-thumb" href="web/overview/glValues_dataset.jpg" title="Example of method to view expression values.   Unlike analysis statistics you may extract expression values from any dataset using the same arrays.">
                                    <img src="web/overview/glValues_dataset_200.jpg"  title="Click to view a larger image"/></a></span>
                            </TD>
                            <TD>
                            <span class="tooltip"  title="Example output for expression value from the selected dataset.<BR>Click to view a larger image.">
                        	<a class="fancybox" rel="fancybox-thumb" href="web/overview/glValues_expression.jpg" title="Example output for expression value from the selected dataset.">
                                    <img src="web/overview/glValues_expression_200.jpg"  title="Click to view a larger image"/></a></span>
                            </TD>
                            </TR>
                            </table>
                            </div>
                    	<H3>Feature List</H3>
                        <div>
                        	Available only for gene lists created from analysis of arrays on PhenoGen.
                            <BR /><BR />
                            <ul>
                            	<li>Retrieve the analysis statistics for the analysis that created the list.</li>
                            	<li>Retrieve expression values for any dataset that uses the same arrays.  An example of this is a gene list created from the HXB/BXH panel in Brain will allow you to retrieve expression values for the same probe sets in the other tissues available.</li>
                            </ul>
                        </div>
                        <BR /><BR />
                        <div style="text-align:center;width:100%;">
                            <a href="<%=geneListsDir%>listGeneLists.jsp" class="button" style="width:170px;color:#666666;">View Gene Lists</a>
                        </div>
                        
                    </div>

    
<%@ include file="/web/overview/ovrvw_js.jsp" %>