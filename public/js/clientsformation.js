(function($) {
$(document).ready(function() 
{ 
    $("#sorter").tablesorter(); 
} 
); 

$(document).ready(function() 
    { 
        $("#myTable").tablesorter( {sortList: [[0,0], [1,0]]} ); 
    } 
); 
})(jQuery);	