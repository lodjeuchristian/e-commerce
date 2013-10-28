--INTERFACE PACKAGE PA_editeur
create or replace package pa_editeur is
type sqlcur is ref cursor;
	function getByNum(numediteur number) return editeur%rowtype;  
	function getAll(theorder varchar2, thedirection varchar2) return sqlcur; 
	function getByRefLivre(reflivre varchar2) return editeur%rowtype; 
	
	
	
end pa_editeur;
/

--CORPS PACKAGE PA_editeur
Create or replace package body pa_editeur is 

	--Fonction qui retourne tous les champs d'un editeur donné en fonction de son id
	function getByNum(numediteur number) return editeur%rowtype
	is  
	ligne_editeur editeur%rowtype;  
	begin   
		select * into ligne_editeur from editeur where num_editeur = numediteur;
		return ligne_editeur;
	end getByNum;
 
 
	--Fonction qui retourne la liste de tous les editeurs
	function getAll(theorder varchar2, thedirection varchar2) return sqlcur
	is  
		c1 sqlcur;
		req varchar2(200) := 'select * from editeur e order by e.' || theorder || ' ' || thedirection || '';
	begin  
		open c1 for req;
		return c1;
	exception
	when no_data_found then   
		return null;
	end getAll; 
	
	--Fonction qui retourne l'éditeur d'un livre
	function getByRefLivre(reflivre varchar2) return editeur%rowtype
	is  
	ligne_editeur editeur%rowtype;  
	reference varchar2(60);
	begin  
		reference := '%' || reflivre || '%'; 
		select e.* into ligne_editeur from editeur e inner join livre l on e.num_editeur = l.num_editeur where l.ref_livre like reference;
		return ligne_editeur;
	end getByRefLivre;  

	
end pa_editeur;
/
show error;
 