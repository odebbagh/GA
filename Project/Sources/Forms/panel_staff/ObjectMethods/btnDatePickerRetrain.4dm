// Purpose: Dirty Staff only when the retrain calendar day actually changes.
// modified by 4D/PS [2026-october-06]
var $oldDate : Date

$oldDate:=Form:C1466.current_item.retrainDate
cs:C1710.Util.me.btnDatePicker(Form:C1466.current_item; "retrainDate")
If (Form:C1466.current_item.retrainDate#$oldDate)
	cs:C1710.panel_staff.me._activate_save_cancel_button()
End if 
