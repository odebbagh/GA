//%attributes = {}


/*
Method Name : _ga_exportSpecToExcel
Author : Medard /4D PS
Date : 01-July-2025
Purpose : This method export the items on Spec Control View List to an .xls document
*/

/*
var $eSetting : cs.sfw_SettingEntity
var $identEntry : Text:=Form.sfw.entry.ident
var $entity : 4D.Entity
var $info : Object
var $wpBlob : 4D.Blob
var $wpEncodedBlob : Text
var $specifications : cs.SpecificationSelection
var $OK : Boolean
var $headers : Collection
var $listOfHeaders : Collection
var $header; $separator_col; $separator_line : Text


$listOfHeaders:=New collection("spec"; "revision"; "extension"; "title"; "revisionDate"; \
"reviewDate"; "remark"; "category"; "department")
$headers:=New collection()
$separator_col:=Char(Tab)
$separator_line:=Char(Carriage return)


$file:=Create document(""; "xls")

If (OK=1)
$export:=New object
$export.records:=New collection

$dataclass:=Form.sfw.entry.dataclass

$specifications:=Form.sfw.lb_items


For each ($entity; $specifications)
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

$specification_es:=$export.records

If ($specification_es.length>0)
OB GET PROPERTY NAMES($specification_es[0]; $headerNames; $arrTypes)
ARRAY TO COLLECTION($headers; $headerNames)
$headers:=$headers.filter(Formula($listOfHeaders.indexOf($1.value)#-1))

$OK:=True
Else 
$OK:=False
End if 
For ($i; 0; $headers.length-1)

Case of 
: ($headers[$i]="spec")
$headerName:="Spec#"
: ($headers[$i]="revisionDate")
$headerName:="Spec Revision date"
: ($headers[$i]="reviewDate")
$headerName:="Last  Review date"
: ($headers[$i]="remark")
$headerName:="remarks"
: ($headers[$i]="category")
$headerName:="Document Type"
: ($headers[$i]="department")
$headerName:="Controlling Dept"
Else 
$headerName:=$headers[$i]
End case 

SEND PACKET($file; _capitalize_text($headerName)+$separator_col)

End for 

SEND PACKET($file; $separator_line)

If ($OK)

For each ($specification_e; $specification_es)

For each ($headerName; $headers)

Case of 
: ($headerName="UUID")
: ($headerName="category")

SEND PACKET($file; Replace string(Replace string(String($specification_e.category.name); Char(Carriage return); Char(Space); *); Char(Line feed); Char(Space))+$separator_col)

: ($headerName="department")

SEND PACKET($file; Replace string(Replace string(String($specification_e.controllingDeppartment.name); Char(Carriage return); Char(Space); *); Char(Line feed); Char(Space))+$separator_col)

Else 
SEND PACKET($file; Replace string(Replace string(String($specification_e[$headerName]); Char(Carriage return); Char(Space); *); Char(Line feed); Char(Space))+$separator_col)

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
		New object:C1471("header"; "Spec #"; "field"; "spec"; "footerOperation"; ""); \
		New object:C1471("header"; "Revision"; "field"; "revision"; "footerOperation"; ""); \
		New object:C1471("header"; "Extention"; "field"; "extension"; "footerOperation"; ""); \
		New object:C1471("header"; "Title"; "field"; "title"; "footerOperation"; ""); \
		New object:C1471("header"; "RevisionDate"; "field"; "revisionDate"; "footerOperation"; ""); \
		New object:C1471("header"; "ReviewDate"; "field"; "reviewDate"; "footerOperation"; ""); \
		New object:C1471("header"; "Remark"; "field"; "remark"; "footerOperation"; ""); \
		New object:C1471("header"; "Category"; "field"; "category.name"; "footerOperation"; ""); \
		New object:C1471("header"; "Department"; "field"; "controllingDeppartment.name"; "footerOperation"; "")\
		)
	
	If ($fileName="Main view")
		$title:="All Specs"
		$fileName:="AllSpecs"
	Else 
		$title:=$fileName
		$fileName:=Replace string:C233($fileName; " "; "")
	End if 
	
	$destinationFolderPath:=Get 4D folder:C485(Current resources folder:K5:16)+"exportedData"+Folder separator:K24:12+"Specs"
	
	$destinationFileName:=Split string:C1554(String:C10($fileName+"_"+Replace string:C233(String:C10(Date:C102(Timestamp:C1445)); "/"; "_")); " "; sk ignore empty strings:K86:1+sk trim spaces:K86:2).join("")
	$sheetName:=$fileName
	$selection:=Form:C1466.sfw.lb_items
	$offscreen:=cs:C1710.ExcelDataExporter.new($templateFile.platformPath; $mapping; $selection; $destinationFileName; $destinationFolderPath; $title; $sheetName; True:C214)
	$excelSheet:=VP Run offscreen area($offscreen)
	
	
Else 
	
	cs:C1710.sfw_dialog.me.alert(ds:C1482.sfw_readXliff("No items in the list to Export"))
	
End if 
