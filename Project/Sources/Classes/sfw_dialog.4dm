property lastExportFolder : 4D:C1709.Folder

shared singleton Class constructor
	
	
	
	
	//mark:-Dialog saveCancelContinue and createRenounceContinue
	
Function saveCancelContinue($formData : Object)
	cs:C1710.sfw_tracker.me.internal("saveCancelContinue")
	
	If (Is Windows:C1573)
		$refConfirm:=Open form window:C675("sfw_dial_SaveCancelContinue"; Modal form dialog box:K39:7)
	Else 
		$refConfirm:=Open form window:C675("sfw_dial_SaveCancelContinue"; Sheet form window:K39:12)
	End if 
	DIALOG:C40("sfw_dial_SaveCancelContinue"; $formData)
	CLOSE WINDOW:C154($refConfirm)
	
	
Function createRenounceContinue($formData : Object)
	cs:C1710.sfw_tracker.me.internal("createRenounceContinue")
	
	If (Is Windows:C1573)
		$refConfirm:=Open form window:C675("sfw_dial_CreateRenounceContinue"; Modal form dialog box:K39:7)
	Else 
		$refConfirm:=Open form window:C675("sfw_dial_CreateRenounceContinue"; Sheet form window:K39:12)
	End if 
	DIALOG:C40("sfw_dial_CreateRenounceContinue"; $formData)
	CLOSE WINDOW:C154($refConfirm)
	
	
	//mark:-Dialog Info
	
Function info($message : Text; $buttonOkLabel : Text)
	
	cs:C1710.sfw_tracker.me.internal($message)
	
	$formData:=New object:C1471
	$formData.message:=$message
	$formData.buttonOkLabel:=$buttonOkLabel || "Ok"
	If (Is Windows:C1573)
		$refAlert:=Open form window:C675("sfw_dial_info"; Modal form dialog box:K39:7)
	Else 
		$refAlert:=Open form window:C675("sfw_dial_info"; Sheet form window:K39:12)
	End if 
	DIALOG:C40("sfw_dial_info"; $formData)
	CLOSE WINDOW:C154($refAlert)
	
Function _sfw_dial_infoFM()
	Case of 
		: (FORM Event:C1606.code=On Load:K2:1)
			OBJECT SET TITLE:C194(*; "bOk"; Form:C1466.buttonOkLabel)
			
	End case 
	
	
	//mark:-Dialog Alert
	
Function alert($message : Text; $buttonOkLabel : Text)
	
	cs:C1710.sfw_tracker.me.internal($message)
	
	$formData:=New object:C1471
	$formData.message:=$message
	$formData.buttonOkLabel:=$buttonOkLabel || "Ok"
	If (Is Windows:C1573)
		$refAlert:=Open form window:C675("sfw_dial_alert"; Modal form dialog box:K39:7)
	Else 
		$refAlert:=Open form window:C675("sfw_dial_alert"; Sheet form window:K39:12)
	End if 
	DIALOG:C40("sfw_dial_alert"; $formData)
	CLOSE WINDOW:C154($refAlert)
	
Function _sfw_dial_alertFM()
	Case of 
		: (FORM Event:C1606.code=On Load:K2:1)
			OBJECT SET TITLE:C194(*; "bOk"; Form:C1466.buttonOkLabel)
			
	End case 
	
	
	//mark:-Dialog Confirm
	
	
Function confirm($message : Text; $buttonOkLabel : Text; $buttonCancelLabel)->$ok : Boolean
	
	cs:C1710.sfw_tracker.me.internal($message)
	
	$formData:=New object:C1471
	$formData.message:=$message
	$formData.buttonOkLabel:=$buttonOkLabel || "Ok"
	$formData.buttonCancelLabel:=$buttonCancelLabel || "Cancel"
	If (Is Windows:C1573)
		$refConfirm:=Open form window:C675("sfw_dial_confirm"; Modal form dialog box:K39:7)
	Else 
		$refConfirm:=Open form window:C675("sfw_dial_confirm"; Sheet form window:K39:12)
	End if 
	DIALOG:C40("sfw_dial_confirm"; $formData)
	CLOSE WINDOW:C154($refConfirm)
	$ok:=(ok=1)
	
Function _sfw_dial_confirmFM()
	Case of 
		: (FORM Event:C1606.code=On Load:K2:1)
			OBJECT SET TITLE:C194(*; "bOk"; Form:C1466.buttonOkLabel)
			OBJECT SET TITLE:C194(*; "bCancel"; Form:C1466.buttonCancelLabel)
			
	End case 
	
	
	
	//mark:-Dialog Request
	
Function request($message : Text; $default : Text; $buttonOkLabel : Text; $buttonCancelLabel;  ...  : Text)->$answer : Object
	
	cs:C1710.sfw_tracker.me.internal($message)
	
	$formData:=New object:C1471
	$formData.message:=$message
	$formData.answer:=$default
	$formData.buttonOkLabel:=$buttonOkLabel || "Ok"
	$formData.buttonCancelLabel:=buttonCancelLabel || "Cancel"
	$formData.trimSpace:=False:C215
	$formData.notEmpty:=False:C215
	For ($p; 5; Count parameters:C259)
		$param:=${$p}
		Case of 
			: ($param="trimSpace")
				$formData.trimSpace:=True:C214
			: ($param="notEmpty")
				$formData.notEmpty:=True:C214
		End case 
	End for 
	If (Is Windows:C1573)
		$refRequest:=Open form window:C675("sfw_dial_request"; Modal form dialog box:K39:7)
	Else 
		$refRequest:=Open form window:C675("sfw_dial_request"; Sheet form window:K39:12)
	End if 
	DIALOG:C40("sfw_dial_request"; $formData)
	CLOSE WINDOW:C154($refRequest)
	
	$answer:=New object:C1471
	$answer.answer:=$formData.answer
	$answer.ok:=(ok=1)
	
Function _sfw_dial_requestFM()
	Case of 
		: (FORM Event:C1606.code=On Load:K2:1)
			OBJECT SET TITLE:C194(*; "bOk"; Form:C1466.buttonOkLabel)
			OBJECT SET TITLE:C194(*; "bCancel"; Form:C1466.buttonCancelLabel)
			
	End case 
	$okEnabled:=(Form:C1466.notEmpty=False:C215) || (Form:C1466.answer#"")
	OBJECT SET ENABLED:C1123(*; "bOk"; $okEnabled)
	
shared Function _getLastExportFolder()->$folder : 4D:C1709.Folder
	
	If (This:C1470.lastExportFolder#Null:C1517)
		$folder:=This:C1470.lastExportFolder
	Else 
		$folder:=Folder:C1567(fk documents folder:K87:21)
		This:C1470._setLastExportFolder($folder)
	End if 
	
shared Function _setLastExportFolder($folder : 4D:C1709.Folder)
	This:C1470.lastExportFolder:=$folder
	