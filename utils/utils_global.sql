--INTERFACE PACKAGE PA_auteur
create or replace package utils_global is 

type sqlcur is ref cursor;

	-- pour le panier
	function getMonPanier return sqlcur;
	function getMonPanierNumerique return sqlcur;
	function getMontalTotal return number;
	function getNbLivresNumeriques return number;
	function getNbLivres return number;
	procedure createMonPanier; 
	procedure ajouterAuPanier(ref_livre varchar2,type_support varchar2,prix_unitaire number,quantite number);	
	procedure modifierMonPanier(uref_livre varchar2,utype_support varchar2,uprix_unitaire number,uquantite number);
	procedure modifierQuantite(uref_livre varchar2, uquantite number);
	procedure modifierTypeSupport(uref_livre varchar2, utype_support varchar2);
	procedure deleteByRef(reference varchar2);
	procedure viderMonPanier;
 
 
 
	
end utils_global;
/

--CORPS PACKAGE PA_auteur
Create or replace package body utils_global is 
 
	--Fonction qui retourne le panier 
	function getMonPanier return sqlcur
	is  
		c1 sqlcur;
		req varchar2(1000) := 'select * from mon_panier';
	begin  
		open c1 for req;
		return c1;
	exception
	when no_data_found then   
		return null;
	end getMonPanier; 
 
 
	--Fonction qui retourne le panier 
	function getMonPanierNumerique return sqlcur
	is  
		c1 sqlcur; 
	begin  
		open c1 for select * from mon_panier where type_support = 'numerique';
		return c1;
	exception
	when no_data_found then   
		return null;
	end getMonPanierNumerique; 
	
	--fonction qui retourne le montant total à payer
	function getMontalTotal return number
	is
		total number(5,2); 
	begin
		select nvl(sum(prix_unitaire*quantite),0) into total from mon_panier; 
		return total;
	end;
	

	--fonction qui retourne le nombre de livres numériques
	function getNbLivresNumeriques return number
	is
		total number(5,2); 
	begin
		select count(*) into total from mon_panier where type_support = 'numerique'; 
		return total;
	end;
	
	--retourne le nombre de livres dans le panier
	function getNbLivres return number
	is
		nblivres number(5);
	begin
		select count(*) into nblivres from mon_panier;
		return nblivres;
	end;

	
	
	--procédure qui creer le panier s'il n'existe pas
	procedure createMonPanier
	is
		req varchar2(1000);
	begin
		req:= ' create global temporary table mon_panier(
					ref_livre varchar2(60),
					type_support varchar2(60),
					prix_unitaire number(5,2),
					quantite number(5)		
				)  
			  ';
		execute immediate req; 
	end;
	
 
	--procédure qui ajoute un livre au panier
	procedure ajouterAuPanier(ref_livre varchar2,type_support varchar2,prix_unitaire number,quantite number)
	is 
		reflivre varchar2(60);
		thereference varchar2(60);
	begin
		reflivre:= '%' || ref_livre || '%';
		select ref_livre into thereference from mon_panier where ref_livre like reflivre; 
		update mon_panier set quantite = quantite+1 where ref_livre like reflivre;  
		commit; 
	exception
		when no_data_found then
			insert into mon_panier values(ref_livre,type_support,prix_unitaire,quantite);
			commit; 
	end;
	
	
	--procédure qui modifie le panier
	procedure modifierMonPanier(uref_livre varchar2,utype_support varchar2,uprix_unitaire number,uquantite number)
	is
		reflivre varchar2(60);
		req varchar2(1000);
	begin
		reflivre:= '%' || uref_livre || '%';
		update mon_panier set ref_livre = uref_livre, type_support = utype_support, prix_unitaire = uprix_unitaire, quantite = uquantite where ref_livre like reflivre;
		commit;
	end;


	--procédure qui modifie la quantite
	procedure modifierQuantite(uref_livre varchar2, uquantite number)
	is
		reflivre varchar2(60);
		req varchar2(1000);
	begin
		reflivre:= '%' || uref_livre || '%';
		update mon_panier set quantite = uquantite where ref_livre like reflivre;
		commit;
	end;
	

	--procédure qui modifie la quantite
	procedure modifierTypeSupport(uref_livre varchar2, utype_support varchar2)
	is
		reflivre varchar2(60);
		req varchar2(1000);
	begin
		reflivre:= '%' || uref_livre || '%';
		update mon_panier set type_support = utype_support where ref_livre like reflivre;
		commit;
	end;

	
	--procédure qui retire un livre du panier
	procedure deleteByRef(reference varchar2)
	is
		reflivre varchar2(60); 
		req varchar2(1000);
	begin  
		reflivre:= '%' || reference || '%';
		delete from mon_panier where ref_livre like reflivre;
		commit;
	end;
 
 
	--procédure qui supprime le panier
	procedure viderMonPanier
	is  
	begin    
		delete from mon_panier;
	end;
	
 
	
	
		
	
end utils_global;
/
show error;
 