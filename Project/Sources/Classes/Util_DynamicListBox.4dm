singleton Class constructor
	
	
Function deleteAllColumns($listboxName : Text)
	
	While (LISTBOX Get number of columns:C831(*; $listboxName)>0)
		LISTBOX DELETE COLUMN:C830(*; $listboxName; 1)
	End while 
	
	
Function insertColumns($listboxName : Text; $colSettings : Collection; $data : Collection)
	
/*
 $colSettings looks like a collection of object 
  -> Ex of object: {"field"; "nom"; "title"; "User Name"; "minWidth"; 150; "maxWidth"; 250}
*/
	
	var $listBoxData : Collection:=New collection:C1472()
	var $targetProperties : Collection:=New collection:C1472()
	//var $colomnSettings : Collection:=New collection()
	var $lastColPosition : Integer
	var $colName : Text
	var $headerName : Text
	var $colPosition : Integer
	
	$colomnSettings:=$colSettings=Null:C1517 ? New object:C1471 : $colSettings
	
	For each ($column; $colomnSettings)
		
		$lastColPosition:=LISTBOX Get number of columns:C831(*; $listboxName)
		$colName:="col_"+String:C10($lastColPosition)
		$headerName:="head_"+String:C10($lastColPosition)
		$colPosition:=$lastColPosition+1
		
		// 1. Insert the column
		LISTBOX INSERT COLUMN FORMULA:C970(*; $listboxName; $colPosition; $colName; \
			"This."+$column.field; $column.fieldType; $headerName; $colName)
		
		// 2. Set Header Text & Style
		OBJECT SET TITLE:C194(*; $headerName; $column.title)
		OBJECT SET FONT STYLE:C166(*; $headerName; Bold:K14:2)
		
		// 3. Set Appearance
		LISTBOX SET COLUMN WIDTH:C833(*; $colName; $column.width; $column.minWidth; $column.maxWidth)
		
		// 4. Optional: Center header text
		//OBJECT SET TEXT ALIGNMENT(*; $headerName; Align center)
		
	End for each 
	
	
	
Function getListBoxCollection($collection : Collection; $targetProperties : Collection)->$listBoxCollection : Collection
	
	If (Form:C1466#Null:C1517)
		$listBoxCollection:=New collection:C1472()
		
		For each ($object; $collection)
			$item:=New object:C1471()
			For each ($property; $targetProperties)
				
				$item[$targetProperties]:=$object[$targetProperties]
				
			End for each 
			
			$listBoxCollection.push($item)
			
		End for each 
		
	End if 
	
	
	
	
	
	
	
	