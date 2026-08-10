//%attributes = {"executedOnServer":true}
var $eEquipment : cs:C1710.EquipmentEntity
var $eRepair : cs:C1710.RepairLogEntity

$equipment_Log:=Folder:C1567(fk data folder:K87:12).file("DataJson/equipment_export.json")

If ($equipment_Log.exists)
	$equipments:=JSON Parse:C1218($equipment_Log.getText())
	TRUNCATE TABLE:C1051([Equipment:13])
	//TRACE
	
	$docs:=Folder:C1567(fk data folder:K87:12).file("DataJson/docServerIndex_export.json")
	$count:=0
	If ($docs.exists)
		
		$documents:=JSON Parse:C1218($docs.getText())
		
	End if 
	
	
	For each ($equipment; $equipments)
		
		$eEquipment:=ds:C1482.Equipment.new()
		
		$eEquipment.assignedID:=$equipment.AssignedID
		
		//Checkand assign a Location if needed
		$location:=ds:C1482.EquipmentLocation.query("name =:1"; Split string:C1554($equipment.LOC; "\r"; sk trim spaces:K86:2).join("\r"))  //$eEquipment.location:=$equipment.LOC
		
		If ($location.length>0)
			$eEquipment.UUID_EquipmentLocation:=$location[0].UUID
			
		End if 
		
		$eEquipment.model:=$equipment.MODEL
		$eEquipment.serialNumber:=$equipment.SerialNumber
		$eEquipment.stmpNextCal:=Date:C102($equipment.NextCalDate)=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build(Date:C102($equipment.NextCalDate))
		$eEquipment.stmpLastCal:=Date:C102($equipment.LastCalDate)=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build(Date:C102($equipment.LastCalDate))
		$eEquipment.stmpLastPM:=Date:C102($equipment.LastPMDate)=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build(Date:C102($equipment.LastPMDate))
		$eEquipment.stmpNextPM:=Date:C102($equipment.NextPMDate)=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build(Date:C102($equipment.NextPMDate))
		$eEquipment.notAtSite:=$equipment.Not_at_site
		
		//Checkand assign a division if needed
		$division:=ds:C1482.Division.query("name =:1"; Split string:C1554($equipment.Division; "\r"; sk trim spaces:K86:2).join("\r"))  //$eEquipment.type:=$equipment.EquipmentType
		
		If ($division.length>0)
			$eEquipment.UUID_Division:=$division[0].UUID
		Else 
			$eEquipment.UUID_Division:=""
		End if 
		
		$eEquipment.engg:=$equipment.Engg
		$eEquipment.calibrationNotRequired:=$equipment.CalibrationNotRequired
		
		//Check and assign a Location if needed
		$type:=ds:C1482.ToolType.query("name =:1"; Split string:C1554($equipment.EquipmentType; "\r"; sk trim spaces:K86:2).join("\r"))  //$eEquipment.type:=$equipment.EquipmentType
		
		If ($type.length>0)
			$eEquipment.UUID_ToolType:=$type[0].UUID
		Else 
			
		End if 
		
		$eEquipment.status:=$equipment.ATE_STATUS
		$eEquipment.calTech:=$equipment.TECH
		$eEquipment.pmTech:=$equipment.PMTech
		$eEquipment.description:=$equipment.Description
		$eEquipment.manufacturer:=$equipment.Manufacturer
		//$eEquipment.equipmentConfig:=$equipment.EquipmentConfig
		$eEquipment.statusHistory:=$equipment.Status_History
		If ($equipment.Status_History#"")
			
		End if 
		$eEquipment.down:=$equipment.Down
		$eEquipment.calInProgress:=$equipment.Cal_inprocess
		$eEquipment.calInterval:=$equipment.CalInterval
		$eEquipment.pmInterval:=$equipment.PMInterval
		$eEquipment.calDocument:=$equipment.CalDocument
		$eEquipment.pmDocument:=$equipment.PMDocument
		$eEquipment.pmNotRequired:=$equipment.PMnotRequired
		
		$eEquipment.moreData:=New object:C1471()
		$eEquipment.moreData.soonDueCal:=False:C215
		$eEquipment.moreData.dueCal:=False:C215
		$eEquipment.moreData.soonDuePM:=False:C215
		$eEquipment.moreData.duePM:=False:C215
		
		
		If ($eEquipment.calibrationNotRequired=False:C215) & ($eEquipment.notAtSite=False:C215) & ($eEquipment.nextCalDate<=Current date:C33(*))
			$eEquipment.outOfCalibration:=True:C214
			
		End if 
		
		$_documents:=$documents.query("PrimaryKeyValue=:1 & TableNumber=:2"; String:C10($equipment.UniqueID); 10)
		
		$eEquipment.reports:=New object:C1471()
		$eEquipment.reports.documents:=New collection:C1472()
		
		For each ($document; $_documents)
			$doc:=New object:C1471
			
			$doc.code:=$document.DocCode
			$doc.dateTimeStamp:=$document.DateTimeStamp
			$doc.creationDateTimeStamp:=$document.CreationDateTimeStamp
			$doc.documentPath:=$document.DocumentPath
			$doc.sourcePath:=$document.SourcePath
			$doc.description:=$document.DocDescription
			$doc.approvalDate:=!00-00-00!
			$doc.approvedBy:=""
			$doc.isApproved:=False:C215
			
			$report:=Folder:C1567(fk data folder:K87:12).file("DataJson/EquipmentReports/"+String:C10($document.UniqueID+$document.PrimaryKeyValue))
			If ($report.exists)
				
				var $blob : Blob
				DOCUMENT TO BLOB:C525($report.platformPath; $blob)
				
				$doc.blob:=$blob
				
			End if 
			
			$eEquipment.reports.documents.push($doc)
		End for each 
		
		$res:=$eEquipment.save()
		If (Not:C34($res.success))
			TRACE:C157
		End if 
		
	End for each 
	
	
End if 


$repair_Log_file:=Folder:C1567(fk data folder:K87:12).file("DataJson/repair_log_export.json")
var $text : Text:=""
If ($repair_Log_file.exists)
	$repair_log:=JSON Parse:C1218($repair_Log_file.getText())
	TRUNCATE TABLE:C1051([RepairLog:21])
	
	For each ($repair; $repair_log)
		
		$eRepair:=ds:C1482.RepairLog.new()
		
		$equipment:=ds:C1482.Equipment.query("assignedID =:1"; Split string:C1554($repair.Sys_ID; "\r"; sk trim spaces:K86:2).join("\r"))
		If ($equipment.length>0)
			$eRepair.UUID_Equipment:=$equipment[0].UUID
		Else 
			$eRepair.UUID_Equipment:=""
			$text:=$text+"\n"+$repair.Sys_ID
		End if 
		
		$eRepair.operators:=New object:C1471()
		
		$staff:=ds:C1482.Staff.query("code =:1"; Split string:C1554($repair.Rep_by; "\r"; sk trim spaces:K86:2).join("\r"))
		
		If ($staff.length>0)
			$eRepair.UUID_Reporter:=$staff[0].UUID
		Else 
			$eRepair.UUID_Reporter:="00"*16
		End if 
		
		$staff:=ds:C1482.Staff.query("code =:1"; Split string:C1554($repair.Fixed_by; "\r"; sk trim spaces:K86:2).join("\r"))
		
		If ($staff.length>0)
			$eRepair.UUID_Fixer:=$staff[0].UUID
		Else 
			$eRepair.UUID_Fixer:="00"*16
		End if 
		
		$eRepair.stmpFixed:=Date:C102($repair.Date_fixed)=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build(Date:C102($repair.Date_fixed))
		$eRepair.stmpReport:=Date:C102($repair.Rep_date)=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build(Date:C102($repair.Rep_date))
		$eRepair.status:=$repair.E_status
		$eRepair.problem:=Split string:C1554($repair.Problem; "\r"; sk trim spaces:K86:2).join("\r")
		$eRepair.reportID:=$repair.Rep_num
		$eRepair.fix:=$repair.Fix
		$eRepair.downHrs:=$repair.Down_hrs
		$eRepair.downAtStmp:=Time:C179($repair.Down_at)=0 ? 0 : cs:C1710.sfw_stmp.me.build(!00-00-00!; Time:C179($repair.Down_at))
		$eRepair.upAtStmp:=Time:C179($repair.Up_at)=0 ? 0 : cs:C1710.sfw_stmp.me.build(!00-00-00!; Time:C179($repair.Up_at))
		$eRepair.stmpUp:=Date:C102($repair.Date_fixed)=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build(Date:C102($repair.Date_fixed))
		
		
		$res:=$eRepair.save()
		If (Not:C34($res.success))
			TRACE:C157
		End if 
		
		
	End for each 
	
End if 
//TRACE
//SET TEXT TO PASTEBOARD($text)






