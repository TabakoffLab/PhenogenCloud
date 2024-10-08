/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package edu.ucdenver.ccp.PhenoGen.data.RNASeq;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.sql.Date;
import java.util.HashMap;
import javax.sql.DataSource;

import org.apache.log4j.Logger;

/**
 * @author smahaffey
 */
public class RNASample {
    private long rnaDatasetID;
    private long rnaSampleID;
    private String strain;
    private String sampleName;
    private String age;
    private String sex;
    private String tissue;
    private String srcName;
    private String srcType;
    private Date srcDate;
    private String breeding;
    private String genoType;
    private String miscDetail;
    private String disease;
    private String phenotype;


    private ArrayList<RNATreatment> treatment;
    private ArrayList<RNARawDataFile> rawFiles;
    private ArrayList<RNAProtocol> protocols;

    private boolean isFileLoaded;
    private boolean isTreatmentLoaded;
    private boolean isProtocolLoaded;
    private int fileCount;

    private DataSource pool;
    private final Logger log;
    private final String selectWCount = "select rs.*,(Select count(*) from RNA_RAW_DATA_FILES rdf where rdf.RNA_SAMPLE_ID=rs.RNA_SAMPLE_ID) as file_count from rna_ds_samples rs ";
    private final String insert = "Insert into RNA_DS_SAMPLES (RNA_SAMPLE_ID,RNA_DATASET_ID,SAMPLE_NAME,STRAIN,AGE,SEX,TISSUE,SRC_NAME,SRC_DATE,SRC_TYPE,BREEDING_DETAILS,GENOTYPE,MISC_DETAILS,ASSOCIATED_DISEASE,PHENOTYPE_ID) Values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
    private final String update = "update set SAMPLE_NAME=?,STRAIN=?,AGE=?,SEX=?,TISSUE=?,SRC_NAME=?,SRC_DATE=?,SRC_TYPE=?,BREEDING_DETAILS=?,GENOTYPE=?,MISC_DETAILS=?,ASSOCIATED_DISEASE=?,PHENOTYPE_ID=? where RNA_SAMPLE_ID=?";
    private final String delete = "delete RNA_DS_SAMPLES where RNA_SAMPLE_ID=?";
    private final String getID = "select RNA_DS_SAMPLES_SEQ.nextVal from dual";

    public RNASample() {
        log = Logger.getRootLogger();
    }

    public RNASample(long sampleID, long datasetID, String sampleName, String strain, String age, String sex, String tissue, DataSource pool) {
        this(sampleID, datasetID, sampleName, strain, age, sex, tissue, "", "", null, "", "", "", "", "", pool);
    }

    public RNASample(long sampleID, long datasetID, String sampleName, String strain, String age, String sex, String tissue, String srcName,
                     String srcType, Date srcDate, String breeding, String genotype, String miscDetail, String disease, String phenotype, DataSource pool) {
        log = Logger.getRootLogger();
        this.setRnaDatasetID(datasetID);
        this.setRnaSampleID(sampleID);
        this.setAge(age);
        this.setSampleName(sampleName);
        this.setStrain(strain);
        this.setSex(sex);
        this.setTissue(tissue);
        this.setSrcName(srcName);
        this.setSrcType(srcType);
        this.setSrcDate(srcDate);
        this.setBreeding(breeding);
        this.setGenoType(genotype);
        this.setMiscDetail(miscDetail);
        this.setDisease(disease);
        this.setPhenotype(phenotype);
        isFileLoaded = false;
        isTreatmentLoaded = false;
        isProtocolLoaded = false;
        this.pool = pool;
        this.fileCount = 0;
    }

    public RNASample getRNASample(long id, DataSource pool) {
        String query = selectWCount + " where rs.rna_sample_id=" + id;
        return getRNASampleByQuery(query, pool);
    }

    public ArrayList<RNASample> getRNASamplesByDataset(long dsid, DataSource pool) {
        String query = selectWCount + " where rs.rna_dataset_id=" + dsid;
        return getRNASamplesByQuery(query, pool);
    }


