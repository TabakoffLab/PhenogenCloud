package edu.ucdenver.ccp.PhenoGen.data.Bio;

import java.util.HashMap;
import java.util.ArrayList;

public class TranscriptomeQTL {
    private String phenogenID="";
    private String ensemblID="";
    private String probeID="";
    private String chromosome="";
    private String geneSymbol="";
    private int start;
    private int end;
    private int strand;

    private HashMap<String,ArrayList<TrxQTL>> ensemblQTL= new HashMap<>();  //tissue, ArrayList of QTLS for ensembl Data
    private HashMap<String,ArrayList<TrxQTL>> phenogenQTL= new HashMap<>();  //tissue, ArrayList of QTLS for reconstruction Data

    public TranscriptomeQTL(String phenogenID,String ensemblID){
        this.phenogenID=phenogenID;
        this.ensemblID=ensemblID;
    }

    public TranscriptomeQTL(){

    }

    public String getPhenogenID() {
        return phenogenID;
    }

    public void setPhenogenID(String phenogenID) {
        this.phenogenID = phenogenID;
    }

    public String getEnsemblID() {
        return ensemblID;
    }

    public void setEnsemblID(String ensemblID) {
        this.ensemblID = ensemblID;
    }

    public String getProbeID() {
        return probeID;
    }

    public void setProbeID(String probeID) {
        this.probeID = probeID;
    }

    public String getChromosome() {
        return chromosome;
    }

    public void setChromosome(String chromosome) {
        this.chromosome = chromosome;
    }

    public int getStart() {
        return start;
    }

    public void setStart(int start) {
        this.start = start;
    }

    public int getEnd() {
        return end;
    }

    public void setEnd(int end) {
        this.end = end;
    }

    public int getStrand() {
        return strand;
    }

    public void setStrand(int strand) {
        this.strand = strand;
    }

    public String getGeneSymbol() {
        return geneSymbol;
    }

    public void setGeneSymbol(String geneSymbol) {
        this.geneSymbol = geneSymbol;
    }

    public void addQTL(String probe_id, String snp_id, String snpChromosome, int snpCoord, double pvalue, boolean isCis, String tissue){
        TrxQTL tmp=new TrxQTL(snp_id,snpChromosome,snpCoord,pvalue,isCis);
        if(probe_id.startsWith("ENS")){
            if(!ensemblQTL.containsKey(tissue)){
                ensemblQTL.put(tissue,new ArrayList<>());
            }
            ArrayList<TrxQTL> tmpList=ensemblQTL.get(tissue);
            tmpList.add(tmp);
        }else{
            if(!phenogenQTL.containsKey(tissue)){
                phenogenQTL.put(tissue,new ArrayList<>());
            }
            ArrayList<TrxQTL> tmpList=phenogenQTL.get(tissue);
            tmpList.add(tmp);
        }
    }
    public ArrayList<TrxQTL> getQTLList(String tissue,String source){
        if(source.equals("ensembl")){
            return ensemblQTL.get(tissue);
        }else{
            return phenogenQTL.get(tissue);
        }

    }
    public HashMap<String,ArrayList<TrxQTL>> getTissueQTLList(String source){
        if(source.equals("ensembl")){
            return ensemblQTL;
        }
        else{
            return phenogenQTL;
        }
    }
}

