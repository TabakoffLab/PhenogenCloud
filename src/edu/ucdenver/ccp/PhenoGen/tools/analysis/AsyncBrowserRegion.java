package edu.ucdenver.ccp.PhenoGen.tools.analysis;


import edu.ucdenver.ccp.PhenoGen.data.User;
import edu.ucdenver.ccp.PhenoGen.driver.ExecHandler;
import edu.ucdenver.ccp.PhenoGen.web.mail.Email;
import edu.ucdenver.ccp.PhenoGen.driver.ExecException;

import java.io.*;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.*;
import javax.sql.DataSource;

import org.apache.log4j.Logger;

import javax.servlet.http.HttpSession;

public class AsyncBrowserRegion extends Thread {
    private String[] rErrorMsg = null;
    private HttpSession session = null;
    private Logger log = null;
    private String userFilesRoot = "";
    private String urlPrefix = "";
    private String ucscDir = "";
    private DataSource pool = null;
    private String dbPropertiesFile = null;
    private String mongoDBPropertiesFile = null;
    private String ensemblDBPropertiesFile = null;
    private String ucscDBVerPropertiesFile = null;

    private String outputDir = "";
    private String chrom = "";
    private String genomeVer = "";
    private String perlDir = "";
    private String perlEnvVar = "";
    private String ucscDB = "";
    private String org = "";
    private String dataVer = "";

    private int minCoord = 0;
    private int maxCoord = 0;
    private int arrayTypeID = 0;
    private int rnaDatasetID = 0;
    private int usageID = -1;
    private boolean done = false;
    private boolean runAGDT = false;
    private boolean isEnsemblGene = true;
    //private String updateSQL="update TRANS_DETAIL_USAGE set TIME_ASYNC_GENE_DATA_TOOLS=? , RESULT=? where TRANS_DETAIL_ID=?";
    private String[] tissues = new String[2];
    private ExecHandler myExec_session = null;
    private List threadList;
    boolean doneThread = false;
    int maxThreadCount = 3;
    private GeneDataTools gdt = null;


    public AsyncBrowserRegion(HttpSession inSession, DataSource pool, String organism, String outputDir, String chr, int min, int max, int arrayTypeID, int rnaDS_ID, String genomeVer, String ucscDB, String ensemblPath, int usageID, boolean runAGDT, GeneDataTools gdt, String dataVer) {
        this.session = inSession;
        this.outputDir = outputDir;
        this.threadList = gdt.getThreadList();
        log = Logger.getRootLogger();
        log.debug("in AsynGeneDataTools()");

        this.pool = pool;
        this.chrom = chr;
        this.minCoord = min;
        this.maxCoord = max;
        this.arrayTypeID = arrayTypeID;
        this.rnaDatasetID = rnaDS_ID;
        this.ucscDB = ucscDB;
        this.usageID = usageID;
        this.org = organism;
        this.runAGDT = runAGDT;
        this.gdt = gdt;
        this.threadList = gdt.getThreadList();

        this.genomeVer = genomeVer;
        this.dataVer = dataVer;
        this.isEnsemblGene = isEnsemblGene;
        this.pool = pool;
        dbPropertiesFile = (String) session.getAttribute("dbPropertiesFile");
        ensemblDBPropertiesFile = (String) session.getAttribute("ensDbPropertiesFile");
        mongoDBPropertiesFile = (String) session.getAttribute("mongoDbPropertiesFile");
        ucscDBVerPropertiesFile = (String) session.getAttribute("ucscDbPropertiesFile");
        //log.debug("db");
        this.perlDir = (String) session.getAttribute("perlDir") + "scripts/";
        this.perlEnvVar = (String) session.getAttribute("perlEnvVar");
        //log.debug("userFilesRoot");
        this.urlPrefix = (String) session.getAttribute("mainURL");
        if (urlPrefix.endsWith(".jsp")) {
            urlPrefix = urlPrefix.substring(0, urlPrefix.lastIndexOf("/") + 1);
        }
    }


