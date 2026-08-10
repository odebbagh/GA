//%attributes = {"executedOnServer":true}


var $eContact : cs:C1710.ContactEntity
var $contactSelection : cs:C1710.ContactSelection

$contactSelection:=ds:C1482.Contact.query("companyType =:1"; "Supplier")
For each ($eContact; $contactSelection)
	$status:=$eContact.drop()
	If ($status.success=False:C215)
		TRACE:C157
	End if 
End for each 
/*

//PartData
var $ePartData : cs.PartDataEntity

$partData_log:=Folder(fk data folder).file("DataJson/partData_export.json")

If ($partData_log.exists)
$partDatas:=JSON Parse($partData_log.getText())

TRUNCATE TABLE()

For each ($partData; $partDatas)

$ePartData:=ds.PartData.new()
$ePartData.internalPartNum:=$partData.InternalPatnum

$res:=$ePartData.save()
If (Not($res.success))
TRACE
End if 

End for each 

End if 

*/
//supplier table
var $eSupplier : cs:C1710.SupplierEntity


$supplier_log:=Folder:C1567(fk data folder:K87:12).file("DataJson/suppliers_export.json")

If ($supplier_log.exists)
	$suppliers:=JSON Parse:C1218($supplier_log.getText())
	
	TRUNCATE TABLE:C1051([Supplier:57])
	
	
	$docs:=Folder:C1567(fk data folder:K87:12).file("DataJson/docServerIndex_export.json")
	$count:=0
	If ($docs.exists)
		
		$documents:=JSON Parse:C1218($docs.getText())
		
	End if 
	
	
	For each ($supplier; $suppliers)
		
		$eSupplier:=ds:C1482.Supplier.new()
		
		$eSupplier.name:=$supplier.Supplier
		$eSupplier.code:=$supplier.code
		
		$eSupplier.moreData:=New object:C1471(\
			"criticalOverdueAudit"; False:C215\
			)
		
		$division:=ds:C1482.Division.query("name =:1"; Split string:C1554($supplier.Division; "\r"; sk trim spaces:K86:2).join("\r"))
		
		If ($division.length>0)
			
			$eSupplier.UUID_Division:=$division[0].UUID
		Else 
			
			$eSupplier.UUID_Division:=""
		End if 
		
		$eSupplier.disqualified:=$supplier.Disqualified
		$eSupplier.enteredBy:=$supplier.Entry_by
		$eSupplier.qaComment:=$supplier.QA_Comments
		$eSupplier.approvedByQA:=$supplier.ApprovedByQA
		$eSupplier.approvedByCustomer:=$supplier.ApprovedByCustomer
		$eSupplier.allowedLotProcessing:=$supplier.lot_processing_allowed
		$eSupplier.webService:=$supplier.WebService
		$eSupplier.auditRequired:=$supplier.Audit_Required
		$eSupplier.deactivated:=$supplier.Deactivate
		$eSupplier.stmpLastAudit:=cs:C1710.sfw_stmp.me.build(Date:C102($supplier.Last_Audit_Date))
		$eSupplier.stmpNextAudit:=cs:C1710.sfw_stmp.me.build(Date:C102($supplier.Next_Audit_Due))
		
		$eSupplier.contactDetails:=New object:C1471()
		$eSupplier.contactDetails.addresses:=New collection:C1472()
		
		$address:=New object:C1471()
		$address.type:="main"
		$address.detail:=New object:C1471()
		$address.detail.country:="US"
		$address.detail.street_1:=$supplier.Address1
		If (String:C10($supplier.Address2)#"")
			$address.detail.street_2:=$supplier.Address2
		End if 
		$address.detail.postcode:=$supplier.Zip
		$address.detail.iso_code_2:="US"
		$address.detail.city:=$supplier.Address3
		$address.detail.state:=$supplier.State
		$eSupplier.contactDetails.addresses.push($address)
		
		$address:=New object:C1471()
		$address.type:="remit"
		$address.detail:=New object:C1471()
		$address.detail.country:="US"
		$address.detail.street_1:=$supplier.remit_add1
		If (String:C10($supplier.Address2)#"")
			$address.detail.street_2:=$supplier.remit_add2
		End if 
		$address.detail.postcode:=$supplier.remit_zip
		$address.detail.iso_code_2:="US"
		$address.detail.city:=$supplier.remit_add3
		$address.detail.state:=$supplier.remit_st
		$eSupplier.contactDetails.addresses.push($address)
		
		$eSupplier.RatingData:=New object:C1471()
		$eSupplier.RatingData.items:=New collection:C1472()
		
		//$file_excel:=Folder(fk data folder).file("DataJson/MonitorProgramSupplierRating.csv")
		
		//$records_excel:=Split string($file_excel.getText(); "\r\n")
		
		//$records_excel.shift()  //remove the header
		
		//$staffs_excel:=New collection()
		
		
		$_documents:=$documents.query("PrimaryKeyValue=:1 & TableNumber=:2"; String:C10($supplier.UniqueID); 18)
		
		$eSupplier.attachedDocuments:=New object:C1471()
		$eSupplier.attachedDocuments.documents:=New collection:C1472()
		
		For each ($document; $_documents)
			$doc:=New object:C1471
			
			$doc.code:=$document.DocCode
			$doc.dateTimeStamp:=$document.DateTimeStamp
			$doc.creationDateTimeStamp:=$document.CreationDateTimeStamp
			$doc.documentPath:=$document.DocumentPath
			$doc.sourcePath:=$document.SourcePath
			$doc.description:=$document.DocDescription
			$doc.approvalDate:=!00-00-00!
			$doc.approvedBy:=""
			$doc.isApproved:=False:C215
			
			$report:=Folder:C1567(fk data folder:K87:12).file("DataJson/SuppliersDocs/"+String:C10($document.UniqueID+$document.PrimaryKeyValue))
			If ($report.exists)
				
				var $blob : Blob
				DOCUMENT TO BLOB:C525($report.platformPath; $blob)
				
				$doc.blob:=$blob
				
			End if 
			
			$eSupplier.attachedDocuments.documents.push($doc)
			
		End for each 
		
		
		//Save the supplier
		$res:=$eSupplier.save()
		If (Not:C34($res.success))
			TRACE:C157
		End if 
		
		
		//Primary contact
		$supplier.C1_first_name:=Split string:C1554($supplier.C1_first_name; ";"; sk ignore empty strings:K86:1+sk trim spaces:K86:2).join(";")
		$supplier.C1_first_name:=Split string:C1554($supplier.C1_first_name; ";"; sk ignore empty strings:K86:1+sk trim spaces:K86:2).join(";")
		If ($supplier.C1_first_name#"") || ($supplier.C1_last_name#"")
			$eContact:=ds:C1482.Contact.new()
			$eContact.UUID_Company:=$eSupplier.UUID
			$eContact.firstName:=$supplier.C1_first_name
			$eContact.lastName:=$supplier.C1_last_name
			$eContact.title:="Primary"
			$eContact.contactDetails:=New object:C1471()
			$eContact.contactDetails.addresses:=New collection:C1472()
			
			$eContact.contactDetails.communications:=New collection:C1472()
			
			$comm:=New object:C1471()
			$comm.type:="phone"
			$comm.comment:=""
			$comm.contact:=$supplier.C1_tel
			$eContact.contactDetails.communications.push($comm)
			
			$comm:=New object:C1471()
			$comm.type:="fax"
			$comm.comment:=""
			$comm.contact:=$supplier.C1_fax
			$eContact.contactDetails.communications.push($comm)
			If ($supplier.C1_fax#"")
				
			End if 
			$comm:=New object:C1471()
			$comm.type:="email"
			$comm.comment:=""
			$comm.contact:=$supplier.C1_Email
			$eContact.contactDetails.communications.push($comm)
			
			$result:=$eContact.save()
			If ($result.success=False:C215)
				TRACE:C157
			End if 
		End if 
		$comm:=New object:C1471()
		$comm.type:="email"
		$comm.comment:=""
		$comm.contact:=$supplier.C1_Email
		$eContact.contactDetails.communications.push($comm)
		
		$result:=$eContact.save()
		If ($result.success=False:C215)
			TRACE:C157
		End if 
		
		
		//Secondary contact
		$eContact:=ds:C1482.Contact.new()
		$eContact.UUID_Company:=$eSupplier.UUID
		$eContact.firstName:=$supplier.C2_first_name
		$eContact.lastName:=$supplier.C2_last_name
		$eContact.title:="Secondary"
		$eContact.contactDetails:=New object:C1471()
		$eContact.contactDetails.addresses:=New collection:C1472()
		
		$eContact.contactDetails.communications:=New collection:C1472()
		
		$comm:=New object:C1471()
		$comm.type:="phone"
		$comm.comment:=""
		$comm.contact:=$supplier.C2_tel
		$eContact.contactDetails.communications.push($comm)
		
		$comm:=New object:C1471()
		$comm.type:="fax"
		$comm.comment:=""
		$comm.contact:=$supplier.C2_fax
		$eContact.contactDetails.communications.push($comm)
		
		$comm:=New object:C1471()
		$comm.type:="email"
		$comm.comment:=""
		$comm.contact:=$supplier.C2_Email
		$eContact.contactDetails.communications.push($comm)
		
		$result:=$eContact.save()
		If ($result.success=False:C215)
			TRACE:C157
			
		End if 
		
		
	End for each 
	
	
	
End if 


//AML table
var $eAvml : cs:C1710.AMLEntity


$avml_log:=Folder:C1567(fk data folder:K87:12).file("DataJson/aml_export.json")

If ($avml_log.exists)
	$avmls:=JSON Parse:C1218($avml_log.getText())
	
	TRUNCATE TABLE:C1051([AML:56])
	
	For each ($avml; $avmls)
		
		$eAvml:=ds:C1482.AML.new()
		
		$eAvml.vendorPartnum:=$avml.Vendor_partnum
		$eAvml.critical:=$avml.Critical
		$eAvml.service:=$avml.Service
		$eAvml.serviceType:=$avml.Service_type
		
		$division:=ds:C1482.Division.query("name =:1"; Split string:C1554($avml.Division; "\r"; sk trim spaces:K86:2).join("\r"))
		
		If ($division.length>0)
			
			$eAvml.UUID_Division:=$division[0].UUID
		Else 
			
			$eAvml.UUID_Division:=""
		End if 
		
		$eAvml.enteredBy:=$avml.EnteredBy
		$eAvml.capacity:=$avml.Capacity
		$eAvml.makeInactive:=$avml.MakeInactive
		$eAvml.comment:=$avml.Comments
		
		$unit:=ds:C1482.Units.query("name =:1"; Split string:C1554($avml.InventoryUnits; "\r"; sk trim spaces:K86:2).join("\r"))
		
		If ($unit.length>0)
			
			$eAvml.inventoryUnits:=$unit[0].levelID
		Else 
			
			$eAvml.inventoryUnits:=0
		End if 
		
		
		$unit:=ds:C1482.Units.query("name =:1"; Split string:C1554($avml.ProcurementUnits; "\r"; sk trim spaces:K86:2).join("\r"))
		
		If ($unit.length>0)
			
			$eAvml.procurementUnits:=$unit[0].levelID
		Else 
			
			$eAvml.procurementUnits:=0
		End if 
		
		$eAvml.transFactorNumerator:=$avml.TransFactorNumerator
		$eAvml.transFactorDenominator:=$avml.TransFactorDenominator
		$eAvml.minInventoryLevel:=$avml.MinInventoryLevel
		$eAvml.description:=$avml.Description
		
		$eAvml.ourPartNum:=$avml.OUR_partnum
		
/*
$partNum:=ds.PartData.query("internalPartNum =:1"; Split string($avml.OUR_partnum; "\r"; sk trim spaces).join("\r"))
If ($partNum.length>0)
$eAvml.UUID_PartData:=$partNum[0].UUID
Else 
		
$ePartData:=ds.PartData.new()
$ePartData.internalPartNum:=$avml.OUR_partnum
		
$res:=$ePartData.save()
If (Not($res.success))
TRACE
End if 
		
$eAvml.UUID_PartData:=$ePartData.UUID
		
End if 
*/
		
		$supplier:=ds:C1482.Supplier.query("name =:1"; Split string:C1554($avml.Supplier; "\r"; sk trim spaces:K86:2).join("\r"))
		If ($supplier.length>0)
			$eAvml.UUID_Supplier:=$supplier[0].UUID
		Else 
			
		End if 
		
		//Attached Documents
		
		$eAvml.attachedDocuments:=New object:C1471()
		$eAvml.attachedDocuments.documents:=New collection:C1472()
		
		$res:=$eAvml.save()
		If (Not:C34($res.success))
			TRACE:C157
		End if 
		
		
	End for each 
	
End if 



//Build Supplier Critical history

$suppliers:=ds:C1482.Supplier.all()
For each ($eSupplier; $suppliers)
	$isCritical:=Bool:C1537($eSupplier.parts.extract("critical").filter(Formula:C1597($1.value=True:C214)).length)
	
	If ($isCritical)
		
		$eSupplier.critical:=True:C214
	End if 
	
	//Save the supplier
	$res:=$eSupplier.save()
	If (Not:C34($res.success))
		TRACE:C157
	End if 
	
End for each 




