package edu.ucdenver.ccp.PhenoGen.tools.analysis;


import edu.ucdenver.ccp.PhenoGen.web.SessionHandler; 
import edu.ucdenver.ccp.PhenoGen.web.mail.*;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import javax.sql.DataSource;
import oracle.jdbc.*;
import org.apache.log4j.Logger;


public class BrowserTrack{
    private int id=0;
    private int userid=0;
    private String settings="";
    private String trackClass="";
    private String trackName="";
    private String trackDescription="";
    private String organism="";
    private String genericCategory="";
    private String category="";
    private int order=-1;
    private String controls="";
    private boolean visible=true;
    private String location="";
    private String originalFile="";
    private String type="";
    private Timestamp ts=null;
    private String gV="";
    private String dbStatus="";
    private HashMap<String,Integer> nullTissueTracks=new HashMap();
    private HashMap<String,Integer> nullStrainTracks=new HashMap();


    
    public BrowserTrack(){
        nullStrainTracks.put("RefSeq",1);
        nullStrainTracks.put("EnsemblAnnotation",1);
        nullStrainTracks.put("EnsemblAnnotationSmall",1);
        nullStrainTracks.put("Array",1);
        nullStrainTracks.put("Repeat",1);
        nullStrainTracks.put("Reconstruction",1);
        nullStrainTracks.put("SmallRNA",1);
        nullStrainTracks.put("SpliceJunction",1);
        nullStrainTracks.put("CirRNA",1);
        nullStrainTracks.put("Sequence",1);
        nullStrainTracks.put("QTL",1);
        nullTissueTracks.put("RefSeq",1);
        nullTissueTracks.put("EnsemblAnnotation",1);
        nullTissueTracks.put("EnsemblAnnotationSmall",1);
        nullTissueTracks.put("Array",1);
        nullTissueTracks.put("Repeat",1);
        nullTissueTracks.put("Variant",1);
        nullTissueTracks.put("Sequence",1);
        nullStrainTracks.put("QTL",1);
    }

    public BrowserTrack( int userid,  String trackclass,
                        String trackname, String description, String organism,String settings, int order,
                        String genCat,String category,String controls,Boolean vis,String location,
                        String fileName,String fileType,Timestamp ts,String genomeVer){
        this(-1,userid, trackclass, trackname,description, organism,settings, order, genCat,category,controls,vis,location,
                fileName,fileType,ts,genomeVer);

    }
    public BrowserTrack(int id, int userid,  String trackclass, 
                String trackname, String description, String organism,String settings, int order,
                String genCat,String category,String controls,Boolean vis,String location,
                String fileName,String fileType,Timestamp ts,String genomeVer){
        this.ts = null;
        this.id=id;
        this.userid=userid;
        this.settings=settings;
        this.trackClass=trackclass;
        this.trackName=trackname;
        this.trackDescription=description;
        this.organism=organism;
        this.order=order;
        this.genericCategory=genCat;
        this.category=category;
        this.controls=controls;
        this.visible=vis;
        this.location=location;
        this.ts=ts;
        this.originalFile=fileName;
        this.type=fileType;
        this.gV=genomeVer;

        nullStrainTracks.put("RefSeq",1);
        nullStrainTracks.put("EnsemblAnnotation",1);
        nullStrainTracks.put("EnsemblAnnotationSmall",1);
        nullStrainTracks.put("Array",1);
        nullStrainTracks.put("Repeat",1);
        nullStrainTracks.put("Reconstruction",1);
        nullStrainTracks.put("SmallRNA",1);
        nullStrainTracks.put("SpliceJunction",1);
        nullStrainTracks.put("CirRNA",1);
        nullStrainTracks.put("Sequence",1);
        nullStrainTracks.put("QTL",1);
        nullTissueTracks.put("RefSeq",1);
        nullTissueTracks.put("EnsemblAnnotation",1);
        nullTissueTracks.put("EnsemblAnnotationSmall",1);
        nullTissueTracks.put("Array",1);
        nullTissueTracks.put("Repeat",1);
        nullTissueTracks.put("Variant",1);
        nullTissueTracks.put("Sequence",1);
        nullStrainTracks.put("QTL",1);
    }

