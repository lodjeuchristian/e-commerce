--INTERFACE PACKAGE PA_livraison
create or replace package pa_livraison is
type sqlcur is ref cursor;
	function getByNumCommande(num number) return livraison%rowtype;
		
end pa_livraison;
/

--CORPS PACKAGE PA_livraison
Create or replace package body pa_livraison is 
	
	--Fonction qui récupère les résultats de la recherche
	function getByNumCommande(num number) return livraison%rowtype
	is
		ligne_livraison livraison%rowtype;  
	begin
		select * into ligne_livraison from livraison where num_cmde = num order by date_livraison desc;
		return ligne_livraison;
	exception
	when no_data_found then   
		return null;
	end getByNumCommande; 
	
end pa_livraison;
/
show error;
 