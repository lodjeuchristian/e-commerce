CREATE OR REPLACE PROCEDURE inscription (nom varchar2, prenom varchar2, email varchar2, password varchar2, action varchar2)
is 
	cookie_auth varchar2(30);
	encrypted_pwd varchar(100);
begin 
	encrypted_pwd := pa_utilisateur.encrypt_password(password);
	
	if pa_utilisateur.isMailClientUnique(email) then
		if action = 'inscriptioncompte' or  action = 'inscriptioncommande' then
			insert into utilisateur (nom_utilisateur,prenom_utilisateur,login_utilisateur,password_utilisateur,type_utilisateur) 
				values(nom, prenom, email,encrypted_pwd,'client'); 
			owa_util.mime_header('text/html', FALSE); 
			owa_cookie.send
			(  
				name=>'login',  
				value=>email,  
				expires => sysdate + interval '15' minute
			); 
			if action = 'inscriptioncompte' then
				owa_util.redirect_url('/g07_epg_dad/consultercompte');
			else
				owa_util.redirect_url('/g07_epg_dad/passercommande1');
			end if;
		else
			cookie_auth := pa_utilisateur.get_cookie('login');
			update utilisateur set nom_utilisateur=nom, prenom_utilisateur=prenom,login_utilisateur=email,password_utilisateur=password where login_utilisateur = cookie_auth;
			owa_util.redirect_url('/g07_epg_dad/consultercompte');
		end if;
	else
		owa_util.redirect_url('/g07_epg_dad/consultercompte');
	end if ;
	 
end inscription; 
/
show error;