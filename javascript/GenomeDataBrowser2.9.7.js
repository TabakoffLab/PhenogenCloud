/*
*	D3js based Genome Data Browser
*
* 	Author: Spencer Mahaffey
*	for http://phenogen.ucdenver.edu
*	Tabakoff Lab
* 	University of Colorado Denver AMC
* 	Department of Pharmaceutical Sciences Skaggs School of Pharmacy & Pharmaceutical Sciences
*
*	Builds an interactive multilevel view of the rat/mouse genome.
*/

$.cookie.defaults.expires = 365;
//global varaiable to store a list of GenomeSVG images representing each level.
var svgList = [];
var svgViewIDList = [];
var processAjax = 0;
var ajaxList = [];
var trackInfo = [];
var selectedGeneSymbol = "";
var selectedID = "";
var trackSettings = [];
var overSelectable = 0;
var zoomUpdateHandle = Math.NaN;


var ratOnly = [];
var mouseOnly = [];
var history = [];
history[0] = [];
history[1] = [];

var customTrackCount = 0;

var testChrome = /chrom(e|ium)/.test(navigator.userAgent.toLowerCase());
var testSafari = /safari/.test(navigator.userAgent.toLowerCase());
var testFireFox = /firefox/.test(navigator.userAgent.toLowerCase());
var testIE = /(wow|.net|ie)/.test(navigator.userAgent.toLowerCase());
if (testChrome && testSafari) {
    testSafari = false;
}
if (testIE && !testChrome && !testFireFox && !testSafari) {
    $("#IEproblem").show();
}
/*console.log(navigator.userAgent.toLowerCase());
console.log("chrome:"+testChrome);
console.log("safari:"+testSafari);
console.log("ie:"+testIE);
console.log("firefox:"+testFireFox);*/


//var defaultMouseFunct="pan";

ratOnly.snpSHRJ = 1;
ratOnly.snpF344 = 1;
ratOnly.snpSHRH = 1;
ratOnly.snpBNLX = 1;
ratOnly.helicos = 1;
ratOnly.spliceJnct = 1;
ratOnly.illuminaTotal = 1;
ratOnly.illuminaSmall = 1;
ratOnly.illuminaPolyA = 1;
ratOnly.liverTotal = 1;
ratOnly.liverspliceJnct = 1;
ratOnly.liverilluminaTotalPlus = 1;
ratOnly.liverilluminaTotalMinus = 1;
ratOnly.polyASite = 1;
ratOnly.braincoding = 1;
ratOnly.brainnoncoding = 1;
ratOnly.brainsmallnc = 1;
ratOnly.heartTotal = 1;
ratOnly.kidneyTotal = 1;
ratOnly.heartilluminaTotalPlus = 1;
ratOnly.heartilluminaTotalMinus = 1;
ratOnly.probe = 1;
ratOnly.mergedTotal = 1;
ratOnly.brainIso = 1;
ratOnly.liverIso = 1;


if (genomeVer === "rn5") {
    mouseOnly.brainTotal = 1;
}
mouseOnly.brainilluminaTotalPlus = 1;
mouseOnly.brainilluminaTotalMinus = 1;
mouseOnly.brainspliceJnct = 1;
mouseOnly.probeMouse = 1;


var mmVer = "Mouse(<span id=\"verSelect\"></span>) Strain:C57BL/6J";
var rnVer = "Rat(<span id=\"verSelect\"></span>) HRDP version:<span id=\"hrdpSelect\"></span> Strain:BN";
var siteVer = "PhenoGen v3.9.6(8/23/2024)";

var trackBinCutoff = 10000;
var customTrackLevel = -1;
var mouseTTOver = 0;
var ttHideHandle = 0;


//setup tooltip text div
var tt = d3.select("body").append("div")
    .attr("class", "testToolTip")
    .style("z-index", 1001)
    .style("opacity", 0);
/*.on("mouseover",function(){
	    		if($(this).css("opacity")>0){
	    			console.log("mouse is over tooltiptext box");
	    			$(this).css("opacity",1);
	    			if($(this).css("opacity")>0){
					    		console.log("Mouse OVER TT");
					    		mouseTTOver=1;
					    		if(ttHideHandle!=0){
					    			clearTimeout(ttHideHandle);
					    			ttHideHandle=0;
					    		}
					}
				}
			})
	    	.on("mouseout",function(){
	    		console.log("Mouse out of tooltiptext box");
	    		tt.transition()
					.delay(200)
	                .duration(200)
	                .style("opacity", 0);
	    		if($(this).css("opacity")>0){
		    		mouseTTOver=0;
		    		ttHideHandle=setTimeout(function(){
		    						if(mouseTTOver==0){
						    			console.log("Mouse still out hiding tt.")
						    			tt.transition()
												.delay(200)
								                .duration(200)
								                .style("opacity", 0);
							        }

					},3000);
	    		}

	    	});*/
tt.append("span").style("float", "right").append("img").attr("src", "web/images/icons/close.png").on("click", function () {
    tt.style("opacity", 0);
});


var tsDialog = d3.select("body").append("div")
    .attr("class", "trackSetting")
    .attr("id", "trackSettingDialog")
    .style("z-index", 1001)
    .style("margin-left", "15px")
    .style("margin-right", "15px");
tsDialog.append("div").attr("id", "trackSettingContent").append("table").attr("cellpadding", "0").attr("cellspacing", "0").append("tbody");


function updatePage(topSVG) {
    'use strict';
    var min = Math.round(topSVG.xScale.domain()[0]), max = Math.round(topSVG.xScale.domain()[1]), tmpMin, tmpMax;
    if ((min < topSVG.prevMinCoord || max > topSVG.prevMaxCoord) && (min < topSVG.dataMinCoord || max > topSVG.dataMaxCoord)) {
        processAjax = 1;
        tmpMin = min;
        tmpMax = max;
        if (min >= topSVG.dataMinCoord && max > topSVG.dataMaxCoord) {
            tmpMin = topSVG.dataMaxCoord + 1;
        } else if (min < topSVG.dataMinCoord && max <= topSVG.dataMaxCoord) {
            tmpMax = topSVG.dataMinCoord - 1;
        }
        topSVG.setLoading();
        $.ajax({
            url: pathPrefix + "updateRegion.jsp",
            type: 'GET',
            data: {
                chromosome: chr,
                minCoord: tmpMin,
                maxCoord: tmpMax,
                fullminCoord: min,
                fullmaxCoord: max,
                panel: panel,
                rnaDatasetID: rnaDatasetID,
                arrayTypeID: arrayTypeID,
                myOrganism: organism,
                genomeVer: genomeVer,
                dataVer: dataVer
            },
            dataType: 'json',
            success: function (data2) {
                topSVG.prevMinCoord = min;
                topSVG.prevMaxCoord = max;
                if (min < topSVG.dataMinCoord) {
                    topSVG.dataMinCoord = min;
                }
                if (max > topSVG.dataMaxCoord) {
                    topSVG.dataMaxCoord = max;
                }
                //regionfolderName=data2.folderName;
                topSVG.folderName = data2.folderName;
                topSVG.updateData();
                processAjax = 0;
                /*if(ga){
						ga('send','event','updatePage','outsideLoadedRegion');
					}*/
                gtag('event', 'outsideLoadedRegion', {'event_category': 'updatePage'});
            },
            error: function (xhr, status, error) {
                console.log(error);
            }
        });
    }

}

function back(level) {
    var tmp = {};
    if (history && history[level]) {
        if (history[level].length > 1) {
            tmp = history[level].pop();
        } else {
            tmp = history[level][0];
        }
        if (chr == tmp.chr) {
            if (tmp.start == svgList[level].xScale.domain()[0] && tmp.stop == svgList[level].xScale.domain()[1]) {
                if (history[level].length > 1) {
                    tmp = history[level].pop();
                } else {
                    tmp = history[level][0];
                }
            }
            if (level == 0) {
                $('#geneTxt').val(tmp.chr + ":" + tmp.start + "-" + tmp.stop);
            }
            svgList[level].xScale.domain([tmp.start, tmp.stop]);
            svgList[level].scaleSVG.select(".x.axis").call(svgList[level].xAxis);
            svgList[level].redraw();
            if (level === 0) {
                updatePage(svgList[level]);
            }
            svgList[level].updateFullData();
        } else {//reload

        }
    }
    /*if(ga){
		ga('send','event','stepBackSVGNaviation','navigateBack');
	}*/
    gtag('event', 'navigateBack', {'event_category': 'stepBackSVGNaviation'});
}

function zoomIn(level, zoomScale) {
    var tmp = {};
    tmp.chr = chr;
    tmp.start = svgList[level].xScale.domain()[0];
    tmp.stop = svgList[level].xScale.domain()[1];

    var len = tmp.stop - tmp.start;
    var contractBy = Math.floor(len * zoomScale);
    if (contractBy < 1) {
        contractBy = 1;
    }
    tmp.start = tmp.start + contractBy;
    tmp.stop = tmp.stop - contractBy;
    if (tmp.stop - tmp.start < 20) {
        tmp.start = tmp.start - contractBy;
        tmp.stop = tmp.stop + contractBy;
    }
    svgList[level].xScale.domain([tmp.start, tmp.stop]);
    if (!history[level]) {
        history[level] = [];
    }
    history[level].push(tmp);
    svgList[level].scaleSVG.select(".x.axis").call(svgList[level].xAxis);
    svgList[level].redraw();
    if (!isNaN(zoomUpdateHandle)) {
        clearTimeout(zoomUpdateHandle);
        zoomUpdateHandle = Math.NaN;
    }
    zoomUpdateHandle = setTimeout(function () {
        if (level === 0) {
            updatePage(svgList[level]);
        }
        svgList[level].updateFullData();
        if (level === 0) {
            setTimeout(function () {
                DisplayRegionReport();
            }, 100);
        }
    }, 300);
    if (level === 0) {
        $('#geneTxt').val(chr + ":" + tmp.start + "-" + tmp.stop);
    }
    /*if(ga){
		ga('send','event',,level);
	}*/

    gtag('event', level, {'event_category': 'calledZoomIn'});
}

function zoomOut(level, zoomScale) {
    var tmp = {};
    tmp.chr = chr;
    tmp.start = svgList[level].xScale.domain()[0];
    tmp.stop = svgList[level].xScale.domain()[1];

    var len = tmp.stop - tmp.start;
    var expandBy = Math.floor(len * zoomScale);
    if (expandBy < 1) {
        expandBy = 1;
    }
    tmp.start = tmp.start - expandBy;
    tmp.stop = tmp.stop + expandBy;
    if (tmp.stop - tmp.start < 10000000) {
        svgList[level].xScale.domain([tmp.start, tmp.stop]);
        if (!history[level]) {
            history[level] = [];
        }
        history[level].push(tmp);
        svgList[level].scaleSVG.select(".x.axis").call(svgList[level].xAxis);
        svgList[level].redraw();
        if (!isNaN(zoomUpdateHandle)) {
            clearTimeout(zoomUpdateHandle);
            zoomUpdateHandle = Math.NaN;
        }
        zoomUpdateHandle = setTimeout(function () {
            if (level === 0) {
                updatePage(svgList[level]);
            }
            svgList[level].updateFullData();
            if (level === 0) {
                setTimeout(function () {
                    DisplayRegionReport();
                }, 100);
            }
        }, 300);
        if (level === 0) {
            $('#geneTxt').val(chr + ":" + tmp.start + "-" + tmp.stop);
        }
        /*if(ga){
            ga('send','event','calledZoomOut',level);
        }*/
        gtag('event', level, {'event_category': 'calledZoomOut'});
    } else {
        alert("maximum viewable area is 10Mb.")
    }
}

//setup event handlers
function mup() {
    var i = 0, p, start, width, minx, maxx;
    for (i = 0; i < svgList.length; i++) {
        if (svgList[i] && typeof svgList[i] !== 'undefined') {
            if (!history[i] && (i == 0 || i == 1)) {
                history[i] = [];
            }
            if ((!svgList[i].overSettings || svgList[i].overSettings == 0) && (!isNaN(svgList[i].downx) || !isNaN(svgList[i].downPanx))) {
                if (i === 0) {
                    updatePage(svgList[i]);
                }
                svgList[i].downx = Math.NaN;
                svgList[i].downPanx = Math.NaN;
                svgList[i].updateFullData();
                if (i === 0) {
                    setTimeout(function () {
                        DisplayRegionReport();
                    }, 300);
                }
                if (i == 0 || i == 1) {
                    var tmp = {};
                    tmp.chr = chr;
                    tmp.start = svgList[i].xScale.domain()[0];
                    tmp.stop = svgList[i].xScale.domain()[1];
                    history[i].push(tmp);
                }
            } else if ((!svgList[i].overSettings || svgList[i].overSettings == 0) && !isNaN(svgList[i].downZoomx)) {
                start = svgList[i].downZoomx;
                p = d3.mouse(svgList[i].vis.node());
                svgList[i].downZoomxEnd = p[0];
                width = 1;
                if (p[0] < start) {
                    start = p[0];
                    width = svgList[i].downZoomx - start;
                } else {
                    width = p[0] - start;
                }
                minx = Math.round(svgList[i].xScale.invert(start));
                maxx = Math.round(svgList[i].xScale.invert(start + width));
                svgList[i].downZoomx = Math.NaN;
                svgList[i].downZoomxEnd = Math.NaN;
                if (i === 0) {
                    $('#geneTxt').val(chr + ":" + minx + "-" + maxx);
                }
                d3.select("#Level" + svgList[i].levelNumber).selectAll("svg rect.zoomRect").remove();
                d3.select("#Level" + svgList[i].levelNumber).selectAll("svg text#zoomTextStart").remove();
                d3.select("#Level" + svgList[i].levelNumber).selectAll("svg text#zoomTextEnd").remove();
                svgList[i].xScale.domain([minx, maxx]);
                svgList[i].scaleSVG.select(".x.axis").call(svgList[i].xAxis);
                svgList[i].redraw();
                svgList[i].updateFullData();
                if (i === 0) {
                    setTimeout(function () {
                        DisplayRegionReport();
                    }, 300);
                }
                if (i == 0 || i == 1) {
                    var tmp = {};
                    tmp.chr = chr;
                    tmp.start = minx;
                    tmp.stop = maxx;
                    history[i].push(tmp);
                }
            }
        }
    }
    /*if(ga){
		ga('send','event','dragMouseUp','mouseUpFromDrag');
	}*/
    gtag('event', 'mouseUpFromDrag', {'event_category': 'dragMouseUp'});
}

function mmove() {
    var i, p, minx, maxx, dist, scaleDist, start, width;
    for (i = 0; i < svgList.length; i++) {
        if (svgList[i] && (!svgList[i].overSettings || svgList[i].overSettings === 0)) {
            if (!isNaN(svgList[i].downx)) {
                p = d3.mouse(svgList[i].vis.node()), rupx = p[0];
                if (rupx !== 0) {
                    minx = Math.round(svgList[i].downscalex.domain()[0]);
                    maxx = Math.round(svgList[i].mw * (svgList[i].downx - svgList[i].downscalex.domain()[0]) / rupx + svgList[i].downscalex.domain()[0]);
                    if (maxx - minx < 10000000) {
                        if (maxx <= svgList[i].xMax && minx >= svgList[i].xMin) {
                            if (i === 0) {
                                $('#geneTxt').val(chr + ":" + minx + "-" + maxx);
                            }
                            svgList[i].xScale.domain([minx, maxx]);
                            svgList[i].scaleSVG.select(".x.axis").call(svgList[i].xAxis);
                            svgList[i].redraw();
                        }
                    } else {
                        alert("Maximum view is 10Megabases.");
                    }
                }
            } else if (!isNaN(svgList[i].downPanx)) {
                p = d3.mouse(svgList[i].vis.node()), rupx = p[0];
                if (rupx !== 0) {
                    dist = svgList[i].downPanx - rupx;
                    scaleDist = (svgList[i].downscalex.domain()[1] - svgList[i].downscalex.domain()[0]) / svgList[i].mw;
                    minx = Math.round(svgList[i].downscalex.domain()[0] + dist * scaleDist);
                    maxx = Math.round(dist * scaleDist + svgList[i].downscalex.domain()[1]);
                    if (maxx - minx < 10000000) {
                        if (maxx <= svgList[i].xMax && minx >= svgList[i].xMin) {
                            if (i === 0) {
                                $('#geneTxt').val(chr + ":" + minx + "-" + maxx);
                            }
                            svgList[i].xScale.domain([minx, maxx]);
                            svgList[i].scaleSVG.select(".x.axis").call(svgList[i].xAxis);
                            svgList[i].redraw();
                            svgList[i].downPanx = p[0];
                        }
                    } else {
                        alert("Maximum view is 10Megabases.");
                    }
                }
            } else if (!isNaN(svgList[i].downZoomx)) {
                start = svgList[i].downZoomx;
                p = d3.mouse(svgList[i].vis.node());
                svgList[i].downZoomxEnd = p[0];
                width = 1;
                if (p[0] < start) {
                    start = p[0];
                    width = svgList[i].downZoomx - start;
                } else {
                    width = p[0] - start;
                }
                minx = Math.round(svgList[i].xScale.invert(start));
                maxx = Math.round(svgList[i].xScale.invert(start + width));
                if (maxx - minx < 10000000) {
                    d3.select("#Level" + svgList[i].levelNumber).selectAll("svg rect.zoomRect")
                        .attr("x", start)
                        .attr("width", width);
                    d3.select("#Level" + svgList[i].levelNumber).selectAll("svg text#zoomTextStart").attr("x", start).attr("y", 15).text(numberWithCommas(minx));
                    d3.select("#Level" + svgList[i].levelNumber).selectAll("svg text#zoomTextEnd").attr("x", start + width).attr("y", 50).text(numberWithCommas(maxx));
                } else {
                    alert("Maximum view is 10Megabases.");
                }
            }
        }
    }
}

d3.select('html')
    .on("mousemove", mmove)
    .on("mouseup", mup);


$(window).resize(function () {
    for (var i = 0; i < svgList.length; i++) {
        if (svgList[i]) {
            svgList[i].resize($(window).width() - 25);
        }
    }
});

$(document).on("click", ".closeBtn", function () {
    var setting = new String($(this).attr("id"));
    setting = setting.substr(6);
    $("." + setting).fadeOut("fast");
    if (setting.indexOf("viewsLevel") > -1) {
        var tmpLevel = setting.substr(setting.length - 1);
        $("div#nameView" + tmpLevel).hide();
        $("div#selection" + tmpLevel).show();
        $("span#viewMenuLbl" + tmpLevel).html("Select/Edit Views");
        $("div.trackLevel" + tmpLevel).fadeOut("fast");
    }
    /*if(ga){
						ga('send','event','closeSettings',setting);
					}*/
    gtag('event', setting, {'event_category': 'closeSettings'});
    return false;
});


$(document).on("click", ".viewSelect", function () {
    var setting = $(this).attr("id");
    var level = setting.substr(setting.length - 1);
    if (!$(".viewsLevel" + level).is(":visible")) {
        var p = $(this).parent().parent().position();
        //console.log(p);
        var top = p.top;
        $(".viewsLevel" + level).css("top", top).css("left", $(window).width() - 610);
        $(".viewsLevel" + level).fadeIn("fast");
        $("#trackSettingDialog").hide();
        tt.transition()
            .duration(200)
            .style("opacity", 0);
        //$(".testToolTip").hide();
        //var tmpStr=new String(setting);
        //setupSettingUI(tmpStr.substr(tmpStr.length-1));
        /*if(ga){
							ga('send','event','openViews',level);
						}*/
        gtag('event', level, {'event_category': 'openViews'});
    } else {
        $(".viewsLevel" + level).fadeOut("fast");
    }
    return false;
});

$(document).on("change", "input[name='optioncbx']", function () {
    var idStr = new String($(this).attr("id"));
    var cbxInd = idStr.indexOf("CBX");
    var prefix = new String(idStr.substr(0, cbxInd));
    var level = idStr.substr(cbxInd + 3, 1);
    redrawTrack(level, prefix);
    /*if(ga){
						ga('send','event','changeSettingView',idStr);
	}*/
    gtag('event', idStr, {'event_category': 'changeSettingView'});
});


$(document).on("change", "input[name='imgCBX']", function () {
    var idStr = new String($(this).attr("id"));
    var cbxInd = idStr.indexOf("CBX");
    var prefix = new String(idStr.substr(0, cbxInd));
    var level = idStr.substr(cbxInd + 3, 1);
    svgList[level].redraw();
    setTimeout(function () {
        DisplayRegionReport();
    }, 300);
    /*if(ga){
						ga('send','event','clickCbx',idStr);
	}*/
    gtag('event', idStr, {'event_category': 'clickCbx'});
});

$(document).on("click", ".reset", function () {
    var id = new String($(this).attr("id"));
    var level = id.substr(id.length - 1);
    if (id.indexOf("resetImage") === 0) {
        if (level === 0) {
            $('#geneTxt').val(chr + ":" + initMin + "-" + initMax);
            svgList[0].xScale.domain([initMin, initMax]);
            svgList[0].scaleSVG.select(".x.axis").call(svgList[0].xAxis);
            svgList[0].redraw();
        }
    } else if (id.indexOf("resetTracks") === 0) {
        svgList[level].removeAllTracks();
        setupDefaultView(level);
        //saveToCookie(level);
    }
    /*if(ga){
						ga('send','event','resetImage',id);
	}*/
    gtag('event', id, {'event_category': 'resetImage'});
});


function numberWithCommas(x) {
    return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

function displayHelpFirstTime() {
    if (navigator.userAgent.toLowerCase().indexOf("phantomjs") === -1) {
        if ($.cookie("genomeBrowserHelp")) {
            var trackListObj = $.cookie("genomeBrowserHelp");
            var vInd = trackListObj.indexOf("v") + 1;
            var periodInd = trackListObj.indexOf(".", trackListObj.indexOf(".") + 1);
            trackListObj = trackListObj.substr(vInd, periodInd - vInd);
            vInd = siteVer.indexOf("v") + 1;
            periodInd = siteVer.indexOf(".", siteVer.indexOf(".") + 1);
            var curVer = siteVer.substr(vInd, periodInd - vInd);
            if (trackListObj === curVer) {


            } else {
                setTimeout(function () {
                    $("a#fbhelp1").click();
                }, 1000);
                $.cookie("genomeBrowserHelp", siteVer);
            }
        } else {
            setTimeout(function () {
                $("a#fbhelp1").click();
            }, 1000);
            $.cookie("genomeBrowserHelp", siteVer);
        }
    }
}

function removeTrack(level, track) {
    if (typeof svgList[level] !== 'undefined') {
        svgList[level].removeTrack(track);
    }
    /*if(ga){
		ga('send','event','removeTrack',level,track);
	}*/
    gtag('event', level, {'event_category': 'removeTrack', 'event_label': track});
}

function redrawTrack(level, track) {
    svgList[level].redrawTrack(track);
    /*if(ga){
		ga('send','event','redrawTrack',level,track);
	}*/
    gtag('event', level, {'event_category': 'redrawTrack', 'event_label': track});
}

function changeTrackHeight(id, val) {
    if (val > 0) {
        var size = val + "px";
        $("#Scroll" + id).css({"max-height": size, "overflow": "auto"});
    } else {
        $("#Scroll" + id).css({"max-height": '', "overflow": "hidden"});
    }

}

registerKeyboardHandler = function (callback) {
    var callback = callback;
    d3.select(window).on("keydown", callback);
};

//Helper functions

function getAllChildrenByName(parentNode, name) {
    var list = [];
    var listCount = 0;
    if (typeof parentNode !== 'undefined' && parentNode !== null && typeof parentNode.childNodes !== 'undefined') {
        var listInit = parentNode.childNodes;
        for (var k = 0; k < listInit.length; k++) {
            if (listInit.item(k).nodeName == name) {
                list[listCount] = listInit.item(k);
                listCount++;
            }
        }
    }
    return list;
}

function getFirstChildByName(parentNode, name) {
    var node = null;
    if (parentNode !== null && typeof parentNode !== 'undefined' && typeof parentNode.childNodes !== 'undefined') {
        var listInit = parentNode.childNodes;
        var found = false;
        for (var k = 0; k < listInit.length && !found; k++) {
            if (listInit.item(k).nodeName == name) {
                node = listInit.item(k);
                found = true;
            }
        }
    }
    return node;
}

function getAddMenuDiv(level, type) {
    var tmpContext = "/" + pathPrefix;
    if (pathPrefix == "") {
        tmpContext = "";
    }
    $.ajax({
        url: tmpContext + "settingsMenu.jsp",
        type: 'GET',
        cache: false,
        data: {level: level, organism: organism, type: type},
        dataType: 'html',
        success: function (data2) {
            $("#imageMenu" + level).remove();
            d3.select("div#imageMenu").append("div").attr("id", "imageMenu" + level);
            $("#imageMenu" + level).html(data2);
        },
        error: function (xhr, status, error) {
            $("#imageMenu" + level).remove();
            d3.select("div#imageMenu").append("div").attr("id", "imageMenu" + level);
            $('#imageMenu' + level).append("<div class=\"settingsLevel" + level + "\">An error occurred generating this menu.  Please try back later.</div>");
        },
        async: false
    });
}


//Load/Save settings to/from cookies
function loadStateFromString(state, imgState, levelInd, svg) {
    /*if(svgList[levelInd]!=undefined){
		svgList[levelInd].removeAllTracks();
	}*/
    //console.log(state);
    //TODO MAKE SURE TO LOAD CUSTOM TRACKS ON LOADING TRACK EDITOR
    loadSavedConfigTracks(state, levelInd, svg);
    loadImageState(imgState, levelInd);
}


function loadSavedConfigTracks(trackListObj, levelInd, curSvg) {
    var trackArray = trackListObj.split(";");
    var addedCount = 0;
    var tmpSvg = NaN;
    if (levelInd < 90) {
        tmpSvg = svgList[levelInd];
    } else {
        tmpSvg = curSvg;
    }
    for (var m = 0; m < trackArray.length; m++) {
        var trackVars = trackArray[m].split(",");
        //console.log("loadingSavedTrack");
        //console.log(trackVars);
        if ((organism == "Rn" && typeof mouseOnly[trackVars[0]] === 'undefined') || (organism == "Mm" && typeof ratOnly[trackVars[0]] === 'undefined')) {
            if (trackVars[0] != "") {
                addedCount++;
                var ext = "";
                if (trackVars.length > 2) {
                    for (var n = 2; n < trackVars.length; n++) {
                        if (n == 2) {
                            ext = trackVars[n];
                        } else {
                            ext = ext + "," + trackVars[n];
                        }
                    }
                }
                if (levelInd == 1) {
                    ext = ext + ",DrawTrx";
                }
                //setTimeout(function (){
                tmpSvg.addTrack(trackVars[0], trackVars[1], ext, 0);
                //	},25*m);


            }
        }
    }
    if (addedCount == 0) {
        setupDefaultView(levelInd);
        //saveToCookie(levelInd);
    }
    /*}else{
		setupDefaultView(levelInd);
    	saveToCookie(levelInd);
	}*/
    /*if(hasOldTrackValues){
		saveToCookie(levelInd);
	}*/
}

function loadImageState(trackListObj, levelInd) {
    /*if($.cookie("imgstate"+defaultView+levelInd)!=null){
    	var trackListObj=$.cookie("imgstate"+defaultView+levelInd);*/
    if (typeof trackListObj !== 'undefined' && trackListObj != "") {
        var trackArray = trackListObj.split(";");
        for (var m = 0; m < trackArray.length; m++) {
            var trackVars = trackArray[m].split("=");
            var tmp = new String(trackVars[0]);
            if (tmp.indexOf("displaySelect") == 0) {
                changeTrackHeight("Level" + levelInd, trackVars[1]);
            }
        }
    }

    //}
}

function calculateBin(len, width) {
    var bpPerPixel = len / width;
    bpPerPixel = Math.floor(bpPerPixel);
    var bpPerPixelStr = new String(bpPerPixel);
    var firstDigit = bpPerPixelStr.substr(0, 1);
    var firstNum = firstDigit * Math.pow(10, (bpPerPixelStr.length - 1));
    var bin = firstNum / 2;
    bin = Math.floor(bin);
    if (bin < 5) {
        bin = 0;
    }
    return bin;
}

//D3 helper functions
function key(d) {
    if (typeof d !== 'undefined') {
        return d.getAttribute("ID");
    } else {
        return "unknown"
    }
};

function keyName(d) {
    if (typeof d !== 'undefined') {
        return d.getAttribute("name");
    } else {
        return "unknown"
    }
};

function keyStart(d) {
    if (typeof d !== 'undefined') {
        return d.getAttribute("start");
    } else {
        return "unknown"
    }
};

function keyTissue(d, tissue) {
    if (typeof d !== 'undefined') {
        return d.getAttribute("ID") + tissue;
    } else {
        return "unknown"
    }
};

function keyPos(d) {
    if (typeof d !== 'undefined') {
        return d.pos;
    } else {
        return "unknown"
    }
};

function keyID(d) {
    if (typeof d !== 'undefined') {
        return d.id;
    } else {
        return "unknown"
    }
};

function keySNP(d) {
    if (typeof d !== 'undefined') {
        return d.getAttribute("strain") + "_" + d.getAttribute("start");
    } else {
        return "unknown";
    }
}

//SVG functions
function GenomeSVG(div, imageWidth, minCoord, maxCoord, levelNumber, title, type, allowSelectGenomeVer) {
    var that = {};
    console.log("SVG dataVer:" + dataVer)
    that.isToolTip = 0;
    that.folderName = "";
    that.selectedTrackSetting = "";
    that.trackListHash = {};
    that.overSettings = 0;
    that.zoomFactor = 0.05;
    that.strainSpecificCountColors = d3.scaleOrdinal(d3.schemeCategory20);
    if (levelNumber == 0) {
        that.folderName = regionfolderName;
    }
    var tmp = {};
    tmp.chr = chr;
    tmp.start = minCoord;
    tmp.stop = maxCoord;
    if (typeof allowSelectGenomeVer === 'undefined') {
        that.allowSelectGenomeVer = true;
    } else {
        that.allowSelectGenomeVer = allowSelectGenomeVer;
    }
    if (levelNumber < 20) {
        if (!history[levelNumber]) {
            history[levelNumber] = [];
        }
        try {
            history[levelNumber].push(tmp);
        } catch (err) {
            Rollbar.error("history[" + levelNumber + "] not defined");
        }
    }

    that.get = function (attr) {
        return that[attr];
    };
    that.getTrackData = function (track) {
        var data = new Array();
        for (var l = 0; l < that.trackList.length; l++) {
            if (typeof that.trackList[l] !== 'undefined' && that.trackList[l].trackClass == track) {
                data = that.trackList[l].data;
            }
        }
        return data;
    };
    that.getTrack = function (track) {
        var tr;
        tr = that.trackListHash[track];
        /*for(var l=0;l<that.trackList.length;l++){
				if(that.trackList[l]!=undefined && that.trackList[l].trackClass==track){
					tr=that.trackList[l];
				}
			}*/
        return tr;
    };

    that.addTrackErrorRemove = function (svg, selector) {
        if (typeof svg !== 'undefined') {
            var track = selector.substr(7);
            svg.select(".infoIcon").style("opacity", 0);
            svg.select(".settings").style("opacity", 0);

            var rem = svg.append("g").attr("class", "removeErrorTrack")
                .attr("id", "remove" + track + that.levelNumber)
                .attr("transform", "translate(" + (that.width - 40) + ",0)");
            rem.append("image").attr("width", "16px")
                .attr("height", "16px")
                .attr("xlink:href", "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJ"
                    + "bWFnZVJlYWR5ccllPAAAARBJREFUeNpi/P//PwMlgBHZgNNajGCO6bX/jNgUY5UHGQDCpzSB1Jn/"
                    + "YAxmQ8UJyaNKNitAMJoifPJMIFecvA4ktitCnPT7DwPDJlkG08X/wU4GYRAbJAaWY4CoBetBDoMp"
                    + "jIz/c4rlIKI/v0HohNcQeoEohGbngqjtfcSQ8x8SDiiBCDYkAar41zfUEGSDal7wGq4ZwwC4IT48"
                    + "WKNsypYvKJpBgAVdkbkmkHj3DasBYDk0wIQez+AA+/kPK4YFLNaEBNccC3QhF45kB3IYyBCgGnhi"
                    + "QolnEA3CxhA8mQGCYXwwhqqFpQOwAWBFWDTDEhKGIUjy8KQ6mwG7ZmyGIMtjpAMQjR5V+OQZKc3O"
                    + "AAEGAInHQgT+/r+xAAAAAElFTkSuQmCC")
                .attr("pointer-events", "all")
                .style("cursor", "pointer")
                .on("click", function (d) {
                    d3.select(selector).remove();
                    /*if(ga){
													ga('send','event','removeErrorTrack',selector);
												}*/
                    gtag('event', selector, {'event_category': 'removeErrorTrack'});
                })
                .on("mouseover", function () {
                    that.overSettings = 1;
                    $("#mouseHelp").html("");
                    /*if(ga){
													ga('send','event','mouseHelp',selector);
												}*/
                    gtag('event', selector, {'event_category': 'mouseHelp'});
                })
                .on("mouseout", function () {
                    that.overSettings = 0;
                    $("#mouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
                    /*if(ga){
													ga('send','event','hideMouseHelp',selector);
												}*/
                    gtag('event', selector, {'event_category': 'hideMouseHelp'});
                });
        }
    };

    that.addTrack = function (track, density, additionalOptions, retry) {
        if (that.forceDrawAsValue == "Trx") {
            var additionalOptionsStr = new String(additionalOptions);
            if (additionalOptionsStr.indexOf("DrawTrx") == -1) {
                if (additionalOptions.substr(additionalOptions.length - 1) === ",") {
                    additionalOptions = additionalOptions + "DrawTrx,";
                } else {
                    additionalOptions = additionalOptions + ",DrawTrx,";
                }

            }
        }
        var folderStr = new String(that.folderName);
        if (folderStr.indexOf(chr) < 0 || folderStr.indexOf(that.xScale.domain()[0] + "_") < 0 || folderStr.indexOf("_" + that.xScale.domain()[1]) < 0) {
            //update folderName because it doesn't match the current range.  that folder should exist, but getFullPath.jsp will call methods to generate if needed
            that.folderName = "/" + chr + "/" + that.xScale.domain()[0] + "_" + that.xScale.domain()[1];
            if (that.levelNumber == 0) {
                if (regionfolderName != that.folderName) {
                    regionfolderName = that.folderName;
                }
            }
            $.ajax({
                url: pathPrefix + "getFullPath.jsp",
                type: 'GET',
                cache: false,
                async: true,
                data: {
                    chromosome: chr,
                    minCoord: that.xScale.domain()[0],
                    maxCoord: that.xScale.domain()[1],
                    panel: panel,
                    rnaDatasetID: rnaDatasetID,
                    arrayTypeID: arrayTypeID,
                    myOrganism: organism,
                    genomeVer: genomeVer
                },
                dataType: 'json',
                success: function (data2) {

                },
                error: function (xhr, status, error) {
                    console.log(error);
                }
            });
        }
        var newTrack = null;

        //Setup the track div if not setup
        var tmpvis = d3.select("#Level" + that.levelNumber + track).nodes();
        if (tmpvis.length === 0 || tmpvis == null) {
            var dragDiv = that.topLevel.append("li").attr("class", "draggable" + that.levelNumber).attr("id", "li" + track).style("margin-bottom", "-3px");
            //dragDiv.append("span").style("background","#CECECE").style("height","100%").style("width","10px").style("display","inline-block");
            var svg = dragDiv.append("svg")
                .attr("width", that.width)
                .attr("height", 30)
                .attr("class", "track")
                .attr("id", "Level" + that.levelNumber + track)
                //.attr("pointer-events", "all")
                .style("cursor", "move")
                .on("mouseover", function () {
                    if (overSelectable === 0) {
                        if (that.defaultMouseFunct === "dragzoom") {
                            $("#mouseHelp").html("<B>Zoom:</B> Click and drag to select a region to zoom in. <B>Navigate or Reorder Tracks:</B> Select the appropriate function at the top left of the image.");
                        } else if (that.defaultMouseFunct === "pan") {
                            $("#mouseHelp").html("<B>Navigate:</B> Move along Genome by clicking and dragging in desired direction. <B>Zoom or Reorder Tracks:</B> Select the appropriate function at the top left of the image.");
                        } else if (that.defaultMouseFunct === "reorder") {
                            $("#mouseHelp").html("<B>Reorder Tracks:</B> Click on the track and drag up or down to desired location. <B>Zoom or Navigate:</B> Select the appropriate function at the top left of the image.");
                        }
                    }
                    /*if(d3.event.altKey){
								that.changeTrackCursor("crosshair");
								that.changeScaleCursor("crosshair");
							}else{
								that.changeTrackCursor("move");
								that.changeScaleCursor("ew-resize");
							}
							if(ga){
								ga('send','event','mouseOverTrack','');
							}*/
                    gtag('event', '', {'event_category': 'mouseOverTrack'});
                })
                .on("mouseout", function () {
                    if (overSelectable === 0) {
                        $("#mouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
                    }
                })
                .on("mousemove", function () {
                    if (d3.event.shiftKey) {
                        that.changeTrackCursor("ns-resize");
                    } else if (d3.event.altKey && that.defaultMouseFunct !== "dragzoom") {
                        that.changeTrackCursor("crosshair");
                    } else if (d3.event.altKey && that.defaultMouseFunct === "dragzoom") {
                        that.changeTrackCursor("move");
                    } else if (!d3.event.altKey && that.defaultMouseFunct === "dragzoom") {
                        that.changeTrackCursor("crosshair");
                    } else if (!d3.event.altKey && that.defaultMouseFunct !== "dragzoom") {
                        that.changeTrackCursor("move");
                    }
                });
            //.on("mousedown", that.panDown);
            //that.svg.append("text").text(that.label).attr("x",that.gsvg.width/2-20).attr("y",12);
            var lblStr = new String("Loading...");
            svg.append("text").text(lblStr).attr("x", that.width / 2 - (lblStr.length / 2) * 7.5).attr("y", 12).attr("id", "trkLbl");
            //var info=svg.append("g").attr("class","infoIcon").attr("transform", "translate(" + (that.width/2+((lblStr.length/2)*7.5)+16) + ",0)");
            var info = svg.append("g").attr("class", "infoIcon")
                .attr("transform", "translate(" + (that.width - 20) + ",0)")
                .style("cursor", "pointer")
                .attr("track", track)
                .attr("title", track)
                .on("mouseover", function () {
                    var tmpTrack = $(this).attr("track");
                    var trackObj = trackInfo[tmpTrack];
                    var ttsr = $(this).tooltipster({
                        position: 'top-right',
                        maxWidth: 250,
                        offsetX: 24,
                        offsetY: 5,
                        contentAsHTML: true,
                        //arrow: false,
                        interactive: true,
                        interactiveTolerance: 350
                    });
                    ttsr.tooltipster('content',
                        function () {
                            var ret = "";
                            if (typeof trackObj !== 'undefined' && typeof trackObj.Description !== 'undefined') {
                                ret = trackObj.Description;
                            }
                            return ret;
                        });
                    ttsr.tooltipster('show');
                    /*if(ga){
													ga('send','event','trackInfo',track);
												}*/
                    gtag('event', track, {'event_category': 'trackInfo'});
                })
                .on("mouseout", function () {
                    $(this).tooltipster('hide');
                });
            info.append("rect")
                .attr("x", 0)
                .attr("y", 0)
                .attr("rx", 3)
                .attr("ry", 3)
                .attr("height", 14)
                .attr("width", 14)
                .attr("fill", "#A7C5E2")
                .attr("stroke", "#7795B2");
            info.append("text").attr("x", 2.5).attr("y", 12).attr("style", "font-family:monospace;font-weight:bold;").attr("fill", "#FFFFFF").text("i");
            var settings = svg.append("g").attr("class", "settings")
                .attr("id", track + "_" + that.levelNumber)
                .attr("transform", "translate(" + (that.width - 40) + ",0)")
            ;
            settings.append("image").attr("width", "16px")
                .attr("height", "16px")
                .attr("xlink:href", "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAQAAAC1+jfqAAAAAmJLR0QA/4ePzL8AAAAJcEhZcwAA" +
                    "AEgAAABIAEbJaz4AAAAJdnBBZwAAABAAAAAQAFzGrcMAAAGASURBVCjPlZGxaxNhAMV/9128JF/u" +
                    "LsndaVoPhEopFW2RGAXpKOpQHNwEHXTVf0Chm6OL4OhccFHoYKGFQgMOLoIUEQfBSZCUBtI2yaVt" +
                    "8hwarI6+5cF7v+HBg/+RH1U3q2/+zdxjK0znO0EhWgru20t2J/fZnXInjrYBHAD/ut30OkW3FBUR" +
                    "fXrtLDroduf2f4ABaARlLzkdRwFFLCFxFBMdPezDGLj5PT/yMChLNqLm6MDFI2eSvT9Dzj2/qLqu" +
                    "7q4+0mXVlx83BnVdUPrC9wEor6Sa0awW38oCKLy1NqsZpap8AgP5BTgk41fP6QE4u60s4xCwCQAr" +
                    "DxofUk2q1i5NAJSmantnlWphvXkXABXf3U6GsSrytwsvC6+CTlWxat2v1+SNR96ZLA9ChSrJyspX" +
                    "qFDlwfkUIAfwcbrvGRwEwAgzEjLDlJ9joPXl6VK639h5cm9rEebfv14emOaZZ9+ck0uUKJTXnret" +
                    "fHvrik7JU+W4+QsCOdzAsOEMT7LfaTGJVMIWBCwAAAAldEVYdGRhdGU6Y3JlYXRlADIwMTAtMDIt" +
                    "MTFUMDA6NTM6MDItMDY6MDDZzrlFAAAAJXRFWHRkYXRlOm1vZGlmeQAyMDA5LTA4LTE4VDAyOjI2" +
                    "OjEwLTA1OjAw2ytpkgAAAABJRU5ErkJggg==")
                .attr("pointer-events", "all")
                .style("cursor", "pointer")
                .on("click", function (d) {
                    if (track != that.selectedTrackSetting) {
                        var trackObj = that.getTrack(track);
                        trackObj.generateSettingsDiv("div#trackSettingContent");
                        that.selectedTrackSetting = track;
                        var p = $(this).position();
                        $('#trackSettingDialog').css("top", p.top).css("left", $(window).width() - 380);
                        $('#trackSettingDialog').fadeIn("fast");
                    } else {
                        that.selectedTrackSetting = "";
                        $('#trackSettingDialog').fadeOut("fast");
                    }
                    /*if(ga){
													ga('send','event','trackSettings','click');
												}*/
                    gtag('event', 'click', {'event_category': 'trackSettings'});
                    return false;
                })
                .on("mouseover", function () {
                    that.overSettings = 1;
                    $("#mouseHelp").html("Track Settings: Click to access track settings or quickly remove the track from the current view.");
                })
                .on("mouseout", function () {
                    that.overSettings = 0;
                    $("#mouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
                });

        }
        //end of track div setup

        console.log("Add Track:" + track + ":" + dataVer);

        var success = 0;
        if (track == "genomeSeq") {
            var newTrack = SequenceTrack(that, track, "Reference Genomic Sequence", additionalOptions);
            that.addTrackList(newTrack);
        } else if (track.indexOf("noncoding") > -1) {
            d3.xml(dataPrefix + "tmpData/browserCache/" + genomeVer + "/regionData/" + that.folderName + "/" + track + ".xml", function (error, d) {
                if (error) {
                    if (retry < 60) {//wait before trying again
                        var time = 1500;
                        if (retry == 1) {
                            time = 2500;
                        }
                        setTimeout(function () {
                            that.addTrack(track, density, additionalOptions, retry + 1);
                        }, time);
                    } else if (success != 1) {
                        d3.select("#Level" + that.levelNumber + track).select("#trkLbl").text("An errror occurred loading Track:" + track);
                        d3.select("#Level" + that.levelNumber + track).attr("height", 15);
                        that.addTrackErrorRemove(d3.select("#Level" + that.levelNumber + track), "#Level" + that.levelNumber + track);
                    }
                } else {
                    if (d == null) {
                        if (retry >= 11) {
                            var data = new Array();
                            var newTrack = GeneTrack(that, data, track, "Long Non-Coding / Non-PolyA+ Genes", additionalOptions);
                            that.addTrackList(newTrack);
                        } else {
                            setTimeout(function () {
                                that.addTrack(track, density, additionalOptions, 10);
                            }, 5000);
                        }
                    } else {
                        var data = d.documentElement.getElementsByTagName("Gene");
                        var ver = 0;
                        var glElem = d.documentElement.getElementsByTagName("GeneList");
                        if (glElem.length > 0 && typeof glElem[0].getAttribute("ver") !== 'undefined') {
                            ver = glElem[0].getAttribute("ver");
                        }
                        try {

                            var newTrack = GeneTrack(that, data, track, "Long Non-Coding / Non-PolyA+ Genes", additionalOptions);
                            newTrack.dataVer = ver;
                            that.addTrackList(newTrack);
                            /*if(selectGene!=""){
                                                                    newTrack.setSelected(selectGene);
                                                            }*/
                        } catch (er) {

                        }
                    }
                }
            });
        } else if (track.indexOf("coding") > -1) {
            d3.xml(dataPrefix + "tmpData/browserCache/" + genomeVer + "/regionData/" + that.folderName + "/" + track + ".xml", function (error, d) {
                if (error) {
                    if (retry < 60) {//wait before trying again
                        var time = 1500;
                        if (retry == 1) {
                            time = 2500;
                        }
                        setTimeout(function () {
                            that.addTrack(track, density, additionalOptions, retry + 1);
                        }, time);
                    } else {
                        d3.select("#Level" + that.levelNumber + track).select("#trkLbl").text("An errror occurred loading Track:" + track);
                        d3.select("#Level" + that.levelNumber + track).attr("height", 15);
                        that.addTrackErrorRemove(d3.select("#Level" + that.levelNumber + track), "#Level" + that.levelNumber + track);
                    }
                } else {
                    if (d == null) {
                        if (retry >= 11) {
                            var data = new Array();
                            var newTrack = GeneTrack(that, data, track, "Protein Coding / PolyA+", additionalOptions);
                            that.addTrackList(newTrack);
                        } else {
                            setTimeout(function () {
                                that.addTrack(track, density, additionalOptions, 11);
                            }, 5000);
                        }
                    } else {
                        var data = d.documentElement.getElementsByTagName("Gene");
                        var ver = 0;
                        var glElem = d.documentElement.getElementsByTagName("GeneList");
                        if (glElem.length > 0 && typeof glElem[0].getAttribute("ver") !== 'undefined') {
                            ver = glElem[0].getAttribute("ver");
                        }
                        try {
                            var newTrack = GeneTrack(that, data, track, "Protein Coding / PolyA+", additionalOptions);
                            newTrack.dataVer = ver;
                            that.addTrackList(newTrack);
                            /*if(selectGene!=""){
                                                            	setTimeout(function (){
                                                            		newTrack.setSelected(selectGene);
                                                            	},500);

                                                            }*/
                        } catch (er) {
                            console.log(er);
                        }
                    }
                }
            });
        } else if (track.indexOf("smallnc") > -1) {
            d3.xml(dataPrefix + "tmpData/browserCache/" + genomeVer + "/regionData/" + that.folderName + "/" + track + ".xml", function (error, d) {
                if (error) {
                    if (retry === 0) {
                        var tmpMin = that.xScale.domain()[0];
                        var tmpMax = that.xScale.domain()[1];
                        var tmpContext = "/" + pathPrefix;
                        if (!pathPrefix) {
                            tmpContext = "";
                        }
                        $.ajax({
                            url: tmpContext + "generateTrackXML.jsp",
                            type: 'GET',
                            cache: false,
                            async: true,
                            data: {
                                chromosome: chr,
                                minCoord: tmpMin,
                                maxCoord: tmpMax,
                                panel: panel,
                                rnaDatasetID: rnaDatasetID,
                                arrayTypeID: arrayTypeID,
                                myOrganism: organism,
                                genomeVer: genomeVer,
                                dataVer: dataVer,
                                track: track,
                                folder: that.folderName
                            },
                            dataType: 'json',
                            success: function (data2) {
                                gtag('event', 'generateTrack' + track, {'event_category': 'browser'});
                            },
                            error: function (xhr, status, error) {

                            }
                        });
                    }
                    if (retry < 70) {//wait before trying again
                        var time = 1500;
                        if (retry > 10) {
                            time = 5000;
                        } else if (retry > 2) {
                            time = 2500;
                        }
                        setTimeout(function () {
                            that.addTrack(track, density, additionalOptions, retry + 1);
                        }, time);
                    } else {
                        d3.select("#Level" + that.levelNumber + track).select("#trkLbl").text("An errror occurred loading Track:" + track);
                        d3.select("#Level" + that.levelNumber + track).attr("height", 15);
                        that.addTrackErrorRemove(d3.select("#Level" + that.levelNumber + track), "#Level" + that.levelNumber + track);
                    }
                } else {
                    if (d == null) {
                        if (retry >= 11) {
                            var data = new Array();
                            var newTrack = GeneTrack(that, data, track, "Small RNA (<200 bp) Genes", additionalOptions);
                            that.addTrackList(newTrack);
                        } else {
                            setTimeout(function () {
                                that.addTrack(track, density, additionalOptions, 11);
                            }, 5000);
                        }
                    } else {
                        var data;
                        if (genomeVer === "rn5") {
                            data = d.documentElement.getElementsByTagName("smnc");
                        } else {
                            data = d.documentElement.getElementsByTagName("Gene");
                        }

                        try {
                            var newTrack = GeneTrack(that, data, track, "Small RNA (<200 bp) Genes", additionalOptions);
                            that.addTrackList(newTrack);
                            if (selectGene != "") {
                                newTrack.setSelected(selectGene);
                            }
                        } catch (er) {

                        }
                    }
                }
            });
        } else if (track.indexOf("liverTotal") === 0 || track === "heartTotal" || track.indexOf("brainTotal") === 0 || track === "mergedTotal" || track.indexOf("kidneyTotal") === 0 || track.indexOf("brainIso") === 0 || track.indexOf("liverIso") === 0) {
            var lbl = "Liver Reconstructed";
            if (track === "heartTotal") {
                lbl = "Heart Reconstructed";
            } else if (track === "brainTotal") {
                lbl = "Whole Brain Reconstructed";
            } else if (track === "mergedTotal") {
                lbl = "Merged (Brain,Heart,Liver,Kidney) Reconstructed";
            } else if (track === "kidneyTotal") {
                lbl = "Kidney Reconstructed";
            } else if (track === "liverIso") {
                lbl = "Liver IsoSeq"
            } else if (track === "brainIso") {
                lbl = "Whole Brain IsoSeq"
            }
            if ((track.indexOf("liverTotal") === 0 || track.indexOf("brainTotal") === 0) && track.indexOf("_") > 0) {
                var strain = track.substr(track.indexOf("_") + 1);
                if (strain === "LEStm") {
                    strain = "LE-Stm";
                    lbl = strain + " " + lbl;
                } else if (strain === "F344Stm") {
                    strain = "F344-Stm";
                    lbl = strain + " " + lbl;
                } else {

                    lbl = lbl + " v" + strain;
                }

            }
            d3.xml(dataPrefix + "tmpData/browserCache/" + genomeVer + "/regionData/" + that.folderName + "/" + dataVer + "_" + track + ".xml", function (error, d) {
                if (error) {
                    if (retry === 0 && (track === "mergedTotal" || track.indexOf("liverTotal") === 0 || track.indexOf("brainTotal") === 0 || track.indexOf("kidneyTotal") === 0 || track.indexOf("brainIso") === 0 || track.indexOf("liverIso") === 0)) {
                        var tmpMin = that.xScale.domain()[0];
                        var tmpMax = that.xScale.domain()[1];
                        var tmpContext = "/" + pathPrefix;
                        if (!pathPrefix) {
                            tmpContext = "";
                        }
                        var curPanel = panel;
                        if ((track.indexOf("liverTotal") === 0 || track.indexOf("brainTotal") === 0) && track.indexOf("_") > 0) {
                            curPanel = track.substr(track.indexOf("_") + 1);
                            if (curPanel === "LEStm") {
                                curPanel = "LE-Stm";
                            }
                            if (curPanel === "F344Stm") {
                                curPanel = "F344-Stm";
                            }

                        } else if (track.indexOf("brainIso") === 0 || track.indexOf("liverIso") === 0) {
                            curPanel = "IsoSeq";
                        }
                        $.ajax({
                            url: tmpContext + "generateTrackXML.jsp",
                            type: 'GET',
                            cache: false,
                            async: true,
                            data: {
                                chromosome: chr,
                                minCoord: tmpMin,
                                maxCoord: tmpMax,
                                panel: curPanel,
                                rnaDatasetID: rnaDatasetID,
                                arrayTypeID: arrayTypeID,
                                myOrganism: organism,
                                genomeVer: genomeVer,
                                dataVer: dataVer,
                                track: track,
                                folder: that.folderName
                            },
                            dataType: 'json',
                            success: function (data2) {
                                /*if(ga){
										ga('send','event','browser','generateTrackRefseq');
									}*/
                                gtag('event', 'generateTrack' + track, {'event_category': 'browser'});
                            },
                            error: function (xhr, status, error) {

                            }
                        });
                    }
                    if (retry < 70) {//wait before trying again
                        var time = 1500;
                        if (retry > 10) {
                            time = 5000;
                        } else if (retry > 2) {
                            time = 2500;
                        }
                        setTimeout(function () {
                            that.addTrack(track, density, additionalOptions, retry + 1);
                        }, time);
                    } else {
                        d3.select("#Level" + that.levelNumber + track).select("#trkLbl").text("An error occurred loading Track:" + track);
                        d3.select("#Level" + that.levelNumber + track).attr("height", 15);
                        that.addTrackErrorRemove(d3.select("#Level" + that.levelNumber + track), "#Level" + that.levelNumber + track);
                    }
                } else {
                    if (d == null) {
                        if (retry >= 11) {
                            var data = new Array();
                            var newTrack = GeneTrack(that, data, track, lbl, additionalOptions);
                            that.addTrackList(newTrack);
                        } else {
                            setTimeout(function () {
                                that.addTrack(track, density, additionalOptions, 11);
                            }, 5000);
                        }
                    } else {
                        var data = d.documentElement.getElementsByTagName("Gene");
                        var ver = 0;
                        var glElem = d.documentElement.getElementsByTagName("GeneList");
                        if (glElem.length > 0 && typeof glElem[0].getAttribute("ver") !== 'undefined') {
                            ver = glElem[0].getAttribute("ver");
                        }
                        try {

                            var newTrack = GeneTrack(that, data, track, lbl, additionalOptions);
                            newTrack.dataVer = ver;
                            that.addTrackList(newTrack);
                            if (selectGene != "") {
                                newTrack.setSelected(selectGene);
                            }
                        } catch (er) {
                        }
                    }
                }
            });
        } else if (track.indexOf("refSeq") === 0) {
            var include = $("#" + track + that.levelNumber + "Select").val();
            var tmpMin = that.xScale.domain()[0];
            var tmpMax = that.xScale.domain()[1];
            var file = dataPrefix + "tmpData/browserCache/" + genomeVer + "/regionData/" + that.folderName + "/" + track + ".xml";
            d3.xml(file, function (error, d) {
                if (error) {
                    console.log(error);
                    if (retry === 0) {
                        var tmpContext = "/" + pathPrefix;
                        if (!pathPrefix) {
                            tmpContext = "";
                        }
                        $.ajax({
                            url: tmpContext + "generateTrackXML.jsp",
                            type: 'GET',
                            cache: false,
                            async: true,
                            data: {
                                chromosome: chr,
                                minCoord: tmpMin,
                                maxCoord: tmpMax,
                                panel: panel,
                                rnaDatasetID: rnaDatasetID,
                                arrayTypeID: arrayTypeID,
                                myOrganism: organism,
                                genomeVer: genomeVer,
                                dataVer: dataVer,
                                track: track,
                                folder: that.folderName
                            },
                            dataType: 'json',
                            success: function (data2) {
                                /*if(ga){
										ga('send','event','browser','generateTrackRefseq');
									}*/
                                gtag('event', 'generateTrack' + track, {'event_category': 'browser'});
                            },
                            error: function (xhr, status, error) {

                            }
                        });
                    }
                    if (retry < 70) {//wait before trying again
                        var time = 1500;
                        if (retry > 10) {
                            time = 5000;
                        } else if (retry > 2) {
                            time = 2500;
                        }
                        setTimeout(function () {
                            that.addTrack(track, density, additionalOptions, retry + 1);
                        }, time);
                    } else {
                        d3.select("#Level" + that.levelNumber + track).select("#trkLbl").text("An errror occurred loading Track:" + track);
                        d3.select("#Level" + that.levelNumber + track).attr("height", 15);
                        that.addTrackErrorRemove(d3.select("#Level" + that.levelNumber + track), "#Level" + that.levelNumber + track);
                    }
                } else {
                    if (d == null) {
                        if (retry >= 11) {
                            var data = new Array();
                            var newTrack = RefSeqTrack(that, data, track, "Ref Seq Genes", additionalOptions);
                            that.addTrackList(newTrack);
                        } else {
                            setTimeout(function () {
                                that.addTrack(track, density, additionalOptions, 11);
                            }, 5000);
                        }
                    } else {

                        var data = d.documentElement.getElementsByTagName("Gene");
                        try {
                            var newTrack = RefSeqTrack(that, data, track, "Ref Seq Genes", additionalOptions);
                            that.addTrackList(newTrack);
                            //newTrack.getDisplayedData();
                        } catch (er) {
                            console.log(er);
                        }
                    }
                }
            });
        } else if (track.indexOf("snp") == 0) {
            //var include=$("#"+track+that.levelNumber+"Select").val();
            var tmpMin = that.xScale.domain()[0];
            var tmpMax = that.xScale.domain()[1];
            var file = dataPrefix + "tmpData/browserCache/" + genomeVer + "/regionData/" + that.folderName + "/" + track + ".xml";
            d3.xml(file, function (error, d) {
                if (error) {
                    console.log(error);
                    if (retry === 0) {
                        var tmpContext = "/" + pathPrefix;
                        if (!pathPrefix) {
                            tmpContext = "";
                        }
                        $.ajax({
                            url: tmpContext + "generateTrackXML.jsp",
                            type: 'GET',
                            cache: false,
                            async: true,
                            data: {
                                chromosome: chr,
                                minCoord: tmpMin,
                                maxCoord: tmpMax,
                                panel: panel,
                                rnaDatasetID: rnaDatasetID,
                                arrayTypeID: arrayTypeID,
                                myOrganism: organism,
                                genomeVer: genomeVer,
                                dataVer: dataVer,
                                track: track,
                                folder: that.folderName
                            },
                            dataType: 'json',
                            success: function (data2) {
                                gtag('event', 'generateTrack' + track, {'event_category': 'browser'});
                            },
                            error: function (xhr, status, error) {

                            }
                        });
                    }
                    if (retry < 70) {//wait before trying again
                        var time = 1500;
                        if (retry > 10) {
                            time = 5000;
                        } else if (retry > 2) {
                            time = 2500;
                        }
                        setTimeout(function () {
                            that.addTrack(track, density, additionalOptions, retry + 1);
                        }, time);
                    } else {
                        d3.select("#Level" + that.levelNumber + track).select("#trkLbl").text("An errror occurred loading Track:" + track);
                        d3.select("#Level" + that.levelNumber + track).attr("height", 15);
                        that.addTrackErrorRemove(d3.select("#Level" + that.levelNumber + track), "#Level" + that.levelNumber + track);
                    }
                } else {
                    if (d == null) {
                        if (retry >= 11) {
                            var snp = new Array();
                            var newTrack = SNPTrack(that, snp, track, density, additionalOptions);
                            that.addTrackList(newTrack);
                        } else {
                            setTimeout(function () {
                                that.addTrack(track, density, additionalOptions, 11);
                            }, 5000);
                        }
                    } else {
                        var snp = d.documentElement.getElementsByTagName("Snp");
                        try {
                            var newTrack = SNPTrack(that, snp, track, density, additionalOptions);
                            that.addTrackList(newTrack);
                        } catch (er) {
                        }
                    }
                }
            });
        } else if (track === "qtl") {
            d3.xml(dataPrefix + "tmpData/browserCache/" + genomeVer + "/regionData/" + that.folderName + "/qtl.xml", function (error, d) {
                if (error) {
                    if (retry < 60) {//wait before trying again
                        var time = 1500;
                        if (retry === 1) {
                            time = 2500;
                        }
                        setTimeout(function () {
                            that.addTrack(track, density, additionalOptions, retry + 1);
                        }, time);
                    } else {
                        d3.select("#Level" + that.levelNumber + track).select("#trkLbl").text("An errror occurred loading Track:" + track);
                        d3.select("#Level" + that.levelNumber + track).attr("height", 15);
                        that.addTrackErrorRemove(d3.select("#Level" + that.levelNumber + track), "#Level" + that.levelNumber + track);
                    }
                } else {
                    if (d == null) {
                        if (retry >= 11) {
                            var qtl = new Array();
                            var newTrack = QTLTrack(that, qtl, track, density);
                            that.addTrackList(newTrack);
                        } else {
                            setTimeout(function () {
                                that.addTrack(track, density, additionalOptions, 11);
                            }, 5000);
                        }
                    } else {
                        var qtl = d.documentElement.getElementsByTagName("QTL");
                        try {
                            var newTrack = QTLTrack(that, qtl, track, density);
                            that.addTrackList(newTrack);
                        } catch (er) {

                        }
                        //success=1;
                    }
                }
            });
        } else if (track === "trx") {
            var txList = getAllChildrenByName(getFirstChildByName(that.selectedData, "TranscriptList"), "Transcript");
            var newTrack = TranscriptTrack(that, txList, track, density);
            that.addTrackList(newTrack);

        } else if (track === "probe" || track == "probeMouse") {
            d3.xml(dataPrefix + "tmpData/browserCache/" + genomeVer + "/regionData/" + that.folderName + "/probe.xml", function (error, d) {
                if (error) {
                    if (retry < 60) {//wait before trying again
                        var time = 1500;
                        if (retry === 1) {
                            time = 2500;
                        }
                        setTimeout(function () {
                            that.addTrack(track, density, additionalOptions, retry + 1);
                        }, time);
                    } else {
                        d3.select("#Level" + that.levelNumber + track).select("#trkLbl").text("An errror occurred loading Track:" + track);
                        d3.select("#Level" + that.levelNumber + track).attr("height", 15);
                        that.addTrackErrorRemove(d3.select("#Level" + that.levelNumber + track), "#Level" + that.levelNumber + track);
                    }
                } else {
                    if (d == null) {
                        if (retry >= 11) {
                            probe = new Array();
                            var newTrack = ProbeTrack(that, probe, track, "Affy Exon 1.0 ST Probe Sets", density + "," + additionalOptions);
                            that.addTrackList(newTrack);
                        } else {
                            setTimeout(function () {
                                that.addTrack(track, density, additionalOptions, 11);
                            }, 5000);
                        }
                    } else {
                        var probe = d.documentElement.getElementsByTagName("probe");
                        try {
                            var newTrack = ProbeTrack(that, probe, track, "Affy Exon 1.0 ST Probe Sets", density + "," + additionalOptions);
                            that.addTrackList(newTrack);
                        } catch (er) {
                        }
                        //success=1;
                    }
                }
            });
        } else if (track === "helicos" || track.indexOf("illuminaTotal") > -1 || track.indexOf("illuminaSmall") > -1 || track === "illuminaPolyA") {
            var tmpMin = that.xScale.domain()[0];
            var tmpMax = that.xScale.domain()[1];
            var len = tmpMax - tmpMin;
            var tmpBin = calculateBin(len, that.width);
            var tmpOpts = [];
            if (additionalOptions) {
                if (additionalOptions.indexOf(",") > 0) {
                    tmpOpts = additionalOptions.split(",");
                } else {
                    tmpOpts[0] = additionalOptions;
                }
            }
            var tmpCount = "Total";
            var countType = 1;
            if (tmpOpts.length > 2) {
                tmp = tmpOpts[1] * 1;
                if (tmp === 2) {
                    tmpCount = "Norm";
                    countType = 2;
                }
            }
            //var file=dataPrefix+"tmpData/regionData/"+that.folderName+"/count"+track+".xml";
            var file = dataPrefix + "tmpData/browserCache/" + genomeVer + "/regionData/" + that.folderName + "/tmp/" + dataVer + "_" + tmpMin + "_" + tmpMax + ".count." + track + "." + tmpCount + ".xml";
            if (tmpBin > 0) {
                tmpMin = tmpMin - (tmpMin % tmpBin);
                tmpMax = tmpMax + (tmpBin - (tmpMax % tmpBin));
                file = dataPrefix + "tmpData/browserCache/" + genomeVer + "/regionData/" + that.folderName + "/tmp/" + dataVer + "_" + tmpMin + "_" + tmpMax + ".bincount." + tmpBin + "." + track + "." + tmpCount + ".xml";
            }
            d3.xml(file, function (error, d) {
                if (error) {
                    if (retry === 0) {
                        var tmpContext = "/" + pathPrefix;
                        if (!pathPrefix) {
                            tmpContext = "";
                        }
                        tmpPanel = panel;
                        if (track.indexOf("-") > -1) {
                            tmpPanel = track.substr(track.indexOf("-") + 1);
                        }
                        $.ajax({
                            url: tmpContext + "generateTrackXML.jsp",
                            type: 'GET',
                            cache: false,
                            async: true,
                            data: {
                                chromosome: chr,
                                minCoord: tmpMin,
                                maxCoord: tmpMax,
                                panel: tmpPanel,
                                rnaDatasetID: rnaDatasetID,
                                arrayTypeID: arrayTypeID,
                                myOrganism: organism,
                                genomeVer: genomeVer,
                                dataVer: dataVer,
                                track: track,
                                folder: that.folderName,
                                binSize: tmpBin,
                                countType: countType
                            },
                            dataType: 'json',
                            success: function (data2) {
                                gtag('event', 'generateTrack' + track, {'event_category': 'browser'});
                            },
                            error: function (xhr, status, error) {

                            }
                        });
                        time = 10000;
                    }
                    if (retry < 70) {//wait before trying again
                        var time = 1000;
                        if (retry > 10) {
                            time = 5000;
                        } else if (retry > 2) {
                            time = 2500;
                        }
                        setTimeout(function () {
                            that.addTrack(track, density, additionalOptions, retry + 1);
                        }, time);
                    } else {
                        d3.select("#Level" + that.levelNumber + track).select("#trkLbl").text("An errror occurred loading Track:" + track);
                        d3.select("#Level" + that.levelNumber + track).attr("height", 15);
                        that.addTrackErrorRemove(d3.select("#Level" + that.levelNumber + track), "#Level" + that.levelNumber + track);
                    }
                } else {
                    //console.log(d);
                    if (d == null) {
                        //if (retry >= 4) {
                        data = new Array();
                        if (track == "helicos") {
                            newTrack = HelicosTrack(that, data, track, density);
                        } else if (track == "illuminaTotal") {
                            newTrack = IlluminaTotalTrack(that, data, track, density);
                        } else if (track == "illuminaSmall") {
                            newTrack = IlluminaSmallTrack(that, data, track, density);
                        } else if (track == "illuminaPolyA") {
                            newTrack = IlluminaPolyATrack(that, data, track, density);
                        } else if (track == "liverilluminaTotalPlus") {
                            newTrack = LiverIlluminaTotalPlusTrack(that, data, track, density);
                        } else if (track == "liverilluminaTotalMinus") {
                            newTrack = LiverIlluminaTotalMinusTrack(that, data, track, density);
                        } else if (track == "heartilluminaTotalPlus") {
                            newTrack = HeartIlluminaTotalPlusTrack(that, data, track, density);
                        } else if (track == "heartilluminaTotalMinus") {
                            newTrack = HeartIlluminaTotalMinusTrack(that, data, track, density);
                        } else if (track == "brainilluminaTotalPlus") {
                            newTrack = BrainIlluminaTotalPlusTrack(that, data, track, density);
                        } else if (track == "brainilluminaTotalMinus") {
                            newTrack = BrainIlluminaTotalMinusTrack(that, data, track, density);
                        } else if (track == "liverilluminaSmall") {
                            newTrack = LiverIlluminaSmallTrack(that, data, track, density);
                        } else if (track == "heartilluminaSmall") {
                            newTrack = HeartIlluminaSmallTrack(that, data, track, density);
                        } else if (track.indexOf("illuminaTotal") > -1) {
                            newTrack = StrainSpecificIlluminaTotalTrack(that, data, track, density, additionalOptions);
                        }
                        that.addTrackList(newTrack);
                        //newTrack.updateFullData();
                        /*} else {
                    setTimeout(function () {
                        that.addTrack(track, density, additionalOptions, 4);
                    }, 3000);
                }*/
                    } else {
                        var data = d.documentElement.getElementsByTagName("Count");
                        var newTrack;
                        try {
                            if (track === "helicos") {
                                newTrack = HelicosTrack(that, data, track, density);
                            } else if (track === "illuminaTotal") {
                                newTrack = IlluminaTotalTrack(that, data, track, density);
                            } else if (track === "illuminaSmall") {
                                newTrack = IlluminaSmallTrack(that, data, track, density);
                            } else if (track === "illuminaPolyA") {
                                newTrack = IlluminaPolyATrack(that, data, track, density);
                            } else if (track === "liverilluminaTotalPlus") {
                                newTrack = LiverIlluminaTotalPlusTrack(that, data, track, density);
                            } else if (track === "liverilluminaTotalMinus") {
                                newTrack = LiverIlluminaTotalMinusTrack(that, data, track, density);
                            } else if (track === "heartilluminaTotalPlus") {
                                newTrack = HeartIlluminaTotalPlusTrack(that, data, track, density);
                            } else if (track === "heartilluminaTotalMinus") {
                                newTrack = HeartIlluminaTotalMinusTrack(that, data, track, density);
                            } else if (track === "brainilluminaTotalPlus") {
                                newTrack = BrainIlluminaTotalPlusTrack(that, data, track, density);
                            } else if (track === "brainilluminaTotalMinus") {
                                newTrack = BrainIlluminaTotalMinusTrack(that, data, track, density);
                            } else if (track === "liverilluminaSmall") {
                                newTrack = LiverIlluminaSmallTrack(that, data, track, density);
                            } else if (track === "heartilluminaSmall") {
                                newTrack = HeartIlluminaSmallTrack(that, data, track, density);
                            } else if (track.indexOf("illuminaTotal") > -1) {
                                newTrack = StrainSpecificIlluminaTotalTrack(that, data, track, density, additionalOptions);
                            }
                            that.addTrackList(newTrack);
                        } catch (er) {
                        }
                        //success=1;
                    }
                    //}
                }
            });

        } else if (track.indexOf("spliceJnct") > -1) {
            //var include=$("#"+track+that.levelNumber+"Select").val();
            var tmpMin = that.xScale.domain()[0];
            var tmpMax = that.xScale.domain()[1];
            var file = dataPrefix + "tmpData/browserCache/" + genomeVer + "/regionData/" + that.folderName + "/" + dataVer + "_" + track + ".xml";
            var lblPrefix = "Brain ";
            if (track == "liverspliceJnct") {
                lblPrefix = "Liver ";
            } else if (track == "heartspliceJnct") {
                lblPrefix = "Heart ";
            }
            d3.xml(file, function (error, d) {
                if (error) {
                    console.log(error);
                    if (retry === 0) {
                        var tmpContext = "/" + pathPrefix;
                        if (!pathPrefix) {
                            tmpContext = "";
                        }
                        $.ajax({
                            url: tmpContext + "generateTrackXML.jsp",
                            type: 'GET',
                            cache: false,
                            async: true,
                            data: {
                                chromosome: chr,
                                minCoord: tmpMin,
                                maxCoord: tmpMax,
                                panel: panel,
                                rnaDatasetID: rnaDatasetID,
                                arrayTypeID: arrayTypeID,
                                myOrganism: organism,
                                genomeVer: genomeVer,
                                dataVer: dataVer,
                                track: track,
                                folder: that.folderName
                            },
                            dataType: 'json',
                            success: function (data2) {
                                /*if(ga){
										ga('send','event','browser','generateTrackSpliceJnct');
									}*/
                                gtag('event', 'generateTrack' + track, {'event_category': 'browser'});
                            },
                            error: function (xhr, status, error) {

                            }
                        });
                    }
                    if (retry < 70) {//wait before trying again
                        var time = 1500;
                        if (retry > 10) {
                            time = 5000;
                        } else if (retry > 2) {
                            time = 2500;
                        }
                        setTimeout(function () {
                            that.addTrack(track, density, additionalOptions, retry + 1);
                        }, time);
                    } else {
                        d3.select("#Level" + that.levelNumber + track).select("#trkLbl").text("An errror occurred loading Track:" + track);
                        d3.select("#Level" + that.levelNumber + track).attr("height", 15);
                        that.addTrackErrorRemove(d3.select("#Level" + that.levelNumber + track), "#Level" + that.levelNumber + track);
                    }
                } else {
                    if (d == null) {
                        if (retry >= 11) {
                            var data = new Array();
                            var newTrack = SpliceJunctionTrack(that, data, track, lblPrefix + "Splice Junctions", 1, "");
                            that.addTrackList(newTrack);
                        } else {
                            setTimeout(function () {
                                that.addTrack(track, density, additionalOptions, 11);
                            }, 5000);
                        }
                    } else {
                        var data = d.documentElement.getElementsByTagName("Feature");
                        //console.log(data);
                        try {
                            var newTrack = SpliceJunctionTrack(that, data, track, lblPrefix + "Splice Junctions", 3, "");
                            that.addTrackList(newTrack);
                        } catch (er) {
                            console.log(er);
                        }
                    }
                }
            });
        } else if (track == "polyASite") {
            d3.xml(dataPrefix + "tmpData/browserCache/" + genomeVer + "/regionData/" + that.folderName + "/polyASite.xml", function (error, d) {
                if (error) {
                    if (retry < 60) {//wait before trying again
                        var time = 1000;
                        if (retry === 1) {
                            time = 2500;
                        }
                        setTimeout(function () {
                            that.addTrack(track, density, additionalOptions, retry + 1);
                        }, time);
                    } else {
                        d3.select("#Level" + that.levelNumber + track).select("#trkLbl").text("An errror occurred loading Track:" + track);
                        d3.select("#Level" + that.levelNumber + track).attr("height", 15);
                        that.addTrackErrorRemove(d3.select("#Level" + that.levelNumber + track), "#Level" + that.levelNumber + track);
                    }
                } else {
                    if (d == null) {
                        if (retry >= 4) {
                            var data = new Array();
                            var newTrack = PolyATrack(that, data, track, "Predicted PolyA Sites", additionalOptions);
                            that.addTrackList(newTrack);
                        } else {
                            setTimeout(function () {
                                that.addTrack(track, density, additionalOptions, 4);
                            }, 5000);
                        }
                    } else {
                        var data = d.documentElement.getElementsByTagName("Feature");
                        try {
                            var newTrack = PolyATrack(that, data, track, "Predicted PolyA Sites", additionalOptions);
                            that.addTrackList(newTrack);
                        } catch (er) {
                        }
                    }
                }
            });
        } else if (track.indexOf("repeatMask") === 0) {
            var include = $("#" + track + that.levelNumber + "Select").val();
            var tmpMin = that.xScale.domain()[0];
            var tmpMax = that.xScale.domain()[1];
            var file = dataPrefix + "tmpData/browserCache/" + genomeVer + "/regionData/" + that.folderName + "/" + track + ".xml";
            d3.xml(file, function (error, d) {
                if (error) {
                    console.log(error);
                    if (retry === 0) {
                        var tmpContext = "/" + pathPrefix;
                        if (!pathPrefix) {
                            tmpContext = "";
                        }
                        $.ajax({
                            url: tmpContext + "generateTrackXML.jsp",
                            type: 'GET',
                            cache: false,
                            async: true,
                            data: {
                                chromosome: chr,
                                minCoord: tmpMin,
                                maxCoord: tmpMax,
                                panel: panel,
                                rnaDatasetID: rnaDatasetID,
                                arrayTypeID: arrayTypeID,
                                myOrganism: organism,
                                genomeVer: genomeVer,
                                dataVer: dataVer,
                                track: track,
                                folder: that.folderName
                            },
                            dataType: 'json',
                            success: function (data2) {
                                gtag('event', 'generateTrack' + track, {'event_category': 'browser'});
                            },
                            error: function (xhr, status, error) {

                            }
                        });
                    }
                    if (retry < 70) {//wait before trying again
                        var time = 1500;
                        if (retry > 10) {
                            time = 5000;
                        } else if (retry > 2) {
                            time = 2500;
                        }
                        setTimeout(function () {
                            that.addTrack(track, density, additionalOptions, retry + 1);
                        }, time);
                    } else {
                        d3.select("#Level" + that.levelNumber + track).select("#trkLbl").text("An errror occurred loading Track:" + track);
                        d3.select("#Level" + that.levelNumber + track).attr("height", 15);
                        that.addTrackErrorRemove(d3.select("#Level" + that.levelNumber + track), "#Level" + that.levelNumber + track);
                    }
                } else {
                    if (d == null) {
                        if (retry >= 11) {
                            var data = new Array();
                            var newTrack = RepeatMaskTrack(that, data, track, "Repeat Masker", density, additionalOptions);
                            that.addTrackList(newTrack);
                        } else {
                            setTimeout(function () {
                                that.addTrack(track, density, additionalOptions, 11);
                            }, 5000);
                        }
                    } else {

                        var data = d.documentElement.getElementsByTagName("Feature");
                        try {
                            var newTrack = RepeatMaskTrack(that, data, track, "Repeat Masker", density, additionalOptions);
                            that.addTrackList(newTrack);
                            //newTrack.getDisplayedData();
                        } catch (er) {
                            console.log(er);
                        }
                    }
                }
            });
        } else if (track.indexOf("custom") == 0) {
            var trackDetails = trackInfo[track];
            additionalOptions = additionalOptions + ",Name=" + trackDetails.Name;
            additionalOptions = "DataFile=" + trackDetails.Location + "," + additionalOptions;
            if (trackDetails.Type == "bed" || trackDetails.Type == "bb") {
                //console.log("ADDED CUSTOM TRANSCRIPT TRACK");
                var data = new Array();
                var newTrack = CustomTranscriptTrack(that, data, track, trackDetails.Name, 3, additionalOptions);
                that.addTrackList(newTrack);
                //newTrack.redraw();
                newTrack.updateFullData(0, 0);
            } else if (trackDetails.Type == "bg" || trackDetails.Type == "bw") {
                var data = new Array();
                var newTrack = CustomCountTrack(that, data, track, 3, additionalOptions);
                that.addTrackList(newTrack);
            }
        } else if (track.indexOf("cirRNA") >= 0) {
            var trackDetails = trackInfo[track];
            var newTrack = CircRNATrack(that, data, track, trackDetails.Name, 3, additionalOptions);
            that.addTrackList(newTrack);
        }
        $(".sortable" + that.levelNumber).sortable("refresh");

        gtag('event', track, {'event_category': 'trackAdded'});
    };


    that.addTrackList = function (newTrack) {
        if (newTrack != null) {
            that.trackList[that.trackCount] = newTrack;
            that.trackCount++;
            that.trackListHash[newTrack.trackClass] = newTrack;
            setTimeout(function () {
                DisplayRegionReport();
            }, 300);
        }
    };
    that.updateLinks = function () {
        if (that.levelNumber === 1) {
            d3.select("#probeSetDetailLink1").each(function () {
                var url = new String(d3.select(this).attr("href"));
                url = url.substr(0, url.lastIndexOf("=") + 1);
                url = url + that.currentView.ViewID;
                d3.select(this).attr("href", url);
            });
        }
    };

    that.changeTrackHeight = function (level, val) {
        if (val > 0) {
            d3.select("#" + level + "Scroll").style("max-height", val + "px").style("overflow", "auto");
        } else {
            d3.select("#" + level + "Scroll").style("max-height", "none").style("overflow", "hidden");
        }
    };

    that.removeAllTracks = function () {
        d3.selectAll("li.draggable" + that.levelNumber).remove();
        that.trackList = [];
        setTimeout(function () {
            DisplayRegionReport();
        }, 300);
        /*if(ga){
			ga('send','event','SVGremoveAllTracks',that.levelNumber);
		}*/
        gtag('event', that.levelNumber, {'event_category': 'SVGremoveAllTracks'});
    };

    that.removeTrack = function (track) {
        d3.select("#Level" + that.levelNumber + track).remove();
        for (var l = 0; l < that.trackList.length; l++) {
            if (typeof that.trackList[l] !== 'undefined' && that.trackList[l].trackClass == track) {
                that.trackList.splice(l, 1);
                that.trackCount--;
            }
        }
        that.trackListHash[track] = undefined;
        setTimeout(function () {
            DisplayRegionReport();
        }, 300);
        /*if(ga){
				ga('send','event','removeTrack',that.levelNumber,track);
			}*/
        gtag('event', that.levelNumber, {'event_category': 'removeTrack', 'event_label': track});
    };

    that.redrawTrack = function (track) {
        for (var l = 0; l < that.trackList.length; l++) {
            if (typeof that.trackList[l] !== 'undefined' && that.trackList[l].trackClass == track) {
                that.trackList[l].redraw();
            }
        }
        setTimeout(function () {
            DisplayRegionReport();
        }, 300);
    };

    that.redraw = function () {
        for (var l = 0; l < that.trackList.length; l++) {
            if (typeof that.trackList[l] !== 'undefined' && typeof that.trackList[l].redraw !== 'undefined') {
                //flog("redraw trackList"+l+":"+that.trackList[l].trackClass);
                that.trackList[l].redraw();
            }
        }
        that.selectSvg.redraw();
        //DisplayRegionReport();
    };

    that.update = function () {
        for (var i = 0; i < that.trackList.length; i++) {
            if (typeof that.trackList[i].update !== 'undefined') {
                that.trackList[i].update();
            }
        }
        setTimeout(function () {
            DisplayRegionReport();
        }, 300);
        /*if(ga){
				ga('send','event','gsvgUpdate','genomeSVG.update');
		}*/
        gtag('event', 'genomeSVG.update', {'event_category': 'gsvgUpdate'});
    };

    that.updateData = function () {
        for (var i = 0; i < that.trackList.length; i++) {
            if (typeof that.trackList[i] !== 'undefined' && typeof that.trackList[i].updateData !== 'undefined') {
                that.trackList[i].updateData(0);
            }
        }
        that.updateFullData();
        setTimeout(function () {
            DisplayRegionReport();
        }, 300);
        /*if(ga){
				ga('send','event','gsvgUpdateData','genomeSVG.updateData');
		}*/
        gtag('event', 'genomeSVG.updateData', {'event_category': 'gsvgUpdateData'});
    };

    that.updateFullData = function () {
        var chkStr = new String(that.folderName);
        if (chkStr.indexOf("img") > -1) {
            that.folderName = "/" + chr + "/" + that.xScale.domain()[0] + "_" + that.xScale.domain()[1];
            if (that.levelNumber == 0) {
                if (regionfolderName != that.folderName) {
                    regionfolderName = that.folderName;
                }
            }
            setTimeout(function () {
                DisplayRegionReport();
            }, 300);
            /*$.ajax({
					url:  pathPrefix +"getFullPath.jsp",
	   				type: 'GET',
	   				async: false,
					data: {chromosome: chr,minCoord:that.xScale.domain()[0],maxCoord:that.xScale.domain()[1],panel:panel,rnaDatasetID:rnaDatasetID,arrayTypeID: arrayTypeID, myOrganism: organism,genomeVer:genomeVer},
					dataType: 'json',
	    			success: function(data2){
	        			that.folderName=data2.folderName;
	        			if(that.levelNumber==0){
	        				if(regionfolderName!=that.folderName){
	        					regionfolderName=that.folderName;
	        				}
	        			}
	        			setTimeout(function(){DisplayRegionReport();},300);
	    			},
	    			error: function(xhr, status, error) {
	        			console.log(error);
	    			}
				});
				*/
        }
        for (var i = 0; i < that.trackList.length; i++) {
            if (typeof that.trackList[i] !== 'undefined' && typeof that.trackList[i].updateFullData !== 'undefined') {
                that.trackList[i].updateFullData(0, 1);
            }
        }
        /*if(ga){
				ga('send','event','gsvgUpdateFullData','genomeSVG.updateFullData');
		}*/
        gtag('event', 'genomeSVG.updateFullData', {'event_category': 'gsvgUpdateFullData'});
    };

    that.setLoading = function () {
        for (var i = 0; i < that.trackList.length; i++) {
            if (typeof that.trackList[i] !== 'undefined') {
                if (typeof that.trackList[i].updateData !== 'undefined' || typeof that.trackList[i].updateFullData !== 'undefined') {
                    that.trackList[i].showLoading();
                }
            }
        }
    };

    that.clearSelection = function () {
        that.selectionStart = -1;
        that.selectionEnd = -1;
        that.scaleSVG.selectAll("rect.selectedArea").remove();
        that.selectSvg.setVis(false);
        for (var i = 0; i < that.trackList.length; i++) {
            if (typeof that.trackList[i] !== 'undefined' && typeof that.trackList[i].clearSelection !== 'undefined') {
                that.trackList[i].clearSelection();
            }
        }
    };

    that.mdown = function () {
        if (that.overSettings == 0) {
            if ((that.defaultMouseFunct !== "dragzoom" && d3.event.altKey) || (that.defaultMouseFunct === "dragzoom" && !d3.event.altKey)) {
                console.log("zoom++");
                var p = d3.mouse(that.vis.node());
                that.downZoomx = p[0];
                that.scaleSVG.append("rect")
                    .attr("class", "zoomRect")
                    .attr("x", p[0])
                    .attr("y", 0)
                    .attr("height", that.scaleSVG.attr("height"))
                    .attr("width", 1)
                    .attr("fill", "#CECECE")
                    .attr("opacity", 0.3);
                that.scaleSVG.append("text").attr("id", "zoomTextStart").attr("x", that.downZoomx).attr("y", 15).text(numberWithCommas(Math.round(that.xScale.invert(that.downZoomx))));
                that.scaleSVG.append("text").attr("id", "zoomTextEnd").attr("x", that.downZoomx).attr("y", 50).text(numberWithCommas(Math.round(that.xScale.invert(that.downZoomx))));
            } else {
                if (processAjax == 0) {
                    that.prevMinCoord = that.xScale.domain()[0];
                    that.prevMaxCoord = that.xScale.domain()[1];
                    var p = d3.mouse(that.vis.node());
                    that.downx = that.xScale.invert(p[0]);
                    that.downscalex = that.xScale;
                }
            }
        }
    };

    that.forceDrawAs = function (value) {
        for (var i = 0; i < that.trackList.length; i++) {
            if (typeof that.trackList[i] !== 'undefined' && (typeof that.trackList[i].drawAs !== 'undefined')) {
                that.trackList[i].drawAs = value;
                that.trackList[i].draw(that.trackList[i].data);
            }
        }
        that.forceDrawAsValue = value;
    };

    that.resize = function (newWidth) {
        that.width = newWidth;
        that.xScale.range([0, that.width]);
        that.xAxis = d3.axisTop(that.xScale)
            .ticks(6)
            .tickSize(8)
            .tickPadding(10);
        that.scaleSVG.attr("width", that.width);
        that.scaleSVG.select(".x.axis").call(that.xAxis);

        d3.select("#Level" + that.levelNumber).select(".axisLbl")
            .attr("x", ((that.width - (that.margin * 2)) / 2));

        that.topLevel.style("width", (that.width + 18) + "px");
        for (var l = 0; l < that.trackList.length; l++) {
            if (typeof that.trackList[l] !== 'undefined' && typeof that.trackList[l].redraw !== 'undefined') {
                that.trackList[l].resize();
            }
        }
        that.selectSvg.width = newWidth;
        that.selectSvg.draw();
    };

    that.updateCountScales = function (minVal, maxVal) {
        for (var i = 0; i < that.trackList.length; i++) {
            if (typeof that.trackList[i] !== 'undefined' && typeof that.trackList[i].updateCountScale !== 'undefined') {
                that.trackList[i].updateCountScale(minVal, maxVal);
            }
        }
    };

    //Function Bar functions
    that.resetDefaultMouse = function (prevSelected) {
        var image = "/web/images/icons/" + prevSelected + "_dark.png";
        d3.select("span#" + prevSelected + that.levelNumber + " img").attr("src", image);
        d3.select("span#" + prevSelected + that.levelNumber).style("background", "#DCDCDC");
    }

    that.changeTrackCursor = function (cursor) {
        for (var i = 0; i < that.trackList.length; i++) {
            if (typeof that.trackList[i] !== 'undefined' && typeof that.trackList[i].svg !== 'undefined') {
                that.trackList[i].svg.style("cursor", cursor);
            }
        }
    };

    that.changeScaleCursor = function (cursor) {
        if (typeof that.scaleSVG !== 'undefined') {
            that.scaleSVG.style("cursor", cursor);
        }
    };

    that.updateTrackSelectedArea = function (start, end) {
        that.selectionStart = start;
        that.selectionEnd = end;
        var xStart = that.xScale(start);
        var width = that.xScale(end) - xStart;
        that.scaleSVG.selectAll("rect.selectedArea").remove();
        if ((xStart > 0 || (xStart + width) > 0) && (xStart < that.width)) {
            if (width < 1) {
                width = 1;
            }
            that.scaleSVG.append("rect").attr("class", "selectedArea")
                .attr("x", xStart)
                .attr("y", 15)
                .attr("height", that.scaleSVG.attr("height") - 15)
                .attr("width", width)
                .attr("fill", "#CECECE")
                .attr("opacity", 0.3)
                .attr("pointer-events", "none");
            for (var i = 0; i < that.trackList.length; i++) {
                if (typeof that.trackList[i] !== 'undefined' && typeof that.trackList[i].setSelectedArea !== 'undefined') {
                    that.trackList[i].setSelectedArea(start, end);
                }
            }
        }
    };


    that.getAddMenus = function () {

        var tmpContext = "/" + pathPrefix;
        if (pathPrefix == "") {
            tmpContext = "";
        }
        $.ajax({
            url: tmpContext + "trackMenu.jsp",
            type: 'GET',
            cache: false,
            data: {level: that.levelNumber, organism: organism},
            dataType: 'html',
            success: function (data2) {
                $("#trackMenu" + that.levelNumber).remove();
                d3.select("div#trackMenu").append("div").attr("id", "trackMenu" + that.levelNumber);
                $("#trackMenu" + that.levelNumber).html(data2);
            },
            error: function (xhr, status, error) {
                $("#trackMenu" + that.levelNumber).remove();
                d3.select("div#trackMenu").append("div").attr("id", "trackMenu" + that.levelNumber);
                $('#trackMenu' + that.levelNumber).append("<div class=\"viewsLevel" + that.levelNumber + "\">An error occurred generating this menu.  Please try back later.</div>");
            },
            async: false
        });

        $.ajax({
            url: tmpContext + "viewMenu.jsp",
            type: 'GET',
            cache: false,
            data: {level: that.levelNumber, organism: organism},
            dataType: 'html',
            success: function (data2) {
                $("#viewMenu" + that.levelNumber).remove();
                d3.select("div#viewMenu").append("div").attr("id", "viewMenu" + that.levelNumber);
                $("#viewMenu" + that.levelNumber).html(data2);

            },
            error: function (xhr, status, error) {
                $("#viewMenu" + that.levelNumber).remove();
                d3.select("div#viewMenu").append("div").attr("id", "viewMenu" + that.levelNumber);
                $('#viewMenu' + that.levelNumber).append("<div class=\"viewsLevel" + that.levelNumber + "\">An error occurred generating this menu.  Please try back later.</div>");
            },
            async: false
        });

    };

    that.zoomMenuChange = function (menuOption) {
        d3.select("#zoomSelectMenu" + that.levelNumber).selectAll("li").style("background", "#FFFFFF");
        that.zoomFactor = parseFloat(d3.select(menuOption).attr("value"));
        d3.select(menuOption).style("background", "#CECECE");
    };

    that.setupFunctionBar = function () {
        d3.selectAll("span.shrt-button")
            .on("click", function () {
                nameSpan = d3.select(this).attr("name");
                if (nameSpan.toLowerCase().indexOf("gene") > -1) {
                    //console.log(":" + selectedID + ":");
                    if (selectedID !== "") {
                        if (!$('div#selectedDetail').is(":visible") && selectedID.indexOf("ENS") === 0) {
                            that.getTrack("ensemblcoding").setSelected(selectedID);
                        }
                        $("span[name='" + nameSpan + "']").click();
                        $('html, body').animate({
                            scrollTop: $("#selectedReport").offset().top
                        }, 1000);
                    } else {
                        alert("You must select a gene from an Ensembl Track before clicking on the gene shortcut.");
                    }
                } else {
                    $("span.closeDetail").click();
                    $("span#" + nameSpan).click();
                    $('html, body').animate({
                        scrollTop: $("#regionDiv").offset().top
                    }, 1000);
                }
            });

        d3.select(div).select("#functLevel" + that.levelNumber).remove();
        //Setup Function Bar
        that.functionBar = that.vis.append("div").attr("class", "functionBar")
            .attr("id", "functLevel" + that.levelNumber)
            .style("float", "left");
        //Setup Mouse Default Function Control
        var defMouse = that.functionBar.append("div").attr("class", "defaultMouse").attr("id", "defaultMouse" + that.levelNumber);
        defMouse.append("span").attr("id", "dragzoom" + that.levelNumber).style("height", "24px").style("display", "inline-block")
            .style("cursor", "pointer")
            .append("img").attr("class", "mouseOpt dragzoom")
            .attr("src", "/web/images/icons/dragzoom_dark.png")
            .attr("pointer-events", "all")
            .on("click", function () {
                that.resetDefaultMouse(that.defaultMouseFunct);
                that.defaultMouseFunct = "dragzoom";
                d3.select(this).attr("src", "/web/images/icons/dragzoom_white.png");
                d3.select("span#dragzoom" + that.levelNumber).style("background", "#989898");
                that.changeTrackCursor("crosshair");
                that.changeScaleCursor("crosshair");
                /*if(ga){
					ga('send','event','clickDragZoom','');
				}*/
                gtag('event', '', {'event_category': 'clickDragZoom'});
            })
            .on("mouseout", function () {
                if (that.defaultMouseFunct != "dragzoom") {
                    d3.select(this).attr("src", "/web/images/icons/dragzoom_dark.png");
                    d3.select("span#dragzoom" + that.levelNumber).style("background", "#DCDCDC");
                }
            })
            .on("mouseover", function () {
                d3.select(this).attr("src", "/web/images/icons/dragzoom_white.png");
                d3.select("span#dragzoom" + that.levelNumber).style("background", "#989898");
                $("#mouseHelp").html("Click to set default mouse function to allow click and drag to select a region to zoom in on.");
            });
        defMouse.append("span").attr("id", "pan" + that.levelNumber).style("height", "24px").style("display", "inline-block")
            .style("cursor", "pointer")
            .append("img")
            .attr("class", "mouseOpt pan")
            .attr("src", "/web/images/icons/pan_dark.png")
            .attr("pointer-events", "all")
            .on("click", function () {
                that.resetDefaultMouse(that.defaultMouseFunct);
                that.defaultMouseFunct = "pan";
                d3.select(this).attr("src", "/web/images/icons/pan_white.png");
                d3.select("span#pan" + that.levelNumber).style("background", "#989898");
                that.changeTrackCursor("move");
                that.changeScaleCursor("ew-resize");
                /*if(ga){
					ga('send','event','clickPan','');
				}*/
                gtag('event', '', {'event_category': 'clickPan'});
            })
            .on("mouseout", function () {
                if (that.defaultMouseFunct != "pan") {
                    d3.select(this).attr("src", "/web/images/icons/pan_dark.png");
                    d3.select("span#pan" + that.levelNumber).style("background", "#DCDCDC");
                }
            })
            .on("mouseover", function () {
                d3.select(this).attr("src", "/web/images/icons/pan_white.png");
                d3.select("span#pan" + that.levelNumber).style("background", "#989898");
                $("#mouseHelp").html("Click to set default mouse function to allow click and drag to navigate along the genome.");
            });
        defMouse.append("span").attr("id", "reorder" + that.levelNumber).style("height", "24px").style("display", "inline-block")
            .style("cursor", "pointer").append("img")
            .attr("class", "mouseOpt pan")
            .attr("src", "/web/images/icons/reorder_dark.png")
            .attr("pointer-events", "all")
            .on("click", function () {
                that.resetDefaultMouse(that.defaultMouseFunct);
                that.defaultMouseFunct = "reorder";
                d3.select(this).attr("src", "/web/images/icons/reorder_white.png");
                d3.select("span#reorder" + that.levelNumber).style("background", "#989898");
                that.changeTrackCursor("ns-resize");
                that.changeScaleCursor("ew-resize");
                /*if(ga){
					ga('send','event','clickReorder','');
				}*/
                gtag('event', '', {'event_category': 'clickReorder'});
            })
            .on("mouseout", function () {
                if (that.defaultMouseFunct != "reorder") {
                    d3.select(this).attr("src", "/web/images/icons/reorder_dark.png");
                    d3.select("span#reorder" + that.levelNumber).style("background", "#DCDCDC");
                }
            })
            .on("mouseover", function () {
                d3.select(this).attr("src", "/web/images/icons/reorder_white.png");
                d3.select("span#reorder" + that.levelNumber).style("background", "#989898");
                $("#mouseHelp").html("Click to set default mouse function to reorder image tracks. <strong>Optionally hold down shift in any mode.</strong>");
            });
        $("span#" + that.defaultMouseFunct + that.levelNumber + " img").click();
        //Setup Additional Buttons
        that.functionBar.append("span").attr("class", "saveImage control").style("display", "inline-block")
            .attr("id", "saveLevel" + that.levelNumber)
            .style("cursor", "pointer")
            .append("img")//.attr("class","mouseOpt dragzoom")
            .attr("src", "/web/images/icons/savePic_dark.png")
            .attr("pointer-events", "all")
            .attr("cursor", "pointer")
            .on("click", function () {
                var id = $(this).parent().attr("id");
                var levelID = (new String(id)).substr(9);
                //console.log("Level #:"+levelID);
                var content = $("div#Level" + levelID).html();
                content = content + "\n";
                $.ajax({
                    url: pathPrefix + "saveBrowserImage.jsp",
                    type: 'POST',
                    contentType: 'text/html',
                    data: content,
                    processData: false,
                    dataType: 'json',
                    success: function (data2) {
                        var d = new Date();
                        var datePart = (d.getMonth() + 1) + "_" + d.getDate() + "_" + d.getFullYear();
                        var http = "http://";
                        if (location.protocol === 'https:') {
                            http = "https://";
                        }
                        var url = http + urlprefix + "/tmpData/download/" + data2.imageFile;
                        var region = new String($('#geneTxt').val());
                        region = region.replace(/:/g, "_");
                        region = region.replace(/-/g, "_");
                        region = region.replace(/,/g, "");
                        if (levelID == "Level1") {
                            region = svgList[1].selectedData.getAttribute("geneSymbol");
                        }
                        var filename = region + "_" + datePart + ".png";
                        var xhr = new XMLHttpRequest();

                        xhr.open('GET', url);
                        xhr.responseType = 'blob';
                        xhr.send();
                        xhr.onreadystatechange = function () {
                            //ready?
                            if (xhr.readyState != 4)
                                return false;

                            //get status:
                            var status = xhr.status;

                            //maybe not successful?
                            if (status != 200) {
                                //console.log("xhr status:"+status);
                                //alert("AJAX: server status " + status);
                                return false;
                            }
                            var a = document.createElement('a');
                            a.href = window.URL.createObjectURL(xhr.response); // xhr.response is a blob
                            a.download = filename; // Set the file name.
                            a.style.display = 'none';
                            document.body.appendChild(a);
                            try {
                                a.click();
                            } catch (error) {
                                //$("#"+id).append("<span style='color:#FF0000;'>Your browser will not save the image directly. Image will open in a popup, in the new window right click to save image.</span>");
                                $("#mouseHelp").html("<span style='color:#FF0000;'>Your browser will not save the image directly. Image will open in a popup, in the new window right click to save image.</span>");
                                window.open(url);
                            }
                            //delete a;
                            return true;
                        }
                        /*if(ga){
										ga('send','event','browser','saveBrowserImage');
								}*/
                        gtag('event', 'saveBrowserImage', {'event_category': 'browser'});

                    },
                    error: function (xhr, status, error) {
                        console.log(error);
                    }
                });
                /*if(ga){
					ga('send','event','saveImage','');
				}*/
                gtag('event', '', {'event_category': 'saveImage'});
            })
            .on("mouseover", function () {
                d3.select(this).attr("src", "/web/images/icons/savePic_white.png");
                d3.select("span#savePic" + that.levelNumber).style("background", "#DCDCDC");
                //$(this).css("background","#989898").html("<img src=\"/web/images/icons/savePic_white.png\">");
                $("#mouseHelp").html("Click to download a PNG image of the current view.");
            })
            .on("mouseout", function () {
                d3.select(this).attr("src", "/web/images/icons/savePic_dark.png");
                d3.select("span#savePic" + that.levelNumber).style("background", "#989898");
                //$(this).css("background","#DCDCDC").html("<img src=\"/web/images/icons/savePic_dark.png\">");
                $("#mouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
            });

        that.functionBar.append("span").attr("class", "reset control").style("display", "inline-block")
            .attr("id", "resetImage" + that.levelNumber)
            .style("cursor", "pointer")
            .append("img")//.attr("class","mouseOpt dragzoom")
            .attr("src", "/web/images/icons/reset_dark.png")
            .attr("pointer-events", "all")
            .attr("cursor", "pointer")
            .on("click", function () {
                var id = new String($(this).parent().attr("id"));
                var level = id.substr(id.length - 1);
                if (level == 0) {
                    $('#geneTxt').val(chr + ":" + initMin + "-" + initMax);
                    svgList[0].xScale.domain([initMin, initMax]);
                    svgList[0].scaleSVG.select(".x.axis").call(svgList[0].xAxis);
                    svgList[0].redraw();
                    svgList[0].updateFullData();
                } else {
                    svgList[level].xScale.domain([svgList[level].initMin, svgList[level].initMax]);
                    svgList[level].scaleSVG.select(".x.axis").call(svgList[level].xAxis);
                    svgList[level].redraw();
                    svgList[0].updateFullData();
                }
                /*if(ga){
					ga('send','event','clickResetImage','');
				}*/
                gtag('event', '', {'event_category': 'clickResetImage'});
            })
            .on("mouseover", function () {
                d3.select(this).attr("src", "/web/images/icons/reset_white.png");
                d3.select("span#reset" + that.levelNumber).style("background", "#DCDCDC");
                $("#mouseHelp").html("Click to reset image zoom to initial region.");
            })
            .on("mouseout", function () {
                d3.select(this).attr("src", "/web/images/icons/reset_dark.png");
                d3.select("span#reset" + that.levelNumber).style("background", "#989898");
                $("#mouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
            });

        that.functionBar.append("span").attr("class", "back control").style("display", "inline-block")
            .attr("id", "backButton" + that.levelNumber)
            .style("cursor", "pointer")
            .append("img")//.attr("class","mouseOpt dragzoom")
            .attr("src", "/web/images/icons/back_dark2.png")
            .attr("pointer-events", "all")
            .attr("cursor", "pointer")
            .on("click", function () {
                back(that.levelNumber);
                /*if(ga){
					ga('send','event','clickBack','');
				}*/
                gtag('event', '', {'event_category': 'clickBack'});
            })
            .on("mouseover", function () {
                d3.select(this).attr("src", "/web/images/icons/back_white2.png");
                //d3.select("span#backButton"+that.levelNumber).style("background","#DCDCDC");
                $("#mouseHelp").html("Click to undo last zoom/pan.");
            })
            .on("mouseout", function () {
                d3.select(this).attr("src", "/web/images/icons/back_dark2.png");
                //d3.select("span#backButton"+that.levelNumber).style("background","#989898");
                $("#mouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
            });

        var zoomBtnSpan = that.functionBar.append("span").style("display", "inline-block").style("position", "relative").style("top", "-9px").attr("id", "zoom" + that.levelNumber);
        zoomBtnSpan.append("button").attr("id", "zoomInButton" + that.levelNumber).attr("class", "zoomIn").style("height", "2.3em")
            .append("img")
            .style("position", "relative")
            .style("top", "-5px")
            .attr("src", "/web/images/icons/magPlus_dark_32.png")
            .attr("pointer-events", "all")
            .attr("cursor", "pointer");
        zoomBtnSpan.append("button").attr("id", "zoomOutButton" + that.levelNumber).attr("class", "zoomOut").style("height", "2.3em")
            .append("img")//.attr("class","mouseOpt dragzoom")
            .style("position", "relative")
            .style("top", "-5px")
            .attr("src", "/web/images/icons/magMinus_dark_32.png")
            .attr("pointer-events", "all")
            .attr("cursor", "pointer");
        zoomBtnSpan.append("button").attr("id", "zoomMenuSelect" + that.levelNumber).attr("class", "zoomSelectMenu");
        if (testChrome) {
            //console.log("CHROME");
            d3.select("#zoomSelect" + that.levelNumber).style("height", "2.3em");
        } else if (testSafari) {
            d3.select("#zoomSelect" + that.levelNumber).style("height", "2.3em");
        } else if (testFireFox) {
            //nothing
        } else if (testIE) {
            //d3.select("#viewSelect"+that.levelNumber).style("position","relative").style("top","-8px").style("height","2.3em");
        }
        var zoomDivMenu = that.functionBar.append("ul").attr("id", "zoomSelectMenu" + that.levelNumber);
        zoomDivMenu.append("li").attr("id", "zoom1" + that.levelNumber).attr("value", "0.025")
            .on("click", function () {
                that.zoomMenuChange(this);
            })
            .text("0.5x");
        zoomDivMenu.append("li").attr("id", "zoom2" + that.levelNumber).attr("value", "0.05").style("background", "#CECECE")
            .on("click", function () {
                that.zoomMenuChange(this);
            })
            .text("1x");
        zoomDivMenu.append("li").attr("id", "zoom3" + that.levelNumber).attr("value", "0.1")
            .on("click", function () {
                that.zoomMenuChange(this);
            })
            .text("2x");
        zoomDivMenu.append("li").attr("id", "zoom4" + that.levelNumber).attr("value", "0.25")
            .on("click", function () {
                that.zoomMenuChange(this);
            })
            .text("5x");
        zoomDivMenu.append("li").attr("id", "zoom5" + that.levelNumber).attr("value", "0.5")
            .on("click", function () {
                that.zoomMenuChange(this);
            })
            .text("10x");
        //viewDivMenu.append("li").attr("id","menuresetView"+that.levelNumber).text("Reset");

        $("#zoomInButton" + that.levelNumber)
            .button()
            .click(function () {
                zoomIn(that.levelNumber, that.zoomFactor);
                /*if(ga){
					ga('send','event','clickZoomIn','');
				}*/
                gtag('event', '', {'event_category': 'clickZoomIn'});
            })
            .on("mouseover", function () {
                $(this).css("background", "#989898");
                $("img", this).attr("src", "/web/images/icons/magPlus_light_32.png");
                $("#mouseHelp").html("Click to zoom in on the center of the region.  Click and drag the scale to zoom in or out more quickly or select the region select tool to highlight a specific region.");
            })
            .on("mouseout", function () {
                $(this).css("background", "#e6e6e6");
                $("img", this).attr("src", "/web/images/icons/magPlus_dark_32.png");
                $("#mouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
            })
            .next()
            .button()
            .click(function () {
                zoomOut(that.levelNumber, that.zoomFactor);
                /*if(ga){
					ga('send','event','clickZoomOut','');
				}*/
                gtag('event', '', {'event_category': 'clickZoomOut'});
            })
            .on("mouseover", function () {
                $(this).css("background", "#989898");
                $("img", this).attr("src", "/web/images/icons/magMinus_light_32.png");
                $("#mouseHelp").html("Click to zoom out from the center of the region.  Click and drag the scale to zoom in or out more quickly or select the region select tool to highlight a specific region.");
            })
            .on("mouseout", function () {
                $(this).css("background", "#e6e6e6");
                $("img", this).attr("src", "/web/images/icons/magMinus_dark_32.png");
                $("#mouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
            })
            .next()
            .button({
                text: false,
                icons: {
                    primary: "ui-icon-triangle-1-s"
                }
            })
            .click(function () {
                var menu = $(this).parent().next().show().position({
                    my: "left top",
                    at: "left bottom",
                    of: this
                });
                $(document).on("click", function () {
                    menu.hide();
                });
                return false;
            })
            .parent()
            .buttonset()
            .next()
            .hide()
            .menu();
    };

    that.generateSettingsString = function () {
        ret = "";
        $("#ScrollLevel" + that.levelNumber + " li.draggable" + that.levelNumber).each(function () {
            var idStr = new String($(this).attr("id"));
            idStr = idStr.substr(2);
            if (typeof that.trackListHash[idStr] !== 'undefined') {
                ret = ret + that.trackListHash[idStr].generateTrackSettingString();
            }
        });
        /*for(var i=0;i<that.trackList.length;i++){
			if(that.trackList[i]!=undefined && that.trackList[i].generateTrackSettingString!=undefined){
				ret=ret+that.trackList[i].generateTrackSettingString();
			}
		}*/
        return ret;
    };

    that.setCurrentViewModified = function () {
        that.currentView.modified = 1;
        $("span#viewModifiedCtl" + that.levelNumber).show();
    };
    that.clearCurrentView = function () {
        that.currentView.modified = 0;
        $("span#viewModifiedCtl" + that.levelNumber).hide();
    };

    //Genome SVG Setup
    that.type = type;
    that.div = div;
    that.margin = 0;

    that.halfWindowWidth = $(window).width() / 2;
    //that.mw=that.width-that.margin;
    that.mh = 400;

    //vars for manipulation
    that.downx = Math.NaN;
    that.downscalex;
    that.downPanx = Math.NaN;
    that.downZoomx = Math.NaN;
    that.downZoomxEnd = Math.NaN;
    that.defaultMouseFunct = "pan";


    that.xMax = 290000000;
    that.xMin = 1;

    that.prevMinCoord = minCoord;
    that.prevMaxCoord = maxCoord;

    that.initMin = minCoord;
    that.initMax = maxCoord;

    that.dataMinCoord = minCoord;
    that.dataMaxCoord = maxCoord;

    that.y = 0;

    that.xScale = null;
    that.xAxis = null;
    that.vis = null;
    that.level = null;

    that.svg = null;


    that.txType = null;
    that.txList = null;

    that.tt = null;

    that.trackList = new Array();
    that.trackCount = 0;

    that.levelNumber = levelNumber;
    that.selectedData = null;
    that.txType = null;

    that.selectionStart = -1;
    that.selectionEnd = -1;
    that.scrollSize = 350;
    //setup code
    that.width = imageWidth;
    that.mw = that.width - that.margin;
    //d3.select(div).select("#settingsLevel"+levelNumber).remove();
    d3.select(div).select("#viewsLevel" + levelNumber).remove();
    d3.select(div).select("#Level" + levelNumber).remove();
    that.vis = d3.select(div);

    that.setupFunctionBar();


    if ($("#viewSelect" + that.levelNumber).length == 0) {
        var viewDivTop = that.vis.append("div")
            .style("float", "right")
            .style("display", "inline-block")
            .style("margin-right", "5px");
        var viewBtnSpan = viewDivTop.append("div");
        viewBtnSpan.append("button").attr("id", "viewSelect" + that.levelNumber).attr("class", "viewSelect").text("Select/Edit Views")
            .on("mouseout", function () {
                $("#mouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
            })
            .on("mouseover", function () {
                $("#mouseHelp").html("Click to select another view or edit the current view.");
            });
        viewBtnSpan.append("button").attr("id", "viewMenuSelect" + that.levelNumber).attr("class", "viewSelectMenu")
            .on("mouseout", function () {
                $("#mouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
            })
            .on("mouseover", function () {
                $("#mouseHelp").html("Click for options to quickly save and delete your current view.");
            });
        if (testChrome) {
            d3.select("#viewSelect" + that.levelNumber).style("height", "2.3em");
        } else if (testSafari) {
            d3.select("#viewSelect" + that.levelNumber).style("height", "2.3em");
        } else if (testFireFox) {
            //nothing
        } else if (testIE) {
            d3.select("#viewSelect" + that.levelNumber).style("position", "relative").style("top", "-8px").style("height", "2.3em");
        }
        var viewDivMenu = viewDivTop.append("ul").attr("id", "viewSelectMenu" + that.levelNumber);
        viewDivMenu.append("li").attr("id", "menusaveView" + that.levelNumber)
            .on("click", function () {
                viewMenu[that.levelNumber].saveView(that.currentView.ViewID, that, false);
                //remove modified labels
                $("#viewModifiedCtl" + that.level).hide();
                /*if(ga){
					ga('send','event','menuSaveView','');
				}*/
                gtag('event', '', {'event_category': 'menuSaveView'});
            })
            .text("Save");
        viewDivMenu.append("li").attr("id", "menusaveAsView" + that.levelNumber)
            .on("click", function () {
                viewMenu[that.levelNumber].saveAsView(that.currentView, svgList[that.levelNumber]);
                $(".viewsLevel" + that.levelNumber).css("top", 250).css("left", $(window).width() - 610);
                $(".viewsLevel" + that.levelNumber).fadeIn("fast");
                $("#viewModifiedCtl" + that.level).hide();
                /*if(ga){
					ga('send','event','menuSaveAsView','');
				}*/
                gtag('event', '', {'event_category': 'menuSaveAsView'});
                //TODO: still need to make it load the new view instead of using the old view.
            })
            .text("Save As");
        viewDivMenu.append("li").attr("id", "menudeleteView" + that.levelNumber)
            .on("click", function () {
                //viewMenu[that.levelNumber].setSelectedView(that.currentView.ViewID);
                viewMenu[that.levelNumber].confirmDeleteView(that.currentView);
                $(".viewsLevel" + that.levelNumber).css("top", 250).css("left", $(window).width() - 610);
                $(".viewsLevel" + that.levelNumber).fadeIn("fast");
                /*if(ga){
					ga('send','event','menuDeleteView','');
				}*/
                gtag('event', '', {'event_category': 'menuDeleteView'});
            })
            .text("Delete");
        //viewDivMenu.append("li").attr("id","menuresetView"+that.levelNumber).text("Reset");

        $("#viewSelect" + that.levelNumber)
            .button()
            .click(function () {

            })
            .next()
            .button({
                text: false,
                icons: {
                    primary: "ui-icon-triangle-1-s"
                }
            })
            .click(function () {
                var menu = $(this).parent().next().show().position({
                    my: "left top",
                    at: "left bottom",
                    of: this
                });
                $(document).on("click", function () {
                    menu.hide();
                });
                return false;
            })
            .parent()
            .buttonset()
            .next()
            .hide()
            .menu();

        var addTrackCtrl = that.vis.append("span").style("float", "right").style("margin-right", "5px");
        addTrackCtrl.append("span").attr("id", "mainAddTrack" + that.levelNumber)
            .attr("class", "control")
            .style("height", "24px")
            .style("display", "inline-block")
            .style("cursor", "pointer")
            .append("img").attr("class", "mainAddTrack")
            .attr("src", "/web/images/icons/addTrack_dark_32.png")
            .attr("pointer-events", "all")
            .style("height", "37px")
            .style("position", "relative")
            .style("top", "-8px")
            .on("click", function () {
                if (!$(".trackLevel" + that.levelNumber).is(":visible")) {
                    //var p=$("div.viewsLevel"+that.level).position();
                    var p = $(this).parent().parent().position();
                    //console.log($("div.trackLevel"+that.level)[0].getBoundingClientRect());
                    //console.log(p);
                    var left = -561;
                    /*if($(window).width()>=1200){
						left=-601;
					}*/
                    trackMenu[that.levelNumber].standalone = true;
                    $(".trackLevel" + that.levelNumber).css("top", p.top).css("left", p.left + left);
                    $(".trackLevel" + that.levelNumber + " span#selectedViewName").html(that.currentView.Name);
                    $(".trackLevel" + that.levelNumber).fadeIn("fast");
                    $("div#selectTrack" + that.levelNumber).show();
                    $("div#addUsrTrack" + that.levelNumber).hide();
                    $("div#addUsrTrack" + that.levelNumber).hide();
                    $("div#deleteUsrTrack" + that.levelNumber).hide();
                    setTimeout(function () {
                        trackMenu[that.levelNumber].generateTrackTable();
                    }, 250);
                    /*if(ga){
						ga('send','event','clickAddTrack','');
					}*/
                    gtag('event', '', {'event_category': 'clickAddTrack'});
                } else {
                    $(".trackLevel" + that.levelNumber).fadeOut("fast");
                }
            })
            .on("mouseout", function () {
                d3.select(this).attr("src", "/web/images/icons/addTrack_dark_32.png");
                d3.select("span#mainAddTrack" + that.levelNumber).style("background", "#DCDCDC");
                $("#mouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
            })
            .on("mouseover", function () {
                d3.select(this).attr("src", "/web/images/icons/addTrack_light_32.png");
                d3.select("span#mainAddTrack" + that.levelNumber).style("background", "#989898");
                $("#mouseHelp").html("Click to quickly add other tracks to the current view.");

            });

        var imgCtrl = that.vis.append("span").style("float", "right").style("margin-right", "5px");

        imgCtrl.append("input")
            .attr("type", "checkbox")
            .attr("name", "imgCBX")
            .attr("id", "forceTrxCBX" + that.levelNumber);
        imgCtrl.append("label")
            .attr("for", "forceTrxCBX" + that.levelNumber)
            .text("Draw Genes as Transcripts")
            .on("mouseout", function () {
                $("#mouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
            })
            .on("mouseover", function () {
                $("#mouseHelp").html("Click to display Gene Tracks as Transcripts. Note: in smaller regions this occurs automatically.");

            });
        $("input#forceTrxCBX" + that.levelNumber).button();

        var scrollCtrl = that.vis.append("span").style("float", "right").style("margin-right", "5px");


        var scrollSize = scrollCtrl.append("div").attr("class", "defaultMouse")
            .style("width", "64px")
            .attr("id", "scrollSize" + that.levelNumber);
        scrollSize.append("span")
            .attr("id", "scrollIncr" + that.levelNumber)
            .style("height", "24px")
            .style("display", "inline-block")
            .style("cursor", "pointer")
            .append("img").attr("class", "mouseOpt ")
            .attr("src", "/web/images/icons/scroll_smaller.png")
            .attr("pointer-events", "all")
            .on("click", function () {
                that.scrollSize = that.scrollSize - 100;
                if (that.scrollSize < 100) {
                    that.scrollSize = 100;
                }
                changeTrackHeight("Level" + that.levelNumber, that.scrollSize);
                /*if(ga){
						ga('send','event','changeScrollHeight','');
					}*/
                gtag('event', '', {'event_category': 'changeScrollHeight'});
            })
            .on("mouseout", function () {
                $("#mouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
            })
            .on("mouseover", function () {
                $("#mouseHelp").html("Decrease the vertical length of the scrollable browser image on the page.");
            });
        scrollSize.append("span")
            .attr("id", "pan" + that.levelNumber)
            .style("height", "24px")
            .style("display", "inline-block")
            .style("cursor", "pointer")
            .append("img")
            .attr("class", "mouseOpt pan")
            .attr("src", "/web/images/icons/scroll_larger.png")
            .attr("pointer-events", "all")
            .on("click", function () {
                if ($("#ScrollLevel" + that.levelNumber).length > 0 && typeof $("#ScrollLevel" + that.levelNumber)[0] !== 'undefined') {
                    if (that.scrollSize < $("#ScrollLevel" + that.levelNumber)[0].scrollHeight) {
                        that.scrollSize = that.scrollSize + 100;
                        changeTrackHeight("Level" + that.levelNumber, that.scrollSize);
                    }
                }
            })
            .on("mouseout", function () {
                $("#mouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
            })
            .on("mouseover", function () {
                $("#mouseHelp").html("Increase the vertical length of the scrollable browser image on the page.");
            });
        scrollCtrl.append("span").attr("class", "scrollBtn control").style("display", "inline-block")
            .attr("id", "scrollImage" + that.levelNumber)
            .style("cursor", "pointer")
            .append("img")//.attr("class","mouseOpt dragzoom")
            .attr("src", "/web/images/icons/scroll.png")
            .attr("pointer-events", "all")
            .attr("cursor", "pointer")
            .on("click", function () {
                if (d3.select(this).attr("src") == "/web/images/icons/no_scroll.png") {
                    d3.select(this).attr("src", "/web/images/icons/scroll.png");
                    d3.select("span#reset" + that.levelNumber).style("background", "#989898");
                    $("#scrollSize" + that.levelNumber).show();
                    changeTrackHeight("Level" + that.levelNumber, that.scrollSize);
                } else {
                    d3.select(this).attr("src", "/web/images/icons/no_scroll.png");
                    d3.select("span#reset" + that.levelNumber).style("background", "#DCDCDC");
                    $("#scrollSize" + that.levelNumber).hide();
                    changeTrackHeight("Level" + that.levelNumber, 0);
                }
                /*if(ga){
						ga('send','event','toggleImageScroll','');
					}*/
                gtag('event', '', {'event_category': 'toggleImageScroll'});
            })
            .on("mouseover", function () {
                $("#mouseHelp").html("Click to toggle browser image scrolling on/off.  <b>Off</b> the image takes as much space as needed. <b>On</b> you can adjust the maximum length of the image.");
            })
            .on("mouseout", function () {
                $("#mouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
            });
    }

    that.topDiv = that.vis.append("div")
        .attr("id", "Level" + levelNumber)
        .style("text-align", "left");

    that.xScale = d3.scaleLinear().domain([minCoord, maxCoord]).range([0, that.width]);
    var tmpHist = {};
    tmpHist.chr = chr;
    tmpHist.start = minCoord;
    tmpHist.stop = maxCoord;
    if (!history[that.levelNumber]) {
        history[that.levelNumber] = []
    }
    history[that.levelNumber].push(tmpHist);

    that.xAxis = d3.axisTop(that.xScale)
        .ticks(6)
        .tickSize(8)
        .tickPadding(10);

    that.scaleSVG = that.topDiv.append("svg:svg")
        .attr("width", that.width)
        .attr("height", 60)
        .attr("pointer-events", "all")
        .attr("class", "scale")

        //.attr("pointer-events", "all")
        .on("mousedown", that.mdown)
        .on("mouseup", mup)
        .on("mouseover", function () {

            if (that.defaultMouseFunct != "dragzoom") {
                $("#mouseHelp").html("<B>Zoom:</b> Click and Drag right to zoom in or left to zoom out. <B>OR</B> Hold the Alt/Option Key while clicking, then drag to select a specific area.");
            } else {
                $("#mouseHelp").html("<B>Zoom:</b> Click and Drag to select an area to zoom in on it. <B>OR</B> Hold the Alt/Option Key while clicking and drag right to zoom in or left to zoom out.");
            }
            if (d3.event.altKey && that.defaultMouseFunct != "dragzoom") {
                that.changeScaleCursor("crosshair");
            } else if (d3.event.altKey && that.defaultMouseFunct == "dragzoom") {
                that.changeScaleCursor("ew-resize");
            }
        })
        .on("mouseout", function () {
            $("#mouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
        })
        .on("mousemove", function () {
            if (d3.event.altKey && that.defaultMouseFunct != "dragzoom") {
                that.changeScaleCursor("crosshair");
            } else if (d3.event.altKey && that.defaultMouseFunct == "dragzoom") {
                that.changeScaleCursor("ew-resize");
            } else if (!d3.event.altKey && that.defaultMouseFunct == "dragzoom") {
                that.changeScaleCursor("crosshair");
            } else if (!d3.event.altKey && that.defaultMouseFunct != "dragzoom") {
                that.changeScaleCursor("ew-resize");
            }
        })
        .style("cursor", "ew-resize");


    that.scaleSVG.append("text")
        .text(title)
        .attr("x", ((that.width - (that.margin * 2)) / 2))
        .attr("y", 10)
        .attr("class", "axisLbl");
    that.scaleSVG.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0,55)")
        .attr("shape-rendering", "crispEdges")
        .call(that.xAxis);

    /*d3.select("#Level"+that.levelNumber).select(".x.axis")
					.append("text")
					.text(title)
					.attr("x", ((that.width-(that.margin*2))/2))
					.attr("y",-40)
					.attr("class","axisLbl");*/

    that.topLevel = that.topDiv.append("div")
        .attr("id", "ScrollLevel" + levelNumber)
        .attr("class", "scroll")
        .style("max-height", "350px")
        .style("overflow", "auto")
        .style("width", "100%")
        .append("ul")
        .attr("id", "sortable" + levelNumber);

    //getAddMenuDiv(levelNumber,that.type);
    that.getAddMenus();
    svgList[levelNumber] = that;

    $("#sortable" + levelNumber).sortable({
        appendTo: "parent",
        containment: "parent",
        stop: function () {
            //saveToCookie(levelNumber);
        }
    }).disableSelection();

    $(".draggable" + levelNumber).draggable({
        connectToSortable: "#sortable" + levelNumber,
        scroll: true,
        revert: "invalid",
        axis: "y"
    });
    //$( "ul,li");
    var orgVer = mmVer;
    if (organism === "Rn") {
        orgVer = rnVer;
    }
    var header = d3.select("div#imageHeader").html("Organism: " + orgVer + "&nbsp&nbsp&nbsp&nbsp" + siteVer);
    setTimeout(function () {
        if ($('span#verSelect').length > 0) {
            var tmpSel = d3.select('span#verSelect').append('select');
            if (that.allowSelectGenomeVer) {
                tmpSel.on("change", function () {
                    //$('input#genomeVer').val($(this).val());
                    displayWorking();
                    if (isLocalStorage() === true) {
                        localStorage.setItem(organism + "DefGenomeVer", $(this).val());
                    } else {
                        $.cookie(organism + "DefGenomeVer", $(this).val());

                    }
                    changeGenome($(this).val(), that.currentView);
                    setTimeout(function () {
                        //console.log("submit genomeVer"+$('input#genomeVer').attr("value"));
                        $('form#geneCentricForm').submit();
                    }, 1500);
                });
                if (organism === 'Rn') {
                    //console.log("running update org:");
                    var rn7Opt = tmpSel.append('option')
                        .attr('value', 'rn7')
                        .html('rn7');
                    //console.log("rn7 added");
                    if (genomeVer === 'rn7') {
                        rn7Opt.attr('selected', 'selected');
                    }
                    var rn6Opt = tmpSel.append('option')
                        .attr('value', 'rn6')
                        .html('rn6');
                    if (genomeVer === 'rn6') {
                        rn6Opt.attr('selected', 'selected');
                    }
                    var rn5Opt = tmpSel.append('option')
                        .attr('value', 'rn5')
                        .html('rn5');
                    if (genomeVer === 'rn5') {
                        rn5Opt.attr('selected', 'selected');
                    }
                } else if (organism === 'Mm') {
                    var mm10Opt = tmpSel.append('option')
                        .attr('value', 'mm10')
                        .html('mm10');
                    if (genomeVer === 'mm10') {
                        mm10Opt.attr('selected', 'selected');
                    }
                }
                //setTimeout(function(){console.log(genomeVer);tmpSel.property( "value", genomeVer );},1000);
            } else {
                tmpSel.append('option')
                    .attr('value', genomeVer)
                    .html(genomeVer);
            }
        }
        if ($('span#hrdpSelect').length > 0) {
            var tmpSelh = d3.select('span#hrdpSelect').append('select');
            tmpSelh.on("change", function () {
                displayWorking();
                if (isLocalStorage() === true) {
                    localStorage.setItem(organism + "DefHRDPVer", $(this).val());
                } else {
                    $.cookie(organism + "DefHRDPVer", $(this).val());
                }
                changeHRDPVer($(this).val());
                setTimeout(function () {
                    //console.log("submit genomeVer"+$('input#genomeVer').attr("value"));
                    $('form#geneCentricForm').submit();
                }, 1500);
            });
            if (organism === 'Rn') {
                $('span#hrdpSelect').css("display", "inline-block");

                if (genomeVer === "rn7") {
                    //console.log("append:v6");
                    var rn6Opt = tmpSelh.append('option')
                        .attr('value', 'hrdp6')
                        .html('HRDP v6');
                    if (dataVer === "hrdp6") {
                        rn6Opt.attr('selected', 'selected');
                    }
                    //console.log("append:v7");
                    var rn7Opt = tmpSelh.append('option')
                        .attr('value', 'hrdp7.1')
                        .html('HRDP v7.1');
                    if (dataVer === "hrdp7.1") {
                        rn7Opt.attr('selected', 'selected');
                    }
                } else if (genomeVer === "rn6") {
                    //console.log("append:v5");
                    var rn5pt = tmpSelh.append('option')
                        .attr('value', 'hrdp5')
                        .html('HRDP v5');
                    rn5pt.attr('selected', 'selected');
                } else if (genomeVer === "rn5") {
                    //console.log("append:v4");
                    var rn5pt = tmpSelh.append('option')
                        .attr('value', 'hrdp3')
                        .html('HRDP v4');
                    //if (hrdpVer === '5') {
                    rn5pt.attr('selected', 'selected');
                } else {
                    console.error("Unsupported genome version");
                }
            } else if (organism === 'Mm') {
                $('span#hrdpSelect').css("display", "none");
            }
        }
    }, 500);
    //Add Sequence Track

    that.addTrack("genomeSeq", 3, "both", 0);
    that.selectSvg = selectionSVG('#Level' + that.levelNumber, that.width, that.levelNumber, that);


    return that;
}

function toolTipSVG(div, imageWidth, minCoord, maxCoord, levelNumber, title, type) {
    var that = {};

    that.isToolTip = 1;
    that.folderName = regionfolderName;

    that.updateTimeoutHandle = {};
    that.timeoutTrack = -1;
    that.forLevel = -1;
    that.strainSpecificCountColors = d3.scaleOrdinal(d3.schemeCategory20);

    that.get = function (attr) {
        return that[attr];
    };

    that.getTrack = function (track) {
        var tr;
        for (var l = 0; l < that.trackList.length; l++) {
            if (typeof that.trackList[l] !== 'undefined' && that.trackList[l].trackClass === track) {
                tr = that.trackList[l];
            }
        }
        return tr;
    };
    that.addTrackErrorRemove = function (svg, selector) {
    };
    that.addTrack = function (track, density, additionalOptions, data) {
        if (that.forceDrawAsValue == "Trx") {
            var additionalOptionsStr = new String(additionalOptions);
            if (additionalOptionsStr.indexOf("DrawTrx") == -1) {
                additionalOptions = additionalOptions + "DrawTrx,";
            }
        }
        var tmpvis = d3.select("#Level" + that.levelNumber + track).nodes();
        if (tmpvis.length === 0 || tmpvis == null) {
            var dragDiv = that.topLevel.append("li").attr("class", "draggable" + that.levelNumber);
            var svg = dragDiv.append("svg:svg")
                .attr("width", that.get('width'))
                .attr("height", 30)
                .attr("class", "track")
                .attr("id", "Level" + that.levelNumber + track);
            var lblStr = new String("Loading...");
            svg.append("text").text(lblStr).attr("x", that.width / 2 - (lblStr.length / 2) * 7.5).attr("y", 12).attr("id", "trkLbl");
        }
        var success = 0;
        var currentSettings = "";
        if (that.forLevel > -1 && that.levelNumber == 99 && typeof svgList[that.forLevel] !== 'undefined') {
            currentSettings = svgList[that.forLevel].getTrack(track).generateTrackSettingString();
            currentSettings = currentSettings.substr(currentSettings.indexOf(",") + 1);
            additionalOptions = currentSettings;
            //console.log("current Settings:"+currentSettings);
        }
        if (track === "genomeSeq") {
            var newTrack = SequenceTrack(that, track, "Reference Genomic Sequence", additionalOptions);
            newTrack.seqRegionSize = 10;
            that.addTrackList(newTrack);
        } else if (track.indexOf("noncoding") > -1) {
            var newTrack = GeneTrack(that, data, track, "Non-Coding/Non-PolyA+ Transcripts", additionalOptions);
            that.addTrackList(newTrack);
        } else if (track.indexOf("coding") > -1) {
            var newTrack = GeneTrack(that, data, track, "Protein Coding/PolyA+ Transcripts", additionalOptions);
            that.addTrackList(newTrack);
        } else if (track.indexOf("liverTotal") === 0 || track === "heartTotal" || track.indexOf("brainTotal") === 0 || track.indexOf("kidneyTotal") === 0 || track === "mergedTotal" || track === "brainIso" || track === "liverIso") {
            var lbl = "Liver Total RNA Transcripts";
            if (track === "heartTotal") {
                lbl = "Heart Total RNA Transcripts";
            } else if (track === "brainTotal") {
                lbl = "Brain Total RNA Transcripts";
            } else if (track === "mergedTotal") {
                lbl = "Merged (Brain,Heart,Liver,Kidney) Reconstructed";
            } else if (track === "kidneyTotal") {
                lbl = "Kidney Total RNA Transcripts";
            } else if (track === "liverIso") {
                lbl = "Liver IsoSeq"
            } else if (track === "brainIso") {
                lbl = "Whole Brain IsoSeq"
            }
            var newTrack = GeneTrack(that, data, track, lbl, additionalOptions);
            that.addTrackList(newTrack);
        } else if (track.indexOf("smallnc") > -1) {
            var newTrack = GeneTrack(that, data, track, "Small RNA (<200 bp) Genes", additionalOptions);
            that.addTrackList(newTrack);
        } else if (track.indexOf("refSeq") === 0) {
            if (that.levelNumber === 99) {
                additionalOptions = additionalOptions + "DrawTrx,";
            }
            var newTrack = RefSeqTrack(that, data, track, "Ref Seq Genes", additionalOptions);
            if (that.levelNumber === 99) {
                newTrack.density = 2;
            } else {
                newTrack.density = density;
            }
            that.addTrackList(newTrack);
        } else if (track.indexOf("snp") === 0) {
            var newTrack = SNPTrack(that, data, track, 1, "4");
            that.addTrackList(newTrack);
        } else if (track === "qtl") {
            var newTrack = QTLTrack(that, data, track, 1);
            that.addTrackList(newTrack);
        } else if (track === "trx") {
            var txList = getAllChildrenByName(getFirstChildByName(that.selectedData, "TranscriptList"), "Transcript");
            var newTrack = TranscriptTrack(that, txList, track, density);
            that.addTrackList(newTrack);
        } else if (track === "probe" || track === "probeMouse") {
            if (that.levelNumber !== 99) {
                additionalOptions = density + "," + additionalOptions;
            }
            var newTrack = ProbeTrack(that, data, track, "Affy Exon 1.0 ST Probe Sets", additionalOptions);
            //var newTrack= ProbeTrack(that,data,track,"Affy Exon 1.0 ST Probe Sets",density+",annot,"+additionalOptions);
            that.addTrackList(newTrack);
        } else if (track.indexOf("spliceJnct") > -1) {
            var lblPrefix = "Brain ";
            if (track === "liverspliceJnct") {
                lblPrefix = "Liver ";
            } else if (track === "heartspliceJnct") {
                lblPrefix = "Heart ";
            }
            var newTrack = SpliceJunctionTrack(that, data, track, lblPrefix + "Splice Junctions", 3, "");
            if (that.levelNumber === 100) {
                newTrack.density = density;
            }
            that.addTrackList(newTrack);
        } else if (track === "polyASite") {
            var newTrack = PolyATrack(that, data, track, "Predicted PolyA Sites", additionalOptions);
            that.addTrackList(newTrack);
        } else if (track === "helicos" || track.indexOf("illuminaTotal") > -1 || track.indexOf("illuminaSmall") > -1 || track === "illuminaPolyA") {
            if (that.updateTimeoutHandle[track]) {
                that.updateTimeoutHandle[track] = -1;
            }
            var newTrack;
            var curDensity = 2;
            var opts = currentSettings.split(",");
            if (opts.length > 1 && (opts[1] === 1 || opts[1] === 2)) {
                curDensity = opts[1];
            }
            if (track === "helicos") {
                newTrack = HelicosTrack(that, data, track, curDensity);
            } else if (track === "illuminaTotal") {
                newTrack = IlluminaTotalTrack(that, data, track, curDensity);
            } else if (track === "illuminaSmall") {
                newTrack = IlluminaSmallTrack(that, data, track, curDensity);
            } else if (track === "illuminaPolyA") {
                newTrack = IlluminaPolyATrack(that, data, track, curDensity);
            } else if (track === "liverilluminaTotalPlus") {
                newTrack = LiverIlluminaTotalPlusTrack(that, data, track, curDensity);
            } else if (track === "liverilluminaTotalMinus") {
                newTrack = LiverIlluminaTotalMinusTrack(that, data, track, curDensity);
            } else if (track === "heartilluminaTotalPlus") {
                newTrack = HeartIlluminaTotalPlusTrack(that, data, track, curDensity);
            } else if (track === "heartilluminaTotalMinus") {
                newTrack = HeartIlluminaTotalMinusTrack(that, data, track, curDensity);
            } else if (track === "brainilluminaTotalPlus") {
                newTrack = BrainIlluminaTotalPlusTrack(that, data, track, curDensity);
            } else if (track === "brainilluminaTotalMinus") {
                newTrack = BrainIlluminaTotalMinusTrack(that, data, track, curDensity);
            } else if (track === "liverilluminaSmall") {
                newTrack = LiverIlluminaSmallTrack(that, data, track, curDensity);
            } else if (track === "heartilluminaSmall") {
                newTrack = HeartIlluminaSmallTrack(that, data, track, curDensity);
            } else if (track.indexOf("illuminaTotal") > -1) {
                newTrack = StrainSpecificIlluminaTotalTrack(that, data, track, curDensity, additionalOptions);
            }
            if (that.levelNumber === 99) {
                if (that.updateTimeoutHandle[track] !== 0) {
                    clearTimeout(that.updateTimeoutHandle[track]);
                    try {
                        clearTimeout(that.timeoutTrack[track].fullDataTimeOutHandle);
                    } catch (error) {
                        //console.log(error);
                    }
                    that.updateTimeoutHandle[track] = 0;
                }
                that.updateTimeoutHandle[track] = setTimeout(function () {
                    newTrack.updateFullData(0, 1);
                    that.timeoutTrack[track] = newTrack;
                    that.updateTimeoutHandle[track] = 0;
                }, 300);
            }
            that.addTrackList(newTrack);
        } else if (track.indexOf("repeatMask") === 0) {
            var newTrack = RepeatMaskTrack(that, data, track, "Repeat Masker", 1, additionalOptions);
            that.addTrackList(newTrack);
        } else if (track.indexOf("custom") > -1) {
            var trackDetails = trackInfo[track];
            additionalOptions = "DataFile=" + trackDetails.Location + "," + additionalOptions;
            if (trackDetails.Type === "bed" || trackDetails.Type === "bb") {
                var data = new Array();
                var newTrack = CustomTranscriptTrack(that, data, track, trackDetails.Name, 3, additionalOptions);
                that.addTrackList(newTrack);
                //newTrack.updateFullData(0,0);
            } else if (trackDetails.Type === "bg" || trackDetails.Type === "bw") {
                var data = new Array();
                var newTrack = CustomCountTrack(that, data, track, 3, additionalOptions);
                that.addTrackList(newTrack);
            }

        } else if (track.indexOf("cirRNA") >= 0) {
            var trackDetails = trackInfo[track];
            var data = new Array();
            var newTrack = CircRNATrack(that, data, track, trackDetails.Name, 3, additionalOptions);
            that.addTrackList(newTrack);
        }
        $(".sortable" + that.levelNumber).sortable("refresh");

    };

    that.addTrackList = function (newTrack) {
        if (newTrack != null) {
            that.trackList[that.trackCount] = newTrack;
            that.trackCount++;
            setTimeout(function () {
                DisplayRegionReport();
            }, 300);
        }
    };

    that.changeTrackHeight = function (level, val) {
        if (val > 0) {
            d3.select("#" + level + "Scroll").style("max-height", val + "px");
        } else {
            d3.select("#" + level + "Scroll").style("max-height", "none");
        }
    };

    that.removeAllTracks = function () {
        for (var l = 0; l < that.trackList.length; l++) {
            if (typeof that.trackList[l] !== 'undefined' && that.trackList[l].trackClass !== "genomeSeq") {
                d3.select("#Level" + that.levelNumber + that.trackList[l].trackClass).remove();
            }
        }
        that.trackList = [];
        setTimeout(function () {
            DisplayRegionReport();
        }, 300);
    };

    that.removeTrack = function (track) {
        d3.select("#Level" + that.levelNumber + track).remove();
        for (var l = 0; l < that.trackList.length; l++) {
            if (typeof that.trackList[l] !== 'undefined' && that.trackList[l].trackClass == track) {
                that.trackList.splice(l, 1);
                that.trackCount--;
            }
        }
        setTimeout(function () {
            DisplayRegionReport();
        }, 300);
    };

    that.redrawTrack = function (track) {
        for (var l = 0; l < that.trackList.length; l++) {
            if (typeof that.trackList[l] !== 'undefined' && that.trackList[l].trackClass == track) {
                that.trackList[l].redraw();
            }
        }
        setTimeout(function () {
            DisplayRegionReport();
        }, 300);
    };

    that.redraw = function () {
        for (var l = 0; l < that.trackList.length; l++) {
            if (typeof that.trackList[l] !== 'undefined' && typeof that.trackList[l].redraw !== 'undefined') {
                that.trackList[l].redraw();
            }
        }
        //DisplayRegionReport();
    };

    that.update = function () {
        for (var i = 0; i < that.trackList.length; i++) {
            if (typeof that.trackList[i].update !== 'undefined') {
                that.trackList[i].update();
            }
        }
        setTimeout(function () {
            DisplayRegionReport();
        }, 300);
    };

    that.updateData = function () {
        for (var i = 0; i < that.trackList.length; i++) {
            if (typeof that.trackList[i] !== 'undefined' && typeof that.trackList[i].updateData !== 'undefined') {
                that.trackList[i].updateData(0);
            }
        }
        that.updateFullData();
        setTimeout(function () {
            DisplayRegionReport();
        }, 300);
    };

    that.updateFullData = function () {
        var chkStr = new String(that.folderName);
        if (chkStr.indexOf("img") > -1) {
            that.folderName = "/" + chr + "/" + that.xScale.domain()[0] + "_" + that.xScale.domain()[1];
            /*$.ajax({
					url:  pathPrefix +"getFullPath.jsp",
	   				type: 'GET',
	   				async: false,
					data: {chromosome: chr,minCoord:that.xScale.domain()[0],maxCoord:that.xScale.domain()[1],panel:panel,rnaDatasetID:rnaDatasetID,arrayTypeID: arrayTypeID, myOrganism: organism,genomeVer:genomeVer},
					dataType: 'json',
	    			success: function(data2){
	        			that.folderName=data2.folderName;
	    			},
	    			error: function(xhr, status, error) {
	        			//console.log(error);
	    			}
				});*/
        }
        for (var i = 0; i < that.trackList.length; i++) {
            if (typeof that.trackList[i] !== 'undefined' && typeof that.trackList[i].updateFullData !== 'undefined') {
                that.trackList[i].updateFullData(0, 1);
            }
        }
    };

    that.setLoading = function () {
        for (var i = 0; i < that.trackList.length; i++) {
            if (typeof that.trackList[i] !== 'undefined' && (typeof that.trackList[i].updateData !== 'undefined' || typeof that.trackList[i].updateFullData !== 'undefined')) {
                that.trackList[i].showLoading();
            }
        }
    };

    that.clearSelection = function () {
        for (var i = 0; i < that.trackList.length; i++) {
            if (typeof that.trackList[i] !== 'undefined' && typeof that.trackList[i].clearSelection !== 'undefined') {
                that.trackList[i].clearSelection();
            }
        }
    };

    that.mdown = function () {
        if (processAjax == 0) {
            that.prevMinCoord = that.xScale.domain()[0];
            that.prevMaxCoord = that.xScale.domain()[1];
            var p = d3.mouse(that.vis.node());
            that.downx = that.xScale.invert(p[0]);
            that.downscalex = that.xScale;
        }
    };

    that.forceDrawAs = function (value) {
        for (var i = 0; i < that.trackList.length; i++) {
            if (typeof that.trackList[i] !== 'undefined' && (typeof that.trackList[i].drawAs !== 'undefined')) {
                that.trackList[i].drawAs = value;
                that.trackList[i].draw(that.trackList[i].data);
            }
        }
        that.forceDrawAsValue = value;
    };

    that.generateSettingsString = function () {
        ret = "";
        for (var i = 0; i < that.trackList.length; i++) {
            if (typeof that.trackList[i] !== 'undefined' && typeof that.trackList[i].generateTrackSettingString !== 'undefined') {
                ret = ret + that.trackList[i].generateTrackSettingString();
            }
        }
        return ret;
    };

    that.setCurrentViewModified = function () {
        if (typeof that.currentView !== 'undefined') {
            that.currentView.modified = 1;
            $("span#viewModifiedCtl" + that.levelNumber).show();
        }
    };
    that.clearCurrentView = function () {
        that.currentView.modified = 0;
        $("span#viewModifiedCtl" + that.levelNumber).hide();
    };

    that.type = type;
    that.div = div;
    that.margin = 0;
    that.halfWindowWidth = $(window).width() / 2;
    //that.mw=that.width-that.margin;
    that.mh = 400;

    //vars for manipulation
    that.downx = Math.NaN;
    that.downscalex;
    that.downPanx = Math.NaN;


    that.xMax = 290000000;
    that.xMin = 1;

    that.prevMinCoord = minCoord;
    that.prevMaxCoord = maxCoord;

    that.dataMinCoord = minCoord;
    that.dataMaxCoord = maxCoord;

    that.y = 0;

    that.xScale = null;
    that.xAxis = null;
    that.vis = null;
    that.level = null;

    that.svg = null;


    that.txType = null;
    that.txList = null;

    that.tt = null;

    that.trackList = new Array();
    that.trackCount = 0;

    that.levelNumber = levelNumber;
    that.selectedData = null;
    that.txType = null;
    //setup code
    that.width = imageWidth;
    that.mw = that.width - that.margin;


    that.vis = d3.select(div);


    that.topDiv = that.vis.append("div")
        .attr("id", "Level" + levelNumber)
        .style("text-align", "left");

    that.xScale = d3.scaleLinear().domain([minCoord, maxCoord]).range([0, that.width]);

    that.xAxis = d3.axisTop(that.xScale)
        .ticks(3)
        .tickSize(8)
        .tickPadding(10);

    that.scaleSVG = that.topDiv.append("svg:svg")
        .attr("width", that.width)
        .attr("height", 60)
        .attr("class", "scale");

    that.scaleSVG.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0,55)")
        .attr("shape-rendering", "crispEdges")
        .call(that.xAxis);

    d3.select("#Level" + that.levelNumber).select(".x.axis")
        .append("text")
        .text(title)
        .attr("x", ((that.width - (that.margin * 2)) / 2))
        .attr("y", -40)
        .attr("class", "axisLbl");

    that.topLevel = that.topDiv.append("div")
        .attr("id", "ScrollLevel" + that.levelNumber)
        /*.style("max-height","350px")
					.style("overflow","none")*/
        .style("width", (that.width + 18) + "px")
        .append("ul")
        .attr("id", "sortable" + that.levelNumber);
    //Add Sequence Track
    //that.addTrack("genomeSeq",3,"both",0);
    return that;
}

function selectionSVG(div, imageWidth, levelNumber, parent) {
    var that = {};

    that.imageWidth = imageWidth + 25;
    that.levelNumber = levelNumber;
    that.parent = parent;

    that.coordSelectStart = 0;
    that.coordSelectStop = 0;
    that.visible = false;

    that.changeSelection = function (start, stop) {
        that.start = start;
        that.stop = stop;

        that.setVis(true);

        that.draw();
    }

    that.setVis = function (visible) {
        that.visible = visible;
        if (that.visible) {
            that.svg.style("display", "inline-block");
            $("div#regionDiv").hide();
        } else {
            that.svg.style("display", "none");
            $("div#regionDiv").show();
        }

    };

    that.draw = function () {
        //console.log("selectionSVG.draw" + that.trackClass);
        if (that.visible) {
            var w = that.xScale(that.stop) - that.xScale(that.start);
            that.parent.updateTrackSelectedArea(that.start, that.stop);
            var startStr = new String(numberWithCommas(Math.floor(that.start)));
            var stopStr = new String(numberWithCommas(Math.floor(that.stop)));
            that.svg.selectAll("line").remove();
            that.svg.selectAll("text").remove();
            that.svg.append("line")
                .attr("x1", function () {
                    var ret = that.xScale(that.start);
                    if (ret < 0) {
                        ret = 0;
                    }
                    return ret;
                })
                .attr("x2", function () {
                    var ret = that.xScale(that.start);
                    if (ret < 0) {
                        ret = 0;
                    }
                    return ret;
                })
                .attr("y1", 0)
                .attr("y2", 15)
                .attr("stroke", "#00992D")
                .attr("stroke-width", "1");
            that.svg.append("line")
                .attr("x1", function () {
                    return that.xScale(that.stop);
                })
                .attr("x2", function () {
                    return that.xScale(that.stop);
                })
                .attr("y1", 0)
                .attr("y2", 15)
                .attr("stroke", "#00992D")
                .attr("stroke-width", "1");
            that.svg.append("line")
                .attr("x1", function () {
                    var ret = that.xScale(that.start);
                    if (ret < 0) {
                        ret = 0;
                    }
                    return ret;
                })
                .attr("x2", 0)
                .attr("y1", 15)
                .attr("y2", 60)
                .attr("stroke", "#00992D")
                .attr("stroke-width", "1");
            that.svg.append("line")
                .attr("x1", function () {
                    return that.xScale(that.stop);
                })
                .attr("x2", that.imageWidth)
                .attr("y1", 15)
                .attr("y2", 60)
                .attr("stroke", "#00992D")
                .attr("stroke-width", "1");
            that.svg.append("text")
                .attr("x", that.xScale(that.start) - (startStr.length * 7.5) - 10)
                .attr("y", 15)
                .text(startStr);
            that.svg.append("text")
                .attr("x", that.xScale(that.stop) + 10)
                .attr("y", 15)
                .text(stopStr);
        }
    };
    that.redraw = function () {
        that.draw();
    };
    that.setup = function () {
        that.svg = d3.select(div).append("svg:svg")
            .attr("width", that.imageWidth)
            .attr("height", 60)
            .attr("id", "selectionLevel" + that.levelNumber)
            .style("display", "none");
        that.xScale = that.parent.xScale;
    }
    that.setup();
    return that;
}

//Track Functions
function Track(gsvgP, dataP, trackClassP, labelP) {
    var that = {};

    that.selectionStart = gsvgP.selectionStart;
    that.selectionEnd = gsvgP.selectionEnd;

    that.ttSVGMinWidth = 20;

    that.panDown = function () {
        if (!d3.event.shiftKey && that.gsvg.overSettings === 0 && overSelectable === 0 && ((that.gsvg.defaultMouseFunct !== "dragzoom" && d3.event.altKey) || (that.gsvg.defaultMouseFunct === "dragzoom" && !d3.event.altKey))) {
            var p = d3.mouse(that.gsvg.vis.node());
            that.gsvg.downZoomx = p[0];
            that.svg.append("rect")
                .attr("class", "zoomRect")
                .attr("x", p[0])
                .attr("y", 0)
                .attr("height", that.svg.attr("height"))
                .attr("width", 1)
                .attr("fill", "#CECECE")
                .attr("opacity", 0.3);
            that.scaleSVG.append("rect")
                .attr("class", "zoomRect")
                .attr("x", p[0])
                .attr("y", 0)
                .attr("height", that.scaleSVG.attr("height"))
                .attr("width", 1)
                .attr("fill", "#CECECE")
                .attr("opacity", 0.3);
            that.scaleSVG.append("text").attr("id", "zoomTextStart").attr("x", that.gsvg.downZoomx).attr("y", 15).text(numberWithCommas(Math.round(that.xScale.invert(that.gsvg.downZoomx))));
            that.scaleSVG.append("text").attr("id", "zoomTextEnd").attr("x", that.gsvg.downZoomx).attr("y", 50).text(numberWithCommas(Math.round(that.xScale.invert(that.gsvg.downZoomx))));
        } else if (!d3.event.shiftKey && that.gsvg.overSettings === 0 && overSelectable === 0 && ((that.gsvg.defaultMouseFunct === "pan" && !d3.event.altKey) || (that.gsvg.defaultMouseFunct !== "pan" && d3.event.altKey))) {
            if (processAjax == 0) {
                var p = d3.mouse(that.gsvg.vis.node());
                that.gsvg.downPanx = p[0];
                that.gsvg.downscalex = that.xScale;
            }
        } else if (that.gsvg.overSettings === 0 && (that.gsvg.defaultMouseFunct === "reorder" || d3.event.shiftKey)) {

        }
    };

    that.zoomToFeature = function (d) {
        var len = parseInt(d.getAttribute("stop"), 10) - parseInt(d.getAttribute("start"), 10);
        len = len * 0.25;
        var minx = parseInt(d.getAttribute("start"), 10) - len;
        var maxx = parseInt(d.getAttribute("stop"), 10) + len;
        if (maxx <= that.gsvg.xMax && minx >= 1) {
            that.xScale.domain([minx, maxx]);
            that.scaleSVG.select(".x.axis").call(that.xAxis);
            that.gsvg.redraw();
            if (that.gsvg.levelNumber == 0 || that.gsvg.levelNumber == 1) {
                var tmp = {};
                tmp.chr = chr;
                tmp.start = minx;
                tmp.stop = maxx;
                if (!history[that.gsvg.levelNumber]) {
                    history[that.gsvg.levelNumber] = [];
                }
                history[that.gsvg.levelNumber].push(tmp);
            }
        }
    };
    that.clearSelection = function () {
        that.selectionStart = -1;
        that.selectionEnd = -1;
        //d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("rect.selectedArea").remove();
        that.svg.selectAll("rect.selectedArea").remove();
        that.svg.selectAll(".selected").each(function () {
            that.svg.select(this).attr("class", "").style("fill", that.color);
        });
        /*d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll(".selected").each(function(){
							d3.select(that).attr("class","").style("fill",that.color);
						});*/
    };

    that.setSelectedArea = function (start, end) {
        that.selectionStart = start;
        that.selectionEnd = end;
        that.redrawSelectedArea();
    };
    that.redrawSelectedArea = function () {
        d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll(".selectedArea").remove();
        if (that.selectionStart > -1 && that.selectionEnd > -1) {
            var tmpStart = that.xScale(that.selectionStart);
            var tmpW = that.xScale(that.selectionEnd) - tmpStart;
            if (tmpW < 1) {
                tmpW = 1;
            }
            d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).append("rect")
                .attr("class", "selectedArea")
                .attr("x", tmpStart)
                .attr("y", 0)
                .attr("height", function () {
                    var rectH = that.svg.attr("height");
                    if (rectH < 15) {
                        rectH = 15;
                    }
                    return rectH;
                })
                .attr("width", tmpW)
                .attr("fill", "#CECECE")
                .attr("opacity", 0.3)
                .attr("pointer-events", "none");
        }
    };
    that.colorStroke = function (d) {
        var colorRet = "black";
        if (that.xScale(d.getAttribute("stop")) - that.xScale(d.getAttribute("start")) < 3) {
            colorRet = that.color(d);
        }
        return colorRet;
    };

    //Pack method does perform additional packing above the default method in track.
    //May be slightly slower but avoids the waterfall like non optimal packing that occurs with the sorted features.
    that.calcY = function (start, end, i) {
        var tmpY = 0;
        if (that.density === 3 || that.density === '3') {
            tmpY = that.calcYPack(start, end, i);
        } else if (that.density === 2 || that.density === '2') {
            tmpY = that.calcYFull(i);
        } else {
            tmpY = that.calcYDense();
        }
        if (that.trackYMax < (tmpY / 15)) {
            that.trackYMax = (tmpY / 15);
        }
        return tmpY;
    };

    that.calcYPack = function (start, end, i) {
        var tmpY = 0;
        if ((start >= that.xScale.domain()[0] && start <= that.xScale.domain()[1]) ||
            (end >= that.xScale.domain()[0] && end <= that.xScale.domain()[1]) ||
            (start <= that.xScale.domain()[0] && end >= that.xScale.domain()[1])) {
            var pStart = Math.round(that.xScale(start));
            if (pStart < 0) {
                pStart = 0;
            }
            var pEnd = Math.round(that.xScale(end));
            if (pEnd >= that.gsvg.width) {
                pEnd = that.gsvg.width - 1;
            }
            var pixStart = pStart - that.xPadding;
            if (pixStart < 0) {
                pixStart = 0;
            }
            var pixEnd = pEnd + that.xPadding;
            if (pixEnd >= that.gsvg.width) {
                pixEnd = that.gsvg.width - 1;
            }
            //find yMax that is clear this is highest line that is clear
            var yMax = 0;
            for (var pix = pixStart; pix <= pixEnd; pix++) {
                if (that.yMaxArr[pix] > yMax) {
                    yMax = that.yMaxArr[pix];
                }
            }
            yMax++;
            //may need to extend yArr for a new line
            var addLine = yMax;
            if (that.yArr.length <= yMax) {
                that.yArr[addLine] = new Array();
                for (var j = 0; j < that.gsvg.width; j++) {
                    that.yArr[addLine][j] = 0;
                }
            }
            //check a couple lines back to see if it can be squeezed in
            var startLine = yMax - that.scanBackYLines;
            if (startLine < 1) {
                startLine = 1;
            }
            var prevLine = -1;
            var stop = 0;
            for (var scanLine = startLine; scanLine < yMax && stop == 0; scanLine++) {
                var available = 0;
                for (var pix = pixStart; pix <= pixEnd && available == 0; pix++) {
                    if (that.yArr[scanLine][pix] > available) {
                        available = 1;
                    }
                }
                if (available == 0) {
                    yMax = scanLine;
                    stop = 1;
                }
            }
            if (yMax > that.trackYMax) {
                that.trackYMax = yMax;
            }
            for (var pix = pStart; pix <= pEnd; pix++) {
                if (that.yMaxArr[pix] < yMax) {
                    that.yMaxArr[pix] = yMax;
                }
                that.yArr[yMax][pix] = 1;
            }
            tmpY = yMax * 15;
        } else {
            tmpY = 15;
        }
        return tmpY;
    };

    that.calcYDense = function () {
        return 15;
    };

    that.calcYFull = function (i) {
        return (i + 1) * 15;
    };

    that.positionTTLeft = function (pageX) {
        var x = pageX + 20;
        if (x > that.gsvg.halfWindowWidth) {
            x = x - 490;
        }
        var xPos = x + "px";
        return xPos;
    };

    that.positionTTTop = function (pageY) {
        /*var topPos=(pageY + 5) + "px";
		if(d3.event.clientY>(window.innerHeight*0.6)){
			topPos=(d3.event.pageY - ($(".testToolTip").height()*2.2)) + "px";
		}*/
        var topPos = window.pageYOffset + 10;
        var tmpDiff = window.innerHeight - ($(".testToolTip").height() * 1.8);
        if (tmpDiff > 20) {
            topPos = topPos + (tmpDiff / 2);
        }
        return topPos + "px";
    };

    that.drawLegend = function (legendList) {
        var lblStr = new String(that.label);
        var x = that.gsvg.width / 2 + (lblStr.length / 2) * 6.5;
        if (that.gsvg.width < 500) {
            x = (lblStr.length) * 7;
        }
        d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll(".legend").remove();
        for (var i = 0; i < legendList.length; i++) {
            that.svg.append("rect")
                .attr("class", "legend")
                .attr("x", x)
                .attr("y", 0)
                .attr("rx", 3)
                .attr("ry", 3)
                .attr("height", 12)
                .attr("width", 16)
                .attr("fill", legendList[i].color)
                .attr("stroke", legendList[i].color);
            lblStr = new String(legendList[i].label);
            that.svg.append("text").text(lblStr).attr("class", "legend").attr("x", x + 18).attr("y", 12);
            x = x + 25 + lblStr.length * 7;
        }
    };

    that.drawScaleLegend = function (minVal, maxVal, lbl, minColor, maxColor, offset) {
        var lblStr = new String(that.label);
        var x = that.gsvg.width / 2 + (lblStr.length / 2) * 7.5 + 16;
        if (that.gsvg.width < 500) {
            x = (lblStr.length) * 7.5;
        }
        x = x + offset;
        d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll(".legend").remove();
        d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll("#def1").remove();
        var grad = that.svg.append("defs").attr("id", "def1").append("linearGradient").attr("id", "grad" + that.gsvg.levelNumber + that.trackClass);
        grad.append("stop").attr("offset", "0%").style("stop-color", minColor);
        grad.append("stop").attr("offset", "100%").style("stop-color", maxColor);
        lblStr = new String(minVal);
        var initOff = lblStr.length * 7.6;
        that.svg.append("text").text(lblStr).attr("class", "legend").attr("x", x).attr("y", 12);
        that.svg.append("rect")
            .attr("class", "legend")
            .attr("x", x + initOff + 5)
            .attr("y", 0)
            .attr("rx", 3)
            .attr("ry", 3)
            .attr("height", 12)
            .attr("width", 75)
            .attr("fill", "url(#grad" + that.gsvg.levelNumber + that.trackClass + ")");
        //.attr("stroke","#FFFFFF");
        lblStr = new String(maxVal);
        that.svg.append("text").text(lblStr).attr("class", "legend").attr("x", x + initOff + 80).attr("y", 12);
        var off = lblStr.length * 8 + 5;
        lblStr = new String(lbl);
        that.svg.append("text").text(lblStr).attr("class", "legend").attr("x", x + initOff + 80 + off).attr("y", 12);
    };

    that.showLoading = function () {
        if (d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll("g.loading") > 0) {
            that.loading = d3.select(that.svg).selectAll("g.loading");
        } else {
            that.loading = that.svg.append("g").attr("class", "loading");
            that.loading.append("rect")
                .attr("x", 0)
                .attr("y", 0)
                .attr("height", that.svg.attr("height"))
                .attr("width", that.gsvg.width)
                .attr("fill", "#CECECE")
                .attr("opacity", 0.6);
            that.loading.append("text").text("Loading...")
                .attr("x", that.gsvg.width / 2 - 5 * 7.5)
                .attr("y", that.svg.attr("height") / 2);
        }
    };

    that.hideLoading = function () {
        that.loading = d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll("g.loading");
        if (typeof that.loading !== 'undefined') {
            that.loading.remove();
        }
    };

    that.displayBreakDown = function (divSelector) {
        //console.log("displayBreakDown");
        //console.log(that.counts);
        var tmpW = 300, tmpH = 300, radius = Math.min(tmpW, tmpH) / 2;
        var winWidth = $(window).width() / 2;
        if ($(window).width() > 1000) {
            winWidth = ($(window).width() - 1000) / 2;
        }

        if (!(typeof that.counts === "undefined") && that.counts.length > 0) {
            var noCounts = 1;
            for (var n = 0; n < that.counts.length && noCounts === 1; n++) {
                if (that.counts[n].value > 0) {
                    noCounts = 0;
                }
            }
            if (noCounts === 0) {
                var arc = d3.arc()
                    .outerRadius(radius - 10)
                    .innerRadius(0);

                var pie = d3.pie()
                    //.sort(null)
                    .value(function (d) {
                        return d.value;
                    });

                var svg = d3.select(divSelector).append("svg")
                    .attr("width", tmpW)
                    .attr("height", tmpH)
                    .append("g")
                    .attr("transform", "translate(" + tmpW / 2 + "," + tmpH / 2 + ")");

                var g = svg.selectAll(".arc")
                    .data(pie(that.counts))
                    .enter().append("g")
                    .attr("class", "arc");
                g.append("path")
                    .attr("d", arc)
                    .attr("fill", that.pieColor)
                    .on("mouseover", function (d) {
                        d3.select('.testToolTip').transition()
                            .duration(200)
                            .style("opacity", .95);
                        d3.select('.testToolTip').html("Name: " + d.data.names + "<BR>Count: " + d.data.value)
                            .style("left", (d3.event.pageX) + "px")
                            .style("top", (d3.event.pageY + 20) + "px");
                        that.triggerTableFilter(d);
                        /**/
                    })
                    .on("mouseout", function (d) {
                        d3.select('.testToolTip').transition()
                            .delay(500)
                            .duration(200)
                            .style("opacity", 0);
                        that.clearTableFilter(d);

                    });
                g.append("text")
                    .attr("transform", function (d) {
                        return "translate(" + arc.centroid(d) + ")";
                    })
                    .attr("dy", ".35em")
                    .attr("fill", "#FFFFFF")
                    //.attr("stroke","#000000")
                    .style("text-anchor", "middle")
                    .text(function (d) {
                        var ret = d.value;
                        if (d.value == 0) {
                            ret = "";
                        }
                        return ret;
                    });
            }
        }

    };

    that.updateLabel = function (label) {
        that.label = label;
        var lblStr = new String(that.label);
        if (that.gsvg.width > 600) {
            d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).select("#trkLbl").attr("x", that.gsvg.width / 2 - (lblStr.length / 2) * 7.5).text(lblStr);
        } else {
            d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).select("#trkLbl").attr("x", 0).text(lblStr);
        }
        d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).select(".infoIcon").attr("transform", "translate(" + (that.gsvg.width - 20) + ",0)");
        d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).select(".settings").attr("transform", "translate(" + (that.gsvg.width - 40) + ",0)");
        //d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).select(".infoIcon").attr("transform", "translate(" + (that.gsvg.width/2+((lblStr.length/2)*7.5)) + ",0)");
    };

    that.resize = function () {
        d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).attr("width", that.gsvg.width);
        that.updateLabel(that.label);
        if (typeof that.redrawLegend !== 'undefined') {
            that.redrawLegend();
        }
        that.redraw();
    };

    that.triggerTableFilter = function (d) {
        //not supported for general tracks see specific tracks.
    };
    that.clearTableFilter = function (d) {
        //not supported for general tracks see specific tracks.
    };

    that.getDisplayID = function (d) {
        return d.getAttribute("ID");
    };

    that.setupToolTipSVG = function (d, perc) {
        //Setup Tooltip SVG
        var start = parseInt(d.getAttribute("start"), 10);
        var stop = parseInt(d.getAttribute("stop"), 10);
        var len = stop - start;
        var margin = Math.floor(len * perc);
        if (margin < 20) {
            margin = 20;
        }
        var tmpStart = start - margin;
        var tmpStop = stop + margin;
        if (tmpStart < 1) {
            tmpStart = 1;
        }
        if (typeof that.ttSVGMinWidth !== 'undefined') {
            if (tmpStop - tmpStart < that.ttSVGMinWidth) {
                tmpStart = start - (that.ttSVGMinWidth / 2);
                tmpStop = stop + (that.ttSVGMinWidth / 2);
            }
        }
        var newSvg = toolTipSVG("div#ttSVG", 450, tmpStart, tmpStop, 99, that.getDisplayID(d), "transcript");
        newSvg.forLevel = that.gsvg.levelNumber;
        //Setup Track for current feature
        var dataArr = new Array();
        dataArr.push(d);
        newSvg.addTrack(that.trackClass, 3, "", dataArr);
        //Setup Other tracks included in the track type(listed in that.ttTrackList)
        for (var r = 0; r < that.ttTrackList.length; r++) {
            //console.log("track.setupToolTipSVG()");
            //console.log(that.ttTrackList[r]);
            //console.log(that.gsvg);
            //console.log(that.gsvg.getTrackData);
            var tData = that.gsvg.getTrackData(that.ttTrackList[r]);
            var fData = new Array();
            if (typeof tData !== 'undefined' && tData.length > 0) {
                var fCount = 0;
                for (var s = 0; s < tData.length; s++) {
                    if ((tmpStart <= parseInt(tData[s].getAttribute("start"), 10) && parseInt(tData[s].getAttribute("start"), 10) <= tmpStop)
                        || (parseInt(tData[s].getAttribute("start"), 10) <= tmpStart && parseInt(tData[s].getAttribute("stop"), 10) >= tmpStart)
                    ) {
                        fData[fCount] = tData[s];
                        fCount++;
                    }
                }
                if (fData.length > 0) {
                    newSvg.addTrack(that.ttTrackList[r], 3, "DrawTrx", fData);
                }
            }
        }
    };

    that.generateSettingsDiv = function (topLevelSelector) {
        that.savePrevious();
        var d = trackInfo[that.trackClass];
        //console.log(trackInfo);
        //console.log(d);
        d3.select(topLevelSelector).select("table").select("tbody").html("");
        if (typeof d !== 'undefined' && d.Controls.length > 0 && d.Controls != "null") {
            var controls = new String(d.Controls).split(",");
            var table = d3.select(topLevelSelector).select("table").select("tbody");
            table.append("tr").append("td").style("font-weight", "bold").html("Track Settings: " + d.Name);
            for (var c = 0; c < controls.length; c++) {
                if (typeof controls[c] !== 'undefined' && controls[c] != "") {
                    var params = controls[c].split(";");
                    var div = table.append("tr").append("td");
                    var lbl = params[0].substr(5);
                    div.append("text").text(lbl + ": ");
                    var def = "";
                    if (params.length > 3 && params[3].indexOf("Default=") == 0) {
                        def = params[3].substr(8);
                    }
                    if (params[1].toLowerCase().indexOf("select") == 0) {
                        var selClass = params[1].split(":");
                        var opts = params[2].split("}");
                        var prefix = "";
                        var suffix = "";
                        if (selClass.length > 2) {
                            prefix = selClass[2];
                        }
                        if (selClass.length > 3) {
                            suffix = selClass[3];
                        }
                        var sel = div.append("select").attr("id", that.trackClass + prefix + that.level + suffix)
                            .attr("name", selClass[1]);
                        for (var o = 0; o < opts.length; o++) {
                            var option = opts[o].substr(1).split(":");
                            if (option.length == 2) {
                                var tmpOpt = sel.append("option").attr("value", option[1]).text(option[0]);

                                if (prefix === "Dense" && option[1] == that.density) {
                                    tmpOpt.attr("selected", "selected");
                                } else if (prefix === "Version" && option[1] == that.dataVer) {
                                    tmpOpt.attr("selected", "selected");
                                } else if (option[1] == def) {
                                    tmpOpt.attr("selected", "selected");
                                }
                            }
                        }
                        d3.select("select#" + that.trackClass + prefix + that.level + suffix).on("change", function () {
                            that.updateSettingsFromUI();
                            that.redraw();
                        });
                    } else {
                        console.log("Undefined track settings:  " + controls[c]);
                    }
                }
            }
            var buttonDiv = table.append("tr").append("td");
            buttonDiv.append("input").attr("type", "button").attr("value", "Remove Track").style("float", "left").style("margin-left", "5px").on("click", function () {
                $('#trackSettingDialog').fadeOut("fast");
                that.gsvg.setCurrentViewModified();
                that.gsvg.removeTrack(that.trackClass);
                var viewID = svgList[that.gsvg.levelNumber].currentView.ViewID;
                var track = viewMenu[that.gsvg.levelNumber].findTrackByClass(that.trackClass, viewID);
                var indx = viewMenu[that.gsvg.levelNumber].findTrackIndexWithViewID(track.TrackID, viewID);
                viewMenu[that.gsvg.levelNumber].removeTrackWithIDIdx(indx, viewID);
            });
            buttonDiv.append("input").attr("type", "button").attr("value", "Apply").style("float", "right").style("margin-left", "5px").on("click", function () {
                $('#trackSettingDialog').fadeOut("fast");
                if (that.density != that.prevSetting.density) {
                    that.gsvg.setCurrentViewModified();
                }
            });
            buttonDiv.append("input").attr("type", "button").attr("value", "Cancel").style("float", "right").style("margin-left", "5px").on("click", function () {
                that.revertPrevious();
                that.draw(that.data);
                $('#trackSettingDialog').fadeOut("fast");
            });
        } else if (d) {
            var table = d3.select(topLevelSelector).select("table").select("tbody");
            table.append("tr").append("td").style("font-weight", "bold").html("Track Settings: " + d.Name);
            table.append("tr").append("td").html("Sorry no settings for this track.");
            var buttonDiv = table.append("tr").append("td");
            buttonDiv.append("input").attr("type", "button").attr("value", "Remove Track").style("float", "left").style("margin-left", "5px").on("click", function () {
                $('#trackSettingDialog').fadeOut("fast");
                that.gsvg.setCurrentViewModified();
                that.gsvg.removeTrack(that.trackClass);
            });
            buttonDiv.append("input").attr("type", "button").attr("value", "Cancel").style("float", "right").style("margin-left", "5px").on("click", function () {
                $('#trackSettingDialog').fadeOut("fast");
            });
        }
    };

    //poll UI controls to adjust settings and do nothing if they are not found
    that.updateSettingsFromUI = function () {
        if ($("#" + that.trackClass + "Dense" + that.level + "Select").length > 0) {
            that.density = $("#" + that.trackClass + "Dense" + that.level + "Select").val();
        }
    };

    that.savePrevious = function () {
        that.prevSetting = {};
        that.prevSetting.density = that.density;
    };

    that.revertPrevious = function () {
        that.density = that.prevSetting.density;
    };

    //update current settings from a view setting string
    that.updateSettings = function (setting) {

    };
    //generate the setting string for a view from current settings
    that.generateTrackSettingString = function () {
        return that.trackClass + "," + that.density + ";";
    };

    /*that.ttMouseOver = function (){
		//console.log("Mouse OVER triggered:"+tt.style("opacity"));
		if(tt.style("opacity")>0){
					    		//console.log("Mouse OVER TT");
					    		mouseTTOver=1;
					    		clearTimeout(ttHideHandle);
		}
	};

	that.ttMouseOver = function (){

	};*/

    that.gsvg = gsvgP;
    that.level = that.gsvg.levelNumber;
    that.data = dataP;
    that.label = labelP;
    that.density = 3;
    that.loading;
    that.trackYMax = 0;
    that.trackClass = trackClassP;
    that.topLevel = that.gsvg.get('topLevel');
    that.xScale = that.gsvg.get('xScale');
    that.scaleSVG = that.gsvg.get('scaleSVG');
    that.xAxis = that.gsvg.get('xAxis');

    //Initialize Y Positioning Variables
    that.yMaxArr = new Array();
    that.yArr = new Array();
    that.yArr[0] = new Array();
    for (var j = 0; j < that.gsvg.width; j++) {
        that.yMaxArr[j] = 0;
        that.yArr[0][j] = 0;
    }
    that.scanBackYLines = 65;
    that.xPadding = 2;
    if (that.gsvg.xScale.domain()[1] - that.gsvg.xScale.domain()[0] > 3000000) {
        that.xPadding = 1;
    }

    that.vis = d3.select("#Level" + that.gsvg.levelNumber + that.trackClass);
    that.svg = d3.select("svg#Level" + that.gsvg.levelNumber + that.trackClass);
    that.svg.on("mousedown", that.panDown);

    that.updateLabel(that.label);
    return that;
}

//Specific Track Objects
/*Track for displaying sequence and translated aa sequence*/
function SequenceTrack(gsvg, trackClass, label, additionalOptions) {
    var data = new Array();
    var that = Track(gsvg, data, trackClass, label);
    that.dispCutoff = 300;
    that.aaDispCutoff = 2900;
    that.seqRegionSize = 4000;
    that.strands = "both";
    that.includeAA = 1;
    that.labelBase = label;
    that.lastUpdate = 0;
    that.seqRegionMin = 0;
    that.seqRegionMax = 0;

    that.color = function (d) {

    };
    that.colorAA = function (d, i) {
        var color = d3.rgb("#FFFFFF");
        if (d.pos % 2 == 0) {
            color = d3.rgb("#C3C3C3");
        } else {
            color = d3.rgb("#838383");
        }
        if (d.aa == "M") {
            color = d3.rgb("#00FF00");
        }
        if (d.aa == "*") {
            color = d3.rgb("#FF0000");
        }
        return color;
    };
    that.createCodon = function () {
        that.codons = [];
        that.codons["AAA"] = "K";
        that.codons["AAT"] = "N";
        that.codons["AAG"] = "K";
        that.codons["AAC"] = "N";
        that.codons["ATA"] = "I";
        that.codons["ATT"] = "I";
        that.codons["ATG"] = "M";
        that.codons["ATC"] = "I";
        that.codons["ACA"] = "T";
        that.codons["ACT"] = "T";
        that.codons["ACG"] = "T";
        that.codons["ACC"] = "T";
        that.codons["AGA"] = "R";
        that.codons["AGT"] = "S";
        that.codons["AGG"] = "R";
        that.codons["AGC"] = "S";
        that.codons["TAA"] = "*";
        that.codons["TAT"] = "Y";
        that.codons["TAG"] = "*";
        that.codons["TAC"] = "Y";
        that.codons["TTA"] = "L";
        that.codons["TTT"] = "F";
        that.codons["TTG"] = "L";
        that.codons["TTC"] = "F";
        that.codons["TCA"] = "S";
        that.codons["TCT"] = "S";
        that.codons["TCG"] = "S";
        that.codons["TCC"] = "S";
        that.codons["TGA"] = "*";
        that.codons["TGT"] = "C";
        that.codons["TGG"] = "W";
        that.codons["TGC"] = "C";
        that.codons["CAA"] = "Q";
        that.codons["CAT"] = "H";
        that.codons["CAG"] = "Q";
        that.codons["CAC"] = "H";
        that.codons["CTA"] = "L";
        that.codons["CTT"] = "L";
        that.codons["CTG"] = "L";
        that.codons["CTC"] = "L";
        that.codons["CCA"] = "P";
        that.codons["CCT"] = "P";
        that.codons["CCG"] = "P";
        that.codons["CCC"] = "P";
        that.codons["CGA"] = "R";
        that.codons["CGT"] = "R";
        that.codons["CGG"] = "R";
        that.codons["CGC"] = "R";
        that.codons["GAA"] = "E";
        that.codons["GAT"] = "D";
        that.codons["GAG"] = "E";
        that.codons["GAC"] = "D";
        that.codons["GTA"] = "V";
        that.codons["GTT"] = "V";
        that.codons["GTG"] = "V";
        that.codons["GTC"] = "V";
        that.codons["GCA"] = "A";
        that.codons["GCT"] = "A";
        that.codons["GCG"] = "A";
        that.codons["GCC"] = "A";
        that.codons["GGA"] = "G";
        that.codons["GGT"] = "G";
        that.codons["GGG"] = "G";
        that.codons["GGC"] = "G";
    }
    that.translate = function (d) {
        d = d.toUpperCase();
        return that.codons[d];
    }
    that.translateRegion = function (aaLevel, offset, start, stop) {
        var aaSeq = new Array();
        var aaCount = 0;
        var minus = 0;
        if (that.data) {
            if (start > stop) {//minus strand
                minus = 1;
                var tmpstart = start;
                start = stop;
                stop = tmpstart;
            }
            for (var i = start; i <= stop; i = i + 3) {
                var seq = that.data.substring(i, i + 3);
                if (minus == 1) {
                    seq = that.reverseCompliment(seq);
                }
                aaSeq[aaCount] = [];
                aaSeq[aaCount].aa = that.translate(seq);
                aaSeq[aaCount].pos = offset + (i - start);
                aaSeq[aaCount].id = aaLevel + ":" + i + ":" + that.translate(seq);
                aaCount++;
            }
        }
        return aaSeq;
    }
    that.reverseCompliment = function (seq) {
        var rc = "";
        for (var k = seq.length - 1; k > -1; k--) {
            rc = rc + that.complement(seq.charAt(k));
        }
        return rc;
    }
    that.complement = function (d) {
        var comp = "N";
        if (d == "A") {
            comp = "T";
        } else if (d == "T") {
            comp = "A";
        } else if (d == "G") {
            comp = "C";
        } else if (d == "C") {
            comp = "G";
        }
        return comp;
    }
    that.redraw = function () {
        that.redrawSelectedArea();
        var tmpMin = that.xScale.domain()[0];
        var tmpMax = that.xScale.domain()[1];
        if (that.prevStrand != that.strands || that.prevIncldAA != that.includeAA) {
            d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll("g.base").each(function (d) {
                d3.select(this).remove();
            });
            d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll("g.aa0").each(function (d) {
                d3.select(this).remove();
            });
            d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll("g.aa1").each(function (d) {
                d3.select(this).remove();
            });
            d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll("g.aa2").each(function (d) {
                d3.select(this).remove();
            });
            d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll("g.aarev0").each(function (d) {
                d3.select(this).remove();
            });
            d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll("g.aarev1").each(function (d) {
                d3.select(this).remove();
            });
            d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll("g.aarev2").each(function (d) {
                d3.select(this).remove();
            });
            if (tmpMin < that.seqRegionMin || tmpMax > that.seqRegionMax) {
                that.updateData(0);
            } else {
                that.draw(that.data);
            }
        } else if (tmpMin < that.seqRegionMin || tmpMax > that.seqRegionMax) {
            that.updateData(0);
        } else {
            var len = tmpMax - tmpMin;
            var aaFont = "12px";
            if (len > 200) {
                aaFont = "10px";
            }
            if ((len <= that.aaDispCutoff && that.includeAA == 1) || (len <= that.dispCutoff)) {
                if (!(that.seqRegionMin <= tmpMin && tmpMin <= that.seqRegionMax
                    && that.seqRegionMin <= tmpMax && tmpMax <= that.seqRegionMax)) {
                    that.updateData(0);
                } else {
                    var charWidth = that.gsvg.width / len;
                    var offsetNA = charWidth / 2;
                    var startInd = tmpMin - that.seqRegionMin;
                    var stopInd = len + startInd;
                    var seqYPos = 27;
                    if (that.includeAA == 1 && that.strands != "-") {
                        seqYPos = seqYPos + 30;
                    }
                    if (len < that.dispCutoff) {
                        d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll("g.line").remove();
                        var dataLen = that.data.length;
                        var dArr = new Array();
                        for (var j = startInd; j < stopInd; j++) {
                            dArr[j - startInd] = [];
                            dArr[j - startInd].base = that.data.charAt(j);
                            dArr[j - startInd].id = j;
                            dArr[j - startInd].pos = j - startInd;
                        }
                        var textSizeVar = that.textSize(len);
                        var yPosComp = that.yPosition(len);


                        var base = that.svg.selectAll(".base")
                            .data(dArr, keyID)
                            .attr("transform", function (d, i) {
                                return "translate(" + ((d.pos) * charWidth - offsetNA) + "," + seqYPos + ")";
                            });
                        //add new
                        var appended = base.enter().append("g")
                            .attr("class", "base")
                            .attr("transform", function (d, i) {
                                return "translate(" + ((d.pos) * charWidth - offsetNA) + "," + seqYPos + ")";
                            });
                        appended.each(function (d) {
                            d3.select(this).append("text")
                                .text(function (d) {
                                    if (that.strands != "-") {
                                        return d.base;
                                    } else {
                                        return that.complement(d.base);
                                    }
                                });
                            if (that.strands == "both") {
                                d3.select(this).append("text")
                                    .attr("class", "comp")
                                    .attr("y", yPosComp)
                                    .text(function (d) {
                                        return that.complement(d.base);
                                    });
                            }
                        });

                        base.exit().remove();
                        base.selectAll("text").attr("font-size", function (d) {
                            return that.textSize(len);
                        });
                        base.selectAll("text.comp").attr("y", yPosComp);
                    } else {
                        d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll("g.base").remove();
                        that.svg.append("g")
                            .attr("class", "line")
                            .append("line")
                            .attr("stroke", "#000000")
                            .attr("x1", 0)
                            .attr("y1", seqYPos)
                            .attr("x2", that.gsvg.width)
                            .attr("y2", seqYPos);
                    }
                    if (that.includeAA == 1) {
                        var aaCharW = charWidth * 3;
                        var aaXLoc = aaCharW / 2 - 4;
                        var tmpLineAt = 25;
                        if (that.strands == "both" || that.strands == "+") {
                            var modStart = tmpMin % 3;
                            var zeroStart = startInd - modStart;
                            var aaList = new Array();
                            aaList[0] = that.translateRegion(0, tmpMin - modStart, zeroStart, zeroStart + len);
                            aaList[1] = that.translateRegion(1, tmpMin - modStart - 1, zeroStart - 1, zeroStart - 1 + len);
                            aaList[2] = that.translateRegion(2, tmpMin - modStart - 2, zeroStart - 2, zeroStart - 2 + len);
                            var tmpLineAt = 25;
                            for (var j = 0; j < 3; j++) {
                                var aa = that.svg.selectAll(".aa" + j)
                                    .data(aaList[j], keyID)
                                    .attr("transform", function (d, i) {
                                        return "translate(" + (that.xScale(d.pos) - charWidth) + "," + tmpLineAt + ")";
                                    })
                                    .each(function (d) {
                                        d3.select(this).select("rect").attr("width", aaCharW);
                                        if (len < that.dispCutoff) {
                                            if (d3.select(this).select("text").size() == 0) {
                                                d3.select(this).append("text")
                                                    .attr("x", aaXLoc)
                                                    .attr("font-size", aaFont)
                                                    .text(function (d) {
                                                        return d.aa;
                                                    });
                                            } else {
                                                d3.select(this).select("text").attr("x", aaXLoc).attr("font-size", aaFont);
                                            }
                                        } else {
                                            d3.select(this).select("text").remove();
                                        }
                                    });
                                //add new
                                var appended = aa.enter().append("g")
                                    .attr("class", "aa" + j)
                                    .attr("transform", function (d, i) {
                                        return "translate(" + (that.xScale(d.pos) - charWidth) + "," + tmpLineAt + ")";
                                    });
                                appended.each(function (d) {
                                    d3.select(this).append("rect")
                                        .attr("y", -10)
                                        .attr("height", 10)
                                        .attr("width", aaCharW)
                                        .attr("stroke", that.colorAA)
                                        .attr("fill", that.colorAA);
                                    if (len < that.dispCutoff) {
                                        d3.select(this).append("text")
                                            .attr("x", aaXLoc)
                                            .attr("font-size", aaFont)
                                            .text(function (d) {
                                                return d.aa;
                                            });
                                    }
                                });
                                aa.exit().remove();
                                tmpLineAt = tmpLineAt + 11;
                            }

                        }
                        if (that.strands == "both") {
                            tmpLineAt = 80;
                        } else {
                            tmpLineAt = 45;
                        }
                        if (that.strands == "both" || that.strands == "-") {
                            var modStart = tmpMin % 3;
                            var zeroStart = startInd - modStart;
                            var aaList = new Array();
                            aaList[0] = that.translateRegion(0, tmpMin - modStart, zeroStart + len, zeroStart);
                            aaList[1] = that.translateRegion(1, tmpMin - modStart - 1, zeroStart - 1 + len, zeroStart - 1);
                            aaList[2] = that.translateRegion(2, tmpMin - modStart - 2, zeroStart - 2 + len, zeroStart - 2);
                            for (var j = 0; j < 3; j++) {
                                var aa = that.svg.selectAll(".aarev" + j)
                                    .data(aaList[j], keyID)
                                    .attr("transform", function (d, i) {
                                        return "translate(" + (that.xScale(d.pos) - charWidth) + "," + tmpLineAt + ")";
                                    })
                                    .each(function (d) {
                                        d3.select(this).select("rect").attr("width", aaCharW);
                                        if (len < that.dispCutoff) {
                                            if (d3.select(this).select("text").size() == 0) {
                                                d3.select(this).append("text")
                                                    .attr("x", aaXLoc)
                                                    .attr("font-size", aaFont)
                                                    .text(function (d) {
                                                        return d.aa;
                                                    });
                                            } else {
                                                d3.select(this).select("text").attr("x", aaXLoc).attr("font-size", aaFont);
                                            }
                                        } else {
                                            d3.select(this).select("text").remove();
                                        }
                                    });
                                //add new
                                var appended = aa.enter().append("g")
                                    .attr("class", "aarev" + j)
                                    .attr("transform", function (d, i) {
                                        return "translate(" + that.xScale(d.pos) + "," + tmpLineAt + ")";
                                    });
                                appended.each(function (d) {
                                    d3.select(this).append("rect")
                                        .attr("y", -10)
                                        .attr("height", 10)
                                        .attr("width", aaCharW)
                                        .attr("stroke", that.colorAA)
                                        .attr("fill", that.colorAA);
                                    if (len < that.dispCutoff) {
                                        d3.select(this).append("text")
                                            .attr("x", aaXLoc)
                                            .attr("font-size", aaFont)
                                            .text(function (d) {
                                                return d.aa;
                                            });
                                    }
                                });
                                aa.exit().remove();
                                tmpLineAt = tmpLineAt + 11;
                            }
                        }
                        if (that.strands == "both") {
                            that.svg.attr("height", 125);
                        } else {
                            that.svg.attr("height", 75);
                        }
                    } else {
                        if (that.strands == "both") {
                            that.svg.attr("height", 45);
                        } else {
                            that.svg.attr("height", 30);
                        }
                    }
                }
                $("li.draggable" + that.gsvg.levelNumber + "#li" + that.trackClass).show();
            } else {
                that.svg.attr("height", 0);
                $("li.draggable" + that.gsvg.levelNumber + "#li" + that.trackClass).hide();
            }
        }
    };
    that.draw = function (data) {
        that.redrawSelectedArea();
        var tmpMin = that.xScale.domain()[0];
        var tmpMax = that.xScale.domain()[1];

        var len = tmpMax - tmpMin;
        var aaLabel = "";
        if (that.includeAA == 1) {
            aaLabel = " and Amino Acids"
        }

        if (that.strands == "both") {
            that.label = that.labelBase + aaLabel + " on +/- strands";
        } else if (that.strands == "+") {
            that.label = that.labelBase + aaLabel + " on + strand";
        } else if (that.strands == "-") {
            that.label = that.labelBase + aaLabel + " on - strand";
        }

        if ((len <= that.aaDispCutoff && that.includeAA == 1) || (len <= that.dispCutoff)) {
        } else {//Only needed to Fix IE Bug which still displays the label
            that.label = "";
        }
        that.updateLabel(that.label);
        that.data = new String(data);
        var aaFont = "10px";
        if (len > 200) {
            aaFont = "8px";
        }
        if (that.data && (len <= that.aaDispCutoff && that.includeAA == 1) || (len <= that.dispCutoff)) {
            var dataLen = data.length;
            var startInd = tmpMin - that.seqRegionMin;
            var stopInd = len + startInd;
            var charWidth = that.gsvg.width / len;
            var offsetNA = charWidth / 2;
            that.svg.selectAll("text.dir").remove();
            if (that.strands == "both") {
                that.svg.append("text").attr("class", "dir").attr("x", 5).attr("y", 15).text("-->");
                that.svg.append("text").attr("class", "dir").attr("x", 5).attr("y", 120).text("<--");
                that.svg.append("text").attr("class", "dir").attr("x", that.gsvg.width - 60).attr("y", 15).text("-->");
                that.svg.append("text").attr("class", "dir").attr("x", that.gsvg.width - 20).attr("y", 120).text("<--");
            } else if (that.strands == "+") {
                that.svg.append("text").attr("class", "dir").attr("x", 5).attr("y", 15).text("-->");
                that.svg.append("text").attr("class", "dir").attr("x", that.gsvg.width - 60).attr("y", 15).text("-->");
            } else if (that.strands == "-") {
                that.svg.append("text").attr("class", "dir").attr("x", 5).attr("y", 15).text("<--");
                that.svg.append("text").attr("class", "dir").attr("x", that.gsvg.width - 60).attr("y", 15).text("<--");
            }

            if (len < that.dispCutoff && data.length > 1) {
                var dArr = new Array();
                for (var j = startInd; j < stopInd; j++) {
                    dArr[j - startInd] = [];
                    dArr[j - startInd].base = data.charAt(j);
                    dArr[j - startInd].id = j;
                    dArr[j - startInd].pos = j - startInd;
                }
                var textSizeVar = that.textSize(len);
                var yPosComp = that.yPosition(len);
                var seqYPos = 27;
                if (that.includeAA == 1 && that.strands != "-") {
                    seqYPos = seqYPos + 30;
                }
                var base = that.svg.selectAll(".base")
                    .data(dArr, keyID)
                    .attr("transform", function (d, i) {
                        return "translate(" + ((d.pos) * charWidth) + "," + seqYPos + ")";
                    });
                //add new
                var appended = base.enter().append("g")
                    .attr("class", "base")
                    .attr("transform", function (d, i) {
                        return "translate(" + ((d.pos) * charWidth) + "," + seqYPos + ")";
                    });
                appended.each(function (d) {
                    var tmpD = d;
                    d3.select(this).append("text")
                        .text(function (d) {
                            if (that.strands != "-") {
                                return tmpD.base;
                            } else {
                                return that.complement(tmpD.base);
                            }
                        });
                    if (that.strands == "both") {
                        d3.select(this).append("text")
                            .attr("class", "comp")
                            .attr("y", yPosComp)
                            .text(function (d) {
                                return that.complement(tmpD.base);
                            });
                    }
                });

                base.exit().remove();
                base.selectAll("text").attr("font-size", textSizeVar);
            } else {
                that.svg.append("g")
                    .attr("class", "base")
                    .append("line")
                    .attr("stroke", "#000000")
                    .attr("x1", 0)
                    .attr("y1", 57)
                    .attr("x2", that.gsvg.width)
                    .attr("y2", 57);
            }
            if (that.data && that.includeAA == 1) {
                var aaCharW = charWidth * 3;
                //var offsetAA=charWidth/2;
                var aaXLoc = aaCharW / 2 - 4;
                var tmpLineAt = 25;
                if (that.strands == "both" || that.strands == "+") {
                    var modStart = tmpMin % 3;
                    var zeroStart = startInd - modStart;
                    var aaList = new Array();
                    aaList[0] = that.translateRegion(0, tmpMin - modStart, zeroStart, zeroStart + len);
                    aaList[1] = that.translateRegion(1, tmpMin - modStart - 2, zeroStart - 2, zeroStart - 2 + len);
                    aaList[2] = that.translateRegion(2, tmpMin - modStart - 1, zeroStart - 1, zeroStart - 1 + len);
                    var tmpLineAt = 25;
                    for (var j = 0; j < 3; j++) {
                        var aa = that.svg.selectAll(".aa" + j)
                            .data(aaList[j], keyID)
                            .attr("transform", function (d, i) {
                                return "translate(" + that.xScale(d.pos) + "," + tmpLineAt + ")";
                            })
                            .each(function (d) {
                                var tmpD = d;
                                d3.select(this).select("rect").attr("width", aaCharW);
                                if (len < that.dispCutoff) {
                                    if (d3.select(this).select("text").size() == 0) {
                                        d3.select(this).append("text")
                                            .attr("x", aaXLoc)
                                            .attr("font-size", aaFont)
                                            .text(function (d) {
                                                return tmpD.aa;
                                            });
                                    } else {
                                        d3.select(this).select("text").attr("x", aaXLoc).attr("font-size", aaFont);
                                    }
                                } else {
                                    d3.select(this).select("text").remove();
                                }
                            });
                        //add new
                        aa.enter().append("g")
                            .attr("class", "aa" + j)
                            .attr("transform", function (d, i) {
                                return "translate(" + that.xScale(d.pos) + "," + tmpLineAt + ")";
                            })
                            .each(function (d) {
                                var tmpD = d;
                                d3.select(this).append("rect")
                                    .attr("y", -10)
                                    .attr("height", 10)
                                    .attr("width", aaCharW)
                                    .attr("stroke", that.colorAA(tmpD))
                                    .attr("fill", that.colorAA(tmpD));
                                if (len < that.dispCutoff) {
                                    d3.select(this).append("text")
                                        .attr("x", aaXLoc)
                                        .attr("font-size", aaFont)
                                        .text(function () {
                                            return tmpD.aa;
                                        });
                                }
                            });
                        /*/var aa=that.svg.selectAll(".aa"+j)
			   				.data(aaList[j],keyID)
							.attr("transform",function(d,i){ return "translate("+that.xScale(d.pos)+","+tmpLineAt+")";});
						//add new
						/*aa.enter().append("g")
								.attr("class","aa"+j)
								.attr("transform",function(d,i){ return "translate("+that.xScale(d.pos)+","+tmpLineAt+")";});
						aa.each( function (d){
								d3.select(this).append("rect")
									.attr("y",-10)
									.attr("height",10)
									.attr("width",aaCharW)
									.attr("stroke",that.colorAA)
									.attr("fill",that.colorAA);
								d3.select(this).append("text")
									.attr("x",aaXLoc)
									.attr("font-size",aaFont)
					    			.text(function(d){
					    				return d.aa;
					    			});
					    	});*/
                        aa.exit().remove();
                        tmpLineAt = tmpLineAt + 11;
                    }

                }
                if (that.strands == "both") {
                    tmpLineAt = 80;
                } else {
                    tmpLineAt = 45;
                }
                if (that.strands == "both" || that.strands == "-") {
                    var modStart = tmpMin % 3;
                    var zeroStart = startInd - modStart;
                    var aaList = new Array();
                    aaList[0] = that.translateRegion(0, tmpMin - modStart, zeroStart + len, zeroStart);
                    aaList[1] = that.translateRegion(1, tmpMin - modStart - 1, zeroStart - 1 + len, zeroStart - 1);
                    aaList[2] = that.translateRegion(2, tmpMin - modStart - 2, zeroStart - 2 + len, zeroStart - 2);
                    for (var j = 0; j < 3; j++) {
                        var aa = that.svg.selectAll(".aarev" + j)
                            .data(aaList[j], keyID)
                            .attr("transform", function (d, i) {
                                return "translate(" + that.xScale(d.pos) + "," + tmpLineAt + ")";
                            });
                        //add new
                        var appended = aa.enter().append("g")
                            .attr("class", "aarev" + j)
                            .attr("transform", function (d, i) {
                                return "translate(" + that.xScale(d.pos) + "," + tmpLineAt + ")";
                            });
                        appended.each(function (d) {
                            var tmpD = d;
                            d3.select(this).append("rect")
                                .attr("y", -10)
                                .attr("height", 10)
                                .attr("width", aaCharW)
                                .attr("stroke", that.colorAA(tmpD))
                                .attr("fill", that.colorAA(tmpD));
                            if (len < that.dispCutoff) {
                                d3.select(this).append("text")
                                    .attr("x", aaXLoc)
                                    .attr("font-size", aaFont)
                                    .text(function (d) {
                                        return tmpD.aa;
                                    });
                            }
                        });
                        aa.exit().remove();
                        tmpLineAt = tmpLineAt + 11;
                    }
                }
                if (that.strands == "both") {
                    that.svg.attr("height", 125);
                } else {
                    that.svg.attr("height", 75);
                }
            } else {
                if (that.strands == "both") {
                    that.svg.attr("height", 45);
                } else {
                    that.svg.attr("height", 30);
                }
            }
            that.prevStrand = that.strands;
            that.prevIncldAA = that.includeAA;
            $("li.draggable" + that.gsvg.levelNumber + "#li" + that.trackClass).show();
        } else {
            that.svg.attr("height", 0);
            $("li.draggable" + that.gsvg.levelNumber + "#li" + that.trackClass).hide();
        }
    };


    that.textSize = function (len) {
        var size = "9px";
        if (len <= 100) {
            size = "11px";
        } else if (len <= 150) {
            size = "8px";
        } else if (len <= 200) {
            size = "6.8px";
        } else if (len <= 250) {
            size = "5.8px";
        } else if (len <= 300) {
            size = "4.8px";
        }
        return size;
    };
    that.yPosition = function (len) {
        var size = 12;
        if (len <= 100) {
            size = 12;
        } else if (len <= 150) {
            size = 10;
        } else if (len <= 200) {
            size = 8;
        } else if (len <= 250) {
            size = 6;
        } else if (len <= 300) {
            size = 5;
        }
        return size;
    };
    that.updateData = function (retry) {
        var curTime = (new Date()).getTime();
        if (curTime - that.lastUpdate > 25000 || retry > 0) {
            if (retry === 0 && (that.lastUpdate === 0 || curTime - that.lastUpdate < 25000)) {
                that.tmpseqRegionMin = that.xScale.domain()[0] - that.seqRegionSize;
                that.tmpseqRegionMax = that.xScale.domain()[1] + that.seqRegionSize;
                if (that.tmpseqRegionMin < 0) {
                    that.tmpseqRegionMin = 0;
                }
            }
            if ((that.xScale.domain()[1] - that.xScale.domain()[0]) < that.aaDispCutoff) {
                that.lastUpdate = curTime;
                if (that.svg && that.svg.attr("height") < 30) {
                    that.svg.attr("height", 30);
                }
                if (retry === 0) {
                    that.showLoading();
                }

                var path = dataPrefix + "tmpData/browserCache/" + genomeVer + "/regionData/" + that.gsvg.folderName + "/" + that.tmpseqRegionMin + "_" + that.tmpseqRegionMax + ".seq";
                d3.text(path, function (error, d) {
                    if (error) {
                        //console.log(error);
                        if (retry === 0) {
                            var tmpContext = "/" + pathPrefix;
                            if (!pathPrefix) {
                                tmpContext = "";
                            }
                            $.ajax({
                                url: tmpContext + "generateTrackXML.jsp",
                                type: 'GET',
                                cache: false,
                                async: true,
                                data: {
                                    chromosome: chr,
                                    minCoord: that.tmpseqRegionMin,
                                    maxCoord: that.tmpseqRegionMax,
                                    panel: panel,
                                    rnaDatasetID: rnaDatasetID,
                                    arrayTypeID: arrayTypeID,
                                    myOrganism: organism,
                                    genomeVer: genomeVer,
                                    dataVer: dataVer,
                                    track: that.trackClass,
                                    folder: that.gsvg.folderName
                                },
                                dataType: 'json',
                                success: function (data2) {
                                    /*if(ga){
												ga('send','event','browser','generateTrackSequence');
											}*/
                                    gtag('event', 'generateTrackSequence', {'event_category': 'browser'});
                                },
                                error: function (xhr, status, error) {

                                }
                            });
                        }
                        if (retry < 3) {//wait before trying again
                            var time = 10000;
                            if (retry === 1) {
                                time = 15000;
                            }
                            setTimeout(function () {
                                that.updateData(retry + 1);
                            }, time);
                        } else {
                            that.seqRegionMin = 0;
                            that.seqRegionMax = 0;
                            that.hideLoading();
                            d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).select("#trkLbl").text("An errror occurred loading Track:" + that.trackClass);
                            d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).attr("height", 15);
                            that.gsvg.addTrackErrorRemove(that.svg, "#Level" + that.gsvg.levelNumber + that.trackClass);
                            that.lastUpdate = 0;
                        }
                    } else {
                        that.seqRegionMin = that.tmpseqRegionMin;
                        that.seqRegionMax = that.tmpseqRegionMax;
                        that.hideLoading();
                        that.draw(d);
                        that.lastUpdate = 0;
                        setTimeout(function () {
                            DisplayRegionReport();
                        }, 300);
                    }
                });
            }
        }
    };

    that.updateSettingsFromUI = function () {
        if ($("#" + that.trackClass + that.level + "Select").length > 0) {
            that.strands = $("#" + that.trackClass + that.level + "Select").val();
        }
        if ($("#" + that.trackClass + "CBX" + that.level + "dispAA").length > 0) {
            if ($("#" + that.trackClass + "CBX" + that.level + "dispAA").is(":checked")) {
                that.includeAA = 1;
            } else {
                that.includeAA = 0;
            }
        }
    };

    that.savePrevious = function () {
        that.prevSetting = {};
        that.prevSetting.strands = that.strands;
        that.prevSetting.includeAA = that.includeAA;
    };

    that.revertPrevious = function () {
        that.strands = that.prevSetting.strands;
        that.includeAA = that.prevSetting.includeAA;
    };

    that.generateTrackSettingString = function () {
        return that.trackClass + "," + that.strands + "," + that.includeAA + ";";
    };

    that.generateSettingsDiv = function (topLevelSelector) {
        var d = trackInfo[that.trackClass];
        that.savePrevious();
        //console.log(trackInfo);
        //console.log(d);
        d3.select(topLevelSelector).select("table").select("tbody").html("");
        if (d.Controls.length > 0 && d.Controls != "null") {
            var controls = new String(d.Controls).split(",");
            var table = d3.select(topLevelSelector).select("table").select("tbody");
            table.append("tr").append("td").style("font-weight", "bold").html("Track Settings: " + d.Name);
            for (var c = 0; c < controls.length; c++) {
                if (controls[c] && controls[c] != "") {
                    var params = controls[c].split(";");

                    var div = table.append("tr").append("td");
                    var lbl = params[0].substr(5);

                    var def = "";
                    if (params.length > 3 && params[3].indexOf("Default=") === 0) {
                        def = params[3].substr(8);
                    }
                    if (params[1].toLowerCase().indexOf("select") === 0) {
                        div.append("text").text(lbl + ": ");
                        var selClass = params[1].split(":");
                        var opts = params[2].split("}");
                        var id = that.trackClass + that.level + "Select";
                        var sel = div.append("select").attr("id", id)
                            .attr("name", selClass[1]);
                        for (var o = 0; o < opts.length; o++) {
                            var option = opts[o].substr(1).split(":");
                            if (option.length == 2) {
                                var tmpOpt = sel.append("option").attr("value", option[1]).text(option[0]);
                                if (option[1] == that.strands) {
                                    tmpOpt.attr("selected", "selected");
                                }
                                /*if(option[1]==def){
									tmpOpt.attr("selected","selected");
								}*/
                            }
                        }
                        d3.select("select#" + id).on("change", function () {
                            that.updateSettingsFromUI();
                            that.redraw();
                        });
                    } else if (params[1].toLowerCase().indexOf("cbx") === 0) {
                        div.append("text").text(lbl);
                        var selClass = params[1].split(":");
                        var opts = params[2].split("}");

                        for (var o = 0; o < opts.length; o++) {
                            var option = opts[o].substr(1).split(":");
                            if (option.length === 2) {
                                var span = div.append("div").style("display", "inline-block");
                                var suffix = "";
                                var prefix = "";
                                if (selClass.length > 2) {
                                    prefix = selClass[2];
                                }
                                if (selClass.length > 3) {
                                    suffix = selClass[3];
                                }
                                var sel = span.append("input").attr("type", "checkbox").attr("id", that.trackClass + prefix + "CBX" + that.level + suffix)
                                    .attr("name", selClass[1])
                                    .style("margin-left", "5px");
                                span.append("text").text(option[0]);
                                //console.log(def+"::"+option[1]);
                                if (that.includeAA == 1) {
                                    $("#" + that.trackClass + prefix + "CBX" + that.level + suffix).prop('checked', true);
                                    //sel.attr("checked","checked");
                                } else {
                                    $("#" + that.trackClass + prefix + "CBX" + that.level + suffix).prop('checked', false);
                                }
                                d3.select("input#" + that.trackClass + prefix + "CBX" + that.level + suffix).on("change", function () {
                                    //console.log("CBX changed");
                                    that.updateSettingsFromUI();
                                    that.redraw();
                                });
                            }
                        }
                    }
                }
            }
            var buttonDiv = table.append("tr").append("td");
            buttonDiv.append("input").attr("type", "button").attr("value", "Remove Track").style("float", "left").style("margin-left", "5px").on("click", function () {
                $('#trackSettingDialog').fadeOut("fast");
                that.gsvg.removeTrack(that.trackClass);
                that.gsvg.setCurrentViewModified();
                var viewID = svgList[that.gsvg.levelNumber].currentView.ViewID;
                var track = viewMenu[that.gsvg.levelNumber].findTrackByClass(that.trackClass, viewID);
                var indx = viewMenu[that.gsvg.levelNumber].findTrackIndexWithViewID(track.TrackID, viewID);
                viewMenu[that.gsvg.levelNumber].removeTrackWithIDIdx(indx, viewID);
            });
            buttonDiv.append("input").attr("type", "button").attr("value", "Apply").style("float", "right").style("margin-left", "5px").on("click", function () {
                $('#trackSettingDialog').fadeOut("fast");
                if (that.strands != that.prevSetting.strands || that.includeAA != that.prevSetting.includeAA) {
                    that.gsvg.setCurrentViewModified();
                }
            });
            buttonDiv.append("input").attr("type", "button").attr("value", "Cancel").style("float", "right").style("margin-left", "5px").on("click", function () {
                that.revertPrevious();
                that.draw(that.data);
                $('#trackSettingDialog').fadeOut("fast");
            });
        } else {
            var table = d3.select(topLevelSelector).select("table").select("tbody");
            table.append("tr").append("td").style("font-weight", "bold").html("Track Settings: " + d.Name);
            table.append("tr").append("td").html("Sorry no settings for this track.");
            var buttonDiv = table.append("tr").append("td");
            buttonDiv.append("input").attr("type", "button").attr("value", "Remove Track").style("float", "left").style("margin-left", "5px").on("click", function () {
                $('#trackSettingDialog').fadeOut("fast");
            });
            buttonDiv.append("input").attr("type", "button").attr("value", "Cancel").style("float", "right").style("margin-left", "5px").on("click", function () {
                $('#trackSettingDialog').fadeOut("fast");
            });
        }
    };

    that.createCodon();
    that.updateData(0);
    that.draw(data);
    return that;
}

/*Track for displaying ProteinCoding,Long Non Coding, Small RNAs*/
function GeneTrack(gsvg, data, trackClass, label, additionalOptions) {
    var that = Track(gsvg, data, trackClass, label);
    that.counts = [{value: 0, names: "Ensembl"}, {value: 0, names: "Brain RNA-Seq"}];
    var additionalOptStr = new String(additionalOptions);
    that.drawAs = "Gene";
    that.trxCutoff = 100000;
    var additionalOptStr = new String(additionalOptions);
    var tmpMin = that.xScale.domain()[0];
    var tmpMax = that.xScale.domain()[1];
    var len = tmpMax - tmpMin;
    if (additionalOptStr.indexOf("DrawTrx") > -1) {
        that.drawAs = "Trx";
    }
    that.density = 3;
    that.dataVer = 0;
    that.reqDataVer = 0;
    that.ttTrackList = [];
    if (that.trackClass.indexOf("smallnc") === -1) {
        that.ttTrackList.push("ensemblcoding");
        that.ttTrackList.push("braincoding");
        that.ttTrackList.push("brainTotal");
        that.ttTrackList.push("liverTotal");
        that.ttTrackList.push("heartTotal");
        that.ttTrackList.push("kidneyTotal");
        that.ttTrackList.push("mergedTotal");
        that.ttTrackList.push("brainIso");
        that.ttTrackList.push("liverIso");
        that.ttTrackList.push("refSeq");
        that.ttTrackList.push("ensemblnoncoding");
        that.ttTrackList.push("brainnoncoding");
        that.ttTrackList.push("repeatMask");
        that.ttTrackList.push("snpSHRH");
        that.ttTrackList.push("snpBNLX");
        that.ttTrackList.push("snpF344");
        that.ttTrackList.push("snpSHRJ");
    } else {
        that.ttTrackList.push("ensemblsmallnc");
        that.ttTrackList.push("brainsmallnc");
        that.ttTrackList.push("liversmallnc");
        that.ttTrackList.push("heartsmallnc");
        that.ttTrackList.push("refSeq");
        that.ttTrackList.push("repeatMask");
        that.ttTrackList.push("snpSHRH");
        that.ttTrackList.push("snpBNLX");
        that.ttTrackList.push("snpF344");
        that.ttTrackList.push("snpSHRJ");
    }

    if (trackClass === "braincoding") {
        that.ttTrackList.push("spliceJnct");
        that.ttTrackList.push("illuminaPolyA");
    } else if (trackClass.indexOf("liverTotal") === 0) {
        that.ttTrackList.push("liverspliceJnct");
        that.ttTrackList.push("liverilluminaTotalPlus");
        that.ttTrackList.push("liverilluminaTotalMinus");
    } else if (trackClass === "heartTotal") {
        that.ttTrackList.push("heartspliceJnct");
        that.ttTrackList.push("heartilluminaTotalPlus");
        that.ttTrackList.push("heartilluminaTotalMinus");
    } else if (trackClass.indexOf("brainTotal") === 0) {
        that.ttTrackList.push("brainspliceJnct");
        that.ttTrackList.push("brainilluminaTotalPlus");
        that.ttTrackList.push("brainilluminaTotalMinus");
    } else if (trackClass === "brainsmallnc") {
        that.ttTrackList.push("illuminaSmall");
    } else if (trackClass === "heartsmallnc") {
        that.ttTrackList.push("heartilluminaSmall");
    } else if (trackClass === "liversmallnc") {
        that.ttTrackList.push("liverilluminaSmall");
    }
    that.pieColorPalette = d3.scaleOrdinal(d3.schemeCategory20);

    that.cleanID = function (id) {
        id = id.replace(/\./g, "_");
        return id;
    };

    that.color = function (d) {
        var color = "#000000";
        //console.log(that.trackClass);
        if (that.trackClass === "ensemblcoding") {
            color = "#DFC184";
        } else if (that.trackClass === "braincoding") {
            color = "#7EB5D6";
            if (d.getAttribute("strain") !== null && typeof d.getAttribute("strain") !== 'undefined' && d.getAttribute("strain") !== "All") {
                color = that.strainSpecColor(color, d);
            }
        } else if (that.trackClass === "ensemblnoncoding") {
            color = "#B58AA5";
        } else if (that.trackClass === "brainnoncoding") {
            color = "#CECFCE";
            if (d.getAttribute("strain") !== null && typeof d.getAttribute("strain") !== 'undefined' && d.getAttribute("strain").toUpperCase() === "BNLX") {
                color = "#3E75FF";
            } else if (d.getAttribute("strain") !== null && typeof d.getAttribute("strain") !== 'undefined' && (d.getAttribute("strain").toUpperCase() === "SHR" || d.getAttribute("strain").toUpperCase() === "SHRH")) {
                color = "#FE7596";
            }
        } else if (that.trackClass === "ensemblsmallnc") {
            color = "#FFCC00";
        } else if (that.trackClass === "brainsmallnc") {
            color = "#3E7596";
            if (d.getAttribute("strain") !== null && typeof d.getAttribute("strain") !== 'undefined' && d.getAttribute("strain") !== "All") {
                color = that.strainSpecColor(color, d);
            }
        } else if (that.trackClass.indexOf("liverTotal") === 0) {
            color = "#bbbedd";
            if (that.trackClass.indexOf("_F344Stm") > 0) {
                color = "#abaefd";
            } else if (that.trackClass.indexOf("_LEStm") > 0) {
                color = "#dbaecd";
            }
            if (d.getAttribute("strain") !== null && typeof d.getAttribute("strain") !== 'undefined' && d.getAttribute("strain") !== "All") {
                color = that.strainSpecColor(color, d);
            }
        } else if (that.trackClass === "heartTotal") {
            color = "#DC7252";
            if (d.getAttribute("strain") !== null && typeof d.getAttribute("strain") !== 'undefined' && d.getAttribute("strain") !== "All") {
                color = that.strainSpecColor(color, d);
            }
        } else if (that.trackClass === "kidneyTotal") {
            color = "#fdb462";
            if (d.getAttribute("strain") !== null && typeof d.getAttribute("strain") !== 'undefined' && d.getAttribute("strain") !== "All") {
                color = that.strainSpecColor(color, d);
            }
        } else if (that.trackClass.indexOf("brainTotal") === 0) {
            color = "#7EB5D6";
            if (that.trackClass.indexOf("_F344Stm") > 0) {
                color = "#6EA5F6";
            } else if (that.trackClass.indexOf("_LEStm") > 0) {
                color = "#9EA5C6";
            }
            if (d.getAttribute("strain") !== null && typeof d.getAttribute("strain") !== 'undefined' && d.getAttribute("strain") !== "All") {
                color = that.strainSpecColor(color, d);
            }
        } else if (that.trackClass === "liversmallnc") {
            color = "#7b7e9d";
            if (d.getAttribute("strain") !== null && typeof d.getAttribute("strain") !== 'undefined' && d.getAttribute("strain") !== "All") {
                color = that.strainSpecColor(color, d);
            }
        } else if (that.trackClass === "heartsmallnc") {
            color = "#9C3212";
            if (d.getAttribute("strain") !== null && typeof d.getAttribute("strain") !== 'undefined' && d.getAttribute("strain") !== "All") {
                color = that.strainSpecColor(color, d);
            }
        } else if (that.trackClass === "mergedTotal") {
            color = "#9F4F92";
        } else if (that.trackClass === "brainIso") {
            color = "#4E85D6";
        } else if (that.trackClass === "liverIso") {
            color = "#9b9ebd";
        }
        color = d3.rgb(color);
        return color;
    };

    that.strainSpecColor = function (currentColor, d) {
        var color = currentColor;
        var r = parseInt(currentColor.substr(1, 2), 16);
        var g = parseInt(currentColor.substr(3, 2), 16);
        var b = parseInt(currentColor.substr(5), 16);
        if (d.getAttribute("strain").toUpperCase() === "BNLX") {//more blue since strain specific SNPs are blue
            b = b + 64;
            r = r - 32;
            g = g - 32;
        } else if (d.getAttribute("strain").toUpperCase() === "SHR" || d.getAttribute("strain").toUpperCase() === "SHRH") {// more red since strain specific SNPs are red
            r = r + 64;
            b = b - 32;
            g = g - 32;
        } else if (d.getAttribute("strain").toUpperCase() === "F344_ST") {
            b = b + 32;
            r = r - 16;
            g = g - 16;
        } else if (d.getAttribute("strain").toUpperCase() === "LE_ST") {
            r = r + 32;
            b = b - 16;
            g = g - 16;
        }
        if (r > 255) {
            r = 255;
        }
        if (g > 255) {
            g = 255;
        }
        if (b > 255) {
            b = 255;
        }
        color = "#" + r.toString(16) + g.toString(16) + b.toString(16);
        return color;
    };

    that.pieStrainSpecColor = function (color, strain) {
        var r = parseInt(color.substr(1, 2), 16);
        var g = parseInt(color.substr(3, 2), 16);
        var b = parseInt(color.substr(5), 16);
        if (strain.toUpperCase() === "BNLX") {//more blue since strain specific SNPs are blue
            b = b + 64;
            r = r - 32;
            g = g - 32;
        } else if (strain.toUpperCase() === "SHR" || strain.toUpperCase() === "SHRH") {// more red since strain specific SNPs are red
            r = r + 64;
            b = b - 32;
            g = g - 32;
        }
        if (r > 255) {
            r = 255;
        }
        if (g > 255) {
            g = 255;
        }
        if (b > 255) {
            b = 255;
        }
        color = "#" + r.toString(16) + g.toString(16) + b.toString(16);
        return color;
    };

    that.pieColor = function (d, i) {
        var color = "#000000";
        if (that.trackClass === "ensemblcoding") {
            color = "#DFC184";
        } else if (that.trackClass === "braincoding") {
            color = "#7EB5D6";
            color = that.pieStrainSpecColor(color, d.data.names);
        } else if (that.trackClass === "ensemblnoncoding") {
            color = "#B58AA5";
        } else if (that.trackClass === "brainnoncoding") {
            color = "#CECFCE";
            if (d.data.names !== null && typeof d.data.names !== 'undefined' && d.data.names.toUpperCase() === "BNLX") {
                color = "#3E75FF";
            } else if (d.data.names !== null && typeof d.data.names !== 'undefined' && (d.data.names.toUpperCase() === "SHR" || d.data.names.toUpperCase() === "SHRH")) {
                color = "#FE7596";
            }
        } else if (that.trackClass === "ensemblsmallnc") {
            color = that.pieColorPalette(d.data.names);
            //color="#FFCC00";
        } else if (that.trackClass === "brainsmallnc") {

            color = "#99CC99";
            color = that.pieStrainSpecColor(color, d.data.names);
        } else if (that.trackClass.indexOf("liverTotal") === 0) {
            color = "#bbbedd";
            color = that.pieStrainSpecColor(color, d.data.names);
        } else if (that.trackClass === "heartTotal") {
            color = "#DC7252";
            color = that.pieStrainSpecColor(color, d.data.names);
        } else if (that.trackClass === "kidneyTotal") {
            color = "#fdb462";
        } else if (that.trackClass.indexOf("brainTotal") === 0) {
            color = "#7EB5D6";
            color = that.pieStrainSpecColor(color, d.data.names);
        } else if (that.trackClass === "liversmallnc") {
            color = "#8b8ead";
            color = that.pieStrainSpecColor(color, d.data.names);
        } else if (that.trackClass === "heartsmallnc") {
            color = "#BC5232";
            color = that.pieStrainSpecColor(color, d.data.names);
        } else if (that.trackClass === "mergedTotal") {
            color = "#9F4F92";
        } else if (that.trackClass === "brainIso") {
            color = "#4E85D6";
        } else if (that.trackClass === "liverIso") {
            color = "#9b9ebd";
        }
        color = d3.rgb(color);
        return color;
    };

    that.getDisplayID = function (id) {
        if (that.trackClass.indexOf("smallnc") > -1) {
            /*if(id.indexOf("ENS")===-1){
				var prefix="smRNA_";
				id=id.substr(id.indexOf("_")+1);
				id=id.replace(/^0+/, '');
				id=prefix+id;
			}*/
        } else {
            if (id.indexOf("_") > -1) {
                id = id.substr(id.indexOf("_") + 1);
            }
        }
        return id;
    };

    that.createToolTip = function (d) {
        //console.log("createToolTip:GeneTrack");
        var tooltip = "";
        var txListStr = "";
        if (that.trackClass.indexOf("smallnc") > -1) {
            var rnaSeqData = "";
            var type = "Known - " + d.getAttribute("biotype");
            var strand = ".";
            if (d.getAttribute("strand") == 1) {
                strand = "+";
            } else if (d.getAttribute("strand") == -1) {
                strand = "-";
            }
            if (new String(d.getAttribute("ID")).indexOf("P") === 0) {
                var txList = getAllChildrenByName(getFirstChildByName(d, "TranscriptList"), "Transcript");
                var quantList = getAllChildrenByName(getFirstChildByName(d, "StrainQuantList"), "Strains");
                //console.log(quantList);
                var bIndx = 0;
                var sIndx = 1;
                if (quantList[1].getAttribute("strain") === "BNLx") {
                    bIndx = 1;
                    sIndx = 0;
                }
                type = txList[0].getAttribute("category") + " - " + txList[0].getAttribute("source");
                /*rnaSeqData="<BR><BR>Read Depth Data:<BR><table name=\"items\"class=\"list_base\" cellpadding=\"0\" cellspacing=\"0\" style=\"width:100%;border: solid 1px #000;\"><thead><th><td>BNLx</td><td>SHR</td></th></thead>";
				rnaSeqData=rnaSeqData+"<tr><td>Median Read Depth</td><td>"+numberWithCommas(quantList[bIndx].getAttribute("median"))+"</td><td>"+numberWithCommas(quantList[sIndx].getAttribute("median"))+"</td></tr>";
				rnaSeqData=rnaSeqData+"<tr><td>Mean Read Depth</td><td>"+numberWithCommas(quantList[bIndx].getAttribute("mean"))+"</td><td>"+numberWithCommas(quantList[sIndx].getAttribute("mean"))+"</td></tr>";
				rnaSeqData=rnaSeqData+"<tr><td>% Coverage</td><td>"+quantList[bIndx].getAttribute("cov")+"</td><td>"+quantList[sIndx].getAttribute("cov")+"</td></tr>";
				rnaSeqData=rnaSeqData+"<tr><td>Min Read Depth</td><td>"+numberWithCommas(quantList[bIndx].getAttribute("min"))+"</td><td>"+numberWithCommas(quantList[sIndx].getAttribute("min"))+"</td></tr>";
				rnaSeqData=rnaSeqData+"<tr><td>Max Read Depth</td><td>"+numberWithCommas(quantList[bIndx].getAttribute("max"))+"</td><td>"+numberWithCommas(quantList[sIndx].getAttribute("max"))+"</td></tr>";
				rnaSeqData=rnaSeqData+"</table>";*/
            }
            tooltip = "<BR><div id=\"ttSVG\" style=\"background:#FFFFFF;\"></div>ID: " + d.getAttribute("ID");
            if (that.trackClass.indexOf("ensembl") === -1) {
                tooltip = tooltip + "<BR>PhenoGen ID: " + d.getAttribute("intGeneID");
            }
            tooltip = tooltip + "<BR>Length: " + (d.getAttribute("stop") - d.getAttribute("start")) + "<BR>Type:" + type + "<BR>Location: " + d.getAttribute("chromosome") + ":" + numberWithCommas(d.getAttribute("start")) + "-" + numberWithCommas(d.getAttribute("stop")) + "<BR>Strand: " + strand + rnaSeqData + "<BR>";
        } else {
            var gid = d.getAttribute("ID");
            gid = that.getDisplayID(gid);
            var geneSym = "";
            if (d.getAttribute("geneSymbol")) {
                geneSym = d.getAttribute("geneSymbol");
            } else if (d.parent && d.parent.getAttribute("geneSymbol")) {
                geneSym = d.parent.getAttribute("geneSymbol");
            }
            var strand = ".";
            if (d.getAttribute("strand") == 1) {
                strand = "+";
            } else if (d.getAttribute("strand") == -1) {
                strand = "-";
            }
            if (d.parent) {
                //console.log("tt text");
                //console.log(d.parent);
                var txList = getAllChildrenByName(getFirstChildByName(d.parent, "TranscriptList"), "Transcript");
                //console.log(txList);
                for (var m = 0; m < txList.length; m++) {
                    var id = new String(txList[m].getAttribute("ID"));
                    /*if(id.indexOf("ENS")==-1){
						id=id.substr(id.indexOf("_")+1);
						id=id.replace(/^0+/, '');
						id="Brain.T"+id;
					}*/
                    if (gid != id) {
                        if (new String(txList[m].getAttribute("ID")).indexOf("ENS") > -1) {
                            txListStr += "<B>" + id + "</B>";
                            txListStr += "<br>";
                        } else {
                            txListStr += "<B>" + id + "</B>";
                            if (new String(txList[m].getAttribute("ID")).indexOf("ENS") == -1) {
                                var annot = getFirstChildByName(getFirstChildByName(txList[m], "annotationList"), "annotation");
                                if (annot != null) {
                                    txListStr += " - " + annot.getAttribute("reason");
                                }
                            }
                            txListStr += "<br>";
                        }
                    }
                    if (geneSym == "") {
                        var annotList = getAllChildrenByName(getFirstChildByName(txList[m], "annotationList"), "annotation");
                        for (var p = 0; p < annotList.length && geneSym == ""; p++) {
                            if (annotList[p].getAttribute("source") == "AKA") {
                                var aka = annotList[p].getAttribute("annot_value");
                                var akaList = new String(aka).split(":");
                                if (new String(akaList[akaList.length - 1]).indexOf("ENS") != 0) {
                                    geneSym = akaList[akaList.length - 1];
                                } else {
                                    geneSym = akaList[0];
                                }
                            }
                        }
                    }

                }
                tooltip = "<BR><div id=\"ttSVG\" style=\"background:#FFFFFF;overflow:\"></div><BR>Transcript ID: " + gid + "<BR>Location: " + d.getAttribute("chromosome") + ":" + numberWithCommas(d.getAttribute("start")) + "-" + numberWithCommas(d.getAttribute("stop")) + "<BR>Strand: " + strand;
                tooltip = tooltip + "<BR><BR>Gene Symbol: " + geneSym + "<BR>Gene ID: " + that.getDisplayID(d.parent.getAttribute("ID")) + "<BR><BR>Other Transcripts:<BR>" + txListStr + "<BR>";
            } else {
                var txList = getAllChildrenByName(getFirstChildByName(d, "TranscriptList"), "Transcript");
                for (var m = 0; m < txList.length; m++) {
                    var id = new String(txList[m].getAttribute("ID"));
                    if (new String(txList[m].getAttribute("ID")).indexOf("ENS") > -1) {
                        txListStr += "<B>" + id + "</B>";
                        txListStr += "<br>";
                    } else {
                        txListStr += "<B>" + id + "</B>";
                        if (new String(txList[m].getAttribute("ID")).indexOf("ENS") === -1) {
                            var annot = getFirstChildByName(getFirstChildByName(txList[m], "annotationList"), "annotation");
                            if (annot != null) {
                                txListStr += " - " + annot.getAttribute("reason");
                            }
                        }
                        txListStr += "<br>";
                    }
                    if (geneSym.length === 0) {
                        var annotList = getAllChildrenByName(getFirstChildByName(txList[m], "annotationList"), "annotation");
                        for (var p = 0; p < annotList.length && geneSym.length === 0; p++) {
                            if (annotList[p].getAttribute("source") === "AKA") {
                                var aka = annotList[p].getAttribute("annot_value");
                                var akaList = new String(aka).split(":");
                                if (new String(akaList[akaList.length - 1]).indexOf("ENS") !== 0) {
                                    geneSym = akaList[akaList.length - 1];
                                } else {
                                    geneSym = akaList[0];
                                }
                            }
                        }
                    }
                }
                tooltip = "<BR><div id=\"ttSVG\" style=\"background:#FFFFFF;overflow:scroll;max-height:400px;\"></div>Gene ID: " + gid + "<BR>Gene Symbol: " + geneSym + "<BR>Location: " + d.getAttribute("chromosome") + ":" + numberWithCommas(d.getAttribute("start")) + "-" + numberWithCommas(d.getAttribute("stop")) + "<BR>Strand: " + strand + "<BR><BR>Transcripts:<BR>" + txListStr + "<BR>";
            }
            if ((that.trackClass === "brainTotal" || that.trackClass === "liverTotal" || that.trackClass === "kidenyTotal") && (d.getAttribute("ID").indexOf("PRN6") > -1 || d.getAttribute("ID").indexOf("PRN6") > -1)) {
                var tmpType = "Gene";
                if (d.getAttribute("ID").indexOf("PRN6T") > -1 || d.getAttribute("ID").indexOf("PRN6.5T") > -1) {
                    tmpType = "Transcript"
                }
                tooltip = tooltip + "<div>Heritability: <span id=\"ttsingleHerit\"></span></div>" + tmpType + " Expression:<BR><div style=\"text-align:center;\">Median Estimated Counts Per Million</div><div id=\"ttChart\"></div>";
                var tmpShortTissue = "Brain";
                var tmpLongTissue = "Whole Brain";
                if (that.trackClass === "liverTotal") {
                    tmpShortTissue = "Liver";
                    tmpLongTissue = "Liver";
                } else if (that.trackClass === "kidneyTotal") {
                    tmpShortTissue = "Kidney";
                    tmpLongTissue = "Kidney";
                }
                tmpChart = chart({
                    "data": "tmpData/browserCache/" + genomeVer + "/regionData/" + that.gsvg.folderName + "/" + tmpShortTissue + "expr.json",
                    "selector": "#ttChart",
                    "allowResize": false,
                    "type": "scatter",
                    "width": "400",
                    "height": "275",
                    "displayHerit": false,
                    "displayControls": false,
                    "title": tmpType + " Expression",
                    "titlePrefix": tmpLongTissue,
                    "filterID": d.getAttribute("ID")
                });

            }
        }
        return tooltip;
    };

    that.redraw = function () {
        that.yMaxArr = new Array();
        that.yArr = new Array();
        that.yArr[0] = new Array();
        for (var p = 0; p < that.gsvg.width; p++) {
            that.yMaxArr[p] = 0;
            that.yArr[0][p] = 0;
        }
        that.trackYMax = 0;
        var tmpMin = that.xScale.domain()[0];
        var tmpMax = that.xScale.domain()[1];
        var len = tmpMax - tmpMin;
        var overrideTrx = 0;

        if (that.reqDataVer !== that.dataVer) {
            that.updateDataVersion(that.reqDataVer, 0);
        } else if (typeof that.prevSetting !== 'undefined' && that.prevSetting.density !== that.density) {
            that.draw(that.data);
        } else if ((len < that.trxCutoff && that.drawnAs === "Gene") || (len >= that.trxCutoff && that.drawnAs === "Trx" && that.drawAs !== "Trx") || (that.drawnAs === "Gene" && $("#forceTrxCBX" + that.gsvg.levelNumber).is(":checked"))) {
            that.draw(that.data);
        } else {
            if (len < that.trxCutoff && that.drawnAs === "Trx" && that.drawAs !== "Trx") {
                overrideTrx = 1;
            }
            if ((that.drawAs === "Gene" && overrideTrx === 0) || that.trackClass.indexOf("smallnc") > -1) {
                if (that.svg) {
                    d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll("g.gene").attr("transform", function (d, i) {
                        var st = that.xScale(d.getAttribute("start"));
                        return "translate(" + st + "," + that.calcY(parseInt(d.getAttribute("start"), 10), parseInt(d.getAttribute("stop"), 10), i) + ")";
                    });
                    d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll("g.gene rect").attr("width", function (d) {
                        var wX = 1;
                        if (that.xScale(d.getAttribute("stop")) - that.xScale(d.getAttribute("start")) > 1) {
                            wX = that.xScale(d.getAttribute("stop")) - that.xScale(d.getAttribute("start"));
                        }
                        return wX;
                    })
                        .attr("stroke", that.colorStroke);
                    d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll("g.gene").each(function (d) {
                        var d3This = d3.select(this);
                        var strand = parseInt(d.getAttribute("strand"), 10);
                        if (strand === -1 || strand === 1) {
                            var strChar = ">";
                            if (strand === -1) {
                                strChar = "<";
                            }
                            var fullChar = "";
                            var rectW = d3This.select("rect").attr("width");
                            if (rectW >= 8.3 && rectW <= 15.8) {
                                fullChar = strChar;
                            } else {
                                while (rectW > 8.5) {
                                    fullChar = fullChar + strChar;
                                    rectW = rectW - 8.5;
                                }
                            }
                            d3This.select("text#strandTxt").text(fullChar);
                        }
                        var dThis = d;
                        if (that.density === 2) {
                            var curLbl = dThis.getAttribute("ID");
                            if (dThis.getAttribute("geneSymbol") && dThis.getAttribute("geneSymbol").length > 0) {
                                curLbl = curLbl + " (" + dThis.getAttribute("geneSymbol") + ")";
                            }
                            if (d3This.select("text#lblTxt").size() === 0) {
                                d3This.append("svg:text").attr("dx", function () {
                                    var xpos = that.xScale(dThis.getAttribute("start"));
                                    if (xpos < ($(window).width() / 2)) {
                                        xpos = that.xScale(dThis.getAttribute("stop")) - that.xScale(dThis.getAttribute("start")) + 5;
                                    } else {
                                        xpos = -1 * curLbl.length * 9;
                                    }
                                    return xpos;
                                })
                                    .attr("dy", 10)
                                    .attr("id", "lblTxt")
                                    .text(curLbl);
                            } else {
                                d3This.select("text#lblTxt").attr("dx", function () {
                                    var xpos = that.xScale(dThis.getAttribute("start"));
                                    if (xpos < ($(window).width() / 2)) {
                                        xpos = that.xScale(dThis.getAttribute("stop")) - that.xScale(dThis.getAttribute("start")) + 5;
                                    } else {
                                        xpos = -1 * curLbl.length * 9;
                                    }
                                    return xpos;
                                });
                            }
                        } else {
                            d3This.select("text#lblTxt").remove();
                        }
                    });
                }
                if (that.density === 1) {
                    that.svg.attr("height", 30);
                } else if (that.density === 2) {
                    //that.svg.attr("height", (d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.gene").size()+1)*15);
                    that.svg.attr("height", (that.trackYMax + 1) * 15);
                } else if (that.density === 3) {
                    that.svg.attr("height", (that.trackYMax + 1) * 15);
                }
            } else if (overrideTrx === 1 || that.drawAs === "Trx") {
                var txG = that.svg.selectAll(".trx" + that.gsvg.levelNumber);
                txG.attr("transform", function (d, i) {
                    return "translate(0," + that.calcY(parseInt(d.getAttribute("start"), 10), parseInt(d.getAttribute("stop"), 10), i) + ")";
                })
                    .each(function (d, i) {
                        var cdsStart = parseInt(d.getAttribute("start"), 10);
                        var cdsStop = parseInt(d.getAttribute("stop"), 10);
                        if (d.getAttribute("cdsStart") && d.getAttribute("cdsStop")) {
                            cdsStart = parseInt(d.getAttribute("cdsStart"), 10);
                            cdsStop = parseInt(d.getAttribute("cdsStop"), 10);
                        }

                        exList = getAllChildrenByName(getFirstChildByName(d, "exonList"), "exon");
                        var pref = "";
                        if (that.gsvg.levelNumber === 1) {
                            pref = "tx";
                        } else if (that.gsvg.levelNumber === 99) {
                            pref = "ttTx";
                        }
                        for (var m = 0; m < exList.length; m++) {
                            var exStrt = exList[m].getAttribute("start");
                            var exStp = exList[m].getAttribute("stop");
                            if ((exStrt < cdsStart && cdsStart < exStp) || (exStp > cdsStop && cdsStop > exStrt)) {
                                var ncStrt = exStrt;
                                var ncStp = cdsStart;
                                if (exStp > cdsStop) {
                                    ncStrt = cdsStop;
                                    ncStp = exStp;
                                    //exStrt=exStrt;
                                    exStp = cdsStop;
                                } else {
                                    exStrt = cdsStart;
                                    //exStp=exStp;
                                }
                                d3.select("#Level" + that.gsvg.levelNumber + that.trackClass + " g#" + pref + that.cleanID(d.getAttribute("ID")) + that.gsvg.levelNumber + " rect#ExNC" + exList[m].getAttribute("ID"))
                                    .attr("x", function (d) {
                                        return that.xScale(ncStrt);
                                    })
                                    .attr("width", function (d) {
                                        return that.xScale(ncStp) - that.xScale(ncStrt);
                                    });
                            }
                            d3.select("#Level" + that.gsvg.levelNumber + that.trackClass + " g#" + pref + that.cleanID(d.getAttribute("ID")) + that.gsvg.levelNumber + " rect#Ex" + exList[m].getAttribute("ID"))
                                .attr("x", function (d) {
                                    return that.xScale(exStrt);
                                })
                                .attr("width", function (d) {
                                    return that.xScale(exStp) - that.xScale(exStrt);
                                });
                            /*d3.select("g#"+pref+d.getAttribute("ID")+" rect#Ex"+exList[m].getAttribute("ID"))
									.attr("x",function(d){ return that.xScale(exList[m].getAttribute("start")); })
									.attr("width",function(d){ return that.xScale(exList[m].getAttribute("stop")) - that.xScale(exList[m].getAttribute("start")); });
								*/
                            if (m > 0) {
                                var strChar = ">";
                                if (d.getAttribute("strand") == "-1") {
                                    strChar = "<";
                                }
                                var fullChar = strChar;
                                var intStart = that.xScale(exList[m - 1].getAttribute("stop"));
                                var intStop = that.xScale(exList[m].getAttribute("start"));
                                var rectW = intStop - intStart;
                                var alt = 0;
                                var charW = 7.0;
                                if (rectW < charW || d.getAttribute("strand") == "0" || d.getAttribute("strand") == ".") {
                                    fullChar = "";
                                } else {
                                    rectW = rectW - charW;
                                    while (rectW > (charW + 1)) {
                                        if (alt === 0) {
                                            fullChar = fullChar + " ";
                                            alt = 1;
                                        } else {
                                            fullChar = fullChar + strChar;
                                            alt = 0;
                                        }
                                        rectW = rectW - charW;
                                    }
                                }
                                d3.select("#Level" + that.gsvg.levelNumber + that.trackClass + " g.trx" + that.gsvg.levelNumber + "#" + pref + that.cleanID(d.getAttribute("ID")) + that.gsvg.levelNumber + " line#Int" + exList[m - 1].getAttribute("ID") + "_" + exList[m].getAttribute("ID"))
                                    .attr("x1", intStart)
                                    .attr("x2", intStop);

                                d3.select("#Level" + that.gsvg.levelNumber + that.trackClass + " g.trx" + that.gsvg.levelNumber + "#" + pref + that.cleanID(d.getAttribute("ID")) + that.gsvg.levelNumber + " #IntTxt" + exList[m - 1].getAttribute("ID") + "_" + exList[m].getAttribute("ID"))
                                    .attr("dx", intStart + 1).text(fullChar);
                            }
                        }
                        var dThis = d;
                        if (that.density === 2) {
                            var curLbl = dThis.getAttribute("ID");
                            if (dThis.getAttribute("geneSymbol") && dThis.getAttribute("geneSymbol").length > 0) {
                                curLbl = curLbl + " (" + dThis.getAttribute("geneSymbol") + ")";
                            }
                            if (d3.select("#Level" + that.gsvg.levelNumber + that.trackClass + " g.trx" + that.gsvg.levelNumber + "#" + pref + that.cleanID(d.getAttribute("ID")) + that.gsvg.levelNumber + " text#lblTxt").size() === 0) {
                                d3.select("#Level" + that.gsvg.levelNumber + that.trackClass + " g.trx" + that.gsvg.levelNumber + "#" + pref + that.cleanID(d.getAttribute("ID")) + that.gsvg.levelNumber).append("svg:text").attr("dx", function () {
                                    var xpos = that.xScale(dThis.parent.getAttribute("start"));
                                    if (xpos < ($(window).width() / 2)) {
                                        xpos = that.xScale(dThis.parent.getAttribute("stop")) - that.xScale(dThis.parent.getAttribute("start")) + 5;
                                    } else {
                                        xpos = -1 * curLbl.length * 9;
                                        ;
                                    }
                                    return xpos;
                                })
                                    .attr("dy", 10)
                                    .attr("id", "lblTxt")
                                    .text(curLbl);
                            } else {
                                d3.select("#Level" + that.gsvg.levelNumber + that.trackClass + " g.trx" + that.gsvg.levelNumber + "#" + pref + that.cleanID(d.getAttribute("ID")) + that.gsvg.levelNumber + " text#lblTxt").attr("dx", function () {
                                    var xpos = that.xScale(dThis.getAttribute("start"));
                                    if (xpos < ($(window).width() / 2)) {
                                        xpos = that.xScale(dThis.getAttribute("stop")) - that.xScale(dThis.getAttribute("start")) + 5;
                                    } else {
                                        xpos = -1 * curLbl.length * 9;
                                    }
                                    return xpos;
                                });
                            }
                        } else {
                            d3.select("#Level" + that.gsvg.levelNumber + that.trackClass + " g.trx" + that.gsvg.levelNumber + "#" + pref + that.cleanID(d.getAttribute("ID")) + that.gsvg.levelNumber + " text#lblTxt").remove();
                        }
                    });
                if (that.density === 1) {
                    that.svg.attr("height", 30);
                } else if (that.density === 2) {
                    //that.svg.attr("height", (d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.trx"+that.gsvg.levelNumber).size()+1)*15);
                    that.svg.attr("height", (that.trackYMax + 1) * 15);
                } else if (that.density === 3) {
                    that.svg.attr("height", (that.trackYMax + 1) * 15);
                }
            }

        }
        that.redrawSelectedArea();
    };

    that.setSelected = function (geneID) {
        if (geneID) {
            if (d3.selectAll("g.gene").size() > 0) {
                //console.log("setup with genes");
                d3.selectAll("rect.selected").each(function () {
                    d3.select(this).attr("class", "").style("fill", that.color);
                });
                var gene = d3.select("g.gene rect#" + geneID);
                if (gene) {
                    gene.attr("class", "selected").style("fill", "green");
                    that.setupDetailedView(gene.data()[0]);
                    selectGene = "";
                }
            } else if (d3.selectAll("g.trx" + that.gsvg.levelNumber).size() > 0) {
                //console.log("setup with transcripts");
                var str = (new String(geneID)).replace(".", "_");
                that.svg.selectAll("g.trx" + that.gsvg.levelNumber + ".selected").selectAll("line").style("stroke", that.color);
                that.svg.selectAll("g.trx" + that.gsvg.levelNumber + ".selected").selectAll("rect").style("fill", that.color);
                that.svg.selectAll("g.trx" + that.gsvg.levelNumber + ".selected").selectAll("text").style("opacity", "0.6").style("fill", that.color);

                that.svg.selectAll("g.trx" + that.gsvg.levelNumber + ".selected").each(function () {
                    var tmpCl = new String($(this).attr("class"));
                    tmpCl = tmpCl.replace(" selected", "");
                    $(this).attr("class", tmpCl);
                });
                that.svg.selectAll("g.gene" + str).each(function () {
                    var tmpCl = $(this).attr("class") + " selected";
                    $(this).attr("class", tmpCl);
                });

                that.svg.selectAll("g.gene" + str).selectAll("line").style("stroke", "green");
                that.svg.selectAll("g.gene" + str).selectAll("rect").style("fill", "green");
                that.svg.selectAll("g.gene" + str).selectAll("text").style("opacity", "0.3").style("fill", "green");
                var tmp;
                if (that.svg.selectAll("g.gene" + str)) {
                    tmp = that.svg.selectAll("g.gene" + str).data();
                    if (tmp && tmp.length > 0) {
                        that.setupDetailedView(tmp[0].parent);
                    } //else {
                    //console.log("tmp[0]");
                    //console.log(tmp);
                    //Rollbar.debug("tmp[0] is undefined.  tmp.length is "+tmp.length+":"+geneID+":"+that.gsvg.levelNumber+":"+that.trackClass);
                    //}
                }

                selectGene = "";
            }
        }
    };

    that.clearSelection = function () {
        that.selectionStart = -1;
        that.selectionEnd = -1;
        that.svg.selectAll("rect.selectedArea").remove();
        if (that.svg.selectAll("g.gene").size() > 0) {
            that.svg.selectAll("rect.selected").each(function (d) {
                d3.select(this).attr("class", "").style("fill", that.color);
            });
        } else if (that.svg.selectAll("g.trx" + that.gsvg.levelNumber).size() > 0) {
            that.svg.selectAll("g.trx" + that.gsvg.levelNumber + ".selected").selectAll("line").style("stroke", that.color);
            that.svg.selectAll("g.trx" + that.gsvg.levelNumber + ".selected").selectAll("rect").style("fill", that.color);
            that.svg.selectAll("g.trx" + that.gsvg.levelNumber + ".selected").selectAll("text").style("opacity", "0.6").style("fill", that.color);
            that.svg.selectAll("g.trx" + that.gsvg.levelNumber + ".selected").each(function () {
                var tmpCl = new String($(this).attr("class"));
                tmpCl = tmpCl.replace(" selected", "");
                $(this).attr("class", tmpCl);
            });
        }
    };

    that.setupDetailedView = function (d) {
        if (d) {
            that.gsvg.clearSelection();
            var e = jQuery.Event("keyup");
            e.which = 32; // # Some key code value
            var newLevel = that.gsvg.levelNumber + 1;
            if (!$('div#collapsableReport').is(':hidden')) {
                $('div#collapsableReport').hide();
                $("span[name='collapsableReport']").removeClass("less");
            }
            if ($('div#selectedDetailHeader').is(':hidden')) {
                $('div#selectedDetailHeader').show();
            }
            if ($('div#selectedDetail').is(':hidden')) {
                $('div#selectedDetail').show();
            }
            var localTxType = "none";
            if (that.trackClass.indexOf("brainTotal") === 0 || that.trackClass.indexOf("liverTotal") === 0 || that.trackClass === "heartTotal" || that.trackClass === "mergedTotal") {
                localTxType = that.trackClass;
            } else if (d.getAttribute("biotype") === "protein_coding" && (d.getAttribute("stop") - d.getAttribute("start")) >= 200) {
                localTxType = "protein";
            } else if (d.getAttribute("biotype") !== "protein_coding" && (d.getAttribute("stop") - d.getAttribute("start")) >= 200) {
                localTxType = "long";
            } else if ((d.getAttribute("stop") - d.getAttribute("start")) < 200) {
                localTxType = "small";
            }
            var newMin = 0;
            var newMax = 0;
            if (localTxType === "protein" || localTxType === "long" || localTxType.indexOf("liverTotal") === 0 || localTxType === "heartTotal" || localTxType.indexOf("brainTotal") === 0 || localTxType === "mergedTotal" || localTxType === "kidneyTotal" || (localTxType === "small" && genomeVer !== "rn5") || (localTxType === "small" && new String(d.getAttribute("ID")).indexOf("ENS") > -1)) {
                //console.log("totalType");
                var displayID = d.getAttribute("ID");
                var akaENS = "";
                var akaGenSym = "";
                if (d.getAttribute("geneSymbol") && d.getAttribute("geneSymbol").length > 0) {
                    displayID = displayID + " (" + d.getAttribute("geneSymbol") + ")";
                } else {
                    var txList = getAllChildrenByName(getFirstChildByName(d, "TranscriptList"), "Transcript");
                    for (var m = 0; m < txList.length && akaENS === ""; m++) {
                        if (akaENS === "") {
                            var annotList = getAllChildrenByName(getFirstChildByName(txList[m], "annotationList"), "annotation");
                            for (var p = 0; p < annotList.length && akaENS.length === 0; p++) {
                                if (annotList[p].getAttribute("source") === "AKA") {
                                    var aka = annotList[p].getAttribute("annot_value");
                                    var akaList = new String(aka).split(":");
                                    if (akaList.length >= 1) {
                                        akaENS = akaList[0];
                                        displayID = displayID + " (" + akaENS + ")";
                                    } else if (akaList.length >= 2) {
                                        akaENS = akaList[0];
                                        akaGenSym = akaList[1];
                                        displayID = displayID + " (" + akaGenSym + ")";
                                    }
                                }
                            }
                        }
                    }
                }
                var min = parseInt(d.getAttribute("start"), 10);
                var max = parseInt(d.getAttribute("stop"), 10);
                if (d.getAttribute("extStart") && d.getAttribute("extStop")) {
                    min = parseInt(d.getAttribute("extStart"), 10);
                    max = parseInt(d.getAttribute("extStop"), 10);
                }

                if (!svgViewIDList[newLevel]) {
                    if (that.gsvg.currentView) {
                        svgViewIDList[newLevel] = that.gsvg.currentView.ViewID;
                    } else {
                        svgViewIDList[newLevel] = defaultView;
                        //Rollbar.debug("that.gsvg.currentView is undefined");
                    }
                }
                var newSvg = GenomeSVG("div#selectedImage", that.gsvg.width, min, max, newLevel, displayID, "transcript");
                newSvg.xMin = min - (max - min) * 0.05;
                newSvg.xMax = max + (max - min) * 0.05;
                newMin = newSvg.xMin;
                newMax = newSvg.xMax;
                svgList[newLevel] = newSvg;
                svgList[newLevel].txType = localTxType;
                svgList[newLevel].selectedData = d;
                //svgList[newLevel].addTrack("trx",2,"",0);

                //viewMenu[newLevel].applySelectedView(tmpViewID);

                //loadStateFromString(that.gsvg.generateSettingsString(),"",newLevel,newSvg);
                //loadState(newLevel);

                selectedGeneSymbol = d.getAttribute("geneSymbol");
                that.gsvg.selectedGeneSymbol = d.getAttribute("geneSymbol");
                selectedID = new String(d.getAttribute("ID"));
                if (selectedID.indexOf("ENS") === -1) {
                    if (akaENS.length > 0) {
                        selectedID = akaENS;
                    }
                }
                $('div#selectedImage').show();
                //console.log("here");
                if ((new String(selectedID)).indexOf("ENS") > -1 && that.trackClass.indexOf("ensembl") > -1) {
                    //console.log("geneReport");
                    $('div#selectedReport').show();
                    var jspPage = pathPrefix + "geneReport.jsp";
                    var params = {
                        id: selectedID,
                        geneSymbol: selectedGeneSymbol,
                        chromosome: chr,
                        species: organism,
                        genomeVer: genomeVer,
                        dataVer: dataVer
                    };
                    DisplaySelectedDetailReport(jspPage, params);
                } else {
                    if (localTxType !== "small") {
                        $('div#selectedReport').html("<BR><BR>Detailed Gene Reports are not currently provided for RNA-Seq(Cufflinks) generated genes that are novel and have not been matched to an existing annotated gene.  In the future overlapping probesets and SNPs will be summarized in the same manner.  This feature should be added by December 2014.  Please keep checking back or let us know you'd like to see it sooner.");
                    } else {
                        if (genomeVer === "rn6") {
                            var path = dataPrefix + "tmpData/browserCache/" + genomeVer + "/regionData/" + that.gsvg.folderName + "/" + that.trackClass + ".xml";
                            var jspPage = pathPrefix + "smallRNAReport.jsp";
                            var params = {dataPath: path, id: selectedID};
                            DisplaySelectedDetailReport(jspPage, params);
                        }
                    }

                }
            } else if (localTxType === "small") {
                if (new String(d.getAttribute("ID")).indexOf("ENS") === -1 && genomeVer === "rn5") {
                    $('div#selectedImage').hide();
                    $('div#selectedReport').show();
                    newMin = d.getAttribute("start");
                    newMax = d.getAttribute("stop");
                    //Add SVG graphic later
                    //For now processing.js graphic is in jsp page of the detail report
                    var jspPage = pathPrefix + "viewSmallNonCoding.jsp";
                    var params = {id: d.getAttribute("ID"), name: "smRNA_" + d.getAttribute("ID")};
                    DisplaySelectedDetailReport(jspPage, params);
                } else {
                    //FILL IN to allow selecting miRNA.

                }
            }
            if (that.gsvg && that.gsvg.selectSvg) {
                that.gsvg.selectSvg.changeSelection(newMin, newMax);
            }
            $('html, body').animate({
                scrollTop: $('#selectedDetail').offset().top
            }, 200);
        }
    };

    that.getDisplayedData = function () {
        var dispData = new Array();
        var dispDataCount = 0;
        var dataElem = [];
        if (that.trackClass.indexOf("smallnc") > -1) {
            var countsInd = 0;
            that.counts = new Array();
            if (that.trackClass.indexOf("ensembl") > -1) {
                if (that.drawnAs === "Gene") {
                    dataElem = d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll("g.gene");
                } else if (that.drawnAs === "Trx") {
                    dataElem = d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll("g.trx");
                }
            } else {
                if (that.drawnAs === "Gene") {
                    dataElem = d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll("g.gene");
                } else if (that.drawnAs === "Trx") {
                    dataElem = d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll("g.trx");
                }
            }
            if (dataElem.each) {
                dataElem.each(function (d) {
                    var start = that.xScale(d.getAttribute("start"));
                    var stop = that.xScale(d.getAttribute("stop"));
                    if ((0 <= start && start <= that.gsvg.width) || (0 <= stop && stop <= that.gsvg.width) || (start <= 0 && stop >= that.gsvg.width)) {
                        //var nameStr=new String(tmpDat[l].__data__.getAttribute("name"));
                        var name = "Ensembl";
                        if (typeof d.getAttribute("strain") !== 'undefined') {
                            name = d.getAttribute("strain");
                        } else if (typeof d.getAttribute("biotype") !== "undefined") {
                            name = d.getAttribute("biotype");
                        }
                        if (typeof that.counts[name] === 'undefined') {
                            that.counts[name] = new Object();
                            that.counts[countsInd] = that.counts[name];
                            countsInd++;
                            that.counts[name].value = 1;
                            that.counts[name].names = name;
                        } else {
                            that.counts[name].value++;
                        }
                        dispData[dispDataCount] = d;
                        dispDataCount++;
                        total++;
                    }
                });
            }
        } else if (that.drawnAs === "Gene") {
            var dataElem = d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll("g.gene");
            that.counts = [{value: 0, names: "Ensembl"}, {value: 0, names: "Brain RNA-Seq"}, {
                value: 0,
                names: "Liver RNA-Seq"
            }, {
                value: 0,
                names: "Heart RNA-Seq"
            }, {value: 0, names: "Merged RNA-Seq"}];
            //console.log(dataElem);
            dataElem.each(function (d) {
                var start = that.xScale(d.getAttribute("start"));
                var stop = that.xScale(d.getAttribute("stop"));
                //console.log("start:"+start+":"+stop);
                if ((0 <= start && start <= that.gsvg.width) || (0 <= stop && stop <= that.gsvg.width)) {
                    if ((new String(d.childNodes[0].id)).indexOf("ENS") > -1) {
                        that.counts[0].value++;
                    } else {
                        if (that.trackClass.indexOf("brain") > -1) {
                            that.counts[1].value++;
                        } else if (that.trackClass.indexOf("liver") > -1) {
                            that.counts[2].value++;
                        } else if (that.trackClass.indexOf("heart") > -1) {
                            that.counts[3].value++;
                        } else if (that.trackClass.indexOf("merged") > -1) {
                            that.counts[4].value++;
                        }
                    }
                    dispData[dispDataCount] = d;
                    dispDataCount++;
                }
            });
            if (dataElem.size() === 0) {
                that.counts = [];
            }
        } else if (that.drawnAs === "Trx") {
            var trxList = d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll("g.trx" + that.gsvg.levelNumber);
            that.counts = new Array();
            var countsInd = 0;
            var total = 0;
            trxList.each(function (d) {
                var start = that.xScale(d.getAttribute("start"));
                var stop = that.xScale(d.getAttribute("stop"));
                if ((0 <= start && start <= that.gsvg.width) || (0 <= stop && stop <= that.gsvg.width) || (start <= 0 && stop >= that.gsvg.width)) {
                    //var nameStr=new String(tmpDat[l].__data__.getAttribute("name"));
                    var name = "Ensembl";
                    if (typeof d.getAttribute("strain") !== 'undefined') {
                        name = d.getAttribute("strain");
                    }
                    if (typeof that.counts[name] === 'undefined') {
                        that.counts[name] = new Object();
                        that.counts[countsInd] = that.counts[name];
                        countsInd++;
                        that.counts[name].value = 1;
                        that.counts[name].names = name;
                    } else {
                        that.counts[name].value++;
                    }
                    dispData[dispDataCount] = d;
                    dispDataCount++;
                    total++;
                }
            });
        }
        return dispData;
    };

    that.updateData = function (retry) {
        var tag = "Gene";
        var path = dataPrefix + "tmpData/browserCache/" + genomeVer + "/regionData/" + that.gsvg.folderName + "/" + that.trackClass + ".xml";
        if (that.trackClass.indexOf("heartTotal") === 0 || that.trackClass.indexOf("liverTotal") === 0 || that.trackClass.indexOf("brainTotal") === 0 || that.trackClass.indexOf("kidneyTotal") === 0 || that.trackClass === 'mergedTotal' || that.trackClass.indexOf("brainIso") === 0 || that.trackClass.indexOf("liverIso") === 0) {
            path = dataPrefix + "tmpData/browserCache/" + genomeVer + "/regionData/" + that.gsvg.folderName + "/" + dataVer + "_" + that.trackClass + ".xml";
        }

        d3.xml(path, function (error, d) {
            if (error) {
                if (retry === 0 && (that.trackClass.indexOf("heartTotal") === 0 || that.trackClass.indexOf("liverTotal") === 0 || that.trackClass.indexOf("brainTotal") === 0 || that.trackClass.indexOf("kidneyTotal") === 0 || that.trackClass === 'mergedTotal' || that.trackClass.indexOf("smallnc") > -1 || that.trackClass.indexOf("brainIso") === 0 || that.trackClass.indexOf("liverIso") === 0)) {
                    var tmpContext = "/" + pathPrefix;
                    if (!pathPrefix) {
                        tmpContext = "";
                    }
                    var file = that.trackClass;
                    var curPanel = panel;
                    if ((that.trackClass.indexOf("liverTotal") === 0 || that.trackClass.indexOf("brainTotal") === 0) && that.trackClass.indexOf("_") > 0) {
                        curPanel = track.substr(track.indexOf("_") + 1);
                        if (curPanel === "LEStm") {
                            curPanel = "LE-Stm";
                        }
                        if (curPanel === "F344Stm") {
                            curPanel = "F344-Stm";
                        }
                    } else if (that.trackClass.indexOf("brainIso") === 0 || that.trackClass.indexOf("liverIso") === 0) {
                        curPanel = "IsoSeq";
                    }
                    $.ajax({
                        url: tmpContext + "generateTrackXML.jsp",
                        type: 'GET',
                        cache: false,
                        asyn: true,
                        data: {
                            chromosome: chr,
                            minCoord: that.gsvg.xScale.domain()[0],
                            maxCoord: that.gsvg.xScale.domain()[1],
                            panel: curPanel,
                            rnaDatasetID: rnaDatasetID,
                            arrayTypeID: arrayTypeID,
                            myOrganism: organism,
                            genomeVer: genomeVer,
                            dataVer: dataVer,
                            track: file,
                            folder: that.gsvg.folderName
                        },
                        dataType: 'json',
                        success: function (data2) {
                            /*if(ga){
										ga('send','event','browser','generateTrackGene');
									}*/
                            gtag('event', 'generateTrackGene', {'event_category': 'browser'});
                        },
                        error: function (xhr, status, error) {

                        }
                    });
                }
                if (retry < 10) {//wait before trying again
                    var time = 2000;
                    if (retry === 1) {
                        time = 5000;
                    }
                    setTimeout(function () {
                        that.updateData(retry + 1);
                    }, time);
                } else {
                    d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).select("#trkLbl").text("An errror occurred loading Track:" + that.trackClass);
                    d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).attr("height", 15);
                    that.gsvg.addTrackErrorRemove(that.svg, "#Level" + that.gsvg.levelNumber + that.trackClass);
                }
            } else if (d) {
                var data = d.documentElement.getElementsByTagName(tag);
                var mergeddata = new Array();
                var checkName = new Array();
                var curInd = 0;
                for (var l = 0; l < data.length; l++) {
                    if (data[l]) {
                        mergeddata[curInd] = data[l];
                        checkName[data[l].getAttribute("ID")] = 1;
                        curInd++;
                    }
                }
                for (var l = 0; l < that.data.length; l++) {
                    if (that.data[l] && !checkName[that.data[l].getAttribute("ID")]) {
                        mergeddata[curInd] = that.data[l];
                        curInd++;
                    }
                }
                that.draw(mergeddata);
                that.hideLoading();
                setTimeout(function () {
                    DisplayRegionReport();
                }, 300);
            } else {
                that.hideLoading();
            }
        });
    };

    that.updateDataVersion = function (ver, retry) {
        var tag = "Gene";
        var file = that.trackClass + "_" + ver;
        if (that.trackClass.indexOf("heartTotal") === 0 || that.trackClass.indexOf("liverTotal") === 0 || that.trackClass.indexOf("brainTotal") === 0 || that.trackClass.indexOf("kidneyTotal") === 0 || that.trackClass === 'mergedTotal' || that.trackClass.indexOf("brainIso") === 0 || that.trackClass.indexOf("liverIso") === 0) {
            file = dataVer + "_" + that.trackClass + ".xml";
        }
        var path = dataPrefix + "tmpData/browserCache/" + genomeVer + "/regionData/" + that.gsvg.folderName + "/" + file + ".xml";
        d3.xml(path, function (error, d) {
            if (error) {
                if (retry === 0) {
                    var tmpContext = "/" + pathPrefix;
                    if (!pathPrefix) {
                        tmpContext = "";
                    }
                    var curPanel = panel;
                    if ((track.indexOf("liverTotal") === 0 || track.indexOf("brainTotal") === 0) && track.indexOf("_") > 0) {
                        curPanel = track.substr(track.indexOf("_") + 1);
                        if (curPanel === "LEStm") {
                            curPanel = "LE-Stm";
                        }
                        if (curPanel === "F344Stm") {
                            curPanel = "F344-Stm";
                        }
                    }
                    $.ajax({
                        url: tmpContext + "generateTrackXML.jsp",
                        type: 'GET',
                        cache: false,
                        async: true,
                        data: {
                            chromosome: chr,
                            minCoord: that.gsvg.xScale.domain()[0],
                            maxCoord: that.gsvg.xScale.domain()[1],
                            panel: curPanel,
                            rnaDatasetID: rnaDatasetID,
                            arrayTypeID: arrayTypeID,
                            myOrganism: organism,
                            genomeVer: genomeVer,
                            dataVer: dataVer,
                            track: file,
                            folder: that.gsvg.folderName
                        },
                        dataType: 'json',
                        success: function (data2) {
                            /*if(ga){
										ga('send','event','browser','generateTrackGene');
									}*/
                            gtag('event', 'generateTrackGene', {'event_category': 'browser'});
                        },
                        error: function (xhr, status, error) {

                        }
                    });
                }
                if (retry < 5) {//wait before trying again
                    var time = 10000;
                    if (retry === 0) {
                        time = 5000;
                    }
                    setTimeout(function () {
                        that.updateDataVersion(ver, retry + 1);
                    }, time);
                } else {
                    d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).select("#trkLbl").text("An errror occurred loading Track:" + that.trackClass);
                    d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).attr("height", 15);
                    that.gsvg.addTrackErrorRemove(that.svg, "#Level" + that.gsvg.levelNumber + that.trackClass);
                }
            } else {
                var data = d.documentElement.getElementsByTagName(tag);
                var version = parseInt(ver);
                /*var glElem=d.documentElement.getElementsByTagName("GeneList");
                if(glElem.length>0 && typeof glElem[0].getAttribute("ver") !=='undefined'){
                        ver=parseInt(glElem[0].getAttribute("ver"));
                }*/
                that.dataVer = version;
                that.draw(data);
                that.hideLoading();
                setTimeout(function () {
                    DisplayRegionReport();
                }, 300);
            }
        });
    };

    that.drawTrx = function (d, i) {
        //console.log("drawTrx"+d.getAttribute("ID"));
        var cdsStart = parseInt(d.getAttribute("start"), 10);
        var cdsStop = parseInt(d.getAttribute("stop"), 10);
        if (d.getAttribute("cdsStart") && d.getAttribute("cdsStop")) {
            cdsStart = parseInt(d.getAttribute("cdsStart"), 10);
            cdsStop = parseInt(d.getAttribute("cdsStop"), 10);
        }
        var pref = "";
        if (that.gsvg.levelNumber === 1) {
            pref = "tx";
        } else if (that.gsvg.levelNumber === 99) {
            pref = "ttTx";
        }
        //var txG=d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).select("#"+pref+d.getAttribute("ID"));
        var txG = d3.select("#Level" + that.gsvg.levelNumber + that.trackClass + " #" + pref + that.cleanID(d.getAttribute("ID")) + that.gsvg.levelNumber);
        exList = getAllChildrenByName(getFirstChildByName(d, "exonList"), "exon");
        for (var m = 0; m < exList.length; m++) {
            var exStrt = parseInt(exList[m].getAttribute("start"), 10);
            var exStp = parseInt(exList[m].getAttribute("stop"), 10);
            if ((exStrt < cdsStart && cdsStart < exStp) || (exStp > cdsStop && cdsStop > exStrt)) {//need to draw two rect one for CDS and one non CDS
                var xPos1 = 0;
                var xWidth1 = 0;
                var xPos2 = 0;
                var xWidth2 = 0;
                //console.log("exStrt:"+exStrt+" exStop:"+exStp);
                //console.log("cds:"+cdsStart+" "+cdsStop);
                if (exStrt < cdsStart) {
                    //console.log("first");
                    xPos1 = that.xScale(exStrt);
                    xWidth1 = that.xScale(cdsStart) - that.xScale(exStrt);
                    xPos2 = that.xScale(cdsStart);
                    xWidth2 = that.xScale(exStp) - that.xScale(cdsStart);
                } else if (exStp > cdsStop) {
                    //console.log("second");
                    xPos2 = that.xScale(exStrt);
                    xWidth2 = that.xScale(cdsStop) - that.xScale(exStrt);
                    xPos1 = that.xScale(cdsStop);
                    xWidth1 = that.xScale(exStp) - that.xScale(cdsStop);
                    //console.log("exStop:"+that.xScale(exStp));
                    //console.log("cdsStop:"+that.xScale(cdsStop));
                }

                //console.log("w1:"+xWidth1+" w2:"+xWidth2);
                txG.append("rect")//non CDS
                    .attr("x", xPos1)
                    .attr("y", 2.5)
                    //.attr("x",function(d){ return that.xScale(exList[m].getAttribute("start")); })
                    //.attr("rx",1)
                    //.attr("ry",1)
                    .attr("height", 5)
                    .attr("width", xWidth1)
                    //.attr("width",function(d){ return that.xScale(exList[m].getAttribute("stop")) - that.xScale(exList[m].getAttribute("start")); })
                    .attr("title", function (d) {
                        return exList[m].getAttribute("ID");
                    })
                    .attr("id", function (d) {
                        return "ExNC" + exList[m].getAttribute("ID");
                    })
                    //.attr("class",function(d){})
                    .style("fill", that.color)
                    .style("cursor", "pointer");
                txG.append("rect")//CDS
                    .attr("x", xPos2)
                    //.attr("x",function(d){ return that.xScale(exList[m].getAttribute("start")); })
                    //.attr("rx",1)
                    //.attr("ry",1)
                    .attr("height", 10)
                    .attr("width", xWidth2)
                    //.attr("width",function(d){ return that.xScale(exList[m].getAttribute("stop")) - that.xScale(exList[m].getAttribute("start")); })
                    .attr("title", function (d) {
                        return exList[m].getAttribute("ID");
                    })
                    .attr("id", function (d) {
                        return "Ex" + exList[m].getAttribute("ID");
                    })
                    .style("fill", that.color)
                    .style("cursor", "pointer");

            } else {
                var height = 10;
                var y = 0;
                if ((exStrt < cdsStart && exStp < cdsStart) || (exStp > cdsStop && exStrt > cdsStop)) {
                    height = 5;
                    y = 2.5;
                }
                txG.append("rect")
                    .attr("x", function (d) {
                        return that.xScale(exList[m].getAttribute("start"));
                    })
                    .attr("y", y)
                    //.attr("rx",1)
                    //.attr("ry",1)
                    .attr("id", function (d) {
                        //console.log("Ex"+exList[m].getAttribute("ID"));
                        return "Ex" + exList[m].getAttribute("ID");
                    })
                    .attr("height", height)
                    .attr("width", function (d) {
                        var tmp = that.xScale(exList[m].getAttribute("stop")) - that.xScale(exList[m].getAttribute("start"));
                        return tmp;
                    })
                    .attr("title", function (d) {
                        return exList[m].getAttribute("ID");
                    })
                    .style("fill", that.color)
                    .style("cursor", "pointer");
            }
            if (m > 0) {
                txG.append("line")
                    .attr("x1", function (d) {
                        return that.xScale(exList[m - 1].getAttribute("stop"));
                    })
                    .attr("x2", function (d) {
                        return that.xScale(exList[m].getAttribute("start"));
                    })
                    .attr("y1", 5)
                    .attr("y2", 5)
                    .attr("id", function (d) {
                        return "Int" + exList[m - 1].getAttribute("ID") + "_" + exList[m].getAttribute("ID");
                    })
                    .attr("stroke", that.color)
                    .attr("stroke-width", "2");
                if (d.getAttribute("strand") == "1" || d.getAttribute("strand") == "-1") {
                    var strChar = ">";
                    if (d.getAttribute("strand") == "-1" || d.getAttribute("strand") == "-") {
                        strChar = "<";
                    }
                    var fullChar = strChar;
                    var intStart = that.xScale(exList[m - 1].getAttribute("stop"));
                    var intStop = that.xScale(exList[m].getAttribute("start"));
                    var rectW = intStop - intStart;
                    var alt = 0;
                    var charW = 7.0;
                    if (rectW < charW) {
                        fullChar = "";
                    } else {
                        rectW = rectW - charW;
                        while (rectW > (charW + 1)) {
                            if (alt == 0) {
                                fullChar = fullChar + " ";
                                alt = 1;
                            } else {
                                fullChar = fullChar + strChar;
                                alt = 0;
                            }
                            rectW = rectW - charW;
                        }
                    }
                    txG.append("svg:text").attr("id", function (d) {
                        return "IntTxt" + exList[m - 1].getAttribute("ID") + "_" + exList[m].getAttribute("ID");
                    }).attr("dx", intStart + 1)
                        .attr("dy", "11")
                        .style("pointer-events", "none")
                        .style("opacity", "0.5")
                        .style("fill", that.color)
                        .style("font-size", "16px")
                        .text(fullChar);
                }

            }
        }
        var dThis = d;
        if (that.density == 2) {
            var curLbl = dThis.getAttribute("ID");
            if (typeof dThis.getAttribute("geneSymbol") !== 'undefined' && dThis.getAttribute("geneSymbol").length > 0) {
                curLbl = curLbl + " (" + dThis.getAttribute("geneSymbol") + ")";
            }
            txG.append("svg:text").attr("dx", function () {
                var xpos = that.xScale(dThis.getAttribute("start"));
                if (xpos < ($(window).width() / 2)) {
                    xpos = that.xScale(dThis.getAttribute("stop")) - that.xScale(dThis.getAttribute("start")) + 5;
                } else {
                    xpos = -1 * curLbl.length * 9;
                    ;
                }
                return xpos;
            })
                .attr("dy", 10)
                .attr("id", "lblTxt")
                .text(curLbl);
        } else {
            txG.select("text#lblTxt").remove();
        }
    };

    that.getSVGID = function (d) {
        return that.getDisplayID(d.getAttribute("ID")) + " (" + d.getAttribute("geneSymbol") + ")";
    };

    that.setupToolTipSVG = function (d, perc) {
        //console.log("setupToolTipSVG:GeneTrack");
        var tmpMin = 0;
        var tmpMax = 0;
        if (typeof d.getAttribute("extStart") !== 'undefined' && d.getAttribute("extStart") !== null) {

            tmpMin = parseInt(d.getAttribute("extStart"), 10);
            tmpMax = parseInt(d.getAttribute("extStop"), 10);
        } else {
            tmpMin = parseInt(d.getAttribute("start"), 10);
            tmpMax = parseInt(d.getAttribute("stop"), 10);
        }
        var margin = Math.floor((tmpMax - tmpMin) * perc);
        if (margin < 10) {
            margin = 10;
        }
        tmpMin = tmpMin - margin;
        tmpMax = tmpMax + margin;
        var newSvg = toolTipSVG("div#ttSVG", 450, tmpMin, tmpMax, 99, that.getSVGID(d), "transcript");
        newSvg.xMin = tmpMin;
        newSvg.xMax = tmpMax;
        var localTxType = "none";
        if (that.trackClass.indexOf("brainTotal") === 0 || that.trackClass.indexOf("liverTotal") === 0 || that.trackClass.indexOf("kidneyTotal") === 0 || that.trackClass === "heartTotal" || that.trackClass == "mergedTotal") {
            localTxType = that.trackClass;
        } else if ((parseInt(d.getAttribute("stop"), 10) - parseInt(d.getAttribute("start"), 10)) < 200) {
            localTxType = "small";
        } else if (d.getAttribute("biotype") == "protein_coding" && (parseInt(d.getAttribute("stop"), 10) - parseInt(d.getAttribute("start"), 10)) >= 200) {
            localTxType = "protein";
        } else if (d.getAttribute("biotype") != "protein_coding" && (parseInt(d.getAttribute("stop"), 10) - parseInt(d.getAttribute("start"), 10)) >= 200) {
            localTxType = "long";
        }
        newSvg.txType = localTxType;
        newSvg.selectedData = d;
        var dataArr = new Array();
        dataArr[0] = d;
        if (typeof d.parent !== 'undefined') {
            dataArr[0] = d.parent;
        }
        newSvg.addTrack(that.trackClass, 2, "DrawTrx", dataArr);
        //Setup Other tracks included in the track type(listed in that.ttTrackList)
        for (var r = 0; r < that.ttTrackList.length; r++) {
            if (that.trackClass !== that.ttTrackList[r]) {
                var tData = that.gsvg.getTrackData(that.ttTrackList[r]);
                var fData = new Array();
                if (typeof tData !== 'undefined' && tData.length > 0) {
                    var fCount = 0;
                    for (var s = 0; s < tData.length; s++) {
                        if ((tmpMin <= (parseInt(tData[s].getAttribute("start"), 10)) && parseInt(tData[s].getAttribute("start"), 10) <= tmpMax) || (tmpMin <= parseInt(tData[s].getAttribute("stop"), 10) && parseInt(tData[s].getAttribute("stop"), 10) <= tmpMax)
                            || (parseInt(tData[s].getAttribute("start"), 10) <= tmpMin && parseInt(tData[s].getAttribute("stop"), 10) >= tmpMin)

                            //|| (newSvg.xMin<=tData[s].getAttribute("stop")&&tData[s].getAttribute("stop")<=newSvg.xMax)
                            //|| (tData[s].getAttribute("start")<=newSvg.xMin&&newSvg.xMax<=tData[s].getAttribute("stop"))
                        ) {
                            fData[fCount] = tData[s];
                            fCount++;
                        }
                    }
                    if (fData.length > 0) {
                        newSvg.addTrack(that.ttTrackList[r], 3, "DrawTrx", fData);
                    }
                }
            }

        }

    };

    that.draw = function (data) {
        that.data = data;
        that.trackYMax = 0;
        that.yMaxArr = new Array();
        that.yArr = new Array();
        that.yArr[0] = new Array();
        for (var j = 0; j < that.gsvg.width; j++) {
            that.yMaxArr[j] = 0;
            that.yArr[0][j] = 0;
        }
        that.svg.selectAll(".gene").remove();
        var prevDrawAs = that.drawAs;
        var tmpMin = that.xScale.domain()[0];
        var tmpMax = that.xScale.domain()[1];
        var len = tmpMax - tmpMin;
        if (len < that.trxCutoff || $("#forceTrxCBX" + that.gsvg.levelNumber).is(":checked")) {
            that.drawAs = "Trx";
        }
        var type = "Genes";
        if (that.drawAs == "Trx") {
            type = "Transcripts";
        }
        var lbl = "Protein Coding";
        var lbltxSuffix = " / PolyA+";
        if (that.trackClass.indexOf("noncoding") > -1) {
            lbl = "Long Non-Coding";
            lbltxSuffix = " / Non-PolyA+"
        } else if (that.trackClass.indexOf("smallnc") > -1) {
            var lblTissue = "Brain";
            if (that.trackClass.indexOf("liver") > -1) {
                lblTissue = "Liver";
            } else if (that.trackClass.indexOf("heart") > -1) {
                lblTissue = "Heart";
            }
            lbl = lblTissue + " Small RNA";
            lbltxSuffix = "";
        } else if (that.trackClass.indexOf("liverTotal") === 0) {
            lbl = "Liver RNA-Seq  ";
            lbltxSuffix = "Total RNA";
        } else if (that.trackClass == "heartTotal") {
            lbl = "Heart RNA-Seq Reconstruction ";
            lbltxSuffix = "Total RNA";
        } else if (that.trackClass.indexOf("brainTotal") === 0) {
            lbl = "Whole Brain RNA-Seq Reconstruction ";
            lbltxSuffix = "Total RNA";
        } else if (that.trackClass.indexOf("kidneyTotal") === 0) {
            lbl = "Kidney RNA-Seq Reconstruction ";
            lbltxSuffix = "Total RNA";
        } else if (that.trackClass == "mergedTotal") {
            lbl = "Merged (Brain,Heart,Liver,Kidney) Reconstructed";
            lbltxSuffix = "Total RNA";
        } else if (that.trackClass == "brainIso") {
            lbl = "Whole Brain";
            lbltxSuffix = "Iso-Seq";
        } else if (that.trackClass == "liverIso") {
            lbl = "Liver";
            lbltxSuffix = "Iso-Seq";
        }
        if (that.trackClass.indexOf("ensembl") > -1) {
            lbl = "Ensembl " + lbl + " " + type;
        } else if (that.trackClass.indexOf("brainTotal") === -1 && that.trackClass.indexOf("liverTotal") === -1 && that.trackClass != "heartTotal" && that.trackClass != "mergedTotal" && that.trackClass.indexOf("kidenyTotal") === -1 && that.trackClass.indexOf("Iso") === -1) {
            lbl = "Reconstruction " + lbl + lbltxSuffix + " " + type;
        } else if (that.trackClass.indexOf("Iso") > -1) {
            lbl = lbl + " " + lbltxSuffix;
        } else {
            lbl = lbl + lbltxSuffix + " " + type;
        }
        if ((that.trackClass.indexOf("liverTotal") === 0 || that.trackClass.indexOf("brainTotal") === 0) && that.trackClass.indexOf("_") > 0) {
            var strain = that.trackClass.substr(that.trackClass.indexOf("_") + 1);
            if (strain === "LEStm") {
                strain = "LE-Stm";
            }
            if (strain === "F344Stm") {
                strain = "F344-Stm";
            }
            lbl = strain + " Filtered (>=1.0TPM) " + lbl;
        }
        that.updateLabel(lbl);
        that.redrawLegend();
        var filterData = data;

        if (that.drawAs === "Trx" && that.trackClass.indexOf("smallnc") === -1) {
            filterData = [];
            var newCount = 0;
            for (var l = 0; l < data.length; l++) {
                if (typeof data[l] !== 'undefined') {
                    /*if(that.gsvg.levelNumber!=1
                                        || (that.gsvg.levelNumber==1 && that.gsvg.selectedData!=undefined  && data[l].getAttribute("ID")!=that.gsvg.selectedData.getAttribute("ID") )
                                        ){*/
                    var tmpTxList = getAllChildrenByName(getFirstChildByName(data[l], "TranscriptList"), "Transcript");
                    for (var k = 0; k < tmpTxList.length; k++) {
                        filterData[newCount] = tmpTxList[k];
                        filterData[newCount].parent = data[l];
                        newCount++;
                    }
                    //}
                }
            }
        }

        //console.log("track:"+that.trackClass);
        //console.log(that.drawAs);
        if (filterData.length > 0) {
            if (that.drawAs === "Gene" || that.trackClass.indexOf("smallnc") > -1) {
                //console.log(that.trackClass);
                //console.log(filterData);
                that.drawnAs = "Gene";
                that.svg.selectAll(".trx0").each(function () {
                    d3.select(this).remove();
                });
                //console.log("selectAll(.gene)");
                //console.log(that.svg.selectAll(".gene"));
                //console.log(that.svg.selectAll(".gene").data(filterData,key));
                var gene = that.svg.selectAll(".gene")
                    .data(filterData, key)
                    .attr("transform", function (d, i) {
                        return "translate(" + that.xScale(d.getAttribute("start")) + "," + that.calcY(parseInt(d.getAttribute("start"), 10), parseInt(d.getAttribute("stop"), 10), i) + ")";
                    });
                //gene.exit().remove();
                //add new
                gene.enter().append("g")
                    .attr("class", "gene")
                    .attr("transform", function (d, i) {
                        return "translate(" + that.xScale(d.getAttribute("start")) + "," + that.calcY(parseInt(d.getAttribute("start"), 10), parseInt(d.getAttribute("stop"), 10), i) + ")";
                    })
                    .merge(gene)
                    .append("rect")
                    .attr("height", 10)
                    .attr("rx", 1)
                    .attr("ry", 1)
                    .attr("width", function (d) {
                        return that.xScale(d.getAttribute("stop")) - that.xScale(d.getAttribute("start"));
                    })
                    .attr("title", function (d) {
                        return d.getAttribute("ID");
                    })
                    .attr("stroke", that.colorStroke)
                    .attr("stroke-width", "1")
                    .attr("id", function (d) {
                        return that.cleanID(d.getAttribute("ID"));
                    })
                    .style("fill", that.color)
                    .style("cursor", "pointer")
                    .on("click", function (d) {
                        setTimeout(function () {
                            //that.zoomToFeature(d);
                            that.setupDetailedView(d);
                            /*d3.selectAll("rect.selected").each(function(){
	                                                                    d3.select(this).attr("class","").style("fill",that.color);
	                                                            });*/
                            d3.select(this).attr("class", "selected").style("fill", "green");
                        }.bind(this), 10);
                    })
                    .on("dblclick", that.zoomToFeature)
                    .on("mouseover", function (d) {
                        //if(mouseTTOver==0){
                        //console.log("MouseOver");
                        if (that.gsvg.isToolTip === 0) {
                            //console.log("not tooltip");
                            overSelectable = 1;
                            $("#mouseHelp").html("<B>Click</B> to see additional details. <B>Double Click</B> to zoom in on this feature.");
                            d3.select(this).style("fill", "green");
                            //that.gsvg.get('tt').transition()
                            tt.transition()
                                .duration(200)
                                .style("opacity", 1)
                                .style("top", function () {
                                    return that.positionTTTop(d3.event.pageY);
                                })
                                .style("left", function () {
                                    return that.positionTTLeft(d3.event.pageX);
                                });
                            //that.gsvg.get('tt').html(that.createToolTip(d))
                            //console.log(d);
                            tt.html(that.createToolTip(d));
                            if (d) {
                                that.triggerTableFilter(d);
                                if (that.trackClass.indexOf("smallnc") === -1) {
                                    if (that.drawAs === "Trx") {
                                        that.setupToolTipSVG(d.parent, 0.05);
                                    } else {
                                        that.setupToolTipSVG(d, 0.05);
                                    }
                                } else {
                                    //console.log("display tooltip svg");
                                    that.setupToolTipSVG(d, 0.05);
                                    /*var newSvg=toolTipSVG("div#ttSVG",450,((d.getAttribute("start")*1)-10),((d.getAttribute("stop")*1)+10),99,that.getDisplayID(d.getAttribute("ID")),"");
										newSvg.xMin=d.getAttribute("start")-20;
										newSvg.xMax=d.getAttribute("stop")+20;
										var dataArr=new Array();
										dataArr[0]=d;
										newSvg.addTrack(that.trackClass,2,"",dataArr);*/
                                }
                                tt.style("top", function () {
                                    return that.positionTTTop(d3.event.pageY);
                                });
                            }
                        }
                        //}
                        //return false;
                    })
                    .on("mouseout", function (d) {
                        //overSelectable=0;
                        $("#mouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
                        if (d3.select(this).attr("class") !== "selected") {
                            d3.select(this).style("fill", that.color);
                        }
                        //that.gsvg.get('tt').transition(
                        tt.transition()
                            .delay(500)
                            .duration(200)
                            .style("opacity", 0);
                        that.clearTableFilter(d);

                    });

                gene.exit().remove();


                d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll("g.gene").each(function (d) {
                    if (d) {
                        var d3This = d3.select(this);
                        if (d.getAttribute("strand") == "-1" || d.getAttribute("strand") == "1") {
                            var strChar = ">";
                            if (d.getAttribute("strand") == "-1") {
                                strChar = "<";
                            }
                            var fullChar = strChar;
                            var rectW = d3This.select("rect").attr("width");
                            if (rectW < 8.5) {
                                fullChar = "";
                            } else {
                                rectW = rectW - 8.5;
                                fullChar = strChar;
                                while (rectW > 8.7) {
                                    fullChar = fullChar + strChar;
                                    rectW = rectW - 8.5;
                                }
                            }

                            d3This.append("svg:text").attr("dx", "1").attr("dy", "10").attr("id", "strandTxt").style("pointer-events", "none").text(fullChar);
                        }
                        var dThis = d;
                        if (that.density === 2) {
                            var curLbl = dThis.getAttribute("ID");
                            if (dThis.getAttribute("geneSymbol") && dThis.getAttribute("geneSymbol").length > 0) {
                                curLbl = curLbl + " (" + dThis.getAttribute("geneSymbol") + ")";
                            }
                            d3This.append("svg:text").attr("dx", function () {
                                var xpos = that.xScale(dThis.getAttribute("start"));
                                if (xpos < ($(window).width() / 2)) {
                                    xpos = that.xScale(dThis.getAttribute("stop")) - that.xScale(dThis.getAttribute("start")) + 5;
                                } else {
                                    xpos = -1 * curLbl.length * 9;
                                    ;
                                }
                                return xpos;
                            })
                                .attr("dy", 10)
                                .attr("id", "lblTxt")
                                .text(curLbl);
                        } else {
                            d3This.select("text#lblTxt").remove();
                        }
                    }
                });

                if (that.density == 1) {
                    that.svg.attr("height", 30);
                } else if (that.density == 2) {
                    that.svg.attr("height", (d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll("g.gene").size() + 1) * 15);
                } else if (that.density == 3) {
                    that.svg.attr("height", (that.trackYMax + 1) * 15);
                }
            } else if (that.drawAs == "Trx") {
                that.drawnAs = "Trx";
                that.svg.selectAll(".gene").each(function () {
                    d3.select(this).remove();
                });
                that.svg.selectAll(".trx" + that.gsvg.levelNumber).remove();
                var tx = that.svg.selectAll(".trx" + that.gsvg.levelNumber)
                    .data(filterData, key)
                    .attr("transform", function (d, i) {
                        return "translate(" + that.xScale(d.getAttribute("start")) + "," + that.calcY(parseInt(d.getAttribute("start"), 10), parseInt(d.getAttribute("stop"), 10), i) + ")";
                    });

                tx.enter().append("g")
                    .attr("class", function (d) {
                        var str = new String(d.parent.getAttribute("ID"));
                        return "trx" + that.gsvg.levelNumber + " gene" + str.replace(".", "_");
                    })
                    //.attr("transform",function(d,i){ return "translate("+txXScale(d.getAttribute("start"))+","+i*15+")";})
                    .attr("transform", function (d, i) {
                        return "translate(0," + that.calcY(parseInt(d.getAttribute("start"), 10), parseInt(d.getAttribute("stop"), 10), i) + ")";
                    })
                    .attr("id", function (d) {
                        var prefix = "";
                        if (that.gsvg.levelNumber == 1) {
                            prefix = "tx";
                        }
                        if (that.gsvg.levelNumber == 99) {
                            prefix = "ttTx";
                        }
                        return prefix + that.cleanID(d.getAttribute("ID")) + that.gsvg.levelNumber;
                    })
                    //.attr("pointer-events", "all")
                    .style("cursor", "pointer")
                    .on("click", function (d) {
                        setTimeout(function () {
                            if (that.gsvg.levelNumber == 0) {
                                var str = (new String(d.parent.getAttribute("ID"))).replace(".", "_");
                                that.svg.selectAll("g.trx" + that.gsvg.levelNumber + ".selected").selectAll("line").style("stroke", that.color);
                                that.svg.selectAll("g.trx" + that.gsvg.levelNumber + ".selected").selectAll("rect").style("fill", that.color);
                                that.svg.selectAll("g.trx" + that.gsvg.levelNumber + ".selected").selectAll("text").style("opacity", "0.6").style("fill", that.color);

                                that.svg.selectAll("g.trx" + that.gsvg.levelNumber + ".selected").each(function () {
                                    var tmpCl = new String($(this).attr("class"));
                                    tmpCl = tmpCl.replace(" selected", "");
                                    $(this).attr("class", tmpCl);
                                });
                                that.svg.selectAll("g.gene" + str).each(function () {
                                    var tmpCl = $(this).attr("class") + " selected";
                                    $(this).attr("class", tmpCl);
                                });

                                that.svg.selectAll("g.gene" + str).selectAll("line").style("stroke", "green");
                                that.svg.selectAll("g.gene" + str).selectAll("rect").style("fill", "green");
                                that.svg.selectAll("g.gene" + str).selectAll("text").style("opacity", "0.3").style("fill", "green");
                                that.setupDetailedView(d.parent);
                            }
                        }, 10);
                    })
                    .on("dblclick", that.zoomToFeature)
                    .on("mouseover", function (d) {
                        if (that.gsvg.isToolTip === 0) {
                            if (that.gsvg.levelNumber === 0 && typeof d.parent !== 'undefined') {
                                var str = (new String(d.parent.getAttribute("ID"))).replace(".", "_");
                                that.svg.selectAll("g.gene" + str).selectAll("line").style("stroke", "green");
                                that.svg.selectAll("g.gene" + str).selectAll("rect").style("fill", "green");
                                that.svg.selectAll("g.gene" + str).selectAll("text").style("opacity", "0.3").style("fill", "green");
                            } else {
                                d3.select(this).selectAll("line").style("stroke", "green");
                                d3.select(this).selectAll("rect").style("fill", "green");
                                d3.select(this).selectAll("text").style("opacity", "0.3").style("fill", "green");
                            }
                            tt.transition()
                                .duration(200)
                                .style("opacity", 1);
                            tt.html(that.createToolTip(d))
                                .style("left", function () {
                                    return that.positionTTLeft(d3.event.pageX);
                                })
                                .style("top", function () {
                                    return that.positionTTTop(d3.event.pageY);
                                });
                            that.triggerTableFilter(d);
                            if (typeof d !== 'undefined') {
                                //that.triggerTableFilter(d);
                                if (that.trackClass.indexOf("smallnc") === -1) {
                                    that.setupToolTipSVG(d, 0.05);
                                } else {
                                    var newSvg = toolTipSVG("div#ttSVG", 450, (parseInt(d.getAttribute("start"), 10) - 10), (parseInt(d.getAttribute("stop"), 10) + 10), 99, that.getDisplayID(d.getAttribute("ID")), "");
                                    newSvg.xMin = parseInt(d.getAttribute("start"), 10) - 20;
                                    newSvg.xMax = parseInt(d.getAttribute("stop"), 10) + 20;
                                    var dataArr = new Array();
                                    dataArr[0] = d;
                                    newSvg.addTrack(that.trackClass, 2, "", dataArr);
                                }
                                tt.style("top", function () {
                                    return that.positionTTTop(d3.event.pageY);
                                });
                            }
                        }
                    })
                    .on("mouseout", function (d) {
                        var tmp = new String(d3.select(this).attr("class"));
                        if (tmp.indexOf("selected") == -1) {
                            if (that.gsvg.levelNumber == 0) {
                                var str = (new String(d.parent.getAttribute("ID"))).replace(".", "_");
                                that.svg.selectAll("g.gene" + str).selectAll("line").style("stroke", that.color);
                                that.svg.selectAll("g.gene" + str).selectAll("rect").style("fill", that.color);
                                that.svg.selectAll("g.gene" + str).selectAll("text").style("opacity", "0.6").style("fill", that.color);
                            } else {
                                d3.select(this).selectAll("line").style("stroke", that.color);
                                d3.select(this).selectAll("rect").style("fill", that.color);
                                d3.select(this).selectAll("text").style("opacity", "0.6").style("fill", that.color);
                            }
                        }
                        tt.transition()
                            .delay(500)
                            .duration(200)
                            .style("opacity", 0);
                        that.clearTableFilter(d);
                    })
                    .merge(tx)
                    .each(that.drawTrx);


                tx.exit().remove();
                tx;
                if (that.density == 1) {
                    that.svg.attr("height", 30);
                } else if (that.density == 2) {
                    that.svg.attr("height", (d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll("g.trx" + that.gsvg.levelNumber).size() + 1) * 15);
                } else if (that.density == 3) {
                    that.svg.attr("height", (that.trackYMax + 1) * 15);
                }
            }
        }
        if (selectGene != "") {
            that.setSelected(selectGene);
        }
        that.redrawSelectedArea();
        that.drawAs = prevDrawAs;
    };

    that.redrawLegend = function () {
        var legend = [];
        var curPos = 0;
        if (that.drawAs === "Trx") {
            if (that.trackClass === "braincoding") {
                if (organism === "Rn") {
                    legend[curPos] = {color: "#7EB5D6", label: "All"};
                    curPos++;
                    legend[curPos] = {color: "#5E95FF", label: "BN-Lx"};
                    curPos++;
                    legend[curPos] = {color: "#BE95B6", label: "SHR"};
                    curPos++;
                }
            } else if (that.trackClass === "brainnoncoding") {
                if (organism === "Rn") {
                    legend[curPos] = {color: "#CECFCE", label: "All"};
                    curPos++;
                    legend[curPos] = {color: "#3E75FF", label: "BN-Lx"};
                    curPos++;
                    legend[curPos] = {color: "#FE7596", label: "SHR"};
                    curPos++;
                }
            } else if (that.trackClass === "liverTotal") {
                legend[curPos] = {color: "#bbbedd", label: "All"};
                curPos++;
                legend[curPos] = {color: "#9b9eFF", label: "BN-Lx"};
                curPos++;
                legend[curPos] = {color: "#Fb9eBd", label: "SHR"};
                curPos++;
            } else if (that.trackClass === "heartTotal") {
                legend[curPos] = {color: "#DC7252", label: "All"};
                curPos++;
                legend[curPos] = {color: "#BC5292", label: "BN-Lx"};
                curPos++;
                legend[curPos] = {color: "#FF5232", label: "SHR"};
                curPos++;
            } else if (that.trackClass === "mergedTotal") {
                /*legend[curPos]={color:"#9F4F92",label:"Multiple"};
                    curPos++;
                    legend[curPos]={color:"#7EB5D6",label:"Brain"};
                    curPos++;
                    legend[curPos]={color:"#DC7252",label:"Heart"};
                    curPos++;
                    legend[curPos]={color:"#bbbedd",label:"Liver"};
                    curPos++;*/
            } else if (that.trackClass === "brainTotal") {
                legend[curPos] = {color: "#7EB5D6", label: "All"};
                curPos++;
                legend[curPos] = {color: "#5E95FF", label: "BN-Lx"};
                curPos++;
                legend[curPos] = {color: "#BE95B6", label: "SHR"};
                curPos++;
            }
            /*else if(that.trackClass.indexOf("brainTotal")===0){
                    legend[curPos]={color:"#7EB5D6",label:"All"};
                    curPos++;
            }else if(that.trackClass.indexOf("liverTotal")===0){
                    legend[curPos]={color:"#bbbedd",label:"All"};
                    curPos++;
            }*/
        }
        if (that.trackClass === "brainsmallnc") {
            legend[curPos] = {color: "#3E7596", label: "All"};
            curPos++;
            legend[curPos] = {color: "#1E55D6", label: "BN-Lx"};
            curPos++;
            legend[curPos] = {color: "#7E5576", label: "SHR"};
            curPos++;
        } else if (that.trackClass === "heartsmallnc") {
            legend[curPos] = {color: "#9C3212", label: "All"};
            curPos++;
            legend[curPos] = {color: "#7C1252", label: "BN-Lx"};
            curPos++;
            legend[curPos] = {color: "#DC1200", label: "SHR"};
            curPos++;
        } else if (that.trackClass === "liversmallnc") {
            legend[curPos] = {color: "#7b7e9d", label: "All"};
            curPos++;
            legend[curPos] = {color: "#5b5eDd", label: "BN-Lx"};
            curPos++;
            legend[curPos] = {color: "#bb5e7d", label: "SHR"};
            curPos++;
        }

        that.drawLegend(legend);
    };

    that.triggerTableFilter = function (d) {
        var e = jQuery.Event("keyup");
        e.which = 32; // # Some key code value
        var filterStr = "";
        //to support different types of d depending on source need to determine what d is.
        if (typeof d.getAttribute === 'undefined' || typeof d.getAttribute("ID") === 'undefined') {

        } else {//represents a track feature
            filterStr = that.getDisplayID(d.getAttribute("ID"));
        }
        if (that.trackClass.indexOf("smallnc") == -1) {
            $('#tblGenes' + that.trackClass + '_filter input').val(filterStr).trigger(e);
        } else {
            $('#tblsmGenes_filter input').val(filterStr).trigger(e);
        }
    };

    that.clearTableFilter = function (d) {
        var e = jQuery.Event("keyup");
        e.which = 32; // # Some key code value
        if (that.trackClass != "smallnc") {
            $('#tblGenes' + that.trackClass + '_filter input').val("").trigger(e);
        } else {
            $('#tblsmGenes_filter input').val("").trigger(e);
        }
    };

    that.updateSettingsFromUI = function () {
        if ($("#" + that.trackClass + "Dense" + that.level + "Select").length > 0) {
            that.density = $("#" + that.trackClass + "Dense" + that.level + "Select").val();
            if (typeof that.density === 'string') {
                that.density = parseInt(that.density);
            }
        }
        if ($("#" + that.trackClass + "Version" + that.level + "Select").length > 0) {
            //console.log("Select Ver:"+$("#"+that.trackClass+"Version"+that.level+"Select").val());
            that.reqDataVer = $("#" + that.trackClass + "Version" + that.level + "Select").val();
        }
    };

    that.savePrevious = function () {
        that.prevSetting = {};
        that.prevSetting.density = that.density;
        that.prevSetting.dataVer = that.dataVer;
    };

    that.revertPrevious = function () {
        that.density = that.prevSetting.density;
        that.dataVer = that.prevSetting.dataVer;
    };

    //update current settings from a view setting string
    that.updateSettings = function (setting) {
        //console.log("updateSettings:"+that.trackClass+":"+setting);
    };

    //generate the setting string for a view from current settings
    that.generateTrackSettingString = function () {
        return that.trackClass + "," + that.density + "," + that.dataVer + ";";
    };

    that.redrawLegend();
    that.draw(data);

    return that;
}

/*Track for displaying RefSeq Genes/Transcripts*/
function RefSeqTrack(gsvg, data, trackClass, label, additionalOptions) {
    var that = GeneTrack(gsvg, data, trackClass, label);
    that.counts = [{value: 0, names: "Ensembl"}, {value: 0, names: "RNA-Seq"}];
    that.drawAs = "Gene";
    that.trxCutoff = 100000;
    that.density = 3;
    var additionalOptStr = new String(additionalOptions);
    if (additionalOptStr.indexOf("DrawTrx") > -1) {
        that.drawAs = "Trx";
    }

    //Initialize Y Positioning Variables
    that.yMaxArr = new Array();
    that.yArr = new Array();
    that.yArr[0] = new Array();
    for (var j = 0; j < that.gsvg.width; j++) {
        that.yMaxArr[j] = 0;
        that.yArr[0][j] = 0;
    }

    that.ttTrackList = [];
    that.ttTrackList.push("ensemblcoding");
    that.ttTrackList.push("braincoding");
    that.ttTrackList.push("liverTotal");
    that.ttTrackList.push("heartTotal");
    that.ttTrackList.push("mergedTotal");
    that.ttTrackList.push("brainIso");
    that.ttTrackList.push("liverIso");
    that.ttTrackList.push("ensemblnoncoding");
    that.ttTrackList.push("brainnoncoding");
    that.ttTrackList.push("repeatMask");
    that.ttTrackList.push("snpSHRH");
    that.ttTrackList.push("snpBNLX");
    that.ttTrackList.push("snpF344");
    that.ttTrackList.push("snpSHRJ");
    that.cleanID = function (id) {
        id = id.replace(/\./g, "_");
        return id;
    };
    that.color = function (d) {
        var color = d3.rgb("#000000");
        if (that.drawnAs == "Gene") {
            var txList = getAllChildrenByName(getFirstChildByName(d, "TranscriptList"), "Transcript");
            var mostValid = -1;
            for (var m = 0; m < txList.length; m++) {
                var cat = new String(txList[m].getAttribute("category"));
                var val = -1;
                if (cat == "Reviewed") {
                    val = 5;
                } else if (cat == "Validated") {
                    val = 4;
                } else if (cat == "Provisional") {
                    val = 3;
                } else if (cat == "Inferred") {
                    val = 2;
                } else if (cat == "Predicted") {
                    val = 1;
                } else if (cat == "Model") {
                    val = 1;
                } else if (cat == "Unknown") {
                    val = 0;
                }
                if (mostValid < val) {
                    mostValid = val;
                }
            }
            if (mostValid === 5) {
                color = d3.rgb("#18814F");
            }
            if (mostValid === 4) {
                color = d3.rgb("#38A16F");
            } else if (mostValid === 3) {
                color = d3.rgb("#78E1AF");
            } else if (mostValid === 2) {
                color = d3.rgb("#A8FFDF");
            } else if (mostValid === 1) {
                color = d3.rgb("#A8DFFF");
            } else if (mostValid === 0) {
                color = d3.rgb("#C8FFFF");
            }

        } else if (that.drawnAs == "Trx") {
            var cat = new String(d.getAttribute("category"));
            if (cat == "Reviewed") {
                color = d3.rgb("#18814F");
            } else if (cat == "Validated") {
                color = d3.rgb("#38A16F");
                //color=d3.rgb("#48B17F");
            } else if (cat == "Provisional") {
                color = d3.rgb("#78E1AF");
                //color=d3.rgb("#68D19F");
            } else if (cat == "Inferred") {
                color = d3.rgb("#A8FFDF");
                //color=d3.rgb("#88F1BF");
            } else if (cat == "Predicted") {
                color = d3.rgb("#A8DFFF");
            } else if (cat === "Model") {
                color = d3.rgb("#A8DFFF");
            } else if (cat === "Unknown") {
                color = d3.rgb("#C8FFFF");
            }
        }
        return color;
    };
    that.pieColor = function (d, i) {
        var color = d3.rgb("#000000");
        var tmpName = new String(d.data.names);

        if (tmpName.indexOf("Reviewed") > -1) {
            color = d3.rgb("#18814F");
        } else if (tmpName.indexOf("Validated") > -1) {
            color = d3.rgb("#38A16F");
        } else if (tmpName.indexOf("Provisional") > -1) {
            color = d3.rgb("#78E1AF");
        } else if (tmpName.indexOf("Inferred") > -1) {
            color = d3.rgb("#A8FFDF");
        } else if (tmpName.indexOf("Predicted") > -1) {
            color = d3.rgb("#A8DFFF");
        } else if (tmpName.indexOf("Model") > -1) {
            color = d3.rgb("#A8DFFF");
        } else if (tmpName.indexOf("Unknown") > -1) {
            color = d3.rgb("#C8FFFF");
        }
        return color;
    };

    that.getDisplayedData = function () {
        var dispData = new Array();
        var dispDataCount = 0;
        var total = 0;
        if (that.drawnAs == "Gene") {
            var dataElem = d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll(".gene");
            that.counts = new Array();
            var countsInd = 0;
            dataElem.each(function (d) {
                var start = that.xScale(d.getAttribute("start"));
                var stop = that.xScale(d.getAttribute("stop"));
                if ((0 <= start && start <= that.gsvg.width) || (0 <= stop && stop <= that.gsvg.width) || (start <= 0 && stop >= that.gsvg.width)) {
                    var txList = getAllChildrenByName(getFirstChildByName(d, "TranscriptList"), "Transcript");
                    var mostValid = -1;
                    for (var m = 0; m < txList.length; m++) {
                        var cat = new String(txList[m].getAttribute("category"));
                        var val = -1;
                        if (cat == "Reviewed") {
                            val = 5;
                        } else if (cat == "Validated") {
                            val = 4;
                        } else if (cat == "Provisional") {
                            val = 3;
                        } else if (cat == "Inferred") {
                            val = 2;
                        } else if (cat == "Predicted") {
                            val = 1;
                        } else if (cat == "Model") {
                            val = 1;
                        } else if (cat == "Unknown") {
                            val = 1;
                        }
                        if (mostValid < val) {
                            mostValid = val;
                        }
                    }
                    var name = "Unknown";
                    if (mostValid == 5) {
                        name = "Reviewed";
                    } else if (mostValid == 4) {
                        name = "Validated";
                    } else if (mostValid == 3) {
                        name = "Provisional";
                    } else if (mostValid == 2) {
                        name = "Inferred";
                    } else if (mostValid == 1) {
                        name = "Predicted/Model";
                    }
                    if (typeof that.counts[name] === 'undefined') {
                        that.counts[name] = new Object();
                        that.counts[countsInd] = that.counts[name];
                        countsInd++;
                        that.counts[name].value = 1;
                        that.counts[name].names = name;
                    } else {
                        that.counts[name].value++;
                    }
                    dispData[dispDataCount] = d;
                    dispDataCount++;
                    total++;
                }
            });
        } else {
            that.counts = new Array();
            var countsInd = 0;
            that.svg.selectAll("g.trx" + that.gsvg.levelNumber).each(function (d) {
                var start = that.xScale(d.getAttribute("start"));
                var stop = that.xScale(d.getAttribute("stop"));
                if ((0 <= start && start <= that.gsvg.width) || (0 <= stop && stop <= that.gsvg.width) || (start <= 0 && stop >= that.gsvg.width)) {
                    var cat = new String(d.getAttribute("category"));
                    if (typeof that.counts[cat] === 'undefined') {
                        that.counts[cat] = new Object();
                        that.counts[countsInd] = that.counts[cat];
                        countsInd++;
                        that.counts[cat].value = 1;
                        that.counts[cat].names = cat;
                    } else {
                        that.counts[cat].value++;
                    }
                    dispData[dispDataCount] = d;
                    dispDataCount++;
                    total++;
                }
            });
        }
        return dispData;
    };

    that.createToolTip = function (d) {
        var tooltip = "";
        var strand = d.getAttribute("strand");
        if (strand == "1" || strand == "+") {
            strand = "+";
        } else if (strand == "-1" || strand == "-") {
            strand = "-";
        } else {
            strand = ".";
        }
        if (that.drawnAs === "Gene") {
            var txListStr = "";
            var txList = getAllChildrenByName(getFirstChildByName(d, "TranscriptList"), "Transcript");
            for (var m = 0; m < txList.length; m++) {
                var id = new String(txList[m].getAttribute("ID"));
                txListStr += "<B>" + id + "</B> - " + txList[m].getAttribute("category");
                txListStr += "<br>";
            }
            tooltip = "<BR><div id=\"ttSVG\" style=\"background:#FFFFFF;\"></div>Gene Symbol: " + d.getAttribute("geneSymbol") + "<BR>Location: " + d.getAttribute("chromosome") + ":" + numberWithCommas(d.getAttribute("start")) + "-" + numberWithCommas(d.getAttribute("stop")) + "<BR>Strand: " + strand + "<BR>Transcripts:<BR>" + txListStr;
        } else if (that.drawnAs === "Trx") {
            var txListStr = "";
            var id = new String(d.getAttribute("ID"));
            txListStr = "<B>" + id + "</B>";
            tooltip = "<BR><div id=\"ttSVG\" style=\"background:#FFFFFF;\"></div>RefSeq ID:" + txListStr + "<BR>Status: " + d.getAttribute("category") + "<BR>Gene Symbol: " + d.getAttribute("geneSymbol") + "<BR>Location: " + d.getAttribute("chromosome") + ":" + numberWithCommas(d.getAttribute("start")) + "-" + numberWithCommas(d.getAttribute("stop")) + "<BR>Strand: " + strand;
        }
        return tooltip;
    };

    that.getSVGID = function (d) {
        return d.getAttribute("geneSymbol");
    };

    that.setupToolTipSVG = function (d, perc) {
        //Setup Tooltip SVG
        var start = parseInt(d.getAttribute("start"), 10);
        var stop = parseInt(d.getAttribute("stop"), 10);
        var len = stop - start;
        var margin = Math.floor(len * perc);
        if (margin < 20) {
            margin = 20;
        }
        var tmpStart = start - margin;
        var tmpStop = stop + margin;
        if (tmpStart < 1) {
            tmpStart = 1;
        }
        if (typeof that.ttSVGMinWidth !== 'undefined') {
            if (tmpStop - tmpStart < that.ttSVGMinWidth) {
                tmpStart = start - (that.ttSVGMinWidth / 2);
                tmpStop = stop + (that.ttSVGMinWidth / 2);
            }
        }
        var newSvg = toolTipSVG("div#ttSVG", 450, tmpStart, tmpStop, 99, that.getSVGID(d), "transcript");
        newSvg.forLevel = that.gsvg.levelNumber;
        //Setup Track for current feature
        var dataArr = new Array();
        dataArr.push(d);
        newSvg.addTrack(that.trackClass, 3, "DrawTrx", dataArr);
        //Setup Other tracks included in the track type(listed in that.ttTrackList)
        for (var r = 0; r < that.ttTrackList.length; r++) {
            var tData = that.gsvg.getTrackData(that.ttTrackList[r]);
            var fData = new Array();
            if (typeof tData !== 'undefined' && tData.length > 0) {
                var fCount = 0;
                for (var s = 0; s < tData.length; s++) {
                    if ((tmpStart <= parseInt(tData[s].getAttribute("start"), 10) && parseInt(tData[s].getAttribute("start"), 10) <= tmpStop)
                        || (parseInt(tData[s].getAttribute("start"), 10) <= tmpStart && parseInt(tData[s].getAttribute("stop"), 10) >= tmpStart)
                    ) {
                        fData[fCount] = tData[s];
                        fCount++;
                    }
                }
                if (fData.length > 0) {
                    newSvg.addTrack(that.ttTrackList[r], 3, "DrawTrx", fData);
                }
            }
        }
    };

    that.calcY = function (start, end, i) {
        var tmpY = 0;
        if (that.density == 3) {
            if ((start >= that.xScale.domain()[0] && start <= that.xScale.domain()[1]) ||
                (end >= that.xScale.domain()[0] && end <= that.xScale.domain()[1]) ||
                (start <= that.xScale.domain()[0] && end >= that.xScale.domain()[1])) {
                var pStart = Math.floor(that.xScale(start));
                if (pStart < 0) {
                    pStart = 0;
                }
                var pEnd = Math.floor(that.xScale(end)) + 1;
                if (pEnd >= that.gsvg.width) {
                    pEnd = that.gsvg.width - 1;
                }
                var pixStart = pStart - 5;
                if (pixStart < 0) {
                    pixStart = 0;
                }
                var pixEnd = pEnd + 5;
                if (pixEnd >= that.gsvg.width) {
                    pixEnd = that.gsvg.width - 1;
                }
                //find yMax that is clear this is highest line that is clear
                var yMax = 0;
                for (var pix = pixStart; pix <= pixEnd; pix++) {
                    if (that.yMaxArr[pix] > yMax) {
                        yMax = that.yMaxArr[pix];
                    }
                }
                yMax++;
                //may need to extend yArr for a new line
                var addLine = yMax;
                if (that.yArr.length <= yMax) {
                    that.yArr[addLine] = new Array();
                    for (var j = 0; j < that.gsvg.width; j++) {
                        that.yArr[addLine][j] = 0;
                    }
                }
                //check a couple lines back to see if it can be squeezed in
                var startLine = yMax - 12;
                if (startLine < 1) {
                    startLine = 1;
                }
                var prevLine = -1;
                var stop = 0;
                for (var scanLine = startLine; scanLine < yMax && stop == 0; scanLine++) {
                    var available = 0;
                    for (var pix = pixStart; pix <= pixEnd && available == 0; pix++) {
                        if (that.yArr[scanLine][pix] > available) {
                            available = 1;
                        }
                    }
                    if (available == 0) {
                        yMax = scanLine;
                        stop = 1;
                    }
                }
                if (yMax > that.trackYMax) {
                    that.trackYMax = yMax;
                }
                for (var pix = pStart; pix <= pEnd; pix++) {
                    if (that.yMaxArr[pix] < yMax) {
                        that.yMaxArr[pix] = yMax;
                    }
                    that.yArr[yMax][pix] = 1;
                }
                tmpY = yMax * 15;
            } else {
                tmpY = 15;
            }
        } else if (that.density == 2) {
            tmpY = (i + 1) * 15;
        } else {
            tmpY = 15;
        }
        if (that.trackYMax < (tmpY / 15)) {
            that.trackYMax = (tmpY / 15);
        }
        return tmpY;
    };

    that.redraw = function () {

        var tmpMin = that.xScale.domain()[0];
        var tmpMax = that.xScale.domain()[1];
        var len = tmpMax - tmpMin;
        var overrideTrx = 0;

        that.yMaxArr = new Array();
        that.yArr = new Array();
        that.yArr[0] = new Array();
        for (var p = 0; p < that.gsvg.width; p++) {
            that.yMaxArr[p] = 0;
            that.yArr[0][p] = 0;
        }
        that.trackYMax = 0;

        if ((len < that.trxCutoff && that.drawnAs == "Gene") || (len >= that.trxCutoff && that.drawnAs == "Trx" && that.drawAs != "Trx") || (that.drawnAs == "Gene" && $("#forceTrxCBX" + that.gsvg.levelNumber).is(":checked"))) {
            that.draw(that.data);
        } else {
            if (len < that.trxCutoff && that.drawnAs == "Trx" && that.drawAs != "Trx") {
                overrideTrx = 1;
            }
            if (that.drawAs == "Gene" && overrideTrx == 0) {
                if (that.svg.node()) {
                    that.svg.selectAll(".trx").each(function () {
                        d3.select(this).remove();
                    });
                    d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll("g.gene").attr("transform", function (d, i) {
                        var st = that.xScale(d.getAttribute("start"));
                        return "translate(" + st + "," + that.calcY(parseInt(d.getAttribute("start"), 10), parseInt(d.getAttribute("stop"), 10), i) + ")";
                    });
                    d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll("g.gene rect").attr("width", function (d) {
                        var wX = 1;
                        if (that.xScale(d.getAttribute("stop")) - that.xScale(d.getAttribute("start")) > 1) {
                            wX = that.xScale(d.getAttribute("stop")) - that.xScale(d.getAttribute("start"));
                        }
                        return wX;
                    })
                        .attr("stroke", that.colorStroke);
                    d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll("g.gene").each(function (d) {
                        var d3This = d3.select(this);
                        if (d.getAttribute("strand") == "1" || d.getAttribute("strand") == "-1" || d.getAttribute("strand") == "-" || d.getAttribute("strand") == "+") {
                            var strChar = ">";
                            if (d.getAttribute("strand") == "-1" || d.getAttribute("strand") == "-") {
                                strChar = "<";
                            }
                            var fullChar = "";
                            var rectW = d3This.select("rect").attr("width");
                            if (rectW >= 8.5 && rectW <= 15.8) {
                                fullChar = strChar;
                            } else {
                                while (rectW > 8.7) {
                                    fullChar = fullChar + strChar;
                                    rectW = rectW - 8.5;
                                }
                            }
                            d3This.select("text").text(fullChar);
                        }
                    });
                }


                if (that.density == 1) {
                    that.svg.attr("height", 30);
                } else if (that.density == 2) {
                    that.svg.attr("height", (d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll("g.gene").size() + 1) * 15);
                } else if (that.density == 3) {
                    that.svg.attr("height", (that.trackYMax + 1) * 15);
                }
            } else if (overrideTrx == 1 || that.drawAs == "Trx") {
                var txG = that.svg.selectAll("g.trx" + that.gsvg.levelNumber);

                txG.attr("transform", function (d, i) {
                    return "translate(0," + that.calcY(parseInt(d.getAttribute("start"), 10), parseInt(d.getAttribute("stop"), 10), i) + ")";
                })
                    .each(function (d, i) {
                        var cdsStart = parseInt(d.getAttribute("cdsStart"), 10);
                        var cdsStop = parseInt(d.getAttribute("cdsStop"), 10);
                        exList = getAllChildrenByName(getFirstChildByName(d, "exonList"), "exon");
                        var pref = "";
                        if (that.gsvg.levelNumber == 1) {
                            pref = "tx";
                        }
                        for (var m = 0; m < exList.length; m++) {
                            var exStrt = parseInt(exList[m].getAttribute("start"), 10);
                            var exStp = parseInt(exList[m].getAttribute("stop"), 10);
                            if ((exStrt < cdsStart && cdsStart < exStp) || (exStp > cdsStop && cdsStop > exStrt)) {
                                var ncStrt = exStrt;
                                var ncStp = cdsStart;
                                if (exStp > cdsStop) {
                                    ncStrt = cdsStop;
                                    ncStp = exStp;
                                    exStrt = exStrt;
                                    exStp = cdsStop;
                                } else {
                                    exStrt = cdsStart;
                                    exStp = exStp;
                                }
                                d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).select("g#" + pref + that.cleanID(d.getAttribute("ID")) + " rect#ExNC" + exList[m].getAttribute("ID"))
                                    .attr("x", function (d) {
                                        return that.xScale(ncStrt);
                                    })
                                    .attr("width", function (d) {
                                        return that.xScale(ncStp) - that.xScale(ncStrt);
                                    });
                            }
                            d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).select("g#" + pref + that.cleanID(d.getAttribute("ID")) + " rect#Ex" + exList[m].getAttribute("ID"))
                                .attr("x", function (d) {
                                    return that.xScale(exStrt);
                                })
                                .attr("width", function (d) {
                                    return that.xScale(exStp) - that.xScale(exStrt);
                                });
                            if (m > 0) {
                                var intStart = that.xScale(exList[m - 1].getAttribute("stop"));
                                var intStop = that.xScale(exList[m].getAttribute("start"));
                                if (d.getAttribute("strand") == "1" || d.getAttribute("strand") == "-1" || d.getAttribute("strand") == "-" || d.getAttribute("strand") == "+") {
                                    var strChar = ">";
                                    if (d.getAttribute("strand") == "-1") {
                                        strChar = "<";
                                    }
                                    var fullChar = strChar;

                                    var rectW = intStop - intStart;
                                    var alt = 0;
                                    var charW = 7.0;
                                    if (rectW < charW) {
                                        fullChar = "";
                                    } else {
                                        rectW = rectW - charW;
                                        while (rectW > (charW + 1)) {
                                            if (alt == 0) {
                                                fullChar = fullChar + " ";
                                                alt = 1;
                                            } else {
                                                fullChar = fullChar + strChar;
                                                alt = 0;
                                            }
                                            rectW = rectW - charW;
                                        }
                                    }
                                    d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).select("g#" + pref + that.cleanID(d.getAttribute("ID")) + " #IntTxt" + exList[m - 1].getAttribute("ID") + "_" + exList[m].getAttribute("ID"))
                                        .attr("dx", intStart + 1).text(fullChar);
                                }

                                d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).select("g#" + pref + that.cleanID(d.getAttribute("ID")) + " line#Int" + exList[m - 1].getAttribute("ID") + "_" + exList[m].getAttribute("ID"))
                                    .attr("x1", intStart)
                                    .attr("x2", intStop);


                            }
                        }
                    });
                if (that.density == 1) {
                    that.svg.attr("height", 30);
                } else if (that.density == 2) {
                    that.svg.attr("height", (d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll("g.trx" + that.gsvg.levelNumber).size() + 1) * 15);
                } else if (that.density == 3) {
                    that.svg.attr("height", (that.trackYMax + 1) * 15);
                }
            }
        }
        that.redrawSelectedArea();
    };

    that.updateData = function (retry) {
        var tag = "Gene";
        var tmpMin = that.xScale.domain()[0];
        var tmpMax = that.xScale.domain()[1];
        var path = dataPrefix + "tmpData/browserCache/" + genomeVer + "/regionData/" + that.gsvg.folderName + "/refSeq.xml";
        d3.xml(path, function (error, d) {
            if (error) {
                //console.log(error);
                if (retry == 0) {
                    var tmpContext = "/" + pathPrefix;
                    if (!pathPrefix) {
                        tmpContext = "";
                    }
                    $.ajax({
                        url: tmpContext + "generateTrackXML.jsp",
                        type: 'GET',
                        cache: false,
                        async: true,
                        data: {
                            chromosome: chr,
                            minCoord: tmpMin,
                            maxCoord: tmpMax,
                            rnaDatasetID: rnaDatasetID,
                            arrayTypeID: arrayTypeID,
                            myOrganism: organism,
                            genomeVer: genomeVer,
                            dataVer: dataVer,
                            track: that.trackClass,
                            folder: that.gsvg.folderName,
                            panel: panel
                        },
                        dataType: 'json',
                        success: function (data2) {

                        },
                        error: function (xhr, status, error) {

                        }
                    });
                }
                if (retry < 10) {//wait before trying again
                    var time = 2500;
                    if (retry == 1) {
                        time = 10000;
                    }
                    setTimeout(function () {
                        that.updateData(retry + 1);
                    }, time);
                } else {
                    d3.select("#Level" + that.levelNumber + that.trackClass).select("#trkLbl").text("An errror occurred loading Track:" + that.trackClass);
                    d3.select("#Level" + that.levelNumber + that.trackClass).attr("height", 15);
                    that.gsvg.addTrackErrorRemove(that.svg, "#Level" + that.gsvg.levelNumber + that.trackClass);
                }
            } else if (d) {
                var data = d.documentElement.getElementsByTagName(tag);
                var mergeddata = new Array();
                var checkName = new Array();
                var curInd = 0;
                for (var l = 0; l < data.length; l++) {
                    if (data[l]) {
                        mergeddata[curInd] = data[l];
                        mergeddata[curInd].setAttribute("ID", curInd);
                        checkName[data[l].getAttribute("geneSymbol")] = 1;
                        curInd++;
                    }
                }
                for (var l = 0; l < that.data.length; l++) {
                    if (that.data[l] && !checkName[that.data[l].getAttribute("geneSymbol")]) {
                        mergeddata[curInd] = that.data[l];
                        mergeddata[curInd].setAttribute("ID", curInd);
                        curInd++;
                    }
                }
                that.draw(mergeddata);
                that.hideLoading();
                that.getDisplayedData();
                setTimeout(function () {
                    DisplayRegionReport();
                }, 300);
                /*var data=d.documentElement.getElementsByTagName(tag);
					var mergeddata=new Array();
					var checkName=new Array();
					var curInd=0;
						for(var l=0;l<data.length;l++){
							if(typeof data[l]!=='undefined' ){
								mergeddata[curInd]=data[l];
								checkName[data[l].getAttribute("ID")]=1;
								curInd++;
							}
						}
						for(var l=0;l<that.data.length;l++){
							if(typeof that.data[l]!=='undefined' && typeof checkName[that.data[l].getAttribute("ID")]==='undefined'){
								mergeddata[curInd]=that.data[l];
								curInd++;
							}
						}
					that.draw(mergeddata);
					that.hideLoading();
					that.getDisplayedData();
					DisplayRegionReport();*/
            } else {
                that.updateData(retry + 1);
                //shouldn't need this
                //that.draw(that.data);
                that.hideLoading();
            }

        });
    };

    that.drawTrx = function (d, i) {
        var cdsStart = parseInt(d.getAttribute("cdsStart"), 10);
        var cdsStop = parseInt(d.getAttribute("cdsStop"), 10);
        var prefix = "";
        if (that.gsvg.levelNumber == 1) {
            prefix = "tx";
        }
        var txG = that.svg.select("#" + prefix + that.cleanID(d.getAttribute("ID")));
        exList = getAllChildrenByName(getFirstChildByName(d, "exonList"), "exon");
        for (var m = 0; m < exList.length; m++) {
            var exStrt = parseInt(exList[m].getAttribute("start"), 10);
            var exStp = parseInt(exList[m].getAttribute("stop"), 10);
            if ((exStrt < cdsStart && cdsStart < exStp) || (exStp > cdsStop && cdsStop > exStrt)) {//need to draw two rect one for CDS and one non CDS
                var xPos1 = 0;
                var xWidth1 = 0;
                var xPos2 = 0;
                var xWidth2 = 0;
                if (exStrt < cdsStart) {
                    xPos1 = that.xScale(exStrt);
                    xWidth1 = that.xScale(cdsStart) - that.xScale(exStrt);
                    xPos2 = that.xScale(cdsStart);
                    xWidth2 = that.xScale(exStp) - that.xScale(cdsStart);
                } else if (exStp > cdsStop) {
                    xPos2 = that.xScale(exStrt);
                    xWidth2 = that.xScale(cdsStop) - that.xScale(exStrt);
                    xPos1 = that.xScale(cdsStop);
                    xWidth1 = that.xScale(exStp) - that.xScale(cdsStop);
                }
                txG.append("rect")//non CDS
                    .attr("x", xPos1)
                    .attr("y", 2.5)
                    .attr("height", 5)
                    .attr("width", xWidth1)
                    .attr("title", function (d) {
                        return exList[m].getAttribute("ID");
                    })
                    .attr("id", function (d) {
                        return "ExNC" + exList[m].getAttribute("ID");
                    })
                    .style("fill", that.color)
                    .style("cursor", "pointer");
                txG.append("rect")//CDS
                    .attr("x", xPos2)
                    .attr("height", 10)
                    .attr("width", xWidth2)
                    //.attr("width",function(d){ return that.xScale(exList[m].getAttribute("stop")) - that.xScale(exList[m].getAttribute("start")); })
                    .attr("title", function (d) {
                        return exList[m].getAttribute("ID");
                    })
                    .attr("id", function (d) {
                        return "Ex" + exList[m].getAttribute("ID");
                    })
                    .style("fill", that.color)
                    .style("cursor", "pointer");

            } else {
                var height = 10;
                var y = 0;
                if ((exStrt < cdsStart && exStp < cdsStart) || (exStp > cdsStop && exStrt > cdsStop)) {
                    height = 5;
                    y = 2.5;
                }
                txG.append("rect")
                    .attr("x", function (d) {
                        return that.xScale(exList[m].getAttribute("start"));
                    })
                    .attr("y", y)
                    .attr("height", height)
                    .attr("width", function (d) {
                        return that.xScale(exList[m].getAttribute("stop")) - that.xScale(exList[m].getAttribute("start"));
                    })
                    .attr("title", function (d) {
                        return exList[m].getAttribute("ID");
                    })
                    .attr("id", function (d) {
                        return "Ex" + exList[m].getAttribute("ID");
                    })
                    .style("fill", that.color)
                    .style("cursor", "pointer");
            }
            if (m > 0) {
                txG.append("line")
                    .attr("x1", function (d) {
                        return that.xScale(exList[m - 1].getAttribute("stop"));
                    })
                    .attr("x2", function (d) {
                        return that.xScale(exList[m].getAttribute("start"));
                    })
                    .attr("y1", 5)
                    .attr("y2", 5)
                    .attr("id", function (d) {
                        return "Int" + exList[m - 1].getAttribute("ID") + "_" + exList[m].getAttribute("ID");
                    })
                    .attr("stroke", that.color)
                    .attr("stroke-width", "2");
                if (d.getAttribute("strand") == "1" || d.getAttribute("strand") == "-1" || d.getAttribute("strand") == "-" || d.getAttribute("strand") == "+") {
                    var strChar = ">";
                    if (d.getAttribute("strand") == "-" || d.getAttribute("strand") == "-1") {
                        strChar = "<";
                    }
                    var fullChar = strChar;
                    var intStart = that.xScale(exList[m - 1].getAttribute("stop"));
                    var intStop = that.xScale(exList[m].getAttribute("start"));
                    var rectW = intStop - intStart;
                    var alt = 0;
                    var charW = 7.0;
                    if (rectW < charW) {
                        fullChar = "";
                    } else {
                        rectW = rectW - charW;
                        while (rectW > (charW + 1)) {
                            if (alt == 0) {
                                fullChar = fullChar + " ";
                                alt = 1;
                            } else {
                                fullChar = fullChar + strChar;
                                alt = 0;
                            }
                            rectW = rectW - charW;
                        }
                    }
                    txG.append("svg:text").attr("id", function (d) {
                        return "IntTxt" + exList[m - 1].getAttribute("ID") + "_" + exList[m].getAttribute("ID");
                    }).attr("dx", intStart + 1)
                        .attr("dy", "11")
                        .style("pointer-events", "none")
                        .style("opacity", "0.5")
                        .style("fill", that.color)
                        .style("font-size", "16px")
                        .text(fullChar);
                }

            }
        }

    };

    that.draw = function (data) {
        that.data = data;

        that.trackYMax = 0;
        that.yArr = new Array();
        that.yArr[0] = new Array();
        for (var j = 0; j < that.gsvg.width; j++) {
            that.yMaxArr[j] = 0;
            that.yArr[0][j] = 0;
        }

        that.svg.selectAll(".gene").remove();
        that.svg.selectAll(".trx" + that.gsvg.levelNumber).remove();

        /*if($("#"+that.trackClass+"Dense"+that.gsvg.levelNumber+"Select").length>0){
			that.density=$("#"+that.trackClass+"Dense"+that.gsvg.levelNumber+"Select").val();
		}*/

        var prevDrawAs = that.drawAs;
        var tmpMin = that.xScale.domain()[0];
        var tmpMax = that.xScale.domain()[1];
        var len = tmpMax - tmpMin;
        if (len < that.trxCutoff || $("#forceTrxCBX" + that.gsvg.levelNumber).is(":checked")) {
            that.drawAs = "Trx";
        }
        if (data != 0 && that.drawAs === "Gene") {
            that.drawnAs = "Gene";
            that.label = "Ref Seq Genes";
            that.updateLabel(that.label);
            that.redrawLegend();
            var gene = that.svg.selectAll(".gene")
                .data(data, key)
                .attr("transform", function (d, i) {
                    return "translate(" + that.xScale(d.getAttribute("start")) + "," + (that.calcY(parseInt(d.getAttribute("start"), 10), parseInt(d.getAttribute("stop"), 10), i)) + ")";
                });
            //add new
            gene.enter().append("g")
                .attr("class", "gene")
                .attr("transform", function (d, i) {
                    return "translate(" + that.xScale(d.getAttribute("start")) + "," + (that.calcY(parseInt(d.getAttribute("start"), 10), parseInt(d.getAttribute("stop"), 10), i)) + ")";
                })
                .append("rect")
                .attr("height", 10)
                .attr("rx", 1)
                .attr("ry", 1)
                .attr("width", function (d) {
                    return that.xScale(d.getAttribute("stop")) - that.xScale(d.getAttribute("start"));
                })
                .attr("title", function (d) {
                    return d.getAttribute("ID");
                })
                .attr("stroke", that.colorStroke)
                .attr("stroke-width", "1")
                .attr("id", function (d) {
                    return that.cleanID(d.getAttribute("ID"));
                })
                .style("fill", that.color)
                .on("dblclick", that.zoomToFeature)
                .on("mouseover", function (d) {
                    if (that.gsvg.isToolTip == 0) {
                        overSelectable = 1;
                        $("#mouseHelp").html("<B>Double Click</B> to zoom in on this feature.");
                        d3.select(this).style("fill", "green");
                        //that.gsvg.get('tt').transition()
                        tt.transition()
                            .duration(200)
                            .style("opacity", 1);
                        //that.gsvg.get('tt').html(that.createToolTip(d))
                        tt.html(that.createToolTip(d))
                            .style("left", function () {
                                return that.positionTTLeft(d3.event.pageX);
                            })
                            .style("top", function () {
                                return that.positionTTTop(d3.event.pageY);
                            });
                        that.setupToolTipSVG(d, 0.05);
                    }
                    return false;
                })
                .on("mouseout", function (d) {
                    overSelectable = 0;
                    $("#mouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
                    if (d3.select(this).attr("class") != "selected") {
                        d3.select(this).style("fill", that.color);
                    }
                    tt.transition()
                        .delay(500)
                        .duration(200)
                        .style("opacity", 0);
                });

            gene.exit().remove();

            d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll("g.gene").each(function (d) {
                if (typeof d !== 'undefined') {
                    var d3This = d3.select(this);
                    if (d.getAttribute("strand") == "1" || d.getAttribute("strand") == "-1" || d.getAttribute("strand") == "-" || d.getAttribute("strand") == "+") {
                        var strChar = ">";
                        if (d.getAttribute("strand") == "-" || d.getAttribute("strand") == "-1") {
                            strChar = "<";
                        }
                        var fullChar = strChar;
                        var rectW = d3This.select("rect").attr("width");
                        if (rectW < 8.5) {
                            fullChar = "";
                        } else {
                            rectW = rectW - 8.5;
                            fullChar = strChar;
                            while (rectW > 8.7) {
                                fullChar = fullChar + strChar;
                                rectW = rectW - 8.5;
                            }
                        }
                        d3This.append("svg:text").attr("dx", "1").attr("dy", "10").style("pointer-events", "none").text(fullChar);
                    }
                }
            });

            if (that.density == 1) {
                that.svg.attr("height", 30);
            } else if (that.density == 2) {
                that.svg.attr("height", (d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll("g.gene").size() + 1) * 15);
            } else if (that.density == 3) {
                that.svg.attr("height", (that.trackYMax + 1) * 15);
            }
        } else if (data != 0 && that.drawAs === "Trx") {
            that.drawnAs = "Trx";
            that.label = "Ref Seq Transcripts";
            that.updateLabel(that.label);
            that.redrawLegend();
            //var geneList=getAllChildrenByName(getFirstChildByName(data,"GeneList"),"Gene");
            var txList = new Array();
            var txListSize = 0;
            for (var j = 0; j < data.length; j++) {
                var tmpTxList = getAllChildrenByName(getFirstChildByName(data[j], "TranscriptList"), "Transcript");
                for (var k = 0; k < tmpTxList.length; k++) {
                    txList[txListSize] = tmpTxList[k];
                    txList[txListSize].parent = data[j];
                    txListSize++;
                }
            }
            d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll(".trx" + that.gsvg.levelNumber).remove();
            var tx = d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll(".trx" + that.gsvg.levelNumber)
                .data(txList, key)
                .attr("transform", function (d, i) {
                    return "translate(" + that.xScale(d.getAttribute("start")) + "," + (that.calcY(parseInt(d.getAttribute("start"), 10), parseInt(d.getAttribute("stop"), 10), i)) + ")";
                });

            tx.enter().append("g")
                .attr("class", "trx" + that.gsvg.levelNumber)
                //.attr("transform",function(d,i){ return "translate("+txXScale(d.getAttribute("start"))+","+i*15+")";})
                .attr("transform", function (d, i) {
                    return "translate(0," + (that.calcY(parseInt(d.getAttribute("start"), 10), parseInt(d.getAttribute("stop"), 10), i)) + ")";
                })
                .attr("id", function (d) {
                    var prefix = "";
                    if (that.gsvg.levelNumber == 1) {
                        prefix = "tx";
                    }
                    return prefix + that.cleanID(d.getAttribute("ID"));
                })
                .on("mouseover", function (d) {
                    if (that.gsvg.isToolTip == 0) {
                        d3.select(this).selectAll("line").style("stroke", "green");
                        d3.select(this).selectAll("rect").style("fill", "green");
                        d3.select(this).selectAll("text").style("opacity", "0.3").style("fill", "green");
                        tt.transition()
                            .duration(200)
                            .style("opacity", 1);
                        tt.html(that.createToolTip(d))
                            .style("left", function () {
                                return that.positionTTLeft(d3.event.pageX);
                            })
                            .style("top", function () {
                                return that.positionTTTop(d3.event.pageY);
                            });
                        if (typeof d !== 'undefined') {
                            that.setupToolTipSVG(d.parent, 0.05);
                        }
                    }
                })
                .on("mouseout", function (d) {
                    d3.select(this).selectAll("line").style("stroke", function (d) {
                        return that.color(d);
                    });
                    d3.select(this).selectAll("rect").style("fill", function (d) {
                        return that.color(d);
                    });
                    d3.select(this).selectAll("text").style("opacity", "0.6").style("fill", function (d) {
                        return that.color(d);
                    });
                    tt.transition()
                        .delay(500)
                        .duration(200)
                        .style("opacity", 0);
                })
                .each(that.drawTrx);
            tx.exit().remove();
            if (that.density == 2) {
                that.svg.attr("height", (d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll("g.trx" + that.gsvg.levelNumber).size() + 1) * 15);
            } else if (that.density == 3) {
                that.svg.attr("height", (that.trackYMax + 1) * 15);
            } else {
                that.svg.attr("height", 30);
            }
        }
        that.redrawSelectedArea();
        that.drawAs = prevDrawAs;
    };

    that.redrawLegend = function () {
        var legend = [];
        var curPos = 0;
        legend = [{color: "#18814F", label: "Reviewed"}, {color: "#38A16F", label: "Validated"}, {
            color: "#78E1AF",
            label: "Provisional"
        }, {
            color: "#A8FFDF",
            label: "Inferred"
        }, {color: "#A8DFFF", label: "Predicted/Model"}, {color: "#C8FFFF", label: "Unknown"}];
        that.drawLegend(legend);
    };


    that.redrawLegend();
    that.draw(data);
    DisplayRegionReport();
    return that;
}

/*Track for displaying Probesets*/
function ProbeTrack(gsvg, data, trackClass, label, additionalOptions) {
    var that = Track(gsvg, data, trackClass, label);

    //console.log("creating probe track options:"+additionalOptions);
    var opts = new String(additionalOptions).split(",");
    if (opts.length > 0) {
        that.density = opts[0];
        if (typeof that.density === 'string') {
            that.density = parseInt(that.density);
        }
        if (opts.length > 1) {
            that.colorSelect = opts[1];
        } else {
            that.colorSelect = "annot";
        }
        if (opts.length > 2) {
            that.tissues = opts[2].split(":");

        } else {
            that.tissues = ["Brain"];
            if (organism == "Rn") {
                that.tissues = ["Brain", "BrownAdipose", "Heart", "Liver"];
            }
        }
    } else {
        that.density = 3;
        that.colorSelect = "annot";
        that.tissues = ["Brain"];
        if (organism == "Rn") {
            that.tissues = ["Brain", "BrownAdipose", "Heart", "Liver"];
        }
    }
    if (that.gsvg.xScale.domain()[1] - that.gsvg.xScale.domain()[0] > 1000000) {
        that.density = 1;
    }

    that.tissuesAll = ["Brain"];
    if (organism == "Rn") {
        that.tissuesAll = ["Brain", "BrownAdipose", "Heart", "Liver"];
    }
    that.xPadding = 1;
    /*if(that.gsvg.xScale.domain()[1]-that.gsvg.xScale.domain()[0]>2000000){
        that.xPadding=0.5;
    }*/

    that.scanBackYLines = 75;
    that.curColor = that.colorSelect;
    //console.log("start Probes");
    //console.log("density:"+that.density);
    //console.log("colorSelect:"+that.colorSelect);
    //console.log("curColor:"+that.curColor);
    //console.log(that.tissues);

    that.ttTrackList = new Array();
    that.ttTrackList.push("ensemblcoding");
    that.ttTrackList.push("braincoding");
    that.ttTrackList.push("liverTotal");
    that.ttTrackList.push("heartTotal");
    that.ttTrackList.push("mergedTotal");
    that.ttTrackList.push("ensemblnoncoding");
    that.ttTrackList.push("brainnoncoding");
    that.ttTrackList.push("repeatMask");
    //that.ttTrackList.push("ensemblsmallnc");
    //that.ttTrackList.push("brainsmallnc");

    that.color = function (d, tissue) {
        var color = d3.rgb("#000000");
        if (that.colorSelect == "annot") {
            color = that.colorAnnotation(d);
        } else if (that.colorSelect == "herit") {
            var value = getFirstChildByName(d, "herit").getAttribute(tissue);
            var cval = Math.floor(value * 255);
            color = d3.rgb(cval, 0, 0);
        } else if (that.colorSelect == "dabg") {
            var value = getFirstChildByName(d, "dabg").getAttribute(tissue);
            var cval = Math.floor(value * 2.55);
            color = d3.rgb(0, cval, 0);
        }
        return color;
    };

    that.colorAnnotation = function (d) {
        var color = d3.rgb("#000000");
        if (d.getAttribute("type") == "core") {
            color = d3.rgb(255, 0, 0);
        } else if (d.getAttribute("type") == "extended") {
            color = d3.rgb(0, 0, 255);
        } else if (d.getAttribute("type") == "full") {
            color = d3.rgb(0, 100, 0);
        } else if (d.getAttribute("type") == "ambiguous") {
            color = d3.rgb(0, 0, 0);
        }
        return color;
    };

    that.pieColor = function (d, i) {
        var color = d3.rgb("#000000");
        var tmpName = new String(d.data.names);
        if (tmpName == "Core") {
            color = d3.rgb(255, 0, 0);
        } else if (tmpName == "Extended") {
            color = d3.rgb(0, 0, 255);
        } else if (tmpName == "Full") {
            color = d3.rgb(0, 100, 0);
        } else if (tmpName == "Ambiguous") {
            color = d3.rgb(0, 0, 0);
        }
        return color;
    };

    that.createToolTip = function (d) {
        var strand = ".";
        if (d.getAttribute("strand") == 1) {
            strand = "+";
        } else if (d.getAttribute("strand") == -1) {
            strand = "-";
        }
        var len = parseInt(d.getAttribute("stop"), 10) - parseInt(d.getAttribute("start"), 10);
        var tooltiptext = "<BR><div id=\"ttSVG\" style=\"background:#FFFFFF;\"></div><BR>Affy Probe Set ID: " + d.getAttribute("ID") + "<BR>Strand: " + strand + "<BR>Location: " + d.getAttribute("chromosome") + ":" + numberWithCommas(d.getAttribute("start")) + "-" + numberWithCommas(d.getAttribute("stop")) + " (" + len + "bp)<BR>";
        tooltiptext = tooltiptext + "Type: " + d.getAttribute("type") + "<BR><BR>";
        //var tissues=$(".settingsLevel"+that.gsvg.levelNumber+" input[name=\"tissuecbx\"]:checked");
        var herit = getFirstChildByName(d, "herit");
        var dabg = getFirstChildByName(d, "dabg");
        tooltiptext = tooltiptext + "<table class=\"tooltipTable\" width=\"100%\" colSpace=\"0\"><tr><TH>Tissue</TH><TH>Heritability</TH><TH>DABG</TH></TR>";
        if (that.tissues.length < that.tissuesAll.length) {
            tooltiptext = tooltiptext + "<TR><TD colspan=\"3\">Displayed Tissues:</TD></TR>";
        }
        var displayed = {};
        for (var t = 0; t < that.tissues.length; t++) {
            var tissue = new String(that.tissues[t]);
            if (tissue.indexOf("Affy") > -1) {
                tissue = tissue.substr(0, tissue.indexOf("Affy"));
            }
            displayed[tissue] = 1;
            var hval = Math.floor(herit.getAttribute(tissue) * 255);
            var hcol = d3.rgb(hval, 0, 0);
            var dval = Math.floor(dabg.getAttribute(tissue) * 2.55);
            var dcol = d3.rgb(0, dval, 0);
            tooltiptext = tooltiptext + "<TR><TD>" + tissue + "</TD><TD style=\"background:" + hcol + ";color:white;\">" + herit.getAttribute(tissue) + "</TD><TD style=\"background:" + dcol + ";color:white;\">" + dabg.getAttribute(tissue) + "%</TD></TR>";
        }
        if (that.tissues.length < that.tissuesAll.length) {
            tooltiptext = tooltiptext + "<TR><TD colspan=\"3\">Other Tissues:</TD></TR>";
            for (var t = 0; t < that.tissuesAll.length; t++) {
                var tissue = new String(that.tissuesAll[t]);
                if (tissue.indexOf("Affy") > -1) {
                    tissue = tissue.substr(0, tissue.indexOf("Affy"));
                }
                if (displayed[tissue] != 1) {
                    var hval = Math.floor(herit.getAttribute(tissue) * 255);
                    var hcol = d3.rgb(hval, 0, 0);
                    var dval = Math.floor(dabg.getAttribute(tissue) * 2.55);
                    var dcol = d3.rgb(0, dval, 0);
                    tooltiptext = tooltiptext + "<TR><TD>" + tissue + "</TD><TD style=\"background:" + hcol + ";color:white;\">" + herit.getAttribute(tissue) + "</TD><TD style=\"background:" + dcol + ";color:white;\">" + dabg.getAttribute(tissue) + "%</TD></TR>";
                }
            }
        }
        tooltiptext = tooltiptext + "</table>";
        return tooltiptext;
    };

    that.updateSettingsFromUI = function () {
        if ($("#" + that.trackClass + "Dense" + that.level + "Select").length > 0) {
            that.density = $("#" + that.trackClass + "Dense" + that.level + "Select").val();
        } else if (!that.density) {
            that.density = 1;
        }
        that.curColor = that.colorSelect;
        if ($("#" + that.trackClass + that.level + "colorSelect").length > 0) {
            that.curColor = $("#" + that.trackClass + that.level + "colorSelect").val();
        } else if (!that.curColor) {
            that.curColor = "annot";
        }
        var count = 0;
        if ($("#affyTissues" + that.level + " input[name=\"tissuecbx\"]").length > 0) {
            that.tissues = [];
            var tis = $("#affyTissues" + that.level + " input[name=\"tissuecbx\"]:checked");
            for (var t = 0; t < tis.length; t++) {
                var tissue = new String(tis[t].id);
                tissue = tissue.substr(0, tissue.indexOf("Affy"));
                that.tissues[count] = tissue;
                count++;
            }
        }
    };

    that.savePrevious = function () {
        that.prevSetting = {};
        that.prevSetting.density = that.density;
        that.prevSetting.curColor = that.curColor;
        that.prevSetting.tissues = that.tissues;
    };

    that.revertPrevious = function () {
        that.density = that.prevSetting.density;
        that.curColor = that.prevSetting.curColor;
        that.tissues = that.prevSetting.tissues;
    };

    //Pack method does perform additional packing above the default method in track.
    //May be slightly slower but avoids the waterfall like non optimal packing that occurs with the sorted features.
    that.calcY = function (start, end, i, idLen) {
        var tmpY = 0;
        var idPix = idLen * 8 + 5;
        if (that.density === 3 || that.density === '3') {
            if ((start >= that.xScale.domain()[0] && start <= that.xScale.domain()[1]) ||
                (end >= that.xScale.domain()[0] && end <= that.xScale.domain()[1]) ||
                (start <= that.xScale.domain()[0] && end >= that.xScale.domain()[1])) {
                var pStart = Math.round(that.xScale(start));
                if (pStart < 0) {
                    pStart = 0;
                }
                var pEnd = Math.round(that.xScale(end));
                if (pEnd >= that.gsvg.width) {
                    pEnd = that.gsvg.width - 1;
                }
                var pixStart = pStart - that.xPadding;
                if (pixStart < 0) {
                    pixStart = 0;
                }
                var pixEnd = pEnd + that.xPadding;
                if (pixEnd >= that.gsvg.width) {
                    pixEnd = that.gsvg.width - 1;
                }

                //add space for ID
                if ((pixEnd + idPix) < that.gsvg.width) {
                    pixEnd = pixEnd + idPix;
                    pEnd = pEnd + idPix;
                } else if ((pixStart - idPix) > 0) {
                    pixStart = pixStart - idPix;
                    pStart = pStart - idPix;
                }

                //find yMax that is clear this is highest line that is clear
                var yMax = 0;
                for (var pix = pixStart; pix <= pixEnd; pix++) {
                    if (that.yMaxArr[pix] > yMax) {
                        yMax = that.yMaxArr[pix];
                    }
                }
                yMax++;
                //may need to extend yArr for a new line
                var addLine = yMax;
                if (that.yArr.length <= yMax) {
                    that.yArr[addLine] = new Array();
                    for (var j = 0; j < that.gsvg.width; j++) {
                        that.yArr[addLine][j] = 0;
                    }
                }
                //check a couple lines back to see if it can be squeezed in
                var startLine = yMax - that.scanBackYLines;
                if (startLine < 1) {
                    startLine = 1;
                }
                var prevLine = -1;
                var stop = 0;
                for (var scanLine = startLine; scanLine < yMax && stop == 0; scanLine++) {
                    var available = 0;
                    for (var pix = pixStart; pix <= pixEnd && available == 0; pix++) {
                        if (that.yArr[scanLine][pix] > available) {
                            available = 1;
                        }
                    }
                    if (available == 0) {
                        yMax = scanLine;
                        stop = 1;
                    }
                }
                if (yMax > that.trackYMax) {
                    that.trackYMax = yMax;
                }
                for (var pix = pStart; pix <= pEnd; pix++) {
                    if (that.yMaxArr[pix] < yMax) {
                        that.yMaxArr[pix] = yMax;
                    }
                    that.yArr[yMax][pix] = 1;
                }
                tmpY = yMax * 15;
            } else {
                tmpY = 15;
            }
        } else if (that.density === 2 || that.density === '2') {
            tmpY = (i + 1) * 15;
        } else {
            tmpY = 15;
        }
        if (that.trackYMax < (tmpY / 15)) {
            that.trackYMax = (tmpY / 15);
        }
        return tmpY;
    };

    that.redraw = function () {
        var tissueLen = that.tissues.length;
        if (that.curColor != that.colorSelect || ((that.colorSelect === "herit" || that.colorSelect === "dabg") && tissueLen != that.tissueLen)) {
            that.tissueLen = tissueLen;
            that.draw(that.data);
        } else {
            that.trackYMax = 0;
            that.yMaxArr = new Array();
            that.yArr = new Array();
            that.yArr[0] = new Array();
            for (var j = 0; j < that.gsvg.width; j++) {
                that.yMaxArr[j] = 0;
                that.yArr[0][j] = 0;
            }
            that.colorSelect = that.curColor;
            that.tissueLen = tissueLen;
            if (that.colorSelect == "dabg" || that.colorSelect == "herit") {
                if (that.colorSelect == "dabg") {
                    that.drawScaleLegend("0%", "100%", "of Samples DABG", "#000000", "#00FF00", 0);
                } else if (that.colorSelect == "herit") {
                    that.drawScaleLegend("0", "1.0", "Probeset Heritability", "#000000", "#FF0000", 0);
                }
                var totalYMax = 1;
                for (var t = 0; t < that.tissues.length; t++) {
                    var tissue = new String(that.tissues[t]);
                    //tissue=tissue.substr(0,tissue.indexOf("Affy"));
                    that.trackYMax = 0;
                    that.yMaxArr = new Array();
                    that.yArr = new Array();
                    that.yArr[0] = new Array();
                    for (var j = 0; j < that.gsvg.width; j++) {
                        that.yMaxArr[j] = 0;
                        that.yArr[0][j] = 0;
                    }
                    totalYMax++;
                    that.svg.select("text." + tissue).attr("y", totalYMax * 15);
                    that.svg.selectAll("g.probe." + tissue)
                        .attr("transform", function (d, i) {
                            var st = that.gsvg.xScale(d.getAttribute("start"));
                            var y = that.calcY(parseInt(d.getAttribute("start"), 10), parseInt(d.getAttribute("stop"), 10), i, d.getAttribute("ID").length) + totalYMax * 15 - 10;
                            return "translate(" + st + "," + y + ")";
                        })
                        .each(function (d) {
                            var tmpD = d;
                            var d3This = d3.select(this);
                            var wX = 1;
                            if (that.gsvg.xScale(tmpD.getAttribute("stop")) - that.gsvg.xScale(tmpD.getAttribute("start")) > 1) {
                                wX = that.gsvg.xScale(tmpD.getAttribute("stop")) - that.gsvg.xScale(tmpD.getAttribute("start"));
                            }
                            //Set probe rect width,etc
                            d3This.selectAll("rect")
                                .attr("width", wX)
                                .attr("fill", that.color(tmpD, tissue));
                            //change text to indicate strandedness
                            var strChar = ">";
                            if (d.getAttribute("strand") == "-1") {
                                strChar = "<";
                            }
                            var fullChar = "";
                            var rectW = wX;
                            if (rectW >= 7.5 && rectW <= 15) {
                                fullChar = strChar;
                            } else if (rectW > 15) {
                                rectW = rectW - 7.5;
                                while (rectW > 7.5) {
                                    fullChar = fullChar + strChar;
                                    rectW = rectW - 7.5;
                                }
                            }
                            d3This.select("text#strand").text(fullChar);
                            //update position and add labels if needed
                            if (that.density == 2 || that.density == 3) {
                                var curLbl = d.getAttribute("ID");
                                if (d3This.select("text#lblTxt").size() === 0) {
                                    d3This.append("svg:text").attr("dx", function () {
                                        var xpos = that.xScale(d.getAttribute("stop")) + curLbl.length * 8 + 5;
                                        var finalXpos = that.xScale(d.getAttribute("stop")) - that.xScale(d.getAttribute("start")) + 5;
                                        if (xpos > that.gsvg.width) {
                                            finalXpos = -1 * curLbl.length * 8;
                                        }
                                        return finalXpos;
                                    })
                                        .attr("dy", 10)
                                        .attr("id", "lblTxt")
                                        //.attr("fill",that.colorAnnotation(d))
                                        .text(curLbl);
                                } else {

                                    d3This.select("text#lblTxt").attr("dx", function () {
                                        var xpos = that.xScale(d.getAttribute("stop")) + curLbl.length * 8 + 5;
                                        var finalXpos = that.xScale(d.getAttribute("stop")) - that.xScale(d.getAttribute("start")) + 5;
                                        if (xpos > that.gsvg.width) {
                                            finalXpos = -1 * curLbl.length * 8;
                                        }
                                        return finalXpos;
                                    });
                                }
                            } else {
                                d3This.selectAll("text#lblTxt").remove();
                            }
                        });
                    totalYMax = totalYMax + that.trackYMax;
                }
                that.trackYMax = totalYMax * 15;
                that.svg.attr("height", that.trackYMax);
            } else if (that.colorSelect === "annot") {
                var legend = [{color: "#FF0000", label: "Core"}, {
                    color: "#0000FF",
                    label: "Extended"
                }, {color: "#006400", label: "Full"}, {
                    color: "#000000",
                    label: "Ambiguous"
                }];
                that.drawLegend(legend);
                that.trackYMax = 0;
                that.yMaxArr = new Array();
                that.yArr = new Array();
                that.yArr[0] = new Array();
                for (var j = 0; j < that.gsvg.width; j++) {
                    that.yMaxArr[j] = 0;
                    that.yArr[0][j] = 0;
                }

                that.svg.selectAll("g.probe")
                    .attr("transform", function (d, i) {
                        var st = that.xScale(d.getAttribute("start"));
                        return "translate(" + st + "," + that.calcY(parseInt(d.getAttribute("start"), 10), parseInt(d.getAttribute("stop"), 10), i, d.getAttribute("ID").length) + ")";
                        //return "translate("+st+","+that.calcY(d.getAttribute("start"),d.getAttribute("stop"),that.density,i,2)+")";
                    });
                that.svg.selectAll("g.probe rect")
                    .attr("width", function (d) {
                        var wX = 1;
                        if (that.xScale(d.getAttribute("stop")) - that.xScale(d.getAttribute("start")) > 1) {
                            wX = that.xScale(d.getAttribute("stop")) - that.xScale(d.getAttribute("start"));
                        }
                        return wX;
                    })
                    .attr("fill", function (d) {
                        return that.color(d, "");
                    });
                that.svg.selectAll("g.probe").each(function (d) {
                    var d3This = d3.select(this);
                    var strChar = ">";
                    if (d.getAttribute("strand") == "-1") {
                        strChar = "<";
                    }
                    var fullChar = "";
                    var rectW = d3This.select("rect").attr("width");
                    if (rectW >= 7.5 && rectW <= 15) {
                        fullChar = strChar;
                    } else if (rectW > 15) {
                        rectW = rectW - 7.5;
                        while (rectW > 7.5) {
                            fullChar = fullChar + strChar;
                            rectW = rectW - 7.5;
                        }
                    }
                    d3This.select("text").text(fullChar);
                    if (that.density == 2 || that.density == 3) {
                        var curLbl = d.getAttribute("ID");
                        if (d3This.select("text#lblTxt").size() === 0) {
                            d3This.append("svg:text").attr("dx", function () {
                                var xpos = that.xScale(d.getAttribute("stop")) + curLbl.length * 8 + 5;
                                var finalXpos = that.xScale(d.getAttribute("stop")) - that.xScale(d.getAttribute("start")) + 5;
                                if (xpos > that.gsvg.width) {
                                    finalXpos = -1 * curLbl.length * 8;
                                }
                                return finalXpos;
                            })
                                .attr("dy", 10)
                                .attr("id", "lblTxt")
                                //.attr("fill",that.colorAnnotation(d))
                                .text(curLbl);
                        } else {
                            d3This.select("text#lblTxt").attr("dx", function () {
                                var xpos = that.xScale(d.getAttribute("stop")) + curLbl.length * 8 + 5;
                                var finalXpos = that.xScale(d.getAttribute("stop")) - that.xScale(d.getAttribute("start")) + 5;
                                if (xpos > that.gsvg.width) {
                                    finalXpos = -1 * curLbl.length * 8;
                                }
                                return finalXpos;
                            });
                        }
                    } else {
                        d3This.selectAll("text#lblTxt").remove();
                    }
                });
                if (that.density == 1) {
                    that.svg.attr("height", 30);
                } else if (that.density == 2) {
                    that.svg.attr("height", (that.trackYMax + 1) * 15);
                } else if (that.density == 3) {
                    that.svg.attr("height", (that.trackYMax + 1) * 15);
                }
            }
        }
        that.redrawSelectedArea();
    };

    that.update = function (d) {
        that.redraw();
    };

    that.updateData = function (retry) {
        var tag = "probe";
        var path = dataPrefix + "tmpData/browserCache/" + genomeVer + "/regionData/" + that.gsvg.folderName + "/probe.xml";
        d3.xml(path, function (error, d) {
            if (error) {
                if (retry < 3) {//wait before trying again
                    var time = 5000;
                    if (retry == 1) {
                        time = 10000;
                    }
                    setTimeout(function () {
                        that.updateData(retry + 1);
                    }, time);
                } else if (retry >= 3) {
                    d3.select("#Level" + that.levelNumber + that.trackClass).select("#trkLbl").text("An errror occurred loading Track:" + that.trackClass);
                    d3.select("#Level" + that.levelNumber + that.trackClass).attr("height", 15);
                    that.gsvg.addTrackErrorRemove(that.svg, "#Level" + that.gsvg.levelNumber + that.trackClass);
                }
            } else if (d) {
                var probe = d.documentElement.getElementsByTagName(tag);
                var mergeddata = new Array();
                var checkName = new Array();
                var curInd = 0;
                for (var l = 0; l < that.data.length; l++) {
                    if (typeof that.data[l] !== 'undefined') {
                        mergeddata[curInd] = that.data[l];
                        checkName[that.data[l].getAttribute("ID")] = 1;
                        curInd++;
                    }
                }
                for (var l = 0; l < probe.length; l++) {
                    if (typeof probe[l] !== 'undefined' && typeof checkName[probe[l].getAttribute("ID")] === 'undefined') {
                        mergeddata[curInd] = probe[l];
                        curInd++;
                    }
                }

                that.draw(mergeddata);
                that.hideLoading();
            } else {
                //shouldn't need this
                //that.draw(that.data);
                that.hideLoading();
            }
        });
    };

    that.draw = function (data) {
        that.data = data;

        that.colorSelect = that.curColor;
        that.trackYMax = 0;
        that.yMaxArr = new Array();
        that.yArr = new Array();
        that.yArr[0] = new Array();
        for (var j = 0; j < that.gsvg.width; j++) {
            that.yMaxArr[j] = 0;
            that.yArr[0][j] = 0;
        }
        if (that.colorSelect == "dabg" || that.colorSelect == "herit") {
            if (that.colorSelect == "dabg") {
                that.drawScaleLegend("0%", "100%", "of Samples DABG", "#000000", "#00FF00", 0);
            } else if (that.colorSelect == "herit") {
                that.drawScaleLegend("0", "1.0", "Probeset Heritability", "#000000", "#FF0000", 0);
            }
            that.svg.selectAll(".probe").remove();
            that.svg.selectAll(".tissueLbl").remove();
            that.tissueLen = that.tissues.length;
            var totalYMax = 1;
            for (var t = 0; t < that.tissues.length; t++) {
                var tissue = new String(that.tissues[t]);
                if (tissue.indexOf(";") > 0) {
                    tissue = tissue.substr(0, tissue.indexOf(";"));
                }
                if (tissue.indexOf(":") > 0) {
                    tissue = tissue.substr(0, tissue.indexOf(":"));
                }
                //tissue=tissue.substr(0,tissue.indexOf("Affy"));
                that.trackYMax = 0;
                that.yMaxArr = new Array();
                that.yArr = new Array();
                that.yArr[0] = new Array();
                for (var j = 0; j < that.gsvg.width; j++) {
                    that.yMaxArr[j] = 0;
                    that.yArr[0][j] = 0;
                }
                var dispTissue = tissue;
                if (dispTissue == "BrownAdipose") {
                    dispTissue = "Brown Adipose";
                } else if (dispTissue == "Brain") {
                    dispTissue = "Whole Brain";
                }
                var tisLbl = new String("Tissue: " + dispTissue);
                totalYMax++;
                that.svg.append("text").attr("class", "tissueLbl " + tissue).attr("x", that.gsvg.width / 2 - (tisLbl.length / 2) * 7.5).attr("y", totalYMax * 15).text(tisLbl);

                //console.log(";.probe."+tissue+";");
                //update
                if (data.length > 0) {
                    var probes = that.svg.selectAll(".probe." + tissue)
                        .data(data, function (d) {
                            return keyTissue(d, tissue);
                        })
                        .attr("transform", function (d, i) {
                            return "translate(" + that.xScale(d.getAttribute("start")) + "," + (that.calcY(parseInt(d.getAttribute("start"), 10), parseInt(d.getAttribute("stop"), 10), i, d.getAttribute("ID").length) + totalYMax * 15 - 10) + ")";
                        });
                    //add new
                    probes.enter().append("g")
                        .attr("class", "probe " + tissue)
                        .attr("transform", function (d, i) {
                            return "translate(" + that.xScale(d.getAttribute("start")) + "," + (that.calcY(parseInt(d.getAttribute("start"), 10), parseInt(d.getAttribute("stop"), 10), i, d.getAttribute("ID").length) + totalYMax * 15 - 10) + ")";
                        })
                        .append("rect")
                        //.attr("class",tissue)
                        .attr("height", 10)
                        .attr("rx", 1)
                        .attr("ry", 1)
                        .attr("width", function (d) {
                            var wX = 1;
                            if (that.xScale(d.getAttribute("stop")) - that.xScale(d.getAttribute("start")) > 1) {
                                wX = that.xScale(d.getAttribute("stop")) - that.xScale(d.getAttribute("start"));
                            }
                            return wX;
                        })
                        .attr("id", function (d) {
                            return d.getAttribute("ID") + tissue;
                        })
                        .style("fill", function (d) {
                            return that.color(d, tissue);
                        })
                        .style("cursor", "pointer")
                        .on("dblclick", that.zoomToFeature)
                        .on("mouseover", function (d) {
                            if (that.gsvg.isToolTip == 0) {
                                overSelectable = 1;
                                $("#mouseHelp").html("<B>Double Click</B> to zoom in on this feature.");
                                var thisD3 = d3.select(this);
                                that.curTTColor = thisD3.style("fill");
                                if (thisD3.style("opacity") > 0) {
                                    thisD3.style("fill", "green");
                                    tt.transition()
                                        .duration(200)
                                        .style("opacity", 1);
                                    tt.html(that.createToolTip(d))
                                        .style("left", function () {
                                            return that.positionTTLeft(d3.event.pageX);
                                        })
                                        .style("top", function () {
                                            return that.positionTTTop(d3.event.pageY);
                                        });
                                    //Setup Tooltip SVG
                                    that.setupToolTipSVG(d, 0.2);
                                }
                            }
                        })
                        .on("mouseout", function (d) {
                            overSelectable = 0;
                            $("#mouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
                            var thisD3 = d3.select(this);
                            if (thisD3.style("opacity") > 0) {
                                thisD3.style("fill", that.curTTColor);
                                tt.transition()
                                    .delay(500)
                                    .duration(200)
                                    .style("opacity", 0);
                            }
                        });
                    that.svg.selectAll("g.probe." + tissue).each(function (d) {
                        var d3This = d3.select(this);
                        var strChar = ">";
                        if (d.getAttribute("strand") == "-1") {
                            strChar = "<";
                        }
                        var fullChar = strChar;
                        var rectW = d3This.select("rect").attr("width");
                        if (rectW < 7.5) {
                            fullChar = "";
                        } else {
                            rectW = rectW - 7.5;
                            while (rectW > 8.5) {
                                fullChar = fullChar + strChar;
                                rectW = rectW - 7.5;
                            }
                        }
                        d3This.append("svg:text").attr("dx", "1").attr("id", "strand").attr("dy", "10").style("pointer-events", "none").style("fill", "white").text(fullChar);
                        if (that.density == 2 || that.density == 3) {
                            var curLbl = d.getAttribute("ID");
                            d3This.append("svg:text").attr("dx", function () {
                                var xpos = that.xScale(d.getAttribute("stop")) + curLbl.length * 8 + 5;
                                var finalXpos = that.xScale(d.getAttribute("stop")) - that.xScale(d.getAttribute("start")) + 5;
                                if (xpos > that.gsvg.width) {
                                    finalXpos = -1 * curLbl.length * 8;
                                }
                                return finalXpos;
                            })
                                .attr("dy", 10)
                                .attr("id", "lblTxt")
                                //.attr("fill",that.colorAnnotation(d))
                                .text(curLbl);

                        } else {
                            d3This.selectAll("text#lblTxt").remove();
                        }
                    });
                    totalYMax = totalYMax + that.trackYMax + 1;
                }
            }
            //probes.exit().remove();
            that.trackYMax = totalYMax;
            that.svg.attr("height", totalYMax * 15 + 45);
        } else if (that.colorSelect == "annot") {
            var legend = [{color: "#FF0000", label: "Core"}, {color: "#0000FF", label: "Extended"}, {
                color: "#006400",
                label: "Full"
            }, {
                color: "#000000",
                label: "Ambiguous"
            }];
            that.drawLegend(legend);
            that.trackYMax = 0;
            that.yMaxArr = new Array();
            that.yArr = new Array();
            that.yArr[0] = new Array();
            for (var j = 0; j < that.gsvg.width; j++) {
                that.yMaxArr[j] = 0;
                that.yArr[0][j] = 0;
            }
            that.svg.selectAll(".probe").remove();
            that.svg.selectAll(".tissueLbl").remove();
            //update
            var probes = that.svg.selectAll(".probe.annot")
                .data(data, key)
                //.attr("transform",function(d,i){ return "translate("+that.xScale(d.getAttribute("start"))+","+that.calcY(d.getAttribute("start"),d.getAttribute("stop"),that.density,i,2)+")";})
                .attr("transform", function (d, i) {
                    return "translate(" + that.xScale(d.getAttribute("start")) + "," + that.calcY(parseInt(d.getAttribute("start"), 10), parseInt(d.getAttribute("stop"), 10), i, d.getAttribute("ID").length) + ")";
                });

            //add new
            probes.enter().append("g")
                .attr("class", "probe annot")
                //.attr("transform",function(d,i){ return "translate("+that.xScale(d.getAttribute("start"))+","+that.calcY(d.getAttribute("start"),d.getAttribute("stop"),that.density,i,2)+")";})
                .attr("transform", function (d, i) {
                    return "translate(" + that.xScale(d.getAttribute("start")) + "," + that.calcY(parseInt(d.getAttribute("start"), 10), parseInt(d.getAttribute("stop"), 10), i, d.getAttribute("ID").length) + ")";
                })
                .append("rect")
                .attr("height", 10)
                .attr("rx", 1)
                .attr("ry", 1)
                .attr("width", function (d) {
                    var wX = 1;
                    if (that.xScale(d.getAttribute("stop")) - that.xScale(d.getAttribute("start")) > 1) {
                        wX = that.xScale(d.getAttribute("stop")) - that.xScale(d.getAttribute("start"));
                    }
                    return wX;
                })
                .attr("id", function (d) {
                    return d.getAttribute("ID");
                })
                .style("fill", function (d) {
                    return that.color(d, "");
                })
                .style("cursor", "pointer")
                .on("dblclick", that.zoomToFeature)
                .on("mouseover", function (d) {
                    if (that.gsvg.isToolTip == 0) {
                        overSelectable = 1;
                        $("#mouseHelp").html("<B>Double Click</B> to zoom in on this feature.");
                        var thisD3 = d3.select(this);
                        if (thisD3.style("opacity") > 0) {
                            thisD3.style("fill", "green");
                            tt.transition()
                                .duration(200)
                                .style("opacity", 1);
                            tt.html(that.createToolTip(d))
                                .style("left", function () {
                                    return that.positionTTLeft(d3.event.pageX);
                                })
                                .style("top", function () {
                                    return that.positionTTTop(d3.event.pageY);
                                });
                            //Setup Tooltip SVG
                            that.setupToolTipSVG(d, 0.2);
                        }
                    }
                })
                .on("mouseout", function (d) {
                    overSelectable = 0;
                    $("#mouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
                    var thisD3 = d3.select(this);
                    if (thisD3.style("opacity") > 0) {
                        thisD3.style("fill", that.color);
                        tt.transition()
                            .delay(500)
                            .duration(200)
                            .style("opacity", 0);
                    }
                });
            that.svg.selectAll("g.probe").each(function (d) {
                var d3This = d3.select(this);
                var strChar = ">";
                if (d.getAttribute("strand") == "-1") {
                    strChar = "<";
                }
                var fullChar = strChar;
                var rectW = d3This.select("rect").attr("width");
                if (rectW < 7.5) {
                    fullChar = "";
                } else {
                    rectW = rectW - 7.5;
                    while (rectW > 15) {
                        fullChar = fullChar + strChar;
                        rectW = rectW - 7.5;
                    }
                }
                d3This.append("svg:text").attr("dx", "1").attr("dy", "10").style("pointer-events", "none").style("fill", "white").text(fullChar);

                if (that.density == 2 || that.density == 3) {
                    var curLbl = d.getAttribute("ID");
                    d3This.append("svg:text").attr("dx", function () {
                        /*var xpos=that.xScale(d.getAttribute("start"));
								if(xpos<($(window).width()/2)){
									xpos=that.xScale(d.getAttribute("stop"))-that.xScale(d.getAttribute("start"))+5;
								}else{
									xpos=-1*curLbl.length*9;;
								}
								return xpos;*/
                        var xpos = that.xScale(d.getAttribute("stop")) + curLbl.length * 8 + 5;
                        var finalXpos = that.xScale(d.getAttribute("stop")) - that.xScale(d.getAttribute("start")) + 5;
                        if (xpos > that.gsvg.width) {
                            finalXpos = -1 * curLbl.length * 8;
                        }
                        return finalXpos;
                    })
                        .attr("dy", 10)
                        .attr("id", "lblTxt")
                        //.attr("fill",that.colorAnnotation(d))
                        .text(curLbl);

                } else {
                    d3This.select("text#lblTxt").remove();
                }
            });


            //probes.exit().remove();
            if (that.density == 1) {
                that.svg.attr("height", 30);
            } else if (that.density == 2) {
                //that.svg.attr("height", (d3.select("#Level"+that.gsvg.levelNumber+that.trackClass).selectAll("g.probe").length+1)*15);
                that.svg.attr("height", (that.trackYMax + 1) * 15);
            } else if (that.density == 3) {
                that.svg.attr("height", (that.trackYMax + 1) * 15);
            }
        }
        that.redrawSelectedArea();
    };

    that.getDisplayedData = function () {
        var dataElem = d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll("g.probe");
        that.counts = [{value: 0, names: "Core"}, {value: 0, names: "Extended"}, {value: 0, names: "Full"}, {
            value: 0,
            names: "Ambiguous"
        }];
        var tmpDat = dataElem[0];
        var dispData = new Array();
        var dispDataCount = 0;
        dataElem.each(function (d) {
            var start = that.xScale(d.getAttribute("start"));
            var stop = that.xScale(d.getAttribute("stop"));
            if ((0 <= start && start <= that.gsvg.width) || (0 <= stop && stop <= that.gsvg.width)) {
                if (d.getAttribute("type") == "core") {
                    that.counts[0].value++;
                } else if (d.getAttribute("type") == "extended") {
                    that.counts[1].value++;
                } else if (d.getAttribute("type") == "full") {
                    that.counts[2].value++;
                } else if (d.getAttribute("type") == "ambiguous") {
                    that.counts[3].value++;
                }
                dispData[dispDataCount] = d;
                dispDataCount++;
            }
        });
        if (dataElem.size() === 0) {
            that.counts = [];
        }
        return dispData;
    };

    that.generateSettingsDiv = function (topLevelSelector) {
        var d = trackInfo[that.trackClass];
        that.savePrevious();
        //console.log(trackInfo);
        //console.log(d);
        d3.select(topLevelSelector).select("table").select("tbody").html("");
        if (typeof d !== 'undefined' && typeof d.Controls !== 'undefined' && d.Controls != "null" && d.Controls.length > 0) {
            var controls = new String(d.Controls).split(",");
            var table = d3.select(topLevelSelector).select("table").select("tbody");
            table.append("tr").append("td").style("font-weight", "bold").html("Track Settings: " + d.Name);
            for (var c = 0; c < controls.length; c++) {
                if (typeof controls[c] !== 'undefined' && controls[c] != "") {
                    var params = controls[c].split(";");

                    var div = table.append("tr").append("td");
                    var lbl = params[0].substr(5);

                    var def = "";
                    if (params.length > 3 && params[3].indexOf("Default=") == 0) {
                        def = params[3].substr(8);
                    }
                    if (params[1].toLowerCase().indexOf("select") == 0) {
                        div.append("text").text(lbl + ": ");
                        var selClass = params[1].split(":");
                        var opts = params[2].split("}");
                        var id = that.trackClass + "Dense" + that.level + "Select";
                        if (selClass[1] == "colorSelect") {
                            id = that.trackClass + that.level + "colorSelect";
                        }
                        var sel = div.append("select").attr("id", id)
                            .attr("name", selClass[1]);
                        for (var o = 0; o < opts.length; o++) {
                            var option = opts[o].substr(1).split(":");
                            if (option.length == 2) {
                                var tmpOpt = sel.append("option").attr("value", option[1]).text(option[0]);
                                if (selClass[1] == "colorSelect" && option[1] == that.curColor) {
                                    tmpOpt.attr("selected", "selected");
                                } else if (option[1] == that.density) {
                                    tmpOpt.attr("selected", "selected");
                                }
                            }
                        }
                        d3.select("select#" + id).on("change", function () {
                            if ($(this).val() == "dabg" || $(this).val() == "herit") {
                                $("div#affyTissues" + that.level).show();
                            } else {
                                $("div#affyTissues" + that.level).hide();
                            }
                            that.updateSettingsFromUI();
                            that.redraw();
                        });
                    } else if (params[1].toLowerCase().indexOf("cbx") == 0) {
                        div = div.append("div").attr("id", "affyTissues" + that.level).style("display", "none");
                        div.append("text").text(lbl + ": ");
                        var selClass = params[1].split(":");
                        var opts = params[2].split("}");

                        for (var o = 0; o < opts.length; o++) {
                            var option = opts[o].substr(1).split(":");
                            if (option.length == 2) {
                                var span = div.append("div").style("display", "inline-block");
                                var sel = span.append("input").attr("type", "checkbox").attr("id", option[1] + "CBX" + that.level)
                                    .attr("name", selClass[1])
                                    .style("margin-left", "5px");
                                span.append("text").text(option[0]);
                                //console.log(def+"::"+option[1]);

                                d3.select("input#" + option[1] + "CBX" + that.level).on("change", function () {
                                    that.updateSettingsFromUI();
                                    that.redraw();
                                });
                            }
                        }
                    }
                }
            }
            if (that.curColor == "dabg" || that.curColor == "herit") {
                $("div#affyTissues" + that.level).show();
            } else {
                $("div#affyTissues" + that.level).hide();
            }
            for (var p = 0; p < that.tissues.length; p++) {
                //console.log("#"+that.tissues[p]+"AffyCBX"+that.level);
                $("#" + that.tissues[p] + "AffyCBX" + that.level).prop('checked', true);
            }
            var buttonDiv = table.append("tr").append("td");
            buttonDiv.append("input").attr("type", "button").attr("value", "Remove Track").style("float", "left").style("margin-left", "5px").on("click", function () {
                $('#trackSettingDialog').fadeOut("fast");
                that.gsvg.removeTrack(that.trackClass);
                var viewID = svgList[that.gsvg.levelNumber].currentView.ViewID;
                var track = viewMenu[that.gsvg.levelNumber].findTrackByClass(that.trackClass, viewID);
                var indx = viewMenu[that.gsvg.levelNumber].findTrackIndexWithViewID(track.TrackID, viewID);
                viewMenu[that.gsvg.levelNumber].removeTrackWithIDIdx(indx, viewID);
            });
            buttonDiv.append("input").attr("type", "button").attr("value", "Apply").style("float", "right").style("margin-left", "5px").on("click", function () {
                $('#trackSettingDialog').fadeOut("fast");
                if (that.density != that.prevSetting.density || that.curColor != that.prevSetting.curColor || that.tissues != that.prevSetting.tissues) {
                    that.gsvg.setCurrentViewModified();
                }
            });
            buttonDiv.append("input").attr("type", "button").attr("value", "Cancel").style("float", "right").style("margin-left", "5px").on("click", function () {
                that.revertPrevious();
                that.draw(that.data);
                $('#trackSettingDialog').fadeOut("fast");
            });
        } else {
            var table = d3.select(topLevelSelector).select("table").select("tbody");
            table.append("tr").append("td").style("font-weight", "bold").html("Track Settings: " + d.Name);
            table.append("tr").append("td").html("Sorry no settings for this track.");
            var buttonDiv = table.append("tr").append("td");
            buttonDiv.append("input").attr("type", "button").attr("value", "Remove Track").style("float", "left").style("margin-left", "5px").on("click", function () {
                $('#trackSettingDialog').fadeOut("fast");
            });
            buttonDiv.append("input").attr("type", "button").attr("value", "Cancel").style("float", "right").style("margin-left", "5px").on("click", function () {
                $('#trackSettingDialog').fadeOut("fast");
            });
        }
    };

    that.generateTrackSettingString = function () {
        var tissueStr = "";
        for (var k = 0; k < that.tissues.length; k++) {
            if (k > 0) {
                tissueStr = tissueStr + ":";
            }
            tissueStr = tissueStr + that.tissues[k];
            /*if(k<(that.tissues.length-1)){
				tissueStr=tissueStr+":";
			}*/
        }
        return that.trackClass + "," + that.density + "," + that.curColor + "," + tissueStr + ";";
    };

    that.draw(data);
    return that;
}

/*Track for displaying SNPs/Indels*/
function SNPTrack(gsvg, data, trackClass, density, additionalOptions) {
    var that = Track(gsvg, data, trackClass, lbl);
    var strain = (new String(trackClass)).substr(3);
    var opts = new String(additionalOptions).split(",");
    if (opts.length > 0) {
        that.include = opts[0];
    } else {
        that.include = 4;
    }
    that.density = density;
    var lbl = strain;
    if (lbl == "SHRH") {
        lbl = "SHR/OlaPrin";
    } else if (lbl == "BNLX") {
        lbl = "BN-Lx/CubPrin";
    } else if (lbl == "SHRJ") {
        lbl = "SHR/NCrlPrin";
    }
    that.displayStrain = lbl;
    if (that.include == 1) {
        lbl = lbl + " SNPs";
    } else if (that.include == 2) {
        lbl = lbl + " Insertions";
    } else if (that.include == 3) {
        lbl = lbl + " Deletions";
    } else if (that.include == 4) {
        lbl = lbl + " SNPs/Indels";
    }
    that.counts = [{value: 0, perc: 0, names: "SNP " + that.displayStrain}, {
        value: 0,
        perc: 0,
        names: "Insertion " + that.displayStrain
    }, {
        value: 0,
        perc: 0,
        names: "Deletion " + that.displayStrain
    }];
    that.strain = strain;

    that.ttTrackList = new Array();
    that.ttTrackList.push("ensemblcoding");
    that.ttTrackList.push("braincoding");
    that.ttTrackList.push("liverTotal");
    that.ttTrackList.push("heartTotal");
    that.ttTrackList.push("mergedTotal");
    that.ttTrackList.push("brainIso");
    that.ttTrackList.push("liverIso");
    that.ttTrackList.push("refSeq");
    that.ttTrackList.push("ensemblnoncoding");
    that.ttTrackList.push("brainnoncoding");
    that.ttTrackList.push("ensemblsmallnc");
    that.ttTrackList.push("brainsmallnc");
    that.ttTrackList.push("probe");
    that.ttTrackList.push("repeatMask");

    that.xPadding = 1;
    /*if(that.gsvg.xScale.domain()[1]-that.gsvg.xScale.domain()[0]>2000000){
        that.xPadding=0.5;
    }*/
    that.scanBackYLines = 50;

    that.updateSettingsFromUI = function () {
        if ($("#" + that.trackClass + "Dense" + that.level + "Select").length > 0) {
            that.density = $("#" + that.trackClass + "Dense" + that.level + "Select").val();
        }
        if ($("#" + that.trackClass + that.level + "Select").length > 0) {
            that.include = $("#" + that.trackClass + that.level + "Select").val();
        }
    };

    that.savePrevious = function () {
        that.prevSetting = {};
        that.prevSetting.density = that.density;
        that.prevSetting.include = that.include;
    };

    that.revertPrevious = function () {
        that.density = that.prevSetting.density;
        that.include = that.prevSetting.include;
    };

    that.generateTrackSettingString = function () {
        return that.trackClass + "," + that.density + "," + that.include + ";";
    };

    that.generateSettingsDiv = function (topLevelSelector) {
        var d = trackInfo[that.trackClass];
        that.savePrevious();
        //console.log(trackInfo);
        //console.log(d);
        d3.select(topLevelSelector).select("table").select("tbody").html("");
        if (d.Controls.length > 0 && d.Controls != "null") {
            var controls = new String(d.Controls).split(",");
            var table = d3.select(topLevelSelector).select("table").select("tbody");
            table.append("tr").append("td").style("font-weight", "bold").html("Track Settings: " + d.Name);
            for (var c = 0; c < controls.length; c++) {
                if (typeof controls[c] !== 'undefined' && controls[c] != "") {
                    var params = controls[c].split(";");
                    var div = table.append("tr").append("td");
                    var lbl = params[0].substr(5);
                    div.append("text").text(lbl + ": ");
                    var def = "";
                    if (params.length > 3 && params[3].indexOf("Default=") == 0) {
                        def = params[3].substr(8);
                    }
                    if (params[1].toLowerCase().indexOf("select") == 0) {
                        var selClass = params[1].split(":");
                        var opts = params[2].split("}");
                        var prefix = "";
                        var suffix = "";
                        if (selClass.length > 2) {
                            prefix = selClass[2];
                        }
                        if (selClass.length > 3) {
                            suffix = selClass[3];
                        }
                        var sel = div.append("select").attr("id", that.trackClass + prefix + that.level + suffix)
                            .attr("name", selClass[1]);
                        for (var o = 0; o < opts.length; o++) {
                            var option = opts[o].substr(1).split(":");
                            if (option.length == 2) {
                                var tmpOpt = sel.append("option").attr("value", option[1]).text(option[0]);
                                if ((prefix == "Dense" && option[1] == that.density) ||
                                    (prefix == "" && option[1] == that.include)) {
                                    tmpOpt.attr("selected", "selected");
                                }
                            }
                        }
                        //console.log("#"+that.trackClass+prefix+that.level+suffix);
                        d3.select("#" + that.trackClass + prefix + that.level + suffix).on("change", function () {
                            that.updateSettingsFromUI();
                            that.updateData();
                        });
                    }/* else {
                        console.log("Undefined track settings:  " + controls[c]);
                    }*/
                }
            }
            var buttonDiv = table.append("tr").append("td");
            buttonDiv.append("input").attr("type", "button").attr("value", "Remove Track").style("float", "left").style("margin-left", "5px").on("click", function () {
                $('#trackSettingDialog').fadeOut("fast");
                that.gsvg.removeTrack(that.trackClass);
                var viewID = svgList[that.gsvg.levelNumber].currentView.ViewID;
                var track = viewMenu[that.gsvg.levelNumber].findTrackByClass(that.trackClass, viewID);
                var indx = viewMenu[that.gsvg.levelNumber].findTrackIndexWithViewID(track.TrackID, viewID);
                viewMenu[that.gsvg.levelNumber].removeTrackWithIDIdx(indx, viewID);
            });
            buttonDiv.append("input").attr("type", "button").attr("value", "Apply").style("float", "right").style("margin-left", "5px").on("click", function () {
                $('#trackSettingDialog').fadeOut("fast");
                if (that.density != that.prevSetting.density || that.include != that.prevSetting.include) {
                    that.gsvg.setCurrentViewModified();
                }
            });
            buttonDiv.append("input").attr("type", "button").attr("value", "Cancel").style("float", "right").style("margin-left", "5px").on("click", function () {
                that.revertPrevious();
                that.draw(that.data);
                $('#trackSettingDialog').fadeOut("fast");
            });
        } else {
            var table = d3.select(topLevelSelector).select("table").select("tbody");
            table.append("tr").append("td").style("font-weight", "bold").html("Track Settings: " + d.Name);
            table.append("tr").append("td").html("Sorry no settings for this track.");
            var buttonDiv = table.append("tr").append("td");
            buttonDiv.append("input").attr("type", "button").attr("value", "Remove Track").style("float", "left").style("margin-left", "5px").on("click", function () {
                $('#trackSettingDialog').fadeOut("fast");
            });
            buttonDiv.append("input").attr("type", "button").attr("value", "Cancel").style("float", "right").style("margin-left", "5px").on("click", function () {
                $('#trackSettingDialog').fadeOut("fast");
            });
        }
    };

    that.redraw = function () {
        /*for(var j=0;j<that.yArr.length;j++){
			that.yArr[j]=-299999999;
		}*/
        that.trackYMax = 0;
        that.yMaxArr = new Array();
        that.yArr = new Array();
        that.yArr[0] = new Array();
        for (var j = 0; j < that.gsvg.width; j++) {
            that.yMaxArr[j] = 0;
            that.yArr[0][j] = 0;
        }
        that.svg.selectAll("g.snp")
            .attr("transform", function (d, i) {
                var st = that.xScale(d.getAttribute("start"));
                return "translate(" + st + "," + that.calcY(parseInt(d.getAttribute("start"), 10), parseInt(d.getAttribute("stop"), 10), i) + ")";
            });
        that.svg.selectAll("g.snp rect")
            .attr("width", function (d) {
                var wX = 1;
                if (that.xScale(d.getAttribute("stop")) - that.xScale(d.getAttribute("start")) > 1) {
                    wX = that.xScale(d.getAttribute("stop")) - that.xScale(d.getAttribute("start"));
                }
                return wX;
            });
        if (that.xScale(that.xScale.domain()[0] + 1) > 6) {
            that.svg
                .selectAll(".snp").each(function (d) {
                var wX = that.xScale(d.getAttribute("stop")) - that.xScale(d.getAttribute("start"));
                var str = new String(d.getAttribute("strainSeq"));
                var font = "8px";
                var fW = 3.2;
                var fY = 8;
                if (d.getAttribute("type") != "SNP") {
                    font = "7px";
                    fW = 3;
                    fY = 7;
                }
                if (d3.select(this).selectAll("text").size() == 0 && (str.length * fW) < wX) {

                    d3.select(this).append("text")
                        .attr("y", fY)
                        .attr("x", function (d) {
                            var x = 0;
                            if (wX > 7) {
                                x = (wX / 2) - (str.length / 2 * fW);
                            }
                            return x;
                        })
                        .attr("font-size", font)
                        .attr("stroke", d3.rgb("#FFFFFF"))
                        .attr("class", "snpLbl")
                        .text(str);
                } else {
                    d3.select(this).selectAll(".snpLbl")
                        .attr("x", function (d) {
                            var x = 0;
                            if (wX > 7) {
                                x = (wX / 2) - (str.length / 2 * fW);
                            }
                            return x;
                        });
                }
            });
        } else {
            that.svg.selectAll("text.snpLbl").remove();
        }

        if (that.density == 1) {
            that.svg.attr("height", 30);
        } else if (that.density == 2) {
            that.svg.attr("height", (that.trackYMax + 1) * 15);
        } else if (that.density == 3) {
            that.svg.attr("height", (that.trackYMax + 1) * 15);
        }
        that.redrawSelectedArea();
    };


    that.color = function (d) {
        var color = d3.rgb("#000000");
        if (d.getAttribute("type") === "SNP") {
            if (d.getAttribute("strain") === "BNLX") {
                color = d3.rgb(0, 0, 255);
            } else if (d.getAttribute("strain") === "SHRH") {
                color = d3.rgb(255, 0, 0);
            } else if (d.getAttribute("strain") === "SHRJ") {
                color = d3.rgb("#00FF00");
            } else if (d.getAttribute("strain") === "F344") {
                color = d3.rgb("#00FFFF");
            } else {
                color = d3.rgb(100, 100, 100);
            }
        } else {
            if (d.getAttribute("strain") === "BNLX") {
                color = d3.rgb(0, 0, 150);
            } else if (d.getAttribute("strain") === "SHRH") {
                color = d3.rgb(150, 0, 0);
            } else if (d.getAttribute("strain") === "SHRJ") {
                color = d3.rgb("#009600");
            } else if (d.getAttribute("strain") === "F344") {
                color = d3.rgb("#009696");
            } else {
                color = d3.rgb(50, 50, 50);
            }
        }
        return color;
    };

    that.getDisplayID = function (d) {
        return d.getAttribute("type") + "_" + keySNP(d);
    }
    that.createToolTip = function (d) {
        var tooltip = "";
        var strain = d.getAttribute("strain");
        if (strain == "SHRH") {
            strain = "SHR";
        }
        tooltip = "<BR><div id=\"ttSVG\" style=\"background:#FFFFFF;\"></div><BR>Type: " + d.getAttribute("type") + "<BR>Strain: " + strain + "<BR>Sequence: " + d.getAttribute("refSeq") + "->" + d.getAttribute("strainSeq") + "<BR>Location: chr" + d.getAttribute("chromosome") + ":" + numberWithCommas(d.getAttribute("start"));
        if (d.getAttribute("type") == "SNP") {

        } else {
            tooltip = tooltip + "-" + numberWithCommas((d.getAttribute("stop")));
        }
        return tooltip;
    };

    that.update = function (d) {
        that.redraw();
    };

    that.updateData = function (retry) {
        var tag = "Snp";
        var path = dataPrefix + "tmpData/browserCache/" + genomeVer + "/regionData/" + that.gsvg.folderName + "/snp" + that.strain + ".xml";
        /*that.include=$("#"+that.trackClass+that.gsvg.levelNumber+"Select").val();
		that.density=$("#"+that.trackClass+"Dense"+that.gsvg.levelNumber+"Select").val();*/
        d3.xml(path, function (error, d) {
            if (error) {
                if (retry < 3) {//wait before trying again
                    var time = 10000;
                    if (retry == 1) {
                        time = 15000;
                    }
                    setTimeout(function () {
                        that.updateData(retry + 1);
                    }, time);
                } else if (retry >= 3) {
                    d3.select("#Level" + that.levelNumber + that.trackClass).select("#trkLbl").text("An errror occurred loading Track:" + that.trackClass);
                    d3.select("#Level" + that.levelNumber + that.trackClass).attr("height", 15);
                    that.gsvg.addTrackErrorRemove(that.svg, "#Level" + that.gsvg.levelNumber + that.trackClass);
                }
            } else {
                var snp = d.documentElement.getElementsByTagName(tag);
                var mergeddata = new Array();
                var checkName = new Array();
                var curInd = 0;
                for (var l = 0; l < snp.length; l++) {
                    if (typeof snp[l] !== 'undefined') {
                        mergeddata[curInd] = snp[l];
                        checkName[keySNP(snp[l])] = 1;
                        curInd++;
                    }
                }
                for (var l = 0; l < that.data.length; l++) {
                    if (typeof that.data[l] !== 'undefined' && typeof checkName[keySNP(that.data[l])] === 'undefined') {
                        mergeddata[curInd] = that.data[l];
                        curInd++;
                    }
                }
                that.draw(mergeddata);
                that.hideLoading();
            }
        });
    };

    that.getDisplayedData = function () {
        var dataElem = d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll(".snp");
        //that.counts=[{value:0,perc:0,names:"SNP "+that.displayStrain},{value:0,perc:0,names:"Insertion "+that.displayStrain},{value:0,perc:0,names:"Deletion "+that.displayStrain}];
        that.counts = [{value: 0, perc: 0, names: "SNP"}, {value: 0, perc: 0, names: "Insertion"}, {
            value: 0,
            perc: 0,
            names: "Deletion"
        }];
        var tmpDat = dataElem[0];
        var dispData = new Array();
        var dispDataCount = 0;
        var total = 0;
        dataElem.each(function (d) {
            var start = that.xScale(d.getAttribute("start"));
            var stop = that.xScale(d.getAttribute("stop"));
            if ((0 <= start && start <= that.gsvg.width) || (0 <= stop && stop <= that.gsvg.width)) {
                var ind = 0;
                if (d.getAttribute("type") == "Insertion") {
                    ind++;
                } else if (d.getAttribute("type") == "Deletion") {
                    ind = ind + 2;
                }
                that.counts[ind].value++;
                dispData[dispDataCount] = d;
                dispDataCount++;
                total++;
            }
        });

        return dispData;
    };

    that.draw = function (data) {

        that.data = data;
        that.trackYMax = 0;
        that.yMaxArr = new Array();
        that.yArr = new Array();
        that.yArr[0] = new Array();
        for (var j = 0; j < that.gsvg.width; j++) {
            that.yMaxArr[j] = 0;
            that.yArr[0][j] = 0;
        }
        var lbl = that.strain;
        if (lbl == "SHRH") {
            lbl = "SHR/OlaPrin";
        } else if (lbl == "BNLX") {
            lbl = "BN-Lx/CubPrin";
        } else if (lbl == "SHRJ") {
            lbl = "SHR/NCrlPrin";
        }
        if (that.include == 1) {
            lbl = lbl + " SNPs";
        } else if (that.include == 2) {
            lbl = lbl + " Insertions";
        } else if (that.include == 3) {
            lbl = lbl + " Deletions";
        } else if (that.include == 4) {
            lbl = lbl + " SNPs/Indels";
        }
        that.updateLabel(lbl);
        that.redrawLegend();
        if (that.include < 4) {
            var newData = [];
            var newCount = 0;
            for (var l = 0; l < data.length; l++) {
                if (typeof data[l] !== 'undefined') {
                    if (that.include == 1 && data[l].getAttribute("type") == "SNP") {
                        newData[newCount] = data[l];
                        newCount++;
                    } else if (that.include == 2 && data[l].getAttribute("type") == "Insertion") {
                        newData[newCount] = data[l];
                        newCount++;
                    } else if (that.include == 3 && data[l].getAttribute("type") == "Deletion") {
                        newData[newCount] = data[l];
                        newCount++;
                    }
                }
            }
            that.data = newData;
        }
        that.svg.selectAll(".snp").remove();
        if (that.data.length > 0) {
            //update
            var snps = that.svg.selectAll(".snp")
                .data(data, keySNP)
                .attr("transform", function (d, i) {
                    return "translate(" + that.xScale(d.getAttribute("start")) + "," + that.calcY(parseInt(d.getAttribute("start"), 10), parseInt(d.getAttribute("stop"), 10), i) + ")";
                });
            //add new
            snps.enter().append("g")
                .attr("class", "snp")
                .attr("transform", function (d, i) {
                    return "translate(" + that.xScale(d.getAttribute("start")) + "," + that.calcY(parseInt(d.getAttribute("start"), 10), parseInt(d.getAttribute("stop"), 10), i) + ")";
                })
                .append("rect")
                .attr("height", 10)
                .attr("rx", 1)
                .attr("ry", 1)
                .attr("width", function (d) {
                    var wX = 1;
                    if (that.xScale(d.getAttribute("stop")) - that.xScale(d.getAttribute("start")) > 1) {
                        wX = that.xScale(d.getAttribute("stop")) - that.xScale(d.getAttribute("start"));
                    }
                    return wX;
                })
                .attr("id", keySNP)
                .style("fill", that.color)
                .on("mouseover", function (d) {
                    if (that.gsvg.isToolTip == 0) {
                        d3.select(this).style("fill", "green");
                        tt.transition()
                            .duration(200)
                            .style("opacity", 1);
                        tt.html(that.createToolTip(d))
                            .style("left", function () {
                                return that.positionTTLeft(d3.event.pageX);
                            })
                            .style("top", function () {
                                return that.positionTTTop(d3.event.pageY);
                            });
                        that.setupToolTipSVG(d, 0.2);
                    }
                })
                .on("mouseout", function (d) {
                    d3.select(this).style("fill", that.color);
                    tt.transition()
                        .delay(500)
                        .duration(200)
                        .style("opacity", 0);
                });
            if (that.density == 1) {
                that.svg.attr("height", 30);
            } else if (that.density == 2) {
                that.svg.attr("height", (that.trackYMax + 1) * 15);
            } else if (that.density == 3) {
                that.svg.attr("height", (that.trackYMax + 1) * 15);
            }
            ;
            snps.merge(snps);
            snps.exit().remove();
        }
        that.redrawSelectedArea();
    };

    that.pieColor = function (d, i) {
        var color = d3.rgb("#000000");
        var tmpName = new String(d.data.names);
        //console.log(d.data.names);
        //console.log(tmpName);
        if (that.strain == "BNLX") {
            if (tmpName.indexOf("SNP") > -1) {
                color = d3.rgb(0, 0, 255);
            } else if (tmpName.indexOf("Insertion") > -1) {
                color = d3.rgb(0, 0, 175);
            } else {
                color = d3.rgb(0, 0, 125);
            }
        } else if (that.strain == "SHRJ") {
            if (tmpName.indexOf("SNP") > -1) {
                color = d3.rgb(0, 255, 0);
            } else if (tmpName.indexOf("Insertion") > -1) {
                color = d3.rgb(0, 175, 0);
            } else {
                color = d3.rgb(0, 125, 0);
            }
        } else if (that.strain == "F344") {
            if (tmpName.indexOf("SNP") > -1) {
                color = d3.rgb(0, 255, 255);
            } else if (tmpName.indexOf("Insertion") > -1) {
                color = d3.rgb(0, 175, 175);
            } else {
                color = d3.rgb(0, 125, 125);
            }
        } else if (that.strain == "SHRH") {
            if (tmpName.indexOf("SNP") > -1) {
                color = d3.rgb(255, 0, 0);
            } else if (tmpName.indexOf("Insertion") > -1) {
                color = d3.rgb(175, 0, 0);
            } else {
                color = d3.rgb(125, 0, 0);
            }
        }
        return color;
    };


    that.redrawLegend = function () {
        var legend = [];
        if (that.include == 4) {
            if (that.strain == "BNLX") {
                legend = [{color: "#0000FF", label: "SNP"}, {color: "#000096", label: "Insertion/Deletion"}];
            } else if (that.strain == "SHRH") {
                legend = [{color: "#FF0000", label: "SNP"}, {color: "#960000", label: "Insertion/Deletion"}];
            } else if (that.strain == "SHRJ") {
                legend = [{color: "#00FF00", label: "SNP"}, {color: "#009600", label: "Insertion/Deletion"}];
            } else if (that.strain == "F344") {
                legend = [{color: "#00FFFF", label: "SNP"}, {color: "#009696", label: "Insertion/Deletion"}];
            } else {
                legend = [{color: "#DEDEDE", label: "SNP"}, {color: "#969696", label: "Insertion/Deletion"}];
            }
        } else if (that.include == 3 || that.include == 2) {
            if (that.strain == "BNLX") {
                legend = [{color: "#000096", label: "Insertion/Deletion"}];
            } else if (that.strain == "SHRH") {
                legend = [{color: "#960000", label: "Insertion/Deletion"}];
            } else if (that.strain == "SHRJ") {
                legend = [{color: "#009600", label: "Insertion/Deletion"}];
            } else if (that.strain == "F344") {
                legend = [{color: "#009696", label: "Insertion/Deletion"}];
            } else {
                legend = [{color: "#969696", label: "Insertion/Deletion"}];
            }
        } else if (that.include == 1) {
            if (that.strain == "BNLX") {
                legend = [{color: "#0000FF", label: "SNP"}];
            } else if (that.strain == "SHRH") {
                legend = [{color: "#FF0000", label: "SNP"}];
            } else if (that.strain == "SHRJ") {
                legend = [{color: "#00FF00", label: "SNP"}];
            } else if (that.strain == "F344") {
                legend = [{color: "#00FFFF", label: "SNP"}];
            } else {
                legend = [{color: "#DEDEDE", label: "SNP"}];
            }
        }
        that.drawLegend(legend);
    };

    that.strain = strain;

    that.redrawLegend();
    that.draw(data);

    return that;
}

/*Track for displaying QTLs*/
function QTLTrack(gsvg, data, trackClass, density) {
    var that = Track(gsvg, data, trackClass, "QTLs Overlapping Region");

    that.color = function (name) {
        return that.pieColorPalette(name);
    };

    that.redraw = function () {

        //var qtlSvg=d3.select("#"+level+"qtl");
        var density = 2;
        that.yCount = 0;
        //var tmpYArr=new Array();
        that.idList = new Array();

        var qtls = that.svg//d3.select("#"+level+"qtl")
            .selectAll("g.qtl")
            .attr("transform", function (d, i) {
                var st = that.xScale(d.getAttribute("start"));
                return "translate(" + st + "," + that.calcY(d, i) + ")";
            });
        d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll("g.qtl rect")
            .attr("width", function (d) {
                var wX = 1;
                if (that.xScale(d.getAttribute("stop")) - that.xScale(d.getAttribute("start")) > 1) {
                    wX = that.xScale(d.getAttribute("stop")) - that.xScale(d.getAttribute("start"));
                }
                return wX;
            });

        /*var qtl=d3.select("#Level"+that.gsvg.levelNumber+that.trackClass)
										.selectAll(".qtl");*/
        /*qtls[0].forEach(function(d){
				var nameStr=d.__data__.getAttribute("name");
				var end=nameStr.indexOf("QTL")-1;
				var name=nameStr.substr(0,end);
				d3.select(d).select("rect").style("fill",that.color(name));
		});*/
        that.svg.attr("height", that.yCount * 15);
        that.redrawSelectedArea();
    };

    that.createToolTip = function (d) {
        var tooltip = "";
        tooltip = "Name: " + d.getAttribute("name") + "<BR>Location: " + d.getAttribute("chromosome") + ":" + numberWithCommas(d.getAttribute("start")) + "-" + numberWithCommas(d.getAttribute("stop")) + "<BR>Trait:<BR>" + d.getAttribute("trait") + "<BR><BR>Phenotype:<BR>" + d.getAttribute("phenotype") + "<BR><BR>Candidate Genes:<BR>" + d.getAttribute("candidate");
        return tooltip;
    };

    that.pieColorPalette = d3.scaleOrdinal(d3.schemeCategory20);

    //For Reports and Pie Chart
    that.pieColor = function (d) {
        return that.pieColorPalette(d.data.names);
    };
    that.triggerTableFilter = function (d) {
        var e = jQuery.Event("keyup");
        e.which = 32; // # Some key code value
        var filterStr = "";
        if (typeof d.getAttribute === 'undefined' || typeof d.getAttribute("ID") === 'undefined') {
            if (typeof d.data !== 'undefined' && typeof d.data.names !== 'undefined') {
                filterStr = d.data.names;
            }
        } else {//represents a track feature
            filterStr = d.getAttribute("ID");
        }
        $('#tblBQTL_filter input').val(filterStr).trigger(e);
    };
    that.clearTableFilter = function (d) {
        var e = jQuery.Event("keyup");
        e.which = 32; // # Some key code value
        $('#tblBQTL_filter input').val("").trigger(e);
    };

    that.getDisplayedData = function () {
        var dataElem = d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll(".qtl");
        that.counts = new Array();
        var countsInd = 0;
        var tmpDat = dataElem.data();
        //console.log(dataElem);
        //console.log(tmpDat);
        var dispData = new Array();
        var dispDataCount = 0;
        var total = 0;
        if (typeof tmpDat !== 'undefined') {
            for (var l = 0; l < tmpDat.length; l++) {
                var start = that.xScale(tmpDat[l].getAttribute("start"));
                var stop = that.xScale(tmpDat[l].getAttribute("stop"));
                if ((0 <= start && start <= that.gsvg.width) || (0 <= stop && stop <= that.gsvg.width) || (start <= 0 && stop >= that.gsvg.width)) {
                    var nameStr = new String(tmpDat[l].getAttribute("name"));
                    var re = /[0-9]+\s*$/g;
                    var end1 = nameStr.search(re);
                    if (end1 > -1) {
                        nameStr = nameStr.substr(0, end1);
                    }
                    re = /QTL\s*$/g;
                    end1 = nameStr.search(re);
                    if (end1 > -1) {
                        nameStr = nameStr.substr(0, end1);
                    }
                    re = /traits+\s*$/g;
                    end1 = nameStr.search(re);
                    if (end1 > -1) {
                        nameStr = nameStr.substr(0, end1 + 5);
                    }
                    var name = nameStr;
                    if (typeof that.counts[name] === 'undefined') {
                        that.counts[name] = new Object();
                        that.counts[countsInd] = that.counts[name];
                        countsInd++;
                        that.counts[name].value = 1;
                        that.counts[name].names = name;
                    } else {
                        that.counts[name].value++;
                    }
                    dispData[dispDataCount] = tmpDat[l];
                    dispDataCount++;
                    total++;
                }
            }
        }
        return dispData;
    };

    that.setupDetailedView = function (d) {
        if (!$('div#collapsableReport').is(':hidden')) {
            $('div#collapsableReport').hide();
            $("span[name='collapsableReport']").removeClass("less");
        }
        if ($('div#selectedDetailHeader').is(':hidden')) {
            $('div#selectedDetailHeader').show();
        }
        if ($('div#selectedDetail').is(':hidden')) {
            $('div#selectedDetail').show();
        }

        //No SVG to add so Hide Image and Show report
        $('div#selectedImage').hide();
        $('div#selectedReport').show();
        var jspPage = pathPrefix + "bQTLReport.jsp";
        var params = {id: d.getAttribute("ID"), species: organism, genomeVer: genomeVer};
        DisplaySelectedDetailReport(jspPage, params);

    };

    that.updateData = function (retry) {
        d3.xml(dataPrefix + "tmpData/browserCache/" + genomeVer + "/regionData/" + that.gsvg.folderName + "/qtl.xml", function (error, d) {
            if (error) {
                if (retry < 3) {//wait before trying again
                    var time = 10000;
                    if (retry == 1) {
                        time = 15000;
                    }
                    setTimeout(function () {
                        that.updateData(retry + 1);
                    }, time);
                } else {
                    d3.select("#Level" + that.levelNumber + that.trackClass).select("#trkLbl").text("An errror occurred loading Track:" + that.trackClass);
                    d3.select("#Level" + that.levelNumber + that.trackClass).attr("height", 15);
                    that.gsvg.addTrackErrorRemove(that.svg, "#Level" + that.gsvg.levelNumber + that.trackClass);
                }
            } else if (d) {
                var qtl = d.documentElement.getElementsByTagName("QTL");
                var mergeddata = new Array();
                var checkName = new Array();
                var curInd = 0;

                for (var l = 0; l < qtl.length; l++) {
                    if (typeof qtl[l] !== 'undefined') {
                        mergeddata[curInd] = qtl[l];
                        checkName[qtl[l].getAttribute("ID")] = 1;
                        curInd++;
                    }
                }
                for (var l = 0; l < that.data.length; l++) {
                    if (typeof that.data[l] !== 'undefined' && typeof checkName[that.data[l].getAttribute("ID")] === 'undefined') {
                        mergeddata[curInd] = that.data[l];
                        curInd++;
                    }
                }
                that.draw(mergeddata);
                that.hideLoading();
            } else {
                //shouldn't need this
                //that.draw(that.data);
                that.hideLoading();
            }
        });
    };

    that.calcY = function (d, i) {
        var ret = 0;
        if (typeof that.idList[d.getAttribute("ID")] === "undefined") {
            ret = that.yCount++;
        }
        return (ret + 1) * 15;
    }
    that.draw = function (data) {

        that.data = data;
        that.yCount = 0;
        that.idList = new Array();
        //update
        //that.svg.selectAll(".qtl").remove();
        if (that.data && that.data.length > 0) {
            //console.log(that.svg);
            //console.log(that.svg.selectAll(".qtl"));

            var qtls = that.svg.selectAll(".qtl")
                .data(data, key);
            //		.attr("transform",function(d,i){ return "translate("+that.xScale(d.getAttribute("start"))+","+that.calcY(d,i)+")";});
            //console.log(qtls);
            //add new
            qtls.enter().append("g")
                .attr("class", "qtl")
                .attr("transform", function (d, i) {
                    return "translate(" + that.xScale(d.getAttribute("start")) + "," + that.calcY(d, i) + ")";
                })
                .append("rect")
                .attr("height", 10)
                .attr("rx", 1)
                .attr("ry", 1)
                .attr("width", function (d) {
                    var wX = 1;
                    if (that.xScale(d.getAttribute("stop")) - that.xScale(d.getAttribute("start")) > 1) {
                        wX = that.xScale(d.getAttribute("stop")) - that.xScale(d.getAttribute("start"));
                    }
                    return wX;
                })
                .attr("id", function (d) {
                    return d.getAttribute("id");
                })
                .style("fill", "blue")
                .style("cursor", "pointer")
                //.on("mouseover", that.onMouseOver)
                //.on("mouseout", that.onMouseOut);
                .on("click", that.setupDetailedView)
                .on("mouseover", function (d) {
                    if (that.gsvg.isToolTip == 0) {
                        overSelectable = 1;
                        $("#mouseHelp").html("<B>Click</B> to see additional details. <B>Double Click</B> to zoom in on this feature.");
                        d3.select(this).style("fill", "green");
                        tt.transition()
                            .duration(200)
                            .style("opacity", 1);
                        tt.html(that.createToolTip(d))
                            .style("left", function () {
                                return that.positionTTLeft(d3.event.pageX);
                            })
                            .style("top", function () {
                                return that.positionTTTop(d3.event.pageY);
                            });
                        that.triggerTableFilter(d);
                    }
                })
                .on("mouseout", function (d) {
                    overSelectable = 0;
                    $("#mouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
                    var nameStr = d.getAttribute("name");
                    var re = /[0-9]+\s*$/g;
                    var end1 = nameStr.search(re);
                    if (end1 > -1) {
                        nameStr = nameStr.substr(0, end1);
                    }
                    re = /QTL\s*$/g;
                    end1 = nameStr.search(re);
                    if (end1 > -1) {
                        nameStr = nameStr.substr(0, end1);
                    }
                    re = /traits?\s*$/g;
                    end1 = nameStr.search(re);
                    if (end1 > -1) {
                        nameStr = nameStr.substr(0, end1 + 5);
                    }
                    var name = nameStr;
                    d3.select(this).style("fill", that.color(name));
                    tt.transition()
                        .delay(500)
                        .duration(200)
                        .style("opacity", 0);
                    that.clearTableFilter(d);
                }).merge(qtls);

            qtls.exit().remove();


            if (typeof qtls[0] !== 'undefined') {
                qtls[0].forEach(function (d) {
                    if (typeof d !== 'undefined') {
                        var nameStr = new String(d.data().getAttribute("name"));
                        var re = /[0-9]+\s*$/g;
                        var end1 = nameStr.search(re);
                        if (end1 > -1) {
                            nameStr = nameStr.substr(0, end1);
                        }
                        re = /QTL\s*$/g;
                        end1 = nameStr.search(re);
                        if (end1 > -1) {
                            nameStr = nameStr.substr(0, end1);
                        }
                        re = /traits?\s*$/g;
                        end1 = nameStr.search(re);
                        if (end1 > -1) {
                            nameStr = nameStr.substr(0, end1 + 5);
                        }
                        var name = nameStr;
                        d3.select(d).select("rect").style("fill", that.color(name));
                    }
                });
            }
            that.svg.attr("height", that.yCount * 15);
            //that.getDisplayedData();

        } else {
            that.svg.attr("height", 15);
        }
        that.redrawSelectedArea();
    };
    that.draw(data);
    that.redraw();
    return that;
}

/*Track to display transcripts for a selected Gene*/
function TranscriptTrack(gsvg, data, trackClass, density) {
    var that = Track(gsvg, data, trackClass, "Selected Gene Transcripts");

    that.createToolTip = function (d) {
        var tooltip = "";
        var strand = ".";
        if (d.getAttribute("strand") == 1) {
            strand = "+";
        } else if (d.getAttribute("strand") == -1) {
            strand = "-";
        }
        var id = d.getAttribute("ID");
        tooltip = "ID: " + id + "<BR>Location: chr" + d.getAttribute("chromosome") + ":" + numberWithCommas(d.getAttribute("start")) + "-" + numberWithCommas(d.getAttribute("stop")) + "<BR>Strand: " + strand;
        if (new String(d.getAttribute("ID")).indexOf("ENS") == -1) {
            var annot = getFirstChildByName(getFirstChildByName(d, "annotationList"), "annotation");
            if (annot != null) {
                tooltip += "<BR>Matching: " + annot.getAttribute("reason");
            }
        }
        return tooltip;
    };

    that.color = function (d) {
        var color = d3.rgb("#000000");
        if (that.gsvg.txType == "protein") {
            if ((new String(d.getAttribute("ID"))).indexOf("ENS") > -1) {
                color = d3.rgb("#DFC184");
            } else {
                color = d3.rgb("#7EB5D6");
            }
        } else if (that.gsvg.txType == "long") {
            if ((new String(d.getAttribute("ID"))).indexOf("ENS") > -1) {
                color = d3.rgb("#B58AA5");
            } else {
                color = d3.rgb("#CECFCE");
            }
        } else if (that.gsvg.txType == "small") {
            if ((new String(d.getAttribute("ID"))).indexOf("ENS") > -1) {
                color = d3.rgb("#FFCC00");
            } else {
                color = d3.rgb("#99CC99");
            }
        } else if (that.gsvg.txType == "liverTotal") {
            color = d3.rgb("#bbbedd");
        } else if (that.gsvg.txType == "heartTotal") {
            color = d3.rgb("#DC7252");
        } else if (that.gsvg.txType == "mergedTotal") {
            color = d3.rgb("#9F4F92");
        }
        return color;
    };

    that.drawTrx = function (d, i) {
        var cdsStart = parseInt(d.getAttribute("start"), 10);
        var cdsStop = parseInt(d.getAttribute("stop"), 10);
        if (typeof d.getAttribute("cdsStart") !== 'undefined' && typeof d.getAttribute("cdsStop") !== 'undefined') {
            cdsStart = parseInt(d.getAttribute("cdsStart"), 10);
            cdsStop = parseInt(d.getAttribute("cdsStop"), 10);
        }

        var txG = d3.select("#Level" + that.gsvg.levelNumber + that.trackClass + " #tx" + d.getAttribute("ID"));
        exList = getAllChildrenByName(getFirstChildByName(d, "exonList"), "exon");
        for (var m = 0; m < exList.length; m++) {
            var exStrt = parseInt(exList[m].getAttribute("start"), 10);
            var exStp = parseInt(exList[m].getAttribute("stop"), 10);
            if ((exStrt < cdsStart && cdsStart < exStp) || (exStp > cdsStop && cdsStop > exStrt)) {//need to draw two rect one for CDS and one non CDS
                var xPos1 = 0;
                var xWidth1 = 0;
                var xPos2 = 0;
                var xWidth2 = 0;
                if (exStrt < cdsStart) {
                    xPos1 = that.xScale(exList[m].getAttribute("start"));
                    xWidth1 = that.xScale(cdsStart) - that.xScale(exList[m].getAttribute("start"));
                    xPos2 = that.xScale(cdsStart);
                    xWidth2 = that.xScale(exList[m].getAttribute("stop")) - that.xScale(cdsStart);
                } else if (exStp > cdsStop) {
                    xPos2 = that.xScale(exList[m].getAttribute("start"));
                    xWidth2 = that.xScale(cdsStop) - that.xScale(exList[m].getAttribute("start"));
                    xPos1 = that.xScale(cdsStop);
                    xWidth1 = that.xScale(exList[m].getAttribute("stop")) - that.xScale(cdsStop);
                }
                txG.append("rect")//non CDS
                    .attr("x", xPos1)
                    .attr("y", 2.5)
                    .attr("height", 5)
                    .attr("width", xWidth1)
                    .attr("title", function (d) {
                        return exList[m].getAttribute("ID");
                    })
                    .attr("id", function (d) {
                        return "ExNC" + exList[m].getAttribute("ID");
                    })
                    .style("fill", that.color)
                    .style("cursor", "pointer");
                txG.append("rect")//CDS
                    .attr("x", xPos2)
                    .attr("height", 10)
                    .attr("width", xWidth2)
                    .attr("title", function (d) {
                        return exList[m].getAttribute("ID");
                    })
                    .attr("id", function (d) {
                        return "Ex" + exList[m].getAttribute("ID");
                    })
                    .style("fill", that.color)
                    .style("cursor", "pointer");

            } else {
                var height = 10;
                var y = 0;
                if ((exStrt < cdsStart && exStp < cdsStart) || (exStp > cdsStop && exStrt > cdsStop)) {
                    height = 5;
                    y = 2.5;
                }
                txG.append("rect")
                    .attr("x", function (d) {
                        return that.xScale(exList[m].getAttribute("start"));
                    })
                    .attr("y", y)
                    //.attr("rx",1)
                    //.attr("ry",1)
                    .attr("height", height)
                    .attr("width", function (d) {
                        return that.xScale(exList[m].getAttribute("stop")) - that.xScale(exList[m].getAttribute("start"));
                    })
                    .attr("title", function (d) {
                        return exList[m].getAttribute("ID");
                    })
                    .attr("id", function (d) {
                        return "Ex" + exList[m].getAttribute("ID");
                    })
                    .style("fill", that.color)
                    .style("cursor", "pointer");
            }
            /*txG.append("rect")
			.attr("x",function(d){ return that.xScale(exList[m].getAttribute("start")); })
			.attr("rx",1)
			.attr("ry",1)
	    	.attr("height",10)
			.attr("width",function(d){ return that.xScale(exList[m].getAttribute("stop")) - that.xScale(exList[m].getAttribute("start")); })
			.attr("title",function(d){ return exList[m].getAttribute("ID");})
			.attr("id",function(d){return "Ex"+exList[m].getAttribute("ID");})
			.style("fill",that.color)
			.style("cursor", "pointer");*/
            if (m > 0) {
                txG.append("line")
                    .attr("x1", function (d) {
                        return that.xScale(exList[m - 1].getAttribute("stop"));
                    })
                    .attr("x2", function (d) {
                        return that.xScale(exList[m].getAttribute("start"));
                    })
                    .attr("y1", 5)
                    .attr("y2", 5)
                    .attr("id", function (d) {
                        return "Int" + exList[m - 1].getAttribute("ID") + "_" + exList[m].getAttribute("ID");
                    })
                    .attr("stroke", that.color)
                    .attr("stroke-width", "2");
                var strChar = ">";
                if (d.getAttribute("strand") == "-1") {
                    strChar = "<";
                }
                var fullChar = strChar;
                var intStart = that.xScale(exList[m - 1].getAttribute("stop"));
                var intStop = that.xScale(exList[m].getAttribute("start"));
                var rectW = intStop - intStart;
                var alt = 0;
                var charW = 7.0;
                if (rectW < charW) {
                    fullChar = "";
                } else {
                    rectW = rectW - charW;
                    while (rectW > (charW + 1)) {
                        if (alt == 0) {
                            fullChar = fullChar + " ";
                            alt = 1;
                        } else {
                            fullChar = fullChar + strChar;
                            alt = 0;
                        }
                        rectW = rectW - charW;
                    }
                }
                txG.append("svg:text").attr("id", function (d) {
                    return "IntTxt" + exList[m - 1].getAttribute("ID") + "_" + exList[m].getAttribute("ID");
                }).attr("dx", intStart + 1)
                    .attr("dy", "11")
                    .style("pointer-events", "none")
                    .style("opacity", "0.5")
                    .style("fill", that.color)
                    .style("font-size", "16px")
                    .text(fullChar);

            }
        }

    };

    that.redraw = function () {

        var txG = d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll("g.trx" + that.gsvg.levelNumber);
        //var txG=that.svg.selectAll("g.trx"+that.gsvg.levelNumber);

        txG//.attr("transform",function(d,i){ return "translate("+txXScale(d.getAttribute("start"))+","+i*15+")";})
            .each(function (d, i) {
                var cdsStart = parseInt(d.getAttribute("start"), 10);
                var cdsStop = parseInt(d.getAttribute("stop"), 10);
                if (typeof d.getAttribute("cdsStart") !== 'undefined' && typeof d.getAttribute("cdsStop") !== 'undefined') {
                    cdsStart = parseInt(d.getAttribute("cdsStart"), 10);
                    cdsStop = parseInt(d.getAttribute("cdsStop"), 10);
                }
                exList = getAllChildrenByName(getFirstChildByName(d, "exonList"), "exon");
                var pref = "tx";
                for (var m = 0; m < exList.length; m++) {
                    var exStrt = parseInt(exList[m].getAttribute("start"), 10);
                    var exStp = parseInt(exList[m].getAttribute("stop"), 10);
                    if ((exStrt < cdsStart && cdsStart < exStp) || (exStp > cdsStop && cdsStop > exStrt)) {
                        var ncStrt = exStrt;
                        var ncStp = cdsStart;
                        if (exStp > cdsStop) {
                            ncStrt = cdsStop;
                            ncStp = exStp;
                            exStrt = exStrt;
                            exStp = cdsStop;
                        } else {
                            exStrt = cdsStart;
                            exStp = exStp;
                        }
                        d3.select("#Level" + that.gsvg.levelNumber + that.trackClass + " g#" + pref + d.getAttribute("ID") + " rect#ExNC" + exList[m].getAttribute("ID"))
                            .attr("x", function (d) {
                                return that.xScale(ncStrt);
                            })
                            .attr("width", function (d) {
                                return that.xScale(ncStp) - that.xScale(ncStrt);
                            });
                    }
                    d3.select("#Level" + that.gsvg.levelNumber + that.trackClass + " g#" + pref + d.getAttribute("ID") + " rect#Ex" + exList[m].getAttribute("ID"))
                        .attr("x", function (d) {
                            return that.xScale(exStrt);
                        })
                        .attr("width", function (d) {
                            return that.xScale(exStp) - that.xScale(exStrt);
                        });
                    if (m > 0) {
                        var strChar = ">";
                        if (d.getAttribute("strand") == "-1") {
                            strChar = "<";
                        }
                        var fullChar = strChar;
                        var intStart = that.xScale(exList[m - 1].getAttribute("stop"));
                        var intStop = that.xScale(exList[m].getAttribute("start"));
                        var rectW = intStop - intStart;
                        var alt = 0;
                        var charW = 7.0;
                        if (rectW < charW) {
                            fullChar = "";
                        } else {
                            rectW = rectW - charW;
                            while (rectW > (charW + 1)) {
                                if (alt == 0) {
                                    fullChar = fullChar + " ";
                                    alt = 1;
                                } else {
                                    fullChar = fullChar + strChar;
                                    alt = 0;
                                }
                                rectW = rectW - charW;
                            }
                        }
                        d3.select("#Level" + that.gsvg.levelNumber + that.trackClass + " g#tx" + d.getAttribute("ID") + " line#Int" + exList[m - 1].getAttribute("ID") + "_" + exList[m].getAttribute("ID"))
                            .attr("x1", intStart)
                            .attr("x2", intStop);

                        d3.select("#Level" + that.gsvg.levelNumber + that.trackClass + " g#tx" + d.getAttribute("ID") + " #IntTxt" + exList[m - 1].getAttribute("ID") + "_" + exList[m].getAttribute("ID"))
                            .attr("dx", intStart + 1).text(fullChar);
                    }
                }
            });
        that.redrawSelectedArea();
    };

    that.update = function () {
        var txList = getAllChildrenByName(getFirstChildByName(that.gsvg.selectedData, "TranscriptList"), "Transcript");
        var min = parseInt(that.gsvg.selectedData.getAttribute("start"), 10);
        var max = parseInt(that.gsvg.selectedData.getAttribute("stop"), 10);
        if (typeof that.gsvg.selectedData.getAttribute("extStart") !== 'undefined' && typeof that.gsvg.selectedData.getAttribute("extStop") !== 'undefined') {
            min = parseInt(that.gsvg.selectedData.getAttribute("extStart"), 10);
            max = parseInt(that.gsvg.selectedData.getAttribute("extStop"), 10);
        }
        that.txMin = min;
        that.txMax = max;
        that.svg.attr("height", (1 + txList.length) * 15);
        d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll(".trx" + that.gsvg.levelNumber).remove();
        var tx = d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll(".trx" + that.gsvg.levelNumber)
            .data(txList, key)
            .attr("transform", function (d, i) {
                return "translate(" + that.xScale(d.getAttribute("start")) + "," + that.calcY(d, i) + ")";
            });

        tx.enter().append("g")
            .attr("class", "trx" + that.gsvg.levelNumber)
            //.attr("transform",function(d,i){ return "translate("+txXScale(d.getAttribute("start"))+","+i*15+")";})
            .attr("transform", function (d, i) {
                return "translate(0," + that.calcY(d, i) + ")";
            })
            .attr("id", function (d) {
                return d.getAttribute("ID");
            })
            //.attr("pointer-events", "all")
            .style("cursor", "pointer")
            .on("mouseover", function (d) {
                if (that.gsvg.isToolTip == 0) {
                    d3.select(this).selectAll("line").style("stroke", "green");
                    d3.select(this).selectAll("rect").style("fill", "green");
                    d3.select(this).selectAll("text").style("opacity", "0.3").style("fill", "green");
                    tt.transition()
                        .duration(200)
                        .style("opacity", 1);
                    tt.html(that.createToolTip(d))
                        .style("left", function () {
                            return that.positionTTLeft(d3.event.pageX);
                        })
                        .style("top", function () {
                            return that.positionTTTop(d3.event.pageY);
                        });
                }
            })
            .on("mouseout", function (d) {
                d3.select(this).selectAll("line").style("stroke", that.color);
                d3.select(this).selectAll("rect").style("fill", that.color);
                d3.select(this).selectAll("text").style("opacity", "0.6").style("fill", that.color);
                tt.transition()
                    .delay(500)
                    .duration(200)
                    .style("opacity", 0);
            })
            .each(that.drawTrx);


        tx.exit().remove();
        that.svg.selectAll(".legend").remove();
        var legend = [];
        if (that.gsvg.txType == "protein") {
            legend = [{color: "#DFC184", label: "Ensembl"}, {color: "#7EB5D6", label: "RNA-Seq"}];
        } else if (that.gsvg.txType == "long") {
            legend = [{color: "#B58AA5", label: "Ensembl"}, {color: "#CECFCE", label: "RNA-Seq"}];
        } else if (that.gsvg.txType == "small") {
            legend = [{color: "#FFCC00", label: "Ensembl"}, {color: "#99CC99", label: "RNA-Seq"}];
        } else if (that.gsvg.txType == "liverTotal") {
            legend = [{color: "#bbbedd", label: "Liver RNA-Seq"}];
        } else if (that.gsvg.txType == "mergedTotal") {
            legend = [{color: "#9F4F92", label: "Merged RNA-Seq"}];
        }

        that.drawLegend(legend);
    };

    that.calcY = function (d, i) {
        return (i + 1) * 15;
    }

    that.redrawLegend = function () {
    };
    if (typeof that.gsvg.selectedData.getAttribute("extStart") !== 'undefined') {
        that.txMin = parseInt(that.gsvg.selectedData.getAttribute("extStart"), 10);
        that.txMax = parseInt(that.gsvg.selectedData.getAttribute("extStop"), 10);
    } else {
        that.txMin = parseInt(that.gsvg.selectedData.getAttribute("start"), 10);
        that.txMax = parseInt(that.gsvg.selectedData.getAttribute("stop"), 10);
    }
    d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).attr("height", (1 + data.length) * 15);
    d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll(".trx" + that.gsvg.levelNumber).remove();
    var tx = d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll(".trx" + that.gsvg.levelNumber)
        .data(data, key)
        .attr("transform", function (d, i) {
            return "translate(" + that.xScale(d.getAttribute("start")) + "," + that.calcY(d, i) + ")";
        });

    tx.enter().append("g")
        .attr("class", "trx" + that.gsvg.levelNumber)
        //.attr("transform",function(d,i){ return "translate("+txXScale(d.getAttribute("start"))+","+i*15+")";})
        .attr("transform", function (d, i) {
            return "translate(0," + that.calcY(d, i) + ")";
        })
        .attr("id", function (d) {
            return "tx" + d.getAttribute("ID");
        })
        //.attr("pointer-events", "all")
        .style("cursor", "pointer")
        .on("mouseover", function (d) {
            if (that.gsvg.isToolTip == 0) {
                d3.select(this).selectAll("line").style("stroke", "green");
                d3.select(this).selectAll("rect").style("fill", "green");
                d3.select(this).selectAll("text").style("opacity", "0.3").style("fill", "green");
                tt.transition()
                    .duration(200)
                    .style("opacity", 1);
                tt.html(that.createToolTip(d))
                    .style("left", function () {
                        return that.positionTTLeft(d3.event.pageX);
                    })
                    .style("top", function () {
                        return that.positionTTTop(d3.event.pageY);
                    });
            }
        })
        .on("mouseout", function (d) {
            d3.select(this).selectAll("line").style("stroke", that.color);
            d3.select(this).selectAll("rect").style("fill", that.color);
            d3.select(this).selectAll("text").style("opacity", "0.6").style("fill", that.color);
            tt.transition()
                .delay(500)
                .duration(200)
                .style("opacity", 0);
        })
        .each(that.drawTrx);


    tx.exit().remove();
    that.redrawLegend();
    that.scaleSVG.transition()
        .duration(300)
        .style("opacity", 1);
    that.svg.transition()
        .duration(300)
        .style("opacity", 1);
    that.redraw();
    return that;
}

/* Setup specific count tracks*/
function HelicosTrack(gsvg, data, trackClass, density) {
    var that = CountTrack(gsvg, data, trackClass, density);
    that.graphColorText = "#DD0000";
    var lbl = "Brain Helicos RNA Read Counts";
    that.updateLabel(lbl);
    that.redrawLegend();
    that.redraw();
    return that;
}

function IlluminaSmallTrack(gsvg, data, trackClass, density) {
    var that = CountTrack(gsvg, data, trackClass, density);
    that.graphColorText = "#99CC99";
    var lbl = "Brain Illumina Small RNA Read Counts";
    that.updateLabel(lbl);
    that.redrawLegend();
    that.redraw();
    that.redraw();
    return that;
}

function IlluminaTotalTrack(gsvg, data, trackClass, density) {
    var that = CountTrack(gsvg, data, trackClass, density);
    var lbl = "BNLx/SHR Brain Illumina Total-RNA(rRNA depleted) Read Counts";
    that.updateLabel(lbl);
    that.redrawLegend();
    return that;
}

function LiverIlluminaTotalPlusTrack(gsvg, data, trackClass, density) {
    var that = CountTrack(gsvg, data, trackClass, density);
    that.graphColorText = "#abaecd";
    var lbl = "BNLx/SHR Liver + Strand Total-RNA Read Counts";
    that.updateLabel(lbl);
    that.redrawLegend();
    that.redraw();
    return that;
}

function LiverIlluminaTotalMinusTrack(gsvg, data, trackClass, density) {
    var that = CountTrack(gsvg, data, trackClass, density);
    that.graphColorText = "#dbdefd";
    var lbl = "BNLx/SHR Liver - Strand Total-RNA Read Counts";
    that.updateLabel(lbl);
    that.redrawLegend();
    that.redraw();
    return that;
}

function LiverIlluminaSmallTrack(gsvg, data, trackClass, density) {
    var that = CountTrack(gsvg, data, trackClass, density);
    that.graphColorText = "#7b7e9d";
    var lbl = "Liver  Illumina Small RNA Read Counts";
    that.updateLabel(lbl);
    that.redrawLegend();
    that.redraw();
    return that;
}

function HeartIlluminaTotalPlusTrack(gsvg, data, trackClass, density) {
    var that = CountTrack(gsvg, data, trackClass, density);
    that.graphColorText = "#CC6242";
    var lbl = "BNLx/SHR Heart + Strand Total-RNA Read Counts";
    that.updateLabel(lbl);
    that.redrawLegend();
    that.redraw();
    return that;
}

function HeartIlluminaTotalMinusTrack(gsvg, data, trackClass, density) {
    var that = CountTrack(gsvg, data, trackClass, density);
    that.graphColorText = "#FC9272";
    var lbl = "BNLx/SHR Heart - Strand Total-RNA Read Counts";
    that.updateLabel(lbl);
    that.redrawLegend();
    that.redraw();
    return that;
}

function HeartIlluminaSmallTrack(gsvg, data, trackClass, density) {
    var that = CountTrack(gsvg, data, trackClass, density);
    that.graphColorText = "#9C3212";
    var lbl = "Heart Illumina Small RNA Read Counts";
    that.updateLabel(lbl);
    that.redrawLegend();
    that.redraw();
    return that;
}

function BrainIlluminaTotalPlusTrack(gsvg, data, trackClass, density) {
    var that = CountTrack(gsvg, data, trackClass, density);
    that.graphColorText = "#7EB5D6";
    var lbl = "Brain + Strand Total-RNA Read Counts";
    that.updateLabel(lbl);
    that.redrawLegend();
    that.redraw();
    return that;
}

function BrainIlluminaTotalMinusTrack(gsvg, data, trackClass, density) {
    var that = CountTrack(gsvg, data, trackClass, density);
    //that.graphColorText="#CC6242";
    var lbl = "Brain - Strand Total-RNA Read Counts";
    that.updateLabel(lbl);
    that.redrawLegend();
    that.redraw();
    return that;
}

function StrainSpecificIlluminaTotalTrack(gsvg, data, trackClass, density, additionalOptions) {
    var that = CountTrack(gsvg, data, trackClass, density, additionalOptions);
    var strain = trackClass.substr(trackClass.indexOf("-") + 1);
    var strand = ".";
    if (trackClass.indexOf("Plus") > 0) {
        strand = "+";
    } else if (trackClass.indexOf("Minus") > 0) {
        strand = "-";
    }
    var tissue = trackClass.substr(0, trackClass.indexOf("illumina"));
    if (tissue === "brain") {
        tissue = "Whole Brain";
    } else if (tissue === "liver") {
        tissue = "Liver";
    }
    that.graphColorText = gsvg.strainSpecificCountColors(strain);
    var sampTxt = "";
    if (that.countType === 2) {
        sampTxt = " Sampled";
    }
    var lbl = strain + " " + tissue + " " + strand + " Strand Total-RNA" + sampTxt + " Read Counts";
    that.updateLabel(lbl);
    that.redrawLegend();
    that.redraw();
    return that;
}

function IlluminaPolyATrack(gsvg, data, trackClass, density) {
    var that = CountTrack(gsvg, data, trackClass, density);
    that.graphColorText = "#7EB5D6";
    var lbl = "Brain Illumina PolyA+ RNA Read Counts";
    that.updateLabel(lbl);
    that.redrawLegend();
    that.redraw();
    return that;
}

function SpliceJunctionTrack(gsvg, data, trackClass, label, density, additionalOptions) {
    var that = GenericTranscriptTrack(gsvg, data, trackClass, label, density, additionalOptions);

    that.dataFileName = trackClass + ".xml";
    that.xmlTag = "Feature";
    that.xmlTagBlockElem = "block";
    that.idPrefix = "splcJnct";
    if (trackClass === "liverspliceJnct") {
        that.idPrefix = "lvrsplcJnct";
    } else if (trackClass === "heartspliceJnct") {
        that.idPrefix = "hrtsplcJnct";
    }
    that.ttSVG = 1;
    that.ttTrackList = new Array();
    that.ttTrackList.push(trackClass);
    /*that.ttTrackList[0]="liverspliceJnct";
	if(trackClass=="spliceJnct"){
		that.ttTrackList[0]="splcJnct";
	}*/
    that.ttTrackList.push("ensemblcoding");
    that.ttTrackList.push("braincoding");
    that.ttTrackList.push("brainTotal");
    that.ttTrackList.push("liverTotal");
    that.ttTrackList.push("heartTotal");
    that.ttTrackList.push("kidneyTotal");
    that.ttTrackList.push("mergedTotal");
    that.ttTrackList.push("brainIso");
    that.ttTrackList.push("liverIso");
    that.ttTrackList.push("refSeq");
    that.ttTrackList.push("repeatMask");
    if (trackClass === "splcJnct") {
        that.ttTrackList.push("illuminaPolyA");
    } else if (trackClass === "liverspliceJnct") {
        that.ttTrackList.push("liverilluminaTotalPlus");
        that.ttTrackList.push("liverilluminaTotalMinus");
    } else if (trackClass === "heartspliceJnct") {
        that.ttTrackList.push("heartilluminaTotalPlus");
        that.ttTrackList.push("heartilluminaTotalMinus");
    } else if (trackClass === "brainspliceJnct") {
        that.ttTrackList.push("brainilluminaTotalPlus");
        that.ttTrackList.push("brainilluminaTotalMinus");
    }
    that.colorValueField = "readCount";
    that.colorScale = d3.scaleLinear().domain([1, 1000]).range(["#E6E6E6", "#000000"]);
    that.legendLbl = "Read Depth";
    that.density = 3;

    //console.log("Splice Junction TRACK:"+that.trackClass);

    that.getDisplayID = function (d) {
        return d.getAttribute("name");
    };

    that.createToolTip = function (d) {
        var tooltip = "";
        tooltip = tooltip + "<BR><div id=\"ttSVG\" style=\"background:#FFFFFF;\"></div><BR>ID: " + d.getAttribute("name");
        tooltip = tooltip + "<BR>Read Counts=" + numberWithCommas(d.getAttribute("readCount"));
        tooltip = tooltip + "<BR>Splice Junction in " + d.getAttribute("sampleCount") + " of ";
        if (organism === 'Rn') {
            tooltip = tooltip + "6 samples(3 BN-Lx, 3 SHR)";
        } else if (organism === 'Mm') {
            tooltip = tooltip + "6 samples(3 ILS, 3 ISS)";
        }
        var bList = getAllChildrenByName(getFirstChildByName(d, "blockList"), "block");
        var exon1 = 0;
        var exon2 = 1;
        var first = "start";
        var second = "stop";
        if (d.getAttribute("strand") == -1) {
            exon1 = 1;
            exon2 = 0;
            first = "stop";
            second = "start";
        }
        tooltip = tooltip + "<BR><BR>Coverage Exon 1: " + numberWithCommas(bList[exon1].getAttribute(first)) + "-" + numberWithCommas(bList[exon1].getAttribute(second)) + " (" + (parseInt(bList[exon1].getAttribute("stop"), 10) - parseInt(bList[exon1].getAttribute("start"), 10)) + " bp)";
        tooltip = tooltip + "<BR>Coverage Exon 2: " + numberWithCommas(bList[exon2].getAttribute(first)) + "-" + numberWithCommas(bList[exon2].getAttribute(second)) + " (" + (parseInt(bList[exon2].getAttribute("stop"), 10) - parseInt(bList[exon2].getAttribute("start"), 10)) + " bp)";
        tooltip = tooltip + "<BR>Intron: " + numberWithCommas((parseInt(bList[1].getAttribute("start"), 10) - parseInt(bList[0].getAttribute("stop"), 10))) + " bp<BR>";
        return tooltip;
    };

    that.drawScaleLegend("1", "1000+", "Read Counts", "#E6E6E6", "#000000", 0);
    that.draw(data);
    return that;
}

function CustomCountTrack(gsvg, data, trackClass, density, additionalOptions) {
    var that = CountTrack(gsvg, data, trackClass, density, additionalOptions);
    that.graphColorText = "#4E85A6";
    that.updateControl = 0;
    var lbl = "Custom Count Track";


    that.updateFullData = function (retry, force) {
        if (that.updateControl == retry) {
            that.updateControl = retry + 1;
            var tmpMin = that.xScale.domain()[0];
            var tmpMax = that.xScale.domain()[1];
            var len = tmpMax - tmpMin;

            that.showLoading();
            that.bin = that.calculateBin(len);
            var tag = "Count";
            var file = dataPrefix + "tmpData/trackXML/" + that.gsvg.folderName + "/tmp/" + tmpMin + "_" + tmpMax + ".count." + that.trackClass + ".xml";
            var bedFile = dataPrefix + "tmpData/trackUpload/" + that.trackClass.substr(6);
            var type = "bg";
            var web = "";
            if (that.bin > 0) {
                tmpMin = tmpMin - (that.bin * 2);
                tmpMin = tmpMin - (tmpMin % (that.bin * 2));
                tmpMax = tmpMax + (that.bin * 2);
                tmpMax = tmpMax + (that.bin * 2 - (tmpMax % (that.bin * 2)));
                file = dataPrefix + "tmpData/trackXML/" + that.gsvg.folderName + "/" + tmpMin + "_" + tmpMax + ".bincount." + that.bin + "." + that.trackClass + ".xml";
            }
            if (that.dataFileName.indexOf("http") > -1) {
                //file=dataPrefix+"tmpData/trackXML/"+that.gsvg.folderName+"/count"+that.trackClass+".xml";
                bedFile = that.dataFileName;
                web = that.dataFileName;
                type = "bw";
            }

            d3.xml(file, function (error, d) {
                if (error) {
                    if (retry == 0 || force == 1) {
                        var tmpContext = "/" + pathPrefix;
                        if (!pathPrefix) {
                            tmpContext = "";
                        }
                        $.ajax({
                            url: tmpContext + "generateTrackXML.jsp",
                            type: 'GET',
                            cache: false,
                            async: true,
                            data: {
                                chromosome: chr,
                                minCoord: tmpMin,
                                maxCoord: tmpMax,
                                myOrganism: organism,
                                genomeVer: genomeVer,
                                dataVer: dataVer,
                                track: that.trackClass,
                                bedFile: bedFile,
                                outFile: file,
                                folder: that.gsvg.folderName,
                                binSize: that.bin,
                                type: type,
                                web: web
                            },
                            //data: {chromosome: chr,minCoord:minCoord,maxCoord:maxCoord,panel:panel,rnaDatasetID:rnaDatasetID,arrayTypeID: arrayTypeID, myOrganism: organism, track: that.trackClass, folder: folderName,binSize:that.bin},
                            dataType: 'json',
                            success: function (data2) {
                                //console.log("generateTrack:DONE");
                                /*if(ga){
															ga('send','event','browser','generateTrackCount');
														}*/
                                gtag('event', 'generateTrackCount', {'event_category': 'browser'});
                            },
                            error: function (xhr, status, error) {

                            }
                        });
                    }
                    //console.log(error);
                    if (retry < 8) {//wait before trying again
                        var time = 500;
                        /*if(retry==0){
									time=10000;
								}*/
                        that.fullDataTimeOutHandle = setTimeout(function () {
                            that.updateFullData(retry + 1);
                        }, time);
                    } else if (retry < 30) {
                        var time = 1000;
                        that.fullDataTimeOutHandle = setTimeout(function () {
                            that.updateFullData(retry + 1);
                        }, time);
                    } else if (retry < 32) {
                        var time = 10000;
                        that.fullDataTimeOutHandle = setTimeout(function () {
                            that.updateFullData(retry + 1);
                        }, time);
                    } else {
                        d3.select("#Level" + that.levelNumber + that.trackClass).select("#trkLbl").text("An errror occurred loading Track:" + that.trackClass);
                        d3.select("#Level" + that.levelNumber + that.trackClass).attr("height", 15);
                        that.gsvg.addTrackErrorRemove(that.svg, "#Level" + that.gsvg.levelNumber + that.trackClass);
                        that.hideLoading();
                        that.fullDataTimeOutHandle = setTimeout(function () {
                            that.updateFullData(retry + 1, 0);
                        }, 15000);
                    }
                } else {
                    //console.log("no error");
                    //console.log(d);
                    if (d == null) {
                        //console.log("")
                        if (retry >= 32) {
                            data = new Array();
                            that.draw(data);
                            //that.hideLoading();
                        } else {
                            that.fullDataTimeOutHandle = setTimeout(function () {
                                that.updateFullData(retry + 1, 0);
                            }, 5000);
                        }
                    } else {
                        that.fullDataTimeOutHandle = 0;
                        that.loadedDataMin = tmpMin;
                        that.loadedDataMax = tmpMax;
                        var data = d.documentElement.getElementsByTagName("Count");
                        that.draw(data);
                        //that.hideLoading();
                        that.updateControl = 0;
                    }
                }
                //that.hideLoading();
            });
        }
    };


    that.updateLabel(lbl);
    that.redrawLegend();
    that.redraw();
    return that;
}

/*Generic numeric track which displays numeric values accross the genome*/
function CountTrack(gsvg, data, trackClass, density, additionalOptions) {
    var that = Track(gsvg, data, trackClass, "Generic Counts");
    that.loadedDataMin = that.xScale.domain()[0];
    that.loadedDataMax = that.xScale.domain()[1];
    that.dataFileName = that.trackClass;
    that.scaleMin = 1;
    that.scaleMax = 5000;
    that.graphColorText = "steelblue";
    that.colorScale = d3.scaleLinear().domain([that.scaleMin, that.scaleMax]).range(["#EEEEEE", "#000000"]);
    that.ttSVG = 1;
    that.data = data;
    that.density = density;
    that.prevDensity = density;
    that.countType = 1;
    that.displayBreakDown = null;
    var tmpMin = that.gsvg.xScale.domain()[0];
    var tmpMax = that.gsvg.xScale.domain()[1];
    var len = tmpMax - tmpMin;
    //console.log(that.trackClass + ":" + additionalOptions);
    var opts = [];
    if (additionalOptions) {
        if (additionalOptions.indexOf(",") > 0) {
            opts = additionalOptions.split(",");
        } else {
            opts[0] = additionalOptions;
        }
    }
    if (opts.length > 1) {
        tmp = opts[0].split(":");
        that.scaleMin = tmp[0] * 1;
        that.scaleMax = tmp[1] * 1;
        //console.log("scale:" + that.scaleMin + ":" + that.scaleMax);
    }
    if (opts.length > 2) {
        that.countType = opts[1] * 1;
        //console.log("countType:" + that.countType);
    }


    that.fullDataTimeOutHandle = 0;

    that.ttTrackList = [];
    if (trackClass.indexOf("illuminaSmall") > -1) {
        that.ttTrackList.push("ensemblsmallnc");
        that.ttTrackList.push("brainsmallnc");
        that.ttTrackList.push("liversmallnc");
        that.ttTrackList.push("heartsmallnc");
        that.ttTrackList.push("repeatMask");
    } else {
        that.ttTrackList.push("ensemblcoding");
        that.ttTrackList.push("braincoding");
        that.ttTrackList.push("liverTotal");
        that.ttTrackList.push("heartTotal");
        that.ttTrackList.push("mergedTotal");
        that.ttTrackList.push("brainIso");
        that.ttTrackList.push("liverIso");
        that.ttTrackList.push("refSeq");
        that.ttTrackList.push("ensemblnoncoding");
        that.ttTrackList.push("brainnoncoding");
        that.ttTrackList.push("probe");
        that.ttTrackList.push("polyASite");
        that.ttTrackList.push("spliceJnct");
        that.ttTrackList.push("liverspliceJnct");
        that.ttTrackList.push("heartspliceJnct");
        that.ttTrackList.push("repeatMask");
    }


    that.calculateBin = function (len) {
        var w = that.gsvg.width;
        var bpPerPixel = len / w;
        bpPerPixel = Math.floor(bpPerPixel);
        var bpPerPixelStr = new String(bpPerPixel);
        var firstDigit = bpPerPixelStr.substr(0, 1);
        var firstNum = firstDigit * Math.pow(10, (bpPerPixelStr.length - 1));
        var bin = firstNum / 2;
        bin = Math.floor(bin);
        if (bin < 5) {
            bin = 0;
        }
        return bin;
    };
    //that.bin = that.calculateBin(len);


    that.color = function (d) {
        var color = "#FFFFFF";
        if (d.getAttribute("count") >= that.scaleMin) {
            color = d3.rgb(that.colorScale(d.getAttribute("count")));
            //color=d3.rgb(that.colorScale(d.getAttribute("count")));
        }
        return color;
    };

    that.redraw = function () {

        var tmpMin = that.gsvg.xScale.domain()[0];
        var tmpMax = that.gsvg.xScale.domain()[1];
        //var len=tmpMax-tmpMin;
        var tmpBin = that.bin;
        var tmpW = that.xScale(tmpMin + tmpBin) - that.xScale(tmpMin);
        /*if(that.gsvg.levelNumber<10 && (tmpW>2||tmpW<0.5)) {
			that.updateFullData(0,1);
		}*//*else if(tmpMin<that.prevMinCoord||tmpMax>that.prevMaxCoord){
			that.updateFullData(0,1);
		}*/
        //else{

        that.prevMinCoord = tmpMin;
        that.prevMaxCoord = tmpMax;

        var tmpMin = that.xScale.domain()[0];
        var tmpMax = that.xScale.domain()[1];
        var newData = [];
        var newCount = 0;
        var tmpYMax = 0;
        for (var l = 0; l < that.data.length; l++) {
            if (typeof that.data[l] !== 'undefined') {
                var start = parseInt(that.data[l].getAttribute("start"), 10);
                var stop = parseInt(that.data[l].getAttribute("stop"), 10);
                var count = parseInt(that.data[l].getAttribute("count"), 10);
                if (that.density != 1 || (that.density == 1 && start != stop)) {
                    if ((l + 1) < that.data.length) {
                        var startNext = parseInt(that.data[l + 1].getAttribute("start"), 10);
                        if ((start >= tmpMin && start <= tmpMax) || (startNext >= tmpMin && startNext <= tmpMax)
                        ) {
                            newData[newCount] = that.data[l];
                            if (count > tmpYMax) {
                                tmpYMax = count;
                            }
                            newCount++;
                        } else {

                        }
                    } else {
                        if (start >= tmpMin && start <= tmpMax) {
                            newData[newCount] = that.data[l];
                            if (count > tmpYMax) {
                                tmpYMax = count;
                            }
                            newCount++;
                        } else {

                        }
                    }
                }
            }
        }
        if (that.density == 1) {
            if (that.density != that.prevDensity) {
                that.redrawLegend();
                var tmpMax = that.gsvg.xScale.domain()[1];
                that.prevDensity = that.density;
                that.svg.selectAll(".area").remove();
                that.svg.selectAll("g.y").remove();
                that.svg.selectAll(".grid").remove();
                that.svg.selectAll(".leftLbl").remove();
                var points = that.svg.selectAll("." + that.trackClass).data(newData, keyStart);
                points.each().remove();
                points = that.svg.selectAll("." + that.trackClass).data(newData, keyStart);
                points.enter()
                    .append("rect")
                    .attr("x", function (d) {
                        return that.xScale(d.getAttribute("start"));
                    })
                    .attr("y", 15)
                    .attr("class", that.trackClass)
                    .attr("height", 10)
                    .attr("width", function (d, i) {
                        var wX = 1;
                        wX = that.xScale((d.getAttribute("stop"))) - that.xScale(d.getAttribute("start"));

                        return wX;
                    })
                    .attr("fill", that.color)
                    .on("mouseover", function (d) {
                        if (that.gsvg.isToolTip == 0) {
                            d3.select(this).style("fill", "green");
                            tt.transition()
                                .duration(200)
                                .style("opacity", 1);
                            tt.html(that.createToolTip(d))
                                .style("left", function () {
                                    return that.positionTTLeft(d3.event.pageX);
                                })
                                .style("top", function () {
                                    return that.positionTTTop(d3.event.pageY);
                                });
                        }
                    })
                    .on("mouseout", function (d) {
                        d3.select(this).style("fill", that.color);
                        tt.transition()
                            .delay(500)
                            .duration(200)
                            .style("opacity", 0);
                    });
                points.exit().remove();
            } else {
                that.svg.selectAll("." + that.trackClass)
                    .attr("x", function (d) {
                        return that.xScale(d.getAttribute("start"));
                    })
                    .attr("width", function (d, i) {
                        var wX = 1;
                        wX = that.xScale((d.getAttribute("stop"))) - that.xScale(d.getAttribute("start"));
                        /*if((i+1)<that.data.length){
											   		if(that.xScale((that.data[i+1].getAttribute("start")))-that.xScale(d.getAttribute("start"))>1){
												   		wX=that.xScale((that.data[i+1].getAttribute("start")))-that.xScale(d.getAttribute("start"));
											   		}
												}/*else{
													if(d3.select(this).attr("width")>0){
														wX=d3.select(this).attr("width")
													}else{
														if(that.xScale(tmpMax)-that.xScale(d.getAttribute("start"))>1){
												   			wX=that.xScale(tmpMax)-that.xScale(d.getAttribute("start"));
											   			}
											   		}
												}*/
                        return wX;
                    })
                    .attr("fill", that.color);
            }
            that.svg.attr("height", 30);
        } else if (that.density == 2) {


            that.svg.selectAll("." + that.trackClass).remove();
            that.svg.select(".y.axis").remove();
            that.svg.select("g.grid").remove();
            that.svg.selectAll(".leftLbl").remove();
            that.yScale.domain([0, tmpYMax]);
            that.svg.select(".area").remove();
            that.area = d3.area()
                .x(function (d) {
                    return that.xScale(d.getAttribute("start"));
                })
                .y0(140)
                .y1(function (d) {
                    return that.yScale(d.getAttribute("count"));
                });
            that.redrawLegend();
            that.prevDensity = that.density;
            that.svg.append("g")
                .attr("class", "y axis")
                .call(that.yAxis);
            that.svg.append("g")
                .attr("class", "grid")
                .call(that.yAxis
                    .tickSize((-that.gsvg.width + 10), 0, 0)
                    .tickFormat("")
                );
            that.svg.select("g.y").selectAll("text").each(function (d) {
                var str = new String(d);
                d3.select(this).attr("x", function () {
                    return str.length * 7.7 + 5;
                })
                    .attr("dy", "0.05em");

                that.svg.append("svg:text").attr("class", "leftLbl")
                    .attr("x", that.gsvg.width - (str.length * 7.8 + 5))
                    .attr("y", function () {
                        return that.yScale(d)
                    })
                    .attr("dy", "0.01em")
                    .style("font-weight", "bold")
                    .text(numberWithCommas(d));


            });

            that.svg.append("path")
                .datum(newData)
                .attr("class", "area")
                .attr("stroke", that.graphColorText)
                .attr("fill", that.graphColorText)
                .attr("d", that.area);

            that.svg.attr("height", 140);
        }
        that.redrawSelectedArea();
        //}
    };

    that.createToolTip = function (d) {
        var tooltip = "";
        tooltip = "<BR><div id=\"ttSVG\" style=\"background:#FFFFFF;\"></div><BR>Read Count=" + numberWithCommas(d.getAttribute("count"));
        if (that.bin > 0) {
            var tmpEnd = parseInt(d.getAttribute("start"), 10) + parseInt(that.bin, 10);
            tooltip = tooltip + "*<BR><BR>*Data compressed for display. Using 90th percentile of<BR>region:" + numberWithCommas(d.getAttribute("start")) + "-" + numberWithCommas(tmpEnd) + "<BR><BR>Zoom in further to see raw data(roughly a region <1000bp). The bin size will decrease as you zoom in thus the resolution of the count data will improve as you zoom in.";
        }/*else{
			tooltip=tooltip+"<BR>Read Count:"+d.getAttribute("count");
		}*/
        return tooltip;
    };

    that.update = function (d) {
        var tmpMin = that.xScale.domain()[0];
        var tmpMax = that.xScale.domain()[1];
        if (that.loadedDataMin <= tmpMin && tmpMax <= that.loadedDataMax) {
            that.redraw();
        } else {
            //console.log("Update caused updateFullData()" + this.trackID);
            that.updateFullData(0, 0);
        }
    };

    that.updateFullData = function (retry, force) {
        var tmpMin = that.xScale.domain()[0];
        var tmpMax = that.xScale.domain()[1];

        var len = tmpMax - tmpMin;

        that.showLoading();
        if (retry === 0 || force == 1) {
            that.bin = that.calculateBin(len);
            //console.log(that.trackClass + ":bin size:" + that.bin);
        }
        var tmpCountType = "Total";
        if (that.countType === 2) {
            tmpCountType = "Norm";
        }
        //console.log("update "+that.trackClass);

        var tag = "Count";
        var file = dataPrefix + "tmpData/browserCache/" + genomeVer + "/regionData/" + that.gsvg.folderName + "/tmp/" + dataVer + "_" + tmpMin + "_" + tmpMax + ".count." + that.trackClass + "." + tmpCountType + ".xml";
        if (that.bin > 0) {
            tmpMin = tmpMin - (that.bin * 2);
            tmpMin = tmpMin - (tmpMin % (that.bin * 2));
            tmpMax = tmpMax + (that.bin * 2);
            tmpMax = tmpMax + (that.bin * 2 - (tmpMax % (that.bin * 2)));
            file = dataPrefix + "tmpData/browserCache/" + genomeVer + "/regionData/" + that.gsvg.folderName + "/tmp/" + dataVer + "_" + tmpMin + "_" + tmpMax + ".bincount." + that.bin + "." + that.trackClass + "." + tmpCountType + ".xml";
        }
        //console.log(that.trackClass + ":file=" + file);
        //console.log(that.trackClass + ":folder=" + that.gsvg.folderName);
        d3.xml(file, function (error, d) {
            if (error) {
                console.log("error:" + that.bin + ":" + file)
                if (retry == 0 || force == 1) {
                    var tmpContext = "/" + pathPrefix;
                    if (!pathPrefix) {
                        tmpContext = "";
                    }
                    tmpPanel = panel;
                    if (that.trackClass.indexOf("-") > -1) {
                        tmpPanel = that.trackClass.substr(that.trackClass.indexOf("-") + 1);
                    }
                    $.ajax({
                        url: tmpContext + "generateTrackXML.jsp",
                        type: 'GET',
                        cache: false,
                        async: true,
                        data: {
                            chromosome: chr,
                            minCoord: tmpMin,
                            maxCoord: tmpMax,
                            panel: tmpPanel,
                            rnaDatasetID: rnaDatasetID,
                            arrayTypeID: arrayTypeID,
                            myOrganism: organism,
                            genomeVer: genomeVer,
                            dataVer: dataVer,
                            track: that.trackClass,
                            folder: that.gsvg.folderName,
                            binSize: that.bin,
                            countType: that.countType
                        },
                        //data: {chromosome: chr,minCoord:minCoord,maxCoord:maxCoord,panel:panel,rnaDatasetID:rnaDatasetID,arrayTypeID: arrayTypeID, myOrganism: organism, track: that.trackClass, folder: folderName,binSize:that.bin},
                        dataType: 'json',
                        success: function (data2) {
                            //console.log("generateTrack:DONE");
                            /*if(ga){
														ga('send','event','browser','generateTrackCount');
													}*/
                            gtag('event', 'generateTrackCount', {'event_category': 'browser'});
                        },
                        error: function (xhr, status, error) {

                        }
                    });
                }
                //console.log(error);
                if (retry < 8) {//wait before trying again
                    var time = 1000;
                    /*if(retry==0){
								time=10000;
							}*/
                    that.fullDataTimeOutHandle = setTimeout(function () {
                        that.updateFullData(retry + 1, 0);
                    }, time);
                } else if (retry < 30) {
                    var time = 2000;
                    that.fullDataTimeOutHandle = setTimeout(function () {
                        that.updateFullData(retry + 1, 0);
                    }, time);
                } else if (retry < 38) {
                    var time = 10000;
                    that.fullDataTimeOutHandle = setTimeout(function () {
                        that.updateFullData(retry + 1, 0);
                    }, time);
                } else {
                    d3.select("#Level" + that.levelNumber + that.trackClass).select("#trkLbl").text("An errror occurred loading Track:" + that.trackClass);
                    d3.select("#Level" + that.levelNumber + that.trackClass).attr("height", 15);
                    that.gsvg.addTrackErrorRemove(that.svg, "#Level" + that.gsvg.levelNumber + that.trackClass);
                    that.hideLoading();
                    that.fullDataTimeOutHandle = setTimeout(function () {
                        that.updateFullData(retry + 1, 1);
                    }, 15000);
                }
            } else {
                //console.log("update data");
                //console.log(d);
                if (d == null) {
                    //console.log("is null");
                    if (retry >= 32) {
                        data = new Array();
                        that.draw(data);
                        //that.hideLoading();
                    } else {
                        that.fullDataTimeOutHandle = setTimeout(function () {
                            that.updateFullData(retry + 1, 0);
                        }, 5000);
                    }
                } else {
                    //console.log("not null is drawing");
                    that.fullDataTimeOutHandle = 0;
                    that.loadedDataMin = tmpMin;
                    that.loadedDataMax = tmpMax;
                    setTimeout(function () {
                        var data = d.documentElement.getElementsByTagName("Count");
                        that.draw(data);
                    }, 10);

                    //that.hideLoading();
                }
            }
            //that.hideLoading();
        });
    };

    that.updateCountScale = function (minVal, maxVal) {
        that.scaleMin = minVal;
        that.scaleMax = maxVal;
        that.colorScale = d3.scaleLinear().domain([that.scaleMin, that.scaleMax]).range(["#EEEEEE", "#000000"]);
        if (that.density == 1) {
            that.redrawLegend();
            that.redraw();
        }
    };

    that.setupToolTipSVG = function (d, perc) {
        //Setup Tooltip SVG
        var tmpMin = that.xScale.domain()[0];
        var tmpMax = that.xScale.domain()[1];
        var start = parseInt(d.getAttribute("start"), 10);
        var stop = parseInt(d.getAttribute("stop"), 10);
        var len = stop - start;
        var margin = Math.floor((tmpMax - tmpMin) * perc);
        if (margin < 20) {
            margin = 20;
        }
        var tmpStart = start - margin;
        var tmpStop = stop + margin;
        if (tmpStart < 1) {
            tmpStart = 1;
        }
        if (typeof that.ttSVGMinWidth !== 'undefined') {
            if (tmpStop - tmpStart < that.ttSVGMinWidth) {
                tmpStart = start - (that.ttSVGMinWidth / 2);
                tmpStop = stop + (that.ttSVGMinWidth / 2);
            }
        }

        var newSvg = toolTipSVG("div#ttSVG", 450, tmpStart, tmpStop, 99, d.getAttribute("ID"), "transcript");
        //Setup Track for current feature
        //var dataArr=new Array();
        //dataArr[0]=d;
        newSvg.addTrack(that.trackClass, 3, "", that.data);
        //Setup Other tracks included in the track type(listed in that.ttTrackList)
        for (var r = 0; r < that.ttTrackList.length; r++) {
            var tData = that.gsvg.getTrackData(that.ttTrackList[r]);
            var fData = new Array();
            if (typeof tData !== 'undefined' && tData.length > 0) {
                var fCount = 0;
                for (var s = 0; s < tData.length; s++) {
                    if ((tmpStart <= parseInt(tData[s].getAttribute("start"), 10) && parseInt(tData[s].getAttribute("start"), 10) <= tmpStop)
                        || (parseInt(tData[s].getAttribute("start"), 10) <= tmpStart && parseInt(tData[s].getAttribute("stop"), 10) >= tmpStart)
                    ) {
                        fData[fCount] = tData[s];
                        fCount++;
                    }
                }
                if (fData.length > 0) {
                    newSvg.addTrack(that.ttTrackList[r], 3, "DrawTrx", fData);
                }
            }
        }
    }

    that.draw = function (data) {
        that.hideLoading();

        //d3.selectAll("."+that.trackClass).remove();
        //data.sort(function(a, b){return a.getAttribute("start")-b.getAttribute("start")});
        that.data = data;
        //console.log("draw:" + that.trackClass + ":" + data.length);
        /*if($("#"+that.trackClass+"Dense"+that.gsvg.levelNumber+"Select").length>0){
			that.density=$("#"+that.trackClass+"Dense"+that.gsvg.levelNumber+"Select").val();
		}*/
        var tmpMin = that.gsvg.xScale.domain()[0];
        var tmpMax = that.gsvg.xScale.domain()[1];
        //var len=tmpMax-tmpMin;
        var tmpBin = that.bin;
        var tmpW = that.xScale(tmpMin + tmpBin) - that.xScale(tmpMin);
        /*if(that.gsvg.levelNumber<10 && (tmpW>2||tmpW<0.5)) {
			that.updateFullData(0,1);
		}else{
		*/
        that.redrawLegend();
        //var tmpMin=that.xScale.domain()[0];
        //var tmpMax=that.xScale.domain()[1];
        var newData = [];
        var newCount = 0;
        var tmpYMax = 0;
        for (var l = 0; l < that.data.length; l++) {
            if (typeof that.data[l] !== 'undefined') {
                var start = parseInt(that.data[l].getAttribute("start"), 10);
                var stop = parseInt(that.data[l].getAttribute("stop"), 10);
                var count = parseInt(that.data[l].getAttribute("count"), 10);
                if (that.density != 1 || (that.density == 1 && start != stop)) {
                    if ((l + 1) < that.data.length) {
                        var startNext = parseInt(data[l + 1].getAttribute("start"), 10);
                        if ((start >= tmpMin && start <= tmpMax) || (startNext >= tmpMin && startNext <= tmpMax)) {
                            newData[newCount] = that.data[l];
                            if (count > tmpYMax) {
                                tmpYMax = count;
                            }
                            newCount++;
                        } else {

                        }
                    } else {
                        if ((start >= tmpMin && start <= tmpMax)) {
                            newData[newCount] = that.data[l];
                            if (count > tmpYMax) {
                                tmpYMax = count;
                            }
                            newCount++;
                        } else {

                        }
                    }
                }
            }
        }
        //console.log("newData:" + newData.length);
        ndata = newData;
        //console.log("data:" + ndata.length);
        //that.svg.selectAll("." + that.trackClass).remove();
        that.svg.select(".y.axis").remove();
        that.svg.select("g.grid").remove();
        that.svg.selectAll(".leftLbl").remove();
        that.svg.select(".area").remove();
        that.svg.selectAll(".area").remove();
        if (that.density == 1) {
            //console.log("draw:den1");
            var tmpMax = that.gsvg.xScale.domain()[1];
            var points = that.svg.selectAll("." + that.trackClass).data(ndata, keyStart);
            points.enter()
                .append("rect")
                .attr("x", function (d) {
                    //console.log("x:" + d.getAttribute("start") + ":" + that.xScale(d.getAttribute("start")));
                    return that.xScale(d.getAttribute("start"));
                })
                .attr("y", 15)
                .attr("class", that.trackClass)
                .attr("height", 10)
                .attr("width", function (d, i) {
                    var wX = 1;
                    wX = that.xScale((d.getAttribute("stop"))) - that.xScale(d.getAttribute("start"));
                    /*if((i+1)<that.data.length){
										   if(that.xScale((that.data[i+1].getAttribute("start")))-that.xScale(d.getAttribute("start"))>1){
											   wX=that.xScale((that.data[i+1].getAttribute("start")))-that.xScale(d.getAttribute("start"));
										   }
										}else{
											if(that.xScale(tmpMax)-that.xScale(d.getAttribute("start"))>1){
											   	wX=that.xScale(tmpMax)-that.xScale(d.getAttribute("start"));
										   	}
										}*/
                    return wX;
                })
                .attr("fill", that.color)
                .on("mouseover", function (d) {
                    //console.log("mouseover count track");
                    if (that.gsvg.isToolTip == 0) {
                        //console.log("setup tooltip:countTrack");
                        d3.select(this).style("fill", "green");
                        tt.transition()
                            .duration(200)
                            .style("opacity", 1);
                        tt.html(that.createToolTip(d))
                            .style("left", function () {
                                return that.positionTTLeft(d3.event.pageX);
                            })
                            .style("top", function () {
                                return that.positionTTTop(d3.event.pageY);
                            });
                        if (that.ttSVG == 1) {
                            //Setup Tooltip SVG
                            that.setupToolTipSVG(d, 0.005);
                        }
                    }
                })
                .on("mouseout", function (d) {
                    d3.select(this).style("fill", that.color);
                    tt.transition()
                        .delay(500)
                        .duration(200)
                        .style("opacity", 0);
                });

            that.svg.attr("height", 30);
        } else if (that.density == 2) {
            //console.log("draw:den2");
            that.yScale.domain([0, tmpYMax]);
            that.yAxis = d3.axisLeft(that.yScale)
                .ticks(5);
            that.svg.select("g.grid").remove();
            that.svg.select(".y.axis").remove();
            that.svg.selectAll(".leftLbl").remove();
            that.svg.append("g")
                .attr("class", "y axis")
                .call(that.yAxis);

            that.svg.select("g.y").selectAll("text").each(function (d) {
                var str = new String(d);
                that.svg.append("svg:text").attr("class", "leftLbl")
                    .attr("x", that.gsvg.width - (str.length * 7.8 + 5))
                    .attr("y", function () {
                        return that.yScale(d)
                    })
                    .attr("dy", "0.01em")
                    .style("font-weight", "bold")
                    .text(numberWithCommas(d));

                d3.select(this).attr("x", function () {
                    return str.length * 7.7 + 5;
                })
                    .attr("dy", "0.05em");
            });

            that.svg.append("g")
                .attr("class", "grid")
                .call(that.yAxis
                    .tickSize((-that.gsvg.width + 10), 0, 0)
                    .tickFormat("")
                );
            that.svg.select(".area").remove();
            that.area = d3.area()
                .x(function (d) {
                    return that.xScale(d.getAttribute("start"));
                })
                .y0(140)
                .y1(function (d, i) {
                    return that.yScale(d.getAttribute("count"));
                    ;
                });
            that.svg.append("path")
                .datum(data)
                .attr("class", "area")
                .attr("stroke", that.graphColorText)
                .attr("fill", that.graphColorText)
                .attr("d", that.area);
            that.svg.attr("height", 140);
        }
        that.redrawSelectedArea();
        //}
    };

    that.redrawLegend = function () {

        if (that.density == 2) {
            d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll(".legend").remove();
        } else if (that.density == 1) {
            var lblStr = new String(that.label);
            var x = that.gsvg.width / 2 + (lblStr.length / 2) * 7.5 - 10;
            var ltLbl = new String("<" + that.scaleMin);
            that.drawScaleLegend(that.scaleMin, numberWithCommas(that.scaleMax) + "+", "Read Counts", "#EEEEEE", "#00000", 15 + (ltLbl.length * 7.6));
            that.svg.append("text").text("<" + that.scaleMin).attr("class", "legend").attr("x", x).attr("y", 12);
            that.svg.append("rect")
                .attr("class", "legend")
                .attr("x", x + ltLbl.length * 7.6 + 5)
                .attr("y", 0)
                .attr("rx", 2)
                .attr("ry", 2)
                .attr("height", 12)
                .attr("width", 15)
                .attr("fill", "#FFFFFF")
                .attr("stroke", "#CECECE");
        }

    };

    that.redrawSelectedArea = function () {
        if (that.density > 1) {
            var rectH = that.svg.attr("height");

            d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll(".selectedArea").remove();
            if (that.selectionStart > -1 && that.selectionEnd > -1) {
                var tmpStart = that.xScale(that.selectionStart);
                var tmpW = that.xScale(that.selectionEnd) - tmpStart;
                if (tmpW < 1) {
                    tmpW = 1;
                }
                d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).append("rect")
                    .attr("class", "selectedArea")
                    .attr("x", tmpStart)
                    .attr("y", 0)
                    .attr("height", rectH)
                    .attr("width", tmpW)
                    .attr("fill", "#CECECE")
                    .attr("opacity", 0.3)
                    .attr("pointer-events", "none");
            }
        } else {
            d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll(".selectedArea").remove();
        }
    };


    that.savePrevious = function () {
        that.prevSetting = {};
        that.prevSetting.density = that.density;
        that.prevSetting.scaleMin = that.scaleMin;
        that.prevSetting.scaleMax = that.scaleMax;
        that.prevSetting.countType = that.countType;
    };

    that.revertPrevious = function () {
        that.density = that.prevSetting.density;
        that.scaleMin = that.prevSetting.scaleMin;
        that.scaleMax = that.prevSetting.scaleMax;
        that.countType = that.prevSetting.countType;
    };

    that.generateTrackSettingString = function () {
        return that.trackClass + "," + that.density + "," + that.scaleMin + ":" + that.scaleMax + "," + that.countType + ";";
    };

    that.generateSettingsDiv = function (topLevelSelector) {
        var d = trackInfo[that.trackClass];
        that.savePrevious();
        //console.log(trackInfo);
        //console.log(d);
        d3.select(topLevelSelector).select("table").select("tbody").html("");
        if (d && d.Controls && d.Controls.length > 0) {
            var controls = new String(d.Controls).split(",");
            var table = d3.select(topLevelSelector).select("table").select("tbody");
            table.append("tr").append("td").style("font-weight", "bold").html("Track Settings: " + d.Name);
            for (var c = 0; c < controls.length; c++) {
                if (typeof controls[c] !== 'undefined' && controls[c] != "") {
                    var params = controls[c].split(";");

                    var div = table.append("tr").append("td");
                    var lbl = params[0].substr(5);

                    var def = "";
                    if (params.length > 3 && params[3].indexOf("Default=") == 0) {
                        def = params[3].substr(8);
                    }
                    if (params[1].toLowerCase().indexOf("select") == 0) {
                        div.append("text").text(lbl + ": ");
                        var selClass = params[1].split(":");
                        var opts = params[2].split("}");
                        var id = that.trackClass + "Dense" + that.level + "Select";
                        if (selClass[1] == "colorSelect") {
                            id = that.trackClass + that.level + "colorSelect";
                        } else if (selClass[1] == "countSelect") {
                            id = that.trackClass + that.level + "countSelect";
                        }
                        var sel = div.append("select").attr("id", id)
                            .attr("name", selClass[1]);
                        for (var o = 0; o < opts.length; o++) {
                            var option = opts[o].substr(1).split(":");
                            if (option.length == 2) {
                                var tmpOpt = sel.append("option").attr("value", option[1]).text(option[0]);
                                if (id.indexOf("Dense") > -1) {
                                    if (option[1] == that.density) {
                                        tmpOpt.attr("selected", "selected");
                                    }
                                } else if (option[1] == def) {
                                    tmpOpt.attr("selected", "selected");
                                }
                            }
                        }
                        d3.select("select#" + id).on("change", function () {
                            if ($(this).attr("id") == that.trackClass + "Dense" + that.level + "Select" && $(this).val() == 1) {
                                $("#scaleControl" + that.level).show();
                            } else {
                                $("#scaleControl" + that.level).hide();
                            }
                            that.updateSettingsFromUI();
                            that.redraw();
                        });
                    } else if (params[1].toLowerCase().indexOf("slider") == 0) {
                        var disp = "none";
                        if (that.density == 1) {
                            disp = "inline-block";
                        }
                        div = div.append("div").attr("id", "scaleControl" + that.level).style("display", disp);
                        div.append("text").text(lbl + ": ");
                        div.append("input").attr("type", "text").attr("id", "amount").attr("value", that.scaleMin + "-" + that.scaleMax).style("border", 0).style("color", "#f6931f").style("font-weight", "bold").style("background-color", "#EEEEEE");
                        var selClass = params[1].split(":");
                        var opts = params[2].split("}");

                        div = div.append("div");
                        div.append("text").text("Min:");
                        div.append("div").attr("id", "min-" + selClass[1])
                            .style("width", "60%")
                            .style("display", "inline-block")
                            .style("float", "right");
                        div.append("br");
                        div.append("text").text("Max:");
                        div.append("div").attr("id", "max-" + selClass[1])
                            .style("width", "60%")
                            .style("display", "inline-block")
                            .style("float", "right");

                        $("#min-" + selClass[1]).slider({
                            min: 1,
                            max: 1000,
                            step: 1,
                            value: that.scaleMin,
                            slide: that.processSlider
                        });
                        $("#max-" + selClass[1]).slider({
                            min: 1000,
                            max: 20000,
                            step: 100,
                            value: that.scaleMax,
                            slide: that.processSlider
                        });
                        that.updateSettingsFromUI();
                        that.redraw();
                    }
                }
            }
            var buttonDiv = table.append("tr").append("td");
            buttonDiv.append("input").attr("type", "button").attr("value", "Remove Track").style("float", "left").style("margin-left", "5px").on("click", function () {
                $('#trackSettingDialog').fadeOut("fast");
                that.gsvg.setCurrentViewModified();
                that.gsvg.removeTrack(that.trackClass);
                var viewID = svgList[that.gsvg.levelNumber].currentView.ViewID;
                var track = viewMenu[that.gsvg.levelNumber].findTrackByClass(that.trackClass, viewID);
                var indx = viewMenu[that.gsvg.levelNumber].findTrackIndexWithViewID(track.TrackID, viewID);
                viewMenu[that.gsvg.levelNumber].removeTrackWithIDIdx(indx, viewID);
            });
            buttonDiv.append("input").attr("type", "button").attr("value", "Apply").style("float", "right").style("margin-left", "5px").on("click", function () {
                $('#trackSettingDialog').fadeOut("fast");
                if (that.density != that.prevSetting.density || that.scaleMin != that.prevSetting.scaleMin || that.scaleMax != that.prevSetting.scaleMax) {
                    that.gsvg.setCurrentViewModified();
                }
            });
            buttonDiv.append("input").attr("type", "button").attr("value", "Cancel").style("float", "right").style("margin-left", "5px").on("click", function () {
                that.revertPrevious();
                that.updateCountScale(that.scaleMin, that.scaleMax);
                that.draw(that.data);
                $('#trackSettingDialog').fadeOut("fast");
            });
        } else {
            var table = d3.select(topLevelSelector).select("table").select("tbody");
            table.append("tr").append("td").style("font-weight", "bold").html("Track Settings: " + d.Name);
            table.append("tr").append("td").html("Sorry no settings for this track.");
            var buttonDiv = table.append("tr").append("td");
            buttonDiv.append("input").attr("type", "button").attr("value", "Remove Track").style("float", "left").style("margin-left", "5px").on("click", function () {
                that.gsvg.setCurrentViewModified();
                $('#trackSettingDialog').fadeOut("fast");
            });
            buttonDiv.append("input").attr("type", "button").attr("value", "Cancel").style("float", "right").style("margin-left", "5px").on("click", function () {
                $('#trackSettingDialog').fadeOut("fast");
            });
        }
    };

    that.processSlider = function (event, ui) {
        var min = $("#min-rangeslider").slider("value");
        var max = $("#max-rangeslider").slider("value");
        $("#amount").val(min + " - " + max);
        that.updateCountScale(min, max);
    };

    that.yScale = d3.scaleLinear()
        .range([140, 20])
        .domain([0, d3.max(data, function (d) {
            return d.getAttribute("count");
        })]);

    that.area = d3.area()
        .x(function (d) {
            return that.xScale(d.getAttribute("start"));
        })
        .y0(140)
        .y1(function (d) {
            return d.getAttribute("count");
        });

    that.yAxis = d3.axisLeft(that.yScale)
        .ticks(5);

    that.redrawLegend();
    that.draw(data);

    return that;
}

function PolyATrack(gsvg, data, trackClass, label, density, additionalOptions) {
    var that = GenericTranscriptTrack(gsvg, data, trackClass, label, density, additionalOptions);
    that.dataFileName = "polyASite.xml";
    that.density = 3;
    that.minFeatureWidth = 1;
    that.colorBy = "Color";
    that.ttSVG = 1;
    that.ttTrackList = [];
    that.ttTrackList.push("ensemblcoding");
    that.ttTrackList.push("braincoding");
    that.ttTrackList.push("liverTotal");
    that.ttTrackList.push("heartTotal");
    that.ttTrackList.push("mergedTotal");
    that.ttTrackList.push("refSeq");
    that.ttTrackList.push("repeatMask");
    that.ttSVGMinWidth = 200;


    that.createToolTip = function (d) {
        var tooltip = "";
        var strand = ".";
        if (d.getAttribute("strand") == 1) {
            strand = "+";
        } else if (d.getAttribute("strand") == -1) {
            strand = "-";
        }
        var zero = "0";
        if (d.getAttribute("pvalue") == 1) {
            zero = "";
        }
        tooltip = "<BR><div id=\"ttSVG\" style=\"background:#FFFFFF;\"></div><BR>Motif:" + d.getAttribute("motif") + "<BR>Strand:" + strand + "<BR>Location: chr" + d.getAttribute("chromosome") + ":" + d.getAttribute("start") + "-" + d.getAttribute("stop") + "<BR>Probability of site: " + zero + d.getAttribute("pvalue");
        return tooltip;
    };

    that.updateData = function (retry) {
        var path = dataPrefix + "tmpData/browserCache/" + genomeVer + "/regionData/" + that.gsvg.folderName + "/" + that.dataFileName;
        d3.xml(path, function (error, d) {
            if (error) {
                if (retry < 3) {//wait before trying again
                    var time = 10000;
                    if (retry == 1) {
                        time = 15000;
                    }
                    setTimeout(function () {
                        that.updateData(retry + 1);
                    }, time);
                } else if (retry >= 3) {
                    d3.select("#Level" + that.levelNumber + that.trackClass).select("#trkLbl").text("An errror occurred loading Track:" + that.trackClass);
                    d3.select("#Level" + that.levelNumber + that.trackClass).attr("height", 15);
                    that.gsvg.addTrackErrorRemove(that.svg, "#Level" + that.gsvg.levelNumber + that.trackClass);
                }
            } else {
                var feature = d.documentElement.getElementsByTagName(that.xmlTag);
                var mergeddata = new Array();
                var checkName = new Array();
                var curInd = 0;
                for (var l = 0; l < feature.length; l++) {
                    if (typeof feature[l] !== 'undefined') {
                        mergeddata[curInd] = feature[l];
                        checkName[feature[l].getAttribute("ID")] = 1;
                        curInd++;
                    }
                }
                for (var l = 0; l < that.data.length; l++) {
                    if (typeof that.data[l] !== 'undefined' && typeof checkName[that.data[l].getAttribute("ID")] === 'undefined') {
                        mergeddata[curInd] = that.data[l];
                        curInd++;
                    }
                }
                that.draw(mergeddata);
                that.hideLoading();
            }
        });
    };

    that.redrawLegend = function () {
        var legend = [];
        legend[0] = {color: "#FF8000", label: "+ Strand >>>"};
        legend[1] = {color: "#330570", label: "- Strand <<<"};
        that.drawLegend(legend);

    };

    that.updateFullData = undefined;

    that.draw(data);
    return that;
}

function CustomTranscriptTrack(gsvg, data, trackClass, label, density, additionalOptions) {
    var that = GenericTranscriptTrack(gsvg, data, trackClass, label, density, additionalOptions);
    var opts = [];
    if (additionalOptions) {
        if (additionalOptions.indexOf(",") > 0) {
            opts = additionalOptions.split(",");
        } else {
            opts[0] = additionalOptions;
        }
    }
    that.xmlTag = "Feature";
    that.xmlTagBlockElem = "block";
    that.density = density;
    if (that.density !== 1 && that.density !== 2 && that.density !== 3) {
        that.density = 3;
    }
    if (opts.length > 0) {
        that.dataFileName = opts[0].substr(9);
    }
    if (opts.length > 1) {
        that.colorBy = opts[1];
    } else {
        that.colorBy = "Score";
    }
    if (opts.length > 2) {
        that.minValue = opts[2];
    }
    if (opts.length > 3) {
        that.maxValue = opts[3];
    }
    if (opts.length > 4) {
        that.minColor = opts[4];
    }
    if (opts.length > 5) {
        that.maxColor = opts[5];
    }
    //that.dataFileName=trackClass.substr(6)+".bed";
    that.colorValueField = "score";
    that.minFeatureWidth = 1;
    that.updateControl = 0;

    if (that.colorBy == "Score") {
        that.createColorScale();
    }

    that.updateFullData = function (retry, force) {
        if (that.updateControl == retry) {
            that.updateControl = retry + 1;
            var tmpMin = that.xScale.domain()[0];
            var tmpMax = that.xScale.domain()[1];
            var file = dataPrefix + "tmpData/trackXML/" + that.gsvg.folderName + "/" + that.dataFileName + ".xml";
            var bedFile = dataPrefix + "tmpData/trackUpload/" + that.dataFileName;
            var http = "";
            var tmp = new Date();
            var type = "bed"
            if (that.dataFileName.indexOf("http") > -1) {
                http = that.dataFileName;
                bedFile = "tmpData/tmpDownload/" + tmp.getTime() + "_" + that.trackClass;
                file = dataPrefix + "tmpData/trackXML/" + that.gsvg.folderName + "/" + that.trackClass + ".xml";
                type = "bb";
            }


            d3.xml(file, function (error, d) {
                //console.log("Handling retry:"+retry+"  force:"+force);
                if (error) {
                    //console.log("ERROR******");
                    console.log(error);
                    if (retry == 0 || force == 1) {
                        var tmpContext = "/" + pathPrefix;
                        if (!pathPrefix) {
                            tmpContext = "";
                        }
                        $.ajax({
                            url: tmpContext + "generateTrackXML.jsp",
                            type: 'GET',
                            cache: false,
                            async: true,
                            data: {
                                chromosome: chr,
                                minCoord: tmpMin,
                                maxCoord: tmpMax,
                                folder: that.gsvg.folderName,
                                bedFile: bedFile,
                                outFile: file,
                                track: that.trackClass,
                                web: http,
                                type: type
                            },
                            //data: {chromosome: chr,minCoord:minCoord,maxCoord:maxCoord,panel:panel,rnaDatasetID:rnaDatasetID,arrayTypeID: arrayTypeID, myOrganism: organism, track: that.trackClass, folder: folderName,binSize:that.bin},
                            dataType: 'json',
                            success: function (data2) {
                                /*if(ga){
											ga('send','event','browser','generateTrackCustomTranscript');
										}*/
                                gtag('event', 'generateTrackCustomTranscript', {'event_category': 'browser'});
                            },
                            error: function (xhr, status, error) {
                                console.log(error);
                            }
                        });
                    }
                    if (retry < 3) {//wait before trying again
                        var time = 10000;
                        if (retry == 1) {
                            time = 15000;
                        }
                        setTimeout(function () {
                            that.updateFullData(retry + 1, 0);
                        }, time);
                    } else {
                        d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).select("#trkLbl").text("An errror occurred loading Track:" + that.trackClass);
                        d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).attr("height", 15);
                        that.gsvg.addTrackErrorRemove(that.svg, "#Level" + that.gsvg.levelNumber + that.trackClass);
                        that.hideLoading();
                    }
                } else {
                    //console.log("SUCCESS******");
                    //console.log(d);
                    /*if(d==null){
								console.log("D:NULL");
								if(retry>=4){
									data=new Array();
									that.draw(data);
									that.hideLoading();
								}else{
									setTimeout(function (){
										that.updateFullData(retry+1,0);
									},5000);
								}
							}else{*/
                    //console.log("SETUP TRACK");
                    var data = d.documentElement.getElementsByTagName(that.xmlTag);
                    //console.log(that.trackClass+" received the following:");
                    //console.log(data);
                    that.draw(data);
                    that.hideLoading();
                    that.updateControl = 0;
                    //}
                }
            });
        }
    };

    that.updateSettingsFromUI = function () {
        if ($("#" + that.trackClass + "Dense" + that.level + "Select").length > 0) {
            that.density = $("#" + that.trackClass + "Dense" + that.level + "Select").val();
        }
        if ($("#" + that.trackClass + that.level + "colorSelect").length > 0) {
            that.colorBy = $("#" + that.trackClass + that.level + "colorSelect").val();
        }
        if (that.colorBy == "Score") {
            //console.log("colorby:Score");
            that.minValue = $("#" + that.trackClass + "minData" + that.level).val();
            that.maxValue = $("#" + that.trackClass + "maxData" + that.level).val();
            if (testIE || testSafari) {
                that.minColor = $("#" + that.trackClass + "minColor" + that.level).spectrum("get").toHexString();
                that.maxColor = $("#" + that.trackClass + "maxColor" + that.level).spectrum("get").toHexString();
                //console.log(that.minColor+":::"+that.maxColor);
            } else {
                that.minColor = $("#" + that.trackClass + "minColor" + that.level).val();
                that.maxColor = $("#" + that.trackClass + "maxColor" + that.level).val();
            }
            that.createColorScale();
        }
    };

    that.generateSettingsDiv = function (topLevelSelector) {
        var d = trackInfo[that.trackClass];
        that.savePrevious();
        d3.select(topLevelSelector).select("table").select("tbody").html("");
        if (d.Controls.length > 0 && d.Controls != "null") {
            var controls = new String(d.Controls).split(",");
            var table = d3.select(topLevelSelector).select("table").select("tbody");
            table.append("tr").append("td").style("font-weight", "bold").html("Track Settings: " + d.Name);
            for (var c = 0; c < controls.length; c++) {
                if (typeof controls[c] !== 'undefined' && controls[c] != "") {
                    var params = controls[c].split(";");
                    var div = table.append("tr").append("td");
                    var lbl = params[0].substr(5);
                    var def = "";
                    if (params.length > 3 && params[3].indexOf("Default=") == 0) {
                        def = params[3].substr(8);
                    }
                    if (params[1].toLowerCase().indexOf("select") == 0) {
                        div.append("text").text(lbl + ": ");
                        var selClass = params[1].split(":");
                        var opts = params[2].split("}");
                        var id = that.trackClass + "Dense" + that.level + "Select";
                        if (selClass[1] == "colorSelect") {
                            id = that.trackClass + that.level + "colorSelect";
                        }
                        var sel = div.append("select").attr("id", id)
                            .attr("name", selClass[1]);
                        for (var o = 0; o < opts.length; o++) {
                            var option = opts[o].substr(1).split(":");
                            if (option.length == 2) {
                                var tmpOpt = sel.append("option").attr("value", option[1]).text(option[0]);
                                if ((id.indexOf("Dense") > -1 && option[1] == that.density) || (id.indexOf("colorSelect") > -1 && option[1] == that.colorBy)) {
                                    tmpOpt.attr("selected", "selected");
                                }
                            }
                        }
                        d3.select("select#" + id).on("change", function () {
                            if ($(this).val() == "Score") {
                                $("div." + that.trackClass + "Scale" + that.level).show();
                            } else if ($(this).val() == "Color") {
                                $("div." + that.trackClass + "Scale" + that.level).hide();
                            }
                            that.updateSettingsFromUI();
                            that.draw(that.data);
                        });
                    } else if (params[1].toLowerCase().indexOf("txt") == 0) {
                        if ($("#colorTrack" + that.level).size() == 0) {
                            div = div.append("div").attr("class", that.trackClass + "Scale" + that.level).style("display", "none");
                        } else {
                            div = d3.select("#" + that.trackClass + "Scale" + that.level);
                        }
                        div.append("text").text(lbl + ": ");
                        var selClass = params[1].split(":");
                        var opts = params[2].split("}");
                        var txtType = "Data";
                        var inputType = "text";
                        var inputMin = that.minValue;
                        var inputMax = that.maxValue;
                        if (selClass[1] == "color") {
                            txtType = "Color";
                            inputType = "Color";
                            inputMin = that.minColor;
                            inputMax = that.maxColor;
                        }

                        div.append("input").attr("type", inputType).attr("id", that.trackClass + "min" + txtType + that.level)
                            .attr("class", selClass[1])
                            .style("margin-left", "5px")
                            .attr("value", inputMin);
                        div.append("text").text(" - ");
                        div.append("input").attr("type", inputType).attr("id", that.trackClass + "max" + txtType + that.level)
                            .attr("class", selClass[1])
                            .style("margin-left", "5px")
                            .attr("value", inputMax);


                        if (txtType == "Color" && (testIE || testSafari)) {//Change for IE and Safari
                            $("#" + that.trackClass + "min" + txtType + that.level).spectrum({
                                change: function (color) {
                                    that.updateSettingsFromUI();
                                    //that.createColorScale();
                                    that.draw(that.data);
                                }
                            });
                            $("#" + that.trackClass + "max" + txtType + that.level).spectrum({
                                change: function (color) {
                                    //that.maxColor=color.toHexString();
                                    that.updateSettingsFromUI();
                                    //that.createColorScale();
                                    that.draw(that.data);
                                }
                            });
                        } else {
                            $("input#" + that.trackClass + "min" + txtType + that.level).on("change", function () {
                                that.updateSettingsFromUI();
                                that.draw(that.data);
                            });

                            $("input#" + that.trackClass + "max" + txtType + that.level).on("change", function () {
                                that.updateSettingsFromUI();
                                that.draw(that.data);
                            });
                        }
                    }
                }
            }
            if ($("#" + that.trackClass + that.level + "colorSelect").val() == "Score") {
                $("div." + that.trackClass + "Scale" + that.level).show();
            } else if ($("#" + that.trackClass + that.level + "colorSelect").val() == "Color") {
                $("div." + that.trackClass + "Scale" + that.level).hide();
            }
            var buttonDiv = table.append("tr").append("td");
            buttonDiv.append("input").attr("type", "button").attr("value", "Remove Track").style("float", "left").style("margin-left", "5px").on("click", function () {
                $('#trackSettingDialog').fadeOut("fast");
                that.gsvg.removeTrack(that.trackClass);
                var viewID = svgList[that.gsvg.levelNumber].currentView.ViewID;
                var track = viewMenu[that.gsvg.levelNumber].findTrackByClass(that.trackClass, viewID);
                var indx = viewMenu[that.gsvg.levelNumber].findTrackIndexWithViewID(track.TrackID, viewID);
                viewMenu[that.gsvg.levelNumber].removeTrackWithIDIdx(indx, viewID);
            });
            buttonDiv.append("input").attr("type", "button").attr("value", "Apply").style("float", "right").style("margin-left", "5px").on("click", function () {
                $('#trackSettingDialog').fadeOut("fast");
            });
            buttonDiv.append("input").attr("type", "button").attr("value", "Cancel").style("float", "right").style("margin-left", "5px").on("click", function () {
                that.revertPrevious();
                that.draw(that.data);
                $('#trackSettingDialog').fadeOut("fast");
            });
        } else {
            var table = d3.select(topLevelSelector).select("table").select("tbody");
            table.append("tr").append("td").style("font-weight", "bold").html("Track Settings: " + d.Name);
            table.append("tr").append("td").html("Sorry no settings for this track.");
            var buttonDiv = table.append("tr").append("td");
            buttonDiv.append("input").attr("type", "button").attr("value", "Remove Track").style("float", "left").style("margin-left", "5px").on("click", function () {
                $('#trackSettingDialog').fadeOut("fast");
            });
            buttonDiv.append("input").attr("type", "button").attr("value", "Cancel").style("float", "right").style("margin-left", "5px").on("click", function () {
                $('#trackSettingDialog').fadeOut("fast");
            });
        }
    };

    that.generateTrackSettingString = function () {
        return that.trackClass + "," + that.density + "," + that.colorBy + "," + that.minValue + "," + that.maxValue + "," + that.minColor + "," + that.maxColor + ";";
    };

    return that;
}

function RepeatMaskTrack(gsvg, data, trackClass, label, density, additionalOptions) {
    var that = GenericTranscriptTrack(gsvg, data, trackClass, label, density, additionalOptions);
    that.dataFileName = "repeatMask.xml";
    that.density = 1;
    that.xmlTag = "Feature";
    that.xmlTagBlockElem = "Block";
    that.minFeatureWidth = 1;
    that.ttSVG = 1;
    that.ttTrackList = [];
    that.ttTrackList.push("ensemblcoding");
    that.ttTrackList.push("braincoding");
    that.ttTrackList.push("liverTotal");
    that.ttTrackList.push("heartTotal");
    that.ttTrackList.push("mergedTotal");
    that.ttTrackList.push("brainIso");
    that.ttTrackList.push("liverIso");
    that.ttTrackList.push("refSeq");
    that.ttTrackList.push("spliceJnct");
    that.ttTrackList.push("liverspliceJnct");
    that.ttTrackList.push("heartspliceJnct");
    that.ttTrackList.push("brainspliceJnct");
    that.ttTrackList.push("illuminaPolyA");
    that.ttTrackList.push("liverilluminaTotalPlus");
    that.ttTrackList.push("liverilluminaTotalMinus");
    that.ttTrackList.push("heartilluminaTotalPlus");
    that.ttTrackList.push("heartilluminaTotalMinus");
    that.ttTrackList.push("brainilluminaTotalPlus");
    that.ttTrackList.push("brainilluminaTotalMinus");


    that.ttSVGMinWidth = 200;
    that.legendLbl = "Smith-Waterman Alignment Score";

    that.typeList = [];
    that.typeList[0] = {name: "SINE", clss: "SINE"};
    that.typeList[1] = {name: "LINE", clss: "LINE"};
    that.typeList[2] = {name: "LTR", clss: "LTR"};
    that.typeList[3] = {name: "DNA", clss: "DNA"};
    that.typeList[4] = {name: "Simple", clss: "Simple_repeat"};
    that.typeList[5] = {name: "Low Comp.", clss: "Low_complexity"};
    that.typeList[6] = {name: "Satellite", clss: "Satellite"};
    that.typeList[7] = {name: "RNA", clss: "RNA"};
    that.typeList[8] = {name: "Other", clss: "Other"};
    that.typeList[9] = {name: "Unknown", clss: "Unknown"};

    that.yList = {};
    for (var i = 0; i < that.typeList.length; i++) {
        that.yList[that.typeList[i].clss] = 15 + i * 15;
    }


    that.createToolTip = function (d) {
        var tooltip = "";
        tooltip = "<BR><div id=\"ttSVG\" style=\"background:#FFFFFF;\"></div><BR>Name: " + d.getAttribute("name") + "&nbsp&nbsp&nbsp&nbsp&nbspClass: " + d.getAttribute("class");
        tooltip = tooltip + "&nbsp&nbsp&nbsp&nbsp&nbspFamily: " + d.getAttribute("family") + "<BR><BR>Location: " + d.getAttribute("chromosome") + ":" + d.getAttribute("start") + "-" + d.getAttribute("stop");
        tooltip = tooltip + "<BR><BR>Alignment Score: " + d.getAttribute("score") + "<BR>Mismatches(parts/thousand): " + d.getAttribute("mis") + "<BR>Insertions(parts/thousand): " + d.getAttribute("ins");
        tooltip = tooltip + "<BR>Deletions(parts/thousand): " + d.getAttribute("del");
        return tooltip;
    };

    /*that.color= function (d){
		var color=d3.rgb("#222222");
		/*var dClass=d.getAttribute("class");
		if(dClass==='LINE'){
			color=d3.rgb("#0C4A4A");
		}else if(dClass==='SINE'){
			color=d3.rgb("#7B4214");
		}else if(dClass==='LTR'){
			color=d3.rgb("#106210");
		}else if(dClass==='DNA'){
			color=d3.rgb("#7B1414");
		}else if(dClass==='Simple_repeat'){
			color=d3.rgb("#6B0C4C");
		}else if(dClass==='Low_complexity'){
			color=d3.rgb("#3C105E");
		}
		return color;
	};*/

    that.pieColor = function (d, i) {
        var color = d3.rgb("#000000");
        var dClass = d.data.names;
        //console.log(dClass);
        if (dClass === 'LINE') {
            color = d3.rgb("#27e5e5");
        } else if (dClass === 'SINE') {
            color = d3.rgb("#e57927");
        } else if (dClass === 'LTR') {
            color = d3.rgb("#27e527");
        } else if (dClass === 'DNA') {
            color = d3.rgb("#e52727");
        } else if (dClass === 'Simple_repeat') {
            color = d3.rgb("#e51ba2");
        } else if (dClass === 'Low_complexity') {
            color = d3.rgb("#9029e5");
        } else if (dClass === 'RNA') {
            color = d3.rgb("#005be5");
        } else if (dClass === 'Satellite') {
            color = d3.rgb("#cccc00");
        } else if (dClass === 'Other') {
            color = d3.rgb("#007f24");
        }
        return color;
    };

    that.calcY = function (start, end, i, d) {
        var tmpY = 0;
        if (that.density === 3 || that.density === '3') {
            tmpY = that.calcYPack(start, end, i);
        } else if (that.density === 2 || that.density === '2') {
            tmpY = that.calcYFull(d);
        } else {
            tmpY = that.calcYDense();
        }
        if (that.trackYMax < (tmpY / 15)) {
            that.trackYMax = (tmpY / 15);
        }
        return tmpY;
    };

    that.calcYFull = function (d) {
        var clss = d.getAttribute("class");
        if (clss.indexOf("RNA") > -1) {
            clss = "RNA";
        }
        return that.yList[clss];
    };

    that.redraw = function () {
        if (that.prevDensity != that.density) {
            that.draw(that.data);
        } else {
            that.yMaxArr = new Array();
            that.yArr = new Array();
            that.yArr[0] = new Array();
            for (var p = 0; p < that.gsvg.width; p++) {
                that.yMaxArr[p] = 0;
                that.yArr[0][p] = 0;
            }
            that.trackYMax = 0;
            var txG = d3.select("#Level" + that.gsvg.levelNumber + that.trackClass)
                .selectAll("g." + that.idPrefix + "trx" + that.gsvg.levelNumber)
                .attr("transform", function (d, i) {
                    return "translate(" + that.xScale(d.getAttribute("start")) + "," + that.calcY(parseInt(d.getAttribute("start"), 10), parseInt(d.getAttribute("stop"), 10), i, d) + ")";
                });

            txG.each(function (d, i) {
                var tmpD = d;
                var tmpI = i;
                var exList = getAllChildrenByName(getFirstChildByName(d, that.xmlTagBlockElem + "List"), that.xmlTagBlockElem);
                for (var m = 0; m < exList.length; m++) {
                    var id = that.idPrefix + "Ex" + exList[m].getAttribute("ID");
                    if (exList[m].getAttribute("ID") == null) {
                        id = that.idPrefix + "Ex" + tmpD.getAttribute("ID") + "_" + m;
                    }

                    //d3.select("#Level"+that.gsvg.levelNumber+that.trackClass+" g#"+that.idPrefix+"tx"+tmpD.getAttribute("ID")+" rect#"+id)
                    that.svg.select("g#" + that.idPrefix + "tx" + tmpD.getAttribute("ID") + " rect#" + id)
                        .attr("x", function (d) {
                            return that.xScale(exList[m].getAttribute("start")) - that.xScale(tmpD.getAttribute("start"));
                        })
                        .attr("width", function (d) {
                            return that.xScale(exList[m].getAttribute("stop")) - that.xScale(exList[m].getAttribute("start"));
                        });

                    if (m > 0) {
                        var strChar = ">";
                        if (d.getAttribute("strand") == "-1") {
                            strChar = "<";
                        }
                        var fullChar = strChar;
                        var intStart = that.xScale(exList[m - 1].getAttribute("stop")) - that.xScale(tmpD.getAttribute("start"));
                        var intStop = that.xScale(exList[m].getAttribute("start")) - that.xScale(tmpD.getAttribute("start"));
                        var rectW = intStop - intStart;
                        var alt = 0;
                        var charW = 7.0;
                        if (rectW < charW) {
                            fullChar = "";
                        } else {
                            rectW = rectW - charW;
                            while (rectW > (charW + 1)) {
                                if (alt == 0) {
                                    fullChar = fullChar + " ";
                                    alt = 1;
                                } else {
                                    fullChar = fullChar + strChar;
                                    alt = 0;
                                }
                                rectW = rectW - charW;
                            }
                        }
                        var id = exList[m - 1].getAttribute("ID") + "_" + exList[m].getAttribute("ID");
                        if (exList[m].getAttribute("ID") == null) {
                            id = tmpD.getAttribute("ID") + "_" + (m - 1) + "_" + m;
                        }
                        that.svg.select("g#" + that.idPrefix + "tx" + tmpD.getAttribute("ID") + " line#" + that.idPrefix + "Int" + id)
                            .attr("x1", intStart)
                            .attr("x2", intStop);

                        that.svg.select("g#" + that.idPrefix + "tx" + tmpD.getAttribute("ID") + " #" + that.idPrefix + "IntTxt" + id)
                            .attr("dx", intStart + 1).text(fullChar);
                    }
                }
            });
            if (that.density == 1) {
                that.svg.attr("height", 30);
            } else if (that.density == 2) {
                that.svg.attr("height", (d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll("g." + that.idPrefix + "trx" + that.gsvg.levelNumber).size() + 1) * 15);
            } else if (that.density == 3) {
                that.svg.attr("height", (that.trackYMax + 1) * 15);
            }
            that.redrawSelectedArea();
        }
    };

    that.drawTrx = function (d, i) {
        var txG = d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).select("#" + that.idPrefix + "tx" + d.getAttribute("ID"));
        exList = getAllChildrenByName(getFirstChildByName(d, that.xmlTagBlockElem + "List"), that.xmlTagBlockElem);
        if (exList.length === 1) {
            var curR = txG.append("rect")
                .attr("x", function (d) {
                    return that.xScale(exList[0].getAttribute("start")) - that.xScale(d.getAttribute("start"));
                })
                .attr("rx", 1)
                .attr("ry", 1)
                .attr("height", 10)
                .attr("width", function (d) {
                    var tmpW = that.xScale(exList[0].getAttribute("stop")) - that.xScale(exList[0].getAttribute("start"));
                    if (that.minFeatureWidth > 0 && tmpW < that.minFeatureWidth) {
                        tmpW = that.minFeatureWidth;
                    }
                    return tmpW;
                })
                .attr("id", function (d, i) {
                    var id = that.idPrefix + "Ex" + exList[0].getAttribute("ID");
                    if (exList[0].getAttribute("ID") == null) {
                        id = that.idPrefix + "Ex" + d.getAttribute("ID") + "_" + 0;
                    }
                    return id;
                })
                .style("fill", that.color)
                .style("cursor", "pointer");
        }
    };

    that.draw = function (data) {
        that.data = data;
        that.prevDensity = that.density;
        //that.setDensity();
        that.trackYMax = 0;
        that.yArr = new Array();
        that.yArr[0] = new Array();
        for (var j = 0; j < that.gsvg.width; j++) {
            that.yMaxArr[j] = 0;
            that.yArr[0][j] = 0;
        }
        that.svg.selectAll(".repeatLine" + that.gsvg.levelNumber).remove();
        that.svg.selectAll(".repeatLbl" + that.gsvg.levelNumber).remove();
        if (that.density == 2) {
            for (var i = 0; i < that.typeList.length; i++) {
                that.svg.append("line")
                    .attr("class", "repeatLine" + that.gsvg.levelNumber)
                    .attr("x1", 0)
                    .attr("x2", that.gsvg.width)
                    .attr("y1", 12 + 15 * (i + 1))
                    .attr("y2", 12 + 15 * (i + 1))
                    .attr("stroke", "#000000")
                    .attr("stroke-width", "1px");
                that.svg.append("text").attr("x", 5)
                    .attr("class", "repeatLbl" + that.gsvg.levelNumber)
                    .attr("y", 10 + 15 * (i + 1))
                    .style("pointer-events", "none")
                    .style("opacity", "0.5")
                    .style("fill", "#000000")
                    .style("font-size", "11px")
                    .text(that.typeList[i].name);
                that.svg.append("text")
                    .attr("class", "repeatLbl" + that.gsvg.levelNumber)
                    .attr("x", that.gsvg.width - 5)
                    .attr("y", 10 + 15 * (i + 1))
                    .style("text-anchor", "end")
                    .style("pointer-events", "none")
                    .style("opacity", "0.5")
                    .style("fill", "#000000")
                    .style("font-size", "11px")
                    .text(that.typeList[i].name);
                ;
            }
        }

        d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll("." + that.idPrefix + "trx" + that.gsvg.levelNumber).remove();
        that.redrawLegend();
        var tx = d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll("." + that.idPrefix + "trx" + that.gsvg.levelNumber)
            .data(data, key)
            .attr("transform", function (d, i) {
                return "translate(" + that.xScale(d.getAttribute("start")) + "," + that.calcY(parseInt(d.getAttribute("start"), 10), parseInt(d.getAttribute("stop"), 10), i, d) + ")";
            });
        tx.enter().append("g")
            .attr("class", that.idPrefix + "trx" + that.gsvg.levelNumber)
            .attr("transform", function (d, i) {
                return "translate(" + that.xScale(d.getAttribute("start")) + "," + that.calcY(parseInt(d.getAttribute("start"), 10), parseInt(d.getAttribute("stop"), 10), i, d) + ")";
            })
            .attr("id", function (d) {
                return that.idPrefix + "tx" + d.getAttribute("ID");
            })
            //.attr("pointer-events", "all")
            .style("cursor", "move")
            .on("mouseover", function (d) {
                if (that.gsvg.isToolTip == 0 && that.trackClass.indexOf("custom") != 0) {
                    d3.select(this).selectAll("line").style("stroke", "green");
                    d3.select(this).selectAll("rect").style("fill", "green");
                    d3.select(this).selectAll("text").style("opacity", "0.3").style("fill", "green");
                    tt.transition()
                        .duration(200)
                        .style("opacity", 1);
                    tt.html(that.createToolTip(d))
                        .style("left", function () {
                            return that.positionTTLeft(d3.event.pageX);
                        })
                        .style("top", function () {
                            return that.positionTTTop(d3.event.pageY);
                        });
                    if (that.ttSVG == 1) {
                        that.setupToolTipSVG(d, 0.05);
                    }
                }
            })
            .on("mouseout", function (d) {
                //if(that.gsvg.isToolTip==0){
                /*mouseTTOver=0;
							console.log("FEATURE MOUSEOUT");*/
                //var tmpThis=this;
                //ttHideHandle=setTimeout(function(){

                //if(mouseTTOver==0){
                //	console.log("MOUSE STILL NOT OVER TT");
                d3.select(this).selectAll("line").style("stroke", that.color);
                d3.select(this).selectAll("rect").style("fill", that.color);
                d3.select(this).selectAll("text").style("opacity", "0.6").style("fill", that.color);
                tt.transition()
                    .delay(100)
                    .duration(200)
                    .style("opacity", 0);
                /*}else{
													console.log("MOUSE IS NOW OVER TT")
												}*/
                //			},2000);
                //}
            })
            .each(that.drawTrx);
        tx.exit().remove();
        if (that.density == 1) {
            that.svg.attr("height", 30);
        } else if (that.density == 2) {
            that.svg.attr("height", that.typeList.length * 15 + 15);
        } else if (that.density == 3) {
            that.svg.attr("height", (that.trackYMax + 2) * 15);
        }
        that.redrawSelectedArea();
    };

    that.getDisplayedData = function () {
        var dataElem = d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll("." + that.idPrefix + "trx" + that.gsvg.levelNumber);
        that.counts = new Array();
        var tmp = {};
        var tmpDat = dataElem[0];
        var dispData = new Array();
        var dispDataCount = 0;
        if (!(typeof tmpDat === 'undefined')) {
            for (var l = 0; l < tmpDat.length; l++) {
                var start = that.xScale(tmpDat[l].__data__.getAttribute("start"));
                var stop = that.xScale(tmpDat[l].__data__.getAttribute("stop"));
                if ((0 <= start && start <= that.gsvg.width) || (0 <= stop && stop <= that.gsvg.width)) {
                    if (typeof tmp[tmpDat[l].__data__.getAttribute("class")] === "undefined") {
                        tmp[tmpDat[l].__data__.getAttribute("class")] = {};
                        tmp[tmpDat[l].__data__.getAttribute("class")].value = 1;
                        tmp[tmpDat[l].__data__.getAttribute("class")].names = tmpDat[l].__data__.getAttribute("class");
                    } else {
                        tmp[tmpDat[l].__data__.getAttribute("class")].value = tmp[tmpDat[l].__data__.getAttribute("class")].value + 1;
                    }
                    dispData[dispDataCount] = tmpDat[l].__data__;
                    dispDataCount++;
                }
            }
            that.counts = new Array();
            for (x in tmp) {
                that.counts.push(tmp[x]);
            }
        } else {
            that.counts = new Array();
        }
        return dispData;
    };

    /*that.redrawLegend=function (){
		var legend=[];
		legend[0]={color:"#7B4214",label:"SINE"};
		legend[1]={color:"#0C4A4A",label:"LINE"};
		legend[2]={color:"#106210",label:"LTR"};
		legend[3]={color:"#7B1414",label:"DNA"};
		legend[4]={color:"#6B0C4C",label:"Simple"};
		legend[5]={color:"#3C105E",label:"Low Comp."};
		legend[6]={color:"#64840F",label:"Sat."};
		legend[7]={color:"#8C8810",label:"RNA"};
		legend[8]={color:"#104466",label:"Other"};
		legend[9]={color:"#9F6011",label:"Unkwn"};
		that.drawLegend(legend);
	};*/

    that.draw(data);
    return that;
}

function GenericTranscriptTrack(gsvg, data, trackClass, label, density, additionalOptions) {
    var that = Track(gsvg, data, trackClass, label);
    //Set Defaults
    that.dataFileName = trackClass + ".xml";
    that.xmlTag = "Feature";
    that.xmlTagBlockElem = "block";
    that.idPrefix = "genTrx";
    that.ttSVG = 0;
    that.ttTrackList = new Array();
    that.colorValueField = "score";
    that.colorBy = "Score";
    that.minValue = 1;
    that.maxValue = 1000;
    that.minColor = "#E6E6E6";
    that.maxColor = "#000000";
    that.minFeatureWidth = -1;
    that.ttSVGMinWidth = 0;
    that.legendLbl = "";
    //Set Specified Options
    var addtlOpt = new String(additionalOptions);
    if (typeof additionalOptions !== 'undefined' && addtlOpt.length > 0) {
        var opt = addtlOpt.split(",");
        for (var i = 0; i < opt.length; i++) {
            var optStr = new String(opt[i]);
            if (optStr.indexOf("colorBy=") == 0) {
                that.colorBy = optStr.substr(optStr.indexOf("=") + 1);
            } else if (optStr.indexOf("minColor=") == 0) {
                that.minColor = optStr.substr(optStr.indexOf("=") + 1);
            } else if (optStr.indexOf("maxColor=") == 0) {
                that.maxColor = optStr.substr(optStr.indexOf("=") + 1);
            } else if (optStr.indexOf("minValue=") == 0) {
                that.minValue = optStr.substr(optStr.indexOf("=") + 1);
            } else if (optStr.indexOf("maxValue=") == 0) {
                that.maxValue = optStr.substr(optStr.indexOf("=") + 1);
            }
        }
    }

    that.createColorScale = function () {
        if (typeof that.minColor !== 'undefined' && typeof that.maxColor !== 'undefined') {
            that.colorScale = d3.scaleLinear().domain([that.minValue, that.maxValue]).range([that.minColor, that.maxColor]);
        }
    };
    that.createColorScale();

    that.setMinColor = function (color) {
        that.minColor = "#" + color;
        that.createColorScale();
        that.draw(that.data);
    };

    that.setMaxColor = function (color) {
        that.maxColor = "#" + color;
        that.createColorScale();
        that.draw(that.data);
    };

    that.setMinValue = function (value) {
        that.minValue = value;
        that.createColorScale();
        that.draw(that.data);
    };

    that.setMaxValue = function (value) {
        that.maxValue = value;
        that.createColorScale();
        that.draw(that.data);
    };
    that.setColorBy = function (value) {
        that.colorBy = value;
        that.createColorScale();
        that.draw(that.data);
    }

    that.getDisplayID = function (d) {
        return d.getAttribute("ID");
    };

    that.createToolTip = function (d) {
        var tooltip = "";
        return tooltip;
    };


    that.getColorValue = function (d) {
        return d.getAttribute(that.colorValueField);
    }

    that.color = function (d) {
        var color = d3.rgb("#FFFFFF");
        if (that.colorBy == "Score") {
            color = that.colorScale(that.getColorValue(d));
        } else if (that.colorBy == "Color") {
            var colorStr = new String(d.getAttribute("color"));
            var colorArr = colorStr.split(",");
            if (colorArr.length == 3) {
                color = d3.rgb(colorArr[0], colorArr[1], colorArr[2]);
            }
        }
        return color;
    };

    that.savePrevious = function () {
        that.prevSetting = {};
        that.prevSetting.density = that.density;
        that.prevSetting.colorValueField = that.colorValueField;
        that.prevSetting.colorBy = that.colorBy;
        that.prevSetting.minValue = that.minValue;
        that.prevSetting.maxValue = that.maxValue;
        that.prevSetting.minColor = that.minColor;
        that.prevSetting.maxColor = that.maxColor;
    };

    that.revertPrevious = function () {
        that.density = that.prevSetting.density;
        that.colorValueField = that.prevSetting.colorValueField;
        that.colorBy = that.prevSetting.colorBy;
        that.minValue = that.prevSetting.minValue;
        that.maxValue = that.prevSetting.maxValue;
        that.minColor = that.prevSetting.minColor;
        that.maxColor = that.prevSetting.maxColor;
        if (that.colorBy == "Score") {
            that.createColorScale();
        }
    };

    that.drawTrx = function (d, i) {
        var txG = d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).select("#" + that.idPrefix + "tx" + d.getAttribute("ID"));
        exList = getAllChildrenByName(getFirstChildByName(d, that.xmlTagBlockElem + "List"), that.xmlTagBlockElem);
        //console.log("DRAW TRX:");
        //console.log(exList);
        for (var m = 0; m < exList.length; m++) {
            var curR = txG.append("rect")
                .attr("x", function (d) {
                    return that.xScale(exList[m].getAttribute("start")) - that.xScale(d.getAttribute("start"));
                })
                .attr("rx", 1)
                .attr("ry", 1)
                .attr("height", 10)
                .attr("width", function (d) {
                    var tmpW = that.xScale(exList[m].getAttribute("stop")) - that.xScale(exList[m].getAttribute("start"));
                    if (that.minFeatureWidth > 0 && tmpW < that.minFeatureWidth) {
                        tmpW = that.minFeatureWidth;
                    }
                    return tmpW;
                })
                //.attr("title",function(d){ return exList[m].getAttribute("ID");})
                .attr("id", function (d, i) {
                    var id = that.idPrefix + "Ex" + exList[m].getAttribute("ID");
                    if (exList[m].getAttribute("ID") == null) {
                        id = that.idPrefix + "Ex" + d.getAttribute("ID") + "_" + m;
                    }
                    return id;
                })
                .style("fill", that.color)
                .style("cursor", "pointer");
            if (m > 0) {
                var intStart = that.xScale(exList[m - 1].getAttribute("stop")) - that.xScale(d.getAttribute("start"));
                var intStop = that.xScale(exList[m].getAttribute("start")) - that.xScale(d.getAttribute("start"));
                txG.append("line")
                    .attr("x1", intStart)//function(d){ return that.xScale(exList[m-1].getAttribute("stop"))-that.xScale(d.getAttribute("start")); })
                    .attr("x2", intStop)//function(d){ return that.xScale(exList[m].getAttribute("start"))-that.xScale(d.getAttribute("start")); })
                    .attr("y1", 5)
                    .attr("y2", 5)
                    .attr("stroke", that.color)
                    .attr("stroke-width", "2")
                    .attr("id", function (d, i) {
                        var id = that.idPrefix + "Int" + exList[m - 1].getAttribute("ID") + "_" + exList[m].getAttribute("ID");
                        if (exList[m].getAttribute("ID") == null) {
                            id = that.idPrefix + "Int" + d.getAttribute("ID") + "_" + (m - 1) + "_" + m;
                        }
                        return id;
                    });
                var strChar = ">";
                if (d.getAttribute("strand") == "-1") {
                    strChar = "<";
                }
                var fullChar = strChar;

                var rectW = intStop - intStart;
                var alt = 0;
                var charW = 7.0;
                if (rectW < charW) {
                    fullChar = "";
                } else {
                    rectW = rectW - charW;
                    while (rectW > (charW + 1)) {
                        if (alt == 0) {
                            fullChar = fullChar + " ";
                            alt = 1;
                        } else {
                            fullChar = fullChar + strChar;
                            alt = 0;
                        }
                        rectW = rectW - charW;
                    }
                }
                txG.append("svg:text").attr("id", function (d) {
                    var id = that.idPrefix + "IntTxt" + exList[m - 1].getAttribute("ID") + "_" + exList[m].getAttribute("ID");
                    if (exList[m].getAttribute("ID") == null) {
                        id = that.idPrefix + "IntTxt" + d.getAttribute("ID") + "_" + (m - 1) + "_" + m;
                    }
                    return id;
                })
                    .attr("dx", intStart + 1)
                    .attr("dy", "11")
                    .style("pointer-events", "none")
                    .style("opacity", "0.5")
                    .style("fill", that.color)
                    .style("font-size", "16px")
                    .text(fullChar);

            }
        }

    };

    that.redraw = function () {
        if (that.prevDensity != that.density) {
            that.draw(that.data);
        } else {
            that.yMaxArr = new Array();
            that.yArr = new Array();
            that.yArr[0] = new Array();
            for (var p = 0; p < that.gsvg.width; p++) {
                that.yMaxArr[p] = 0;
                that.yArr[0][p] = 0;
            }
            that.trackYMax = 0;
            var txG = d3.select("#Level" + that.gsvg.levelNumber + that.trackClass)
                .selectAll("g." + that.idPrefix + "trx" + that.gsvg.levelNumber)
                .attr("transform", function (d, i) {
                    return "translate(" + that.xScale(d.getAttribute("start")) + "," + that.calcY(parseInt(d.getAttribute("start"), 10), parseInt(d.getAttribute("stop"), 10), i) + ")";
                });

            txG.each(function (d, i) {
                var tmpD = d;
                var tmpI = i;
                var exList = getAllChildrenByName(getFirstChildByName(d, that.xmlTagBlockElem + "List"), that.xmlTagBlockElem);
                for (var m = 0; m < exList.length; m++) {
                    var id = that.idPrefix + "Ex" + exList[m].getAttribute("ID");
                    if (exList[m].getAttribute("ID") == null) {
                        id = that.idPrefix + "Ex" + tmpD.getAttribute("ID") + "_" + m;
                    }

                    //d3.select("#Level"+that.gsvg.levelNumber+that.trackClass+" g#"+that.idPrefix+"tx"+tmpD.getAttribute("ID")+" rect#"+id)
                    that.svg.select("g#" + that.idPrefix + "tx" + tmpD.getAttribute("ID") + " rect#" + id)
                        .attr("x", function (d) {
                            return that.xScale(exList[m].getAttribute("start")) - that.xScale(tmpD.getAttribute("start"));
                        })
                        .attr("width", function (d) {
                            return that.xScale(exList[m].getAttribute("stop")) - that.xScale(exList[m].getAttribute("start"));
                        });

                    if (m > 0) {
                        var strChar = ">";
                        if (d.getAttribute("strand") == "-1") {
                            strChar = "<";
                        }
                        var fullChar = strChar;
                        var intStart = that.xScale(exList[m - 1].getAttribute("stop")) - that.xScale(tmpD.getAttribute("start"));
                        var intStop = that.xScale(exList[m].getAttribute("start")) - that.xScale(tmpD.getAttribute("start"));
                        var rectW = intStop - intStart;
                        var alt = 0;
                        var charW = 7.0;
                        if (rectW < charW) {
                            fullChar = "";
                        } else {
                            rectW = rectW - charW;
                            while (rectW > (charW + 1)) {
                                if (alt == 0) {
                                    fullChar = fullChar + " ";
                                    alt = 1;
                                } else {
                                    fullChar = fullChar + strChar;
                                    alt = 0;
                                }
                                rectW = rectW - charW;
                            }
                        }
                        var id = exList[m - 1].getAttribute("ID") + "_" + exList[m].getAttribute("ID");
                        if (exList[m].getAttribute("ID") == null) {
                            id = tmpD.getAttribute("ID") + "_" + (m - 1) + "_" + m;
                        }
                        that.svg.select("g#" + that.idPrefix + "tx" + tmpD.getAttribute("ID") + " line#" + that.idPrefix + "Int" + id)
                            .attr("x1", intStart)
                            .attr("x2", intStop);

                        that.svg.select("g#" + that.idPrefix + "tx" + tmpD.getAttribute("ID") + " #" + that.idPrefix + "IntTxt" + id)
                            .attr("dx", intStart + 1).text(fullChar);
                    }
                }
            });
            if (that.density == 1) {
                that.svg.attr("height", 30);
            } else if (that.density == 2) {
                that.svg.attr("height", (d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll("g." + that.idPrefix + "trx" + that.gsvg.levelNumber).size() + 1) * 15);
            } else if (that.density == 3) {
                that.svg.attr("height", (that.trackYMax + 1) * 15);
            }
            that.redrawSelectedArea();
        }
    };

    that.update = function (d) {
        that.redraw();
    };

    that.updateFullData = function (retry, force) {
        var tmpMin = that.xScale.domain()[0];
        var tmpMax = that.xScale.domain()[1];
        that.showLoading();
        var file = dataPrefix + "tmpData/browserCache/" + genomeVer + "/regionData/" + that.gsvg.folderName + "/" + that.dataFileName;
        d3.xml(file, function (error, d) {
            if (error) {
                //console.log(error);
                if (retry == 0 || force == 1) {
                    var tmpContext = "/" + pathPrefix;
                    if (!pathPrefix) {
                        tmpContext = "";
                    }
                    $.ajax({
                        url: tmpContext + "generateTrackXML.jsp",
                        type: 'GET',
                        cache: false,
                        async: true,
                        data: {
                            chromosome: chr,
                            minCoord: tmpMin,
                            maxCoord: tmpMax,
                            panel: panel,
                            rnaDatasetID: rnaDatasetID,
                            arrayTypeID: arrayTypeID,
                            myOrganism: organism,
                            genomeVer: genomeVer,
                            dataVer: dataVer,
                            track: that.trackClass,
                            folder: that.gsvg.folderName
                        },
                        //data: {chromosome: chr,minCoord:minCoord,maxCoord:maxCoord,panel:panel,rnaDatasetID:rnaDatasetID,arrayTypeID: arrayTypeID, myOrganism: organism, track: that.trackClass, folder: folderName,binSize:that.bin},
                        dataType: 'json',
                        success: function (data2) {
                            /*if(ga){
										ga('send','event','browser','generateTrackTranscript');
									}*/
                            gtag('event', 'generateTrackTranscript', {'event_category': 'browser'});
                        },
                        error: function (xhr, status, error) {

                        }
                    });
                }
                if (retry < 3) {//wait before trying again
                    var time = 10000;
                    if (retry == 1) {
                        time = 15000;
                    }
                    setTimeout(function () {
                        that.updateFullData(retry + 1, 0);
                    }, time);
                } else {
                    d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).select("#trkLbl").text("An errror occurred loading Track:" + that.trackClass);
                    d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).attr("height", 15);
                    that.gsvg.addTrackErrorRemove(that.svg, "#Level" + that.gsvg.levelNumber + that.trackClass);
                    that.hideLoading();
                }
            } else {
                if (d == null) {
                    if (retry >= 4) {
                        data = new Array();
                        that.draw(data);
                        that.hideLoading();
                    } else {
                        setTimeout(function () {
                            that.updateFullData(retry + 1, 0);
                        }, 5000);
                    }
                } else {
                    var data = d.documentElement.getElementsByTagName(that.xmlTag);
                    that.draw(data);
                    that.hideLoading();
                }
            }
        });
    };

    that.redrawLegend = function () {
        var legend = [];
        var curPos = 0;
        if (that.colorBy == "Score") {
            that.drawScaleLegend(that.minValue, that.maxValue + "+", that.legendLbl, that.minColor, that.maxColor, 0);
        } else if (that.colorBy == "Color") {
            legend[curPos] = {color: "#FFFFFF", label: "User assigned color from track file."};
            that.drawLegend(legend);
        }

    };


    that.draw = function (data) {
        //console.log("DRAW"+that.trackClass);
        that.data = data;
        that.prevDensity = that.density;
        //that.setDensity();
        that.trackYMax = 0;
        that.yArr = new Array();
        that.yArr[0] = new Array();
        for (var j = 0; j < that.gsvg.width; j++) {
            that.yMaxArr[j] = 0;
            that.yArr[0][j] = 0;
        }
        //console.log("#Level"+that.gsvg.levelNumber+that.trackClass);
        //console.log("."+that.idPrefix+"trx"+that.gsvg.levelNumber);
        d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll("." + that.idPrefix + "trx" + that.gsvg.levelNumber).remove();
        that.redrawLegend();
        if (data) {
            //console.log(data);
            //d3.select("#Level"+that.gsvg.levelNumber+that.trackClass)
            var tmp = d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll("." + that.idPrefix + "trx" + that.gsvg.levelNumber)
                .data(data, key);
            //console.log(tmp);
            tmp.enter().append("g")
                .attr("class", that.idPrefix + "trx" + that.gsvg.levelNumber)
                .attr("transform", function (d, i) {
                    return "translate(" + that.xScale(d.getAttribute("start")) + "," + that.calcY(parseInt(d.getAttribute("start"), 10), parseInt(d.getAttribute("stop"), 10), i) + ")";
                })
                .attr("id", function (d) {
                    return that.idPrefix + "tx" + d.getAttribute("ID");
                })
                //.attr("pointer-events", "all")
                .style("cursor", "move")
                .on("mouseover", function (d) {
                    if (that.gsvg.isToolTip == 0 && that.trackClass.indexOf("custom") != 0) {
                        d3.select(this).selectAll("line").style("stroke", "green");
                        d3.select(this).selectAll("rect").style("fill", "green");
                        d3.select(this).selectAll("text").style("opacity", "0.3").style("fill", "green");
                        tt.transition()
                            .duration(200)
                            .style("opacity", 1);
                        tt.html(that.createToolTip(d))
                            .style("left", function () {
                                return that.positionTTLeft(d3.event.pageX);
                            })
                            .style("top", function () {
                                return that.positionTTTop(d3.event.pageY);
                            });
                        if (that.ttSVG == 1) {
                            that.setupToolTipSVG(d, 0.05);
                        }
                    }
                })
                .on("mouseout", function (d) {
                    //if(that.gsvg.isToolTip==0){
                    /*mouseTTOver=0;
								console.log("FEATURE MOUSEOUT");*/
                    //var tmpThis=this;
                    //ttHideHandle=setTimeout(function(){

                    //if(mouseTTOver==0){
                    //	console.log("MOUSE STILL NOT OVER TT");
                    d3.select(this).selectAll("line").style("stroke", that.color);
                    d3.select(this).selectAll("rect").style("fill", that.color);
                    d3.select(this).selectAll("text").style("opacity", "0.6").style("fill", that.color);
                    tt.transition()
                        .delay(100)
                        .duration(200)
                        .style("opacity", 0);
                    /*}else{
														console.log("MOUSE IS NOW OVER TT")
													}*/
                    //			},2000);
                    //}
                })
                .merge(tmp)
                .each(that.drawTrx);
            //tmp.attr("transform",
            //		function(d,i){ return "translate("+that.xScale(d.getAttribute("start"))+","+that.calcY(parseInt(d.getAttribute("start"),10),parseInt(d.getAttribute("stop"),10),i)+")";});

            tmp.exit().remove();
        }
        if (that.density == 1) {
            that.svg.attr("height", 30);
        } else if (that.density == 2) {
            that.svg.attr("height", (d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll("g." + that.idPrefix + "trx" + that.gsvg.levelNumber).size() + 1) * 15);
        } else if (that.density == 3) {
            that.svg.attr("height", (that.trackYMax + 2) * 15);
        }
        that.redrawSelectedArea();
    };
    return that;
}

function CircRNATrack(gsvg, data, trackClass, label, density, additionalOptions) {
    var that = GenericTranscriptTrack(gsvg, data, trackClass, label, density, additionalOptions);
    var opts = [];
    if (additionalOptions) {
        if (additionalOptions.indexOf(",") > 0) {
            opts = additionalOptions.split(",");
        } else {
            opts[0] = additionalOptions;
        }
    }
    that.density = density;
    if (opts.length > 0) {
        that.dataFileName = opts[0].substr(9);
    }
    if (opts.length > 1) {
        that.colorBy = opts[1];
    } else {
        that.colorBy = "Score";
    }
    if (opts.length > 2) {
        that.minValue = opts[2];
    }
    if (opts.length > 3) {
        that.maxValue = opts[3];
    }
    if (opts.length > 4) {
        that.minColor = opts[4];
    }
    if (opts.length > 5) {
        that.maxColor = opts[5];
    }
    //that.dataFileName=trackClass.substr(6)+".bed";
    that.colorValueField = "score";
    that.minFeatureWidth = 1;
    that.updateControl = 0;
    that.xmlTag = "Gene";
    that.xmlTagBlockElem = "Block";
    that.idPrefix = "cirRNA";
    that.xCirLineWidth = 4;
    that.xPadding = 7;
    that.featureHeight = 30;

    if (that.colorBy == "Score") {
        that.createColorScale();
    }
    that.color = function (d) {
        var color = d3.rgb("#000000");
        if (d.getAttribute("Array") === "1" && d.getAttribute("Ciri") === "1" && d.getAttribute("Circexplorer") === "1") {
            color = d3.rgb("#DD9C56");
        } else if (d.getAttribute("Array") === "0" && d.getAttribute("Ciri") === "1" && d.getAttribute("Circexplorer") === "1") {
            color = d3.rgb("#0f4c75");
        } else if (d.getAttribute("Array") === "0" && (d.getAttribute("Ciri") === "1" || d.getAttribute("Circexplorer") === "1")) {
            color = d3.rgb("#3282b8");
        } else if (d.getAttribute("Array") === "1" && d.getAttribute("Ciri") === "0" && d.getAttribute("Circexplorer") === "0") {
            color = d3.rgb("#5D576B");
        } else if (d.getAttribute("Array") === "1" && (d.getAttribute("Ciri") === "1" || d.getAttribute("Circexplorer") === "1")) {
            color = d3.rgb("#7A9D98");
        }
        return color;
    };

    that.calcY = function (start, end, i) {
        var tmpY = 0;
        if (that.density === 3 || that.density === '3') {
            tmpY = that.calcYPack(start, end, i);
        } else if (that.density === 2 || that.density === '2') {
            tmpY = that.calcYFull(i);
        } else {
            tmpY = that.calcYDense();
        }
        if (that.trackYMax < (tmpY / that.featureHeight)) {
            that.trackYMax = (tmpY / that.featureHeight);
        }
        return tmpY;
    };

    that.calcYPack = function (start, end, i) {
        var tmpY = 0;
        if ((start >= that.xScale.domain()[0] && start <= that.xScale.domain()[1]) ||
            (end >= that.xScale.domain()[0] && end <= that.xScale.domain()[1]) ||
            (start <= that.xScale.domain()[0] && end >= that.xScale.domain()[1])) {
            var pStart = Math.round(that.xScale(start));
            if (pStart < 0) {
                pStart = 0;
            }
            var pEnd = Math.round(that.xScale(end));
            if (pEnd >= that.gsvg.width) {
                pEnd = that.gsvg.width - 1;
            }
            var pixStart = pStart - that.xPadding;
            if (pixStart < 0) {
                pixStart = 0;
            }
            var pixEnd = pEnd + that.xPadding;
            if (pixEnd >= that.gsvg.width) {
                pixEnd = that.gsvg.width - 1;
            }
            //find yMax that is clear this is highest line that is clear
            var yMax = 0;
            for (var pix = pixStart; pix <= pixEnd; pix++) {
                if (that.yMaxArr[pix] > yMax) {
                    yMax = that.yMaxArr[pix];
                }
            }
            yMax++;
            //may need to extend yArr for a new line
            var addLine = yMax;
            if (that.yArr.length <= yMax) {
                that.yArr[addLine] = new Array();
                for (var j = 0; j < that.gsvg.width; j++) {
                    that.yArr[addLine][j] = 0;
                }
            }
            //check a couple lines back to see if it can be squeezed in
            var startLine = yMax - that.scanBackYLines;
            if (startLine < 1) {
                startLine = 1;
            }
            var prevLine = -1;
            var stop = 0;
            for (var scanLine = startLine; scanLine < yMax && stop == 0; scanLine++) {
                var available = 0;
                for (var pix = pixStart; pix <= pixEnd && available == 0; pix++) {
                    if (that.yArr[scanLine][pix] > available) {
                        available = 1;
                    }
                }
                if (available == 0) {
                    yMax = scanLine;
                    stop = 1;
                }
            }
            if (yMax > that.trackYMax) {
                that.trackYMax = yMax;
            }
            for (var pix = pStart; pix <= pEnd; pix++) {
                if (that.yMaxArr[pix] < yMax) {
                    that.yMaxArr[pix] = yMax;
                }
                that.yArr[yMax][pix] = 1;
            }
            tmpY = yMax * that.featureHeight;
        } else {
            tmpY = that.featureHeight;
        }
        return tmpY;
    };
    that.calcYFull = function (i) {
        return (i + 1) * that.featureHeight;
    };

    that.draw = function (data) {
        that.data = data;
        that.prevDensity = that.density;
        //that.setDensity();
        that.trackYMax = 0;
        that.yArr = new Array();
        that.yArr[0] = new Array();
        for (var j = 0; j < that.gsvg.width; j++) {
            that.yMaxArr[j] = 0;
            that.yArr[0][j] = 0;
        }

        d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll("." + that.idPrefix + "trx" + that.gsvg.levelNumber).remove();
        that.redrawLegend();
        if (data) {
            //d3.select("#Level"+that.gsvg.levelNumber+that.trackClass)
            var tmp = d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll("." + that.idPrefix + "trx" + that.gsvg.levelNumber)
                .data(data, key);

            tmp.enter().append("g")
                .attr("class", that.idPrefix + "trx" + that.gsvg.levelNumber)
                .attr("transform", function (d, i) {
                    return "translate(" + that.xScale(d.getAttribute("start")) + "," + that.calcY(parseInt(d.getAttribute("start"), 10), parseInt(d.getAttribute("stop"), 10), i) + ")";
                })
                .attr("id", function (d) {
                    return that.idPrefix + "tx" + d.getAttribute("ID");
                })
                //.attr("pointer-events", "all")
                .style("cursor", "move")
                .on("mouseover", function (d) {
                    if (that.gsvg.isToolTip == 0 && that.trackClass.indexOf("custom") != 0) {
                        d3.select(this).selectAll("line").style("stroke", "green");
                        d3.select(this).selectAll("rect").style("fill", "green");
                        d3.select(this).selectAll("text").style("opacity", "0.3").style("fill", "green");
                        tt.transition()
                            .duration(200)
                            .style("opacity", 1);
                        tt.html(that.createToolTip(d))
                            .style("left", function () {
                                return that.positionTTLeft(d3.event.pageX);
                            })
                            .style("top", function () {
                                return that.positionTTTop(d3.event.pageY);
                            });
                        if (that.ttSVG == 1) {
                            that.setupToolTipSVG(d, 0.05);
                        }
                    }
                })
                .on("mouseout", function (d) {
                    //if(that.gsvg.isToolTip==0){
                    /*mouseTTOver=0;
                    console.log("FEATURE MOUSEOUT");*/
                    //var tmpThis=this;
                    //ttHideHandle=setTimeout(function(){

                    //if(mouseTTOver==0){
                    //	console.log("MOUSE STILL NOT OVER TT");
                    d3.select(this).selectAll("line").style("stroke", that.color);
                    d3.select(this).selectAll("rect").style("fill", that.color);
                    d3.select(this).selectAll("text").style("opacity", "0.6").style("fill", that.color);
                    tt.transition()
                        .delay(100)
                        .duration(200)
                        .style("opacity", 0);
                    /*}else{
                        console.log("MOUSE IS NOW OVER TT")
                    }*/
                    //			},2000);
                    //}
                })
                .merge(tmp)
                .each(that.drawTrx);
            //tmp.attr("transform",
            //		function(d,i){ return "translate("+that.xScale(d.getAttribute("start"))+","+that.calcY(parseInt(d.getAttribute("start"),10),parseInt(d.getAttribute("stop"),10),i)+")";});

            tmp.exit().remove();
        }
        if (that.density == 1) {
            that.svg.attr("height", 30);
        } else if (that.density == 2) {
            that.svg.attr("height", (d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll("g." + that.idPrefix + "trx" + that.gsvg.levelNumber).size() + 1) * 15);
        } else if (that.density == 3) {
            that.svg.attr("height", (that.trackYMax + 2) * 30);
        }
        that.redrawSelectedArea();
    };
    that.drawTrx = function (d, i) {
        var txG = d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).select("#" + that.idPrefix + "tx" + d.getAttribute("ID"));
        exList = getAllChildrenByName(getFirstChildByName(d, that.xmlTagBlockElem + "List"), that.xmlTagBlockElem);
        minStart = that.xScale(d.getAttribute("start"));
        maxEnd = that.xScale(d.getAttribute("stop"));
        txG.append("line")
            .attr("id", function () {
                return "l" + d.getAttribute("ID") + "_x1"
            })
            .attr("x1", function () {
                return that.calcXLine(exList, 0, -1, "start", minStart);
            })
            .attr("x2", function () {
                return that.calcXLine(exList, 0, -1, "start", minStart);
            })
            .attr("y1", 5)
            .attr("y2", 20)
            .attr("stroke", that.color)
            .attr("stroke-width", "1");
        txG.append("line")
            .attr("id", function () {
                return "l" + d.getAttribute("ID") + "_x2"
            })
            .attr("x1", function () {
                return that.calcXLine(exList, exList.length - 1, 1, "stop", minStart);
            })
            .attr("x2", function () {
                return that.calcXLine(exList, exList.length - 1, 1, "stop", minStart);
            })
            .attr("y1", 5)
            .attr("y2", 20)
            .attr("stroke", that.color)
            .attr("stroke-width", "1");
        txG.append("line")
            .attr("id", function () {
                return "l" + d.getAttribute("ID") + "_x3"
            })
            .attr("x1", function () {
                return that.calcXLine(exList, 0, -1, "start", minStart);
            })
            .attr("x2", function () {
                return that.calcXLine(exList, exList.length - 1, 1, "stop", minStart);
            })
            .attr("y1", 5)
            .attr("y2", 5)
            .attr("stroke", that.color)
            .attr("stroke-width", "1");
        txG.append("line")
            .attr("id", function () {
                return "l" + d.getAttribute("ID") + "_x4"
            })
            .attr("x1", function () {
                return that.calcXLine(exList, 0, -1, "start", minStart);
            })
            .attr("x2", function () {
                return that.calcXLine(exList, 0, 0, "start", minStart);
            })
            .attr("y1", 20)
            .attr("y2", 20)
            .attr("stroke", that.color)
            .attr("stroke-width", "1");
        txG.append("line")
            .attr("id", function () {
                return "l" + d.getAttribute("ID") + "_x5"
            })
            .attr("x1", function () {
                return that.calcXLine(exList, exList.length - 1, 0, "stop", minStart);
            })
            .attr("x2", function () {
                return that.calcXLine(exList, exList.length - 1, 1, "stop", minStart);
            })
            .attr("y1", 20)
            .attr("y2", 20)
            .attr("stroke", that.color)
            .attr("stroke-width", "1");

        for (var m = 0; m < exList.length; m++) {
            var curR = txG.append("rect")
                .attr("x", function (d) {
                    return that.xScale(exList[m].getAttribute("start")) - that.xScale(d.getAttribute("start"));
                })
                .attr("y", 15)
                .attr("rx", 1)
                .attr("ry", 1)
                .attr("height", 10)
                .attr("width", function (d) {
                    var tmpW = that.xScale(exList[m].getAttribute("stop")) - that.xScale(exList[m].getAttribute("start"));
                    if (that.minFeatureWidth > 0 && tmpW < that.minFeatureWidth) {
                        tmpW = that.minFeatureWidth;
                    }
                    return tmpW;
                })
                //.attr("title",function(d){ return exList[m].getAttribute("ID");})
                .attr("id", function (d, i) {
                    var id = that.idPrefix + "Ex" + exList[m].getAttribute("ID");
                    if (exList[m].getAttribute("ID") == null) {
                        id = that.idPrefix + "Ex" + d.getAttribute("ID") + "_" + m;
                    }
                    return id;
                })
                .style("fill", that.color)
                .style("cursor", "pointer");
            if (m > 0) {
                var intStart = that.xScale(exList[m - 1].getAttribute("stop")) - that.xScale(d.getAttribute("start"));
                var intStop = that.xScale(exList[m].getAttribute("start")) - that.xScale(d.getAttribute("start"));
                txG.append("line")
                    .attr("x1", intStart)//function(d){ return that.xScale(exList[m-1].getAttribute("stop"))-that.xScale(d.getAttribute("start")); })
                    .attr("x2", intStop)//function(d){ return that.xScale(exList[m].getAttribute("start"))-that.xScale(d.getAttribute("start")); })
                    .attr("y1", 20)
                    .attr("y2", 20)
                    .attr("stroke", that.color)
                    .attr("stroke-width", "2")
                    .attr("id", function (d, i) {
                        var id = that.idPrefix + "Int" + exList[m - 1].getAttribute("ID") + "_" + exList[m].getAttribute("ID");
                        if (exList[m].getAttribute("ID") == null) {
                            id = that.idPrefix + "Int" + d.getAttribute("ID") + "_" + (m - 1) + "_" + m;
                        }
                        return id;
                    });
                var strChar = ">";
                if (d.getAttribute("strand") === "-") {
                    strChar = "<";
                }
                var fullChar = strChar;

                var rectW = intStop - intStart;
                var alt = 0;
                var charW = 7.0;
                if (rectW < charW) {
                    fullChar = "";
                } else {
                    rectW = rectW - charW;
                    while (rectW > (charW + 1)) {
                        if (alt == 0) {
                            fullChar = fullChar + " ";
                            alt = 1;
                        } else {
                            fullChar = fullChar + strChar;
                            alt = 0;
                        }
                        rectW = rectW - charW;
                    }
                }
                txG.append("svg:text").attr("id", function (d) {
                    var id = that.idPrefix + "IntTxt" + exList[m - 1].getAttribute("ID") + "_" + exList[m].getAttribute("ID");
                    if (exList[m].getAttribute("ID") == null) {
                        id = that.idPrefix + "IntTxt" + d.getAttribute("ID") + "_" + (m - 1) + "_" + m;
                    }
                    return id;
                }).attr("y", 15)
                    .attr("dx", intStart + 1)
                    .attr("dy", "11")
                    .style("pointer-events", "none")
                    .style("opacity", "0.5")
                    .style("fill", that.color)
                    .style("font-size", "16px")
                    .text(fullChar);

            }
        }

    };
    that.calcXLine = function (exList, ind, plusMinus, attr, xStart) {
        var val = 0;
        var adjust = that.xCirLineWidth * plusMinus;
        if (exList.length > 0) {
            val = that.xScale(exList[ind].getAttribute(attr)) - xStart + adjust;
        } else {
            val = 0 + adjust;
        }
        return val;
    };


    that.redraw = function () {
        if (that.prevDensity != that.density) {
            that.draw(that.data);
        } else {
            that.yMaxArr = new Array();
            that.yArr = new Array();
            that.yArr[0] = new Array();
            for (var p = 0; p < that.gsvg.width; p++) {
                that.yMaxArr[p] = 0;
                that.yArr[0][p] = 0;
            }
            that.trackYMax = 0;
            var txG = d3.select("#Level" + that.gsvg.levelNumber + that.trackClass)
                .selectAll("g." + that.idPrefix + "trx" + that.gsvg.levelNumber)
                .attr("transform", function (d, i) {
                    return "translate(" + that.xScale(d.getAttribute("start")) + "," + that.calcY(parseInt(d.getAttribute("start"), 10), parseInt(d.getAttribute("stop"), 10), i) + ")";
                });

            txG.each(function (d, i) {
                var tmpD = d;
                minStart = that.xScale(tmpD.getAttribute("start"));
                maxEnd = that.xScale(tmpD.getAttribute("stop"));


                var tmpI = i;
                var exList = getAllChildrenByName(getFirstChildByName(d, that.xmlTagBlockElem + "List"), that.xmlTagBlockElem);
                //update backsplice lines
                that.svg.select("#l" + tmpD.getAttribute("ID") + "_x1")
                    .attr("x1", function () {
                        return that.calcXLine(exList, 0, -1, "start", minStart);
                    })
                    .attr("x2", function () {
                        return that.calcXLine(exList, 0, -1, "start", minStart);
                    });
                that.svg.select("#l" + tmpD.getAttribute("ID") + "_x2")
                    .attr("x1", function () {
                        return that.calcXLine(exList, exList.length - 1, 1, "stop", minStart);
                    })
                    .attr("x2", function () {
                        return that.calcXLine(exList, exList.length - 1, 1, "stop", minStart);
                    });
                that.svg.select("#l" + tmpD.getAttribute("ID") + "_x3")
                    .attr("x1", function () {
                        return that.calcXLine(exList, 0, -1, "start", minStart);
                    })
                    .attr("x2", function () {
                        return that.calcXLine(exList, exList.length - 1, 1, "stop", minStart);
                    });
                that.svg.select("#l" + tmpD.getAttribute("ID") + "_x4")
                    .attr("x1", function () {
                        return that.calcXLine(exList, 0, -1, "start", minStart);
                    })
                    .attr("x2", function () {
                        return that.calcXLine(exList, 0, 0, "start", minStart);
                    });
                that.svg.select("#l" + tmpD.getAttribute("ID") + "_x5")
                    .attr("x1", function () {
                        return that.calcXLine(exList, exList.length - 1, 0, "stop", minStart);
                    })
                    .attr("x2", function () {
                        return that.calcXLine(exList, exList.length - 1, 1, "stop", minStart);
                    });
                for (var m = 0; m < exList.length; m++) {
                    var id = that.idPrefix + "Ex" + exList[m].getAttribute("ID");
                    if (exList[m].getAttribute("ID") == null) {
                        id = that.idPrefix + "Ex" + tmpD.getAttribute("ID") + "_" + m;
                    }

                    //d3.select("#Level"+that.gsvg.levelNumber+that.trackClass+" g#"+that.idPrefix+"tx"+tmpD.getAttribute("ID")+" rect#"+id)
                    that.svg.select("g#" + that.idPrefix + "tx" + tmpD.getAttribute("ID") + " rect#" + id)
                        .attr("x", function (d) {
                            return that.xScale(exList[m].getAttribute("start")) - that.xScale(tmpD.getAttribute("start"));
                        })
                        .attr("width", function (d) {
                            return that.xScale(exList[m].getAttribute("stop")) - that.xScale(exList[m].getAttribute("start"));
                        });

                    if (m > 0) {
                        var strChar = ">";
                        if (d.getAttribute("strand") === "-") {
                            strChar = "<";
                        }
                        var fullChar = strChar;
                        var intStart = that.xScale(exList[m - 1].getAttribute("stop")) - that.xScale(tmpD.getAttribute("start"));
                        var intStop = that.xScale(exList[m].getAttribute("start")) - that.xScale(tmpD.getAttribute("start"));
                        var rectW = intStop - intStart;
                        var alt = 0;
                        var charW = 7.0;
                        if (rectW < charW) {
                            fullChar = "";
                        } else {
                            rectW = rectW - charW;
                            while (rectW > (charW + 1)) {
                                if (alt == 0) {
                                    fullChar = fullChar + " ";
                                    alt = 1;
                                } else {
                                    fullChar = fullChar + strChar;
                                    alt = 0;
                                }
                                rectW = rectW - charW;
                            }
                        }
                        var id = exList[m - 1].getAttribute("ID") + "_" + exList[m].getAttribute("ID");
                        if (exList[m].getAttribute("ID") == null) {
                            id = tmpD.getAttribute("ID") + "_" + (m - 1) + "_" + m;
                        }
                        that.svg.select("g#" + that.idPrefix + "tx" + tmpD.getAttribute("ID") + " line#" + that.idPrefix + "Int" + id)
                            .attr("x1", intStart)
                            .attr("x2", intStop);

                        that.svg.select("g#" + that.idPrefix + "tx" + tmpD.getAttribute("ID") + " #" + that.idPrefix + "IntTxt" + id)
                            .attr("dx", intStart + 1).text(fullChar);
                    }
                }
            });
            if (that.density == 1) {
                that.svg.attr("height", 40);
            } else if (that.density == 2) {
                that.svg.attr("height", (d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).selectAll("g." + that.idPrefix + "trx" + that.gsvg.levelNumber).size() + 1) * 25);
            } else if (that.density == 3) {
                that.svg.attr("height", (that.trackYMax + 1) * 25);
            }
            that.redrawSelectedArea();
        }
    };

    that.updateFullData = function (retry, force) {
        if (that.updateControl == retry) {
            that.updateControl = retry + 1;
            var tmpMin = that.xScale.domain()[0];
            var tmpMax = that.xScale.domain()[1];
            var file = dataPrefix + "tmpData/browserCache/" + genomeVer + "/regionData/" + that.gsvg.folderName + "/" + that.trackClass + ".xml";
            var http = "";

            d3.xml(file, function (error, d) {
                //console.log("Handling retry:"+retry+"  force:"+force);
                if (error) {
                    //console.log("ERROR******");
                    console.log(error);
                    if (retry == 0 || force == 1) {
                        var tmpContext = "/" + pathPrefix;
                        if (!pathPrefix) {
                            tmpContext = "";
                        }
                        $.ajax({
                            url: tmpContext + "generateTrackXML.jsp",
                            type: 'GET',
                            cache: false,
                            async: true,
                            data: {
                                chromosome: chr,
                                minCoord: tmpMin,
                                maxCoord: tmpMax,
                                folder: that.gsvg.folderName,
                                track: that.trackClass,
                                myOrganism: organism,
                                genomeVer: genomeVer,
                                dataVer: dataVer
                            },
                            //data: {chromosome: chr,minCoord:minCoord,maxCoord:maxCoord,panel:panel,rnaDatasetID:rnaDatasetID,arrayTypeID: arrayTypeID, myOrganism: organism, track: that.trackClass, folder: folderName,binSize:that.bin},
                            dataType: 'json',
                            success: function (data2) {
                                /*if(ga){
									ga('send','event','browser','generateTrackCustomTranscript');
								}*/
                                gtag('event', 'generateTrackCustomTranscript', {'event_category': 'browser'});
                            },
                            error: function (xhr, status, error) {
                                console.log(error);
                            }
                        });
                    }
                    if (retry < 3) {//wait before trying again
                        var time = 10000;
                        if (retry == 1) {
                            time = 15000;
                        }
                        setTimeout(function () {
                            that.updateFullData(retry + 1, 0);
                        }, time);
                    } else {
                        d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).select("#trkLbl").text("An errror occurred loading Track:" + that.trackClass);
                        d3.select("#Level" + that.gsvg.levelNumber + that.trackClass).attr("height", 15);
                        that.gsvg.addTrackErrorRemove(that.svg, "#Level" + that.gsvg.levelNumber + that.trackClass);
                        that.hideLoading();
                    }
                } else {
                    //console.log("SUCCESS******");
                    //console.log(d);
                    /*if(d==null){
                        console.log("D:NULL");
                        if(retry>=4){
                            data=new Array();
                            that.draw(data);
                            that.hideLoading();
                        }else{
                            setTimeout(function (){
                                that.updateFullData(retry+1,0);
                            },5000);
                        }
                    }else{*/
                    //console.log("SETUP TRACK");
                    var data = d.documentElement.getElementsByTagName(that.xmlTag);
                    that.draw(data);
                    that.hideLoading();
                    that.updateControl = 0;
                    //}
                }
            });
        }
    };

    that.updateSettingsFromUI = function () {
        if ($("#" + that.trackClass + "Dense" + that.level + "Select").length > 0) {
            that.density = $("#" + that.trackClass + "Dense" + that.level + "Select").val();
        }
        if ($("#" + that.trackClass + that.level + "colorSelect").length > 0) {
            that.colorBy = $("#" + that.trackClass + that.level + "colorSelect").val();
        }
        /*if(that.colorBy=="Score"){
			//console.log("colorby:Score");
			that.minValue=$("#"+that.trackClass+"minData"+that.level).val();
			that.maxValue=$("#"+that.trackClass+"maxData"+that.level).val();
			if(testIE||testSafari){
				that.minColor=$("#"+that.trackClass+"minColor"+that.level).spectrum("get").toHexString();
				that.maxColor=$("#"+that.trackClass+"maxColor"+that.level).spectrum("get").toHexString();
				//console.log(that.minColor+":::"+that.maxColor);
			}else{
				that.minColor=$("#"+that.trackClass+"minColor"+that.level).val();
				that.maxColor=$("#"+that.trackClass+"maxColor"+that.level).val();
			}
			that.createColorScale();
		}*/
    };

    that.generateSettingsDiv = function (topLevelSelector) {
        var d = trackInfo[that.trackClass];
        that.savePrevious();
        d3.select(topLevelSelector).select("table").select("tbody").html("");
        if (d.Controls.length > 0 && d.Controls != "null") {
            var controls = new String(d.Controls).split(",");
            var table = d3.select(topLevelSelector).select("table").select("tbody");
            table.append("tr").append("td").style("font-weight", "bold").html("Track Settings: " + d.Name);
            for (var c = 0; c < controls.length; c++) {
                if (typeof controls[c] !== 'undefined' && controls[c] != "") {
                    var params = controls[c].split(";");
                    var div = table.append("tr").append("td");
                    var lbl = params[0].substr(5);
                    var def = "";
                    if (params.length > 3 && params[3].indexOf("Default=") == 0) {
                        def = params[3].substr(8);
                    }
                    if (params[1].toLowerCase().indexOf("select") == 0) {
                        div.append("text").text(lbl + ": ");
                        var selClass = params[1].split(":");
                        var opts = params[2].split("}");
                        var id = that.trackClass + "Dense" + that.level + "Select";
                        if (selClass[1] == "colorSelect") {
                            id = that.trackClass + that.level + "colorSelect";
                        }
                        var sel = div.append("select").attr("id", id)
                            .attr("name", selClass[1]);
                        for (var o = 0; o < opts.length; o++) {
                            var option = opts[o].substr(1).split(":");
                            if (option.length == 2) {
                                var tmpOpt = sel.append("option").attr("value", option[1]).text(option[0]);
                                if ((id.indexOf("Dense") > -1 && option[1] == that.density) || (id.indexOf("colorSelect") > -1 && option[1] == that.colorBy)) {
                                    tmpOpt.attr("selected", "selected");
                                }
                            }
                        }
                        d3.select("select#" + id).on("change", function () {
                            if ($(this).val() == "Score") {
                                $("div." + that.trackClass + "Scale" + that.level).show();
                            } else if ($(this).val() == "Color") {
                                $("div." + that.trackClass + "Scale" + that.level).hide();
                            }
                            that.updateSettingsFromUI();
                            that.draw(that.data);
                        });
                    } else if (params[1].toLowerCase().indexOf("txt") == 0) {
                        if ($("#colorTrack" + that.level).size() == 0) {
                            div = div.append("div").attr("class", that.trackClass + "Scale" + that.level).style("display", "none");
                        } else {
                            div = d3.select("#" + that.trackClass + "Scale" + that.level);
                        }
                        div.append("text").text(lbl + ": ");
                        var selClass = params[1].split(":");
                        var opts = params[2].split("}");
                        var txtType = "Data";
                        var inputType = "text";
                        var inputMin = that.minValue;
                        var inputMax = that.maxValue;
                        if (selClass[1] == "color") {
                            txtType = "Color";
                            inputType = "Color";
                            inputMin = that.minColor;
                            inputMax = that.maxColor;
                        }

                        div.append("input").attr("type", inputType).attr("id", that.trackClass + "min" + txtType + that.level)
                            .attr("class", selClass[1])
                            .style("margin-left", "5px")
                            .attr("value", inputMin);
                        div.append("text").text(" - ");
                        div.append("input").attr("type", inputType).attr("id", that.trackClass + "max" + txtType + that.level)
                            .attr("class", selClass[1])
                            .style("margin-left", "5px")
                            .attr("value", inputMax);


                        if (txtType == "Color" && (testIE || testSafari)) {//Change for IE and Safari
                            $("#" + that.trackClass + "min" + txtType + that.level).spectrum({
                                change: function (color) {
                                    that.updateSettingsFromUI();
                                    //that.createColorScale();
                                    that.draw(that.data);
                                }
                            });
                            $("#" + that.trackClass + "max" + txtType + that.level).spectrum({
                                change: function (color) {
                                    //that.maxColor=color.toHexString();
                                    that.updateSettingsFromUI();
                                    //that.createColorScale();
                                    that.draw(that.data);
                                }
                            });
                        } else {
                            $("input#" + that.trackClass + "min" + txtType + that.level).on("change", function () {
                                that.updateSettingsFromUI();
                                that.draw(that.data);
                            });

                            $("input#" + that.trackClass + "max" + txtType + that.level).on("change", function () {
                                that.updateSettingsFromUI();
                                that.draw(that.data);
                            });
                        }
                    }
                }
            }
            if ($("#" + that.trackClass + that.level + "colorSelect").val() == "Score") {
                $("div." + that.trackClass + "Scale" + that.level).show();
            } else if ($("#" + that.trackClass + that.level + "colorSelect").val() == "Color") {
                $("div." + that.trackClass + "Scale" + that.level).hide();
            }
            var buttonDiv = table.append("tr").append("td");
            buttonDiv.append("input").attr("type", "button").attr("value", "Remove Track").style("float", "left").style("margin-left", "5px").on("click", function () {
                $('#trackSettingDialog').fadeOut("fast");
                that.gsvg.removeTrack(that.trackClass);
                var viewID = svgList[that.gsvg.levelNumber].currentView.ViewID;
                var track = viewMenu[that.gsvg.levelNumber].findTrackByClass(that.trackClass, viewID);
                var indx = viewMenu[that.gsvg.levelNumber].findTrackIndexWithViewID(track.TrackID, viewID);
                viewMenu[that.gsvg.levelNumber].removeTrackWithIDIdx(indx, viewID);
            });
            buttonDiv.append("input").attr("type", "button").attr("value", "Apply").style("float", "right").style("margin-left", "5px").on("click", function () {
                $('#trackSettingDialog').fadeOut("fast");
            });
            buttonDiv.append("input").attr("type", "button").attr("value", "Cancel").style("float", "right").style("margin-left", "5px").on("click", function () {
                that.revertPrevious();
                that.draw(that.data);
                $('#trackSettingDialog').fadeOut("fast");
            });
        } else {
            var table = d3.select(topLevelSelector).select("table").select("tbody");
            table.append("tr").append("td").style("font-weight", "bold").html("Track Settings: " + d.Name);
            table.append("tr").append("td").html("Sorry no settings for this track.");
            var buttonDiv = table.append("tr").append("td");
            buttonDiv.append("input").attr("type", "button").attr("value", "Remove Track").style("float", "left").style("margin-left", "5px").on("click", function () {
                $('#trackSettingDialog').fadeOut("fast");
            });
            buttonDiv.append("input").attr("type", "button").attr("value", "Cancel").style("float", "right").style("margin-left", "5px").on("click", function () {
                $('#trackSettingDialog').fadeOut("fast");
            });
        }
    };

    that.generateTrackSettingString = function () {
        return that.trackClass + "," + that.density + "," + that.colorBy + "," + that.minValue + "," + that.maxValue + "," + that.minColor + "," + that.maxColor + ";";
    };

    that.updateFullData(0, 0);

    that.redrawLegend = function () {
        var legend = [];
        var curPos = 0;
        legend = [{color: "#DD9C56", label: "All"},
            {color: "#0f4c75", label: "Predicted(Multi)"},
            {color: "#3282b8", label: "Predicted(Single)"},
            {color: "#5D576B", label: "Array"},
            {color: "#7A9D98", label: "Array/Predicted"}];
        that.drawLegend(legend);
    };

    return that;
}


window['GenomeSVG'] = GenomeSVG;
