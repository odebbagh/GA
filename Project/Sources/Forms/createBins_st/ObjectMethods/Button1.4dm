Case of 
		//: (Form.binDefinition.num=0)
		//ALERT("Select a bin number !")
		
		//: (Form.binDefinition.definition="")
		//ALERT("Enter a bin definition !")
		
		//: (Form.binType.index=-1)
		//ALERT("Select a bin type !")
		
		
	Else 
		Form:C1466.binDefinition.num:=Form:C1466.bin.currentValue
		Form:C1466.binDefinition.type:=Form:C1466.binType.currentValue
		ACCEPT:C269
End case 