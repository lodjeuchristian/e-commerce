CREATE OR REPLACE PROCEDURE passercommande3(inputNumEtRue varchar2, inputCodePostal varchar2, inputVille varchar2,
inputTelephone varchar2, inputNom varchar2, inputPrenom varchar2, selectTypeCarte varchar2, inputNumCarte varchar2,
selectMoisDateExpiration varchar2, selectAnneeDateExpiration varchar2, inputCodeVerif varchar2)
IS 
	ttc number(5,2);
	cptrnumerique number(5):=0;
	nbelpanier number(5);
	numDerniereCmde number(10);
	cookie_auth varchar2(30);
	dateExpiration varchar2(12);
	ligne_theme theme%rowtype;
	ligne_utilisateur utilisateur%rowtype;
	ligne_livre livre%rowtype;
	ligne_panier mon_panier%rowtype;
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
 
 
 --on fait les enregistrements en bdd
 dateExpiration:= '01/' || selectMoisDateExpiration || selectAnneeDateExpiration;
 pa_carte.put(inputNumCarte,ligne_utilisateur.num_utilisateur,inputNom, inputPrenom, selectTypeCarte, inputCodeVerif,dateExpiration);
 
 --ajout dans la commande
 pa_commande.put(inputNumCarte, to_number(ligne_utilisateur.num_utilisateur), sysdate, 'En cours de traitement', 0, 2, inputNumEtRue, inputCodePostal, inputVille);
 
 --ajout dans la table concerner
	numDerniereCmde:= pa_commande.getDerniereCommande;
	
	cpanier:= utils_global.getMonPanier;
	LOOP
	fetch cpanier into ligne_panier;
	exit when cpanier%NOTFOUND; 
		if ligne_panier.type_support = 'numerique' then 
			cptrnumerique:=cptrnumerique +1;
		end if;
	 	pa_concerner.put(numDerniereCmde, ligne_panier.ref_livre, ligne_panier.quantite, ligne_panier.prix_unitaire);  
	end loop;
	close cpanier;
	
	nbelpanier:= utils_global.getNbLivres;
	if nbelpanier = cptrnumerique then
		update commande set etat_cmde = 'Livré' where num_cmde = numDerniereCmde; 
		commit;
	end if;
				 
 -- fin des enregistrements
 
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
		<h4>Passer une commande</h4>
		<hr/>
		<table width="100%" style="margin-left:5%">
			<tr>
				<td><img src="/public/img/pictookgreen.png" /><font color="green"> Authentification</font></td>
				<td><img src="/public/img/pictookgreen.png" /><font color="green"> Adresse de livraison</font></td>
				<td><img src="/public/img/pictookgreen.png" /><font color="green"> Paiement</font></td> 
			</tr>
		</table>
		<hr/> 
		<div class="alert alert-success" align="center">
			<br/>
			<h4>Votre commande a bien été éffectuée. Référence : ' || numDerniereCmde || '</h5>
			<br/>
		</div>
		
	');
	if utils_global.getNbLivresNumeriques > 0 then 
	htp.print('	
		<div>
			<table class="table stable-striped table-bordered table-hover">
				<tr>
					<th>Titre</th>
					<th>Langue</th>
					<th>Nombre de pages</th>
					<th>Date de parution</th>
					<th>Opération</th>
				</tr>
		');
			
	--Affichage des meilleures ventes. On répupère d'abord la ref des livres les plus vendus
	cpanier:= utils_global.getMonPanierNumerique;
	LOOP
		fetch cpanier into ligne_panier;
		exit when cpanier%NOTFOUND; 
		ligne_livre:= pa_livre.getByRef(ligne_panier.ref_livre); 
		htp.print('
				
					<tr>
						<td>' || ligne_livre.titre_livre || '</td>
						<td>' || ligne_livre.langue || '</td>
						<td>' || ligne_livre.nb_pages || '</td>
						<td>' || ligne_livre.date_parution || '</td>
						<td><a href="../public/img/livres/pdf/' || ligne_livre.pdf || '" target=_blank>Télécharger</a></td>
					</tr>  
		');	
	end loop; 
	close cpanier;
	
	htp.print('				
		</table>
	</div>');


	end if; 	
	htp.print('
	
		<hr/>
		<div align="center">
			<a href="/g07_epg_dad/suivremescommandes">Suivre mes commandes</a> | <a href="/g07_epg_dad/home">Retour aux achats</a>
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
 --on vide le panier;
 utils_global.viderMonPanier;
 else
 owa_util.redirect_url('/g07_epg_dad/authentificationcommande' );
 end if;
 end if;
 END passercommande3;
 / 