//%attributes = {}
//%attributes = {}

TRUNCATE TABLE:C1051([PurchaseOrderLine:116])

var $projectFolder : 4D:C1709.Folder
var $importsFolder : 4D:C1709.Folder
var $file : 4D:C1709.File
var $text : Text
var $records : Collection
var $record : Object
var $line : cs:C1710.PurchaseOrderLineEntity
var $purchaseOrder : cs:C1710.PurchaseOrderEntity
var $job : cs:C1710.JobEntity
var $res : Object
var $created : Integer
var $failed : Integer
var $poNumber : Text
var $shipJobNumber : Integer
var $code : Text
var $closed : Boolean
var $uuid : Text

$projectFolder:=Folder:C1567(fk database folder:K87:14)
$importsFolder:=$projectFolder.folder("project/imports")
$file:=$importsFolder.file("poItems_export.json")

If (Not:C34($file.exists))
	ALERT:C41("Import file not found: "+$file.platformPath)
Else 
	$text:=$file.getText()
	$records:=JSON Parse:C1218($text)
	
	$created:=0
	$failed:=0
	
	For each ($record; $records)
		$line:=ds:C1482.PurchaseOrderLine.new()
		
		$poNumber:=String:C10($record.PO_number)
		$shipJobNumber:=Num:C11($record.ShipJobNumber)
		$uuid:=String:C10($record.UniqueID)
		
		$line.itemNum:=Num:C11($record.Item_num)
		$line.description:=String:C10($record.Item_Desc)
		$line.qtyOrdered:=Num:C11($record.Qty_Ordered)
		$line.dateOrdered:=$record.Date_Ordered
		$line.customerRequestedDate:=$record.CustomerRequestedDate
		$line.shipJobNumber:=$shipJobNumber
		$line.unitPrice:=Num:C11($record.Unit_Price)
		$line.unreleased:=Bool:C1537($record.void)
		$line.currency:=String:C10($record.Currency)
		$line.seqNum:=Num:C11($record.SeqNum)
		//$line.itemTypeCode:=Num($record.ItemTypeCode)
		//$line.salesSource:=String($record.SalesSource)
		$line.total:=Num:C11($record.LineItemTotal)
		
		$closed:=Bool:C1537($record.Closed) | Bool:C1537($record.Void)
		$line.closed:=$closed
		
		$code:=String:C10($record.PO_number)+"-"+String:C10($record.SeqNum)
		If ($code="")
			$code:=String:C10($record.Item_num)
		End if 
		$line.code:=$code
		
		If ($uuid#"")
			$line.UUID:=$uuid
		End if 
		
		$purchaseOrder:=Null:C1517
		If ($poNumber#"")
			$purchaseOrder:=ds:C1482.PurchaseOrder.query("poNum = :1"; $poNumber).first()
		End if 
		If ($purchaseOrder#Null:C1517)
			$line.UUID_PurchaseOrder:=$purchaseOrder.UUID
		End if 
		
		$job:=Null:C1517
		If ($shipJobNumber#0)
			$job:=ds:C1482.Job.query("jobNumber = :1"; $shipJobNumber).first()
		End if 
		If ($job#Null:C1517)
			$line.UUID_Job:=$job.UUID
		End if 
		
		$res:=$line.save()
		If ($res.success)
			$created:=$created+1
		Else 
			$failed:=$failed+1
		End if 
	End for each 
	
	ALERT:C41("PO_Items import termine. Created: "+String:C10($created)+", Failed: "+String:C10($failed))
End if 
