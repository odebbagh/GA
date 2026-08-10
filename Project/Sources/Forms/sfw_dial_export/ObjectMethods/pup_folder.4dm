var $folder : 4D:C1709.Folder

$menu:=Create menu:C408

$folder:=Form:C1466.folderToExport
While ($folder#Null:C1517)
	APPEND MENU ITEM:C411($menu; $folder.name; *)
	//SET MENU ITEM PARAMETER($menu; -1; )
	$folder:=$folder.parent
End while 
APPEND MENU ITEM:C411($menu; "-")
APPEND MENU ITEM:C411($menu; "Select the folder to export ..."; *)
SET MENU ITEM PARAMETER:C1004($menu; -1; "--select")

$choose:=Dynamic pop up menu:C1006($menu)
RELEASE MENU:C978($menu)

Case of 
	: ($choose="--select")
		$folderpath:=Select folder:C670("Select the folder to export"; Form:C1466.folderToExport.platformPath)
		If (ok=1)
			Form:C1466.folderToExport:=Folder:C1567($folderpath; fk platform path:K87:2)
			cs:C1710.sfw_dialog.me._setLastExportFolder(Form:C1466.folderToExport)
			OBJECT SET TITLE:C194(*; "pup_folder"; Form:C1466.folderToExport.name)
		End if 
End case 
