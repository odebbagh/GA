//%attributes = {}
//BackgroundColor lb_assignments

If (This:C1470.certified)
	$today:=Current date:C33()
	
	$date_15j:=Add to date:C393($today; 0; 0; 15)
	$date_30j:=Add to date:C393($today; 0; 0; 30)
	
	Case of 
		: (This:C1470.oneTime)
			$0:="#7befb2"  //green
			
		: ((This:C1470.expiredIn>=$today) & (This:C1470.expiredIn<=$date_15j))
			$0:="#ff7979"  //red
			
		: ((This:C1470.expiredIn>=$today) & (This:C1470.expiredIn<=$date_30j))
			$0:="#f6e58d"  //yellow
			
		: (This:C1470.expiredIn>$date_30j)
			$0:="#7befb2"  //green
			
		Else 
			$0:="transparent"
	End case 
Else 
	$0:="transparent"
End if 
