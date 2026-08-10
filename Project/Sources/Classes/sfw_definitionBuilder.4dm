property globalParameters : Object
property visions : Collection
property entries : Collection

Class constructor
	var $vision : cs:C1710.sfw_definitionVision
	var $entry : cs:C1710.sfw_definitionEntry
	
	This:C1470.visions:=New collection:C1472
	This:C1470.entries:=New collection:C1472
	
	
	//Mark: vision : Administration
	
	$vision:=cs:C1710.sfw_definitionVision.new("line"; "-")
	$vision.setDisplayOrder(-1002)
	This:C1470._push_vision($vision)
	
	$vision:=cs:C1710.sfw_definitionVision.new("administration"; "Administration")
	$vision.setXliffLabel("vision.administration")
	$vision.setToolbarBackgroundColor("Gray")
	$vision.setDisplayOrder(-1003)
	$vision.setAllowedProfiles("admin")
	$vision.setIcon("sfw/vision/administration-24x24.png")
	This:C1470._push_vision($vision)
	
	$vision:=cs:C1710.sfw_definitionVision.new("userManagement"; ds:C1482.sfw_readXliff("user.vision"))
	$vision.setToolbarBackgroundColor("LightSlateGray")
	$vision.setXliffLabel("user.vision")
	$vision.setDisplayOrder(-1004)
	$vision.setIcon("sfw/vision/user-24x24.png")
	$vision.setAllowedProfiles(cs:C1710.sfw_globalParameters.me.userVision.visionAllowedProfiles || "admin")
	This:C1470._push_vision($vision)
	
	//If (OB Entries(ds).indices("key = :1"; "dfd_@").length>0)
	$vision:=cs:C1710.sfw_definitionVision.new("documentManagement"; ds:C1482.sfw_readXliff("dfdVision.vision"))
	$vision.setToolbarBackgroundColor("CornflowerBlue")
	$vision.setXliffLabel("dfdVision.vision")
	$vision.setDisplayOrder(-1005)
	$vision.setIcon("dfd/image/vision/dfd-24x24.png")
	$vision.setAllowedProfiles(cs:C1710.sfw_globalParameters.me.dfd.visionAllowedProfiles || "admin")
	This:C1470._push_vision($vision)
	
	$entry:=cs:C1710.sfw_definitionEntry.new("splitterDocuments1"; "documentManagement")
	$entry.setAsSplitter()
	$entry.setDisplayOrder(11000)
	This:C1470._push_entry($entry)
	
	$entry:=cs:C1710.sfw_definitionEntry.new("splitterDocuments2"; "documentManagement")
	$entry.setAsSplitter()
	$entry.setDisplayOrder(10000)
	This:C1470._push_entry($entry)
	//End if 
	
	For each ($dataclassName; ds:C1482)
		If (ds:C1482[$dataclassName].entryDefinition#Null:C1517)
			$entry:=ds:C1482[$dataclassName].entryDefinition()
			This:C1470._push_entry($entry)
		End if 
	End for each 
	
	//Mark: entry : scheduler
	If (cs:C1710.sfw_definition.me.globalParameters.schedulers.activate)
		$entry:=cs:C1710.sfw_definitionEntry.new("scheduler"; "administration"; "Scheduler")
		$entry.setXliffLabel("scheduler.title")
		$entry.setIcon("sfw/entry/scheduler-50x50.png")
		$entry.setWizard("sfw_wizard_scheduler"; "palette")
		This:C1470._push_entry($entry)
	End if 
	
	
	
	//Mark:-Internal tool functions
Function _push_vision($vision : cs:C1710.sfw_definitionVision)
	
	This:C1470.visions.push(OB Copy:C1225($vision; ck shared:K85:29; This:C1470.visions))
	
Function _push_entry($entry : cs:C1710.sfw_definitionEntry)
	
	This:C1470.entries.push(OB Copy:C1225($entry; ck shared:K85:29; This:C1470.entries))
	