    public ArrayList<BrowserTrack> getBrowserTracks(int userid,String genomeVer,DataSource pool){
        Logger log=Logger.getRootLogger();
        ArrayList<BrowserTrack> ret=new ArrayList<BrowserTrack>();
        
        String query="select bt.TRACKID, bt.USER_ID, bt.TRACK_CLASS, bt.TRACK_NAME, bt.TRACK_DESC, bt.ORGANISM, bt.CATEGORY_GENERIC, bt.CATEGORY, bt.DISPLAY_OPTS, bt.VISIBLE, bt.CUSTOM_LOCATION, bt.CUSTOM_DATE, bt.CUSTOM_FILE_ORIGINAL, bt.CUSTOM_TYPE,gbt.genome_id from BROWSER_TRACKS bt, BROWSER_GV2TRACK gbt "+
                        "where ";
            if(!genomeVer.equals("all")){
                query=query+" gbt.genome_id= '"+genomeVer+"' and ";
            }
            query=query+" gbt.TRACKID=bt.TRACKID "+
                        "and bt.user_id="+userid+" and bt.visible=1";

            PreparedStatement ps=null;
            try(Connection conn=pool.getConnection();) {
                ps = conn.prepareStatement(query);
                ResultSet rs = ps.executeQuery();
                //int count=0;
                while(rs.next()){
                    int tid=rs.getInt(1);
                    int uid=rs.getInt(2);
                    String tclass=rs.getString(3);
                    String name=rs.getString(4);
                    String desc=rs.getString(5);
                    String org=rs.getString(6);
                    String genCat=rs.getString(7);
                    String cat=rs.getString(8);
                    String controls=rs.getString(9);
                    boolean vis=rs.getBoolean(10);
                    String location=rs.getString(11);
                    Timestamp t=rs.getTimestamp(12);
                    String file=rs.getString(13);
                    String type=rs.getString(14);
                    String gV=rs.getString(15);
                    BrowserTrack tmpBT=new BrowserTrack(tid,uid,tclass,name,desc,org,"",0,genCat,cat,controls,vis,location,file,type,t,gV);
                    ret.add(tmpBT);
                }
                
                ps.close();
            } catch (SQLException ex) {
                log.error("SQL Exception retreiving browser views:" ,ex);
                try {
                    ps.close();
                } catch (Exception ex1) {
                   
                }
            }
            
            
        return ret;
    }

        public BrowserTrack getBrowserTrack(int trackid,DataSource pool){
        Logger log=Logger.getRootLogger();
        BrowserTrack ret=null;
        
        String query="select TRACKID, USER_ID, TRACK_CLASS, TRACK_NAME, TRACK_DESC, ORGANISM, CATEGORY_GENERIC, CATEGORY, DISPLAY_OPTS, VISIBLE, CUSTOM_LOCATION, CUSTOM_DATE, CUSTOM_FILE_ORIGINAL, CUSTOM_TYPE from BROWSER_TRACKS "+
                        "where trackid="+trackid;
            PreparedStatement ps=null;
            try(Connection conn=pool.getConnection()) {
                ps = conn.prepareStatement(query);
                ResultSet rs = ps.executeQuery();
                //int count=0;
                if(rs.next()){
                    int tid=rs.getInt(1);
                    int uid=rs.getInt(2);
                    String tclass=rs.getString(3);
                    String name=rs.getString(4);
                    String desc=rs.getString(5);
                    String org=rs.getString(6);
                    String genCat=rs.getString(7);
                    String cat=rs.getString(8);
                    String controls=rs.getString(9);
                    boolean vis=rs.getBoolean(10);
                    String location=rs.getString(11);
                    Timestamp t=rs.getTimestamp(12);
                    String file=rs.getString(13);
                    String type=rs.getString(14);
                    ret=new BrowserTrack(tid,uid,tclass,name,desc,org,"",0,genCat,cat,controls,vis,location,file,type,t,"");
                }
                
                ps.close();

            } catch (SQLException ex) {
                log.error("SQL Exception retreiving browser views:" ,ex);
                try {
                    ps.close();
                } catch (Exception ex1) {
                   
                }
            }
        return ret;
    }

