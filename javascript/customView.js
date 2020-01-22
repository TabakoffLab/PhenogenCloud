<script>
    var GDBCustomView=function(params){
        var that={};
        that.createView=function(){
            setTimeout(function(){
                that.setStatus("Creating View");
                that.toggleGO();
                setTimeout(function(){
                    that.setStatus("");
                    that.toggleGO();
                },10000)
            },50);
        };

        that.addTracks=function(){

        };

        that.removeTracks=function(){

        };

        that.submitChanges=function(){

        };
        //Utility Functions
        that.toggleGO=function(){
            if($(".goBTN").prop('disabled')){
                $(".goBTN").prop('disabled', false);

            }else{
                $(".goBTN").prop('disabled', true);
            }
        };
        that.setStatus=function(status){
            $('.custViewStatus').html(status);
        };
        that.displayCustom=function(){
            $("#createCustomView").show();
            $("#defaultView").append('<option value="0" selected="selected">Custom View</option>');
            $( "div#accordion" ).accordion();
            that.createView();
        };
        return that;
    };
</script>