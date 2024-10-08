package edu.ucdenver.ccp.PhenoGen.data;


import java.sql.Date;
import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
/* for logging messages */
import org.apache.log4j.Logger;

/**
 * Class for handling data related to managing anonymous users.
 *
 * @author Spencer Mahaffey
 */

public class AnonUser {
    String uuid = "";
    String email = "";
    Date created = null;
    Date last_access = null;
    int access_count = 0;

    private Logger log = null;


    public AnonUser() {
        log = Logger.getRootLogger();
    }

    public String getUUID() {
        return uuid;
    }

    public void setUUID(String uuid) {
        this.uuid = uuid;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        if (email != null && !email.equals("null")) {
            this.email = email;
        }
    }

    public String getObfuscatedEmail() {
        String oEmail = "";
        int atInd = email.indexOf("@");
        if (atInd > -1) {
            oEmail = email.substring(0, 1);
            for (int i = 1; i < atInd; i++) {
                oEmail += "*";
            }
            oEmail += email.substring(atInd);
        }
        return oEmail;
    }

    public Date getCreated() {
        return created;
    }

    public void setCreated(Date created) {
        this.created = created;
    }

    public Date getLast_access() {
        return last_access;
    }

    public void setLast_access(Date last_access) {
        this.last_access = last_access;
    }

    public int getAccess_count() {
        return access_count;
    }

    public void setAccess_count(int access_count) {
        this.access_count = access_count;
    }


    public AnonUser createAnonUser(String uuid, DataSource pool) {
        String insert = "insert into ANON_USERS (UUID,CREATED,LAST_ACCESS,ACCESS_COUNT) VALUES (?,?,?,?)";

        try (Connection conn = pool.getConnection()) {
            Date created = new Date((new java.util.Date()).getTime());
            Date access = created;
            int count = 1;
            PreparedStatement ps = conn.prepareStatement(insert);
            ps.setString(1, uuid);
            ps.setDate(2, created);
            ps.setDate(3, access);
            ps.setInt(4, count);
            ps.execute();
        } catch (SQLException e) {

        }
        return this.getAnonUser(uuid, false, pool);
    }

    public void incrementLogin(DataSource pool) {
        String select = "select Access_count from Anon_users where uuid=?";
        String update = "update ANON_USERS set LAST_ACCESS = ?, ACCESS_Count=? where UUID=?";
        try (Connection conn = pool.getConnection()) {
            PreparedStatement ps1 = conn.prepareStatement(select);
            ps1.setString(1, uuid);
            ResultSet rs1 = ps1.executeQuery();
            int count = 1;
            if (rs1.next()) {
                count = rs1.getInt(1) + 1;
            }
            ps1.close();
            //Date time = new Date((new java.util.Date()).getTime());
            java.sql.Timestamp ts = new java.sql.Timestamp((new java.util.Date()).getTime());
            PreparedStatement ps = conn.prepareStatement(update);
            ps.setTimestamp(1, ts);
            ps.setInt(2, count);
            ps.setString(3, uuid);
            ps.executeUpdate();
        } catch (SQLException e) {
            log.error("Error updating anonymous login", e);
        }
    }

