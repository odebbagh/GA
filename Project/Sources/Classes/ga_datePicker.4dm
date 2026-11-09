// ga_datePicker
// The framework calendar (form sfw_calendar: year / month pop-ups, today, cancel / OK), opened
// under a button of the panel by the panel's own code.
// Why not the framework widget (subform sfw_widget_datePicker_icon): its button lives inside a
// subform, so the click never reaches the panel's form method - the record is changed but the
// toolbar is not told, and Save stays disabled until the next event. Called from a button of
// the panel, the click is a panel event: the panel can activate Save at once.
singleton Class constructor
	
	
// Opens the calendar under the object $objectName of the current form, on $date (today when
// empty). Returns the date chosen - a click on a day, or OK on the date shown - or !00-00-00!
// when cancelled.
Function pick($date : Date; $objectName : Text)->$picked : Date
	var $formData : Object
	var $window : Integer
	
	$formData:=New object:C1471("display"; New object:C1471("date"; ($date=!00-00-00!) ? Current date:C33 : $date))
	If ($date#!00-00-00!)
		$formData.display.datesToHighlight:=New collection:C1472(New object:C1471("date"; $date; "color"; "red"; "colorText"; "white"))
	End if 
	OBJECT GET COORDINATES:C663(*; $objectName; $left; $top; $right; $bottom)
	CONVERT COORDINATES:C1365($left; $bottom; XY Current form:K27:5; XY Main window:K27:8)
	$window:=Open form window:C675("sfw_calendar"; Pop up form window:K39:11; $left; $bottom)
	DIALOG:C40("sfw_calendar"; $formData)
	CLOSE WINDOW:C154($window)
	$picked:=(OK=1) ? $formData.display.date : !00-00-00!
	
Function pickInto($object : Object; $attribute : Text; $anchor : Text)->$changed : Boolean
	// The calendar under the clicked button (or under $anchor), writing the date chosen into
	// $object[$attribute]. True when the date changed. Used by every date button of the app
	// outside the QA module, so they all open the same calendar.
	var $current; $date : Date
	
	If ($object=Null:C1517)
		return 
	End if 
	If (Count parameters:C259<3)
		$anchor:=OBJECT Get name:C1087(Object current:K67:2)
	End if 
	If ($anchor="")
		$anchor:=OBJECT Get name:C1087(Object current:K67:2)
	End if 
	$current:=!00-00-00!
	If ($object[$attribute]#Null:C1517)
		$current:=$object[$attribute]
	End if 
	$date:=This:C1470.pick($current; $anchor)
	If ($date#!00-00-00!) && ($date#$current)
		$object[$attribute]:=$date
		$changed:=True:C214
	End if 
	
