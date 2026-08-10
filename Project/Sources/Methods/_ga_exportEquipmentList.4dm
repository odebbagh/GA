//%attributes = {}

/*
Method Name : _ga_exportEquipmentList
Author : Medard /4D PS
Date : 03-June-2025
Purpose : This method export the items on Equipment View List to an .xls document
*/

/*
var $eSetting : cs.sfw_SettingEntity
var $identEntry : Text:=Form.sfw.entry.ident
var $entity : 4D.Entity
var $info : Object
var $wpBlob : 4D.Blob
var $wpEncodedBlob : Text
var $equipments : cs.EquipmentSelection
var $OK; $allFields; $continue : Boolean
var $headers; $relevantFields : Collection
var $header; $separator_col; $separator_line : Text

$continue:=True
$allFields:=False

MOUSE POSITION($vlMouseX; $vlMouseY; $vlButton)

$vtItems:="Export relevant fields; (-; Export all fields"
$vlUserChoice:=Pop up menu($vtItems)
Case of 
: ($vlUserChoice=1)
$allFields:=False

: ($vlUserChoice=3)
$allFields:=True

Else 
$continue:=False

End case 

If ($continue)
$headers:=New collection()
$relevantFields:=New collection("division"; "assignedID"; "model"; "description"; "type"; "nextCalDate"; \
"nextPMDate"; "calTech"; "pmTech"; "location")
$separator_col:=Char(Tab)
$separator_line:=Char(Carriage return)


$file:=Create document(""; "xls")

If (OK=1)
$export:=New object
$export.records:=New collection

$dataclass:=Form.sfw.entry.dataclass

$equipments:=Form.sfw.lb_items

For each ($entity; $equipments)
$oEntity:=New object
For each ($attribute; ds[$dataclass])
If (ds[$dataclass][$attribute].fieldType=Is object) && ($entity[$attribute]#Null) && \
(String($entity[$attribute].title)="4D Write Pro New Document")
WP EXPORT VARIABLE($entity[$attribute]; $wpBlob; wk 4wp)
BASE64 ENCODE($wpBlob; $wpEncodedBlob)
$oEntity[$attribute]:=$wpEncodedBlob
Else 
$oEntity[$attribute]:=$entity[$attribute]
End if 

End for each 
$export.records.push($oEntity)

End for each 

$equipment_es:=$export.records

If ($equipment_es.length>0)
OB GET PROPERTY NAMES($equipment_es[0]; $headerNames; $arrTypes)
ARRAY TO COLLECTION($headers; $headerNames)

$headers:=$headers.remove($headers.indexOf("repairLogs"))
$headers:=$headers.remove($headers.indexOf("reports"))

$headers:=$headers.remove($headers.indexOf("UUID"))
$headers:=$headers.filter(Formula($1.value#"stmp@"))
$headers:=$headers.filter(Formula($1.value#"UUID_@"))

If (Not($allFields))
$headers:=$relevantFields
End if 
$OK:=True
Else 
$OK:=False
End if 
For ($i; 0; $headers.length-1)

SEND PACKET($file; $headers[$i]+$separator_col)

End for 

SEND PACKET($file; $separator_line)

If ($OK)

For each ($equipment_e; $equipment_es)

For each ($headerName; $headers)

Case of 

: ($headerName="location")
SEND PACKET($file; Replace string(String($equipment_e.location.name); Char(Carriage return); Char(Space))+\
separator_col)
: ($headerName="type")
SEND PACKET($file; Replace string(String($equipment_e.type.name); Char(Carriage return); Char(Space))+\
$separator_col)

: ($headerName="division")
SEND PACKET($file; Replace string(String($equipment_e.division.name); Char(Carriage return); Char(Space))+\
$separator_col)

: ($headerName="reports")


Else 
SEND PACKET($file; Replace string(String($equipment_e[$headerName]); Char(Carriage return); Char(Space))+\
$separator_col)

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

End if 

*/



var $OK; $allFields; $continue : Boolean
var $fields : Collection
var $mapping : Collection:=New collection:C1472()

