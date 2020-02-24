<script>
    var GDBCustomView=function(params){
        var that={};
        that.curTimeout=-1;
        that.include={'cbxDatatotal':1,'cbxTrackReconstruction':1,'cbxEnsemblAnnotation':1,'cbxRefSeq':1,'cbxRepeat':1};
        that.viewID=-1;

        that.createView=function(){
            setTimeout(function(){
                var organism=$("#speciesCB").val();
                var curGV=$("#custGenomeVer").val();
                $.ajax({
                    url:  "/web/GeneCentric/createBrowserViews.jsp",
                    type: 'GET',
                    cache: false,
                    data: {UUID:PhenogenAnonSession.UUID,org:organism,genomeVer:curGV,type:"blank"},
                    dataType: 'json',
                    beforeSend: function(){
                        that.setStatus("Creating View");
                        that.toggleGO();
                    },
                    success: function(data2){
                        that.viewID=data2.viewID;
                        that.setStatus("");
                        that.toggleGO();
                        $("#defaultView").append('<option value="'+that.viewID+'" selected="selected">Custom View</option>');
                        //$('defaultView').
                    },
                    error: function(xhr, status, error) {
                        that.setError(error);
                        that.toggleGO();
                    }
                });
            },5);
        };

        /*that.addTracks=function(){

        };

        that.removeTracks=function(){

        };*/

        that.submitChanges=function(){
            if(that.curTimeout>0){
                clearTimeout(that.curTimeout);
            }
            that.curTimeout=setTimeout( function(){
                includeString="";
                includeKey=Object.keys(that.include);
                for( k in includeKey ){
                    includeString=includeString+","+includeKey[k];
                }
                includeString=includeString.substr(1);
                genomeVer=$("#custGenomeVer").val();
                name=$("#viewName").val();
                email=$("#assocEmail").val();
                dsVer=$("#selDataTotalVer").val();
                $.ajax({
                    url: "/web/GeneCentric/addRemoveViewTracks.jsp",
                    type: 'GET',
                    cache: false,
                    data: {tracks:includeString,viewID:that.viewID,genomeVer: genomeVer,name:name,email: email,version:dsVer},
                    dataType: 'json',
                    beforeSend: function () {
                        that.curTimeout = -1;
                        that.toggleGO();
                        that.setStatus("Updating Tracks...");
                    },
                    success: function(){
                        if(that.curTimeout==-1){
                            $(".goBTN").prop('disabled', false);
                        }
                        that.setStatus("Updating Tracks...Done");
                        setTimeout(function(){that.setStatus("")},5000);
                    },
                    error: function(xhr, status, error){
                        if(that.curTimeout==-1){
                            that.toggleGO();
                        }
                        that.setError(" You can try to proceed but some tracks may not be correct."+ error);
                    }
                });
            },1000);
        };
        //Utility Functions
        that.setup=function(){
            $(".custviewCbx").on("click", function(){
                if($(this).attr("id").indexOf("cbxData")==0){
                    divName=$(this).attr("id").substr(7);
                    console.log(divName);
                    if($(this).prop("checked")){
                        $("div#"+divName+"Opts").show();
                    }else{
                        $("div#"+divName+"Opts").hide();
                    }
                }else if($(this).attr("id").indexOf("cbxTrack")==0){
                    divName=$(this).attr("id").substr(8);
                    console.log(divName);
                    if($(this).prop("checked")){
                        $("div#"+divName+"Opts").show();
                    }else{
                        $("div#"+divName+"Opts").hide();
                    }
                }
                //add/delete tracks
                var id=$(this).attr("id");
                if($(this).prop("checked")){
                    that.include[id]=1;
                }else{
                    if(that.include[id]){
                        delete that.include[id];
                    }
                }
                that.submitChanges();
            });
        }
        that.selectAllStrains=function(){
            $(".strainCbx").prop('checked',true);
        };
        that.deselectAllStrains=function(){
            $(".strainCbx").prop('checked',false);
        };
        that.toggleGO=function(){
            if($(".goBTN").prop('disabled')){
                $(".goBTN").prop('disabled', false);

            }else{
                $(".goBTN").prop('disabled', true);
            }
        };
        that.setError=function(error){
            $('.custViewStatus').css("color","#FF0000").html(error);
        };
        that.setStatus=function(status){
            $('.custViewStatus').css("color","#000000").html(status);
        };
        that.displayCustom=function(){
            $("#createCustomView").show();
            $( "div#accordion" ).accordion();
            $("#custGenomeVer").val("<%=genomeVer%>");
            that.createView();
        };

        return that;
    };
</script>