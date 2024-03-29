<%@ include file="/web/access/include/login_vars.jsp" %>
<%

    session.setAttribute("mainMenuSelected", "");
    session.setAttribute("mainFunction", "");
    session.setAttribute("mainFunctionStep", "");

    //loggedIn = false;
    extrasList.add("index.css");
    extrasList.add("jquery.fancybox.css");
    extrasList.add("jquery.fancybox-thumbs.css");
    extrasList.add("fancyBox/helpers/jquery.fancybox-thumbs.js");
    extrasList.add("fancyBox/jquery.fancybox.js");
    extrasList.add("d3.v3.5.16.min.js");
    extrasList.add("landing.js");
    request.setAttribute("extras", extrasList);
%>

<%pageDescription = "The site for quantitative genetics of the transcriptome";%>

<%@ include file="/web/common/header_adaptive_menu.jsp" %>


<%
    log.debug("Start of index.jsp");
    String msg = "";
    String callerMsg = "";
 
        	/*
			//May need to add back this is to keep user from opening another window
			if (contextRoot.equals("/PhenoGen/") || contextRoot.equals("/PhenoGenTEST/")) {
                	if ((String) session.getAttribute("userID") != null) {
                        	log.debug("user already logged in.  Invalidating session");
                        	mySessionHandler.setSession_id(session.getId());
                        	mySessionHandler.logoutSession(dbConn);
                        	session.invalidate();
                	}
        	}
			*/

    callerMsg = "";
    //log.debug("caller = " + caller);
    //log.debug("this = " + "http://" + host + contextRoot + "index.jsp");

    if (caller == null) {
        //log.debug("caller is null");
    } else if (caller.equals("http://" + host + contextRoot + "index.jsp") ||
            caller.equals("http://" + host + contextRoot) ||
            caller.equals("http://" + host + "/")) {
        log.debug("caller is " + caller + " - possibly typed incorrect username/password combination");
    } else if (caller.equals("http://" + host + helpDir + "gettingStarted.jsp") ||
            caller.equals("http://" + host + accessDir + "registration.jsp") ||
            caller.equals("http://" + host + commonDir + "successMsg.jsp") ||
            caller.equals("http://" + host + accessDir + "loginError.jsp") ||
            caller.equals("http://" + host + accessDir + "emailPassword.jsp") ||
            caller.equals("http://" + host + webDir + "iniaHome.jsp") ||
            caller.equals("http://" + host + commonDir + "iniaPartners.jsp") ||
            caller.equals("http://" + host + commonDir + "contact.jsp") ||
            !caller.startsWith("http://phenogen.uchsc.edu") ||
            caller.equals("http://" + host + accessDir + "logout.jsp")) {
        callerMsg = "";
    } else {
        log.debug("session had expired");
        //callerMsg = "Due to inactivity, your session has expired.  Please login again.";
        session.setAttribute("loginErrorMsg", "Expired");
        response.sendRedirect(accessDir + "loginError.jsp");
    }
    log.debug("caller = " + caller + ", and callerMsg = " + callerMsg);
    formName = "index.jsp";
    actionForm = "index.jsp";
%>


<div style="text-align:center;">
    <!--Download the slides from the Informatics Workshop <a href="<%=webDir%>overview/PhenoGen.workshop.16Apr15.pdf">here</A>.-->
    <!--Download the 2019 NIDA Meeting poster <a href="/web/overview/NIDA_NGC_2019_poster.pdf">here</a> .-->
</div>

<div id="index" style="background: #365473;">


    <!--<div id="primary-content">-->
    <div id="welcome" style="width:100%;margin:0px,0px,0px,0px;">
        <h1 id="index" class="homePage">Welcome to PhenoGen Informatics</h1>
        <H2 style="color:#FFFFFF;"> The site for quantitative genetics of the transcriptome.</h2>
        <div style="text-align:center;">
            <%@ include file="/web/common/indexGraph.jsp" %>
        </div>

        <div style="display:inline-block;margin:0px,0px,0px,10px;padding-left:10px;color:#FFFFFF;" id="ack">

            <h3 style="margin:10px;">Acknowledgements</h3>
            <H4 style="margin:10px;">Funding</H4>
            <p style="padding-left: 20px;">We would like to thank the National Institue on Alcohol Abuse and Alcoholism (<a
                    href="http://www.niaaa.nih.gov/">NIAAA</a>) for continued funding to develop and support this site.
                The Banbury Fund for supporting the development of this site.</p>
            <H4 style="margin:10px;">Computational Resources</H4>
            <p style="padding-left: 20px;">We would like acknowledge the UNLV National Supercomputing Institute (<a href="https://www.nscee.edu/">UNLV
                NSI</a>) for access to
                supercomputing resources to support analysis of sequencing data.</p>
            <h4 style="margin:10px;">Recombinant Inbred Panels</h4>
            <p style="padding-left: 20px;">We are grateful to the following investigators for providing the recombinant inbred panels found on the
                site.<BR/>
            <p style="padding-left: 20px;">HXB/BXH Rat RI Panel was provided by <a href="http://www.fgu.cas.cz/en/departments/genetics-of-model-diseases">Michal
                Pravenec</a> (Czech Academy
                of Sciences) and <a href="http://pharmacology.ucsd.edu/faculty/printz.html">Morton Printz</a>(UC San Diego).<BR>
                F344/LE Rat RI Panel was provided by <a href="http://www.med.kyoto-u.ac.jp/en/organization-staff/research/doctoral_course/r-022/">Masahide
                    Asano</a>(National BioResource Project for the Rat in Japan).<BR>
                ILSXISS Mouse RI Panel was provided by <a href="http://ibgwww.colorado.edu/tj-lab/">Thomas Johnson</a>(CU Boulder) and John DeFries (CU
                Boulder).</p>
        </div>
    </div>
    <!--</div>--> <!-- // end primary-content -->


</div>
<!-- end index -->
</div>
</div>

<script type="text/javascript">
    $("#closeBTN").on("click", function () {
        $('div#indexDesc').hide();
    });
    $(document).ready(function () {
        $('#body_wrapper_plain').css("background", "#365473");
        //$(".search").css("top", "4px");
        $("div.clicker").click(function () {
            var thisHidden = $("span#" + $(this).attr("name")).is(":hidden");
            var tabTriggers = $(this).parents("ul").find("span.branch").hide();
            var baseName = $(this).attr("name");
            $("span#" + baseName).removeClass("clickerLess");
            if (thisHidden) {
                $("span#" + baseName).show().addClass("clickerLess");
            }
            $("div." + baseName).removeClass("clicker");
            $("div." + baseName).addClass("clickerLess");
        });

    });

</script>

<%@ include file="/web/common/basicFooter.jsp" %>

