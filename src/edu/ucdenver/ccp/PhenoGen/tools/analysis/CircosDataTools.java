package edu.ucdenver.ccp.PhenoGen.tools.analysis;

import edu.ucdenver.ccp.PhenoGen.driver.ExecException;
import edu.ucdenver.ccp.PhenoGen.driver.ExecHandler;
import edu.ucdenver.ccp.PhenoGen.tools.idecoder.IDecoderClient;
import edu.ucdenver.ccp.PhenoGen.tools.idecoder.Identifier;
import edu.ucdenver.ccp.PhenoGen.tools.idecoder.IdentifierLink;

import java.io.*;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Set;

import javax.servlet.http.HttpSession;
import javax.sql.DataSource;
import java.util.Date;
import java.sql.Connection;
import java.text.SimpleDateFormat;

import edu.ucdenver.ccp.PhenoGen.web.mail.Email;
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

public boolean runCircosGeneList(int geneListID,String chromosomeList,String tissueList,String source, String genomeVer, String rnaDSIDs, int cutoff){
    this.chrList=chromosomeList;
    this.tisList=tissueList;
    this.source=source;
    this.genomeVer=genomeVer;
    this.cutoff=cutoff;
    this.geneListID=geneListID;
    this.success=false;
    boolean continueCircos=true;
    String circosErrorMessage;
    DataSource pool=(DataSource) session.getAttribute("dbPool");

    // Check for Gene list
    // Create if doeesn't exist or is older than 1 month
    // Copy to circos folder if it does exist
    String finalPath=path+"/geneListLocations.txt";
    String finalPathEQTL=path+"/geneListEQTLs_"+source+".txt";

    StringBuffer pgID=new StringBuffer();
    boolean firstPGID=true;
    StringBuffer affID=new StringBuffer();
    boolean firstAffID=true;
    File geneFile=new File(finalPath);
    File eqtlFile=new File(finalPathEQTL);
    File geneDirs=new File(path);
    long curTimeMinusOneWeek=(new Date()).getTime() - (7*24*60*60*1000);
    if( ! geneFile.exists() || geneFile.lastModified() < curTimeMinusOneWeek || geneFile.length()==0 || ! eqtlFile.exists() || eqtlFile.lastModified() < curTimeMinusOneWeek || eqtlFile.length()==0 ) {
        log.debug("\nRunning GeneList code\n");
        if(!geneDirs.exists()){
            geneDirs.mkdirs();
        }
        IDecoderClient myIDecoderClient = new IDecoderClient();
        myIDecoderClient.setNum_iterations(0);
        String[] targets = new String[]{"Gene Symbol", "Location", "Ensembl ID", "PhenoGen ID", "Affymetrix ID"};
        HashMap<String, String> found = new HashMap<>();
        try(BufferedWriter out = new BufferedWriter(new FileWriter(geneFile))) {
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
                                if( tmpP.getIdentifier().startsWith("PRN6") /* &&
                                        ( (tmpP.getIdentifier().startsWith("PRN6.4") && rnaDSIDs.equals("93,94")) ||
                                                ( ! tmpP.getIdentifier().startsWith("PRN6.4") && rnaDSIDs.equals("21,23"))
                                        )*/
                                    ){
                                    if (count > 0) {
                                        phID = phID + ",";
                                    }else if(count==0){
                                        if(!firstPGID){
                                            pgID.append(",");
                                        }
                                        pgID.append("'"+tmpP.getIdentifier()+"'");
                                        firstPGID=false;
                                    }
                                    phID = phID + tmpP.getIdentifier();
                                    count++;
                                }else{
                                    log.debug("ID:"+tmpP.getIdentifier()+":rnads:"+rnaDSIDs);
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
                                    }else if(count==0){
                                        if(!firstAffID){
                                            affID.append(",");
                                        }
                                        affID.append("'"+tmpA.getIdentifier()+"'");
                                        firstAffID=false;
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
        } catch (IOException er) {
            message = "Error IO.";
            log.error("iDecoder IO exception", er);
            continueCircos = false;
        }
    /*}
    //If iDecoder success call eQTL
    if(continueCircos){*/

        HashMap<Integer,String> chrHM=new HashMap<>();
        try(BufferedWriter out = new BufferedWriter(new FileWriter(finalPathEQTL))) {
            try(Connection conn=pool.getConnection()) {
                String organism="Rn";
                if(genomeVer.toLowerCase().startsWith("mm")){
                    organism="Mm";
                }
                String chrQ="select chromosome_id,name from chromosomes where organism='"+organism+"'";
                PreparedStatement psC = conn.prepareStatement(chrQ);
                ResultSet rsC = psC.executeQuery();
                while(rsC.next()){
                    int tmpID=rsC.getInt(1);
                    String tmpName=rsC.getString(2);
                    chrHM.put(tmpID,tmpName);
                }
                String inIDs;
                if(source.equals("array")){
                    inIDs=affID.toString();
                }else{
                    inIDs=pgID.toString();
                }
                String qtlQuery="select s.chromosome_id,s.snp_start,s.tissue,l.pvalue,l.probe_id "
                        +"from SNPS s "
                        +"left outer join location_specific_eqtl2 l on s.snp_id=l.snp_id "
                        +"where l.probe_id in ( "+inIDs+") "
                        +"and s.genome_id='"+genomeVer+"' "
                        +"and s.type='"+source+"' ";
                if(source.equals("seq")){

                    qtlQuery=qtlQuery+" and s.rna_dataset_id in ("+rnaDSIDs+")";
                }
                        //+"and l.PVALUE >= "+cutoff;
                log.debug("\n"+qtlQuery+"\n");
                PreparedStatement ps = conn.prepareStatement(qtlQuery);
                ResultSet rs= ps.executeQuery();
                while (rs.next()){
                    String curChr=chrHM.get(rs.getInt(1));
                    int start=rs.getInt(2);
                    String tissue=rs.getString(3);
                    float pval=rs.getFloat(4);
                    String probe=rs.getString(5);
                    out.write(curChr+"\t"+start+"\t"+tissue+"\t"+pval+"\t"+probe+"\n");
                }
            }catch (SQLException e) {
                message = "Error SQL.";
                log.error("genelist circos eQTL exception", e);
                continueCircos = false;
            }
        }catch (IOException er) {
            message = "Error IO.";
            log.error("genelist circos IO exception", er);
            continueCircos = false;
        }
    }

    java.util.Date dNow = new java.util.Date( );
    SimpleDateFormat ft = new SimpleDateFormat ("yyyyMMddhhmmss");
    String timeStampString = ft.format(dNow);

    //If eQTL success call circos
    if(continueCircos){
        //setup dirs

        String perlScriptDirectory = (String)session.getAttribute("perlDir")+"scripts/";
        String perlEnvironmentVariables = (String)session.getAttribute("perlEnvVar");

        perlEnvironmentVariables += ":/usr/bin:/usr/share/circos/lib:/usr/share/circos/bin";
        String[] perlScriptArguments = new String[11];
        // the 0 element in the perlScriptArguments array must be "perl" ??
        perlScriptArguments[0] = "perl";
        // the 1 element in the perlScriptArguments array must be the script name including path
        perlScriptArguments[1]=perlScriptDirectory+"callCircosGeneList.pl";
        perlScriptArguments[2]=Integer.toString(cutoff);
        perlScriptArguments[3]=genomeVer.substring(0, 2);
        perlScriptArguments[4]=chrList;
        perlScriptArguments[5]=tisList;
        perlScriptArguments[6]=path;
        perlScriptArguments[7]=timeStampString;
        perlScriptArguments[8]=genomeVer;
        perlScriptArguments[9]=source;
        perlScriptArguments[10]=rnaDSIDs;
        //setup params
        //call circos
        String[] envVar=perlEnvironmentVariables.split(",");

        for (int i = 0; i < envVar.length; i++) {
            log.debug(i + " EnvVar::" + envVar[i]);
        }

        String filePrefixWithPath=path+"/"+timeStampString;
        File oDir=new File(filePrefixWithPath);
        if(! oDir.exists()){
            oDir.mkdirs();
        }
        //construct ExecHandler which is used instead of Perl Handler because environment variables were needed.
        ExecHandler myExec_session = new ExecHandler(perlScriptDirectory, perlScriptArguments, envVar, filePrefixWithPath+"/circos");
        boolean exception = false;
        try {

            myExec_session.runExec();
            int exit=myExec_session.getExitValue();
            if(exit==0){

            }else{
                continueCircos=false;
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
            if(! circosErrorMessage.contains("WARNING **: Unimplemented style property SP_PROP_POINTER_EVENTS:")){
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
        if(!exception && errors!=null && !(errors.equals(""))) {
            if (!errors.contains("WARNING **: Unimplemented style property SP_PROP_POINTER_EVENTS:")) {
                Email myAdminEmail = new Email();
                myAdminEmail.setSubject("Exception thrown in Exec_session");
                circosErrorMessage = "There was an error while running ";
                circosErrorMessage = circosErrorMessage + " " + perlScriptArguments[1] + " (";
                for (int i = 2; i < perlScriptArguments.length; i++) {
                    circosErrorMessage = circosErrorMessage + " " + perlScriptArguments[i];
                }
                circosErrorMessage = circosErrorMessage + ")\n\n" + errors;
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
    }
    if(continueCircos){
        success=true;
    }
    //set message and URL
    if(success) {
        File tmp=new File(path+"/"+timeStampString+"/svg/circos_new.svg");
        tmp.setReadable(true,false);
        tmp.setExecutable(true,false);
        //url = path.substring(path.indexOf("tmpData"))+"/"+timeStampString+"/svg/circos_new.svg";
        url = path.substring(path.indexOf("/tmpData"))+"/"+timeStampString+"/svg/circos_new.svg";
        log.debug("circosPath:\n"+url);

        message = "success";
    }
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
