package edu.ucdenver.ccp.PhenoGen.data;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import javax.sql.DataSource;

import edu.ucdenver.ccp.util.ObjectHandler;
import edu.ucdenver.ccp.util.sql.Results;
import edu.ucdenver.ccp.util.Debugger;
import edu.ucdenver.ccp.PhenoGen.util.DbUtils;
import edu.ucdenver.ccp.util.FileHandler;

import java.io.File;
import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.HashSet;
import java.util.Hashtable;
import java.util.LinkedHashSet;
import java.util.Set;

import oracle.jdbc.OraclePreparedStatement;


/* for logging messages */
import org.apache.log4j.Logger;

/**
 * Class for handling anonymous gene list data.
 *
 * @author Spencer Mahaffey
 */

public class AnonGeneList extends edu.ucdenver.ccp.PhenoGen.data.GeneList {

    private ObjectHandler myObjectHandler = new ObjectHandler();
    private Logger log = null;

    private String selectClause =
            "select " +
                    "gl.gene_list_id, " +
                    "'', " +
                    "gl.path, " +
                    "gl.gene_list_name, " +
                    "ifnull(gl.description, 'No Description Entered') Description, " +
                    "(Select count(*) from genes ge where ge.gene_list_id=gl.gene_list_id), " +
                    "gl.organism Organism, " +
                    "'', " +
                    "date_format(gl.create_date, '%m/%d/%Y %h:%i %p') \"Date Created\", " +
                    "date_format(gl.create_date, '%m%d%Y_%H%i%S'), " +
                    "ifnull(gl.dataset_id, -99), " +
                    "ifnull(gl.parameter_group_id, -99), " +
                    "gl.created_by_user_id, " +
                    "ifnull(gl.version, -99), " +
                    "gl.create_date ";
    private String fromClause =
            "from gene_lists gl " +
                    "left join genes g on g.gene_list_id = gl.gene_list_id ";
    private String groupByClause =
            "group by " +
                    "gl.gene_list_id ";
                    /*"gl.created_by_user_id, " +
                    "gl.path, " +
                    "gl.gene_list_name, " +
                    "gl.description, " +
                    "gl.organism, " +
                    "gl.gene_list_source, " +

                    "gl.create_date, " +
                    "gl.dataset_id, " +
                    "gl.version, " +
                    "gl.parameter_group_id ";*/


    public AnonGeneList() {
        log = Logger.getRootLogger();
    }


    /**
     * Retrieves the gene lists for all datasets created by a user or public
     *
     * @param user_id The ID of the user
     * @param pool    the database connection pool
     * @return An array of GeneList objects
     * @throws SQLException if a database error occurs
     */
    public AnonGeneList[] getGeneListsForAllDatasetsForUser(String UUID, DataSource pool) throws SQLException {
        //log.debug("in getGeneListsForAllDatasetsForUser. user_id = " + user_id);
        String query = selectClause +
  			/*"select "+
			"gl.gene_list_id, "+
			"'', "+
			"gl.path, "+
        		"gl.gene_list_name, "+
        		"ifnull(gl.description, 'No Description Entered') Description, "+
                	"(Select count(*) from genes ge where ge.gene_list_id=gl.gene_list_id), "+
        		"gl.organism Organism, "+
			"'', "+
			"to_char(gl.create_date, 'mm/dd/yyyy hh12:mi AM') \"Date Created\", "+
			"to_char(gl.create_date, 'mmddyyyy_hh24miss'), "+
			"ifnull(gl.dataset_id, -99), "+
			"ifnull(gl.parameter_group_id, -99), "+
			"gl.created_by_user_id, "+
			"ifnull(gl.version, -99), "+
			"gl.create_date "+*/
                "from gene_lists gl, Anon_user_genelist aug " +
                "where gl.gene_list_id = aug.genelist_id " +
                "and gl.created_by_user_id = -20 " +
                "and aug.UUID= ? ";
			/*"and  ds.created_by_user_id = "+
			"	(select user_id "+
			"	from users "+
			"	where user_name = 'public') ";*/

        //log.debug("query = " + query);
        String[] dataRow;
        List<AnonGeneList> geneLists = new ArrayList<AnonGeneList>();
        try (Connection conn = pool.getConnection()) {
            Results myResults = new Results(query, UUID, conn);


            while ((dataRow = myResults.getNextRow()) != null) {
                //log.debug(dataRow);
                AnonGeneList thisGeneList = setupGeneListValues(dataRow);
                geneLists.add(thisGeneList);
            }
            myResults.close();
        } catch (SQLException er) {
            throw er;
        }
        //log.debug("LEN GENELISTS\n"+geneLists.size());
        AnonGeneList[] geneListArray = (AnonGeneList[]) myObjectHandler.getAsArray(geneLists, AnonGeneList.class);
        //log.debug("LEN GENELISTSArray\n"+geneListArray.length);
        return geneListArray;

    }

