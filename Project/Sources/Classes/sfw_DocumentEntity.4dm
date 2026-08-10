Class extends Entity


Function get date()->$date : Date
	$date:=cs:C1710.sfw_stmp.me.getDate(This:C1470.stmp)
	
	
local Function saveFromFile()->$return : Object
	var $file : 4D:C1709.File
	var $blob : 4D:C1709.Blob
	
	If (This:C1470.moreData.originalPathOnClient#Null:C1517)
		READ PICTURE FILE:C678(This:C1470.moreData.originalPathOnClient; $pict)
		$file:=File:C1566(This:C1470.moreData.originalPathOnClient; fk platform path:K87:2)
		PICTURE TO BLOB:C692($pict; $blob; $file.extension)
		$return:=This:C1470.processSaveFromFile($file; $blob)
		If ($return.success)
			This:C1470.moreData.originalPathOnClient:=Null:C1517
		End if 
	End if 
	
Function processSaveFromFile($file : Object; $blob : 4D:C1709.Blob)->$return : Object
	
	$return:={success: False:C215}
	
	If (BLOB size:C605($blob)>0)
		
		$subFolder:=This:C1470._getSubFolder()
		
		$subFolder.file(This:C1470.getKey()).setContent($blob)
		
		This:C1470.moreData:=This:C1470.moreData || New object:C1471
		This:C1470.moreData.fileInfo:=$file
		$return:=This:C1470.save()
		
	End if 
	
	
Function saveFromWP($wp : 4D:C1709.WriteDocument)->$return : Object
	var $file : 4D:C1709.File
	$subFolder:=This:C1470._getSubFolder()
	
	$file:=$subFolder.file(This:C1470.getKey())
	
	WP EXPORT DOCUMENT:C1337($wp; $file.platformPath; wk 4wp:K81:4; wk normal:K81:7)
	
	
Function getStoredBlob()->$return : 4D:C1709.Blob
	
	var $file : 4D:C1709.File
	var $subFolder : 4D:C1709.Folder
	$key:=This:C1470.getKey()
	$subFolder:=This:C1470._getSubFolder()
	$file:=$subFolder.file($key)
	If ($file.exists)
		$return:=$file.getContent()
	End if 
	
	
Function getStoredWP()->$return : 4D:C1709.WriteDocument
	
	var $file : 4D:C1709.File
	$subFolder:=This:C1470._getSubFolder()
	$fileName:=This:C1470.getKey(dk key as string:K85:16)  //+".4wp"
	$file:=$subFolder.file($fileName+".4wp")
	If ($file.exists)
		
		$return:=WP Import document:C1318($file.platformPath)
	End if 
	
	
Function _getSubFolder()->$subFolder : 4D:C1709.Folder
	
	$level1:=Substring:C12(This:C1470.UUID; 1; 2)
	$level2:=Substring:C12(This:C1470.UUID; 1; 4)
	$subFolder:=cs:C1710.sfw_definition.me.globalParameters.documentsStorageOnServer.folder.folder($level1).folder($level2)
	If (Not:C34($subFolder.exists))
		$subFolder.create()
	End if 
	
	
Function get displayableSize()->$displayableSize : Text
	This:C1470.moreData:=This:C1470.moreData || New object:C1471
	If (This:C1470.moreData.size=Null:C1517)
		$blob:=This:C1470.getStoredBlob()
		If ($blob#Null:C1517)
			This:C1470.moreData.size:=BLOB size:C605($blob)
		Else 
			This:C1470.moreData.size:=0
		End if 
	End if 
	$size:=This:C1470.moreData.size
	$displayableSize:=cs:C1710.sfw_bytes.me.getBestFormat($size)
	
	
Function deleteFile()
	var $file:=This:C1470._getSubFolder().file(This:C1470.UUID)
	If ($file.exists)
		$file.delete()
	End if 
	