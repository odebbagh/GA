


Case of 
		
	: (Form event code:C388=On Data Change:K2:15)
		If (Form:C1466.currentTeam.members.extract("selected").distinct().length=1) & (Form:C1466.currentTeam.members.extract("selected").distinct()[0]=True:C214)
			
			Form:C1466.currentTeam.selected:=True:C214
			//OBJECT SET ENTERABLE(*; "membersChecBox"; False)
			
		Else 
			Form:C1466.currentTeam.selected:=False:C215
			
		End if 
		
		Form:C1466.teams:=Form:C1466.teams
		
	Else 
		
		
End case 




