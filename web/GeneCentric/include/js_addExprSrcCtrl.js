PhenogenExpr = function (params) {
    var that = {};
    that.featureType = "Long";
    that.displayHerit = false;
    that.dataPrefix = "";
    that.displayCtrl = true;
    that.geneReport = false;

    that.parseParams = function (params) {
        if (params.div) {
            that.ctrlDiv = params.div;
        }
        if (params.genomeBrowser) {
            that.gb = params.genomeBrowser;
        }
        if (params.type) {
            that.type = params.type;
        }
        if (params.featureType) {
            that.featureType = params.featureType;
        }
        if (params.dataPrefix) {
            that.dataPrefix = params.dataPrefix;
        }
        if (typeof params.displayCtrl !== 'undefined') {
            that.displayCtrl = params.displayCtrl;
        }
        if (params.displayHerit) {
            that.displayHerit = params.displayHerit;
        }
        if (params.geneReport) {
            that.geneReport = params.geneReport;
        }
    };

    that.setup = function () {
        if (that.displayCtrl) {
            that.ctrl = d3.select("div#" + that.ctrlDiv + "srcCtrl");
            that.ctrl.append("text").text("Display Feature Type:");
            that.sel = that.ctrl.append("select").attr("id", "srcCtrl" + that.ctrlDiv)
                .attr("name", "srcCtrl" + that.ctrlDiv)
                .on("change", function () {
                    //change titles
                    val = that.sel.node().value;
                    that.featureType = val;
                    /*that.rbChart.setTitle(val + " RNA Gene/Transcript Expression");
                    that.rlChart.setTitle(val + " RNA Gene/Transcript Expression");
                    that.rkChart.setTitle(val + " RNA Gene/Transcript Expression");
                    that.rhChart.setTitle(val + " RNA Gene/Transcript Expression");
                    d3.select("span#" + that.ctrlDiv + "Titleb").html("Whole Brain " + val + " RNA-Seq Expression");
                    d3.select("span#" + that.ctrlDiv + "Titlel").html("Liver " + val + " RNA-Seq Expression");
                    d3.select("span#" + that.ctrlDiv + "Titlek").html("Kidney " + val + " RNA-Seq Expression");
                    d3.select("span#" + that.ctrlDiv + "Titleh").html("Heart " + val + " RNA-Seq Expression");*/

                    //change datasources
                    /*that.brainURL = "/tmpData/browserCache/" + genomeVer + "/regionData/" + that.gb.folderName + "/Brainexpr.json";
                    that.liverURL = "/tmpData/browserCache/" + genomeVer + "/regionData/" + that.gb.folderName + "/Liverexpr.json";
                    that.kidneyURL = "/tmpData/browserCache/" + genomeVer + "/regionData/" + that.gb.folderName + "/Kidneyexpr.json";
                    that.heartURL = "/tmpData/browserCache/" + genomeVer + "/regionData/" + that.gb.folderName + "/Heartexpr.json";
                    if (val === "Small") {
                        that.brainURL = "tmpData/browserCache/" + genomeVer + "/regionData/" + that.gb.folderName + "/Brain_sm_expr.json";
                        that.liverURL = "tmpData/browserCache/" + genomeVer + "/regionData/" + that.gb.folderName + "/Liver_sm_expr.json";
                        that.rbChart.setDisplayHerit(false);
                        that.rlChart.setDisplayHerit(false);
                    } else {
                        that.rbChart.setDisplayHerit(true);
                        that.rlChart.setDisplayHerit(true);
                        that.rkChart.setDisplayHerit(true);
                        that.rhChart.setDisplayHerit(true);
                    }
                    that.rbChart.setDataURL(that.brainURL);
                    that.rlChart.setDataURL(that.liverURL);
                    that.rkChart.setDataURL(that.kidneyURL);
                    that.rhChart.setDataURL(that.heartURL);*/
                });
            that.sel.append("option").attr("value", "Long").text("long RNAs (>200bp)");
            that.sel.append("option").attr("value", "Small").text("small RNAs (<=200bp)");
            that.ctrl.append("br");
            that.ctrl.append("text").text("Tissue for left/top chart:");
            that.selLeft = that.ctrl.append("select").attr("id", "dataSrcLeft" + that.ctrlDiv)
                .attr("name", "dataSrcLeft" + that.ctrlDiv)
                .on("change", function () {
                    val = that.selLeft.node().value;
                    //$("#expRegionRight").css("display", "inline-block");
                    w = 45;
                    url = that.liverURL;
                    titlePref = "";
                    if (val === "brain") {
                        url = that.brainURL;
                        titlePref = "Whole Brain";
                    } else if (val === "liver") {
                        url = that.liverURL;
                        titlePref = "Liver";
                    } else if (val === "kidney") {
                        url = that.kidneyURL;
                        titlePref = "Kidney";
                    } else if (val === "heart") {
                        url = that.heartURL;
                        titlePref = "Heart";
                    }
                    $("div#chartLeft" + that.ctrlDiv + " div.controls").remove();
                    $("div#chartLeft" + that.ctrlDiv + " div#imgDiv").remove();
                    that.rrChart.setWidth(w + "%");

                    that.rlChart = chart({
                        "data": url, "selector": "#chartLeft" + that.ctrlDiv, "allowResize": true,
                        "type": that.type, "width": w + "%", "height": "70%", "displayHerit": that.displayHerit,
                        "title": that.featureType + " RNA Gene/Transcript Expression", "titlePrefix": titlePref
                    });
                    d3.select("span#" + that.ctrlDiv + "Titlel").html(titlePref + " Long RNA-Seq Expression");
                });
            that.ctrl.append("text").text("Tissue for right/bottom chart :");
            that.selRight = that.ctrl.append("select").attr("id", "dataSrcRight" + that.ctrlDiv)
                .attr("name", "dataSrcRight" + that.ctrlDiv)
                .on("change", function () {
                    val = that.selRight.node().value;
                    $("#expRegionRight").css("display", "inline-block");
                    w = 45;
                    url = that.liverURL;
                    titlePref = "";
                    if (val === "brain") {
                        url = that.brainURL;
                        titlePref = "Whole Brain";
                    } else if (val === "liver") {
                        url = that.liverURL;
                        titlePref = "Liver";
                    } else if (val === "kidney") {
                        url = that.kidneyURL;
                        titlePref = "Kidney";
                    } else if (val === "heart") {
                        url = that.heartURL;
                        titlePref = "Heart";
                    }
                    $("div#chartRight" + that.ctrlDiv + " div.controls").remove();
                    $("div#chartRight" + that.ctrlDiv + " div#imgDiv").remove();
                    if (val !== "none") {
                        that.rlChart.setWidth(w + "%");
                        that.rrChart = chart({
                            "data": url, "selector": "#chartRight" + that.ctrlDiv, "allowResize": true,
                            "type": that.type, "width": w + "%", "height": "70%", "displayHerit": that.displayHerit,
                            "title": that.featureType + " RNA Gene/Transcript Expression", "titlePrefix": titlePref
                        });
                        d3.select("span#" + that.ctrlDiv + "Titler").html(titlePref + " Long RNA-Seq Expression");
                    } else {
                        $("#expRegionRight").css("display", "none");
                        that.rlChart.setWidth("98%");
                    }
                });

            that.selLeft.append("option").attr("value", "brain").attr("selected", "selected").text("Whole Brain");
            that.selLeft.append("option").attr("value", "liver").text("Liver");
            that.selLeft.append("option").attr("value", "heart").text("Heart");
            that.selLeft.append("option").attr("value", "kidney").text("Kidney");
            that.selRight.append("option").attr("value", "none").attr("selected", "selected").text("None");
            that.selRight.append("option").attr("value", "brain").text("Whole Brain");
            that.selRight.append("option").attr("value", "liver").text("Liver");
            that.selRight.append("option").attr("value", "heart").text("Heart");
            that.selRight.append("option").attr("value", "kidney").text("Kidney");

        }
        d3.select("span#" + that.ctrlDiv + "Titlel").html("Whole Brain Long RNA-Seq Expression");

        /*d3.select("span#" + that.ctrlDiv + "Titleb").html("Whole Brain Long RNA-Seq Expression");
        d3.select("span#" + that.ctrlDiv + "Titlel").html("Liver Long RNA-Seq Expression");
        d3.select("span#" + that.ctrlDiv + "Titlek").html("Kidney Long RNA-Seq Expression");
        d3.select("span#" + that.ctrlDiv + "Titleh").html("Heart Long RNA-Seq Expression");*/
        that.setupCharts();
    };

    that.setupCharts = function () {
        //setup charts

        if (that.geneReport && reportMinCoord && reportMaxCoord) {
            that.curPrefix = "/tmpData/browserCache/" + genomeVer + "/regionData/" + chr + "/" + reportMinCoord + "_" + reportMaxCoord;
        } else {
            that.curPrefix = "/tmpData/browserCache/" + genomeVer + "/regionData/" + that.gb.folderName;
        }

        if (that.dataPrefix !== "") {
            that.curPrefix = that.dataPrefix;
            if (location.protocol == 'https:') {
                that.curPrefix = that.curPrefix.replace("http://", "https://");
            } else {
                that.curPrefix = that.curPrefix.replace("https://", "http://");
            }
        }
        that.brainURL = that.curPrefix + "/" + dataVer + "_Brainexpr.json";
        that.liverURL = that.curPrefix + "/" + dataVer + "_Liverexpr.json";
        that.kidneyURL = that.curPrefix + "/" + dataVer + "_Kidneyexpr.json";
        that.heartURL = that.curPrefix + "/" + dataVer + "_Heartexpr.json";
        if (that.featureType === "Small") {
            that.brainURL = that.curPrefix + "/Brain_sm_expr.json";
            that.liverURL = that.curPrefix + "/Liver_sm_expr.json";
            that.displayHerit = false;
        }
        //console.log("ctrlDiv:" + that.ctrlDiv);
        that.rlChart = chart({
            "data": that.brainURL, "selector": "#chartLeft" + that.ctrlDiv, "allowResize": true,
            "type": that.type, "width": "98%", "height": "70%", "displayHerit": that.displayHerit,
            "title": that.featureType + " RNA Gene/Transcript Expression", "titlePrefix": "Whole Brain"
        });
        /*that.rrChart = chart({
            "data": that.liverURL, "selector": "#chartRight" + that.ctrlDiv, "allowResize": true,
            "type": that.type, "width": "45%", "height": "70%", "displayHerit": that.displayHerit,
            "title": that.featureType + " RNA Gene/Transcript Expression", "titlePrefix": "Liver"
        });*/
        //if ($(window).width() < 1500) {
        that.rlChart.setWidth("98%");
        //that.rrChart.setWidth("98%");
        //}
        /*that.brainURL = that.curPrefix + "/Brainexpr.json";
        that.liverURL = that.curPrefix + "/Liverexpr.json";
        that.kidneyURL = that.curPrefix + "/Kidneyexpr.json";
        that.heartURL = that.curPrefix + "/Heartexpr.json";

        if (that.featureType === "Small") {
            that.brainURL = curPrefix + "/Brain_sm_expr.json";
            that.liverURL = curPrefix + "/Liver_sm_expr.json";
            that.displayHerit = false;
        }
        that.rbChart = chart({
            "data": that.brainURL, "selector": "#chartBrain" + that.ctrlDiv, "allowResize": true,
            "type": that.type, "width": "45%", "height": "70%", "displayHerit": that.displayHerit,
            "title": that.featureType + " RNA Gene/Transcript Expression", "titlePrefix": "Whole Brain"
        });
        that.rlChart = chart({
            "data": that.liverURL, "selector": "#chartLiver" + that.ctrlDiv, "allowResize": true,
            "type": that.type, "width": "45%", "height": "70%", "displayHerit": that.displayHerit,
            "title": that.featureType + " RNA Gene/Transcript Expression", "titlePrefix": "Liver"
        });
        that.rkChart = chart({
            "data": that.kidneyURL, "selector": "#chartKidney" + that.ctrlDiv, "allowResize": true,
            "type": that.type, "width": "45%", "height": "70%", "displayHerit": that.displayHerit,
            "title": that.featureType + " RNA Gene/Transcript Expression", "titlePrefix": "Kidney"
        });
        that.rhChart = chart({
            "data": that.heartURL, "selector": "#chartHeart" + that.ctrlDiv, "allowResize": true,
            "type": that.type, "width": "45%", "height": "70%", "displayHerit": that.displayHerit,
            "title": that.featureType + " RNA Gene/Transcript Expression", "titlePrefix": "Heart"
        });
        if ($(window).width() < 1500) {
            that.rbChart.setWidth("98%");
            that.rlChart.setWidth("98%");
            that.rkChart.setWidth("98%");
            that.rhChart.setWidth("98%");
        }*/
    };

    that.parseParams(params);
    that.setup();
    return that;
};
            






