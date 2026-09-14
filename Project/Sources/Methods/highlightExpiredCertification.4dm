//%attributes = {}
//BackgroundColor lb_assignments

// Purpose: Row color from assignment expiry window; uses precomputed daysUntilExpiry (Date props are unreliable in listbox rowFillSource).
// modified by 4D/PS [2026-june-08]

var $days : Integer

If (Not:C34(Bool:C1537(This:C1470.hasAssignment)))
	$0:="transparent"
	return 
End if 

If (Bool:C1537(This:C1470.overrideExpired))
	$0:="#87CEEB"
	return 
End if 

If (Bool:C1537(This:C1470.oneTime))
	$0:="#7befb2"  //green — one-time certification
	return 
End if 

$days:=Num:C11(This:C1470.daysUntilExpiry)

Case of 
	: ($days<0)
		$0:="#ff7979"  //red — past expiry date
		
	: ($days<=15)
		$0:="#ff7979"  //red — expiring within 15 days
		
	: ($days<=30)
		$0:="#f6e58d"  //yellow — expiring within 30 days
		
	: ($days>30)
		$0:="#7befb2"  //green — more than 30 days remaining
		
	Else 
		$0:="transparent"
End case 
