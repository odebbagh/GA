//%attributes = {}
[BuyingOrder:46]
$es:=ds:C1482.Contact.query("firstName = :1"; "FUAD BARAKAT")

TRACE:C157

//OBJECT GET BEST SIZE(*; "desc 1\n\r\n\romar debbagh"; $l; $h; $lm)

$col:=Split string:C1554("desc 1\n\r\n\romar debbagh"; "\n")

TRACE:C157

TRUNCATE TABLE:C1051([dfd_Line:24])
TRUNCATE TABLE:C1051([dfd_Template:14])
TRUNCATE TABLE:C1051([dfd_Picture:23])
TRUNCATE TABLE:C1051([dfd_Document:22])

TRACE:C157

_ga_fillBarcodeDataField("Lot")

TRACE:C157

$users:=ds:C1482.Staff.query("firstName = 'Rexie'")

TRACE:C157

$lotSteps:=ds:C1482.Lot.query("number = 29003").lotSteps

TRACE:C157

$lotSteps:=ds:C1482.Lot.query("number = 29001").lotSteps
$stepProperties:=ds:C1482.StepProperty.all().extract("name"; "name"; "description"; "description"; "UUID"; "uuid")
For each ($prop; $stepProperties)
	$prop["enabled"]:=False:C215
End for each 

For each ($step; $lotSteps)
	If ($step.properties=Null:C1517)
		$step.properties:=New object:C1471()
		$step.properties["items"]:=$stepProperties
		$step.save()
	End if 
End for each 



TRACE:C157

$stepfiles:=ds:C1482.StepFile.all()

For each ($item; $stepfiles)
	If ($item.stepsDefinition#Null:C1517)
		For each ($step; $item.stepsDefinition.items)
			If ($step.UUID_Step=("0"*32))
				$step_:=ds:C1482.Step.query("description = :1"; $step.description)
				If ($step_.length=1)
					$step.UUID_Step:=$step_[0].UUID
					$item.save()
				Else 
					$step_:=ds:C1482.Step.query("description = :1"; Substring:C12($step.description; 1; 10)+"@")
					If ($step.length>0)
						$step.UUID_Step:=$step_[0].UUID
						$item.save()
					End if 
				End if 
			End if 
		End for each 
	End if 
End for each 

//$step:=ds.Step.query("description = :1"; "INCOMING DIE INSPECTION@")

$lotSteps:=ds:C1482.Lot.query("number = 29001").lotSteps

For each ($step; $lotSteps)
	//$step.step
	//[LotStep]specificationControl
End for each 

$var:=$myStep.extract("qtyOut"; "Qty"; "dateOut"; "Date")

$steps:=ds:C1482.LotStep.query("qtyOut = 0 and dateOut = :1"; !00-00-00!)


//$myStep.tools:=New object()
//$step:=ds.Step.query("description = 'GROSS LEAK Test@'").first()
//$myStep.UUID_Step:=$step[0].UUID
//$myStep.save()
