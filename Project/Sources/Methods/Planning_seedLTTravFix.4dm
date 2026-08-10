//%attributes = {}
// Restores Lot Traveller step-block template order and footer wiring (run after layout issues).

var $binningLine : cs:C1710.dfd_LineEntity
var $blockIndices : Collection
var $blockLines : Collection
var $colCount : Integer
var $crIdx : Integer
var $dtHeaderLine : cs:C1710.dfd_LineEntity
var $dtRowLine : cs:C1710.dfd_LineEntity
var $existing : Object
var $footerLine : cs:C1710.dfd_LineEntity
var $groupWithMain : Boolean
var $headerKey : Text
var $i : Integer
var $indices : Collection
var $lineEntry : Object
var $lineRef : Object
var $message : Text
var $newBlock : Collection
var $okCount : Integer
var $orderedSpecs : Collection
var $res : Object
var $rowsKey : Text
var $sourceCol : Text
var $spec : Object
var $stepLine : cs:C1710.dfd_LineEntity
var $subCol : Text
var $tag : Object
var $template : cs:C1710.dfd_TemplateEntity
var $templateLines : Collection
var $templateName : Text
var $wireSpec : Object

$templateName:="Lot Traveller"
$okCount:=0

$stepLine:=ds:C1482.dfd_Line.query("name = :1"; "LT - Step").first()
If ($stepLine=Null:C1517)
	ALERT:C41("LT - Step line not found.")
	return 
End if 

$footerLine:=Planning_travLTStepFooterLine()
$res:=$footerLine.save()
If ($res.success)
	$okCount:=$okCount+1
End if 

$binningLine:=Planning_travLTBinningHdr()
$res:=$binningLine.save()
If ($res.success)
	$okCount:=$okCount+1
End if 

$binningLine:=Planning_travLTBinningLine()
$res:=$binningLine.save()
If ($res.success)
	$okCount:=$okCount+1
End if 

For ($colCount; 1; 6)
	$dtRowLine:=Planning_travLTDTColLine($colCount; False:C215)
	$res:=$dtRowLine.save()
	If ($res.success)
		$okCount:=$okCount+1
	End if 
	$dtHeaderLine:=Planning_travLTDTColLine($colCount; True:C214)
	$res:=$dtHeaderLine.save()
	If ($res.success)
		$okCount:=$okCount+1
	End if 
End for 

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
$crIdx:=-1
For ($i; 0; $templateLines.length-1)
	If ($templateLines[$i].typology="CR") && (String:C10($templateLines[$i].UUID_entity)=String:C10($stepLine.UUID))
		$crIdx:=$i
		break
	End if 
End for 

If ($crIdx=-1)
	ALERT:C41("LT - Step CR not found in template.")
	return 
End if 