    public void linkRGDListToUser(String uuID, String rgdID, DataSource pool) throws SQLException {
        String select = "select genelist_id from Anon_rgd_genelist where RGD_ID=?";
        String delete = "delete Anon_rgd_genelist where RGD_ID=?";
        String insert = "insert into Anon_USER_GENELIST (UUID,GENELIST_ID) Values (?,?)";
        try (Connection conn = pool.getConnection()) {
            conn.setAutoCommit(false);
            PreparedStatement ps = conn.prepareStatement(select);
            ps.setString(1, rgdID);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                PreparedStatement ps2 = conn.prepareStatement(insert);
                ps2.setString(1, uuID);
                ps2.setInt(2, rs.getInt(1));
                ps2.execute();
                ps2.close();
            }
            rs.close();
            ps.close();
            ps = conn.prepareStatement(delete);
            ps.setString(1, rgdID);
            int delCount = ps.executeUpdate();
            ps.close();
            conn.commit();
        } catch (SQLException er) {
            throw er;
        }
    }

    public void linkRGDListToRGDUser(String rgdID, int glID, DataSource pool) throws SQLException {
        log.debug("link RGD");
        String insert = "insert into Anon_RGD_GENELIST (RGD_ID,GENELIST_ID) Values (?,?)";
        try (Connection conn = pool.getConnection()) {
            conn.setAutoCommit(false);
            PreparedStatement ps = conn.prepareStatement(insert);
            ps.setString(1, rgdID);
            ps.setInt(2, glID);
            ps.executeUpdate();
            ps.close();
            conn.commit();
            log.debug("conn close");
        } catch (SQLException er) {
            throw er;
        }
    }

    /**
     * Retrieves the set of gene lists available to this user.
     * It contains gene lists that were derived from the datasets viewable by this user
     * (including from public datasets)
     * PLUS the gene lists created by another user that have been granted to this user
     * PLUS the gene lists uploaded by this user or created by this user for
     * literature search, QTL analysis, or promoter analysis.  It is sorted by create_date descending.
     *
     * @param user_id  The ID of the user who has access to the gene lists or -99 for all users
     * @param organism The organism of the gene lists requested or "All" or "MmOrRn" or "MmOrHs"
     * @param conn     the database connection
     * @return An array of GeneList objects
     * @throws SQLException if a database error occurs
     */
    public AnonGeneList[] getGeneLists(String UUID, String organism, DataSource pool) throws SQLException {

        String orgSpecific = "";
        if (organism.equals("All")) {
            orgSpecific = "%";
        } else if (organism.equals("MmOrRn")) {
            orgSpecific = "Mm' or gl.organism like 'Rn";
        } else if (organism.equals("MmOrHs")) {
            orgSpecific = "Mm' or gl.organism like 'Hs";
        } else {
            orgSpecific = organism;
        }


        String query = selectClause +
                "from gene_lists gl, Anon_user_genelist aug " +
                "where gl.gene_list_id = aug.genelist_id " +
                "and gl.created_by_user_id = -20 " +
                "and aug.UUID= ? " +
                "and gl.organism like '" + orgSpecific + "' ";

        String[] dataRow;
        List<AnonGeneList> geneLists = new ArrayList<AnonGeneList>();
        try (Connection conn = pool.getConnection()) {
            Results myResults = new Results(query, UUID, conn);
            while ((dataRow = myResults.getNextRow()) != null) {
                AnonGeneList thisGeneList = setupGeneListValues(dataRow);

                geneLists.add(thisGeneList);
            }
            myResults.close();
        } catch (SQLException er) {
            throw er;
        }

        AnonGeneList[] geneListArray = (AnonGeneList[]) myObjectHandler.getAsArray(geneLists, AnonGeneList.class);

        return geneListArray;
    }


    public AnonGeneList getGeneList(int geneListID, DataSource pool) throws SQLException {
        AnonGeneList myGeneList = null;
        try (Connection conn = pool.getConnection()) {
            log.info("in getGeneList as a GeneList object. geneListID = " + geneListID);

            String query =
                    selectClause +
                            fromClause +
                            "where gl.gene_list_id = ? " +
                            groupByClause;
            //log.debug(query);
            Results myResults = new Results(query, geneListID, conn);
            String[] dataRow = myResults.getNextRow();
            myGeneList = setupGeneListValues(dataRow);
            if (myGeneList.getParameter_group_id() != -99) {
                myGeneList.setAnovaPValue(
                        new ParameterValue().getAnovaPValue(
                                myGeneList.getParameter_group_id(), pool));
                myGeneList.setStatisticalMethod(
                        new ParameterValue().getStatisticalMethod(
                                myGeneList.getParameter_group_id(), pool));
            }
            myGeneList.setColumnHeadings(getColumnHeadings(geneListID, pool));
            myResults.close();
        } catch (SQLException e) {
            log.debug("getGeneList ERROR:", e);
            throw e;
        }
        return myGeneList;
    }

    /**
     * Retrieves the set of gene lists available to this user.
     * It contains gene lists that were derived from the datasets viewable by this user
     * (including from public datasets)
     * PLUS the gene lists created by another user that have been granted to this user
     * PLUS the gene lists uploaded by this user or created by this user for
     * literature search, QTL analysis, or promoter analysis.  It is sorted by create_date descending.
     *
     * @param user_id       The ID of the user who has access to the gene lists or -99 for all users
     * @param organism      The organism of the gene lists requested or "All" or "MmOrRn" or "MmOrHs"
     * @param geneListTypes Types of genelists to include or "All"
     * @param conn          the database connection
     * @return An array of GeneList objects
     * @throws SQLException if a database error occurs
     */
    public GeneList[] getGeneLists(AnonUser user, String organism, DataSource pool) throws SQLException {

        String orgSpecific = "";
        //String typeSpecific = "";

        if (organism.equals("All")) {
            orgSpecific = "%";
        } else if (organism.equals("MmOrRn")) {
            orgSpecific = "Mm' or gl.organism like 'Rn";
        } else if (organism.equals("MmOrHs")) {
            orgSpecific = "Mm' or gl.organism like 'Hs";
        } else {
            orgSpecific = organism;
        }

		/*if (geneListTypes.equals("WithResults")) {
			typeSpecific = 
				"and (exists "+
				"	(select 'x' "+
				"	from gene_list_analyses gla "+
				"	where gla.gene_list_id = gl.gene_list_id)) ";
		}*/

        String query =
                selectClause +
                        "from gene_lists gl, Anon_user_genelist aug " +
                        "where gl.gene_list_id = aug.genelist_id " +
                        "and gl.created_by_user_id = -20 " +
                        "and aug.UUID = ?" +
                        "and gl.organism like '" + orgSpecific + "' " +
                        groupByClause +
                        "order by 15 desc";

        log.debug("in getGeneLists.");
        //log.debug("query = "+query);

        String[] dataRow;
        List<GeneList> geneLists = new ArrayList<GeneList>();

        try (Connection conn = pool.getConnection()) {
            Results myResults = new Results(query, user.getUUID(), conn);
            while ((dataRow = myResults.getNextRow()) != null) {
                GeneList thisGeneList = setupGeneListValues(dataRow);

                geneLists.add(thisGeneList);
            }
            myResults.close();
        } catch (SQLException e) {
            throw e;
        }
        GeneList[] geneListArray = (GeneList[]) myObjectHandler.getAsArray(geneLists, GeneList.class);

        return geneListArray;
    }


    public boolean geneListNameExists(String geneListName, String UUID, DataSource pool) throws SQLException {

        log.debug("in geneListNameExists");

        String query =
                "select 'x' " +
                        "from gene_lists gl, Anon_user_genelist aug " +
                        "where gl.gene_list_id = aug.genelist_id " +
                        "and gl.gene_list_name = ? " +
                        "and gl.created_by_user_id = -20 " +
                        "and aug.UUID= ? ";

        boolean itExists = false;
        try (Connection conn = pool.getConnection()) {
            Results myResults = new Results(query, new Object[]{geneListName, UUID}, conn);
            if (myResults.getNumRows() >= 1) {
                itExists = true;
            }

            myResults.close();

        } catch (SQLException er) {
            throw er;
        }


        return itExists;
    }

    public int createGeneList(DataSource pool) throws SQLException {

        //this.setGene_list_id(myDbUtils.getUniqueID("gene_lists_seq", pool));

        log.debug("in createGeneList");


        String query =
                "insert into gene_lists " +
                        "( gene_list_name, description, create_date, " +
                        "created_by_user_id, path, gene_list_source, " +
                        "parameter_group_id, dataset_id, version, " +
                        "organism) values " +
                        "( ?, ?, ?, " +
                        "?, ?, ?, " +
                        "?, ?, ?, " +
                        "?)";

        java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());
        try (Connection conn = pool.getConnection()) {

            PreparedStatement pstmt = conn.prepareStatement(query,
                    PreparedStatement.RETURN_GENERATED_KEYS);
            //pstmt.setInt(1, this.getGene_list_id());
            pstmt.setString(1, this.getGene_list_name());
            pstmt.setString(2, this.getDescription());
            // This is the create_date
            pstmt.setTimestamp(3, now);
            myDbUtils.setToNullIfZero(pstmt, 4, this.getCreated_by_user_id());
            pstmt.setString(5, this.getPath());
            pstmt.setString(6, this.getGene_list_source());
            myDbUtils.setToNullIfZero(pstmt, 7, this.getParameter_group_id());
            myDbUtils.setToNullIfZero(pstmt, 8, this.getDataset_id());
            myDbUtils.setToNullIfZero(pstmt, 9, this.getVersion());
            pstmt.setString(10, this.getOrganism());

            pstmt.executeUpdate();
            ResultSet rs = pstmt.getGeneratedKeys();
            int key = -99;
            if (rs.next()) {
                key = rs.getInt(1);
            }
            this.setGene_list_id(key);
            pstmt.close();
            log.debug("gene_list_id = " + this.getGene_list_id() + ", and path = " + this.getPath());
        } catch (SQLException er) {
            throw er;
        }
        return this.getGene_list_id();
    }

    /**
     * Loads genes from a flatfile.
     *
     * @param numGroups the number of groups that have group means in the flat file
     * @param filename  the full name of the file
     * @param conn      the database connection
     * @return the id of the gene list that was created
     * @throws SQLException if a database error occurs
     * @throws IOException  if the file cannot be accessed
     */
    public int loadFromFile(int groups, String filename, DataSource pool) throws SQLException, IOException {

        log.debug("in loadFromFile");

        this.setGene_list_id(createGeneList(pool));
        log.info("just created gene list.  the ID is " + this.getGene_list_id());


        FileHandler fileReader = new FileHandler();
        String[] fileContents = fileReader.getFileContents(new File(filename), "spaces");

        log.debug("file contains " + fileContents.length + " genes.");


        String query = "insert into genes " +
                "(gene_list_id, gene_id) " +
                "values (?, ?)";

        PreparedStatement pstmt = null;
        OraclePreparedStatement gv_pstmt = null;
        log.debug("filename = " + filename);
        //log.debug("query = " + query);
        String gene_id = "";

        try (Connection conn = pool.getConnection()) {
            String statisticalMethod = "";
            String[] fields = null;
            String[] headers = null;
            int[] headerCodes = null;
            int startLine = 0;
            Hashtable<String, String> genesHash = new Hashtable<String, String>();
            conn.setAutoCommit(false);
            pstmt = conn.prepareStatement(query,
                    ResultSet.TYPE_SCROLL_INSENSITIVE,
                    ResultSet.CONCUR_UPDATABLE);


            for (int i = startLine; i < fileContents.length; i++) {
                if (!fileContents[i].equals("")) {

                    gene_id = fileContents[i].replaceAll("[\\s]", "");

                    if (!genesHash.containsKey(gene_id)) {
                        pstmt.setInt(1, this.getGene_list_id());
                        pstmt.setString(2, gene_id);
                        pstmt.execute();
                        genesHash.put(gene_id, gene_id);
                    }
                }
            }
            log.debug("just uploaded last gene and ready to close pstmt.  Then will create Alternate Identifiers");
            pstmt.close();

            log.debug("creating alternate identifiers");
            createAlternateIdentifiers(this, pool);
            conn.commit();
        } catch (SQLException e) {
            if (e.getErrorCode() == 1) {
                log.error("Got a duplicate key SQLException while in loadFromFile for gene_id = " + gene_id);
            }
            log.error("in exception of loadFromFile", e);
            //conn.rollback();
            throw e;
        }

        return this.getGene_list_id();
    }


    /**
     * Gets gene lists that contain the identifiers in this gene list
     *
     * @param user_id the id of the user logged in
     * @param conn    the database connection
     * @return an array of Gene objects from this gene list, with the Set of containing GeneLists attached
     * @throws SQLException if a database error occurs
     */

    public Gene[] findContainingGeneLists(String UUID, DataSource pool) throws SQLException {

        String query =
                "select a.gene_id, " +
                        "b.gene_list_id, " +
                        "gl.gene_list_name, " +
                        "b.gene_id " +
                        "from genes a " +
                        "left join genes b " +
                        "	on a.gene_id = b.gene_id " +
                        "	and b.gene_list_id != a.gene_list_id " +
                        "left join gene_lists gl " +
                        "	on b.gene_list_id = gl.gene_list_id " +
                        "left join anon_user_genelist agl " +
                        "	on agl.genelist_id = gl.gene_list_id " +
                        "	and agl.UUID = ? " +
                        "where a.gene_list_id = ? " +
                        // if b.gene_list_id is null, then this id is not in any other gene lists
                        // if ugl.user_id is not null, then this person has access to this gene list
                        "and (b.gene_list_id is null or agl.UUID is not null) " +
                        "order by a.gene_id, gl.gene_list_name";

        log.debug("in findContainingGeneLists. gene_list_id = " + this.getGene_list_id());
        //log.debug("query = "+query);
        List<Gene> myGenes = new ArrayList<Gene>();
        try (Connection conn = pool.getConnection()) {
            Results myResults = new Results(query, new Object[]{UUID, this.getGene_list_id()}, conn);

            Gene latestGene = new Gene();


            String thisGeneID = "";
            //
            // initialize this to 'X' so that the first iteration will work correctly
            //
            String lastGeneID = "X";
            Set<GeneList> theSet = null;
            String[] dataRow;

            while ((dataRow = myResults.getNextRow()) != null) {
                thisGeneID = dataRow[0];
                int containingGeneListID = (dataRow[1] != null ? Integer.parseInt(dataRow[1]) : -99);
                //log.debug("thisGeneID = "+thisGeneID + ", and containingGeneListID = "+containingGeneListID);

                GeneList thisGeneList = new GeneList(containingGeneListID, dataRow[2]);
                //
                // If the value in first column is the same as the value in the
                // first column of the previous record and the gene_list_id column is not null,
                // add another GeneList to the list of containing gene lists
                // Otherwise, close out this list
                // and set the containing gene lists for the Gene.
                //
                if (thisGeneID.equals(lastGeneID) && containingGeneListID != -99) {
                    //log.debug("geneIDs are the same");
                    latestGene.getContainingGeneLists().add(thisGeneList);
                } else {
                    //log.debug("geneIDs are not the same");
                    Gene newGene = new Gene(this.getGene_list_id(), thisGeneID);
                    if (containingGeneListID != -99) {
                        theSet = new LinkedHashSet<GeneList>();
                        theSet.add(thisGeneList);
                        //log.debug("just created the Set and now adding to it");
                        newGene.setContainingGeneLists(theSet);
                    }
                    latestGene = newGene;
                    myGenes.add(latestGene);
                }
                //log.debug("this Gene = "); myDebugger.print(latestGene);
                //if (latestGene.getContainingGeneLists() != null)
                //	log.debug("containingGeneLists= "); myDebugger.print(latestGene.getContainingGeneLists());
                lastGeneID = thisGeneID;
            }
            myResults.close();
        } catch (SQLException er) {
            throw er;
        }

        Gene[] myGeneArray = (Gene[]) myObjectHandler.getAsArray(myGenes, Gene.class);
        //log.debug("done with findContainingGeneLists. myGeneArray contains this many entries: "+myGeneArray.length);

        return myGeneArray;
    }

    public String getGeneListOwner(int geneListID, DataSource pool) throws SQLException {
        String uuid = "";
        String query = "select UUID from Anon_user_genelist aug " +
                "where aug.genelist_id = ?";
        try (Connection conn = pool.getConnection()) {
            PreparedStatement ps = conn.prepareStatement(query);
            ps.setInt(1, geneListID);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                uuid = rs.getString(1);
            }
            ps.close();
        } catch (SQLException e) {
            throw e;
        }
        return uuid;
    }


    public boolean moveGeneListsToSession(String uuidSource, String uuidDest, DataSource pool) throws SQLException {
        boolean ret = false;
        String query = "update Anon_user_genelist set UUID=? where UUID=?";
        try (Connection conn = pool.getConnection()) {
            PreparedStatement ps = conn.prepareStatement(query);
            ps.setString(1, uuidDest);
            ps.setString(2, uuidSource);
            int updated = ps.executeUpdate();
            ps.close();
            if (updated > 0) {
                ret = true;
            }
        } catch (SQLException e) {
            throw e;
        }
        return ret;
    }


    /**
     * Creates a new GeneList object and sets the data values to those retrieved from the database.
     *
     * @param dataRow the row of data corresponding to one GeneList
     * @return a GeneList object with its values setup
     */
    private AnonGeneList setupGeneListValues(String[] dataRow) {

        log.debug("in anon setupGeneListValues");
        //log.debug("dataRow= "); new Debugger().print(dataRow);

        AnonGeneList myGeneList = new AnonGeneList();

        myGeneList.setGene_list_id(Integer.parseInt(dataRow[0]));
        myGeneList.setGene_list_owner(dataRow[1]);
        myGeneList.setPath(dataRow[2] + "/");
        myGeneList.setGene_list_name(dataRow[3]);
        myGeneList.setGene_list_name_no_spaces(new ObjectHandler().removeBadCharacters(dataRow[3]));
        myGeneList.setDescription(dataRow[4]);
        myGeneList.setNumber_of_genes(Integer.parseInt(dataRow[5]));
        myGeneList.setOrganism(dataRow[6]);
        myGeneList.setGene_list_source(dataRow[7]);
        myGeneList.setCreate_date_as_string(dataRow[8]);
        try {
            myGeneList.setCreate_date(new ObjectHandler().getDisplayDateAsTimestamp(dataRow[8]));
        } catch (Exception e) {
            log.error("Couldn't parse date", e);
        }
        log.debug("dataset_id = " + dataRow[10]);

        myGeneList.setDataset_id(-99);
        myGeneList.setParameter_group_id(Integer.parseInt(dataRow[11]));
        myGeneList.setCreated_by_user_id(Integer.parseInt(dataRow[12]));
        myGeneList.setVersion(-99);

        return myGeneList;
    }

    public String toJSON(String type) {
        String ret = "";
        if (type.equals("summary")) {
            StringBuffer sb = new StringBuffer();
            sb.append("{");
            sb.append("\"id\":" + this.getGene_list_id());
            sb.append(",\"name\":\"" + this.getGene_list_name() + "\"");
            sb.append(",\"created\":\"" + this.getCreate_date_as_string() + "\"");
            sb.append(",\"geneCount\":" + this.getNumber_of_genes());
            sb.append(",\"organism\":\"" + this.getOrganism() + "\"");
            String source = this.getGene_list_source();
            if (source == null) {
                source = "";
            }
            sb.append(",\"source\":\"" + source + "\"");
            sb.append("}");
            ret = sb.toString();
        } else if (type.equals("full")) {

        }
        return ret;
    }

}

