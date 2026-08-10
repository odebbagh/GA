//%attributes = {}
/*
Method Name : _ga_usageLogReport()
Author : Medard /4D PS
Date : 29-May-2025
Purpose : This method Display the equipment Usage Log for Printing
*/

var $wp : Object
var $OK : Boolean
var $lotStepSelection : cs:C1710.LotStepSelection
var $entityCollection : Collection
var $range : Object
var $isDataExist : Boolean

$range:=New object:C1471()
$entityCollection:=New collection:C1472()
$wp:=WP New:C1317()
$OK:=False:C215

cs:C1710.Util.me.setDateInterval(True:C214; "set date interval")

$OK:=cs:C1710.sfw_dialog.me.confirm("Print Usage Log for "+Form:C1466.current_item.assignedID+"  Period "+String:C10(Storage:C1525.cache.startDate)+" to "+String:C10(Storage:C1525.cache.endDate)+"? "; "yes"; "no")

If ($OK)
	
	$lotStepSelection:=ds:C1482.LotStep.query("dateIn>=:1 & dateOut<=:2 & type#:3 & type#:4 & type#:5"; Storage:C1525.cache.startDate; Storage:C1525.cache.endDate; 9; 10; 540)
	
	For each ($lotStep; $lotStepSelection)
		If ($lotStep.tools#Null:C1517)
			$toolItems:=$lotStep.tools.items
			
			
			If ($toolItems.indexOf(String:C10(Form:C1466.current_item.assignedID+"@"))#-1)
				
				$entityCollection.push($lotStep)
				
			End if 
		End if 
	End for each 
	
	SET PRINT OPTION:C733(Orientation option:K47:2; 2)
	
	WP SET ATTRIBUTES:C1342($wp; wk font bold:K81:68; False:C215; wk font size:K81:66; 9; wk font family:K81:65; "Times New Roman"; wk text align:K81:49; wk left:K81:95)
	
	$Maxcount:=20
	$isDataExist:=False:C215
	For ($dateID; 0; Num:C11(Storage:C1525.cache.interval))
		$currentDate:=Storage:C1525.cache.startDate+$dateID
		$data:=$entityCollection.query("dateIn=:1"; $currentDate)
		
		If ($data.length>0)
			$isDataExist:=True:C214
			
			$range:=WP Text range:C1341($wp; wk end text:K81:164; wk end text:K81:164)
			
			
			WP SET TEXT:C1574($range; String:C10($currentDate); wk append:K81:179)
			
			WP SET ATTRIBUTES:C1342($range; wk font bold:K81:68; True:C214; wk font size:K81:66; 15; wk font family:K81:65; "Times New Roman"; wk text align:K81:49; wk left:K81:95; wk text underline style:K81:73; wk solid:K81:115)
			
			$range:=WP Text range:C1341($wp; wk end text:K81:164; wk end text:K81:164)
			WP SET ATTRIBUTES:C1342($range; wk font bold:K81:68; False:C215; wk font size:K81:66; 9; wk font family:K81:65; "Times New Roman"; wk text align:K81:49; wk left:K81:95; wk text underline style:K81:73; wk none:K81:91)
			$table:=WP New:C1317()
			$table:=WP Insert table:C1473($range; wk append:K81:179)
			
			// insert header
			$row:=WP Table append row:C1474($table; "IN"; "Date Out"; "AT"; "Lot#"; "Step description"; "Qty-in"; "Qty-Out"; "Tool* CalDate"; "Opre-In"; "Oper_Out")
			
			
			$Count:=0
			//insert rows
			For each ($entity; $data)
				$Count:=$Count+1
				$row:=WP Table append row:C1474($table; String:C10(Time:C179($entity.timeIn); HH MM:K7:2); String:C10($entity.dateOut; System date short:K1:1); String:C10(Time:C179($entity.timeOut); HH MM:K7:2); String:C10($entity.lot.lotNumber); $entity.description; String:C10($entity.qtyIn); String:C10($entity.qtyOut); $entity.tools.items[$entity.tools.items.indexOf(String:C10(Form:C1466.current_item.assignedID+"@"))]; $entity.inOperator; $entity.outOperator)
				
				$position1:=1
				$position2:=Position:C15("\t"; WP Get text:C1575($row); 1; *)
				
				
				$position3:=Position:C15("\t"; WP Get text:C1575($row); $position2+2; *)
				$position4:=Position:C15("\t"; WP Get text:C1575($row); $position3+1; *)
				$position5:=Position:C15("\t"; WP Get text:C1575($row); $position4+1; *)
				
				$linkRange:=WP Text range:C1341($row; $position4; $position5)
				$link:=New object:C1471("method"; "_ga_WPLink_To_Lot"; "parameter"; String:C10($entity.lot.lotNumber))  //Don't forget to authorize with SET ALLOWED METHODS  
				WP SET LINK:C1642($linkRange; $link)
				
			End for each 
			If ($Count<$Maxcount) & ($PageBreak=1)  // ADD BLANK LINES
				Repeat 
					$Trow:=WP Table append row:C1474($table; ""; ""; ""; ""; ""; ""; ""; ""; ""; "")
					$Count:=$Count+1
				Until ($Count>=$Maxcount)
			End if 
			
			
			//set size,font family & color
			$col:=WP Table get columns:C1476($table; 1; 1)
			WP SET ATTRIBUTES:C1342($col; wk width:K81:45; "25pt"; wk font bold:K81:68; False:C215)
			$col:=WP Table get columns:C1476($table; 2; 1)
			WP SET ATTRIBUTES:C1342($col; wk width:K81:45; "50pt"; wk font bold:K81:68; False:C215)
			$col:=WP Table get columns:C1476($table; 3; 1)
			WP SET ATTRIBUTES:C1342($col; wk width:K81:45; "25pt"; wk font bold:K81:68; False:C215)
			$col:=WP Table get columns:C1476($table; 4; 1)
			WP SET ATTRIBUTES:C1342($col; wk width:K81:45; "90pt"; wk font bold:K81:68; False:C215)
			$col:=WP Table get columns:C1476($table; 5; 1)
			WP SET ATTRIBUTES:C1342($col; wk width:K81:45; "180pt"; wk font bold:K81:68; False:C215)
			$col:=WP Table get columns:C1476($table; 6; 1)
			WP SET ATTRIBUTES:C1342($col; wk width:K81:45; "35pt"; wk font bold:K81:68; False:C215)
			$col:=WP Table get columns:C1476($table; 7; 1)
			WP SET ATTRIBUTES:C1342($col; wk width:K81:45; "35pt"; wk font bold:K81:68; False:C215)
			$col:=WP Table get columns:C1476($table; 8; 1)
			WP SET ATTRIBUTES:C1342($col; wk width:K81:45; "120pt"; wk font bold:K81:68; False:C215)
			$col:=WP Table get columns:C1476($table; 9; 1)
			WP SET ATTRIBUTES:C1342($col; wk width:K81:45; "40pt"; wk font bold:K81:68; False:C215)
			$col:=WP Table get columns:C1476($table; 10; 1)
			WP SET ATTRIBUTES:C1342($col; wk width:K81:45; "40pt"; wk font bold:K81:68; False:C215)
			
			WP SET ATTRIBUTES:C1342($table; wk font family:K81:65; "New Times Roman")
			WP SET ATTRIBUTES:C1342($table; wk font size:K81:66; 9; wk text underline style:K81:73; wk none:K81:91)
			$row:=WP Table get rows:C1475($table; 1)
			WP SET ATTRIBUTES:C1342($row; wk font bold:K81:68; True:C214; wk font size:K81:66; 9)
			
			WP SET TEXT:C1574($wp; Char:C90(Carriage return:K15:38); wk append:K81:179)
			
			
		End if 
		
	End for 
	
	If (Not:C34($isDataExist))
		$range:=WP Text range:C1341($wp; wk end text:K81:164; wk end text:K81:164)
		WP SET ATTRIBUTES:C1342($range; wk font family:K81:65; "New Times Roman")
		WP SET ATTRIBUTES:C1342($range; wk font size:K81:66; 12; wk text underline style:K81:73; wk none:K81:91; wk font bold:K81:68; wk true:K81:174)
		WP SET TEXT:C1574($wp; Char:C90(Carriage return:K15:38); wk append:K81:179)
		WP SET TEXT:C1574($wp; "There is no usage Log for this period"; wk append:K81:179)
		WP SET TEXT:C1574($wp; Char:C90(Carriage return:K15:38); wk append:K81:179)
		
		$range:=WP Text range:C1341($wp; wk end text:K81:164; wk end text:K81:164)
		WP SET ATTRIBUTES:C1342($range; wk font size:K81:66; 9; wk text underline style:K81:73; wk none:K81:91)
	End if 
	
	$title:="Equipment Log. for "+String:C10(Form:C1466.current_item.assignedID)+" from "+String:C10(Storage:C1525.cache.startDate)+" to "+String:C10(Storage:C1525.cache.endDate)
	$form:=New object:C1471
	
	$form.wp:=$wp
	$form.title:=$title
	$winRef:=Open form window:C675("_ga_usageLogPreview"; Plain form window:K39:10; Horizontally centered:K39:1; Vertically centered:K39:4)
	DIALOG:C40("_ga_usageLogPreview"; $form)
	CLOSE WINDOW:C154($winRef)
	
	
End if 
