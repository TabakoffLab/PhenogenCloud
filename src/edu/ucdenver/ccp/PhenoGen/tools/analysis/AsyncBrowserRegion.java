package edu.ucdenver.ccp.PhenoGen.tools.analysis;


import edu.ucdenver.ccp.PhenoGen.data.User;
import edu.ucdenver.ccp.PhenoGen.driver.ExecHandler;
import edu.ucdenver.ccp.PhenoGen.web.mail.Email;
import edu.ucdenver.ccp.PhenoGen.driver.ExecException;
import java.io.*;

import java.util.Properties;
import javax.sql.DataSource;
import org.apache.log4j.Logger;
import javax.servlet.http.HttpSession;

public class AsyncBrowserRegion extends Thread {
    private String[] rErrorMsg = null;
    private HttpSession session=null;
    private Logger log = null;
    private String userFilesRoot = "";
    private String urlPrefix = "";
    private String ucscDir="";
    private DataSource pool=null;
    private String dbPropertiesFile=null;
    private String mongoDBPropertiesFile=null;
    private String ensemblDBPropertiesFile=null;
    private String ensemblPath="";
    private String outputDir="";
    private String chrom="";
    private String genomeVer="";
    private String perlDir="";
    private String perlEnvVar="";
    private String ucscDB="";
    private String org="";

    private int minCoord=0;
    private int maxCoord=0;
    private int arrayTypeID=0;
    private int rnaDatasetID=0;
    private int usageID=-1;
    private boolean done=false;
    private boolean runAGDT=false;
    private boolean isEnsemblGene=true;
    private String updateSQL="update TRANS_DETAIL_USAGE set TIME_ASYNC_GENE_DATA_TOOLS=? , RESULT=? where TRANS_DETAIL_ID=?";
    private String[] tissues=new String[2];
    private ExecHandler myExec_session = null;

    public AsyncBrowserRegion(HttpSession inSession,DataSource pool,String organism,String outputDir,String chr,int min,int max,int arrayTypeID,int rnaDS_ID,String genomeVer,String ucscDB,String ensemblPath,int usageID,boolean runAGDT) {
        this.session = inSession;
        this.outputDir=outputDir;
        log = Logger.getRootLogger();
        log.debug("in AsynGeneDataTools()");

        this.pool=pool;
        this.chrom=chr;
        this.minCoord=min;
        this.maxCoord=max;
        this.arrayTypeID=arrayTypeID;
        this.rnaDatasetID=rnaDS_ID;
        this.ucscDB=ucscDB;
        this.ensemblPath=ensemblPath;
        this.usageID=usageID;
        this.org=organism;
        this.runAGDT=runAGDT;

        this.genomeVer=genomeVer;
        this.isEnsemblGene=isEnsemblGene;
        this.pool = pool;
        dbPropertiesFile = (String) session.getAttribute("dbPropertiesFile");
        ensemblDBPropertiesFile = (String) session.getAttribute("ensDbPropertiesFile");
        mongoDBPropertiesFile = (String)session.getAttribute("mongoDbPropertiesFile");
        //log.debug("db");
        this.perlDir = (String) session.getAttribute("perlDir") + "scripts/";
        this.perlEnvVar=(String)session.getAttribute("perlEnvVar");
        //log.debug("userFilesRoot");
        this.urlPrefix = (String) session.getAttribute("mainURL");
        if (urlPrefix.endsWith(".jsp")) {
            urlPrefix = urlPrefix.substring(0, urlPrefix.lastIndexOf("/") + 1);
        }
    }



    public void run() throws RuntimeException {
        done=false;
        createRegionImagesXMLFiles(outputDir,org,genomeVer,ensemblPath,arrayTypeID,rnaDatasetID,ucscDB);
        if(runAGDT) {
            AsyncGeneDataTools agdt;
            agdt = new AsyncGeneDataTools(session, pool, outputDir, chrom, minCoord, maxCoord, arrayTypeID, rnaDatasetID, usageID, genomeVer, false,"");
            agdt.start();
            try {
                agdt.join();
            } catch (InterruptedException e) {
                e.printStackTrace();
                log.error("Error waiting on AsyncGeneDataTools:" + chrom + ":" + minCoord + "-" + maxCoord + ":", e);
            }
        }
        done=true;
    }

