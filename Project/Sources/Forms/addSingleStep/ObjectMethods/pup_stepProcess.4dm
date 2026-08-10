Case of 
	: (Form event code:C388=On Clicked:K2:4)
		var $form : Object
		var $processes : 4D:C1709.EntitySelection
		var $winRef : Integer
		
		OBJECT GET COORDINATES:C663(*; "pup_stepProcess"; $l; $t; $r; $b)
		CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
		
		$processes:=ds:C1482.StepProcess.all().orderBy("name")
		
		$form:=New object:C1471(\
			"colName"; "name"; \
			"allData"; $processes; \
			"dataclass"; "StepProcess"\
			)
		
		$winRef:=Open form window:C675("select1toN"; Pop up form window:K39:11; $l; $b+1)
		DIALOG:C40("select1toN"; $form)
		CLOSE WINDOW:C154($winRef)
		
		If ((ok=1) & ($form.item#Null:C1517))
			Form:C1466.stepProcessUUID:=$form.item.UUID
			Form:C1466.processDisplay:=$form.item.name
			Form:C1466.selectedStep:=Null:C1517
			Form:C1466.stepDisplay:=""
			OBJECT SET ENABLED:C1123(*; "pup_step"; True:C214)
		End if 
End case 