    private RNASample getRNASampleByQuery(String query, DataSource pool) {
        RNASample ret = null;
        try (Connection conn = pool.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                ret = new RNASample(rs.getLong("RNA_SAMPLE_ID"),
                        rs.getLong("RNA_DATASET_ID"),
                        rs.getString("SAMPLE_NAME"),
                        rs.getString("STRAIN"),
                        rs.getString("AGE"),
                        rs.getString("SEX"),
                        rs.getString("TISSUE"),
                        rs.getString("SRC_NAME"),
                        rs.getString("SRC_TYPE"),
                        rs.getDate("SRC_DATE"),
                        rs.getString("BREEDING_DETAILS"),
                        rs.getString("GENOTYPE"),
                        rs.getString("MISC_DETAILS"),
                        rs.getString("ASSOCIATED_DISEASE"),
                        rs.getString("PHENOTYPE_ID"),
                        pool
                );
                ret.setFileCount(rs.getInt("FILE_COUNT"));
            }
            ps.close();

        } catch (SQLException e) {
            log.error("Error getting RNASample from \n" + query, e);
        }
        return ret;
    }

    public ArrayList<RNASample> getRNASamplesByQuery(String query, DataSource pool) {

        ArrayList<RNASample> ret = new ArrayList<>();
        try (Connection conn = pool.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {

                RNASample tmp = new RNASample(rs.getLong("RNA_SAMPLE_ID"),
                        rs.getLong("RNA_DATASET_ID"),
                        rs.getString("SAMPLE_NAME"),
                        rs.getString("STRAIN"),
                        rs.getString("AGE"),
                        rs.getString("SEX"),
                        rs.getString("TISSUE"),
                        rs.getString("SRC_NAME"),
                        rs.getString("SRC_TYPE"),
                        rs.getDate("SRC_DATE"),
                        rs.getString("BREEDING_DETAILS"),
                        rs.getString("GENOTYPE"),
                        rs.getString("MISC_DETAILS"),
                        rs.getString("ASSOCIATED_DISEASE"),
                        rs.getString("PHENOTYPE_ID"),
                        pool
                );
                tmp.setFileCount(rs.getInt("file_count"));
                ret.add(tmp);
            }
            ps.close();
        } catch (SQLException e) {
            log.error("Error getting RNADataset from \n" + query, e);
        }
        return ret;
    }

    public boolean createRNASample(RNASample rs, DataSource pool) {
        boolean success = false;
        this.pool = pool;
        if (rs.getRnaSampleID() == 0) {
            try (Connection conn = pool.getConnection()) {
                long newID = getNextID();
                PreparedStatement ps = conn.prepareStatement(insert);
                ps.setLong(1, newID);
                ps.setLong(2, rs.getRnaDatasetID());
                ps.setString(3, rs.getSampleName());
                ps.setString(4, rs.getStrain());
                ps.setString(5, rs.getAge());
                ps.setString(6, rs.getSex());
                ps.setString(7, rs.getTissue());
                ps.setString(8, rs.getSrcName());
                ps.setDate(9, rs.getSrcDate());
                ps.setString(10, rs.getSrcType());
                ps.setString(11, rs.getBreeding());
                ps.setString(12, rs.getGenoType());
                ps.setString(13, rs.getMiscDetail());
                ps.setString(14, rs.getDisease());
                ps.setString(15, rs.getPhenotype());
                boolean tmpSuccess = ps.execute();
                rs.setRnaSampleID(newID);
                //Treatments?
                if (tmpSuccess) {
                    RNATreatment myRS = new RNATreatment();
                    ArrayList<RNATreatment> rt = rs.getTreatment();
                    for (int i = 0; i < rt.size() && tmpSuccess; i++) {
                        tmpSuccess = myRS.createTreatment(rt.get(i), pool);
                    }
                }
                //RawFiles?
                if (tmpSuccess) {
                    RNARawDataFile myRDF = new RNARawDataFile();
                    ArrayList<RNARawDataFile> rdf = rs.getRawFiles();
                    for (int i = 0; i < rdf.size() && tmpSuccess; i++) {
                        tmpSuccess = myRDF.createRNARawDataFile(rdf.get(i), pool);
                    }
                }
                //Protocols?
                if (tmpSuccess) {
                    RNAProtocol myRP = new RNAProtocol();
                    ArrayList<RNAProtocol> rp = rs.getProtocols();
                    for (int i = 0; i < rp.size() && tmpSuccess; i++) {
                        RNAProtocol tmpRP = rp.get(i);
                        tmpSuccess = myRP.addRNAProtocolToSample(tmpRP.getRnaSampleID(), tmpRP.getRnaProtocolID(), tmpRP.getOrder(), tmpRP.getVariation(), pool);
                    }
                }
                if (tmpSuccess) {
                    success = true;
                }
            } catch (Exception e) {

            }
        }
        return success;
    }

    public boolean updateRNASample(RNASample rs, DataSource pool) {
        boolean success = false;
        try (Connection conn = pool.getConnection()) {
            PreparedStatement ps = conn.prepareStatement(update);
            ps.setString(1, rs.getSampleName());
            ps.setString(2, rs.getStrain());
            ps.setString(3, rs.getAge());
            ps.setString(4, rs.getSex());
            ps.setString(5, rs.getTissue());
            ps.setString(6, rs.getSrcName());
            ps.setDate(7, rs.getSrcDate());
            ps.setString(8, rs.getSrcType());
            ps.setString(9, rs.getBreeding());
            ps.setString(10, rs.getGenoType());
            ps.setString(11, rs.getMiscDetail());
            ps.setString(12, rs.getGenoType());
            ps.setString(13, rs.getPhenotype());
            ps.setLong(14, rs.getRnaSampleID());
            int numUpdated = ps.executeUpdate();
            if (numUpdated == 1) {
                success = true;
            }
        } catch (Exception e) {

        }
        return success;
    }

    public boolean deleteRNASample(RNASample rs, DataSource pool) {
        boolean success = false;
        //delete treatments
        RNATreatment myRT = new RNATreatment();
        myRT.removeAllTreatmentsFromSample(rs.getRnaSampleID(), pool);
        //delete raw files
        RNARawDataFile myRRDF = new RNARawDataFile();
        myRRDF.deleteRNARawDataFileBySample(rs.getRnaSampleID(), pool);
        //delete protocols
        RNAProtocol myRP = new RNAProtocol();
        myRP.deleteRNAProtocolsFromSample(rs.getRnaSampleID(), pool);
        //delete sample
        try (Connection conn = pool.getConnection()) {
            PreparedStatement ps = conn.prepareStatement(delete);
            ps.setLong(1, rs.getRnaSampleID());
            boolean tmpSuccess = ps.execute();
            if (tmpSuccess) {
                success = true;
            }
            ps.close();
        } catch (Exception e) {

        }

        return success;
    }

    private long getNextID() {
        long ret = 0;
        try (Connection conn = pool.getConnection();
             PreparedStatement ps = conn.prepareStatement(getID)) {
            ResultSet rs = ps.executeQuery();
            ret = rs.getLong(1);
            rs.close();
        } catch (SQLException e) {
            log.error("Error getting new RNA_Sample_ID:", e);
        }
        return ret;
    }

    public String getSampleName() {
        return sampleName;
    }

    public void setSampleName(String sampleName) {
        this.sampleName = sampleName;
    }

    public String getSrcName() {
        return srcName;
    }

    public void setSrcName(String srcName) {
        this.srcName = srcName;
    }

    public long getRnaDatasetID() {
        return rnaDatasetID;
    }

    public void setRnaDatasetID(long rnaDatasetID) {
        this.rnaDatasetID = rnaDatasetID;
    }

    public long getRnaSampleID() {
        return rnaSampleID;
    }

    public void setRnaSampleID(long rnaSampleID) {
        this.rnaSampleID = rnaSampleID;
    }

    public String getStrain() {
        return strain;
    }

    public void setStrain(String strain) {
        this.strain = strain;
    }

    public String getAge() {
        return age;
    }

    public void setAge(String age) {
        this.age = age;
    }

    public String getSex() {
        return sex;
    }

    public void setSex(String sex) {
        this.sex = sex;
    }

    public int getFileCount() {
        return fileCount;
    }

    public void setFileCount(int fileCount) {
        this.fileCount = fileCount;
    }

    public String getTissue() {
        return tissue;
    }

    public void setTissue(String tissue) {
        this.tissue = tissue;
    }

    public String getSrcType() {
        return srcType;
    }

    public void setSrcType(String srcType) {
        if (srcType != null) {
            this.srcType = srcType;
        } else {
            this.srcType = "";
        }
    }

    public Date getSrcDate() {
        return srcDate;
    }

    public void setSrcDate(Date srcDate) {
        if (srcDate != null) {
            this.srcDate = srcDate;
        } else {
            this.srcDate = new Date(0);
        }
    }

    public String getBreeding() {
        return breeding;
    }

    public void setBreeding(String breeding) {
        if (breeding != null) {
            this.breeding = breeding;
        } else {
            this.breeding = "";
        }
    }

    public String getGenoType() {
        return genoType;
    }

    public void setGenoType(String genoType) {
        if (genoType != null) {
            this.genoType = genoType;
        } else {
            this.genoType = "";
        }
    }

    public String getMiscDetail() {
        return miscDetail;
    }

    public void setMiscDetail(String miscDetail) {
        if (miscDetail != null) {
            this.miscDetail = miscDetail;
        } else {
            this.miscDetail = "";
        }
    }

    public String getDisease() {
        return disease;
    }

    public void setDisease(String disease) {
        if (disease != null) {
            this.disease = disease;
        } else {
            this.disease = "";
        }
    }

    public String getPhenotype() {
        return phenotype;
    }

    public void setPhenotype(String phenotype) {
        if (phenotype != null) {
            this.phenotype = phenotype;
        } else {
            this.phenotype = "";
        }
    }

    public ArrayList<RNATreatment> getTreatment() {
        if (!isTreatmentLoaded) {
            RNATreatment myTreatment = new RNATreatment();
            try {
                this.treatment = myTreatment.getTreatmentBySample(rnaSampleID, pool);
                isTreatmentLoaded = true;
            } catch (Exception e) {
                isTreatmentLoaded = false;
                treatment = new ArrayList<>();
                e.printStackTrace(System.err);
                log.error("error retreiving RNATreatments for RNASample:" + rnaDatasetID, e);
            }
        }
        return treatment;
    }

    public void setTreatment(ArrayList<RNATreatment> treatment) {
        this.treatment = treatment;
    }

    public ArrayList<RNARawDataFile> getRawFiles() {
        if (!isFileLoaded) {
            RNARawDataFile myDataFile = new RNARawDataFile();
            try {
                this.rawFiles = myDataFile.getRawDataFilesBySample(rnaSampleID, pool);
                isFileLoaded = true;
            } catch (Exception e) {
                isFileLoaded = false;
                rawFiles = new ArrayList<>();
                e.printStackTrace(System.err);
                log.error("error retreiving RNARawFiles for RNASample:" + rnaDatasetID, e);
            }
        }
        return rawFiles;
    }

    public void setRawFiles(ArrayList<RNARawDataFile> rawFiles) {
        this.rawFiles = rawFiles;
    }

    public boolean isIsFileLoaded() {
        return isFileLoaded;
    }

    public void setIsFileLoaded(boolean isFileLoaded) {
        this.isFileLoaded = isFileLoaded;
    }

    public boolean isIsTreatmentLoaded() {
        return isTreatmentLoaded;
    }

    public void setIsTreatmentLoaded(boolean isTreatmentLoaded) {
        this.isTreatmentLoaded = isTreatmentLoaded;
    }

    public ArrayList<RNAProtocol> getProtocols() {
        if (!isProtocolLoaded) {
            RNAProtocol myProtocol = new RNAProtocol();
            try {
                this.protocols = myProtocol.getProtocolsBySample(rnaSampleID, pool);
                isProtocolLoaded = true;
            } catch (Exception e) {
                isProtocolLoaded = false;
                protocols = new ArrayList<>();
                e.printStackTrace(System.err);
                log.error("error retreiving RNAProtocols for RNASample:" + rnaDatasetID, e);
            }
        }
        return protocols;
    }

    public ArrayList<String> getSeqTechFromRawFiles() {
        //log.debug("PRocessing Sample:"+this.getSampleName());
        ArrayList<String> list = new ArrayList<String>();
        HashMap<String, Integer> hm = new HashMap<String, Integer>();
        ArrayList<RNARawDataFile> tmpFile = this.getRawFiles();
        for (int i = 0; i < tmpFile.size(); i++) {
            if (!hm.containsKey(tmpFile.get(i).getInstrument())) {
                hm.put(tmpFile.get(i).getInstrument(), 1);
                list.add(tmpFile.get(i).getInstrument());
                //log.debug("add:"+tmpFile.get(i).getInstrument());
            }
        }
        return list;
    }

    public ArrayList<String> getReadTypeFromRawFiles() {
        //log.debug("PRocessing Sample:"+this.getSampleName());
        ArrayList<String> list = new ArrayList<String>();
        HashMap<String, Integer> hm = new HashMap<String, Integer>();
        ArrayList<RNARawDataFile> tmpFile = this.getRawFiles();
        for (int i = 0; i < tmpFile.size(); i++) {
            String readType = tmpFile.get(i).getReadLen() + "bp ";
            if (tmpFile.get(i).getPaired()) {
                readType = readType + " paired-end reads";
            } else {
                readType = readType + " single-end reads";
            }
            if (!hm.containsKey(readType)) {
                hm.put(readType, 1);
                list.add(readType);
                //log.debug("add:"+tmpFile.get(i).getInstrument());
            }
        }
        return list;
    }
}
