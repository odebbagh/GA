Case of
	: (Form event code:C388=On Load:K2:1)
		If (Not:C34(Bool:C1537(Form:C1466.serialized)))
			// non-serialized lot: no SN selection, the quantity is typed directly
			OBJECT SET VISIBLE:C603(*; "lbl_snHint"; False:C215)
			OBJECT SET VISIBLE:C603(*; "lb_snItems"; False:C215)
		Else
			// serialized lot: the quantity follows the SN selection
			OBJECT SET ENTERABLE:C238(*; "inp_quantity"; False:C215)
		End if
End case