    public void run() throws RuntimeException {
        doneThread = false;
        Thread thisThread = Thread.currentThread();
        //wait for other Expr threads to finish
        boolean waiting = true;
        int myIndex = -1;
        if (threadList.size() > 0) {
            while (waiting) {
                int waitingOnCount = 0;
                boolean reachedMySelf = false;
                for (int i = 0; i < threadList.size() && !reachedMySelf; i++) {
                    if (thisThread.equals(threadList.get(i))) {
                        reachedMySelf = true;
                        myIndex = i;
                    } else {
                        if (((Thread) threadList.get(i)).isAlive()) {
                            waitingOnCount++;
                        }
                    }
                }
                if (waitingOnCount < maxThreadCount) {
                    waiting = false;
                } else {
                    try {
                        //log.debug("WAITING PREVTHREAD");
                        thisThread.sleep(2000);
                    } catch (InterruptedException er) {
                        log.error("wait interrupted", er);
                    }
                }
            }
        }
        Date start = new Date();
        //try{
        log.debug("STARTING");
        done = false;
        createRegionImagesXMLFiles(outputDir, org, genomeVer, arrayTypeID, rnaDatasetID, ucscDB, dataVer);
        if (runAGDT) {
            AsyncGeneDataTools agdt;
            agdt = new AsyncGeneDataTools(session, pool, outputDir, chrom, minCoord, maxCoord, arrayTypeID, rnaDatasetID, usageID, genomeVer, false, dataVer, "", gdt);
            agdt.start();
            try {
                agdt.join();
            } catch (InterruptedException e) {
                e.printStackTrace();
                log.error("Error waiting on AsyncGeneDataTools:" + chrom + ":" + minCoord + "-" + maxCoord + ":", e);
            }
        }
        createRegionXML(outputDir, org, genomeVer, arrayTypeID, rnaDatasetID, ucscDB, dataVer);
        done = true;
        doneThread = true;
        threadList.remove(thisThread);
    }

    public HashMap<String, String> getGenomeVersionSource(String genomeVer) {

        HashMap<String, String> hm = new HashMap<String, String>();
        String query = "select * from Browser_Genome_versions " +
                "where genome_id='" + genomeVer + "'";

        PreparedStatement ps = null;
        try (Connection conn = pool.getConnection()) {

            ps = conn.prepareStatement(query);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                hm.put("ensembl", rs.getString("ENSEMBL"));
                hm.put("ucsc", rs.getString("UCSC"));
            }
            ps.close();
        } catch (SQLException ex) {
            log.error("SQL Exception retreiving datasources for genome Version=" + genomeVer, ex);

        }

