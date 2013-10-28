CREATE OR REPLACE PROCEDURE ajouteraupanier(ref_livre varchar2, type_support varchar2, prix_unitaire number, quantite number, action varchar2, redirecturl varchar2)
is  
	prix_de_vente number(5,2);
begin  
	prix_de_vente := pa_livre.getSellingPriceByRef(trim(ref_livre));
	
	if action = 'ajout' then 
		utils_global.ajouterAuPanier(trim(ref_livre),type_support,to_number(prix_de_vente),to_number(quantite));
	elsif action = 'modifier' then
		utils_global.modifierMonPanier(trim(ref_livre),type_support,to_number(prix_de_vente),to_number(quantite));
	elsif action = 'supprimer' then
		utils_global.deleteByRef(trim(ref_livre));
	elsif action = 'vider' then
		utils_global.viderMonPanier;
	end if; 
	  
	owa_util.redirect_url('/g07_epg_dad/' || redirecturl);
 
end ajouteraupanier; 
/

CREATE OR REPLACE PROCEDURE viderPanier(redirecturl varchar2)
is   
begin  
	utils_global.viderMonPanier; 
	owa_util.redirect_url('/g07_epg_dad/' || redirecturl);
 
end viderPanier; 
/


CREATE OR REPLACE PROCEDURE update_quantite(ref_livre varchar2, quantite number, redirecturl varchar2)
is   
begin  
	utils_global.modifierQuantite(trim(ref_livre), to_number(quantite)); 
	owa_util.redirect_url('/g07_epg_dad/' || redirecturl);
 
end update_quantite; 
/

CREATE OR REPLACE PROCEDURE update_support(ref_livre varchar2, type_support varchar2, redirecturl varchar2)
is   
begin  
	utils_global.modifierTypeSupport(trim(ref_livre), type_support); 
	owa_util.redirect_url('/g07_epg_dad/' || redirecturl);
 
end update_support; 
/


CREATE OR REPLACE PROCEDURE remove_livre(ref_livre varchar2, redirecturl varchar2)
is   
begin  
	utils_global.deleteByRef(trim(ref_livre)); 
	owa_util.redirect_url('/g07_epg_dad/' || redirecturl);
 
end remove_livre; 
/

