var reportSelectedTrack = null;
var loadedTrackTable = null;
var regionDetailLoaded = {};

//automatically loads but keeping incase we decide to change functionality.
/*$(document).on('click','span.triggerRegionTable', function (event){
		console.log("triggerRegionTable");
		var baseName = $(this).attr("name");
        var thisHidden = $("div#" + baseName).is(":hidden");
        if (thisHidden) {
        	console.log("div#" + baseName+ " is hidden");
			$("div#" + baseName).show();
			$(this).addClass("less");
			var tc=new String(reportSelectedTrack.trackClass);
			if(tc=="coding" || tc=="noncoding" || tc=="smallnc" || tc=="qtl"){
				$("tr#regionDetailRow").show();
			}else{
				$("tr#regionDetailRow").hide();
			}
			if(!$('div#regionTable').is(":hidden")){
				loadTrackTable();
			}
			/*var curRptRegion=chr+":"+minCoord+"-"+maxCoord+":"+reportSelectedTrack;
			if( loadedTrackTable!=undefined  && regionDetailLoaded[baseName]==curRptRegion){
				//don't have to load might reset?
				console.log("div#" + baseName+ " is loaded");
			}else{
				//last loaded in a different region need to update.
				if(reportSelectedTrack!=null){
					
				}
				regionDetailLoaded[baseName]=curRptRegion;
			}*/
/*} else {
    console.log("div#" + baseName+ " is visible");
    $("div#" + baseName).hide();
    $(this).removeClass("less");
}
});*/

$(document).on('click', 'span.detailMenu', function (event) {
    var baseName = $(this).attr("name");
    var selectedTab = $('span.detailMenu.selected').attr("name");
    $("div#" + selectedTab).hide();
    $('span.detailMenu.selected').removeClass("selected");
    $("span[name='" + baseName + "']").addClass("selected");
    $("div#" + baseName).show();
    //check if loaded load if not
    if (typeof svgList[0] !== 'undefined') {
        var min = svgList[0].xScale.domain()[0];
        var max = svgList[0].xScale.domain()[1];
        loadRegionReport(baseName, chr, min, max);
    }

});

function loadRegionReport(reportName, chromosome, rptmin, rptmax) {
    var curRptRegion = chromosome + ":" + rptmin + "-" + rptmax;
    if (reportName === "regionTable") {
        curRptRegion = curRptRegion + ":" + reportSelectedTrack;
    }

    if (regionDetailLoaded[reportName] && regionDetailLoaded[reportName] === curRptRegion) {
        //don't have to load might reset?
        if (reportName === "regionWGCNAEQTL" && $("div#regionWGCNAEQTL").html() === "") {
            loadRegionWGCNA();
        }
    } else {
        if (reportName == "regionTable" && reportSelectedTrack != null) {
            loadTrackTable();
        } else if (reportName == "regionEQTLTable") {
            $("div#regionEQTLTable").html("<span style=\"text-align:center;width:100%;\"><img src=\"web/images/ucsc-loading.gif\"><BR>Loading...</span>");
            setTimeout(function () {
                loadEQTLTable();
            }, 750);
        } else if (reportName == "regionWGCNAEQTL") {
            loadRegionWGCNA();
        }
        regionDetailLoaded[reportName] = curRptRegion;
    }
    /*if(reportName==="regionEQTLTable"){
            if(tblFrom){
                    tblFrom.fnAdjustColumnSizing();
            }
    }*/
    /*if(ga){
						ga('send','event','loadRegionReport',reportName);
	}*/
    gtag('event', reportName, {'event_category': 'loadRegionReport'});
}

