//%attributes = {}



var $wpDoc : Object
var $context : Object
var $reportLogs : Collection
var $meanTbf; $minTbf; $maxTbf : Real

$reportLogs:=New collection:C1472()
$meanTbf:=0
$minTbf:=0
$maxTbf:=0
$wpDoc:=WP New:C1317()

$context:=New object:C1471()

$file:=Folder:C1567(fk resources folder:K87:11).file("4DWriteProPrintTemplates/equipmentRepairLog.4wp")
$wpDoc:=WP Import document:C1318($file.platformPath)
SET PRINT OPTION:C733(Orientation option:K47:2; 1)

$reportLogs:=Form:C1466.current_item.repairLogs.toCollection().orderBy("reportDate asc, downAt asc")
If ($reportLogs.length>0)
	$down_time:=Round:C94($reportLogs.sum("downHrs"); 2)
	$uptime:=0
	$uptime:=Round:C94(_ga_up_time($reportLogs[0].reportDate; Current date:C33(*); $down_time); 2)
	$adate:=$reportLogs.extract("reportDate")
	$atime:=$reportLogs.extract("downAt")
	Case of 
		: ($adate.length-1>0)
			ARRAY REAL:C219($atbf; $adate.length-1)
			For ($i; 1; $adate.length-1)
				$atbf{$i}:=_ga_time2hrs($adate[$i-1]; $atime[$i-1]; $adate[$i]; $atime[$i])
				$meanTbf:=$meanTbf+$atbf{$i}
			End for 
			$meanTbf:=Round:C94($meanTbf/$adate.length-1; 2)
			SORT ARRAY:C229($atbf; >)
			$minTbf:=Round:C94($atbf{1}; 2)
			$maxTbf:=Round:C94($atbf{Size of array:C274($atbf)}; 2)
	End case 
	
	
	$context.assignedID:=Form:C1466.current_item.assignedID
	$context.meanTbf:=$meanTbf
	$context.minTbf:=$minTbf
	$context.maxTbf:=$maxTbf
	$context.upTime:=$uptime
	$context.downTime:=$down_time
	
	WP SET DATA CONTEXT:C1786($wpDoc; $context)
	
	PRINT SETTINGS:C106(2)
	WP PRINT:C1343($wpDoc)
	
Else 
	
	
End if 



