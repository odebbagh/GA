//%attributes = {"executedOnServer":true}

var $eCip : cs:C1710.ContinuousImprovementEntity


$cip_log:=Folder:C1567(fk data folder:K87:12).file("DataJson/continuousImprovement.json")

If ($cip_log.exists)
	$cips:=JSON Parse:C1218($cip_log.getText())
	
	TRUNCATE TABLE:C1051([ContinuousImprovement:25])
	
	For each ($cip; $cips)
		
		$eCip:=ds:C1482.ContinuousImprovement.new()
		
		$eCip.item:=$cip.item
		$eCip.interestedParty:=Split string:C1554($cip.interestedParty; "\n"; sk ignore empty strings:K86:1+sk trim spaces:K86:2).join(",")
		
		$priority:=ds:C1482.CIPriority.query("levelID =:1"; $cip.priority)
		If ($priority.length>0)
			$eCip.UUID_CIPriority:=$priority[0].UUID
		Else 
			$eCip.UUID_CIOrigin:=""
			
		End if 
		
		$eCip.stmpInitiated:=cs:C1710.sfw_stmp.me.build(Date:C102($cip.dateInitiated))
		
		$origin:=ds:C1482.CIOrigin.query("name =:1"; Split string:C1554($cip.origin; "\r"; sk trim spaces:K86:2).join("\r"))
		If ($origin.length>0)
			$eCip.UUID_CIOrigin:=$origin[0].UUID
		Else 
			$eCip.UUID_CIOrigin:=""
			
		End if 
		
		$eCip.procedureType:=$cip.procedureType
		$eCip.action:=$cip.action
		$eCip.requirement:=$cip.requirement
		
		$category:=ds:C1482.CICategory.query("name =:1"; Split string:C1554($cip.category; "\r"; sk trim spaces:K86:2).join("\r"))
		If ($category.length>0)
			$eCip.UUID_CICategory:=$category[0].UUID
		Else 
			
			If (Split string:C1554($cip.category; "\r"; sk trim spaces:K86:2).join("\r")="RMA-NonKPI'")
				$eCip.UUID_CICategory:=ds:C1482.CICategory.query("levelID =:1"; 12).first().UUID
				
			Else 
				$eCip.UUID_CICategory:=""
			End if 
		End if 
		
		$disposition:=ds:C1482.CIDisposition.query("name =:1"; Split string:C1554($cip.disposition; "\r"; sk trim spaces:K86:2).join("\r"))
		If ($disposition.length>0)
			$eCip.UUID_CIDisposition:=$disposition[0].UUID
			
		Else 
			Case of 
					
				: (Split string:C1554($cip.disposition; "\r"; sk trim spaces:K86:2).join("\r")="Not applicable (Not NCP)") | (Split string:C1554($cip.disposition; "\r"; sk trim spaces:K86:2).join("\r")="NA (Not NCP)")
					$eCip.UUID_CIDisposition:=ds:C1482.CIDisposition.query("levelID =:1"; 1).first().UUID
					
				: (Split string:C1554($cip.disposition; "\r"; sk trim spaces:K86:2).join("\r")="Us as is")
					$eCip.UUID_CIDisposition:=ds:C1482.CIDisposition.query("levelID =:1"; 6).first().UUID
					
				Else 
					
					$eCip.UUID_CIDisposition:=""
			End case 
			
		End if 
		
		$eCip.moreData:=New object:C1471()
		$eCip.moreData.disposition:=""
		
		$humanFactor:=ds:C1482.CIHumanFactor.query("name =:1"; Split string:C1554($cip.humanFactor; "\r"; sk trim spaces:K86:2).join("\r"))
		If ($humanFactor.length>0)
			$eCip.UUID_CIHumanFactor:=$humanFactor[0].UUID
		Else 
			$eCip.UUID_CIHumanFactor:=""
		End if 
		
		$eCip.responsible:=$cip.responsible
		$eCip.stmpOriginalDue:=cs:C1710.sfw_stmp.me.build(Date:C102($cip.originalDueDate))
		$eCip.stmpClosed:=cs:C1710.sfw_stmp.me.build(Date:C102($cip.dateClosed))
		
		$IsAcceptable:=ds:C1482.YesNoQuestion.query("name =:1"; Split string:C1554($cip.IsAcceptable; "\r"; sk trim spaces:K86:2).join("\r"))
		If ($IsAcceptable.length>0)
			$eCip.UUID_YesNoQuestion:=$IsAcceptable[0].UUID
		Else 
			$eCip.UUID_CIDisposition:=ds:C1482.YesNoQuestion.query("levelID =:1"; 3).first().UUID
		End if 
		
		$eCip.externalID:=$cip.externalID
		$eCip.stmpCurrentDue:=cs:C1710.sfw_stmp.me.build(Date:C102($cip.currentDueDate))
		$eCip.notes:=$cip.notes
		$eCip.title:=""
		
		
		$res:=$eCip.save()
		If (Not:C34($res.success))
			TRACE:C157
		End if 
		
		
	End for each 
	
	
End if 

