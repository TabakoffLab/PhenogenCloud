package edu.ucdenver.ccp.PhenoGen.data.internal;

import javax.servlet.http.HttpSession;
import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.List;

import edu.ucdenver.ccp.PhenoGen.data.Dataset;
import edu.ucdenver.ccp.PhenoGen.data.Experiment;
import edu.ucdenver.ccp.PhenoGen.data.GeneList;
import edu.ucdenver.ccp.PhenoGen.data.User;

import edu.ucdenver.ccp.util.Debugger;
import edu.ucdenver.ccp.util.ObjectHandler;

/* for logging messages */
import org.apache.log4j.Logger;

/**
 * Class for handling the resources available for downloading
 *  @author  Cheryl Hornbaker
 */

public class Resource {

	private Logger log=null;

	private Debugger myDebugger = new Debugger();
	private ObjectHandler myObjectHandler = new ObjectHandler();
	public MarkerDataFile[] markerDataFiles = null;
        public SAMDataFile[] samDataFiles = null;
        public GenotypeDataFile[] genotypeDataFiles = null;
	public ExpressionDataFile[] expressionDataFiles = null;
    public SAMDataFile[] rnaSeqExpressionDataFiles = null;
	public EQTLDataFile[] eQTLDataFiles = null;
	public HeritabilityDataFile[] heritabilityDataFiles = null;
        public MaskDataFile[] maskDataFiles=null;
        public PublicationFile[] publicationFiles=null;
        private Dataset[] publicDatasets = null;
	private HttpSession session ;
	private edu.ucdenver.ccp.PhenoGen.data.Array myArray = new edu.ucdenver.ccp.PhenoGen.data.Array();
        public static final String BXDRI_PANEL = "BXD Recombinant Inbred Panel"; 
        public static final String INBRED_PANEL = "Inbred Panel"; 
        public static final String HXBRI_PANEL = "HXB/BXH Recombinant Inbred Panel";
        public static final String LXSRI_PANEL = "ILSXISS Recombinant Inbred Panel";

        private int id;
        private String organism;
        private String source="";
        private String panel;
        private String tissue;
        private String arrayName;
        private String rnaType;
        private String techType;
        private String readType;
        private String panelStr;
        private Dataset dataset;
        private String population;
        private String ancestry;
        private String description;
        private String genomeVer;
        private String downloadHeader;
        //private String context="";


	public Resource() {
		log = Logger.getRootLogger();
	}

	public Resource(int id) {
		log = Logger.getRootLogger();
		setID(id);
	}

	public Resource(int id, String organism, String panel, String tissue, String arrayName) {
		log = Logger.getRootLogger();
		setID(id);
		setOrganism(organism);
		setPanel(panel);
		setTissue(tissue);
		setArrayName(arrayName);
	}

	public Resource(int id, String organism, String panel, Dataset dataset, String tissue, String arrayName, ExpressionDataFile[] expressionFileArray, EQTLDataFile[] eQTLFileArray, HeritabilityDataFile[] heritabilityFileArray, MaskDataFile[] maskFileArray) {
		log = Logger.getRootLogger();
		setID(id);
		setOrganism(organism);
		setPanel(panel);
		setDataset(dataset);
		setTissue(tissue);
		setArrayName(arrayName);
		setExpressionDataFiles(expressionFileArray);
		setEQTLDataFiles(eQTLFileArray);
		setHeritabilityDataFiles(heritabilityFileArray);
                setMaskDataFiles(maskFileArray);
	}
        
        public Resource(int id, String organism, String strain,String rnaType,String tissue,String tech,String readType, SAMDataFile[] samFileArray,String genomeVer) {
		log = Logger.getRootLogger();
		setID(id);
		setOrganism(organism);
		setSource(strain);
		setSAMDataFiles(samFileArray);
                setRNAType(rnaType);
                setTissue(tissue);
                setTechType(tech);
                setReadType(readType);
                setGenome(genomeVer);
	}
        
        public Resource(int id, String organism, String strain,String tech, SAMDataFile[] samFileArray,String genomeVer) {
		log = Logger.getRootLogger();
		setID(id);
		setOrganism(organism);
		setSource(strain);
		setSAMDataFiles(samFileArray);
                setTechType(tech);
                setGenome(genomeVer);
	}
        
        public Resource(int id, String organism, String population,String ancestry,String tech, GenotypeDataFile[] genotypeFileArray) {
		log = Logger.getRootLogger();
		setID(id);
		setOrganism(organism);
		setPopulation(population);
		setGenotypeDataFiles(genotypeFileArray);
                setAncestry(ancestry);
                setTechType(tech);
	}

	public Resource(int id, String organism, String source, Dataset dataset, MarkerDataFile[] markerFileArray, EQTLDataFile[] eQTLFileArray,String paneltmp) {
		log = Logger.getRootLogger();
		setID(id);
		setOrganism(organism);
		setSource(source);
		setDataset(dataset);
		setMarkerDataFiles(markerFileArray);
		setEQTLDataFiles(eQTLFileArray);
                setPanelString(paneltmp);
	}

	public Resource(int id, String organism, String panel) {
		log = Logger.getRootLogger();
		setID(id);
		setOrganism(organism);
		setPanel(panel);
	}
        
        public Resource(int id, String organism, String panel,String description,PublicationFile[] files,String downloadHeader) {
		log = Logger.getRootLogger();
		setID(id);
		setOrganism(organism);
		setPanel(panel);
                setDescription(description);
                setPublicationFiles(files);
                setDownloadHeader(downloadHeader);
	}

        public Resource(HttpSession session) {
                log = Logger.getRootLogger();
		setSession(session); 
		//log.debug("instantiated Resource setting session variable");
	}

        public void setID(int inInt) {
                this.id = inInt;
        }

        public int getID() {
                return this.id;
        }

        public void setOrganism(String inString) {
                this.organism = inString;
        }

        public String getOrganism() {
                return this.organism;
        }
        
        public void setDescription(String inString) {
                this.description = inString;
        }

        public String getDescription() {
                return this.description;
        }

        public void setSource(String inString) {
                this.source = inString;
        }

        public String getSource() {
                return this.source;
        }

        public void setPanel(String inString) {
                this.panel = inString;
        }

        public String getPanel() {
                return this.panel;
        }
        
        public void setPanelString(String inString) {
                this.panelStr = inString;
        }

        public String getPanelString() {
                return this.panelStr;
        }

        public void setTissue(String inString) {
                this.tissue = inString;
        }

        public String getTissue() {
                return this.tissue;
        }

    public String getReadType() {
        return readType;
    }

    public void setReadType(String readType) {
        this.readType = readType;
    }

    public String getRNAType() {
        return rnaType;
    }

    public void setRNAType(String rnaType) {
        this.rnaType = rnaType;
    }
    
    public String getGenome() {
        return genomeVer;
    }

    public void setGenome(String genome) {
        this.genomeVer = genome;
    }

    public String getTechType() {
        return techType;
    }

    public void setTechType(String techType) {
        this.techType = techType;
    }

        public void setArrayName(String inString) {
                this.arrayName = inString;
        }

        public String getArrayName() {
                return this.arrayName;
        }

        public void setDataset(Dataset inDataset) {
                this.dataset = inDataset;
        }

        public Dataset getDataset() {
                return this.dataset;
        }

        public void setMarkerDataFiles(MarkerDataFile[] inMarkerDataFiles) {
                this.markerDataFiles = inMarkerDataFiles;
        }

        public MarkerDataFile[] getMarkerDataFiles() {
                return this.markerDataFiles;
        }

        /*public SAMDataFile[] getRNASeqExpressionDataFiles() {
            return this.rnaSeqExpressionDataFiles;
        }
        public void setRNASeqExpressionDataFiles(SAMDataFile[] inSAMDataFiles) {
            this.rnaSeqExpressionDataFiles = inSAMDataFiles;
        }*/
        
        public void setSAMDataFiles(SAMDataFile[] inSAMDataFiles) {
                this.samDataFiles = inSAMDataFiles;
        }
        public SAMDataFile[] getSAMDataFiles() {
                return this.samDataFiles;
        }
        
        public void setGenotypeDataFiles(GenotypeDataFile[] inGenotypeDataFiles) {
                this.genotypeDataFiles = inGenotypeDataFiles;
        }
        public GenotypeDataFile[] getGenotypeDataFiles() {
                return this.genotypeDataFiles;
        }

        public void setExpressionDataFiles(ExpressionDataFile[] inExpressionDataFiles) {
                this.expressionDataFiles = inExpressionDataFiles;
        }

        public ExpressionDataFile[] getExpressionDataFiles() {
                return this.expressionDataFiles;
        }

        public void setEQTLDataFiles(EQTLDataFile[] inEQTLDataFiles) {
                this.eQTLDataFiles = inEQTLDataFiles;
        }

        public EQTLDataFile[] getEQTLDataFiles() {
                return this.eQTLDataFiles;
        }

        public void setHeritabilityDataFiles(HeritabilityDataFile[] inHeritabilityDataFiles) {
                this.heritabilityDataFiles = inHeritabilityDataFiles;
        }

        public HeritabilityDataFile[] getHeritabilityDataFiles() {
                return this.heritabilityDataFiles;
        }

        public void setMaskDataFiles(MaskDataFile[] inMaskDataFiles) {
                this.maskDataFiles = inMaskDataFiles;
        }

        public MaskDataFile[] getMaskDataFiles() {
                return this.maskDataFiles;
        }
        
        public void setPublicationFiles(PublicationFile[] inPubFiles) {
                this.publicationFiles = inPubFiles;
        }

        public PublicationFile[] getPublicationFiles() {
                return this.publicationFiles;
        }
        
        public String getPopulation() {
            return population;
        }

        public void setPopulation(String population) {
            this.population = population;
        }

        public String getAncestry() {
            return ancestry;
        }

        public void setAncestry(String ancestry) {
            this.ancestry = ancestry;
        }

        public String getDownloadHeader() {
            return downloadHeader;
        }

        public void setDownloadHeader(String downloadHeader) {
            this.downloadHeader = downloadHeader;
        }
        
        

	public HttpSession getSession() {
		log.debug("in getSession");
		return session;
	}

	public void setSession(HttpSession inSession) {
		log.debug("in Resource.setSession");
		this.session = inSession;
                //this.context=(String)this.session.getAttribute("contextRoot");
                //this.context=this.context.substring(0,this.context.length()-1);
                this.publicDatasets = ((Dataset[]) session.getAttribute("publicDatasets") == null ?
                                null :
                                (Dataset[]) session.getAttribute("publicDatasets"));
	}

	/**
	 * Gets all the expression and marker resources
	 * @return	an array of Resource objects
	 */
	public Resource[] getAllResources() {
		List<Resource> expressionResources = Arrays.asList(getExpressionResources());
		List<Resource> markerResources = Arrays.asList(getMarkerResources());
                List<Resource> rnaResources = Arrays.asList(getRNASeqResources());
                List<Resource> dnaResources = Arrays.asList(getDNASeqResources());
                List<Resource> genotypingResources = Arrays.asList(getGenotypingResources());
                List<Resource> pubResources1 = Arrays.asList(getPublicationResources1());
                List<Resource> pubResources2 = Arrays.asList(getPublicationResources2());
                List<Resource> pubResources3 = Arrays.asList(getPublicationResources3());
                List<Resource> pubResources4 = Arrays.asList(getPublicationResources4());
                List<Resource> pubResources5 = Arrays.asList(getPublicationResources5());
                List<Resource> pubResources6 = Arrays.asList(getPublicationResources6());
                List<Resource> pubResources7 = Arrays.asList(getPublicationResources7());
                List<Resource> pubResources8 = Arrays.asList(getPublicationResources8());
                List<Resource> pubResources9 = Arrays.asList(getPublicationResources9());
                List<Resource> gtfResources = Arrays.asList(getGTFResources());
                List<Resource> rsemResources = Arrays.asList(getRNASeqExpressionResources());
		List<Resource> allResources = new ArrayList<Resource>(expressionResources);
		allResources.addAll(markerResources);
                allResources.addAll(rnaResources);
                allResources.addAll(dnaResources);
                allResources.addAll(genotypingResources);
                allResources.addAll(pubResources1);
                allResources.addAll(pubResources2);
                allResources.addAll(pubResources3);
                allResources.addAll(pubResources4);
                allResources.addAll(pubResources5);
                allResources.addAll(pubResources6);
                allResources.addAll(pubResources7);
                allResources.addAll(pubResources8);
                allResources.addAll(pubResources9);
                allResources.addAll(gtfResources);
                allResources.addAll(rsemResources);
		Resource[] allResourcesArray = myObjectHandler.getAsArray(allResources, Resource.class);
		return allResourcesArray;
	}

