CREATE OR REPLACE PROCEDURE passercommande2(inputNumEtRue varchar2, inputCodePostal varchar2, inputVille varchar2, inputTelephone varchar2)
IS
	cookie_auth varchar2(30);
	ligne_utilisateur utilisateur%rowtype;
	ligne_livre livre%rowtype;
	ligne_theme theme%rowtype;
	ligne_panier mon_panier%rowtype;
	ttc number(5,2);
	type sqlcur is ref cursor;
	cthemes sqlcur;
	cpanier sqlcur;
 BEGIN
 
 --Si le panier est vide, on le redirige vers le panier
if utils_global.getMontalTotal = 0 then
	owa_util.redirect_url('/g07_epg_dad/panier');
else
  if pa_utilisateur.isAuthenticated then
	--Récupération des infos dans la BD
		cookie_auth := pa_utilisateur.get_cookie('login');
		ligne_utilisateur:= pa_utilisateur.getByLogin(cookie_auth);

 --on enregistre les infos du client en BDD
 --pa_utilisateur.updateAdresseClient(to_number(ligne_utilisateur.num_utilisateur), inputNom, inputPrenom, inputNumEtRue, inputCodePostal, inputVille, inputTelephone)
 
 
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
		<h4><a href="/g07_epg_dad/panier">Mon Panier</a> - Passer une commande</h4>
		<hr/>
		<table width="100%" style="margin-left:5%">
			<tr>
				<td><img src="/public/img/pictookgreen.png" /><font color="green"> Authentification</font></td>
				<td><img src="/public/img/pictookgreen.png" /><font color="green"> Adresse de livraison</font></td>
				<td><img src="/public/img/pictocurrent.png" /><font color="red"> Paiement</font></td> 
			</tr>
		</table>
		<hr/>
		<!--Paiement-->
		<ul class="nav nav-tabs" id="myTab">
		  <li class="active"><a href="#cartebancaire" data-toggle="tab">Carte bancaire</a></li>
		  <li class=""><a href="#recapitulatif" data-toggle="tab">Récapitulatif</a></li> 
		</ul>
		
		<div id="myTab" class="tab-content">

		   <!-- onglet1 : carte bancaire -->
		   <div class="tab-pane fade active in" id="cartebancaire">
			<div class="row">
			<div class="span2"></div>
				<div class="span5" style="border:1px solid #ccc"> 
					<form  method="POST" action="/g07_epg_dad/passercommande3" class="form-horizontal">
						<input type="hidden" name="inputNumEtRue" value="'|| inputNumEtRue ||'" />
						<input type="hidden" name="inputCodePostal" value="'|| inputCodePostal ||'" />
						<input type="hidden" name="inputVille" value="'|| inputVille ||'" />
						<input type="hidden" name="inputTelephone" value="'|| inputTelephone ||'" />
					<br/><br/>
					  <div class="control-group">
						<label class="control-label" for="inputNom">Nom *</label>
						<div class="controls">
						  <input type="text"  maxlength="20" name="inputNom" id="inputNom" placeholder="Nom" required>
						</div>
					  </div>
					  <div class="control-group">
						<label class="control-label" for="inputPrenom">Prenom *</label>
						<div class="controls">
						  <input type="text"  maxlength="20" name="inputPrenom" id="inputPrenom" placeholder="Prenom" required>
						</div>
					  </div>   
					  <div class="control-group">
						<label class="control-label" for="selectTypeCarte">Type de carte *</label>
						<div class="controls">
							<select name="selectTypeCarte">
								<option value="visa">Visa</option>
								<option value="master card">Master card</option>
								<option value="bleue">Carte bleue</option>		
							</select>
						</div>
					  </div>  					  
					  <div class="control-group">
						<label class="control-label" for="inputNumCarte">Numéro de la carte *</label>
						<div class="controls">
						  <input type="text" maxlength="20" id="inputNumCarte" name="inputNumCarte" required>
						</div>
					  </div>
					  <div class="control-group">
						<label class="control-label" for="selectDateExpiration">Date d expiration *</label>
						<div class="controls">
						  <select class="span1" name="selectMoisDateExpiration">
							<option value="01">01</option>
							<option value="02">02</option>
							<option value="03">03</option>
							<option value="04">04</option>
							<option value="05">05</option>
							<option value="06">06</option>
							<option value="07">07</option>
							<option value="08">08</option>
							<option value="09">09</option>
							<option value="10">10</option>
							<option value="11">11</option>
							<option value="12">12</option>
						  </select> - 
						  <select class="span1" name="selectAnneeDateExpiration">
							<option value="2010">2010</option>
							<option value="2011">2011</option>
							<option value="2012">2012</option>
							<option value="2013">2013</option>
							<option value="2014">2014</option>
							<option value="2015">2015</option>
							<option value="2016">2016</option>
							<option value="2017">2017</option>
							<option value="2018">2018</option>
							<option value="2019">2019</option>
							<option value="2020">2020</option>
						  </select>						  
						</div>
					  </div>
					  <div class="control-group">
						<label class="control-label" for="inputCodeVerif">Code de vérification *</label>
						<div class="controls">
						  <input type="number" id="inputCodeVerif" name="inputCodeVerif" class="span1" max="999" required>
						</div>
					  </div>					  
					  <hr/>
					  <div class="control-group">
						<div class="controls"> 
						  <button type="submit" class="btn btn-success btn-large">Valider le paiement</button>
						</div>
					  </div>
					</form>
				</div> 
			</div>  				     
		   </div>

		   
		   <!-- onglet1 : recapitulatif -->
		   <div class="tab-pane fade" id="recapitulatif"> 
			 <div class="row">	
