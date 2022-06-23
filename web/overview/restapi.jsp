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

<H2>REST API</H2>
<div style="height:100%;">
    <H3>Description</H3>
    <div>
        We have sequenced each of the HXB inbred panel parental strains(BN-Lx/CubPrin and SHR/OlaIpcvPrin). Sequences were aligned to the reference BN(Rn5)
        genome. SNPs and short Indels were identified. The download currently only contains the alignment with SNPs.
        <BR/><BR/>
        All identified SNPs/Indels can be displayed when you view a gene or region under <a
            href="<%=commonDir%>selectMenu.jsp?menuURL=<%=accessDir%>createAnnonymousSession.jsp?url=<%=contextRoot%>gene.jsp">Detailed Genome/Transcription
        Information</a>.
    </div>
    <BR/><BR/>
    <div>
        We are building a REST API to provide access to all public data. Eventually this will also
        include running most functions available through the website. Keep checking back for new functions.
    </div>
    <BR>
    <H2>Domains for Functions Calls:</H2>
    <div>
        Functions can be called at either:<BR>
        <BR>
        https://rest.phenogen.org<BR>
        <BR>
        or<BR>
        <BR>
        https://rest-test.phenogen.org<BR>
        Please note this is a development and testing version of the API. Please do not use this
        for actual data analysis. Only for development.
    </div>
    <BR>
    <H2>Help</H2>
    <div>
        https://rest-doc.phenogen.org
        <BR><BR>
        All functions should include help as a response if you call the function with this appended to the
        end `?help=Y`. The response returns a JSON object with supported methods and then list of parameters
        and description of each parameter as well as a list of options if there is a defined list of values.
        <BR>
    </div>
    <BR>
    <H2>R methods for the API</H2>
    <div>
        We are developing methods to call the REST API from R and to retrieve the data directly from PhenoGen into
        R. For now this is limited to the datasets at https://phenogen.org/web/sysbio/resources.jsp -> New RNA
        Sequencing Datasets Experimental Details/Downloads
        <BR><BR>
        We will turn this into an R package and release it.
        <BR><BR>
        GitHub Repository -
        https://github.com/TabakoffLab/PhenoGenRESTR
    </div>
</div>

<%@ include file="/web/overview/ovrvw_js.jsp" %>