function loadTrackTable() {

    var min = svgList[0].xScale.domain()[0];
    var max = svgList[0].xScale.domain()[1];
    //console.log("loadTrackTable");
    //console.log(reportSelectedTrack.trackClass);
    var curRptRegion = chr + ":" + minCoord + "-" + maxCoord + ":" + reportSelectedTrack.trackClass;
    if (loadedTrackTable && loadedTrackTable === curRptRegion) {
        //don't have to load might reset?
        //console.log(curRptRegion);
        //console.log(loadedTrackTable);

    } else {

        loadedTrackTable = curRptRegion;
        var jspPage = "";
        var params = {
            species: organism,
            minCoord: min,
            maxCoord: max,
            chromosome: chr,
            rnaDatasetID: rnaDatasetID,
            arrayTypeID: arrayTypeID,
            forwardPvalueCutoff: forwardPValueCutoff,
            folderName: regionfolderName,
            genomeVer: genomeVer,
            track: reportSelectedTrack.trackClass,
            dataVer: dataVer
        };
        //console.log("ready to send");
        //console.log(params);
        if (reportSelectedTrack.trackClass.indexOf("noncoding") > -1) {
            params.type = "noncoding";
            params.source = "ensembl";
            if (reportSelectedTrack.trackClass.indexOf("brain") > -1) {
                params.source = "brain";
            }
            jspPage = "web/GeneCentric/geneTable.jsp";
        } else if (reportSelectedTrack.trackClass.indexOf("coding") > -1) {
            jspPage = "web/GeneCentric/geneTable.jsp";
            params.type = "coding";
            params.source = "ensembl";
            if (reportSelectedTrack.trackClass.indexOf("brain") > -1) {
                params.source = "brain";
            }
        } else if (reportSelectedTrack.trackClass === "liverTotal" || reportSelectedTrack.trackClass === "heartTotal" || reportSelectedTrack.trackClass === "brainTotal" || reportSelectedTrack.trackClass === "mergedTotal" || reportSelectedTrack.trackClass === "kidneyTotal") {
            jspPage = "web/GeneCentric/geneTable.jsp";
            params.type = "all";
            params.source = "liver";
            if (reportSelectedTrack.trackClass === "heartTotal") {
                params.source = "heart";
            } else if (reportSelectedTrack.trackClass.indexOf("brainTotal") > -1) {
                params.source = "brain";
            } else if (reportSelectedTrack.trackClass === "mergedTotal") {
                params.source = "merged";
            } else if (reportSelectedTrack.trackClass.indexOf("kidneyTotal") > -1) {
                params.source = "kidney";
            }
        } else if (reportSelectedTrack.trackClass.indexOf("smallnc") > -1) {
            params.source = "ensembl";
            if (reportSelectedTrack.trackClass.indexOf("brain") > -1) {
                params.source = "brain";
            } else if (reportSelectedTrack.trackClass.indexOf("heart") > -1) {
                params.source = "heart";
            }
            if (reportSelectedTrack.trackClass.indexOf("liver") > -1) {
                params.source = "liver";
            }
            jspPage = "web/GeneCentric/smallGeneTable.jsp";
        } else if ((new String(reportSelectedTrack.trackClass)).indexOf("snp") > -1) {
            //jspPage="web/GeneCentric/snpTable.jsp";
        } else if (reportSelectedTrack.trackClass === "qtl") {
            jspPage = "web/GeneCentric/bqtlTable.jsp";
        } else if (reportSelectedTrack.trackClass === "transcript") {

            //jspPage="web/GeneCentric/transcriptTable.jsp";
        } else {

        }
        if (jspPage) {
            loadDivWithPage("div#regionTable", jspPage, false, params,
                "<span style=\"text-align:center;width:100%;\"><img src=\"web/images/ucsc-loading.gif\"><BR>Loading...</span>", 0);
        }
    }
    /*if(ga){
        ga('send','event','loadTrackTable',reportSelectedTrack.trackClass);
    }*/
    gtag('event', reportSelectedTrack.trackClass, {'event_category': 'loadTrackTable'});
}

function loadEQTLTable() {
    var jspPage = "web/GeneCentric/regionEQTLTableSeq.jsp";
    var min = svgList[0].xScale.domain()[0];
    var max = svgList[0].xScale.domain()[1];

    transcriptome = $("#transriptome").val();
    cisOnly = $("#cisTrans").val();
    pValueCutoff = $("#pvalueCutoffSelect2").val();

    var params = {
        species: organism,
        minCoord: min,
        maxCoord: max,
        chromosome: chr,
        rnaDatasetID: rnaDatasetID,
        arrayTypeID: arrayTypeID,
        pValueCutoff: pValueCutoff,
        folderName: regionfolderName,
        genomeVer: genomeVer,
        transcriptome: transcriptome,
        cisOnly: cisOnly

    };
    if (dataVer != "hrdp7.1") {
        loadDivWithPage("div#regionEQTLTable", jspPage, false, params,
            "<span style=\"text-align:center;width:100%;\"><img src=\"web/images/ucsc-loading.gif\"><BR>Loading...</span>", 0);
    } else {
        $("div#regionEQTLTable").css("font-size", "20pt").css("color", "#FF0000").html("Coming soon for HRDP v7.1.  HRDP v6(rn7) does have eQTLs if you would like to switch please change the drop down list at the top of the page.");
    }
    gtag('event', 'eQTLTable', {'event_category': 'loadEQTLTable'});
}


