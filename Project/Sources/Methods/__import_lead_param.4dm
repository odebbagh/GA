//%attributes = {"executedOnServer":true}
var $eInteractionMethod : cs:C1710.InteractionMethodEntity
var $eInteractionOutcome : cs:C1710.InteractionOutcomeEntity
var $eInteractionTrigger : cs:C1710.InteractionTriggerEntity
var $eInteractionType : cs:C1710.InteractionTypeEntity
var $eLeadPriority : cs:C1710.LeadPriorityEntity
var $eLeadNextStep : cs:C1710.LeadNextStepEntity
var $eLeadStage : cs:C1710.LeadStageEntity
var $eServiceType : cs:C1710.ServiceTypeEntity


TRUNCATE TABLE:C1051([InteractionMethod:55])
If (True:C214)
	$file:=Folder:C1567(fk data folder:K87:12).file("DataJson/InteractionMethod_export.json")
	$records:=JSON Parse:C1218($file.getText())
	
	For each ($q; $records)
		$eInteractionMethod:=ds:C1482.InteractionMethod.new()
		$eInteractionMethod.code:=$q.code
		$eInteractionMethod.name:=$q.name
		$eInteractionMethod.levelID:=$q.levelID
		$eInteractionMethod.color:=$q.color
		
		$info:=$eInteractionMethod.save()
		If (Not:C34($info.success))
			TRACE:C157
		End if 
	End for each 
End if 



TRUNCATE TABLE:C1051([InteractionOutcome:54])
If (True:C214)
	$file:=Folder:C1567(fk data folder:K87:12).file("DataJson/InteractionOutcome_export.json")
	$records:=JSON Parse:C1218($file.getText())
	
	For each ($q; $records)
		$eInteractionOutcome:=ds:C1482.InteractionOutcome.new()
		$eInteractionOutcome.code:=$q.code
		$eInteractionOutcome.name:=$q.name
		$eInteractionOutcome.levelID:=$q.levelID
		$eInteractionOutcome.color:=$q.color
		
		$info:=$eInteractionOutcome.save()
		If (Not:C34($info.success))
			TRACE:C157
		End if 
	End for each 
End if 



TRUNCATE TABLE:C1051([InteractionTrigger:53])
If (True:C214)
	$file:=Folder:C1567(fk data folder:K87:12).file("DataJson/InteractionTrigger_export.json")
	$records:=JSON Parse:C1218($file.getText())
	
	For each ($q; $records)
		$eInteractionTrigger:=ds:C1482.InteractionTrigger.new()
		$eInteractionTrigger.code:=$q.code
		$eInteractionTrigger.name:=$q.name
		$eInteractionTrigger.levelID:=$q.levelID
		$eInteractionTrigger.color:=$q.color
		$eInteractionTrigger.moreData:=$q.moreData
		
		$info:=$eInteractionTrigger.save()
		If (Not:C34($info.success))
			TRACE:C157
		End if 
	End for each 
End if 



TRUNCATE TABLE:C1051([InteractionType:41])
If (True:C214)
	$file:=Folder:C1567(fk data folder:K87:12).file("DataJson/InteractionType_export.json")
	$records:=JSON Parse:C1218($file.getText())
	
	For each ($q; $records)
		$eInteractionType:=ds:C1482.InteractionType.new()
		$eInteractionType.code:=$q.code
		$eInteractionType.name:=$q.name
		$eInteractionType.levelID:=$q.levelID
		$eInteractionType.color:=$q.color
		
		$info:=$eInteractionType.save()
		If (Not:C34($info.success))
			TRACE:C157
		End if 
	End for each 
End if 



TRUNCATE TABLE:C1051([LeadPriority:38])
If (True:C214)
	$file:=Folder:C1567(fk data folder:K87:12).file("DataJson/LeadPriority_export.json")
	$records:=JSON Parse:C1218($file.getText())
	
	For each ($q; $records)
		$eLeadPriority:=ds:C1482.LeadPriority.new()
		$eLeadPriority.code:=$q.code
		$eLeadPriority.name:=$q.name
		$eLeadPriority.levelID:=$q.levelID
		$eLeadPriority.color:=$q.color
		
		$info:=$eLeadPriority.save()
		If (Not:C34($info.success))
			TRACE:C157
		End if 
	End for each 
End if 



TRUNCATE TABLE:C1051([LeadNextStep:40])
If (True:C214)
	$file:=Folder:C1567(fk data folder:K87:12).file("DataJson/LeadNextStep_export.json")
	$records:=JSON Parse:C1218($file.getText())
	
	For each ($q; $records)
		$eLeadNextStep:=ds:C1482.LeadNextStep.new()
		$eLeadNextStep.code:=$q.code
		$eLeadNextStep.name:=$q.name
		$eLeadNextStep.nextStepID:=$q.nextStepID
		$eLeadNextStep.color:=$q.color
		
		$info:=$eLeadNextStep.save()
		If (Not:C34($info.success))
			TRACE:C157
		End if 
	End for each 
End if 



TRUNCATE TABLE:C1051([LeadStage:39])
If (True:C214)
	$file:=Folder:C1567(fk data folder:K87:12).file("DataJson/LeadStage_export.json")
	$records:=JSON Parse:C1218($file.getText())
	
	For each ($q; $records)
		$eLeadStage:=ds:C1482.LeadStage.new()
		$eLeadStage.code:=$q.code
		$eLeadStage.name:=$q.name
		$eLeadStage.stageID:=$q.stageID
		$eLeadStage.color:=$q.color
		
		$info:=$eLeadStage.save()
		If (Not:C34($info.success))
			TRACE:C157
		End if 
	End for each 
End if 



TRUNCATE TABLE:C1051([ServiceType:36])
If (True:C214)
	$file:=Folder:C1567(fk data folder:K87:12).file("DataJson/ServiceType_export.json")
	$records:=JSON Parse:C1218($file.getText())
	
	For each ($q; $records)
		$eServiceType:=ds:C1482.ServiceType.new()
		$eServiceType.code:=$q.code
		$eServiceType.name:=$q.name
		$eServiceType.levelID:=$q.levelID
		$eServiceType.color:=$q.color
		
		$info:=$eServiceType.save()
		If (Not:C34($info.success))
			TRACE:C157
		End if 
	End for each 
End if 










