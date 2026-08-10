//%attributes = {}
// Ensures binning and data-table CRS lines are wired on the Lot Traveller template (idempotent).

var $binningHeaderLine : cs:C1710.dfd_LineEntity
var $binningRowLine : cs:C1710.dfd_LineEntity
var $colCount : Integer
var $dtHeaderLine : cs:C1710.dfd_LineEntity
var $dtRowLine : cs:C1710.dfd_LineEntity
var $hasSubCol : Boolean
var $headerKey : Text
var $insertAt : Integer
var $indices : Collection
var $lineEntry : Object
var $lineIdx : Integer
var $lineRef : Object
var $message : Text
var $okCount : Integer
var $prevSpec : Object
var $prevWireIdx : Integer
var $res : Object
var $rowsKey : Text
var $stepLine : cs:C1710.dfd_LineEntity
var $subCol : Text
var $template : cs:C1710.dfd_TemplateEntity
var $templateLines : Collection
var $templateName : Text
var $wireIdx : Integer
var $wireOrder : Collection
var $wireSpec : Object

$templateName:="Lot Traveller"
$okCount:=0

$stepLine:=ds:C1482.dfd_Line.query("name = :1"; "LT - Step").first()
If ($stepLine=Null:C1517)
	ALERT:C41("LT - Step line not found.")
	return 
End if 

$template:=ds:C1482.dfd_Template.query("name = :1"; $templateName).first()
If ($template=Null:C1517)
	ALERT:C41("Template not found: "+$templateName)
	return 
End if 

If ($template.hierarchy=Null:C1517)
	$template.hierarchy:=New object:C1471("lines"; New collection:C1472())
End if 
If ($template.hierarchy.lines=Null:C1517)
	$template.hierarchy.lines:=New collection:C1472()
End if 

$templateLines:=$template.hierarchy.lines

$wireOrder:=New collection:C1472()

$binningHeaderLine:=ds:C1482.dfd_Line.query("name = :1"; "LT - Binning Header").first()
$binningRowLine:=ds:C1482.dfd_Line.query("name = :1"; "LT - Binning").first()
If ($binningHeaderLine#Null:C1517)
	$wireOrder.push(New object:C1471("line"; $binningHeaderLine; "subCol"; "binningH"))
End if 
If ($binningRowLine#Null:C1517)
	$wireOrder.push(New object:C1471("line"; $binningRowLine; "subCol"; "bins"))
End if 

For ($colCount; 1; 6)
	$headerKey:="dt"+String:C10($colCount)+"colH"
	$rowsKey:="dt"+String:C10($colCount)+"col"
	$dtHeaderLine:=ds:C1482.dfd_Line.query("name = :1"; "LT - DT"+String:C10($colCount)+"Col Header").first()
	$dtRowLine:=ds:C1482.dfd_Line.query("name = :1"; "LT - DT"+String:C10($colCount)+"Col").first()
	If ($dtHeaderLine#Null:C1517)
		$wireOrder.push(New object:C1471("line"; $dtHeaderLine; "subCol"; $headerKey))
	End if 
	If ($dtRowLine#Null:C1517)
		$wireOrder.push(New object:C1471("line"; $dtRowLine; "subCol"; $rowsKey))
	End if 
End for 

For ($wireIdx; 0; $wireOrder.length-1)
	$wireSpec:=$wireOrder[$wireIdx]
	$hasSubCol:=False:C215
	For each ($lineEntry; $templateLines)
		If ($lineEntry.typology="CRS") && (String:C10($lineEntry.UUID_entity)=String:C10($wireSpec.line.UUID))
			$subCol:=""
			If ($lineEntry.properties#Null:C1517)
				$indices:=$lineEntry.properties.indices("kind = :1"; "subcollectionSource")
				If ($indices.length>0)
					$subCol:=String:C10($lineEntry.properties[$indices[0]].value)
				End if 
			End if 
			If ($subCol=String:C10($wireSpec.subCol))
				$hasSubCol:=True:C214
				break
			End if 
		End if 
	End for each 
	
	If (Not:C34($hasSubCol))
		$insertAt:=Planning_travLTStepsBlockEnd($templateLines; String:C10($stepLine.UUID); "")
		If ($insertAt=-1)
			ALERT:C41("LT - Step CR not found in template hierarchy.")
			return 
		End if 
		
		For ($prevWireIdx; $wireIdx-1; 0; -1)
			$prevSpec:=$wireOrder[$prevWireIdx]
			For ($lineIdx; 0; $templateLines.length-1)
				$lineEntry:=$templateLines[$lineIdx]
				If ($lineEntry.typology="CRS") && (String:C10($lineEntry.UUID_entity)=String:C10($prevSpec.line.UUID))
					$subCol:=""
					If ($lineEntry.properties#Null:C1517)
						$indices:=$lineEntry.properties.indices("kind = :1"; "subcollectionSource")
						If ($indices.length>0)
							$subCol:=String:C10($lineEntry.properties[$indices[0]].value)
						End if 
					End if 
					If ($subCol=String:C10($prevSpec.subCol))
						$insertAt:=$lineIdx+1
						break
					End if 
				End if 
			End for 
			If ($insertAt#Planning_travLTStepsBlockEnd($templateLines; String:C10($stepLine.UUID); ""))
				break
			End if 
		End for 
		
		$lineRef:=New object:C1471(\
"kind"; "template_line"; \
"UUID_entity"; $wireSpec.line.UUID; \
"typology"; "CRS"; \
"properties"; New collection:C1472(\
New object:C1471("name"; "source collection"; "kind"; "collectionSource"; "value"; "steps"); \
New object:C1471("name"; "sub collection"; "kind"; "subcollectionSource"; "value"; $wireSpec.subCol); \
New object:C1471("name"; "groupWithMain"; "kind"; "groupWithMain"; "value"; "true")\
)\
)
		
		$templateLines.insert($insertAt; $lineRef)
		$okCount:=$okCount+1
	End if 
End for 

$template.hierarchy.lines:=$templateLines
$res:=$template.save()
If ($res.success)
	$okCount:=$okCount+1
End if 

Planning_seedLTTravFix

$message:=String:C10($okCount)+" Lot Traveller CRS wiring update(s) applied."
$message:=$message+"\rBinning and data-table sublines should render again after each step."
ALERT:C41($message)
