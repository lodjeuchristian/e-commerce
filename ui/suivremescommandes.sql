CREATE OR REPLACE PROCEDURE suivremescommandes
IS
	etat_css varchar2(30);
	cookie_auth varchar2(30);
	ttc number(5,2);
	ligne_theme theme%rowtype;
	ligne_livraison livraison%rowtype;
	ligne_utilisateur utilisateur%rowtype;
	ligne_commande commande%rowtype;
	type sqlcur is ref cursor;
	cthemes sqlcur;
	ccommandes  sqlcur;
 BEGIN
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
				<li class="dropdown">
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
							<li class="dropdown active">
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
		<h4><a href="/g07_epg_dad/consultercompte">Mon Compte</a> - Mes commandes</h4>
		<hr/>  
		<table class="table  table-hover">
			<tr>
				<th>Reférence</th>
				<th>Date</th> 
				<th>Date de livraison</th>
				<th>Statut</th> 
			</tr>
			');		
					--Affichage de la liste des commandes
					ccommandes:= pa_utilisateur.getAllCommandes;
					LOOP
					fetch ccommandes into ligne_commande;
					exit when ccommandes%NOTFOUND;
					if ( ligne_commande.etat_cmde = 'Refusé' ) then
						etat_css := 'error';
					else
						if ( ligne_commande.etat_cmde = 'En cours de livraison' ) then
							etat_css := 'warning';
						else
							if ( ligne_commande.etat_cmde = 'Livré' ) then
								etat_css := 'success';
							else
								etat_css := '';
							end if;
						end if;
					end if;
					ligne_livraison := pa_livraison.getByNumCommande(ligne_commande.num_cmde);
					HTP.print('
						<tr class="'|| etat_css ||'">
							<td>' || ligne_commande.num_cmde || '</td>
							<td>' || ligne_commande.date_cmde || '</td> ');
							if ligne_livraison.date_livraison is NULL then
								HTP.print('<td> -- </td>');
							else
								HTP.print('<td>' || ligne_livraison.date_livraison || '</td>');
							end if;
							HTP.print('
							<td>' || ligne_commande.etat_cmde || '</td> 
						</tr>	
					');   
					end loop;
					close ccommandes; 	   
 HTP.print('		
		</table>
		 
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
 owa_util.redirect_url('/g07_epg_dad/authentificationcompte' );
 end if;
 END suivremescommandes;
 / 
 show error;