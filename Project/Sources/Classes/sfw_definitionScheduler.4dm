property hourly : Boolean
property daily : Boolean
property weekly : Boolean
property monthly : Boolean
property yearly : Boolean
property dayNumbers : Collection
property hourToStart : Integer
property minuteToStart : Integer
property hourMini : Integer
property hourMaxi : Integer
property dayNumber : Integer
property minutesToStart : Collection
property displayOrder : Integer

Class constructor($typePeriodicity : Text)
	
	Case of 
		: ($typePeriodicity="hourly")
			This:C1470.hourly:=True:C214
			This:C1470.displayOrder:=1
		: ($typePeriodicity="daily")
			This:C1470.daily:=True:C214
			This:C1470.displayOrder:=2
		: ($typePeriodicity="weekly")
			This:C1470.weekly:=True:C214
			This:C1470.displayOrder:=3
		: ($typePeriodicity="monthly")
			This:C1470.monthly:=True:C214
			This:C1470.displayOrder:=4
		: ($typePeriodicity="yearly")
			This:C1470.yearly:=True:C214
			This:C1470.displayOrder:=5
	End case 
	This:C1470.hourToStart:=0
	This:C1470.minuteToStart:=0
	This:C1470.hourMini:=0
	This:C1470.hourMaxi:=23
	This:C1470.dayNumbers:=[]
	This:C1470.dayNumber:=Monday:K10:13
	This:C1470.minutesToStart:=[]
	
	//Mark:- Functions set 
	
Function setHourToStart($hour : Integer)
	
	$hour:=$hour%24
	This:C1470.hourToStart:=$hour
	
Function setMinuteToStart($minute : Integer)
	
	$minute:=$minute%60
	This:C1470.minuteToStart:=$minute
	
Function setMinutesToStart($minutes : Collection)
	This:C1470.minutesToStart:=[]
	For each ($minute; $minutes)
		$minute:=$minute%60
		This:C1470.minutesToStart.push($minute)
	End for each 
	
Function setHourMinMax($hourMini : Integer; $hourMaxi : Integer)
	
	This:C1470.hourMini:=$hourMini || 0
	This:C1470.hourMaxi:=$hourMaxi || 23
	
	
Function setDayNumbers( ...  : Integer)
	
	For ($p; 1; Count parameters:C259)
		This:C1470.dayNumbers.push(${$p})
	End for 
	This:C1470.dayNumbers:=This:C1470.dayNumbers.distinct()
	
Function setDayNumber($dayNumber : Integer)
	
	This:C1470.dayNumber:=$dayNumber