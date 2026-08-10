//%attributes = {}
/*
_ga_createMoreDataFields

Create moreData field if it does not exist in each table of the database

*/


var $XmlCatalog; $catalogPath; $elementTosearch : Text

$catalogPath:=Folder:C1567(fk database folder:K87:14).folder("Project").folder("Sources").file("catalog.4DCatalog").platformPath

$elementTosearch:="table"

//Parse Catalog File
$XmlCatalog:=DOM Parse XML source:C719($catalogPath)

$totalTables:=DOM Count XML elements:C726($XmlCatalog; $elementTosearch)

For ($i; 1; $totalTables)  //Loop on all tables
	
	$fieldFind:=False:C215
	
	$targetedElement:=$elementTosearch+"["+String:C10($i)+"]"
	
	$tableNode:=DOM Find XML element:C864($XmlCatalog; $targetedElement)
	
	DOM GET XML ATTRIBUTE BY NAME:C728($tableNode; "name"; $tableName)
	
	If ($tableName#"sfw_@") & ($tableName#"dfd_@")
		
		$targetedChildToSearch:="field"
		
		$totalfields:=DOM Count XML elements:C726($tableNode; $targetedChildToSearch)
		
		For ($j; 1; $totalfields)  //Loop on on all fields of the current table and search for "moreData"
			
			$targetedChildElement:=$targetedChildToSearch+"["+String:C10($j)+"]"
			
			$field:=DOM Find XML element:C864($tableNode; $targetedChildElement)
			
			DOM GET XML ATTRIBUTE BY NAME:C728($field; "name"; $fieldName)
			
			If ($fieldName="moreData")
				
				$fieldFind:=True:C214
				
			End if 
			
		End for 
		$UUID:=Generate UUID:C1066
		If (Not:C34($fieldFind))  // If not found the create it
			
			$name:="moreData"
			$uuid:=Generate UUID:C1066  //"EBF096AA221543D59956F8268859F11F"
			$vxPath:="field[1]"
			
			// 1. Création de l'élément 'field' sous le nœud table parent ($tableRef)
			$fieldRef:=DOM Create XML element:C865($tableNode; $vxPath)
			
			// 2. Ajout de chaque attribut tel qu'ils apparaissent dans votre extrait
			DOM SET XML ATTRIBUTE:C866($fieldRef; "name"; $name)
			DOM SET XML ATTRIBUTE:C866($fieldRef; "uuid"; $uuid)
			DOM SET XML ATTRIBUTE:C866($fieldRef; "type"; "21")  // Type Objet
			DOM SET XML ATTRIBUTE:C866($fieldRef; "blob_switch_size"; "2147483647")
			DOM SET XML ATTRIBUTE:C866($fieldRef; "never_null"; "true")
			
		End if 
		
	End if 
	
End for 

DOM EXPORT TO FILE:C862($XmlCatalog; $catalogPath)



