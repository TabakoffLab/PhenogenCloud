package edu.ucdenver.ccp.PhenoGen.data;

import edu.ucdenver.ccp.PhenoGen.util.DbUtils;
import edu.ucdenver.ccp.util.Debugger;
import edu.ucdenver.ccp.util.ObjectHandler;
import edu.ucdenver.ccp.util.sql.*;

import java.io.*;
import java.sql.*;
import java.util.*;
import javax.sql.DataSource;

import org.apache.log4j.Logger;

/**
 * Class for handling data related to managing executions of programs for interpreting gene lists.
 *
 * @author Cheryl Hornbaker
 */


public class GeneListAnalysis {
    private int analysis_id;
    private int gene_list_id;
    private int user_id;
    private int parameter_group_id;
    private java.sql.Timestamp create_date;
    private String create_date_as_string;
    private String create_date_for_filename;
    private String analysis_type;
    private String description;
    private int visible = 0;
    private GeneList analysisGeneList;
    private String sortColumn;
    private String sortOrder;
    private ParameterValue[] parameterValues;
    private String name = "";
    private String status = "";
    private String path = "";
    private long excessiveTimeLimit = (24 * 60 * 60 * 1000);


    private Logger log = null;

    private DbUtils myDbUtils = new DbUtils();
    private Debugger myDebugger = new Debugger();

    public GeneListAnalysis() {
        log = Logger.getRootLogger();
    }

    public GeneListAnalysis(int analysis_id) throws SQLException {
        log = Logger.getRootLogger();
        setAnalysis_id(analysis_id);
    }

    public GeneListAnalysis(int analysis_id, DataSource pool) throws SQLException {
        log = Logger.getRootLogger();
        getGeneListAnalysis(analysis_id, pool);
    }

    public int getAnalysis_id() {
        return analysis_id;
    }

    public void setAnalysis_id(int inInt) {
        this.analysis_id = inInt;
    }

    public int getGene_list_id() {
        return gene_list_id;
    }

    public void setGene_list_id(int inInt) {
        this.gene_list_id = inInt;
    }

    public void setUser_id(int inInt) {
        this.user_id = inInt;
    }

    public int getUser_id() {
        return user_id;
    }

    public void setParameter_group_id(int inInt) {
        this.parameter_group_id = inInt;
    }

    public int getParameter_group_id() {
        return parameter_group_id;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String inString) {
        this.description = inString;
    }

    public String getAnalysis_type() {
        return analysis_type;
    }

    public void setAnalysis_type(String inString) {
        this.analysis_type = inString;
    }

    public void setCreate_date(java.sql.Timestamp inTimestamp) {
        this.create_date = inTimestamp;
    }

    public java.sql.Timestamp getCreate_date() {
        return create_date;
    }

    public void setCreate_date_as_string(String inString) {
        this.create_date_as_string = inString;
    }

    public String getCreate_date_as_string() {
        return create_date_as_string;
    }

    public void setCreate_date_for_filename(String inString) {
        this.create_date_for_filename = inString;
    }

    public String getCreate_date_for_filename() {
        return create_date_for_filename;
    }

    public GeneList getAnalysisGeneList() {
        return analysisGeneList;
    }

    public void setAnalysisGeneList(GeneList inGeneList) {
        this.analysisGeneList = inGeneList;
    }

    public ParameterValue[] getParameterValues() {
        return parameterValues;
    }

    public void setParameterValues(ParameterValue[] inParameterValues) {
        this.parameterValues = inParameterValues;
    }

    public void setVisible(int inInt) {
        this.visible = inInt;
    }

    public int getVisible() {
        return visible;
    }

    public String getSortColumn() {
        return sortColumn;
    }

    public void setSortColumn(String inString) {
        this.sortColumn = inString;
    }

    public String getSortOrder() {
        return sortOrder;
    }

