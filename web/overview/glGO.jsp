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



<H2>multiMiR</H2>
<div  style="overflow:auto;height:92%;">
    <H3>Demo/Screen Shots</H3>
    <div style="overflow:auto;display:inline-block;height:30%;width:100%;">
        <table>
            <TR>
                <TD>
                            <span class="tooltip"  title="The Gene Ontology results Summary.<BR>Click to view a larger image.">
                            <a class="fancybox" rel="fancybox-thumb" href="web/overview/browseWGCNA_go.png" title="The GO Summary image/table.">
                                <img src="web/overview/browseWGCNA_go_150.png"  title="Click to view a larger image"/></a></span>
                </TD>
            </TR>
        </table>
    </div>
    <H3>Feature List</H3>
    <div>
        Gene Ontology summary provides a way to retrieve a summary of GO terms for annotated genes in the select list.
        An interactive graphic is produced as well as linked table that adjusts as the image is adjusted or allows expansion level by level.
    </div>
    <BR /><BR />
    <div style="text-align:center;width:100%;">
        <a href="<%=geneListsDir%>listGeneLists.jsp" class="button" style="width:170px;color:#666666;">View Gene Lists</a>
    </div>

</div>


<%@ include file="/web/overview/ovrvw_js.jsp" %>