//%attributes = {}

TRUNCATE TABLE:C1051([Lot:118])

var $projectFolder : 4D:C1709.Folder
var $importsFolder : 4D:C1709.Folder
var $file : 4D:C1709.File
var $records : Collection
var $record : Object
var $lot : cs:C1710.LotEntity
var $job : cs:C1710.JobEntity
var $result : Object
var $created : Integer
var $failed : Integer
var $linkedJobs : Integer
var $missingJobs : Integer
var $idToUUID : Object
var $parentLinks : Collection
var $parentLink : Object
var $parentUUID : Text

$projectFolder:=Folder:C1567(fk database folder:K87:14)
$importsFolder:=$projectFolder.folder("project/imports")
$file:=$importsFolder.file("lotinfo_export.json")

If (Not:C34($file.exists))
	ALERT:C41("Import file not found: "+$file.platformPath)
Else 
	$records:=JSON Parse:C1218($file.getText())
	$idToUUID:=New object:C1471()
	$parentLinks:=New collection:C1472()
	
	$created:=0
	$failed:=0
	$linkedJobs:=0
	$missingJobs:=0
	
	For each ($record; $records)
		$lot:=ds:C1482.Lot.new()
		$created:=$created+1
		
		// Core mapping from legacy Lotinfo to current Lot schema.
		$lot.lotNumber:=String:C10($record.Lotnum)
		$lot.dateIn:=Date:C102($record.Datein)
		$lot.dateOut:=Date:C102($record.Dateout)
		$lot.process:=String:C10($record.Process)
		$lot.ourCount:=Num:C11($record.Our_count)
		$lot.device:=String:C10($record.Device)
		$lot.totalTested:=Num:C11($record.TotalTestedOrTotalPulls)
		$lot.OQADone:=Bool:C1537($record.OQAdone)
		$lot.OQADate:=Date:C102($record.OQADate)
		$lot.OQASimpleSize:=Num:C11($record.OQASamplesize)
		$lot.location:=String:C10($record.Location)
		$lot.customerCount:=Num:C11($record.Customercount)
		$lot.dateCode:=Date:C102($record.Datecode)
		$lot.customerLotNumber:=String:C10($record.AltLotNumber)
		$lot.comment:=String:C10($record.Lot_comment)
		$lot.currentOrNextArea:=String:C10($record.CurrentOrNextArea)
		$lot.prQualifier:=String:C10($record.Pr_qualifier)
		$lot.onHold:=Bool:C1537($record.Hold)
		$lot.holdDate:=Date:C102($record.Hold_date)
		$lot.holdTime:=Num:C11($record.Hold_time)
		$lot.unitCost:=Num:C11($record.UnitCost)
		$lot.totalCharge:=Num:C11($record.TotalCharge)
		$lot.readyToShipDate:=Date:C102($record.ReadyToShipdate)
		$lot.reCommit:=Date:C102($record.Recommit_date)
		$lot.poNumber:=String:C10($record.PO_num)
		$lot.cOfCInspector:=String:C10($record.CofCInspector)
		$lot.altDevNumber:=String:C10($record.AltDevNum)
		$lot.packageType:=String:C10($record.PackageType1)
		$lot.shippingMemo:=String:C10($record.ShippingMemo)
		$lot.customer:=String:C10($record.Customer)
		$lot.deviceTableLink:=String:C10($record.LinkToDeviceTable)
		$lot.trackingNumber:=String:C10($record.ShipTrackingNumber)
		$lot.carrier:=String:C10($record.Carrier)
		$lot.cOfCRemarks:=String:C10($record.CofCText)
		$lot.shipRel:=Num:C11($record.ShipRel)
		$lot.commit:=Date:C102($record.CustomerRequestDate)
		$lot.progressive:=Num:C11($record.Progress_count)
		$lot.releaseNumber:=Num:C11($record.Recommits)
		$lot.status:=Num:C11($record.Stage)
		
		// Preserve extra legacy-only fields in moreData.
		$lot.moreData:=New object:C1471(\
			"legacyID"; $record.ID; \
			"legacyUniqueID"; $record.UniqueID; \
			"legacyDateTimeStamp"; $record.DateTimeStamp; \
			"legacyCreationDateTimeStamp"; $record.CreationDateTimeStamp; \
			"legacyRecord"; $record\
			)
		
		// Keep original UUID when legacy unique id is a valid UUID string.
		If (String:C10($record.UniqueID)#"")
			$lot.UUID:=String:C10($record.UniqueID)
		End if 
		
		// Link to Job by legacy ErpJobNumber.
		If (Num:C11($record.ErpJobNumber)>0)
			$job:=ds:C1482.Job.query("jobNumber = :1"; Num:C11($record.ErpJobNumber)).first()
			If ($job#Null:C1517)
				$lot.UUID_Job:=$job.UUID
				$linkedJobs:=$linkedJobs+1
			Else 
				$missingJobs:=$missingJobs+1
			End if 
		End if 
		
		$result:=$lot.save()
		If (Not:C34($result.success))
			$failed:=$failed+1
		Else 
			// Store id->uuid mapping for parent relinking in second pass.
			If (String:C10($record.ID)#"")
				$idToUUID[String:C10($record.ID)]:=$lot.UUID
			End if 
			
			If (String:C10($record.ParentID)#"")
				$parentLinks.push(New object:C1471(\
					"childUUID"; $lot.UUID; \
					"parentID"; String:C10($record.ParentID)\
					))
			End if 
		End if 
	End for each 
	
	// Second pass: parent lot links by legacy ParentID -> imported UUID.
	For each ($parentLink; $parentLinks)
		$parentUUID:=$idToUUID[$parentLink.parentID]
		If (String:C10($parentUUID)#"")
			$lot:=ds:C1482.Lot.query("UUID = :1"; $parentLink.childUUID).first()
			If ($lot#Null:C1517)
				$lot.UUID_LotParent:=$parentUUID
				$result:=$lot.save()
				If (Not:C34($result.success))
					$failed:=$failed+1
				End if 
			End if 
		End if 
	End for each 
	
	ALERT:C41("Import termine - created: "+String:C10($created)+" | linked jobs: "+String:C10($linkedJobs)+" | missing jobs: "+String:C10($missingJobs)+" | failed: "+String:C10($failed))
End if 