    public boolean createRegionImagesXMLFiles(String folderName,String organism,String genomeVer,String ensemblPath,int arrayTypeID,int rnaDatasetID,String ucscDB){
        boolean completedSuccessfully=false;
        try{
            int publicUserID=new User().getUser_id("public",pool);
            Properties myProperties = new Properties();
            File myPropertiesFile = new File(dbPropertiesFile);
            myProperties.load(new FileInputStream(myPropertiesFile));
            String dsn="dbi:"+myProperties.getProperty("PLATFORM") +":database="+myProperties.getProperty("DATABASE")+":host="+myProperties.getProperty("HOST");
            String dbUser=myProperties.getProperty("USER");
            String dbPassword=myProperties.getProperty("PASSWORD");

            File ensPropertiesFile = new File(ensemblDBPropertiesFile);
            Properties myENSProperties = new Properties();
            myENSProperties.load(new FileInputStream(ensPropertiesFile));
            String ensHost=myENSProperties.getProperty("HOST");
            String ensPort=myENSProperties.getProperty("PORT");
            String ensUser=myENSProperties.getProperty("USER");
            String ensPassword=myENSProperties.getProperty("PASSWORD");

            File mongoPropertiesFile = new File(mongoDBPropertiesFile);
            Properties myMongoProperties = new Properties();
            myMongoProperties.load(new FileInputStream(mongoPropertiesFile));
            String mongoHost=myMongoProperties.getProperty("HOST");
            String mongoUser=myMongoProperties.getProperty("USER");
            String mongoPassword=myMongoProperties.getProperty("PASSWORD");

            //construct perl Args
            String[] perlArgs = new String[25];
            perlArgs[0] = "perl";
            perlArgs[1] = perlDir + "writeXML_Region.pl";
            perlArgs[2] = "blank";
            perlArgs[3] = outputDir;
            perlArgs[4] = folderName;
            if (organism.equals("Rn")) {
                perlArgs[5] = "Rat";
            } else if (organism.equals("Mm")) {
                perlArgs[5] = "Mouse";
            }
            perlArgs[6] = "Core";
            if(chrom.startsWith("chr")){
                chrom=chrom.substring(3);
            }
            perlArgs[7] = chrom;
            perlArgs[8] = Integer.toString(minCoord);
            perlArgs[9] = Integer.toString(maxCoord);
            perlArgs[10] = Integer.toString(arrayTypeID);
            perlArgs[11] = Integer.toString(rnaDatasetID);
            perlArgs[12] = Integer.toString(publicUserID);
            perlArgs[13] = genomeVer;
            perlArgs[14] = dsn;
            perlArgs[15] = dbUser;
            perlArgs[16] = dbPassword;
            perlArgs[17] = ucscDB;
            perlArgs[18] = ensHost;
            perlArgs[19] = ensPort;
            perlArgs[20] = ensUser;
            perlArgs[21] = ensPassword;
            perlArgs[22] = mongoHost;
            perlArgs[23] = mongoUser;
            perlArgs[24] = mongoPassword;


            //set environment variables so you can access oracle pulled from perlEnvVar session variable which is a comma separated list
            String[] envVar=perlEnvVar.split(",");

            for (int i = 0; i < envVar.length; i++) {
                if(envVar[i].contains("/ensembl")){
                    envVar[i]=envVar[i].replaceAll("/ensembl","/"+ensemblPath);
                }
                log.debug(i + " EnvVar::" + envVar[i]);
            }


            //construct ExecHandler which is used instead of Perl Handler because environment variables were needed.
            myExec_session = new ExecHandler(perlDir, perlArgs, envVar, outputDir+"genRegionAsync");
            boolean exception=false;
            try {

                myExec_session.runExec();

            } catch (ExecException e) {
                exception=true;
                log.error("In Exception of run writeXML_Region.pl Exec_session", e);
                //setError("Running Perl Script to get Gene and Transcript details/images.");
                Email myAdminEmail = new Email();
                myAdminEmail.setSubject("Exception thrown in Exec_session");
                myAdminEmail.setContent("There was an error while running "
                        + perlArgs[1] + " (" + perlArgs[2] +" , "+perlArgs[3]+" , "+perlArgs[4]+" , "+perlArgs[5]+" , "+perlArgs[6]+","+perlArgs[7]+","+perlArgs[8]+","+perlArgs[9]+","+perlArgs[10]+","+perlArgs[11]+
                        ")\n\n"+myExec_session.getErrors());
                try {
                    myAdminEmail.sendEmailToAdministrator((String) session.getAttribute("adminEmail"));
                } catch (Exception mailException) {
                    log.error("error sending message", mailException);
                    try {
                        myAdminEmail.sendEmailToAdministrator("");
                    } catch (Exception mailException1) {
                        //throw new RuntimeException();
                    }
                }
            }

            String errors=myExec_session.getErrors();
            log.debug("ERRORS:\n:"+errors+":");
            if(!exception && errors!=null && !(errors.equals(""))){
                Email myAdminEmail = new Email();
                myAdminEmail.setSubject("Exception thrown in Exec_session");
                myAdminEmail.setContent("There was an error while running "
                        + perlArgs[1] + " (" + perlArgs[2] +" , "+perlArgs[3]+" , "+perlArgs[4]+" , "+perlArgs[5]+" , "+perlArgs[6]+
                        ")\n\n"+errors);
                try {
                    myAdminEmail.sendEmailToAdministrator((String) session.getAttribute("adminEmail"));
                } catch (Exception mailException) {
                    log.error("error sending message", mailException);
                    try {
                        myAdminEmail.sendEmailToAdministrator("");
                    } catch (Exception mailException1) {
                        //throw new RuntimeException();
                    }
                }
            }else{
                completedSuccessfully=true;
            }
        }catch(Exception e){
            log.error("Error getting DB properties or Public User ID.",e);
            String fullerrmsg=e.getMessage();
            StackTraceElement[] tmpEx=e.getStackTrace();
            for(int i=0;i<tmpEx.length;i++){
                fullerrmsg=fullerrmsg+"\n"+tmpEx[i];
            }
            Email myAdminEmail = new Email();
            myAdminEmail.setSubject("Exception thrown in GeneDataTools.java");
            myAdminEmail.setContent("There was an error setting up to run writeXML_Region.pl\n\nFull Stacktrace:\n"+fullerrmsg);
            try {
                myAdminEmail.sendEmailToAdministrator((String) session.getAttribute("adminEmail"));
            } catch (Exception mailException) {
                log.error("error sending message", mailException);
                try {
                    myAdminEmail.sendEmailToAdministrator("");
                } catch (Exception mailException1) {
                    //throw new RuntimeException();
                }
            }
        }
        return completedSuccessfully;
    }



    public boolean isDone(){
        return done;
    }


}


