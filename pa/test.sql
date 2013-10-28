-- TEST PACKAGE PA_LIVRE
set serveroutput on

--recherche livre par id
Create or replace procedure test
is
	ligne_livre livre%rowtype;
	reff varchar2(60):= 'RESIS';
begin
	
	ligne_livre:= pa_livre.getbyref(reff);
	dbms_output.put_line(ligne_livre.ref_livre || ' - ' ||ligne_livre.titre_livre); 
	

end;
/
show error;

--recherche livre par titre
Create or replace procedure test
is
	ligne_livre livre%rowtype;
	titre varchar2(60):= 'CCNA';
begin
	
	ligne_livre:= pa_livre.getbytitre(titre);
	dbms_output.put_line(ligne_livre.ref_livre || ' - ' ||ligne_livre.titre_livre); 
end;
/
show error;


--recherche livres par editeur;
Create or replace procedure test
is
	ligne_livre livre%rowtype;
	type sqlcur is ref cursor;
	clivres sqlcur;
begin
	
	clivres:= pa_livre.getByEditeurNumber(21, 'titre_livre', 'DESC');
	LOOP
	fetch clivres into ligne_livre;
	exit when clivres%NOTFOUND;
		dbms_output.put_line(ligne_livre.ref_livre || ' - ' ||ligne_livre.titre_livre);  
	end loop;
	close clivres;
end;
/
show error;



--liste de tous les thèmes;
Create or replace procedure test
is
	ligne_theme theme%rowtype;
	type sqlcur is ref cursor;
	cthemes sqlcur;
begin
	
	cthemes:= pa_theme.getAll('lib_theme', 'ASC');
	LOOP
	fetch cthemes into ligne_theme;
	exit when cthemes%NOTFOUND;
		dbms_output.put_line(ligne_theme.num_theme || ' - ' ||ligne_theme.lib_theme);  
	end loop;
	close cthemes;
end;
/
show error;


--liste des thèmes d'un livre donné;
set serveroutput on
Create or replace procedure test
is
	ligne_theme theme%rowtype;
	type sqlcur is ref cursor;
	cthemes sqlcur;
begin 
	cthemes:= pa_theme.getByLivreRef('RE', 'lib_theme', 'ASC');
	LOOP
	fetch cthemes into ligne_theme;
	exit when cthemes%NOTFOUND; 
		dbms_output.put_line(ligne_theme.lib_theme || ' ,');   
	end loop;
	close cthemes; 
end;
/
show error;


--editeur d'un livre;
set serveroutput on
Create or replace procedure test
is
	ligne_editeur editeur%rowtype; 
begin 
	ligne_editeur:= pa_editeur.getByRefLivre('BDIOA'); 
	dbms_output.put_line(ligne_editeur.nom_editeur || ' ,');   
end;
/
show error;


execute utils_session.ajouterAuPanier('BDIOA');
begin
	dbms_output.put_line(utils_session.getNbLivres);
end;
/


--derniere cmd
set serveroutput on
Create or replace procedure test
is
	lastcmde number(10); 
begin 
	lastcmde:= pa_commande.getDerniereCommande;
	dbms_output.put_line(lastcmde);
end;
/
show error;


execute utils_session.ajouterAuPanier('BDIOA');
begin
	dbms_output.put_line(utils_session.getNbLivres);
end;
/



