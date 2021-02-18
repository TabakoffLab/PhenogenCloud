<%--
  User: Spencer Mahaffey
  Date: 10/21/20
  Time: 7:05 PM
--%>


<script>
    PhenoGenGeneList = function(thisDataTable,geneCol,processFunction,organism,downloadSelector){
        var that={};
        that.geneList=[];
        that.geneCol=geneCol;
        that.thisDataTable=thisDataTable;
        that.buttonSelector="createGeneListFromTable";
        that.buttonDiv=".downloadBtns";
        that.tmpContainer=thisDataTable.buttons().container();
        that.organism="Rn";
        if(organism){
            that.organism=organism;
        }
        if(downloadSelector){
            that.buttonDiv=downloadSelector;
        }

        that.processingFunction=function(data,col){
            console.log("processingFunction");
            var geneList = [];
            var geneHash={};
            console.log(data);
            for (var i = 0; i < data.length; i++) {
                console.log(data[i]);
                if (data[i][col].indexOf("<a href") > -1) {
                    var end = data[i][col].indexOf("</a>");
                    var tmp = data[i][col].substring(0, end);
                    var id = tmp.substring(tmp.lastIndexOf(">") + 1);
                    if(!geneHash[id]) {
                        geneList.push(id);
                        geneHash[id] = 1;
                    }
                } else {
                    var id = data[i][col];
                    if(id!=="") {
                        if(!geneHash[id]) {
                            geneList.push(id);
                            geneHash[id] = 1;
                        }
                    }else{
                        console.log("empty:"+data[i][col]);
                    }
                }
            }
            return geneList;
        };
        if(processFunction){
            that.processingFunction=processFunction;
        }
        //setup
        console.log("creating button");
        that.tmpContainer.prepend("<button class=\"dt-button ui-button ui-state-default ui-button-text-only buttons-html5\"  type=\"button\" id=\""+that.buttonSelector+"\"><span class=\"ui-button-text\">Create PhenoGen Gene List</span></button>");
        console.log("adding button:"+that.buttonDiv);
        $(that.buttonDiv).append(that.tmpContainer);
        console.log("done");
        $('#'+that.buttonSelector).on('click',function(){
            $('#glStatus').html("Preparing Gene List...");
            $('#dialogCreateGLBtn').prop("disabled",true);
            $('#dialogCreateGLBtn').button('option', 'label', 'Create Gene List');
            $('#dialogCancelBtn').button('option', 'label', 'Cancel');
            $( "div#createGLDialog" ).dialog( "open" );
            //$( "div#createGLDialog" )
            setTimeout(function (){
                PhenogenAnonSession = SetupAnonSession();
                PhenogenAnonSession.setupSession();
            },5);
            setTimeout(function(){
                var data = that.thisDataTable.rows({order: 'current', search: 'applied'}).data();
                that.geneList=that.processingFunction(data,that.geneCol);
                $("#glCount").html("Number of Genes: "+that.geneList.length);
                $('#glStatus').html("");
                $('#dialogCreateGLBtn').prop("disabled",false);
            },15);

        });

        $("div#createGLDialog").dialog({
            autoOpen: false,
            resizable:true,
            height: "auto",
            width: 500,
            position:{my: "center top",at: "center top", of: window},
            modal: true,
            buttons: [{
                text :"Create Gene List",
                id:"dialogCreateGLBtn",
                click : function() {
                    if( $('#dialogCreateGLBtn').button('option', 'label')=="View Gene List"){
                        window.location.href = "/web/geneLists/listGeneLists.jsp";
                    }else {
                        var params = new FormData();
                        params.append("gene_list_name", $("#glName").val());
                        params.append("description", $("#glDescription").val());
                        params.append("organism", that.organism);
                        params.append("inputGeneList", that.geneList);
                        /*{
                            gene_list_name:$("#glName").val(),
                            description:$("#glDescription").val(),
                            organism:spec,
                            inputGeneList:list
                        };*/
                        $.ajax({
                            url: "/web/geneLists/createGeneList2.jsp",
                            type: 'POST',
                            cache: false,
                            data: params,
                            contentType: false,
                            processData: false,
                            async: true,
                            beforeSend: function () {
                                $('#glStatus').html("Creating Gene List...");
                                $('#dialogCreateGLBtn').prop("disabled", true);
                            },
                            success: function (data2) {
                                $('#glStatus').html("Gene List Created");
                                $('#dialogCreateGLBtn').button('option', 'label', 'View Gene List');
                                $('#dialogCreateGLBtn').prop("disabled", false);
                                $('#dialogCancelBtn').button('option', 'label', 'Close');
                                //setTimeout(displayHelpFirstTime,200);
                            },
                            error: function (xhr, status, error) {
                                $('#glStatus').css("font", "#FF0000").html("Error:" + error);
                            }
                        });
                    }
                }},
                {
                    text: "Cancel",
                    id:"dialogCancelBtn",
                    click: function () {

                        $(this).dialog("close");
                    }
                }
            ]
        });

        return that;
    }
</script>

<div style="display: none;text-align: left;" id="createGLDialog">
    <H2>Create Gene List</H2>
    Gene List Name: <input type="text" id="glName" style="width:344px;"><BR><BR>
    Description: <textarea id="glDescription" cols="58"></textarea><BR>
    <BR><BR>
    <span style="float:left;" id="glCount"></span>
    <BR><BR>
    <span style="float:left;" id="glStatus"></span>
    <span style="display:none;"></span>
</div>
