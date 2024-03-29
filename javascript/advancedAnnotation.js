/* --------------------------------------------------------------------------------
 *
 *  specific functions for advancedAnnotation.jsp
 *
 * -------------------------------------------------------------------------------- */
$(document).ready(function() {
    $("div#wait1").css("display", "none");


   var itemDetails = createDialog(".itemDetails" , {width: 900, height: 500, title: "Download"});
   $("#downloadBtn").click(function(){
     var iDecoderChoice        = new Array();
     var AffymetrixArrayChoice = new Array();
     var CodeLinkArrayChoice   = new Array();
			   
     if (IsAdvancedAnnotationComplete()){
        $.each($("input[name='iDecoderChoice']:checked"), function() {	
            iDecoderChoice.push($(this).val());
        });
					 
        $.each($("input[name='AffymetrixArrayChoice']:checked"), function() {	
            AffymetrixArrayChoice.push($(this).val());
        });
					 
        $.each($("input[name='CodeLinkArrayChoice']:checked"), function() {	
           CodeLinkArrayChoice.push($(this).val());
        });
					 
        $.get("/web/geneLists/downloadAnnotationPopup.jsp?callingForm=advancedAnnotation.jsp", {'iDecoderChoice[]':iDecoderChoice, 'AffymetrixArrayChoice[]':AffymetrixArrayChoice , 'CodeLinkArrayChoice[]':CodeLinkArrayChoice},
                		function(data){							   
                    			itemDetails.dialog("open").html(data);
					            closeDialog(itemDetails);					
                		});
     }  
   });	
});



function IsAdvancedAnnotationComplete(){
	var field = document.advancedAnnotation.iDecoderChoice;
	for (i=0; i<field.length; i++) {
		if (field[i].checked) {
			return true;
		}
	}
	alert('You must select one or more target databases before proceeding.')
	return false; 
}

// check the Affymetrix ID if any of the Affy-specific chips are requested 
function clickAffyID() {
	$("input[value='Affymetrix ID']").prop('checked', true);
}

// check the CodeLink ID if any of the CodeLink-specific chips are requested 
function clickCodeLinkID() {
	$("input[value='CodeLink ID']").prop('checked', true);
}

function checkUncheckCodeLinkID(id) {
   $("input[value='CodeLink ID']").prop('checked', $('#' + id).is(':checked'));
}
function checkUncheckAffyID(id) {
   $("input[value='Affymetrix ID']").prop('checked', $('#' + id).is(':checked'));
}

