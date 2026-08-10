//%attributes = {}

/*
Method Name : _ga_exportEquipmentList
Author : Medard /4D PS
Date : 23-June-2025
Purpose : This method export the items on CIP View List to an .xls document
*/

/*
var $eSetting : cs.sfw_SettingEntity
var $identEntry : Text:=Form.sfw.entry.ident
var $entity : 4D.Entity
var $info : Object
var $wpBlob : 4D.Blob
var $wpEncodedBlob : Text
var $cips : cs.ContinuousImprovementSelection
var $OK : Boolean
var $headers : Collection
var $header; $separator_col; $separator_line : Text


$headers:=New collection()
$separator_col:=Char(Tab)
$separator_line:=Char(Carriage return)


$file:=Create document(""; "xls")

If (OK=1)
$export:=New object
$export.records:=New collection

$dataclass:=Form.sfw.entry.dataclass

$cips:=Form.sfw.lb_items

For each ($entity; $cips)
$oEntity:=New object
For each ($attribute; ds[$dataclass])
If (ds[$dataclass][$attribute].fieldType=Is object) && ($entity[$attribute]#Null) && (String($entity[$attribute].title)="4D Write Pro New Document")
WP EXPORT VARIABLE($entity[$attribute]; $wpBlob; wk 4wp)
BASE64 ENCODE($wpBlob; $wpEncodedBlob)
$oEntity[$attribute]:=$wpEncodedBlob
Else 
$oEntity[$attribute]:=$entity[$attribute]
End if 

End for each 
$export.records.push($oEntity)

End for each 

$cip_es:=$export.records

If ($cip_es.length>0)
OB GET PROPERTY NAMES($cip_es[0]; $headerNames; $arrTypes)
ARRAY TO COLLECTION($headers; $headerNames)

$headers.remove($headers.indexOf("UUID"))
$headers.remove($headers.indexOf("moreData"))
$headers:=$headers.filter(Formula($1.value#"stmp@"))
$headers:=$headers.filter(Formula($1.value#"UUID_@"))

$OK:=True
Else 
$OK:=False
End if 
For ($i; 0; $headers.length-1)

SEND PACKET($file; _capitalize_text($headers[$i])+$separator_col)

End for 

SEND PACKET($file; $separator_line)

If ($OK)

For each ($cip_e; $cip_es)

For each ($headerName; $headers)

Case of 
: ($headerName="UUID")

: ($headerName="priority")

SEND PACKET($file; Replace string(Replace string(Replace string(String($cip_e.priority.name); Char(Carriage return); Char(Space); *); Char(Line feed); Char(Space)); Char(Tab); Char(Space))+$separator_col)

: ($headerName="origin")

SEND PACKET($file; Replace string(Replace string(Replace string(String($cip_e.origin.name); Char(Carriage return); Char(Space); *); Char(Line feed); Char(Space)); Char(Tab); Char(Space))+$separator_col)

: ($headerName="humanFactor")

SEND PACKET($file; Replace string(Replace string(Replace string(String($cip_e.humanFactor.name); Char(Carriage return); Char(Space); *); Char(Line feed); Char(Space)); Char(Tab); Char(Space))+$separator_col)

: ($headerName="disposition")
If ($cip_e.moreData.disposition#"")
SEND PACKET($file; Replace string(Replace string(Replace string(String($cip_e.moreData.disposition); Char(Carriage return); Char(Space); *); Char(Line feed); Char(Space)); Char(Tab); Char(Space))+$separator_col)

Else 

SEND PACKET($file; Replace string(Replace string(Replace string(String($cip_e.disposition.name); Char(Carriage return); Char(Space); *); Char(Line feed); Char(Space)); Char(Tab); Char(Space))+$separator_col)
End if 

: ($headerName="category")

SEND PACKET($file; Replace string(Replace string(Replace string(String($cip_e.category.name); Char(Carriage return); Char(Space); *); Char(Line feed); Char(Space)); Char(Tab); Char(Space))+$separator_col)

: ($headerName="yesNoQuestion")

SEND PACKET($file; Replace string(Replace string(Replace string(String($cip_e.yesNoQuestion.name); Char(Carriage return); Char(Space); *); Char(Line feed); Char(Space)); Char(Tab); Char(Space))+$separator_col)


Else 
SEND PACKET($file; Replace string(Replace string(Replace string(String($cip_e[$headerName]); Char(Carriage return); Char(Space); *); Char(Line feed); Char(Space)); Char(Tab); Char(Space))+$separator_col)


End case 

End for each 

SEND PACKET($file; $separator_line)

End for each 

CLOSE DOCUMENT($file)

cs.sfw_dialog.me.info(ds.sfw_readXliff("export.done"; "The export is done"))

SET ENVIRONMENT VARIABLE("_4D_OPTION_BLOCKING_EXTERNAL_PROCESS"; "false")
SET ENVIRONMENT VARIABLE("_4D_OPTION_HIDE_CONSOLE"; "true")

LAUNCH EXTERNAL PROCESS("cmd.exe /C  start \"\" \""+document+"\"")

Else 

cs.sfw_dialog.me.alert(ds.sfw_readXliff("No items in the list to print"))

End if 

End if 
*/


