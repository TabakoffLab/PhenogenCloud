package edu.ucdenver.ccp.PhenoGen.web.mail;    

import java.io.IOException;
import java.io.PrintWriter;
import java.net.UnknownHostException;
import java.util.Properties;

import javax.mail.*;
import javax.mail.internet.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.File;
import java.io.FileInputStream;

/* for logging messages */
import org.apache.log4j.Logger;

public class Email  {
	//defaults
	private final static String DEFAULT_CONTENT = "Unknown content";
	private final static String DEFAULT_SUBJECT= "Unknown subject";
	private static String DEFAULT_SERVER = "";
	private static String DEFAULT_TO = null;
	private static String DEFAULT_FROM = "info@phenogen.org";

	private static String defaultAdmin="Spencer.Mahaffey@ucdenver.edu";
	private Logger log = null;


	//JavaBean properties
	private String to;
	private String from;
	private String content;
	private String subject;
	private String smtpHost;
	private String adminEmail="";
	private String SMTP_AUTH_USER="";
	private String SMTP_AUTH_PWD="";
 
	public Email() {
		log = Logger.getRootLogger();
		SMTP_AUTH_USER="";
		SMTP_AUTH_PWD="";
		DEFAULT_SERVER="";
		from=DEFAULT_FROM;
	}
	public Email(String user,String password,String server,String from) {
		log = Logger.getRootLogger();
		SMTP_AUTH_USER=user;
		SMTP_AUTH_PWD=password;
		DEFAULT_SERVER=server;
		this.from=from;
	}
	public Email(String propFile){
		log = Logger.getRootLogger();
		try {
			Properties myProp2 = new Properties();
			File myPropFile = new File(propFile);
			myProp2.load(new FileInputStream(myPropFile));
			this.setAuth(myProp2.getProperty("USER"), myProp2.getProperty("PASS"));
			this.setSMTPServer(myProp2.getProperty("HOST"));
			defaultAdmin = myProp2.getProperty("ADMIN");
		}catch(Exception e){
			log.error("Email properties file exception",e);
		}
	}
	public void setAuth(String user,String password){
		SMTP_AUTH_USER=user;
		SMTP_AUTH_PWD=password;
	}
	public void setSMTPServer(String server){
		this.smtpHost=server;
	}

	public void sendEmail() throws MessagingException, SendFailedException {
		log.info("in Email.sendEmail to:"+to);
		log.info(content);
		//setSmtpHost("");
		//setFrom("");
		//Properties properties = System.getProperties();
                
		content=content+"\n\n\nPlease do not reply to this message.  This message is sent from an unmonitored account.  We welcome any feedback and questions. Please use the form here(http://phenogen.org/web/common/contact.jsp) to submit questions or feedback.";

		Properties props = new Properties();
		props.put("mail.transport.protocol", "smtp");
		//props.put("mail.smtp.host", smtpHost);
		props.put("mail.smtp.port", 465);
		props.put("mail.smtp.starttls.enable", "true");
		props.put("mail.smtp.auth", "true");
		log.debug("to:"+to);
		log.debug("from:"+from);
		log.debug("user:"+SMTP_AUTH_USER);
		log.debug("pass:"+SMTP_AUTH_PWD);
		log.debug("host:"+smtpHost);
		Session session = Session.getDefaultInstance(props);

		MimeMessage msg = new MimeMessage(session);
		msg.setFrom(new InternetAddress(from));
		msg.setRecipient(Message.RecipientType.TO, new InternetAddress(to));
		msg.setSubject(subject);
		msg.setContent(content,"text/html");

		Transport transport = session.getTransport();
		try {
			// Connect to Amazon SES using the SMTP username and password you specified above.
			transport.connect(smtpHost, SMTP_AUTH_USER, SMTP_AUTH_PWD);

			// Send the email.
			transport.sendMessage(msg, msg.getAllRecipients());
			log.debug("Email sent!");
		}catch(Exception e){
			log.error("Email Exception:",e);
		}
		transport.close();
	}

	public void sendEmailToAdministrator(String adminEmail) throws MessagingException, SendFailedException {
		log.debug("in sendEmailToAdministrator");
		log.debug(this.content);
               String[] adminEmails=null;
                if(adminEmail.length()>0){
                    adminEmails=adminEmail.split(",");
                }else{
                    adminEmails=this.defaultAdmin.split(",");
                }
                java.net.InetAddress localMachine =null;
                try{
                    localMachine = java.net.InetAddress.getLocalHost();
                }catch(UnknownHostException ex){
                    log.error("Unknown host exception while sending email.", ex);
                }
				this.content = "From Host:"+localMachine+"\nNOTE: This email was only sent to the administrator \n\n" +this.content;
                this.subject = localMachine+"::"+this.subject;
                for(int i=0;i<adminEmails.length;i++){
                    if(adminEmails[i].indexOf("@")>0){
                        this.to = adminEmails[i];
                        sendEmail();
                    }
                }
		log.debug("just sent email");
	}
        
        
    
	public void setSmtpHost(String host){
        	if (check(host)){
        		this.smtpHost = host;
        	} else {
    			this.smtpHost = Email.DEFAULT_SERVER;
        	}
	}
    
	public void setTo(String to){
        	if (check(to)){
       			this.to = to;
        	} else {
	    		this.to = Email.DEFAULT_TO;
        	}
	}
    
	public void setFrom(String from){
        	if (check(from)){
        		this.from = from;
        	} else {
    			this.from = Email.DEFAULT_FROM;
        	}
	}
    
	public void setContent(String content){
        	if (check(content)){
        		this.content = content;
        	} else {
    			this.content = Email.DEFAULT_CONTENT;
        	}
	}
        
        public void setContent(String content,Exception e){
        	if (check(content)){
        		this.content = content;
                        StackTraceElement[] st=e.getStackTrace();
                        this.content=this.content+"\n\n\nStack Trace:\n"+e.getMessage();
                        for(int i=0;i<st.length;i++){
                            this.content=this.content+"\n\t"+st[i].toString();
                        }
        	} else {
    			this.content = Email.DEFAULT_CONTENT;
                        StackTraceElement[] st=e.getStackTrace();
                        this.content=this.content+"\n\n\nStack Trace:\n"+e.getMessage();
                        for(int i=0;i<st.length;i++){
                            this.content=this.content+"\n\t"+st[i].toString();
                        }
        	}
	}
    
	public void setSubject(String subject){
        	if (check(subject)){
        		this.subject = subject;
        	} else {
    			this.subject = Email.DEFAULT_SUBJECT;
        	}
	}
        
        public String getSubject(){
            return this.subject;
        }
    
	private boolean check(String value){
        	if(value == null || value.equals("")) {
            		return false;
		}
		return true;
	}


	public static void main (String [] args) {
	}


	private class SMTPAuthenticator extends javax.mail.Authenticator {
		public PasswordAuthentication getPasswordAuthentication() {
			String username = SMTP_AUTH_USER;
			String password = SMTP_AUTH_PWD;
			return new PasswordAuthentication(username, password);
		}
	}
}
