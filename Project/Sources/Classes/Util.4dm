singleton Class constructor
	
Function trim($text : Text; $chars : Collection)->$result : Text
	$result:=$text
	For each ($char; $chars)
		$items:=Split string:C1554($result; $char; sk ignore empty strings:K86:1+sk trim spaces:K86:2)
		$result:=$items.join($char)
	End for each 
	
	
Function cacheLoad()
	
	If (Storage:C1525.cache=Null:C1517)
		Use (Storage:C1525)
			Storage:C1525.cache:=New shared object:C1526
		End use 
	End if 
	If (Storage:C1525.cache.startDate=Null:C1517)
		Use (Storage:C1525.cache)
			Storage:C1525.cache.startDate:=Current date:C33()
		End use 
	End if 
	If (Storage:C1525.cache.endDate=Null:C1517)
		Use (Storage:C1525.cache)
			Storage:C1525.cache.endDate:=Current date:C33()
		End use 
	End if 
	If (Undefined:C82(Storage:C1525.cache.interval))
		Use (Storage:C1525.cache)
			Storage:C1525.cache.interval:="0"
		End use 
	End if 
	
	
Function setDateInterval($pushUp; $title)
	This:C1470.cacheLoad()
	
	$form:=New object:C1471
	$form.startDate:=Storage:C1525.cache.startDate
	$form.endDate:=Storage:C1525.cache.endDate
	$form.interval:=Storage:C1525.cache.interval
	MOUSE POSITION:C468($mouseX; $mouseY; $mouseButtons)
	CONVERT COORDINATES:C1365($mouseX; $mouseY; XY Current form:K27:5; XY Main window:K27:8)
	If ($pushUp)
		$mouseY:=$mouseY-190
		$mouseX:=$mouseX-100
	End if 
	$form.pushUp:=$pushUp
	$windRef:=Open window:C153($mouseX; $mouseY; $mouseX+270; $mouseY+165; Movable dialog box:K34:7; "Set date interval")
	DIALOG:C40("_ga_setDateInterval"; $form)
	CLOSE WINDOW:C154($windRef)
	Use (Storage:C1525.cache)
		Storage:C1525.cache.startDate:=$form.startDate
		Storage:C1525.cache.endDate:=$form.endDate
		Storage:C1525.cache.interval:=$form.interval
	End use 
	
	
Function btnDatePicker($object; $attribut)
	//If (Form.sfw.checkIsInModification())
	
	
	$form:=New object:C1471
	$form.date:=$object[$attribut]
	
	OBJECT GET COORDINATES:C663(Self:C308->; $left; $top; $rigth; $bottom)
	CONVERT COORDINATES:C1365($left; $bottom; XY Current form:K27:5; XY Main window:K27:8)
	Open window:C153($left; $bottom; $left+285; $bottom+210; Movable dialog box:K34:7; "calendar")
	DIALOG:C40("_ga_calendar"; $form)
	
	If (OK=1)
		$object[$attribut]:=$form.calendar.display.date
	End if 
	
	//End if 
Function firstLetterLowerCase($inText : Text)->$outText : Text
	
	If (Length:C16($inText)>0)
		$inText[[1]]:=Lowercase:C14($inText[[1]])
	End if 
	$outText:=$inText
	
Function firstLetterUpperCase($inText : Text)->$outText : Text
	
	If (Length:C16($inText)>0)
		$inText[[1]]:=Uppercase:C13($inText[[1]])
	End if 
	$outText:=$inText
	