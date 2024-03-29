<%
    String mainMenuSelected = "";
    String mainFunction = "";
    String mainStep = "";
    String topPos = "45px";

    String tmpMMS = (String) session.getAttribute("mainMenuSelected");
    String tmpMF = (String) session.getAttribute("mainFunction");
    String tmpMS = (String) session.getAttribute("mainFunctionStep");
    if (tmpMMS != null) {
        mainMenuSelected = tmpMMS;
    }
    if (tmpMF != null) {
        mainFunction = tmpMF;
    }
    if (tmpMS != null) {
        mainStep = tmpMS;
    }
    if (!mainFunction.equals("") || !mainStep.equals("")) {
        topPos = "5px";
    }
    log.debug("begining of menu");
    //log.debug("Context Dir:\n"+contextRoot+":"+commonDir+"\n\n");
%>

<style>
    <%@ include file="/css/menu.css" %>
</style>


<div id="page_header_wide">
    <div id="header_title"><a href="/">PhenoGen Informatics</a>
        <div style=" font-size:12px;">The site for quantitative genetics of the transcriptome.</div>
    </div>
    <div class="header_status">
        <div class="search" style="width:350px;float:right;position:relative;top:-14px;">
            <script>
                (function () {
                    var cx = '002251072100941693273:v3xvo3chde4';
                    var gcse = document.createElement('script');
                    gcse.type = 'text/javascript';
                    gcse.async = true;
                    gcse.src = 'https://cse.google.com/cse.js?cx=' + cx;
                    var s = document.getElementsByTagName('script')[0];
                    s.parentNode.insertBefore(gcse, s);
                })();
            </script>
            <gcse:search></gcse:search>
        </div>
    </div>

</div>
<!-- page_header -->

