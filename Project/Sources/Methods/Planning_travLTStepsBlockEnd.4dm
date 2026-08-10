//%attributes = {}
// Returns the template hierarchy index AFTER the last steps child line (CRS/RP grouped under LT - Step CR).
#DECLARE($templateLines : Collection; $stepLineUUID : Text; $footerLineUUID : Text)->$blockEnd : Integer

var $groupWithMain : Boolean
var $i : Integer
var $isInBlock : Boolean
var $lineEntry : Object
var $sourceCol : Text
var $subCol : Text
var $tag : Object

$blockEnd:=-1

For ($i; 0; $templateLines.length-1)
	If ($templateLines[$i].typology="CR") && (String:C10($templateLines[$i].UUID_entity)=$stepLineUUID)
		$blockEnd:=$i+1
		break
	End if 
End for 

If ($blockEnd=-1)
	return -1
End if 

For ($i; $blockEnd; $templateLines.length-1)
	$lineEntry:=$templateLines[$i]
	$isInBlock:=False:C215
	$sourceCol:=""
	$subCol:=""
	$groupWithMain:=False:C215
	
	If ($lineEntry.properties#Null:C1517)
		For each ($tag; $lineEntry.properties)
			Case of 
				: ($tag.kind="collectionSource")
					$sourceCol:=String:C10($tag.value)
				: ($tag.kind="subcollectionSource")
					$subCol:=String:C10($tag.value)
				: ($tag.kind="groupWithMain") && (String:C10($tag.value)="true")
					$groupWithMain:=True:C214
			End case 
		End for each 
	End if 
	
	Case of 
		: ($lineEntry.typology="CRS")
			If ($sourceCol="steps") || ($groupWithMain) || ($subCol#"")
				$isInBlock:=True:C214
			End if 
		: ($lineEntry.typology="RP")
			If ($footerLineUUID#"") && (String:C10($lineEntry.UUID_entity)=$footerLineUUID) && ($sourceCol="steps")
				$isInBlock:=True:C214
			End if 
	End case 
	
	If ($isInBlock)
		$blockEnd:=$i+1
	Else 
		break
	End if 
End for 

return $blockEnd
