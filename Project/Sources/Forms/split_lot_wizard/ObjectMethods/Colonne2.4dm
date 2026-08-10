Case of 
	: (Form event code:C388=On Data Change:K2:15)
		
		$sumRejects:=0
		$totalLots:=Form:C1466.child_lots.length-1
		$initialRejects:=This:C1470.totalTransferred-This:C1470.transferedGoods
		
		For ($i; 1; $totalLots)
			$sumRejects+=Form:C1466.child_lots[$i].transferedRejects
		End for 
		
		If (Form:C1466.child_lots[0].transferedRejects<$sumRejects)
			This:C1470.transferedRejects:=$initialRejects
		Else 
			This:C1470.totalTransferred+=This:C1470.transferedRejects-$initialRejects
		End if 
		
End case 