');			 
						ttc:=utils_global.getMontalTotal;
						
					 
							--Affichage des meilleures ventes. On répupère d'abord la ref des livres les plus vendus
							cpanier:= utils_global.getMonPanier;
							LOOP
							fetch cpanier into ligne_panier;
							exit when cpanier%NOTFOUND;
								
							ligne_livre:= pa_livre.getByRef(ligne_panier.ref_livre);
							
							HTP.print('
							
								<div class="span3">
									<font color="#0088cc">Titre : </font>' || ligne_livre.titre_livre || '<br/>
									<font color="#0088cc">Nombre de pages : </font>' || ligne_livre.nb_pages || '<br/>  
									<font color="#0088cc">Support : </font>' || ligne_panier.type_support || '<br/> 
									<font color="#0088cc">Prix unitaire : </font> ' || ligne_panier.prix_unitaire || ' €<br/> 
									<font color="#0088cc">Quantité : </font>' || ligne_panier.quantite || '<hr/>					
								</div> 	
							');
							end loop;
							close cpanier;
 	
	htp.print('			
				
			  </div> 	
			  
			  <div class="row alert alert-warning"> 
				 <div class="span4"> 
						<h4>Adresse de livraison</h4> 
						<hr/> 
						<h5>
							' || inputNumEtRue || '<br/>
							' || inputCodePostal || '
							' || inputVille || '<br/>
							Tél : ' || inputTelephone || '
							 
						</h5> 
				 </div>
				 <div class="span4"> 
					<h4>Somme à payer</h4> 
					<hr/> 
					<h3>' || ttc ||' €</h3>  
				 </div>	  
			 </div> 
		   </div>
		   
		   

		</div>

		
		
	 
	<!-- Pied de page -->  
	<hr/>
	<div class="footer">
		  <div class="container" id="footer">   
			  Copyright 2013 | BD50 - Lodjeu - Libam - Yarga - Ntieche
		  </div>
	</div> 
 
 ');
 
 
 
 
 
 HTP.print('<script type="text/javascript" src="/public/js/jquery-1.9.1.min.js" ></script>');
 HTP.print('<script type="text/javascript" src="/public/js/bootstrap.min.js" ></script>');
 HTP.bodyclose;
 HTP.htmlclose;
 
 else
 owa_util.redirect_url('/g07_epg_dad/authentificationcommande' );
 end if;
 end if;
 END passercommande2;
 / 