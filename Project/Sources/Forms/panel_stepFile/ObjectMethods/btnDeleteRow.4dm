Case of 
	: (FORM Event:C1606.code=On Clicked:K2:4)
		If (Not:C34(Form:C1466.sfw.checkIsInModification())) || (Form:C1466.step=Null:C1517)
			return 
		End if 
		cs:C1710.panel_stepFile.me.ensureStepsDefinition()
		Form:C1466.current_item.stepsDefinition.items.remove(Form:C1466.stepPos)
		var $i : Integer
		var $step : Object
		$i:=1
		For each ($step; Form:C1466.current_item.stepsDefinition.items)
			$step.order:=$i
			$i+=1
		End for each 
		cs:C1710.panel_stepFile.me.loadSelectedSteps()
		cs:C1710.panel_stepFile.me.redrawAndSetVisible()
		
	: (FORM Event:C1606.code=On Mouse Enter:K2:33)
		SET CURSOR:C469(Choose:C955(OBJECT Get enabled:C1079(Self:C308->); 9000; 9019))
		
	: (FORM Event:C1606.code=On Mouse Leave:K2:34)
		SET CURSOR:C469()
End case 
