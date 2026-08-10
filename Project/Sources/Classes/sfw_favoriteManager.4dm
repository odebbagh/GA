singleton Class constructor
	
	
	
	
Function clicOnHeader
	var $signal : 4D:C1709.Signal
	
	$signal:=New signal:C1641
	Use ($signal)
		$signal.UUID_target:=Form:C1466.current_item.UUID
		$signal.UUID_User:=cs:C1710.sfw_userManager.me.info.UUID
		$signal.entryIdent:=Form:C1466.sfw.entry.ident
	End use 
	CALL WORKER:C1389("sfw_favorite_worker"; Formula:C1597(cs:C1710.sfw_favoriteManager.me._worker($1)); $signal)
	$signal.wait(100)
	If ($signal.signaled)
		This:C1470._displayHeaderTabFavorite()
	End if 
	
	
Function _worker($signal : 4D:C1709.Signal)
	var $eFavorite : cs:C1710.sfw_FavoriteEntity
	If ($signal.UUID_User=("00"*16))
		$eFavorite:=ds:C1482.sfw_Favorite.query("UUID_target = :1 and entryIdent = :2"; $signal.UUID_target; $signal.entryIdent).first()
	Else 
		$eFavorite:=ds:C1482.sfw_Favorite.query("UUID_target = :1 and UUID_User = :2 and entryIdent = :3"; $signal.UUID_target; $signal.UUID_User; $signal.entryIdent).first()
	End if 
	If ($eFavorite=Null:C1517)
		$eFavorite:=ds:C1482.sfw_Favorite.new()
		$eFavorite.UUID:=Generate UUID:C1066
		$eFavorite.UUID_target:=$signal.UUID_target
		$eFavorite.UUID_User:=$signal.UUID_User
		$eFavorite.entryIdent:=$signal.entryIdent
		$eFavorite.stmp:=cs:C1710.sfw_stmp.me.now()
		$info:=$eFavorite.save()
		
	Else 
		$info:=$eFavorite.drop()
	End if 
	
	$signal.trigger()
	
	
	
Function _displayHeaderTabFavorite()
	var $esFavorite : cs:C1710.sfw_FavoriteSelection
	
	If (Form:C1466.current_item#Null:C1517) && (Bool:C1537(Form:C1466.sfw.entry.allowFavorite))
		If (cs:C1710.sfw_userManager.me.info.UUID=("00"*16))
			$esFavorite:=ds:C1482.sfw_Favorite.query("UUID_target = :1 and entryIdent = :2"; Form:C1466.current_item.UUID; Form:C1466.sfw.entry.ident)
		Else 
			$esFavorite:=ds:C1482.sfw_Favorite.query("UUID_target = :1 and UUID_User = :2 and entryIdent = :3"; Form:C1466.current_item.UUID; cs:C1710.sfw_userManager.me.info.UUID; Form:C1466.sfw.entry.ident)
		End if 
		$title:=($esFavorite.length=0) ? ds:C1482.sfw_readXliff("favorite.addFavorite"; "Add as favorite") : ds:C1482.sfw_readXliff("favorite.isFavorite"; "Is a favorite")
		OBJECT SET HELP TIP:C1181(*; "headerTabFavorite_button"; $title)
		$format:=($esFavorite.length=0) ? ";path:/RESOURCES/sfw/image/picto/star-empty.png;;4;1;1;4;0;0;0;0;0;1;1" : ";path:/RESOURCES/sfw/image/picto/star.png;;4;1;1;4;0;0;0;0;0;1;1"
		OBJECT SET FORMAT:C236(*; "headerTabFavorite_button"; $format)
		$favoriteTabVisible:=(Form:C1466.current_item#Null:C1517) && (Bool:C1537(Form:C1466.sfw.entry.allowFavorite))
		OBJECT SET VISIBLE:C603(*; "headerTabFavorite@"; $favoriteTabVisible)
	Else 
		OBJECT SET VISIBLE:C603(*; "headerTabFavorite@"; False:C215)
	End if 
	
	Form:C1466.sfw.arrangeHeaderTabs()
	
	
Function getUUIDs($entryIdent : Text)->$uuids : Collection
	
	If (Count parameters:C259=0)
		If (cs:C1710.sfw_userManager.me.info.UUID=("00"*16))
			$uuids:=ds:C1482.sfw_Favorite.all().UUID_target
		Else 
			$uuids:=ds:C1482.sfw_Favorite.query("UUID_User = :1"; cs:C1710.sfw_userManager.me.info.UUID).UUID_target
		End if 
	Else 
		If (cs:C1710.sfw_userManager.me.info.UUID=("00"*16))
			$uuids:=ds:C1482.sfw_Favorite.query("entryIdent = :1"; $entryIdent).UUID_target
		Else 
			$uuids:=ds:C1482.sfw_Favorite.query("UUID_User = :1 and entryIdent = :2"; cs:C1710.sfw_userManager.me.info.UUID; $entryIdent).UUID_target
		End if 
	End if 
	
	
Function getFavorites($entryIdent : Text)->$esFavorite : cs:C1710.sfw_FavoriteSelection
	
	$UUIDs:=This:C1470.getUUIDs($entryIdent)
	$entry:=cs:C1710.sfw_definition.me.getEntryByIdent($entryIdent)
	$esFavorite:=ds:C1482[$entry.dataclass].query("UUID in :1"; $UUIDs)
	
	