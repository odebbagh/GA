//%attributes = {}


If (True:C214)
	//Keyboard implementation
	
	$winRef:=Open form window:C675("_ga_scanInterface"; Movable dialog box:K34:7; Horizontally centered:K39:1; Vertically centered:K39:4)
	
	$form:=New object:C1471
	$form.barcodeData:=""
	$form.winRef:=$winRef
	SET WINDOW TITLE:C213("Scan the bar code"; $winRef)
	DIALOG:C40("_ga_scanInterface"; $form)
	CLOSE WINDOW:C154($winRef)
	$0:=(OK=1) ? $form.barcodeData : ""
	
	
Else 
	//Serial port implemetation
/*
$form:=$1
$OK:=_ga_openScannerSerialPort
	
If ($OK=1)
$userFined:=False
While ($form.user="") | ($userFined=False)
	
RECEIVE BUFFER($data)
	
If (Length($data)>0)
	
Case of 
	
: (Substring($data; 23)="==")
	
$data:=Uppercase(_ga_UUID22To32($data))
$form.userEntity:=ds.sfw_User.query("UUID = :1"; $data).first()
	
Else 
	
$form.userEntity:=ds.sfw_User.query("login = :1"; $data).first()
	
End case 
	
If ($form.userEntity#Null)
$form.user:=$form.userEntity.login
SET TIMER(0)
SET CHANNEL(11)
$userFined:=True
Else 
$form.user:=""
$userFined:=False
// SET TIMER(30)
End if 
	
End if 
	
End while 
	
Else 
	
SET TIMER(30)
$form.failedConnect:=$form.failedConnect+1
If ($form.failedConnect>5)
ALERT("Erreur : failed to Connect to the Scanner!Restart the app.")
SET TIMER(0)
End if 
	
//ALERT("Erreur : failed Set channel!")
End if 
	
Use ($2)
$2.result:=OB Copy($form; ck shared)  // On stocke la valeur ici
End use 
*/
End if 
