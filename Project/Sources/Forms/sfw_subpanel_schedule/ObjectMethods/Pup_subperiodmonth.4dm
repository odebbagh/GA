$refmenus:=New collection:C1472()
$menu:=Create menu:C408
$refmenus.push($menu)
$m:=0
For each ($month; Form:C1466.months)
	$m:=$m+1
	APPEND MENU ITEM:C411($menu; $month)
	$newAttribute:=Substring:C12(Form:C1466.period.name; 1; 4)+String:C10($m; "00")+Substring:C12(Form:C1466.period.name; 7; 2)
	SET MENU ITEM PARAMETER:C1004($menu; -1; $newAttribute)
	If (String:C10($m; "00")=Substring:C12(Form:C1466.period.name; 5; 2))
		SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
	Else 
		If (Form:C1466.schedule[$newAttribute]#Null:C1517)
			DISABLE MENU ITEM:C150($menu; -1)
		End if 
	End if 
End for each 


$newAttribute:=Dynamic pop up menu:C1006($menu)

For each ($menu; $refmenus)
	RELEASE MENU:C978($menu)
End for each 

Case of 
	: ($newAttribute="")
	: ($newAttribute#"")
		$oldAttribute:=Form:C1466.period.name
		$objectTransfert:=OB Copy:C1225(Form:C1466.schedule[$oldAttribute])
		OB REMOVE:C1226(Form:C1466.schedule; $oldAttribute)
		Form:C1466.schedule[$newAttribute]:=$objectTransfert
		sfw_subpanel_schedule_draw($newAttribute)
		CALL SUBFORM CONTAINER:C1086(-98001)
		
End case 