function loadRegionWGCNA() {
    $("div#geneWGCNA").html("");
    var jspPage = "web/GeneCentric/wgcnaGene.jsp";
    var curmin = svgList[0].xScale.domain()[0];
    var curmax = svgList[0].xScale.domain()[1];
    var params = {
        region: chr + ":" + curmin + "-" + curmax
    };
    if (dataVer != "hrdp7.1") {
        loadDivWithPage("div#regionWGCNAEQTL", jspPage, true, params,
            "<span style=\"text-align:center;width:100%;\"><img src=\"web/images/ucsc-loading.gif\"><BR>Loading...</span>", 0);
    } else {
        $("div#regionWGCNAEQTL").css("font-size", "20pt").css("color", "#FF0000").html("Coming soon for HRDP v7.1.  HRDP v6(rn7) does have WGCNA modules if you would like to switch please change the drop down list at the top of the page.");
    }

    gtag('event', 'wgcna', {'event_category': 'loadWGCNA'});
}

function loadEQTLTableWParams(levelList, chrList, tisList, pval, dataSource) {
    var jspPage = "web/GeneCentric/regionEQTLTableSeq.jsp";
    var min = svgList[0].xScale.domain()[0];
    var max = svgList[0].xScale.domain()[1];

    transcriptome = $("#transriptome").val();
    cisOnly = $("#cisTrans").val();
    pValueCutoff = $("#pvalueCutoffSelect2").val();
    var params = {
        genomeVer: genomeVer,
        species: organism,
        minCoord: min,
        maxCoord: max,
        chromosome: chr,
        rnaDatasetID: rnaDatasetID,
        arrayTypeID: arrayTypeID,
        pValueCutoff: pValueCutoff,
        tissues: tisList,
        chromosomes: chrList,
        //levels:levelList,
        folderName: regionfolderName,
        //dataSource:dataSource,
        transcriptome: transcriptome,
        cisOnly: cisOnly

    };
    loadDivWithPage("div#regionEQTLTable", jspPage, false, params,
        "<span style=\"text-align:center;width:100%;\"><img src=\"web/images/ucsc-loading.gif\"><BR>Loading...</span>", 0);
    /*if(ga){
        ga('send','event','loadEQTLTableWParams','eqtlwparams');
    }*/
    gtag('event', 'eqtlwparams', {'event_category': 'loadEQTLTableWParams'});
}


function loadDivWithPage(divSelector, jspPage, scrollToDiv, params, loadingHTML, retryNum) {
    $(divSelector).html(loadingHTML);
    $.ajax({
        url: jspPage,
        type: 'GET',
        cache: false,
        data: params,
        dataType: 'html',
        async: true,
        success: function (data2) {
            $(divSelector).html(data2);
            if (scrollToDiv) {
                setTimeout(function () {
                    $('html, body').animate({
                        scrollTop: $(divSelector).offset().top
                    }, 200);
                }, 300);
            }
            //setTimeout(displayHelpFirstTime,200);
        },
        error: function (xhr, status, error) {
            if (jspPage.indexOf("geneReport.jsp") == -1 || (jspPage.indexOf("geneReport.jsp") > 0 && retryNum < 30)) {
                $(divSelector).html("<span style=\"color:#FF0000;\">An error occurred generating this page.  This can occur when loading the report the first time. Will automatically continue trying to load the report.</span>");
                setTimeout(function () {
                    loadDivWithPage(divSelector, jspPage, scrollToDiv, params, loadingHTML, retryNum + 1);
                }, 15000);
            } else {
                $(divSelector).html("<span style=\"color:#FF0000;\">An error occurred generating this page.  This can happen initially when loading the report. This error has occurred too many times and has been reported.</span>");
            }

        }
    });
}

