package edu.ucdenver.ccp.PhenoGen.tools.analysis;


import edu.ucdenver.ccp.PhenoGen.tools.analysis.BrowserTrack;
import edu.ucdenver.ccp.PhenoGen.web.SessionHandler;
import edu.ucdenver.ccp.PhenoGen.web.mail.*;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Set;
import javax.sql.DataSource;
import oracle.jdbc.*;
import org.apache.log4j.Logger;

public class BrowserView{
    private int id=0;
    private int userID=0;
    private String name="";
    private String description="";
    private String organism="";
    private boolean visible=false;
    private String imageSettings="";
    private String bvGenomeVer="";
    private String UUID="";
    private String email="";
    private Timestamp created=null;
    private Timestamp lastAccessed=null;
    private ArrayList<BrowserTrack> btList=new ArrayList<BrowserTrack>();
    private ArrayList<BrowserTrack> btListToDelete=new ArrayList<BrowserTrack>();
    private Logger log=null;
    
    public BrowserView(){
        log=Logger.getRootLogger();
    }
    public BrowserView(int userid,String name,String description, String organism,boolean visible,String imgsetting,String bvGenomeVer){
        this(-1,userid,name,description,organism,visible,imgsetting,bvGenomeVer);
    }
    
    public BrowserView(int id,int userid,String name,String description, String organism,boolean visible,String imgsetting,String bvGenomeVer){
        log=Logger.getRootLogger();
        this.id=id;
        this.userID=userid;
        this.name=name;
        this.description=description;
        this.organism=organism;
        this.visible=visible;
        this.imageSettings=imgsetting;
        this.bvGenomeVer=bvGenomeVer;
    }
    

