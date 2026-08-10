Case of 
	: (FORM Event:C1606.code=-2000)
		//TRACE
		OBJECT SET VISIBLE:C603(*; "sf_stepTemplateSearch"; False:C215)
		
		If (Form:C1466.sf_stepTemplateSearch.selectedItem#Null:C1517)
			Form:C1466.searchStep:=Form:C1466.sf_stepTemplateSearch.selectedItem.description
			
			Form:C1466.lotStep.alert:=Form:C1466.sf_stepTemplateSearch.selectedItem.alert
			Form:C1466.lotStep.description:=Form:C1466.sf_stepTemplateSearch.selectedItem.description
		End if 
		
	: (FORM Event:C1606.code=-3000)
		OBJECT SET VISIBLE:C603(*; "sf_stepTemplateSearch"; False:C215)
		OBJECT SET SUBFORM:C1138(*; "sf_stepTemplateSearch"; "")
End case 