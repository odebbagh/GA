Case of 
	: (Form event code:C388=On Data Change:K2:15)
		
		$sumGoods:=0
		$totalLots:=Form:C1466.child_lots.length-1
		$initialGoods:=This:C1470.totalTransferred-This:C1470.transferedRejects
		
		For ($i; 1; $totalLots)
			$sumGoods+=Form:C1466.child_lots[$i].transferedGoods
		End for 
		
		If (Form:C1466.child_lots[0].transferedGoods<$sumGoods)
			This:C1470.transferedGoods:=$initialGoods
		Else 
			This:C1470.totalTransferred+=This:C1470.transferedGoods-$initialGoods
		End if 
		
End case 