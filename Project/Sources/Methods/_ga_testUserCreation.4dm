//%attributes = {}
/*
_ga_testUserCreation()
--> Test user creation automatically
*/


$users:=New collection:C1472(\
New object:C1471("lastName"; "BAJET"; \
"firstName"; "MARY GRACE"; \
"roles"; "QI"; \
"teams"; "Quality"; \
"profile"; "qi"); \
New object:C1471("lastName"; "MOLINA"; \
"firstName"; "ESTER"; \
"roles"; "QI"; \
"teams"; "Quality"; \
"profile"; "qi"); \
New object:C1471("lastName"; "DY"; \
"firstName"; "KARLA PATRICIA"; \
"roles"; "QS"; \
"teams"; "Quality"; \
"profile"; "qs"); \
New object:C1471("lastName"; "VARGAS"; \
"firstName"; "VICKY"; \
"roles"; "QI"; \
"teams"; "Quality"; \
"profile"; "qi")\
)


For each ($user; $users)
	
	_ga_createUsers($user)
	
	
	If ($res.success)
		
		For each ($team; $user.teams)
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