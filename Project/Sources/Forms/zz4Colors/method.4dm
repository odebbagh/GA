Case of 
	: (FORM Event:C1606.code=On Load:K2:1)
		
		Form:C1466.hl:=New list:C375
		
		$sublist:=New list:C375
		APPEND TO LIST:C376($sublist; "Titouan"; 1)
		APPEND TO LIST:C376($sublist; "Alexiane"; 2)
		
		APPEND TO LIST:C376(Form:C1466.hl; "childrens"; 3; $sublist; True:C214)
		
		SELECT LIST ITEMS BY REFERENCE:C630(Form:C1466.hl; 2)
		
	: (FORM Event:C1606.code=On Unload:K2:2)
		CLEAR LIST:C377(Form:C1466.hl; *)
		
End case 
