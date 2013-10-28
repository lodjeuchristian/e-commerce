CREATE OR REPLACE PROCEDURE passercommande1
IS
	cookie_auth varchar2(30);
	ligne_utilisateur utilisateur%rowtype;
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
				<td><img src="/public/img/pictookgreen.png" style="margin-right:5px"/><font color="green"> Authentification</font></td>
				<td><img src="/public/img/pictocurrent.png" style="margin-right:5px"/><font color="red"> Adresse de livraison</font></td>
				<td><img src="/public/img/pictonotfilled.png" style="margin-right:5px"/><font color="#aaa"> Paiement</font></td> 
			</tr>
		</table>
		<hr/>
		<div class="row">
			<div class="span2"></div>
			<div class="span5" style="border:1px solid #ccc">
			
					<form method = "POST" action="/g07_epg_dad/passercommande2"  class="form-horizontal">
			<br/><br/>  
					  <div class="control-group">
						<label class="control-label" for="inputNumEtRue">Numéro et rue *</label>
						<div class="controls">
						  <input type="text" maxlength="20" name="inputNumEtRue" id="inputNumEtRue"  placeholder="Ex : 06 Boulevard Anatole" required>
						</div>
					  </div>
					  <div class="control-group">
						<label class="control-label" for="inputCodePostal">Code postal *</label>
						<div class="controls">
						  <input type="text"  maxlength="7"  name="inputCodePostal" id="inputCodePostal"  placeholder="Ex : 90000" required>
						</div>
					  </div>
					  <div class="control-group">
						<label class="control-label" for="inputVille">Ville *</label>
						<div class="controls">
						  <input type="text"  maxlength="20" name="inputVille" id="inputVillee"  placeholder="Ex : Belfort" required>
						</div>
					  </div> 
					  <div class="control-group">
						<label class="control-label" for="inputTelephone">Télephone </label>
						<div class="controls">
						  <input type="text"  maxlength="20"  name="inputTelephone" id="inputTelephone"  placeholder="Ex : 0657840214">
						</div>
					  </div>            
					  <br/>
					  <div class="control-group">
						<div class="controls"> 
						  <button type="submit" class="btn btn-info">Valider</button>
						</div>
					  </div>
					</form>
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
 END passercommande1;
 / 