$menu:=Create menu:C408


APPEND MENU ITEM:C411($menu; ds:C1482.sfw_readXliff("period.type.noException"; "no exception"))
SET MENU ITEM PARAMETER:C1004($menu; -1; "no")

If (Form:C1466.period.element.except#Null:C1517)
	$excepts:=Form:C1466.period.element.except
Else 
	$excepts:=New collection:C1472()
	SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
End if 

APPEND MENU ITEM:C411($menu; "-")
$d:=0
For each ($dayName; Form:C1466.days)
	$d:=$d+1
	APPEND MENU ITEM:C411($menu; $dayName)
	SET MENU ITEM PARAMETER:C1004($menu; -1; "d="+String:C10($d))
	If ($excepts.indexOf($d)#-1)
		SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
	End if 
End for each 


$ref:=Dynamic pop up menu:C1006($menu)

RELEASE MENU:C978($menu)

$attribute:=Form:C1466.period.name
Case of 
	: ($ref="")
	: ($ref="no")
		OB REMOVE:C1226(Form:C1466.schedule[$attribute]; "except")
		
	: ($ref="d=@")
		$numday:=Num:C11(Substring:C12($ref; 3))
		If (Form:C1466.schedule[$attribute].except=Null:C1517)
			Form:C1466.schedule[$attribute].except:=New collection:C1472
		End if 
		$p:=Form:C1466.schedule[$attribute].except.indexOf($numday)
		If ($p=-1)
			Form:C1466.schedule[$attribute].except.push($numday)
		Else 
			Form:C1466.schedule[$attribute].except.remove($p)
			If (Form:C1466.schedule[$attribute].except.length=0)
				OB REMOVE:C1226(Form:C1466.schedule[$attribute]; "except")
			End if 
		End if 
		
End case 

If ($ref#"")
	sfw_subpanel_schedule_draw($attribute)
	CALL SUBFORM CONTAINER:C1086(-98001)
	
End if 