// Collect existing steps-block CRS/RP entries keyed by subcollection or footer typology.
$blockLines:=New collection:C1472()
$blockIndices:=New collection:C1472()
$existing:=New object:C1471()
For ($i; $crIdx+1; $templateLines.length-1)
	$lineEntry:=$templateLines[$i]
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
		: ($lineEntry.typology="CRS") && (($sourceCol="steps") || ($groupWithMain) || ($subCol#""))
			$blockLines.push($lineEntry)
			$blockIndices.push($i)
			If ($subCol#"")
				$existing[$subCol]:=$lineEntry
			Else 
				If (String:C10($lineEntry.UUID_entity)=String:C10($footerLine.UUID))
					$existing["__footerCrs__"]:=$lineEntry
				End if 
			End if 
		: ($lineEntry.typology="RP") && (String:C10($lineEntry.UUID_entity)=String:C10($footerLine.UUID)) && ($sourceCol="steps")
			$blockLines.push($lineEntry)
			$blockIndices.push($i)
			$existing["__footerRp__"]:=$lineEntry
		Else 
			break
	End case 
End for 

// Remove old block lines from highest index down.
For ($i; $blockIndices.length-1; 0; -1)
	$templateLines.remove($blockIndices[$i])
End for 

// Recompute CR index after removals.
For ($i; 0; $templateLines.length-1)
	If ($templateLines[$i].typology="CR") && (String:C10($templateLines[$i].UUID_entity)=String:C10($stepLine.UUID))
		$crIdx:=$i
		break
	End if 
End for 

$orderedSpecs:=New collection:C1472()
$orderedSpecs.push(New object:C1471("kind"; "binningH"; "line"; ds:C1482.dfd_Line.query("name = :1"; "LT - Binning Header").first()))
$orderedSpecs.push(New object:C1471("kind"; "bins"; "line"; ds:C1482.dfd_Line.query("name = :1"; "LT - Binning").first()))
For ($colCount; 1; 6)
	$headerKey:="dt"+String:C10($colCount)+"colH"
	$rowsKey:="dt"+String:C10($colCount)+"col"
	$dtHeaderLine:=ds:C1482.dfd_Line.query("name = :1"; "LT - DT"+String:C10($colCount)+"Col Header").first()
	$dtRowLine:=ds:C1482.dfd_Line.query("name = :1"; "LT - DT"+String:C10($colCount)+"Col").first()
	$orderedSpecs.push(New object:C1471("kind"; $headerKey; "line"; $dtHeaderLine))
	$orderedSpecs.push(New object:C1471("kind"; $rowsKey; "line"; $dtRowLine))
End for 

$newBlock:=New collection:C1472()
For each ($wireSpec; $orderedSpecs)
	If ($wireSpec.line=Null:C1517)
		continue
	End if 
	$subCol:=String:C10($wireSpec.kind)
	If ($existing[$subCol]#Null:C1517)
		$newBlock.push($existing[$subCol])
	Else 
		$lineRef:=New object:C1471(\
"kind"; "template_line"; \
"UUID_entity"; $wireSpec.line.UUID; \
"typology"; "CRS"; \
"properties"; New collection:C1472(\
New object:C1471("name"; "source collection"; "kind"; "collectionSource"; "value"; "steps"); \
New object:C1471("name"; "sub collection"; "kind"; "subcollectionSource"; "value"; $subCol); \
New object:C1471("name"; "groupWithMain"; "kind"; "groupWithMain"; "value"; "true")\
)\
)
		$newBlock.push($lineRef)
		$okCount:=$okCount+1
	End if 
End for each 

// Footer CRS: horizontal close only, always last before page-break RP.
If ($existing["__footerCrs__"]#Null:C1517)
	$newBlock.push($existing["__footerCrs__"])
Else 
	$lineRef:=New object:C1471(\
"kind"; "template_line"; \
"UUID_entity"; $footerLine.UUID; \
"typology"; "CRS"; \
"properties"; New collection:C1472(\
New object:C1471("name"; "source collection"; "kind"; "collectionSource"; "value"; "steps"); \
New object:C1471("name"; "groupWithMain"; "kind"; "groupWithMain"; "value"; "true")\
)\
)
	$newBlock.push($lineRef)
	$okCount:=$okCount+1
End if 

If ($existing["__footerRp__"]#Null:C1517)
	$newBlock.push($existing["__footerRp__"])
Else 
	$lineRef:=New object:C1471(\
"kind"; "template_line"; \
"UUID_entity"; $footerLine.UUID; \
"typology"; "RP"; \
"properties"; New collection:C1472(\
New object:C1471("name"; "source collection"; "kind"; "collectionSource"; "value"; "steps"); \
New object:C1471("name"; "afficher en fin"; "kind"; "displayAtEnd"; "value"; "true")\
)\
)
	$newBlock.push($lineRef)
	$okCount:=$okCount+1
End if 

For ($i; $newBlock.length-1; 0; -1)
	$templateLines.insert($crIdx+1; $newBlock[$i])
End for 

$template.hierarchy.lines:=$templateLines
$res:=$template.save()
If ($res.success)
	$okCount:=$okCount+1
End if 

Planning_seedLTStepLayout

$message:=String:C10($okCount)+" Lot Traveller template fix(es) applied."
$message:=$message+"\rStep block order: Step CR -> binning -> data table -> bottom border."
$message:=$message+"\rFooter is horizontal-only; vertical lines no longer split sublines."
$message:=$message+"\rSection titles: Binning / Data Table. Footer verticals meet bottom border."
ALERT:C41($message)
