--INTERFACE PACKAGE PA_LIVRE
create or replace package pa_livre is
type sqlcur is ref cursor; 
	function getAll(theorder varchar2, thedirection varchar2) return sqlcur; 
	function getAllByLimit(theorder varchar2, thedirection varchar2, thelimit number) return sqlcur; 
	function getRefBestSellers return sqlcur;
	function getByBestSoldes return sqlcur;
	function getNbVentes(reference varchar2) return number;
	function getSellingPriceByRef(reference varchar2) return number;
	function getByRef(reference varchar2) return livre%rowtype; 
	function getByTitre(titre varchar2) return livre%rowtype; 
	function getByEditeurNumber(numediteur number, theorder varchar2, thedirection varchar2) return sqlcur;
	function getByThemeNumber(numtheme number, theorder varchar2, thedirection varchar2) return sqlcur;
	function isValidBook(title varchar2) return boolean;
	function getByChampRecherche(champ varchar2) return sqlcur;
	
	
	
	
	
	
	
end pa_livre;
/

--CORPS PACKAGE PA_LIVRE
Create or replace package body pa_livre is 


	--Fonction qui retourne la liste de tous les livres
	function getAll(theorder varchar2, thedirection varchar2) return sqlcur
	is  
		c1 sqlcur;
		req varchar2(200) := 'select * from livre l order by l.' || theorder || ' ' || thedirection || '';
	begin  
		open c1 for req;
		return c1;
	exception
	when no_data_found then   
		return null;
	end getAll; 
	
	
	--Fonction qui retourne la liste des 'thelimit' premiers livres
	function getAllByLimit(theorder varchar2, thedirection varchar2, thelimit number) return sqlcur
	is  
		c1 sqlcur;
		req varchar2(200) := 'select * from livre l where rownum <= ' || thelimit || ' order by l.' || theorder || ' ' || thedirection || '';
	begin  
		open c1 for req;
		return c1;
	exception
	when no_data_found then   
		return null;
	end getAllByLimit; 
	

	
	--Fonction qui retourne la liste des livres les plus vendus (apparait + dans la table concerner)
	function getRefBestSellers return sqlcur
	is  
		c1 sqlcur;
		req varchar2(200) := 'select ref_livre from(SELECT ref_livre, count(*) as qte from concerner group by ref_livre) order by qte desc';
	begin  
		open c1 for req;
		return c1;
	exception
	when no_data_found then   
		return null;
	end getRefBestSellers; 
	
	
	--Fonction qui retourne la liste des livres les plus soldés
	function getByBestSoldes return sqlcur
	is  
		c1 sqlcur;
		req varchar2(200) := 'SELECT l.* from livre l, promotion p where l.num_promo = p.num_promo order by p.pourcentage DESC';
	begin  
		open c1 for req;
		return c1;
	exception
	when no_data_found then   
		return null;
	end getByBestSoldes; 
	

	--Fonction qui retourne nombre de ventes d'un livre
	function getNbVentes(reference varchar2) return number
	is   
		reflivre varchar2(60);
		nombre number; 
	begin  
		reflivre:= '%' || reference || '%';
		select count(ref_livre) into nombre from concerner where ref_livre like reflivre;
		return nombre;
	exception
	when no_data_found then   
		return null;
	end getNbVentes; 
	
	
	--Fonction qui retourne le prix de vente réel du livre
	function getSellingPriceByRef(reference varchar2) return number
	is
		reflivre varchar2(60);
		numpromo number(5);
		total number(5,2);
	begin
		reflivre:= '%' || reference || '%';
		select l.num_promo into numpromo from livre l where l.ref_livre like reflivre;
		if numpromo is NULL then
			select l.prix_livre into total from livre l where l.ref_livre like reflivre;
			dbms_output.put_line('c null donc je retourne le prix = ' || total);
			return total;
		else
			select (l.prix_livre * (1 - p.pourcentage/100)) into total from livre l, promotion p where l.num_promo = p.num_promo and l.ref_livre like reflivre;
			dbms_output.put_line('PROMO DC JAPPLIQUE PROMO prix = ' || total);
			return total;
		end if;
		 
 	end getSellingPriceByRef;
	
	
	--Fonction qui retourne tous les champs d'un livre donné en fonction de la reférence
	function getByRef(reference varchar2) return livre%rowtype
	is 
	reflivre varchar2(60);
	ligne_livre livre%rowtype;  
	begin 
		reflivre := '%' || reference || '%'; 
		select * into ligne_livre from livre where ref_livre like reflivre;
		return ligne_livre;
	end getByRef; 

	
	--Fonction qui retourne tous les champs d'un livre donné en fonction du titre
	function getByTitre(titre varchar2) return livre%rowtype
	is 
	titrelivre varchar2(60);
	ligne_livre livre%rowtype;  
	begin 
		titrelivre := '%' || titre || '%'; 
		select * into ligne_livre from livre where titre_livre like titrelivre;
		return ligne_livre;
	exception
	when no_data_found then 
		--si on ne trouve pas de livre, on retourne quand même un livre avec comme titre 'no_data_found'
		--NB : si la table n'a pas de string, retourner 0 dans la premiere colonne numérique
		ligne_livre.titre_livre := 'no_data_found';
		return ligne_livre;
	end getByTitre; 
 
 
	--Fonction qui retourne la liste des livres d'un éditeur dont l'id est passé en paramètre
	function getByEditeurNumber(numediteur number, theorder varchar2, thedirection varchar2) return sqlcur
	is  
		c1 sqlcur;
		req varchar2(200) := 'select * from livre l where l.num_editeur = ' || numediteur || 'order by l.' || theorder || ' ' || thedirection || '';
	begin  
		open c1 for req;
		return c1;
	exception
	when no_data_found then   
		return null;
	end getByEditeurNumber; 
	
	
	--Fonction qui retourne la liste des livres(livre+theme+editeur) d'un thème dont l'id est passé en paramètre
	function getByThemeNumber(numtheme number, theorder varchar2, thedirection varchar2) return sqlcur
	is  
		c1 sqlcur;
		
		--NB : la jointure ANSI ne marche pas lorsqu'on inclu le order by dans ce cas.  (5 h de recherche)
		req varchar2(200) := 'select distinct l.* 
							 from livre l, porter_sur p, theme t where l.ref_livre = p.ref_livre and t.num_theme = p.num_theme and   t.num_theme = ' || numtheme || '
							 order by ' || theorder || '  ' || thedirection || '';  
	begin  
		open c1 for req;
		return c1;
	exception
	when no_data_found then   
		return null;
	end getByThemeNumber; 
	
	
		--Fonction qui verifie si le titre du livre existe en base
	function isValidBook(title varchar2) return boolean
	is
		res char(12);	
	begin
		select 1 into res from livre where titre_livre = title;
		return SQL%FOUND;
	Exception
		when no_data_found then 
			return false;
	end isValidBook;
	
	
		--Fonction qui retourne le résultat de la recherche
	function getByChampRecherche(champ varchar2) return sqlcur
	is    
		champ_recherche varchar2(100);
		nombre number; 
		c1 sqlcur;
	begin  
		champ_recherche:= '%' || lower(champ) || '%';
		open c1 for select distinct * from livre where 
			lower(langue) like champ_recherche 
			or lower(titre_livre) like champ_recherche or ref_livre in (select p.ref_livre from porter_sur p inner join  theme t on t.num_theme = p.num_theme where lower(t.lib_theme) like champ_recherche)
			or ref_livre in (select e.ref_livre from ecrire e inner join  auteur a on a.num_auteur = e.num_auteur where lower(a.nom_auteur) like champ_recherche or lower(a.prenom_auteur) like champ_recherche)
			or num_editeur in (select num_editeur from editeur where lower(nom_editeur) like champ_recherche or lower(pays_editeur) like champ_recherche);
			return c1;
	exception
	when no_data_found then   
		return null;
	end getByChampRecherche;

	
end pa_livre;
/
show error;
 