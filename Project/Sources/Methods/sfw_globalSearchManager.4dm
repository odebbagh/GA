//%attributes = {}
#DECLARE($action : Text; $param2 : Text; $vision : Object; $entries : Collection)

var $entry : cs:C1710.sfw_definitionEntry

Case of 
	: ($action="search")
		If (Count parameters:C259>1)
			Form:C1466.sfw.searchbox:=$param2
		End if 
		If (Count parameters:C259>2)
			Form:C1466.vision:=$vision
		End if 
		If (Count parameters:C259>3)
			Form:C1466.entries:=$entries
		End if 
		Form:C1466.lb_results:=New collection:C1472
		If (Form:C1466.limit=Null:C1517)
			Form:C1466.limit:=New object:C1471
		End if 
		
		$metaEntry:=New object:C1471("fill"; "navy"; "stroke"; "white"; "fontWeight"; "bold")
		$metaMore:=New object:C1471("fill"; "#cacaca"; "stroke"; "grey"; "fontWeight"; "normal")
		For each ($entry; Form:C1466.entries)
			
			Case of 
				: ($entry.isDisplayable()=False:C215)
				: ($entry.searchbox#Null:C1517) && ($entry.searchfields#Null:C1517) && ($entry.searchfields.length>0)
					Form:C1466.sfw.entry:=$entry
					Form:C1466.sfw.searchForEntry()
					$dataclass:=$entry.dataclass
					If (Form:C1466.sfw.lb_items#Null:C1517)
						If (Form:C1466.sfw.lb_items.length>0)
							$line:=New object:C1471
							$line.kind:="entry"
							$line.text:=ds:C1482.sfw_readXliff($entry.xliff; $entry.label)
							$line.meta:=$metaEntry
							Form:C1466.lb_results.push($line)
						End if 
						If (Form:C1466.limit[$dataclass]=Null:C1517)
							Form:C1466.limit[$dataclass]:=New object:C1471("max"; 10)
						End if 
						For each ($item; Form:C1466.sfw.lb_items.slice(0; Num:C11(Form:C1466.limit[$dataclass].max)))
							$line:=New object:C1471
							$line.kind:="entity"
							$line.dataclass:=$entry.dataclass
							$line.entity:=$item
							Case of 
								: ($item.displayAsSearchResult#Null:C1517)
									$value:=$item.displayAsSearchResult()
								: ($item.getFullName#Null:C1517)
									$value:=$item.getFullName()
								: ($item.nameForGlobalSearch#Null:C1517)
									$value:=$item.nameForGlobalSearch
								: ($item.fullName#Null:C1517)
									$value:=$item.fullName
								: ($item.name#Null:C1517)
									$value:=$item.name
								: ($item.lastName#Null:C1517)
									$value:=$item.lastName
								Else 
									$value:="---"
							End case 
							$line.text:=$value
							Form:C1466.lb_results.push($line)
						End for each 
						If (Form:C1466.sfw.lb_items.length>Num:C11(Form:C1466.limit[$dataclass].max))
							$line:=New object:C1471
							$line.kind:="more"
							$line.dataclass:=$entry.dataclass
							$line.text:="+"+(String:C10(Num:C11(Form:C1466.sfw.lb_items.length-Num:C11(Form:C1466.limit[$dataclass].max))))+" items"
							$line.meta:=$metaMore
							Form:C1466.lb_results.push($line)
						End if 
					End if 
					
				: ($entry.searchbox#Null:C1517) && ((($entry.searchbox.fields#Null:C1517) && ($entry.searchbox.fields.length>0)) || (($entry.searchbox.specificSearches#Null:C1517) && ($entry.searchbox.specificSearches.length>0)))
					Form:C1466.sfw.entry:=$entry
					Form:C1466.sfw.searchForEntry()
					$dataclass:=$entry.dataclass
					If (Form:C1466.sfw.lb_items#Null:C1517)
						If (Form:C1466.sfw.lb_items.length>0)
							$line:=New object:C1471
							$line.kind:="entry"
							$line.text:=ds:C1482.sfw_readXliff($entry.xliff; $entry.label)
							$line.meta:=$metaEntry
							Form:C1466.lb_results.push($line)
						End if 
						
						If (Form:C1466.limit[$dataclass]=Null:C1517)
							Form:C1466.limit[$dataclass]:=New object:C1471("max"; 10)
						End if 
						For each ($item; Form:C1466.sfw.lb_items.slice(0; Num:C11(Form:C1466.limit[$dataclass].max)))
							$line:=New object:C1471
							$line.kind:="entity"
							$line.dataclass:=$entry.dataclass
							$line.entity:=$item
							Case of 
								: ($item.displayAsSearchResult#Null:C1517)
									$value:=$item.displayAsSearchResult()
								: ($item.getFullName#Null:C1517)
									$value:=$item.getFullName()
								: ($item.nameForGlobalSearch#Null:C1517)
									$value:=$item.nameForGlobalSearch
								: ($item.fullName#Null:C1517)
									$value:=$item.fullName
								: ($item.name#Null:C1517)
									$value:=$item.name
								: ($item.lastName#Null:C1517)
									$value:=$item.lastName
								Else 
									$value:="---"
							End case 
							$line.text:=$value
							Form:C1466.lb_results.push($line)
						End for each 
						If (Form:C1466.sfw.lb_items.length>Num:C11(Form:C1466.limit[$dataclass].max))
							$line:=New object:C1471
							$line.kind:="more"
							$line.dataclass:=$entry.dataclass
							$line.text:="+"+(String:C10(Num:C11(Form:C1466.sfw.lb_items.length-Num:C11(Form:C1466.limit[$dataclass].max))))+" items"
							$line.meta:=$metaMore
							Form:C1466.lb_results.push($line)
						End if 
					End if 
			End case 
		End for each 
		
		If (Form:C1466.lb_results.length=0)
			Form:C1466.lb_results.push({kind: "entry"; text: "No results"; meta: {fill: "red"; stroke: "white"}})
		End if 
		Form:C1466.lb_results:=Form:C1466.lb_results
		
		If (Count parameters:C259>1)
			If (Frontmost window:C447#Current form window:C827)
				HIDE WINDOW:C436(Current form window:C827)
				$refWindow:=Num:C11(Storage:C1525.windows.globalSearch)
				CALL FORM:C1391($refWindow; "sfw_globalSearchManager"; "showWindow")
			End if 
		End if 
		
	: ($action="close")
		CANCEL:C270
		
	: ($action="showWindow")
		SHOW WINDOW:C435(Current form window:C827)
		BRING TO FRONT:C326(Current process:C322)
		
End case 