    public ArrayList<BrowserTrack> getBrowserTracks(String[] tracks,String genomeVer,int datasetVer,DataSource pool){
        Logger log=Logger.getRootLogger();
        log.debug("getBrowserTracks find any that match selection");
        log.debug(tracks);
        ArrayList<BrowserTrack> ret=new ArrayList<BrowserTrack>();

        String query="select bt.TRACKID, bt.USER_ID, bt.TRACK_CLASS, bt.TRACK_NAME, bt.TRACK_DESC, bt.ORGANISM, bt.CATEGORY_GENERIC, bt.CATEGORY, bt.DISPLAY_OPTS, bt.VISIBLE, bt.CUSTOM_LOCATION, bt.CUSTOM_DATE, bt.CUSTOM_FILE_ORIGINAL, bt.CUSTOM_TYPE,bt.Tissue,bt.track_type,bt.strain,gbt.genome_id from BROWSER_TRACKS bt, BROWSER_GV2TRACK gbt where ";
        query = query +"bt.TRACKID=gbt.TRACKID and  bt.visible=1 ";
        if(!genomeVer.equals("all")){
            query=query+" and gbt.genome_id= '"+genomeVer+"' ";
        }


        boolean readCounts=false;
        boolean readCountsSmall=false;
        boolean variants=false;
        String tissueSelection="";
        String nullSTTrackType="";
        String nullStrainTrackType="";
        String nullTissueTrackType="";
        String strainsReads="";
        String strainsReadsSmall="";
        String strainVars="";
        HashMap<String,String> settingHM=new HashMap<>();
        for(int i=0;i<tracks.length;i++){
            log.debug("Track:"+tracks[i]);
            if(tracks[i].startsWith("cbxTissue")){
                tissueSelection=tissueSelection+",'"+tracks[i].substring(9)+"'";
            }else if(tracks[i].startsWith("cbxTrack") && !tracks[i].equals("cbxTrackVariant")){
                String track=tracks[i].substring(8);
                if(nullTissueTracks.containsKey(track) && nullStrainTracks.containsKey(track)){
                    nullSTTrackType=nullSTTrackType+",'"+track+"'";
                }else if(nullTissueTracks.containsKey(track)){
                    nullTissueTrackType=nullTissueTrackType+",'"+track+"'";
                }else if(nullStrainTracks.containsKey(track)){
                    nullStrainTrackType=nullStrainTrackType+",'"+track+"'";
                }/*else{
                    strainTrackType=strainTrackType+",'"+track+"'";
                }*/
            }else if(tracks[i].startsWith("strainReads")){
                strainsReads=strainsReads+",'"+tracks[i].substring(11)+"'";
            }else if(tracks[i].startsWith("strainReadsSmall")){
                strainsReadsSmall=strainsReadsSmall+",'"+tracks[i].substring(16)+"'";
            }else if(tracks[i].startsWith("strainVar")){
                strainVars=strainVars+",'"+tracks[i].substring(9)+"'";
            }
            log.debug("tissueSelection:"+tissueSelection);
            log.debug("nullSTTT:"+nullSTTrackType);
            log.debug("nullTTT:"+nullTissueTrackType);
            log.debug("nullSTT:"+nullStrainTrackType);
        }
        String tissueQuery="";
        //String nullStrainTrackQuery="";
        //String nullTissueTrackQuery="";
        //String nullSTTrackQuery="";
        if(!tissueSelection.equals("")){
            tissueSelection=tissueSelection.substring(1);
            if(tissueSelection.indexOf(",")>0){
                tissueQuery = " bt.tissue in ("+tissueSelection+") ";
            }else{
                tissueQuery = " bt.tissue = "+tissueSelection+" ";
            }

        }
        log.debug("tissueQuery:"+tissueQuery);
        String and=" and (";
        if(!nullStrainTrackType.equals("")){
            nullStrainTrackType=nullStrainTrackType.substring(1);
            if(nullStrainTrackType.indexOf(",")>0) {
                query = query +and+" ("+tissueQuery+" and bt.strain is null and bt.track_Type in (" + nullStrainTrackType + ") ) ";
            }else{
                query = query +and +" ( "+tissueQuery+" and bt.strain is null and bt.track_type = " + nullStrainTrackType + ") ";
            }
            and=" or ";
        }

        if(!nullTissueTrackType.equals("")){
            nullTissueTrackType=nullTissueTrackType.substring(1);
            if(nullTissueTrackType.indexOf(",")>0) {
                query = query  +and+" ( bt.tissue is null and bt.track_Type in (" + nullTissueTrackType + ") )";
            }else{
                query = query  +and+" ( bt.tissue is null and bt.track_type = " + nullTissueTrackType + ") ";
            }
            and=" or ";
        }
        if(!nullSTTrackType.equals("")){
            nullSTTrackType=nullSTTrackType.substring(1);
            if(nullSTTrackType.indexOf(",")>0) {
                query = query +and+" ( bt.tissue is null and bt.strain is null and bt.track_Type in (" + nullSTTrackType + ") )";
            }else{
                query = query +and+" ( bt.tissue is null and bt.strain is null and bt.track_type = " + nullSTTrackType + ") ";
            }
            and=" or ";
        }

        /*if( !tissueQuery.equals("") && !trackQuery.equals("")) {
            query = query + " and (( " + tissueQuery + " and " + trackQuery + " ) or ( bt.tissue is null and " + trackQuery + " ) )";
        }else if(!trackQuery.equals("")){
            query = query + " and  bt.tissue is null and "+trackQuery;
        }else if(!tissueQuery.equals("")){
            query = query + " and "+tissueQuery;
        }*/

        if(!strainsReads.equals("")){
            strainsReads=strainsReads.substring(1);
            if(strainsReads.indexOf(",")>0) {
                query = query +and+ " ("+tissueQuery+" and  bt.track_type = 'ReadCounts' and bt.strain in (" + strainsReads + ") ) ";
            }else{
                query = query +and+" ("+tissueQuery+" and  bt.track_type = 'ReadCounts' and bt.strain = " +strainsReads+ ") ";
            }
            and=" or ";
        }
        if(!strainsReadsSmall.equals("")){
            strainsReadsSmall=strainsReadsSmall.substring(1);
            if(strainsReadsSmall.indexOf(",")>0) {
                query = query + and+" ("+tissueQuery+" and bt.track_type = 'ReadCountsSmall' and bt.strain in (" +strainsReadsSmall + ") ) ";
            }else{
                query = query + and +" ("+tissueQuery+" and bt.track_type = 'ReadCountsSmall' and bt.strain = " + strainsReadsSmall + ") ";
            }
            and=" or ";
        }
        if(!strainVars.equals("")){
            strainVars=strainVars.substring(1);
            if(strainVars.indexOf(",")>0) {
                query = query + and+" ( bt.track_type = 'Variant' and bt.strain in (" +strainVars + ") ) ";
            }else{
                query = query +and+" ( bt.track_type = 'Variant' and bt.strain = " + strainVars + ") ";
            }
            and=" or ";
        }
        if(and.equals(" or ")){
            query=query+" )";
        }
        log.debug("find Tracks for trackString:\n");
        log.debug(query);
        PreparedStatement ps=null;
        try(Connection conn=pool.getConnection();) {
            ps = conn.prepareStatement(query);
            ResultSet rs = ps.executeQuery();
            //int count=0;
            while(rs.next()){
                int tid=rs.getInt(1);
                int uid=rs.getInt(2);
                String tclass=rs.getString(3);
                String name=rs.getString(4);
                String desc=rs.getString(5);
                String org=rs.getString(6);
                String genCat=rs.getString(7);
                String cat=rs.getString(8);
                String controls=rs.getString(9);
                boolean vis=rs.getBoolean(10);
                String location=rs.getString(11);
                Timestamp t=rs.getTimestamp(12);
                String file=rs.getString(13);
                String type=rs.getString(14);
                String gV=rs.getString(18);
                BrowserTrack tmpBT=new BrowserTrack(tid,uid,tclass,name,desc,org,"",0,genCat,cat,controls,vis,location,file,type,t,gV);
                ret.add(tmpBT);
            }

            ps.close();
        } catch (SQLException ex) {
            log.error("SQL Exception retreiving browser views:" ,ex);
            try {
                ps.close();
            } catch (Exception ex1) {

            }
        }
        return ret;
    }
    
