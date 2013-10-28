

$(".rowformation").click(function(event){ 	
		var id = event.target.id;  
		document.location.href="./inscription?num="+id;
});
 
$('#fadeOutIn').fadeOut(0);
$('#fadeOutIn').fadeIn(300);  
jQuery(function($){
	   $.datepicker.regional['fr'] = {
	      closeText: 'Fermer',
	      prevText: '<Préc',
	      nextText: 'Suiv>',
	      currentText: 'Courant',
	      monthNames: ['Janvier','Février','Mars','Avril','Mai','Juin',
	      'Juillet','Août','Septembre','Octobre','Novembre','Décembre'],
	      monthNamesShort: ['Jan','Fév','Mar','Avr','Mai','Jun',
	      'Jul','Aoû','Sep','Oct','Nov','Déc'],
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