CREATE OR REPLACE PROCEDURE redirection(login varchar2, password varchar2, action varchar2)
is 
	ligne_utilisateur utilisateur%rowtype;
	encrypted_pwd varchar(100);
begin 
	encrypted_pwd := pa_utilisateur.encrypt_password(password);
	if pa_utilisateur.isValidIdentifiers(login,encrypted_pwd) then
		ligne_utilisateur := pa_utilisateur.getByLoginAndPassword(login,encrypted_pwd);
		owa_util.mime_header('text/html', FALSE); 
		owa_cookie.send
		(  
			name=>'login',  
			value=>ligne_utilisateur.login_utilisateur,  
			expires => sysdate + interval '15' minute
		); 
		if action = 'consultercompte' then
			owa_util.redirect_url('/g07_epg_dad/consultercompte');
		else
			owa_util.redirect_url('/g07_epg_dad/passercommande1');
		end if;
	else
		owa_util.redirect_url('/g07_epg_dad/authentificationcompte');
	end if ;
end redirection; 
/
show error;