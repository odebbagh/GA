Case of 
	: (FORM Event:C1606.code=On Clicked:K2:4)
		If (Form:C1466.sf_templateSearch.selectedItem#Null:C1517)
			Form:C1466.sf_stepTemplateSearch:=New object:C1471(\
				"colName"; "description"; \
				"lb_values"; Form:C1466.sf_templateSearch.selectedItem.steps\
				)
			
			OBJECT SET SUBFORM:C1138(*; "sf_stepTemplateSearch"; "searchOnList")
			OBJECT SET VISIBLE:C603(*; "sf_stepTemplateSearch"; True:C214)
		Else 
			cs:C1710.sfw_dialog.me.alert("No Template selected !")
		End if 
	: (FORM Event:C1606.code=On Mouse Enter:K2:33)
		SET CURSOR:C469(9000)
	: (FORM Event:C1606.code=On Mouse Leave:K2:34)
		SET CURSOR:C469()
		
End case 