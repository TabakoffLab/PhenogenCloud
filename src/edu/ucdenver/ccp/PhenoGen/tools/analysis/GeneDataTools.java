package edu.ucdenver.ccp.PhenoGen.tools.analysis;

//import com.sun.org.apache.xpath.internal.operations.String;
import edu.ucdenver.ccp.PhenoGen.data.Bio.*;
import edu.ucdenver.ccp.PhenoGen.driver.RException;
import edu.ucdenver.ccp.PhenoGen.driver.R_session;
import edu.ucdenver.ccp.PhenoGen.data.AsyncUpdateDataset;
import edu.ucdenver.ccp.PhenoGen.data.Dataset;
import edu.ucdenver.ccp.PhenoGen.data.User;
import edu.ucdenver.ccp.PhenoGen.driver.PerlHandler;
import edu.ucdenver.ccp.PhenoGen.driver.PerlException;
import edu.ucdenver.ccp.PhenoGen.driver.ExecHandler;
import edu.ucdenver.ccp.PhenoGen.driver.ExecException;
import edu.ucdenver.ccp.util.FileHandler;
import edu.ucdenver.ccp.util.ObjectHandler;
import edu.ucdenver.ccp.PhenoGen.tools.analysis.Statistic;
import edu.ucdenver.ccp.PhenoGen.tools.analysis.AsyncGeneDataExpr;
import edu.ucdenver.ccp.PhenoGen.tools.analysis.AsyncGeneDataTools;



import java.util.GregorianCalendar;
import java.util.Date;

import javax.servlet.http.HttpSession;
import java.sql.Connection;
import java.sql.SQLException;

import org.apache.log4j.Logger;

import edu.ucdenver.ccp.PhenoGen.web.mail.*;
import java.io.*;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Properties;
import java.util.Set;
import java.util.regex.Pattern;
import javax.sql.DataSource;





public class GeneDataTools {
    private ArrayList<Thread> threadList;
    private String[] rErrorMsg = null;
    private R_session myR_session = new R_session();
    //private PerlHandler myPerl_session=null;
    private ExecHandler myExec_session = null;
    private HttpSession session = null;
    private User userLoggedIn = null;
    private DataSource pool = null;
    //private DataSource poolRO = null;
    private Logger log = null;
    private String perlDir = "", fullPath = "";
    private String rFunctDir = "";
    private String userFilesRoot = "";
    private String urlPrefix = "";
    private int validTime=7*24*60*60*1000;
    private String perlEnvVar="";
    private String ucscDir="";
    private String ucscGeneDir="";
    private String bedDir="";
    private String geneSymbol="";
    private String ucscURL="";
    private String deMeanURL="";
    private String deFoldDiffURL="";
    private String chrom="";
    private String dbPropertiesFile="";
    private String ensemblDBPropertiesFile="";
    private String ucscDBVerPropertiesFile="";
    private String mongoDBPropertiesFile="";
    private String regionEQTLErrorMessage="";
    private int minCoord=0;
    private int maxCoord=0;
    FileHandler myFH=new FileHandler();
    private int usageID=-1;
    private int maxThreadRunning=1;
    String outputDir="";
    private boolean pathReady=false;
    
    private String  returnGenURL="";
    private String  returnUCSCURL= "";
    private String  returnOutputDir="";
    private String returnGeneSymbol="";
    private boolean isSessionSet=false;

    //private String insertUsage="insert into TRANS_DETAIL_USAGE (INPUT_ID,IDECODER_RESULT,RUN_DATE,ORGANISM) values (?,?,?,?)";
    //String updateSQL="update TRANS_DETAIL_USAGE set TIME_TO_RETURN=? , RESULT=? where TRANS_DETAIL_ID=?";
    private HashMap eQTLRegions=new HashMap();
    //HashMap<String,HashMap> cacheHM=new HashMap<String,HashMap>();
    //ArrayList<String> cacheList=new ArrayList<String>();
    int maxCacheList=5;

    
    

    public GeneDataTools() {
        log = Logger.getRootLogger();
    }
    
    public boolean isPathReady(){
        return this.pathReady;
    }

    public boolean isSessionSet() { return this.isSessionSet; }
    
    public void resetPathReady(){
        this.pathReady=false;
    }
    
    public int[] getOrganismSpecificIdentifiers(String organism,String genomeVer){
        
            int[] ret=new int[2];
            String organismLong="Mouse";
            if(organism.equals("Rn")){
                organismLong="Rat";
            }
            String atQuery="select Array_type_id from array_types "+
                        "where array_name like 'Affymetrix GeneChip "+organismLong+" Exon 1.0 ST Array'";
            /*
            *  This does only look for the brain RNA dataset id.  Right now the tables link that RNA Dataset ID to
            *  the other datasets.  This means finding the right organism and genome version for now is sufficient without
            *  regard to tissues as all other tables link to the brain dataset since we have brain for both supported organisms
            */
            String rnaIDQuery="select rna_dataset_id from RNA_DATASET "+
                        "where organism = '"+organism+"' and tissue='Brain' and strain_panel='BNLX/SHRH' and visible=1 and genome_id='"+genomeVer+"' order by BUILD_VERSION DESC";
            log.debug("\nRNAID Query:\n"+rnaIDQuery);
            Connection conn=null;
            PreparedStatement ps=null;
            try {
                conn=pool.getConnection();
                ps = conn.prepareStatement(atQuery);
                ResultSet rs = ps.executeQuery();
                if(rs.next()){
                    ret[0]=rs.getInt(1);
                }
                ps.close();
            } catch (SQLException ex) {
                log.error("SQL Exception retreiving Array_Type_ID from array_types for Organism="+organism ,ex);
                try {
                    ps.close();
                } catch (Exception ex1) {
                   
                }
            }
            try {
                if(conn==null || conn.isClosed()){
                    conn=pool.getConnection();
                }
                ps = conn.prepareStatement(rnaIDQuery);
                ResultSet rs = ps.executeQuery();
                if(rs.next()){
                    ret[1]=rs.getInt(1);
                }
                ps.close();
                conn.close();
            } catch (SQLException ex) {
                log.error("SQL Exception retreiving RNA_dataset_ID from RNA_DATASET for Organism="+organism ,ex);
                try {
                    ps.close();
                } catch (Exception ex1) {

                }
            }finally{
                    try {
                            if(conn!=null)
                                conn.close();
                        } catch (SQLException ex) {
                        }
            }
            return ret;
        
    }
    
    public int[] getOrganismSpecificIdentifiers(String organism,String tissue,String genomeVer,String version){
        
            int[] ret=new int[2];
            String organismLong="Mouse";
            if(organism!=null && organism.equals("Rn")){
                organismLong="Rat";
            }
            if(tissue!=null && tissue.equals("Whole Brain")){
                tissue="Brain";
            }
            String atQuery="select Array_type_id from array_types "+
                        "where array_name like 'Affymetrix GeneChip "+organismLong+" Exon 1.0 ST Array'";
            
            /*
            *  This does only look for the brain RNA dataset id.  Right now the tables link that RNA Dataset ID to
            *  the other datasets.  This means finding the right organism and genome version for now is sufficient without
            *  regard to tissues as all other tables link to the brain dataset since we have brain for both supported organisms
            */
            String rnaIDQuery="select rna_dataset_id from RNA_DATASET "+
                        "where organism = '"+organism+"' and tissue='"+tissue+"' and strain_panel='BNLX/SHRH' and visible=1 and genome_id='"+genomeVer+"'";
            if(version==null || version.equals("")) {
                rnaIDQuery=rnaIDQuery+" order by BUILD_VERSION DESC";
            }else{
                rnaIDQuery=rnaIDQuery+" and BUILD_VERSION='"+version+"' ";
            }
            log.debug("\nRNAID Query:\n"+rnaIDQuery);
            PreparedStatement ps=null;
            try(Connection conn=pool.getConnection()) {

                ps = conn.prepareStatement(atQuery);
                ResultSet rs = ps.executeQuery();
                if(rs.next()){
                    ret[0]=rs.getInt(1);
                }
                ps.close();
            } catch (SQLException ex) {
                log.error("SQL Exception retreiving Array_Type_ID from array_types for Organism="+organism ,ex);

            }
            try(Connection conn=pool.getConnection()) {
                ps = conn.prepareStatement(rnaIDQuery);
                ResultSet rs = ps.executeQuery();
                if(rs.next()){
                    ret[1]=rs.getInt(1);
                }
                ps.close();
                conn.close();
            } catch (SQLException ex) {
                log.error("SQL Exception retreiving RNA_dataset_ID from RNA_DATASET for Organism="+organism ,ex);
                try {
                    ps.close();
                } catch (Exception ex1) {

                }
            }
            return ret;
    }

    public String getRNADatasetIDsforTissues(String organism,String tissueIn,String genomeVer,String version){
        String ret="";
        String organismLong="Mouse";
        if(organism.equals("Rn")){
            organismLong="Rat";
        }
        String[] list=tissueIn.split(";");
        String tissues="";
        for(int i=0;i<list.length;i++) {
            if (list[i].equals("Whole Brain")) {
                list[i] = "Brain";
            }
            if(i==0){
                tissues="'"+list[i]+"'";
            }else{
                tissues=tissues+",'"+list[i]+"'";
            }
        }
        /*
         *  This does only look for the brain RNA dataset id.  Right now the tables link that RNA Dataset ID to
         *  the other datasets.  This means finding the right organism and genome version for now is sufficient without
         *  regard to tissues as all other tables link to the brain dataset since we have brain for both supported organisms
         */
        String rnaIDQuery="select rna_dataset_id,tissue from RNA_DATASET "+
                "where organism = '"+organism+"' and tissue in ("+tissues+") and strain_panel='BNLX/SHRH' and visible=1 and genome_id='"+genomeVer+"'";
        if(version.equals("")) {
            rnaIDQuery=rnaIDQuery+" order by BUILD_VERSION DESC";
        }else{
            rnaIDQuery=rnaIDQuery+" and BUILD_VERSION='"+version+"' ";
        }
        log.debug("\nRNAID Query:\n"+rnaIDQuery);
        HashMap<String,String> hm=new HashMap<>();
        try(Connection conn=pool.getConnection()) {
            PreparedStatement ps = conn.prepareStatement(rnaIDQuery);
            ResultSet rs = ps.executeQuery();
            while(rs.next()){
                String tmpTissue=rs.getString(2);
                int tmpInt=rs.getInt(1);
                String tmp=Integer.toString(tmpInt);
                if(hm.containsKey(tmpTissue)){
                    //skip
                }else{
                    hm.put(tmpTissue,tmp);
                }
            }
            ps.close();
        } catch (SQLException ex) {
            log.error("SQL Exception retreiving RNA_dataset_ID from RNA_DATASET for Organism="+organism ,ex);

        }
        Iterator itr=hm.keySet().iterator();

        while(itr.hasNext()){
            String tmp=(String)itr.next();
            if(ret.equals("")){
                ret=hm.get(tmp);
            }else {
                ret = ret + "," + hm.get(tmp);
            }
        }
        return ret;
    }
    public String translateENStoPRN(String rnaDS,String ens){
        String ret="";

        String rnaIDQuery="select distinct merge_gene_id from rna_transcripts rt " +
                "where rt.rna_dataset_id="+rnaDS +" "+
                "and rt.rna_transcript_id in (select rna_transcript_id from rna_transcripts_annot where annotation like '"+ens+":%')";

        log.debug("\nENS to PRN ID Query:\n"+rnaIDQuery);
        try(Connection conn=pool.getConnection()) {
            PreparedStatement ps = conn.prepareStatement(rnaIDQuery);
            ResultSet rs = ps.executeQuery();
            while(rs.next()){
                String tmp=rs.getString(1);

                if(ret.equals("")){
                    ret="'"+tmp+"'";
                }else{
                    ret=ret+",'"+tmp+"'";
                }
            }
            ps.close();
        } catch (SQLException ex) {
            log.error("SQL Exception retreiving ENS ID" ,ex);

        }

        return ret;
    }

    public ArrayList<String> getTranscriptList(String geneID,String organism,String tissue,String genomeVer,String version){
        ArrayList<String> ret=new ArrayList<>();

        int[] rnaDS=getOrganismSpecificIdentifiers(organism,tissue,genomeVer,version);
        if(geneID.startsWith("ENS")){
            geneID=translateENStoPRN(Integer.toString(rnaDS[1]),geneID);
            if(geneID.length()>1 && geneID.indexOf(",")==-1) {
                geneID = geneID.substring(1, geneID.length() - 1);
            }
        }
        String trxQuery="select isoform_id,merge_isoform_id from rna_transcripts rt " +
                "where rt.rna_dataset_id="+rnaDS[1] +" ";


        if(geneID.indexOf(",")>-1){
            trxQuery= trxQuery+" and rt.gene_id in ( "+geneID+" ) or rt.merge_gene_id in ("+geneID+") ";
        }else{
            trxQuery=trxQuery+" and rt.gene_id='"+geneID+"' or rt.merge_gene_id='"+geneID+"'";
        }

        log.debug("\ntrx ID list Query:\n"+trxQuery);
        try(Connection conn=pool.getConnection()) {
            PreparedStatement ps = conn.prepareStatement(trxQuery);
            ResultSet rs = ps.executeQuery();
            while(rs.next()){
                String tmp=rs.getString(1);
                if(!tmp.startsWith("PRN")){
                    tmp=rs.getString(2);
                }
                ret.add(tmp);
            }
            ps.close();
        } catch (SQLException ex) {
            log.error("SQL Exception retreiving ENS ID" ,ex);
        }
        return ret;
    }
    