<div style="width:100%; text-align:center;/*margin-top:5px;*/">
    <!--*********MESSAGE TOP*********-->
    <!--<BR><div></div><BR>-->
    <div id='cssmenu'>
        <ul>

            <!-- HOME -->
            <%if (!loggedIn || userLoggedIn.getUser_name().equals("anon")) {%>
            <li class="has-sub hideLogin <%if(mainMenuSelected.equals("overview")){%>selected<%}%>"><a
                    href='<%=commonDir%>selectMenu.jsp?menuURL=<%=contextRoot%>index.jsp' class="public"><span class="menu1line">Overview</span></a>
                <ul>
                    <li><a href="<%=commonDir%>selectMenu.jsp?menuURL=<%=commonDir%>ovrvw_whats_new.jsp"><span>What's New</span></a></li>
                    <li><a href="<%=commonDir%>selectMenu.jsp?menuURL=<%=commonDir%>ovrvw_transcript_detail.jsp"><span>Genome/Transcriptome Data Browser</span></a>
                    </li>
                    <li><a href="<%=commonDir%>selectMenu.jsp?menuURL=<%=commonDir%>ovrvw_downloads.jsp"><span>Downloads</span></a></li>
                    <li><a href="<%=commonDir%>selectMenu.jsp?menuURL=<%=commonDir%>ovrvw_microarray_tools.jsp"><span>Microarray Analysis Tools</span></a></li>
                    <li><a href="<%=commonDir%>selectMenu.jsp?menuURL=<%=commonDir%>ovrvw_genelist_tools.jsp"><span>Gene List Analysis Tools</span></a></li>
                    <li><a href="<%=commonDir%>selectMenu.jsp?menuURL=<%=commonDir%>ovrvw_qtl_tools.jsp"><span>QTL Tools</span></a></li>
                </ul>
            </li>
            <%} else {%>
            <li><a href='<%=commonDir%>startPage.jsp'><span class="menu1line">Home</span></a></li>
            <%}%>


            <li class="hideLogin <%if(mainMenuSelected.equals("transcript")){%>selected<%}%>"><a
                    href="<%=commonDir%>selectMenu.jsp?menuURL=<%=contextRoot%>gene.jsp" <%if (!loggedIn || userLoggedIn.getUser_name().equals("anon")) {%>
                    class="public" <%}%>><span class="menu3line">Genome / Transcriptome Data Browser</span></a></li>
            <li class="hideLogin <%if(mainMenuSelected.equals("download")){%>selected<%}%>"><a
                    href='<%=commonDir%>selectMenu.jsp?menuURL=<%=sysBioDir%>resources.jsp' <%if (!loggedIn || userLoggedIn.getUser_name().equals("anon")) {%>
                    class="public" <%}%>><span class="menu2lineAdj">Data Downloads / REST API / R</span></a></li>


            <li class='has-sub hideLogin <%if(mainMenuSelected.equals("genelist")){%>selected<%}%>'><span
                    class=<%if(!loggedIn||userLoggedIn.getUser_name().equals("anon")){%> "noLink public" <%} else {%>"noLink"<%}%>><span class="menu2line">Gene List Analysis Tools</span></span>
                <ul>
                    <li><a href="<%=geneListsDir%>listGeneLists.jsp"><span>Analyze a gene list</span></a>
                    <li><a href="<%=geneListsDir%>createGeneList.jsp?fromMain=Y">Upload or create a new list of genes to use for an analysis</a></li>
                    <li><a href="<%=commonDir%>selectMenu.jsp?menuURL=<%=accessDir%>checkLogin.jsp?url=<%=datasetsDir%>listDatasets.jsp?">Derive a list of genes
                        from a microarray analysis</a></li>
                </ul>
            </li>


            <!-- <li class='has-sub hideLogin <%if(mainMenuSelected.equals("qtl")){%>selected<%}%>'><span class="noLink"><span class="menu1line">QTL Tools</span></span>
       			<ul>
                	<li><a href="<%=commonDir%>selectMenu.jsp?menuURL=<%=accessDir%>checkLogin.jsp?url=<%=qtlsDir%>defineQTL.jsp?fromMain=Y&fromQTL=Y"><span>Enter phenotypic QTL information</span></a></li>
                    <li><a href="<%=commonDir%>selectMenu.jsp?menuURL=<%=accessDir%>checkLogin.jsp?url=<%=qtlsDir%>calculateQTLs.jsp">Calculate QTLs for phenotype</a></li>
            		<li><a href="<%=commonDir%>selectMenu.jsp?menuURL=<%=accessDir%>checkLogin.jsp?url=<%=qtlsDir%>downloadMarker.jsp">Download marker set used in eQTL calculations</a></li>
            		<li><a href="<%=commonDir%>selectMenu.jsp?menuURL=<%=accessDir%>checkLogin.jsp?url=<%=geneListsDir%>listGeneLists.jsp?fromQTL=Y">View physical location and eQTL information about specific genes from a gene list</a></li>
                </ul>
       </li>-->
            <li class='has-sub hideLogin <%if(mainMenuSelected.equals("about")){%>selected<%}%>'><span
                    class="noLink <%if(!loggedIn||userLoggedIn.getUser_name().equals("anon")){%>public<%}%>"><span class="menu1line">About</span></span>
                <ul>
                    <li><a href="<%=commonDir%>selectMenu.jsp?menuURL=<%=contextRoot%>CurrentDataSets.jsp"><span>Current Datasets</span></a></li>
                    <li><a href="<%=commonDir%>selectMenu.jsp?menuURL=<%=commonDir%>publications.jsp"><span>Recent Publications</span></a></li>
                    <li><a href="<%=commonDir%>selectMenu.jsp?menuURL=<%=commonDir%>siteVersion.jsp"><span>Version Information</span></a></li>
                    <li><a href="<%=commonDir%>selectMenu.jsp?menuURL=<%=commonDir%>citation.jsp"><span>Citations</span></a></li>
                    <li><a href="<%=commonDir%>selectMenu.jsp?menuURL=<%=commonDir%>acknowledgements.jsp"><span>Acknowledgements</span></a></li>
                    <li><a href="<%=commonDir%>selectMenu.jsp?menuURL=<%=commonDir%>usefulLinks.jsp"><span>Useful Links</span></a></li>
                    <li><a href="<%=commonDir%>selectMenu.jsp?menuURL=https://github.com/TabakoffLab/PhenogenCloud" target="Phenogen Source Code">PhenoGen Code
                        (GitHub)</a></li>
                    <li><a href="<%=commonDir%>selectMenu.jsp?menuURL=https://github.com/TabakoffLab/PhenoGenRESTAPI" target="Phenogen REST API Code">REST API
                        Code (GitHub)</a></li>
                    <li><a href="<%=commonDir%>selectMenu.jsp?menuURL=https://github.com/TabakoffLab/PhenoGenRESTR" target="Phenogen R Code">R Code
                        (GitHub)</a></li>
                </ul>
            </li>
            <%@ include file="/web/common/helpFileURL.jsp" %>
            <li class='has-sub hideLogin <%if(mainMenuSelected.equals("help")){%>selected<%}%>'><a href="<%=commonDir%>selectMenu.jsp?menuURL=<%=helpFileURL%>"
                                                                                                   target="_blank" <%if (!loggedIn || userLoggedIn.getUser_name().equals("anon")) {%>
                                                                                                   class="public" <%}%>><span class="menu1line">Help</span></a>
                <ul>
                    <li><a href="https://rest-doc.phenogen.org" target="_blank"><span>REST API Help</span></a></li>
                    <li><a href="https://github.com/TabakoffLab/PhenoGenRESTR" target="_blank"><span>R Package Help</span></a></li>
                    <%if (!helpFileURL.equals("/helpdocs/PhenoGen_Overview_CSH.htm?filename=Phenogen_Overview.htm#Overview")) { %>
                    <li><a href="<%=commonDir%>selectMenu.jsp?menuURL=<%=helpFileURL%>" target="_blank"><span>Page Specific Help</span></a></li>
                    <%}%>
                    <li><a href="<%=commonDir%>selectMenu.jsp?menuURL=/helpdocs/PhenoGen_Overview_CSH.htm#Phenogen_Overview.htm#Overview" target="_blank"><span>Help Overview</span></a>
                    </li>
                    <li><a href="<%=commonDir%>selectMenu.jsp?menuURL=<%=commonDir%>PhenoGen.pdf" target="_blank"><span>Download Manual</span></a></li>
                    <li><a href="<%=webDir%>demo/mainDemo.jsp"><span>Demonstration Videos</span></a></li>
                    <li><a href="<%=commonDir%>selectMenu.jsp?menuURL=<%=commonDir%>siteRequirements.jsp"><span>Browser Support/Software Requirments</span></a>
                    </li>
                    <!--<li><a href="<%=commonDir%>how_do_i.jsp"><span>How do I?</span></a></li>-->
                    <li><a href="<%=commonDir%>selectMenu.jsp?menuURL=<%=commonDir%>contact.jsp"><span>Contact Us</span></a></li>
                </ul>
            </li>
            <li class='has-sub hideLogin <%if(mainMenuSelected.equals("microarray")){%>selected<%}%>'><span class="noLink"><span class="menu3lineAdj">View Previous Microarray Analysis</span></span>
                <ul>
                    <li><a href="<%=commonDir%>selectMenu.jsp?menuURL=<%=accessDir%>checkLogin.jsp?url=<%=datasetsDir%>listDatasets.jsp"><span>View previously compiled datasets</span></a>
                        <!--<li><a href="<%=commonDir%>selectMenu.jsp?menuURL=<%=accessDir%>checkLogin.jsp?url=<%=experimentsDir%>listExperiments.jsp"><span>Upload your own data</span></a></li>
             <li><a href="<%=commonDir%>selectMenu.jsp?menuURL=<%=accessDir%>checkLogin.jsp?url=<%=datasetsDir%>basicQuery.jsp"><span>Create a dataset from public and private arrays</span></a></li>-->
                    <li><a href="<%=commonDir%>selectMenu.jsp?menuURL=<%=accessDir%>checkLogin.jsp?url=<%=datasetsDir%>geneData.jsp"><span>View expression values for a list of genes in a dataset</span></a>
                    </li>
                </ul>
            </li>

            <% if (!loggedIn || userLoggedIn.getUser_name().equals("anon")) {%>
            <li id="loginMenu" class='has-sub <%if(mainMenuSelected.equals("login")){%>selected<%}%>'><a href='#' class="end login_btn"><span class="menu2line">Login /<BR>Register</span></a>
            </li>
            <%} else {%>
            <li id="loginMenu" class='has-sub <%if(mainMenuSelected.equals("account")){%>selected<%}%>'><a href='#' class="end"><span
                    class="menu1line">Account</span></a>
                <UL id="account">
                    <li><a href="/web/access/userUpdate.jsp">My Profile</a></li>
                    <li><a href="<%=accessDir%>logout.jsp">Logout</a></li>
                </UL>
            </li>
            <% } %>


        </ul>
    </div>
    <%@ include file="/web/access/include/accountBox.jsp" %>

