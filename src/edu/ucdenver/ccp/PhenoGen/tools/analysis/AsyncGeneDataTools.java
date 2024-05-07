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

public class AsyncGeneDataTools extends Thread {
    private String[] rErrorMsg = null;
    private HttpSession session = null;
    private Logger log = null;
    private String userFilesRoot = "";
    private String urlPrefix = "";
    private String ucscDir = "";
    private DataSource pool = null;
    //private DataSource poolRO=null;
    private String dbPropertiesFile = null;
    private String mongoDBPropertiesFile = null;
    private String outputDir = "";
    private String chrom = "";
    private String genomeVer = "";
    private String perlDir = "";
    private String perlEnvVar = "";

    private String dataVer = "";
    private String organism = "";
    private String ensemblID1 = "";

    private int minCoord = 0;
    private int maxCoord = 0;
    private int arrayTypeID = 0;
    private int rnaDatasetID = 0;
    private int usageID = 0;
    private boolean done = false;
    private boolean isEnsemblGene = true;
    //private String updateSQL="update TRANS_DETAIL_USAGE set TIME_ASYNC_GENE_DATA_TOOLS=? , RESULT=? where TRANS_DETAIL_ID=?";
    private String[] tissues = new String[2];
    private GeneDataTools gdt = null;
    private ExecHandler myExec_session = null;


    public AsyncGeneDataTools(HttpSession inSession, DataSource pool, String outputDir, String chr, int min, int max, int arrayTypeID, int rnaDS_ID, int usageID, String genomeVer, boolean isEnsemblGene, String dataVer, String ensemblID1, GeneDataTools gdt) {
        this.session = inSession;
        this.outputDir = outputDir;
        log = Logger.getRootLogger();
        log.debug("in AsynGeneDataTools()");
        this.session = inSession;
        this.pool = pool;
        this.chrom = chr;
        this.minCoord = min;
        this.maxCoord = max;
        this.arrayTypeID = arrayTypeID;
        this.rnaDatasetID = rnaDS_ID;
        this.usageID = usageID;
        this.genomeVer = genomeVer;
        this.isEnsemblGene = isEnsemblGene;
        this.dataVer = dataVer;
        this.ensemblID1 = ensemblID1;
        this.gdt = gdt;

        log.debug("start");

        //this.selectedDataset = (Dataset) session.getAttribute("selectedDataset");
        //this.selectedDatasetVersion = (Dataset.DatasetVersion) session.getAttribute("selectedDatasetVersion");
        //this.publicDatasets = (Dataset[]) session.getAttribute("publicDatasets");
        this.pool = (DataSource) session.getAttribute("dbPool");
        //this.poolRO= (DataSource) session.getAttribute("dbPoolRO");
        dbPropertiesFile = (String) session.getAttribute("dbPropertiesFile");
        mongoDBPropertiesFile = (String) session.getAttribute("mongoDbPropertiesFile");
        //log.debug("db");
        this.perlDir = (String) session.getAttribute("perlDir") + "scripts/";
        this.perlEnvVar = (String) session.getAttribute("perlEnvVar");
        String contextRoot = (String) session.getAttribute("contextRoot");
        //log.debug("context" + contextRoot);
        String appRoot = (String) session.getAttribute("applicationRoot");
        //log.debug("app" + appRoot);

        //log.debug("userFilesRoot");
        this.urlPrefix = (String) session.getAttribute("mainURL");
        if (urlPrefix.endsWith(".jsp")) {
            urlPrefix = urlPrefix.substring(0, urlPrefix.lastIndexOf("/") + 1);
        }
        //log.debug("mainURL");

        this.ucscDir = (String) session.getAttribute("ucscDir");
        //log.debug("ucsc");

        tissues[0] = "Brain";
        tissues[1] = "Liver";

        if (genomeVer.toLowerCase().startsWith("rn")) {
            organism = "Rn";
        } else if (genomeVer.toLowerCase().startsWith("mm")) {
            organism = "Mm";
        }

    }


