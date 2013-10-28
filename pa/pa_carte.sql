--INTERFACE PACKAGE PA_utilisateur
create or replace package pa_carte is
type sqlcur is ref cursor;
	procedure put(num_carte char, num_utilisateur number, nom_proprietaire varchar2, prenom_proprietaire varchar2, type_carte varchar2, crayptogramme char, date_expiration date);
	
end pa_carte;
/

--CORPS PACKAGE PA_utilisateur
Create or replace package body pa_carte is 

 --ajoute un enregistrement
 procedure put(num_carte char, num_utilisateur number, nom_proprietaire varchar2, prenom_proprietaire varchar2, type_carte varchar2, crayptogramme char, date_expiration date)
 is 
 begin
	insert into carte_bancaire values(num_carte, num_utilisateur, nom_proprietaire, prenom_proprietaire, type_carte, crayptogramme, date_expiration);
	commit; 
 end;
 
  
 
end pa_carte;
/
show error;
 