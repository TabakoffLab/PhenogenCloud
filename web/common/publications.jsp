<%--
 *  Author: Cheryl Hornbaker
 *  Created: February, 2007
 *  Description:  The web page created by this file displays information on citing the website tools for reference
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/access/include/login_vars.jsp" %>

<% extrasList.add("normalize.css");
	extrasList.add("index.css"); %>

<%
	pageTitle = "Publications";
	pageDescription = "A list of publications utilizing PhenoGen";
%>

<%@ include file="/web/common/header_adaptive_menu.jsp" %>

<div id="welcome" style="min-height:575px;">

	<h2>Recent Publications</h2>
	<div id="overview-content">
		<p><a target="Publication Window" href="http://www.ncbi.nlm.nih.gov/pubmed/21185315">A systems genetic analysis of alcohol drinking by mice, rats
			and men: influence of brain GABAergic transmission</a></p><BR>
		<p><a target="Publication Window" href="http://www.ncbi.nlm.nih.gov/pmc/articles/PMC3121939">Genetical genomic analysis of complex phenotypes using
			the PhenoGen website</a></p><BR>
		<p><a target="Publication Window" href="http://www.ncbi.nlm.nih.gov/pmc/articles/PMC3115429">Using the Phenogen website for 'in silico' analysis of
			morphine-induced analgesia: identifying candidate genes</a></p><BR>
		<p><a target="Publication Window" href="http://www.ncbi.nlm.nih.gov/pmc/articles/PMC2912051">Type 7 adenylyl cyclase-mediated
			hypothalamic-pituitary-adrenal axis responsiveness: influence of ethanol and sex</a></p><BR>
		<p><a target="Publication Window" href="http://www.ncbi.nlm.nih.gov/pmc/articles/PMC2777866">Genetical genomic determinants of alcohol consumption
			in rats and humans</a></p><BR>
		<p><a target="Publication Window" href="http://www.ncbi.nlm.nih.gov/pubmed/16783646">Candidate genes and their regulatory elements: alcohol
			preference and tolerance</a></p><BR>
		<p><a target="Publication Window" href="http://www.ncbi.nlm.nih.gov/pubmed/17010133">Gene array profiles of alcohol and aldehyde metabolizing
			enzymes in brains of C57BL/6 and DBA/2 mice</a></p><BR>
		<p><a target="Publication Window" href="http://www.ncbi.nlm.nih.gov/pubmed/17135423">A sex-specific role of type VII adenylyl cyclase in
			depression</a></p><BR>
		<p><a target="Publication Window" href="http://www.ncbi.nlm.nih.gov/pubmed/17760997">The PhenoGen Informatics website: Tools for analyses of complex
			traits</a></p><BR>
		<p><a target="Publication Window" href="http://www.ncbi.nlm.nih.gov/pubmed/18563486">The genomic determinants of alcohol preference in mice</a></p>
		<BR>
		<p><a target="Publication Window" href="http://www.ncbi.nlm.nih.gov/pubmed/18550690">Genomic Insights into Acute Alcohol Tolerance</a></p><BR>
		<p><a target="Publication Window" href="http://pubs.niaaa.nih.gov/publications/arh313/272-274.pdf">Expression Quantitative Trait Loci and the
			Phenogen Database</a></p>
	</div> <!-- // end overview-content -->

</div>
<!-- / end welcome -->

<%@ include file="/web/common/footer_adaptive.jsp" %>
