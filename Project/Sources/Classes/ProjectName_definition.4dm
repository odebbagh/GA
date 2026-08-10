Class extends sfw_definitionBuilder

Class constructor
	
	Super:C1705()
	This:C1470._global_parameters()
	This:C1470._visions_definition()
	This:C1470._entries_definition()
	This:C1470._event_definition()
	
	
Function _global_parameters()
	
	This:C1470.globalParameters:=New object:C1471
	This:C1470.globalParameters.toolbar:=New object:C1471("visionsLogo"; "/RESOURCES/image/logo/Kairos-logo-100x25.png"; "visionsLogoLocal"; "/RESOURCES/image/logo/Kairos-logo-local-100x25.png")
	This:C1470.globalParameters.panel:=New object:C1471("defaultLogo"; "/RESOURCES/image/logo/Kairos-512x452.png"; "defaultLogoLocal"; "/RESOURCES/image/logo/Kairos-local-512x452.png")
	This:C1470.globalParameters.users:=New object:C1471("passwordLength"; 12)
	This:C1470.globalParameters.users.linkedDataclass:="Staff"
	This:C1470.globalParameters.users.linkedObject:="staff"
	This:C1470.globalParameters.users.linkedPathToNameFormUserEntity:="staffs.first().fullName"
	This:C1470.globalParameters.folders:=New object:C1471("projectResources"; "repFrais")
	This:C1470.globalParameters.address:=New object:C1471("defaultCountry"; "fr")
	This:C1470.globalParameters.preferedCountriesInPup:=New collection:C1472("ma"; "fr"; "us")
	
Function _event_definition()
	
	cs:C1710.sfw_eventManager.me.createIfNotExist("addSkill"; "Add skill to a staff")
	cs:C1710.sfw_eventManager.me.createIfNotExist("closeSkill"; "Close a skill for a staff")
	cs:C1710.sfw_eventManager.me.createIfNotExist("startSkill"; "Start a skill for a staff")
	
	
	//Mark:-Visions defintion
Function _visions_definition()
	var $vision : cs:C1710.sfw_definitionVision
	
	$vision:=cs:C1710.sfw_definitionVision.new("newVision"; "New vision")
	$vision.setToolbarBackgroundColor("#52ABD8")
	$vision.setFocusRingColor("navy")
	This:C1470._push_vision($vision)
	
	$vision:=cs:C1710.sfw_definitionVision.new("lineHWMH"; "-")
	$vision.setDisplayOrder(-10000)
	This:C1470._push_vision($vision)
	
	
	//Mark:-Entries defintion
Function _entries_definition()
	
	var $entry : cs:C1710.sfw_definitionEntry
	var $view : cs:C1710.sfw_definitionView
	
	
	
	
	
	If (123=124)
		//mark: entry : compilation
		$entry:=cs:C1710.sfw_definitionEntry.new("compilation"; "administration"; "Compilation")
		$entry.setXliffLabel("entry.compilation")
		$entry.setIcon("image/entry/compiler2-50x50.png")
		$entry.setVirtual("collection")
		$item:=cs:C1710.sfw_definitionVirtualItem.new("syntaxCheck"; "sfw_compilation_syntaxCheck")
		$item.setXliffLabel("compilation.title.syntaxCheck")
		$item.setItemAction("Export compilation file"; "sfw_compilation_exportFile"; "xliff:entry.compilation.export")
		$item.setItemAction("Import compilation file"; "sfw_compilation_importFile"; "xliff:entry.compilation.import")
		$entry.setVirtualItem($item)
		$item:=cs:C1710.sfw_definitionVirtualItem.new("interprocessVariables"; "sfw_panel_default")
		$item.setXliffLabel("compilation.title.interprocessVariables")
		$entry.setVirtualItem($item)
		$item:=cs:C1710.sfw_definitionVirtualItem.new("processVariables"; "sfw_panel_default")
		$item.setXliffLabel("compilation.title.processVariables")
		$entry.setVirtualItem($item)
		$item:=cs:C1710.sfw_definitionVirtualItem.new("localVariables"; "sfw_panel_default")
		$item.setXliffLabel("compilation.title.localVariables")
		$entry.setVirtualItem($item)
		$item:=cs:C1710.sfw_definitionVirtualItem.new("methods"; "sfw_panel_default")
		$item.setXliffLabel("compilation.title.methods")
		$entry.setVirtualItem($item)
		This:C1470._push_entry($entry)
	End if 
	
	