//%attributes = {"executedOnServer":true}

// Purpose: Facilities test import only. Location and Division first, then tool types, users/staff, then equipment and repair logs.
// Run manually on the server. Do not call from entry UI. Truncates EquipmentLocation, Division, and (if tools JSON exists) ToolType/Tool; __import_data_users truncates users/staff.
// created by 4D/PS [2026-november-03]

_ga_createMoreDataFields

//----> [EquipmentLocation]  (from __import_data_lists)
var $eEquipmentLocation : cs:C1710.EquipmentLocationEntity
var $equipmentsLocations : Collection:=New collection:C1472("4TH OPTICAL"; "Burn-in"; "Eng'r"; \
"Engineering"; "Environmental"; "EOL"; "FACILITY"; "FOL"; "FOL for Profiler"; \
"FOL/RTC"; "Front of Line"; "Lab/ Vibration"; "Lab/Mechanical Shock"; \
"Lab/Milpitas"; "Marking"; "Pad"; "Solder"; "Solder Dip"; "Trim")
TRUNCATE TABLE:C1051([EquipmentLocation:19])
For ($i; 0; $equipmentsLocations.length-1)
	$eEquipmentLocation:=ds:C1482.EquipmentLocation.new()
	$eEquipmentLocation.levelID:=$i+1
	$eEquipmentLocation.name:=$equipmentsLocations[$i]
	$eEquipmentLocation.color:="#FFFFFF"
	$eEquipmentLocation.save()
End for 

//----> [Division]  (from __import_data_lists)
var $eDivision : cs:C1710.DivisionEntity
var $divisions : Collection:=New collection:C1472("GAC")
TRUNCATE TABLE:C1051([Division:20])
For ($i; 0; $divisions.length-1)
	$eDivision:=ds:C1482.Division.new()
	$eDivision.levelID:=$i+1
	$eDivision.name:=$divisions[$i]
	$eDivision.color:="#FFFFFF"
	$eDivision.save()
End for 

//----> [ToolType] / [Tool]  (from __import_purchaseOrders)
$file:=Folder:C1567(fk data folder:K87:12).file("DataJson/tools_export.json")
If ($file.exists)
	TRUNCATE TABLE:C1051([ToolType:122])
	TRUNCATE TABLE:C1051([Tool:6])
	
	$records:=JSON Parse:C1218($file.getText())
	
	For each ($record; $records)
		$toolType_e:=ds:C1482.ToolType.new()
		$toolType_e.name:=$record.name
		$toolType_e.type:=$record.type
		$toolType_e.date:=$record.date
		$res:=$toolType_e.save()
		If ($res.success)
			For each ($tool; $record.tools)
				$tool_e:=ds:C1482.Tool.new()
				$tool_e.name:=Split string:C1554($tool; "*")[0]
				$tool_e.date:=Date:C102(Split string:C1554($tool; "*")[1])
				$tool_e.UUID_ToolType:=$toolType_e.UUID
				$tool_e.save()
			End for each 
		End if 
	End for each 
End if 

__import_data_users
__import_data_equipment

ALERT:C41("Facilities import done")
