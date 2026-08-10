$draw:=False:C215
Case of 
	: (Form:C1466=Null:C1517)  // to early 
	: (FORM Event:C1606.code=On Load:K2:1)
		sfw_subpanel_schedule_init
		$draw:=True:C214
		
	: (FORM Event:C1606.code=On Bound Variable Change:K2:52)
		If (Form:C1466.pupPeriods=Null:C1517)
			sfw_subpanel_schedule_init
		End if 
		$draw:=True:C214
		
End case 

If ($draw)
	
	sfw_subpanel_schedule_draw
	
	//If (String(Form.currentMode)#String(Form.situation.mode)) | (String(Form.currentMode)="")
	//Form.period:=Null
	//Form.period_position:=0
	//sfw_subpanel_schedule_period(Form.period)
	//End if 
	//Form.currentMode:=Form.situation.mode
	
	If (Form:C1466.isNewSelection)
		Form:C1466.isNewSelection:=False:C215
		If (Form:C1466.periods.length=0)
			Form:C1466.period_position:=0
		Else 
			Form:C1466.period_position:=1
			LISTBOX SELECT ROW:C912(*; "lb_periods"; 1; lk replace selection:K53:1)
			Form:C1466.period:=Form:C1466.periods[Form:C1466.period_position-1]
			sfw_subpanel_schedule_period(Form:C1466.period)
		End if 
		
	End if 
	
End if 

