//%attributes = {}


/*
Method Name : _ga_exportAmlList
Author : Medard /4D PS
Date : 08-August-2025
Last Modification datem : 12-march-2026
Purpose : This method export the items on Spec Control View List to an .xls document
*/

/*
var $aml_es : cs.AMLSelection
var $aml_e : cs.AMLEntity
var $OK : Boolean
var $listOfHeaders : Collection
var $header; $separator_col; $separator_line : Text
var $headers : Collection:=New collection()


$headers:=New collection("Division"; "Internal Part"; "Vendor Part"; "Description"; "Comments"; "Critical?")

$separator_col:=Char(Tab)
$separator_line:=Char(Carriage return)


$file:=Create document(""; "xls")

If (OK=1)
$export:=New object
$export.records:=New collection

$dataclass:=Form.sfw.entry.dataclass


$aml_es:=Form.sfw.lb_items  //$export.records

If ($aml_es.length>0)

$OK:=True
Else 
$OK:=False
End if 
For ($i; 0; $headers.length-1)

SEND PACKET($file; _capitalize_text($headers[$i])+$separator_col)

End for 

SEND PACKET($file; $separator_line)

If ($OK)

For each ($aml_e; $aml_es)

For each ($headerName; $headers)

Case of 

: ($headerName="Division")
$data:=Replace string(Replace string(String($aml_e.division.name); Char(Carriage return); Char(Space); *); Char(Line feed); Char(Space))
SEND PACKET($file; $data+$separator_col)

: ($headerName="Internal Part")
$data:=Replace string(Replace string(String($aml_e.ourPartNum); Char(Carriage return); Char(Space); *); Char(Line feed); Char(Space))
SEND PACKET($file; $data+$separator_col)


: ($headerName="Vendor Part")
$data:=Replace string(Replace string(String($aml_e["vendorPartnum"]); Char(Carriage return); Char(Space); *); Char(Line feed); Char(Space))
SEND PACKET($file; $data+$separator_col)


: ($headerName="Description")
$data:=Replace string(Replace string(String($aml_e["description"]); Char(Carriage return); Char(Space); *); Char(Line feed); Char(Space))
SEND PACKET($file; $data+$separator_col)


: ($headerName="Comments")
$data:=Replace string(Replace string(String($aml_e["comment"]); Char(Carriage return); Char(Space); *); Char(Line feed); Char(Space))
SEND PACKET($file; $data+$separator_col)


: ($headerName="Critical?")
$data:=String($aml_e["critical"]=True ? "Yes" : "No")
SEND PACKET($file; $data+$separator_col)

Else 

//SEND PACKET($file; Replace string(Replace string(String($aml_e[$headerName]); Char(Carriage return); Char(Space); *); Char(Line feed); Char(Space))+$separator_col)

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
		New object:C1471("header"; "Division #"; "field"; "devision.name"; "footerOperation"; ""); \
		New object:C1471("header"; "Internal Part"; "field"; "ourPartNum"; "footerOperation"; ""); \
		New object:C1471("header"; "Vendor Part"; "field"; "vendorPartnum"; "footerOperation"; ""); \
		New object:C1471("header"; "Description"; "field"; "description"; "footerOperation"; ""); \
		New object:C1471("header"; "Comments"; "field"; "comment"; "footerOperation"; ""); \
		New object:C1471("header"; "Critical?"; "field"; "critical"; "footerOperation"; "")\
		)
	
	If ($fileName="main") | ($fileName="Main view")
		$title:="All AMLs"
		$fileName:="AllAMLs"
	Else 
		$title:=$fileName
		$fileName:=Replace string:C233($fileName; " "; "")
	End if 
	
	$destinationFolderPath:=Get 4D folder:C485(Current resources folder:K5:16)+"exportedData"+Folder separator:K24:12+"AMLs"
	
	$destinationFileName:=Split string:C1554(String:C10($fileName+"_"+Replace string:C233(String:C10(Date:C102(Timestamp:C1445)); "/"; "_")); " "; sk ignore empty strings:K86:1+sk trim spaces:K86:2).join("")
	$sheetName:=$fileName
	$selection:=Form:C1466.sfw.lb_items
	$offscreen:=cs:C1710.ExcelDataExporter.new($templateFile.platformPath; $mapping; $selection; $destinationFileName; $destinationFolderPath; $title; $sheetName; True:C214)
	$excelSheet:=VP Run offscreen area($offscreen)
	
	
Else 
	
	cs:C1710.sfw_dialog.me.alert(ds:C1482.sfw_readXliff("No items in the list to Export"))
	
End if 
