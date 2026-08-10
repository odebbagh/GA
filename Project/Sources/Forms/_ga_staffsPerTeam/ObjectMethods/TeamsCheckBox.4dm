


Case of 
		
		
	: (Form event code:C388=On Data Change:K2:15)
		
		If (Form:C1466.currentTeam.selected=True:C214)
			
			For ($j; 0; Form:C1466.currentTeam.members.length-1)
				
				Form:C1466.currentTeam.members[$j].selected:=True:C214
			End for 
			//OBJECT SET ENTERABLE(*; "membersChecBox"; False)
		Else 
			
			For ($j; 0; Form:C1466.currentTeam.members.length-1)
				
				Form:C1466.currentTeam.members[$j].selected:=False:C215
			End for 
			
			OBJECT SET ENTERABLE:C238(*; "membersChecBox"; True:C214)
		End if 
		
		Form:C1466.currentTeam.members:=Form:C1466.currentTeam.members
		
		
	Else 
		
		
End case 




