package edu.ucdenver.ccp.PhenoGen.data.Bio;

public class TrxQTL {
    private String snpID = "";
    private double pvalue;
    private boolean isCis = false;
    private int snpCoord = 0;
    private String snpChr = "";

    public TrxQTL(String snpID, String snpChr, int snpCoord, double pvalue, boolean isCis) {
        this.snpID = snpID;
        this.snpChr = snpChr;
        this.snpCoord = snpCoord;
        this.pvalue = pvalue;
        this.isCis = isCis;
    }

    public String getSnpID() {
        return snpID;
    }

    public void setSnpID(String snpID) {
        this.snpID = snpID;
    }

    public double getPValue() {
        return pvalue;
    }

    public void setPValue(double pvalue) {
        this.pvalue = pvalue;
    }

    public boolean isCis() {
        return isCis;
    }

    public void setCis(boolean cis) {
        isCis = cis;
    }

    public int getSNPCoord() {
        return snpCoord;
    }

    public void setSNPCoord(int snpCoord) {
        this.snpCoord = snpCoord;
    }

    public String getSNPChr() {
        return snpChr;
    }

    public void setSNPChr(String snpChr) {
        this.snpChr = snpChr;
    }
    public double getNegLogPVal(){
        double newP=Math.log10(this.pvalue)*-1;
        return newP;
    }
}
