var $lotEntity : cs:C1710.LotEntity
var $lastCompletedStep : Integer

Case of 
	: (FORM Event:C1606.code=On Load:K2:1)
		Form:C1466.lastCompletedStep:=0
		Form:C1466.splitLotCount:=0
		Form:C1466.child_lots:=New collection:C1472()
		Form:C1466.splitStepWithBins:=False:C215
		
		Form:C1466.lastCompletedStep:=Form:C1466.lot.getLastCompletedStep()
		Form:C1466.splitStep:=Form:C1466.lot.lotSteps.query("order = :1"; Form:C1466.lastCompletedStep)[0]
		If (Form:C1466.splitStep.bins#Null:C1517) && (Form:C1466.splitStep.bins.query("items # 0").length>0)
			Form:C1466.splitStepWithBins:=True:C214
		End if 
End case 