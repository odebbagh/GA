//%attributes = {"executedOnServer":true}
/*
__import_data_staff

*/

///*
/**
Create user: sfw_User & Staff tables
**/
/*
If (True)
TRUNCATE TABLE([Staff])
TRUNCATE TABLE([sfw_User])

$user:=ds.sfw_User.new()
$user.firstName:="Hassan"
$user.lastName:="Sribet"
$user.login:="hassansribet"
$user.accesses:=JSON Parse("{\"asDesigner\":true,\"password\":{\"temporary\":false,\"sendTemporaryByMail\":false,\"lastReset\":705253775,\"hash\":\"$2b$10$1KIfSf/DkyivGUKEeHHPDulQ51F9LSOuyFmHy6X9TvAXi1K79E4ri\",\"lastChange\":705253879}}")  //pSzjGX!Ey9P1c~p
$user.asDesigner:=True
$user.moreData:=New object()
$recodNumber:=ds.sfw_Counter.getNextValue("sfw_User")
$user.moreData.barcodeData:=String($recodNumber; "0000000000")
$res:=$user.save()

If (Not($res.success))
TRACE
End if 

$staff:=ds.Staff.new()
$staff.UUID_User:=$user.UUID
$staff.firstName:="Hassan"
$staff.lastName:="Sribet"
$staff.code:=String($staff.codeID; "00000#")

$staff.contactDetails:=New object(\
"addresses"; New collection(); \
"communications"; New collection()\
)

$res:=$staff.save()

If (Not($res.success))
TRACE
End if 

$user:=ds.sfw_User.new()
$user.firstName:="Omar"
$user.lastName:="Debbagh"
$user.login:="omardebbagh"
$user.accesses:=JSON Parse("{\"asDesigner\":true,\"password\":{\"temporary\":false,\"sendTemporaryByMail\":false,\"lastReset\":706358866,\"hash\":\"$2b$10$1KIfSf/DkyivGUKEeHHPDulQ51F9LSOuyFmHy6X9TvAXi1K79E4ri\",\"lastChange\":706358916}}")
$user.moreData:=New object()
$recodNumber:=ds.sfw_Counter.getNextValue("sfw_User")
$user.moreData.barcodeData:=String($recodNumber; "0000000000")
$res:=$user.save()

If (Not($res.success))
TRACE
End if 

$staff:=ds.Staff.new()
$staff.UUID_User:=$user.UUID
$staff.firstName:="Omar"
$staff.lastName:="Debbagh"
$staff.code:=String($staff.codeID; "00000#")

$staff.contactDetails:=New object(\
"addresses"; New collection(); \
"communications"; New collection()\
)

$res:=$staff.save()

If (Not($res.success))
TRACE
End if 
End if 
*/

