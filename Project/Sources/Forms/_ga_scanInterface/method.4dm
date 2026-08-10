

Case of 
		
	: (Form event code:C388=On Load:K2:1)
		Form:C1466.manualEntry:=False:C215
		Use (Storage:C1525)
			Storage:C1525.scanner:=New shared object:C1526("scanBuffer"; ""; "scanStartTime"; 0; "currentWindow"; Form:C1466.winRef)
		End use 
		
		READ PICTURE FILE:C678(Get 4D folder:C485(Current resources folder:K5:16)+Folder separator:K24:12+"image"+Folder separator:K24:12+"button"+Folder separator:K24:12+"barcode.png"; image)
		
		ON EVENT CALL:C190("_ga_scanningEventHandler")
		
	: (Form event code:C388=On Timer:K2:25)
		//Serial port implementation
		
		//ON EVENT CALL("_ga_scanningEventHandler")
		//$data:=""
		//While ($data="")
		
		//RECEIVE BUFFER($data)
		
		//End while 
		//Form.barcodeData:=$data
		//SET TIMER(0)
		
		//ACCEPT
		
	: (Form event code:C388=On Unload:K2:2)
		Use (Storage:C1525.scanner)
			Form:C1466.barcodeData:=Storage:C1525.scanner.scanBuffer
			
		End use 
		ON EVENT CALL:C190("")
End case 

