
property window : Integer
property displayLineNb : Integer

shared singleton Class constructor
	This:C1470.window:=0
	This:C1470.displayLineNb:=0
	
	//MARK:-open tracker interface 
Function open()
	
	CALL WORKER:C1389("trackingList"; Formula:C1597(cs:C1710.sfw_tracker.me.launch()))
	
	
Function launch()
	
	If (This:C1470.window=0)
		
		$refWindow:=Open form window:C675("sfw_trackerList"; Palette form window:K39:9; On the left:K39:2; At the top:K39:5)
		Use (This:C1470)
			This:C1470.window:=$refWindow
		End use 
		SET WINDOW TITLE:C213("Tracking"; $refWindow)
		DIALOG:C40("sfw_trackerList")
		CLOSE WINDOW:C154($refWindow)
		Use (This:C1470)
			This:C1470.window:=0
		End use 
	End if 
	
	
	//MARK: add action to tracker list 
Function mark($message : Text)
	If (This:C1470.window#0)
		
		$chain:=Call chain:C1662
		$form:=New object:C1471
		$form.code:=$chain[1].type+" "+$chain[1].name
		$form.line:=$chain[1].line
		$form.callChain:=Call chain:C1662
		$formula:=This:C1470._update
		CALL FORM:C1391(This:C1470.window; $formula; $message; $form)
		
	End if 
	
	
Function internal($message : Text)
	If (This:C1470.window#0)
		
		$chain:=Call chain:C1662
		$form:=New object:C1471
		$form.code:=$chain[1].type+" "+$chain[1].name
		$form.line:=$chain[1].line
		$form.callChain:=Call chain:C1662
		$form.internal:=True:C214
		$formula:=This:C1470._update
		CALL FORM:C1391(This:C1470.window; $formula; $message; $form)
		
	End if 
	
Function _update($message : Text; $form : Object)
	
	$newEvent:=New object:C1471
	$newEvent.time:=Current time:C178
	$newEvent.message:=$message
	$newEvent.from:=$form
	Form:C1466.lb_events.push($newEvent)
	
Function internalColor($obj : Object)->$result : Object
	
	$color:=New object:C1471()
	If ($obj.from.internal#Null:C1517)
		If ($obj.from.internal)
			// red for internal calls
			$color.odd:="#f5d9d7"  // clear
			$color.even:="#f0bdbd"  // dark
		End if 
	Else 
		// for mark calls
		$color.odd:="white"  // clear
		$color.even:="#f0eded"  // dark
	End if 
	
	Use (This:C1470)
		This:C1470.displayLineNb+=1
	End use 
	If ((This:C1470.displayLineNb%2)=0)
		$result:=New object:C1471("fill"; $color.even)
	Else 
		$result:=New object:C1471("fill"; $color.odd)
	End if 