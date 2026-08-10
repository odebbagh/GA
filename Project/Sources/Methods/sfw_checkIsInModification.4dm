//%attributes = {}
#DECLARE()->$isInModification : Boolean
If (Form:C1466.situation#Null:C1517)
	$isInModification:=((String:C10(Form:C1466.situation.mode)="modify") | (String:C10(Form:C1466.situation.mode)="add") | (String:C10(Form:C1466.situation.mode)="duplicate")) & (Bool:C1537(Form:C1466.notEditable)=False:C215)
Else 
	$isInModification:=False:C215
End if 