//%attributes = {}

var $doc : cs:C1710.dfd_DocumentEntity
var $docsCreated : Integer
var $input : Variant
var $items : Collection
var $item : Variant
var $lot : cs:C1710.LotEntity
var $lotDataClass : 4D:C1709.DataClass
var $lotNumber : Text
var $lots : cs:C1710.LotSelection
var $opts : Object
var $pdfFolder : 4D:C1709.Folder
var $rows : Collection
var $row : Object
var $sampleTemplateName : Text
var $steps : cs:C1710.LotStepSelection
var $step : cs:C1710.LotStepEntity
var $template : cs:C1710.dfd_TemplateEntity
var $unknown : Integer
var $valueType : Integer
var $warnings : Collection
var $saveInfo : Object
var $safeLotId : Text
var $pdfName : Text
var $invalidChars : Collection
var $invalidChar : Text

$sampleTemplateName:="ZZ Sample Lot Traveler Template"
$docsCreated:=0
$unknown:=0
$warnings:=New collection:C1472()

$lotDataClass:=ds:C1482.Lot
$template:=ds:C1482.dfd_Template.query("name = :1"; $sampleTemplateName).first()

If ($template=Null:C1517)
	ALERT:C41("Template not found: "+$sampleTemplateName+".\rRun __seed_dfd_lotTraveler_sample first.")
Else 
	If (Count parameters:C259=0)
		$lotNumber:=""
		Request:C163("Enter Lot Number:"; $lotNumber)
		If ($lotNumber#"")
			$items:=New collection:C1472($lotNumber)
		Else 
			$items:=New collection:C1472()
		End if 
	Else 
		$input:=${1}
		$valueType:=Value type:C1509($input)
		Case of 
			: ($valueType=Is collection:K8:32)
				$items:=$input
			: ($valueType=Is text:K8:3)
				$items:=New collection:C1472($input)
			Else 
				$items:=New collection:C1472($input)
		End case 
	End if 
	
	If ($items.length=0)
		ALERT:C41("No lot provided.")
	Else 
		$pdfFolder:=Folder:C1567(fk desktop folder:K87:19)
		
		For each ($item; $items)
			$lot:=Null:C1517
			
			$valueType:=Value type:C1509($item)
			Case of 
				: ($valueType=Is object:K8:27)
					// Accept a Lot entity directly
					If (OB Class:C1730($item).name="LotEntity")
						$lot:=$item
					End if 
				: ($valueType=Is text:K8:3)
					// Try UUID first, then lotNumber
					$lot:=$lotDataClass.get(String:C10($item))
					If ($lot=Null:C1517)
						$lot:=$lotDataClass.query("lotNumber = :1"; String:C10($item)).first()
					End if 
				: ($valueType=Is longint:K8:6)
					$lot:=$lotDataClass.query("number = :1"; Num:C11($item)).first()
			End case 
			
			If ($lot=Null:C1517)
				$unknown:=$unknown+1
			Else 
				$steps:=ds:C1482.LotStep.query("UUID_Lot = :1"; $lot.UUID).orderBy("order asc")
				$rows:=New collection:C1472()
				
				For each ($step; $steps)
					$row:=New object:C1471(\
						"partNumber"; String:C10($lot.device); \
						"lotNumber"; String:C10($lot.lotNumber); \
						"waferNumber"; String:C10($step.order); \
						"quantity"; String:C10($step.qtyOut); \
						"comments"; String:C10($step.description)\
						)
					$rows.push($row)
				End for each 
				
				If ($rows.length=0)
					$rows.push(New object:C1471(\
						"partNumber"; String:C10($lot.device); \
						"lotNumber"; String:C10($lot.lotNumber); \
						"waferNumber"; ""; \
						"quantity"; ""; \
						"comments"; "No LotStep records"\
						))
					$warnings.push("Lot "+String:C10($lot.lotNumber)+" has no LotStep records.")
				End if 
				
				$safeLotId:=String:C10($lot.lotNumber)
				If ($safeLotId="")
					$safeLotId:=String:C10($lot.number)
				End if 
				If ($safeLotId="")
					$safeLotId:=String:C10($lot.UUID)
				End if 
				
				$invalidChars:=New collection:C1472("\\"; "/"; ":"; "*"; "?"; "\""; "<"; ">"; "|")
				For each ($invalidChar; $invalidChars)
					$safeLotId:=Replace string:C233($safeLotId; $invalidChar; "-")
				End for each 
				
				$safeLotId:=Replace string:C233($safeLotId; Char:C90(13); " ")
				$safeLotId:=Replace string:C233($safeLotId; Char:C90(10); " ")
				$safeLotId:=Replace string:C233($safeLotId; Char:C90(9); " ")
				If ($safeLotId="")
					$safeLotId:="unknown"
				End if 
				
				$pdfName:="LotTraveler_"+$safeLotId+".pdf"
				
				$opts:=New object:C1471(\
					"pdfPath"; $pdfFolder.platformPath; \
					"pdfDocumentName"; $pdfName; \
					"printPreview"; False:C215\
					)
				
				$doc:=ds:C1482.dfd_Document.buildFromTemplate(\
					"Lot Traveler "+String:C10($lot.lotNumber); \
					$template; \
					New object:C1471(\
					"customer"; String:C10($lot.customer); \
					"lotTravelerNo"; String:C10($lot.number); \
					"dateIn"; String:C10($lot.dateIn); \
					"expectedOut"; String:C10($lot.commit); \
					"processText"; String:C10($lot.process); \
					"specText"; String:C10($lot.device); \
					"originalCount"; String:C10($lot.original); \
					"rows"; $rows\
					); \
					"save;pdf"; \
					$opts\
					)
				
				If ($doc#Null:C1517)
					// Ensure the generated document is fully linked in DFD panel
					$doc.UUID_dfd_Template:=$template.UUID
					$doc.UUID_target:=$lot.UUID
					$saveInfo:=$doc.save()
					If (Not:C34($saveInfo.success))
						$warnings.push("Lot "+String:C10($lot.lotNumber)+": document saved without full links ("+$saveInfo.statusText+").")
					End if 
					
					$docsCreated:=$docsCreated+1
				End if 
			End if 
		End for each 
		
		$message:=String:C10($docsCreated)+" document(s) generated."
		If ($unknown>0)
			$message:=$message+"\r"+String:C10($unknown)+" input item(s) not found."
		End if 
		If ($warnings.length>0)
			$message:=$message+"\r"+$warnings.join("\r")
		End if 
		
		ALERT:C41($message)
	End if 
End if 
