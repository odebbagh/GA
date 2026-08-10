
Case of 
		
	: (Form event code:C388=On Load:K2:1)
		If (Form:C1466.holdLot=Null:C1517)
			Form:C1466.holdLot:=New object:C1471
		End if 
		If (Form:C1466.holdDate=Null:C1517) | (Form:C1466.holdDate=!00-00-00!)
			Form:C1466.holdDate:=Current date:C33
		End if 
		If (String:C10(Form:C1466.holdAction)="")
			Form:C1466.holdAction:="Hold ON"
		End if 
		var $holdTime : Time
		$holdTime:=Time:C179(Current time:C178)
		If (Form:C1466.holdTime#Null:C1517)
			Case of 
				: (Value type:C1509(Form:C1466.holdTime)=Is time:K8:8)
					$holdTime:=Form:C1466.holdTime
				: ((Value type:C1509(Form:C1466.holdTime)=Is real:K8:4) | (Value type:C1509(Form:C1466.holdTime)=Is longint:K8:6))
					$holdTime:=Time:C179(Form:C1466.holdTime)
			End case 
		End if 
		Form:C1466.holdTime:=$holdTime
		Form:C1466.holdTimeDisplay:=String:C10($holdTime; HH MM:K7:2)
		If (Form:C1466.performedBy=Null:C1517)
			Form:C1466.performedBy:=""
		End if 
		If (Form:C1466.staffCode=Null:C1517)
			Form:C1466.staffCode:=""
		End if 
		If (Form:C1466.holdAction="Hold OFF")
			Form:C1466.holdLot.code:=Form:C1466.hold_code.code
			OBJECT SET ENABLED:C1123(*; "pup_holdCodes"; False:C215)
		End if 
End case 