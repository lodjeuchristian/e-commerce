

$(".rowformation").click(function(event){ 	
		var id = event.target.id;  
		document.location.href="./inscription?num="+id;
});
 
$('#fadeOutIn').fadeOut(0);
$('#fadeOutIn').fadeIn(300);  
jQuery(function($){
	   $.datepicker.regional['fr'] = {
	      closeText: 'Fermer',
	      prevText: '<Pr�c',
	      nextText: 'Suiv>',
	      currentText: 'Courant',
	      monthNames: ['Janvier','F�vrier','Mars','Avril','Mai','Juin',
	      'Juillet','Ao�t','Septembre','Octobre','Novembre','D�cembre'],
	      monthNamesShort: ['Jan','F�v','Mar','Avr','Mai','Jun',
	      'Jul','Ao�','Sep','Oct','Nov','D�c'],
	      dayNames: ['Dimanche','Lundi','Mardi','Mercredi','Jeudi','Vendredi','Samedi'],
	      dayNamesShort: ['Dim','Lun','Mar','Mer','Jeu','Ven','Sam'],
	      dayNamesMin: ['Di','Lu','Ma','Me','Je','Ve','Sa'],
	      weekHeader: 'Sm', 
	      dateFormat: 'dd/mm/yy',
	      firstDay: 1,
	      isRTL: false,
	      showMonthAfterYear: false,
	      yearSuffix: ''};
	   $.datepicker.setDefaults($.datepicker.regional['fr']);
	});
$("#date").datepicker();

$("#reinitialiser").click(function(){
	$("#cours").val("");
	$("#lieu").val("");
	$("#date").val(""); 
	$("#date").val("");  
	$("#searchForm").submit();
});

$("#sortbycode").click(function(){   
	document.location.href="./formations?op=sort&sortby=code"; 
});

$("#sortbytitle").click(function(){ 
	document.location.href="./formations?op=sort&sortby=title";
});

$("#sortbystartdate").click(function(){ 
	document.location.href="./formations?op=sort&sortby=start";
});

$("#sortbyenddate").click(function(){ 
	document.location.href="./formations?op=sort&sortby=end";
});

$("#sortbylocation").click(function(){ 
	document.location.href="./formations?op=sort&sortby=city";
});