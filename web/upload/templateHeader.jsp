<%@ page language="java" 
import="java.io.*" 
import="java.sql.Connection" 
import="java.util.Properties" 
import="org.apache.log4j.Logger" 
import="edu.ucdenver.ccp.util.sql.*"
import="edu.ucdenver.ccp.PhenoGen.data.Experiment_protocol" 
import="edu.ucdenver.ccp.PhenoGen.data.Protocol" %>
<%@ page session="true" %>
<%@ page errorPage="/web/common/errorPage.jsp" %> 
<jsp:useBean id="myArray" class="edu.ucdenver.ccp.PhenoGen.data.Array"></jsp:useBean> 
<jsp:useBean id="myExperiment" class="edu.ucdenver.ccp.PhenoGen.data.Experiment"></jsp:useBean> 
<jsp:useBean id="myExperiment_protocol" class="edu.ucdenver.ccp.PhenoGen.data.Experiment_protocol"></jsp:useBean> 
<jsp:useBean id="myProtocol" class="edu.ucdenver.ccp.PhenoGen.data.Protocol"></jsp:useBean> 
<jsp:useBean id="myUser" class="edu.ucdenver.ccp.PhenoGen.data.User"></jsp:useBean> 
<jsp:useBean id="myEmail" class="edu.ucdenver.ccp.PhenoGen.web.mail.Email"></jsp:useBean><%
        //
        // Initialize the logger to log debug messages
        //
        Logger log=null;
        //log = Logger.getRootLogger();
        log = Logger.getLogger("JSPLogger");

        String host = request.getHeader("host");

	%>
