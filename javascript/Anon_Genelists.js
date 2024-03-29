function GeneLists(){
    
    var that=this;
    that.retryCount=0;
    
    this.getListGeneLists=function (draw,selector,size){
        var params={};
        if(rgdUUID){
            params={rgd:rgdUUID};
        }
    	$.ajax({
            url: contextRoot+"web/geneLists/include/getGeneList.jsp",
            type: 'GET',
            cache: false,
            data: params,
            dataType: 'json',
            success: function(data2){
               	console.log(data2);
               	if(draw){
                    createTableGeneLists(data2,selector,size);
                }
                if(that.callBack){
                    that.callBack(data2);
                }
            },
            error: function(xhr, status, error) {
                console.log("ERROR:"+error);
                if(that.retryCount<10){
                	that.retryCount++;
                	setTimeout(that.getListGeneLists,2000*that.retryCount);
            	}
            }
        });
    };

    function createTableGeneLists(data,selector,size){
        if(data.length>0){
        d3.select(selector).select("tbody")
    		.selectAll('tr').remove();
    	var tracktbl=d3.select(selector).select("tbody")
    		.selectAll('tr')
    		.data(data)
			.enter().append("tr")
			.style("text-align","center")
			.attr("id",function(d){return "gl"+d.id;})
			.attr("class",function(d,i){var ret="odd";if(i%2===0){ret="even";} return ret;});

			tracktbl.each(function(d,i){
						var tmpI=i;
						var id=d3.select(this).data()[0].id;
						console.log(id);
						d3.select(this).append("td").html(d.name);
						d3.select(this).append("td").html(d.created);
						d3.select(this).append("td").html(d.geneCount);
						d3.select(this).append("td").html(d.organism);
						d3.select(this).append("td").html(d.source);
                                                if(size==="full"){
                                                    d3.select(this).append("td").attr("class","details").append("span").text("view");
                                                    d3.select(this).append("td").attr("class","actionIcons").append("img").attr("src",contextRoot+"web/images/icons/delete.png");
                                                    d3.select(this).append("td").attr("class","actionIcons").append("img").attr("src",contextRoot+"web/images/icons/download_g.png");
                                                }
		
						$("tr#gl"+id).find("td").slice(0,5).click( function() {
                                       var listItemId = $(this).parent("tr").attr("id").substr(2);
                                       $("input[name='geneListID']").val( listItemId );
                                       showLoadingBox();
                                       document.chooseGeneList.submit();
                               });

                        $("tr#gl"+id).find("td.details").click( function() {
                                       var geneListID = $(this).parent("tr").attr("id").substr(2);
                                       var parameterGroupID = $(this).parent("tr").attr("parameterGroupID");
                                       $.get("/web/geneLists/formatParametersGL.jsp",
                                               {geneListID: geneListID, 
                                               parameterGroupID: parameterGroupID,
                                               parameterType:"geneList"},
                                               function(data){
                                                       itemDetails.dialog("open").html(data);
                                                       closeDialog(itemDetails);
                                       });
                               });
            });
            var tableRows = getRows();
            hoverRows(tableRows);
        }else{
            colspanSize=5;
            if(size==="full"){
                colspanSize=8
            }
            d3.select(selector).select("tbody")
    		.selectAll('tr').remove();
            var tracktbl=d3.select(selector).select("tbody").append("tr").append("td").attr("colspan",colspanSize).html("No Results");
        }    
    };
    
    /* * *
     *  sets up the create new genelist modal
    /*/
    that.setupLinkEmail=function () {
           console.log("call setupLinkEmail");
           var linkEmailDialog;
           // setup create new gene list button
           $("#linkEmail").click(function(){
                console.log("clicked linkEmail");
                   if ( linkEmailDialog == undefined ) {
                           var dialogSettings = {width: 500, height: 365, title: "Link Email to This Anonymous Session"};
                           $("body").append("<div id=\"linkEmailDialog\"></div>");
                           linkEmailDialog = createDialog("div#linkEmailDialog", dialogSettings); 
                   }
                   
                   $.ajax({
                        url: "/web/access/linkEmail.jsp",
                        type: 'GET',
                        cache: false,
                        data: { uuid:PhenogenAnonSession.UUID },
                        dataType: 'html',
                        beforeSend: function(){
                            $('#linkEmailDialog').html("");
                        },
                        success: function(data2){
                             linkEmailDialog.dialog("open").html(data2);
                        },
                        error: function(xhr, status, error) {
                            console.log("ERROR:"+error);
                        }
                    });
           });
    }
    
    return that;
};

var geneListjs=GeneLists();