If (Form:C1466.sfw.lb_items.length>0)
	
	$fileName:=Form:C1466.sfw.view.label
	
	$templateFile:=Folder:C1567(fk resources folder:K87:11).file("excelTemplates/excelExportTemplate.xlsx")
	
	
	$continue:=True:C214
	$allFields:=False:C215
	
	MOUSE POSITION:C468($vlMouseX; $vlMouseY; $vlButton)
	
	$vtItems:="Export relevant fields; (-; Export all fields"
	$vlUserChoice:=Pop up menu:C542($vtItems)
	Case of 
		: ($vlUserChoice=1)
			$allFields:=False:C215
			
		: ($vlUserChoice=3)
			$allFields:=True:C214
			
		Else 
			$continue:=False:C215
			
	End case 
	
	If ($continue)
		If (Not:C34($allFields))
			
			$mapping:=New collection:C1472(\
				New object:C1471("header"; "Division"; "field"; "division.name"; "footerOperation"; ""); \
				New object:C1471("header"; "assigned ID"; "field"; "assignedID"; "footerOperation"; ""); \
				New object:C1471("header"; "Model"; "field"; "model"; "footerOperation"; ""); \
				New object:C1471("header"; "Description"; "field"; "desription"; "footerOperation"; ""); \
				New object:C1471("header"; "Type"; "field"; "type.name"; "footerOperation"; ""); \
				New object:C1471("header"; "Next Cal Date"; "field"; "nextCalDate"; "footerOperation"; ""); \
				New object:C1471("header"; "Next PM Date"; "field"; "nextPMDate"; "footerOperation"; ""); \
				New object:C1471("header"; "Cal Tech"; "field"; "calTech"; "footerOperation"; ""); \
				New object:C1471("header"; "PM Tech"; "field"; "pmTech"; "footerOperation"; ""); \
				New object:C1471("header"; "Location"; "field"; "location.name"; "footerOperation"; "")\
				)
			
		Else 
			
			$mapping:=New collection:C1472(\
				New object:C1471("header"; "Division"; "field"; "division.name"; "footerOperation"; ""); \
				New object:C1471("header"; "assigned ID"; "field"; "assignedID"; "footerOperation"; ""); \
				New object:C1471("header"; "Model"; "field"; "model"; "footerOperation"; ""); \
				New object:C1471("header"; "Description"; "field"; "desription"; "footerOperation"; ""); \
				New object:C1471("header"; "Type"; "field"; "type.name"; "footerOperation"; ""); \
				New object:C1471("header"; "Next Cal Date"; "field"; "nextCalDate"; "footerOperation"; ""); \
				New object:C1471("header"; "Next PM Date"; "field"; "nextPMDate"; "footerOperation"; ""); \
				New object:C1471("header"; "Cal Tech"; "field"; "calTech"; "footerOperation"; ""); \
				New object:C1471("header"; "PM Tech"; "field"; "pmTech"; "footerOperation"; ""); \
				New object:C1471("header"; "Location"; "field"; "location.name"; "footerOperation"; ""); \
				New object:C1471("header"; "Serial #"; "field"; "serialNumber"; "footerOperation"; ""); \
				New object:C1471("header"; "Status"; "field"; "status"; "footerOperation"; ""); \
				New object:C1471("header"; "Engg"; "field"; "engg"; "footerOperation"; ""); \
				New object:C1471("header"; "Calibration not required"; "field"; "calibrationNotRequired"; "footerOperation"; ""); \
				New object:C1471("header"; "PM not required"; "field"; "pmNotRequired"; "footerOperation"; ""); \
				New object:C1471("header"; "Cal in progress"; "field"; "calInProgress"; "footerOperation"; ""); \
				New object:C1471("header"; "Manufacturer"; "field"; "manufacturer"; "footerOperation"; ""); \
				New object:C1471("header"; "Cal interval"; "field"; "calInterval"; "footerOperation"; ""); \
				New object:C1471("header"; "down"; "field"; "down"; "footerOperation"; ""); \
				New object:C1471("header"; "Cal Document"; "field"; "calDocument"; "footerOperation"; ""); \
				New object:C1471("header"; "PM Document"; "field"; "pmDocument"; "footerOperation"; ""); \
				New object:C1471("header"; "Decomissioned"; "field"; "decommissioned"; "footerOperation"; ""); \
				New object:C1471("header"; "Last Cal Date"; "field"; "lastCalDate"; "footerOperation"; ""); \
				New object:C1471("header"; "Last PM Date"; "field"; "lastCalDate"; "footerOperation"; ""); \
				New object:C1471("header"; "Out of calibration"; "field"; "outOfCalibration"; "footerOperation"; "")\
				)
		End if 
		
		If ($fileName="main") | ($fileName="Main view")
			$title:="All Equipments"
			$fileName:="AllEquipments"
		Else 
			$title:=$fileName
			$fileName:=Replace string:C233($fileName; " "; "")
		End if 
		
		
		$destinationFolderPath:=Get 4D folder:C485(Current resources folder:K5:16)+"exportedData"+Folder separator:K24:12+"RepairLogs"
		
		$destinationFileName:=Split string:C1554(String:C10($fileName+"_"+Replace string:C233(String:C10(Date:C102(Timestamp:C1445)); "/"; "_")); " "; sk ignore empty strings:K86:1+sk trim spaces:K86:2).join("")
		$sheetName:=$fileName
		$selection:=Form:C1466.sfw.lb_items
		$offscreen:=cs:C1710.ExcelDataExporter.new($templateFile.platformPath; $mapping; $selection; $destinationFileName; $destinationFolderPath; $title; $sheetName; True:C214)
		$excelSheet:=VP Run offscreen area($offscreen)
		
	End if 
	
	//cs.sfw_dialog.me.info(ds.sfw_readXliff("export.done"; "The export is done"))
	//OPEN URL($file.platformPath; *)
Else 
	
	cs:C1710.sfw_dialog.me.alert(ds:C1482.sfw_readXliff("No items in the list to Export"))
	
End if 






