--INTERFACE PACKAGE PA_auteur
create or replace package pa_auteur is
type sqlcur is ref cursor;
	function getByNum(numauteur number) return auteur%rowtype;  
	function getAll(theorder varchar2, thedirection varchar2) return sqlcur;
	function getByLivreRef(reflivre varchar2, theorder varchar2, thedirection varchar2) return sqlcur;
	
	
	
	
	
	
end pa_auteur;
/

--CORPS PACKAGE PA_auteur
Create or replace package body pa_auteur is 

	--Fonction qui retourne tous les champs d'un auteur donné en fonction de son id
	function getByNum(numauteur number) return auteur%rowtype
	is  
	ligne_auteur auteur%rowtype;  
	begin   
		select * into ligne_auteur from auteur where num_auteur = numauteur;
		return ligne_auteur;
	end getByNum;
 
 
	--Fonction qui retourne la liste de tous les auteurs
	function getAll(theorder varchar2, thedirection varchar2) return sqlcur
	is  
		c1 sqlcur;
		req varchar2(200) := 'select * from auteur a order by a.' || theorder || ' ' || thedirection || '';
	begin  
		open c1 for req;
		return c1;
	exception
	when no_data_found then   
		return null;
	end getAll; 
	
	
	--Fonction qui retourne la liste des auteurs d'un livre, dont la reférence est passée en paramètre
	function getByLivreRef(reflivre varchar2, theorder varchar2, thedirection varchar2) return sqlcur
	is   
		req varchar2(200);
		c1 sqlcur;
	begin  
		req := 'select distinct a.* from auteur a inner join ecrire e on a.num_auteur = e.num_auteur inner join livre l on l.ref_livre = e.ref_livre where l.ref_livre like ''%' || reflivre || '%''  order by a.' || theorder || ' ' || thedirection || '';
		open c1 for req;
		return c1;
	exception
	when no_data_found then   
		return null;
	end getByLivreRef;  

	
end pa_auteur;
/
show error;
 