

Class extends DataClass

local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	
	$entry:=cs:C1710.sfw_definitionEntry.new("user"; "userManagement"; "Users")
	//$entry.setXliffLabel("entry.users")
	$entry.setDataclass("sfw_User")
	$entry.setIcon("sfw/entry/users-50x50.png")
	$entry.setXliffLabel("user.users")
	//$entry.setDisplayOrder(-1000)
	$entry.setSearchboxField("firstName")
	$entry.setSearchboxField("lastName")
	$entry.setSearchboxField("login")
	$entry.setSearchboxField("moreData.barcodeData"; "placeholder:barcode")
	$entry.setPanel("sfw_panel_user")
	$entry.setPanelPage(1; "address-32x32.png"; "Profiles")
	$entry.setLBItemsColumn("firstName"; "First name"; "xliff:user.field.firstname")
	$entry.setLBItemsColumn("lastName"; "Last name"; "xliff:user.field.lastname")
	$entry.setLBItemsColumn("login"; "Login"; "xliff:user.field.login")
	$entry.setLBItemsOrderBy("firstName")
	$entry.setLBItemsOrderBy("lastName")
	$entry.setLBItemsCounter("###,###,##0 ^1;;"; "unit1:user"; "unitN:users")
	
	$entry.setValidationRule("firstName"; "entryField_name"; "mandatory"; "trimSpace"; "capitalize")
	$entry.setValidationRule("lastName"; "entryField_name"; "mandatory"; "trimSpace"; "capitalize")
	$entry.setValidationRule("login"; "entryField_name"; "unique"; "capitalize")
	
	$entry.setItemListPreconfigAction("exportReferenceRecords")
	$entry.setLinkedReferenceRecordsDataclasses("userInscriptions"; "userInscriptions.userProfile"; "iuserInscriptionsGiven")
	$entry.setItemListPreconfigAction("importReferenceRecords")
	$entry.setItemListPreconfigAction("copyItemsListToPasteboard")
	$entry.setItemListAction("-"; "-")
	$entry.setItemListAction(ds:C1482.sfw_readXliff("user.capitalename"); "capitalize_all")
	$entry.setItemListAction(ds:C1482.sfw_readXliff("user.cleanprofile"); "cleanUpProfileInscriptions")
	
	$entry.enableTransaction()
	
	$entry.setAllowedProfiles(cs:C1710.sfw_globalParameters.me.userVision.entryUser.allowedProfiles || "admin")
	
	$entry.setItemAction("Generate Barcode"; "_ga_openBarCodeForm")
	
	$entry.setItemListAction("Search by Scanning"; "_ga_searchByBarcodeScanning")
	
Function getActiveUsers()->$esUsers : cs:C1710.sfw_UserSelection
	var $eRelated : 4D:C1709.Entity
	
	If (cs:C1710.sfw_definition.me.globalParameters.users.linkedDataclass#Null:C1517)
		$esUsers:=ds:C1482.sfw_User.newSelection()
		For each ($eUser; ds:C1482.sfw_User.query("isInactive != True"))
			Try
				$eRelated:=ds:C1482[cs:C1710.sfw_definition.me.globalParameters.users.linkedDataclass].query("UUID_User = :1"; $eUser.UUID).first()
				If ($eRelated#Null:C1517)
					$esUsers.add($eUser)
				End if 
			Catch
				
			End try
		End for each 
	Else 
		$esUsers:=ds:C1482.sfw_User.query("isInactive != True")
	End if 
	
	
Function capitalize_all()
	var $eUser : cs:C1710.sfw_UserEntity
	
	For each ($eUser; This:C1470.all())
		$eUser.firstName:=cs:C1710.sfw_string.me.stringCapitalize($eUser.firstName)
		$eUser.lastName:=cs:C1710.sfw_string.me.stringCapitalize($eUser.lastName)
		$info:=$eUser.save()
	End for each 
	
Function cleanUpProfileInscriptions()
	
	$uuidsProfiles:=ds:C1482.sfw_UserProfile.all().extract("UUID")
	$esInscriptionsWithoutProfile:=ds:C1482.sfw_UserInscription.query("not(UUID_UserProfile in :1)"; $uuidsProfiles)
	$info:=$esInscriptionsWithoutProfile.drop()
	
	
local Function closeBoxMainForm()
	If (Form:C1466.subForm#Null:C1517) && (Form:C1466.subForm.hl_permissions#Null:C1517) && (Is a list:C621(Form:C1466.subForm.hl_permissions))
		CLEAR LIST:C377(Form:C1466.subForm.hl_permissions; *)
	End if 