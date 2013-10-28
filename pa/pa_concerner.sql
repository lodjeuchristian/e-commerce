--INTERFACE PACKAGE PA_utilisateur
create or replace package pa_concerner is
type sqlcur is ref cursor;
	procedure put(num_cmde number, ref_livre char, qte_cmde number, prix_achat number);
	
end pa_concerner;
/

--CORPS PACKAGE PA_utilisateur
Create or replace package body pa_concerner is 

 --ajoute un enregistrement
 procedure put(num_cmde number, ref_livre char, qte_cmde number, prix_achat number)
 is 
 begin
	insert into concerner(num_cmde, ref_livre, qte_cmde, prix_achat)
		values(num_cmde, ref_livre, qte_cmde, prix_achat);
	commit; 
 end;
 
  
 
end pa_concerner;
/
show error;
 