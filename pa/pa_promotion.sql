--INTERFACE PACKAGE PA_promotion
create or replace package pa_promotion is
type sqlcur is ref cursor;
	function getByNum(numpromotion number) return promotion%rowtype;  
	function getAll(theorder varchar2, thedirection varchar2) return sqlcur; 
	
	
	
	
	
	
end pa_promotion;
/

--CORPS PACKAGE PA_promotion
Create or replace package body pa_promotion is 

	--Fonction qui retourne tous les champs d'un promotion donné en fonction de son id
	function getByNum(numpromotion number) return promotion%rowtype
	is  
	ligne_promotion promotion%rowtype;  
	begin   
		select * into ligne_promotion from promotion where num_promo = numpromotion;
		return ligne_promotion;
	end getByNum;
 
 
	--Fonction qui retourne la liste de tous les promotions
	function getAll(theorder varchar2, thedirection varchar2) return sqlcur
	is  
		c1 sqlcur;
		req varchar2(200) := 'select * from promotion p order by p.' || theorder || ' ' || thedirection || '';
	begin  
		open c1 for req;
		return c1;
	exception
	when no_data_found then   
		return null;
	end getAll; 
	
	 
end pa_promotion;
/
show error;
 