//%attributes = {}
Case of 
	: (FORM Event:C1606.objectName#Null:C1517) && (cs:C1710[Form:C1466.sfw.entry.panel.name].me[FORM Event:C1606.objectName]#Null:C1517)
		cs:C1710[Form:C1466.sfw.entry.panel.name].me[FORM Event:C1606.objectName]()
	: (FORM Event:C1606.columnName#Null:C1517) && (cs:C1710[Form:C1466.sfw.entry.panel.name].me[FORM Event:C1606.columnName]#Null:C1517)
		cs:C1710[Form:C1466.sfw.entry.panel.name].me[FORM Event:C1606.columnName]()
End case 