        return hm;

    }

    public boolean createRegionImagesXMLFiles(String folderName, String organism, String genomeVer, int arrayTypeID, int rnaDatasetID, String ucscDB, String dataVer) {
        boolean completedSuccessfully = false;
        try {
            HashMap<String, String> source = this.getGenomeVersionSource(genomeVer);
            String ensemblPath = source.get("ensembl");
            int publicUserID = new User().getUser_id("public", pool);

            String panel = "BNLX/SHRH";
            if (organism.equals("Mm")) {
                panel = "ILS/ISS";
            }

            Properties myProperties = new Properties();
            File myPropertiesFile = new File(dbPropertiesFile);
            myProperties.load(new FileInputStream(myPropertiesFile));
            String port = myProperties.getProperty("PORT");
            String dsn = "dbi:mysql:database=" + myProperties.getProperty("DATABASE") + ";host=" + myProperties.getProperty("HOST") + ";port=" + port;
            String dbUser = myProperties.getProperty("USER");
            String dbPassword = myProperties.getProperty("PASSWORD");

            File ensPropertiesFile = new File(ensemblDBPropertiesFile);
            Properties myENSProperties = new Properties();
            myENSProperties.load(new FileInputStream(ensPropertiesFile));
            String ensHost = myENSProperties.getProperty("HOST");
            String ensPort = myENSProperties.getProperty("PORT");
            String ensUser = myENSProperties.getProperty("USER");
            String ensPassword = myENSProperties.getProperty("PASSWORD");

            File mongoPropertiesFile = new File(mongoDBPropertiesFile);
            Properties myMongoProperties = new Properties();
            myMongoProperties.load(new FileInputStream(mongoPropertiesFile));
            String mongoHost = myMongoProperties.getProperty("HOST");
            String mongoUser = myMongoProperties.getProperty("USER");
            String mongoPassword = myMongoProperties.getProperty("PASSWORD");

            Properties myVerProperties = new Properties();
            log.debug("UCSC file:" + ucscDBVerPropertiesFile);
            File myVerPropertiesFile = new File(ucscDBVerPropertiesFile);
            myVerProperties.load(new FileInputStream(myVerPropertiesFile));
            log.debug("read prop");
            String ucscHost = myVerProperties.getProperty("HOST");
            String ucscPort = myVerProperties.getProperty("PORT");
            String ucscUser = myVerProperties.getProperty("USER");
            String ucscPassword = myVerProperties.getProperty("PASSWORD");

            String ensDsn = "DBI:mysql:database=" + source.get("ensembl") + ";host=" + ensHost + ";port=" + ensPort + ";";
            String ucscDsn = "DBI:mysql:database=" + source.get("ucsc") + ";host=" + ucscHost + ";port=" + ucscPort + ";";

            //set environment variables so you can access oracle pulled from perlEnvVar session variable which is a comma separated list
            String[] envVar = perlEnvVar.split(",");

            for (int i = 0; i < envVar.length; i++) {
                if (envVar[i].contains("/ensembl")) {
                    envVar[i] = envVar[i].replaceAll("/ensembl", "/" + ensemblPath);
                }
                log.debug(i + " EnvVar::" + envVar[i]);
            }

            callWriteTrackXML("ensemblcoding", folderName, organism, "", 1, panel, chrom, minCoord, maxCoord, publicUserID, 0, "", genomeVer, dsn, dbUser, dbPassword, ensDsn, ensHost, ensUser, ensPassword,
                    ucscDsn, ucscUser, ucscPassword, mongoHost, mongoUser, mongoPassword, envVar, dataVer);

            if (organism.equals("Rn")) {
                if (genomeVer.equals("rn5") || genomeVer.equals("rn6")) {
                    callWriteTrackXML("probe", folderName, organism, "", 1, panel, chrom, minCoord, maxCoord, publicUserID, 0, "", genomeVer, dsn, dbUser, dbPassword, ensDsn, ensHost, ensUser, ensPassword,
                            ucscDsn, ucscUser, ucscPassword, mongoHost, mongoUser, mongoPassword, envVar, dataVer);
                }
                if (genomeVer.equals("rn5")) {
                    callWriteTrackXML("braincoding", folderName, organism, "", 1, panel, chrom, minCoord, maxCoord, publicUserID, 0, "Brain", genomeVer, dsn, dbUser, dbPassword, ensDsn, ensHost, ensUser, ensPassword,
                            ucscDsn, ucscUser, ucscPassword, mongoHost, mongoUser, mongoPassword, envVar, dataVer);
                    callWriteTrackXML("brainnoncoding", folderName, organism, "", 1, panel, chrom, minCoord, maxCoord, publicUserID, 0, "Brain", genomeVer, dsn, dbUser, dbPassword, ensDsn, ensHost, ensUser, ensPassword,
                            ucscDsn, ucscUser, ucscPassword, mongoHost, mongoUser, mongoPassword, envVar, dataVer);
                } else {
                    callWriteTrackXML("brainTotal", folderName, organism, "", 1, panel, chrom, minCoord, maxCoord, publicUserID, 0, "Brain", genomeVer, dsn, dbUser, dbPassword, ensDsn, ensHost, ensUser, ensPassword,
                            ucscDsn, ucscUser, ucscPassword, mongoHost, mongoUser, mongoPassword, envVar, dataVer);
                    callWriteTrackXML("liverTotal", folderName, organism, "", 1, panel, chrom, minCoord, maxCoord, publicUserID, 0, "Liver", genomeVer, dsn, dbUser, dbPassword, ensDsn, ensHost, ensUser, ensPassword,
                            ucscDsn, ucscUser, ucscPassword, mongoHost, mongoUser, mongoPassword, envVar, dataVer);
                    callWriteTrackXML("heartTotal", folderName, organism, "", 1, panel, chrom, minCoord, maxCoord, publicUserID, 0, "Heart", genomeVer, dsn, dbUser, dbPassword, ensDsn, ensHost, ensUser, ensPassword,
                            ucscDsn, ucscUser, ucscPassword, mongoHost, mongoUser, mongoPassword, envVar, dataVer);
                    callWriteTrackXML("kidneyTotal", folderName, organism, "", 1, panel, chrom, minCoord, maxCoord, publicUserID, 0, "Kidney", genomeVer, dsn, dbUser, dbPassword, ensDsn, ensHost, ensUser, ensPassword,
                            ucscDsn, ucscUser, ucscPassword, mongoHost, mongoUser, mongoPassword, envVar, dataVer);
                    callWriteTrackXML("mergedTotal", folderName, organism, "", 1, panel, chrom, minCoord, maxCoord, publicUserID, 0, "Merged", genomeVer, dsn, dbUser, dbPassword, ensDsn, ensHost, ensUser, ensPassword,
                            ucscDsn, ucscUser, ucscPassword, mongoHost, mongoUser, mongoPassword, envVar, dataVer);
                }

            } else if (organism.equals("Mm")) {
                callWriteTrackXML("braincoding", folderName, organism, "", 1, panel, chrom, minCoord, maxCoord, publicUserID, 0, "Brain", genomeVer, dsn, dbUser, dbPassword, ensDsn, ensHost, ensUser, ensPassword,
                        ucscDsn, ucscUser, ucscPassword, mongoHost, mongoUser, mongoPassword, envVar, "");
                callWriteTrackXML("brainnoncoding", folderName, organism, "", 1, panel, chrom, minCoord, maxCoord, publicUserID, 0, "Brain", genomeVer, dsn, dbUser, dbPassword, ensDsn, ensHost, ensUser, ensPassword,
                        ucscDsn, ucscUser, ucscPassword, mongoHost, mongoUser, mongoPassword, envVar, "");
                callWriteTrackXML("qtl", folderName, organism, "", 1, panel, chrom, minCoord, maxCoord, publicUserID, 0, "", genomeVer, dsn, dbUser, dbPassword, ensDsn, ensHost, ensUser, ensPassword,
                        ucscDsn, ucscUser, ucscPassword, mongoHost, mongoUser, mongoPassword, envVar, "");
            }

            //construct ExecHandler which is used instead of Perl Handler because environment variables were needed.

        } catch (Exception e) {
            log.error("Error getting DB properties or Public User ID.", e);
            String fullerrmsg = e.getMessage();
            StackTraceElement[] tmpEx = e.getStackTrace();
            for (int i = 0; i < tmpEx.length; i++) {
                fullerrmsg = fullerrmsg + "\n" + tmpEx[i];
            }
            Email myAdminEmail = new Email();
            myAdminEmail.setSubject("Exception thrown in GeneDataTools.java");
            myAdminEmail.setContent("There was an error setting up to run writeXML_Region.pl\n\nFull Stacktrace:\n" + fullerrmsg);
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

    public boolean createRegionXML(String folderName, String organism, String genomeVer, int arrayTypeID, int rnaDatasetID, String ucscDB, String dataVer) {
        boolean completedSuccessfully = false;
        try {
            HashMap<String, String> source = this.getGenomeVersionSource(genomeVer);
            String ensemblPath = source.get("ensembl");
            int publicUserID = new User().getUser_id("public", pool);

            String panel = "BNLX/SHRH";
            if (organism.equals("Mm")) {
                panel = "ILS/ISS";
            }

            Properties myProperties = new Properties();
            File myPropertiesFile = new File(dbPropertiesFile);
            myProperties.load(new FileInputStream(myPropertiesFile));
            String port = myProperties.getProperty("PORT");
            String dsn = "dbi:mysql:database=" + myProperties.getProperty("DATABASE") + ";host=" + myProperties.getProperty("HOST") + ";port=" + port;
            String dbUser = myProperties.getProperty("USER");
            String dbPassword = myProperties.getProperty("PASSWORD");

            File ensPropertiesFile = new File(ensemblDBPropertiesFile);
            Properties myENSProperties = new Properties();
            myENSProperties.load(new FileInputStream(ensPropertiesFile));
            String ensHost = myENSProperties.getProperty("HOST");
            String ensPort = myENSProperties.getProperty("PORT");
            String ensUser = myENSProperties.getProperty("USER");
            String ensPassword = myENSProperties.getProperty("PASSWORD");

            File mongoPropertiesFile = new File(mongoDBPropertiesFile);
            Properties myMongoProperties = new Properties();
            myMongoProperties.load(new FileInputStream(mongoPropertiesFile));
            String mongoHost = myMongoProperties.getProperty("HOST");
            String mongoUser = myMongoProperties.getProperty("USER");
            String mongoPassword = myMongoProperties.getProperty("PASSWORD");

            Properties myVerProperties = new Properties();
            log.debug("UCSC file:" + ucscDBVerPropertiesFile);
            File myVerPropertiesFile = new File(ucscDBVerPropertiesFile);
            myVerProperties.load(new FileInputStream(myVerPropertiesFile));
            log.debug("read prop");
            String ucscHost = myVerProperties.getProperty("HOST");
            String ucscPort = myVerProperties.getProperty("PORT");
            String ucscUser = myVerProperties.getProperty("USER");
            String ucscPassword = myVerProperties.getProperty("PASSWORD");

            String ensDsn = "DBI:mysql:database=" + source.get("ensembl") + ";host=" + ensHost + ";port=" + ensPort + ";";
            String ucscDsn = "DBI:mysql:database=" + source.get("ucsc") + ";host=" + ucscHost + ";port=" + ucscPort + ";";

            //set environment variables so you can access oracle pulled from perlEnvVar session variable which is a comma separated list
            String[] envVar = perlEnvVar.split(",");

            for (int i = 0; i < envVar.length; i++) {
                if (envVar[i].contains("/ensembl")) {
                    envVar[i] = envVar[i].replaceAll("/ensembl", "/" + ensemblPath);
                }
                log.debug(i + " EnvVar::" + envVar[i]);
            }

            //construct perl Args
            String[] perlArgs = new String[27];
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
            if (chrom.startsWith("chr")) {
                chrom = chrom.substring(3);
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
            perlArgs[18] = ensemblPath;
            perlArgs[19] = ensHost;
            perlArgs[20] = ensPort;
            perlArgs[21] = ensUser;
            perlArgs[22] = ensPassword;
            perlArgs[23] = mongoHost;
            perlArgs[24] = mongoUser;
            perlArgs[25] = mongoPassword;
            perlArgs[26] = dataVer;


            //construct ExecHandler which is used instead of Perl Handler because environment variables were needed.
            myExec_session = new ExecHandler(perlDir, perlArgs, envVar, outputDir + "genRegionAsync");
            boolean exception = false;
            try {
                myExec_session.runExec();
                completedSuccessfully = true;
            } catch (ExecException e) {
                exception = true;
                log.error("In Exception of run writeXML_Region.pl Exec_session", e);
                //setError("Running Perl Script to get Gene and Transcript details/images.");
                Email myAdminEmail = new Email();
                myAdminEmail.setSubject("Exception thrown in Exec_session");
                myAdminEmail.setContent("There was an error while running "
                        + perlArgs[1] + " (" + perlArgs[2] + " , " + perlArgs[3] + " , " + perlArgs[4] + " , " + perlArgs[5] + " , " + perlArgs[6] + "," + perlArgs[7] + "," + perlArgs[8] + "," + perlArgs[9] + "," + perlArgs[10] + "," + perlArgs[11] +
                        ")\n\n" + myExec_session.getErrors());
                if (myExec_session.isError()) {
                    try {
                        myAdminEmail.sendEmailToAdministrator((String) session.getAttribute("adminEmail"));
                    } catch (Exception mailException) {
                        log.error("error sending message", mailException);
                        try {
                            myAdminEmail.sendEmailToAdministrator("");
                        } catch (Exception mailException1) {
                        }
                    }
                }
            }
        } catch (Exception e) {
            log.error("Error getting DB properties or Public User ID.", e);
            String fullerrmsg = e.getMessage();
            StackTraceElement[] tmpEx = e.getStackTrace();
            for (int i = 0; i < tmpEx.length; i++) {
                fullerrmsg = fullerrmsg + "\n" + tmpEx[i];
            }
            Email myAdminEmail = new Email();
            myAdminEmail.setSubject("Exception thrown in GeneDataTools.java");
            myAdminEmail.setContent("There was an error setting up to run writeXML_Region.pl\n\nFull Stacktrace:\n" + fullerrmsg);
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

    public boolean isDone() {
        return done;
    }

    private boolean callWriteTrackXML(String track, String tmpOutputDir, String organism, String version, int countType, String panel, String chromosome,
                                      int min, int max, int publicUserID, int binSize, String tissue, String genomeVer, String dsn, String dbUser, String dbPassword, String
                                              ensDsn, String ensHost, String ensUser, String ensPassword,
                                      String ucscDsn, String ucscUser, String ucscPassword, String mongoHost, String mongoUser, String mongoPassword, String[] envVar, String dataVer) {
        boolean completedSuccessfully = false;
        //construct perl Args
        //construct perl Args

        log.debug("running:" + track);
        String[] perlArgs = new String[27];
        perlArgs[0] = "perl";
        perlArgs[1] = perlDir + "writeXML_Track.pl";
        perlArgs[2] = tmpOutputDir;
        if (organism.equals("Rn")) {
            perlArgs[3] = "Rat";
        } else if (organism.equals("Mm")) {
            perlArgs[3] = "Mouse";
        }
        String tmpTrack = track;
        if (!version.equals("")) {
            tmpTrack = tmpTrack + "_" + version;
        }
        if (track.indexOf("illumina") > -1) {
            if (countType == 1) {
                tmpTrack = tmpTrack + ";Total;";
            } else if (countType == 2) {
                tmpTrack = tmpTrack + ";Norm;";
            }
        }
        perlArgs[4] = tmpTrack;
        perlArgs[5] = panel;
        perlArgs[6] = chromosome;
        perlArgs[7] = Integer.toString(min);
        perlArgs[8] = Integer.toString(max);
        perlArgs[9] = Integer.toString(publicUserID);
        perlArgs[10] = Integer.toString(binSize);
        perlArgs[11] = tissue;
        perlArgs[12] = genomeVer;
        perlArgs[13] = dsn;
        perlArgs[14] = dbUser;
        perlArgs[15] = dbPassword;
        perlArgs[16] = ensDsn;
        perlArgs[17] = ensHost;
        perlArgs[18] = ensUser;
        perlArgs[19] = ensPassword;
        perlArgs[20] = ucscDsn;
        perlArgs[21] = ucscUser;
        perlArgs[22] = ucscPassword;
        perlArgs[23] = mongoHost;
        perlArgs[24] = mongoUser;
        perlArgs[25] = mongoPassword;
        perlArgs[26] = dataVer;

        myExec_session = new ExecHandler(perlDir, perlArgs, envVar, outputDir + "genRegionAsync");
        boolean exception = false;
        try {
            log.debug("about to execute :" + track);
            myExec_session.runExec();
            log.debug("after execute :" + track);
        } catch (ExecException e) {
            exception = true;
            log.error("In Exception of run writeXML_Region.pl Exec_session", e);
            //setError("Running Perl Script to get Gene and Transcript details/images.");
            Email myAdminEmail = new Email();
            myAdminEmail.setSubject("Exception thrown in Exec_session");
            myAdminEmail.setContent("There was an error while running "
                    + perlArgs[1] + " (" + perlArgs[2] + " , " + perlArgs[3] + " , " + perlArgs[4] + " , " + perlArgs[5] + " , " + perlArgs[6] + "," + perlArgs[7] + "," + perlArgs[8] + "," + perlArgs[9] + "," + perlArgs[10] + "," + perlArgs[11] +
                    ")\n\n" + myExec_session.getErrors());
            if (myExec_session.isError()) {
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
        }

        String errors = myExec_session.getErrors();
        log.debug("ERRORS:\n:" + errors + ":");
        if (myExec_session.isError() && !exception && errors != null && !(errors.equals(""))) {
            Email myAdminEmail = new Email();
            myAdminEmail.setSubject("Exception thrown in Exec_session");
            myAdminEmail.setContent("There was an error while running "
                    + perlArgs[1] + " (" + perlArgs[2] + " , " + perlArgs[3] + " , " + perlArgs[4] + " , " + perlArgs[5] + " , " + perlArgs[6] +
                    ")\n\n" + errors);
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
        } else {
            completedSuccessfully = true;
        }
        return completedSuccessfully;
    }


}


