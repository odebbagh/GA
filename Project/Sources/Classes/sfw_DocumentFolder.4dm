Class extends DataClass

local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	
	$entry:=cs:C1710.sfw_definitionEntry.new("documentFolder"; "documentManagement"; ds:C1482.sfw_readXliff("documentFolder.entry.plural"); ds:C1482.sfw_readXliff("documentFolder.entry.single"))
	$entry.setDataclass("sfw_DocumentFolder")
	//$entry.setXliffLabel("documentFolder.entry.plural")
	$entry.setDisplayOrder(11010)
	$entry.setIcon("sfw/entry/DocumentFolder-50x50.png")
	
	$entry.setSearchboxField("name")
	
	
	$entry.setPanel("sfw_panel_documentFolder"; 1)
	$entry.setPanelPage(1; ""; "Definition")
	$entry.setPanelPage(2; ""; "Permissions")
	
	
	$entry.setRLDefinition("name"; "parentFolder")
	$entry.setMainViewLabel(ds:C1482.sfw_readXliff("documentFolder.entry.allfolders"))
	
	$entry.enableTransaction()
	$entry.setItemListPreconfigAction("exportReferenceRecords")
	$entry.setItemListPreconfigAction("importReferenceRecords")
	
	$entry.setValidationRule("name"; "entryField_name"; "mandatory"; "trimSpace"; "message:the name is mandatory")
	$entry.setValidationRule("ident"; "entryField_ident"; "mandatory"; "trimSpace"; "message:the ident is mandatory")
	$entry.setValidationRule("ident"; "entryField_ident"; "unique"; "message:the ident is must be unique")
	
	$entry.setAllowedProfiles("admin")
	
	
	
Function getAndCreateIfNotExist($ident : Text; $name : Text;  ...  : Text)->$eFolder : cs:C1710.sfw_DocumentFolderEntity
	var $eParentFolder : cs:C1710.sfw_DocumentFolderEntity
	
	If (Application type:C494#4D Remote mode:K5:5)
		$eFolder:=ds:C1482.sfw_DocumentFolder.query("ident = :1"; $ident).first()
		If ($eFolder=Null:C1517)
			$eFolder:=This:C1470.new()
			$eFolder.UUID:=Generate UUID:C1066
			$eFolder.ident:=$ident
			$eFolder.name:=$name
			$eFolder.moreData:=New object:C1471
			
			For ($p; 3; Count parameters:C259)
				$params:=Split string:C1554(${$p}; ":")
				$selector:=$params.shift()
				Case of 
					: ($selector="subFolderOf")
						$eParentFolder:=ds:C1482.sfw_DocumentFolder.query("ident = :1"; $params[0]).first()
						If ($eParentFolder#Null:C1517)
							$eFolder.UUID_ParentFolder:=$eParentFolder.UUID
						End if 
				End case 
			End for 
			$info:=$eFolder.save()
			
		End if 
	End if 
	
	//Mark:- Function to manage the cache
local Function cacheClear()
	If (Storage:C1525.cache#Null:C1517)
		Use (Storage:C1525.cache)
			Storage:C1525.cache.documentFolder:=Null:C1517
		End use 
	End if 
	
	
local Function cacheLoad($option : Integer)
	
	If (Storage:C1525.cache=Null:C1517)
		Use (Storage:C1525)
			Storage:C1525.cache:=New shared object:C1526
		End use 
	End if 
	If (Storage:C1525.cache.documentFolder=Null:C1517) || (Count parameters:C259>0)
		$documentFolder:=This:C1470._loadAsCollection()
		Use (Storage:C1525.cache)
			Storage:C1525.cache.documentFolder:=$documentFolder.copy(ck shared:K85:29; Storage:C1525.cache)
		End use 
	End if 
	
	
local Function cacheGet($uuid : Text)->$documentFolder : Object
	If (Storage:C1525.cache=Null:C1517)
		This:C1470.cacheLoad()
	Else 
		If (Storage:C1525.cache.sfw_country=Null:C1517)
			This:C1470.cacheLoad()
		End if 
	End if 
	
	$indices:=Storage:C1525.cache.documentFolder.indices("UUID = :1"; $uuid)
	If ($indices.length>0)
		$documentFolder:=Storage:C1525.cache.documentFolder[$indices[0]]
	Else 
		$documentFolder:=New object:C1471
	End if 
	
	
Function trigger()
	If (Application type:C494=4D Local mode:K5:1)
		This:C1470.cacheClear()
	Else 
		EXECUTE ON CLIENT:C651("@"; "sfw_cacheManager"; "clear"; "sfw_DocumentFolder")
	End if 
	
Function _loadAsCollection()->$documentFolder : Collection
	
	$documentFolder:=This:C1470.all().toCollection().orderBy("name")