    public ArrayList<BrowserView> getBrowserViews(int userid,String genomeVer,String uuid,DataSource pool){
        Logger log=Logger.getRootLogger();

        ArrayList<BrowserView> ret=new ArrayList<BrowserView>();
        
        HashMap<Integer,BrowserView> hm=new HashMap<Integer,BrowserView>();
        
        String query="select bv.BVID,bv.USER_ID,bv.NAME,bv.DESCRIPTION,bv.ORGANISM,bv.VISIBLE,bv.IMAGE_SETTINGS,gbv.genome_id ";
        String queryP2="from BROWSER_VIEWS bv, BROWSER_GV2VIEW gbv "+
                        "where bv.user_id="+userid;
        if(uuid.equals("")){
            queryP2=queryP2+" and UUID is null ";
        }else{
            queryP2=queryP2+" and UUID='"+uuid+"' ";
        }
        /*if(genomeVer.indexOf(",")>-1){
            String[] genomes=genomeVer.split(",");
            queryP2=queryP2+" and ( gbv.genome_id = '"+genomes[0]+"' or "+
                        " gbv.genome_id = '"+genomes[1]+"' ) "+
                        " and gbv.BVID=bv.BVID"+
                        " and bv.visible=1";
        }else{*/
            queryP2=queryP2+" and gbv.genome_id = '"+genomeVer+"' "+
                        " and gbv.BVID=bv.BVID"+
                        " and bv.visible=1";
        //}
        /*queryP2=queryP2+" and gbv.BVID=bv.BVID"+
                        " and bv.visible=1";*/
        query=query+queryP2+" order by bv.bvid";
                        
        String trackquery="select bvt.bvid,bt.TRACKID, bt.USER_ID, bt.TRACK_CLASS, bt.TRACK_NAME, bt.TRACK_DESC, bt.ORGANISM, bt.CATEGORY_GENERIC, bt.CATEGORY, bt.DISPLAY_OPTS,"+
                        "bt.VISIBLE, bt.CUSTOM_LOCATION, bt.CUSTOM_DATE, bt.CUSTOM_FILE_ORIGINAL, bt.CUSTOM_TYPE,bts.settings,bvt.ordering,bts.TRACKSETTINGID "+
                        " from BROWSER_VIEWS_TRACKS bvt,BROWSER_TRACKS bt, BROWSER_TRACK_SETTINGS bts where "+
                        " bvt.trackid=bt.trackid and bvt.tracksettingid=bts.tracksettingid "+
                        " and bt.visible=1 "+
                        " and bvt.bvid in (select bv.bvid "+queryP2+" ) "+
                        " order by bvt.bvid,bvt.ordering";
            Connection conn=null;
            PreparedStatement ps=null;
            try {
                conn=pool.getConnection();
                log.debug("\n"+query+"\n");
                ps = conn.prepareStatement(query);
                ResultSet rs = ps.executeQuery();
                //int count=0;
                while(rs.next()){
                    int id=rs.getInt(1);
                    if(!hm.containsKey(id)){
                        int uid=rs.getInt(2);
                        String name=rs.getString(3);
                        String desc=rs.getString(4);
                        String org=rs.getString(5);
                        boolean vis=rs.getBoolean(6);
                        String imgsetting=rs.getString(7);
                        String bvGenomeVer=rs.getString(8);
                        BrowserView tmpBV=new BrowserView(id,uid,name,desc,org,vis,imgsetting,bvGenomeVer);
                        ret.add(tmpBV);
                        hm.put(id,tmpBV);
                    }else{
                        BrowserView tmpBV=hm.get(id);
                        String bvGenomeVer=rs.getString(8);
                        String tmpGV=tmpBV.getGenomeVersion();
                        tmpGV = tmpGV +","+ bvGenomeVer;
                        tmpBV.setGenomeVersion(tmpGV);
                    }
                    //count++;
                }
                ps.close();
                log.debug("\n"+trackquery+"\n");
                ps = conn.prepareStatement(trackquery);
                rs = ps.executeQuery();
                while(rs.next()){
                    int bvid=rs.getInt(1);
                    int tid=rs.getInt(2);
                    int uid=rs.getInt(3);
                    String tclass=rs.getString(4);
                    String name=rs.getString(5);
                    String desc=rs.getString(6);
                    String org=rs.getString(7);
                    String genCat=rs.getString(8);
                    String cat=rs.getString(9);
                    String controls=rs.getString(10);
                    boolean vis=rs.getBoolean(11);
                    String location=rs.getString(12);
                    Timestamp ts=rs.getTimestamp(13);
                    String file=rs.getString(14);
                    String type=rs.getString(15);
                    String sett=rs.getString(16);
                    int order=rs.getInt(17);
                    int settingID=rs.getInt(18);
                    BrowserTrack tmpBT=new BrowserTrack(tid,uid,tclass,name,desc,org,sett,order,genCat,cat,controls,vis,location,file,type,ts,genomeVer,settingID);
                    if(hm.containsKey(bvid)){
                        hm.get(bvid).addTrack(tmpBT);
                    }
                }
                ps.close();
                conn.close();
                conn=null;
            } catch (SQLException ex) {
                log.error("SQL Exception retreiving browser views:" ,ex);
                try {
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
    public BrowserView getBrowserView(int viewid,DataSource pool){
        Logger log=Logger.getRootLogger();
        BrowserView ret=null;
        String query="select bv.BVID,bv.USER_ID,bv.NAME,bv.DESCRIPTION,bv.ORGANISM,bv.VISIBLE,bv.IMAGE_SETTINGS,gbv.genome_id from BROWSER_VIEWS bv, BROWSER_GV2VIEW gbv "+
                        "where bv.bvid="+viewid+" and bv.bvid=gbv.bvid";
        String trackquery="select bvt.bvid,bt.TRACKID, bt.USER_ID, bt.TRACK_CLASS, bt.TRACK_NAME, bt.TRACK_DESC, bt.ORGANISM, bt.CATEGORY_GENERIC, bt.CATEGORY, bt.DISPLAY_OPTS,"+
                        "bt.VISIBLE, bt.CUSTOM_LOCATION, bt.CUSTOM_DATE, bt.CUSTOM_FILE_ORIGINAL, bt.CUSTOM_TYPE,bts.settings,bvt.ordering,bts.TRACKSETTINGID "+
                        " from BROWSER_VIEWS_TRACKS bvt,BROWSER_TRACKS bt, BROWSER_TRACK_SETTINGS bts "+
                        " where bvt.trackid=bt.trackid and bvt.tracksettingid=bts.tracksettingid "+
                        " and bt.visible=1 and bvt.bvid ="+viewid+" "+
                        " order by bvt.bvid,bvt.ordering";
            Connection conn=null;
            PreparedStatement ps=null;
            try {
                conn=pool.getConnection();
                ps = conn.prepareStatement(query);
                ResultSet rs = ps.executeQuery();
                //int count=0;
                if(rs.next()){
                    int id=rs.getInt(1);
                    int uid=rs.getInt(2);
                    String name=rs.getString(3);
                    String desc=rs.getString(4);
                    String org=rs.getString(5);
                    boolean vis=rs.getBoolean(6);
                    String imgsetting=rs.getString(7);
                    String bvGenomeVer=rs.getString(8);
                    ret=new BrowserView(id,uid,name,desc,org,vis,imgsetting,bvGenomeVer);
                    //count++;
                }
                ps.close();
                ps = conn.prepareStatement(trackquery);
                rs = ps.executeQuery();
                while(rs.next()){
                    int bvid=rs.getInt(1);
                    int tid=rs.getInt(2);
                    int uid=rs.getInt(3);
                    String tclass=rs.getString(4);
                    String name=rs.getString(5);
                    String desc=rs.getString(6);
                    String org=rs.getString(7);
                    String genCat=rs.getString(8);
                    String cat=rs.getString(9);
                    String controls=rs.getString(10);
                    boolean vis=rs.getBoolean(11);
                    String location=rs.getString(12);
                    Timestamp ts=rs.getTimestamp(13);
                    String file=rs.getString(14);
                    String type=rs.getString(15);
                    String sett=rs.getString(16);
                    int order=rs.getInt(17);
                    int settingID=rs.getInt(18);
                    BrowserTrack tmpBT=new BrowserTrack(tid,uid,tclass,name,desc,org,sett,order,genCat,cat,controls,vis,location,file,type,ts,bvGenomeVer,settingID);
                    ret.addTrack(tmpBT);
                }
                ps.close();
                conn.close();
                conn=null;
            } catch (SQLException ex) {
                log.error("SQL Exception retreiving browser views:" ,ex);
                try {
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
    public boolean deleteView(int viewid,DataSource pool){
        Logger log=Logger.getRootLogger();
        boolean ret=false;
        
        String settings="delete from BROWSER_TRACK_SETTINGS "+
                        "where tracksettingid in (select tracksettingid from browser_views_tracks where "+
                        "bvid="+viewid+" )";
        String trackquery="delete from browser_views_tracks where bvid="+viewid;
        String viewquery="delete from browser_views where bvid="+viewid;
                       
            Connection conn=null;
            PreparedStatement ps=null;
            try {
                conn=pool.getConnection();
                conn.setAutoCommit(false);
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
                log.error("SQL Exception retreiving browser views:" ,ex);
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
    public void addTrack(BrowserTrack toAdd){
        btList.add(toAdd);
    }

    public String getImageSettings() {
        return imageSettings;
    }

    public void setImageSettings(String imageSettings) {
        this.imageSettings = imageSettings;
    }

    public int getID() {
        return id;
    }

    public void setID(int id) {
        this.id = id;
    }

    public int getUserID() {
        return userID;
    }

    public void setUserID(int userID) {
        this.userID = userID;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getOrganism() {
        return organism;
    }

    public void setOrganism(String organism) {
        this.organism = organism;
    }
    
    public String getGenomeVersion() {
        return this.bvGenomeVer;
    }

    public void setGenomeVersion(String genomeVersion) {
        this.bvGenomeVer = genomeVersion;
    }

    public boolean isVisible() {
        return visible;
    }

    public void setVisible(boolean visible) {
        this.visible = visible;
    }

    public ArrayList<BrowserTrack> getTracks() {
        return btList;
    }

    public void setTracks(ArrayList<BrowserTrack> btList) {
        this.btList = btList;
    }

    public String getUUID() {
        return UUID;
    }

    public void setUUID(String UUID) {
        this.UUID = UUID;
    }

    public Timestamp getCreatedDate() {
        return created;
    }

    public void setCreatedDate(Timestamp created) {
        this.created = created;
    }

    public Timestamp getLastAccessed() {
        return lastAccessed;
    }

    public void setLastAccessed(Timestamp lastAccessed) {
        this.lastAccessed = lastAccessed;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    /*public int getNextID(DataSource pool){
        int id=-1;
        String query="select Browser_View_ID_SEQ.nextVal from dual";
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
    /*public int getNextTrackSettingID(DataSource pool){
        int id=-1;
        String query="select Browser_TrackSetting_ID_SEQ.nextVal from dual";
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
        String insertVersion="insert into browser_GV2VIEW (GENOME_ID,BVID) values(?,?)";
        String extraColumns="";
        String extraValues="";
        if(! this.UUID.equals("")){
            extraColumns=", UUID, CREATED,LAST_ACCESS ";
            extraValues=",?,?,?";
        }
        String insertUsage="insert into browser_views ("
                + "USER_ID,NAME,DESCRIPTION,ORGANISM,"
                + "VISIBLE,IMAGE_SETTINGS"+extraColumns+") values (?,?,?,?,?,?"+extraValues+")";
         String insertCount="insert into browser_view_counts (BVID,COUNTER) values (?,?)";

        try(Connection conn=pool.getConnection();){

            PreparedStatement ps=conn.prepareStatement(insertUsage, PreparedStatement.RETURN_GENERATED_KEYS);
            //ps.setInt(1, this.id);
            ps.setInt(1,this.userID);
            ps.setString(2, name);
            ps.setString(3, this.description);
            ps.setString(4, this.organism);
            ps.setBoolean(5,this.visible);
            ps.setString(6, this.imageSettings);
            if(! this.UUID.equals("")){
                ps.setString(7, this.UUID);
                ps.setTimestamp(8,this.created);
                ps.setTimestamp(9,this.created);
            }
            ps.executeUpdate();
            ResultSet rsID = ps.getGeneratedKeys();
            if (rsID.next()) {
                this.id = rsID.getInt(1);
            }
            ps.close();

            ps=conn.prepareStatement(insertCount, 
						ResultSet.TYPE_SCROLL_INSENSITIVE,
						ResultSet.CONCUR_UPDATABLE);
            ps.setInt(1,this.id);
            ps.setInt(2,0);
            ps.execute();
            ps.close();
            ps=conn.prepareStatement(insertVersion,
                    ResultSet.TYPE_SCROLL_INSENSITIVE,
                    ResultSet.CONCUR_UPDATABLE);
            ps.setString(1, genomeVer);
            ps.setInt(2, this.id);
            ps.execute();
            ps.close();
            success=true;
        }catch(SQLException e){
            e.printStackTrace(System.err);
            Logger log = Logger.getRootLogger();
            log.error("Error inserting new View:",e);
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
    public boolean copyTracksInView(int source,int dest,DataSource pool){
            boolean success=false;
            String query="select BVID, TRACKID, TRACKSETTINGID, ORDERING from BROWSER_VIEWS_TRACKS "+
                        "where bvid="+source;
            String insert="insert into BROWSER_VIEWS_TRACKS (BVID,TRACKID,TRACKSETTINGID,ORDERING) VALUES (?,?,?,?)";
            
            Connection conn=null;
            PreparedStatement ps=null;
           try{
                conn=pool.getConnection();
                PreparedStatement insertBVT=conn.prepareStatement(insert, 
						ResultSet.TYPE_SCROLL_INSENSITIVE,
						ResultSet.CONCUR_UPDATABLE);
                ps = conn.prepareStatement(query);
                ResultSet rs = ps.executeQuery();
                //int count=0;
                while(rs.next()){
                    int tid=rs.getInt(2);
                    int tsid=rs.getInt(3);
                    int order=rs.getInt(4);
                    int newTSID=-1;
                    boolean copied=false;
                    int preventLooping=0;
                    while(!copied && preventLooping<20){
                        //newTSID=getNextTrackSettingID(pool);
                        newTSID=copyTrackSettings(tsid,conn);
                        if(newTSID>0){
                            copied=true;
                        }
                        preventLooping++;
                    }
                    if(copied && newTSID>0){
                        insertBVT.setInt(1, dest);
                        insertBVT.setInt(2, tid);
                        insertBVT.setInt(3, newTSID);
                        insertBVT.setInt(4, order);
                        insertBVT.execute();
                        insertBVT.clearParameters();
                    }
                }
                insertBVT.close();
                ps.close();
                conn.close();
                conn=null;
                success=true;
            }catch(SQLException e){
                e.printStackTrace(System.err);
                Logger log = Logger.getRootLogger();
                log.error("Error copying View:",e);
                Email myAdminEmail = new Email();
                String fullerrmsg=e.getMessage();
                StackTraceElement[] tmpEx=e.getStackTrace();
                for(int i=0;i<tmpEx.length;i++){
                            fullerrmsg=fullerrmsg+"\n"+tmpEx[i];
                }
                myAdminEmail.setSubject("Exception thrown inserting a copied view");
                myAdminEmail.setContent("There was an error inserting a copied view.\n"+fullerrmsg);
                try {
                        myAdminEmail.sendEmailToAdministrator("");
                } catch (Exception mailException) {
                        log.error("error sending message", mailException);
                        throw new RuntimeException();
                }
            }finally{
                try{
                    if(conn!=null&&!conn.isClosed()){
                        conn.close();
                        conn=null;
                    }
                }catch(SQLException er){

                }
            }
        return success;
    }
        
    public int copyTrackSettings(int source,Connection conn){
        int dest=-1;
        try{
            String query="select TRACKSETTINGID, SETTINGS from BROWSER_TRACK_SETTINGS "+
                        "where tracksettingid="+source;
            String insert="insert into BROWSER_TRACK_SETTINGS (SETTINGS) VALUES (?)";
            PreparedStatement ps=null;
                PreparedStatement insertBTS=conn.prepareStatement(insert, PreparedStatement.RETURN_GENERATED_KEYS);
                ps = conn.prepareStatement(query);
                ResultSet rs = ps.executeQuery();
                //int count=0;
                if(rs.next()){
                    String settings=rs.getString(2);
                    //insertBTS.setInt(1, dest);
                    insertBTS.setString(1, settings);
                    insertBTS.executeUpdate();
                    ResultSet rsID = insertBTS.getGeneratedKeys();
                    if (rsID.next()) {
                        dest = rsID.getInt(1);
                    }
                    insertBTS.close();
                }
                ps.close();

        }catch(SQLException e){
             e.printStackTrace(System.err);
            Logger log = Logger.getRootLogger();
            log.error("Error copying track settings:",e);
            Email myAdminEmail = new Email();
            String fullerrmsg=e.getMessage();
            StackTraceElement[] tmpEx=e.getStackTrace();
            for(int i=0;i<tmpEx.length;i++){
                        fullerrmsg=fullerrmsg+"\n"+tmpEx[i];
            }
            myAdminEmail.setSubject("Exception thrown inserting a track setting");
            myAdminEmail.setContent("There was an error inserting a track setting.\n"+fullerrmsg);
            try {
                    myAdminEmail.sendEmailToAdministrator("");
            } catch (Exception mailException) {
                    log.error("error sending message", mailException);
                    throw new RuntimeException();
            }
        }
        return dest;
    }
    
    public String updateTracks(String tracks,DataSource pool){
            boolean success=false;
            String ret="";
            String queryAll="select bt.track_class,bvt.BVID, bvt.TRACKID, bvt.TRACKSETTINGID, bvt.ORDERING,bts.settings from BROWSER_VIEWS_TRACKS bvt,BROWSER_TRACK_SETTINGS bts, browser_tracks bt "+
                    "where bvt.bvid="+this.id+" and bvt.tracksettingid=bts.tracksettingid and bt.trackID=bvt.trackID";

            String query="select BVID,TRACKID,TRACKSETTINGID,ORDERING from BROWSER_VIEWS_TRACKS where bvid="+this.id+" and trackid=?";
            String querySettings="select TRACKSETTINGID,SETTINGS from BROWSER_TRACK_SETTINGS where TRACKSETTINGID=?";

            String queryTrackID="select trackid from BROWSER_TRACKS where TRACK_CLASS=?";
            
            String insert="insert into BROWSER_VIEWS_TRACKS (BVID,TRACKID,TRACKSETTINGID,ORDERING) VALUES (?,?,?,?)";
            String insertSettings="insert into BROWSER_TRACK_SETTINGS (SETTINGS) VALUES (?)";
            
            String updateOrder="update BROWSER_VIEWS_TRACKS set ORDERING=? where bvid="+this.id+ " and trackid=?";
            String updateSettings="update BROWSER_TRACK_SETTINGS set SETTINGS=? where TRACKSETTINGID=?";
            
            String delete="delete BROWSER_VIEWS_TRACKS where bvid="+this.id+" and trackid=?";
            String deleteSetting="delete BROWSER_TRACK_SETTINGS where tracksettingid=?";
            
            String[] trackList=tracks.split(";");

            PreparedStatement ps=null;
            HashMap<String,TrackSettings> hm=new HashMap<String,TrackSettings>();
           try(Connection conn=pool.getConnection();){
                ps = conn.prepareStatement(queryAll);
                ResultSet rs = ps.executeQuery();
                
                while(rs.next()){
                    String trClass=rs.getString(1);
                    int trackID=rs.getInt(3);
                    int trackSettingID=rs.getInt(4);
                    int order=rs.getInt(5);
                    String setting=rs.getString(6);
                    TrackSettings ts=new TrackSettings(trackID,trackSettingID,order,setting);
                    hm.put(trClass,ts);
                }
                ps.close();
                for(int i=0;i<trackList.length;i++){
                    String trackClass=trackList[i].substring(0, trackList[i].indexOf(","));
                    String setting=trackList[i].substring(trackList[i].indexOf(",")+1);
                    //String curDen=setting.substring(0,setting.indexOf(","));
                    //if(curDen.equals(den))
                    if(hm.containsKey(trackClass)){//check and update?
                        TrackSettings ts=hm.get(trackClass);
                        if(ts.getOrder() != i){
                            //update browser_view_tracks to change order
                            PreparedStatement ips = conn.prepareStatement(updateOrder);
                            ips.setInt(1,i);
                            ips.setInt(2, ts.getTrackID());
                            ips.execute();
                            ips.close();
                        }
                        if(!ts.getSettings().equals(setting)){
                            //update browser_track_settings to change settings
                            PreparedStatement ips = conn.prepareStatement(updateSettings);
                            ips.setString(1,setting);
                            ips.setInt(2, ts.getTrackSettingID());
                            ips.execute();
                            ips.close();
                        }
                        //mark as processed
                        ts.markProcessed();
                    }else{//insert
                        //get tracksettingid
                        int newSettingID=-1;//getNextTrackSettingID(pool);
                        int trackID=-1;
                        ps = conn.prepareStatement(queryTrackID);
                        ps.setString(1, trackClass);
                        rs = ps.executeQuery();
                        if(rs.next()){
                            trackID=rs.getInt(1);
                        }
                        ps.close();
                        if(trackID>0){
                            //insert browser track settings
                            PreparedStatement ips = conn.prepareStatement(insertSettings,PreparedStatement.RETURN_GENERATED_KEYS);
                            //ips.setInt(1,newSettingID);
                            ips.setString(1, setting);
                            ips.executeUpdate();
                            ResultSet rsID = ips.getGeneratedKeys();
                            if (rsID.next()) {
                                newSettingID = rsID.getInt(1);
                            }
                            ips.close();
                            //insert browser view tracks
                            ips = conn.prepareStatement(insert);
                            ips.setInt(1,this.id);
                            ips.setInt(2, trackID);
                            ips.setInt(3, newSettingID);
                            ips.setInt(4, i);
                            ips.execute();
                            ips.close();

                        }
                    }
                }
                Iterator itr=hm.keySet().iterator();
                while(itr.hasNext()){
                    TrackSettings ts=hm.get(itr.next());
                    if(!ts.isProcessed()){
                        //delete
                        ps = conn.prepareStatement(deleteSetting);
                        ps.setInt(1, ts.getTrackSettingID());
                        ps.execute();
                        ps.close();
                        ps = conn.prepareStatement(delete);
                        ps.setInt(1, ts.getTrackID());
                        ps.execute();
                        ps.close();
                    }
                }

                success=true;
            }catch(SQLException e){
                e.printStackTrace(System.err);
                Logger log = Logger.getRootLogger();
                log.error("Error copying View:",e);
                Email myAdminEmail = new Email();
                String fullerrmsg=e.getMessage();
                StackTraceElement[] tmpEx=e.getStackTrace();
                for(int i=0;i<tmpEx.length;i++){
                            fullerrmsg=fullerrmsg+"\n"+tmpEx[i];
                }
                myAdminEmail.setSubject("Exception thrown inserting a copied view");
                myAdminEmail.setContent("There was an error inserting a copied view.\n"+fullerrmsg);
                try {
                        myAdminEmail.sendEmailToAdministrator("");
                } catch (Exception mailException) {
                        log.error("error sending message", mailException);
                        throw new RuntimeException();
                }
            }
           ret="Completed";
           if(!success){
               ret="Error saving view.";
           }
        return ret;
    }


    public String saveTracksToDB(String countDensity,String countDefault,DataSource pool){
        boolean success=false;
        String ret="";

        String insert="insert into BROWSER_VIEWS_TRACKS (BVID,TRACKID,TRACKSETTINGID,ORDERING) VALUES (?,?,?,?)";
        String insertSettings="insert into BROWSER_TRACK_SETTINGS (SETTINGS) VALUES (?)";

        String settingQuery="select tracksettingid from BROWSER_VIEWS_TRACKS where bvid=? and trackid=?";

        String update="update BROWSER_VIEWS_TRACKS set ORDERING=? where bvid=? and trackid=?";
        String updateSettings="update BROWSER_TRACK_SETTINGS set SETTINGS=? where TRACKSETTINGID=?";

        String delete="delete from BROWSER_VIEWS_TRACKS where bvid=? and trackid=?";
        String deleteSetting="delete from BROWSER_TRACK_SETTINGS where tracksettingid in (select tracksettingid from BROWSER_VIEWS_TRACKS where bvid=? and trackid=?)";

        PreparedStatement ps=null;
        try(Connection conn=pool.getConnection();){
            log.debug("before update");
            for(int i=0;i<btList.size();i++){
                if(btList.get(i).getDBStatus().equals("update")) {
                    //update browser_view_tracks to change order
                    log.debug(update);
                    PreparedStatement ips = conn.prepareStatement(update);
                    ips.setInt(1, i);
                    ips.setInt(2,this.id);
                    ips.setInt(3, btList.get(i).getID());
                    ips.execute();
                    ips.close();
                    int settingID=btList.get(i).getSettingID();
                    if(settingID<0) {
                        ips = conn.prepareStatement(settingQuery);
                        ips.setInt(1, this.id);
                        ips.setInt(2, btList.get(i).getID());
                        ResultSet rs = ips.executeQuery();
                        if (rs.next()) {
                            settingID = rs.getInt(1);
                        }
                        ips.close();
                    }
                    if(settingID>-1) {
                        String setting = btList.get(i).getDefaultSettings();
                        String newSetting=setting;
                        if (btList.get(i).getTrackClass().indexOf("illuminaTotal") > -1) {
                            String[] settings=setting.split(",");
                            for(int j=0;j<settings.length;j++){
                                if(j==0){
                                    newSetting=countDensity;
                                }else if(j==2){
                                    newSetting =newSetting+","+countDefault ;
                                }else {
                                    newSetting = newSetting+ "," + settings[j];
                                }
                            }
                            //setting = countDensity + setting.substring(setting.indexOf(","));
                        }
                        PreparedStatement ips2 = conn.prepareStatement(updateSettings);
                        ips2.setString(1, newSetting);
                        ips2.setInt(2, settingID);
                        ips2.execute();
                        ips2.close();
                    }

                }
            }
            log.debug("update");

            for(int i=0;i<btList.size();i++){
                if(btList.get(i).getDBStatus().equals("add")) {
                    int newSettingID = -1;
                    //insert browser track settings
                    PreparedStatement ips = conn.prepareStatement(insertSettings, PreparedStatement.RETURN_GENERATED_KEYS);
                    //ips.setInt(1,newSettingID);
                    //log.debug("update");
                    //log.debug("setting:" + btList.get(i).getDefaultSettings());
                    String setting=btList.get(i).getDefaultSettings();
                    String newSetting=setting;
                    if(btList.get(i).getTrackClass().indexOf("illuminaTotal")>-1) {
                        String[] settings=setting.split(",");
                        for(int j=0;j<settings.length;j++){
                            if(j==0){
                                newSetting=countDensity;
                            }else if(j==2){
                                newSetting =newSetting+","+countDefault ;
                            }else {
                                newSetting = newSetting+ "," + settings[j];
                            }
                        }
                        //setting=countDensity+setting.substring(setting.indexOf(","));
                    }
                    ips.setString(1, newSetting);
                    ips.executeUpdate();
                    ResultSet rsID = ips.getGeneratedKeys();
                    if (rsID.next()) {
                        newSettingID = rsID.getInt(1);
                    }
                    ips.close();
                    //log.debug("before bvt insert");
                    //insert browser view tracks
                    if (newSettingID > 0) {
                        ips = conn.prepareStatement(insert);
                        ips.setInt(1, this.getID());
                        ips.setInt(2, btList.get(i).getID());
                        ips.setInt(3, newSettingID);
                        ips.setInt(4, i);
                        ips.execute();

                        ips.close();
                    }
                    //log.debug("after bvt");
                }
            }
            log.debug("insert");
            for(int i=0;i<btListToDelete.size();i++) {
                //delete
                log.debug(deleteSetting);
                ps = conn.prepareStatement(deleteSetting);
                ps.setInt(1,this.getID());
                ps.setInt(2,btListToDelete.get(i).getID());
                ps.execute();
                ps.close();
                log.debug("delete bvid:"+this.getID()+"::"+btListToDelete.get(i).getID());
                ps = conn.prepareStatement(delete);
                ps.setInt(1,this.getID());
                ps.setInt(2,btListToDelete.get(i).getID());
                ps.execute();
                ps.close();

            }
            log.debug("delete");
            btListToDelete=new ArrayList<>();
            success=true;
        }catch(SQLException e){
            e.printStackTrace(System.err);
            Logger log = Logger.getRootLogger();
            log.error("Error copying View:",e);
            Email myAdminEmail = new Email();
            String fullerrmsg=e.getMessage();
            StackTraceElement[] tmpEx=e.getStackTrace();
            for(int i=0;i<tmpEx.length;i++){
                fullerrmsg=fullerrmsg+"\n"+tmpEx[i];
            }
            myAdminEmail.setSubject("Exception thrown inserting a copied view");
            myAdminEmail.setContent("There was an error inserting a copied view.\n"+fullerrmsg);
            try {
                myAdminEmail.sendEmailToAdministrator("");
            } catch (Exception mailException) {
                log.error("error sending message", mailException);
                throw new RuntimeException();
            }
        }
        ret="Completed";
        if(!success){
            ret="Error saving view.";
        }
        return ret;
    }

    public void updateView(String countDensity,String countDefault,DataSource pool){
        log.debug("before update tracks to DB");
        saveTracksToDB(countDensity,countDefault,pool);
        log.debug("after update tracks to DB");
        if(!this.name.equals("") || !this.email.equals("")){
            try(Connection conn=pool.getConnection();){
                String update="update browser_views set name=?, ANON_email=? where bvid=?";
                PreparedStatement ips = conn.prepareStatement(update);
                ips.setString(1,this.name);
                ips.setString(2,this.email);
                ips.setInt(3,this.id);
                ips.execute();
                ips.close();
            }catch(SQLException e){
                log.error("Error saving view:",e);
            }
        }
    }

    public void updateTracks(ArrayList<BrowserTrack> tracks){
        HashMap<String,Integer> trackHM= new HashMap<>();
        ArrayList<BrowserTrack> newList= new ArrayList<>();
        for(int i=0;i<btList.size();i++){
            trackHM.put(btList.get(i).getTrackClass(),i);
        }
        for(int i=0;i<tracks.size();i++){
            if(trackHM.containsKey(tracks.get(i).getTrackClass())) {
                tracks.get(i).setDBStatus("update");
                btList.set(trackHM.get(tracks.get(i).getTrackClass()), tracks.get(i));
                trackHM.put(tracks.get(i).getTrackClass(),0);

            }else{
                tracks.get(i).setDBStatus("add");
                btList.add(tracks.get(i));
                trackHM.put(tracks.get(i).getTrackClass(),0);
            }
        }
        for(int i=0;i<btList.size();i++){
            if(trackHM.get(btList.get(i).getTrackClass())==0){
                newList.add(btList.get(i));
            }else{
                btList.get(i).setDBStatus("delete");
                btListToDelete.add(btList.get(i));
            }
        }
        this.btList=newList;
    }
    
}

class TrackSettings{
    private int trackID;
    private int trackSettingID;
    private int order;
    private String settings;
    private boolean processed=false;
    
    TrackSettings(int trackID,int trackSettingID,int order,String settings){
        this.trackID=trackID;
        this.trackSettingID=trackSettingID;
        this.order=order;
        this.settings=settings;
        this.processed=false;
    }

    public int getTrackID() {
        return trackID;
    }

    public int getTrackSettingID() {
        return trackSettingID;
    }

    public int getOrder() {
        return order;
    }

    public String getSettings() {
        return settings;
    }
    
    public boolean isProcessed(){
        return this.processed;
    }
    
    public void markProcessed(){
        this.processed=true;
    }

}