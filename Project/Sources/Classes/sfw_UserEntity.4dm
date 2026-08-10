Class extends Entity


Function get fullName()->$fullName : Text
	$fullName:=[This:C1470.firstName; This:C1470.lastName].join(" "; ck ignore null or empty:K85:5)
	
Function get asDesigner()->$asDesigner : Boolean
	If (This:C1470.accesses=Null:C1517)
		This:C1470.accesses:=New object:C1471
		This:C1470.accesses.asDesigner:=False:C215
	End if 
	$asDesigner:=This:C1470.accesses.asDesigner
	
Function set asDesigner($asDesigner : Boolean)
	var $eUserInscription : cs:C1710.sfw_UserInscriptionEntity
	var $eProfilDesigner : cs:C1710.sfw_UserProfileEntity
	If (This:C1470.accesses=Null:C1517)
		This:C1470.accesses:=New object:C1471
	End if 
	This:C1470.accesses.asDesigner:=$asDesigner
	$eProfilDesigner:=cs:C1710.sfw_userManager.me.getDesignerProfil()
	$eUserInscription:=ds:C1482.sfw_UserInscription.query("UUID_User = :1 and UUID_UserProfile = :2"; This:C1470.UUID; $eProfilDesigner.UUID).first()
	If ($asDesigner)
		If ($eUserInscription=Null:C1517)
			$eUserInscription:=ds:C1482.sfw_UserInscription.new()
			$eUserInscription.UUID:=Generate UUID:C1066
			$eUserInscription.UUID_User:=This:C1470.UUID
			$eUserInscription.UUID_UserProfile:=$eProfilDesigner.UUID
			$eUserInscription.UUID_whoHasGiven:=cs:C1710.sfw_userManager.me.info.UUID
			$eUserInscription.stmp_given:=cs:C1710.sfw_stmp.me.now()
			$eUserInscription.moreData:=New object:C1471("autoCreation"; $eUserInscription.stmp_given)
			$info:=$eUserInscription.save()
		End if 
	Else 
		If ($eUserInscription#Null:C1517)
			$info:=$eUserInscription.drop()
		End if 
	End if 
	
	
Function get nameToDisplayForEventOrComment()->$name : Text
	If (cs:C1710.sfw_definition.me.globalParameters.linkedPathToNameFormUserEntity=Null:C1517)
		$name:=This:C1470.fullName
	Else 
		$pathParts:=Split string:C1554(cs:C1710.sfw_definition.me.globalParameters.linkedPathToNameFormUserEntity; ".")
		$source:=This:C1470
		$lastAttribute:=$pathParts.pop()
		For each ($pathPart; $pathParts)
			If ($pathPart="@()")
				$source:=$source[Substring:C12($pathPart; 1; Length:C16($pathPart)-2)]()
			Else 
				$source:=$source[$pathPart]
			End if 
		End for each 
		$name:=$source[$lastAttribute]
	End if 
	
local Function get nameInWindowTitle()->$nameInWindowTitle : Text
	// With this callback you return the name to displayed in the title of the window for the current item
	$nameInWindowTitle:=This:C1470.login
	
	// mark: password
local Function askForNewPassword()->$result : Object
	
	$result:=cs:C1710.sfw_passwordManager.me.askForNewPassword(This:C1470)
	If ($result.success)
		This:C1470.accesses.password.temporary:=False:C215
		This:C1470.accesses.password.temporaryPassword:=""
		This:C1470.accesses.password.sendTemporaryByMail:=False:C215
		This:C1470.accesses.password.lastChange:=cs:C1710.sfw_stmp.me.now()
		This:C1470.accesses.password.hash:=$result.hash
		$info:=This:C1470.save()
		If ($info.success=False:C215)
			
		End if 
	End if 
	
	
local Function generateTemporaryPassword()->$password : Text
	var $emailTemplate : cs:C1710.sfw_EmailTemplateEntity
	var $emailBody : Text
	
	$password:=cs:C1710.sfw_passwordManager.me.generateTemporaryPassword()
	
	This:C1470.accesses:=(This:C1470.accesses=Null:C1517) ? New object:C1471 : This:C1470.accesses
	This:C1470.accesses.password:=(This:C1470.accesses.password=Null:C1517) ? New object:C1471 : This:C1470.accesses.password
	This:C1470.accesses.password.temporary:=True:C214
	This:C1470.accesses.password.sendTemporaryByMail:=True:C214
	This:C1470.accesses.password.temporaryPassword:=$password
	
	This:C1470.accesses.password.lastReset:=cs:C1710.sfw_stmp.me.now()
	
	This:C1470.accesses.password.hash:=Generate password hash:C1533($password; cs:C1710.sfw_passwordManager.me.hashOptions)
	
	
local Function sendTemporaryPassword()
	// todo: send an email with the temporary password
	
	//$formula:=Formula from string("ds.sfw_User.get($1)."+cs.sfw_definition.me.globalParameters.users.linkedPathToEmailFromUserEntity)
	//$userEmail:=$formula.call(Null; This.UUID)
	
	//If ($userEmail#"")
	//$email:=New object
	//$dataContext:={userName: This.login; temporaryPassword: This.accesses.password.temporaryPassword}
	//$email:=ds.sfw_EmailTemplate.prepareEmail("UserPasswordTempo"; $dataContext)
	
	//If ($email#Null)
	//// To
	//$addressTo:=New object
	//$addressTo.emailAddress:=New object
	//$addressto.emailAddress.address:=$userEmail
	//$email.toRecipients:=New collection($addressTo)
	
	//cs.sfw_eMailManager.me.sendAnEMail($email)
	//End if 
	//End if 
	
local Function setLogin()->$login : Text
	$i:=0
	Repeat 
		This:C1470.login:=This:C1470.firstName+" "+This:C1470.lastName
		If ($i>0)
			This:C1470.login+="_"+String:C10($i)
		End if 
		$isUnique:=ds:C1482.sfw_checkValidationRuleUnique(This:C1470.getDataClass().getInfo().name; "login"; This:C1470.login; This:C1470.UUID)
		If ($isUnique=False:C215)
			$i+=1
		End if 
	Until ($isUnique)
	
	This:C1470.login:=cs:C1710.sfw_string.me.stringCapitalize(This:C1470.login)
	
	
local Function beforeSaveCreation()
	If (This:C1470.accesses.password="")
		$msg:=ds:C1482.sfw_readXliff("user.entry.confirm.newUser.createTemporaryPassword")
		$ok:=cs:C1710.sfw_dialog.me.confirm($msg)
		If ($ok)
			$password:=Form:C1466.current_item.generateTemporaryPassword()
			$msg:=ds:C1482.sfw_readXliff("user.entry.confirm.temporaryPasswordToPasteboard")
			$ok:=cs:C1710.sfw_dialog.me.confirm($msg)
			If ($ok)
				SET TEXT TO PASTEBOARD:C523($password)
			End if 
		End if 
		
	End if 
	
	
	
local Function afterSave()
	// This callback is called after saving the current item
	If (Application type:C494=4D Local mode:K5:1)
		If (Form:C1466.current_item.UUID=cs:C1710.sfw_userManager.me.info.UUID)
			cs:C1710.sfw_userManager.me.getAuthorizedProfiles()
		End if 
	Else 
		EXECUTE ON CLIENT:C651("@"; "sfw_userUpdate"; "getAuthorizedProfiles")
	End if 
	
	If (Bool:C1537(This:C1470.accesses.password.sendTemporaryByMail)=True:C214)
		This:C1470.sendTemporaryPassword()
		This:C1470.accesses.password.sendTemporaryByMail:=False:C215
		OB REMOVE:C1226(This:C1470.accesses.password; "temporaryPassword")
		$info:=This:C1470.save()
	End if 
	