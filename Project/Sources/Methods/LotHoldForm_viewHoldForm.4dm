//%attributes = {}
// Opens a hold form dialog in read-only mode for a hold ON event.
#DECLARE($lot : 4D:C1709.Entity; $formFieldName : Text; $holdOn : Object)

var $form : Object
var $formWindowName : Text
var $winRef : Integer

If ($lot=Null:C1517) || ($holdOn=Null:C1517)
	return 
End if 

$form:=LotHoldForm_resolveFormForHold($lot; $formFieldName; $holdOn)

If ($form=Null:C1517)
	Case of 
		: ($formFieldName="NCMN")
			cs:C1710.sfw_dialog.me.alert("No NCMN form was saved for this hold.")
		: ($formFieldName="ISSNF")
			cs:C1710.sfw_dialog.me.alert("No ISSNF form was saved for this hold.")
		Else 
			cs:C1710.sfw_dialog.me.alert("No hold form was saved for this hold.")
	End case 
	return 
End if 

$form.readOnly:=True:C214

Case of 
	: ($formFieldName="NCMN")
		$formWindowName:="NCMN"
	: ($formFieldName="ISSNF")
		$formWindowName:="ISSNF"
	Else 
		return 
End case 

$winRef:=Open form window:C675($formWindowName; Controller form window:K39:17; Horizontally centered:K39:1; Vertically centered:K39:4)
DIALOG:C40($formWindowName; $form)
CLOSE WINDOW:C154($winRef)
