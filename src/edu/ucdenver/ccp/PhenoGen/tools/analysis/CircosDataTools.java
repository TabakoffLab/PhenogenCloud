package edu.ucdenver.ccp.PhenoGen.tools.analysis;

import edu.ucdenver.ccp.PhenoGen.tools.idecoder.IDecoderClient;
import edu.ucdenver.ccp.PhenoGen.tools.idecoder.Identifier;
import edu.ucdenver.ccp.PhenoGen.tools.idecoder.IdentifierLink;

import java.io.*;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Set;

import javax.servlet.http.HttpSession;
import javax.sql.DataSource;
import java.util.Date;
import org.apache.log4j.Logger;

public class CircosDataTools {
    private String chrList;
    private String tisList;
    private String genomeVer;
    private String source;
    private String url="";
    private String message="";
    private String path;
    private boolean success=false;
    private int cutoff;
    private int geneListID;
    private HttpSession session = null;
    private Logger log = null;


public CircosDataTools (HttpSession session,String path){
    this.session=session;
    this.path=path;
    log = Logger.getRootLogger();
}

public boolean runCircosGeneList(int geneListID,String chromosomeList,String tissueList,String source, String genomeVer, int cutoff){
    this.chrList=chromosomeList;
    this.tisList=tissueList;
    this.source=source;
    this.genomeVer=genomeVer;
    this.cutoff=cutoff;
    this.geneListID=geneListID;
    this.success=false;
    boolean continueCircos=true;

    DataSource pool=(DataSource) session.getAttribute("dbPool");

    // Check for Gene list
    // Create if doeesn't exist or is older than 1 month
    // Copy to circos folder if it does exist
    String finalPath=path+"geneListLocations.txt";
    File geneFile=new File(finalPath);
    File geneDirs=new File(path);
    long curTimeMinusOneWeek=(new Date()).getTime() - (7*24*60*60*1000);
    if( ! geneFile.exists() || geneFile.lastModified() < curTimeMinusOneWeek) {
        if(!geneDirs.exists()){
            geneDirs.mkdirs();
        }
        IDecoderClient myIDecoderClient = new IDecoderClient();
        myIDecoderClient.setNum_iterations(0);
        String[] targets = new String[]{"Gene Symbol", "Location", "Ensembl ID", "PhenoGen ID", "Affymetrix ID"};
        HashMap<String, String> found = new HashMap<>();
        try {
            BufferedWriter out = new BufferedWriter(new FileWriter(geneFile));
            try {
                Set iDecoderSet = myIDecoderClient.getIdentifiersByInputIDAndTargetCaseInsensitive(geneListID, targets, pool);
                if (iDecoderSet.size() > 0) {
                    Iterator itr = iDecoderSet.iterator();
                    while (((Iterator) itr).hasNext()) {
                        String chr = "";
                        int min = -1;
                        String id = "";
                        String trxID = "";
                        String phenogenID = "";
                        Identifier thisIdentifier = (Identifier) itr.next();
                        HashMap<String, Set<Identifier>> targetHM = thisIdentifier.getTargetHashMap();
                        if (targetHM.containsKey("Ensembl ID")) {
                            Set<Identifier> ensIDs = targetHM.get("Ensembl ID");
                            Iterator ensItr = ensIDs.iterator();
                            while (ensItr.hasNext()) {
                                Identifier curID = (Identifier) ensItr.next();
                                if (curID.getIdentifier().startsWith("ENSRNOG") || curID.getIdentifier().startsWith("ENSMUSG")) {
                                    chr = curID.getChromosome();
                                    min = Integer.parseInt(curID.getBP());
                                    id = curID.getIdentifier();
                                }
                            }
                        }
                        if (targetHM.containsKey("Gene Symbol")) {
                            String gs = "";
                            Set<Identifier> gsIDs = targetHM.get("Gene Symbol");
                            Iterator gsItr = gsIDs.iterator();
                            int count = 0;
                            while (gsItr.hasNext()) {
                                Identifier tmpGS = (Identifier) gsItr.next();
                                if (count > 0) {
                                    gs = gs + ",";
                                }
                                gs = gs + tmpGS.getIdentifier();
                                count++;
                            }
                            id = gs;
                        }
                        if (targetHM.containsKey("PhenoGen ID")) {
                            String phID = "";
                            Set<Identifier> phIDs = targetHM.get("PhenoGen ID");
                            Iterator pItr = phIDs.iterator();
                            int count = 0;
                            while (pItr.hasNext()) {
                                Identifier tmpP = (Identifier) pItr.next();
                                if(tmpP.getIdentifier().startsWith("PRN6G")) {
                                    if (count > 0) {
                                        phID = phID + ",";
                                    }
                                    phID = phID + tmpP.getIdentifier();
                                    count++;
                                }
                            }
                            if (id.equals("")) {
                                id = phID;
                            }
                            phenogenID = phID;
                        }
                        if (targetHM.containsKey("Affymetrix ID")) {
                            String affyID = "";
                            Set<Identifier> affyIDs = targetHM.get("Affymetrix ID");
                            Iterator aItr = affyIDs.iterator();
                            int count = 0;
                            while (aItr.hasNext()) {
                                Identifier tmpA = (Identifier) aItr.next();
                                if (tmpA.getIdentifier().startsWith("7")) {
                                    if (count > 0) {
                                        affyID = affyID + ",";
                                    }
                                    affyID = affyID + tmpA.getIdentifier();
                                    count++;
                                }
                            }
                            if (id.equals("")) {
                                id = affyID;
                            }
                            trxID = affyID;
                        }
                        if (chr.toLowerCase().startsWith("c")) {
                            chr = chr.substring(3);
                        }
                        chr = genomeVer.substring(0, 2) + chr;
                        out.write(chr + "\t" + min + "\t" + id + "\t" + trxID + "\t" + phenogenID + "\n");
                    }
                } else {
                    message = "Error translating gene list IDs to IDs with eQTLs.";
                    continueCircos = false;
                }
            } catch (SQLException e) {
                message = "Error SQL.";
                log.error("iDecoder exception", e);
                continueCircos = false;
            }
            out.close();
            log.debug("Final FILE:"+path+"/geneListLocations.txt");
            if(geneFile.exists()){
                log.debug("FILE EXISTS");
            }else{
                log.debug("File DOES NOT EXIST");
            }
        } catch (IOException er) {
            message = "Error IO.";
            log.error("iDecoder IO exception", er);
            continueCircos = false;
        }
    }
    //If iDecoder success call eQTL
    if(continueCircos){

    }

    //If eQTL success call circos
    if(continueCircos){
        //setup dirs
        //setup params
        //call circos
        success=true;
    }
    //set message and URL

    return success;
}


    public boolean isSuccess(){
        return success;
    }

    public String getURL() {
        return url;
    }

    private void setURL(String url) {
        this.url = url;
    }

    public String getMessage() {
        return message;
    }

    private void setMessage(String message) {
        this.message = message;
    }
}
