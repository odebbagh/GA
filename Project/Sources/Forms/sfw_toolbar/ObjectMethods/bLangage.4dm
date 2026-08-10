$lprog:=Get database localization:C1009(Current localization:K5:22)


$folders:=Folder:C1567(fk resources folder:K87:11).folders().query("extension = :1"; ".lproj")


$menu:=Create menu:C408

For each ($folder; $folders)
	APPEND MENU ITEM:C411($menu; $folder.name)
	SET MENU ITEM PARAMETER:C1004($menu; -1; $folder.name)
	If ($folder.name=$lprog)
		SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
	End if 
End for each 
$choose:=Dynamic pop up menu:C1006($menu)
RELEASE MENU:C978($menu)

Case of 
	: ($choose="")
	: ($choose#"")
		SET DATABASE LOCALIZATION:C1104($choose)
		ACCEPT:C269
End case 