    public void run() throws RuntimeException {
        log.debug("AsyncGeneDataTools - running");
        done = false;
        try {
            String tmpOutDir = "";
            if (gdt == null) {
                tmpOutDir = outputDir;
            } else {
                tmpOutDir = gdt.getFullPath() + "tmpData/browserCache/" + genomeVer + "/regionData/" + chrom + "/" + minCoord + "_" + maxCoord + "/";
            }
            outputRNASeqExprFiles(tmpOutDir, chrom, minCoord, maxCoord, genomeVer, dataVer);
            log.debug("AsyncGeneDataTools - after ExprFiles:" + chrom + ":" + minCoord + ":" + maxCoord);
            if (isEnsemblGene) {
                if (genomeVer.equals("rn5") || genomeVer.equals("rn6")) {
                    outputProbesetIDFiles(tmpOutDir, chrom, minCoord, maxCoord, arrayTypeID, genomeVer);
                }
                done = true;
            }
            log.debug("AsyncGeneDataTools - after probeset");
            /*if (ensemblID1 != null && !ensemblID1.equals("")) {
                callWriteXML(ensemblID1, organism, genomeVer, chrom, minCoord, maxCoord, arrayTypeID, rnaDatasetID);
            }*/
            log.debug("AsyncGeneDataTools DONE");
        } catch (Exception ex) {
            done = true;
            log.error("Error processing initial files in AsyncGeneDataTools", ex);
            Date end = new Date();

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
        done = true;
    }

    private void outputProbesetIDFiles(String outputDir, String chr, int min, int max, int arrayTypeID, String genomeVer) {
        if (chr.toLowerCase().startsWith("chr")) {
            chr = chr.substring(3);
        }

        String organism = "Rn";
        if (genomeVer.toLowerCase().startsWith("mm")) {
            organism = "Mm";
        }
        String chrQ = "select chromosome_id from chromosomes where name= '" + chr.toUpperCase() + "' and organism='" + organism + "'";
        int chrID = -99;

        // Original version
        /*
        String probeTransQuery="select distinct s.Probeset_ID,c2.name,s.PSSTART,s.PSSTOP,s.PSLEVEL,s.Strand "+
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


        //" and s.PROBESET_ID in (select l.probe_id from location_specific_eqtl l,snps sn where sn.genome_id='"+genomeVer+"' and l.snp_id=sn.snp_id)";


        String pListFile = outputDir + "tmp_psList.txt";
        try {
            BufferedWriter psout = new BufferedWriter(new FileWriter(new File(pListFile)));
            try (Connection conn = pool.getConnection()) {
                PreparedStatement psC = conn.prepareStatement(chrQ);
                ResultSet rsC = psC.executeQuery();
                if (rsC.next()) {
                    chrID = rsC.getInt(1);
                }
                rsC.close();
                psC.close();
                String probeQuery = "select s.Probeset_ID " +
                        "from Affy_Exon_ProbeSet s " +
                        "where s.chromosome_id = " + chrID + " " +
                        "and s.genome_id='" + genomeVer + "' " +
                        "and ( " +
                        "(s.psstart >= " + min + " and s.psstart <=" + max + ") OR " +
                        "(s.psstop >= " + min + " and s.psstop <= " + max + ") OR " +
                        "(s.psstart <= " + min + " and s.psstop >=" + min + ")" +
                        ") " +
                        "and s.psannotation <> 'transcript' " +
                        "and s.updatedlocation = 'Y' " +
                        "and s.Array_TYPE_ID = " + arrayTypeID;
                //log.debug("PSLEVEL SQL:"+probeQuery);
                PreparedStatement ps = conn.prepareStatement(probeQuery);
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    int psid = rs.getInt(1);
                    psout.write(psid + "\n");
                }
                ps.close();
            } catch (SQLException ex) {
                log.error("Error getting exon probesets", ex);
            }
            psout.flush();
            psout.close();
        } catch (IOException e) {
            log.error("Error writing exon probesets", e);
        }
        done = true;
        ArrayList<GeneLoc> geneList = GeneLoc.readGeneListFile(outputDir, log);
        //log.debug("Read in gene list:"+geneList.size());
        String ptransListFiletmp = outputDir + "tmp_psList_transcript.txt";
        StringBuilder sb = new StringBuilder();

        try (Connection conn = pool.getConnection()) {
            String probeTransQuery = "select distinct s.Probeset_ID,'" + chr.toUpperCase() + "',s.PSSTART,s.PSSTOP,s.PSLEVEL,s.Strand " +
                    "from location_specific_eqtl l " +
                    "left outer join snps sn on sn.snp_id=l.SNP_ID " +
                    "left outer join Affy_Exon_ProbeSet s on s.probeset_id = l.probe_id " +
                    "where sn.genome_id='" + genomeVer + "' " +
                    "and sn.type='array' " +
                    "and s.chromosome_id = " + chrID + " " +
                    "and s.genome_id='" + genomeVer + "' " +
                    "and ( " +
                    "(s.psstart >= " + min + " and s.psstart <=" + max + ") OR " +
                    "(s.psstop >= " + min + " and s.psstop <= " + max + ") OR " +
                    "(s.psstart <= " + min + " and s.psstop >=" + min + ") ) " +
                    "and s.psannotation = 'transcript' " +
                    "and s.updatedlocation = 'Y' " +
                    "and s.Array_TYPE_ID = " + arrayTypeID;
            //log.debug("Transcript Level SQL:"+probeTransQuery);
            PreparedStatement ps = conn.prepareStatement(probeTransQuery);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                int psid = rs.getInt(1);
                //log.debug("transcript read ps:"+psid);
                String ch = rs.getString(2);
                long start = rs.getLong(3);
                long stop = rs.getLong(4);
                String level = rs.getString(5);
                String strand = rs.getString(6);

                String ensemblId = "", ensGeneSym = "";
                double maxOverlapTC = 0.0, maxOverlapGene = 0.0, maxComb = 0.0;
                GeneLoc maxGene = null;
                for (int i = 0; i < geneList.size(); i++) {
                    GeneLoc tmpLoc = geneList.get(i);
                    //log.debug("strand:"+tmpLoc.getStrand()+":"+strand);
                    if (tmpLoc.getStrand().equals(strand)) {
                        long maxStart = tmpLoc.getStart();
                        long minStop = tmpLoc.getStop();
                        if (start > maxStart) {
                            maxStart = start;
                        }
                        if (stop < minStop) {
                            minStop = stop;
                        }
                        long genLen = tmpLoc.getStop() - tmpLoc.getStart();
                        long tcLen = stop - start;
                        double overlapLen = minStop - maxStart;
                        double curTCperc = 0.0, curGperc = 0.0, comb = 0.0;
                        if (overlapLen > 0) {
                            curTCperc = overlapLen / tcLen * 100;
                            curGperc = overlapLen / tcLen * 100;
                            comb = curTCperc + curGperc;
                            if (comb > maxComb) {
                                maxOverlapTC = curTCperc;
                                maxOverlapGene = curGperc;
                                maxComb = comb;
                                maxGene = tmpLoc;
                            }
                        }
                    }
                }
                if (maxGene != null) {
                    String tmpGS = maxGene.getGeneSymbol();
                    if (tmpGS.equals("")) {
                        tmpGS = maxGene.getID();
                    }
                    //log.debug("out:"+psid + "\t" + ch + "\t" + start + "\t" + stop + "\t" + level + "\t"+tmpGS+"\n");
                    sb.append(psid + "\t" + ch + "\t" + start + "\t" + stop + "\t" + level + "\t" + tmpGS + "\n");

                } else {
                    //log.debug("out"+psid + "\t" + ch + "\t" + start + "\t" + stop + "\t" + level + "\t\n");
                    sb.append(psid + "\t" + ch + "\t" + start + "\t" + stop + "\t" + level + "\t\n");

                }
            }
            ps.close();
            conn.close();
        } catch (SQLException ex) {
            log.error("Error getting transcript probesets", ex);
        }
        try {
            log.debug("To File:" + ptransListFiletmp + "\n\n" + sb.toString());
            FileHandler myFH = new FileHandler();
            myFH.writeFile(sb.toString(), ptransListFiletmp);
            log.debug("DONE");
        } catch (IOException e) {
            log.error("Error outputing transcript ps list.", e);
        }

    }


    public boolean outputRNASeqExprFiles(String outputDir, String chr, int min, int max, String genomeVer, String dataVer) {
        boolean success = true;
        log.debug("outputRNASeqExprFiles");
        // get list of tissues/datasets
        String query = "select RNA_DATASET_ID, TISSUE,BUILD_VERSION,EXP_DATA_ID from rna_dataset where genome_id=? and trx_recon=1 and visible=1 and exp_data_id is not null";
        if (dataVer.equals("")) {
            query = query + " order by BUILD_VERSION DESC";
        } else {
            String version = dataVer;
            if (dataVer.startsWith("hrdp")) {
                version = dataVer.substring(4);
            }
            query = query + " and build_Version='" + version + "'";
        }
        String querySmall = "select RNA_DATASET_ID, TISSUE,BUILD_VERSION,EXP_DATA_ID from rna_dataset where genome_id=? and trx_recon=0 and visible=0 and description like ? and exp_data_id is not null";
        HashMap<String, Tissues> tissuesTotal = new HashMap<String, Tissues>();
        HashMap<String, Tissues> tissuesSmall = new HashMap<String, Tissues>();
        try (Connection conn = pool.getConnection()) {
            PreparedStatement ps = conn.prepareStatement(query);
            ps.setString(1, genomeVer);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                String tissue = rs.getString(2);
                int build = Integer.parseInt(rs.getString(3));
                Tissues t = new Tissues(rs.getInt(1), tissue, build, rs.getInt(4));
                if (tissuesTotal.containsKey(tissue)) {
                    if (tissuesTotal.get(tissue).getBuildVer() < build) {
                        tissuesTotal.put(tissue, t);
                    }
                } else {
                    tissuesTotal.put(tissue, t);
                }
                //log.debug("*********"+tissue+":"+build+":"+rs.getInt(1)+":"+rs.getInt(4));
            }
            ps.close();
            //log.debug("SMALL TISSUE QUERY:\n"+querySmall);
            ps = conn.prepareStatement(querySmall);
            ps.setString(1, genomeVer);
            ps.setString(2, "%Smallnc");
            rs = ps.executeQuery();
            //log.debug("rs statement:\n"+rs.getStatement().toString());
            while (rs.next()) {
                String tissue = rs.getString(2);
                //log.debug("small tissue: "+tissue);
                int build = Integer.parseInt(rs.getString(3));
                Tissues t = new Tissues(rs.getInt(1), tissue, build, rs.getInt(4));
                if (tissuesSmall.containsKey(tissue)) {
                    if (tissuesSmall.get(tissue).getBuildVer() < build) {
                        tissuesSmall.put(tissue, t);
                    }
                } else {
                    tissuesSmall.put(tissue, t);
                }
                //log.debug("*********"+tissue+":"+build+":"+rs.getInt(1)+":"+rs.getInt(4));
            }
            ps.close();
            conn.close();
        } catch (SQLException e) {
            success = false;
            log.error("Error in outputRNASeqExprFiles", e);
        }

        if (success) {
            log.debug("call processTotal()");
            success = processTotal(tissuesTotal, chr, min, max, outputDir);
        }
        log.debug("****AFTER TOTAL");
        if (success) {
            success = processSmall(tissuesSmall, chr, min, max, outputDir);
        } else {
            log.error("SMALLRNA not run as total ended unsuccessfully.");
        }

        return success;
    }

    public boolean isDone() {
        return done;
    }

    private boolean processTotal(HashMap<String, Tissues> tissuesTotal, String chr, int min, int max, String outputDir) {
        boolean success = true;
        Iterator itr = tissuesTotal.keySet().iterator();
        while (itr.hasNext()) {
            HashMap<String, GeneID> genes = new HashMap<String, GeneID>();
            StringBuilder sb = new StringBuilder();
            StringBuilder sbGeneList = new StringBuilder();
            String perlGeneList = "";
            ArrayList<FeatureID> featList = new ArrayList<FeatureID>();
            HashMap<String, Integer> featHM = new HashMap<String, Integer>();
            Tissues curTissue = (Tissues) tissuesTotal.get(itr.next());
            //get transcripts
            String selectTrx = "select r.merge_gene_id,r.merge_isoform_id,r.herit_gene,r.herit_trx from rna_transcripts r, chromosomes c where " +
                    "c.organism=? and c.name=? and c.chromosome_id=r.chromosome_id " +
                    "and r.rna_dataset_id=? " +
                    "and ((trstart>=" + min + " and trstart<=" + max + ") OR (trstop>=" + min + " and trstop<=" + max + ") OR (trstart<=" + min + " and trstop>=" + max + "))";
            String selectR2 = "select r.merge_gene_id,r.merge_isoform_id,r.herit_gene,r.herit_trx from rna_transcripts r where r.rna_dataset_id=? and " +
                    " r.merge_gene_id in (";
            //log.debug(selectTrx);
            try (Connection conn = pool.getConnection()) {
                PreparedStatement ps = conn.prepareStatement(selectTrx);
                String org = "Rn";
                if (genomeVer.toLowerCase().startsWith("mm")) {
                    org = "Mm";
                }
                ps.setString(1, org);
                if (chr.startsWith("chr")) {
                    chr = chr.substring(3);
                }
                ps.setString(2, chr);
                ps.setInt(3, curTissue.getDatasetID());
                //log.debug(selectTrx+"\norg:"+org+"\nchr:"+chr+"\nds:"+curTissue.getDatasetID()+"\n");
                ResultSet rs = ps.executeQuery();
                int sbCount = 0;
                while (rs.next()) {
                    String gID = rs.getString(1);
                    //String trxID=rs.getString(2);
                    //log.debug("processTotal:"+gID+":");
                    double gHerit = rs.getDouble(3);
                    //double tHerit=rs.getDouble(4);
                    //TrxID tmpTrx=new TrxID(trxID,tHerit);
                    GeneID tmpGene = new GeneID(gID, gHerit);
                    //tmpGene.addTranscript(tmpTrx);
                    if (genes.containsKey(gID)) {
                        /*GeneID tmpGene2=genes.get(geneID);
                        tmpGene2.addTranscript(tmpTrx);*/
                    } else {
                        genes.put(gID, tmpGene);
                        if (sb.length() > 0) {
                            sb.append(",");
                            sbGeneList.append(",");
                        }
                        sb.append("'" + gID + "'");
                        sbGeneList.append(gID);
                        sbCount++;
                    }
                    if (!featHM.containsKey(gID)) {
                        featList.add(tmpGene);
                        featHM.put(gID, 1);
                    }

                }
                ps.close();
                //log.debug("between queries");
                perlGeneList = sbGeneList.toString();
                //log.debug("gl:"+perlGeneList);
                if (sbCount > 0) {
                    ps = conn.prepareStatement(selectR2 + sb.toString() + " )");
                    ps.setInt(1, curTissue.getDatasetID());
                    rs = ps.executeQuery();
                    //log.debug(rs.getStatement());
                    while (rs.next()) {
                        String geneID = rs.getString(1);
                        String trxID = rs.getString(2);
                        double gHerit = rs.getDouble(3);
                        double tHerit = rs.getDouble(4);
                        //log.debug("processTotal:R2:" + geneID + ":" + trxID);
                        GeneID tmpGene = genes.get(geneID);
                        if (trxID != null && !trxID.equals("")) {
                            TrxID tmpTrx = new TrxID(trxID, tHerit);
                        /*boolean found = false;
                        for (int i = 0; i < tmpGene.getTranscripts().size() && !found; i++) {
                            if (tmpGene.getTranscripts().get(i).getID().equals(trxID)) {
                                found = true;
                            }
                        }
                        if (!found) {*/
                            tmpGene.addTranscript(tmpTrx);
                            featList.add(tmpTrx);
                            //}
                        }
                    }
                    ps.close();
                }
                conn.close();
                //log.debug("after R2");
                //log.debug("PERLGENELIST:\n"+perlGeneList);
                String heritFile = outputDir + curTissue.getTissue() + "_herit.txt";
                //output heritablity file for each dataset
                try {
                    BufferedWriter psout = new BufferedWriter(new FileWriter(new File(heritFile)));
                    for (int i = 0; i < featList.size(); i++) {
                        psout.write(featList.get(i).getID() + "\t" + featList.get(i).getHeritability() + "\n");
                    }
                    psout.close();
                } catch (IOException e) {
                    log.error("\n\nError outputing herit file:" + heritFile, e);
                }
                File mongoPropertiesFile = new File(mongoDBPropertiesFile);
                Properties myMongoProperties = new Properties();
                try {
                    myMongoProperties.load(new FileInputStream(mongoPropertiesFile));
                } catch (IOException e) {
                    log.error("Error opening property file", e);
                }
                String mongoHost = myMongoProperties.getProperty("HOST");
                String mongoUser = myMongoProperties.getProperty("USER");
                String mongoPassword = myMongoProperties.getProperty("PASSWORD");
                //for each tissue call perl
                String[] perlArgs = new String[9];
                perlArgs[0] = "perl";
                perlArgs[1] = perlDir + "readExprDataFromMongo.pl";
                perlArgs[2] = outputDir + curTissue.getTissue() + "expr.json";
                perlArgs[3] = Integer.toString(curTissue.getExprDataID());
                perlArgs[4] = perlGeneList;
                perlArgs[5] = heritFile;
                perlArgs[6] = mongoHost;
                perlArgs[7] = mongoUser;
                perlArgs[8] = mongoPassword;

