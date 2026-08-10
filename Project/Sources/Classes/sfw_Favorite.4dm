Class extends DataClass


Function getIdentFavoriteEntries()->$idents : Collection
	var $esFavorites : cs:C1710.sfw_FavoriteSelection
	If (cs:C1710.sfw_userManager.me.info.UUID=("00"*16))
		$esFavorites:=ds:C1482.sfw_Favorite.query("UUID_target = null")
	Else 
		$esFavorites:=ds:C1482.sfw_Favorite.query("UUID_target = null and UUID_User = :1 "; cs:C1710.sfw_userManager.me.info.UUID)
	End if 
	
	$idents:=$esFavorites.extract("entryIdent")