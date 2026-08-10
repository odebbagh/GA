//%attributes = {}
/*
_ga_rejectionForm

Author : Medard /4D PS
Date :27-October-2025
Purpose : upload,view modify rejection form
*/

If (Form:C1466.subForm.currentStep#Null:C1517)
	
	
	var $context : Object
	
	$context:=New object:C1471()
	
	
	$details:=New object:C1471("blob"; Form:C1466.subForm.currentStep.rejectionBlob; "docPath"; ""; "docName"; "QA_QC_Rejection_Notice_")
	
	$form:=New object:C1471("details"; $details)
	
	$form.uploadDisplayOnly:=True:C214
	$form.type:="Reject Form"
	
	$winRef:=Open form window:C675("_ga_uploadDocument"; Plain form window:K39:10; Horizontally centered:K39:1; Vertically centered:K39:4)
	
	DIALOG:C40("_ga_uploadDocument"; $form)
	
	If (OK=1)
		
		Form:C1466.subForm.currentStep.rejectionBlob:=$form.details.blob
		
		$res:=Form:C1466.subForm.currentStep.save()
		
		If ($res.success)
			cs:C1710.panel_punchOut.me._activate_save_cancel_button()
		End if 
		
		
	End if 
	
	
End if 
