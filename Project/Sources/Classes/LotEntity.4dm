Class extends Entity

Function getCurrentStep()->$currentStepOrder : Integer
	//$currentstep_es:=This.steps.query("qtyIn = :1 AND qtyOut = :1 AND dateIn = :2 AND dateOut = :2"; 0; !00-00-00!).orderBy("order asc")
	
	//If ($currentstep_es.length>0)
	//$currentStepOrder:=$currentstep_es[0].order
	//End if 
	
local Function loadAfterCreation()
	
	Case of 
		: (Form:C1466.sfw.entry.ident="customerReceivedMaterial")
			$job:=ds:C1482.Job.new()
			$res:=$job.save()
			
			If ($res.success)
				This:C1470.UUID_Job:=$job.UUID
			End if 
			
			If (This:C1470.dateIn=!00-00-00!)
				This:C1470.dateIn:=Current date:C33
			End if 
			
			This:C1470.number:=Sequence number:C244([Lot:118])
			
		Else 
			// This callback is called after creating the new item but before displaying the panel.
			If (This:C1470.lotNumber="")
				This:C1470.lotNumber:=String:C10(String:C10(ds:C1482.Lot.all().extract("lotNumber").map(Formula:C1597(Num:C11($1.value))).filter(Formula:C1597((Num:C11($1.value)#1) && (Num:C11($1.value)#0))).max()+1); "0000000000#")  //
				
				//String(Num(ds.Lot.all().max("lotNumber")+1000); "00000#")
			End if 
			If (Form:C1466.sfw.entry.ident="receiver")
				$job:=ds:C1482.Job.new()
				
				$job.jobNumber:=ds:C1482.Job.all().max("jobNumber")+1
				
				$res:=$job.save()
				
				If ($res.success)
					This:C1470.UUID_Job:=$job.UUID
				End if 
			End if 
	End case 
	
local Function get nameInWindowTitle()->$nameInWindowTitle : Text
	// With this callback you return the name to displayed in the title of the window for the current item
	$nameInWindowTitle:=String:C10(This:C1470.number)
	
Function getLastCompletedStep()->$lastCompletedStepOrder : Integer
	
	If (This:C1470.lotSteps#Null:C1517) && (This:C1470.lotSteps.length>0)
		$completedSteps:=This:C1470.lotSteps.query("dateOut # :1"; !00-00-00!).orderBy("order desc")
		If ($completedSteps.length>0)
			$lastCompletedStepOrder:=$completedSteps[0].order
		End if 
	End if 