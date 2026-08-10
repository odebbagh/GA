Class extends Entity

local Function get nameInWindowTitle()->$nameInWindowTitle : Text
	$nameInWindowTitle:=String:C10(This:C1470.transactionNumber)
	
	
local Function get transactionDate()->$date : Date
	$date:=This:C1470.stmpTransaction=0 ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate(This:C1470.stmpTransaction; True:C214)
	
local Function set transactionDate($date : Date)
	This:C1470.stmpTransaction:=$date=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build($date)

	