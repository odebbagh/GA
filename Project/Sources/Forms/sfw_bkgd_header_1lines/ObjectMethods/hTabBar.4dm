#DECLARE()->$return : Integer
Form:C1466.sfw.clicHTab()

If (FORM Event:C1606.code=On Scroll:K2:57)
	OBJECT SET SCROLL POSITION:C906(*; FORM Event:C1606.objectName; 0; 0)
End if 