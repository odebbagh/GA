//%attributes = {}

var $cell : Object
var $docFolder : cs:C1710.sfw_DocumentFolderEntity
var $docFolders : cs:C1710.sfw_DocumentFolderSelection
var $model : cs:C1710.sfw_DocumentModelEntity
var $modelName : Text
var $range : Object
var $res : Object
var $rowHeader : Object
var $row : Object
var $table : Object
var $wpDoc : Object

$modelName:="Job Lots Summary WP"

// Put model in "Documents management" folder when available
$docFolder:=ds:C1482.sfw_DocumentFolder.query("name = :1"; "Documents management").first()
If ($docFolder=Null:C1517)
	$docFolders:=ds:C1482.sfw_DocumentFolder.all().orderBy("name asc")
	If ($docFolders.length>0)
		$docFolder:=$docFolders.first()
	End if 
End if 

If ($docFolder=Null:C1517)
	ALERT:C41("No sfw_DocumentFolder found. Create a document folder first.")
Else 
	$model:=ds:C1482.sfw_DocumentModel.query("name = :1"; $modelName).first()
	If ($model=Null:C1517)
		$model:=ds:C1482.sfw_DocumentModel.new()
	End if 
	
	$model.name:=$modelName
	$model.UUID_DocumentFolder:=$docFolder.UUID
	$model.type:=2  // 4D Write Pro
	$model.moreData:=($model.moreData=Null:C1517) ? New object:C1471() : $model.moreData
	$model.moreData.documentNameFormula:="\"Job Lots - \"+$data.jobNumber"
	$model.moreData.documentPrecalculationMethod:=\
"$data.jobNumber:=String(This.jobNumber)\r\
$lots:=This.lots.orderBy(\"lotNumber asc\")\r\
$lines:=New collection\r\
For each ($lot; $lots)\r\
\t$line:=String($lot.lotNumber)\r\
\tIf ($line#\"\")\r\
\t\t$lines.push($line)\r\
\tEnd if \r\
End for each \r\
$data.lotNumbers:=$lines.join(\"; \")\r\
$wpDoc:=WP New()\r\
$range:=WP Text range($wpDoc; wk start text; wk end text)\r\
$table:=WP Insert table($range; wk append; wk include in range)\r\
$headerRow:=WP Table append row($table; \"Job Number\"; \"Lot Numbers related\")\r\
WP Table append row($table; String($data.jobNumber); String($data.lotNumbers))\r\
$data.wpArea:=$wpDoc"
	
	// Minimal placeholder model area (real content is built in documentPrecalculationMethod)
	$wpDoc:=WP New:C1317()
	$range:=WP Text range:C1341($wpDoc; wk start text:K81:165; wk end text:K81:164)
	$table:=WP Insert table:C1473($range; wk append:K81:179; wk include in range:K81:180)
	
	$rowHeader:=WP Table append row:C1474($table; "Job Number"; "Lot Numbers related")
	$row:=WP Table append row:C1474($table; "<dynamic>"; "<dynamic>")
	
	$model.area:=$wpDoc
	
	$res:=$model.save()
	If ($res.success)
		ALERT:C41("Write Pro model created/updated: "+$model.name+"\rFolder: "+$docFolder.name)
	Else 
		ALERT:C41("Failed to save model: "+$res.statusText)
	End if 
End if 
