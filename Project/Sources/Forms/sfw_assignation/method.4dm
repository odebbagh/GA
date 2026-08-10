Case of 
	: (FORM Event:C1606.code=On Load:K2:1)
		
		Form:C1466.from:=cs:C1710.sfw_userManager.me.info.name
		Form:C1466.UUID_targetAssigned:=""
		Form:C1466.todoDescription:=""
		Form:C1466.assignation:=Null:C1517
		Form:C1466.deadlineDate:=Current date:C33+1
		Form:C1466.deadlineTime:=?18:00:00?
		Form:C1466.deadline:=True:C214
		Form:C1466.lb_assignations:=ds:C1482.sfw_Todo.query("UUID_target = :1 and entryIdent = :2 order by deadlineStmp desc, achievedStmp, stmp desc"; Form:C1466.current_item.UUID; Form:C1466.entry.ident)
		If (Form:C1466.lb_assignations.length=0)
			FORM GOTO PAGE:C247(2)
			SET TIMER:C645(-1)
		Else 
			FORM GOTO PAGE:C247(1)
			SET TIMER:C645(-1)
		End if 
		
	: (FORM Event:C1606.code=On Timer:K2:25)
		SET TIMER:C645(0)
		GET WINDOW RECT:C443($gw; $hw; $dw; $bw; Current form window:C827)
		Case of 
			: (FORM Get current page:C276=1) && (Form:C1466.assignation=Null:C1517)
				OBJECT GET COORDINATES:C663(*; "bkgdMiddle"; $g; $h; $d; $b)
				If ($bw#($hw+$b))
					SET WINDOW RECT:C444($gw; $hw; $dw; $hw+$b; Current form window:C827)
				End if 
				
			: (FORM Get current page:C276=1)
				OBJECT GET COORDINATES:C663(*; "bkgdBottom"; $g; $h; $d; $b)
				SET WINDOW RECT:C444($gw; $hw; $dw; $hw+$h; Current form window:C827)
				
			: (FORM Get current page:C276=2)
				LISTBOX SELECT ROW:C912(*; "lb_assignations"; 0; lk remove from selection:K53:3)
				
				OBJECT GET COORDINATES:C663(*; "bkgdBottom"; $g; $h; $d; $b)
				SET WINDOW RECT:C444($gw; $hw; $dw; $hw+$b; Current form window:C827)
				
		End case 
		
End case 

OBJECT SET ENABLED:C1123(*; "bAssign"; (Form:C1466.todoDescription#"") && (Form:C1466.UUID_targetAssigned#""))
OBJECT SET VISIBLE:C603(*; "deadlineDate"; Form:C1466.deadline)
OBJECT SET VISIBLE:C603(*; "deadlineTime"; Form:C1466.deadline)
OBJECT SET VISIBLE:C603(*; "datePicker"; Form:C1466.deadline)
OBJECT SET TITLE:C194(*; "bDeadline"; Form:C1466.deadline ? ds:C1482.sfw_readXliff("assignation.deadline") : ds:C1482.sfw_readXliff("assignation.nodeadline"))