function trKey(d) {
    var key = "";
    if (d) {
        key = d.trackClass;
    }
    return key;
}

function DisplayRegionReport() {
    //console.log("DisplayRegionReport");
    //d3.select('#collaspableReportList').selectAll('li').remove();
    if (d3.select('#collapsableReportList').size() > 0) {
        var tmptrackList = svgList[0].trackList;
        if (reportSelectedTrack) {
            for (var i = 0; i < tmptrackList.length && !reportSelectedTrack; i++) {
                //console.log(tmptrackList[i].trackClass);
                //console.log(tmptrackList[i].getDisplayedData);
                if (tmptrackList[i] && tmptrackList[i].getDisplayedData) {
                    reportSelectedTrack = tmptrackList[i];
                }
            }
        }
        var list = d3.select('#collapsableReportList').selectAll('li.report').data(tmptrackList, trKey).html(function (d) {
            var label = "";
            if (d) {
                if (d.getDisplayedData) {
                    var data = d.getDisplayedData();
                    //console.log(data);
                    //console.log(d.label+": "+data.length);
                    label = d.label + ": " + data.length;
                }
            }
            return label;
        });

        list.enter().append("li")
            .attr("class", function (d) {
                if (d) {
                    return "report " + d.trackClass;
                } else {
                    return "report";
                }
            })
            .html(function (d) {
                var label = "";
                if (d) {
                    if (d.getDisplayedData) {
                        var data = d.getDisplayedData();
                        //console.log(data);
                        //console.log(d.label+": "+data.length);
                        label = d.label + ": " + data.length;
                    }
                }
                return label;
            })
            .on("click", displayDetailedView);

        list.exit().remove();

        if (!$('div#collapsableReport').is(":hidden") && reportSelectedTrack) {
            displayDetailedView(reportSelectedTrack);
        }
    }
    var selectedTab = $('span.detailMenu.selected').attr("name");
    var curmin = svgList[0].xScale.domain()[0];
    var curmax = svgList[0].xScale.domain()[1];
    loadRegionReport(selectedTab, chr, curmin, curmax);
    /*if(ga){
		ga('send','event','loadRegionReport','regionReport');
	}*/
    gtag('event', 'regionReport', {'event_category': 'loadRegionReport'});
}

function displayDetailedView(track) {
    //console.log("displayDetailedView:"+track);
    reportSelectedTrack = track;
    $('li.report').removeClass("selected");
    $("li." + track.trackClass).addClass("selected");
    if (track.displayBreakDown) {
        setTimeout(function () {
            //console.log("in displayDetailedView()");
            $('div#trackGraph').html("");
            track.displayBreakDown("div#collapsableReport div#trackGraph");
        }, 50);
    }
    var tc = new String(track.trackClass);
    if (tc.indexOf("coding") > -1 || tc.indexOf("noncoding") > -1 || tc.indexOf("smallnc") > -1 ||
        tc.indexOf("liverTotal") > -1 || tc.indexOf("heartTotal") > -1 || tc.indexOf("brainTotal") > -1 || tc.indexOf("mergedTotal") > -1 || tc.indexOf("kidneyTotal") > -1 || tc == "qtl") {
        $("#regionTableSubHeader").show();
        $("#regionTable").show();
    } else {
        $("#regionTableSubHeader").hide();
        $("#regionTable").hide();
    }
    if (!$('div#regionTable').is(":hidden")) {
        //console.log("loading track table");
        loadTrackTable();
    }
    /*if(ga){
        ga('send','event','loaddetailedView',track);
    }*/
    gtag('event', track, {'event_category': 'loaddetailedView'});
}


function DisplaySelectedDetailReport(jspPage, params) {
    timeout = 5;
    if (jspPage.indexOf("geneReport.jsp") > 0) {
        $("div#selectedReport").hide();
        timeout = 3000;
    }
    setTimeout(function () {
        loadDivWithPage("div#selectedReport", jspPage, false, params,
            "<span style=\"text-align:center;width:100%;\"><img src=\"web/images/ucsc-loading.gif\"><BR>Loading...</span>", 0);
        if (jspPage.indexOf("geneReport.jsp") > 0) {
            $("div#selectedReport").show();
        }
    }, timeout);
}
