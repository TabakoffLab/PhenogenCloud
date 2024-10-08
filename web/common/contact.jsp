<%--
 *  Author: Cheryl Hornbaker
 *  Created: June, 2004
 *  Description:  The web page created by this file displays contact information.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/access/include/login_vars.jsp" %>

<jsp:useBean id="myEmail" class="edu.ucdenver.ccp.PhenoGen.web.mail.Email"></jsp:useBean>

<% extrasList.add("normalize.css");
    extrasList.add("index.css");

    Properties myProperties = new Properties();
    File myPropertiesFile = new File(captchaPropertiesFile);
    myProperties.load(new FileInputStream(myPropertiesFile));

    String pub = "";
    String secret = "";
    pub = myProperties.getProperty("PUBLIC");
    secret = myProperties.getProperty("SECRET");

    log.debug("action=" + action);
    String msg = "";
    String msgColor = "#FF0000";
    String emailAddress = "";
    String subject = "";
    String feedback = "";
    if (action != null && action.equals("submit")) {
        emailAddress = (String) request.getParameter("emailAddress");
        subject = (String) request.getParameter("subject");
        feedback = (String) request.getParameter("feedback").trim();
        String remoteAddr = request.getRemoteAddr();
        reCaptcha re = new reCaptcha();
        String gResponse = "";
        if (request.getParameter("g-recaptcha-response") != null) {
            gResponse = request.getParameter("g-recaptcha-response");
        }

        if (re.checkResponse(secret, gResponse, remoteAddr)) {
            Properties myProp2 = new Properties();
            File myPropFile = new File(mailPropertiesFile);
            myProp2.load(new FileInputStream(myPropFile));
            myEmail.setFrom("info@phenogen.org");
            myEmail.setAuth(myProp2.getProperty("USER"), myProp2.getProperty("PASS"));
            myEmail.setSMTPServer(myProp2.getProperty("HOST"));
            myEmail.setSubject("PhenoGen " + subject);
            myEmail.setContent("Feedback from " + emailAddress + " :" + "\n\n" + feedback);
            try {
                myEmail.sendEmailToAdministrator(myProp2.getProperty("ADMIN"));
                //mySessionHandler.createSessionActivity(session.getId(), "Sent an email from contact page", dbConn);
                msg = "The following message has been successfully sent.";
                msgColor = "#00CC00";
            } catch (Exception e) {
                log.error("exception while trying to send feedback to administrator", e);
                msg = "The message has NOT been sent.  Please try again.  If the form is not working you can email Spencer.Mahaffey@ucdenver.edu directly.";
            }
                /*if(dbConn!=null){
                    String msgNum = "ADM-003";
                    session.setAttribute("successMsg", msgNum);
                    //response.sendRedirect(commonDir + "startPage.jsp");
                }else{
                    //response.sendRedirect(commonDir + "startPage.jsp");
                }*/
        } else {
            msg = "Please make sure that there is a check mark by the \"I'm not a robot\" field below and try again.";
        }
    }
    //mySessionHandler.createSessionActivity(session.getId(), "Looked at contact page", dbConn);
%>
<%
    pageTitle = "Contact Us";
    pageDescription = "Contact Us, provide feedback or ask questions";
%>
<%@ include file="/web/common/header_adaptive_menu.jsp" %>
<script src='https://www.google.com/recaptcha/api.js'></script>
<div id="welcome" style="min-height:625px;width: 98%;margin-left: 10px">
    <h2>Contact PhenoGen </h2>
    <p> The quality, functionality, and continued maintenance of the PhenoGen Informatics
        website depends on feedback from you, our user. We welcome your questions and appreciate
        your comments and suggestions.
        Use the form below to send us your question or to give us feedback.
    </p>


    <BR>
    <BR>
    <div style="width:100%;">
        <div style="background:#FFFFFF;text-align:center;font-size:14px;font-weight:bold; width:95%;color:<%=msgColor%>;"><%=msg%>
        </div>

        <form method="post"
              action="contact.jsp"
              id="contact"
              name="contact"
              enctype="application/x-www-form-urlencoded">
            <table width="95%">
                <tr>
                    <td colspan="4"><h2>Provide the following information:</h2></td>
                </tr>
                <tr>
                    <td colspan="4">&nbsp;</td>
                </tr>
                <tr>
                    <td> Your email address:</td>
                    <td><input type="text" name="emailAddress" size="30" value="<%=emailAddress%>"/></td>
                    <td>Subject:</td>
                    <td><select name="subject">
                        <option label="Question" value="Question" <%if(subject.equals("Question")){%>selected="selected"<%}%>>Question</option>
                        <option label="Suggestion" value="Suggestion" <%if(subject.equals("Suggestion")){%>selected="selected"<%}%>>Suggestion</option>
                        <option label="Feedback" value="Feedback" <%if(subject.equals("Feedback")){%>selected="selected"<%}%>>Feedback</option>
                        <option label="Error" value="Error" <%if(subject.equals("Error")){%>selected="selected"<%}%>>Error</option>
                    </select>
                    </td>
                </tr>

                <tr>
                    <td colspan="4">&nbsp;</td>
                </tr>
                <tr>
                    <td>Feedback:</td>
                </tr>
                <tr>
                    <td colspan="4"><textarea name="feedback" cols="120" rows="10"><%=feedback%></textarea></td>
                </tr>
                <tr>
                    <td colspan="4">&nbsp;</td>
                </tr>
                <!--<TR>
                    <TD colspan="4" >
                    	 <div style="text-align:center;width:100%">
                                <div class="g-recaptcha" data-sitekey="<%=pub%>"></div>
                         </div>
                    </TD>
                </TR>-->
                <tr>
                    <td colspan="4" align="center">
					  <div id="block_container">
					   <div id="bloc1">
                        <input type="hidden" id="action" name="action" value="">
                        <input type="reset" name="reset" value="Reset"> <%=tenSpaces%>
					   </div>
                       <div id="bloc2">
                        <button class="g-recaptcha"
                                data-sitekey="<%=pub%>"
                                data-callback='onSubmit'
                                data-action='submit'>Submit
                        </button>
					   </div>
					  </div>	
                    </td>
                </tr>
                <tr>
                    <td colspan="4">&nbsp;</td>
                </tr>
            </table>
            <BR><BR>
        </form>
    </div>
</div>
<!-- // end welcome-->
</div>
</div>

<%@ include file="/web/common/footer_adaptive.jsp" %>
<script type="text/javascript">
    function onSubmit(token) {
        $('#action').val("submit");
        document.getElementById("contact").submit();
    }

    $(document).ready(function () {


        setTimeout("setupMain()", 100);
    });
</script>