	/**
	 * Gets all the expression resources
	 * @return	an array of Resource objects
	 */
	public Resource[] getExpressionResources() {

		log.debug("in getExpressionResources");
		List<Resource> resourceList = new ArrayList<Resource>();
		log.debug("publicDatasets has " + publicDatasets.length + " entries");

		Dataset myDataset = new Dataset();
		Dataset BXDRI_Dataset = myDataset.getDatasetFromMyDatasets(publicDatasets, myDataset.BXDRI_DATASET_NAME);
		Dataset HXBRI_Dataset = myDataset.getDatasetFromMyDatasets(publicDatasets, myDataset.HXBRI_DATASET_NAME);
		Dataset Inbred_Dataset = myDataset.getDatasetFromMyDatasets(publicDatasets, myDataset.INBRED_DATASET_NAME);
		Dataset LXSRI_Dataset = myDataset.getDatasetFromMyDatasets(publicDatasets, myDataset.LXSRI_DATASET_NAME);
		Dataset HXBRI_Brain_Exon_Dataset = myDataset.getDatasetFromMyDatasets(publicDatasets, myDataset.HXBRI_BRAIN_EXON_DATASET_NAME);
		Dataset HXBRI_Heart_Exon_Dataset = myDataset.getDatasetFromMyDatasets(publicDatasets, myDataset.HXBRI_HEART_EXON_DATASET_NAME);
		Dataset HXBRI_Liver_Exon_Dataset = myDataset.getDatasetFromMyDatasets(publicDatasets, myDataset.HXBRI_LIVER_EXON_DATASET_NAME);
		Dataset HXBRI_Brown_Adipose_Exon_Dataset = myDataset.getDatasetFromMyDatasets(publicDatasets, myDataset.HXBRI_BROWN_ADIPOSE_EXON_DATASET_NAME);

		// Setup the BXDRI stuff
		String resourcesDir = BXDRI_Dataset.getResourcesDir();
        log.debug("BXDRI"+resourcesDir);
		resourcesDir=resourcesDir.substring(resourcesDir.indexOf("/userFiles/"));
		String datasetDir = BXDRI_Dataset.getPath();

		List<ExpressionDataFile> expressionFileList = new ArrayList<ExpressionDataFile>();
		expressionFileList.add(new ExpressionDataFile("Normalized expression values", resourcesDir + "BXD_v6_Affymetrix.Normalization.output.csv.zip","Mm9"));
		expressionFileList.add(new ExpressionDataFile("Raw Data - CEL Files, Part 1", resourcesDir + "PublicBXDRIMice_RawData_Part1.zip","N/A"));
		expressionFileList.add(new ExpressionDataFile("Raw Data - CEL Files, Part 2", resourcesDir + "PublicBXDRIMice_RawData_Part2.zip","N/A"));
		ExpressionDataFile[] expressionFileArray = myObjectHandler.getAsArray(expressionFileList, ExpressionDataFile.class);

		List<EQTLDataFile> eQTLFileList = new ArrayList<EQTLDataFile>();
		eQTLFileList.add(new EQTLDataFile("eQTLs using Wellcome Trust Markers", resourcesDir + "BXD_eQTL_WellcomeTrustMarkers_16Apr12.csv.zip"));
		EQTLDataFile[] eQTLFileArray = myObjectHandler.getAsArray(eQTLFileList, EQTLDataFile.class);

		List<HeritabilityDataFile> heritabilityFileList = new ArrayList<HeritabilityDataFile>();
		heritabilityFileList.add(new HeritabilityDataFile("Heritability file from RMA normalization plus probe mask", resourcesDir + "herits.BXD.zip","Mm9"));
		HeritabilityDataFile[] heritabilityFileArray = myObjectHandler.getAsArray(heritabilityFileList, HeritabilityDataFile.class);

		resourceList.add(new Resource(257, "Mouse", BXDRI_PANEL, BXDRI_Dataset, "Whole Brain", myArray.MOUSE430V2_ARRAY_TYPE,  expressionFileArray, eQTLFileArray, heritabilityFileArray,null));

		// Setup the LXSRI stuff
		resourcesDir = LXSRI_Dataset.getResourcesDir();
                resourcesDir=resourcesDir.substring(resourcesDir.indexOf("/userFiles/"));
		datasetDir = LXSRI_Dataset.getPath();

		expressionFileList = new ArrayList<ExpressionDataFile>();
		expressionFileList.add(new ExpressionDataFile("Normalized expression values and DABG p-values for Core Transcripts", resourcesDir + "LXS_mm10_v4_Affymetrix.Normalization.output.csv.zip","Mm10"));
		expressionFileList.add(new ExpressionDataFile("Normalized expression values and DABG p-values for Full Transcripts", resourcesDir + "LXS_mm10_v5_Affymetrix.Normalization.output.csv.zip","Mm10"));
                expressionFileList.add(new ExpressionDataFile("Normalized expression values and DABG p-values for Full Probesets", resourcesDir + "LXS_mm10_v6_Affymetrix.Normalization.output.csv.zip","Mm10"));
		expressionFileList.add(new ExpressionDataFile("Core Transcripts Detection Above Background p-values", resourcesDir + "dabg.coreTrans.LXS.mm10.PhenoGen.txt.zip","Mm10"));
		expressionFileList.add(new ExpressionDataFile("Core Transcripts Normalized expression values", resourcesDir + "rma.coreTrans.LXS.mm10.PhenoGen.txt.zip","Mm10"));
		expressionFileList.add(new ExpressionDataFile("Full Transcripts Detection Above Background p-values", resourcesDir + "dabg.fullTrans.LXS.mm10.PhenoGen.txt.zip","Mm10"));
		expressionFileList.add(new ExpressionDataFile("Full Transcripts Normalized expression values", resourcesDir + "rma.fullTrans.LXS.mm10.PhenoGen.txt.zip","Mm10"));
                expressionFileList.add(new ExpressionDataFile("Full Probesets Detection Above Background p-values", resourcesDir + "dabg.fullPS.LXS.mm10.PhenoGen.txt.zip","Mm10"));
		expressionFileList.add(new ExpressionDataFile("Full Probesets Normalized expression values", resourcesDir + "rma.fullPS.LXS.mm10.PhenoGen.txt.zip","Mm10"));
		expressionFileList.add(new ExpressionDataFile("Raw Data - CEL Files, Part 1", resourcesDir + "PublicLXSRIMice_RawData_Part1.zip","N/A"));
		expressionFileList.add(new ExpressionDataFile("Raw Data - CEL Files, Part 2", resourcesDir + "PublicLXSRIMice_RawData_Part2.zip","N/A"));
		expressionFileList.add(new ExpressionDataFile("Raw Data - CEL Files, Part 3", resourcesDir + "PublicLXSRIMice_RawData_Part3.zip","N/A"));
		expressionFileList.add(new ExpressionDataFile("Raw Data - CEL Files, Part 4", resourcesDir + "PublicLXSRIMice_RawData_Part4.zip","N/A"));
		expressionFileList.add(new ExpressionDataFile("Raw Data - CEL Files, Part 5", resourcesDir + "PublicLXSRIMice_RawData_Part5.zip","N/A"));
		expressionFileList.add(new ExpressionDataFile("Raw Data - CEL Files, Part 6", resourcesDir + "PublicLXSRIMice_RawData_Part6.zip","N/A"));
		expressionFileList.add(new ExpressionDataFile("Raw Data - CEL Files, Part 7", resourcesDir + "PublicLXSRIMice_RawData_Part7.zip","N/A"));
		expressionFileList.add(new ExpressionDataFile("Raw Data - CEL Files, Part 8", resourcesDir + "PublicLXSRIMice_RawData_Part8.zip","N/A"));
		expressionFileList.add(new ExpressionDataFile("Raw Data - CEL Files, Part 9", resourcesDir + "PublicLXSRIMice_RawData_Part9.zip","N/A"));
		expressionFileList.add(new ExpressionDataFile("Raw Data - CEL Files, Part 10", resourcesDir + "PublicLXSRIMice_RawData_Part10.zip","N/A"));
		expressionFileList.add(new ExpressionDataFile("Raw Data - CEL Files, Part 11", resourcesDir + "PublicLXSRIMice_RawData_Part11.zip","N/A"));
		expressionFileList.add(new ExpressionDataFile("Raw Data - CEL Files, Part 12", resourcesDir + "PublicLXSRIMice_RawData_Part12.zip","N/A"));
		expressionFileList.add(new ExpressionDataFile("Raw Data - CEL Files, Part 13", resourcesDir + "PublicLXSRIMice_RawData_Part13.zip","N/A"));
		expressionFileList.add(new ExpressionDataFile("Raw Data - CEL Files, Part 14", resourcesDir + "PublicLXSRIMice_RawData_Part14.zip","N/A"));
		expressionFileList.add(new ExpressionDataFile("Raw Data - CEL Files, Part 15", resourcesDir + "PublicLXSRIMice_RawData_Part15.zip","N/A"));
		expressionFileArray = myObjectHandler.getAsArray(expressionFileList, ExpressionDataFile.class);
                                                                                                                                                                                                
		eQTLFileList = new ArrayList<EQTLDataFile>();
		eQTLFileList.add(new EQTLDataFile("eQTLs for Core Transcripts from the Affymetrix Mouse Diversity SNP Array data gathered by Churchill et al. in .csv format", resourcesDir + "LXS.eQTL.coreTrans.mm10.11Nov13.csv.zip"));
		eQTLFileList.add(new EQTLDataFile("eQTLs for Core Transcripts from the Affymetrix Mouse Diversity SNP Array data gathered by Churchill et al. in .txt format", resourcesDir + "LXS.eQTL.coreTrans.mm10.11Nov13.txt.zip"));
                eQTLFileList.add(new EQTLDataFile("eQTLs for Full Probesets from the Affymetrix Mouse Diversity SNP Array data gathered by Churchill et al. in .csv format", resourcesDir + "LXS.eQTL.fullPS.mm10.19Nov13.csv.zip"));
		eQTLFileList.add(new EQTLDataFile("eQTLs for Full Probesets from the Affymetrix Mouse Diversity SNP Array data gathered by Churchill et al. in .txt format", resourcesDir + "LXS.eQTL.fullPS.mm10.19Nov13.txt.zip"));
		eQTLFileArray = myObjectHandler.getAsArray(eQTLFileList, EQTLDataFile.class);

		heritabilityFileList = new ArrayList<HeritabilityDataFile>();
		heritabilityFileList.add(new HeritabilityDataFile("Heritabilty File from Core Transcripts", resourcesDir + "herits.coreTrans.LXS.mm10.Brain.txt.zip","Mm10"));
		heritabilityFileList.add(new HeritabilityDataFile("Heritabilty File from Full Transcripts", resourcesDir + "herits.fullTrans.LXS.mm10.Brain.txt.zip","Mm10"));
                heritabilityFileList.add(new HeritabilityDataFile("Heritabilty File from Full Probe sets", resourcesDir + "herits.fullPS.LXS.mm10.Brain.txt.zip","Mm10"));
		heritabilityFileArray = myObjectHandler.getAsArray(heritabilityFileList, HeritabilityDataFile.class);

                List<MaskDataFile> maskFileList = new ArrayList<MaskDataFile>();
		maskFileList.add(new MaskDataFile("Mask File for ILS/ISS Mm10 All Transcripts", resourcesDir + "MoEx-1_0-st-v1.r2.dt1.mm10.all.MASKED.LXS.mps.zip","Mm10"));
		maskFileList.add(new MaskDataFile("Mask File for ILS/ISS Mm10 Core Transcripts", resourcesDir + "MoEx-1_0-st-v1.r2.dt1.mm10.core.MASKED.LXS.mps.zip","Mm10"));
                maskFileList.add(new MaskDataFile("Mask File for ILS/ISS Mm10 Extended Transcripts", resourcesDir + "MoEx-1_0-st-v1.r2.dt1.mm10.extended.MASKED.LXS.mps.zip","Mm10"));
                maskFileList.add(new MaskDataFile("Mask File for ILS/ISS Mm10 Full Transcripts", resourcesDir + "MoEx-1_0-st-v1.r2.dt1.mm10.full.MASKED.LXS.mps.zip","Mm10"));
                maskFileList.add(new MaskDataFile("Mask File for ILS/ISS Mm10 All Probe sets", resourcesDir + "MoEx-1_0-st-v1.r2.dt1.mm10.all.MASKED.LXS.ps.zip","Mm10"));
                maskFileList.add(new MaskDataFile("Mask File for ILS/ISS Mm10 Core Probe sets", resourcesDir + "MoEx-1_0-st-v1.r2.dt1.mm10.core.MASKED.LXS.ps.zip","Mm10"));
                maskFileList.add(new MaskDataFile("Mask File for ILS/ISS Mm10 Extended Probe sets", resourcesDir + "MoEx-1_0-st-v1.r2.dt1.mm10.extended.MASKED.LXS.ps.zip","Mm10"));
		maskFileList.add(new MaskDataFile("Mask File for ILS/ISS Mm10 Full Probe sets", resourcesDir + "MoEx-1_0-st-v1.r2.dt1.mm10.full.MASKED.LXS.ps.zip","Mm10"));
                maskFileList.add(new MaskDataFile("PGF File for ILS/ISS Mm10", resourcesDir + "MoEx-1_0-st-v1.r2.mm10.MASKED.LXS.pgf.zip","Mm10"));
		MaskDataFile[] maskFileArray = myObjectHandler.getAsArray(maskFileList, MaskDataFile.class);
                
                resourceList.add(new Resource(707, "Mouse", LXSRI_PANEL, LXSRI_Dataset, "Whole Brain", myArray.MOUSE_EXON_ARRAY_TYPE,  expressionFileArray, eQTLFileArray, heritabilityFileArray,maskFileArray));


		// Setup the Inbred stuff
		resourcesDir =Inbred_Dataset.getResourcesDir();
        log.debug("mice"+resourcesDir);
                resourcesDir=resourcesDir.substring(resourcesDir.indexOf("/userFiles/"));
		datasetDir = Inbred_Dataset.getPath();

		expressionFileList = new ArrayList<ExpressionDataFile>();
		expressionFileList.add(new ExpressionDataFile("Normalized expression values", resourcesDir + "Inbred_v6_Affymetrix.Normalization.output.csv.zip","Mm10"));
		expressionFileList.add(new ExpressionDataFile("Raw Data - CEL Files, Part 1", resourcesDir + "PublicInbredMice_RawData_Part1.zip","N/A"));
		expressionFileList.add(new ExpressionDataFile("Raw Data - CEL Files, Part 2", resourcesDir + "PublicInbredMice_RawData_Part2.zip","N/A"));
		expressionFileArray = myObjectHandler.getAsArray(expressionFileList, ExpressionDataFile.class);

		eQTLFileList = new ArrayList<EQTLDataFile>();
		eQTLFileArray = myObjectHandler.getAsArray(eQTLFileList, EQTLDataFile.class);

		heritabilityFileList = new ArrayList<HeritabilityDataFile>();
		heritabilityFileList.add(new HeritabilityDataFile("Heritability file from RMA normalization plus probe mask", resourcesDir + "herits.Inbred.txt.zip","Mm10"));
		heritabilityFileArray = myObjectHandler.getAsArray(heritabilityFileList, HeritabilityDataFile.class);

                resourceList.add(new Resource(258, "Mouse", INBRED_PANEL, Inbred_Dataset, "Whole Brain", myArray.MOUSE430V2_ARRAY_TYPE,  expressionFileArray, eQTLFileArray, heritabilityFileArray,null));

		// Setup the HXBRI stuff
		resourcesDir = HXBRI_Dataset.getResourcesDir();
                resourcesDir=resourcesDir.substring(resourcesDir.indexOf("/userFiles/"));
		datasetDir = HXBRI_Dataset.getPath();

		expressionFileList = new ArrayList<ExpressionDataFile>();
		expressionFileList.add(new ExpressionDataFile("Normalized expression values", resourcesDir + "HXB_BXH_v6_CodeLink.Normalization.output.csv.zip","Rn5"));
		expressionFileList.add(new ExpressionDataFile("Raw Data - TXT Files", resourcesDir + "PublicHXB_BXHRIRats_RawData.zip","N/A"));
		expressionFileArray = myObjectHandler.getAsArray(expressionFileList, ExpressionDataFile.class);

		eQTLFileList = new ArrayList<EQTLDataFile>();
		eQTLFileList.add(new EQTLDataFile("eQTLs using STAR Consortium Markers", resourcesDir + "HXB_BXH_eQTL_STARConsortiumMarkers_07Oct09.txt.zip"));
		eQTLFileArray = myObjectHandler.getAsArray(eQTLFileList, EQTLDataFile.class);

		heritabilityFileList = new ArrayList<HeritabilityDataFile>();
		heritabilityFileList.add(new HeritabilityDataFile("Heritability file from RMA normalization plus probe mask", resourcesDir + "herits.HXB.txt.zip","Rn5"));
		heritabilityFileArray = myObjectHandler.getAsArray(heritabilityFileList, HeritabilityDataFile.class);

                resourceList.add(new Resource(261, "Rat", HXBRI_PANEL, HXBRI_Dataset, "Whole Brain", myArray.CODELINK_RAT_ARRAY_TYPE,  expressionFileArray, eQTLFileArray, heritabilityFileArray,null));

		// Setup the HXBRI Brain Exon stuff
		resourcesDir = HXBRI_Brain_Exon_Dataset.getResourcesDir();
        log.debug("HXBRIBrain:"+resourcesDir);
                resourcesDir=resourcesDir.substring(resourcesDir.indexOf("/userFiles/"));
		datasetDir = HXBRI_Brain_Exon_Dataset.getPath();

		expressionFileList = new ArrayList<ExpressionDataFile>();
                expressionFileList.add(new ExpressionDataFile("Normalized expression values and DABG p-values for Core Transcripts", resourcesDir + "HXB_BXH.brain_v7_Affymetrix.Normalization.output.csv.zip","Rn6"));
		expressionFileList.add(new ExpressionDataFile("Normalized expression values and DABG p-values for Full Transcripts", resourcesDir + "HXB_BXH.brain_v8_Affymetrix.Normalization.output.csv.zip","Rn6"));
                expressionFileList.add(new ExpressionDataFile("Normalized expression values and DABG p-values for Full Probesets", resourcesDir + "HXB_BXH.brain_v9_Affymetrix.Normalization.output.csv.zip","Rn6"));
		expressionFileList.add(new ExpressionDataFile("Core Transcripts Detection Above Background p-values", resourcesDir + "dabg.coreTrans.HXB_BXH.brain.rn6.PhenoGen.txt.zip","Rn6"));
		expressionFileList.add(new ExpressionDataFile("Core Transcripts Normalized expression values", resourcesDir + "rma.coreTrans.HXB_BXH.brain.rn6.PhenoGen.txt.zip","Rn6"));
		expressionFileList.add(new ExpressionDataFile("Full Transcripts Detection Above Background p-values", resourcesDir + "dabg.fullTrans.HXB_BXH.brain.rn6.PhenoGen.txt.zip","Rn6"));
		expressionFileList.add(new ExpressionDataFile("Full Transcripts Normalized expression values", resourcesDir + "rma.fullTrans.HXB_BXH.brain.rn6.PhenoGen.txt.zip","Rn6"));
                expressionFileList.add(new ExpressionDataFile("Full Probesets Detection Above Background p-values", resourcesDir + "dabg.fullPS.HXB_BXH.brain.rn6.PhenoGen.txt.zip","Rn6"));
		expressionFileList.add(new ExpressionDataFile("Full Probesets Normalized expression values", resourcesDir + "rma.fullPS.HXB_BXH.brain.rn6.PhenoGen.txt.zip","Rn6"));
		expressionFileList.add(new ExpressionDataFile("Normalized expression values and DABG p-values for Core Transcripts", resourcesDir + "HXB_BXH.brain_v4_Affymetrix.Normalization.output.csv.zip","Rn5"));
		expressionFileList.add(new ExpressionDataFile("Normalized expression values and DABG p-values for Full Transcripts", resourcesDir + "HXB_BXH.brain_v5_Affymetrix.Normalization.output.csv.zip","Rn5"));
                expressionFileList.add(new ExpressionDataFile("Normalized expression values and DABG p-values for Full Probesets", resourcesDir + "HXB_BXH.brain_v6_Affymetrix.Normalization.output.csv.zip","Rn5"));
		expressionFileList.add(new ExpressionDataFile("Core Transcripts Detection Above Background p-values", resourcesDir + "dabg.coreTrans.HXB_BXH.brain.rn5.PhenoGen.txt.zip","Rn5"));
		expressionFileList.add(new ExpressionDataFile("Core Transcripts Normalized expression values", resourcesDir + "rma.coreTrans.HXB_BXH.brain.rn5.PhenoGen.txt.zip","Rn5"));
		expressionFileList.add(new ExpressionDataFile("Full Transcripts Detection Above Background p-values", resourcesDir + "dabg.fullTrans.HXB_BXH.brain.rn5.PhenoGen.txt.zip","Rn5"));
		expressionFileList.add(new ExpressionDataFile("Full Transcripts Normalized expression values", resourcesDir + "rma.fullTrans.HXB_BXH.brain.rn5.PhenoGen.txt.zip","Rn5"));
                expressionFileList.add(new ExpressionDataFile("Full Probesets Detection Above Background p-values", resourcesDir + "dabg.fullPS.HXB_BXH.brain.rn5.PhenoGen.txt.zip","Rn5"));
		expressionFileList.add(new ExpressionDataFile("Full Probesets Normalized expression values", resourcesDir + "rma.fullPS.HXB_BXH.brain.rn5.PhenoGen.txt.zip","Rn5"));
                
		expressionFileList.add(new ExpressionDataFile("Raw Data - CEL Files, Part 1", resourcesDir + "PublicHXB_BXH.Brain.Exon.RawData_Part1.zip","N/A"));
		expressionFileList.add(new ExpressionDataFile("Raw Data - CEL Files, Part 2", resourcesDir + "PublicHXB_BXH.Brain.Exon.RawData_Part2.zip","N/A"));
		expressionFileList.add(new ExpressionDataFile("Raw Data - CEL Files, Part 3", resourcesDir + "PublicHXB_BXH.Brain.Exon.RawData_Part3.zip","N/A"));
		expressionFileList.add(new ExpressionDataFile("Raw Data - CEL Files, Part 4", resourcesDir + "PublicHXB_BXH.Brain.Exon.RawData_Part4.zip","N/A"));
		expressionFileArray = myObjectHandler.getAsArray(expressionFileList, ExpressionDataFile.class);

		eQTLFileList = new ArrayList<EQTLDataFile>();
		eQTLFileList.add(new EQTLDataFile("eQTLs for Core Transcripts in .csv format", resourcesDir + "HXB.BXH.eQTL.brain.coreTrans.rn5.31Jan13.csv.zip"));
		eQTLFileList.add(new EQTLDataFile("eQTLs for Core Transcripts in .txt format", resourcesDir + "HXB.BXH.eQTL.brain.coreTrans.rn5.31Jan13.txt.zip"));
                eQTLFileList.add(new EQTLDataFile("eQTLs for Full Probesets in .csv format", resourcesDir + "HXB.BXH.eQTL.brain.fullPS.rn5.12Feb13.csv.zip"));
		eQTLFileList.add(new EQTLDataFile("eQTLs for Full Probesets in .txt format", resourcesDir + "HXB.BXH.eQTL.brain.fullPS.rn5.12Feb13.txt.zip"));
		eQTLFileArray = myObjectHandler.getAsArray(eQTLFileList, EQTLDataFile.class);

		heritabilityFileList = new ArrayList<HeritabilityDataFile>();
                heritabilityFileList.add(new HeritabilityDataFile("Heritabilty File from Core Transcripts", resourcesDir + "herits.coreTrans.HXB_BXH.brain.rn6.txt.zip","Rn6"));
		heritabilityFileList.add(new HeritabilityDataFile("Heritabilty File from Full Transcripts", resourcesDir + "herits.fullTrans.HXB_BXH.brain.rn6.txt.zip","Rn6"));
		heritabilityFileList.add(new HeritabilityDataFile("Heritabilty File from Full Probesets", resourcesDir + "herits.fullPS.HXB_BXH.brain.rn6.txt.zip","Rn6"));
		heritabilityFileList.add(new HeritabilityDataFile("Heritabilty File from Core Transcripts", resourcesDir + "herits.coreTrans.HXB_BXH.brain.rn5.txt.zip","Rn5"));
		heritabilityFileList.add(new HeritabilityDataFile("Heritabilty File from Full Transcripts", resourcesDir + "herits.fullTrans.HXB_BXH.brain.rn5.txt.zip","Rn5"));
		heritabilityFileList.add(new HeritabilityDataFile("Heritabilty File from Full Probesets", resourcesDir + "herits.fullPS.HXB_BXH.brain.rn5.txt.zip","Rn5"));
                heritabilityFileArray = myObjectHandler.getAsArray(heritabilityFileList, HeritabilityDataFile.class);
                
                maskFileList = new ArrayList<MaskDataFile>();
		maskFileList.add(new MaskDataFile("Mask File for HXB Rn6 All Transcripts", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn6.all.MASKED.HXB.mps.zip","Rn6"));
		maskFileList.add(new MaskDataFile("Mask File for HXB Rn6 Core Transcripts", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn6.core.MASKED.HXB.mps.zip","Rn6"));
                maskFileList.add(new MaskDataFile("Mask File for HXB Rn6 Extended Transcripts", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn6.extended.MASKED.HXB.mps.zip","Rn6"));
                maskFileList.add(new MaskDataFile("Mask File for HXB Rn6 Full Transcripts", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn6.full.MASKED.HXB.mps.zip","Rn6"));
                maskFileList.add(new MaskDataFile("Mask File for HXB Rn6 All Probe sets", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn6.all.MASKED.HXB.ps.zip","Rn6"));
                maskFileList.add(new MaskDataFile("Mask File for HXB Rn6 Core Probe sets", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn6.core.MASKED.HXB.ps.zip","Rn6"));
                maskFileList.add(new MaskDataFile("Mask File for HXB Rn6 Extended Probe sets", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn6.extended.MASKED.HXB.ps.zip","Rn6"));
		maskFileList.add(new MaskDataFile("Mask File for HXB Rn6 Full Probe sets", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn6.full.MASKED.HXB.ps.zip","Rn6"));
                maskFileList.add(new MaskDataFile("PGF File for HXB Rn6", resourcesDir + "RaEx-1_0-st-v1.r2.rn6.MASKED.HXB.pgf.zip","Rn6"));
		maskFileList.add(new MaskDataFile("Mask File for HXB Rn5 All Transcripts", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn5.all.MASKED.HXB.mps.zip","Rn5"));
		maskFileList.add(new MaskDataFile("Mask File for HXB Rn5 Core Transcripts", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn5.core.MASKED.HXB.mps.zip","Rn5"));
                maskFileList.add(new MaskDataFile("Mask File for HXB Rn5 Extended Transcripts", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn5.extended.MASKED.HXB.mps.zip","Rn5"));
                maskFileList.add(new MaskDataFile("Mask File for HXB Rn5 Full Transcripts", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn5.full.MASKED.HXB.mps.zip","Rn5"));
                maskFileList.add(new MaskDataFile("Mask File for HXB Rn5 All Probe sets", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn5.all.MASKED.HXB.ps.zip","Rn5"));
                maskFileList.add(new MaskDataFile("Mask File for HXB Rn5 Core Probe sets", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn5.core.MASKED.HXB.ps.zip","Rn5"));
                maskFileList.add(new MaskDataFile("Mask File for HXB Rn5 Extended Probe sets", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn5.extended.MASKED.HXB.ps.zip","Rn5"));
		maskFileList.add(new MaskDataFile("Mask File for HXB Rn5 Full Probe sets", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn5.full.MASKED.HXB.ps.zip","Rn5"));
                maskFileList.add(new MaskDataFile("PGF File for HXB Rn5", resourcesDir + "RaEx-1_0-st-v1.r2.rn5.MASKED.HXB.pgf.zip","Rn5"));
		maskFileArray = myObjectHandler.getAsArray(maskFileList, MaskDataFile.class);

                resourceList.add(new Resource(730, "Rat", HXBRI_PANEL, HXBRI_Brain_Exon_Dataset, "Whole Brain", myArray.RAT_EXON_ARRAY_TYPE,  expressionFileArray, eQTLFileArray, heritabilityFileArray,maskFileArray));

		// Setup the HXBRI Heart Exon stuff
		resourcesDir = HXBRI_Heart_Exon_Dataset.getResourcesDir();
        log.debug("HXBRIHeart"+resourcesDir);
                resourcesDir=resourcesDir.substring(resourcesDir.indexOf("/userFiles/"));
		datasetDir = HXBRI_Heart_Exon_Dataset.getPath();

		expressionFileList = new ArrayList<ExpressionDataFile>();
                expressionFileList.add(new ExpressionDataFile("Normalized expression values and DABG p-values for Core Transcripts", resourcesDir + "HXB_BXH.heart_v7_Affymetrix.Normalization.output.csv.zip","Rn6"));
		expressionFileList.add(new ExpressionDataFile("Normalized expression values and DABG p-values for Full Transcripts", resourcesDir + "HXB_BXH.heart_v8_Affymetrix.Normalization.output.csv.zip","Rn6"));
		expressionFileList.add(new ExpressionDataFile("Normalized expression values and DABG p-values for Full Probesets", resourcesDir + "HXB_BXH.heart_v9_Affymetrix.Normalization.output.csv.zip","Rn6"));
                expressionFileList.add(new ExpressionDataFile("Core Transcripts Detection Above Background p-values", resourcesDir + "dabg.coreTrans.HXB_BXH.heart.rn6.PhenoGen.txt.zip","Rn6"));
		expressionFileList.add(new ExpressionDataFile("Core Transcripts Normalized expression values", resourcesDir + "rma.coreTrans.HXB_BXH.heart.rn6.PhenoGen.txt.zip","Rn6"));
		expressionFileList.add(new ExpressionDataFile("Full Transcripts Detection Above Background p-values", resourcesDir + "dabg.fullTrans.HXB_BXH.heart.rn6.PhenoGen.txt.zip","Rn6"));
		expressionFileList.add(new ExpressionDataFile("Full Transcripts Normalized expression values", resourcesDir + "rma.fullTrans.HXB_BXH.heart.rn6.PhenoGen.txt.zip","Rn6"));
		expressionFileList.add(new ExpressionDataFile("Full Probesets Detection Above Background p-values", resourcesDir + "dabg.fullPS.HXB_BXH.heart.rn6.PhenoGen.txt.zip","Rn6"));
		expressionFileList.add(new ExpressionDataFile("Full Probesets Normalized expression values", resourcesDir + "rma.fullPS.HXB_BXH.heart.rn6.PhenoGen.txt.zip","Rn6"));
		expressionFileList.add(new ExpressionDataFile("Normalized expression values and DABG p-values for Core Transcripts", resourcesDir + "HXB_BXH.heart_v4_Affymetrix.Normalization.output.csv.zip","Rn5"));
		expressionFileList.add(new ExpressionDataFile("Normalized expression values and DABG p-values for Full Transcripts", resourcesDir + "HXB_BXH.heart_v5_Affymetrix.Normalization.output.csv.zip","Rn5"));
		expressionFileList.add(new ExpressionDataFile("Normalized expression values and DABG p-values for Full Probesets", resourcesDir + "HXB_BXH.heart_v6_Affymetrix.Normalization.output.csv.zip","Rn5"));
                expressionFileList.add(new ExpressionDataFile("Core Transcripts Detection Above Background p-values", resourcesDir + "dabg.coreTrans.HXB_BXH.heart.rn5.PhenoGen.txt.zip","Rn5"));
		expressionFileList.add(new ExpressionDataFile("Core Transcripts Normalized expression values", resourcesDir + "rma.coreTrans.HXB_BXH.heart.rn5.PhenoGen.txt.zip","Rn5"));
		expressionFileList.add(new ExpressionDataFile("Full Transcripts Detection Above Background p-values", resourcesDir + "dabg.fullTrans.HXB_BXH.heart.rn5.PhenoGen.txt.zip","Rn5"));
		expressionFileList.add(new ExpressionDataFile("Full Transcripts Normalized expression values", resourcesDir + "rma.fullTrans.HXB_BXH.heart.rn5.PhenoGen.txt.zip","Rn5"));
		expressionFileList.add(new ExpressionDataFile("Full Probesets Detection Above Background p-values", resourcesDir + "dabg.fullPS.HXB_BXH.heart.rn5.PhenoGen.txt.zip","Rn5"));
		expressionFileList.add(new ExpressionDataFile("Full Probesets Normalized expression values", resourcesDir + "rma.fullPS.HXB_BXH.heart.rn5.PhenoGen.txt.zip","Rn5"));
                expressionFileList.add(new ExpressionDataFile("Raw Data - CEL Files, Part 1", resourcesDir + "PublicHXB_BXH.Heart.Exon.RawData_Part1.zip","N/A"));
		expressionFileList.add(new ExpressionDataFile("Raw Data - CEL Files, Part 2", resourcesDir + "PublicHXB_BXH.Heart.Exon.RawData_Part2.zip","N/A"));
		expressionFileList.add(new ExpressionDataFile("Raw Data - CEL Files, Part 3", resourcesDir + "PublicHXB_BXH.Heart.Exon.RawData_Part3.zip","N/A"));
		expressionFileList.add(new ExpressionDataFile("Raw Data - CEL Files, Part 4", resourcesDir + "PublicHXB_BXH.Heart.Exon.RawData_Part4.zip","N/A"));
		expressionFileArray = myObjectHandler.getAsArray(expressionFileList, ExpressionDataFile.class);

		//log.debug("csv file exists: "+new File(resourcesDir + "HXB.BXH.eQTL.brain.coreTrans.11Jan12.csv.zip").exists());
		//log.debug("txt file exists: "+new File(resourcesDir + "HXB.BXH.eQTL.brain.coreTrans.11Jan12.txt.zip").exists());

		eQTLFileList = new ArrayList<EQTLDataFile>();
		eQTLFileList.add(new EQTLDataFile("eQTLs for Core Transcripts in .csv format", resourcesDir + "HXB.BXH.eQTL.heart.coreTrans.rn5.31Jan13.csv.zip"));
		eQTLFileList.add(new EQTLDataFile("eQTLs for Core Transcripts in .txt format", resourcesDir + "HXB.BXH.eQTL.heart.coreTrans.rn5.31Jan13.txt.zip"));
                eQTLFileList.add(new EQTLDataFile("eQTLs for Full Probesets in .csv format", resourcesDir + "HXB.BXH.eQTL.heart.fullPS.rn5.12Feb13.csv.zip"));
		eQTLFileList.add(new EQTLDataFile("eQTLs for Full Probesets in .txt format", resourcesDir + "HXB.BXH.eQTL.heart.fullPS.rn5.12Feb13.txt.zip"));
		eQTLFileArray = myObjectHandler.getAsArray(eQTLFileList, EQTLDataFile.class);

		heritabilityFileList = new ArrayList<HeritabilityDataFile>();
                heritabilityFileList.add(new HeritabilityDataFile("Heritabilty File from Core Transcripts", resourcesDir + "herits.coreTrans.HXB_BXH.heart.rn6.txt.zip","Rn6"));
		heritabilityFileList.add(new HeritabilityDataFile("Heritabilty File from Full Transcripts", resourcesDir + "herits.fullTrans.HXB_BXH.heart.rn6.txt.zip","Rn6"));
                heritabilityFileList.add(new HeritabilityDataFile("Heritabilty File from Full Probesets", resourcesDir + "herits.fullPS.HXB_BXH.heart.rn6.txt.zip","Rn6"));
		heritabilityFileList.add(new HeritabilityDataFile("Heritabilty File from Core Transcripts", resourcesDir + "herits.coreTrans.HXB_BXH.heart.rn5.txt.zip","Rn5"));
		heritabilityFileList.add(new HeritabilityDataFile("Heritabilty File from Full Transcripts", resourcesDir + "herits.fullTrans.HXB_BXH.heart.rn5.txt.zip","Rn5"));
                heritabilityFileList.add(new HeritabilityDataFile("Heritabilty File from Full Probesets", resourcesDir + "herits.fullPS.HXB_BXH.heart.rn5.txt.zip","Rn5"));
		heritabilityFileArray = myObjectHandler.getAsArray(heritabilityFileList, HeritabilityDataFile.class);

                maskFileList = new ArrayList<MaskDataFile>();
		maskFileList.add(new MaskDataFile("Mask File for HXB Rn6 All Transcripts", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn6.all.MASKED.HXB.mps.zip","Rn6"));
		maskFileList.add(new MaskDataFile("Mask File for HXB Rn6 Core Transcripts", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn6.core.MASKED.HXB.mps.zip","Rn6"));
                maskFileList.add(new MaskDataFile("Mask File for HXB Rn6 Extended Transcripts", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn6.extended.MASKED.HXB.mps.zip","Rn6"));
                maskFileList.add(new MaskDataFile("Mask File for HXB Rn6 Full Transcripts", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn6.full.MASKED.HXB.mps.zip","Rn6"));
                maskFileList.add(new MaskDataFile("Mask File for HXB Rn6 All Probe sets", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn6.all.MASKED.HXB.ps.zip","Rn6"));
                maskFileList.add(new MaskDataFile("Mask File for HXB Rn6 Core Probe sets", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn6.core.MASKED.HXB.ps.zip","Rn6"));
                maskFileList.add(new MaskDataFile("Mask File for HXB Rn6 Extended Probe sets", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn6.extended.MASKED.HXB.ps.zip","Rn6"));
		maskFileList.add(new MaskDataFile("Mask File for HXB Rn6 Full Probe sets", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn6.full.MASKED.HXB.ps.zip","Rn6"));
                maskFileList.add(new MaskDataFile("PGF File for HXB Rn6", resourcesDir + "RaEx-1_0-st-v1.r2.rn6.MASKED.HXB.pgf.zip","Rn6"));
		maskFileList.add(new MaskDataFile("Mask File for HXB Rn5 All Transcripts", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn5.all.MASKED.HXB.mps.zip","Rn5"));
		maskFileList.add(new MaskDataFile("Mask File for HXB Rn5 Core Transcripts", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn5.core.MASKED.HXB.mps.zip","Rn5"));
                maskFileList.add(new MaskDataFile("Mask File for HXB Rn5 Extended Transcripts", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn5.extended.MASKED.HXB.mps.zip","Rn5"));
                maskFileList.add(new MaskDataFile("Mask File for HXB Rn5 Full Transcripts", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn5.full.MASKED.HXB.mps.zip","Rn5"));
                maskFileList.add(new MaskDataFile("Mask File for HXB Rn5 All Probe sets", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn5.all.MASKED.HXB.ps.zip","Rn5"));
                maskFileList.add(new MaskDataFile("Mask File for HXB Rn5 Core Probe sets", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn5.core.MASKED.HXB.ps.zip","Rn5"));
                maskFileList.add(new MaskDataFile("Mask File for HXB Rn5 Extended Probe sets", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn5.extended.MASKED.HXB.ps.zip","Rn5"));
		maskFileList.add(new MaskDataFile("Mask File for HXB Rn5 Full Probe sets", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn5.full.MASKED.HXB.ps.zip","Rn5"));
                maskFileList.add(new MaskDataFile("PGF File for HXB Rn5", resourcesDir + "RaEx-1_0-st-v1.r2.rn5.MASKED.HXB.pgf.zip","Rn5"));
                maskFileList.add(new MaskDataFile("PGF File for HXB Rn5", resourcesDir + "RaEx-1_0-st-v1.r2.rn5.MASKED.HXB.pgf.zip","Rn5"));
		maskFileArray = myObjectHandler.getAsArray(maskFileList, MaskDataFile.class);
                
                resourceList.add(new Resource(729, "Rat", HXBRI_PANEL, HXBRI_Heart_Exon_Dataset, "Heart", myArray.RAT_EXON_ARRAY_TYPE,  expressionFileArray, eQTLFileArray, heritabilityFileArray,maskFileArray));

		// Setup the HXBRI Liver Exon stuff
		resourcesDir = HXBRI_Liver_Exon_Dataset.getResourcesDir();
		log.debug("HXBRILiver"+resourcesDir);
		resourcesDir=resourcesDir.substring(resourcesDir.indexOf("/userFiles/"));

		datasetDir = HXBRI_Liver_Exon_Dataset.getPath();

		expressionFileList = new ArrayList<ExpressionDataFile>();
                expressionFileList.add(new ExpressionDataFile("Normalized expression values and DABG p-values for Core Transcripts", resourcesDir + "HXB_BXH.liver_v7_Affymetrix.Normalization.output.csv.zip","Rn6"));
		expressionFileList.add(new ExpressionDataFile("Normalized expression values and DABG p-values for Full Transcripts", resourcesDir + "HXB_BXH.liver_v8_Affymetrix.Normalization.output.csv.zip","Rn6"));
		expressionFileList.add(new ExpressionDataFile("Normalized expression values and DABG p-values for Full Probesets", resourcesDir + "HXB_BXH.liver_v9_Affymetrix.Normalization.output.csv.zip","Rn6"));
                expressionFileList.add(new ExpressionDataFile("Core Transcripts Detection Above Background p-values", resourcesDir + "dabg.coreTrans.HXB_BXH.liver.rn6.PhenoGen.txt.zip","Rn6"));
		expressionFileList.add(new ExpressionDataFile("Core Transcripts Normalized expression values", resourcesDir + "rma.coreTrans.HXB_BXH.liver.rn6.PhenoGen.txt.zip","Rn6"));
		expressionFileList.add(new ExpressionDataFile("Full Transcripts Detection Above Background p-values", resourcesDir + "dabg.fullTrans.HXB_BXH.liver.rn6.PhenoGen.txt.zip","Rn6"));
		expressionFileList.add(new ExpressionDataFile("Full Transcripts Normalized expression values", resourcesDir + "rma.fullTrans.HXB_BXH.liver.rn6.PhenoGen.txt.zip","Rn6"));
		expressionFileList.add(new ExpressionDataFile("Full Probesets Detection Above Background p-values", resourcesDir + "dabg.fullPS.HXB_BXH.liver.rn6.PhenoGen.txt.zip","Rn6"));
		expressionFileList.add(new ExpressionDataFile("Full Probesets Normalized expression values", resourcesDir + "rma.fullPS.HXB_BXH.liver.rn6.PhenoGen.txt.zip","Rn6"));
		expressionFileList.add(new ExpressionDataFile("Normalized expression values and DABG p-values for Core Transcripts", resourcesDir + "HXB_BXH.liver_v4_Affymetrix.Normalization.output.csv.zip","Rn5"));
		expressionFileList.add(new ExpressionDataFile("Normalized expression values and DABG p-values for Full Transcripts", resourcesDir + "HXB_BXH.liver_v5_Affymetrix.Normalization.output.csv.zip","Rn5"));
		expressionFileList.add(new ExpressionDataFile("Normalized expression values and DABG p-values for Full Probesets", resourcesDir + "HXB_BXH.liver_v6_Affymetrix.Normalization.output.csv.zip","Rn5"));
                expressionFileList.add(new ExpressionDataFile("Core Transcripts Detection Above Background p-values", resourcesDir + "dabg.coreTrans.HXB_BXH.liver.rn5.PhenoGen.txt.zip","Rn5"));
		expressionFileList.add(new ExpressionDataFile("Core Transcripts Normalized expression values", resourcesDir + "rma.coreTrans.HXB_BXH.liver.rn5.PhenoGen.txt.zip","Rn5"));
		expressionFileList.add(new ExpressionDataFile("Full Transcripts Detection Above Background p-values", resourcesDir + "dabg.fullTrans.HXB_BXH.liver.rn5.PhenoGen.txt.zip","Rn5"));
		expressionFileList.add(new ExpressionDataFile("Full Transcripts Normalized expression values", resourcesDir + "rma.fullTrans.HXB_BXH.liver.rn5.PhenoGen.txt.zip","Rn5"));
		expressionFileList.add(new ExpressionDataFile("Full Probesets Detection Above Background p-values", resourcesDir + "dabg.fullPS.HXB_BXH.liver.rn5.PhenoGen.txt.zip","Rn5"));
		expressionFileList.add(new ExpressionDataFile("Full Probesets Normalized expression values", resourcesDir + "rma.fullPS.HXB_BXH.liver.rn5.PhenoGen.txt.zip","Rn5"));
                expressionFileList.add(new ExpressionDataFile("Raw Data - CEL Files, Part 1", resourcesDir + "PublicHXB_BXH.Liver.Exon.RawData_Part1.zip","N/A"));
		expressionFileList.add(new ExpressionDataFile("Raw Data - CEL Files, Part 2", resourcesDir + "PublicHXB_BXH.Liver.Exon.RawData_Part2.zip","N/A"));
		expressionFileList.add(new ExpressionDataFile("Raw Data - CEL Files, Part 3", resourcesDir + "PublicHXB_BXH.Liver.Exon.RawData_Part3.zip","N/A"));
		expressionFileList.add(new ExpressionDataFile("Raw Data - CEL Files, Part 4", resourcesDir + "PublicHXB_BXH.Liver.Exon.RawData_Part4.zip","N/A"));
		expressionFileArray = myObjectHandler.getAsArray(expressionFileList, ExpressionDataFile.class);

		eQTLFileList = new ArrayList<EQTLDataFile>();
		eQTLFileList.add(new EQTLDataFile("eQTLs for Core Transcripts in .csv format", resourcesDir + "HXB.BXH.eQTL.liver.coreTrans.rn5.31Jan13.csv.zip"));
		eQTLFileList.add(new EQTLDataFile("eQTLs for Core Transcripts in .txt format", resourcesDir + "HXB.BXH.eQTL.liver.coreTrans.rn5.31Jan13.txt.zip"));
                eQTLFileList.add(new EQTLDataFile("eQTLs for Full Probesets in .csv format", resourcesDir + "HXB.BXH.eQTL.liver.fullPS.rn5.08Feb13.csv.zip"));
		eQTLFileList.add(new EQTLDataFile("eQTLs for Full Probesets in .txt format", resourcesDir + "HXB.BXH.eQTL.liver.fullPS.rn5.08Feb13.txt.zip"));
		eQTLFileArray = myObjectHandler.getAsArray(eQTLFileList, EQTLDataFile.class);

		heritabilityFileList = new ArrayList<HeritabilityDataFile>();
                heritabilityFileList.add(new HeritabilityDataFile("Heritabilty File from Core Transcripts", resourcesDir + "herits.coreTrans.HXB_BXH.liver.rn6.txt.zip","Rn6"));
		heritabilityFileList.add(new HeritabilityDataFile("Heritabilty File from Full Transcripts", resourcesDir + "herits.fullTrans.HXB_BXH.liver.rn6.txt.zip","Rn6"));
                heritabilityFileList.add(new HeritabilityDataFile("Heritabilty File from Full Probesets", resourcesDir + "herits.fullPS.HXB_BXH.liver.rn6.txt.zip","Rn6"));
		heritabilityFileList.add(new HeritabilityDataFile("Heritabilty File from Core Transcripts", resourcesDir + "herits.coreTrans.HXB_BXH.liver.rn5.txt.zip","Rn5"));
		heritabilityFileList.add(new HeritabilityDataFile("Heritabilty File from Full Transcripts", resourcesDir + "herits.fullTrans.HXB_BXH.liver.rn5.txt.zip","Rn5"));
                heritabilityFileList.add(new HeritabilityDataFile("Heritabilty File from Full Probesets", resourcesDir + "herits.fullPS.HXB_BXH.liver.rn5.txt.zip","Rn5"));
		heritabilityFileArray = myObjectHandler.getAsArray(heritabilityFileList, HeritabilityDataFile.class);

                maskFileList = new ArrayList<MaskDataFile>();
		maskFileList.add(new MaskDataFile("Mask File for HXB Rn6 All Transcripts", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn6.all.MASKED.HXB.mps.zip","Rn6"));
		maskFileList.add(new MaskDataFile("Mask File for HXB Rn6 Core Transcripts", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn6.core.MASKED.HXB.mps.zip","Rn6"));
                maskFileList.add(new MaskDataFile("Mask File for HXB Rn6 Extended Transcripts", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn6.extended.MASKED.HXB.mps.zip","Rn6"));
                maskFileList.add(new MaskDataFile("Mask File for HXB Rn6 Full Transcripts", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn6.full.MASKED.HXB.mps.zip","Rn6"));
                maskFileList.add(new MaskDataFile("Mask File for HXB Rn6 All Probe sets", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn6.all.MASKED.HXB.ps.zip","Rn6"));
                maskFileList.add(new MaskDataFile("Mask File for HXB Rn6 Core Probe sets", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn6.core.MASKED.HXB.ps.zip","Rn6"));
                maskFileList.add(new MaskDataFile("Mask File for HXB Rn6 Extended Probe sets", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn6.extended.MASKED.HXB.ps.zip","Rn6"));
		maskFileList.add(new MaskDataFile("Mask File for HXB Rn6 Full Probe sets", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn6.full.MASKED.HXB.ps.zip","Rn6"));
                maskFileList.add(new MaskDataFile("PGF File for HXB Rn6", resourcesDir + "RaEx-1_0-st-v1.r2.rn6.MASKED.HXB.pgf.zip","Rn6"));
		maskFileList.add(new MaskDataFile("Mask File for HXB Rn5 All Transcripts", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn5.all.MASKED.HXB.mps.zip","Rn5"));
		maskFileList.add(new MaskDataFile("Mask File for HXB Rn5 Core Transcripts", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn5.core.MASKED.HXB.mps.zip","Rn5"));
                maskFileList.add(new MaskDataFile("Mask File for HXB Rn5 Extended Transcripts", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn5.extended.MASKED.HXB.mps.zip","Rn5"));
                maskFileList.add(new MaskDataFile("Mask File for HXB Rn5 Full Transcripts", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn5.full.MASKED.HXB.mps.zip","Rn5"));
                maskFileList.add(new MaskDataFile("Mask File for HXB Rn5 All Probe sets", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn5.all.MASKED.HXB.ps.zip","Rn5"));
                maskFileList.add(new MaskDataFile("Mask File for HXB Rn5 Core Probe sets", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn5.core.MASKED.HXB.ps.zip","Rn5"));
                maskFileList.add(new MaskDataFile("Mask File for HXB Rn5 Extended Probe sets", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn5.extended.MASKED.HXB.ps.zip","Rn5"));
		maskFileList.add(new MaskDataFile("Mask File for HXB Rn5 Full Probe sets", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn5.full.MASKED.HXB.ps.zip","Rn5"));
                maskFileList.add(new MaskDataFile("PGF File for HXB Rn5", resourcesDir + "RaEx-1_0-st-v1.r2.rn5.MASKED.HXB.pgf.zip","Rn5"));
		maskFileArray = myObjectHandler.getAsArray(maskFileList, MaskDataFile.class);
                
                resourceList.add(new Resource(727, "Rat", HXBRI_PANEL, HXBRI_Liver_Exon_Dataset, "Liver", myArray.RAT_EXON_ARRAY_TYPE,  expressionFileArray, eQTLFileArray, heritabilityFileArray,maskFileArray));

		// Setup the HXBRI Brown Adipose Exon stuff
		resourcesDir = HXBRI_Brown_Adipose_Exon_Dataset.getResourcesDir();
        log.debug("HXBRIBAT"+resourcesDir);
                resourcesDir=resourcesDir.substring(resourcesDir.indexOf("/userFiles/"));
		datasetDir = HXBRI_Brown_Adipose_Exon_Dataset.getPath();

		expressionFileList = new ArrayList<ExpressionDataFile>();
                expressionFileList.add(new ExpressionDataFile("Normalized expression values and DABG p-values for Core Transcripts", resourcesDir + "HXB_BXH.bat_v7_Affymetrix.Normalization.output.csv.zip","Rn6"));
		expressionFileList.add(new ExpressionDataFile("Normalized expression values and DABG p-values for Full Transcripts", resourcesDir + "HXB_BXH.bat_v8_Affymetrix.Normalization.output.csv.zip","Rn6"));
                expressionFileList.add(new ExpressionDataFile("Normalized expression values and DABG p-values for Full Probesets", resourcesDir + "HXB_BXH.bat_v9_Affymetrix.Normalization.output.csv.zip","Rn6"));
		expressionFileList.add(new ExpressionDataFile("Core Transcripts Detection Above Background p-values", resourcesDir + "dabg.coreTrans.HXB_BXH.BAT.rn6.PhenoGen.txt.zip","Rn6"));
		expressionFileList.add(new ExpressionDataFile("Core Transcripts Normalized expression values", resourcesDir + "rma.coreTrans.HXB_BXH.BAT.rn6.PhenoGen.txt.zip","Rn6"));
		expressionFileList.add(new ExpressionDataFile("Full Transcripts Detection Above Background p-values", resourcesDir + "dabg.fullTrans.HXB_BXH.BAT.rn6.PhenoGen.txt.zip","Rn6"));
		expressionFileList.add(new ExpressionDataFile("Full Transcripts Normalized expression values", resourcesDir + "rma.fullTrans.HXB_BXH.BAT.rn6.PhenoGen.txt.zip","Rn6"));
                expressionFileList.add(new ExpressionDataFile("Full Probesets Detection Above Background p-values", resourcesDir + "dabg.fullPS.HXB_BXH.BAT.rn6.PhenoGen.txt.zip","Rn6"));
		expressionFileList.add(new ExpressionDataFile("Full Probesets Normalized expression values", resourcesDir + "rma.fullPS.HXB_BXH.BAT.rn6.PhenoGen.txt.zip","Rn6"));
		expressionFileList.add(new ExpressionDataFile("Normalized expression values and DABG p-values for Core Transcripts", resourcesDir + "HXB_BXH.bat_v4_Affymetrix.Normalization.output.csv.zip","Rn5"));
		expressionFileList.add(new ExpressionDataFile("Normalized expression values and DABG p-values for Full Transcripts", resourcesDir + "HXB_BXH.bat_v5_Affymetrix.Normalization.output.csv.zip","Rn5"));
                expressionFileList.add(new ExpressionDataFile("Normalized expression values and DABG p-values for Full Probesets", resourcesDir + "HXB_BXH.bat_v6_Affymetrix.Normalization.output.csv.zip","Rn5"));
		expressionFileList.add(new ExpressionDataFile("Core Transcripts Detection Above Background p-values", resourcesDir + "dabg.coreTrans.HXB_BXH.BAT.rn5.PhenoGen.txt.zip","Rn5"));
		expressionFileList.add(new ExpressionDataFile("Core Transcripts Normalized expression values", resourcesDir + "rma.coreTrans.HXB_BXH.BAT.rn5.PhenoGen.txt.zip","Rn5"));
		expressionFileList.add(new ExpressionDataFile("Full Transcripts Detection Above Background p-values", resourcesDir + "dabg.fullTrans.HXB_BXH.BAT.rn5.PhenoGen.txt.zip","Rn5"));
		expressionFileList.add(new ExpressionDataFile("Full Transcripts Normalized expression values", resourcesDir + "rma.fullTrans.HXB_BXH.BAT.rn5.PhenoGen.txt.zip","Rn5"));
                expressionFileList.add(new ExpressionDataFile("Full Probesets Detection Above Background p-values", resourcesDir + "dabg.fullPS.HXB_BXH.BAT.rn5.PhenoGen.txt.zip","Rn5"));
		expressionFileList.add(new ExpressionDataFile("Full Probesets Normalized expression values", resourcesDir + "rma.fullPS.HXB_BXH.BAT.rn5.PhenoGen.txt.zip","Rn5"));
		expressionFileList.add(new ExpressionDataFile("Raw Data - CEL Files, Part 1", resourcesDir + "PublicHXB_BXH.BrownAdipose.Exon.RawData_Part1.zip","N/A"));
		expressionFileList.add(new ExpressionDataFile("Raw Data - CEL Files, Part 2", resourcesDir + "PublicHXB_BXH.BrownAdipose.Exon.RawData_Part2.zip","N/A"));
		expressionFileList.add(new ExpressionDataFile("Raw Data - CEL Files, Part 3", resourcesDir + "PublicHXB_BXH.BrownAdipose.Exon.RawData_Part3.zip","N/A"));
		expressionFileList.add(new ExpressionDataFile("Raw Data - CEL Files, Part 4", resourcesDir + "PublicHXB_BXH.BrownAdipose.Exon.RawData_Part4.zip","N/A"));
		expressionFileArray = myObjectHandler.getAsArray(expressionFileList, ExpressionDataFile.class);

		eQTLFileList = new ArrayList<EQTLDataFile>();
		eQTLFileList.add(new EQTLDataFile("eQTLs for Core Transcripts in .csv format", resourcesDir + "HXB.BXH.eQTL.BAT.coreTrans.rn5.31Jan13.csv.zip"));
		eQTLFileList.add(new EQTLDataFile("eQTLs for Core Transcripts in .txt format", resourcesDir + "HXB.BXH.eQTL.BAT.coreTrans.rn5.31Jan13.txt.zip"));
                eQTLFileList.add(new EQTLDataFile("eQTLs for Full Probesets in .csv format", resourcesDir + "HXB.BXH.eQTL.BAT.fullPS.rn5.13Feb13.csv.zip"));
		eQTLFileList.add(new EQTLDataFile("eQTLs for Full Probesets in .txt format", resourcesDir + "HXB.BXH.eQTL.BAT.fullPS.rn5.13Feb13.csv.zip"));
		eQTLFileArray = myObjectHandler.getAsArray(eQTLFileList, EQTLDataFile.class);

		heritabilityFileList = new ArrayList<HeritabilityDataFile>();
                heritabilityFileList.add(new HeritabilityDataFile("Heritabilty File from Core Transcripts", resourcesDir + "herits.coreTrans.HXB_BXH.bat.rn6.txt.zip","Rn6"));
		heritabilityFileList.add(new HeritabilityDataFile("Heritabilty File from Full Transcripts", resourcesDir + "herits.fullTrans.HXB_BXH.bat.rn6.txt.zip","Rn6"));
                heritabilityFileList.add(new HeritabilityDataFile("Heritabilty File from Full Probesets", resourcesDir + "herits.fullPS.HXB_BXH.bat.rn6.txt.zip","Rn6"));
		heritabilityFileList.add(new HeritabilityDataFile("Heritabilty File from Core Transcripts", resourcesDir + "herits.coreTrans.HXB_BXH.BAT.rn5.txt.zip","Rn5"));
		heritabilityFileList.add(new HeritabilityDataFile("Heritabilty File from Full Transcripts", resourcesDir + "herits.fullTrans.HXB_BXH.BAT.rn5.txt.zip","Rn5"));
                heritabilityFileList.add(new HeritabilityDataFile("Heritabilty File from Full Probesets", resourcesDir + "herits.fullPS.HXB_BXH.BAT.rn5.txt.zip","Rn5"));
		heritabilityFileArray = myObjectHandler.getAsArray(heritabilityFileList, HeritabilityDataFile.class);

                maskFileList = new ArrayList<MaskDataFile>();
                maskFileList.add(new MaskDataFile("Mask File for HXB Rn6 All Transcripts", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn6.all.MASKED.HXB.mps.zip","Rn6"));
		maskFileList.add(new MaskDataFile("Mask File for HXB Rn6 Core Transcripts", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn6.core.MASKED.HXB.mps.zip","Rn6"));
                maskFileList.add(new MaskDataFile("Mask File for HXB Rn6 Extended Transcripts", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn6.extended.MASKED.HXB.mps.zip","Rn6"));
                maskFileList.add(new MaskDataFile("Mask File for HXB Rn6 Full Transcripts", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn6.full.MASKED.HXB.mps.zip","Rn6"));
                maskFileList.add(new MaskDataFile("Mask File for HXB Rn6 All Probe sets", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn6.all.MASKED.HXB.ps.zip","Rn6"));
                maskFileList.add(new MaskDataFile("Mask File for HXB Rn6 Core Probe sets", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn6.core.MASKED.HXB.ps.zip","Rn6"));
                maskFileList.add(new MaskDataFile("Mask File for HXB Rn6 Extended Probe sets", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn6.extended.MASKED.HXB.ps.zip","Rn6"));
		maskFileList.add(new MaskDataFile("Mask File for HXB Rn6 Full Probe sets", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn6.full.MASKED.HXB.ps.zip","Rn6"));
                maskFileList.add(new MaskDataFile("PGF File for HXB Rn6", resourcesDir + "RaEx-1_0-st-v1.r2.rn6.MASKED.HXB.pgf.zip","Rn6"));
		maskFileList.add(new MaskDataFile("Mask File for HXB Rn5 All Transcripts", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn5.all.MASKED.HXB.mps.zip","Rn5"));
		maskFileList.add(new MaskDataFile("Mask File for HXB Rn5 Core Transcripts", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn5.core.MASKED.HXB.mps.zip","Rn5"));
                maskFileList.add(new MaskDataFile("Mask File for HXB Rn5 Extended Transcripts", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn5.extended.MASKED.HXB.mps.zip","Rn5"));
                maskFileList.add(new MaskDataFile("Mask File for HXB Rn5 Full Transcripts", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn5.full.MASKED.HXB.mps.zip","Rn5"));
                maskFileList.add(new MaskDataFile("Mask File for HXB Rn5 All Probe sets", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn5.all.MASKED.HXB.ps.zip","Rn5"));
                maskFileList.add(new MaskDataFile("Mask File for HXB Rn5 Core Probe sets", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn5.core.MASKED.HXB.ps.zip","Rn5"));
                maskFileList.add(new MaskDataFile("Mask File for HXB Rn5 Extended Probe sets", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn5.extended.MASKED.HXB.ps.zip","Rn5"));
		maskFileList.add(new MaskDataFile("Mask File for HXB Rn5 Full Probe sets", resourcesDir + "RaEx-1_0-st-v1.r2.dt1.rn5.full.MASKED.HXB.ps.zip","Rn5"));
                maskFileList.add(new MaskDataFile("PGF File for HXB Rn5", resourcesDir + "RaEx-1_0-st-v1.r2.rn5.MASKED.HXB.pgf.zip","Rn5"));
		maskFileArray = myObjectHandler.getAsArray(maskFileList, MaskDataFile.class);
                
                resourceList.add(new Resource(760, "Rat", HXBRI_PANEL, HXBRI_Brown_Adipose_Exon_Dataset, "Brown Adipose", myArray.RAT_EXON_ARRAY_TYPE,  expressionFileArray, eQTLFileArray, heritabilityFileArray,maskFileArray));

		Resource[] resourceArray = myObjectHandler.getAsArray(resourceList, Resource.class);
		return resourceArray;
	}

	/**
	 * Gets all the genomic marker resources
	 * @return	an array of Resource objects
	 */
	public Resource[] getMarkerResources() {
		log.debug("in getMarkerResources");
		List<Resource> resourceList = new ArrayList<Resource>();
		log.debug("publicDatasets has " + publicDatasets.length + " entries");

        	Dataset myDataset = new Dataset();
        	Dataset BXDRI_Dataset = myDataset.getDatasetFromMyDatasets(publicDatasets, myDataset.BXDRI_DATASET_NAME);
        	Dataset HXBRI_Dataset = myDataset.getDatasetFromMyDatasets(publicDatasets, myDataset.HXBRI_DATASET_NAME);
        	Dataset LXSRI_Dataset = myDataset.getDatasetFromMyDatasets(publicDatasets, myDataset.LXSRI_DATASET_NAME);

        String markerFilePath="/downloads/Markers/";
        List<MarkerDataFile> markerFileList = new ArrayList<MarkerDataFile>();
        markerFileList.add(new MarkerDataFile("HRDPv4 Markers", markerFilePath + "HRDP_v4_Markers.txt","HRDPv4"));
        MarkerDataFile[] markerFileArray = myObjectHandler.getAsArray(markerFileList, MarkerDataFile.class);

        EQTLDataFile[] eQTLFileArray = new EQTLDataFile[0];

        resourceList.add(new Resource(13, "Rat", "<a href='http://oct2012.archive.ensembl.org/Rattus_norvegicus/Info/Content?file=star.html' target='_blank'>STAR consortium</a>", null, markerFileArray,eQTLFileArray,"HRDPv4"));

        // Setup the HXBRI stuff
        String resourcesDir = HXBRI_Dataset.getResourcesDir();
        resourcesDir=resourcesDir.substring(resourcesDir.indexOf("/userFiles/"));

        String datasetDir = HXBRI_Dataset.getPath();
        markerFileList = new ArrayList<MarkerDataFile>();
        markerFileList.add(new MarkerDataFile("HXB Markers", resourcesDir + "HXB_BXH_Markers.txt.zip","HXB/BXH"));
        markerFileArray = myObjectHandler.getAsArray(markerFileList, MarkerDataFile.class);

        List<EQTLDataFile> eQTLFileList = new ArrayList<EQTLDataFile>();
        eQTLFileList.add(new EQTLDataFile("eQTLs using STAR Consortium Markers", resourcesDir + "HXB_BXH_eQTL_STARConsortiumMarkers_07Oct09.txt.zip"));
        eQTLFileArray = myObjectHandler.getAsArray(eQTLFileList, EQTLDataFile.class);

        resourceList.add(new Resource(12, "Rat", "<a href='http://oct2012.archive.ensembl.org/Rattus_norvegicus/Info/Content?file=star.html' target='_blank'>STAR consortium</a>", HXBRI_Dataset, markerFileArray, eQTLFileArray,"HXB/BXH"));

		// Setup the BXDRI stuff
		resourcesDir = BXDRI_Dataset.getResourcesDir();
        log.debug("BXD:"+resourcesDir);
                resourcesDir=resourcesDir.substring(resourcesDir.indexOf("/userFiles/"));
		datasetDir = BXDRI_Dataset.getPath();

        markerFileList = new ArrayList<MarkerDataFile>();
		markerFileList.add(new MarkerDataFile("BXD Markers", resourcesDir + "BXD_Markers.zip","BXD"));
		markerFileArray = myObjectHandler.getAsArray(markerFileList, MarkerDataFile.class);

		eQTLFileList = new ArrayList<EQTLDataFile>();
		eQTLFileList.add(new EQTLDataFile("eQTLs using Wellcome Trust Markers", resourcesDir + "BXD_eQTL_WellcomeTrustMarkers_16Apr12.csv.zip"));
		eQTLFileArray = myObjectHandler.getAsArray(eQTLFileList, EQTLDataFile.class);

                resourceList.add(new Resource(10, "Mouse", "<a href='http://www.well.ox.ac.uk/mouse/INBREDS' target='_blank'>Wellcome-CTC Mouse Strain SNP Genotype Set</a>", BXDRI_Dataset, markerFileArray, eQTLFileArray,"BXD"));
//Wellcome-CTC Mouse Strain SNP Genotype Set (http://www.well.ox.ac.uk/mouse/INBREDS/)

		// Setup the LXSRI stuff
		resourcesDir = LXSRI_Dataset.getResourcesDir();
                resourcesDir=resourcesDir.substring(resourcesDir.indexOf("/userFiles/"));
		datasetDir = LXSRI_Dataset.getPath();

		markerFileList = new ArrayList<MarkerDataFile>();
		markerFileList.add(new MarkerDataFile("SNP information on the LXS RI panel was collected by Dr. Gary Churchill and colleagues at the Jackson "+
					"Laboratory using the Affymetrix Mouse Diversity Genotyping array.  This information was gathered with funding from NIH "+
					"grants (GM0706833 and AG0038070).", resourcesDir + "LXS.markers.mm10.txt.zip","LXS"));
		markerFileArray = myObjectHandler.getAsArray(markerFileList, MarkerDataFile.class);

		eQTLFileList = new ArrayList<EQTLDataFile>();
		eQTLFileList.add(new EQTLDataFile("eQTLs for Core Transcripts from the Affymetrix Mouse Diversity SNP Array", resourcesDir + "LXS.eQTL.coreTrans.mm10.11Nov13.txt.zip"));
		eQTLFileArray = myObjectHandler.getAsArray(eQTLFileList, EQTLDataFile.class);

                resourceList.add(new Resource(11, "Mouse", "Affymetrix Mouse Diversity SNP Array", LXSRI_Dataset, markerFileArray, eQTLFileArray,"LXS"));



		Resource[] resourceArray = myObjectHandler.getAsArray(resourceList, Resource.class);
		return resourceArray;
	}
        
        /**
	 * Gets all the RNA Seq resources
	 * @return	an array of Resource objects
	 */
	public Resource[] getRNASeqResources() {
		log.debug("in getRNASeqResources");
		String seqFilePath="/downloads/RNASeq/";
		List<Resource> resourceList = new ArrayList<Resource>();



                
                SAMDataFile[] bnlxFileList = new SAMDataFile[4];
                bnlxFileList[0]=new SAMDataFile("BN-Lx Aligned BAM File",seqFilePath+"Aligned/rn6/BNLx.rn6.Brain.polyA.bam","Rn6");
                bnlxFileList[1]=new SAMDataFile("BN-Lx Sample #1 Aligned BAM File",seqFilePath+"Aligned/PolyA/BNLx1.polyA.bam","Rn5");
                bnlxFileList[2]=new SAMDataFile("BN-Lx Sample #2 Aligned BAM File",seqFilePath+"Aligned/PolyA/BNLx2.polyA.bam","Rn5");
                bnlxFileList[3]=new SAMDataFile("BN-Lx Sample #3 Aligned BAM File",seqFilePath+"Aligned/PolyA/BNLx3.polyA.bam","Rn5");
                resourceList.add(new Resource(50, "Rat", "BN-Lx/CubPrin","polyA+ (>200 nt) selected","Brain","Illumina HiSeq2000","100 bp paired-end", bnlxFileList,"Rn6, Rn5" ));
        	
                SAMDataFile[] shrhFileList = new SAMDataFile[4];
                shrhFileList[0]=new SAMDataFile("SHR Aligned BAM File",seqFilePath+"Aligned/rn6/SHR.rn6.Brain.polyA.bam","Rn6");
                shrhFileList[1]=new SAMDataFile("SHR Sample #1 Aligned BAM File",seqFilePath+"Aligned/PolyA/SHR1.polyA.bam","Rn5");
                shrhFileList[2]=new SAMDataFile("SHR Sample #2 Aligned BAM File",seqFilePath+"Aligned/PolyA/SHR2.polyA.bam","Rn5");
                shrhFileList[3]=new SAMDataFile("SHR Sample #3 Aligned BAM File",seqFilePath+"Aligned/PolyA/SHR3.polyA.bam","Rn5");
                resourceList.add(new Resource(51, "Rat", "SHR/OlaIpcvPrin","polyA+ (>200 nt) selected","Brain","Illumina HiSeq2000","100 bp paired-end", shrhFileList,"Rn6, Rn5" ));
                
                bnlxFileList = new SAMDataFile[4];
                bnlxFileList[0]=new SAMDataFile("BN-Lx Aligned BAM File",seqFilePath+"Aligned/rn6/BNLx.rn6.Brain.totalRNA.bam","Rn6");
                bnlxFileList[1]=new SAMDataFile("BN-Lx Sample #1 Aligned BAM File",seqFilePath+"Aligned/Total/BNLx1.totalRNA.bam","Rn5");
                bnlxFileList[2]=new SAMDataFile("BN-Lx Sample #2 Aligned BAM File",seqFilePath+"Aligned/Total/BNLx2.totalRNA.bam","Rn5");
                bnlxFileList[3]=new SAMDataFile("BN-Lx Sample #3 Aligned BAM File",seqFilePath+"Aligned/Total/BNLx3.totalRNA.bam","Rn5");
                resourceList.add(new Resource(54, "Rat", "BN-Lx/CubPrin","total RNA (>200 nt) after ribosomal RNA depletion","Brain","Illumina HiSeq2000","100 bp paired-end", bnlxFileList,"Rn6, Rn5" ));
        	
                shrhFileList = new SAMDataFile[4];
                shrhFileList[0]=new SAMDataFile("SHR Aligned BAM File",seqFilePath+"Aligned/rn6/SHR.rn6.Brain.totalRNA.bam","Rn6");
                shrhFileList[1]=new SAMDataFile("SHR Sample #1 Aligned BAM File",seqFilePath+"Aligned/Total/SHR1.totalRNA.bam","Rn5");
                shrhFileList[2]=new SAMDataFile("SHR Sample #2 Aligned BAM File",seqFilePath+"Aligned/Total/SHR2.totalRNA.bam","Rn5");
                shrhFileList[3]=new SAMDataFile("SHR Sample #3 Aligned BAM File",seqFilePath+"Aligned/Total/SHR3.totalRNA.bam","Rn5");
                resourceList.add(new Resource(55, "Rat", "SHR/OlaIpcvPrin","total RNA (>200 nt) after ribosomal RNA depletion","Brain","Illumina HiSeq2000","100 bp paired-end", shrhFileList,"Rn6, Rn5" ));
                
                bnlxFileList = new SAMDataFile[3];
                bnlxFileList[0]=new SAMDataFile("BN-Lx Sample #1 Aligned BAM File",seqFilePath+"Aligned/Small/BNLx1.smRNA.bam","Rn5");
                bnlxFileList[1]=new SAMDataFile("BN-Lx Sample #2 Aligned BAM File",seqFilePath+"Aligned/Small/BNLx2.smRNA.bam","Rn5");
                bnlxFileList[2]=new SAMDataFile("BN-Lx Sample #3 Aligned BAM File",seqFilePath+"Aligned/Small/BNLx3.smRNA.bam","Rn5");
                resourceList.add(new Resource(56, "Rat", "BN-Lx/CubPrin","small RNA (<200 nt) selected","Brain","Illumina HiSeq2000","50 bp single-end", bnlxFileList,"Rn5" ));
        	
                shrhFileList = new SAMDataFile[3];
                shrhFileList[0]=new SAMDataFile("SHR Sample #1 Aligned BAM File",seqFilePath+"Aligned/Small/SHR1.smRNA.bam","Rn5");
                shrhFileList[1]=new SAMDataFile("SHR Sample #2 Aligned BAM File",seqFilePath+"Aligned/Small/SHR2.smRNA.bam","Rn5");
                shrhFileList[2]=new SAMDataFile("SHR Sample #3 Aligned BAM File",seqFilePath+"Aligned/Small/SHR3.smRNA.bam","Rn5");
                resourceList.add(new Resource(57, "Rat", "SHR/OlaIpcvPrin","small RNA (<200 nt) selected","Brain","Illumina HiSeq2000","50 bp single-end", shrhFileList,"Rn5" ));
                
                SAMDataFile[] helicosBNLXFileList = new SAMDataFile[3];
                helicosBNLXFileList[0]=new SAMDataFile("BN-Lx Sample #1 BED File",seqFilePath+"Aligned/Helicos/BNLX1.Helicos.bed.zip","Rn5");
                helicosBNLXFileList[1]=new SAMDataFile("BN-Lx Sample #2 BED File",seqFilePath+"Aligned/Helicos/BNLX2.Helicos.bed.zip","Rn5");
                helicosBNLXFileList[2]=new SAMDataFile("BN-Lx Sample #3 BED File",seqFilePath+"Aligned/Helicos/BNLX3.Helicos.bed.zip","Rn5");
                resourceList.add(new Resource(52, "Rat", "BN-Lx/CubPrin","total RNA (>200 nt) after ribosomal RNA depletion","Brain","Helicos","~33 bp single-end", helicosBNLXFileList,"Rn5" ));
        	
                SAMDataFile[] helicosSHRHFileList = new SAMDataFile[3];
                helicosSHRHFileList[0]=new SAMDataFile("SHR Sample #1 BED File",seqFilePath+"Aligned/Helicos/SHRH1.Helicos.bed.zip","Rn5");
                helicosSHRHFileList[1]=new SAMDataFile("SHR Sample #2 BED File",seqFilePath+"Aligned/Helicos/SHRH2.Helicos.bed.zip","Rn5");
                helicosSHRHFileList[2]=new SAMDataFile("SHR Sample #3 BED File",seqFilePath+"Aligned/Helicos/SHRH3.Helicos.bed.zip","Rn5");
                resourceList.add(new Resource(53, "Rat", "SHR/OlaIpcvPrin","total RNA (>200 nt) after ribosomal RNA depletion","Brain","Helicos","~33 bp single-end", helicosSHRHFileList,"Rn5" ));
                
                bnlxFileList = new SAMDataFile[1];
                bnlxFileList[0]=new SAMDataFile("BN-Lx Aligned BAM File",seqFilePath+"Aligned/rn6/BNLx.rn6.Heart.totalRNA.bam","Rn6");
                resourceList.add(new Resource(58, "Rat", "BN-Lx/CubPrin","total RNA (>200 nt) after ribosomal RNA depletion","Heart","Illumina HiSeq2000","stranded 100 bp paired-end", bnlxFileList,"Rn6" ));
                shrhFileList = new SAMDataFile[1];
                shrhFileList[0]=new SAMDataFile("SHR Sample #1 Aligned BAM File",seqFilePath+"Aligned/rn6/SHR.rn6.Heart.totalRNA.bam","Rn6");
                resourceList.add(new Resource(59, "Rat", "SHR/OlaIpcvPrin","total RNA (>200 nt) after ribosomal RNA depletion","Heart","Illumina HiSeq2000","stranded 100 bp paired-end", shrhFileList,"Rn6" ));
                
                bnlxFileList = new SAMDataFile[1];
                bnlxFileList[0]=new SAMDataFile("BN-Lx Aligned BAM File",seqFilePath+"Aligned/rn6/BNLx.rn6.Liver.totalRNA.bam","Rn6");
                resourceList.add(new Resource(80, "Rat", "BN-Lx/CubPrin","total RNA (>200 nt) after ribosomal RNA depletion","Liver","Illumina HiSeq2000","stranded 100 bp paired-end", bnlxFileList,"Rn6" ));
                shrhFileList = new SAMDataFile[1];
                shrhFileList[0]=new SAMDataFile("SHR Sample #1 Aligned BAM File",seqFilePath+"Aligned/rn6/SHR.rn6.Liver.totalRNA.bam","Rn6");
                resourceList.add(new Resource(81, "Rat", "SHR/OlaIpcvPrin","total RNA (>200 nt) after ribosomal RNA depletion","Liver","Illumina HiSeq2000","stranded 100 bp paired-end", shrhFileList,"Rn6" ));
                
                

                Resource[] resourceArray = myObjectHandler.getAsArray(resourceList, Resource.class);
		return resourceArray;

	}
        
        /**
	 * Gets all the RNA Seq resources
	 * @return	an array of Resource objects
	 */
	public Resource[] getDNASeqResources() {
		log.debug("in getRNASeqResources");
                String seqFilePath="/downloads/DNASeq/";
		List<Resource> resourceList = new ArrayList<Resource>();
                
                SAMDataFile[] bnlxFileList = new SAMDataFile[2];
                bnlxFileList[0]=new SAMDataFile("BNLX Genome Fasta File",seqFilePath+"BNLx.rn6.Genome.fa.zip","Rn6");
                bnlxFileList[1]=new SAMDataFile("BNLX Genome Fasta File",seqFilePath+"BNLX_rn5_Genome.fa.zip","Rn5");
                resourceList.add(new Resource(60, "Rat", "BN-Lx/CubPrin","Illumina HiSeq2000", bnlxFileList, "Rn6, Rn5" ));
        	
                SAMDataFile[] shrhFileList = new SAMDataFile[2];
                shrhFileList[0]=new SAMDataFile("SHRH Genome Fasta File",seqFilePath+"SHRH.rn6.Genome.fa.zip","Rn6");
                shrhFileList[1]=new SAMDataFile("SHRH Genome Fasta File",seqFilePath+"SHRH_rn5_Genome.fa.zip","Rn5");
                resourceList.add(new Resource(61, "Rat", "SHR/OlaIpcvPrin","Illumina HiSeq2000", shrhFileList, "Rn6, Rn5" ));
                
                 SAMDataFile[] shrjFileList = new SAMDataFile[1];
                shrjFileList[0]=new SAMDataFile("SHRJ Genome Fasta File",seqFilePath+"SHRJ_rn5_Genome.fa.zip","Rn5");
                resourceList.add(new Resource(62, "Rat", "SHR/NCrlPrin","Illumina HiSeq2000", shrjFileList, "Rn5" ));
                
                 SAMDataFile[] f344FileList = new SAMDataFile[1];
                f344FileList[0]=new SAMDataFile("presumptive F344* Genome Fasta File",seqFilePath+"F344_rn5_Genome.fa.zip","Rn5");
                resourceList.add(new Resource(63, "Rat", "presumptive F344*","Illumina HiSeq2000", f344FileList, "Rn5" ));
                
                Resource[] resourceArray = myObjectHandler.getAsArray(resourceList, Resource.class);
		return resourceArray;

	}
        
        /**
	 * Gets all the RNA Seq resources
	 * @return	an array of Resource objects
	 */
	public Resource[] getGTFResources() {
		log.debug("in getRNASeqResources");
                String seqFilePath="/downloads/RNASeq/";
		List<Resource> resourceList = new ArrayList<Resource>();

        SAMDataFile[] brainGTFList = new SAMDataFile[1];
        brainGTFList[0]=new SAMDataFile("HRDPv5 Brain Rn6 GTF (10/31/2019)",seqFilePath+"PhenoGen.HRDP.v5.totalRNA.Brain.reconstruction.gtf.gz","Rn6");
        resourceList.add(new Resource(124, "Rat", "HRDP v5","Whole Brain", brainGTFList, "Stringtie" ));

        SAMDataFile[] liverGTFList = new SAMDataFile[1];
        liverGTFList[0]=new SAMDataFile("HRDPv5 Liver Rn6 GTF (10/31/2019)",seqFilePath+"PhenoGen.HRDP.v5.totalRNA.Liver.reconstruction.gtf.gz","Rn6");
        resourceList.add(new Resource(125, "Rat", "HRDP v5","Liver", liverGTFList, "Stringtie" ));
        SAMDataFile[] heartGTFList = new SAMDataFile[1];
        heartGTFList[0]=new SAMDataFile("HRDPv5 Heart Rn6 GTF (10/31/2019)",seqFilePath+"PhenoGen.HRDP.v5.totalRNA.Heart.reconstruction.gtf.gz","Rn6");

        resourceList.add(new Resource(126, "Rat", "HRDP v5","Heart", heartGTFList, "Stringtie" ));
        SAMDataFile[] mergedGTFList = new SAMDataFile[1];
        mergedGTFList[0]=new SAMDataFile("HRDPv5 Merged Rn6 GTF (10/31/2019)",seqFilePath+"PhenoGen.HRDP.v5.totalRNA.Merged.reconstruction.gtf.gz","Rn6");
        resourceList.add(new Resource(127, "Rat", "HRDP v5","Merged", mergedGTFList, "Stringtie" ));
                
        brainGTFList = new SAMDataFile[2];
                brainGTFList[0]=new SAMDataFile("HXB Brain Rn6 GTF v1 (5/31/2016)",seqFilePath+"HXB.Brain.rn6.gtf.zip","Rn6");
                brainGTFList[1]=new SAMDataFile("HXB Brain Rn6 GTF with Merged IDs v1 (5/31/2016)",seqFilePath+"HXB.Brain.rn6.Merged.v1.gtf.zip","Rn6");
                resourceList.add(new Resource(120, "Rat", "BN-Lx/CubPrin,SHR/OlaIpcvPrin","Whole Brain", brainGTFList, "Cufflinks" ));
        heartGTFList = new SAMDataFile[2];
                heartGTFList[0]=new SAMDataFile("HXB Heart Rn6 GTF v1 (4/6/2016)",seqFilePath+"HXB.Heart.rn6.gtf.zip","Rn6");
                heartGTFList[1]=new SAMDataFile("HXB Heart Rn6 GTF with Merged IDs v1 (4/6/2016)",seqFilePath+"HXB.Heart.rn6.Merged.v1.gtf.zip","Rn6");
                resourceList.add(new Resource(121, "Rat", "BN-Lx/CubPrin,SHR/OlaIpcvPrin","Heart", heartGTFList, "Cufflinks" ));
        liverGTFList = new SAMDataFile[2];
                liverGTFList[0]=new SAMDataFile("HXB Liver Rn6 GTF v1 (4/6/2016)",seqFilePath+"HXB.Liver.rn6.gtf.zip","Rn6");
                liverGTFList[1]=new SAMDataFile("HXB Liver Rn6 GTF with Merged IDs v1 (4/6/2016)",seqFilePath+"HXB.Liver.rn6.Merged.v1.gtf.zip","Rn6");
                resourceList.add(new Resource(122, "Rat", "BN-Lx/CubPrin,SHR/OlaIpcvPrin","Liver", liverGTFList, "Cufflinks" ));
        mergedGTFList = new SAMDataFile[1];
                mergedGTFList[0]=new SAMDataFile("HXB Merged Tissue Rn6 GTF v1 (5/31/2016)",seqFilePath+"HXB.Merged.rn6.v1.gtf.zip","Rn6");
                resourceList.add(new Resource(123, "Rat", "BN-Lx/CubPrin,SHR/OlaIpcvPrin","Whole Brain", mergedGTFList, "Cufflinks" ));
                Resource[] resourceArray = myObjectHandler.getAsArray(resourceList, Resource.class);
		return resourceArray;

	}

    public Resource[] getRNASeqExpressionResources() {
        log.debug("in getRNASeqResources");
        String seqFilePath="/downloads/RNASeq/RSEM/";
        List<Resource> resourceList = new ArrayList<Resource>();

        SAMDataFile[] brainGTFList = new SAMDataFile[8];
        brainGTFList[0]=new SAMDataFile("HRDPv5 Brain TotalRNA Ensembl Gene Strain Means",seqFilePath+"PhenoGen.HRDP.v5.totalRNA.Brain.gene.ensembl96.strainMeans.txt.gz","Rn6");
        brainGTFList[1]=new SAMDataFile("HRDPv5 Brain TotalRNA Ensembl Transcript Strain Means",seqFilePath+"PhenoGen.HRDP.v5.totalRNA.Brain.transcript.ensembl96.strainMeans.txt.gz","Rn6");
        brainGTFList[2]=new SAMDataFile("HRDPv5 Brain TotalRNA Reconstruction Gene Strain Means",seqFilePath+"PhenoGen.HRDP.v5.totalRNA.Brain.gene.reconstruction.strainMeans.txt.gz","Rn6");
        brainGTFList[3]=new SAMDataFile("HRDPv5 Brain TotalRNA Reconstruction Transcript Strain Means",seqFilePath+"PhenoGen.HRDP.v5.totalRNA.Brain.transcript.reconstruction.strainMeans.txt.gz","Rn6");
        brainGTFList[4]=new SAMDataFile("HRDPv5 Brain TotalRNA Ensembl Gene Individual Samples",seqFilePath+"PhenoGen.HRDP.v5.totalRNA.Brain.gene.ensembl96.txt.gz","Rn6");
        brainGTFList[5]=new SAMDataFile("HRDPv5 Brain TotalRNA Ensembl Transcript Individual Samples",seqFilePath+"PhenoGen.HRDP.v5.totalRNA.Brain.transcript.ensembl96.txt.gz","Rn6");
        brainGTFList[6]=new SAMDataFile("HRDPv5 Brain TotalRNA Reconstruction Gene Individual Samples",seqFilePath+"PhenoGen.HRDP.v5.totalRNA.Brain.gene.reconstruction.txt.gz","Rn6");
        brainGTFList[7]=new SAMDataFile("HRDPv5 Brain TotalRNA Reconstruction Transcript Individual Sampless",seqFilePath+"PhenoGen.HRDP.v5.totalRNA.Brain.transcript.reconstruction.txt.gz","Rn6");
        resourceList.add(new Resource(500, "Rat", "HRDP v5","Whole Brain", brainGTFList, "RSEM" ));

        SAMDataFile[] liverGTFList = new SAMDataFile[8];
        liverGTFList[0]=new SAMDataFile("HRDPv5 Liver TotalRNA Ensembl Gene Strain Means",seqFilePath+"PhenoGen.HRDP.v5.totalRNA.Liver.gene.ensembl96.strainMeans.txt.gz","Rn6");
        liverGTFList[1]=new SAMDataFile("HRDPv5 Liver TotalRNA Ensembl Transcript Strain Means",seqFilePath+"PhenoGen.HRDP.v5.totalRNA.Liver.transcript.ensembl96.strainMeans.txt.gz","Rn6");
        liverGTFList[2]=new SAMDataFile("HRDPv5 Liver TotalRNA Reconstruction Gene Strain Means",seqFilePath+"PhenoGen.HRDP.v5.totalRNA.Liver.gene.reconstruction.strainMeans.txt.gz","Rn6");
        liverGTFList[3]=new SAMDataFile("HRDPv5 Liver TotalRNA Reconstruction Transcript Strain Means",seqFilePath+"PhenoGen.HRDP.v5.totalRNA.Liver.transcript.reconstruction.strainMeans.txt.gz","Rn6");
        liverGTFList[4]=new SAMDataFile("HRDPv5 Liver TotalRNA Ensembl Gene Individual Samples",seqFilePath+"PhenoGen.HRDP.v5.totalRNA.Liver.gene.ensembl96.txt.gz","Rn6");
        liverGTFList[5]=new SAMDataFile("HRDPv5 Liver TotalRNA Ensembl Transcript Individual Samples",seqFilePath+"PhenoGen.HRDP.v5.totalRNA.Liver.transcript.ensembl96.txt.gz","Rn6");
        liverGTFList[6]=new SAMDataFile("HRDPv5 Liver TotalRNA Reconstruction Gene Individual Samples",seqFilePath+"PhenoGen.HRDP.v5.totalRNA.Liver.gene.reconstruction.txt.gz","Rn6");
        liverGTFList[7]=new SAMDataFile("HRDPv5 Liver TotalRNA Reconstruction Transcript Individual Samples",seqFilePath+"PhenoGen.HRDP.v5.totalRNA.Liver.transcript.reconstruction.txt.gz","Rn6");
        resourceList.add(new Resource(501, "Rat", "HRDP v5","Liver", liverGTFList, "RSEM" ));

        /*SAMDataFile[] heartGTFList = new SAMDataFile[8];
        heartGTFList[0]=new SAMDataFile("HRDPv5 Heart TotalRNA Ensembl Gene Strain Means",seqFilePath+"PhenoGen.HRDP.totalRNA.Liver.gene.v5.ensembl96.strainMeans.csv.gz","Rn6");
        heartGTFList[1]=new SAMDataFile("HRDPv5 Liver TotalRNA Ensembl Transcript Strain Means",seqFilePath+"PhenoGen.HRDP.totalRNA.Liver.transcript.v5.ensembl96.strainMeans.csv.gz","Rn6");
        heartGTFList[2]=new SAMDataFile("HRDPv5 Liver TotalRNA Reconstruction Gene Strain Means",seqFilePath+"PhenoGen.HRDP.totalRNA.Liver.gene.v5.strainMeans.csv.gz","Rn6");
        heartGTFList[3]=new SAMDataFile("HRDPv5 Liver TotalRNA Reconstruction Transcript Strain Means",seqFilePath+"PhenoGen.HRDP.totalRNA.Liver.transcript.v5.strainMeans.csv.gz","Rn6");
        heartGTFList[4]=new SAMDataFile("HRDPv5 Liver TotalRNA Ensembl Gene Individual Samples",seqFilePath+"PhenoGen.HRDP.totalRNA.Liver.gene.v5.ensembl96.csv.gz","Rn6");
        heartGTFList[5]=new SAMDataFile("HRDPv5 Liver TotalRNA Ensembl Transcript Individual Samples",seqFilePath+"PhenoGen.HRDP.totalRNA.Liver.transcript.v5.ensembl96.csv.gz","Rn6");
        heartGTFList[6]=new SAMDataFile("HRDPv5 Liver TotalRNA Reconstruction Gene Individual Samples",seqFilePath+"PhenoGen.HRDP.totalRNA.Liver.gene.v5.csv.gz","Rn6");
        heartGTFList[7]=new SAMDataFile("HRDPv5 Liver TotalRNA Reconstruction Transcript Individual Sampless",seqFilePath+"PhenoGen.HRDP.totalRNA.Liver.transcript.v5.csv.gz","Rn6");
        resourceList.add(new Resource(502, "Rat", "HRDP v5","Heart", heartGTFList, "RSEM" ));*/

        Resource[] resourceArray = myObjectHandler.getAsArray(resourceList, Resource.class);
        return resourceArray;

    }
        
        
        /**
	 * Gets all the Genotyping resources
	 * @return	an array of Resource objects
	 */
	public Resource[] getGenotypingResources() {
		log.debug("in getGenotypingResources");
                String seqFilePath="/userFiles/public/Genotyping/";
		List<Resource> resourceList = new ArrayList<Resource>();
                
                /*GenotypeDataFile[] genotypingFileList = new GenotypeDataFile[5];
                genotypingFileList[0]=new GenotypeDataFile("Genotype CEL Files Part 1",seqFilePath+"Genotyping_1.zip");
                genotypingFileList[1]=new GenotypeDataFile("Genotype CEL Files Part 2",seqFilePath+"Genotyping_2.zip");
                genotypingFileList[2]=new GenotypeDataFile("Genotype CEL Files Part 3",seqFilePath+"Genotyping_3.zip");
                genotypingFileList[3]=new GenotypeDataFile("Genotype CEL Files Part 4",seqFilePath+"Genotyping_4.zip");
                genotypingFileList[4]=new GenotypeDataFile("Genotype CEL Files Part 5",seqFilePath+"Genotyping_5.zip");
                resourceList.add(new Resource(70, "Human", "Alcohol dependent subjects receiving outpatient treatment at the Medical University of Vienna (Austria)",
                                            "self-reported European","Affymetrix Genome-Wide Human SNP Array 6.0", genotypingFileList ));*/
                Resource[] resourceArray = myObjectHandler.getAsArray(resourceList, Resource.class);
		return resourceArray;
	}
        
        public Resource[] getPublicationResources1() {
            log.debug("in getPublicationResources");
            String pubFilePath="/downloads/Publication/";
            List<Resource> resourceList = new ArrayList<Resource>();
                
                PublicationFile[] fileList = new PublicationFile[2];
                fileList[0]=new PublicationFile("Reconstructed PolyA Transcriptome",pubFilePath+"reconPolyA.13Feb14.gtf.zip");
                fileList[1]=new PublicationFile("Reconstructed NonPolyA Transcriptome",pubFilePath+"reconNonPolyA.13Feb14.gtf.zip");
                resourceList.add(new Resource(90, "Rat", "BN-Lx/SHR","Reconstructed Brain Transcriptome",fileList,"\"The sequenced rat brain transcriptome, its use in identifying networks predisposing alcohol consumption\"(Saba et. al. 2015, FEBS)"));
                
                fileList = new PublicationFile[1];
                fileList[0]=new PublicationFile("SNPs for bQTL",pubFilePath+"SDPsforbQTL.csv.zip");
                resourceList.add(new Resource(91, "Rat", "HXB/BXH","SNPs used for alcohol consumption QTL",fileList,"\"The sequenced rat brain transcriptome, its use in identifying networks predisposing alcohol consumption\"(Saba et. al. 2015, FEBS)"));
                
                fileList = new PublicationFile[1];
                fileList[0]=new PublicationFile("Strain Mean Alcohol Consumption Week 2",pubFilePath+"StrainMeans_ConsumpWk2.txt.zip");
                resourceList.add(new Resource(92, "Rat","HXB/BXH", "Alcohol Consumption (2 bottle choice, 10% ethanol, week 2)",fileList,"\"The sequenced rat brain transcriptome, its use in identifying networks predisposing alcohol consumption\"(Saba et. al. 2015, FEBS)"));
                
                fileList = new PublicationFile[2];
                fileList[0]=new PublicationFile("Detection Above Background - Gene Level",pubFilePath+"dabg.brain.reconTrans.geneLevel.txt.zip");
                fileList[1]=new PublicationFile("Normalized Expression values - Gene Level",pubFilePath+"Adjusted_rma.brain.reconTrans.geneLevel.txt.zip");
                resourceList.add(new Resource(93, "Rat","HXB/BXH", "Normalized exon array data - gene level",fileList,"\"The sequenced rat brain transcriptome, its use in identifying networks predisposing alcohol consumption\"(Saba et. al. 2015, FEBS)"));
                
                fileList = new PublicationFile[2];
                fileList[0]=new PublicationFile("Detection Above Background - Isoform Level",pubFilePath+"dabg.brain.reconTrans.isoformLevel.txt.zip");
                fileList[1]=new PublicationFile("Normalized Expression values - Isoform Level",pubFilePath+"Adjusted_rma.brain.reconTrans.isoformLevel.txt.zip");
                resourceList.add(new Resource(94, "Rat","HXB/BXH", "Normalized exon array data - isoform level",fileList,"\"The sequenced rat brain transcriptome, its use in identifying networks predisposing alcohol consumption\"(Saba et. al. 2015, FEBS)"));
                
                fileList = new PublicationFile[2];
                fileList[0]=new PublicationFile("Detection Above Background - Gene Level",pubFilePath+"dabg.brain.reconTrans.geneLevel.selectedLines.txt.zip");
                fileList[1]=new PublicationFile("Normalized Expression values - Gene Level",pubFilePath+"rma.brain.reconTrans.geneLevel.selectedLines.txt.zip");
                resourceList.add(new Resource(95, "Rat","Selected Lines", "Normalized exon array data - gene level",fileList,"\"The sequenced rat brain transcriptome, its use in identifying networks predisposing alcohol consumption\"(Saba et. al. 2015, FEBS)"));
                
                fileList = new PublicationFile[2];
                fileList[0]=new PublicationFile("Detection Above Background - Isoform Level",pubFilePath+"dabg.brain.reconTrans.isoformLevel.selectedLines.txt.zip");
                fileList[1]=new PublicationFile("Normalized Expression values - Isoform Level",pubFilePath+"rma.brain.reconTrans.isoformLevel.selectedLines.txt.zip");
                resourceList.add(new Resource(96, "Rat","Selected Lines", "Normalized exon array data - isoform level",fileList,"\"The sequenced rat brain transcriptome, its use in identifying networks predisposing alcohol consumption\"(Saba et. al. 2015, FEBS)"));
                
                fileList = new PublicationFile[3];
                fileList[0]=new PublicationFile("Masked MPS file by gene",pubFilePath+"RaEx-1_0-st-v1.r2.dt1.rn5.reconstruction.withStrand.byGene.MASKED.mps.zip");
                fileList[1]=new PublicationFile("Masked MPS file",pubFilePath+"RaEx-1_0-st-v1.r2.dt1.rn5.reconstruction.withStrand.MASKED.mps.zip");
                fileList[2]=new PublicationFile("Masked PGF File",pubFilePath+"RaEx-1_0-st-v1.r2.rn5masked.pgf.zip");
                resourceList.add(new Resource(97, "Rat","N/A", "Array Masks",fileList,"\"The sequenced rat brain transcriptome, its use in identifying networks predisposing alcohol consumption\"(Saba et. al. 2015, FEBS)"));
        	
            Resource[] resourceArray = myObjectHandler.getAsArray(resourceList, Resource.class);
            return resourceArray;
        }
        public Resource[] getPublicationResources2() {
            log.debug("in getPublicationResources");
            String pubFilePath="/downloads/Publication/harrall/";
            List<Resource> resourceList = new ArrayList<Resource>();
                
                PublicationFile[] fileList = new PublicationFile[2];
                fileList[0]=new PublicationFile("Affymetrix Mask File",pubFilePath+"RaEx-1_0-st-v1.r2.dt1.rn5.reconstruction.withStrand.byGene.29Oct15.v2.mps");
                fileList[1]=new PublicationFile("Affymetrix PGF File",pubFilePath+"RaEx-1_0-st-v1.r2.rn5masked.pgf.zip");
                resourceList.add(new Resource(100, "Rat", "N/A","Array Masks",fileList,"\"Uncovering the liver's role in immunity through RNA co-expression networks.\" Harrall et. al. (2016, Mamm. Genome)"));
                
                fileList = new PublicationFile[1];
                fileList[0]=new PublicationFile("Normalized Array Data",pubFilePath+"Adjusted_rma.cellSpecific.txt");
                resourceList.add(new Resource(101, "Rat", "N/A","Cell Type Specific Normalized Exon Array",fileList,"\"Uncovering the liver's role in immunity through RNA co-expression networks.\" Harrall et. al. (2016, Mamm. Genome)"));
                
                fileList = new PublicationFile[2];
                fileList[0]=new PublicationFile("Normalized Array Data",pubFilePath+"Adjusted_rma.liver.reconTrans.withStrand.byGene.txt");
                fileList[1]=new PublicationFile("Detection Above Background",pubFilePath+"dabg.liver.reconTrans.geneLevel.txt");
                resourceList.add(new Resource(102, "Rat","N/A", "HXB Normalized Exon Array",fileList,"\"Uncovering the liver's role in immunity through RNA co-expression networks.\" Harrall et. al. (2016, Mamm. Genome)"));
                
                fileList = new PublicationFile[1];
                fileList[0]=new PublicationFile("Reconstructed Transcriptome",pubFilePath+"reconstruct.liver.23Oct15.FINAL.gtf");
                resourceList.add(new Resource(103, "Rat","N/A", "Reconstructed Liver Transcriptome",fileList,"\"Uncovering the liver's role in immunity through RNA co-expression networks.\" Harrall et. al. (2016, Mamm. Genome)"));
                
                fileList = new PublicationFile[14];
                fileList[0]=new PublicationFile("Aligned BNLx BAM",pubFilePath+"BNLx123.liver.bam");
                fileList[1]=new PublicationFile("Aligned SHR BAM",pubFilePath+"SHR.liver.bam");
                fileList[2]=new PublicationFile("BNLx #1 R1 FastQ",pubFilePath+"BNLX_1_GCCAAT_L005_R1_001.fastq.gz");
                fileList[3]=new PublicationFile("BNLx #1 R2 FastQ",pubFilePath+"BNLX_1_GCCAAT_L005_R2_001.fastq.gz");
                fileList[4]=new PublicationFile("BNLx #2 R1 FastQ",pubFilePath+"BNLX_2_CAGATC_L006_R1_001.fastq.gz");
                fileList[5]=new PublicationFile("BNLx #2 R2 FastQ",pubFilePath+"BNLX_2_CAGATC_L006_R2_001.fastq.gz");
                fileList[6]=new PublicationFile("BNLx #3 R1 FastQ",pubFilePath+"BNLX_3_CTTGTA_L001_R1_001.fastq.gz");
                fileList[7]=new PublicationFile("BNLx #3 R2 FastQ",pubFilePath+"BNLX_3_CTTGTA_L001_R2_001.fastq.gz");
                fileList[8]=new PublicationFile("SHR #1 R1 FastQ",pubFilePath+"SHR_H1_CGATGT_L005_R1_001.fastq.gz");
                fileList[9]=new PublicationFile("SHR #1 R2 FastQ",pubFilePath+"SHR_H1_CGATGT_L005_R2_001.fastq.gz");
                fileList[10]=new PublicationFile("SHR #2 R1 FastQ",pubFilePath+"SHR_H5_TGACCA_L006_R1_001.fastq.gz");
                fileList[11]=new PublicationFile("SHR #2 R2 FastQ",pubFilePath+"SHR_H5_TGACCA_L006_R2_001.fastq.gz");
                fileList[12]=new PublicationFile("SHR #3 R1 FastQ",pubFilePath+"SHR_L25_ACAGTG_L001_R1_001.fastq.gz");
                fileList[13]=new PublicationFile("SHR #3 R2 FastQ",pubFilePath+"SHR_L25_ACAGTG_L001_R2_001.fastq.gz");

                resourceList.add(new Resource(104, "Rat","N/A", "RNA-Seq",fileList,"\"Uncovering the liver's role in immunity through RNA co-expression networks.\" Harrall et. al. (2016, Mamm. Genome)"));
                
                fileList = new PublicationFile[1];
                fileList[0]=new PublicationFile("Strain Distibution Patterns",pubFilePath+"HXB.eQTL.masterList.rn5.txt");
                resourceList.add(new Resource(105, "Rat","N/A", "SDPs",fileList,"\"Uncovering the liver's role in immunity through RNA co-expression networks.\" Harrall et. al. (2016, Mamm. Genome)"));

        	
            Resource[] resourceArray = myObjectHandler.getAsArray(resourceList, Resource.class);
            return resourceArray;
        }
        public Resource[] getPublicationResources3() {
            log.debug("in getPublicationResources3");
            String pubFilePath="/downloads/Publication/pravenec/";
            List<Resource> resourceList = new ArrayList<Resource>();
                
            PublicationFile[] fileList = new PublicationFile[4];
            fileList[0]=new PublicationFile("CEL Files Part 1",pubFilePath+"BAT_pravenec_CEL_part1.zip");
            fileList[1]=new PublicationFile("CEL Files Part 2",pubFilePath+"BAT_pravenec_CEL_part2.zip");
            fileList[2]=new PublicationFile("CEL Files Part 3",pubFilePath+"BAT_pravenec_CEL_part3.zip");
            fileList[3]=new PublicationFile("CEL Files Part 4",pubFilePath+"BAT_pravenec_CEL_part4.zip");
            resourceList.add(new Resource(110, "Rat", "N/A","CEL Files",fileList,"\"Systems Genetic Analysis of Brown Adipose Tissue Function\" by Michal Pravenec et al. (Nov 10, 2017, Physiol Genomics.)"));

            fileList = new PublicationFile[1];
            fileList[0]=new PublicationFile("Normalized Array Data",pubFilePath+"BAT.norm.exparray.txt.zip");
            resourceList.add(new Resource(111, "Rat", "N/A","Normalized Gene Array",fileList,"\"Systems Genetic Analysis of Brown Adipose Tissue Function\" by Michal Pravenec et al. (Nov 10, 2017, Physiol Genomics.)"));

            fileList = new PublicationFile[2];
            fileList[0]=new PublicationFile("Probe Module Summary",pubFilePath+"BAT_pravenec_Probe_Module_Summary_8_2017.txt");
            fileList[1]=new PublicationFile("Module Eigengene Matrix",pubFilePath+"BAT_pravenec_Module_Eigengene_Matrix_8_2017.txt");
            resourceList.add(new Resource(112, "Rat","N/A", "WGCNA Module Data",fileList,"\"Systems Genetic Analysis of Brown Adipose Tissue Function\" by Michal Pravenec et al. (Nov 10, 2017, Physiol Genomics.)"));
            
            Resource[] resourceArray = myObjectHandler.getAsArray(resourceList, Resource.class);
            return resourceArray;
        }
        public Resource[] getPublicationResources4() {
            log.debug("in getPublicationResources4");
            String pubFilePath="/downloads/Publication/kechris/";
            List<Resource> resourceList = new ArrayList<Resource>();
                
            PublicationFile[] fileList = new PublicationFile[15];
            fileList[0]=new PublicationFile("Fastq Files Part 1",pubFilePath+"reads_smRNA.Stage1.tar.gz");
            fileList[1]=new PublicationFile("Fastq Files Part 2.1",pubFilePath+"reads_smRNA.Stage2.1.tar.gz");
            fileList[2]=new PublicationFile("Fastq Files Part 2.2",pubFilePath+"reads_smRNA.Stage2.2.tar.gz");
            fileList[3]=new PublicationFile("Fastq Files Part 3.1",pubFilePath+"reads_smRNA.Stage3.1.tar.gz");
            fileList[4]=new PublicationFile("Fastq Files Part 3.2",pubFilePath+"reads_smRNA.Stage3.2.tar.gz");
            fileList[5]=new PublicationFile("Fastq Files Part 3.3",pubFilePath+"reads_smRNA.Stage3.3.tar.gz");
            fileList[6]=new PublicationFile("Fastq Files Part 4.1",pubFilePath+"reads_smRNA.Stage4.1.tar.gz");
            fileList[7]=new PublicationFile("Fastq Files Part 4.2",pubFilePath+"reads_smRNA.Stage4.2.tar.gz");
            fileList[8]=new PublicationFile("Fastq Files Part 4.3",pubFilePath+"reads_smRNA.Stage4.3.tar.gz");
            fileList[9]=new PublicationFile("Fastq Files Part 4.4",pubFilePath+"reads_smRNA.Stage4.4.tar.gz");
            fileList[10]=new PublicationFile("Fastq Files Part 5.1",pubFilePath+"reads_smRNA.Stage5.1.tar.gz");
            fileList[11]=new PublicationFile("Fastq Files Part 5.2",pubFilePath+"reads_smRNA.Stage5.2.tar.gz");
            fileList[12]=new PublicationFile("Fastq Files Part 5.3",pubFilePath+"reads_smRNA.Stage5.3.tar.gz");
            fileList[13]=new PublicationFile("Fastq Files Part 5.4",pubFilePath+"reads_smRNA.Stage5.4.tar.gz");
            fileList[14]=new PublicationFile("Fastq Files Part 5.5",pubFilePath+"reads_smRNA.Stage5.5.tar.gz");
            resourceList.add(new Resource(150, "Mouse", "N/A","Fastq Files",fileList,"\"\"miR-MaGiC improves quantification accuracy for small RNA-seq\" by Pamela Russell et al."));

            Resource[] resourceArray = myObjectHandler.getAsArray(resourceList, Resource.class);
            return resourceArray;
        }
        
        public Resource[] getPublicationResources5() {
            log.debug("in getPublicationResources5");
            String pubFilePath="/downloads/Publication/vanderlinden/";
            List<Resource> resourceList = new ArrayList<Resource>();
                
            PublicationFile[] fileList = new PublicationFile[1];
            fileList[0]=new PublicationFile("BXD Whole Brain Expression Data for WGCNA",pubFilePath+"BXD.wholeBrain.priorToWGCNA.txt.zip");
            resourceList.add(new Resource(162, "Mouse", "BXD","BXD Whole Brain Expression Data for WGCNA",fileList, "\"Whole Brain and Brain Regional Coexpression Network Interactions Associated with Predisposition to Alcohol Consumption\" (Vanderlinden et. al. 2013 PLOS)"));

            fileList = new PublicationFile[1];
            fileList[0]=new PublicationFile("Module Membership Key",pubFilePath+"BXD.wholeBrain.moduleMembershipKey.txt");
            resourceList.add(new Resource(161, "Mouse", "BXD","Module Membership Key",fileList,"\"Whole Brain and Brain Regional Coexpression Network Interactions Associated with Predisposition to Alcohol Consumption\" (Vanderlinden et. al. 2013 PLOS)"));

            fileList = new PublicationFile[1];
            fileList[0]=new PublicationFile("Module Eigengene Matrix",pubFilePath+"BXD.wholeBrain.ModuleEigengeneMatrix.txt");
            resourceList.add(new Resource(160, "Mouse","BXD", "Module Eigengene Matrix",fileList,"\"Whole Brain and Brain Regional Coexpression Network Interactions Associated with Predisposition to Alcohol Consumption\" (Vanderlinden et. al. 2013 PLOS)"));
            
            Resource[] resourceArray = myObjectHandler.getAsArray(resourceList, Resource.class);
            return resourceArray;
        }
         public Resource[] getPublicationResources6() {
            log.debug("in getPublicationResources6");
            String pubFilePath="/downloads/Publication/kechris/";
            List<Resource> resourceList = new ArrayList<Resource>();
                
            PublicationFile[] fileList = new PublicationFile[15];
            fileList[0]=new PublicationFile("Fastq Files Part 1",pubFilePath+"reads_smRNA.Stage1.tar.gz");
            fileList[1]=new PublicationFile("Fastq Files Part 2.1",pubFilePath+"reads_smRNA.Stage2.1.tar.gz");
            fileList[2]=new PublicationFile("Fastq Files Part 2.2",pubFilePath+"reads_smRNA.Stage2.2.tar.gz");
            fileList[3]=new PublicationFile("Fastq Files Part 3.1",pubFilePath+"reads_smRNA.Stage3.1.tar.gz");
            fileList[4]=new PublicationFile("Fastq Files Part 3.2",pubFilePath+"reads_smRNA.Stage3.2.tar.gz");
            fileList[5]=new PublicationFile("Fastq Files Part 3.3",pubFilePath+"reads_smRNA.Stage3.3.tar.gz");
            fileList[6]=new PublicationFile("Fastq Files Part 4.1",pubFilePath+"reads_smRNA.Stage4.1.tar.gz");
            fileList[7]=new PublicationFile("Fastq Files Part 4.2",pubFilePath+"reads_smRNA.Stage4.2.tar.gz");
            fileList[8]=new PublicationFile("Fastq Files Part 4.3",pubFilePath+"reads_smRNA.Stage4.3.tar.gz");
            fileList[9]=new PublicationFile("Fastq Files Part 4.4",pubFilePath+"reads_smRNA.Stage4.4.tar.gz");
            fileList[10]=new PublicationFile("Fastq Files Part 5.1",pubFilePath+"reads_smRNA.Stage5.1.tar.gz");
            fileList[11]=new PublicationFile("Fastq Files Part 5.2",pubFilePath+"reads_smRNA.Stage5.2.tar.gz");
            fileList[12]=new PublicationFile("Fastq Files Part 5.3",pubFilePath+"reads_smRNA.Stage5.3.tar.gz");
            fileList[13]=new PublicationFile("Fastq Files Part 5.4",pubFilePath+"reads_smRNA.Stage5.4.tar.gz");
            fileList[14]=new PublicationFile("Fastq Files Part 5.5",pubFilePath+"reads_smRNA.Stage5.5.tar.gz");
            resourceList.add(new Resource(170, "Mouse", "N/A","Fastq Files",fileList,"\"Predictive Modeling of miRNA-mediated Predisposition to Alcohol-related Phenotypes in Mouse\" by Pratyaydipta Rudra et al."));
            
            fileList = new PublicationFile[6];
            fileList[0]=new PublicationFile("miRNA Normalized Expression - This table (881 x 59) contains the filtered, normalized and batch effect corrected miRNA expression data. Each row is a miRNA and each column is a sample. ",pubFilePath+"mirna_expression_normalized.csv.zip");
            fileList[1]=new PublicationFile("miRNA Variance Stabilized Expression - This table (881 x 59) contains the filtered, normalized and batch effect corrected and variance stabilized miRNA expression data after variance stabilizing transformation from DESeq was performed. Each row is a miRNA and each column is a sample.",pubFilePath+"mirna_expression_variance_stabilized.csv.zip");
            fileList[2]=new PublicationFile("mRNA Expression Strain Means",pubFilePath+"mRNA_expression_data_strainmeans.csv.zip");
            fileList[3]=new PublicationFile("mRNA Expression Full",pubFilePath+"mRNA_expression_data_full.csv.zip");
            fileList[4]=new PublicationFile("All SDPs - This table (1416 x 7) shows the list of all SDPs along with the number of SNPs, chromosome number, the rs number and base-pair location for the first and last SNP corresponding to every SDP. ",pubFilePath+"Table_of_all_SDPs.csv.zip");
            fileList[5]=new PublicationFile("All Quadruples - This table (2916 x 10) shows the list of all the 2916 cohesive quadruples. Each row corresponds to a quadruple. The first four columns show the phenotype name, SDP number, miRNA name and the gene (mRNA) name.  The next 6 columns show the pairwise correlations between the 4 variables for each quadruple.",pubFilePath+"Table_of_all_quadruples.csv.zip");
            resourceList.add(new Resource(171, "Mouse", "N/A","Processed Data",fileList,"\"Predictive Modeling of miRNA-mediated Predisposition to Alcohol-related Phenotypes in Mouse\" by Pratyaydipta Rudra et al."));
            
            Dataset myDataset = new Dataset();
            Dataset LXSRI_Dataset = myDataset.getDatasetFromMyDatasets(publicDatasets, myDataset.LXSRI_DATASET_NAME);
            String resourcesDir = LXSRI_Dataset.getResourcesDir();
            resourcesDir=resourcesDir.substring(resourcesDir.indexOf("/userFiles/"));

            fileList = new PublicationFile[1];
            fileList[0] = new PublicationFile("SNP information on the LXS RI panel was collected by Dr. Gary Churchill and colleagues at the Jackson Laboratory using the Affymetrix Mouse Diversity Genotyping array.  This information was gathered with funding from NIH grants (GM0706833 and AG0038070).", resourcesDir + "LXS.markers.mm10.txt.zip");
            resourceList.add(new Resource(172, "Mouse", "N/A","Markers",fileList,"\"Predictive Modeling of miRNA-mediated Predisposition to Alcohol-related Phenotypes in Mouse\" by Pratyaydipta Rudra et al."));
            

            Resource[] resourceArray = myObjectHandler.getAsArray(resourceList, Resource.class);
            return resourceArray;
        }
         
         public Resource[] getPublicationResources7() {
            log.debug("in getPublicationResources7");
            String pubFilePath="/downloads/Publication/Li.PSU/";
            List<Resource> resourceList = new ArrayList<Resource>();
            Dataset myDataset = new Dataset();
            Dataset HXBRI_Brain_Exon_Dataset = myDataset.getDatasetFromMyDatasets(publicDatasets, myDataset.HXBRI_BRAIN_EXON_DATASET_NAME);
            Dataset HXBRI_Heart_Exon_Dataset = myDataset.getDatasetFromMyDatasets(publicDatasets, myDataset.HXBRI_HEART_EXON_DATASET_NAME);
            
            PublicationFile[] fileList = new PublicationFile[10];
            fileList[0]=new PublicationFile("Brain - Normalized Expression Values",pubFilePath+"HXB.Brain.rn6.expr.TC.core.v2.txt.zip");
            fileList[1]=new PublicationFile("Heart - Normalized Expression Values",pubFilePath+"HXB.Heart.rn6.expr.TC.core.v2.txt.zip");            
            String resourcesDir = HXBRI_Brain_Exon_Dataset.getResourcesDir();
            resourcesDir=resourcesDir.substring(resourcesDir.indexOf("/userFiles/"));
            fileList[2]=new PublicationFile("Brain - Raw Data - CEL Files, Part 1", resourcesDir + "PublicHXB_BXH.Brain.Exon.RawData_Part1.zip");
            fileList[3]=new PublicationFile("Brain - Raw Data - CEL Files, Part 2", resourcesDir + "PublicHXB_BXH.Brain.Exon.RawData_Part2.zip");
            fileList[4]=new PublicationFile("Brain - Raw Data - CEL Files, Part 3", resourcesDir + "PublicHXB_BXH.Brain.Exon.RawData_Part3.zip");
            fileList[5]=new PublicationFile("Brain - Raw Data - CEL Files, Part 4", resourcesDir + "PublicHXB_BXH.Brain.Exon.RawData_Part4.zip");
            resourcesDir = HXBRI_Heart_Exon_Dataset.getResourcesDir();
            resourcesDir=resourcesDir.substring(resourcesDir.indexOf("/userFiles/"));
            fileList[6]=new PublicationFile("Heart - Raw Data - CEL Files, Part 1", resourcesDir + "PublicHXB_BXH.Heart.Exon.RawData_Part1.zip");
            fileList[7]=new PublicationFile("Heart - Raw Data - CEL Files, Part 2", resourcesDir + "PublicHXB_BXH.Heart.Exon.RawData_Part2.zip");
            fileList[8]=new PublicationFile("Heart - Raw Data - CEL Files, Part 3", resourcesDir + "PublicHXB_BXH.Heart.Exon.RawData_Part3.zip");
            fileList[9]=new PublicationFile("Heart - Raw Data - CEL Files, Part 4", resourcesDir + "PublicHXB_BXH.Heart.Exon.RawData_Part4.zip");
            
            resourceList.add(new Resource(180, "Rat", "N/A","Normalized Expression/Raw CEL Files",fileList,"\"Condition-adaptive fusion graphical lasso (CFGL): an adaptive procedure for inferring condition-specific gene co-expression network.\" by Y. Lyu et al."));
            
            Resource[] resourceArray = myObjectHandler.getAsArray(resourceList, Resource.class);
            return resourceArray;
        }

    public Resource[] getPublicationResources8() {
        log.debug("in getPublicationResources8");
        String pubFilePath="/downloads/Publication/kordas/";
        List<Resource> resourceList = new ArrayList<Resource>();

        PublicationFile[] fileList = new PublicationFile[1];
        fileList[0]=new PublicationFile("LXS Brain - miRNA eQTLs",pubFilePath+"full_mieqtl_table.csv");

        resourceList.add(new Resource(210, "Mouse", "ILS/ISS(LXS)","miRNA eQTLs",fileList,"\"Insight into genetic regulation of miRNA in mouse brain\" by G. Kordas et. al."));

        Resource[] resourceArray = myObjectHandler.getAsArray(resourceList, Resource.class);
        return resourceArray;
    }

    public Resource[] getPublicationResources9() {
        log.debug("in getPublicationResources9");
        String pubFilePath="/downloads/Publication/saba_lrap/";
        List<Resource> resourceList = new ArrayList<Resource>();

        PublicationFile[] fileList = new PublicationFile[1];
        fileList[0]=new PublicationFile("LRAP KO transcpriptome merged w/ Ensembl",pubFilePath+"lncKO_merged_wEnsembl.annotated.gtf.zip");
        resourceList.add(new Resource(220, "Rat", "","WT/KO Transcriptome GTF",fileList,"\"A Long Non-Coding RNA (Lrap) Modulates Brain Gene Expression and Levels of Alcohol Consumption in Rats\" by L. Saba et. al."));
        fileList = new PublicationFile[2];
        fileList[0]=new PublicationFile("Gene Count Matrix",pubFilePath+"gene_count_matrix.txt.zip");
        fileList[1]=new PublicationFile("Isoform Count Matrix",pubFilePath+"isoform_count_matrix.txt.zip");
        resourceList.add(new Resource(221, "Rat", "","Gene/Isoform Count Matrices",fileList,"\"A Long Non-Coding RNA (Lrap) Modulates Brain Gene Expression and Levels of Alcohol Consumption in Rats\" by L. Saba et. al."));
        Resource[] resourceArray = myObjectHandler.getAsArray(resourceList, Resource.class);
        return resourceArray;
    }

	/**
	 * Returns one Resource object from an array of Resource objects
	 * @param myResources	an array of Resource objects 
	 * @param id	the name of the resources to return 
	 * @return            an Resource object
	 */
	public Resource getResourceFromMyResources(Resource[] myResources, int id) {
        	//
        	// Return the Resource object that contains the id from the myResources
        	//

        	myResources = sortResources(myResources, "id");

        	int idx = Arrays.binarySearch(myResources, new Resource(id), new ResourceSortComparator());
		log.debug("idx = " + idx);
	
        	Resource thisResource = null;
                if(idx>-1){
                    thisResource=myResources[idx];
                }

        	return thisResource;
	}

	public boolean equals(Object obj) {
		if (!(obj instanceof Resource)) return false;
		return this.id == ((Resource)obj).id;
	}
        
	public void print(Resource myResource) {
		myResource.print();
	}

	public String toString() {
		return "This Resource has organism = " + organism +
		", tissue = " + tissue + ", and panel = " + panel;
	}

	public void print() {
		log.debug("Resource = " + toString());
	}

	public Resource[] sortResources (Resource[] myResources, String sortColumn) {
		setSortColumn(sortColumn);
		Arrays.sort(myResources, new ResourceSortComparator());
		return myResources;
	}

	private String sortColumn;
	public void setSortColumn(String inString) {
		this.sortColumn = inString;
	}

	public String getSortColumn() {
		return sortColumn;
	}

	public class ResourceSortComparator implements Comparator<Resource> {
		int compare;
		Resource resource1, resource2;

		public int compare(Resource resource1, Resource resource2) 	{ 
			//log.debug("in ResourceSortComparator. sortOrder = "+getSortOrder() + ", sortColumn = "+getSortColumn());
			//log.debug("resource1 organism = "+resource1.getOrganism()+ ", resource2 organism = "+resource2.getOrganism());

                	if (getSortColumn().equals("organism")) {
                        	compare = resource1.getOrganism().compareTo(resource2.getOrganism());
                	} else if (getSortColumn().equals("panel")) {
                        	compare = resource1.getPanel().compareTo(resource2.getPanel());
                	} else if (getSortColumn().equals("arrayName")) {
                        	compare = resource1.getArrayName().compareTo(resource2.getArrayName());
                	} else if (getSortColumn().equals("tissue")) {
                        	compare = resource1.getTissue().compareTo(resource2.getTissue());
                	} else if (getSortColumn().equals("id")) {
                        	compare = new Integer(resource1.getID()).compareTo(new Integer(resource2.getID()));
			}
                	return compare;
        	}
	}
}