    public AnonUser linkEmail(String uuid, String email, DataSource pool) {
        String update = "update ANON_USERS set EMAIL = ? where UUID=?";
        String checkEmail = "select email from Anon_Users where UUID=?";
        try (Connection conn = pool.getConnection()) {
            PreparedStatement ps = conn.prepareStatement(checkEmail);
            ps.setString(1, uuid);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                if (rs.getString(1) == null) {
                    PreparedStatement ps2 = conn.prepareStatement(update);
                    ps2.setString(1, email);
                    ps2.setString(2, uuid);
                    ps2.execute();
                    ps2.close();
                }
            }
            rs.close();
            ps.close();
        } catch (SQLException e) {

        }
        return this.getAnonUser(uuid, false, pool);
    }


    public void linkGeneList(int glID, DataSource pool) throws SQLException {
        String insert = "insert into ANON_USER_GENELIST (UUID,GENELIST_ID) VALUES (?,?)";
        try (Connection conn = pool.getConnection()) {
            PreparedStatement ps = conn.prepareStatement(insert);
            ps.setString(1, uuid);
            ps.setInt(2, glID);
            ps.execute();
        } catch (SQLException e) {
            throw e;
        }
    }

    public AnonUser getAnonUser(String uuid, boolean increment, DataSource pool) {
        AnonUser ret = null;
        String select = "select Access_count from Anon_users where uuid=?";
        String update = "update Anon_users set ACCESS_COUNT=? where UUID=?";
        String selectAll = "select * from ANON_USERS where uuid=?";
        try (Connection conn = pool.getConnection()) {
            PreparedStatement ps = conn.prepareStatement(selectAll);
            ps.setString(1, uuid);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                ret = new AnonUser();
                ret.setUUID(rs.getString("UUID"));
                ret.setCreated(rs.getDate("CREATED"));
                ret.setLast_access(rs.getDate("LAST_ACCESS"));
                ret.setAccess_count(rs.getInt("ACCESS_COUNT"));
                ret.setEmail(rs.getString("EMAIL"));
            }
            rs.close();
            ps.close();
          /*if(increment){
                PreparedStatement ps1=conn.prepareStatement(select);
                ps1.setString(1, uuid);
                ResultSet rs1=ps1.executeQuery();
                int count=1;
                if(rs1.next()){
                    count=rs1.getInt(1)+1;
                }
                rs1.close();
                ps1.close();
                log.debug("get count:"+count);
                Date time = new Date((new java.util.Date()).getTime());
                log.debug("after date");
                //java.sql.Timestamp ts=new java.sql.Timestamp((new java.util.Date()).getTime());
                PreparedStatement ps2=conn.prepareStatement(update);
                log.debug("after prepare");
                //ps2.setDate(1, time);
                //log.debug("after time");
                ps2.setInt(1, count);
                log.debug("after count");
                ps2.setString(2, uuid);
                log.debug("after uuid");
                
                ps2.execute();
                log.debug("after execUpdate");
                ps2.close();
                log.debug("update ts/count");
          }*/

        } catch (SQLException e) {
            log.error("exception getting anon_user", e);
        }
        return ret;
    }

    public ArrayList<String> getAnonSessionListByEmail(String email, DataSource pool) {
        ArrayList<String> list = new ArrayList<String>();
        String select = "select uuid from ANON_USERS au,  where email=?";
        String selectCount = "select count(*) from Anon_user_genelist where uuid=?";
        try (Connection conn = pool.getConnection()) {
            PreparedStatement ps = conn.prepareStatement(select);
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                String uuid = rs.getString("uuid");
                PreparedStatement ps1 = conn.prepareStatement(selectCount);
                ps1.setString(1, uuid);
                ResultSet rs1 = ps1.executeQuery();
                if (rs1.next()) {
                    int count = rs1.getInt(1);
                    if (count > 0) {
                        list.add(uuid);
                    }
                }
            }
            rs.close();
            ps.close();
        } catch (SQLException e) {

        }
        return list;
    }

    public boolean mergeSessionTo(String uuidSource, String uuidDest, DataSource pool) throws SQLException {
        boolean ret = false;
        AnonGeneList agl = new AnonGeneList();
        boolean moved = agl.moveGeneListsToSession(uuidSource, uuidDest, pool);
        String delete = "delete from Anon_users where uuid=?";
        try (Connection conn = pool.getConnection()) {
            conn.setAutoCommit(false);
            PreparedStatement ps = conn.prepareStatement(delete);
            ps.setString(1, uuidSource);
            int del = ps.executeUpdate();
            if (del == 1 && moved) {
                ret = true;
                conn.commit();
            } else {
                conn.rollback();
            }

        } catch (SQLException e) {
            throw e;
        }
        return ret;
    }

}