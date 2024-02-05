package edu.ucdenver.ccp.PhenoGen.tools.analysis;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import javax.mail.MessagingException;
import javax.mail.SendFailedException;
import javax.servlet.http.HttpSession;

import edu.ucdenver.ccp.util.Debugger;
import edu.ucdenver.ccp.PhenoGen.data.Dataset;
import edu.ucdenver.ccp.PhenoGen.data.Dataset.DatasetVersion;
import edu.ucdenver.ccp.PhenoGen.data.User;
import edu.ucdenver.ccp.PhenoGen.driver.ExecHandler;
import edu.ucdenver.ccp.PhenoGen.web.mail.Email;
import edu.ucdenver.ccp.PhenoGen.driver.RException;
import edu.ucdenver.ccp.PhenoGen.driver.R_session;
import edu.ucdenver.ccp.PhenoGen.tools.analysis.GeneLoc;
import edu.ucdenver.ccp.util.ObjectHandler;
import edu.ucdenver.ccp.util.sql.PropertiesConnection;
import edu.ucdenver.ccp.util.FileHandler;

/* for handling exceptions in Threads */
import au.com.forward.threads.ThreadReturn;
import au.com.forward.threads.ThreadInterruptedException;
import au.com.forward.threads.ThreadException;
import edu.ucdenver.ccp.PhenoGen.driver.ExecException;

import java.io.*;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.DecimalFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Properties;
import java.util.logging.Level;
import javax.sql.DataSource;


/* for logging messages */
import org.apache.log4j.Logger;

public class AsyncGenerateTrack extends Thread {
    private static int GENERATE_TRACK_XML = 1;
    private static int GENERATE_CUSTOM_REMOTE_TRACK_XML = 2;
    private static int GENERATE_CUSTOM_BED_TRACK_XML = 3;
    private static int GENERATE_CUSTOM_BEDGRAPH_TRACK_XML = 4;
    private HttpSession session = null;
    private Logger log = null;
    private GeneDataTools gdt = null;
    private String userFilesRoot = "";
    private String urlPrefix = "";
    private String ucscDir = "";
    private DataSource pool = null;
    private String dbPropertiesFile = null;
    private String mongoDBPropertiesFile = null;
    private String outputDir = "";
    private String chrom = "";
    private String genomeVer = "";
    private String track = "";
    private String panel = "";
    private String organism = "";
    private String bedFile = "";
    private String outFile = "";
    private String type = "";
    private String web = "";
    private String version = "";
    private int countType = 0;

    private int minCoord = 0;
    private int maxCoord = 0;
    private int arrayTypeID = 0;
    private int rnaDatasetID = 0;
    private int binSize;
    private boolean done = false;
    private boolean isEnsemblGene = true;
    private String[] tissues = new String[2];
    private ExecHandler myExec_session = null;
    private int execType;
    private String hashValue = "";
    private List threadList;
    boolean doneThread = false;
    int maxThreadCount = 4;

    public AsyncGenerateTrack(GeneDataTools gdt, HttpSession inSession, DataSource pool) {
        this.session = inSession;
        this.gdt = gdt;
        this.threadList = gdt.getThreadList();
        this.pool = pool;
        log = Logger.getRootLogger();
    }

    public void setupGenerateTrackXML(String chr, int min, int max, String panel, String track, String org, String genomeVer, int rnaDatasetID, int arrayTypeID, String folderName, int binSize, String version, int countType, String hashValue) {
        log.debug("in setupGenerateTrackXML");
        this.chrom = chr;
        this.minCoord = min;
        this.maxCoord = max;
        this.arrayTypeID = arrayTypeID;
        this.rnaDatasetID = rnaDatasetID;
        this.genomeVer = genomeVer;
        this.track = track;
        this.panel = panel;
        this.organism = org;
        this.outputDir = folderName;
        this.binSize = binSize;
        this.version = version;
        this.countType = countType;
        this.hashValue = hashValue;
        this.execType = this.GENERATE_TRACK_XML;
        log.debug("END setupGenerateTrackXML");
    }

    public void setupGenerateCustomRemoteTrackXML(String chr, int min, int max, String track, String org, String folderName, String bedFile, String outputFile, String type, String web, int binSize, String hashValue) {
        log.debug("in setupGenerateCustomRemoteTrackXML");
        this.chrom = chr;
        this.minCoord = min;
        this.maxCoord = max;
        this.track = track;
        this.organism = org;
        this.arrayTypeID = arrayTypeID;
        this.rnaDatasetID = rnaDatasetID;
        this.genomeVer = genomeVer;
        this.outputDir = folderName;
        this.bedFile = bedFile;
        this.outFile = outputFile;
        this.type = type;
        this.web = web;
        this.binSize = binSize;
        this.hashValue = hashValue;
        this.execType = this.GENERATE_CUSTOM_REMOTE_TRACK_XML;
    }

    public void setupGenerateCustomBedTrackXML(String chr, int min, int max, String track, String org, String folderName, String bedFile, String outputFile, String hashValue) {
        log.debug("in setupGenerateCustomBedTrackXML()");
        this.chrom = chr;
        this.minCoord = min;
        this.maxCoord = max;
        this.track = track;
        this.organism = org;
        this.outputDir = folderName;
        this.bedFile = bedFile;
        this.outFile = outputFile;
        this.hashValue = hashValue;
        this.execType = this.GENERATE_CUSTOM_BED_TRACK_XML;
    }