</div>

<!-- Website status message or other important message-->
<span style="color:#FF0000;font-size: large; text-align: center;display:none;"></span>
<span id="noJS" style="color:#FF0000;display:inline-block;">This site requires JavaScript and it is currently disabled.  Please visit <a
        href="<%=commonDir%>siteRequirements.jsp">Browser Support/Software Requirments</a>.</span>
<script type="text/javascript">
    $('#noJS').css("display", "none");
    $('#login_box').css("left", $('#loginMenu').position().left - 53);
    $(window).resize(function () {
        var x = $('#loginMenu').position().left;
        $('#login_box').css("left", x - 53);
    });
</script>


<!--<div id="crumb_trail"></div>-->

<script type="text/javascript">
    var mouse_is_inside = false;

    $(document).ready(function () {
        var loginBox = $("#login_box");
        $(".login_btn").click(function () {
            if (loginBox.is(":visible")) {
                loginBox.fadeOut("fast");
                //$(".triangle_up").removeClass('triangle_up').addClass('triangle_down');
            } else {
                loginBox.fadeIn("fast");
                //$(".triangle_down").removeClass('triangle_down').addClass('triangle_up');
                $("#user_name").focus();
            }
            return false;
        });
        $(".login_btn").hover(function () {
            if (!loginBox.is(":visible")) {
                loginBox.fadeIn("fast");
                //$(".triangle_down").removeClass('triangle_down').addClass('triangle_up');
                $("#user_name").focus();
            }
            return false;
        });

        $("#login_box").hover(function () {
            mouse_is_inside = true;
        }, function () {
            mouse_is_inside = false;
        });


        $("body").click(function () {
            if (!mouse_is_inside) $("#login_box").fadeOut("fast");
            //$(".triangle_up").removeClass('triangle_up').addClass('triangle_down');
        });
        $("body").hover(function () {
            if (!mouse_is_inside) $("#login_box").fadeOut("fast");
            //$(".triangle_up").removeClass('triangle_up').addClass('triangle_down');
        });
        $("#page_header").hover(function () {
            $("#login_box").fadeOut("fast");
            //$(".triangle_up").removeClass('triangle_up').addClass('triangle_down');
        });
        $(".hideLogin").hover(function () {
            $("#login_box").fadeOut("fast");
            //$(".triangle_up").removeClass('triangle_up').addClass('triangle_down');
        });

    });
</script>