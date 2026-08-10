//%attributes = {}
// Disables editing on NCMN / ISSNF dialog forms (expects Form.readOnly = true).
If (Not:C34(Bool:C1537(Form:C1466.readOnly)))
	return 
End if 

OBJECT SET VISIBLE:C603(*; "btn_save"; False:C215)
OBJECT SET ENABLED:C1123(*; "btn_save"; False:C215)
OBJECT SET ENTERABLE:C238(*; "field@"; False:C215)
OBJECT SET ENABLED:C1123(*; "chk_@"; False:C215)
OBJECT SET ENABLED:C1123(*; "btnDatePicker@"; False:C215)