    public void setSortOrder(String inString) {
        this.sortOrder = inString;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getPath() {
        return path;
    }

    public void setPath(String path) {
        this.path = path;
    }

    /**
     * Creates a record in the gene_list_analysis table.
     *
     * @param conn the database connection
     * @return the id of the record created
     * @throws SQLException if a database error occurs
     */
    public int createGeneListAnalysis(DataSource pool) throws SQLException {
        int analysis_id = -99;
        GeneList myGeneList = new GeneList();
        log.debug("analysis_id = , gene_list_id = " + this.getGene_list_id());
        String query =
                "insert into gene_list_analyses " +
                        "( gene_list_id, user_id, parameter_group_id, analysis_type, " +
                        "create_date, description, visible,name,status,path) values " +
                        "( ?, ?, ?, ?, " +
                        "?, ?, ?, ?, ?, ?)";

        try (Connection conn = pool.getConnection()) {
            log.debug("in GeneListAnalysis.createGeneListAnalysis.");
            PreparedStatement pstmt = conn.prepareStatement(query, PreparedStatement.RETURN_GENERATED_KEYS);
            //pstmt.setInt(1, analysis_id);
            pstmt.setInt(1, this.getGene_list_id());
            pstmt.setInt(2, this.getUser_id());
            pstmt.setInt(3, this.getParameter_group_id());
            pstmt.setString(4, this.getAnalysis_type());
            pstmt.setTimestamp(5, this.getCreate_date());
            pstmt.setString(6, this.getDescription());
            pstmt.setInt(7, this.getVisible());
            pstmt.setString(8, this.getName());
            pstmt.setString(9, this.getStatus());
            pstmt.setString(10, this.getPath());
            pstmt.executeUpdate();
            ResultSet rs = pstmt.getGeneratedKeys();
            if (rs.next()) {
                analysis_id = rs.getInt(1);
                this.setAnalysis_id(analysis_id);
            }
            pstmt.close();
        } catch (SQLException e) {
            log.error("Error creating genelist", e);
            throw e;
        }

        for (int i = 0; i < this.getParameterValues().length; i++) {
            ParameterValue thisParameterValue = this.getParameterValues()[i];
            log.debug(i + ": Parameter Value:" + thisParameterValue.getValue() + ":" + thisParameterValue.getParameter());
            thisParameterValue.createParameterValue(pool);
        }
        return analysis_id;
    }

    /**
     * Returns all of the gene list analysis results for this gene_list_id
     *
     * @param gene_list_id the identifier of the gene_list
     * @param conn         the database connection
     * @return an array of the results
     * @throws SQLException if a database error occurs
     */
    public GeneListAnalysis[] getAllGeneListAnalysisResults(int gene_list_id, DataSource pool) throws SQLException {
        String query =
                "select ga.analysis_id, " +
                        "ga.description, " +
                        "gl.gene_list_id, " +
                        "date_format(ga.create_date, '%m/%d/%Y %h:%i %p'), " +
                        "ga.user_id, " +
                        "date_format(ga.create_date, '%m%d%Y_%H%i%S'), " +
                        "ga.analysis_type, " +
                        "ga.visible, " +
                        "ga.name, " +
                        "ga.status, " +
                        "ga.path, " +
                        "ga.parameter_group_id " +
                        "from gene_list_analyses ga, gene_lists gl " +
                        "where ga.gene_list_id = gl.gene_list_id " +
                        "and gl.gene_list_id = ? " +
                        "order by ga.create_date desc";

        //log.debug("in getAllGeneListAnalysisResults");
        //log.debug("query = " + query);
        List<GeneListAnalysis> myGeneListAnalysisResults = new ArrayList<GeneListAnalysis>();
        try (Connection conn = pool.getConnection()) {
            Results myResults = new Results(query, gene_list_id, conn);
            String[] dataRow;

            while ((dataRow = myResults.getNextRow()) != null) {
                GeneListAnalysis newGeneListAnalysis = setupGeneListAnalysisValues(dataRow);
                newGeneListAnalysis.setAnalysisGeneList(new GeneList().getGeneList(newGeneListAnalysis.getGene_list_id(), pool));
                myGeneListAnalysisResults.add(newGeneListAnalysis);
            }
            myResults.close();
        } catch (SQLException e) {
            log.debug("SQL Error:", e);
            throw e;
        }
        GeneListAnalysis[] myGeneListAnalysisResultArray = (GeneListAnalysis[]) myGeneListAnalysisResults.toArray(
                new GeneListAnalysis[myGeneListAnalysisResults.size()]);
        return myGeneListAnalysisResultArray;
    }


    /**
     * Returns the particular gene list analysis type results for this user and/or gene_list_id
     *
     * @param user_id       the identifier of the user
     * @param gene_list_id  the identifier of the gene_list
     * @param analysis_type the type of analysis
     * @param conn          the database connection
     * @return an array of the results
     * @throws SQLException if a database error occurs
     */

    public GeneListAnalysis[] getGeneListAnalysisResults(int user_id, int gene_list_id,
                                                         String analysis_type, DataSource pool) throws SQLException {
        SQLException err = null;
        GeneListAnalysis[] ret = new GeneListAnalysis[0];
        try (Connection conn = pool.getConnection()) {

            String query =
                    "select ga.analysis_id, " +
                            "ga.description, " +
                            "gl.gene_list_id, " +
                            "date_format(ga.create_date, '%m/%d/%Y %h:%i %p'), " +
                            "ga.user_id, " +
                            "date_format(ga.create_date, '%m%d%Y_%H%i%S'), " +
                            "ga.analysis_type, " +
                            "ga.visible, " +
                            "ga.name, " +
                            "ga.status, " +
                            "ga.path, " +
                            "ga.parameter_group_id " +
                            "from gene_list_analyses ga, gene_lists gl " +
                            "where ga.user_id = ? " +
                            "and ga.gene_list_id = gl.gene_list_id " +
                            "and ga.visible = 1 " +
                            "and ga.analysis_type = ? ";
            if (gene_list_id != -99) {
                query = query + "and gl.gene_list_id = ? ";
            }
            query = query +
                    "order by ga.create_date desc";

            log.debug("in getGeneListAnalysisResults");
            //log.debug("query = " + query);
            List<GeneListAnalysis> myGeneListAnalysisResults = new ArrayList<GeneListAnalysis>();

            Object[] parameters = new Object[3];
            parameters[0] = user_id;
            parameters[1] = analysis_type;
            if (gene_list_id != -99) {
                parameters[2] = gene_list_id;
            }
            Results myResults = new Results(query, parameters, conn);
            String[] dataRow;
            GeneList curGeneList = new GeneList().getGeneList(gene_list_id, pool);
            while ((dataRow = myResults.getNextRow()) != null) {
                GeneListAnalysis newGeneListAnalysis = setupGeneListAnalysisValues(dataRow);
                newGeneListAnalysis.setAnalysisGeneList(curGeneList);
                myGeneListAnalysisResults.add(newGeneListAnalysis);
            }
            myResults.close();

            ret = myGeneListAnalysisResults.toArray(new GeneListAnalysis[myGeneListAnalysisResults.size()]);

            log.debug("finished getGeneListAnalysisResults");
        } catch (SQLException e) {
            log.debug("SQL ERROR: ", e);
            throw e;
        }
        return ret;
    }

    /**
     * Returns the particular gene list analysis type results for this user and/or gene_list_id
     *
     * @param user_id       the identifier of the user
     * @param gene_list_id  the identifier of the gene_list
     * @param analysis_type the type of analysis
     * @param conn          the database connection
     * @return an array of the results
     * @throws SQLException if a database error occurs
     */
    public GeneListAnalysis[] getAnonGeneListAnalysisResults(int user_id, int gene_list_id, String analysis_type, DataSource pool) throws SQLException {
        SQLException err = null;
        GeneListAnalysis[] ret = new GeneListAnalysis[0];
        String query =
                "select ga.analysis_id, " +
                        "ga.description, " +
                        "gl.gene_list_id, " +
                        "date_format(ga.create_date, '%m/%d/%Y %h:%i %p'), " +
                        "ga.user_id, " +
                        "date_format(ga.create_date, '%m%d%Y_%H%i%S'), " +
                        "ga.analysis_type, " +
                        "ga.visible, " +
                        "ga.name, " +
                        "ga.status, " +
                        "ga.path, " +
                        "ga.parameter_group_id " +
                        "from gene_list_analyses ga, gene_lists gl " +
                        "where ga.user_id = ? " +
                        "and ga.gene_list_id = gl.gene_list_id " +
                        "and ga.visible = 1 " +
                        "and ga.analysis_type = ? ";
        if (gene_list_id != -99) {
            query = query + "and gl.gene_list_id = ? ";
        }
        query = query +
                "order by ga.create_date desc";

        log.debug("in getGeneListAnalysisResults");
        log.debug("query = " + query);
        List<GeneListAnalysis> myGeneListAnalysisResults = new ArrayList<GeneListAnalysis>();
        try (Connection conn = pool.getConnection()) {
            Object[] parameters = new Object[3];
            parameters[0] = user_id;
            parameters[1] = analysis_type;
            if (gene_list_id != -99) {
                parameters[2] = gene_list_id;
            }
            Results myResults = new Results(query, parameters, conn);
            String[] dataRow;
            GeneList curGeneList = new AnonGeneList().getGeneList(gene_list_id, pool);
            while ((dataRow = myResults.getNextRow()) != null) {
                GeneListAnalysis newGeneListAnalysis = setupGeneListAnalysisValues(dataRow);
                newGeneListAnalysis.setAnalysisGeneList(curGeneList);
                myGeneListAnalysisResults.add(newGeneListAnalysis);
            }
            myResults.close();

            ret = myGeneListAnalysisResults.toArray(new GeneListAnalysis[myGeneListAnalysisResults.size()]);
            log.debug("finished getGeneListAnalysisResults");
        } catch (SQLException e) {
            log.debug("SQL Exception:", e);
            throw e;
        }
        return ret;
    }


    /**
     * Creates a new GeneListAnalysis object and sets the data values to those retrieved from the database.
     *
     * @param dataRow the row of data corresponding to one GeneListAnalysis
     * @return a GeneListAnalysisobject with its values setup
     */
    private GeneListAnalysis setupGeneListAnalysisValues(String[] dataRow) {

        //log.debug("in setupGeneListAnalysisValues");
        //log.debug("dataRow= "); new Debugger().print(dataRow);

        GeneListAnalysis newGeneListAnalysis = new GeneListAnalysis();

        newGeneListAnalysis.setAnalysis_id(Integer.parseInt(dataRow[0]));
        newGeneListAnalysis.setDescription(dataRow[1]);
        newGeneListAnalysis.setGene_list_id(Integer.parseInt(dataRow[2]));
        newGeneListAnalysis.setCreate_date_as_string(dataRow[3]);
        newGeneListAnalysis.setCreate_date(new ObjectHandler().getDisplayDateAsTimestamp(dataRow[3]));
        newGeneListAnalysis.setUser_id(Integer.parseInt(dataRow[4]));
        newGeneListAnalysis.setCreate_date_for_filename(dataRow[5]);
        newGeneListAnalysis.setAnalysis_type(dataRow[6]);
        newGeneListAnalysis.setVisible(Integer.parseInt(dataRow[7]));
        newGeneListAnalysis.setName(dataRow[8]);
        newGeneListAnalysis.setStatus(dataRow[9]);
        newGeneListAnalysis.setPath(dataRow[10]);
        if (dataRow.length > 11 && dataRow[11] != null && !dataRow[11].equals("")) {
            newGeneListAnalysis.setParameter_group_id(Integer.parseInt(dataRow[11]));
        } else {
            newGeneListAnalysis.setParameter_group_id(-99);
        }

        //check for long running probably an error
        if (newGeneListAnalysis.getStatus() != null && newGeneListAnalysis.getStatus().equals("Running")) {
            java.util.Date cur = new java.util.Date();
            long diff = cur.getTime() - newGeneListAnalysis.getCreate_date().getTime();
            if (diff > excessiveTimeLimit) {
                newGeneListAnalysis.setStatus("Error");
            }
        }

        return newGeneListAnalysis;
    }


    public GeneListAnalysis getAnonGeneListAnalysis(int analysis_id, DataSource pool) throws SQLException {

        SQLException err = null;
        GeneListAnalysis newGeneListAnalysis = new GeneListAnalysis();
        try (Connection conn = pool.getConnection()) {

            String query =
                    "select ga.analysis_id, " +
                            "ga.description, " +
                            "ga.gene_list_id, " +
                            "date_format(ga.create_date, '%m/%d/%Y %h:%i %p'), " +
                            "ga.user_id, " +
                            "date_format(ga.create_date, '%m%d%Y_%H%i%S'), " +
                            "ga.analysis_type, " +
                            "ga.visible, " +
                            "ga.name, " +
                            "ga.status, " +
                            "ga.path, " +
                            "ga.parameter_group_id " +
                            "from gene_list_analyses ga " +
                            "where ga.analysis_id = ? " +
                            "and ga.visible = 1";

            log.debug("in getGeneListAnalysis");
            //log.debug("query = " + query);

            Results myResults = new Results(query, analysis_id, conn);
            String[] dataRow;


            while ((dataRow = myResults.getNextRow()) != null) {
                newGeneListAnalysis = setupGeneListAnalysisValues(dataRow);
                ParameterValue[] myParameterValues =
                        new ParameterValue().getParameterValues(newGeneListAnalysis.getParameter_group_id(), pool);
                newGeneListAnalysis.setParameterValues(myParameterValues);
                newGeneListAnalysis.setAnalysisGeneList(new AnonGeneList().getGeneList(newGeneListAnalysis.getGene_list_id(), pool));
            }
            myResults.close();


        } catch (SQLException e) {
            log.debug("SQL Error:", e);
            throw (e);
        }
        return newGeneListAnalysis;
    }

    /**
     * Returns the gene list analysis results for this analysis_id.
     *
     * @param analysis_id the identifier of the analysis record
     * @return the GeneListAnalysis object
     * @throws SQLException if a database error occurs
     */

    public GeneListAnalysis getGeneListAnalysis(int analysis_id, DataSource pool) throws SQLException {

        SQLException err = null;
        GeneListAnalysis newGeneListAnalysis = new GeneListAnalysis();
        try (Connection conn = pool.getConnection()) {
            String query =
                    "select ga.analysis_id, " +
                            "ga.description, " +
                            "ga.gene_list_id, " +
                            "date_format(ga.create_date, '%m/%d/%Y %h:%i %p'), " +
                            "ga.user_id, " +
                            "date_format(ga.create_date, '%m%d%Y_%H%i%S'), " +
                            "ga.analysis_type, " +
                            "ga.visible, " +
                            "ga.name, " +
                            "ga.status, " +
                            "ga.path, " +
                            "ga.parameter_group_id " +
                            "from gene_list_analyses ga " +
                            "where ga.analysis_id = ? " +
                            "and ga.visible = 1";

            log.debug("in getGeneListAnalysis");
            //log.debug("query = " + query);

            Results myResults = new Results(query, analysis_id, conn);
            String[] dataRow;


            while ((dataRow = myResults.getNextRow()) != null) {
                newGeneListAnalysis = setupGeneListAnalysisValues(dataRow);
                ParameterValue[] myParameterValues =
                        new ParameterValue().getParameterValues(newGeneListAnalysis.getParameter_group_id(), pool);
                newGeneListAnalysis.setParameterValues(myParameterValues);
                newGeneListAnalysis.setAnalysisGeneList(new GeneList().getGeneList(newGeneListAnalysis.getGene_list_id(), pool));
            }
            myResults.close();

        } catch (SQLException e) {
            log.debug("SQL Error:", e);
            throw (e);
        }

        return newGeneListAnalysis;
    }


    /**
     * Gets the value for the named parameter used in the analysis.
     *
     * @param parameterName the name of the parameter
     * @return the parameter value
     */
    public String getThisParameter(String parameterName) {
        log.debug("in GeneListAnalysis.getThisParameter");

        ParameterValue[] myParameterValues = this.getParameterValues();
        //log.debug("parmavalues len = "+myParameterValues.length);
        String parameterValue = null;
        for (int i = 0; i < myParameterValues.length; i++) {
            if (myParameterValues[i].getParameter().equals(parameterName)) {
                parameterValue = myParameterValues[i].getValue();
                //log.debug("parameter value = "+parameterValue);
            }
        }
        return parameterValue;
    }

    /**
     * Updates the visible flag to '1'.
     *
     * @param conn the database connection
     */

    public void updateVisible(DataSource pool) throws SQLException {
        String query =
                "update gene_list_analyses " +
                        "set visible = 1 " +
                        "where analysis_id = ?";

        log.debug("in updateVisible.  analysis = " + this.getDescription());
        try (Connection conn = pool.getConnection()) {
            PreparedStatement pstmt = conn.prepareStatement(query,
                    ResultSet.TYPE_SCROLL_INSENSITIVE,
                    ResultSet.CONCUR_UPDATABLE);
            pstmt.setInt(1, this.getAnalysis_id());
            pstmt.executeUpdate();
        } catch (SQLException e) {
            log.debug("SQL Error:", e);
            throw (e);
        }
    }

    /**
     * Updates the status text.
     *
     * @param conn the database connection
     */

    public void updateStatus(DataSource pool, String status) throws SQLException {
        this.setStatus(status);
        String query =
                "update gene_list_analyses " +
                        "set status = ? " +
                        "where analysis_id = ?";
        try (Connection conn = pool.getConnection()) {

            log.debug("in updateStatus.  analysis = " + this.getDescription());
            PreparedStatement pstmt = conn.prepareStatement(query,
                    ResultSet.TYPE_SCROLL_INSENSITIVE,
                    ResultSet.CONCUR_UPDATABLE);
            pstmt.setString(1, this.getStatus());
            pstmt.setInt(2, this.getAnalysis_id());
            pstmt.executeUpdate();
        } catch (SQLException e) {
            log.debug("SQL Error:", e);
            throw (e);
        }
    }

    /**
     * Updates the path text.
     *
     * @param conn the database connection
     */

    public void updatePath(DataSource pool, String path) throws SQLException {
        this.setPath(path);
        try (Connection conn = pool.getConnection()) {
            String query =
                    "update gene_list_analyses " +
                            "set path = ? " +
                            "where analysis_id = ?";

            log.debug("in updateStatus.  analysis = " + this.getDescription());
            PreparedStatement pstmt = conn.prepareStatement(query,
                    ResultSet.TYPE_SCROLL_INSENSITIVE,
                    ResultSet.CONCUR_UPDATABLE);
            pstmt.setString(1, this.getPath());
            pstmt.setInt(2, this.getAnalysis_id());
            pstmt.executeUpdate();

        } catch (SQLException e) {
            log.debug("SQL Error:", e);
            throw (e);
        }
    }

    /**
     * Updates the status text.
     *
     * @param conn the database connection
     */

    public void updateStatusVisible(DataSource pool, String status) throws SQLException {
        try (Connection conn = pool.getConnection()) {
            String query =
                    "update gene_list_analyses " +
                            "set status = ?, visible = 1" +
                            "where analysis_id = ?";

            log.debug("in updateStatusVisible.  analysis = " + this.getDescription());
            PreparedStatement pstmt = conn.prepareStatement(query,
                    ResultSet.TYPE_SCROLL_INSENSITIVE,
                    ResultSet.CONCUR_UPDATABLE);
            pstmt.setString(1, this.getStatus());
            pstmt.setInt(2, this.getAnalysis_id());
            pstmt.executeUpdate();
        } catch (SQLException e) {
            log.debug("SQL Error:", e);
            throw (e);
        }
    }


    /**
     * Deletes a record from the gene_list_analyses table, and all associated records.
     *
     * @param analysis_id the identifier of the analysis record to be deleted
     * @param conn        the database connection
     * @throws SQLException if a database error occurs
     */

    public void deleteAnonGeneListAnalysisResult(int analysis_id, DataSource pool) throws SQLException {
        log.info("in deleteGeneListAnalysisResult");
        GeneListAnalysis thisGLA = getAnonGeneListAnalysis(analysis_id, pool);

        //
        // Had to do it this way because you can't delete the parameter_groups record before deleting the
        // gene_list_analyses record (it's a one-to-many)
        //

        String query1 =
                "delete from gene_list_analyses " +
                        "where analysis_id = ? ";

        String query2 =
                "delete from parameter_values pv  " +
                        "where parameter_group_id = ?";

        String query3 =
                "delete from parameter_groups pg  " +
                        "where parameter_group_id = ?";

        PreparedStatement pstmt = null;
        try (Connection conn = pool.getConnection()) {
            conn.setAutoCommit(false);
            try {
                int paramGroupID = thisGLA.getParameter_group_id();

                pstmt = conn.prepareStatement(query1,
                        ResultSet.TYPE_SCROLL_INSENSITIVE,
                        ResultSet.CONCUR_UPDATABLE);
                pstmt.setInt(1, analysis_id);
                pstmt.executeUpdate();

                pstmt = conn.prepareStatement(query2,
                        ResultSet.TYPE_SCROLL_INSENSITIVE,
                        ResultSet.CONCUR_UPDATABLE);
                pstmt.setInt(1, paramGroupID);
                pstmt.executeUpdate();

                pstmt = conn.prepareStatement(query3,
                        ResultSet.TYPE_SCROLL_INSENSITIVE,
                        ResultSet.CONCUR_UPDATABLE);
                pstmt.setInt(1, paramGroupID);
                pstmt.executeUpdate();
                pstmt.close();
                conn.commit();
            } catch (SQLException e) {
                log.error("In exception of deleteGeneListAnalysisResult", e);
                conn.rollback();
                throw e;
            }
        } catch (Exception e) {
            throw e;
        }


    }

    /**
     * Deletes a record from the gene_list_analyses table, and all associated records.
     *
     * @param analysis_id the identifier of the analysis record to be deleted
     * @param conn        the database connection
     * @throws SQLException if a database error occurs
     */
    public void deleteGeneListAnalysisResult(int analysis_id, DataSource pool) throws SQLException {
        log.info("in deleteGeneListAnalysisResult");

        // Had to do it this way because you can't delete the parameter_groups record before deleting the
        // gene_list_analyses record (it's a one-to-many)
        //

        String query1 = "delete from gene_list_analyses where analysis_id = ? ";

        String query2 = "delete from parameter_values pv where parameter_group_id = ?";

        String query3 = "delete from parameter_groups pg where parameter_group_id = ?";

        PreparedStatement pstmt = null;

        GeneListAnalysis thisGLA = getGeneListAnalysis(analysis_id, pool);

        try (Connection conn = pool.getConnection()) {
            conn.setAutoCommit(false);
            try {
                int paramGroupID = thisGLA.getParameter_group_id();

                pstmt = conn.prepareStatement(query1,
                        ResultSet.TYPE_SCROLL_INSENSITIVE,
                        ResultSet.CONCUR_UPDATABLE);
                pstmt.setInt(1, analysis_id);
                pstmt.executeUpdate();
                pstmt = conn.prepareStatement(query2,
                        ResultSet.TYPE_SCROLL_INSENSITIVE,
                        ResultSet.CONCUR_UPDATABLE);
                pstmt.setInt(1, paramGroupID);
                pstmt.executeUpdate();
                pstmt = conn.prepareStatement(query3,
                        ResultSet.TYPE_SCROLL_INSENSITIVE,
                        ResultSet.CONCUR_UPDATABLE);
                pstmt.setInt(1, paramGroupID);
                pstmt.executeUpdate();
                conn.commit();
                conn.setAutoCommit(true);
            } catch (SQLException e) {
                log.error("In exception of deleteGeneListAnalysisResult", e);
                conn.rollback();
                throw e;
            }
        } catch (Exception e) {
            throw e;
        }
    }


    /**
     * Deletes files associated with a gene list analysis.
     *
     * @param userMainDir the users's top directory
     * @param analysis_id the identifier of the analysis record to be deleted
     * @param conn        the database connection
     * @throws SQLException if a database error occurs
     */
    public void deleteAnonGeneListAnalysisFiles(String userMainDir, int analysis_id, DataSource pool) throws SQLException {

        log.info("in deleteGeneListAnalysisFiles");

        GeneListAnalysis thisGLA = getAnonGeneListAnalysis(analysis_id, pool);

        String dirToDelete = "";
        GeneList thisGeneList = thisGLA.getAnalysisGeneList();
        String glaDir = userMainDir + thisGeneList.getGene_list_id() + "/";
        log.debug("deleteAnonGeneListAnalysis:" + glaDir);
        if (thisGLA.getAnalysis_type().equals("oPOSSUM")) {
            dirToDelete = thisGeneList.getOPOSSUMDir(glaDir);
        } else if (thisGLA.getAnalysis_type().equals("MEME")) {
            dirToDelete = thisGeneList.getMemeDir(glaDir);
        } else if (thisGLA.getAnalysis_type().equals("Upstream")) {
            dirToDelete = thisGeneList.getUpstreamDir(glaDir);
        } else if (thisGLA.getAnalysis_type().equals("Pathway")) {
            dirToDelete = thisGeneList.getPathwayDir(glaDir);
        } else if (thisGLA.getAnalysis_type().equals("multiMiR")) {
            dirToDelete = thisGeneList.getMultiMiRDir(glaDir) + thisGLA.getPath();
        } else if (thisGLA.getAnalysis_type().equals("GO")) {
            dirToDelete = thisGeneList.getGODir(glaDir) + thisGLA.getPath();
        }
        log.debug("glaDir=" + glaDir);
        log.debug("dirToDelete=" + dirToDelete);
        File dir = new File(dirToDelete);
        File[] filesInDir = dir.listFiles();
        boolean emptyFolder = true;
        for (int i = 0; i < filesInDir.length; i++) {
            log.debug("files" + i + "=" + filesInDir[i].getAbsolutePath());
            if (filesInDir[i].getName().indexOf(thisGLA.getCreate_date_as_string()) > -1 ||
                    filesInDir[i].getName().indexOf(thisGLA.getCreate_date_for_filename()) > -1 ||
                    thisGLA.getAnalysis_type().equals("GO") || thisGLA.getAnalysis_type().equals("multiMiR")
            ) {
                try {
                    if (!filesInDir[i].delete()) {
                        emptyFolder = false;
                    }
                } catch (Exception e) {
                    log.error("error deleteing Gene List Analysis File:" + filesInDir[i].getAbsolutePath(), e);
                }

            }
        }
        if (emptyFolder) {
            try {
                dir.delete();
            } catch (Exception e) {
                log.error("error deleteing Gene List Analysis Folder", e);
            }
        }
    }

    /**
     * Deletes files associated with a gene list analysis.
     *
     * @param userMainDir the users's top directory
     * @param analysis_id the identifier of the analysis record to be deleted
     * @param conn        the database connection
     * @throws SQLException if a database error occurs
     */
    public void deleteGeneListAnalysisFiles(String userMainDir, int analysis_id, DataSource pool) throws SQLException {
        log.info("in deleteGeneListAnalysisFiles");
        GeneListAnalysis thisGLA = getGeneListAnalysis(analysis_id, pool);

        String dirToDelete = "";
        GeneList thisGeneList = thisGLA.getAnalysisGeneList();
        String glaDir = thisGeneList.getGeneListAnalysisDir(userMainDir);

        if (thisGLA.getAnalysis_type().equals("oPOSSUM")) {
            dirToDelete = thisGeneList.getOPOSSUMDir(glaDir);
        } else if (thisGLA.getAnalysis_type().equals("MEME")) {
            dirToDelete = thisGeneList.getMemeDir(glaDir);
        } else if (thisGLA.getAnalysis_type().equals("Upstream")) {
            dirToDelete = thisGeneList.getUpstreamDir(glaDir);
        } else if (thisGLA.getAnalysis_type().equals("Pathway")) {
            dirToDelete = thisGeneList.getPathwayDir(glaDir);
        } else if (thisGLA.getAnalysis_type().equals("multiMiR")) {
            dirToDelete = thisGeneList.getMultiMiRDir(glaDir) + thisGLA.getPath();
        } else if (thisGLA.getAnalysis_type().equals("GO")) {
            dirToDelete = thisGeneList.getGODir(glaDir) + thisGLA.getPath();
        }
        log.debug("glaDir=" + glaDir);
        log.debug("dirToDelete=" + dirToDelete);
        File dir = new File(dirToDelete);
        File[] filesInDir = dir.listFiles();
        boolean emptyFolder = true;
        for (int i = 0; i < filesInDir.length; i++) {
            log.debug("files" + i + "=" + filesInDir[i].getAbsolutePath());
            if (filesInDir[i].getName().indexOf(thisGLA.getCreate_date_as_string()) > -1 ||
                    filesInDir[i].getName().indexOf(thisGLA.getCreate_date_for_filename()) > -1 ||
                    thisGLA.getAnalysis_type().equals("GO") || thisGLA.getAnalysis_type().equals("multiMiR")
            ) {
                try {
                    if (!filesInDir[i].delete()) {
                        emptyFolder = false;
                    }
                } catch (Exception e) {
                    log.error("error deleteing Gene List Analysis File:" + filesInDir[i].getAbsolutePath(), e);
                }

            }
        }
        if (emptyFolder) {
            try {
                dir.delete();
            } catch (Exception e) {
                log.error("error deleteing Gene List Analysis Folder", e);
            }
        }
    }


    /**
     * Deletes all gene list analyses records for a gene list
     *
     * @param gene_list_id the identifier of the genelist
     * @param conn         the database connection
     * @throws SQLException if a database error occurs
     */
    public void deleteAllGeneListAnalysisResultsForGeneList(int gene_list_id, DataSource pool) throws SQLException {
        String select = "select analysis_id " +
                "from gene_list_analyses " +
                "where gene_list_id = ?";
        try (Connection conn = pool.getConnection()) {
            PreparedStatement pstmt = conn.prepareStatement(select,
                    ResultSet.TYPE_SCROLL_INSENSITIVE,
                    ResultSet.CONCUR_UPDATABLE);
            pstmt.setInt(1, gene_list_id);

            pstmt.executeUpdate();
            ResultSet rs = pstmt.executeQuery();

            while (rs.next()) {
                deleteGeneListAnalysisResult(rs.getInt(1), pool);
            }
            pstmt.close();
        } catch (SQLException e) {
            log.debug("SQL Error:", e);
            throw (e);
        }
    }


    public String toString() {
        String glaInfo = "This GeneListAnalysis object has analysis_id = " + analysis_id +
                " and description = " + description;
        return glaInfo;
    }

    public void print() {
        log.debug(toString());
    }

    /**
     * Compares GeneListAnalysis objects based on different fields.
     */
    public class GeneListAnalysisSortComparator implements Comparator<GeneListAnalysis> {
        int compare;
        GeneListAnalysis geneListAnalysis1, geneListAnalysis2;

        public int compare(GeneListAnalysis object1, GeneListAnalysis object2) {
            String sortColumn = getSortColumn();
            String sortOrder = getSortOrder();

            if (sortOrder.equals("A")) {
                geneListAnalysis1 = object1;
                geneListAnalysis2 = object2;
                // default for null columns for ascending order
                compare = 1;
            } else {
                geneListAnalysis2 = object1;
                geneListAnalysis1 = object2;
                // default for null columns for ascending order
                compare = -1;
            }

            //log.debug("geneListAnalysis1 = "+geneListAnalysis1+ ", geneListAnalysis2 = "+geneListAnalysis2);

            if (sortColumn.equals("description")) {
                compare = geneListAnalysis1.getDescription().compareTo(geneListAnalysis2.getDescription());
            } else if (sortColumn.equals("geneListName")) {
                compare = geneListAnalysis1.getAnalysisGeneList().getGene_list_name().compareTo(geneListAnalysis2.getAnalysisGeneList().getGene_list_name());
            } else if (sortColumn.equals("dateCreated")) {
                compare = geneListAnalysis1.getCreate_date().compareTo(geneListAnalysis2.getCreate_date());
            }
            return compare;
        }
    }

    public GeneListAnalysis[] sortGeneListAnalyses(GeneListAnalysis[] myAnalysisResults, String sortColumn, String sortOrder) {
        setSortColumn(sortColumn);
        setSortOrder(sortOrder);
        Arrays.sort(myAnalysisResults, new GeneListAnalysisSortComparator());
        return myAnalysisResults;
    }

    /**
     * A GeneListAnalysis object is equal if analysis_ids are the same.
     *
     * @param obj a GeneListAnalysis object
     * @return true if the objects are equal, false otherwise
     */
    public boolean equals(Object obj) {
        if (!(obj instanceof GeneListAnalysis)) return false;
        return (this.analysis_id == ((GeneListAnalysis) obj).analysis_id);
    }

}

