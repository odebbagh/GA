


Case of 
		
	: (Form event code:C388=On Load:K2:1)
		
		OBJECT SET ENTERABLE:C238(*; "lb_equipments"; False:C215)
		If (Form:C1466.lb_equipments.length=0)
			OBJECT SET TITLE:C194(*; "lbl_selectionList"; "0 Items")
		End if 
		
		
End case 