    public void setupGenerateCustomBedGraphTrackXML(String chr, int min, int max, String track, String org, String folderName, String bedFile, String outputFile, int binSize, String hashValue) {
        log.debug("in setupGenerateCustomBedGraphTrackXML()");
        this.chrom = chr;
        this.minCoord = min;
        this.maxCoord = max;
        this.track = track;
        this.organism = org;
        this.outputDir = folderName;
        this.bedFile = bedFile;
        this.outFile = outputFile;
        this.binSize = binSize;
        this.hashValue = hashValue;
        this.execType = this.GENERATE_CUSTOM_BEDGRAPH_TRACK_XML;
    }

    private String generateFileName() {
        String retPathFile = "";
        String tmpOutputDir = gdt.getFullPath() + "tmpData/browserCache/" + genomeVer + "/regionData/" + outputDir + "/";
        String countType = "";
        String tmpType = "";
        if (track.indexOf("illumina") > -1 || track.indexOf("helicos") > -1) {
            if (track.indexOf("_") > -1) {
                String ver = track.substring(track.indexOf("_") + 1);
                if (ver.indexOf(";") > -1) {
                    String tmpVer = ver.substring(0, ver.indexOf(";"));
                    countType = ver.substring(ver.indexOf(";") + 1);
                    ver = tmpVer;
                }
                tmpType = type.substring(0, type.indexOf("_"));
            } else if (type.indexOf(";") > -1) {
                countType = type.substring(type.indexOf(";") + 1);
                tmpType = type.substring(0, type.indexOf(";"));
            }
            if (countType.indexOf(";") > -1) {
                if (countType.indexOf(";") == 0) {
                    countType = countType.substring(1);
                }
                if (countType.indexOf(";") > -1) {
                    countType = countType.substring(0, countType.indexOf(";"));
                }
            }

            if (binSize > 0) {
                if (!countType.equals("")) {
                    retPathFile = tmpOutputDir + "tmp/" + minCoord + "_" + maxCoord + ".bincount." + binSize + "." + tmpType + "." + countType + ".xml";
                } else {
                    retPathFile = tmpOutputDir + "tmp/" + minCoord + "_" + maxCoord + ".bincount." + binSize + "." + tmpType + ".xml";
                }
            } else {
                retPathFile = tmpOutputDir + minCoord + "_" + maxCoord + ".count." + track + "." + tmpType + ".xml";
            }
        }
        return retPathFile;
    }

    private boolean checkIfExistsNonZero(String path) {
        boolean exists = false;

        return exists;
    }

    public void run() throws RuntimeException {
        doneThread = false;
        Thread thisThread = Thread.currentThread();
        String outputTrackFile = this.generateFileName();
        File testFile = new File(outputTrackFile);
        if (!testFile.exists() || testFile.length() <= 0) {
            log.debug("AsyncGenerateTrack - running");

            //wait for other Expr threads to finish
            boolean waiting = true;
            int myIndex = -1;
            if (threadList.size() > 0) {
                log.debug("AsyncGenerateTrack - non-zero threadlist");
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
                            thisThread.sleep(1000);
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
            try {
                if (execType == this.GENERATE_TRACK_XML) {
                    gdt.generateXMLTrack(chrom, minCoord, maxCoord, panel, track, organism, genomeVer, rnaDatasetID, arrayTypeID, outputDir, binSize, version, countType);
                } else if (execType == this.GENERATE_CUSTOM_REMOTE_TRACK_XML) {
                    gdt.generateCustomRemoteXMLTrack(chrom, minCoord, maxCoord, track, organism, outputDir, bedFile, outFile, type, web, binSize);
                } else if (execType == this.GENERATE_CUSTOM_BED_TRACK_XML) {
                    gdt.generateCustomBedXMLTrack(chrom, minCoord, maxCoord, track, organism, outputDir, bedFile, outFile);
                } else if (execType == this.GENERATE_CUSTOM_BEDGRAPH_TRACK_XML) {
                    gdt.generateCustomBedGraphXMLTrack(chrom, minCoord, maxCoord, track, organism, outputDir, bedFile, outFile, binSize);
                }
                done = true;
                log.debug("AsyncGeneDataTools DONE");
            } catch (Exception ex) {
                done = true;

                String fullerrmsg = ex.getMessage();
                StackTraceElement[] tmpEx = ex.getStackTrace();
                for (int i = 0; i < tmpEx.length; i++) {
                    fullerrmsg = fullerrmsg + "\n" + tmpEx[i];
                }
                Email myAdminEmail = new Email();
                myAdminEmail.setSubject("Exception thrown in AsyncGeneDataTools");
                myAdminEmail.setContent("There was an error while running AsyncGeneDataTools \nStackTrace:\n" + fullerrmsg);
                try {
                    myAdminEmail.sendEmailToAdministrator((String) session.getAttribute("adminEmail"));
                } catch (Exception mailException) {
                    log.error("error sending message", mailException);
                    throw new RuntimeException();
                }
            }
        }
        done = true;
        doneThread = true;
        gdt.removeRunning(hashValue);
        threadList.remove(thisThread);
    }

    public boolean isDone() {
        return done;
    }
}