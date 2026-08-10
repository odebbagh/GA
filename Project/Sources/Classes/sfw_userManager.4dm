property info : Object
property authorizations : Object
property authorizedProfiles : Collection
property userProfiles : cs:C1710.sfw_UserProfileSelection
property icon : Object

shared singleton Class constructor
	
	This:C1470.info:=New shared object:C1526
	This:C1470.defineUser()
	This:C1470._loadIcons()
	
	
shared Function defineUser()
	
	$eUser:=cs:C1710.sfw_UserEntity
	
	$eUser:=ds:C1482.sfw_User.query("login = :1"; Current user:C182).first()
	If ($eUser#Null:C1517)
		
		This:C1470.info.asDesigner:=$eUser.asDesigner
		This:C1470.info.login:=$eUser.login
		This:C1470.info.UUID:=$eUser.UUID
		If (cs:C1710.sfw_definition.me.globalParameters.users.linkedPathToNameFromUserEntity#Null:C1517)
			$formula:=Formula from string:C1601("ds.sfw_User.get($1)."+cs:C1710.sfw_definition.me.globalParameters.users.linkedPathToNameFromUserEntity)
			This:C1470.info.name:=$formula.call(Null:C1517; This:C1470.info.UUID)  // "staffs.first().fullName"
		Else 
			This:C1470.info.name:=This:C1470.info.login
		End if 
		If (cs:C1710.sfw_definition.me.globalParameters.users.linkedPathToEmailFromUserEntity#Null:C1517)
			$formula:=Formula from string:C1601("ds.sfw_User.get($1)."+cs:C1710.sfw_definition.me.globalParameters.users.linkedPathToEmailFromUserEntity)
			This:C1470.info.email:=$formula.call(Null:C1517; This:C1470.info.UUID)  // "staffs.first().email"
		Else 
			This:C1470.info.email:=""
		End if 
		
		If (cs:C1710.sfw_definition.me.globalParameters.users.linkedDataclass#Null:C1517)
			$dcName:=cs:C1710.sfw_definition.me.globalParameters.users.linkedDataclass
			$formula:=Formula from string:C1601("ds."+$dcName+".query(\"UUID_User = :1\";$1).first().UUID")
			This:C1470.info["UUID_"+$dcName]:=$formula.call(Null:C1517; This:C1470.info.UUID)
		End if 
		
	Else 
		This:C1470.info.asDesigner:=True:C214
		This:C1470.info.login:="Designer"
		This:C1470.info.UUID:="00"*16
		This:C1470.info.name:=This:C1470.info.login
		This:C1470.info.email:=""
	End if 
	
	This:C1470.authorizations:=New shared object:C1526
	This:C1470.authorizations.canImportExportReferenceRecords:=This:C1470.canImportExportReferenceRecords()
	
	This:C1470.getAuthorizedProfiles()
	
	
	
shared Function onStartup()
	
	If (Application type:C494#4D Remote mode:K5:5)
		$eProfilAdmin:=This:C1470.getAdmistratorProfil()
		$eProfilDesigner:=This:C1470.getDesignerProfil()
		
	End if 
	
shared Function getAdmistratorProfil()->$eProfilAdmin : cs:C1710.sfw_UserProfileEntity
	$eProfilAdmin:=ds:C1482.sfw_UserProfile.getAndCreateIfNotExist("admin"; "administrator"; "autoCreation")
	
shared Function getDesignerProfil()->$eProfilDesigner : cs:C1710.sfw_UserProfileEntity
	$eProfilDesigner:=ds:C1482.sfw_UserProfile.getAndCreateIfNotExist("designer"; "designer"; "autoCreation")
	
	
shared Function canImportExportReferenceRecords()->$canDoIt : Boolean
	$canDoIt:=This:C1470.info.asDesigner
	
	
shared Function get isDeveloper()->$isDev : Boolean
	$isDev:=This:C1470.info.asDesigner
	
	
shared Function _loadIcons()
	var $folder : 4D:C1709.Folder
	$folder:=Folder:C1567("/RESOURCES/sfw/image/picto/"; fk posix path:K87:1)
	
	This:C1470.icon:=New shared object:C1526
	
	READ PICTURE FILE:C678($folder.file("user-black.png").platformPath; $icon)
	This:C1470.icon.devMale:=$icon
	
	READ PICTURE FILE:C678($folder.file("user-black-female.png").platformPath; $icon)
	This:C1470.icon.devFemale:=$icon
	
	READ PICTURE FILE:C678($folder.file("user-white.png").platformPath; $icon)
	This:C1470.icon.basicMale:=$icon
	
	READ PICTURE FILE:C678($folder.file("user-white-female.png").platformPath; $icon)
	This:C1470.icon.basicFemale:=$icon
	
	READ PICTURE FILE:C678($folder.file("user-inactive.png").platformPath; $icon)
	This:C1470.icon.inactiveMale:=$icon
	
	READ PICTURE FILE:C678($folder.file("user-inactive-female.png").platformPath; $icon)
	This:C1470.icon.inactiveFemale:=$icon
	
	
	
shared Function login()
	
	var $form : Object:=New object:C1471
	var $esUsers : cs:C1710.sfw_UserSelection
	var $file : 4D:C1709.File
	var $logFolder : 4D:C1709.Folder:=Folder:C1567(fk logs folder:K87:17)
	
	//$form.users:=ds.sfw_User.query("isInactive != :1"; True)
	$form.users:=ds:C1482.sfw_User.getActiveUsers()
	
	If ($form.users.length>0)
		$file:=Folder:C1567(fk user preferences folder:K87:10).file("myAccess.json")
		If ($file.exists=True:C214)
			$storedInfo:=JSON Parse:C1218($file.getText())
			$esUsers:=ds:C1482.sfw_User.query("login = :1"; $storedInfo.login)
			If ($esUsers.length=1)
				$eUser:=$esUsers.first()
				If ($storedInfo.hashPassword=String:C10($eUser.accesses.password.hash))
					If (Verify password hash:C1534($eUser.UUID; $storedInfo.hashPassword2))
						If (Verify password hash:C1534($logFolder.platformPath; $storedInfo.hashPassword3))
							If (Bool:C1537($eUser.accesses.asDesigner))
								CHANGE CURRENT USER:C289("Designer"; "")  //cs.sfw_definition.me.globalParameters.users.designerPassword)
							End if 
							SET USER ALIAS:C1666($storedInfo.login)
							cs:C1710.sfw_userManager.me.defineUser()
							return 
						End if 
					End if 
				End if 
			End if 
		End if 
		
		If (True:C214)  //TODO:RESTORE
			$ref:=Open form window:C675("_ga_login"; Palette form window:K39:9)
			DIALOG:C40("_ga_login"; $form)
			CLOSE WINDOW:C154($ref)
		Else 
			//This is the initial code
			$ref:=Open form window:C675("sfw_login"; Palette form window:K39:9)
			DIALOG:C40("sfw_login"; $form)
			CLOSE WINDOW:C154($ref)
		End if 
		
		If (ok=1)
			If ($form.currentUser.accesses#Null:C1517) && (Bool:C1537($form.currentUser.accesses.password.temporary)=True:C214)
				var $result : Object
				$result:=cs:C1710.sfw_passwordManager.me.askForNewPassword($form.currentUser)
				If ($result.success)
					$form.currentUser.accesses.password.temporary:=False:C215
					$form.currentUser.accesses.password.lastChange:=cs:C1710.sfw_stmp.me.now()
					$form.currentUser.accesses.password.hash:=$result.hash
					$info:=$form.currentUser.save()
					If ($info.success=False:C215)
						
					End if 
				End if 
			End if 
			
			If ($form.storeAccess)
				cs:C1710.sfw_userManager.me.storeAccess()
			End if 
		Else 
			QUIT 4D:C291
		End if 
	End if 
	
	
shared Function storeAccess()
	var $eUser : cs:C1710.sfw_UserEntity
	var $file : 4D:C1709.File
	var $logFolder : 4D:C1709.Folder:=Folder:C1567(fk logs folder:K87:17)
	
	// todo: supp les dialogs + supp item du menu dans la toolbar
	$eUser:=ds:C1482.sfw_User.get(cs:C1710.sfw_userManager.me.info.UUID)
	$hashOptions:=New object:C1471("algorithm"; "bcrypt"; "cost"; 10)
	
	$infoToStore:=New object:C1471
	$infoToStore.stmp:=cs:C1710.sfw_stmp.me.now()
	$infoToStore.login:=cs:C1710.sfw_userManager.me.info.login
	$infoToStore.hashPassword:=$eUser.accesses.password.hash
	$infoToStore.hashPassword2:=Generate password hash:C1533($eUser.UUID; $hashOptions)
	$infoToStore.hashPassword3:=Generate password hash:C1533($logFolder.platformPath; $hashOptions)
	$applicationInfo:=Application info:C1599
	$file:=Folder:C1567(fk user preferences folder:K87:10).file("myAccess.json")
	$file.setText(JSON Stringify:C1217($infoToStore; *))
	
	
shared Function getAuthorizedProfiles()
	
	This:C1470.authorizedProfiles:=ds:C1482.sfw_UserInscription.query("UUID_User = :1"; This:C1470.info.UUID).extract("userProfile.ident").copy(ck shared:K85:29)
	If (This:C1470.authorizedProfiles.indexOf("admin")<0) && (This:C1470.info.asDesigner)
		This:C1470.authorizedProfiles.push("admin")
	End if 
	
	This:C1470.userProfiles:=ds:C1482.sfw_UserProfile.query("ident in :1"; This:C1470.authorizedProfiles)