package edu.ucdenver.ccp.PhenoGen.tools.analysis;


import edu.ucdenver.ccp.PhenoGen.data.User;
import edu.ucdenver.ccp.PhenoGen.tools.analysis.BrowserView;
import edu.ucdenver.ccp.PhenoGen.web.SessionHandler;
import edu.ucdenver.ccp.PhenoGen.web.mail.*;

import java.io.File;
import java.sql.*;
import java.util.ArrayList;
import java.util.Date;
import javax.servlet.http.HttpSession;
import javax.sql.DataSource;

import oracle.jdbc.*;
import org.apache.log4j.Logger;

public class BrowserTools {
    private DataSource pool = null;
    private HttpSession session = null;
    private Logger log = null;
    private String fullPath = "";

    public BrowserTools() {
        log = Logger.getRootLogger();
    }

    public BrowserTools(HttpSession session) {
        log = Logger.getRootLogger();
        this.session = session;
        this.pool = (DataSource) session.getAttribute("dbPool");
    }

    public void setSession(HttpSession session) {
        this.session = session;
        this.pool = (DataSource) session.getAttribute("dbPool");
        String contextRoot = (String) session.getAttribute("contextRoot");
        String appRoot = (String) session.getAttribute("applicationRoot");
        this.fullPath = appRoot + contextRoot;
    }

    public ArrayList<BrowserView> getBrowserViews(String genomeVer, String uuid) {
        BrowserView bv = new BrowserView();
        ArrayList<BrowserView> ret = bv.getBrowserViews(0, genomeVer, "", pool);
        int userID = ((User) session.getAttribute("userLoggedIn")).getUser_id();
        if (userID > 0) {
            ArrayList<BrowserView> tmp = bv.getBrowserViews(userID, genomeVer, uuid, pool);
            if (tmp.size() > 0) {
                ret.addAll(tmp);
            }
        }
        return ret;
    }

    public ArrayList<BrowserTrack> getBrowserTracks(String genomeVer) {
        BrowserTrack bv = new BrowserTrack();
        ArrayList<BrowserTrack> ret = bv.getBrowserTracks(0, genomeVer, pool);
        int userID = ((User) session.getAttribute("userLoggedIn")).getUser_id();
        log.debug("getBROWSERTRACK():uid:" + userID);
        if (userID > 0) {
            ArrayList<BrowserTrack> tmp = bv.getBrowserTracks(userID, genomeVer, pool);
            if (tmp.size() > 0) {
                ret.addAll(tmp);
            }
        }
        return ret;
    }

    public int createCustomTrack(int uid, String trackclass, String trackname, String description, String organism, String genomeVer, String settings, int order, String genCat, String category, String controls, Boolean vis, String location, String fileName, String type) {
        BrowserTrack bt = new BrowserTrack();
        int trackID = -1;
        BrowserTrack newTrack = new BrowserTrack(uid, trackclass, trackname, description, organism, settings, order, genCat, category, controls, vis, location, fileName, type, new Timestamp((new Date()).getTime()), genomeVer, -1);
        trackID = newTrack.saveToDB(genomeVer, pool);
        return trackID;
    }

    public int createBlankView(String name, String description, String organism, String genomeVer, String imgDisp) {
        BrowserView bv = new BrowserView();
        int viewID = -1;
        int userID = ((User) session.getAttribute("userLoggedIn")).getUser_id();
        BrowserView newView = new BrowserView(userID, name, description, organism.toUpperCase(), true, imgDisp, genomeVer);
        viewID = newView.saveToDB(genomeVer, pool);
        return viewID;
    }

    public int createBlankView(String UUID, String name, String description, String organism, String genomeVer, String imgDisp) {
        BrowserView bv = new BrowserView();
        int viewID = -1;
        int userID = ((User) session.getAttribute("userLoggedIn")).getUser_id();
        BrowserView newView = new BrowserView(userID, name, description, organism.toUpperCase(), true, imgDisp, genomeVer);
        newView.setUUID(UUID);
        newView.setCreatedDate(new Timestamp((new Date()).getTime()));
        viewID = newView.saveToDB(genomeVer, pool);
        return viewID;
    }

    public int createCopiedView(String name, String description, String organism, String genomeVer, String imgDisp, int copyFrom) {
        BrowserView bv = new BrowserView();
        int ret = -1;
        int viewID = -1;
        int userID = ((User) session.getAttribute("userLoggedIn")).getUser_id();
        BrowserView newView = new BrowserView(userID, name, description, organism.toUpperCase(), true, imgDisp, genomeVer);
        viewID = newView.saveToDB(genomeVer, pool);
        //copy tracks and settings
        boolean success = false;
        if (viewID > 0) {
            success = bv.copyTracksInView(copyFrom, newView.getID(), pool);
        }
        if (success) {
            ret = viewID;
        }
        return ret;
    }

    public boolean editCustomView(String trackString, int viewID, int userID, String name, String email, String genomeVer, int datasetVer, String countDefault, String strainList, String countDensity) {
        boolean success = false;
        BrowserView bv = new BrowserView();
        BrowserTrack bt = new BrowserTrack();

        BrowserView curView = bv.getBrowserView(viewID, pool);
        log.debug("GOT curView");
        log.debug(trackString);
        String[] checkBoxes = trackString.split(",");
        //Get BrowserTracks that fit trackString
        ArrayList<BrowserTrack> tracks = bt.getBrowserTracks(checkBoxes, genomeVer, datasetVer, pool);
        log.debug("got tracks");

        curView.updateTracks(tracks);
        log.debug("update tracks");
        curView.setName(name);
        curView.setEmail(email);
        curView.updateView(countDensity, countDefault, pool);
        log.debug("update view");
        success = true;

        return success;
    }

