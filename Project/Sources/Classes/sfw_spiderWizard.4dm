
property current_pathParts : Collection
property current_pathDataclassParts : Collection
property startDataclass : Text

singleton Class constructor
	
	
Function formMethod()
	
	Case of 
		: (FORM Event:C1606.code=On Load:K2:1)
			Form:C1466.lb_links:=New collection:C1472
			This:C1470.current_pathParts:=New collection:C1472
			This:C1470.current_pathDataclassParts:=New collection:C1472
			This:C1470.startDataclass:=""
			This:C1470.loadLinks(Form:C1466.current_item)
			Form:C1466.lb_links:=Form:C1466.lb_links.orderBy("depth, link")
	End case 
	
	
	
Function loadLinks($target : Variant)
	
	$previousPathParts:=This:C1470.current_pathParts
	
	$dataclassName:=This:C1470._getDataclassName($target)
	
	If (This:C1470.startDataclass="")
		This:C1470.startDataclass:=$dataclassName
	End if 
	
	If (ds:C1482[$dataclassName]#Null:C1517)
		For each ($attribute; ds:C1482[$dataclassName])
			Case of 
				: (ds:C1482[$dataclassName][$attribute].kind="relatedEntity")
					Case of 
						: ($target[$attribute]=Null:C1517)
						: (OB Instance of:C1731($target[$attribute]; cs:C1710[This:C1470.startDataclass+"Entity"]))
						: (OB Instance of:C1731($target[$attribute]; cs:C1710[This:C1470.startDataclass+"Selection"]))
						: (This:C1470.current_pathParts.indexOf($attribute)#-1)
						: (This:C1470.current_pathDataclassParts.indexOf(This:C1470._getDataclassName($target[$attribute]))#-1)
						Else 
							This:C1470.current_pathParts.push($attribute)
							This:C1470.current_pathDataclassParts.push(This:C1470._getDataclassName($target[$attribute]))
							$link:=New object:C1471
							$link.type:="relatedEntity"
							$link.link:=This:C1470.current_pathParts.join(".")
							$link.nbRecords:=($target[$attribute]#Null:C1517) ? 1 : 0
							$link.depth:=This:C1470.current_pathParts.length
							If ($link.nbRecords#0)
								Form:C1466.lb_links.push($link)
								This:C1470.loadLinks($target[$attribute])
							End if 
							$last:=This:C1470.current_pathParts.pop()
							$last:=This:C1470.current_pathDataclassParts.pop()
					End case 
					
				: (ds:C1482[$dataclassName][$attribute].kind="relatedEntities")
					Case of 
						: ($target[$attribute]=Null:C1517)
						: (OB Instance of:C1731($target[$attribute]; cs:C1710[This:C1470.startDataclass+"Entity"]))
						: (OB Instance of:C1731($target[$attribute]; cs:C1710[This:C1470.startDataclass+"Selection"]))
						: (This:C1470.current_pathParts.indexOf($attribute)#-1)
						: (This:C1470.current_pathDataclassParts.indexOf(This:C1470._getDataclassName($target[$attribute]))#-1)
						Else 
							This:C1470.current_pathParts.push($attribute)
							This:C1470.current_pathDataclassParts.push(This:C1470._getDataclassName($target[$attribute]))
							$link:=New object:C1471
							$link.type:="relatedEntities"
							$link.link:=This:C1470.current_pathParts.join(".")
							$link.nbRecords:=($target[$attribute]#Null:C1517) ? $target[$attribute].length : 0
							$link.depth:=This:C1470.current_pathParts.length
							If ($link.nbRecords#0)
								Form:C1466.lb_links.push($link)
								This:C1470.loadLinks($target[$attribute])
							End if 
							$last:=This:C1470.current_pathParts.pop()
							$last:=This:C1470.current_pathDataclassParts.pop()
					End case 
			End case 
		End for each 
	End if 
	
	This:C1470.current_pathParts:=$previousPathParts
	
	
Function _getDataclassName($target : Variant)->$dataclassName : Text
	$dataclass:=OB Class:C1730($target)
	Case of 
		: ($dataclass.name="@Entity")
			$dataclassName:=Substring:C12($dataclass.name; 1; Length:C16($dataclass.name)-6)
		: ($dataclass.name="@Selection")
			$dataclassName:=Substring:C12($dataclass.name; 1; Length:C16($dataclass.name)-9)
		Else 
			$dataclassName:=$dataclass.name
	End case 
	
	