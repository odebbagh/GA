

Case of 
		
	: (Form event code:C388=On Clicked:K2:4)
		
		$refMenu:=Create menu:C408
		APPEND MENU ITEM:C411($refMenu; "select scanner seral port")
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--selectPort")
		
		$choose:=Dynamic pop up menu:C1006($refMenu)
		
		Case of 
			: ($choose="--selectPort")
				
				var $commandLine; $output; $in : Text
				var $ports : Collection:=New collection:C1472()
				
				$commandLine:="powershell Get-CimInstance Win32_SerialPort | Where-Object { (($_.PNPDeviceID -like '*USB*') -or ($_.PNPDeviceID -like '*BTHENUM*')) -and ($_.PNPDeviceID-like '*VID*') }  | ForEach-Object { $_.DeviceID +':'+ $_.Name }"
				
				SET ENVIRONMENT VARIABLE:C812("_4D_OPTION_HIDE_CONSOLE"; "true")
				LAUNCH EXTERNAL PROCESS:C811($commandLine; $in; $output; $error; $pid)
				
				$result:=Split string:C1554($output; "\r\n"; sk ignore empty strings:K86:1+sk trim spaces:K86:2)
				
				For ($i; 0; $result.length-1)
					
					$splitResult:=Split string:C1554($result[$i]; ":"; sk ignore empty strings:K86:1+sk trim spaces:K86:2)
					ports[$i]:=New object:C1471("deviceID"; $splitResult[0]; "name"; $splitResult[1])
					
				End for 
				
				var $form : Object:=New object:C1471()
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
						
						ALERT:C41("SELECT ONLY ONE PORT")
						
					End if 
					
				End if 
				
				//$portsList:=$ports.join(";")
				//MOUSE POSITION(mX; mY; $mouseBtn)
				//$choice:=Pop up menu($portsList; mX; mY)
				
				If ($serialPort#"")
					_ga_findScannerSeriaPort($serialPort)
					//_ga_openScannerSerialPort
					SET TIMER:C645(1)
				End if 
				
		End case 
		
	Else 
		
End case 