    public HashMap<String,String> getGenomeVersionSource(String genomeVer){
        
            HashMap<String,String> hm=new HashMap<String,String>();
            String query="select * from Browser_Genome_versions "+
                        "where genome_id='"+genomeVer+"'";

            PreparedStatement ps=null;
            try(Connection conn=pool.getConnection()) {

                ps = conn.prepareStatement(query);
                ResultSet rs = ps.executeQuery();
                if(rs.next()){
                    hm.put("ensembl",rs.getString("ENSEMBL"));
                    hm.put("ucsc",rs.getString("UCSC"));
                }
                ps.close();
            } catch (SQLException ex) {
                log.error("SQL Exception retreiving datasources for genome Version="+genomeVer ,ex);

            }
            
            return hm;
        
    }

    
    public String getGeneFolder(String inputID,String ensemblIDList,
            String panel,String organism,String genomeVer,int RNADatasetID,int arrayTypeID) {
        String ret="";
        String[] ensemblList = ensemblIDList.split(",");
        String ensemblID1 = ensemblList[0];
        boolean error=false;
        if(ensemblID1!=null && !ensemblID1.equals("")){
            //Define output directory
            String tmpoutputDir = fullPath + "tmpData/browserCache/"+genomeVer+"/geneData/" + ensemblID1 + "/";
            log.debug("checking for path:"+tmpoutputDir);
            String folderName = ensemblID1;
            String[] loc=null;
            try{
                    loc=myFH.getFileContents(new File(tmpoutputDir+"location.txt"));
            }catch(IOException e){
                    log.error("Couldn't load location for gene.",e);
            }
            if(loc!=null){
                    chrom=loc[0];
                    minCoord=Integer.parseInt(loc[1]);
                    maxCoord=Integer.parseInt(loc[2]);
            }
            //log.debug("getGeneCentricData->getRegionData");
            ret=this.getImageRegionData(chrom, minCoord, maxCoord, panel, organism,genomeVer, RNADatasetID, arrayTypeID, 0.001,false);
        }else{
            ret="";
        }
        return ret;
    }
    /**
     * Calls the Perl script WriteXML_RNA.pl and R script ExonCorrelation.R.
     * @param ensemblID       the ensemblIDs as a comma separated list
     * @param panel 
     * @param organism        the organism         
     * 
     */
    public ArrayList<Gene> getGeneCentricData(String inputID,String ensemblIDList,
            String panel,String organism,String genomeVer,int RNADatasetID,int arrayTypeID,boolean eQTL) {
        
        //Setup a String in the format YYYYMMDDHHMM to append to the folder
        Date start = new Date();
        GregorianCalendar gc = new GregorianCalendar();
        gc.setTime(start);
        String rOutputPath = "";
        outputDir="";
        String result="";
        returnGenURL="";
        HashMap<String,String> source=this.getGenomeVersionSource(genomeVer);
        log.debug("source"+source.keySet().toString()+source.values().toString());
        log.debug("source:"+source.get("ensembl"));
        /*try(Connection conn=pool.getConnection()){
            PreparedStatement ps=conn.prepareStatement(insertUsage, PreparedStatement.RETURN_GENERATED_KEYS);
            //ps.setInt(1, usageID);
            ps.setString(1,inputID);
            ps.setString(2, ensemblIDList);
            ps.setTimestamp(3, new Timestamp(start.getTime()));
            ps.setString(4, organism);
            ps.execute();
            ResultSet rs = ps.getGeneratedKeys();
            if (rs.next()) {
                usageID = rs.getInt(1);
            }
            ps.close();

        }catch(SQLException e){
            log.error("Error saving Transcription Detail Usage",e);
        }*/
        Date endDBSetup=new Date();
        log.debug("Insert usage:"+(endDBSetup.getTime()-start.getTime())+"ms");
        //EnsemblIDList can be a comma separated list break up the list
        String[] ensemblList = ensemblIDList.split(",");
        String ensemblID1 = ensemblList[0];
        boolean error=false;
        if(ensemblID1!=null && !ensemblID1.equals("")){
            //Define output directory
            outputDir = fullPath + "tmpData/browserCache/"+genomeVer+"/geneData/" + ensemblID1 + "/";
            //session.setAttribute("geneCentricPath", outputDir);
            log.debug("checking for path:"+outputDir);
            String folderName = ensemblID1;
            //String publicPath = H5File.substring(H5File.indexOf("/Datasets/") + 10);
            //publicPath = publicPath.substring(0, publicPath.indexOf("/Affy.NormVer.h5"));
            
            try {
                File geneDir=new File(outputDir);
                File errorFile=new File(outputDir+"errMsg.txt");
                if(geneDir.exists()){
                    Date lastMod=new Date(geneDir.lastModified());
                    Date prev2Months=new Date(start.getTime()-(60*24*60*60*1000));
                    if(lastMod.before(prev2Months)||errorFile.exists()){
                        if(myFH.deleteAllFilesPlusDirectory(geneDir)) {
                        }
                        error=generateFiles(organism,genomeVer,source.get("ensembl"),rOutputPath,ensemblIDList,folderName,ensemblID1,RNADatasetID,arrayTypeID,panel);
                        result="old files, regenerated all files";
                    }else{
                        //do nothing just need to set session var
                        String errors;
                        errors = loadErrorMessage();
                        if(errors.equals("")){
                            //String[] results=this.createImage("probe,numExonPlus,numExonMinus,noncoding,smallnc,refseq", organism,outputDir,chrom,minCoord,maxCoord);
                            //getUCSCUrl(results[1].replaceFirst(".png", ".url"));
                            //getUCSCUrls(ensemblID1);
                            result="cache hit files not generated";
                        }else{
                            if(myFH.deleteAllFilesPlusDirectory(geneDir)) {
                            }
                            error=generateFiles(organism,genomeVer,source.get("ensembl"),rOutputPath,ensemblIDList,folderName,ensemblID1,RNADatasetID,arrayTypeID,panel);
                            result="old files, regenerated all files";

                        }
                    }
                }else{
                    error=generateFiles(organism,genomeVer,source.get("ensembl"),rOutputPath,ensemblIDList,folderName,ensemblID1,RNADatasetID,arrayTypeID,panel);
                    if(!error){
                        result="NewGene generated successfully";
                    }
                }
                
            } catch (Exception e) {
                error=true;
                
                log.error("In Exception getting Gene Centric Results", e);
                Email myAdminEmail = new Email();
                String fullerrmsg=e.getMessage();
                    StackTraceElement[] tmpEx=e.getStackTrace();
                    for(int i=0;i<tmpEx.length;i++){
                        fullerrmsg=fullerrmsg+"\n"+tmpEx[i];
                    }
                myAdminEmail.setSubject("Exception thrown getting Gene Centric Results");
                myAdminEmail.setContent("There was an error while getting gene centric results.\n"+fullerrmsg);
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
        }else{
            error=true;
            setError("No Ensembl IDs");
        }
        Date endFindGen=new Date();
        log.debug("\nFindGene:"+(endFindGen.getTime()-endDBSetup.getTime())+"ms");
        if(error){
            result=(String)session.getAttribute("genURL");
        }
        this.setPublicVariables(error,genomeVer,ensemblID1);
        Date endLoadLoc=new Date();
        Date endRegion=new Date();
        ArrayList<Gene> ret=new ArrayList<Gene>();
        String[] loc=null;
        if(!error){

            try{
                    loc=myFH.getFileContents(new File(outputDir+"location.txt"));
            }catch(IOException e){
                    log.error("Couldn't load location for gene.",e);
            }
            if(loc!=null){
                    chrom=loc[0];
                    minCoord=Integer.parseInt(loc[1]);
                    maxCoord=Integer.parseInt(loc[2]);
            }
            endLoadLoc=new Date();
            //log.debug("getGeneCentricData->getRegionData");
            if(!chrom.toLowerCase().startsWith("chr")){
                chrom="chr"+chrom;
            }
            ret=this.getRegionData(chrom, minCoord, maxCoord, panel, organism,genomeVer, RNADatasetID, arrayTypeID, 0.01,eQTL,false);
            for(int i=0;i<ret.size();i++){
                //log.debug(ret.get(i).getGeneID()+"::"+ensemblIDList);
                if(ret.get(i).getGeneID().equals(ensemblIDList)){
                    //log.debug("EQUAL::"+ret.get(i).getGeneID()+"::"+ensemblIDList);
                    this.returnGeneSymbol=ret.get(i).getGeneSymbol();
                }
            }
            endRegion=new Date();
        }else{
            try{
                loc=myFH.getFileContents(new File(outputDir+"location.txt"));
            }catch(IOException e){
                log.error("Couldn't load location for gene.",e);
            }
            if(loc!=null){
                chrom=loc[0];
                minCoord=Integer.parseInt(loc[1]);
                maxCoord=Integer.parseInt(loc[2]);
                if(chrom.length()>6){
                    session.setAttribute("genURL","ERROR: Gene is located on a contig which is not currently supported.");
                }
            }
            endLoadLoc=new Date();
            //log.debug("getGeneCentricData->getRegionData");
            if(!chrom.toLowerCase().startsWith("chr")){
                chrom="chr"+chrom;
            }

        }
        log.debug("\ngetRegion:"+(endRegion.getTime()-endFindGen.getTime())+"ms");
        /*try(Connection conn=pool.getConnection()){
            PreparedStatement ps=conn.prepareStatement(updateSQL, 
						ResultSet.TYPE_SCROLL_INSENSITIVE,
						ResultSet.CONCUR_UPDATABLE);
            Date end=new Date();
            long returnTimeMS=end.getTime()-start.getTime();
            ps.setLong(1, returnTimeMS);
            ps.setString(2, result);
            ps.setInt(3, usageID);
            ps.executeUpdate();
            ps.close();
        }catch(SQLException e){
            log.error("Error saving Transcription Detail Usage",e);
        }*/
        Date endDB=new Date();
        
        log.debug("Timing:");
        log.debug("Total:"+(endDB.getTime()-start.getTime())/1000+"s");
        log.debug("DB Setup:"+(endDBSetup.getTime()-start.getTime())/1000+"s");
        log.debug("Find Gene:"+(endFindGen.getTime()-endDBSetup.getTime())/1000+"s");
        log.debug("Load Location:"+(endLoadLoc.getTime()-endFindGen.getTime())/1000+"s");
        log.debug("Get Region:"+(endRegion.getTime()-endLoadLoc.getTime())/1000+"s");
        log.debug("DB Final:"+(endDB.getTime()-endRegion.getTime())/1000+"s");
        return ret;
    }
    
    public HashMap<String,Integer> getRegionTrackList(String chromosome,int min,int max,String panel,String myOrganism,String genomeVer,int rnaDatasetID,int arrayTypeID,String track){
        HashMap<String,Integer> ret=new HashMap<String,Integer>();
        chromosome=chromosome.toLowerCase();
        if(!chromosome.startsWith("chr")){
            chromosome="chr"+chromosome;
        }
        
        //Setup a String in the format YYYYMMDDHHMM to append to the folder
        Date start = new Date();
        GregorianCalendar gc = new GregorianCalendar();
        gc.setTime(start);
        //String datePart=Integer.toString(gc.get(gc.MONTH)+1)+
        //        Integer.toString(gc.get(gc.DAY_OF_MONTH))+
        //        Integer.toString(gc.get(gc.YEAR))+"_"+
        //        Integer.toString(gc.get(gc.HOUR_OF_DAY))+
        //        Integer.toString(gc.get(gc.MINUTE))+
        //        Integer.toString(gc.get(gc.SECOND));
        
        HashMap<String,String> source=this.getGenomeVersionSource(genomeVer);
        
        
        //EnsemblIDList can be a comma separated list break up the list
        boolean error=false;

            //Define output directory
            outputDir = fullPath + "tmpData/browserCache/"+genomeVer+"/regionData/"+chromosome+"/"+min+"_"+max+"/";
            //session.setAttribute("geneCentricPath", outputDir);
            log.debug("checking for path:"+outputDir);
            String folderName = minCoord+"_"+maxCoord;
            //RegionDirFilter rdf=new RegionDirFilter(myOrganism+ chromosome+"_"+minCoord+"_"+maxCoord+"_");
            File mainDir=new File(fullPath + "tmpData/browserCache/"+genomeVer+"/regionData/chr"+chromosome+"/"+min+"_"+max);
            //File[] list=mainDir.listFiles(rdf);
            try {
                File geneDir=new File(outputDir);
                File errorFile=new File(outputDir+"errMsg.txt");
                
                if(mainDir.exists()){
                    //outputDir=list[0].getAbsolutePath()+"/";
                    //int second=outputDir.lastIndexOf("/",outputDir.length()-2);
                    //folderName=outputDir.substring(second+1,outputDir.length()-1);
                    String errors;
                    errors = loadErrorMessage();
                    if(errors.equals("")){
                        
                    }else{
                        //ERROR
                    }
                }else{
                    //ERROR
                }
                
                
                
            } catch (Exception e) {
                error=true;
                log.error("In Exception getting Gene List for a track", e);
                Email myAdminEmail = new Email();
                String fullerrmsg=e.getMessage();
                    StackTraceElement[] tmpEx=e.getStackTrace();
                    for(int i=0;i<tmpEx.length;i++){
                        fullerrmsg=fullerrmsg+"\n"+tmpEx[i];
                    }
                myAdminEmail.setSubject("Exception thrown getting Gene List for a track");
                myAdminEmail.setContent("There was an error while getting Gene List for a track.\n"+fullerrmsg);
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
        
        this.pathReady=true;
        
        ret=Gene.readGeneIDList(outputDir+track+".xml");
        log.debug("getRegionData() returning gene list of size:"+ret.size());
        return ret;
    }
    
    public ArrayList<Gene> getMergedRegionData(String chromosome,int minCoord,int maxCoord,
            String panel,
            String organism,String genomeVer,int RNADatasetID,int arrayTypeID,double pValue,boolean withEQTL,boolean withRNASeqQTL) {
        return this.getRegionDataMain(chromosome,minCoord,maxCoord,panel,organism,genomeVer,RNADatasetID,arrayTypeID,pValue,withEQTL,withRNASeqQTL,"mergedTotal.xml");
    }
    
    public ArrayList<Gene> getRegionData(String chromosome,int minCoord,int maxCoord,
            String panel,
            String organism,String genomeVer,int RNADatasetID,int arrayTypeID,double pValue,boolean withEQTL,boolean withRNASeqQTL) {
        return this.getRegionDataMain(chromosome,minCoord,maxCoord,panel,organism,genomeVer,RNADatasetID,arrayTypeID,pValue,withEQTL,withRNASeqQTL,"Region.xml");
    }
    
    public ArrayList<Gene> getRegionDataMain(String chromosome,int minCoord,int maxCoord,
            String panel,
            String organism,String genomeVer,int RNADatasetID,int arrayTypeID,double pValue,boolean withEQTL,boolean withRNASeqEQTL,String file) {

        ArrayList<Gene> ret = new ArrayList<Gene>();

        chromosome=chromosome.toLowerCase();
        if(!chromosome.startsWith("chr")){
            chromosome="chr"+chromosome;
        }
        if(chromosome.length()>6){
            returnGenURL="ERROR: Gene is located on a contig which is not currently supported.";
        }else {
            //Setup a String in the format YYYYMMDDHHMM to append to the folder
            Date start = new Date();
            GregorianCalendar gc = new GregorianCalendar();
            gc.setTime(start);
        /*String datePart=Integer.toString(gc.get(gc.MONTH)+1)+
                Integer.toString(gc.get(gc.DAY_OF_MONTH))+
                Integer.toString(gc.get(gc.YEAR))+"_"+
                Integer.toString(gc.get(gc.HOUR_OF_DAY))+
                Integer.toString(gc.get(gc.MINUTE))+
                Integer.toString(gc.get(gc.SECOND));*/
            String rOutputPath = "";
            outputDir = "";
            String result = "";
            this.minCoord = minCoord;
            this.maxCoord = maxCoord;
            this.chrom = chromosome;
            String inputID = organism + ":" + chromosome + ":" + minCoord + "-" + maxCoord;
            HashMap<String, String> source = this.getGenomeVersionSource(genomeVer);
           /* try (Connection conn = pool.getConnection()) {

                PreparedStatement ps = conn.prepareStatement(insertUsage, PreparedStatement.RETURN_GENERATED_KEYS);
                //ps.setInt(1, usageID);
                ps.setString(1, inputID);
                ps.setString(2, "");
                ps.setTimestamp(3, new Timestamp(start.getTime()));
                ps.setString(4, organism);
                ps.execute();
                ResultSet rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    usageID = rs.getInt(1);
                }
                ps.close();
            } catch (SQLException e) {
                log.error("Error saving Transcription Detail Usage", e);
            }*/

            //EnsemblIDList can be a comma separated list break up the list
            boolean error = false;

            //Define output directory
            outputDir = fullPath + "tmpData/browserCache/" + genomeVer + "/regionData/" + chromosome + "/" + minCoord + "_" + maxCoord + "/";
            //+"_"+datePart + "/";
            //session.setAttribute("geneCentricPath", outputDir);
            log.debug("checking for path:" + outputDir);
            String folderName = "/" + chromosome + "/" + minCoord + "_" + maxCoord;
            // +"_"+datePart;
            //String publicPath = H5File.substring(H5File.indexOf("/Datasets/") + 10);
            //publicPath = publicPath.substring(0, publicPath.indexOf("/Affy.NormVer.h5"));

            try {
                File geneDir = new File(outputDir);
                File errorFile = new File(outputDir + "errMsg.txt");
                if (geneDir.exists()) {
                    //do nothing just need to set session var
                    String errors;
                    errors = loadErrorMessage();
                    if (errors.equals("")) {
                        //String[] results=this.createImage("default", organism,outputDir,chrom,minCoord,maxCoord);
                        //getUCSCUrl(results[1].replaceFirst(".png", ".url"));
                        result = "cache hit files not generated";

                    } else {
                        result = "Previous Result had errors. Trying again.";
                        generateRegionFiles(organism, genomeVer, source.get("ensembl"), folderName, RNADatasetID, arrayTypeID, source.get("ucsc"));

                        //error=true;
                        //this.setError(errors);
                    }
                } else {
                    /*RegionDirFilter rdf=new RegionDirFilter(organism+ chromosome+"_"+minCoord+"_"+maxCoord+"_");
                    File mainDir=new File(fullPath + "tmpData/browserCache/"+genomeVer+"/regionData/");
                    File[] list=mainDir.listFiles(rdf);
                    if(list.length>0){
                        outputDir=list[0].getAbsolutePath()+"/";
                        int second=outputDir.lastIndexOf("/",outputDir.length()-2);
                        folderName=outputDir.substring(second+1,outputDir.length()-1);
                        String errors;
                        errors = loadErrorMessage();
                        if(errors.equals("")){
                            //String[] results=this.createImage("default", organism,outputDir,chrom,minCoord,maxCoord);
                            //getUCSCUrl(results[1].replaceFirst(".png", ".url"));
                            result="cache hit files not generated";
                        }else{
                            result="Previous Result had errors. Trying again.";
                            generateRegionFiles(organism,genomeVer,source.get("ensembl"),folderName,RNADatasetID,arrayTypeID,source.get("ucsc"));
                            
                            //error=true;
                            //this.setError(errors);
                        }
                    }else{*/
                    generateRegionFiles(organism, genomeVer, source.get("ensembl"), folderName, RNADatasetID, arrayTypeID, source.get("ucsc"));
                    result = "New Region generated successfully";
                    //}
                }


            } catch (Exception e) {
                error = true;

                log.error("In Exception getting Gene Centric Results", e);
                Email myAdminEmail = new Email();
                String fullerrmsg = e.getMessage();
                StackTraceElement[] tmpEx = e.getStackTrace();
                for (int i = 0; i < tmpEx.length; i++) {
                    fullerrmsg = fullerrmsg + "\n" + tmpEx[i];
                }
                myAdminEmail.setSubject("Exception thrown getting Gene Centric Results");
                myAdminEmail.setContent("There was an error while getting gene centric results.\n" + fullerrmsg);
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
            if (error) {
                result = this.returnGenURL;
            }
            this.setPublicVariables(error, genomeVer, folderName);
            this.pathReady = true;

            ret = Gene.readGenes(outputDir + file);
            log.debug("getRegionData() returning gene list of size:" + ret.size());
            if(withRNASeqEQTL){
                this.addRegionHeritEQTLs(ret,minCoord,maxCoord,organism,chromosome,"5","rn6",pValue);
            }
            if (withEQTL) {
                this.addHeritDABG(ret, minCoord, maxCoord, organism, chromosome, RNADatasetID, arrayTypeID, genomeVer);
                ArrayList<TranscriptCluster> tcList = getTransControlledFromEQTLs(minCoord, maxCoord, chromosome, arrayTypeID, pValue, "All", genomeVer);
                HashMap<String, TranscriptCluster> transInQTLsCore = new HashMap<String, TranscriptCluster>();
                HashMap<String, TranscriptCluster> transInQTLsExtended = new HashMap<String, TranscriptCluster>();
                HashMap<String, TranscriptCluster> transInQTLsFull = new HashMap<String, TranscriptCluster>();
                for (int i = 0; i < tcList.size(); i++) {
                    TranscriptCluster tmp = tcList.get(i);
                    if (tmp.getLevel().equals("core")) {
                        transInQTLsCore.put(tmp.getTranscriptClusterID(), tmp);
                    } else if (tmp.getLevel().equals("extended")) {
                        transInQTLsExtended.put(tmp.getTranscriptClusterID(), tmp);
                    } else if (tmp.getLevel().equals("full")) {
                        transInQTLsFull.put(tmp.getTranscriptClusterID(), tmp);
                    }
                }
                addFromQTLS(ret, transInQTLsCore, transInQTLsExtended, transInQTLsFull);
            }

            /*try (Connection conn = pool.getConnection()) {
                PreparedStatement ps = conn.prepareStatement(updateSQL,
                        ResultSet.TYPE_SCROLL_INSENSITIVE,
                        ResultSet.CONCUR_UPDATABLE);
                Date end = new Date();
                long returnTimeMS = end.getTime() - start.getTime();
                ps.setLong(1, returnTimeMS);
                ps.setString(2, result);
                ps.setInt(3, usageID);
                ps.executeUpdate();
                ps.close();
            } catch (SQLException e) {
                log.error("Error saving Transcription Detail Usage", e);
            }*/
        }
        return ret;
    }
    
    public String getImageRegionData(String chromosome,int minCoord,int maxCoord,
            String panel,String organism,String genomeVer,int RNADatasetID,int arrayTypeID,double pValue,boolean img) {
        
        
        chromosome=chromosome.toLowerCase();
        if(!chromosome.startsWith("chr")){
            chromosome="chr"+chromosome;
        }
        //Setup a String in the format YYYYMMDDHHMM to append to the folder
        Date start = new Date();
        GregorianCalendar gc = new GregorianCalendar();
        gc.setTime(start);
        /*String datePart=Integer.toString(gc.get(gc.MONTH)+1)+
                Integer.toString(gc.get(gc.DAY_OF_MONTH))+
                Integer.toString(gc.get(gc.YEAR))+"_"+
                Integer.toString(gc.get(gc.HOUR_OF_DAY))+
                Integer.toString(gc.get(gc.MINUTE))+
                Integer.toString(gc.get(gc.SECOND));*/
        String rOutputPath = "";
        outputDir="";
        String result="";
        this.minCoord=minCoord;
        this.maxCoord=maxCoord;
        this.chrom=chromosome;
        String inputID=organism+":"+chromosome+":"+minCoord+"-"+maxCoord;
        String imgStr="img_";
        if(!img){
            imgStr="";
        }
        HashMap<String,String> source=this.getGenomeVersionSource(genomeVer);
        //EnsemblIDList can be a comma separated list break up the list
        boolean error=false;

            //Define output directory
            outputDir = fullPath + "tmpData/browserCache/"+genomeVer+"/regionData/"+chromosome+"/"+imgStr+minCoord+"_"+maxCoord+ "/";
            //session.setAttribute("geneCentricPath", outputDir);
            log.debug("checking for path:"+outputDir);
            String folderName = "/"+chromosome+"/"+imgStr+minCoord+"_"+maxCoord;
            //+"_"+datePart;
            //String publicPath = H5File.substring(H5File.indexOf("/Datasets/") + 10);
            //publicPath = publicPath.substring(0, publicPath.indexOf("/Affy.NormVer.h5"));
            /*RegionDirFilter rdf=new RegionDirFilter(imgStr+organism+ chromosome+"_"+minCoord+"_"+maxCoord+"_");
            File mainDir=new File(fullPath + "tmpData/browserCache/"+genomeVer+"/regionData/");
            File[] list=mainDir.listFiles(rdf);*/
            try {
                File geneDir=new File(outputDir);
                File errorFile=new File(outputDir+"errMsg.txt");
                if(geneDir.exists()){
                        //do nothing just need to set session var
                        String errors;
                        errors = loadErrorMessage();
                        if(errors.equals("")){
                            result="cache hit files not generated";
                            
                        }else{
                            result="Previous Result had errors. Trying again.";
                            generateRegionFiles(organism,genomeVer,source.get("ensembl"),folderName,RNADatasetID,arrayTypeID,source.get("ucsc"));
                        }
                }else{
                    /*if(list.length>0){
                        
                        outputDir=list[0].getAbsolutePath()+"/";
                        int second=outputDir.lastIndexOf("/",outputDir.length()-2);
                        folderName=outputDir.substring(second+1,outputDir.length()-1);
                        log.debug("previous exists:"+outputDir);
                        log.debug("set folder:"+folderName);
                        String errors;
                        errors = loadErrorMessage();
                        if(errors.equals("")){
                            result="cache hit files not generated";
                        }else{
                            result="Previous Result had errors. Trying again.";
                            generateRegionFiles(organism,genomeVer,source.get("ensembl"),folderName,RNADatasetID,arrayTypeID,source.get("ucsc"));
                        }
                    }else{*/
                        generateRegionFiles(organism,genomeVer,source.get("ensembl"),folderName,RNADatasetID,arrayTypeID,source.get("ucsc"));
                        result="New Region generated successfully";
                    //}
                }
                
                
            } catch (Exception e) {
                error=true;
                
                log.error("In Exception getting Gene Centric Results", e);
                Email myAdminEmail = new Email();
                String fullerrmsg=e.getMessage();
                    StackTraceElement[] tmpEx=e.getStackTrace();
                    for(int i=0;i<tmpEx.length;i++){
                        fullerrmsg=fullerrmsg+"\n"+tmpEx[i];
                    }
                myAdminEmail.setSubject("Exception thrown getting Gene Centric Results");
                myAdminEmail.setContent("There was an error while getting gene centric results.\n"+fullerrmsg);
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
        if(error){
            result=(String)session.getAttribute("genURL");
        }
        return outputDir;
    }

    public boolean generateFiles(String organism,String genomeVer,String ensemblPath,String rOutputPath, String ensemblIDList,String folderName,String ensemblID1,int RNADatasetID,int arrayTypeID,String panel) {
        log.debug("generate files");
        AsyncGeneDataTools prevThread=null;
        boolean error = false;
        log.debug("outputDir:"+outputDir);
        File outDirF = new File(outputDir);
        //Mkdir if some are missing    
        if (!outDirF.exists()) {
            outDirF.mkdirs();
        }
        
        boolean createdXML=this.createXMLFiles(organism,genomeVer,ensemblIDList,ensemblID1,ensemblPath);
        
        log.debug(ensemblIDList+" CreatedXML::"+createdXML);
        
        if(createdXML){
            String[] loc=null;
            try{
                loc=myFH.getFileContents(new File(outputDir+"location.txt"));
            }catch(IOException e){
                error=true;
                log.error("Couldn't load location for gene.",e);
            }
            if(loc!=null){
                chrom=loc[0];
                minCoord=Integer.parseInt(loc[1]);
                maxCoord=Integer.parseInt(loc[2]);
                if(chrom.length()>6){
                    error=true;
                    setError("Gene is on a contig which is not currently supported.");
                }else {
                    log.debug("AsyncGeneDataTools with " + chrom + ":" + minCoord + "-" + maxCoord);
                    callWriteXML(ensemblID1, organism, genomeVer, chrom, minCoord, maxCoord, arrayTypeID, RNADatasetID);
                    boolean isENS = false;
                    if (ensemblID1.startsWith("ENS")) {
                        isENS = true;
                    }
                    prevThread = callAsyncGeneDataTools(chrom, minCoord, maxCoord, arrayTypeID, RNADatasetID, genomeVer, isENS);
                }
            }else{
                error=true;
            }
        }else{
            error=true;
        }
        return error;
    }
    
    public boolean generateGeneRegionFiles(String organism,String genomeVer,String folderName,int RNADatasetID,int arrayTypeID) {
        log.debug("generate files");
        log.debug("outputDir:"+outputDir);
        File outDirF = new File(outputDir);
        //Mkdir if some are missing    
        if (!outDirF.exists()) {
            outDirF.mkdirs();
        }
        HashMap<String,String> source=this.getGenomeVersionSource(genomeVer);
        String ensemblPath=source.get("ensembl");
        //boolean createdXML=this.createRegionImagesXMLFiles(folderName,organism,genomeVer,ensemblPath,arrayTypeID,RNADatasetID,source.get("ucsc"));
        AsyncBrowserRegion abr=new AsyncBrowserRegion(session,pool,organism,outputDir,chrom,minCoord,maxCoord,arrayTypeID,RNADatasetID,genomeVer,source.get("ucsc"),ensemblPath,usageID,false);
        abr.start();
        return true;
    }
    
    public boolean generateRegionFiles(String organism,String genomeVer,String ensemblPath,String folderName,int RNADatasetID,int arrayTypeID,String ucscDB) {
        log.debug("generate files");
        boolean completedSuccessfully = false;
        log.debug("outputDir:"+outputDir);
        File outDirF = new File(outputDir);
        //Mkdir if some are missing    
        if (!outDirF.exists()) {
            //log.debug("make output dir");
            outDirF.mkdirs();
        }
        AsyncBrowserRegion abr=new AsyncBrowserRegion(session,pool,organism,outputDir,chrom,minCoord,maxCoord,arrayTypeID,RNADatasetID,genomeVer,ucscDB,ensemblPath,usageID,true);
        abr.start();
        //boolean createdXML=this.createRegionImagesXMLFiles(folderName,organism,genomeVer,ensemblPath,arrayTypeID,RNADatasetID,ucscDB);
        //AsyncGeneDataTools prevThread=callAsyncGeneDataTools(chrom, minCoord, maxCoord,arrayTypeID,RNADatasetID,genomeVer,false);
        return true;
    }
    
    public ArrayList<String> getPhenoGenID(String ensemblID,String genomeVer,String version) throws SQLException{

        ArrayList<String> ret=new ArrayList<String>();
        try(Connection conn=pool.getConnection();){

           String org="Rn";
           if(ensemblID.startsWith("ENSMUS")){
               org="Mm";
           }
           String query="select rt.gene_id,rta.annotation from rna_transcripts_annot rta, rna_transcripts rt "+
                        "where rt.RNA_TRANSCRIPT_ID=rta.RNA_TRANSCRIPT_ID "+
                        "and rt.RNA_DATASET_ID=? "+
                        "and rta.ANNOTATION like '"+ensemblID+"%'";
           int[] tmp=getOrganismSpecificIdentifiers(org,"Merged",genomeVer,version);
           int dsid=tmp[1];
           PreparedStatement ps=conn.prepareStatement(query);
           ps.setInt(1, dsid);
           ResultSet rs=ps.executeQuery();
           
           while(rs.next()){
               String id=rs.getString(1);
               if(id.startsWith("Merged_GPRN")){
                   id=id.substring(8);
               }
               boolean found=false;
               for(int i=0;i<ret.size()&&!found;i++){
                   if(ret.get(i).equals(id)){
                       found=true;
                   }
               }
               if(!found){
                   ret.add(id);
               }
           }
           ps.close();

        }catch(SQLException e){
            throw(e);
        }
        return ret;
    }
    
    private void outputProbesetIDFiles(String outputDir,String chr, int min, int max,int arrayTypeID,int rnaDS_ID,String genomeVer){
        if(chr.toLowerCase().startsWith("chr")){
            chr=chr.substring(3);
        }
        String organism="Rn";
        if(genomeVer.toLowerCase().startsWith("mm")){
            organism="Mm";
        }
        String chrQ="select chromosome_id from chromosomes where name= '"+chr.toUpperCase()+"' and organism='"+organism+"'";
        int chrID=-99;



        /*String probeTransQuery="select distinct s.Probeset_ID,c2.name,s.PSSTART,s.PSSTOP,s.PSLEVEL,s.Strand "+
                "from location_specific_eqtl l "+
                "left outer join snps sn on sn.snp_id=l.SNP_ID "+
                "left outer join Affy_Exon_ProbeSet s on s.probeset_id = l.probe_id "+
                "left outer join Chromosomes c2 on c2.chromosome_id = s.chromosome_id "+
                "where sn.genome_id='"+genomeVer+"' "+
                "and l.probe_id in (select distinct ae.Probeset_ID " +
                "from Affy_Exon_ProbeSet ae "+
                "left outer join Chromosomes c on c.chromosome_id = ae.chromosome_id "+
                "where c.name = '"+chr.toUpperCase()+"' "+
                "and ae.genome_id='"+genomeVer+"' "+
                "and ( "+
                "(ae.psstart >= "+min+" and ae.psstart <="+max+") OR "+
                "(ae.psstop >= "+min+" and ae.psstop <= "+max+") OR "+
                "(ae.psstart <= "+min+" and ae.psstop >="+min+") )"+
                "and ae.psannotation = 'transcript' " +
                "and ae.updatedlocation = 'Y' "+
                "and ae.Array_TYPE_ID = " + arrayTypeID +" )";*/

        


            String pListFile=outputDir+"tmp_psList.txt";
            try{
                BufferedWriter psout=new BufferedWriter(new FileWriter(new File(pListFile)));
                try(Connection conn=pool.getConnection()){
                    PreparedStatement psC = conn.prepareStatement(chrQ);
                    ResultSet rsC = psC.executeQuery();
                    if(rsC.next()){
                        chrID=rsC.getInt(1);
                    }else{
                        log.debug("No Rows for CHR:"+chrQ);
                    }
                    rsC.close();
                    psC.close();
                    String probeQuery="select s.Probeset_ID "+
                            "from Affy_Exon_ProbeSet s "+
                            "where s.chromosome_id =  "+chrID+" "+
                            "and ( "+
                            "(s.psstart >= "+min+" and s.psstart <="+max+") OR "+
                            "(s.psstop >= "+min+" and s.psstop <= "+max+") OR "+
                            "(s.psstart <= "+min+" and s.psstop >="+min+")"+
                            ") "+
                            "and s.psannotation <> 'transcript' " +
                            "and s.updatedlocation = 'Y' "+
                            "and s.Array_TYPE_ID = "+arrayTypeID;
                    log.debug("PSLEVEL SQL:"+probeQuery);
                    PreparedStatement ps = conn.prepareStatement(probeQuery);
                    ResultSet rs = ps.executeQuery();
                    while (rs.next()) {
                        int psid = rs.getInt(1);
                        psout.write(psid + "\n");
                    }
                    ps.close();
                    conn.close();
                }catch(SQLException ex){
                    log.error("Error getting exon probesets",ex);
                }
                psout.flush();
                psout.close();
            }catch(IOException e){
                log.error("Error writing exon probesets",e);
            }
            
            ArrayList<GeneLoc> geneList=GeneLoc.readGeneListFile(outputDir,log);
            log.debug("Read in gene list:"+geneList.size());
            String ptransListFiletmp = outputDir + "tmp_psList_transcript.txt";
            //String ptransListFile = outputDir + "tmp_psList_transcript.txt";
            //File srcFile=new File(ptransListFiletmp);
            //File destFile=new File(ptransListFile);
            //try{
                StringBuffer sb=new StringBuffer();
                //BufferedWriter psout = new BufferedWriter(new FileWriter(srcFile));

                try (Connection conn=pool.getConnection()){

                    String probeTransQuery="select distinct s.Probeset_ID,'"+chr.toUpperCase()+"',s.PSSTART,s.PSSTOP,s.PSLEVEL,s.Strand "+
                            "from location_specific_eqtl l "+
                            "left outer join snps sn on sn.snp_id=l.SNP_ID "+
                            "left outer join Affy_Exon_ProbeSet s on s.probeset_id = l.probe_id "+
                            "where sn.genome_id='"+genomeVer+"' "+
                            "and sn.type='array' "+
                            "and s.chromosome_id = "+chrID+" "+
                            "and s.genome_id='"+genomeVer+"' "+
                            "and ( "+
                            "(s.psstart >= "+min+" and s.psstart <="+max+") OR "+
                            "(s.psstop >= "+min+" and s.psstop <= "+max+") OR "+
                            "(s.psstart <= "+min+" and s.psstop >="+min+") ) "+
                            "and s.psannotation = 'transcript' " +
                            "and s.updatedlocation = 'Y' "+
                            "and s.Array_TYPE_ID = " + arrayTypeID ;
                    log.debug("Transcript Level SQL:"+probeTransQuery);
                    PreparedStatement ps = conn.prepareStatement(probeTransQuery);
                    ResultSet rs = ps.executeQuery();
                    while (rs.next()) {
                        int psid = rs.getInt(1);
                        //log.debug("read ps:"+psid);
                        String ch = rs.getString(2);
                        long start = rs.getLong(3);
                        long stop = rs.getLong(4);
                        String level=rs.getString(5);
                        String strand=rs.getString(6);
                        
                        String ensemblId="",ensGeneSym="";
                        double maxOverlapTC=0.0,maxOverlapGene=0.0,maxComb=0.0;
                        GeneLoc maxGene=null;
                        for(int i=0;i<geneList.size();i++){
                            GeneLoc tmpLoc=geneList.get(i);
                            //log.debug("strand:"+tmpLoc.getStrand()+":"+strand);
                            if(tmpLoc.getStrand().equals(strand)){
                                long maxStart=tmpLoc.getStart();
                                long minStop=tmpLoc.getStop();
                                if(start>maxStart){
                                    maxStart=start;
                                }
                                if(stop<minStop){
                                    minStop=stop;
                                }
                                long genLen=tmpLoc.getStop()-tmpLoc.getStart();
                                long tcLen=stop-start;
                                double overlapLen=minStop-maxStart;
                                double curTCperc=0.0,curGperc=0.0,comb=0.0;
                                if(overlapLen>0){
                                    curTCperc=overlapLen/tcLen*100;
                                    curGperc=overlapLen/tcLen*100;
                                    comb=curTCperc+curGperc;
                                    if(comb>maxComb){
                                        maxOverlapTC=curTCperc;
                                        maxOverlapGene=curGperc;
                                        maxComb=comb;
                                        maxGene=tmpLoc;
                                    }
                                }
                            }
                        }
                        if(maxGene!=null){
                            String tmpGS=maxGene.getGeneSymbol();
                            if(tmpGS.equals("")){
                                tmpGS=maxGene.getID();
                            }
                            //log.debug("out:"+psid + "\t" + ch + "\t" + start + "\t" + stop + "\t" + level + "\t"+tmpGS+"\n");
                            sb.append(psid + "\t" + ch + "\t" + start + "\t" + stop + "\t" + level + "\t"+tmpGS+"\n");
                            
                        }else{
                            //log.debug("out"+psid + "\t" + ch + "\t" + start + "\t" + stop + "\t" + level + "\t\n");
                            sb.append(psid + "\t" + ch + "\t" + start + "\t" + stop + "\t" + level + "\t\n");
                            
                        }
                    }
                    ps.close();
                    conn.close();
                }catch(SQLException ex){
                    log.error("Error getting transcript probesets",ex);
                }
                try{
                    //log.debug("To File:"+ptransListFiletmp+"\n\n"+sb.toString());
                    myFH.writeFile(sb.toString(),ptransListFiletmp);
                    log.debug("DONE");
                }catch(IOException e){
                    log.error("Error outputing transcript ps list.",e);
                }
                /*psout.flush();
                psout.close();
            }catch(IOException e){
                log.error("Error writing transcript probesets",e);
            }*/
            //srcFile.renameTo(destFile);
            
    }
    
    public boolean createCircosFiles(String perlScriptDirectory, String perlEnvironmentVariables, String[] perlScriptArguments,String filePrefixWithPath){
   		// 
   	    boolean completedSuccessfully=false;
   	    String circosErrorMessage;

   
        //set environment variables so you can access oracle. Environment variables are pulled from perlEnvironmentVariables which is a comma separated list
        String[] envVar=perlEnvironmentVariables.split(",");
    
        for (int i = 0; i < envVar.length; i++) {
            log.debug(i + " EnvVar::" + envVar[i]);
        }
        
       
        //construct ExecHandler which is used instead of Perl Handler because environment variables were needed.
        myExec_session = new ExecHandler(perlScriptDirectory, perlScriptArguments, envVar, filePrefixWithPath);
        boolean exception = false;
        try {

            myExec_session.runExec();
            int exit=myExec_session.getExitValue();
            if(exit==0){
                completedSuccessfully=true;
            }else{
                completedSuccessfully=false;
            }
        } catch (ExecException e) {
            exception = true;
            log.error("In Exception of createCircosFiles Exec_session", e);
            Email myAdminEmail = new Email();
            myAdminEmail.setSubject("Exception thrown in Exec_session");
            circosErrorMessage = "There was an error while running ";
            circosErrorMessage = circosErrorMessage + " " + perlScriptArguments[1] + " (";
            for(int i=2; i<perlScriptArguments.length; i++){
            	circosErrorMessage = circosErrorMessage + " " + perlScriptArguments[i];
            }
            circosErrorMessage = circosErrorMessage + ")\n\n"+myExec_session.getErrors();
            if (!circosErrorMessage.contains("WARNING **: Unimplemented style property SP_PROP_POINTER_EVENTS:")  && !circosErrorMessage.contains("Circos::Error::GROUPERROR")) {
                myAdminEmail.setContent(circosErrorMessage);
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
        
        String errors=myExec_session.getErrors();
        if(!exception && errors!=null && !(errors.equals(""))){
            if (!errors.contains("WARNING **: Unimplemented style property SP_PROP_POINTER_EVENTS:")  && !errors.contains("Circos::Error::GROUPERROR")) {
                Email myAdminEmail = new Email();
                myAdminEmail.setSubject("Exception thrown in Exec_session");
                circosErrorMessage = "There was an error while running ";
                circosErrorMessage = circosErrorMessage + " " + perlScriptArguments[1] + " (";
                for(int i=2; i<perlScriptArguments.length; i++){
                    circosErrorMessage = circosErrorMessage + " " + perlScriptArguments[i];
                }
                circosErrorMessage = circosErrorMessage + ")\n\n"+errors;
                myAdminEmail.setContent(circosErrorMessage);
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
   	return completedSuccessfully;
   } 
    

    public boolean createXMLFiles(String organism,String genomeVer,String ensemblIDList,String ensemblID1,String ensemblPath){
        boolean completedSuccessfully=false;
        if(ensemblIDList!=null && ensemblID1!=null && !ensemblIDList.equals("") && !ensemblID1.equals("")){
        try{
            log.debug(ensemblIDList+"\n\n"+ensemblID1);
            //Connection tmpConn=pool.getConnection();
            int publicUserID=new User().getUser_id("public",pool);
            //tmpConn.close();
            log.debug("createXML outputDir:"+outputDir);
            File outDir=new File(outputDir);
            if(outDir.exists()){
                outDir.mkdirs();
            }
            log.debug("after mkdir");
            Properties myProperties = new Properties();
            File myPropertiesFile = new File(dbPropertiesFile);
            myProperties.load(new FileInputStream(myPropertiesFile));

            String dsn="dbi:mysql:database="+myProperties.getProperty("DATABASE")+";host="+myProperties.getProperty("HOST")+";port=3306";
            String dbUser=myProperties.getProperty("USER");
            String dbPassword=myProperties.getProperty("PASSWORD");
            log.debug("after dbprop");
            File ensPropertiesFile = new File(ensemblDBPropertiesFile);
            Properties myENSProperties = new Properties();
            myENSProperties.load(new FileInputStream(ensPropertiesFile));
            String ensHost=myENSProperties.getProperty("HOST");
            String ensPort=myENSProperties.getProperty("PORT");
            String ensUser=myENSProperties.getProperty("USER");
            String ensPassword=myENSProperties.getProperty("PASSWORD");
            log.debug("after ens dbprop");
            //construct perl Args
            String[] perlArgs = new String[15];
            perlArgs[0] = "perl";
            perlArgs[1] = perlDir + "findGeneRegion.pl";
            perlArgs[2] = outputDir;
            log.debug("perl org:"+organism);
            if (organism.equals("Rn")) {
                perlArgs[3] = "Rat";
            } else if (organism.equals("Mm")) {
                perlArgs[3] = "Mouse";
            }
            perlArgs[4] = "Core";
            perlArgs[5] = ensemblIDList;
            perlArgs[6] = Integer.toString(publicUserID);
            perlArgs[7] = dsn;
            perlArgs[8] = dbUser;
            perlArgs[9] = dbPassword;
            perlArgs[10] = ensHost;
            perlArgs[11] = ensPort;
            perlArgs[12] = ensUser;
            perlArgs[13] = ensPassword;
            perlArgs[14]=genomeVer;
            
            log.debug("after perl args");
            log.debug("setup params");
            //set environment variables so you can access oracle pulled from perlEnvVar session variable which is a comma separated list
             String[] envVar=perlEnvVar.split(",");

            for (int i = 0; i < envVar.length; i++) {
                if(envVar[i].contains("/ensembl")){
                    envVar[i]=envVar[i].replaceFirst("/ensembl", "/"+ensemblPath);
                }
                log.debug(i + " EnvVar::" + envVar[i]);
            }

            log.debug("setup envVar");
            //construct ExecHandler which is used instead of Perl Handler because environment variables were needed.
            myExec_session = new ExecHandler(perlDir, perlArgs, envVar, fullPath + "tmpData/browserCache/"+genomeVer+"/geneData/"+ensemblID1+"/");
            boolean exception=false;
            boolean missingDB=false;
            log.debug("setup exec");
            try {

                myExec_session.runExec();
                log.debug("after exec No Exception");
            } catch (ExecException e) {
                exception = true;
                completedSuccessfully=false;
                log.error("In Exception of run findGeneRegion.pl Exec_session", e);
                
                String errorList=myExec_session.getErrors();
                
                String apiVer="";
                
                    if(errorList.contains("does not exist in DB.")){
                        missingDB=true;
                    }
                    if(errorList.contains("Ensembl API version =")){
                        int apiStart=errorList.indexOf("Ensembl API version =")+22;
                        apiVer=errorList.substring(apiStart,apiStart+3);
                    }
                Email myAdminEmail = new Email();
                if(!missingDB){
                    myAdminEmail.setSubject("Exception thrown in Exec_session");
                    setError("Running Perl Script to get Gene and Transcript details/images. Ensembl Assembly v"+apiVer);
                }else{
                    myAdminEmail.setSubject("Missing Ensembl ID in DB");
                    setError("The current Ensembl database does not have an entry for this gene ID."+
                                " As Ensembl IDs are added/removed from new versions it is likely this ID has been removed."+
                                " If you used a Gene Symbol and reached this the administrator will investigate. "+
                                "If you entered this Ensembl ID please try to use a synonym or visit Ensembl to investigate the status of this ID. "+
                                "Ensembl Assembly v"+apiVer);
                                        
                }
                
                String errors=myExec_session.getErrors();
                
                myAdminEmail.setContent("There was an error while running "
                        + perlArgs[1] + " (" + perlArgs[2] +" , "+perlArgs[3]+" , "+perlArgs[4]+" , "+perlArgs[5]+" , "+perlArgs[6]+
                        ")\ngenomeVer:"+genomeVer+"\n"+errors);
                try {
                    if(!missingDB && errors!=null &&errors.length()>0){
                        myAdminEmail.sendEmailToAdministrator((String) session.getAttribute("adminEmail"));
                    }
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
            log.debug("after read Exec Errors");
            if(!missingDB && errors!=null && !(errors.equals(""))){
                completedSuccessfully=false;
                Email myAdminEmail = new Email();
                myAdminEmail.setSubject("Exception thrown in Exec_session");
                myAdminEmail.setContent("There was an error while running "
                        + perlArgs[1] + " (" + perlArgs[2] +" , "+perlArgs[3]+" , "+perlArgs[4]+" , "+perlArgs[5]+" , "+perlArgs[6]+
                        ")\ngenomeVer:"+genomeVer+"\n"+errors);
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
            log.debug("after if Exec Errors");
            completedSuccessfully=true;
        }catch(Exception e){
            completedSuccessfully=false;
            log.error("Error getting DB properties or Public User ID.",e);
            String fullerrmsg=e.getMessage();
                    StackTraceElement[] tmpEx=e.getStackTrace();
                    for(int i=0;i<tmpEx.length;i++){
                        fullerrmsg=fullerrmsg+"\n"+tmpEx[i];
                    }
            Email myAdminEmail = new Email();
                myAdminEmail.setSubject("Exception thrown in GeneDataTools.java");
                myAdminEmail.setContent("There was an error setting up to run findGeneRegion.pl.pl\n\nFull Stacktrace:\n"+fullerrmsg);
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
        return completedSuccessfully;
    }
    public String generateXMLTrack(String chromosome,int min,int max,String panel,String track,String organism,String genomeVer,int rnaDatasetID,int arrayTypeID,String folderName,int binSize,String version,int countType){
        String status="";
        try{
            //Connection tmpConn=pool.getConnection();
            log.debug("before get public user id");
            int publicUserID=(new User()).getUser_id("public",pool);
            log.debug("PUBLIC USER ID:"+publicUserID);
            //tmpConn.close();
            String tmpOutputDir=fullPath + "tmpData/browserCache/"+genomeVer+"/regionData/"+folderName+"/";
            
            HashMap<String,String> source=this.getGenomeVersionSource(genomeVer);
            String ensemblPath=source.get("ensembl");
            Properties myProperties = new Properties();
            File myPropertiesFile = new File(dbPropertiesFile);
            myProperties.load(new FileInputStream(myPropertiesFile));

            String dsn="dbi:mysql:database="+myProperties.getProperty("DATABASE")+";host="+myProperties.getProperty("HOST")+";port=3306";
            String dbUser=myProperties.getProperty("USER");
            String dbPassword=myProperties.getProperty("PASSWORD");
            
            Properties myVerProperties = new Properties();
            log.debug("UCSC file:"+ucscDBVerPropertiesFile);
            File myVerPropertiesFile = new File(ucscDBVerPropertiesFile);
            myVerProperties.load(new FileInputStream(myVerPropertiesFile));
            log.debug("read prop");
            //String dbVer=myVerProperties.getProperty("UCSCDATE");
            //String refSeqDB=organism+"_"+myVerProperties.getProperty("REFSEQVER");
            String ucscHost=myVerProperties.getProperty("HOST");
            String ucscPort=myVerProperties.getProperty("PORT");
            String ucscUser=myVerProperties.getProperty("USER");
            String ucscPassword=myVerProperties.getProperty("PASSWORD");
            
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
            
            /*String refSeqDB="Rn_refseq_5";
            if(organism.equals("Mm")){
                refSeqDB="Mm_refseq_5";
            }*/
            /*String genome="rn5";
            if(organism.equals("Mm")){
                genome="mm10";
            }*/
            log.debug("done properties");
            //NEED TO MODIFY*************************
            String ensDsn="DBI:mysql:database="+source.get("ensembl")+";host="+ensHost+";port=3306;";
            String ucscDsn="DBI:mysql:database="+source.get("ucsc")+";host="+ucscHost+";port=3306;";
            //NEED TO MODIFY******************************************************************************************************
            String tissue="Brain";
            if(track.startsWith("liver") || track.toLowerCase().endsWith("liver")){
                tissue="Liver";
            }else if(track.startsWith("heart") || track.toLowerCase().endsWith("heart")){
                tissue="Heart";
            }else if(track.startsWith("merged")){
                tissue="Merged";
            }
            
            //construct perl Args
            String[] perlArgs = new String[26];
            perlArgs[0] = "perl";
            perlArgs[1] = perlDir + "writeXML_Track.pl";
            perlArgs[2] = tmpOutputDir;
            if (organism.equals("Rn")) {
                perlArgs[3] = "Rat";
            }else if (organism.equals("Mm")) {
                perlArgs[3] = "Mouse";
            }
            String tmpTrack=track;
            if(!version.equals("")){
                tmpTrack=tmpTrack+"_"+version;
            }
            if(track.indexOf("illumina")>-1) {
                if (countType == 1) {
                    tmpTrack = tmpTrack + ";Total;";
                } else if (countType == 2) {
                    tmpTrack = tmpTrack + ";Norm;";
                }
            }
            perlArgs[4] = tmpTrack;
            perlArgs[5] = panel;
            perlArgs[6]=chromosome;
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

            //set environment variables so you can access oracle pulled from perlEnvVar session variable which is a comma separated list
            String[] envVar=perlEnvVar.split(",");

            for (int i = 0; i < envVar.length; i++) {
                if(envVar[i].contains("/ensembl")){
                    envVar[i]=envVar[i].replaceAll("/ensembl", "/"+ensemblPath);
                }
                log.debug(i + " EnvVar::" + envVar[i]);
            }
            //construct ExecHandler which is used instead of Perl Handler because environment variables were needed.
            myExec_session = new ExecHandler(perlDir, perlArgs, envVar, fullPath + "tmpData/browserCache/"+genomeVer+"/regionData/"+folderName+"/"+track);
            boolean exception=false;
            try {
                myExec_session.runExec();
                status="successful";
            } catch (ExecException e) {
                exception=true;
                e.printStackTrace(System.err);
                status="Error generating track";
                log.error("In Exception of run writeXML_Track.pl Exec_session", e);
                String errors=myExec_session.getErrors();
                if(errors!=null && errors.length()>0 ){
                    setError("Running Perl Script to get Gene and Transcript details/images.");
                    Email myAdminEmail = new Email();
                    myAdminEmail.setSubject("Exception thrown in Exec_session");
                    myAdminEmail.setContent("There was an error while running "
                            + perlArgs[1] + " (" + perlArgs[2] +" , "+perlArgs[3]+" , "+perlArgs[4]+" , "+perlArgs[5]+" , "+perlArgs[6]+","+perlArgs[7]+","+perlArgs[8]+
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
                }
            }

            String errors=myExec_session.getErrors();
            //log.debug("Error String:"+errors);
            if(!exception && errors!=null && !(errors.equals(""))){
                status="Error generating track";
                Email myAdminEmail = new Email();
                myAdminEmail.setSubject("Error is not null in Exec_session");
                myAdminEmail.setContent("There was not an exception but error output was not empty while running "
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
            }
        }catch(Exception e){
            status="Error generating track";
            log.error("Error getting DB properties or Public User ID.",e);
            String fullerrmsg=e.getMessage();
                    StackTraceElement[] tmpEx=e.getStackTrace();
                    for(int i=0;i<tmpEx.length;i++){
                        fullerrmsg=fullerrmsg+"\n"+tmpEx[i];
                    }
            Email myAdminEmail = new Email();
                myAdminEmail.setSubject("Exception thrown in GeneDataTools.java");
                myAdminEmail.setContent("There was an error setting up to run writeXML_Track.pl\n\nFull Stacktrace:\n"+fullerrmsg);
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
        return status;
    }
    
     public String generateCustomBedXMLTrack(String chromosome,int min,int max,String track,String organism,String folder,String bedFile,String outputFile){
        String status="";
        try{        
            //construct perl Args
            String[] perlArgs = new String[7];
            perlArgs[0] = "perl";
            perlArgs[1] = perlDir + "bed2XML.pl";
            perlArgs[2] = fullPath +bedFile;
            perlArgs[3] = fullPath +outputFile;
            
            perlArgs[4] = Integer.toString(min);
            perlArgs[5] = Integer.toString(max);
            perlArgs[6] = chromosome;

            File dir=new File(fullPath + "tmpData/trackXML/"+folder+"/");
            if(dir.exists()||dir.mkdirs()){
                for (int i = 0; i < perlArgs.length; i++) {
                    log.debug(i + " perlArgs::" + perlArgs[i]);
                }
                //set environment variables so you can access oracle pulled from perlEnvVar session variable which is a comma separated list
                String[] envVar=perlEnvVar.split(",");
                
                for (int i = 0; i < envVar.length; i++) {
                    log.debug(i + " EnvVar::" + envVar[i]);
                    /*if(envVar[i].startsWith("PERL5LIB")&&organism.equals("Mm")){
                        envVar[i]=envVar[i].replaceAll("ensembl_ucsc", "ensembl_ucsc_old");
                    }*/
                }
                //construct ExecHandler which is used instead of Perl Handler because environment variables were needed.
                myExec_session = new ExecHandler(perlDir, perlArgs, envVar, fullPath + "tmpData/trackXML/"+folder+"/");
                boolean exception=false;
                try {
                    myExec_session.runExec();
                    status="successful";
                } catch (ExecException e) {
                    exception=true;
                    status="Error generating track";
                    log.error("In Exception of run bed2XML.pl Exec_session", e);
                    setError("Running Perl Script to get Gene and Transcript details/images.");
                    Email myAdminEmail = new Email();
                    myAdminEmail.setSubject("Exception thrown in Exec_session");
                    myAdminEmail.setContent("There was an error while running "
                            + perlArgs[1] + " (" + perlArgs[2] +" , "+perlArgs[3]+" , "+perlArgs[4]+" , "+perlArgs[5]+" , "+perlArgs[6]+","+perlArgs[7]+","+perlArgs[8]+
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
                if(!exception && errors!=null && !(errors.equals(""))){
                    status="Error generating track";
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

                }
            }
        }catch(Exception e){
            status="Error generating track";
            log.error("Error getting DB properties or Public User ID.",e);
            String fullerrmsg=e.getMessage();
                    StackTraceElement[] tmpEx=e.getStackTrace();
                    for(int i=0;i<tmpEx.length;i++){
                        fullerrmsg=fullerrmsg+"\n"+tmpEx[i];
                    }
            Email myAdminEmail = new Email();
                myAdminEmail.setSubject("Exception thrown in GeneDataTools.java");
                myAdminEmail.setContent("There was an error setting up to run bed2XML.pl\n\nFull Stacktrace:\n"+fullerrmsg);
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
        return status;
    }
    
    public String generateCustomBedGraphXMLTrack(String chromosome,int min,int max,String track,String organism,String folder,String bedFile,String outputFile,int binSize){
        String status="";
        try{        
            //construct perl Args
            String[] perlArgs = new String[8];
            perlArgs[0] = "perl";
            perlArgs[1] = perlDir + "bedGraph2XML.pl";
            perlArgs[2] = fullPath+bedFile;
            perlArgs[3] = fullPath+outputFile;
            perlArgs[4] = Integer.toString(min);
            perlArgs[5] = Integer.toString(max);
            perlArgs[6] = chromosome;
            perlArgs[7] = Integer.toString(binSize);
            File dir=new File(fullPath + "tmpData/trackXML/"+folder+"/");
            if(dir.exists()||dir.mkdirs()){
                for (int i = 0; i < perlArgs.length; i++) {
                    log.debug(i + " perlArgs::" + perlArgs[i]);
                }
                //set environment variables so you can access oracle pulled from perlEnvVar session variable which is a comma separated list
                String[] envVar=perlEnvVar.split(",");
                
                //for (int i = 0; i < envVar.length; i++) {
                //    log.debug(i + " EnvVar::" + envVar[i]);
                    /*if(envVar[i].startsWith("PERL5LIB")&&organism.equals("Mm")){
                        envVar[i]=envVar[i].replaceAll("ensembl_ucsc", "ensembl_ucsc_old");
                    }*/
                //}
                //construct ExecHandler which is used instead of Perl Handler because environment variables were needed.
                myExec_session = new ExecHandler(perlDir, perlArgs, envVar, fullPath + "tmpData/trackXML/"+folder+"/");
                boolean exception=false;
                try {
                    myExec_session.runExec();
                    status="successful";
                } catch (ExecException e) {
                    exception=true;
                    status="Error generating track";
                    log.error("In Exception of run bed2XML.pl Exec_session", e);
                    setError("Running Perl Script to get Gene and Transcript details/images.");
                    Email myAdminEmail = new Email();
                    myAdminEmail.setSubject("Exception thrown in Exec_session");
                    myAdminEmail.setContent("There was an error while running "
                            + perlArgs[1] + " (" + perlArgs[2] +" , "+perlArgs[3]+" , "+perlArgs[4]+" , "+perlArgs[5]+" , "+perlArgs[6]+","+perlArgs[7]+","+perlArgs[8]+
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
                if(!exception && errors!=null && !(errors.equals(""))){
                    status="Error generating track";
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

                }
            }
        }catch(Exception e){
            status="Error generating track";
            log.error("Error getting DB properties or Public User ID.",e);
            String fullerrmsg=e.getMessage();
                    StackTraceElement[] tmpEx=e.getStackTrace();
                    for(int i=0;i<tmpEx.length;i++){
                        fullerrmsg=fullerrmsg+"\n"+tmpEx[i];
                    }
            Email myAdminEmail = new Email();
                myAdminEmail.setSubject("Exception thrown in GeneDataTools.java");
                myAdminEmail.setContent("There was an error setting up to run bed2XML.pl\n\nFull Stacktrace:\n"+fullerrmsg);
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
        return status;
    }
    
    public String generateCustomRemoteXMLTrack(String chromosome,int min,int max,String track,String organism,String folder,String bedFile,String outputFile,String type,String url,int binSize){
        String status="";
        int paramSize=7;
        String function="bigBed2XML.pl";
        //String fullBed=fullPath+bedFile;
        if(type.equals("bw")){
                paramSize=8;
                function="bigWig2XML.pl";
                //fullBed=url;
        }
        String[] perlArgs = new String[paramSize];
        perlArgs[0] = "perl";
        perlArgs[1] = perlDir + function;
        perlArgs[2] = url;
        perlArgs[3] = fullPath+outputFile;
        perlArgs[4] = Integer.toString(min);
        perlArgs[5] = Integer.toString(max);
        perlArgs[6] = chromosome;
        if(type.equals("bw")){
            perlArgs[7]=Integer.toString(binSize);
        }
        try{        
            //construct perl Args
            

            File dir=new File(fullPath + "tmpData/trackXML/"+folder+"/");
            if(dir.exists()||dir.mkdirs()){
                for (int i = 0; i < perlArgs.length; i++) {
                    log.debug(i + " perlArgs::" + perlArgs[i]);
                }
                //set environment variables so you can access oracle pulled from perlEnvVar session variable which is a comma separated list
                String[] envVar=perlEnvVar.split(",");
                
                //for (int i = 0; i < envVar.length; i++) {
                //    log.debug(i + " EnvVar::" + envVar[i]);
                    /*if(envVar[i].startsWith("PERL5LIB")&&organism.equals("Mm")){
                        envVar[i]=envVar[i].replaceAll("ensembl_ucsc", "ensembl_ucsc_old");
                    }*/
                //}
                //construct ExecHandler which is used instead of Perl Handler because environment variables were needed.
                myExec_session = new ExecHandler(perlDir, perlArgs, envVar, fullPath + "tmpData/trackXML/"+folder+"/");
                boolean exception=false;
                try {
                    myExec_session.runExec();
                    status="successful";
                } catch (ExecException e) {
                    exception=true;
                    status="Error generating track";
                    log.error("In Exception of run bed2XML.pl Exec_session", e);
                    setError("Running Perl Script to get Gene and Transcript details/images.");
                    Email myAdminEmail = new Email();
                    myAdminEmail.setSubject("Exception thrown in Exec_session");
                    myAdminEmail.setContent("There was an error while running "
                            + perlArgs[1] + " (" + perlArgs[2] +" , "+perlArgs[3]+" , "+perlArgs[4]+" , "+perlArgs[5]+" , "+perlArgs[6]+","+perlArgs[7]+","+perlArgs[8]+
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
                if(!exception && errors!=null && !(errors.equals(""))){
                    status="Error generating track";
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

                }
            }
        }catch(Exception e){
            status="Error generating track";
            log.error("Error getting DB properties or Public User ID.",e);
            String fullerrmsg=e.getMessage();
                    StackTraceElement[] tmpEx=e.getStackTrace();
                    for(int i=0;i<tmpEx.length;i++){
                        fullerrmsg=fullerrmsg+"\n"+tmpEx[i];
                    }
            Email myAdminEmail = new Email();
                myAdminEmail.setSubject("Exception thrown in GeneDataTools.java");
                myAdminEmail.setContent("There was an error setting up to run "+function+"\n\nFull Stacktrace:\n"+fullerrmsg);
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
        return status;
    }
     
    /*public boolean createRegionImagesXMLFiles(String folderName,String organism,String genomeVer,String ensemblPath,int arrayTypeID,int rnaDatasetID,String ucscDB){
        boolean completedSuccessfully=false;
        try{
            //Connection tmpConn=pool.getConnection();
            int publicUserID=new User().getUser_id("public",pool);
            //tmpConn.close();
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
            perlArgs[2] = ucscDir+ucscGeneDir;
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
            myExec_session = new ExecHandler(perlDir, perlArgs, envVar, outputDir+"genRegion");
            boolean exception=false;
            try {

                myExec_session.runExec();

            } catch (ExecException e) {
                exception=true;
                log.error("In Exception of run writeXML_Region.pl Exec_session", e);
                setError("Running Perl Script to get Gene and Transcript details/images.");
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
    }*/
    
    public AsyncGeneDataTools callAsyncGeneDataTools(String chr, int min, int max,int arrayTypeID,int rnaDS_ID,String genomeVer,boolean isENSGene){
        AsyncGeneDataTools agdt;         
        agdt = new AsyncGeneDataTools(session,pool,outputDir,chr, min, max,arrayTypeID,rnaDS_ID,usageID,genomeVer,isENSGene,"");
        //log.debug("Getting ready to start");
        agdt.start();
        //log.debug("Started AsyncGeneDataTools");
        return agdt;
    }
    
    
    
    public boolean callWriteXML(String id,String organism,String genomeVer,String chr, int min, int max,int arrayTypeID,int rnaDS_ID){
        boolean completedSuccessfully=false;
        log.debug("callWriteXML()"+id+","+organism+","+genomeVer+","+arrayTypeID+","+rnaDS_ID);
        try{
            //Connection tmpConn=pool.getConnection();
            int publicUserID=new User().getUser_id("public",pool);
            //tmpConn.close();
            String tmpoutputDir = fullPath + "tmpData/browserCache/"+genomeVer+"/geneData/" + id + "/";
            HashMap<String,String> source=this.getGenomeVersionSource(genomeVer);
            String ensemblPath=source.get("ensembl");
            File test=new File(tmpoutputDir+"Region.xml");
            long testLM=test.lastModified();
            testLM=(new Date().getTime())-testLM;
            long fifteenMin=15*60*1000;
            if(!test.exists() || (test.length()==0 && testLM>fifteenMin)){
                log.debug("createXML outputDir:"+tmpoutputDir);
                File outDir=new File(tmpoutputDir);
                if(outDir.exists()){
                    outDir.mkdirs();
                }
                Properties myProperties = new Properties();
                File myPropertiesFile = new File(dbPropertiesFile);
                myProperties.load(new FileInputStream(myPropertiesFile));

                String dsn="dbi:mysql:database="+myProperties.getProperty("DATABASE")+";host="+myProperties.getProperty("HOST")+";port=3306";
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
                log.debug("loaded properties");

                //construct perl Args
                String[] perlArgs = new String[21];
                perlArgs[0] = "perl";
                perlArgs[1] = perlDir + "writeXML_RNA.pl";
                perlArgs[2] = tmpoutputDir;
                if (organism.equals("Rn")) {
                    perlArgs[3] = "Rat";
                } else if (organism.equals("Mm")) {
                    perlArgs[3] = "Mouse";
                }
                perlArgs[4] = "Core";
                perlArgs[5] = id;
                perlArgs[6] = ucscDir+ucscGeneDir;
                perlArgs[7] = Integer.toString(arrayTypeID);
                perlArgs[8] = Integer.toString(rnaDS_ID);
                perlArgs[9] = Integer.toString(publicUserID);
                perlArgs[10]= genomeVer;
                perlArgs[11] = dsn;
                perlArgs[12] = dbUser;
                perlArgs[13] = dbPassword;
                perlArgs[14] = ensHost;
                perlArgs[15] = ensPort;
                perlArgs[16] = ensUser;
                perlArgs[17] = ensPassword;
                perlArgs[18] = mongoHost;
                perlArgs[19] = mongoUser;
                perlArgs[20] = mongoPassword;


                log.debug("setup params");
                //set environment variables so you can access oracle pulled from perlEnvVar session variable which is a comma separated list
                String[] envVar=perlEnvVar.split(",");

                for (int i = 0; i < envVar.length; i++) {
                    if(envVar[i].contains("/ensembl")){
                        envVar[i]=envVar[i].replaceFirst("/ensembl", "/"+ensemblPath);
                    }
                    log.debug(i + " EnvVar::" + envVar[i]);
                }
                log.debug("setup envVar");
                //construct ExecHandler which is used instead of Perl Handler because environment variables were needed.
                myExec_session = new ExecHandler(perlDir, perlArgs, envVar, fullPath + "tmpData/browserCache/"+genomeVer+"/geneData/"+id+"/");
                boolean exception = false;
                try {
                    myExec_session.runExec();
                } catch (ExecException e) {
                    exception=true;
                    completedSuccessfully=false;
                    e.printStackTrace(System.err);
                    log.error("In Exception of run callWriteXML:writeXML_RNA.pl Exec_session", e);

                    String errorList=myExec_session.getErrors();
                    boolean missingDB=false;
                    String apiVer="";

                        if(errorList.contains("does not exist in DB.")){
                            missingDB=true;
                        }
                        if(errorList.contains("Ensembl API version =")){
                            int apiStart=errorList.indexOf("Ensembl API version =")+22;
                            apiVer=errorList.substring(apiStart,apiStart+3);
                        }
                    Email myAdminEmail = new Email();
                    if(!missingDB){
                        myAdminEmail.setSubject("Exception thrown in Exec_session");
                        setError("Running Perl Script to get Gene and Transcript details/images. Ensembl Assembly v"+apiVer);
                    }else{
                        myAdminEmail.setSubject("Missing Ensembl ID in DB");
                        setError("The current Ensembl database does not have an entry for this gene ID."+
                                    " As Ensembl IDs are added/removed from new versions it is likely this ID has been removed."+
                                    " If you used a Gene Symbol and reached this the administrator will investigate. "+
                                    "If you entered this Ensembl ID please try to use a synonym or visit Ensembl to investigate the status of this ID. "+
                                    "Ensembl Assembly v"+apiVer);

                    }

                    myAdminEmail.setContent("There was an error while running "
                            + perlArgs[1] + " (" + perlArgs[2] +" , "+perlArgs[3]+" , "+perlArgs[4]+" , "+perlArgs[5]+" , "+perlArgs[6]+","+perlArgs[7]+
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
                if(!exception && errors!=null && !(errors.equals(""))){
                    completedSuccessfully=false;
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
                }
            }
        }catch(Exception e){
            completedSuccessfully=false;
            log.error("Error getting DB properties or Public User ID.",e);
            String fullerrmsg=e.getMessage();
                    StackTraceElement[] tmpEx=e.getStackTrace();
                    for(int i=0;i<tmpEx.length;i++){
                        fullerrmsg=fullerrmsg+"\n"+tmpEx[i];
                    }
            Email myAdminEmail = new Email();
                myAdminEmail.setSubject("Exception thrown in GeneDataTools.java");
                myAdminEmail.setContent("There was an error setting up to run writeXML_RNA.pl\n\nFull Stacktrace:\n"+fullerrmsg);
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
    
    public boolean callPanelExpr(String id,String chr, int min, int max,String genomeVer,int arrayTypeID,int rnaDS_ID,AsyncGeneDataTools prevThread){
        boolean error=false;
        String organism="Rn";
        if(arrayTypeID==21){
            organism="Mm";
        }
        callWriteXML(id,organism,genomeVer,chr,min,max,arrayTypeID,rnaDS_ID);
        //create File with Probeset Tissue herit and DABG
        /*String datasetQuery="select rd.dataset_id, rd.tissue "+
                            "from rnadataset_dataset rd "+
                            "where rd.rna_dataset_id = "+rnaDS_ID+" "+
                            "order by rd.tissue";
        
        Date start=new Date();
        Connection conn=null;
        try{
            conn=pool.getConnection();
            PreparedStatement ps = conn.prepareStatement(datasetQuery);
            ResultSet rs = ps.executeQuery();
            try{
                String ver="v9";
                if(arrayTypeID==21){
                    ver="v6";
                }
                String tmpOutput= fullPath + "tmpData/browserCache/"+genomeVer+"/geneData/" + id+ "/";
                //log.debug("Getting ready to start");
                File indivf=new File(tmpOutput+"Panel_Expr_indiv.txt");
                File groupf=new File(tmpOutput+"Panel_Expr_group.txt");
                long curTime=new Date().getTime();
                long indLM=indivf.lastModified();
                long groupLM=groupf.lastModified();
                indLM=curTime-indLM;
                groupLM=curTime-groupLM;
                long twoHours=1000*60*10;
                if(!indivf.exists() || !groupf.exists()||((groupf.length()==0 && groupLM>twoHours) || (indivf.length()==0 && indLM>twoHours))){
                    log.debug("\n\ntrying to run\n\n");
                    BufferedWriter outGroup=new BufferedWriter(new FileWriter(groupf));
                    BufferedWriter outIndiv=new BufferedWriter(new FileWriter(indivf));
                    ArrayList<AsyncGeneDataExpr> localList=new ArrayList<AsyncGeneDataExpr>();
                    SyncAndClose sac=new SyncAndClose(start,localList,null,pool,outGroup,outIndiv,usageID,tmpOutput);
                    log.debug("\n\nafter setup\n\n");
                    while(rs.next()){
                        AsyncGeneDataExpr agde=new AsyncGeneDataExpr(session,tmpOutput+"tmp_psList.txt",tmpOutput,null,threadList,maxThreadRunning,outGroup,outIndiv,sac,ver);
                        String dataset_id=Integer.toString(rs.getInt("DATASET_ID"));
                        int iDSID=rs.getInt("DATASET_ID");
                        String tissue=rs.getString("TISSUE");
                        log.debug("\nAGDE for "+iDSID+":"+tissue+"\n");
                        String tissueNoSpaces=tissue.replaceAll(" ", "_");
                        edu.ucdenver.ccp.PhenoGen.data.Dataset sDataSet=new edu.ucdenver.ccp.PhenoGen.data.Dataset();
                        //Connection tmpConn=pool.getConnection();
                        edu.ucdenver.ccp.PhenoGen.data.Dataset curDS=sDataSet.getDataset(iDSID,pool,"");
                        //tmpConn.close();
                        String affyFile="allPS";
                        String verStr="allPS";
                        if(arrayTypeID==21){
                            affyFile="NormVer";
                            verStr=ver;
                        }
                        log.debug("After Dataset before paths");
                        String DSPath=userFilesRoot+"public/Datasets/"+curDS.getNameNoSpaces()+"_Master/Affy."+affyFile+".h5";
                        String sampleFile=userFilesRoot+"public/Datasets/"+curDS.getNameNoSpaces()+"_Master/"+verStr+"_samples.txt";
                        String groupFile=userFilesRoot+"public/Datasets/"+curDS.getNameNoSpaces()+"_Master/"+verStr+"_groups.txt";
                        String outGroupFile="group_"+tissueNoSpaces+"_exprVal.txt";
                        String outIndivFile="indiv_"+tissueNoSpaces+"_exprVal.txt";
                        log.debug("after paths");
                        agde.add(DSPath,sampleFile,groupFile,outGroupFile,outIndivFile,tissue,curDS.getPlatform());
                        log.debug("after add agde");
                        threadList.add(agde);
                        localList.add(agde);
                        log.debug("before start");
                        agde.start();     
                        log.debug("after start");
                    }
                    
                }
                try{
                    ps.close();
                }catch(Exception e){}
                try{
                    conn.close();
                }catch(Exception e){}
                //log.debug("Started AsyncGeneDataExpr");
            }catch(IOException ioe){
                log.error("IOException:\n",ioe);
            }
            
        }catch(SQLException e){
            error=true;
            log.error("Error getting dataset id",e);
            setError("SQL Error occurred while setting up Panel Expression");
        }finally{
           try {
                    if(conn!=null)
                        conn.close();
                } catch (SQLException ex) {
                }
        }*/
        return error;
    }
    
    
    private String getUCSCUrlwoGlobal(String urlFile){
        String ret="error";
        try{
                String[] urls=myFH.getFileContents(new File(urlFile));
                ret=urls[1];
                ret=ret.replaceFirst("&position=", "&pix='800'&position=");
        }catch(IOException e){
                log.error("Error reading url file "+urlFile,e);
        }
        return ret;
    }
    private boolean getUCSCUrl(String urlFile){
        boolean error=false;
        String[] urls;
        try{
                urls=myFH.getFileContents(new File(urlFile));
                this.geneSymbol=urls[0];
                this.returnGeneSymbol=this.geneSymbol;
                if(urls.length>2){
                    this.returnGeneSymbol=urls[2];
                }
                
                //session.setAttribute("geneSymbol", this.geneSymbol);
                this.ucscURL=urls[1];
                this.ucscURL=this.ucscURL.replaceFirst("&position=", "&pix='800'&position=");
                int start=urls[1].indexOf("position=")+9;
                int end=urls[1].indexOf("&",start);
                String position=urls[1].substring(start,end);
                String[] split=position.split(":");
                String chromosome=split[0].substring(3);
                String[] split2=split[1].split("-");
                this.minCoord=Integer.parseInt(split2[0]);
                this.maxCoord=Integer.parseInt(split2[1]);
                this.chrom=chromosome;
                //log.debug(ucscURL+"\n");
        }catch(IOException e){
                log.error("Error reading url file "+urlFile,e);
                setError("Reading URL File");
                error=true;
        }
        return error;
    }
    
    private boolean getUCSCUrls(String ensemblID1){
        boolean error=false;
        String[] urls;
        try{
                urls=myFH.getFileContents(new File(outputDir + ensemblID1+".url"));
                this.geneSymbol=urls[0];
                this.returnGeneSymbol=this.geneSymbol;
                
                //session.setAttribute("geneSymbol", this.geneSymbol);
                this.ucscURL=urls[1];
                int start=urls[1].indexOf("position=")+9;
                int end=urls[1].indexOf("&",start);
                String position=urls[1].substring(start,end);
                String[] split=position.split(":");
                String chromosome=split[0].substring(3);
                String[] split2=split[1].split("-");
                this.minCoord=Integer.parseInt(split2[0]);
                this.maxCoord=Integer.parseInt(split2[1]);
                this.chrom=chromosome;
                //log.debug(ucscURL+"\n");
        }catch(IOException e){
                log.error("Error reading url file "+outputDir + ensemblID1,e);
                setError("Reading URL File");
                error=true;
        }
        return error;
    }

    public String getChromosome() {
        return chrom;
    }

    public int getMinCoord() {
        return minCoord;
    }

    public int getMaxCoord() {
        return maxCoord;
    }
    
    private String loadErrorMessage(){
        String ret="";
        try{
                File err=new File(outputDir +"errMsg.txt");
                if(err.exists()){
                    String[] tmp=myFH.getFileContents(new File(outputDir +"errMsg.txt"));
                    if(tmp!=null){
                        if(tmp.length>=1){
                            ret=tmp[0];
                        }
                        for(int i=1;i<tmp.length;i++){
                            ret=ret+"\n"+tmp;
                        }
                    }
                }
        }catch(IOException e){
                log.error("Error reading errMsg.txt file "+outputDir ,e);
                setError("Reading errMsg File");
        }
        return ret;
    }
    
    private void setError(String errorMessage){
        String tmp=returnGenURL;
        if(tmp==null||tmp.equals("")||!tmp.startsWith("ERROR:")){
            //session.setAttribute("genURL","ERROR: "+errorMessage);
            returnGenURL="ERROR: "+errorMessage;
        }else{
            returnGenURL=returnGenURL+", "+errorMessage;
        }
    }
    
    /*private void setReturnSessionVar(boolean error,String folderName){
        if(!error){
            session.setAttribute("genURL",urlPrefix + "tmpData/geneData/" + folderName + "/");
            session.setAttribute("ucscURL", this.ucscURL);
            session.setAttribute("ucscURLFiltered", this.ucscURLfilter);
            session.setAttribute("curOutputDir",outputDir);
        }else{
            String tmp=(String)session.getAttribute("genURL");
            if(tmp.equals("")||!tmp.startsWith("ERROR:")){
                session.setAttribute("genURL","ERROR:Unknown Error");
            }
            session.setAttribute("ucscURL", "");
            session.setAttribute("ucscURLFiltered", "");
            if(folderName!=null && !folderName.equals("")){
                try{
                    new FileHandler().writeFile((String)session.getAttribute("genURL"),outputDir+"errMsg.txt");
                }catch(IOException e){
                    log.error("Error writing errMsg.txt",e);
                }
            }
        }
    }*/
    
    private void setPublicVariables(boolean error,String genomeVer,String folderName){
        if(!error){
            returnGenURL=urlPrefix + "tmpData/browserCache/"+genomeVer+"/geneData/" + folderName + "/";
            returnUCSCURL= this.ucscURL;
            returnOutputDir=outputDir;
        }else{
            String tmp=returnGenURL;
            if(tmp.equals("")||!tmp.startsWith("ERROR:")){
                returnGenURL="ERROR:Unknown Error";
            }
            returnUCSCURL= "";
            if(folderName!=null && !folderName.equals("")){
                try{
                    new FileHandler().writeFile(returnGenURL,outputDir+"errMsg.txt");
                }catch(IOException e){
                    log.error("Error writing errMsg.txt",e);
                }
            }
        }
        
        
    }
    
    public HttpSession getSession() {
        return session;
    }

    public String formatDate(GregorianCalendar gc) {
        String ret;
        String year = Integer.toString(gc.get(GregorianCalendar.YEAR));
        String month = Integer.toString(gc.get(GregorianCalendar.MONTH) + 1);
        if (month.length() == 1) {
            month = "0" + month;
        }
        String day = Integer.toString(gc.get(GregorianCalendar.DAY_OF_MONTH));
        if (day.length() == 1) {
            day = "0" + day;
        }
        String hour = Integer.toString(gc.get(GregorianCalendar.HOUR_OF_DAY));
        if (hour.length() == 1) {
            hour = "0" + hour;
        }
        String minute = Integer.toString(gc.get(GregorianCalendar.MINUTE));
        if (minute.length() == 1) {
            minute = "0" + minute;
        }
        ret = year + month + day + hour + minute;
        return ret;
    }
    
    public void setSession(HttpSession inSession) {
        //log.debug("in GeneDataTools.setSession");
        this.session = inSession;
        
        //log.debug("start");
        //this.dbConn = (Connection) session.getAttribute("dbConn");
        this.pool= (DataSource) session.getAttribute("dbPool");
        //this.poolRO= (DataSource) session.getAttribute("dbPoolRO");
        //log.debug("db");
        this.perlDir = (String) session.getAttribute("perlDir") + "scripts/";
        //log.debug("perl"+perlDir);
        String contextRoot = (String) session.getAttribute("contextRoot");
        //log.debug("context"+contextRoot);
        String host = (String) session.getAttribute("host");
        //log.debug("host"+host);
        String appRoot = (String) session.getAttribute("applicationRoot");
        //log.debug("app"+appRoot);
        this.fullPath = appRoot + contextRoot;
        //log.debug("fullpath");
        this.rFunctDir = (String) session.getAttribute("rFunctionDir");
        //log.debug("rFunction");
        
        //this.urlPrefix=(String)session.getAttribute("mainURL");
        //if(urlPrefix.endsWith(".jsp")){
            urlPrefix="https://" + host + contextRoot;
        //}
        //log.debug("mainURL");
        this.perlEnvVar=(String)session.getAttribute("perlEnvVar");
        //log.debug("PerlEnv");
        this.ucscDir=(String)session.getAttribute("ucscDir");
        this.ucscGeneDir=(String)session.getAttribute("ucscGeneDir");
        //log.debug("ucsc");
        this.bedDir=(String) session.getAttribute("bedDir");
        //log.debug("bedDir");
        
        this.dbPropertiesFile = (String)session.getAttribute("dbPropertiesFile");
        this.ensemblDBPropertiesFile = (String)session.getAttribute("ensDbPropertiesFile");
        this.ucscDBVerPropertiesFile = (String)session.getAttribute("ucscDbPropertiesFile");
        this.mongoDBPropertiesFile = (String)session.getAttribute("mongoDbPropertiesFile");
        log.debug("UCSC File:"+ucscDBVerPropertiesFile);
        if(session.getAttribute("maxRThreadCount")!=null){
            this.maxThreadRunning = Integer.parseInt((String)session.getAttribute("maxRThreadCount"));
        }
        if(session.getAttribute("userFilesRoot")!=null){
            this.userFilesRoot = (String) session.getAttribute("userFilesRoot");
            //log.debug("userFilesRoot");
        }
        threadList=(ArrayList<Thread>)session.getServletContext().getAttribute("threadList");
        isSessionSet=true;
    }

    public ArrayList<Gene> mergeOverlapping(ArrayList<Gene> initialList){
        ArrayList<Gene> mainGenes=new ArrayList<Gene>();
        ArrayList<Gene> rnaGenes=new ArrayList<Gene>();
        ArrayList<Gene> singleExon=new ArrayList<Gene>();
        for(int i=0;i<initialList.size();i++) {
            if (initialList.get(i).getSource().equals("Ensembl")) {
                mainGenes.add(initialList.get(i));
            } else {
                rnaGenes.add(initialList.get(i));
            }
        }
        for(int i=0;i<rnaGenes.size();i++){
            double maxOverlap=0;
            int maxIndex=-1;
            for(int j=0;j<mainGenes.size();j++){
                double overlapPerc=calculateOverlap(rnaGenes.get(i),mainGenes.get(j));
                if(overlapPerc>maxOverlap){
                    maxOverlap=overlapPerc;
                    maxIndex=j;
                }
            }
            if(maxIndex>-1){
                //merge into mainGene at maxIndex
                ArrayList<Transcript> rnaTrans=rnaGenes.get(i).getTranscripts();
                mainGenes.get(maxIndex).addTranscripts(rnaTrans);
            }else{
                //add to main
                if(rnaGenes.get(i).isSingleExon()){
                    singleExon.add(rnaGenes.get(i));
                }else{
                    mainGenes.add(rnaGenes.get(i)); 
                }
            }
        }
        for(int i=0;i<singleExon.size();i++){
            mainGenes.add(singleExon.get(i));
        }
        return mainGenes;
    }
    
    public ArrayList<Gene> mergeAnnotatedOverlapping(ArrayList<Gene> initialList){
        ArrayList<Gene> mainGenes=new ArrayList<Gene>();
        ArrayList<Gene> rnaGenes=new ArrayList<Gene>();
        //ArrayList<Gene> singleExon=new ArrayList<Gene>();
        HashMap<String,Gene> hm=new HashMap<String,Gene>();
        for(int i=0;i<initialList.size();i++){
            if(initialList.get(i).getSource().equals("Ensembl")){
                mainGenes.add(initialList.get(i));
                hm.put(initialList.get(i).getGeneID(),initialList.get(i));
            }else{
                rnaGenes.add(initialList.get(i));
            }
        }
        for(int i=0;i<rnaGenes.size();i++){
            String ens=rnaGenes.get(i).getEnsemblAnnotation();
            if(hm.containsKey(ens)){
                Gene tmpG=hm.get(ens);
                ArrayList<Transcript> tmpTrx=rnaGenes.get(i).getTranscripts();
                tmpG.addTranscripts(tmpTrx);
            }else{
                //add to main
                mainGenes.add(rnaGenes.get(i)); 
            }
        }
        return mainGenes;
    }

    public HashMap<String,HashMap<String,HashMap<String,Double>>> getTPM(String geneIDs,String dsIDs){
        HashMap<String,HashMap<String,HashMap<String,Double>>> ret= new HashMap<>();
        String tpmQ="select rd.tissue,rtt.* from rna_transcripts_tpm rtt left outer join rna_dataset rd on rd.rna_dataset_id=rtt.rna_dataset_id  where rtt.rna_dataset_id in ("+dsIDs+ ") and (rtt.feature_id in (" +geneIDs+ ") or rtt.alt_feature_id in ("+geneIDs+") )";
        log.debug("TPMQ\n"+tpmQ);
        try (Connection conn=pool.getConnection()){
            PreparedStatement psC = conn.prepareStatement(tpmQ);
            ResultSet rsC = psC.executeQuery();
            while(rsC.next()){
                String tissue=rsC.getString(1);
                String id=rsC.getString(3);
                String altID=rsC.getString(7);
                String mainID=id;
                if(!geneIDs.contains(id)){
                    mainID=altID;
                }
                if(! ret.containsKey(tissue)){
                    ret.put(tissue,new HashMap<String,HashMap<String,Double>>());
                }
                String keyMed="ensmed";
                String keyMin="ensmin";
                String keyMax="ensmax";
                if(id.startsWith("PRN")){
                    keyMed="reconmed";
                    keyMin="reconmin";
                    keyMax="reconmax";
                }
                if(ret.get(tissue).containsKey(mainID)){
                    HashMap<String, Double> tmp=ret.get(tissue).get(mainID);
                    tmp.put(keyMed,rsC.getDouble(4));
                    tmp.put(keyMin,rsC.getDouble(5));
                    tmp.put(keyMax,rsC.getDouble(6));
                    if(id.startsWith("ENS")) {
                        tmp.put("geneHerit", rsC.getDouble(8));
                        tmp.put("trxHerit", rsC.getDouble(9));
                    }
                }else {
                    HashMap<String, Double> tmp=new HashMap<>();
                    tmp.put(keyMed,rsC.getDouble(4));
                    tmp.put(keyMin,rsC.getDouble(5));
                    tmp.put(keyMax,rsC.getDouble(6));
                    if(id.startsWith("ENS")) {
                        tmp.put("geneHerit", rsC.getDouble(8));
                        tmp.put("trxHerit", rsC.getDouble(9));
                    }
                    ret.get(tissue).put(mainID, tmp);
                }
            }
        }catch(SQLException e) {
            log.error("getTPM error",e);
        }
        return ret;
    }
    public void addRegionHeritEQTLs(ArrayList<Gene> list,int min, int max,String organism,String chr,String hrdpVer,String genomeVer,double pvalue){

        if(chr.startsWith("chr")){
            chr=chr.substring(3);
        }
        String chrQ="select chromosome_id,name from chromosomes where organism='"+organism+"'";
        HashMap<Integer,String> chrHM=new HashMap<>();
        HashMap<String,RNASeqHeritQTLData> geneHM=new HashMap<>();
        try (Connection conn=pool.getConnection()){
            int chrID=-99;
            PreparedStatement psC = conn.prepareStatement(chrQ);
            ResultSet rsC = psC.executeQuery();
            while(rsC.next()){
                int tmpID=rsC.getInt(1);
                String name=rsC.getString(2);
                chrHM.put(tmpID,name);
                if(name.equals(chr.toUpperCase())) {
                    chrID=tmpID;
                }
            }
            rsC.close();
            psC.close();
            //get region Phenogen Gene IDs
            String heritQ="select rt.merge_gene_id, rt.herit_gene,rt.rna_dataset_id,rta.annotation from rna_transcripts rt "+
                " left outer join rna_transcripts_annot rta on rt.rna_transcript_id=rta.rna_transcript_id "+
                "where rt.rna_dataset_id in (97,98) "+
                "and rt.chromosome_id="+chrID+" "+
                "and (( "+min+"<=rt.trstart and rt.trstart<="+max+") "+
                "or ( "+min+"<=rt.trstop and rt.trstop<="+max+") "+
                    " or (rt.trstart <= "+min+" and "+max+"<=rt.trstop))";
            log.debug("region herit:"+heritQ);
            PreparedStatement psH = conn.prepareStatement(heritQ);
            ResultSet rsH = psH.executeQuery();
            while(rsH.next()){
                String id=rsH.getString(4);
                String phenogenID=rsH.getString(1);
                String ensemblID=rsH.getString(4);
                if(ensemblID!=null && ensemblID.startsWith("ENSRNOG")){
                    ensemblID=ensemblID.substring(0,ensemblID.indexOf(":"));
                }
                String tissue="";
                if(rsH.getInt(3)==97){
                    tissue="Whole Brain";
                }else if(rsH.getInt(3)==98){
                    tissue="Liver";
                }
                if(ensemblID!=null && ensemblID.startsWith("ENSRNOG")){
                    id=ensemblID;
                }else{
                    id=phenogenID;
                }
                if(geneHM.containsKey(id) ) {
                    RNASeqHeritQTLData tmp=geneHM.get(id);
                    tmp.addHerit(tissue, rsH.getDouble(2));
                }else{
                    RNASeqHeritQTLData tmp=new RNASeqHeritQTLData(phenogenID,ensemblID);
                    tmp.addHerit(tissue,rsH.getDouble(2));
                    if(phenogenID!=null){
                        geneHM.put(phenogenID,tmp);
                    }
                    if(ensemblID!=null) {
                        geneHM.put(ensemblID, tmp);
                    }
                }
            }
            psH.close();
            StringBuffer sb=new StringBuffer();
            HashMap<String,Gene> p2E=new HashMap<>();
            for(int i=0;i<list.size();i++) {
                Gene curGene=list.get(i);
                if(geneHM.containsKey(curGene.getGeneID())) {
                    RNASeqHeritQTLData tmpSeq=geneHM.get(curGene.getGeneID());
                    curGene.setRNASeq(tmpSeq);
                    if(tmpSeq.getPhenogenID()!=null) {
                        sb.append(",'" + tmpSeq.getPhenogenID() + "'");
                    }
                    if(tmpSeq.getEnsemblID()!=null){
                        sb.append(",'" + tmpSeq.getEnsemblID() + "'");
                    }
                    if(tmpSeq.getPhenogenID()!=null && !tmpSeq.getPhenogenID().equals("")) {
                        p2E.put(tmpSeq.getPhenogenID(), curGene);
                    }
                    if(tmpSeq.getEnsemblID()!=null && !tmpSeq.getEnsemblID().equals("")) {
                        p2E.put(tmpSeq.getEnsemblID(), curGene);
                    }
                }
            }
            if(sb.length()>1) {
                //get region eQTLs for Gene IDs
                String qtlQ = "select s.chromosome_id,s.coord,s.tissue,lse.PROBE_ID,lse.PVALUE,lse.is_cis,lse.cor_pvalue from LOCATION_SPECIFIC_EQTL_HRDP lse " +
                        "inner join snps_hrdp s on s.snp_id=lse.snp_id " +
                        "where s.rna_dataset_id in (97,98) " +
                        " and s.type='seq' " +
                        " and lse.probe_id in ( " + sb.substring(1) + " )"+
                        " and ( (lse.is_cis=0 and lse.pvalue <= 0.000001 ) "+
                        " or ( lse.is_cis=1 and lse.cor_pvalue <=0.05) )";
                log.debug("region qtl:" + qtlQ);
                PreparedStatement ps = conn.prepareStatement(qtlQ);
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    String id = rs.getString(4);
                    String tissue = rs.getString(3);
                    String location = chrHM.get(rs.getInt(1)) + ":" + rs.getInt(2);
                    double pval = rs.getDouble(5);
                    double corPval=rs.getDouble(7);
                    int isCis=rs.getInt(6);
                    if (p2E.containsKey(id)) {
                        RNASeqHeritQTLData cur = p2E.get(id).getRNASeq();
                        String source="ensembl";
                        if(id.startsWith("PRN")){
                            source="reconst";
                        }
                        if(isCis==1){
                            cur.addCount(tissue, corPval, location,true,source);
                        }else{
                            cur.addCount(tissue, pval, location,false,source);
                        }

                    }
                }
                ps.close();
            }
        }catch(SQLException e) {
            log.error("addRNASeqHeritQTL error",e);
        }
    }
    public void addHeritDABG(ArrayList<Gene> list,int min,int max,String organism,String chr,int rnaDS_ID,int arrayTypeID,String genomeVer){
        //get all probesets for region with herit and dabg
        if(chr.startsWith("chr")){
            chr=chr.substring(3);
        }
        String chrQ="select chromosome_id from chromosomes where name= '"+chr.toUpperCase()+"' and organism='"+organism+"'";

        HashMap probesets=new HashMap();
        try (Connection conn=pool.getConnection()){
            int chrID=-99;
            PreparedStatement psC = conn.prepareStatement(chrQ);
            ResultSet rsC = psC.executeQuery();
            if(rsC.next()){
                chrID=rsC.getInt(1);
            }
            rsC.close();
            psC.close();
            String probeQuery="select phd.probeset_id, rd.tissue, phd.herit,phd.dabg "+
                    "from probeset_herit_dabg phd " +
                    "left outer join rnadataset_dataset rd on rd.dataset_id = phd.dataset_id "+
                    "left outer join Affy_Exon_ProbeSet s on s.probeset_id = phd.probeset_id "+
                    "where rd.rna_dataset_id = "+rnaDS_ID+" "+
                    "and phd.dataset_id=rd.dataset_id "+
                    "and phd.genome_id='"+genomeVer+"' "+
                    "and s.chromosome_id = "+chrID+" "+
                    "and s.genome_id='"+genomeVer+"' "+
                    "and "+
                    "((s.psstart >= "+min+" and s.psstart <="+max+") OR "+
                    "(s.psstop >= "+min+" and s.psstop <= "+max+")) "+
                    "and s.psannotation <> 'transcript' " +
                    "and s.Array_TYPE_ID = "+arrayTypeID;
                    //"order by phd.probeset_id,rd.tissue";
            log.debug("herit/DABG SQL\n"+probeQuery);
            PreparedStatement ps = conn.prepareStatement(probeQuery);
            ResultSet rs = ps.executeQuery();
            while(rs.next()){
                String probeset=Integer.toString(rs.getInt("PROBESET_ID"));
                double herit=rs.getDouble("herit");
                double dabg=rs.getDouble("dabg");
                String tissue=rs.getString("TISSUE");
                //log.debug("adding"+probeset);
                if(probesets.containsKey(probeset)){
                    HashMap<String,HashMap> phm=(HashMap<String,HashMap>)probesets.get(probeset);
                    HashMap<String,Double> val=new HashMap<String,Double>();
                    val.put("herit", herit);
                    val.put("dabg", dabg);
                    phm.put(tissue, val);
                }else{
                    HashMap<String,HashMap> phm=new HashMap<String,HashMap>();
                    HashMap<String,Double> val=new HashMap<String,Double>();
                    val.put("herit", herit);
                    val.put("dabg", dabg);
                    phm.put(tissue, val);
                    probesets.put(probeset, phm);
                }
            }
            ps.close();
            conn.close();
            //log.debug("HashMap size:"+probesets.size());
        }catch(SQLException e){
            log.error("Error retreiving Herit/DABG.",e);
            System.err.println("Error retreiving Herit/DABG.");
            e.printStackTrace(System.err);
        }
        if(probesets!=null){
            //fill probeset data for each Gene
            for(int i=0;i<list.size();i++){
                Gene curGene=list.get(i);
                curGene.setHeritDabg(probesets);
            }
        }
        
    }
    //calculate the % of gene1 that overlaps gene2
    public double calculateOverlap(Gene gene1, Gene gene2){
        double ret=0;
        //needs to be on same strand
        if(gene1.getStrand().equals(gene2.getStrand())){
            long gene1S=gene1.getStart();
            long gene1E=gene1.getEnd();
            long gene2S=gene2.getStart();
            long gene2E=gene2.getEnd();
            
            long gene1Len=gene1E-gene1S;
            if(gene1S>gene2S&&gene1S<gene2E){
                long end=gene2E;
                if(gene1E<gene2E){
                    end=gene1E;
                }
                double len=end-gene1S;
                ret=len/gene1Len*100;
            }else if(gene1E>gene2S&&gene1E<gene2E){
                long start=gene2S;
                double len=gene1E-start;
                ret=len/gene1Len*100;
            }else if(gene1S<gene2S&&gene1E>gene2E){
                double len=gene2E-gene2S;
                ret=len/gene1Len*100;
            }
        }
        return ret;
    }
    
    public ArrayList<EQTL> getProbeEQTLs(int min,int max,String chr,int arrayTypeID,ArrayList<String> tissues,String genomeVer){
        ArrayList<EQTL> eqtls=new ArrayList<EQTL>();
        if(genomeVer.equals("rn5")||genomeVer.equals("mm10") ){
            if(chr.startsWith("chr")){
                chr=chr.substring(3);
            }
            String organism="Rn";
            if(genomeVer.startsWith("Mm")){
                organism="Mm";
            }
            //HashMap probesets=new HashMap();
            String chrQ="select chromosome_id from chromosomes where name= '"+chr.toUpperCase()+"' and organism='"+organism+"'";
            try (Connection conn=pool.getConnection()){
                int chrID=-99;
                PreparedStatement psC = conn.prepareStatement(chrQ);
                ResultSet rsC = psC.executeQuery();
                if(rsC.next()){
                    chrID=rsC.getInt(1);
                }
                rsC.close();
                psC.close();
                String qtlQuery="select eq.identifier,eq.lod_score,eq.p_value,eq.fdr,eq.marker,eq.marker_chromosome,eq.marker_mb,eq.lower_limit,eq.upper_limit,eq.tissue "+
                        "from Affy_Exon_ProbeSet s "+
                        "left outer join expression_qtls eq on eq.identifier = TO_CHAR (s.probeset_id) "+
                        "where s.chromosome_id = "+chrID+" "+
                        "and ((s.psstart >= "+min+" and s.psstart <="+max+") OR "+
                        "(s.psstop >= "+min+" and s.psstop <= "+max+")) "+
                        "and s.psannotation <> 'transcript' " +
                        "and s.Array_TYPE_ID = "+arrayTypeID+" "+
                        "and eq.lod_score>2.5 "+
                        "order by eq.identifier";
                log.debug("SQL\n"+qtlQuery);
                PreparedStatement ps = conn.prepareStatement(qtlQuery);
                ResultSet rs = ps.executeQuery();
                while(rs.next()){
                    String psID=rs.getString(1);
                    double lod=rs.getDouble(2);
                    double pval=rs.getDouble(3);
                    double fdr=rs.getDouble(4);
                    String marker=rs.getString(5);
                    String marker_chr=rs.getString(6);
                    double marker_loc=rs.getDouble(7);
                    double lower=rs.getDouble(8);
                    double upper=rs.getDouble(9);
                    String tissue=rs.getString(10);
                    EQTL eqtl=new EQTL(psID,marker,marker_chr,marker_loc,tissue,lod,pval,fdr,lower,upper);
                    eqtls.add(eqtl);
                    if(!tissues.contains(tissue)){
                        tissues.add(tissue);;
                    }
                }
                ps.close();
                conn.close();
                //log.debug("EQTL size:"+eqtls.size());
                //log.debug("Tissue Size:"+tissues.size());
            }catch(SQLException e){
                log.error("Error retreiving EQTLs.",e);
            }
        }else{
            
        }
        return eqtls;
    }
    
    public ArrayList<TranscriptCluster> getTransControlledFromEQTLs(int min,int max,String chr,int arrayTypeID,double pvalue,String level,String genomeVer){
        if(chr.startsWith("chr")){
            chr=chr.substring(3);
        }
        String tmpRegion=chr+":"+min+"-"+max;
        String curParams="min="+min+",max="+max+",chr="+chr+",arrayid="+arrayTypeID+",pvalue="+pvalue+",level="+level;
        ArrayList<TranscriptCluster> transcriptClusters=new ArrayList<TranscriptCluster>();
        HashMap<Integer,String> chrHM=new HashMap<>();
        /*boolean run=true;
        if(this.cacheHM.containsKey(tmpRegion)){
            HashMap regionHM=(HashMap)cacheHM.get(tmpRegion);
            String testParam=(String)regionHM.get("fromRegionParams");
            if(curParams.equals(testParam)){
                log.debug("\nPrevious results returned-controlled from\n");
                transcriptClusters=(ArrayList<TranscriptCluster>)regionHM.get("fromRegion");
                run=false;
            }
        }
        if(run){*/

            String organism="Rn";
            if(arrayTypeID==21){
                organism="Mm";
            }
            String chrQ="select chromosome_id,name from chromosomes where organism='"+organism+"'";
            int chrID=-99;
            try(Connection conn=pool.getConnection()){
                PreparedStatement psC = conn.prepareStatement(chrQ);
                ResultSet rsC = psC.executeQuery();
                while(rsC.next()){
                    int tmpID=rsC.getInt(1);
                    String tmpName=rsC.getString(2);
                    if(tmpName.equals(chr.toUpperCase())){
                        chrID=tmpID;
                    }
                    chrHM.put(tmpID,tmpName);
                }
                rsC.close();
                psC.close();

                int snpcount=0;
                String snpQ="select snp_id,tissue,snp_name,snp_start,snp_end,chromosome_id from snps s where "+
                        "s.genome_id='"+genomeVer+"' " +
                        "and s.type='array' ";

                HashMap<String,HashMap<String,String>> snpsHM=new HashMap<>();
                StringBuffer sb=new StringBuffer();
                PreparedStatement ps = conn.prepareStatement(snpQ);
                ResultSet rs = ps.executeQuery();
                while(rs.next()) {
                    if (sb.length() == 0) {
                        sb.append(rs.getInt(1));
                    } else {
                        sb.append("," + rs.getInt(1));
                    }
                    String id=Integer.toString(rs.getInt(1));
                    HashMap<String,String> snpEntry=new HashMap<>();
                    snpEntry.put("id",id);
                    snpEntry.put("tissue",rs.getString(2));
                    snpEntry.put("snp_name",rs.getString(3));
                    snpEntry.put("start",Integer.toString(rs.getInt(4)));
                    snpEntry.put("end",Integer.toString(rs.getInt(5)));
                    snpEntry.put("chr",Integer.toString(rs.getInt(6)));
                    snpsHM.put(id,snpEntry);
                    snpcount++;
                }
                rs.close();
                ps.close();
                log.debug("\ngenerating new-controlled from\n");
                String qtlQuery="select aep.transcript_cluster_id,'"+chr.toUpperCase()+"',aep.strand,aep.psstart,aep.psstop,aep.pslevel, lse.snp_id,lse.pvalue "+
                        "from affy_exon_probeset aep " +
                        "left outer join location_specific_eqtl lse on lse.probe_id=aep.probeset_id " +
                        //"left outer join chromosomes c2 on c2.chromosome_id = s.chromosome_id "+
                        "where lse.snp_id in ("+sb.toString()+") and aep.chromosome_id = "+chrID+" "+
                        "and aep.genome_id='"+genomeVer+"' "+
                        "and ((aep.psstart >="+min+" and aep.psstart <="+max+") or (aep.psstop>="+min+" and aep.psstop <="+max+")or (aep.psstop<="+min+" and aep.psstop >="+max+")) "+
                        "and aep.psannotation = 'transcript' ";
                if(level.equals("All")){
                    qtlQuery=qtlQuery+"and aep.pslevel <> 'ambiguous' ";
                }else{
                    qtlQuery=qtlQuery+"and aep.pslevel = '"+level+"' ";
                }
                qtlQuery=qtlQuery+"and aep.array_type_id="+arrayTypeID+" "+
                        "and aep.updatedlocation='Y' "+
                        "and lse.pvalue >= "+(-Math.log10(pvalue));
                        //+" order by aep.probeset_id,s.tissue,s.chromosome_id,s.snp_start";
                log.debug("SQL eQTL FROM QUERY\n"+qtlQuery);
                ps = conn.prepareStatement(qtlQuery);
                rs = ps.executeQuery();
                TranscriptCluster curTC=null;
                while(rs.next()){
                    String tcID=rs.getString(1);
                    //log.debug("process:"+tcID);
                    String tcChr=rs.getString(2);
                    int tcStrand=rs.getInt(3);
                    long tcStart=rs.getLong(4);
                    long tcStop=rs.getLong(5);
                    String tcLevel=rs.getString(6);

                    if(curTC==null||!tcID.equals(curTC.getTranscriptClusterID())){
                        if(curTC!=null){
                            transcriptClusters.add(curTC);
                        }
                        curTC=new TranscriptCluster(tcID,tcChr,Integer.toString(tcStrand),tcStart,tcStop,tcLevel);
                        //log.debug("create transcript cluster:"+tcID);
                    }
                    int snpID=rs.getInt(7);
                    String snpIDs=Integer.toString(snpID);
                    double pval=Math.pow(10, (-1*rs.getDouble(8)));
                    //log.debug("before curSNP:"+snpID);
                    HashMap<String,String> curSnp=snpsHM.get(snpIDs);
                    //log.debug("after curSNP");
                    String tissue=(String)curSnp.get("tissue");
                    //log.debug("after curSnp usage");
                    String marker_name=(String)curSnp.get("snp_name");
                    String marker_chr="Err";
                    long marker_start=Long.parseLong((String)curSnp.get("start"));
                    long marker_end=Long.parseLong((String)curSnp.get("end"));

                    int tmp_marker_chr=Integer.parseInt(curSnp.get("chr"));
                    if(chrHM.containsKey(tmp_marker_chr)){
                        marker_chr=chrHM.get(tmp_marker_chr);
                    }
                    //double tcLODScore=rs.getDouble(13);
                    curTC.addEQTL(tissue,pval,marker_name,marker_chr,marker_start,marker_end,0);
                }
                if(curTC!=null){
                    transcriptClusters.add(curTC);
                }
                ps.close();
                conn.close();
                log.debug("Transcript Cluster Size:"+transcriptClusters.size());
                /*if(cacheHM.containsKey(tmpRegion)){
                    HashMap regionHM=(HashMap)cacheHM.get(tmpRegion);
                    regionHM.put("fromRegionParams",curParams);        
                    regionHM.put("fromRegion",transcriptClusters);
                }else{
                    HashMap regionHM=new HashMap();
                    regionHM.put("fromRegionParams",curParams);        
                    regionHM.put("fromRegion",transcriptClusters);
                    cacheHM.put(tmpRegion,regionHM);
                    this.cacheList.add(tmpRegion);
                }*/
                //this.fromRegionParams=curParams;
                //this.fromRegion=transcriptClusters;
            }catch(SQLException e){
                log.error("Error retreiving EQTLs.",e);
                e.printStackTrace(System.err);
            }
        //}
        return transcriptClusters;
    }
    
    public String getFolder(int min,int max,String chr,String organism,String genomeVer){
        String folder="";

        if(chr.startsWith("chr")){
            chr=chr.substring(3);
        }
        log.debug("getFolderName:"+organism+"chr"+chr+"_"+min+"_"+max+"_");
        /*RegionDirFilter rdf=new RegionDirFilter(organism+"chr"+chr+"_"+min+"_"+max+"_");
        log.debug(fullPath + "tmpData/browserCache/"+genomeVer+"/regionData");
        File mainDir=new File(fullPath + "tmpData/browserCache/"+genomeVer+"/regionData");
        File[] list=mainDir.listFiles(rdf);    
        if(list.length>0){
            log.debug("length>0");
            String tmpOutputDir=list[0].getAbsolutePath()+"/";
            int second=tmpOutputDir.lastIndexOf("/",tmpOutputDir.length()-2);
            folder=tmpOutputDir.substring(second+1,tmpOutputDir.length()-1);
                        
        }
        log.debug(folder);*/
        folder=min+"_"+max;
        return folder;
    }

    public String getRegionEQTLMessage(){
        return regionEQTLErrorMessage;
    }

    public HashMap<String, TranscriptomeQTL> getRegionEQTLs(int min,int max,String chr,int arrayTypeID,int RNADatasetID,double pvalue,String organism,String genomeVer,String circosTissue,String circosChr,String dataSource,String cisTrans) {
        session.setAttribute("getTransControllingEQTL", "");
        regionEQTLErrorMessage="";
        if (chr.startsWith("chr")) {
            chr = chr.substring(3);
        }
        String folderName = min + "_" + max;
        String tmpOutputDir = fullPath + "tmpData/browserCache/" + genomeVer + "/regionData/chr" + chr + "/" + folderName + "/";
        File mainDir = new File(fullPath + "tmpData/browserCache/" + genomeVer + "/regionData/chr" + chr + "/" + folderName);
        if (!mainDir.exists()) {
            String panel = "BNLX/SHRH";
            if (organism.equals("Mm")) {
                panel = "ILS/ISS";
            }
            this.getRegionData(chr, min, max, panel, organism, genomeVer, RNADatasetID, arrayTypeID, pvalue, false, false);
        }

        circosTissue = circosTissue.replaceAll(";;", ";");
        circosChr = circosChr.replaceAll(";;", ";");

        String tmpRegion = chr + ":" + min + "-" + max;
        String curParams = "min=" + min + ",max=" + max + ",chr=" + chr + ",arrayid=" + arrayTypeID + ",pvalue=" + pvalue + ",org=" + organism;
        String curParamsMinusPval = "min=" + min + ",max=" + max + ",chr=" + chr + ",arrayid=" + arrayTypeID + ",org=" + organism;
        String curCircosParams = "min=" + min + ",max=" + max + ",chr=" + chr + ",arrayid=" + arrayTypeID + ",pvalue=" + pvalue + ",org=" + organism + ",circosTissue=" + circosTissue + ",circosChr=" + circosChr;
        boolean run = true;
        boolean filter = false;

        HashMap<String, TranscriptomeQTL> geneQTLHM = new HashMap<>();

        HashMap<Integer, String> chrHM = new HashMap<>();
        String org = "Rn";
        if (genomeVer.toLowerCase().startsWith("mm")) {
            org = "Mm";
        }
        String chrQ = "select chromosome_id,name from chromosomes where organism='" + org + "'";

        int chrID = -99;
        try (Connection conn = pool.getConnection()) {

            PreparedStatement psC = conn.prepareStatement(chrQ);
            ResultSet rsC = psC.executeQuery();
            while (rsC.next()) {
                int tmpID = rsC.getInt(1);
                String tmpName = rsC.getString(2);
                if (tmpName.equals(chr.toUpperCase())) {
                    chrID = tmpID;
                }
                chrHM.put(tmpID, tmpName);
            }
            rsC.close();
            psC.close();
            int snpcount = 0;
            String snpQ = "select snp_id,tissue,snp_name,coord from snps_hrdp s where " +
                    "s.genome_id='" + genomeVer + "' " +
                    "and s.type='seq' " +
                    "and s.chromosome_id = " + chrID + " " +
                    "and ( s.coord>=" + (min - 1000000) + " and s.coord<=" + (max + 1000000) + ") ";

            //if (dataSource.equals("seq")) {
            snpQ = snpQ + " and s.RNA_DATASET_ID in (97,98)";
            //}

            HashMap<String, HashMap<String, String>> snpsHM = new HashMap<>();
            StringBuffer sb = new StringBuffer();
            log.debug("SNP_HRDP Query\n" + snpQ);
            PreparedStatement ps = conn.prepareStatement(snpQ);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                if (sb.length() == 0) {
                    sb.append(rs.getInt(1));
                } else {
                    sb.append("," + rs.getInt(1));
                }
                String id = Integer.toString(rs.getInt(1));
                HashMap<String, String> snpEntry = new HashMap<>();
                snpEntry.put("id", id);
                snpEntry.put("tissue", rs.getString(2));
                snpEntry.put("snp_name", rs.getString(3));
                snpEntry.put("start", Integer.toString(rs.getInt(4)));
                snpsHM.put(id, snpEntry);
                snpcount++;
            }
            rs.close();
            ps.close();
            int isCis = 0;
            if (cisTrans.equals("all")) {
                isCis = 0;
            } else if (cisTrans.equals("cis")) {
                isCis = 1;
            }
            String qtlQuery = "select rt.rna_dataset_id,rt.merge_gene_id,c.name,rt.trstart,rt.trstop,rt.strand,rta.annotation,rncg.stable_id,rncsr.name,rncg.seq_region_start,rncg.seq_region_end,lse.probe_id,lse.snp_id, lse.pvalue,lse.is_cis " +
                    "from  location_specific_eqtl_hrdp lse " +
                    "left outer join RNA_TRANSCRIPTS rt on rt.MERGE_GENE_ID=lse.probe_id and rt.RNA_DATASET_ID in (97,98) " +
                    "left outer join rna_transcripts_annot rta on rta.rna_transcript_id=rt.rna_transcript_id " +
                    "left outer join chromosomes c on c.chromosome_id=rt.chromosome_id " +
                    "left outer join rattus_norvegicus_core_98_6.gene rncg on rncg.stable_id=lse.probe_id " +
                    "left outer join rattus_norvegicus_core_98_6.seq_region rncsr on rncsr.seq_region_id=rncg.seq_region_id and rncsr.coord_system_id=3 " +
                    "where lse.pvalue<=0.000001 " +
                    "and lse.snp_id in ( " + sb.toString() + ") ";
            if (cisTrans.equals("cis")) {
                qtlQuery = qtlQuery + "and lse.is_cis=" + isCis;
            }
            if(dataSource.equals("ensembl")){
                qtlQuery= qtlQuery+" and lse.probe_id like 'ENS%' ";
            }else if(dataSource.equals("reconst")){
                qtlQuery= qtlQuery+" and lse.probe_id like 'PRN%' ";
            }
            qtlQuery=qtlQuery+" order by lse.pvalue asc";
            log.debug("SQL eQTL FROM QUERY\n" + qtlQuery);
            ps = conn.prepareStatement(qtlQuery);
            rs = ps.executeQuery();
            while (rs.next()) {
                String probeID = rs.getString(12);
                String ensID = rs.getString(8);
                if (ensID == null && rs.getString(7) != null) {
                    ensID = rs.getString(7);
                    ensID = ensID.substring(0, ensID.indexOf(":"));
                }
                String phenogenID = rs.getString(2);
                String tcChr = "";
                String rtChr = rs.getString(3);
                String eChr = rs.getString(9);
                if (rtChr == null) {
                    tcChr = eChr;
                } else if (eChr == null) {
                    tcChr = rtChr;
                } else if (rtChr != null && eChr != null && rtChr.equals(eChr)) {
                    tcChr = rtChr;
                }

                int tcStrand = rs.getInt(6);
                int tcStart = rs.getInt(4);
                int tcEnd = rs.getInt(5);
                int ensStart = rs.getInt(10);
                int ensEnd = rs.getInt(11);
                int snpID = rs.getInt(13);
                double pval = rs.getDouble(14);
                int cis = rs.getInt(15);
                boolean isCis1 = false;
                if (cis == 1) {
                    isCis1 = true;
                }
                //log.debug("probe_id:"+probeID+":phenogen:"+phenogenID+":ens:"+ensID+":snpID:"+snpID+":pval:"+(-1*Math.log10(pval)));
                TranscriptomeQTL tmpQTL = null;
                if (ensID != null && geneQTLHM.containsKey(ensID)) {
                    tmpQTL = geneQTLHM.get(ensID);
                    if (phenogenID != null && !geneQTLHM.containsKey(phenogenID)) {
                        geneQTLHM.put(phenogenID, tmpQTL);
                    }
                }
                if (phenogenID != null && geneQTLHM.containsKey(phenogenID)) {
                    tmpQTL = geneQTLHM.get(phenogenID);
                    if (ensID != null && !geneQTLHM.containsKey(ensID)) {
                        geneQTLHM.put(ensID, tmpQTL);
                    }
                }
                if(!geneQTLHM.containsKey(probeID)){
                    tmpQTL = new TranscriptomeQTL();
                    if (ensID != null) {
                        tmpQTL.setEnsemblID(ensID);
                        if (!geneQTLHM.containsKey(ensID)) {
                            geneQTLHM.put(ensID, tmpQTL);
                        }
                    }
                    if (phenogenID != null) {
                        tmpQTL.setPhenogenID(phenogenID);
                        if (!geneQTLHM.containsKey(phenogenID)) {
                            geneQTLHM.put(phenogenID, tmpQTL);
                        }
                    }
                    tmpQTL.setProbeID(probeID);
                    tmpQTL.setChromosome(tcChr);
                    if (ensStart != 0 && tcStart != 0) {
                        if (tcStart < ensStart) {
                            tmpQTL.setStart(tcStart);
                        } else {
                            tmpQTL.setStart(ensStart);
                        }
                    } else if (ensStart == 0) {
                        tmpQTL.setStart(tcStart);
                    } else if (tcStart == 0) {
                        tmpQTL.setStart(ensStart);
                    }
                    if (ensEnd != 0 && tcEnd != 0) {
                        if (tcEnd > ensEnd) {
                            tmpQTL.setEnd(tcEnd);
                        } else {
                            tmpQTL.setEnd(ensEnd);
                        }
                    } else if (ensEnd == 0) {
                        tmpQTL.setEnd(tcEnd);
                    } else if (tcEnd == 0) {
                        tmpQTL.setEnd(ensEnd);
                    }
                    if (tcStrand == 0) {
                        tmpQTL.setStrand(0);
                    } else {
                        tmpQTL.setStrand(tcStrand);
                    }
                }
                //update IDs just in case
                if (tmpQTL.getEnsemblID().equals("") && ensID != null) {
                    tmpQTL.setEnsemblID(ensID);
                }
                if (tmpQTL.getPhenogenID().equals("") && phenogenID != null) {
                    tmpQTL.setPhenogenID(phenogenID);
                }
                if (tmpQTL != null) {
                    String snpIDstr = (new Integer(snpID)).toString();
                    HashMap<String, String> curSNP = snpsHM.get(snpIDstr);
                    tmpQTL.addQTL(probeID, curSNP.get("snp_name"), chr, Integer.parseInt(curSNP.get("start")), pval, isCis1, curSNP.get("tissue"));
                }

            }
            ps.close();
        } catch (SQLException e) {
            log.error("SQL Exception:" + e.toString(), e);
        }
        HashMap<String, String> previousOutput = new HashMap<>();
        Set keys = geneQTLHM.keySet();
        Iterator itr = keys.iterator();
        try {
            log.debug("open geneLocation.txt");
            BufferedWriter out = new BufferedWriter(new FileWriter(new File(tmpOutputDir + dataSource + "_geneLocation.txt")));
            while (itr.hasNext()) {
                TranscriptomeQTL tmpQ = (TranscriptomeQTL) geneQTLHM.get(itr.next());
                String pID = tmpQ.getEnsemblID();
                if (pID == null || pID.equals("")) {
                    pID = tmpQ.getPhenogenID();
                }
                if (!previousOutput.containsKey(pID)) {
                    String line = tmpQ.getProbeID() + "\t" + tmpQ.getChromosome() + "\t" + tmpQ.getStart() + "\t" + tmpQ.getEnd() + "\t" + tmpQ.getStrand() + "\n";
                    out.write(line);
                    previousOutput.put(tmpQ.getProbeID(), "");
                }
            }
            out.flush();
            out.close();
            log.debug("done output geneLocation.txt");
        } catch (IOException e) {
            log.error("I/O Exception trying to output geneLocation.txt file.", e);
            session.setAttribute("getTransControllingEQTL", "Error retreiving eQTLs(4).  Please try again later.  The administrator has been notified of the problem.");
            Email myAdminEmail = new Email();
            myAdminEmail.setSubject("Exception thrown in GeneDataTools.getTransControllingEQTLS");
            myAdminEmail.setContent("There was an error while running getTransControllingEQTLS.\nI/O Exception trying to output transcluster.txt file.", e);
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
        //log.debug("after geneLocation.txt");
        HashMap<String, String> source = getGenomeVersionSource(genomeVer);
        String ensemblPath = source.get("ensembl");
        File ensPropertiesFile = new File(ensemblDBPropertiesFile);
        Properties myENSProperties = new Properties();
        String ensHost = "";
        String ensPort = "";
        String ensUser = "";
        String ensPassword = "";
        try {
            myENSProperties.load(new FileInputStream(ensPropertiesFile));
            ensHost = myENSProperties.getProperty("HOST");
            ensPort = myENSProperties.getProperty("PORT");
            ensUser = myENSProperties.getProperty("USER");
            ensPassword = myENSProperties.getProperty("PASSWORD");
        } catch (IOException e) {
            log.error("I/O Exception trying to read properties file.", e);
            session.setAttribute("getTransControllingEQTL", "Error retreiving eQTLs(5).  Please try again later.  The administrator has been notified of the problem.");
            Email myAdminEmail = new Email();
            myAdminEmail.setSubject("Exception thrown in GeneDataTools.getTransControllingEQTLS");
            myAdminEmail.setContent("There was an error while running getTransControllingEQTLS.\nI/O Exception trying to read properties file.", e);
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

        /*boolean error=false;
        String[] perlArgs = new String[9];
        perlArgs[0] = "perl";
        perlArgs[1] = perlDir + "writeGeneIDs.pl";
        perlArgs[2] = tmpOutputDir+"transcluster.txt";
        perlArgs[3] = tmpOutputDir+"TC_to_Gene.txt";
        if (organism.equals("Rn")) {
            perlArgs[4] = "Rat";
        } else if (organism.equals("Mm")) {
            perlArgs[4] = "Mouse";
        }
        perlArgs[5] = ensHost;
        perlArgs[6] = ensPort;
        perlArgs[7] = ensUser;
        perlArgs[8] = ensPassword;


        //set environment variables so you can access oracle pulled from perlEnvVar session variable which is a comma separated list
        String[] envVar=perlEnvVar.split(",");

        for (int i = 0; i < envVar.length; i++) {
            if(envVar[i].contains("/ensembl")){
                envVar[i]=envVar[i].replaceFirst("/ensembl", "/"+ensemblPath);
            }
            log.debug(i + " EnvVar::" + envVar[i]);
        }


        //construct ExecHandler which is used instead of Perl Handler because environment variables were needed.
        myExec_session = new ExecHandler(perlDir, perlArgs, envVar, tmpOutputDir+"toGeneID");
        boolean exception=false;
        try {

            myExec_session.runExec();

        } catch (ExecException e) {
            exception=true;
            error=true;
            log.error("In Exception of run writeGeneIDs.pl Exec_session", e);
            session.setAttribute("getTransControllingEQTL","Error retreiving eQTLs(6).  Please try again later.  The administrator has been notified of the problem.");
            setError("Running Perl Script to match Transcript Clusters to Genes.");
            Email myAdminEmail = new Email();
            myAdminEmail.setSubject("Exception thrown in Exec_session");
            myAdminEmail.setContent("There was an error while running "
                    + perlArgs[1] + " (" + perlArgs[2] +" , "+perlArgs[3]+" , "+perlArgs[4]+")\n\n"+myExec_session.getErrors());
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
        if(!exception && errors!=null && !(errors.equals(""))){
            error=true;
            Email myAdminEmail = new Email();
            session.setAttribute("getTransControllingEQTL","Error retreiving eQTLs(1).  Please try again later.  The administrator has been notified of the problem.");
            myAdminEmail.setSubject("Exception thrown in Exec_session");
            myAdminEmail.setContent("There was an error while running "
                    + perlArgs[1] + " (" + perlArgs[2] +" , "+perlArgs[3]+" , "+perlArgs[4]+
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
        }
        if(!error){*/
        int finalCount = 0;
        try {
                /*log.debug("Read TC_to_Gene");
                BufferedReader in = new BufferedReader(new FileReader(new File(tmpOutputDir+"TC_to_Gene.txt")));
                while(in.ready()){
                    String line=in.readLine();
                    String[] tabs=line.split("\t");
                    String tcID=tabs[0];
                    String ensID=tabs[1];
                    String geneSym=tabs[2];
                    String sStart=tabs[3];
                    String sEnd=tabs[4];
                    String sOverlap=tabs[5];
                    String sOverlapG=tabs[6];
                    String description="";
                    if(tabs.length>7){
                        description=tabs[7];
                    }
                    if(tmpHM.containsKey(tcID)){
                        TranscriptCluster tmpTC=(TranscriptCluster)tmpHM.get(tcID);
                        tmpTC.addGene(ensID,geneSym,sStart,sEnd,sOverlap,sOverlapG,description);
                    }
                }
                in.close();*/
            log.debug("geneQTLDetails.txt");
            ArrayList<String> geneQTLKeys = new ArrayList<>(geneQTLHM.keySet());
            HashMap<String, String> processedHM = new HashMap<>();
            BufferedWriter out = new BufferedWriter(new FileWriter(new File(tmpOutputDir + dataSource + "_geneQTLDetails.txt")));
            int outputCount = 0;
            for (int i = 0; i < geneQTLKeys.size(); i++) {
                TranscriptomeQTL tQ = geneQTLHM.get(geneQTLKeys.get(i));
                HashMap<String, ArrayList<TrxQTL>> hm = tQ.getTissueQTLList(dataSource);
                String[] tissueKey = hm.keySet().toArray(new String[hm.size()]);
                if (tissueKey != null) {
                    for (int j = 0; j < tissueKey.length; j++) {
                        if (processedHM.containsKey(tissueKey[j] + ":" + tQ.getProbeID())) {
                        } else {
                            processedHM.put(tissueKey[j] + ":" + tQ.getProbeID(), "");
                            finalCount++;
                            String line = "";
                            ArrayList<TrxQTL> tmpQTLArr = (ArrayList<TrxQTL>) hm.get(tissueKey[j]);
                            if (tmpQTLArr != null && tmpQTLArr.size() > 0) {
                                TrxQTL tmpEQTL = tmpQTLArr.get(0);
                                line = tmpEQTL.getSnpID() + "\t" + tmpEQTL.getSNPChr() + "\t" + tmpEQTL.getSNPCoord();
                                line = line + "\t" + tQ.getProbeID() + "\t" + tQ.getChromosome() + "\t" + tQ.getStart() + "\t" + tQ.getEnd();
                                String tmpGeneSym = tQ.getEnsemblID();
                                if (tmpGeneSym == null || tmpGeneSym.equals("")) {
                                    tmpGeneSym = tQ.getPhenogenID();
                                }
                                if (tmpGeneSym == null || tmpGeneSym.equals("")) {
                                    tmpGeneSym = tQ.getProbeID();
                                }
                                line = line + "\t" + tmpGeneSym + "\t" + tissueKey[j] + "\t" + tmpEQTL.getNegLogPVal() + "\n";
                                out.write(line);
                                outputCount++;
                            }
                        }
                    }
                }

            }
            if (outputCount > 0){
                run = true;
             }else{
                regionEQTLErrorMessage="This region did not contain a QTL for any gene given the current parameters.  You can change the filtering parameters by clicking the filter button or expand the region in the browser.";
            }
            out.close();
            log.debug("Done-transcript cluster details.");
        } catch (IOException e) {
            log.error("Error reading Gene - Transcript IDs.", e);
            session.setAttribute("getTransControllingEQTL", "Error retreiving eQTLs(2).  Please try again later.  The administrator has been notified of the problem.");
            Email myAdminEmail = new Email();
            myAdminEmail.setSubject("Exception thrown in GeneDataTools.getTransControllingEQTLS");
            myAdminEmail.setContent("There was an error while running getTransControllingEQTLS.\nI/O Exception trying to read Gene - Transcript IDs file.", e);
            try {
                myAdminEmail.sendEmailToAdministrator((String) session.getAttribute("adminEmail"));
            } catch (Exception mailException) {
                log.error("error sending message", mailException);
            }
        }


        //}
        log.debug("Transcript Cluster Size:" + finalCount);
    /*}catch(SQLException e){
        log.error("Error retreiving EQTLs.",e);
        session.setAttribute("getTransControllingEQTL","Error retreiving eQTLs(3).  Please try again later.  The administrator has been notified of the problem.");
        e.printStackTrace(System.err);

        Email myAdminEmail = new Email();
        myAdminEmail.setSubject("Exception thrown in GeneDataTools.getTransControllingEQTLS");
        myAdminEmail.setContent("There was an error while running getTransControllingEQTLS.\n SQLException getting transcript clusters.",e);
        try {
            myAdminEmail.sendEmailToAdministrator((String) session.getAttribute("adminEmail"));
        } catch (Exception mailException) {
            log.error("error sending message", mailException);
        }
    }*/

        double tmpPval=-1*Math.log10(pvalue);
        File test=new File(tmpOutputDir.substring(0,tmpOutputDir.length()-1)+"/circos"+dataSource+cisTrans+tmpPval);
        if(run) {
            if (!test.exists()) {
                log.debug("\ngenerating new-circos\n");

                //run circos scripts
                boolean errorCircos = false;
                String[] perlArgs = new String[8];
                perlArgs[0] = "perl";
                perlArgs[1] = perlDir + "callCircosReverse.pl";
                perlArgs[2] = Double.toString(tmpPval);
                perlArgs[3] = organism;
                perlArgs[4] = tmpOutputDir.substring(0, tmpOutputDir.length() - 1);
                perlArgs[5] = circosTissue;
                perlArgs[6] = circosChr;
                perlArgs[7] = dataSource;
                //remove old circos directory
                double cutoff = pvalue;
                String circosDir = tmpOutputDir + "circos" + cutoff;
                File circosFile = new File(circosDir);
                if (circosFile.exists()) {
                    try {
                        myFH.deleteAllFilesPlusDirectory(circosFile);
                    } catch (Exception e) {
                        log.error("Error trying to delete circos directory\n", e);
                    }
                }

                //set environment variables so you can access oracle pulled from perlEnvVar session variable which is a comma separated list
                String[] envVar = perlEnvVar.split(",");

                //construct ExecHandler which is used instead of Perl Handler because environment variables were needed.
                myExec_session = new ExecHandler(perlDir, perlArgs, envVar, tmpOutputDir + "circos_" + pvalue);

                try {

                    myExec_session.runExec();
                } catch (ExecException e) {
                    //error=true;
                    log.error("In Exception of run callCircosReverse.pl Exec_session", e);
                    session.setAttribute("getTransControllingEQTLCircos", "Error running Circos.  Unable to generate Circos image.  Please try again later.  The administrator has been notified of the problem.");
                    setError("Running Perl Script to match create circos plot.");

                }
            }
        }else{

        }

        return geneQTLHM;
    }
    
    
    public ArrayList<TranscriptCluster> getTransControllingEQTLs(int min,int max,String chr,int arrayTypeID,int RNADatasetID,double pvalue,String level,String organism,String genomeVer,String circosTissue,String circosChr,String dataSource){
        //session.removeAttribute("get");
        session.setAttribute("getTransControllingEQTL","");
        ArrayList<TranscriptCluster> transcriptClusters=new ArrayList<TranscriptCluster>();
        ArrayList<TranscriptCluster> beforeFilter=null;
        if(chr.startsWith("chr")){
            chr=chr.substring(3);
        }
        String folderName=min+"_"+max;
        String tmpOutputDir=fullPath + "tmpData/browserCache/"+genomeVer+"/regionData/chr"+chr+"/"+folderName+"/";
        File mainDir=new File(fullPath + "tmpData/browserCache/"+genomeVer+"/regionData/chr"+chr+"/"+min+"_"+max);
        if(! mainDir.exists()){
                String panel="BNLX/SHRH";
                if(organism.equals("Mm")){
                    panel="ILS/ISS";
                }
                this.getRegionData(chr, min, max, panel, organism,genomeVer, RNADatasetID, arrayTypeID, pvalue, false,false);
        }

        circosTissue=circosTissue.replaceAll(";;", ";");
        circosChr=circosChr.replaceAll(";;", ";");

        String[] levels=level.split(";");
        String tmpRegion=chr+":"+min+"-"+max;
        String curParams="min="+min+",max="+max+",chr="+chr+",arrayid="+arrayTypeID+",pvalue="+pvalue+",level="+level+",org="+organism;
        String curParamsMinusPval="min="+min+",max="+max+",chr="+chr+",arrayid="+arrayTypeID+",level="+level+",org="+organism;
        String curCircosParams="min="+min+",max="+max+",chr="+chr+",arrayid="+arrayTypeID+",pvalue="+pvalue+",level="+level+",org="+organism+",circosTissue="+circosTissue+",circosChr="+circosChr;
        boolean run=true;
        boolean filter=false;

        HashMap<String,TranscriptCluster> tmpHM=new HashMap<String,TranscriptCluster>();
        HashMap<Integer,String> chrHM=new HashMap<>();
        String org="Rn";
        if(genomeVer.toLowerCase().startsWith("mm")){
            org="Mm";
        }
        String chrQ="select chromosome_id,name from chromosomes where organism='"+org+"'";

        int chrID=-99;
        try(Connection conn=pool.getConnection()){

            PreparedStatement psC = conn.prepareStatement(chrQ);
            ResultSet rsC = psC.executeQuery();
            while(rsC.next()){
                int tmpID=rsC.getInt(1);
                String tmpName=rsC.getString(2);
                if(tmpName.equals(chr.toUpperCase())){
                    chrID=tmpID;
                }
                chrHM.put(tmpID,tmpName);
            }
            rsC.close();
            psC.close();
            int snpcount=0;
            String snpQ="select snp_id,tissue,snp_name,snp_start,snp_end from snps s where "+
                    "s.genome_id='"+genomeVer+"' " +
                    "and s.type='"+dataSource+"' "+
                    "and s.chromosome_id = "+chrID+" " +
                    "and (((s.snp_start>="+min+" and s.snp_start<="+max+") or (s.snp_end>="+min+" and s.snp_end<="+max+") or (s.snp_start<="+min+" and s.snp_end>="+min+")) "+
                    " or (s.snp_start=s.snp_end and ((s.snp_start>="+(min-500000)+" and s.snp_start<="+(max+500000)+") or (s.snp_end>="+(min-500000)+" and s.snp_end<="+(max+500000)+") or (s.snp_start<="+(min-500000)+" and s.snp_end>="+(max+500000)+")))) ";

            if(dataSource.equals("seq")){
                snpQ=snpQ+" and s.RNA_DATASET_ID in (97,98)";
            }

            HashMap<String,HashMap<String,String>> snpsHM=new HashMap<>();
            StringBuffer sb=new StringBuffer();
            PreparedStatement ps = conn.prepareStatement(snpQ);
            ResultSet rs = ps.executeQuery();
            while(rs.next()) {
                if (sb.length() == 0) {
                    sb.append(rs.getInt(1));
                } else {
                    sb.append("," + rs.getInt(1));
                }
                String id=Integer.toString(rs.getInt(1));
                HashMap<String,String> snpEntry=new HashMap<>();
                snpEntry.put("id",id);
                snpEntry.put("tissue",rs.getString(2));
                snpEntry.put("snp_name",rs.getString(3));
                snpEntry.put("start",Integer.toString(rs.getInt(4)));
                snpEntry.put("end",Integer.toString(rs.getInt(5)));
                snpsHM.put(id,snpEntry);
                snpcount++;
            }
            rs.close();
            ps.close();
            String qtlQuery="";
            if(dataSource.equals("array")) {
                qtlQuery = "select aep.transcript_cluster_id,aep.chromosome_id,aep.strand,aep.psstart,aep.psstop,aep.pslevel,lse.snp_id, lse.pvalue " +
                        "from affy_exon_probeset aep " +
                        "inner join location_specific_eqtl lse on lse.probe_id=aep.probeset_id " +
                        "where  aep.genome_id='" + genomeVer + "' " +
                        "and aep.updatedlocation='Y' " +
                        "and aep.psannotation='transcript' " +
                        "and aep.array_type_id=" + arrayTypeID + " " +
                        "and lse.pvalue>=1.5 "+
                        "and lse.snp_id in ( " + sb.toString() + ")" ;

                if (!level.equals("All")) {
                    if (level.equals("core;extended;full")) {
                        qtlQuery = qtlQuery + " and aep.pslevel <> 'ambiguous' ";
                    } else {
                        qtlQuery = qtlQuery + " and ( ";
                        for (int k = 0; k < levels.length; k++) {
                            if (k == 0) {
                                qtlQuery = qtlQuery + " aep.pslevel='" + levels[k] + "' ";
                            } else {
                                qtlQuery = qtlQuery + " or aep.pslevel='" + levels[k] + "' ";
                            }
                        }
                        qtlQuery = qtlQuery + ") ";
                    }
                }
            }else{
                qtlQuery = "select rt.MERGE_GENE_ID,rt.chromosome_id,rt.strand,rt.trstart,rt.trstop,'',lse.snp_id, lse.pvalue " +
                        "from RNA_TRANSCRIPTS rt " +
                        "inner join location_specific_eqtl2 lse on lse.probe_id=rt.MERGE_GENE_ID " +
                        "where  rt.RNA_DATASET_ID in (97,98) " +
                        "and lse.pvalue>=2 "+
                        "and lse.snp_id in ( " + sb.toString() + ")" ;
            }
                log.debug("SQL eQTL FROM QUERY\n"+qtlQuery);
                ps = conn.prepareStatement(qtlQuery);
                rs = ps.executeQuery();
                eQTLRegions=new HashMap();
                TranscriptCluster curTC=null;
                while(rs.next()){
                    String tcID=rs.getString(1);
                    //log.debug("process:"+tcID);
                    String tcChr="Err";
                    int tmp_chr_ID=rs.getInt(2);
                    if(chrHM.containsKey(tmp_chr_ID)){
                        tcChr=chrHM.get(tmp_chr_ID);
                    }
                    int tcStrand=rs.getInt(3);
                    long tcStart=rs.getLong(4);
                    long tcStop=rs.getLong(5);
                    String tcLevel=rs.getString(6);
                    //log.debug("before tmpHM put");
                    if(tmpHM.containsKey(tcID)){
                        curTC=tmpHM.get(tcID);
                    }else{
                        curTC=new TranscriptCluster(tcID,tcChr,Integer.toString(tcStrand),tcStart,tcStop,tcLevel);
                        //log.debug("TC:\n"+tcID+":"+curTC);
                        tmpHM.put(tcID,curTC);
                    }
                    //log.debug("after tmpHM put");
                    double pval=Math.pow(10, (-1*rs.getDouble(8)));
                    int snpID=rs.getInt(7);
                    HashMap curSnp=snpsHM.get(Integer.toString(snpID));
                    String tissue=(String)curSnp.get("tissue");
                    String marker_name=(String)curSnp.get("snp_name");
                    String marker_chr=chr.toUpperCase();
                    long marker_start=Long.parseLong((String)curSnp.get("start"));
                    long marker_end=Long.parseLong((String)curSnp.get("end"));
                    //double tcLODScore=rs.getDouble(13);
                    //log.debug("before add region");
                    if(marker_chr.equals(chr) && ((marker_start>=min && marker_start<=max) || (marker_end>=min && marker_end<=max) || (marker_start<=min && marker_end>=max)) ){
                        //log.debug("add Region");
                        curTC.addRegionEQTL(tissue,pval,marker_name,marker_chr,marker_start,marker_end,-1);
                        DecimalFormat df=new DecimalFormat("#,###");
                        String eqtl="chr"+marker_chr+":"+df.format(marker_start)+"-"+df.format(marker_end);
                        if(!eQTLRegions.containsKey(eqtl)){
                            eQTLRegions.put(eqtl, 1);
                        }
                    }else{
                        //log.debug("add eqtl");
                        curTC.addEQTL(tissue,pval,marker_name,marker_chr,marker_start,marker_end,-1);
                    }
                    //log.debug("after add region");
                }
                ps.close();
                log.debug("done");
                

                if(snpcount==0){
                    session.setAttribute("getTransControllingEQTL","This region does not overlap with any markers used in the eQTL calculations.  You should expand the region to view eQTLs.");
                }/*else{
                    String qtlQuery2="select aep.transcript_cluster_id,aep.chromosome_id,aep.strand,aep.psstart,aep.psstop,aep.pslevel,lse.snp_id,lse.pvalue " +
                            "from location_specific_eqtl lse " +
                            "inner join affy_exon_probeset aep on aep.probeset_id=lse.probe_id " +
                            //"where lse.pvalue between 1.0 and "+(-Math.log10(pvalue))+" " +
                            "where lse.snp_id in ("+sb.toString()+") " +
                            "and aep.genome_id='"+genomeVer+"' "+
                            "and aep.updatedlocation='Y' " +
                            "and aep.psannotation='transcript' " +
                            "and aep.array_type_id="+arrayTypeID+" ";
                    /*String qtlQuery2="select aep.transcript_cluster_id,aep.chromosome_id,aep.strand,aep.psstart,aep.psstop,aep.pslevel, s.tissue,lse.pvalue, s.snp_name,'"+chr.toUpperCase()+"',s.snp_start,s.snp_end " +
                            "from location_specific_eqtl lse " +
                            "left outer join snps s on s.snp_id=lse.snp_id " +
                            "left outer join affy_exon_probeset aep on aep.probeset_id=lse.probe_id " +
                            //"left outer join chromosomes c2 on c2.chromosome_id=aep.chromosome_id " +
                            "where  s.genome_id='"+genomeVer+"' " +
                            "and s.type='array' "+
                            "and s.chromosome_id="+chrID+" " +
                            "and (((s.snp_start>="+min+" and s.snp_start<="+max+") or (s.snp_end>="+min+" and s.snp_end<="+max+") or (s.snp_start<="+min+" and s.snp_end>="+min+")) "+
                            " or (s.snp_start=s.snp_end and ((s.snp_start>="+(min-500000)+" and s.snp_start<="+(max+500000)+") or (s.snp_end>="+(min-500000)+" and s.snp_end<="+(max+500000)+") or (s.snp_start<="+(min-500000)+" and s.snp_end>="+(max+500000)+")))) "+
                            "and lse.pvalue between 1.0 and "+(-Math.log10(pvalue))+" " +
                            "and aep.genome_id='"+genomeVer+"' "+
                            "and aep.updatedlocation='Y' " +
                            "and aep.psannotation='transcript' " +
                            "and aep.array_type_id="+arrayTypeID+" ";*/

                 /*   if(!level.equals("All")){
                        qtlQuery2=qtlQuery2+" and ( ";
                        for(int k=0;k<levels.length;k++){
                            if(k==0){
                                qtlQuery2=qtlQuery2+"aep.pslevel='"+levels[k]+"' ";
                            }else{
                                qtlQuery2=qtlQuery2+" or aep.pslevel='"+levels[k]+"' ";
                            }
                        }
                        qtlQuery2=qtlQuery2+") ";
                    }
                    log.debug("Query2:"+qtlQuery2);
                    ps = conn.prepareStatement(qtlQuery2);
                    rs = ps.executeQuery();

                    while(rs.next()){
                        String tcID=rs.getString(1);
                        int snpID=rs.getInt(7);
                        HashMap curSnp=snpsHM.get(Integer.toString(snpID));
                        String tissue=(String)curSnp.get("tissue");
                        String marker_name=(String)curSnp.get("snp_name");
                        long marker_start=Long.parseLong((String)curSnp.get("start"));
                        long marker_end=Long.parseLong((String)curSnp.get("end"));
                        double pval=Math.pow(10, (-1*rs.getDouble(8)));
                        String marker_chr=chr.toUpperCase();

                        //double tcLODScore=rs.getDouble(13);
                        if(tmpHM.containsKey(tcID)){
                            TranscriptCluster tmpTC=(TranscriptCluster)tmpHM.get(tcID);
                            tmpTC.addRegionEQTL(tissue,pval,marker_name,marker_chr,marker_start,marker_end,-1);
                        }

                    }
                    ps.close();
                }*/
                conn.close();
                Set keys=tmpHM.keySet();
                Iterator itr=keys.iterator();
                try{
                    BufferedWriter out=new BufferedWriter(new FileWriter(new File(tmpOutputDir+"transcluster.txt")));
                    while(itr.hasNext()){
                        TranscriptCluster tmpC=(TranscriptCluster)tmpHM.get(itr.next().toString());
                        if(tmpC!=null){
                            if(tmpC.getTissueRegionEQTLs().size()>0){
                                transcriptClusters.add(tmpC);
                                String line=tmpC.getTranscriptClusterID()+"\t"+tmpC.getChromosome()+"\t"+tmpC.getStart()+"\t"+tmpC.getEnd()+"\t"+tmpC.getStrand()+"\n";
                                out.write(line);
                                
                            }
                        }
                    }
                    out.flush();
                    out.close();
                }catch(IOException e){
                    log.error("I/O Exception trying to output transcluster.txt file.",e);
                    session.setAttribute("getTransControllingEQTL","Error retreiving eQTLs(4).  Please try again later.  The administrator has been notified of the problem.");
                    Email myAdminEmail = new Email();
                    myAdminEmail.setSubject("Exception thrown in GeneDataTools.getTransControllingEQTLS");
                    myAdminEmail.setContent("There was an error while running getTransControllingEQTLS.\nI/O Exception trying to output transcluster.txt file.",e);
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
                HashMap<String,String> source=getGenomeVersionSource(genomeVer);
                String ensemblPath=source.get("ensembl");
                File ensPropertiesFile = new File(ensemblDBPropertiesFile);
                Properties myENSProperties = new Properties();
                String ensHost="";
                String ensPort="";
                String ensUser="";
                String ensPassword="";
                try{
                    myENSProperties.load(new FileInputStream(ensPropertiesFile));
                    ensHost=myENSProperties.getProperty("HOST");
                    ensPort=myENSProperties.getProperty("PORT");
                    ensUser=myENSProperties.getProperty("USER");
                    ensPassword=myENSProperties.getProperty("PASSWORD");
                }catch(IOException e){
                    log.error("I/O Exception trying to read properties file.",e);
                    session.setAttribute("getTransControllingEQTL","Error retreiving eQTLs(5).  Please try again later.  The administrator has been notified of the problem.");
                    Email myAdminEmail = new Email();
                    myAdminEmail.setSubject("Exception thrown in GeneDataTools.getTransControllingEQTLS");
                    myAdminEmail.setContent("There was an error while running getTransControllingEQTLS.\nI/O Exception trying to read properties file.",e);
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

                boolean error=false;
                String[] perlArgs = new String[9];
                perlArgs[0] = "perl";
                perlArgs[1] = perlDir + "writeGeneIDs.pl";
                perlArgs[2] = tmpOutputDir+"transcluster.txt";
                perlArgs[3] = tmpOutputDir+"TC_to_Gene.txt";
                if (organism.equals("Rn")) {
                    perlArgs[4] = "Rat";
                } else if (organism.equals("Mm")) {
                    perlArgs[4] = "Mouse";
                }
                perlArgs[5] = ensHost;
                perlArgs[6] = ensPort;
                perlArgs[7] = ensUser;
                perlArgs[8] = ensPassword;


                //set environment variables so you can access oracle pulled from perlEnvVar session variable which is a comma separated list
                String[] envVar=perlEnvVar.split(",");

                for (int i = 0; i < envVar.length; i++) {
                    if(envVar[i].contains("/ensembl")){
                        envVar[i]=envVar[i].replaceFirst("/ensembl", "/"+ensemblPath);
                    }
                    log.debug(i + " EnvVar::" + envVar[i]);
                }


                //construct ExecHandler which is used instead of Perl Handler because environment variables were needed.
                myExec_session = new ExecHandler(perlDir, perlArgs, envVar, tmpOutputDir+"toGeneID");
                boolean exception=false;
                try {

                    myExec_session.runExec();

                } catch (ExecException e) {
                    exception=true;
                    error=true;
                    log.error("In Exception of run writeGeneIDs.pl Exec_session", e);
                    session.setAttribute("getTransControllingEQTL","Error retreiving eQTLs(6).  Please try again later.  The administrator has been notified of the problem.");
                    setError("Running Perl Script to match Transcript Clusters to Genes.");
                    Email myAdminEmail = new Email();
                    myAdminEmail.setSubject("Exception thrown in Exec_session");
                    myAdminEmail.setContent("There was an error while running "
                            + perlArgs[1] + " (" + perlArgs[2] +" , "+perlArgs[3]+" , "+perlArgs[4]+")\n\n"+myExec_session.getErrors());
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
                if(!exception && errors!=null && !(errors.equals(""))){
                    error=true;
                    Email myAdminEmail = new Email();
                    session.setAttribute("getTransControllingEQTL","Error retreiving eQTLs(1).  Please try again later.  The administrator has been notified of the problem.");
                    myAdminEmail.setSubject("Exception thrown in Exec_session");
                    myAdminEmail.setContent("There was an error while running "
                            + perlArgs[1] + " (" + perlArgs[2] +" , "+perlArgs[3]+" , "+perlArgs[4]+
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
                }
                if(!error){
                    try{
                        log.debug("Read TC_to_Gene");
                        BufferedReader in = new BufferedReader(new FileReader(new File(tmpOutputDir+"TC_to_Gene.txt")));
                        while(in.ready()){
                            String line=in.readLine();
                            String[] tabs=line.split("\t");
                            String tcID=tabs[0];
                            String ensID=tabs[1];
                            String geneSym=tabs[2];
                            String sStart=tabs[3];
                            String sEnd=tabs[4];
                            String sOverlap=tabs[5];
                            String sOverlapG=tabs[6];
                            String description="";
                            if(tabs.length>7){
                                description=tabs[7];
                            }
                            if(tmpHM.containsKey(tcID)){
                                TranscriptCluster tmpTC=(TranscriptCluster)tmpHM.get(tcID);
                                tmpTC.addGene(ensID,geneSym,sStart,sEnd,sOverlap,sOverlapG,description);
                            }
                        }
                        in.close();
                        log.debug("write transcriptclusterdetails.txt");
                        BufferedWriter out= new BufferedWriter(new FileWriter(new File(tmpOutputDir+"TranscriptClusterDetails.txt")));
                        for(int i=0;i<transcriptClusters.size();i++){
                            TranscriptCluster tc=transcriptClusters.get(i);
                            HashMap hm=tc.getTissueRegionEQTLs();
                            Set key=hm.keySet();
                            if(key!=null){
                                Object[] tissue=key.toArray();
                                for(int j=0;j<tissue.length;j++){
                                    String line="";
                                    ArrayList<EQTL> tmpEQTLArr=(ArrayList<EQTL>)hm.get(tissue[j].toString());
                                    if(tmpEQTLArr!=null && tmpEQTLArr.size()>0){
                                        EQTL tmpEQTL=tmpEQTLArr.get(0);
                                        if(tmpEQTL.getMarkerChr().equals(chr) && 
                                                ((tmpEQTL.getMarker_start()>=min && tmpEQTL.getMarker_start()<=max) || 
                                                (tmpEQTL.getMarker_end()>=min && tmpEQTL.getMarker_end()<=max) || 
                                                (tmpEQTL.getMarker_start()<=min && tmpEQTL.getMarker_end()>=max))
                                                ){
                                            line=tmpEQTL.getMarkerName()+"\t"+tmpEQTL.getMarkerChr()+"\t"+tmpEQTL.getMarker_start();
                                            line=line+"\t"+tc.getTranscriptClusterID()+"\t"+tc.getChromosome()+"\t"+tc.getStart()+"\t"+tc.getEnd();
                                            String tmpGeneSym=tc.getGeneSymbol();
                                            if(tmpGeneSym==null||tmpGeneSym.equals("")){
                                                tmpGeneSym=tc.getGeneID();
                                            }
                                            if(tmpGeneSym==null||tmpGeneSym.equals("")){
                                                tmpGeneSym=tc.getTranscriptClusterID();
                                            }
                                            line=line+"\t"+tmpGeneSym+"\t"+tissue[j].toString()+"\t"+tmpEQTL.getNegLogPVal()+"\n";
                                            out.write(line);
                                        }
                                    }
                                }
                            }

                        }
                        out.close();
                        log.debug("Done-transcript cluster details.");
                    }catch(IOException e){
                        log.error("Error reading Gene - Transcript IDs.",e);
                        session.setAttribute("getTransControllingEQTL","Error retreiving eQTLs(2).  Please try again later.  The administrator has been notified of the problem.");
                        Email myAdminEmail = new Email();
                        myAdminEmail.setSubject("Exception thrown in GeneDataTools.getTransControllingEQTLS");
                        myAdminEmail.setContent("There was an error while running getTransControllingEQTLS.\nI/O Exception trying to read Gene - Transcript IDs file.",e);
                        try {
                            myAdminEmail.sendEmailToAdministrator((String) session.getAttribute("adminEmail"));
                        } catch (Exception mailException) {
                            log.error("error sending message", mailException);
                        }
                    }
                    

                }
                log.debug("Transcript Cluster Size:"+transcriptClusters.size());
                //this.controlledRegionParams=curParams;
                //this.controlledRegion=transcriptClusters;
                /*if(cacheHM.containsKey(tmpRegion)){
                    HashMap regionHM=(HashMap)cacheHM.get(tmpRegion);
                    regionHM.put("controlledRegionParams",curParams);        
                    regionHM.put("controlledRegion",transcriptClusters);
                }else{
                    HashMap regionHM=new HashMap();
                    regionHM.put("controlledRegionParams",curParams);        
                    regionHM.put("controlledRegion",transcriptClusters);
                    cacheHM.put(tmpRegion,regionHM);
                    this.cacheList.add(tmpRegion);
                }*/
            }catch(SQLException e){
                log.error("Error retreiving EQTLs.",e);
                session.setAttribute("getTransControllingEQTL","Error retreiving eQTLs(3).  Please try again later.  The administrator has been notified of the problem.");
                e.printStackTrace(System.err);

                Email myAdminEmail = new Email();
                    myAdminEmail.setSubject("Exception thrown in GeneDataTools.getTransControllingEQTLS");
                    myAdminEmail.setContent("There was an error while running getTransControllingEQTLS.\n SQLException getting transcript clusters.",e);
                    try {
                        myAdminEmail.sendEmailToAdministrator((String) session.getAttribute("adminEmail"));
                    } catch (Exception mailException) {
                        log.error("error sending message", mailException);
                    }
            }
        /*}else if(filter){//don't need to rerun just filter.
            log.debug("transcript controlling Filtering");
            String[] includedTissues=circosTissue.split(";");
            for(int i=0;i<includedTissues.length;i++){
                if(includedTissues[i].equals("Brain")){
                    includedTissues[i]="Whole Brain";
                }else if(includedTissues[i].equals("BAT")){
                    includedTissues[i]="Brown Adipose";
                }
            }
            for(int i=0;i<beforeFilter.size();i++){
                TranscriptCluster tc=beforeFilter.get(i);
                boolean include=false;
                for(int j=0;j<includedTissues.length&&!include;j++){
                    ArrayList<EQTL> regionQTL=tc.getTissueRegionEQTL(includedTissues[j]);
                    
                    if(regionQTL!=null){
                            EQTL regQTL=regionQTL.get(0);
                            if(regQTL.getPVal()<=pvalue){
                                    include=true;
                            }
                    }
                }
                if(include){
                    transcriptClusters.add(tc);
                }
            }
        }*/
        run=true;
        /*if(this.cacheHM.containsKey(tmpRegion)){
            HashMap regionHM=(HashMap)cacheHM.get(tmpRegion);
            String testParam=(String)regionHM.get("controlledCircosRegionParams");
            if(curCircosParams.equals(testParam)){
                //log.debug("\nreturning previous-circos\n");
                run=false;
            }
        }*/
        
        //File test=new File(tmpOutputDir.substring(0,tmpOutputDir.length()-1)+"/circos"+Double.toString(-Math.log10(pvalue)));
        File test=new File(tmpOutputDir.substring(0,tmpOutputDir.length()-1)+"/circos"+pvalue);
        if(!test.exists()){
            log.debug("\ngenerating new-circos\n");
            
            //run circos scripts
            boolean errorCircos=false;
            String[] perlArgs = new String[7];
            perlArgs[0] = "perl";
            perlArgs[1] = perlDir + "callCircosReverse.pl";
            perlArgs[2] = Double.toString(-Math.log10(pvalue));
            perlArgs[3] = organism;
            perlArgs[4] = tmpOutputDir.substring(0,tmpOutputDir.length()-1);
            perlArgs[5] = circosTissue;
            perlArgs[6] = circosChr;
            //remove old circos directory
            double cutoff=pvalue;
            String circosDir=tmpOutputDir+"circos"+cutoff;
            File circosFile=new File(circosDir);
            if(circosFile.exists()){
                try{
                    myFH.deleteAllFilesPlusDirectory(circosFile);
                }catch(Exception e){
                    log.error("Error trying to delete circos directory\n",e);
                }
            }

            //set environment variables so you can access oracle pulled from perlEnvVar session variable which is a comma separated list
            String[] envVar=perlEnvVar.split(",");

            //construct ExecHandler which is used instead of Perl Handler because environment variables were needed.
            myExec_session = new ExecHandler(perlDir, perlArgs, envVar, tmpOutputDir+"circos_"+pvalue);
            
            try {

                myExec_session.runExec();
            } catch (ExecException e) {
                //error=true;
                log.error("In Exception of run callCircosReverse.pl Exec_session", e);
                session.setAttribute("getTransControllingEQTLCircos","Error running Circos.  Unable to generate Circos image.  Please try again later.  The administrator has been notified of the problem.");
                setError("Running Perl Script to match create circos plot.");

            }
        }
        
        return transcriptClusters;
    }
    
    public ArrayList<SmallNonCodingRNA> getSmallNonCodingRNA(int min,int max,String chr,int rnaDatasetID,String organism){
        //session.removeAttribute("get");
        HashMap smncID=new HashMap();
        ArrayList<SmallNonCodingRNA> smncRNA=new ArrayList<SmallNonCodingRNA>();
        if(chr.startsWith("chr")){
            chr=chr.substring(3);
        }
        String tmpRegion=chr+":"+min+"-"+max;
        String curParams="min="+min+",max="+max+",chr="+chr+",org="+organism;
  
        /*boolean run=true;
        if(this.cacheHM.containsKey(tmpRegion)){
            HashMap regionHM=(HashMap)cacheHM.get(tmpRegion);
            String testParam=(String)regionHM.get("smallNonCodingParams");
            if(curParams.equals(testParam)){
                //log.debug("\nreturning previous-controlling\n");
                smncRNA=(ArrayList<SmallNonCodingRNA>)regionHM.get("smallNonCoding");
                run=false;
            }
        }
        if(run){*/
            HashMap tmpHM=new HashMap();

            String smncQuery="Select rsn.rna_smnc_id,rsn.feature_start,rsn.feature_stop,rsn.sample_count,rsn.total_reads,rsn.strand,rsn.reference_seq,c.name "+
                             "from rna_sm_noncoding rsn, chromosomes c "+ 
                             "where c.chromosome_id=rsn.chromosome_id "+
                             "and c.name = '"+chr.toUpperCase()+"' "+
                             "and rsn.rna_dataset_id="+rnaDatasetID+" "+
                             "and ((rsn.feature_start>="+min+" and rsn.feature_start<="+max+") OR (rsn.feature_stop>="+min+" and rsn.feature_stop<="+max+") OR (rsn.feature_start<="+min+" and rsn.feature_stop>="+max+")) ";

            String smncSeqQuery="select s.* from rna_smnc_seq s "+
                                "where s.rna_smnc_id in ("+
                                "select rsn.rna_smnc_id "+
                                "from rna_sm_noncoding rsn, chromosomes c "+ 
                                "where c.chromosome_id=rsn.chromosome_id "+
                                "and  c.name =  '"+chr.toUpperCase()+"' "+
                                "and rsn.rna_dataset_id="+rnaDatasetID+" "+
                                "and ((rsn.feature_start>="+min+" and rsn.feature_start<="+max+") OR (rsn.feature_stop>="+min+" and rsn.feature_stop<="+max+") OR (rsn.feature_start<="+min+" and rsn.feature_stop>="+max+")) "+
                                ")";
                                
            String smncAnnotQuery="select a.rna_smnc_annot_id,a.rna_smnc_id,a.annotation,s.shrt_name from rna_smnc_annot a,rna_annot_src s "+
                                "where s.rna_annot_src_id=a.source_id "+
                                "and a.rna_smnc_id in ("+
                                "select rsn.rna_smnc_id "+
                                "from rna_sm_noncoding rsn, chromosomes c "+ 
                                "where c.chromosome_id=rsn.chromosome_id "+
                                "and  c.name =  '"+chr.toUpperCase()+"' "+
                                "and rsn.rna_dataset_id="+rnaDatasetID+" "+
                                "and ((rsn.feature_start>="+min+" and rsn.feature_start<="+max+") OR (rsn.feature_stop>="+min+" and rsn.feature_stop<="+max+") OR (rsn.feature_start<="+min+" and rsn.feature_stop>="+max+")) "+
                                ")";
           
           String smncVarQuery="select v.* from rna_smnc_variant v "+
                                "where v.rna_smnc_id in ("+
                                "select rsn.rna_smnc_id "+
                                "from rna_sm_noncoding rsn, chromosomes c "+ 
                                "where c.chromosome_id=rsn.chromosome_id "+
                                "and  c.name =  '"+chr.toUpperCase()+"' "+
                                "and rsn.rna_dataset_id="+rnaDatasetID+" "+
                                "and ((rsn.feature_start>="+min+" and rsn.feature_start<="+max+") OR (rsn.feature_stop>="+min+" and rsn.feature_stop<="+max+") OR (rsn.feature_start<="+min+" and rsn.feature_stop>="+max+")) "+
                                ")";

            try(Connection conn=pool.getConnection()){
                log.debug("SQL smnc FROM QUERY\n"+smncQuery);
                PreparedStatement ps = conn.prepareStatement(smncQuery);
                ResultSet rs = ps.executeQuery();
                while(rs.next()){
                    int id=rs.getInt(1);
                    int start=rs.getInt(2);
                    int stop=rs.getInt(3);
                    String smplCount=rs.getString(4);
                    int total=rs.getInt(5);
                    int strand=rs.getInt(6);
                    String ref=rs.getString(7);
                    String chrom=rs.getString(8);
                    SmallNonCodingRNA tmpSmnc=new SmallNonCodingRNA(id,start,stop,chrom,ref,strand,total);
                    smncRNA.add(tmpSmnc);
                    smncID.put(id,tmpSmnc);
                }
                ps.close();
                log.debug("SQL smncSeq FROM QUERY\n"+smncSeqQuery);
                ps = conn.prepareStatement(smncSeqQuery);
                rs = ps.executeQuery();
                while(rs.next()){
                    int id=rs.getInt(1);
                    int smID=rs.getInt(2);
                    String seq=rs.getString(3);
                    int readCount=rs.getInt(4);
                    int unique=rs.getInt(5);
                    int offset=rs.getInt(6);
                    int bnlx=rs.getInt(7);
                    int shrh=rs.getInt(8);
                    HashMap<String,Integer> match=new HashMap<String,Integer>();
                    match.put("BNLX", bnlx);
                    match.put("SHRH", shrh);
                    RNASequence tmpSeq=new RNASequence(id,seq,readCount,unique,offset,match);
                    if(smncID.containsKey(smID)){
                        SmallNonCodingRNA tmp=(SmallNonCodingRNA)smncID.get(smID);
                        tmp.addSequence(tmpSeq);
                    }
                }
                ps.close();
                log.debug("SQL smncAnnot FROM QUERY\n"+smncAnnotQuery);
                ps = conn.prepareStatement(smncAnnotQuery);
                rs = ps.executeQuery();
                while(rs.next()){
                    int id=rs.getInt(1);
                    int smID=rs.getInt(2);
                    String annot=rs.getString(3);
                    String src=rs.getString(4);
                    Annotation tmpAnnot=new Annotation(id,src,annot,"smnc");
                    if(smncID.containsKey(smID)){
                        //log.debug("adding:"+smID);
                        SmallNonCodingRNA tmp=(SmallNonCodingRNA)smncID.get(smID);
                        tmp.addAnnotation(tmpAnnot);
                    }else{
                        log.debug("ID not found:"+smID);
                    }
                }
                ps.close();
                ps = conn.prepareStatement(smncVarQuery);
                rs = ps.executeQuery();
                while(rs.next()){
                    int id=rs.getInt(1);
                    int smID=rs.getInt(2);
                    int start=rs.getInt(3);
                    int stop=rs.getInt(4);
                    String refSeq=rs.getString(5);
                    String strainSeq=rs.getString(6);
                    String type=rs.getString(7);
                    String strain=rs.getString(8);
                    SequenceVariant tmpVar=new SequenceVariant(id,start,stop,refSeq,strainSeq,type,strain);
                    if(smncID.containsKey(smID)){
                        SmallNonCodingRNA tmp=(SmallNonCodingRNA)smncID.get(smID);
                        tmp.addVariant(tmpVar);
                    }
                }
                ps.close();
                /*if(cacheHM.containsKey(tmpRegion)){
                    HashMap regionHM=(HashMap)cacheHM.get(tmpRegion);
                    regionHM.put("smallNonCodingParams",curParams); 
                    regionHM.put("smallNonCoding",smncRNA);
                }else{
                    HashMap regionHM=new HashMap();
                    regionHM.put("smallNonCodingParams",curParams); 
                    regionHM.put("smallNonCoding",smncRNA);       
                    cacheHM.put(tmpRegion,regionHM);
                    this.cacheList.add(tmpRegion);
                }*/
                conn.close();
            
            }catch(SQLException e){
                log.error("Error retreiving SMNCs.",e);
                //session.setAttribute("getTransControllingEQTL","Error retreiving eQTLs.  Please try again later.  The administrator has been notified of the problem.");
                e.printStackTrace(System.err);
                Email myAdminEmail = new Email();
                    myAdminEmail.setSubject("Exception thrown in GeneDataTools.getSmallNonCodingRNA");
                    myAdminEmail.setContent("There was an error while running getSmallNonCodingRNA.\n",e);
                    try {
                        myAdminEmail.sendEmailToAdministrator((String) session.getAttribute("adminEmail"));
                    } catch (Exception mailException) {
                        log.error("error sending message", mailException);
                    }
            }

        return smncRNA;
    }
    
    public ArrayList<String> getEQTLRegions(){
        ArrayList<String> ret=new ArrayList<String>();
        Set tmp=this.eQTLRegions.keySet();
        Iterator itr=tmp.iterator();
        while(itr.hasNext()){
            String key=itr.next().toString();
            ret.add(key);
        }
        return ret;
    }
    
    public ArrayList<BQTL> getBQTLs(int min,int max,String chr,String organism,String genomeVer){
        if(chr.startsWith("chr")){
            chr=chr.substring(3);
        }
        String tmpRegion=chr+":"+min+"-"+max;
        String curParams="min="+min+",max="+max+",chr="+chr+",org="+organism;
        ArrayList<BQTL> bqtl=new ArrayList<BQTL>();
        session.removeAttribute("getBQTLsERROR");
        boolean run=true;

            String query="select pq.*,c.name from public_qtls pq, chromosomes c "+
                            "where pq.genome_id='"+genomeVer+"' "+
                            "and ((pq.qtl_start>="+min+" and pq.qtl_start<="+max+") or (pq.qtl_end>="+min+" and pq.qtl_end<="+max+") or (pq.qtl_start<="+min+" and pq.qtl_end>="+max+")) "+
                            "and c.name='"+chr.toUpperCase()+"' "+ 
                            "and c.chromosome_id=pq.chromosome";
            try{ 
            try(Connection conn=pool.getConnection()){
                log.debug("SQL eQTL FROM QUERY\n"+query);
                PreparedStatement ps = conn.prepareStatement(query);
                ResultSet rs = ps.executeQuery();
                while(rs.next()){
                    String id=Integer.toString(rs.getInt(1));
                    String mgiID=rs.getString(2);
                    String rgdID=rs.getString(3);
                    String symbol=rs.getString(5);
                    String name=rs.getString(6);
                    double lod=rs.getDouble(8);
                    double pvalue=rs.getDouble(9);
                    String trait=rs.getString(10);
                    String subTrait=rs.getString(11);
                    String traitMethod=rs.getString(12);
                    String phenotype=rs.getString(13);
                    String diseases=rs.getString(14);
                    String rgdRef=rs.getString(15);
                    String pubmedRef=rs.getString(16);
                    String relQTLs=rs.getString(18);
                    String candidGene=rs.getString(17);
                    long start=rs.getLong(19);
                    long stop=rs.getLong(20);
                    String mapMethod=rs.getString(21);
                    String chromosome=rs.getString(23);
                    BQTL tmpB=new BQTL(id,mgiID,rgdID,symbol,name,trait,subTrait,traitMethod,phenotype,diseases,rgdRef,pubmedRef,mapMethod,relQTLs,candidGene,lod,pvalue,start,stop,chromosome);
                    bqtl.add(tmpB);
                }
                ps.close();
                conn.close();
                /*if(cacheHM.containsKey(tmpRegion)){
                    HashMap regionHM=(HashMap)cacheHM.get(tmpRegion);
                    regionHM.put("bqtlParams",curParams);        
                    regionHM.put("bqtl",bqtl);
                }else{
                    HashMap regionHM=new HashMap();
                    regionHM.put("bqtlParams",curParams);        
                    regionHM.put("controlledRegion",bqtl);
                    cacheHM.put(tmpRegion,regionHM);
                    this.cacheList.add(tmpRegion);
                }*/
            }catch(SQLException e){
                log.error("Error retreiving bQTLs.",e);
                e.printStackTrace(System.err);
                session.setAttribute("getBQTLsERROR","Error retreiving region bQTLs.  Please try again later.  The administrator has been notified of the problem.");
                 Email myAdminEmail = new Email();
                 myAdminEmail.setSubject("Exception thrown in GeneDataTools.getBQTLs");
                 myAdminEmail.setContent("There was an error while running getBQTLs.",e);
                try {
                    myAdminEmail.sendEmailToAdministrator((String) session.getAttribute("adminEmail"));
                } catch (Exception mailException) {
                    log.error("error sending message", mailException);
                }
            }
            }catch(Exception er){
                er.printStackTrace(System.err);
                session.setAttribute("getBQTLsERROR","Error retreiving region bQTLs.  Please try again later.  The administrator has been notified of the problem.");
                 Email myAdminEmail = new Email();
                 myAdminEmail.setSubject("Exception thrown in GeneDataTools.getBQTLs");
                 myAdminEmail.setContent("There was an error while running getBQTLs.",er);
                try {
                    myAdminEmail.sendEmailToAdministrator((String) session.getAttribute("adminEmail"));
                } catch (Exception mailException) {
                    log.error("error sending message", mailException);
                }
            }
        //}
        
        return bqtl;
    }
    public BQTL getBQTL(String id,String genomeVer){
        
        BQTL bqtl=null;
        session.removeAttribute("getBQTLsERROR");
        boolean run=true;
        
            String query="select pq.*,c.name from public_qtls pq, chromosomes c "+
                            "where pq.genome_id='"+genomeVer+"' and pq.rgd_id="+id+
                            "and pq.chromosome=c.chromosome_id";
            Connection conn=null;
            try{ 
            try{
                log.debug("SQL bQTL FROM QUERY\n"+query);
                conn=pool.getConnection();
                PreparedStatement ps = conn.prepareStatement(query);
                ResultSet rs = ps.executeQuery();
                if(rs.next()){
                    String mgiID=rs.getString(2);
                    String rgdID=rs.getString(3);
                    String symbol=rs.getString(5);
                    String name=rs.getString(6);
                    double lod=rs.getDouble(8);
                    double pvalue=rs.getDouble(9);
                    String trait=rs.getString(10);
                    String subTrait=rs.getString(11);
                    String traitMethod=rs.getString(12);
                    String phenotype=rs.getString(13);
                    String diseases=rs.getString(14);
                    String rgdRef=rs.getString(15);
                    String pubmedRef=rs.getString(16);
                    String relQTLs=rs.getString(18);
                    String candidGene=rs.getString(17);
                    long start=rs.getLong(19);
                    long stop=rs.getLong(20);
                    String mapMethod=rs.getString(21);
                    String chromosome=rs.getString(23);
                    bqtl=new BQTL(id,mgiID,rgdID,symbol,name,trait,subTrait,traitMethod,phenotype,diseases,rgdRef,pubmedRef,mapMethod,relQTLs,candidGene,lod,pvalue,start,stop,chromosome);
                }
                ps.close();
                conn.close();
            }catch(SQLException e){
                log.error("Error retreiving bQTLs.",e);
                e.printStackTrace(System.err);
                session.setAttribute("getBQTLsERROR","Error retreiving region bQTLs.  Please try again later.  The administrator has been notified of the problem.");
                 Email myAdminEmail = new Email();
                 myAdminEmail.setSubject("Exception thrown in GeneDataTools.getBQTLs");
                 myAdminEmail.setContent("There was an error while running getBQTLs.",e);
                try {
                    myAdminEmail.sendEmailToAdministrator((String) session.getAttribute("adminEmail"));
                } catch (Exception mailException) {
                    log.error("error sending message", mailException);
                }
            }finally{
                try {
                    if(conn!=null)
                        conn.close();
                } catch (SQLException ex) {
                }
            }
            }catch(Exception er){
                er.printStackTrace(System.err);
                session.setAttribute("getBQTLsERROR","Error retreiving region bQTLs.  Please try again later.  The administrator has been notified of the problem.");
                 Email myAdminEmail = new Email();
                 myAdminEmail.setSubject("Exception thrown in GeneDataTools.getBQTLs");
                 myAdminEmail.setContent("There was an error while running getBQTLs.",er);
                try {
                    myAdminEmail.sendEmailToAdministrator((String) session.getAttribute("adminEmail"));
                } catch (Exception mailException) {
                    log.error("error sending message", mailException);
                }
            }
        
        
        return bqtl;
    }
    
    public String getBQTLRegionFromSymbol(String qtlSymbol,String organism,String genomeVer){
        return this.getBQTLRegionFromSymbol(qtlSymbol,organism,genomeVer, pool);
    }
    
    public String getBQTLRegionFromSymbol(String qtlSymbol,String organism,String genomeVer,DataSource pool){
        if(qtlSymbol.startsWith("bQTL:")){
            qtlSymbol=qtlSymbol.substring(5);
        }
        String region="";
        String query="select pq.*,c.name from public_qtls pq, chromosomes c "+
                        "where pq.genome_id='"+genomeVer+"' "+
                        "and pq.chromosome=c.chromosome_id "+
                        "and pq.QTL_SYMBOL='"+qtlSymbol+"'";
        
        try{ 
        try(Connection conn=pool.getConnection()){
            //log.debug("SQL eQTL FROM QUERY\n"+query);
            PreparedStatement ps = conn.prepareStatement(query);
            ResultSet rs = ps.executeQuery();
            if(rs.next()){
                long start=rs.getLong(19);
                long stop=rs.getLong(20);
                String chromosome=rs.getString(23);
                region="chr"+chromosome+":"+start+"-"+stop;
            }
            ps.close();
            
        }catch(SQLException e){
            log.error("Error retreiving bQTL region from symbol.",e);
            e.printStackTrace(System.err);
            session.setAttribute("getBQTLRegionFromSymbol","Error retreiving bQTL region from symbol.  Please try again later.  The administrator has been notified of the problem.");
             Email myAdminEmail = new Email();
             myAdminEmail.setSubject("Exception thrown in GeneDataTools.getBQTLs");
             myAdminEmail.setContent("There was an error while running getBQTLs.",e);
            try {
                myAdminEmail.sendEmailToAdministrator((String) session.getAttribute("adminEmail"));
            } catch (Exception mailException) {
                log.error("error sending message", mailException);
            }
        }
        }catch(Exception er){
            er.printStackTrace(System.err);
            session.setAttribute("getBQTLsERROR","Error retreiving bQTL region from symbol.  Please try again later.  The administrator has been notified of the problem.");
             Email myAdminEmail = new Email();
             myAdminEmail.setSubject("Exception thrown in GeneDataTools.getBQTLs");
             myAdminEmail.setContent("There was an error while running getBQTLs.",er);
            try {
                myAdminEmail.sendEmailToAdministrator((String) session.getAttribute("adminEmail"));
            } catch (Exception mailException) {
                log.error("error sending message", mailException);
            }
        }
        
        return region;
    }
        
    public void addQTLS(ArrayList<Gene> genes, ArrayList<EQTL> eqtls){
        HashMap eqtlInd=new HashMap();
        for(int i=0;i<eqtls.size();i++){
            EQTL tmp=eqtls.get(i);
            eqtlInd.put(tmp.getProbeSetID(), i);
        }
        for(int i=0;i<genes.size();i++){
            genes.get(i).addEQTLs(eqtls,eqtlInd,log);
        }
    }
    
    public void addFromQTLS(ArrayList<Gene> genes, HashMap transcriptClustersCore,HashMap transcriptClustersExt,HashMap transcriptClustersFull){
        for(int i=0;i<genes.size();i++){
            if(genes.get(i).getGeneID().startsWith("ENS")){
                genes.get(i).addTranscriptCluster(transcriptClustersCore,transcriptClustersExt,transcriptClustersFull,log);
            }
        }
    }

    public String getGenURL() {
        return returnGenURL;
    }

    public String getUCSCURL() {
        return returnUCSCURL;
    }

    public String getOutputDir() {
        return returnOutputDir;
    }

    public String getGeneSymbol() {
        return returnGeneSymbol;
    }

}

class RegionDirFilter implements FileFilter{
    String toCheck="";
    
    RegionDirFilter(String toCheck){
        this.toCheck=toCheck;
    }
    
    public boolean accept(File file) {
        boolean ret=true;
        if(!file.isDirectory()){
            ret=false;
        }
        if(!file.getName().startsWith(toCheck)){
            ret=false;
        }
        return ret;
    }
    
}
