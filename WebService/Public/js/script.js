var lock = false; 
var localhost = true; 
var word = "11111111111111100001100000101100110";
var baseURL = "http://duruofei.com/Stamp/";
var localURL = "http://localhost:8888/Stamp/";

var lastURL = "?last="; 
var setURL = "?set="; 

function UpdateViz() {
	var data = $("#data").val() ; 
	console.log( data ); 

	if ($("#data").val() != word) {
		$("#data").val(word) ; 
		var n = 5, m = 7; 

		for (var i = 0; i < n; ++i) {
			for (var j = 0; j < m; ++j) {
				var cid = (i+1)*10 + (j+1);
				console.log(parseInt(data.substr(i*m+j, 1))); 
				$("#g"+ cid).fadeTo("slow", 1 - parseInt(data.substr(i*m+j, 1)) );
			}
		}
	}
}

function UpdateData() {
	if (!lock) {
		$.ajax({url:(baseURL + lastURL + (256-parseInt($( "#timestamp" ).slider( "value" ) ) ) ), success:function(result){
		    	word = result;
		    	lock = false; 
		  	}, error: function(XMLHttpRequest, textStatus, errorThrown) { 
	        	lock = false; 
	    	}   
    	});
  	}
}

function UpdateThres() {
	$.ajax({url:(baseURL + setURL + $( "#thres" ).slider( "value" )), success:function(result){
    	//console.log(result);
  	}});

  	$("#lblThres").html("<h3>Threshold: " + $( "#thres" ).slider( "value" )  + "</h3>"); 
}

function UpdateTimeStamp() {
	//console.log("<h3>Time stamp: " + (256-parseInt($( "#timestamp" ).slider( "value" ) )) + "</h3>"); 
	$("#lblTimeStamp").html("<h3>Time stamp: " + (256-parseInt($( "#timestamp" ).slider( "value" ) )) + "</h3>"); 
}

$(document).ready(function() {
	UpdateViz(); 
	if (localhost) {
		baseURL = localURL; 
	}

	setInterval(function() {
    	UpdateData();
    	UpdateViz(); 
    	console.log(256-parseInt($( "#timestamp" ).slider( "value" ))); 
	}, 500); 

	$( "#thres" ).slider({
      orientation: "horizontal",
      range: "min",
      max: 255,
      value: 127,
      slide: UpdateThres,
      change: UpdateThres
    });

	$( "#timestamp" ).slider({
      orientation: "horizontal",
      range: "min",
      max: 255,
      value: 255,
      slide: UpdateTimeStamp,
      change: UpdateTimeStamp
    });


    $( "#timestamp" ).slider( "value", 255 );


    $( "#thres" ).slider( "value", 127 );
});



