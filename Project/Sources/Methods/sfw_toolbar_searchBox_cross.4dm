//%attributes = {}
Form:C1466.sfw.searchbox:=""
GOTO OBJECT:C206(*; "")
$refWindow:=Num:C11(Storage:C1525.windows.globalSearch)
If ($refWindow#0)
	CALL FORM:C1391($refWindow; "sfw_globalSearchManager"; "close")
End if 