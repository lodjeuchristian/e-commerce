--INTERFACE PACKAGE PA_auteur
create or replace package pa_commentaire is
type sqlcur is ref cursor;
	procedure put(pref_livre varchar2, pnum_utilisateur number, plib_commentaire varchar2, pdate_commentaire date);
	function getByNum(numcommentaire number) return commentaire%rowtype;  
	function getAll(theorder varchar2, thedirection varchar2) return sqlcur;
	function getByLivreRef(reflivre varchar2, theorder varchar2, thedirection varchar2) return sqlcur;
	function getUtilisateurByNumCmt(numcommentaire number) return utilisateur%rowtype; 
	
	
	
	
	
	
end pa_commentaire;
/

--CORPS PACKAGE PA_commentaire
Create or replace package body pa_commentaire is 
	
	--Procédure qui insère un nouveau commentaire
	procedure put(pref_livre varchar2, pnum_utilisateur number, plib_commentaire varchar2, pdate_commentaire date)
	is
	begin
		insert into commentaire(ref_livre, num_utilisateur, lib_commentaire, date_commentaire) values(pref_livre,pnum_utilisateur,plib_commentaire,pdate_commentaire);
		commit;
	end;


	--Fonction qui retourne tous les champs d'un commentaire donné en fonction de son id
	function getByNum(numcommentaire number) return commentaire%rowtype
	is  
	ligne_commentaire commentaire%rowtype;  
	begin   
		select * into ligne_commentaire from commentaire where num_commentaire = numcommentaire;
		return ligne_commentaire;
	end getByNum;
 
 
	--Fonction qui retourne la liste de tous les commentaires
	function getAll(theorder varchar2, thedirection varchar2) return sqlcur
	is  
		c1 sqlcur;
		req varchar2(200) := 'select * from commentaire c order by c.' || theorder || ' ' || thedirection || '';
	begin  
		open c1 for req;
		return c1;
	exception
	when no_data_found then   
		return null;
	end getAll; 
	
	
	--Fonction qui retourne la liste des commentaires d'un livre, dont la reférence est passée en paramètre
	function getByLivreRef(reflivre varchar2, theorder varchar2, thedirection varchar2) return sqlcur
	is   
		req varchar2(200);
		c1 sqlcur;
	begin  
		req := 'select * from commentaire c  where c.ref_livre like ''%' || reflivre || '%''  order by c.' || theorder || ' ' || thedirection || '';
		open c1 for req;
		return c1;
	exception
	when no_data_found then   
		return null;
	end getByLivreRef;  

	
	--Fonction qui retourne l'utilisateur qui a écrit le commentaire
	function getUtilisateurByNumCmt(numcommentaire number) return utilisateur%rowtype
	is  
	ligne_utilisateur utilisateur%rowtype;  
	begin   
		select distinct u.* into ligne_utilisateur from utilisateur u, commentaire c where u.num_utilisateur = c.num_utilisateur and c.num_commentaire = numcommentaire;
		return ligne_utilisateur;
	end getUtilisateurByNumCmt;
	
	
	
end pa_commentaire;
/
show error;
 