    public String getControls() {
        return controls;
    }

    public void setControls(String controls) {
        this.controls = controls;
    }

    public String getGenericCategory() {
        return genericCategory;
    }

    public void setGenericCategory(String genericCategory) {
        this.genericCategory = genericCategory;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }
        
    public int getID() {
        return id;
    }

    public void setID(int id) {
        this.id = id;
    }

    public int getUserID() {
        return userid;
    }

    public void setUserID(int userid) {
        this.userid = userid;
    }

    public String getSettings() {
        return settings;
    }

    public void setSettings(String settings) {
        this.settings = settings;
    }

    public String getTrackClass() {
        return trackClass;
    }

    public void setTrackClass(String trackClass) {
        this.trackClass = trackClass;
    }

    public String getTrackName() {
        return trackName;
    }

    public void setTrackName(String trackName) {
        this.trackName = trackName;
    }

    public String getTrackDescription() {
        return trackDescription;
    }

    public void setTrackDescription(String trackDescription) {
        this.trackDescription = trackDescription;
    }

    public String getOrganism() {
        return organism;
    }

    public void setOrganism(String organism) {
        this.organism = organism;
    }

    public int getOrder() {
        return order;
    }

    public void setOrder(int order) {
        this.order = order;
    }
    
    public String getTrackLine(){
        return this.trackClass+","+this.settings;
    }