var $fields : Collection
var $mapping : Collection:=New collection:C1472()

If (Form:C1466.sfw.lb_items.length>0)
	
	$fileName:=Form:C1466.sfw.view.label
	
	$templateFile:=Folder:C1567(fk resources folder:K87:11).file("excelTemplates/excelExportTemplate.xlsx")
	
	$mapping:=New collection:C1472(\
		New object:C1471("header"; "#"; "field"; "item"; "footerOperation"; ""); \
		New object:C1471("header"; "InterestedParty"; "field"; "interestedParty"; "footerOperation"; ""); \
		New object:C1471("header"; "Procedure Type"; "field"; "procedureType"; "footerOperation"; ""); \
		New object:C1471("header"; "Action"; "field"; "action"; "footerOperation"; ""); \
		New object:C1471("header"; "Requirement"; "field"; "requirement"; "footerOperation"; ""); \
		New object:C1471("header"; "Responsable"; "field"; "responsible"; "footerOperation"; ""); \
		New object:C1471("header"; "Notes"; "field"; "notes"; "footerOperation"; ""); \
		New object:C1471("header"; "ExternalID"; "field"; "externalID"; "footerOperation"; ""); \
		New object:C1471("header"; "Title"; "field"; "title"; "footerOperation"; ""); \
		New object:C1471("header"; "Priority"; "field"; "priority.name"; "footerOperation"; ""); \
		New object:C1471("header"; "Category"; "field"; "category.name"; "footerOperation"; ""); \
		New object:C1471("header"; "Origin"; "field"; "origin.name"; "footerOperation"; ""); \
		New object:C1471("header"; "Disposition"; "field"; "eDisposition"; "footerOperation"; ""); \
		New object:C1471("header"; "Human Factor"; "field"; "humanFactor.name"; "footerOperation"; ""); \
		New object:C1471("header"; "Current Due Date"; "field"; "currentDueDate"; "footerOperation"; ""); \
		New object:C1471("header"; "Date closed"; "field"; "dateClosed"; "footerOperation"; ""); \
		New object:C1471("header"; "Original Due date"; "field"; "originalDueDate"; "footerOperation"; ""); \
		New object:C1471("header"; "Date initiated"; "field"; "dateInitiated"; "footerOperation"; "")\
		)
	
	If ($fileName="main") | ($fileName="Main view")
		$title:="All CIPs"
		$fileName:="AllCIPs"
	Else 
		$title:=$fileName
		$fileName:=Replace string:C233($fileName; " "; "")
	End if 
	
	$destinationFolderPath:=Get 4D folder:C485(Current resources folder:K5:16)+"exportedData"+Folder separator:K24:12+"CIPs"
	
	$destinationFileName:=Split string:C1554(String:C10($fileName+"_"+Replace string:C233(String:C10(Date:C102(Timestamp:C1445)); "/"; "_")); " "; sk ignore empty strings:K86:1+sk trim spaces:K86:2).join("")
	$sheetName:=$fileName
	$selection:=Form:C1466.sfw.lb_items
	$offscreen:=cs:C1710.ExcelDataExporter.new($templateFile.platformPath; $mapping; $selection; $destinationFileName; $destinationFolderPath; $title; $sheetName; True:C214)
	$excelSheet:=VP Run offscreen area($offscreen)
	
	
Else 
	
	cs:C1710.sfw_dialog.me.alert(ds:C1482.sfw_readXliff("No items in the list to Export"))
	
End if 
