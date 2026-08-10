//%attributes = {}

TRUNCATE TABLE:C1051([Job:117])

var $projectFolder : 4D:C1709.Folder
var $importsFolder : 4D:C1709.Folder
var $file : 4D:C1709.File
var $records : Collection
var $record : Object
var $job : cs:C1710.JobEntity
var $purchaseOrder : cs:C1710.PurchaseOrderEntity
var $result : Object
var $created : Integer
var $updated : Integer
var $failed : Integer
var $linkedPO : Integer
var $missingPO : Integer
var $erpJobNumber : Integer
var $purchaseOrderNum : Text

$projectFolder:=Folder:C1567(fk database folder:K87:14)
$importsFolder:=$projectFolder.folder("project/imports")
$file:=$importsFolder.file("receiverJobs_export.json")

If (Not:C34($file.exists))
	ALERT:C41("Import file not found: "+$file.platformPath)
Else 
	$records:=JSON Parse:C1218($file.getText())
	
	$created:=0
	$updated:=0
	$failed:=0
	$linkedPO:=0
	$missingPO:=0
	
	For each ($record; $records)
		$erpJobNumber:=Num:C11($record.ErpJobNumber)
		$purchaseOrderNum:=$record.Purchase_Order
		
		If ($erpJobNumber<=0)
			$failed:=$failed+1
		Else 
			$job:=ds:C1482.Job.query("jobNumber = :1"; $erpJobNumber).first()
			
			If ($job=Null:C1517)
				$job:=ds:C1482.Job.new()
				$created:=$created+1
			Else 
				$updated:=$updated+1
			End if 
			
			$job.jobNumber:=$erpJobNumber
			
			$purchaseOrder:=Null:C1517
			If ($purchaseOrderNum#"")
				$purchaseOrder:=ds:C1482.PurchaseOrder.query("poNum = :1"; $purchaseOrderNum).first()
			End if 
			
			If ($purchaseOrder#Null:C1517)
				// Establish Job -> PurchaseOrder relation through UUID link.
				$job.UUID_PurchaseOrder:=$purchaseOrder.UUID
				$job.poNumber:=Num:C11($purchaseOrder.poNumber)
				If ($job.UUID_Customer=(16*"00")) || ($job.UUID_Customer="")
					$job.UUID_Customer:=$purchaseOrder.UUID_Customer
				End if 
				$linkedPO:=$linkedPO+1
			Else 
				$missingPO:=$missingPO+1
				$job.poNumber:=Num:C11($purchaseOrderNum)
			End if 
			
			$result:=$job.save()
			If (Not:C34($result.success))
				$failed:=$failed+1
			End if 
		End if 
	End for each 
	
	ALERT:C41("Import termine - created: "+String:C10($created)+" | updated: "+String:C10($updated)+" | linked PO: "+String:C10($linkedPO)+" | missing PO: "+String:C10($missingPO)+" | failed: "+String:C10($failed))
End if 
