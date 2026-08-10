//%attributes = {}


/*
Method Name : _ga_exportSupplierList
Date : 08-August-2025
Purpose : This method export the items on Supplier View List to an .xls document
*/


var $eSetting : cs:C1710.sfw_SettingEntity
var $identEntry : Text:=Form:C1466.sfw.entry.ident
var $entity : 4D:C1709.Entity
var $info : Object
var $wpBlob : 4D:C1709.Blob
var $wpEncodedBlob : Text
var $suppliers : cs:C1710.SupplierSelection
var $supplier_e : cs:C1710.SupplierEntity
var $OK : Boolean
var $headers : Collection
var $listOfHeaders : Collection
var $header; $separator_col; $separator_line : Text
var $contact_e : cs:C1710.ContactEntity
var $addressInfos : Object:=New object:C1471
var $addresses : Collection:=New collection:C1472()


$headers:=New collection:C1472("name"; "street1"; "street2"; \
"city"; "state"; "zip"; "firstName"; "lastName"; "tel"; "approved By QA"; "disqualified"; "deactivated")


$separator_col:=Char:C90(Tab:K15:37)
$separator_line:=Char:C90(Carriage return:K15:38)


$file:=Create document:C266(""; "xls")

If (OK=1)
	$export:=New object:C1471
	$export.records:=New collection:C1472
	
	$dataclass:=Form:C1466.sfw.entry.dataclass
	
	$suppliers:=Form:C1466.sfw.lb_items
	
	
	For each ($entity; $suppliers)
		$oEntity:=New object:C1471
		For each ($attribute; ds:C1482[$dataclass])
			If (ds:C1482[$dataclass][$attribute].fieldType=Is object:K8:27) && ($entity[$attribute]#Null:C1517) && (String:C10($entity[$attribute].title)="4D Write Pro New Document")
				WP EXPORT VARIABLE:C1319($entity[$attribute]; $wpBlob; wk 4wp:K81:4)
				BASE64 ENCODE:C895($wpBlob; $wpEncodedBlob)
				$oEntity[$attribute]:=$wpEncodedBlob
			Else 
				$oEntity[$attribute]:=$entity[$attribute]
			End if 
			
		End for each 
		$export.records.push($oEntity)
		
	End for each 
	
	$supplier_es:=$export.records
	
	If ($supplier_es.length>0)
		
		$OK:=True:C214
	Else 
		$OK:=False:C215
	End if 
	
	
	If ($OK)
		
		For ($i; 0; $headers.length-1)
			
			SEND PACKET:C103($file; _Capitalize_text($headers[$i])+$separator_col)
			
		End for 
		
		SEND PACKET:C103($file; $separator_line)
		
		
		For each ($supplier_e; $supplier_es)
			
			For each ($headerName; $headers)
				
				$addresses:=$supplier_e.contactDetails.addresses
				If ($addresses.length>0)
					$addressInfos:=$addresses[0].detail
				End if 
				
				
				$contact_e:=ds:C1482.Contact.query("UUID_Company = :1"; $supplier_e.UUID).query("title=:1"; "Primary").first()
				
				Case of 
						
					: ($headerName="street1")
						$data:=Replace string:C233(Replace string:C233(String:C10($addressInfos["street_1"]); Char:C90(Carriage return:K15:38); Char:C90(Space:K15:42); *); Char:C90(Line feed:K15:40); Char:C90(Space:K15:42))
						SEND PACKET:C103($file; $data+$separator_col)
						
					: ($headerName="street2")
						$data:=Replace string:C233(Replace string:C233(String:C10($addressInfos["street_2"]); Char:C90(Carriage return:K15:38); Char:C90(Space:K15:42); *); Char:C90(Line feed:K15:40); Char:C90(Space:K15:42))
						SEND PACKET:C103($file; $data+$separator_col)
						
					: ($headerName="city")
						$data:=Replace string:C233(Replace string:C233(String:C10($addressInfos[$headerName]); Char:C90(Carriage return:K15:38); Char:C90(Space:K15:42); *); Char:C90(Line feed:K15:40); Char:C90(Space:K15:42))
						
						SEND PACKET:C103($file; $data+$separator_col)
						
					: ($headerName="state")
						$data:=Replace string:C233(Replace string:C233(String:C10($addressInfos[$headerName]); Char:C90(Carriage return:K15:38); Char:C90(Space:K15:42); *); Char:C90(Line feed:K15:40); Char:C90(Space:K15:42))
						SEND PACKET:C103($file; $data+$separator_col)
						
					: ($headerName="zip")
						$data:=Replace string:C233(Replace string:C233(String:C10($addressInfos.postcode); Char:C90(Carriage return:K15:38); Char:C90(Space:K15:42); *); Char:C90(Line feed:K15:40); Char:C90(Space:K15:42))
						SEND PACKET:C103($file; $data+$separator_col)
						
					: ($headerName="firstName")
						If ($contact_e#Null:C1517)
							$data:=$contact_e#Null:C1517 ? Replace string:C233(Replace string:C233(String:C10($contact_e[$headerName]); Char:C90(Carriage return:K15:38); Char:C90(Space:K15:42); *); Char:C90(Line feed:K15:40); Char:C90(Space:K15:42)) : ""
							SEND PACKET:C103($file; $data+$separator_col)
						End if 
					: ($headerName="lastName")
						If ($contact_e#Null:C1517)
							$data:=$contact_e#Null:C1517 ? Replace string:C233(Replace string:C233(String:C10($contact_e[$headerName]); Char:C90(Carriage return:K15:38); Char:C90(Space:K15:42); *); Char:C90(Line feed:K15:40); Char:C90(Space:K15:42)) : ""
							SEND PACKET:C103($file; $data+$separator_col)
						End if 
					: ($headerName="tel")
						If ($contact_e#Null:C1517)
							If ($contact_e.contactDetails.communications.length>0)
								$data:=Replace string:C233(Replace string:C233(String:C10($contact_e.contactDetails.communications.query("type =:1"; "phone")[0]["contact"]); Char:C90(Carriage return:K15:38); Char:C90(Space:K15:42); *); Char:C90(Line feed:K15:40); Char:C90(Space:K15:42))
								SEND PACKET:C103($file; $data+$separator_col)
							End if 
						End if 
					: ($headerName="approved By QA")
						$data:=String:C10($supplier_e["approvedByQA"]=True:C214 ? "Yes" : "No")
						SEND PACKET:C103($file; $data+$separator_col)
						
					: ($headerName="disqualified")
						$data:=String:C10($supplier_e["disqualified"]=True:C214 ? "Yes" : "No")
						SEND PACKET:C103($file; $data+$separator_col)
						
					: ($headerName="deactivated")
						$data:=String:C10($supplier_e["deactivated"]=True:C214 ? "Yes" : "No")
						SEND PACKET:C103($file; $data+$separator_col)
						
						
					Else 
						SEND PACKET:C103($file; Replace string:C233(Replace string:C233(String:C10($supplier_e[$headerName]); Char:C90(Carriage return:K15:38); Char:C90(Space:K15:42); *); Char:C90(Line feed:K15:40); Char:C90(Space:K15:42))+$separator_col)
						
				End case 
				
			End for each 
			
			SEND PACKET:C103($file; $separator_line)
			
		End for each 
		
		CLOSE DOCUMENT:C267($file)
		
		cs:C1710.sfw_dialog.me.info(ds:C1482.sfw_readXliff("export.done"; "The export is done"))
		
		SET ENVIRONMENT VARIABLE:C812("_4D_OPTION_BLOCKING_EXTERNAL_PROCESS"; "false")
		SET ENVIRONMENT VARIABLE:C812("_4D_OPTION_HIDE_CONSOLE"; "true")
		
		LAUNCH EXTERNAL PROCESS:C811("cmd.exe /C  start \"\" \""+document+"\"")
		
	Else 
		
		cs:C1710.sfw_dialog.me.alert(ds:C1482.sfw_readXliff("No items in the list to print"))
		
	End if 
	
End if 

/*
var $fields : Collection
var $mapping : Collection:=New collection()

If (Form.sfw.lb_items.length>0)

$fileName:=Form.sfw.view.label

$templateFile:=Folder(fk resources folder).file("excelTemplates/excelExportTemplate.xlsx")

$mapping:=New collection(\
New object("header"; "Name"; "field"; "item"; "footerOperation"; ""); \
New object("header"; "Street1"; "field"; "interestedParty"; "footerOperation"; ""); \
New object("header"; "Street2"; "field"; "procedureType"; "footerOperation"; ""); \
New object("header"; "City"; "field"; "action"; "footerOperation"; ""); \
New object("header"; "Zip"; "field"; "requirement"; "footerOperation"; ""); \
New object("header"; "FirstName"; "field"; "responsible"; "footerOperation"; ""); \
New object("header"; "LastName"; "field"; "notes"; "footerOperation"; ""); \
New object("header"; "Tel"; "field"; "externalID"; "footerOperation"; ""); \
New object("header"; "Approved"; "field"; "approvedByQA"; "footerOperation"; ""); \
New object("header"; "Disqualified"; "field"; "disqualified"; "footerOperation"; ""); \
New object("header"; "Desactivated"; "field"; "deactivated"; "footerOperation"; "")\
)

If ($fileName="main") | ($fileName="Main view")
$title:="All Suppliers"
$fileName:="AllSuppliers"
Else 
$title:=$fileName
$fileName:=Replace string($fileName; " "; "")
End if 

$destinationFolderPath:=Get 4D folder(Current resources folder)+"exportedData"+Folder separator+"Suppliers"

$destinationFileName:=Split string(String($fileName+"_"+Replace string(String(Date(Timestamp)); "/"; "_")); " "; sk ignore empty strings+sk trim spaces).join("")
$sheetName:=$fileName
$selection:=Form.sfw.lb_items
$offscreen:=cs.ExcelDataExporter.new($templateFile.platformPath; $mapping; $selection; $destinationFileName; $destinationFolderPath; $title; $sheetName)
$excelSheet:=VP Run offscreen area($offscreen)


Else 

cs.sfw_dialog.me.alert(ds.sfw_readXliff("No items in the list to Export"))

End if 
*/