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
    private static int GENERATE_TRACK_XML=1;
    private static int GENERATE_CUSTOM_REMOTE_TRACK_XML=2;
    private static int GENERATE_CUSTOM_BED_TRACK_XML=3;
    private static int GENERATE_CUSTOM_BEDGRAPH_TRACK_XML=4;
    private HttpSession session=null;
    private Logger log = null;
    private GeneDataTools gdt=null;
    private String userFilesRoot = "";
    private String urlPrefix = "";
    private String ucscDir="";
    private DataSource pool=null;
    private String dbPropertiesFile=null;
    private String mongoDBPropertiesFile=null;
    private String outputDir="";
    private String chrom="";
    private String genomeVer="";
    private String track="";
    private String panel="";
    private String organism="";
    private String bedFile="";
    private String outFile="";
    private String type="";
    private String web="";

    private int minCoord=0;
    private int maxCoord=0;
    private int arrayTypeID=0;
    private int rnaDatasetID=0;
    private int binSize;
    private boolean done=false;
    private boolean isEnsemblGene=true;
    private String[] tissues=new String[2];
    private ExecHandler myExec_session = null;
    private int execType;

    public AsyncGenerateTrack(GeneDataTools gdt,HttpSession inSession,DataSource pool){
        this.session = inSession;
        this.gdt=gdt;
        this.pool=pool;
        log = Logger.getRootLogger();
    }

    public void setupGenerateTrackXML(String chr,int min,int max,String panel,String track,String org,String genomeVer,int rnaDatasetID,int arrayTypeID,String folderName,int binSize) {
        log.debug("in AsynGeneDataTools()");
        this.chrom=chr;
        this.minCoord=min;
        this.maxCoord=max;
        this.arrayTypeID=arrayTypeID;
        this.rnaDatasetID=rnaDatasetID;
        this.genomeVer=genomeVer;
        this.track=track;
        this.panel=panel;
        this.organism=org;
        this.outputDir=folderName;
        this.binSize=binSize;
        this.execType=this.GENERATE_TRACK_XML;
    }

    public void setupGenerateCustomRemoteTrackXML(String chr,int min,int max,String track,String org,String folderName,String bedFile,String outputFile,String type,String web,int binSize) {
        log.debug("in AsynGeneDataTools()");
        this.chrom = chr;
        this.minCoord = min;
        this.maxCoord = max;
        this.track=track;
        this.organism=org;
        this.arrayTypeID = arrayTypeID;
        this.rnaDatasetID = rnaDatasetID;
        this.genomeVer = genomeVer;
        this.outputDir=folderName;
        this.bedFile=bedFile;
        this.outFile=outputFile;
        this.type=type;
        this.web=web;
        this.binSize=binSize;
        this.execType=this.GENERATE_CUSTOM_REMOTE_TRACK_XML;
    }

    public void setupGenerateCustomBedTrackXML(String chr,int min,int max,String track,String org,String folderName,String bedFile, String outputFile) {
        log.debug("in AsynGeneDataTools()");
        this.chrom = chr;
        this.minCoord = min;
        this.maxCoord = max;
        this.track=track;
        this.organism=org;
        this.outputDir=folderName;
        this.bedFile=bedFile;
        this.outFile=outputFile;
        this.execType=this.GENERATE_CUSTOM_BED_TRACK_XML;
    }

    public void setupGenerateCustomBedGraphTrackXML(String chr,int min,int max,String track,String org,String folderName,String bedFile,String outputFile,int binSize) {
        log.debug("in AsynGeneDataTools()");
        this.chrom = chr;
        this.minCoord = min;
        this.maxCoord = max;
        this.track=track;
        this.organism=org;
        this.outputDir=folderName;
        this.bedFile=bedFile;
        this.outFile=outputFile;
        this.binSize=binSize;
        this.execType=this.GENERATE_CUSTOM_BEDGRAPH_TRACK_XML;
    }

    public void run() throws RuntimeException {
        done=false;
        Date start=new Date();
        try{
            if(execType==this.GENERATE_TRACK_XML){
                gdt.generateXMLTrack(chrom,minCoord,maxCoord,panel,track,organism,genomeVer,rnaDatasetID,arrayTypeID,outputDir,binSize);
            }else if(execType==this.GENERATE_CUSTOM_REMOTE_TRACK_XML){
                gdt.generateCustomRemoteXMLTrack(chrom,minCoord,maxCoord,track,organism,outputDir,bedFile,outFile,type,web,binSize);
            }else if(execType==this.GENERATE_CUSTOM_BED_TRACK_XML){
                gdt.generateCustomBedXMLTrack(chrom,minCoord,maxCoord,track,organism,outputDir,bedFile,outFile);
            }else if(execType==this.GENERATE_CUSTOM_BEDGRAPH_TRACK_XML){
                gdt.generateCustomBedGraphXMLTrack(chrom,minCoord,maxCoord,track,organism,outputDir,bedFile,outFile,binSize);
            }
            done=true;
            log.debug("AsyncGeneDataTools DONE");
        } catch (Exception ex) {
            done=true;

            String fullerrmsg=ex.getMessage();
            StackTraceElement[] tmpEx=ex.getStackTrace();
            for(int i=0;i<tmpEx.length;i++){
                fullerrmsg=fullerrmsg+"\n"+tmpEx[i];
            }
            Email myAdminEmail = new Email();
            myAdminEmail.setSubject("Exception thrown in AsyncGeneDataTools");
            myAdminEmail.setContent("There was an error while running AsyncGeneDataTools \nStackTrace:\n"+fullerrmsg);
            try {
                myAdminEmail.sendEmailToAdministrator((String) session.getAttribute("adminEmail"));
            } catch (Exception mailException) {
                log.error("error sending message", mailException);
                throw new RuntimeException();
            }
        }
        done=true;
    }

    public boolean isDone(){
        return done;
    }
}