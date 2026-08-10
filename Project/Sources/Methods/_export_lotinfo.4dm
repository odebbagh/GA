//%attributes = {}

var $records : Collection
var $record : Object
var $lots : 4D.EntitySelection
var $lot : 4D.Entity
var $lotInfoDataClass : 4D.DataClass
var $resourcesFolder : 4D.Folder
var $exportsFolder : 4D.Folder
var $file : 4D.File

$records:=New collection()

$lotInfoDataClass:=ds["Lotinfo"]

If ($lotInfoDataClass=Null)
	ALERT("DataClass Lotinfo not found.")
Else 
	$lots:=$lotInfoDataClass.all()
	
	For each ($lot; $lots)
		$record:=New object()
		$record.Lotnum:=$lot.Lotnum
		$record.ErpJobNumber:=$lot.ErpJobNumber
		$record.Datein:=$lot.Datein
		$record.ExpectedOutDate:=$lot.ExpectedOutDate
		$record.Dateout:=$lot.Dateout
		$record.Stage:=$lot.Stage
		$record.Our_count:=$lot.Our_count
		$record.Process:=$lot.Process
		$record.Cycled:=$lot.Cycled
		$record.Customer:=$lot.Customer
		$record.Device:=$lot.Device
		$record.TotalTestedOrTotalPulls:=$lot.TotalTestedOrTotalPulls
		$record.TesterType:=$lot.TesterType
		$record.Division:=$lot.Division
		$record.PackageType1:=$lot.PackageType1
		$record.Priority:=$lot.Priority
		$record.ArchiveMonth:=$lot.ArchiveMonth
		$record.ArchiveYear:=$lot.ArchiveYear
		$record.OQAdone:=$lot.OQAdone
		$record.ID:=$lot.ID
		$record.Location:=$lot.Location
		$record.Latepareto:=$lot.Latepareto
		$record.Datetoloc:=$lot.Datetoloc
		$record.OQASamplesize:=$lot.OQASamplesize
		$record.OQAInitials:=$lot.OQAInitials
		$record.OQADate:=$lot.OQADate
		$record.Customercount:=$lot.Customercount
		$record.Datecode:=$lot.Datecode
		$record.PackageType2:=$lot.PackageType2
		$record.Groupb:=$lot.Groupb
		$record.Groupc:=$lot.Groupc
		$record.Groupd:=$lot.Groupd
		$record.Alt_grpb_lot:=$lot.Alt_grpb_lot
		$record.Alt_grpc_lot:=$lot.Alt_grpc_lot
		$record.Alt_grpd_lot:=$lot.Alt_grpd_lot
		$record.Child_lot:=$lot.Child_lot
		$record.Lead_finish:=$lot.Lead_finish
		$record.AltLotNumber:=$lot.AltLotNumber
		$record.Lot_comment:=$lot.Lot_comment
		$record.Pyield:=$lot.Pyield
		$record.PlannedStartDT:=$lot.PlannedStartDT
		$record.Stage_date:=$lot.Stage_date
		$record.Progress_count:=$lot.Progress_count
		$record.Customer2:=$lot.Customer2
		$record.At_sub:=$lot.At_sub
		$record.CSI_done:=$lot.CSI_done
		$record.CurrentOrNextArea:=$lot.CurrentOrNextArea
		$record.CSI_SS:=$lot.CSI_SS
		$record.Pr_qualifier:=$lot.Pr_qualifier
		$record.In_process:=$lot.In_process
		$record.Late:=$lot.Late
		$record.Hold:=$lot.Hold
		$record.Hold_date:=$lot.Hold_date
		$record.Hold_time:=$lot.Hold_time
		$record.Hold_hrs:=$lot.Hold_hrs
		$record.Holdby:=$lot.Holdby
		$record.Releasedby:=$lot.Releasedby
		$record.Hold_history:=$lot.Hold_history
		$record.UnitCost:=$lot.UnitCost
		$record.TotalCharge:=$lot.TotalCharge
		$record.ReadyToShipdate:=$lot.ReadyToShipdate
		$record.Return_untested:=$lot.Return_untested
		$record.Recommit_date:=$lot.Recommit_date
		$record.Recommits:=$lot.Recommits
		$record.Merged:=$lot.Merged
		$record.PO_num:=$lot.PO_num
		$record.Milestone:=$lot.Milestone
		$record.Processing_site:=$lot.Processing_site
		$record.CofCInspector:=$lot.CofCInspector
		$record.AltDevNum:=$lot.AltDevNum
		$record.RejectsFromLastStep:=$lot.RejectsFromLastStep
		$record.Hold_lot_code:=$lot.Hold_lot_code
		$record.BO_Number:=$lot.BO_Number
		$record.BuyItemNumber:=$lot.BuyItemNumber
		$record.Expectedyld:=$lot.Expectedyld
		$record.PlannedFinishDT:=$lot.PlannedFinishDT
		$record.DTStampToLoc:=$lot.DTStampToLoc
		$record.LastArea:=$lot.LastArea
		$record.ShippingMemo:=$lot.ShippingMemo
		$record.CustomerRequestDate:=$lot.CustomerRequestDate
		$record.LastOffHoldDate:=$lot.LastOffHoldDate
		$record.DateTimeStamp:=$lot.DateTimeStamp
		$record.CreationDateTimeStamp:=$lot.CreationDateTimeStamp
		$record.Property:=$lot.Property
		$record.UniqueID:=$lot.UniqueID
		$record.LinkToDeviceTable:=$lot.LinkToDeviceTable
		$record.ParentID:=$lot.ParentID
		$record.SplitLevel:=$lot.SplitLevel
		$record.ConfigurableString1:=$lot.ConfigurableString1
		$record.ConfigurableString2:=$lot.ConfigurableString2
		$record.ConfigurableString3:=$lot.ConfigurableString3
		$record.RelatedLotsData:=$lot.RelatedLotsData
		$record.ShipAddress:=$lot.ShipAddress
		$record.Supplier:=$lot.Supplier
		$record.DocumentsinDocServer:=$lot.DocumentsinDocServer
		$record.ShipTrackingNumber:=$lot.ShipTrackingNumber
		$record.Carrier:=$lot.Carrier
		$record.CofCText:=$lot.CofCText
		$record.SerialNumMin:=$lot.SerialNumMin
		$record.SerialNumMax:=$lot.SerialNumMax
		$record.Engineer:=$lot.Engineer
		$record.OneID:=$lot.OneID
		$record.ShipRel:=$lot.ShipRel
		$record.ShipInitials:=$lot.ShipInitials
		$record.Manual_status1:=$lot.Manual_status1
		$record.TravelerApprovalStatus:=$lot.TravelerApprovalStatus
		$records.push($record)
	End for each 
	
	$resourcesFolder:=Folder(fk resources folder)
	$exportsFolder:=$resourcesFolder.folder("exports")
	
	If (Not($exportsFolder.exists))
		$exportsFolder.create()
	End if 
	
	$file:=$exportsFolder.file("lotinfo_export.json")
	
	If (Not($file.exists))
		$file.create()
	End if 
	
	$file.setText(JSON Stringify($records))
	
	ALERT("Export termine: "+$file.platformPath)
End if 
