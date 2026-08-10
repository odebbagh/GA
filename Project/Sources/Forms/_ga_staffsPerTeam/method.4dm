
Case of 
		
	: (Form event code:C388=On Load:K2:1)
		
		LISTBOX SELECT ROW:C912(*; "teams"; 1)
		
		If (Form:C1466.currentTeam.selected=True:C214)
			For ($j; 0; Form:C1466.currentTeam.members.length-1)
				
				Form:C1466.currentTeam.members[$j].selected:=True:C214
			End for 
			//OBJECT SET ENTERABLE(*; "membersChecBox"; False)
			
		End if 
		Form:C1466.currentTeam.members:=Form:C1466.currentTeam.members
		
		
	Else 
		
End case 