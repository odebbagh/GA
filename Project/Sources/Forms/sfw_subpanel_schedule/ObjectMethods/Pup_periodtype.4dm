$menu:=Create menu:C408


APPEND MENU ITEM:C411($menu; ds:C1482.sfw_readXliff("period.type.work"; "Work"))
SET MENU ITEM PARAMETER:C1004($menu; -1; "work")
If (Form:C1466.period.type="work")
	SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
End if 

APPEND MENU ITEM:C411($menu; ds:C1482.sfw_readXliff("period.type.bankHoliday"; "Bank Holiday"))
SET MENU ITEM PARAMETER:C1004($menu; -1; "bankHoliday")
If (Form:C1466.period.type="bankHoliday")
	SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
End if 

APPEND MENU ITEM:C411($menu; ds:C1482.sfw_readXliff("period.type.holiday"; "Holiday"))
SET MENU ITEM PARAMETER:C1004($menu; -1; "holiday")
If (Form:C1466.period.type="holiday")
	SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
End if 

$ref:=Dynamic pop up menu:C1006($menu)

RELEASE MENU:C978($menu)

$attribute:=Form:C1466.period.name
$newAttribute:=""
Case of 
	: ($ref="")
	: ($ref="work")
		If (Form:C1466.schedule[$attribute].work=Null:C1517)
			Form:C1466.schedule[$attribute].work:=New collection:C1472(32400; 43200; 50400; 61200)
		End if 
		OB REMOVE:C1226(Form:C1466.schedule[$attribute]; "bankHoliday")
		OB REMOVE:C1226(Form:C1466.schedule[$attribute]; "holiday")
		
	: ($ref="bankHoliday")
		Form:C1466.schedule[$attribute].bankHoliday:=True:C214
		OB REMOVE:C1226(Form:C1466.schedule[$attribute]; "work")
		OB REMOVE:C1226(Form:C1466.schedule[$attribute]; "holiday")
		
	: ($ref="holiday")
		Form:C1466.schedule[$attribute].holiday:=True:C214
		OB REMOVE:C1226(Form:C1466.schedule[$attribute]; "work")
		OB REMOVE:C1226(Form:C1466.schedule[$attribute]; "bankHoliday")
		
End case 

If ($ref#"")
	sfw_subpanel_schedule_draw($attribute)
	CALL SUBFORM CONTAINER:C1086(-98001)
	
End if 