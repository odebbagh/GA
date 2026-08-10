Case of 
	: (Form event code:C388=On Clicked:K2:4)
		var $form : Object
		var $steps : 4D:C1709.EntitySelection
		var $winRef : Integer
		
		If (Form:C1466.stepProcessUUID=Null:C1517)
			cs:C1710.sfw_dialog.me.alert("Please select a step process first.")
			return 
		End if 
		
		OBJECT GET COORDINATES:C663(*; "pup_step"; $l; $t; $r; $b)
		CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
		
		$steps:=ds:C1482.Step.query("UUID_StepProcess = :1"; Form:C1466.stepProcessUUID).orderBy("description")
		
		If ($steps.length=0)
			cs:C1710.sfw_dialog.me.alert("No steps found for the selected process.")
			return 
		End if 
		
		$form:=New object:C1471(\
			"colName"; "description"; \
			"allData"; $steps; \
			"dataclass"; "Step"\
			)
		
		$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b+1)
		DIALOG:C40("selectNto1"; $form)
		CLOSE WINDOW:C154($winRef)
		
		If ((ok=1) & ($form.item#Null:C1517))
			Form:C1466.selectedStep:=$form.item
			Form:C1466.stepDisplay:=$form.item.description
		End if 
End case 
