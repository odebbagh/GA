//%attributes = {}
/*
_ga_createUsers

default password :  pSzjGX!Ey9P1c~p
hash : $2b$10$1KIfSf/DkyivGUKEeHHPDulQ51F9LSOuyFmHy6X9TvAXi1K79E4ri

Caution : Make sure the users json file at the right location and have the same name (GA_employee_list.csv)
*/

If (True:C214)
	$file_excel:=Folder:C1567(fk data folder:K87:12).file("DataJson/GA_employee_list.csv")  //Make sure the file at the right location and have the same name
	
	$records_excel:=Split string:C1554($file_excel.getText(); "\r\n")
	
	$records_excel.shift()  //remove the header
	
	$staffs_excel:=New collection:C1472()
	
	For each ($record; $records_excel)
		$staffs_excel.push(New object:C1471(\
			"lastName"; Split string:C1554(Split string:C1554($record; ";")[1]; ",")[0]; \
			"firstName"; Split string:C1554(Split string:C1554($record; ";")[1]; ",")[1]; \
			"roles"; Split string:C1554(Split string:C1554($record; ";")[2]; ","); \
			"teams"; Split string:C1554(Split string:C1554($record; ";")[3]; ","); \
			"code"; Split string:C1554(Split string:C1554($record; ";")[4]; ",")\
			))
	End for each 
	
	TRUNCATE TABLE:C1051([Team:136])
	TRUNCATE TABLE:C1051([Membership:137])
	TRUNCATE TABLE:C1051([Role:132])
	TRUNCATE TABLE:C1051([StaffRole:63])
	TRUNCATE TABLE:C1051([Staff:135])
	TRUNCATE TABLE:C1051([sfw_User:16])
	
	//SET DATABASE PARAMETER([Staff]; Table sequence number; 2)
	
	For each ($staff; $staffs_excel)
		
		
		$user:=ds:C1482.sfw_User.new()
		$user.firstName:=$staff.firstName
		$user.lastName:=$staff.lastName
		$user.login:=Lowercase:C14($staff.firstName+$staff.lastName)
		$user.accesses:=JSON Parse:C1218("{\"asDesigner\":true,\"password\":{\"temporary\":true,\"sendTemporaryByMail\":true,\"lastReset\":705253775,\"hash\":\"$2b$10$1KIfSf/DkyivGUKEeHHPDulQ51F9LSOuyFmHy6X9TvAXi1K79E4ri\",\"lastChange\":705253879}}")  //pSzjGX!Ey9P1c~p
		$user.asDesigner:=True:C214
		$user.isInactive:=False:C215
		$user.moreData:=New object:C1471()
		$recodNumber:=ds:C1482.sfw_Counter.getNextValue("sfw_User")
		$user.moreData.barcodeData:=String:C10($recodNumber; "0000000000")
		$res:=$user.save()
		
		If (Not:C34($res.success))
			TRACE:C157
		End if 
		
		
		$staff_e:=ds:C1482.Staff.new()
		
		$staff_e.UUID_User:=$user.UUID
		If ($staff.code#Null:C1517) && ($staff.code.length>0)
			$staff_e.code:=$staff.code[0]
		Else 
			$staff_e.code:=String:C10($staff_e.code; "00000#")
		End if 
		
		$staff_e.firstName:=$staff.firstName
		$staff_e.lastName:=$staff.lastName
		
		$staff_e.contactDetails:=New object:C1471(\
			"addresses"; New collection:C1472(); \
			"communications"; New collection:C1472()\
			)
		
		$staff_e.moreData:=New object:C1471(\
			"retrainNotified"; False:C215\
			)
		
		
		$res:=$staff_e.save()
		
		
		If ($res.success)
			
			For each ($team; $staff.teams)
				$teams_es:=ds:C1482.Team.query("name = :1"; $team)
				
				If ($teams_es.length>0)
					$team_e:=$teams_es[0]
				Else 
					$team_e:=ds:C1482.Team.new()
					$team_e.levelID:=ds:C1482.Team.all().length+1
					$team_e.name:=$team
					
					$res:=$team_e.save()
					
					If (Not:C34($res.success))
						TRACE:C157
					End if 
				End if 
				
				$membership_e:=ds:C1482.Membership.new()
				
				$membership_e.UUID_Staff:=$staff_e.UUID
				$membership_e.UUID_Team:=$team_e.UUID
				
				$res:=$membership_e.save()
				
				If (Not:C34($res.success))
					TRACE:C157
				End if 
			End for each 
			
			For each ($role; $staff.roles)
				$roles_es:=ds:C1482.Role.query("name = :1"; $role)
				
				If ($roles_es.length>0)
					$role_e:=$roles_es[0]
				Else 
					$role_e:=ds:C1482.Role.new()
					
					$role_e.name:=$role
					
					$res:=$role_e.save()
					
					If (Not:C34($res.success))
						TRACE:C157
					End if 
				End if 
				
				$staffRole_e:=ds:C1482.StaffRole.new()
				
				$staffRole_e.UUID_Staff:=$staff_e.UUID
				$staffRole_e.UUID_Role:=$role_e.UUID
				
				$res:=$staffRole_e.save()
				
				If (Not:C34($res.success))
					TRACE:C157
				End if 
			End for each 
			
		End if 
	End for each 
End if 

