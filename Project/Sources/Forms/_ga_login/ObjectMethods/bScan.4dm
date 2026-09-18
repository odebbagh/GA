


Case of 
		
	: (Form event code:C388=On Clicked:K2:4)
		
		//var $esUsers : cs.sfw_UserSelection
		//var $eUser : cs.sfw_UserEntity
		
		/*
		$barcodeData:=cs.Util_ScannerManager.me.communicateWithScanner()  //Old versiono _ga_communicateWithScanner()
		
		//$esUsers:=ds.sfw_User.query("moreData.barcodeData = :1"; $barcodeData)//using application user barcode
		$esUsers:=ds.Staff.query("moreData.barcodeData = :1"; $barcodeData)  //Using staff badge
		If (OK=1)
			If ($esUsers.length=1)
				$eUser:=$esUsers.first().user
				
				If ($eUser#Null)
					
					If (Bool($eUser.accesses.asDesigner))
						CHANGE CURRENT USER("Designer"; "")  //cs.sfw_definition.me.globalParameters.users.designerPassword)
					End if
					SET USER ALIAS($eUser.login)
					Form.currentUser:=$eUser
					cs.sfw_userManager.me.defineUser()
					ACCEPT
					
				Else
					Form.error:="Unknown user"
				End if
				
			Else
				Form.error:="Unknown user"
			End if
		End if
		*/
		
		var $result : Object
		var $eUser : cs:C1710.sfw_UserEntity
		
		$result:=cs:C1710.Util_ScannerManager.me.resolveStaffFromScanOrRequest()
		
		If ($result.cancelled)
			
		Else
			If (Not:C34($result.success))
				Form:C1466.error:="Unknown user"
			Else
				$eUser:=$result.staff.user
				
				If (Bool:C1537($eUser.accesses.asDesigner))
					CHANGE CURRENT USER:C289("Designer"; "")  //cs.sfw_definition.me.globalParameters.users.designerPassword)
				End if
				SET USER ALIAS:C1666($eUser.login)
				Form:C1466.currentUser:=$eUser
				cs:C1710.sfw_userManager.me.defineUser()
				ACCEPT:C269
			End if
		End if 
	Else 
		
End case 

