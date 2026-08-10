

Case of 
	: (FORM Event:C1606.code=On Data Change:K2:15)
		
		CLEAR LIST:C377(Form:C1466.hList)
		
		Form:C1466.hList:=New list:C375
		
		If (Form:C1466.words#"")
			$data:=ds:C1482.Team.query("name = :1"; "@"+Form:C1466.words+"@").orderBy("id")
		Else 
			$data:=ds:C1482.Team.all().orderBy("id")
		End if 
		
		Form:C1466.lb_items:=New collection:C1472()
		
		$count:=$data.length
		
		For each ($team_e; $data)
			
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
