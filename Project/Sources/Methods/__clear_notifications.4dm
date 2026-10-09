//%attributes = {"executedOnServer":true}

// Purpose: Empty notification tables and reset send-once flags for a clean QA/Facilities test. Run manually on the server. Do not call from startup.
// created by 4D/PS [2026-october-09]
// modified by 4D/PS [2026-october-09]
var $entity : 4D:C1709.Entity
var $keys : Collection
var $key : Text
var $dirty : Boolean
var $milestone : Text
var $droppedNotifications : Integer
var $droppedTypes : Integer

$droppedNotifications:=0
$droppedTypes:=0

If (ds:C1482["sfw_Notification"]#Null:C1517)
	$droppedNotifications:=ds:C1482.sfw_Notification.all().length
	ds:C1482.sfw_Notification.all().drop()
End if 
If (ds:C1482["sfw_NotificationType"]#Null:C1517)
	$droppedTypes:=ds:C1482.sfw_NotificationType.all().length
	ds:C1482.sfw_NotificationType.all().drop()
End if 

If (ds:C1482["Equipment"]#Null:C1517)
	$keys:=New collection:C1472("soonDueCal"; "dueCal"; "soonDuePM"; "duePM")
	For each ($entity; ds:C1482.Equipment.all())
		$dirty:=False:C215
		If ($entity.moreData#Null:C1517)
			For each ($key; $keys)
				If (Bool:C1537($entity.moreData[$key]))
					$entity.moreData[$key]:=False:C215
					$dirty:=True:C214
				End if 
			End for each 
			If ($dirty)
				$entity.save()
			End if 
		End if 
	End for each 
End if 

If (ds:C1482["Supplier"]#Null:C1517)
	For each ($entity; ds:C1482.Supplier.all())
		If ($entity.moreData#Null:C1517) && (Bool:C1537($entity.moreData.criticalOverdueAudit))
			$entity.moreData.criticalOverdueAudit:=False:C215
			$entity.save()
		End if 
	End for each 
End if 

If (ds:C1482["Specification"]#Null:C1517)
	For each ($entity; ds:C1482.Specification.all())
		$dirty:=False:C215
		If ($entity.moreData#Null:C1517)
			If (Bool:C1537($entity.moreData.dueReview))
				$entity.moreData.dueReview:=False:C215
				$dirty:=True:C214
			End if 
			If (Bool:C1537($entity.moreData.dueApproval))
				$entity.moreData.dueApproval:=False:C215
				$dirty:=True:C214
			End if 
			If ($dirty)
				$entity.save()
			End if 
		End if 
	End for each 
End if 

If (ds:C1482["CertificationAssignment"]#Null:C1517)
	For each ($entity; ds:C1482.CertificationAssignment.all())
		$dirty:=False:C215
		If ($entity.moreData#Null:C1517)
			If (OB Is defined:C1231($entity.moreData; "validityExpiryNotified")) && (Bool:C1537($entity.moreData.validityExpiryNotified))
				$entity.moreData.validityExpiryNotified:=False:C215
				$dirty:=True:C214
			End if 
			If (OB Is defined:C1231($entity.moreData; "retrainNotifiedMilestones"))
				For each ($milestone; OB Keys:C1719($entity.moreData.retrainNotifiedMilestones))
					If (Bool:C1537($entity.moreData.retrainNotifiedMilestones[$milestone]))
						$entity.moreData.retrainNotifiedMilestones[$milestone]:=False:C215
						$dirty:=True:C214
					End if 
				End for each 
			End if 
			If ($dirty)
				$entity.save()
			End if 
		End if 
	End for each 
End if 

ALERT:C41("Notifications cleared for tests.\r\r"+\
	"Rows dropped: "+String:C10($droppedNotifications)+"\r"+\
	"Types dropped: "+String:C10($droppedTypes)+"\r\r"+\
	"Restart 4D so notifications rebuild from current data.")