/**
import staffs
**/
If (True:C214)
	
	$counter:=ds:C1482.Certification.all().extract("ref").max()
	
	$file_excel:=Folder:C1567(fk data folder:K87:12).file("DataJson/GA_employee_list.csv")
	
	$records_excel:=Split string:C1554($file_excel.getText(); "\r\n")
	
	$records_excel.shift()  //remove the header
	
	$staffs_excel:=New collection:C1472()
	
	For each ($record; $records_excel)
		$staffs_excel.push(New object:C1471(\
			"lastName"; Split string:C1554(Split string:C1554($record; ";")[1]; ",")[0]; \
			"firstName"; Split string:C1554(Split string:C1554($record; ";")[1]; ",")[1]; \
			"roles"; Split string:C1554(Split string:C1554($record; ";")[2]; ","); \
			"teams"; Split string:C1554(Split string:C1554($record; ";")[3]; ",")\
			))
	End for each 
	
	$remaingCertification:=New collection:C1472()
	
	$trainingFile:=Folder:C1567(fk data folder:K87:12).file("DataJson/employeeTraining_export.json")
	
	$trainings:=JSON Parse:C1218($trainingFile.getText())
	
	$employee_Log:=Folder:C1567(fk data folder:K87:12).file("DataJson/staff_export.json")  //.file("DataJson/employees.json")
	If ($employee_Log.exists)
		$employees:=JSON Parse:C1218($employee_Log.getText())
		
		$employees:=$employees.map("_ga_normalizeEmployeeForQuery")
		
		TRUNCATE TABLE:C1051([Team:136])
		TRUNCATE TABLE:C1051([Membership:137])
		TRUNCATE TABLE:C1051([Role:132])
		TRUNCATE TABLE:C1051([StaffRole:63])
		TRUNCATE TABLE:C1051([Staff:135])
		TRUNCATE TABLE:C1051([sfw_User:16])
		TRUNCATE TABLE:C1051([CertificationAssignment:134])
		
		//SET DATABASE PARAMETER([Staff]; Table sequence number; 2)
		
		For each ($staff; $staffs_excel)
			
			
			$user:=ds:C1482.sfw_User.new()
			$user.firstName:=$staff.firstName
			$user.lastName:=$staff.lastName
			$user.login:=Lowercase:C14($staff.firstName+$staff.lastName)
			$user.accesses:=JSON Parse:C1218("{\"asDesigner\":true,\"password\":{\"temporary\":true,\"sendTemporaryByMail\":false,\"lastReset\":705253775,\"hash\":\"$2b$10$1KIfSf/DkyivGUKEeHHPDulQ51F9LSOuyFmHy6X9TvAXi1K79E4ri\",\"lastChange\":705253879}}")  //pSzjGX!Ey9P1c~p
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
			$staff_e.code:=String:C10($staff_e.codeID; "00000#")
			$staff_e.firstName:=$staff.firstName
			$staff_e.lastName:=$staff.lastName
			
			$existingStaff:=$employees.query(\
				"Last_Name_key = :1 & First_Name_key = :2"; \
				Replace string:C233($staff.lastName; " "; ""); \
				Replace string:C233($staff.firstName; " "; ""))
			$existingStaff:=$existingStaff.length>0 ? $existingStaff : $employees.query("Last_Name_key = :1 & First_Name_key = :2"; Replace string:C233($staff.firstName; " "; ""); Replace string:C233($staff.lastName; " "; ""))
			
			If ($existingStaff.length>0)
				$employee:=$existingStaff[0]
				$division:=ds:C1482.Division.query("name =:1"; Split string:C1554($employee.division; "\r"; sk trim spaces:K86:2).join("\r"))
				
				If ($division.length>0)
					$staff_e.UUID_Division:=$division[0].UUID
				Else 
					$staff_e.UUID_Division:=16*"00"
				End if 
				
				$staff_e.citizenShipStatus:=$employee.citizenShipStatus
				$staff_e.contactDetails:=$employee.contactDetails
				$staff_e.stmpRetrain:=Date:C102($employee.retrainDate)=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build(Date:C102($employee.retrainDate))
				$staff_e.stmpCreation:=$employee.creationDate
				$staff_e.stmpTermination:=Date:C102($employee.terminationDate)=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build(Date:C102($employee.terminationDate))
				$staff_e.stmpHire:=Date:C102($employee.hireDate)=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build(Date:C102($employee.hireDate))
				$staff_e.terminated:=$employee.terminated
				$staff_e.shift:=Num:C11($employee.shift)=1 ? "A" : (Num:C11($employee.shift)=2 ? "B" : $employee.shift)
				
				
			Else 
				//
			End if 
			
			$staff_e.moreData:=New object:C1471("retrainNotified"; False:C215)
			
			$res:=$staff_e.save()
			
			If ($res.success)
				
				
/**
import certification Assignment
**/
				If ($existingStaff.length>0)
					$employee:=$existingStaff[0]
					$staffTrainings:=$trainings.query("Employee_Code =:1"; $employee.employeeCode)
				End if 
				
				For each ($training; $staffTrainings)
					
					var $certImport : Object
					
					$certificationAssigment_e:=ds:C1482.CertificationAssignment.new()
					
					// Purpose: Certification date from legacy Tdate; validity days from Certification.duration (default 365), not raw training row only.
					// modified by 4D/PS [2026-june-02]
					If (Date:C102($training.Tdate)=!00-00-00!)
						$certificationAssigment_e.certificationStmp:=0
					Else 
						$certificationAssigment_e.certificationStmp:=cs:C1710.sfw_stmp.me.build(Date:C102($training.Tdate))
					End if 
					
					$certificationAssigment_e.UUID_Staff:=$staff_e.UUID
					
					$certImport:=ds:C1482.Certification.importForLegacyTraining($training.T_Type; Num:C11($training.Duration); $counter)
					$counter:=$certImport.refCounter
					
					If ($certImport.success) && ($certImport.certification#Null:C1517)
						$certificationAssigment_e.UUID_Certification:=$certImport.certification.UUID
						$certificationAssigment_e.expiredIn:=$certImport.validityDays
					Else 
						$remaingCertification.push($training.T_Type)
					End if 
					
					$res:=$certificationAssigment_e.save()
					
					If (Not:C34($res.success))
						TRACE:C157
					End if 
				End for each 
				
				// Purpose: Sync Staff.stmpRetrain from re-training milestones after legacy assignment import.
				// modified by 4D/PS [2026-june-12]
				If (ds:C1482.CertificationAssignment.query("UUID_Staff = :1"; $staff_e.UUID).length>0)
					$staff_e.recomputeRetrainDate()
				End if 
				
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
End if 
SET TEXT TO PASTEBOARD:C523($remaingCertification.distinct().join("\n"))
