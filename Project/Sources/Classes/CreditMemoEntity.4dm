Class extends Entity


local Function get nameInWindowTitle()->$nameInWindowTitle : Integer
	$nameInWindowTitle:=This:C1470.cmNum
	
local Function get creditMemoDate()->$date : Date
	$date:=This:C1470.cmStmp=0 ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate(This:C1470.cmStmp; True:C214)
	
local Function set creditMemoDate($date : Date)
	This:C1470.cmStmp:=$date=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build($date)
	
	
	