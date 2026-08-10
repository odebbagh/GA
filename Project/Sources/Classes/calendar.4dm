
Class constructor
	This:C1470.dayLabels:=Split string:C1554(ds:C1482.sfw_readXliff("wsfw.dateAndTime.daysList.abrev"); ";")
	This:C1470.months:=Split string:C1554(ds:C1482.sfw_readXliff("dateAndTime.months"; "January;Febuary;March;April;May;June;July;August;September;October;November;December"); ";")
	
	
	
Function build($date : Date)
	This:C1470.display:=New object:C1471()
	This:C1470.display.monthNumber:=Month of:C24($date)
	This:C1470.display.month:=This:C1470.months[This:C1470.display.monthNumber-1]
	This:C1470.display.year:=Year of:C25($date)
	
	This:C1470.nextMonth(This:C1470.display.monthNumber; This:C1470.display.year)
	This:C1470.previousMonth(This:C1470.display.monthNumber; This:C1470.display.year)
	
	$startDate:=Add to date:C393(!00-00-00!; Year of:C25($date); Month of:C24($date); 1)
	$endDate:=Add to date:C393($startDate; 0; 1; 0)-1
	$numberOfDays:=$endDate-$startDate+1
	
	$startDay:=Day number:C114($startDate)-1
	
	This:C1470.lines:=New collection:C1472()
	$dayNumbers:=New collection:C1472()
	This:C1470.lines.push($dayNumbers)
	For ($i; 1-$startDay; $numberOfDays)
		If ($dayNumbers.length=7)
			$dayNumbers:=New collection:C1472()
			This:C1470.lines.push($dayNumbers)
		End if 
		
		$day:=New object:C1471()
		$day.isAvailable:=False:C215
		
		$date_temp:=Add to date:C393(!00-00-00!; This:C1470.display.year; This:C1470.display.monthNumber; $i)
		If ($i>0) & ($date_temp>=Current date:C33)
			$options:=New object:C1471
			$options.date:=$date_temp
			$options.nbSlots:=20
			$options.dontMoveDate:=True:C214
			
			$avAppointements:=ds:C1482.Appointment.getAvailableAppointements(Session:C1714.storage.appointment.medicalStaff.UUID; Session:C1714.storage.appointment.medicalHouse.UUID; ""; Session:C1714.storage.appointment.consultation.UUID; $options)
			
			$uuids_avAppointements:=$avAppointements.distinct("UUID")
			$es_toDelete:=ds:C1482.Appointment.query("UUID in :1"; $uuids_avAppointements)
			$es_toDelete:=$es_toDelete.drop()
			
			If ($avAppointements.length#0)
				$day.isAvailable:=True:C214
			End if 
		End if 
		
		
		$day.dayNumber:=String:C10(Choose:C955($i>0; String:C10($i); ""))
		$dayNumbers.push($day)
	End for 
	$dayNumbers.resize(7; New object:C1471("dayNumber"; ""; "isAvailable"; False:C215))
	
	
	
Function previousMonth($monthNumber : Integer; $year : Integer)
	This:C1470.prev:=New object:C1471()
	If ($monthNumber=1)
		This:C1470.prev.month:=12
		This:C1470.prev.year:=$year-1
	Else 
		This:C1470.prev.month:=$monthNumber-1
		This:C1470.prev.year:=$year
	End if 
	
	
Function nextMonth($monthNumber : Integer; $year : Integer)
	This:C1470.next:=New object:C1471()
	If ($monthNumber=12)
		This:C1470.next.month:=1
		This:C1470.next.year:=$year+1
	Else 
		This:C1470.next.month:=$monthNumber+1
		This:C1470.next.year:=$year
	End if 
	