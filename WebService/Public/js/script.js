function UpdateViz() {
	var data = $("#data").val() ; 
	console.log( data ); 

	var n = 5, m = 7; 

	for (var i = 0; i < n; ++i) {
		for (var j = 0; j < m; ++j) {
			var cid = (i+1)*10 + (j+1);
			//console.log(cid); 
			$("#g"+ cid).fadeTo("slow", 1 - parseInt(data.substr(i*m+j, 1)) );
		}
	}
}

function UpdateData() {
	$.ajax({url:"http://duruofei.com/ThermalGrid/?last=1", success:function(result){
    	$("#data").val(result);
  	}});
}

function UpdateThres() {
	$.ajax({url:("http://duruofei.com/ThermalGrid/?set=" + $( "#slider" ).slider( "value" )), success:function(result){
    	console.log(result);
  	}});
}

$(document).ready(function() {
	UpdateViz(); 

	setInterval(function() {
    	UpdateData();
    	UpdateViz(); 
	}, 500); 

	$( "#slider" ).slider({
      orientation: "horizontal",
      range: "min",
      max: 255,
      value: 127,
      slide: UpdateThres,
      change: UpdateThres
    });
    $( "#slider" ).slider( "value", 127 );
});



