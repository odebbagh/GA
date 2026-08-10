Class extends Entity



Function get type()->$type : Text
	
	Case of 
		: (This:C1470.periodicity.hourly)
			$type:="Hourly"
		: (This:C1470.periodicity.daily)
			$type:="Daily"
		: (This:C1470.periodicity.weekly)
			$type:="Weekly"
		: (This:C1470.periodicity.monthly)
			$type:="Montlhy"
		: (This:C1470.periodicity.yearly)
			$type:="Yearly"
	End case 
	
	
Function get lastExecution()->$dateAndTime : Text
	var $eLastLog : cs:C1710.sfw_SchedulerLogEntity
	
	If (This:C1470.schedulerLogs.length=0)
		$dateAndTime:=ds:C1482.sfw_readXliff("scheduler.never"; "never")
	Else 
		$stmp:=This:C1470.schedulerLogs.max("stmp")
		$dateAndTime:=String:C10((cs:C1710.sfw_stmp.me.getDate($stmp)); Internal date short special:K1:4)+" - "+String:C10((cs:C1710.sfw_stmp.me.getTime($stmp)); HH MM:K7:2)
	End if 