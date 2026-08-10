//%attributes = {}
Case of 
	: (FORM Event:C1606.code>-99100) & (FORM Event:C1606.code<-99000)
		$page:=Abs:C99(FORM Event:C1606.code)-99000
		FORM GOTO PAGE:C247($page; *)
End case 

