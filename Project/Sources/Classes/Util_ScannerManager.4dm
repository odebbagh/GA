singleton Class constructor
	
	
Function dropDownListSelection($dataClass; $foreignKey; $fieldRedrawer; $pannelClass)
	
	$barcodeData:=This:C1470.communicateWithScanner()
	
	If (OK=1)
		$eEntities:=ds:C1482[$dataClass].query("moreData.barcodeData = :1"; $barcodeData)
		
		Case of 
				
			: ($eEntities.length=0)
				cs:C1710.sfw_dialog.me.alert(ds:C1482.sfw_readXliff("Error"; "No Records Found for the Barcode Scanned"))
				
			: ($eEntities.length=1)
				$eEntity:=$eEntities.first()
				//$keys:=Split string($foreignKey; ".")
				//Case of 
				//: ($keys.length=1)
				Form:C1466.current_item[$foreignKey]:=$eEntity.UUID
				
				//: ($keys.length=2)  //Repair_Log case where fixer and reporter are saved as attribute of an object name operators
				//Form.current_item[$keys[0]][$keys[1]]:=$eEntity.UUID
				
				//Else 
				
				//End case 
				
			: ($eEntities.length>1)
				cs:C1710.sfw_dialog.me.alert(ds:C1482.sfw_readXliff("Error"; "Multiples Records Found for the Barcode Scanned"))
				
			Else 
				
		End case 
		
		$nomFonction:="_activate_save_cancel_button"
		$formule:=Formula from string:C1601("cs."+$pannelClass+".me."+$nomFonction+"()")
		$resultat:=$formule.source
		
		$formule:=Formula from string:C1601("cs."+$pannelClass+".me."+$fieldRedrawer+"()")
		$resultat:=$formule.source
		
	End if 
	
	
Function scanForInputField()
	
	
Function UserApprovalByScanning($object)  //$type)
	
	$barcodeData:=This:C1470.communicateWithScanner()
	
	If (OK=1)
		$eEntities:=ds:C1482.Staff.query("moreData.barcodeData = :1"; $barcodeData)
		
		Case of 
				
			: ($eEntities.length=0)
				cs:C1710.sfw_dialog.me.alert(ds:C1482.sfw_readXliff("No User Found for the Barcode Scanned"))
				
			: ($eEntities.length=1)
				$eEntity:=$eEntities.first()
				
				If ($object.isApproved)
					$object.approvedBy:=$eEntity.code
					$object.approvalDate:=Current date:C33(*)
				Else 
					$object.approvedBy:=""
					$object.approvalDate:=Date:C102(!00-00-00!)
				End if 
				
/*
//TODO : IMPROVE
Case of 
: ($type="document")
If (Form.details.isApproved)
Form.details.approvedBy:=$eEntity.code
Form.details.approvalDate:=Current date(*)
Else 
Form.details.approvedBy:=""
Form.details.approvalDate:=Date(!00-00-00!)
End if 
				
: ($type="steps")
				
If (Form.currentStep.isApproved)
Form.currentStep.approvedBy:=$eEntity.code
Form.currentStep.approvalDate:=Current date(*)
				
Else 
Form.currentStep.approvedBy:=""
Form.currentStep.approvalDate:=Date(!00-00-00!)
				
End if 
				
				
: ($type="other")
				
If (Form.current_item.isApproved)
Form.current_item.approvalDate:=Current date(*)
Form.current_item.approvedBy:=$eEntity.code
Else 
Form.current_item.approvalDate:=Date(!00-00-00!)
Form.current_item.approvedBy:=""
End if 
				
Else 
				
End case 
				
*/
				
			: ($eEntities.length>1)
				cs:C1710.sfw_dialog.me.alert(ds:C1482.sfw_readXliff("Multiples Users Found for the Barcode Scanned"))
				
			Else 
				
		End case 
		
	Else 
		
		$object.isApproved:=Form:C1466.details.clone.isApproved
		
	End if 
	
	
Function communicateWithScanner()->$barcodeData : Text
	
	$winRef:=Open form window:C675("_ga_scanInterface"; Movable dialog box:K34:7; Horizontally centered:K39:1; Vertically centered:K39:4)
	
	$form:=New object:C1471
	$form.barcodeData:=""
	$form.winRef:=$winRef
	SET WINDOW TITLE:C213("Scan the bar code"; $winRef)
	DIALOG:C40("_ga_scanInterface"; $form)
	CLOSE WINDOW:C154($winRef)
	$barcodeData:=(OK=1) ? $form.barcodeData : ""
	
Function resolveStaffFromScanOrRequest()->$result : Object
	
	var $barcodeData : Text
	var $scanResult : Object
	var $userCode : Text
	var $esStaff : cs:C1710.StaffSelection
	var $eStaff : cs:C1710.StaffEntity
	
	$result:=New object:C1471("success"; False:C215; "cancelled"; False:C215; "failureReason"; "")
	
	$scanResult:=This:C1470.communicateWithScannerForStaff()
	
	If ($scanResult.cancelled)
		$result.cancelled:=True:C214
		return 
	End if 
	
	If ($scanResult.manualEntry)
		$userCode:=Request:C163("Please enter your user code:")
		If ($userCode="")
			$result.cancelled:=True:C214
			return 
		End if 
		
		$esStaff:=ds:C1482.Staff.query("code = :1"; $userCode)
		If ($esStaff.length=1)
			$eStaff:=$esStaff.first()
			If ($eStaff.user#Null:C1517)
				$result.success:=True:C214
				$result.staff:=$eStaff
			Else 
				$result.failureReason:="noUserAccount"
			End if 
		Else 
			$result.failureReason:="codeNotFound"
		End if 
		return 
	End if 
	
	$barcodeData:=$scanResult.barcodeData
	If ($barcodeData#"")
		$esStaff:=ds:C1482.Staff.query("moreData.barcodeData = :1"; $barcodeData)
		If ($esStaff.length=1)
			$eStaff:=$esStaff.first()
			If ($eStaff.user#Null:C1517)
				$result.success:=True:C214
				$result.staff:=$eStaff
				return 
			Else 
				$result.failureReason:="noUserAccount"
			End if 
		Else 
			$result.failureReason:="barcodeNotFound"
		End if 
	Else 
		$result.failureReason:="barcodeNotFound"
	End if 
	
	
Function communicateWithScannerForStaff()->$scanResult : Object
	
	var $form : Object
	var $winRef : Time
	
	$scanResult:=New object:C1471("cancelled"; False:C215; "manualEntry"; False:C215; "barcodeData"; "")
	
	$winRef:=Open form window:C675("_ga_scanInterface"; Movable dialog box:K34:7; Horizontally centered:K39:1; Vertically centered:K39:4)
	
	$form:=New object:C1471
	$form.barcodeData:=""
	$form.manualEntry:=False:C215
	$form.winRef:=$winRef
	SET WINDOW TITLE:C213("Scan the bar code"; $winRef)
	DIALOG:C40("_ga_scanInterface"; $form)
	CLOSE WINDOW:C154($winRef)
	
	If (OK=1)
		If ($form.manualEntry)
			$scanResult.manualEntry:=True:C214
		Else 
			$scanResult.barcodeData:=$form.barcodeData
		End if 
	Else 
		$scanResult.cancelled:=True:C214
	End if 
	
	return $scanResult
	
	