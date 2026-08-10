//%attributes = {}

If (FORM Event:C1606.code=On Load:K2:1)
	Form:C1466.holdCodeDisplay:=Choose:C955(Form:C1466.holdCode#Null:C1517; Form:C1466.holdCode.Code; "")
	Form:C1466.holdDateDisplay:=String:C10(Form:C1466.holdDate)+" "+String:C10(Form:C1466.holdTime)
End if 
