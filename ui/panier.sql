CREATE OR REPLACE PROCEDURE panier
IS
	cookie_auth varchar2(30);
	ligne_utilisateur utilisateur%rowtype;
	ligne_theme theme%rowtype; 
	ligne_theme2 theme%rowtype;
	ligne_livre livre%rowtype; 
	ligne_auteur auteur%rowtype; 
	ligne_editeur editeur%rowtype;
	ligne_promo promotion%rowtype;
	ligne_panier mon_panier%rowtype;
				
	reference_livre varchar2(60); 
	nb_ventes number(5);
	ttc number(5,2);
	prix_reel number(5,2);
	nouveau_prix number(8,2);
	cptr number(3):=0;
	cptrventes number(3):=0;
	cptrpromos number(3):=0; 
	referencelivre varchar2(60);
	type sqlcur is ref cursor;
	cthemes sqlcur;
	cthemes2 sqlcur;
	clivres sqlcur; 
	cauteurs sqlcur;
	cpanier sqlcur;
	
 BEGIN
 HTP.print('<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">');
 HTP.htmlopen;
 HTP.headopen;
 HTP.print('<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">');
 HTP.title('Accueil'); 
 HTP.print('<link href="/public/css/bootstrap.min.css" rel="stylesheet" type="text/css" />');
 HTP.print('<link href="/public/css/formationscss.css" rel="stylesheet" type="text/css" />');
 HTP.headclose;
 HTP.bodyopen;

 HTP.print('
 
	<!-- Entete --> 
	<div class="navbar navbar-fixed-top" >
	  <div class="navbar-inner">
		  <div class="container"> 
			<a class="brand" href="/g07_epg_dad/home" style="padding-top: 8px; padding-bottom: 0px;">
			  <b style="color:#0088cc;font-weight:bold;font-family:arial;font-size:25px;margin-right:-5px;">L</b>
			  <span style="color:#555;font-size:18px;">ibInfo</span>
			</a> 
			 
			<ul class="nav"> 
				
				<li class="divider-vertical"></li>   
				<li><a href="/g07_epg_dad/home"><i class="icon-home"></i>Accueil</a></li> 
				<li class="divider-vertical"></li>   
				<li class="dropdown">
					<a href="#" class="dropdown-toggle" data-toggle="dropdown"><i class="icon-th"></i>  Thèmes
					  <b class="caret"></b>
					</a>
					<ul class="dropdown-menu">
			');		
						--Affichage de la liste des thèmes dans le menu
						cthemes:= pa_theme.getAll('lib_theme', 'ASC');
						LOOP
						fetch cthemes into ligne_theme;
						exit when cthemes%NOTFOUND;
							HTP.print('<li><a href="/g07_epg_dad/livrespartheme' || '?' || 'numtheme=' || ligne_theme.num_theme || '&' || 'theorder=titre_livre' || '&' || 'thedirection=asc">' || ligne_theme.lib_theme || '</a></li>');   
						end loop;
						close cthemes; 
					   
 HTP.print('				   
					</ul>
				</li> 
				<li class="divider-vertical"></li>  
				<li class="dropdown active">
					<a href="#" class="dropdown-toggle" data-toggle="dropdown"><i class="icon-shopping-cart"></i>  Mon Panier
					  <b class="caret"></b>
					</a>
					<ul class="dropdown-menu">
					   <li><a href="/g07_epg_dad/panier"> Consulter </a></li>
		  ');
		  			
						ttc:=utils_global.getMontalTotal; 
						if ttc > 0 then
							htp.print('<li><a href="/g07_epg_dad/passercommande1">  Passer la commande </a></li>');
							HTP.print('<li><a href="/g07_epg_dad/viderPanier' || '?' || 'redirecturl=panier"><font color="red">Vider mon panier</font></a></li>'); 
						end if;
HTP.print('		
					</ul>
				</li> 
				<li class="divider-vertical"></li>   
				');
					--Affichage menu déroulant en fonction de l'authentification
					if pa_utilisateur.isAuthenticated then
						cookie_auth := pa_utilisateur.get_cookie('login');
						ligne_utilisateur:= pa_utilisateur.getByLogin(cookie_auth);
					HTP.print('
							<li class="dropdown">
								<a href="/g07_epg_dad/consultercompte" class="dropdown-toggle" data-toggle="dropdown"><i class="icon-user"></i> '||ligne_utilisateur.prenom_utilisateur ||'
									<b class="caret"></b>
								</a>
								<ul class="dropdown-menu">
								   <li><a href="/g07_epg_dad/consultercompte"> consulter compte </a></li>
								   <li><a href="/g07_epg_dad/deconnexion">  se déconnecter </a></li>
								</ul>
							</li> 
						');
					else
					HTP.print('<li class=""><a href="/g07_epg_dad/authentificationcompte"><i class="icon-user"></i>  Mon compte </a></li> ');
					end if;
		HTP.print(' 
				<li class="divider-vertical"></li>  
			
			<form  action="/g07_epg_dad/resultatsrecherche" method="GET" class="navbar-search pull-right">
				<input type="text" name="champ" class="search-query" style="width:100px" placeholder="Rechercher">
			</form>
			</ul>
		 </div>
	 </div>
	</div>

	
	<!-- Corps -->
	<div class="container conteneurwtborder" id="fadeOutIn"> 
		<br/>
		<h4>Mon Panier</h4>
		<hr/>
		
		
			');		
						 --utils_global.ajouterAuPanier('RESIS','papier',10.5,1);
						  
						ttc:=utils_global.getMontalTotal;
						
						if ttc = 0 then
							htp.print('<div align="center"><h5><font color="darkorange">Votre panier est vide</font></h5></div>');
						else
							--Affichage des meilleures ventes. On répupère d'abord la ref des livres les plus vendus
							cpanier:= utils_global.getMonPanier;
							LOOP
							fetch cpanier into ligne_panier;
							exit when cpanier%NOTFOUND;
								
							ligne_livre:= pa_livre.getByRef(ligne_panier.ref_livre);
							
							HTP.print('
								<div class="row">
									<div class="item active span3">  
										<img src="/public/img/livres/' || ligne_livre.couverture || '" alt="' || ligne_livre.titre_livre || '" />		 
									</div>
									<div align="left" class="span3" style="margin-left:-20px;">
										<font color="#0088cc"><h4>' || ligne_livre.titre_livre || '</font></h4><hr/>
										<font color="#0088cc">Nombre de pages :</font>' || ligne_livre.nb_pages || '<br/>
										<font color="#0088cc">Date de parution:</font>' || ligne_livre.date_parution || '<br/>
										<font color="#0088cc">Langue :</font> ' || ligne_livre.langue || '<br/><br/>
									 
										<font color="#0088cc">Thème (s) :</font> ');
											--On liste tous les thèmes du livre
											cthemes2:= pa_theme.getByLivreRef(ligne_livre.ref_livre, 'lib_theme', 'ASC');
											LOOP
											fetch cthemes2 into ligne_theme2;
											exit when cthemes2%NOTFOUND;
												HTP.print(ligne_theme2.lib_theme || ' ,');   
											end loop;
											close cthemes2; 
	 

							HTP.print('<br/>
										<font color="#0088cc">Auteur (s) :</font> ');
											--On liste tous auteurs du livre
											cauteurs:= pa_auteur.getByLivreRef(ligne_livre.ref_livre, 'nom_auteur', 'ASC');
											LOOP
											fetch cauteurs into ligne_auteur;
											exit when cauteurs%NOTFOUND;
												HTP.print(ligne_auteur.prenom_auteur || ' ' || ligne_auteur.nom_auteur || ' ,');   
											end loop;
											close cauteurs;  
											
							HTP.print('<br/>	 
										<font color="#0088cc">Editeur :</font>');

											--On récupère le nom et le prénom de l'éditeur
											ligne_editeur:= pa_editeur.getByRefLivre(ligne_livre.ref_livre); 
											HTP.print(ligne_editeur.nom_editeur || ' (' || ligne_editeur.pays_editeur || ')');    

							HTP.print('<br/><br/> 
										<i class="icon-chevron-right"></i> <a href="/g07_epg_dad/detailslivre?ref_livre=' || trim(ligne_livre.ref_livre) || '&' || 'lib_cmt=empty#myTab">Avis des utilisateurs</a>
										
									</div>
									<div class="alert alert-warning pull-right blocInfosPanier">
										Prix unitaire : 
										
	');
			prix_reel:= pa_livre.getSellingPriceByRef(ligne_livre.ref_livre);
			if prix_reel != ligne_livre.prix_livre then
				htp.print(' <b><s>' || ligne_livre.prix_livre || ' € </s></b>');
				htp.print('<h3><font color="darkorange">' || prix_reel || ' € </font></h3>');
			else
				htp.print('<h3>' || ligne_livre.prix_livre || ' €</h3>');
			end if;

htp.print('											
										
										<br/>
										');
										if ligne_panier.type_support = 'papier' then
											htp.print('									
											<label class="radio">
												 <input type="radio" name="naturelivre'||trim(ligne_panier.ref_livre)||'" id="'||trim(ligne_panier.ref_livre)||'" value="papier" class="radioTypeLivre" checked> Version papier
											</label>
											<label class="radio"> 
												 <input type="radio" name="naturelivre'||trim(ligne_panier.ref_livre)||'" id="'||trim(ligne_panier.ref_livre)||'"  value="numerique" class="radioTypeLivre"> Version numérique
											</label>');
										else
											htp.print('									
											<label class="radio">
												 <input type="radio" name="naturelivre'||trim(ligne_panier.ref_livre)||'" id="'||trim(ligne_panier.ref_livre)||'" value="papier" class="radioTypeLivre"> Version papier
											</label>
											<label class="radio"> 
												 <input type="radio" name="naturelivre'||trim(ligne_panier.ref_livre)||'" id="'||trim(ligne_panier.ref_livre)||'" value="numerique" class="radioTypeLivre" checked> Version numérique
											</label>'); 
										end if;

										htp.print('
										
										<br/>
										<label for="quantite'||ligne_panier.ref_livre||'">Quantité :  
											<input class="span1 inputQuantite" value="' || ligne_panier.quantite ||'" name="'||trim(ligne_panier.ref_livre)||'" id="'||ligne_panier.ref_livre||'" type="number" step="1" min="1" max="500" style="height:18px;"> 
										</label> 
										<br/>
										<button class="btn removeLivreFromCart" href="#myModal" role="button" data-toggle="modal" id="'||ligne_livre.ref_livre||'"><i class="icon-trash"></i> Supprimer</button>
										<br/> 
									</div>
								</div> 
								<hr/>
							');	  
							
							end loop;
							close cpanier; 
					   
 HTP.print('					
 
		
		<!--bouton validercommande-->
		<div class="pull-right" align="right"><font color="darkorange"><h3>Total : ' || ttc || ' €</h3></font><br/><button class="btn btn-warning btn-large" id="btnValiderCommande"><h5><i class="icon-ok icon-white"></i> Valider ma commande</h5></button></div>	 
		<br/><br/><br/><br/><br/><br/>
		');
						end if;
 HTP.print('
	 
	<!-- Pied de page -->  
	<hr/>
	<div class="footer">
		  <div class="container" id="footer">   
			  Copyright 2013 | BD50 - Lodjeu - Libam - Yarga - Ntieche
		  </div>
	</div> 
 
 
	<!-- Modal -->
<div id="myModal" class="modal hide fade" tabindex="-1" > 
    <div class="modal-header well">
      <button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
      <h3 id="myModalLabel">Confirmation de suppression</h3>
    </div>
    <div class="modal-body">
      <p>    
          <font color="red">Voulez-vous vraiment supprimer cet article du panier ?</font><hr/>  
      </p>
    </div>
    <div class="modal-footer">
      <button class="btn" data-dismiss="modal" aria-hidden="true"> Non </button> 
      <button type="submit" name="redirecturl" id="removeLivre" class="btn btn-danger"> <i class="icon-trash icon-white"></i> Oui  </button>
    </div> 
</div>
<!-- Fin modal --> 
 
 
 
 ');
 
 
 
 
 
 HTP.print('<script type="text/javascript" src="/public/js/jquery-1.9.1.min.js" ></script>');
 HTP.print('<script type="text/javascript" src="/public/js/bootstrap.min.js" ></script>'); 
 HTP.print('
 <script type="text/javascript">
	
	$(".inputQuantite").change(function(event){   
		 var redirectionvar = "/g07_epg_dad/update_quantite?ref_livre="+$(this).attr("id")+"' || '&' || 'quantite="+$(this).val()+"' || '&' || 'redirecturl=panier";
		 document.location.href = redirectionvar;
	});
	
	$(".radioTypeLivre").click(function(event){
		 var redirectionvar = "/g07_epg_dad/update_support?ref_livre="+$(this).attr("id")+"' || '&' || 'type_support="+$(this).val()+"' || '&' || 'redirecturl=panier";
		 document.location.href = redirectionvar;	
	});
	
	$(".removeLivreFromCart").click(function(event){
		ref_livre = $(this).attr("id");
	});
	
	$("#removeLivre").click(function(event){
		 var redirectionvar = "/g07_epg_dad/remove_livre?ref_livre="+ref_livre+"' || '&' || 'redirecturl=panier";
		 document.location.href = redirectionvar;		
	});
	
	$("#btnValiderCommande").click(function(){
		 var redirectionvar = "/g07_epg_dad/passercommande1";
		 document.location.href = redirectionvar;
	});
 
 
 </script>');
 HTP.bodyclose;
 HTP.htmlclose;
 END panier;
 / 