CREATE OR REPLACE PROCEDURE deconnexion
is 
begin 
	if pa_utilisateur.isAuthenticated then
		owa_cookie.remove('login',NULL);
		utils_global.viderMonPanier;
	end if;
	owa_util.redirect_url('/g07_epg_dad/home');
end deconnexion; 
/