                //log.debug("after perl args");
                log.debug("setup params");
                //set environment variables so you can access oracle pulled from perlEnvVar session variable which is a comma separated list
                String[] envVar = perlEnvVar.split(",");

            /*for (int i = 0; i < envVar.length; i++) {
                if(envVar[i].contains("/ensembl")){
                    envVar[i]=envVar[i].replaceFirst("/ensembl", "/"+ensemblPath);
                }
                log.debug(i + " EnvVar::" + envVar[i]);
            }*/

                log.debug("setup envVar");
                //construct ExecHandler which is used instead of Perl Handler because environment variables were needed.
                myExec_session = new ExecHandler(perlDir, perlArgs, envVar, outputDir + curTissue.getTissue() + "tExpr");
                boolean exception = false;
                try {

                    myExec_session.runExec();

                } catch (ExecException e) {
                    exception = true;
                    success = false;
                    e.printStackTrace(System.err);
                    log.error("In Exception of run callWriteXML:writeXML_RNA.pl Exec_session", e);
                }
            } catch (SQLException e) {
                log.error("\n\nError in outputRNASeqExprFiles", e);
            }
            //create gene list for perl call
            /*StringBuilder sbGeneList=new StringBuilder();
            Iterator gItr=genes.keySet().iterator();
            int c=0;
            while(gItr.hasNext()){
                String next=(String)gItr.next();
                log.debug("while:"+next);
                if(c>0){
                    sbGeneList.append(",");
                }
                sbGeneList.append(next);
                c++;
            }*/


        }
        return success;
    }

    private boolean processSmall(HashMap<String, Tissues> tissuesSmall, String chr, int min, int max, String outputDir) {
        boolean success = true;
        log.debug("processSmall");
        Iterator itr = tissuesSmall.keySet().iterator();
        HashMap<String, GeneID> genes = new HashMap<String, GeneID>();
        StringBuilder sb = new StringBuilder();
        while (itr.hasNext()) {

            ArrayList<FeatureID> featList = new ArrayList<FeatureID>();
            HashMap<String, Integer> featHM = new HashMap<String, Integer>();
            Tissues curTissue = (Tissues) tissuesSmall.get(itr.next());
            //log.debug(curTissue.getTissue()+":"+curTissue.getDatasetID()+":"+curTissue.getExprDataID());
            //get transcripts
            String selectTrx = "select r.merge_gene_id,r.merge_isoform_id from rna_transcripts r, chromosomes c where " +
                    "c.organism=? and c.name=? and c.chromosome_id=r.chromosome_id " +
                    "and r.rna_dataset_id=? " +
                    "and ((trstart>=" + min + " and trstart<=" + max + ") OR (trstop>=" + min + " and trstop<=" + max + ") OR (trstart<=" + min + " and trstop>=" + max + "))";
            /*String selectR2="select r.merge_gene_id,r.merge_isoform_id,r.herit_gene,r.herit_trx from rna_transcripts r where r.rna_dataset_id=? and "+
                    " r.merge_gene_id in (";*/
            log.debug("SMALL:" + selectTrx);
            try (Connection conn = pool.getConnection()) {
                PreparedStatement ps = conn.prepareStatement(selectTrx);
                String org = "Rn";
                if (genomeVer.toLowerCase().startsWith("mm")) {
                    org = "Mm";
                }
                ps.setString(1, org);
                if (chr.startsWith("chr")) {
                    chr = chr.substring(3);
                }
                ps.setString(2, chr);
                ps.setInt(3, curTissue.getDatasetID());
                //log.debug(selectTrx+"\norg:"+org+"\nchr:"+chr+"\nds:"+curTissue.getDatasetID()+"\n");

                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    String geneID = rs.getString(1);
                    String trxID = rs.getString(2);
                    //double gHerit=rs.getDouble(3);
                    //double tHerit=rs.getDouble(4);
                    //TrxID tmpTrx=new TrxID(trxID,null);
                    GeneID tmpGene = new GeneID(geneID);
                    //tmpGene.addTranscript(tmpTrx);
                    if (genes.containsKey(geneID)) {
                        /*GeneID tmpGene=genes.get(geneID);
                        tmpGene.addTranscript(tmpTrx);*/
                    } else {
                        genes.put(geneID, tmpGene);
                        if (sb.length() > 0) {
                            sb.append(",");
                        }
                        sb.append("'" + geneID + "'");
                    }
                    if (!featHM.containsKey(geneID)) {
                        featList.add(tmpGene);
                        featHM.put(geneID, 1);
                    }
                    //featList.add(tmpTrx);
                    //log.debug("\n&&&&&&&&&&&&&&&&&&&&&&&& trx:"+trxID+"::"+geneID);
                }
                ps.close();
                
                /*ps=conn.prepareStatement(selectR2+sb.toString()+" )");
                ps.setInt(1,curTissue.getDatasetID());
                rs=ps.executeQuery();
                while (rs.next()){
                    String geneID=rs.getString(1);
                    String trxID=rs.getString(2);
                    double gHerit=rs.getDouble(3);
                    double tHerit=rs.getDouble(4);
                    TrxID tmpTrx=new TrxID(trxID,tHerit);
                    
                    GeneID tmpGene=genes.get(geneID);
                    boolean found=false;
                    for(int i=0;i<tmpGene.getTranscripts().size()&&!found;i++){
                        if(tmpGene.getTranscripts().get(i).getID().equals(trxID)){
                            found=true;
                        }
                    }
                    if(!found){
                        tmpGene.addTranscript(tmpTrx);
                        featList.add(tmpTrx);
                    }
                    
                }
                ps.close();*/
                conn.close();
            } catch (SQLException e) {
                log.error("\n\nError in outputRNASeqExprFiles", e);
            }
            //create gene list for perl call
            String perlGeneList = "";
            Iterator gItr = genes.keySet().iterator();
            int c = 0;
            while (gItr.hasNext()) {
                String next = (String) gItr.next();
                if (c > 0) {
                    perlGeneList = perlGeneList + ",";
                }
                perlGeneList = perlGeneList + next;
                c++;
            }
            log.debug("PERLGENELIST:\n" + perlGeneList);
            String heritFile = outputDir + curTissue.getTissue() + "_sm_herit.txt";
            //output heritablity file for each dataset
            try {
                BufferedWriter psout = new BufferedWriter(new FileWriter(new File(heritFile)));
                for (int i = 0; i < featList.size(); i++) {
                    psout.write(featList.get(i).getID() + "\t\n");//+featList.get(i).getHeritability()+"\n");
                }
                psout.close();
            } catch (IOException e) {
                log.error("\n\nError outputing herit file:" + heritFile, e);
            }


            File mongoPropertiesFile = new File(mongoDBPropertiesFile);
            Properties myMongoProperties = new Properties();
            try {
                myMongoProperties.load(new FileInputStream(mongoPropertiesFile));
            } catch (IOException e) {
                log.error("Error opening property file", e);
            }
            String mongoHost = myMongoProperties.getProperty("HOST");
            String mongoUser = myMongoProperties.getProperty("USER");
            String mongoPassword = myMongoProperties.getProperty("PASSWORD");
            //for each tissue call perl
            String[] perlArgs = new String[9];
            perlArgs[0] = "perl";
            perlArgs[1] = perlDir + "readExprDataFromMongo.pl";
            perlArgs[2] = outputDir + curTissue.getTissue() + "_sm_expr.json";
            perlArgs[3] = Integer.toString(curTissue.getExprDataID());
            perlArgs[4] = perlGeneList;
            perlArgs[5] = heritFile;
            perlArgs[6] = mongoHost;
            perlArgs[7] = mongoUser;
            perlArgs[8] = mongoPassword;

            log.debug("after perl args");
            log.debug("setup params");
            //set environment variables so you can access oracle pulled from perlEnvVar session variable which is a comma separated list
            String[] envVar = perlEnvVar.split(",");

            /*for (int i = 0; i < envVar.length; i++) {
                if(envVar[i].contains("/ensembl")){
                    envVar[i]=envVar[i].replaceFirst("/ensembl", "/"+ensemblPath);
                }
                log.debug(i + " EnvVar::" + envVar[i]);
            }*/

            log.debug("setup envVar");
            //construct ExecHandler which is used instead of Perl Handler because environment variables were needed.
            myExec_session = new ExecHandler(perlDir, perlArgs, envVar, outputDir + curTissue.getTissue() + "smExpr");
            boolean exception = false;
            try {

                myExec_session.runExec();

            } catch (ExecException e) {
                exception = true;
                success = false;
                e.printStackTrace(System.err);
                log.error("In Exception of run callWriteXML:writeXML_RNA.pl Exec_session", e);
            }
        }
        return success;
    }

   /* private boolean callWriteXML(String id, String organism, String genomeVer, String chr, int min, int max, int arrayTypeID, int rnaDS_ID) {
        boolean completedSuccessfully = false;
        log.debug("callWriteXML()" + id + "," + organism + "," + genomeVer + "," + arrayTypeID + "," + rnaDS_ID);
        try {
            //Connection tmpConn=pool.getConnection();
            int publicUserID = new User().getUser_id("public", pool);
            //tmpConn.close();
            String tmpoutputDir = gdt.getFullPath() + "tmpData/browserCache/" + genomeVer + "/geneData/" + id + "/";
            HashMap<String, String> source = this.gdt.getGenomeVersionSource(genomeVer);
            String ensemblPath = source.get("ensembl");
            File test = new File(tmpoutputDir + "Region.xml");
            long testLM = test.lastModified();
            testLM = (new Date().getTime()) - testLM;
            long fifteenMin = 15 * 60 * 1000;
            if (!test.exists() || (test.length() == 0 && testLM > fifteenMin)) {
                log.debug("createXML outputDir:" + tmpoutputDir);
                File outDir = new File(tmpoutputDir);
                if (outDir.exists()) {
                    outDir.mkdirs();
                }
                Properties myProperties = new Properties();
                File myPropertiesFile = new File(dbPropertiesFile);
                myProperties.load(new FileInputStream(myPropertiesFile));
                String port = myProperties.getProperty("PORT");
                String dsn = "dbi:mysql:database=" + myProperties.getProperty("DATABASE") + ";host=" + myProperties.getProperty("HOST") + ";port=" + port;
                String dbUser = myProperties.getProperty("USER");
                String dbPassword = myProperties.getProperty("PASSWORD");

                File ensPropertiesFile = new File(gdt.getEnsemblDBPropertiesFile());
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
                perlArgs[6] = ucscDir + gdt.getUCSCGeneDir();
                perlArgs[7] = Integer.toString(arrayTypeID);
                perlArgs[8] = Integer.toString(rnaDS_ID);
                perlArgs[9] = Integer.toString(publicUserID);
                perlArgs[10] = genomeVer;
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
                String[] envVar = perlEnvVar.split(",");

                for (int i = 0; i < envVar.length; i++) {
                    if (envVar[i].contains("/ensembl")) {
                        envVar[i] = envVar[i].replaceFirst("/ensembl", "/" + ensemblPath);
                    }
                    log.debug(i + " EnvVar::" + envVar[i]);
                }
                log.debug("setup envVar");
                //construct ExecHandler which is used instead of Perl Handler because environment variables were needed.
                myExec_session = new ExecHandler(perlDir, perlArgs, envVar, gdt.getFullPath() + "tmpData/browserCache/" + genomeVer + "/geneData/" + id + "/");
                boolean exception = false;
                try {
                    myExec_session.runExec();
                } catch (ExecException e) {
                    exception = true;
                    completedSuccessfully = false;
                    e.printStackTrace(System.err);
                    log.error("In Exception of run callWriteXML:writeXML_RNA.pl Exec_session", e);

                    String errorList = myExec_session.getErrors();
                    boolean missingDB = false;
                    String apiVer = "";

                    if (errorList.contains("does not exist in DB.")) {
                        missingDB = true;
                    }
                    if (errorList.contains("Ensembl API version =")) {
                        int apiStart = errorList.indexOf("Ensembl API version =") + 22;
                        apiVer = errorList.substring(apiStart, apiStart + 3);
                    }
                    Email myAdminEmail = new Email();
                    if (!missingDB) {
                        myAdminEmail.setSubject("Exception thrown in Exec_session");
                        gdt.setError("Running Perl Script to get Gene and Transcript details/images. Ensembl Assembly v" + apiVer);
                    } else {
                        myAdminEmail.setSubject("Missing Ensembl ID in DB");
                        gdt.setError("The current Ensembl database does not have an entry for this gene ID." +
                                " As Ensembl IDs are added/removed from new versions it is likely this ID has been removed." +
                                " If you used a Gene Symbol and reached this the administrator will investigate. " +
                                "If you entered this Ensembl ID please try to use a synonym or visit Ensembl to investigate the status of this ID. " +
                                "Ensembl Assembly v" + apiVer);

                    }

                    myAdminEmail.setContent("There was an error while running "
                            + perlArgs[1] + " (" + perlArgs[2] + " , " + perlArgs[3] + " , " + perlArgs[4] + " , " + perlArgs[5] + " , " + perlArgs[6] + "," + perlArgs[7] +
                            ")\n\n" + myExec_session.getErrors());
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

                String errors = myExec_session.getErrors();
                if (myExec_session.isError() && !exception && errors != null && !(errors.equals(""))) {
                    completedSuccessfully = false;
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
                }
            }
        } catch (Exception e) {
            completedSuccessfully = false;
            log.error("Error getting DB properties or Public User ID.", e);
            String fullerrmsg = e.getMessage();
            StackTraceElement[] tmpEx = e.getStackTrace();
            for (int i = 0; i < tmpEx.length; i++) {
                fullerrmsg = fullerrmsg + "\n" + tmpEx[i];
            }
            Email myAdminEmail = new Email();
            myAdminEmail.setSubject("Exception thrown in GeneDataTools.java");
            myAdminEmail.setContent("There was an error setting up to run writeXML_RNA.pl\n\nFull Stacktrace:\n" + fullerrmsg);
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

}

class Tissues {
    private int dsid;
    private String tissue;
    private int buildVer;
    private int exprID;

    public Tissues(int dsid, String tissue, int buildVer, int exprID) {
        this.dsid = dsid;
        this.tissue = tissue;
        this.buildVer = buildVer;
        this.exprID = exprID;
    }

    public String getTissue() {
        return this.tissue;
    }

    public int getDatasetID() {
        return this.dsid;
    }

    public int getBuildVer() {
        return this.buildVer;
    }

    public int getExprDataID() {
        return exprID;
    }
}

class FeatureID {
    private String id;
    private double herit;

    public FeatureID(String id) {
        this.id = id;
    }

    public FeatureID(String id, double herit) {
        this.id = id;
        this.herit = herit;
    }

    public String getID() {
        return this.id;
    }

    public double getHeritability() {
        return this.herit;
    }
}

class GeneID extends FeatureID {
    private ArrayList<TrxID> trx;

    public GeneID(String geneID) {
        super(geneID);
        this.trx = new ArrayList<TrxID>();
    }

    public GeneID(String geneID, double herit) {
        super(geneID, herit);
        this.trx = new ArrayList<TrxID>();
    }

    public ArrayList<TrxID> getTranscripts() {
        return this.trx;
    }

    public void addTranscript(TrxID transcript) {
        trx.add(transcript);
    }
}

class TrxID extends FeatureID {
    public TrxID(String geneID, double herit) {
        super(geneID, herit);
    }
}
