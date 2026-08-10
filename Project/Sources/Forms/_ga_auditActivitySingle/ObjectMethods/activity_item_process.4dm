
If (Storage:C1525.cache=Null:C1517) || (Storage:C1525.cache.processTypes=Null:C1517)
	ds:C1482.ProcessType.cacheLoad()
End if 

Form:C1466.process:=""
$menu:=Create menu:C408

For each ($process; Storage:C1525.cache.processTypes.extract("name"))
	APPEND MENU ITEM:C411($menu; $process; *)
	SET MENU ITEM PARAMETER:C1004($menu; -1; $process)
	If ($process=Form:C1466.process)
		SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
	End if 
End for each 

$choose:=Dynamic pop up menu:C1006($menu)
RELEASE MENU:C978($menu)

Case of 
	: ($choose="")
		
	Else 
		Form:C1466.process:=$choose
		
End case 


OBJECT SET TITLE:C194(*; "activity_item_process"; Form:C1466.process)