    public String updateView(int id, String tracks) {
        String ret = "";
        BrowserView bv = new BrowserView();
        BrowserView toUpdate = bv.getBrowserView(id, pool);
        int userID = ((User) session.getAttribute("userLoggedIn")).getUser_id();
        if (toUpdate != null) {
            if (toUpdate.getUserID() == userID && toUpdate.getUserID() > 0) {
                toUpdate.updateTracks(tracks, pool);
            } else {
                ret = "Edit View:Permission Denied";
            }
        } else {
            ret = "View not found.";
        }
        return ret;
    }

    public String deleteBrowserView(int id) {
        String ret = "";
        BrowserView bv = new BrowserView();
        BrowserView toDelete = bv.getBrowserView(id, pool);
        int userID = ((User) session.getAttribute("userLoggedIn")).getUser_id();
        if (toDelete != null) {
            if (toDelete.getUserID() == userID && toDelete.getUserID() > 0) {
                boolean success = bv.deleteView(id, pool);
                if (success) {
                    ret = "Deleted Successfully";
                } else {
                    ret = "An Error occurred the view was not deleted.";
                }
            } else {
                ret = "Delete View:Permission Denied";
            }
        } else {
            ret = "View not found.";
        }
        return ret;
    }

    public void addViewCount(int id) {
        String update = "update browser_view_counts set counter=(counter+1) where bvid=" + id;
        Connection conn = null;
        try {
            conn = pool.getConnection();
            PreparedStatement ps = conn.prepareStatement(update,
                    ResultSet.TYPE_SCROLL_INSENSITIVE,
                    ResultSet.CONCUR_UPDATABLE);
            ps.execute();
            ps.close();
            conn.close();
            conn = null;
        } catch (SQLException e) {
            e.printStackTrace(System.err);
            Logger log = Logger.getRootLogger();
            log.error("Error incrementing BrowserViewCount", e);
            Email myAdminEmail = new Email();
            String fullerrmsg = e.getMessage();
            StackTraceElement[] tmpEx = e.getStackTrace();
            for (int i = 0; i < tmpEx.length; i++) {
                fullerrmsg = fullerrmsg + "\n" + tmpEx[i];
            }
            myAdminEmail.setSubject("Exception thrown incrementing BrowserViewCount");
            myAdminEmail.setContent("There was an error incrementing BrowserViewCount.\n" + fullerrmsg);
            try {
                myAdminEmail.sendEmailToAdministrator("");
            } catch (Exception mailException) {
                log.error("error sending message", mailException);
                throw new RuntimeException();
            }
        } finally {
            try {
                if (conn != null && !conn.isClosed()) {
                    conn.close();
                    conn = null;
                }
            } catch (SQLException er) {

            }
        }
    }

    public String deleteCustomTrack(int id) {
        String ret = "";
        BrowserTrack bt = new BrowserTrack();
        BrowserTrack toDelete = bt.getBrowserTrack(id, pool);
        int userID = ((User) session.getAttribute("userLoggedIn")).getUser_id();
        if (toDelete != null) {
            if (toDelete.getUserID() == userID && toDelete.getUserID() > 0) {
                boolean success = bt.deleteTrack(id, pool);
                if (success) {
                    ret = "Deleted Successfully";
                    if (toDelete.getType().equals("bed") || toDelete.getType().equals("bg")) {
                        //delete files too
                        File source = new File(fullPath + "tmpData/trackUpload/" + toDelete.getLocation());
                        File dest = new File(fullPath + "tmpData/toDelete/" + toDelete.getLocation());
                        source.renameTo(dest);
                    }
                } else {
                    ret = "An Error occurred the track was not deleted.";
                }
            } else {
                ret = "Delete View:Permission Denied";
            }
        } else {
            ret = "View not found.";
        }
        return ret;
    }

    public String getBrowserEnsemblDatabase(String genomeVer) {
        String ret = "";
        log.debug("start");
        try (Connection conn = pool.getConnection()) {
            log.debug("try");
            PreparedStatement ps = conn.prepareStatement("select ensembl_db from browser_genome_versions where genome_id='" + genomeVer + "'");
            log.debug(ps);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                ret = rs.getString(1);
            }
            ps.close();
        } catch (SQLException e) {
            e.printStackTrace(System.err);
            log.error("Error getting Ensembl DB version string.", e);
            Email myAdminEmail = new Email();
            String fullerrmsg = e.getMessage();
            StackTraceElement[] tmpEx = e.getStackTrace();
            for (int i = 0; i < tmpEx.length; i++) {
                fullerrmsg = fullerrmsg + "\n" + tmpEx[i];
            }
            myAdminEmail.setSubject("Exception thrown getting Ensembl DB version string");
            myAdminEmail.setContent("There was an error getting Ensembl DB version string.\n" + fullerrmsg);
            try {
                myAdminEmail.sendEmailToAdministrator("");
            } catch (Exception mailException) {
                log.error("error sending message", mailException);
                throw new RuntimeException();
            }
        }
        return ret;
    }
}