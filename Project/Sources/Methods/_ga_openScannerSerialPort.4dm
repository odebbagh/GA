//%attributes = {}

/*
_ga_openScannerSerialPort

*/

ON ERR CALL:C155("_ga_scannerErrorHandler"; ek local:K92:1)

var $portNum; $setting : Integer
$setting:=0

//open the serial port
Use (Storage:C1525)
	$portNum:=Storage:C1525.cache.scannerSerailPort
End use 
//DELAY PROCESS(Current process; 60)
SET CHANNEL:C77(11)
DELAY PROCESS:C323(Current process:C322; 120)

SET CHANNEL:C77($portNum; $setting)

$0:=OK
If (OK=1)
	RECEIVE BUFFER:C172(data)
Else 
	
End if 

ON ERR CALL:C155("")

