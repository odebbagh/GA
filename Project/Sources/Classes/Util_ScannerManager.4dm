singleton Class constructor
	
	
Function scanForInputField()
	
	
Function dropDownListSelection($dataClass; $foreignKey; $fieldRedrawer; $pannelClass)
	
	var $scanResult : Object
	var $barcodeData; $userCode : Text
	var $eEntities : 4D:C1709.EntitySelection
	var $eEntity : 4D:C1709.Entity
	var $nomFonction; $resultat : Text
	var $formule : 4D:C1709.Function
	
	$scanResult:=This:C1470.communicateWithScanner()
	
	If ($scanResult.cancelled)
		return 
	End if 
	
	If ($scanResult.manualEntry)
		If ($dataClass="Staff")
			$userCode:=Request:C163("Please enter your user code:")
			If ($userCode="")
				return 
			End if 
			$eEntities:=ds:C1482[$dataClass].query("code = :1"; $userCode)
		Else 
			return 
		End if 
	Else 
		$barcodeData:=$scanResult.barcodeData
		If ($barcodeData="")
			return 
		End if 
		$eEntities:=ds:C1482[$dataClass].query("moreData.barcodeData = :1"; $barcodeData)
	End if 
	
	Case of 
			
		: ($eEntities.length=0)
			cs:C1710.sfw_dialog.me.alert(ds:C1482.sfw_readXliff("Error"; "No Records Found for the Barcode Scanned"))
			
		: ($eEntities.length=1)
			$eEntity:=$eEntities.first()
			Form:C1466.current_item[$foreignKey]:=$eEntity.UUID
			
		: ($eEntities.length>1)
			cs:C1710.sfw_dialog.me.alert(ds:C1482.sfw_readXliff("Error"; "Multiples Records Found for the Barcode Scanned"))
			
		Else 
			
	End case 
	
	$nomFonction:="_activate_save_cancel_button"
	$formule:=Formula from string:C1601("cs."+$pannelClass+".me."+$nomFonction+"()")
	$resultat:=$formule.source
	
	$formule:=Formula from string:C1601("cs."+$pannelClass+".me."+$fieldRedrawer+"()")
	$resultat:=$formule.source
	
	
Function UserApprovalByScanning($object)  //$type)
	
	// Purpose: Restore isApproved to its pre-click value when scan fails or is cancelled.
	// Works for AML, Specification, RepairLog, PunchOut step, etc. via $object — not Form.details.
	// Parameters: $object : Object — entity or step with isApproved, approvedBy, approvalDate
	// modified by 4D/PS [2026-september-18]
	
	var $result : Object
	var $eEntity : cs:C1710.StaffEntity
	var $previousIsApproved : Boolean
	
	$previousIsApproved:=Not:C34($object.isApproved)
	
	$result:=This:C1470.resolveStaffFromScanOrRequest()
	
	If ($result.cancelled)
		$object.isApproved:=$previousIsApproved
		return 
	End if 
	
	If (Not:C34($result.success))
		Case of 
			: ($result.failureReason="codeNotFound")
				cs:C1710.sfw_dialog.me.alert("The user code entered does not correspond to any existing user.")
			: ($result.failureReason="barcodeNotFound")
				cs:C1710.sfw_dialog.me.alert("The scanned barcode does not correspond to any existing user.")
			: ($result.failureReason="noUserAccount")
				cs:C1710.sfw_dialog.me.alert("This employee does not have an application user account.")
			Else 
				cs:C1710.sfw_dialog.me.alert("Unable to identify the user.")
		End case 
		$object.isApproved:=$previousIsApproved
		return 
	End if 
	
	$eEntity:=$result.staff
	If ($object.isApproved)
		$object.approvedBy:=$eEntity.code
		$object.approvalDate:=Current date:C33(*)
	Else 
		$object.approvedBy:=""
		$object.approvalDate:=Date:C102(!00-00-00!)
	End if 
	
Function resolveStaffFromScanOrRequest()->$result : Object
	
	var $barcodeData : Text
	var $scanResult : Object
	var $userCode : Text
	var $esStaff : cs:C1710.StaffSelection
	var $eStaff : cs:C1710.StaffEntity
	
	$result:=New object:C1471("success"; False:C215; "cancelled"; False:C215; "failureReason"; "")
	
	$scanResult:=This:C1470.communicateWithScanner()  //ForStaff()
	
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
	
	
Function communicateWithScanner()->$scanResult : Object  //communicateWithScannerForStaff()
	
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
	
	