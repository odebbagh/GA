//%attributes = {}
/*
Method Name : _ga_getListFiltersValues
Author : Medard /4D PS
Date : 20-May-2025
Purpose : This method get the values set for folters on View Lists
*/

C_TEXT:C284($1; $dataClass; $2; $field)
$dataClass:=$1
$field:=$2
var $allValues : Collection
var $value : Text
var $i : Integer

For ($i; 0; Form:C1466.filters.length-1)
	If (Form:C1466.filters[$i].linkedDataclassName=$dataClass)
		If (OB Is defined:C1231(Form:C1466.filters[$i]; "IDS"))
			
			$allValues:=Form:C1466.filters[$i].IDS
			If ($allValues.length=ds:C1482[$dataClass].all().length)
				$value:=Form:C1466.filters[$i].defaultTitle
			Else 
				
				For ($j; 0; $allValues.length-1)
					$valueName:=ds:C1482[$dataClass].query($field+"= :1"; $allValues[$j]).first().name
					If ($j=0)
						$value:=$valueName
						
					Else 
						$value:=$value+", "+$valueName
					End if 
					
				End for 
				
			End if 
			
		Else 
			
			If (OB Is defined:C1231(Form:C1466.filters[$i]; "UUIDS"))
				
				$allValues:=Form:C1466.filters[$i].UUIDS
				If ($allValues.length=ds:C1482[$dataClass].all().length)
					$value:=Form:C1466.filters[$i].defaultTitle
				Else 
					
					For ($j; 0; $allValues.length-1)
						If (Count parameters:C259>2)
							$valueName:=ds:C1482[$dataClass].query($field+" ==:1"; $allValues[$j]).first()[$3]
							
						Else 
							ds:C1482[$dataClass].query($field+" ==:1"; $allValues[$j]).first().name
						End if 
						If ($j=0)
							$value:=$valueName
							
						Else 
							$value:=$value+", "+$valueName
						End if 
						
					End for 
					
				End if 
			Else 
				
				$value:=Form:C1466.filters[$i].defaultTitle
				
			End if 
			
		End if 
		
		$i:=Form:C1466.filters.length
	End if 
	
End for 

$0:=$value

