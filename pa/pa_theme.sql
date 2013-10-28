--INTERFACE PACKAGE PA_theme
create or replace package pa_theme is
type sqlcur is ref cursor;
	function getByNum(num number) return theme%rowtype;   
	function getAll(theorder varchar2, thedirection varchar2) return sqlcur;
	function getByLivreRef(reflivre varchar2, theorder varchar2, thedirection varchar2) return sqlcur;
	
	
	
	
	
	
end pa_theme;
/

--CORPS PACKAGE PA_theme
Create or replace package body pa_theme is 

	--Fonction qui retourne tous les champs d'un theme donné en fonction de la reférence
	function getByNum(num number) return theme%rowtype
	is  
	ligne_theme theme%rowtype;  
	begin   
		select * into ligne_theme from theme where num_theme = num;
		return ligne_theme;
	end getByNum; 

 
 
	--Fonction qui retourne la liste de tous les thèmes
	function getAll(theorder varchar2, thedirection varchar2) return sqlcur
	is  
		c1 sqlcur;
		req varchar2(200) := 'select * from theme t order by t.' || theorder || ' ' || thedirection || '';
	begin  
		open c1 for req;
		return c1;
	exception
	when no_data_found then   
		return null;
	end getAll; 

	--Fonction qui retourne la liste des thèmes d'un livre, dont la reférence est passée en paramètre
	function getByLivreRef(reflivre varchar2, theorder varchar2, thedirection varchar2) return sqlcur
	is   
		req varchar2(200);
		c1 sqlcur;
	begin  
		req := 'select distinct t.* from theme t inner join porter_sur p on t.num_theme = p.num_theme inner join livre l on l.ref_livre = p.ref_livre where l.ref_livre like ''%' || reflivre || '%''  order by t.' || theorder || ' ' || thedirection || '';
		open c1 for req;
		return c1;
	exception
	when no_data_found then   
		return null;
	end getByLivreRef; 

	
end pa_theme;
/
show error;
 