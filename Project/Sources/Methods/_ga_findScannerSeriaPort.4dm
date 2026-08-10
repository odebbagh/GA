//%attributes = {}
/*
_ga_findScannerSeriaPort : Find the port to use for scannaning
4D PS :: 16-Jan-2026
*/

var $commandLine; $output; $in; $serialPort : Text
var $portNumber : Integer
var ports : Collection:=New collection:C1472()
var $result : Collection:=New collection:C1472()
var $form : Object:=New object:C1471()
var $continue : Boolean:=False:C215

$callChain:=Call chain:C1662

If ($callChain.length>1)
	
	$caller:=$callChain[1].name
	
End if 


If (Count parameters:C259=0)
	
	//GET SERIAL PORT MAPPING($numArr; $nameArr)
	// --- 1. Executer PowerShell command ---
	$commandLine:="powershell Get-CimInstance Win32_SerialPort | Where-Object { (($_.PNPDeviceID -like '*USB*') -or ($_.PNPDeviceID -like '*BTHENUM*')) -and ($_.PNPDeviceID-like '*VID*') }  | ForEach-Object { $_.DeviceID +':'+ $_.Name }"
	//"powershell Get-CimInstance Win32_SerialPort | Where-Object { $_.PNPDeviceID -like '*VID*' } | ForEach-Object { $_.DeviceID +':'+ $_.Name }"
	//"powershell Get-CimInstance Win32_SerialPort | Where-Object { $_.PNPDeviceID -like '*VID*' } | Select-Object -ExpandProperty DeviceID"
	//"powershell Get-WmiObject Win32_SerialPort | Where-Object { $_.PNPDeviceID -like '*VID*' } | Select-Object DeviceID | Format-List"
	SET ENVIRONMENT VARIABLE:C812("_4D_OPTION_HIDE_CONSOLE"; "true")
	LAUNCH EXTERNAL PROCESS:C811($commandLine; $in; $output; $error; $pid)
	
	$result:=Split string:C1554(Replace string:C233($output; "\r"; ""); "\n"; sk ignore empty strings:K86:1+sk trim spaces:K86:2)
	If ($result.length=1)
		
		ports:=Split string:C1554($result[0]; ":"; sk ignore empty strings:K86:1+sk trim spaces:K86:2)
		$serialPort:=ports[0]
		//$continue:=True
	Else 
		
		//If ($caller="")
		
		For ($i; 0; $result.length-1)
			
			$splitResult:=Split string:C1554($result[$i]; ":"; sk ignore empty strings:K86:1+sk trim spaces:K86:2)
			ports[$i]:=New object:C1471("deviceID"; $splitResult[0]; "name"; $splitResult[1])
			
		End for 
		
		$form.ports:=ports
		$winRef:=Open form window:C675("_ga_selectSerialPort"; Movable dialog box:K34:7; Horizontally centered:K39:1; Vertically centered:K39:4)
		//SET WINDOW TITLE("Select the Scanner Port"; $winRef)
		DIALOG:C40("_ga_selectSerialPort"; $form)
		CLOSE WINDOW:C154($winRef)
		
		If (OK=1)
			$selectedPort:=$form.currentSelectedPort
			
			If ($selectedPort.length=1)
				
				$serialPort:=$selectedPort[0].deviceID
			Else 
				
				ALERT:C41("No Serial Port Selected")
				
			End if 
			
		End if 
		
		//$continue:=True
		
		//End if 
		
	End if 
	
Else 
	
	$serialPort:=$1
End if 
// --- 2. Find the port Number ---
$portNumber:=100+Num:C11(Substring:C12($serialPort; 4))

// --- 3. Save in the cache ---
If (Storage:C1525.cache=Null:C1517)
	Use (Storage:C1525)
		Storage:C1525.cache:=New shared object:C1526
	End use 
End if 
If (Storage:C1525.cache.scannerSerailPort=Null:C1517) | ($caller="_ga_login.bHelp")
	Use (Storage:C1525.cache)
		Storage:C1525.cache.scannerSerailPort:=$portNumber
	End use 
End if 

