Case of 
	: (FORM Event:C1606.code=On Load:K2:1)
		Form:C1466.hList:=New list:C375
		
		Form:C1466.lb_items:=New collection:C1472()
		$count:=ds:C1482.Team.all().length
		
		For each ($team_e; ds:C1482.Team.all().orderBy("id"))
			
			$subList:=New list:C375
			
			$team:=New object:C1471(\
				"uuid"; $team_e.UUID; \
				"name"; $team_e.name; \
				"id"; Form:C1466.lb_items.length+1; \
				"members"; New collection:C1472()\
				)
			
			For each ($membership_e; $team_e.memberships)
				$id:=$count+$team.members.length+$team.id
				
				$team.members.push(New object:C1471(\
					"uuid"; $membership_e.UUID_Staff; \
					"name"; $membership_e.staff.fullName; \
					"id"; $id\
					))
				
				APPEND TO LIST:C376($subList; $membership_e.staff.fullName; $id)
			End for each 
			
			APPEND TO LIST:C376(Form:C1466.hList; $team.name; $team.id; $subList; False:C215)
			
			Form:C1466.lb_items.push($team)
		End for each 
End case 