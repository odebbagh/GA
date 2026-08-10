
Class extends DataClass


//local Function entryDefinition()->$entry : cs.sfw_definitionEntry
////Mark: entry : LotStep

////Punch In
//$entry:=cs.sfw_definitionEntry.new("punchIn"; ["production"]; "Punch In")
//$entry.setDataclass("LotStep")
//$entry.setDisplayOrder(100)
//$entry.setIcon("image/entry/equipment-white-50x50.png")

//$entry.setSubset("currentSteps")

//$entry.setLBItemsColumn("order"; "Step Order"; "width:60")
//$entry.setLBItemsColumn("lot.number"; "Lot Number"; "width:110")
//$entry.setLBItemsColumn("lot.subSequence"; "Sub Lot"; "width:60")
//$entry.setLBItemsColumn("lot.job.jobNumber"; "Job Number"; "width:125")

//$entry.setLBItemsOrderBy("lot.number desc")

//$entry.setPanel("panel_punch_in")

//$entry.setPanelPage(1; ""; "Main")
//$entry.setPanelPage(2; ""; "Step Interruption")
//$entry.setPanelPage(3; ""; "Hold Info")
//$entry.setPanelPage(4; ""; "Serialization"; "disabled:Form.hasSnItems=False")
//$entry.setPanelPage(5; ""; "Inventory Pulls")
//$entry.setPanelPage(6; ""; "Data Table"; "disabled:Form.current_item.step.stepTemplate.dataTables=Null")
//$entry.setPanelPage(7; ""; "Binning"; "disabled:Form.current_item.step.stepTemplate.binning=False")

//$entry.enableTransaction()

////Punch Out
//$entry:=cs.sfw_definitionEntry.new("punchOut"; ["production"]; "Punch OUT")
//$entry.setDataclass("LotStep")
//$entry.setDisplayOrder(-400)
//$entry.setIcon("image/entry/punsh-out-50x50.png")

//$entry.setSubset("punchOutSteps")

//$entry.setLBItemsColumn("order"; "Step Order"; "width:60")
//$entry.setLBItemsColumn("lot.number"; "Lot Number"; "width:110")
//$entry.setLBItemsColumn("lot.subSequence"; "Sub Lot"; "width:60")
//$entry.setLBItemsColumn("lot.job.jobNumber"; "Job Number"; "width:125")

//$entry.setLBItemsOrderBy("lot.number desc")

//$entry.setPanel("panel_punch_out")

//$entry.setPanelPage(1; ""; "Main")
//$entry.setPanelPage(2; ""; "Step Interruption")
//$entry.setPanelPage(3; ""; "Hold Info")
//$entry.setPanelPage(4; ""; "Serialization"; "disabled:Form.hasSnItems=False")
//$entry.setPanelPage(5; ""; "Inventory Pulls")
//$entry.setPanelPage(6; ""; "Data Table"; "disabled:Form.current_item.step.stepTemplate.dataTables=Null")
//$entry.setPanelPage(7; ""; "Binning"; "disabled:Form.current_item.step.stepTemplate.binning=False")

//$entry.enableTransaction()

//This._push_entry($entry)

//// MARK: -Filters

//$filter:=cs.sfw_definitionFilter.new("filterEquipmentLocation")
//$filter.setDefaultTitle("All locations")
//$filter.setFilterByLinkedEntity("EquipmentLocation"; "UUID_EquipmentLocation"; ""; "location")
//$filter.setDynamicTitle("name"; "## equipment location")
//$entry.addFilter($filter)

//$filter:=cs.sfw_definitionFilter.new("filterEquipmentType")
//$filter.setDefaultTitle("All types")
//$filter.setFilterByLinkedEntity("ToolType"; "UUID_ToolType"; ""; "type")
//$filter.setDynamicTitle("name"; "## equipment type")
//$entry.addFilter($filter)

//$filter:=cs.sfw_definitionFilter.new("filterEquipmentDivision")
//$filter.setDefaultTitle("All divisions")
//$filter.setFilterByLinkedEntity("Division"; "UUID_Division"; ""; "division")
//$filter.setDynamicTitle("name"; "## equipment division")
//$entry.addFilter($filter)



//// MARK: - Views Definition

//// MARK: Equipment out of calibration List
//$view:=cs.sfw_definitionView.new("currentSteps"; "Current Steps"; "derivedFrom:main"; $entry)  //Calibration Overdue
//$view.setSubset("currentSteps")
//$entry.setView($view)


local Function currentSteps()->$lotSteps : cs:C1710.LotStepSelection  //Calibration Overdue
	
	$lotSteps:=Create entity selection:C1512([LotStep:5])
	
	$lots:=ds:C1482.LotStep.query("qtyOut = 0 AND dateOut = :1"; !00-00-00!).orderBy("lot.number asc, order asc")
	$currentLot:=0
	
	For each ($item; $lots)
		If ($currentLot#$item.lot.number)
			$lotSteps.add($item)
		End if 
		If ($item.properties#Null:C1517) && ($item.properties.items#Null:C1517)
			$OCR:=$item.properties.items.query("name = 'OCR'")
			If ($OCR.length>0) && ($OCR[0].enabled)
				$lotSteps.add($item)
			End if 
		End if 
		$currentLot:=$item.lot.number
	End for each 
	
	//$lotSteps:=$lotSteps.orderBy("lot.number asc, order asc")
	
local Function punchOutSteps()->$lotSteps : cs:C1710.LotStepSelection
	
	$lotSteps:=Create entity selection:C1512([LotStep:5])
	
	$lots:=ds:C1482.LotStep.query(" (qtyIn # :1 AND dateIn # :2) AND (qtyOut = :1 OR dateOut = :2)"; 0; !00-00-00!).orderBy("lot.number asc, order desc")
	$currentLot:=0
	
	For each ($item; $lots)
		If ($currentLot#$item.lot.number)
			$lotSteps.add($item)
		End if 
		If ($item.properties#Null:C1517) && ($item.properties.items#Null:C1517)
			$OCR:=$item.properties.items.query("name = 'OCR'")
			If ($OCR.length>0) && ($OCR[0].enabled)
				$lotSteps.add($item)
			End if 
		End if 
		$currentLot:=$item.lot.number
	End for each 
	
local Function getPossibleActions()->$possibleActions : Collection
	
	$possibleActions:=New collection:C1472()
	
	$possibleActions.push("Edit Control Parameters")
	
	If (This:C1470.qtyIn=0) | (This:C1470.dateIn=!00-00-00!)
		$possibleActions.push("Punch In")
	End if 
	
	If (This:C1470.qtyOut=0) | (This:C1470.dateOut=!00-00-00!)
		$possibleActions.push("Punch Out")
	End if 
	