<%--
 *  Author: Spencer Mahaffey
 *  Created: May, 2013
 *  Description:  This file takes the input from an ajax request and returns a json object with genes.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ page language="java"
         import="org.json.*" %>

<%@ include file="/web/common/anon_session_vars.jsp" %>

<jsp:useBean id="gdt" class="edu.ucdenver.ccp.PhenoGen.tools.analysis.GeneDataTools" scope="session"></jsp:useBean>


<%
    gdt.setSession(session);
    String chromosome = "", panel = "", myOrganism = "", track = "", folderName = "", bedFile = "", outputFile = "", web = "", type = "", genomeVer = "", version = "",dataVer="";
    int min = 0, max = 0, rnaDatasetID = 0, arrayTypeID = 0, binSize = 0, countType = 1;
    double forwardPValueCutoff = 0;
    if (request.getParameter("chromosome") != null) {
        chromosome = FilterInput.getFilteredInput(request.getParameter("chromosome").trim());
    }
    if (request.getParameter("track") != null) {
        track = request.getParameter("track").trim();
    }
    if (request.getParameter("folder") != null) {
        folderName = request.getParameter("folder").trim();
    }
    if (request.getParameter("version") != null) {
        version = FilterInput.getFilteredInput(request.getParameter("version").trim());
    }
    if (request.getParameter("dataVer") != null) {
           dataVer = FilterInput.getFilteredInput(request.getParameter("dataVer").trim());
        }
    if (request.getParameter("minCoord") != null) {
        try {
            min = Integer.parseInt(request.getParameter("minCoord").trim());
        } catch (NumberFormatException e) {
            log.error("Number format exception:Min\n", e);
        }
    }
    if (request.getParameter("maxCoord") != null) {
        try {
            max = Integer.parseInt(request.getParameter("maxCoord").trim());
        } catch (NumberFormatException e) {
            log.error("Number format exception:Max\n", e);
        }
    }
    if (request.getParameter("panel") != null) {
        panel = FilterInput.getFilteredInput(request.getParameter("panel").trim());
    }
    if (request.getParameter("rnaDatasetID") != null) {
        try {
            rnaDatasetID = Integer.parseInt(request.getParameter("rnaDatasetID").trim());
        } catch (NumberFormatException e) {
            log.error("Number format exception:rnaDatasetID\n", e);
        }
    }
    if (request.getParameter("arrayTypeID") != null) {
        try {
            arrayTypeID = Integer.parseInt(request.getParameter("arrayTypeID").trim());
        } catch (NumberFormatException e) {
            log.error("Number format exception:arrayTypeID\n", e);
        }
    }
    if (request.getParameter("binSize") != null) {
        try {
            binSize = Integer.parseInt(request.getParameter("binSize").trim());
        } catch (NumberFormatException e) {
            log.error("Number format exception:binSize\n", e);
        }
    }
    if (request.getParameter("myOrganism") != null) {
        myOrganism = FilterInput.getFilteredInput(request.getParameter("myOrganism").trim());
    } else {
        if (!panel.equals("")) {
            if (panel.equals("BNLX/SHRH")) {
                myOrganism = "Rn";
            } else if (panel.equals("ILS/ISS")) {
                myOrganism = "Mm";
            }
        } else if (arrayTypeID == 21) {
            myOrganism = "Mm";
        } else if (arrayTypeID == 22) {
            myOrganism = "Rn";
        }
    }

    if (request.getParameter("bedFile") != null) {
        bedFile = request.getParameter("bedFile").trim();
    }
    if (request.getParameter("outFile") != null) {
        outputFile = request.getParameter("outFile").trim();
    }
    if (request.getParameter("web") != null) {
        web = request.getParameter("web");
    }
    if (request.getParameter("type") != null) {
        type = request.getParameter("type");
    }
    if (request.getParameter("genomeVer") != null) {
        genomeVer = FilterInput.getFilteredInputGenomeVer(request.getParameter("genomeVer"));
    }
    if (request.getParameter("countType") != null) {
        countType = Integer.parseInt(request.getParameter("countType"));
    }
%>


<%
    String status = "";
    try {
        String toHash = "generateTrack:" + chromosome + "_" + min + "_" + max + "_" + panel + "_" + track + "_" + myOrganism + "_" + genomeVer + "_" + rnaDatasetID + "_" + arrayTypeID + "_" + folderName + "_" + binSize + "_" + version +"_"+dataVer+ "_" + countType + "_" + bedFile + "_" + outputFile + "_" + type + "_" + web;
        if (!gdt.isRunning(toHash)) {
            AsyncGenerateTrack agt = new AsyncGenerateTrack(gdt, session, pool);
            gdt.appendRunningMap(toHash, "True");
            gdt.appendThreadList(agt);
            if (!track.startsWith("custom") && bedFile.equals("") && outputFile.equals("")) {
                log.debug("calling GenerateTrack:"+track+":"+dataVer);
                agt.setupGenerateTrackXML(chromosome, min, max, panel, track, myOrganism, genomeVer, rnaDatasetID, arrayTypeID, folderName, binSize, version, countType, toHash,dataVer);
            } else if (track.startsWith("custom")) {
                log.debug("Generating custom xml track");
                if (web.startsWith("http")) {
                    if (type.equals("bb") || type.equals("bw")) {
                        agt.setupGenerateCustomRemoteTrackXML(chromosome, min, max, track, myOrganism, folderName, bedFile, outputFile, type, web, binSize, toHash);
                    }
                } else {
                    if (type.equals("bed")) {
                        File tmp = new File(applicationRoot + contextRoot + outputFile);
                        if (tmp.exists()) {
                            tmp.delete();
                        }
                        agt.setupGenerateCustomBedTrackXML(chromosome, min, max, track, myOrganism, folderName, bedFile, outputFile, toHash);
                    } else if (type.equals("bg")) {
                        File tmp = new File(applicationRoot + contextRoot + outputFile);
                        if (tmp.exists()) {
                            tmp.delete();
                        }
                        agt.setupGenerateCustomBedGraphTrackXML(chromosome, min, max, track, myOrganism, folderName, bedFile, outputFile, binSize, toHash);
                    }
                }
            }
            agt.start();
            status = "success";
        } else {
            status = "already running/queued";
        }
    } catch (Exception e) {
        status = "failed:" + e.toString();
        log.error("Error:AsyncGenerateTrack:", e);
    }
    JSONObject genejson;
    genejson = new JSONObject();
    genejson.put("status", status);
    response.setContentType("application/json");
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setDateHeader("Expires", 0);
    response.getWriter().write(genejson.toString());
%>





