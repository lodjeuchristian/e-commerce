--INTERFACE PACKAGE PA_utilisateur
create or replace package pa_utilisateur is
type sqlcur is ref cursor;
	function getByLoginAndPassword(login varchar2, password varchar2) return utilisateur%rowtype;
	function isValidIdentifiers(login varchar2, password varchar2) return boolean;
	function get_cookie (cookie_name varchar2) return varchar2 ;
	function isAuthenticated return boolean;
	function getByLogin(login varchar2) return utilisateur%rowtype;
	function getAllCommandes return sqlcur;
	function encrypt_password (v_mdp in varchar2 default null) return varchar2;
	function isMailClientUnique(mail in varchar2) return boolean; 
end pa_utilisateur;
/

--CORPS PACKAGE PA_utilisateur
Create or replace package body pa_utilisateur is 

	--Fonction qui retourne la ligne de la table utilisateur en fonction du login et du password
	function getByLoginAndPassword(login varchar2, password varchar2) return utilisateur%rowtype
	is  
		ligne_utilisateur utilisateur%rowtype;  
	begin   
		select * into ligne_utilisateur from utilisateur where login_utilisateur = login and password_utilisateur = password ;
		return ligne_utilisateur;
	exception
	when no_data_found then   
			return null;
	end getByLoginAndPassword ;
	
	--Fonction qui verifier la validité des champs renseignés par l'utilisateur
	function isValidIdentifiers(login varchar2, password varchar2) return boolean
	is 
		res number;
	begin
		select 1 into res from utilisateur where login_utilisateur = login and password_utilisateur = password ;
		return SQL%FOUND;
	Exception
	when no_data_found then 
		return false;
	end isValidIdentifiers;
	
	--Fonction qui récupère la valeur du cookie d'authentification
	function get_cookie (cookie_name varchar2) return varchar2
	is
		auth_cookie owa_cookie.cookie;
	begin
		auth_cookie := owa_cookie.get (cookie_name);
    
    if auth_cookie.num_vals > 0 then
      return auth_cookie.vals (1);
    else
      return null;
    end if;
	end get_cookie;
	
	--Fonction qui vérifie si l'utilisateur est connecté ou pas 
	function isAuthenticated return boolean
	is
		auth_cookie owa_cookie.cookie;
	begin
		auth_cookie := owa_cookie.get('login');
		if auth_cookie.vals.First IS NULL then   
			return false;  
		else   
			return true;   
		end if;
	end isAuthenticated;
	
	--Fonction qui retourne la ligne de la table utilisateur en fontion du login
	function getByLogin(login varchar2) return utilisateur%rowtype
	is
		ligne_utilisateur utilisateur%rowtype;  
	begin   
		select * into ligne_utilisateur from utilisateur where login_utilisateur = login;
		return ligne_utilisateur;
	end getByLogin;
	
	--Fonction qui récupère la liste des commandes de l'utilisateur connecté
	function getAllCommandes return sqlcur
	is
		c1 sqlcur;
	begin
		open c1 for select * from commande where num_utilisateur in (select num_utilisateur from utilisateur  where login_utilisateur = get_cookie('login')) order by 4 desc;
		return c1;
	exception
	when no_data_found then   
		return null;
	end getAllCommandes;
	
	--Fonction qui récupère le mot passe saisi par l'utilisateur, l'encrypte et retourne la valeur encryptée
	function encrypt_password (v_mdp in varchar2 default null) return varchar2
	is
		encrypted_pwd varchar2(100);
	begin
		-- utilisation de l'algorithme de hashage md5
		encrypted_pwd := dbms_obfuscation_toolkit.md5(input_string=>v_mdp);
		return encrypted_pwd;
	end;
	
	--Fonction qui vérifie l'unicité du mail renseigné par le client
	function isMailClientUnique(mail in varchar2) return boolean
	is
	total number;
	begin
		select count(login_utilisateur) into total from utilisateur where login_utilisateur = mail;
		if total > 0 then
			return false;
		else
			return true;
		end if;	
	end isMailClientUnique;
	
 
	
end pa_utilisateur;
/
show error;
 