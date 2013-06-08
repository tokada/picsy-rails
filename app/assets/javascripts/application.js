// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.

$("table.selectable tr").each(function(r){
  var row = r;
  $("td", this).each(function(d){
    var cell = d;
    $(this)
      .data("rowIndex", row)
      .data("cellIndex", cell)
      .click(function(){
          $("#message").show().text("Row-Index is: " + $(this).data("rowIndex") +
																	  " and Cell-Index is: " + $(this).data("cellIndex") );
        })
      .hover(
				function(){
					if ($(this).data("cellIndex") > 0) {
						$(this).addClass("alert alert-info");
						$("#from-p"+$(this).data("rowIndex")).addClass("alert alert-success");
						$("#to-p"+$(this).data("cellIndex")).addClass("alert alert-success");
					}
        },function(){
					if ($(this).data("cellIndex") > 0) {
						$(this).removeClass("alert alert-info");
						$("#from-p"+$(this).data("rowIndex")).removeClass("alert alert-success");
						$("#to-p"+$(this).data("cellIndex")).removeClass("alert alert-success");
					}
      });
  });
});

$(document).ready(function(){

});
