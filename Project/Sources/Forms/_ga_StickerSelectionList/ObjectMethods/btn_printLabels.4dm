
/*
Print Cal Stickers 

*/


Case of 
		
	: (Form event code:C388=On Clicked:K2:4)
		
		var $wpDoc : Object
		
		If (Form:C1466.lb_currentEquipment#Null:C1517)
			//No template used Generate the sticker by code
			var $equipmentSelection : cs:C1710.EquipmentSelection
			
			$wpDoc:=WP New:C1317()
			
			SET PRINT OPTION:C733(Orientation option:K47:2; 1)
			
			$equipmentSelection:=Form:C1466.lb_selectedEquipments
			
			$start:=0
			$end:=34
			$line:=1
			$column:=1
			$verOffSet:=1
			$horOffSet:=0.5
			
			
			For ($i; 0; $equipmentSelection.length-1)
				
				If ($i%3=0) & ($i#0)
					
					$verOffSet:=$verOffSet+4
					$line:=$line+1
					$column:=1
					$horOffSet:=0.5
				Else 
					If ($i#0)
						$horOffSet:=$horOffSet+6.8
						$column:=$column+1
					End if 
				End if 
				
				
				If ($line%7=0)
					WP INSERT BREAK:C1413($wpDoc; wk page break:K81:188; wk append:K81:179)
					$line:=1
					$column:=1
					$verOffSet:=1
					$horOffSet:=0.5
				End if 
				
				$count:=WP Get page count:C1412($wpDoc)
				
				$textBox:=WP New text box:C1797($wpDoc; $count)
				WP SET ATTRIBUTES:C1342($textBox; wk id:K81:193; "textBox"+String:C10($i))
				WP SET ATTRIBUTES:C1342($textBox; wk width:K81:45; "175pt")
				WP SET ATTRIBUTES:C1342($textBox; wk height:K81:46; "90pt")
				WP SET ATTRIBUTES:C1342($textBox; wk border style:K81:29; wk none:K81:91; wk border color:K81:34; "white")
				WP SET ATTRIBUTES:C1342($textBox; wk anchor horizontal align:K81:237; wk left:K81:95)
				WP SET ATTRIBUTES:C1342($textBox; wk anchor horizontal offset:K81:236; $horOffSet)
				WP SET ATTRIBUTES:C1342($textBox; wk anchor vertical offset:K81:238; $verOffSet)
				
				$range:=WP Text range:C1341($textBox; wk end text:K81:164; wk end text:K81:164)
				
				$table:=WP New:C1317()
				$table:=WP Insert table:C1473($range; wk append:K81:179)
				
				//insert rows
				$row:=WP Table append row:C1474($table; "ERP ID"; $equipmentSelection[$i].assignedID)
				$row:=WP Table append row:C1474($table; "Model"; $equipmentSelection[$i].model)
				$row:=WP Table append row:C1474($table; "Serial #"; $equipmentSelection[$i].serialNumber)
				$row:=WP Table append row:C1474($table; "Last cal date"; String:C10($equipmentSelection[$i].lastCalDate)+" by "+String:C10($equipmentSelection[$i].calTech))
				$row:=WP Table append row:C1474($table; "Cal dur Date"; String:C10($equipmentSelection[$i].nextCalDate))
				
				//set size , font family & color
				$col:=WP Table get columns:C1476($table; 1; 1)
				WP SET ATTRIBUTES:C1342($col; wk width:K81:45; "50pt")
				WP SET ATTRIBUTES:C1342($table; wk font family:K81:65; "New Times Roman")
				WP SET ATTRIBUTES:C1342($table; wk font size:K81:66; 8)
				WP SET ATTRIBUTES:C1342($table; wk text color:K81:64; "black")
				
				$start:=$start+34
				$end:=$end+34
				
			End for 
			
			PRINT SETTINGS:C106(2)
			WP PRINT:C1343($wpDoc)
			
			
		Else 
			
			//Old WAY USING THE TEMPLATE
/*
var $context; $options : Object
var $targetObj; $_wpDoc : Object
$wpDoc:=WP New()
$_wpDoc:=WP New()
$context:=New object()
$options:=New object()
var $nbrBegin; $nbrToEvaluate; $nbrOfPages : Integer
			
$file:=Folder(fk resources folder).file("4DWriteProPrintTemplates/equipmentSticker.4wp")
			
//$options.anchoredTextAreas:="inline"
			
$template:=WP Import document($file.platformPath)  //; $options)
			
$context:=Form.lb_selectedEquipments
			
$nbrEquipments:=$context.length
			
$nbrOfPages:=$nbrEquipments/21
If ($nbrEquipments%21>0)
$nbrOfPages:=$nbrOfPages+1
End if 
			
OPEN PRINTING JOB
			
For ($k; 1; $nbrOfPages)
			
$template:=WP Import document($file.platformPath)  //; $options)
			
If ($k=$nbrOfPages)
If ($nbrEquipments%21>0)
$nbrToEvaluate:=($nbrEquipments%21)
End if 
Else 
$nbrToEvaluate:=21
End if 
If ($k=1)
$nbrBegin:=0
$end:=21
Else 
$nbrBegin:=$end
$end:=$end+21
End if 
			
$_context:=$context.slice($nbrBegin; $end)
WP SET DATA CONTEXT($template; $_context)
			
			
For ($i; $nbrToEvaluate; 20)
			
$textbox:=WP Get elements($template; wk type text box)[$i]
WP SET TEXT($textbox; ""; wk replace)
			
End for 
			
WP PRINT($template)
			
End for 
			
CLOSE PRINTING JOB
			
//WP COMPUTE FORMULAS($template)
//WP FREEZE FORMULAS($template; wk do not recompute expressions)
			
//WP INSERT DOCUMENT($wpDoc; $template; wk append)
			
//PRINT SETTINGS(2)
//WP PRINT($wpDoc)
			
*/
			cs:C1710.sfw_dialog.me.info(ds:C1482.sfw_readXliff("Info"; "Select equipments for stickers printing"))
			
		End if 
		
End case 