    public boolean isVisible() {
        return visible;
    }

    public void setVisible(boolean visible) {
        this.visible = visible;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public String getOriginalFile() {
        return originalFile;
    }

    public void setOriginalFile(String originalFile) {
        this.originalFile = originalFile;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public Timestamp getSetupTime() {
        return ts;
    }

    public void setSetupTime(Timestamp ts) {
        this.ts = ts;
    }

    public String getDBStatus() {
        return dbStatus;
    }

    public void setDBStatus(String dbStatus) {
        this.dbStatus = dbStatus;
    }

    public String getDefaultSettings(){
        String ret="";
        if(this.controls!=null) {
            String[] list = this.controls.split(",");
            for (int i = 0; i < list.length; i++) {
                String tmp = list[i].substring(list[i].indexOf("Default=") + 8);
                ret = ret + "," + tmp;
            }
            ret = ret.substring(1);
        }
        return ret;
    }

    /*public int getNextID(DataSource pool){
        int id=-1;
        String query="select Browser_Track_ID_SEQ.nextVal from dual";
        Connection conn=null;
        try{
            conn=pool.getConnection();
            PreparedStatement ps=conn.prepareStatement(query, 
						ResultSet.TYPE_SCROLL_INSENSITIVE,
						ResultSet.CONCUR_UPDATABLE);
            ResultSet rs=ps.executeQuery();
            if (rs.next()){
                id=rs.getInt(1);
            }
            ps.close();
            conn.close();
            conn=null;
        }catch(SQLException e){
            
        }finally{
            try{
            if(conn!=null&&!conn.isClosed()){
                conn.close();
                conn=null;
            }
            }catch(SQLException er){
                
            }
        }
        return id;
    }*/
    
    public int saveToDB(String genomeVer,DataSource pool){
        boolean success=false;
        String insertGV2Track="insert into browser_GV2TRACK (genome_id,trackid) values (?,?)";
        String insertUsage="insert into browser_tracks (USER_ID,TRACK_CLASS,"
                + "TRACK_NAME,TRACK_DESC,ORGANISM,CATEGORY_GENERIC,CATEGORY,DISPLAY_OPTS,"
                + "VISIBLE,CUSTOM_LOCATION,CUSTOM_DATE,CUSTOM_FILE_ORIGINAL,CUSTOM_TYPE) values (?,?,?,?,?,?,?,?,?,?,?,?,?)";
        try(Connection conn=pool.getConnection();){
            PreparedStatement ps=conn.prepareStatement(insertUsage, PreparedStatement.RETURN_GENERATED_KEYS);
            //ps.setInt(1, this.id);
            ps.setInt(1,this.userid);
            ps.setString(2, this.trackClass);
            ps.setString(3, this.trackName);
            ps.setString(4, this.trackDescription);
            ps.setString(5, this.organism.toUpperCase());
            ps.setString(6, this.genericCategory);
            ps.setString(7, this.category);
            ps.setString(8, this.controls);
            ps.setBoolean(9, this.visible);
            ps.setString(10, this.location);
            ps.setTimestamp(11,this.ts);
            ps.setString(12, this.originalFile);
            ps.setString(13, this.type);
            ps.executeUpdate();
            ResultSet rsID = ps.getGeneratedKeys();
            if (rsID.next()) {
                this.id = rsID.getInt(1);
            }
            ps.close();
            ps=conn.prepareStatement(insertGV2Track,
                    ResultSet.TYPE_SCROLL_INSENSITIVE,
                    ResultSet.CONCUR_UPDATABLE);
            ps.setString(1, genomeVer);
            ps.setInt(2,this.id);
            ps.execute();
            ps.close();
            success=true;
        }catch(SQLException e){
            e.printStackTrace(System.err);
            Logger log = Logger.getRootLogger();
            log.error("Error inserting custom track:",e);
            Email myAdminEmail = new Email();
            String fullerrmsg=e.getMessage();
            StackTraceElement[] tmpEx=e.getStackTrace();
            for(int i=0;i<tmpEx.length;i++){
                        fullerrmsg=fullerrmsg+"\n"+tmpEx[i];
            }
            myAdminEmail.setSubject("Exception thrown inserting a custom track");
            myAdminEmail.setContent("There was an error inserting a custom track.\n"+fullerrmsg);
            try {
                    myAdminEmail.sendEmailToAdministrator("");
            } catch (Exception mailException) {
                    log.error("error sending message", mailException);
                    throw new RuntimeException();
            }
        }
        
        return this.id;
    }
    
    public boolean deleteTrack(int trackid,DataSource pool){
        Logger log=Logger.getRootLogger();
        boolean ret=false;
        String deleteGV2Track="delete from BROWSER_GV2TRACK where trackid="+trackid;
        String settings="delete from BROWSER_TRACK_SETTINGS "+
                        "where tracksettingid in (select tracksettingid from browser_views_tracks where "+
                        "trackid="+trackid+" )";
        String trackquery="delete from browser_views_tracks where trackid="+trackid;
        String viewquery="delete from browser_tracks where trackid="+trackid;
                       
            Connection conn=null;
            PreparedStatement ps=null;
            try {
                conn=pool.getConnection();
                conn.setAutoCommit(false);
                ps = conn.prepareStatement(deleteGV2Track);
                ps.executeUpdate();
                ps.close();
                ps = conn.prepareStatement(settings);
                ps.executeUpdate();
                ps.close();
                ps = conn.prepareStatement(trackquery);
                ps.executeUpdate();
                ps.close();
                ps = conn.prepareStatement(viewquery);
                ps.executeUpdate();
                ps.close();
                conn.commit();
                conn.close();
                conn=null;
                ret=true;
            } catch (SQLException ex) {
                log.error("SQL Exception deleting custom track:" ,ex);
                try {
                    conn.rollback();
                    ps.close();
                } catch (Exception ex1) {
                }
            } finally{
                if(conn!=null){
                    try{
                        conn.close();
                        conn=null;
                    }catch(SQLException e){
                        
                    }
                    conn=null;
                }
            }
        return ret;
    }
}