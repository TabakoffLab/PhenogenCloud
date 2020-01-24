<script>
    var GDBCustomView=function(params){
        var that={};
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
                        that.setStatus("");
                        that.toggleGO();
                    },
                    error: function(xhr, status, error) {
                        that.setError(error);
                        that.toggleGO();
                    }
                });
            },5);
        };

        that.addTracks=function(){

        };

        that.removeTracks=function(){

        };

        that.submitChanges=function(){

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
                }else if($(this).attr("id")=="cbxTrackReadCnt"){
                    if($(this).prop("checked")){
                        $("div#strainList").show();
                    }else{
                        $("div#strainList").hide();
                    }
                }
                //add/delete tracks

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
            $("#defaultView").append('<option value="0" selected="selected">Custom View</option>');
            $( "div#accordion" ).accordion();
            $("#custGenomeVer").val("<%=genomeVer%>");
            that.createView();
        };

        return that;
    };
</script>