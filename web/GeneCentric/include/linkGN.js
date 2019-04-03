function linkToGN2(){
    var baseLink="http://gn2.genenetwork.org/snp_browser?";
    var queryStr="";
    var skip={remove_strain:1,add_strain:1};
    var count=0;
    $('#snp_browser_form select').each(function(i){
        var curID=$(this)[0].name;
        var curVal="";
        if(curID!=="") {
            curVal = $(this).val();
        }else if($(this)[0].id==="chosen_strains_select"){
                curID="chosen_strains_rat";
                curVal="";
                var i=0;
                $('#'+$(this)[0].id+' option').each(function() {
                    if(i>0){
                        curVal=curVal+",";
                    }
                    curVal=curVal+$(this).val();
                    i++;
                });
        }
        if (count > 0) {
            queryStr = queryStr + "&";
        }
        queryStr = queryStr + curID + "=" + encodeURIComponent(curVal);
        count++;
    });
    $('#snp_browser_form input').each(function(i){
        var curID=$(this)[0].name;
        if(curID!=="" && typeof(skip[curID])!=="number" ) {
            var curVal = $(this).val();
            if($(this)[0].type=="checkbox"){
                if($(this)[0].checked){
                    curVal="on";
                }else{
                    curVal="off";
                }
            }
            if (count > 0) {
                queryStr = queryStr + "&";
            }
            if(curVal!=="off") {
                queryStr = queryStr + curID + "=" + encodeURIComponent(curVal);
                count++;
            }
        }
    });

    window.open(baseLink+queryStr, 'GN2 SNP Browser', '');
    console.log(baseLink+queryStr);
}

function addStrainToLimit(){

}

function removeStrainFromLimit(){

}

//Add/remove strains on changing from mouse/rat
$('#strain_select').on('change',function() {

});

$("input[name='add_strain']").on('click',function(){
    var toAdd=$('#strain_select').val();
    var toAddDisp=$( "#strain_select option:selected" ).text();
    var exists=false;
    //check if it exists
    $('#chosen_strains_select option').each(function() {
        if($(this).val()===toAdd){
            exists=true;
        }
    });
    if(! exists) {
        $('#chosen_strains_select').append('<option value="' + toAdd + '">' + toAddDisp + '</option>');
    }else{
        alert("Strain is already added.");
    }
});
$("input[name='remove_strain']").on('click',function(){
    $('#chosen_strains_select option:selected').each(function() {
        $(this).remove();
    });
});