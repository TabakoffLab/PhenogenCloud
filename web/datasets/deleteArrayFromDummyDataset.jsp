<%--
 *  Author: Cheryl Hornbaker
 *  Created: Apr, 2009
 *  Description:  This file handles deleting an array during review of quality control results
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/datasets/include/datasetHeader.jsp"  %>
<%

	Dataset dummyDataset = (session.getAttribute("dummyDataset") == null ?
					new Dataset(-99) : (Dataset) session.getAttribute("dummyDataset"));;

	log.info("in deleteArrayFromDummyDataset.jsp. user = " + user + ", itemID = "+itemID);
        try {
		dummyDataset.deleteDataset_chip(userID, itemID, pool);
                //Success - "Array deleted"
		mySessionHandler.createDatasetActivity(session.getId(), dummyDataset.getDataset_id(), -99, "Deleted array from dummy dataset", pool);
        } catch( Exception e ) {
            	throw e;
        }
%>
