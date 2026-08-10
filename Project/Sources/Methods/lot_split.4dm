//%attributes = {}

var $form : Object

$form:=New object:C1471()

If (Form:C1466.current_lb_item#Null:C1517)
	$form.lot:=Form:C1466.current_lb_item
End if 

$winRef:=Open form window:C675("split_lot"; Controller form window:K39:17; Horizontally centered:K39:1; Vertically centered:K39:4)
DIALOG:C40("split_lot"; $form)
CLOSE WINDOW:C154($winRef)
