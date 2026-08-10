property toolbar : Object
property panel : Object
property users : Object
property login : Object
property folders : Object
property address : Object
property preferedCountriesInPup : Collection
property microsoftGraphAPI : Object
property mail : Object
property notifications : Object
property documentsStorageOnServer : Object
property dfd : Object
property userVision : Object
property mainInterface : Object
property constants : Object


Class extends sfw_definition_globalParameters

Class constructor
	
	Super:C1705()
	This:C1470._global_parameters()
	
Function _global_parameters()
	
	This:C1470.toolbar:=New object:C1471("visionsLogo"; "/RESOURCES/image/logo/golden_atos_100x25.png"; "visionsLogoLocal"; "/RESOURCES/image/logo/golden_atos_100x25.png")
	This:C1470.toolbar.entryIconsResize:=True:C214
	This:C1470.toolbar.entryIconsResize:=True:C214
	This:C1470.toolbar.entryIconsAutoWidth:=True:C214
	This:C1470.toolbar.entryIconsMargin:=3
	This:C1470.toolbar.entryIconsSameWidth:=True:C214
	This:C1470.toolbar.changeLanguage:=False:C215
	
	This:C1470.mainInterface:=New object:C1471("window"; New object:C1471)
	This:C1470.mainInterface.window:=New object:C1471("width"; 1800; "height"; 850)
	
	This:C1470.panel:=New object:C1471("defaultLogo"; "/RESOURCES/image/logo/logoGATransparent.png"; "defaultLogoLocal"; "/RESOURCES/image/logo/logoGATransparent.png")
	This:C1470.users:=New object:C1471("passwordLength"; 12)
	This:C1470.users.linkedDataclass:="Staff"
	This:C1470.users.linkedObject:="staff"
	This:C1470.users.linkedPathToNameFromUserEntity:="staffs.first().fullName"
	This:C1470.users.linkedPathToEmailFromUserEntity:="staffs.first().email"
	This:C1470.folders:=New object:C1471("projectResources"; "ga")
	This:C1470.address:=New object:C1471("defaultCountry"; "us")
	This:C1470.preferedCountriesInPup:=New collection:C1472("ma"; "fr"; "us")
	
	This:C1470.microsoftGraphAPI:=New object:C1471()
	This:C1470.microsoftGraphAPI.clientId:="08c8a78e-8ad9-4bd7-b24f-73d590be281b"
	This:C1470.microsoftGraphAPI.tenant:="06dc191b-7348-4b66-b0d9-806cb7d9455b"
	This:C1470.microsoftGraphAPI.scope:="offline_access https://graph.microsoft.com/.default"
	This:C1470.microsoftGraphAPI.userId:="noreply.goldenAltos@4d.com"
	This:C1470.mail:=New object:C1471("sender"; "noreply.goldenAltos@4d.com")
	
	
	This:C1470.notifications:=New object:C1471("activate"; True:C214)
	This:C1470.todoList:=New object:C1471("activate"; True:C214)
	
	If (Application type:C494#4D Remote mode:K5:5)
		This:C1470.documentsStorageOnServer:=New object:C1471
		This:C1470.documentsStorageOnServer.folder:=Folder:C1567(Folder:C1567(fk data folder:K87:12).platformPath; fk platform path:K87:2).parent.folder("DocumentData")
	End if 
	//mark:- Dynamic document 
	
	//mark: vision
	
	This:C1470.dfd:=New object:C1471
	This:C1470.dfd.visionAllowedProfiles:=["admin"; "pm"]
	
	//mark: entries
	
	This:C1470.dfd.entryDocument:=New object:C1471
	This:C1470.dfd.entryDocument.allowedProfiles:=["admin"; "pm"]
	This:C1470.dfd.entryDocument.allowedProfilesForCreation:=["admin"; "pm"]
	This:C1470.dfd.entryDocument.allowedProfilesForDeletion:=["pm"]
	This:C1470.dfd.entryDocument.allowedProfilesForModification:=["pm"]
	
	This:C1470.dfd.entryTemplate:=New object:C1471
	This:C1470.dfd.entryTemplate.allowedProfiles:=["admin"; "pm"]
	This:C1470.dfd.entryTemplate.allowedProfilesForCreation:=["admin"; "pm"]
	This:C1470.dfd.entryTemplate.allowedProfilesForDeletion:=["pm"]
	This:C1470.dfd.entryTemplate.allowedProfilesForModification:=["pm"]
	
	This:C1470.dfd.entryLine:=New object:C1471
	This:C1470.dfd.entryLine.allowedProfiles:=["admin"; "pm"]
	This:C1470.dfd.entryLine.allowedProfilesForCreation:=["admin"; "pm"]
	This:C1470.dfd.entryLine.allowedProfilesForDeletion:=["pm"]
	This:C1470.dfd.entryLine.allowedProfilesForModification:=["pm"]
	
	
	This:C1470.dfd.entryPicture:=New object:C1471
	This:C1470.dfd.entryPicture.allowedProfiles:=["admin"; "pm"]
	This:C1470.dfd.entryPicture.allowedProfilesForCreation:=["admin"; "pm"]
	This:C1470.dfd.entryPicture.allowedProfilesForDeletion:=["pm"]
	This:C1470.dfd.entryPicture.allowedProfilesForModification:=["pm"]
	
	
	
	//mark:- User management 
	
	//mark: vision
	
	This:C1470.userVision:=New object:C1471
	This:C1470.userVision.visionAllowedProfiles:=["admin"; "pm"]
	
	//mark: entries
	
	This:C1470.userVision.entryUser:=New object:C1471
	This:C1470.userVision.entryUser.allowedProfiles:=["admin"; "pm"]
	This:C1470.userVision.entryUser.allowedProfilesForCreation:=["admin"; "pm"]
	This:C1470.userVision.entryUser.allowedProfilesForDeletion:=["pm"]
	This:C1470.userVision.entryUser.allowedProfilesForModification:=["pm"]
	
	This:C1470.userVision.entryProfile:=New object:C1471
	This:C1470.userVision.entryProfile.allowedProfiles:=["admin"; "pm"]
	This:C1470.userVision.entryProfile.allowedProfilesForCreation:=["admin"; "pm"]
	This:C1470.userVision.entryProfile.allowedProfilesForDeletion:=["pm"]
	This:C1470.userVision.entryProfile.allowedProfilesForModification:=["pm"]
	
	
	
	//mark:- constants 
	
	This:C1470.constants:=New object:C1471
	This:C1470.constants.deleveryMinimunDelay:=10
	
	
	
	
	