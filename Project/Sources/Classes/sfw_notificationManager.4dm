property notificationWorkerName : Text
property currentToolbarWindowRef : Integer
property currentWizardWindowRef : Integer

singleton Class constructor
	
	This:C1470.currentToolbarWindowRef:=0
	This:C1470.currentWizardWindowRef:=0
	This:C1470.notificationWorkerName:="NotificationWorker"
	
	If (cs:C1710.sfw_definition.me.globalParameters.notifications.activate)
		
		$definition:=cs:C1710.sfw_definitionNotificationType.new()
		$definition.setDescription("The record ##recordName## of the dataclass ##dataclassName## is updated.")
		$definition.setActive()
		This:C1470.createTypeIfNotExist("sfw_updateRecord"; "Update of the record"; $definition)
		
	End if 
	
	
Function openWizardNotifications()
	
	If (This:C1470.currentWizardWindowRef=0)
		$dialogName:="sfw_wizard_notification"
		$windowType:=Plain form window:K39:10
		This:C1470.currentWizardWindowRef:=cs:C1710.sfw_window.me.openFormWindow($dialogName; $windowType)
		DIALOG:C40($dialogName)
		cs:C1710.sfw_window.me.closeWindow(This:C1470.currentWizardWindowRef)
		This:C1470.currentWizardWindowRef:=0
	End if 
	
Function formMethod()
	
	Case of 
		: (FORM Event:C1606.code=On Load:K2:1)
			Form:C1466.sfw:=cs:C1710.sfw_foundations.new()
			This:C1470.loadNotifications()
			Form:C1466.current_notification:=Null:C1517
	End case 
	Case of 
		: (Form:C1466.current_notification=Null:C1517)
			FORM GOTO PAGE:C247(1)
			
		: (Form:C1466.current_notification#Null:C1517)
			FORM GOTO PAGE:C247(2)
			OBJECT SET VISIBLE:C603(*; "bValidateNotification"; (Num:C11(Form:C1466.current_notification.stmpOver)=0))
			
	End case 
	$nb:=Form:C1466.lb_notifications.query("stmpOver=0 or stmpOver=null").length
	Form:C1466.summary:=String:C10(Form:C1466.lb_notifications.length)+" notifications ; "+String:C10($nb)+" not validated"
	
Function loadNotifications()
	
	Form:C1466.lb_notifications:=ds:C1482.sfw_Notification.query("UUID_User = :1 and stmpOver = :2 order by stmp desc"; cs:C1710.sfw_userManager.me.info.UUID; 0)
	
	
Function refreshNotification()
	This:C1470.loadNotifications()
	$index:=Form:C1466.current_notification.indexOf()
	If ($index>=0)
		LISTBOX SELECT ROW:C912(*; "lb_notifications"; $index+2; lk replace selection:K53:1)
	Else 
		Form:C1466.current_notification:=Null:C1517
	End if 
	
Function bOpenRelatedRecord()
	$entity:=4D:C1709.Entity
	
	$entry:=cs:C1710.sfw_definition.me.entries.query("ident = :1"; Form:C1466.current_notification.moreData.targetDataclass).first()
	$visionIdent:=$entry.visions[0]
	
	$entity:=ds:C1482[$entry.dataclass].get(Form:C1466.current_notification.UUID_target)
	If ($entity=Null:C1517)
		$notifications:=ds:C1482.sfw_Notification.query("UUID_target =:1"; Form:C1466.current_notification.UUID_target)
		$info:=$notifications.drop()
		cs:C1710.sfw_notificationManager.me.updateNodifications()
	Else 
		Form:C1466.sfw.openInANewWindow($entity; $visionIdent; $entry.ident)
	End if 
	
	
Function bValidateNotification()
	
	Form:C1466.current_notification.stmpOver:=cs:C1710.sfw_stmp.me.now()
	$info:=Form:C1466.current_notification.save()
	This:C1470.updateNodifications()
	
	
Function getNbNotifications()->$nbT : Text
	var $esNotification : cs:C1710.sfw_NotificationSelection
	
	$esNotification:=ds:C1482.sfw_Notification.query("UUID_User = :1 and (stmpOver=0 or stmpOver=null)"; cs:C1710.sfw_userManager.me.info.UUID)
	$nb:=$esNotification.length
	If ($nb>99)
		$nbT:="99+"
	Else 
		$nbT:=String:C10($nb)
	End if 
	
Function notify($ident : Text; $users : Collection; $context : Object)
	ds:C1482.sfw_fireAndForgetFormula(Formula:C1597(cs:C1710.sfw_notificationManager.me._notify($1; $2; $3)); "NotificationWorker"; $ident; $users; $context)
	
	
Function _notify($ident : Text; $users : Collection; $context : Object)
	var $eNotificationType : cs:C1710.sfw_NotificationTypeEntity
	var $eNotification : cs:C1710.sfw_NotificationEntity
	
	If ($context.targetDataclass#Null:C1517)
		$esSubscriptions:=ds:C1482.sfw_Subscription.query("UUID_target = :1 and entryIdent = :2"; $context.target; $context.targetDataclass)
		If ($esSubscriptions.length>0)
			$users:=$users.concat($esSubscriptions.distinct("UUID_User")).distinct()
		End if 
	End if 
	
	$eNotificationType:=ds:C1482.sfw_NotificationType.query("ident = :1"; $ident).first()
	//$staff:=ds.Staff.query("UUID_User = :1"; cs.sfw_userManager.me.info.UUID).first()
	If ($eNotificationType#Null:C1517)
		For each ($user; $users)
			
			//If ($user#$staff.user.UUID)
			$eNotification:=ds:C1482.sfw_Notification.new()
			$eNotification.UUID:=Generate UUID:C1066
			$eNotification.UUID_NotificationType:=$eNotificationType.UUID
			$eNotification.UUID_User:=$user
			$eNotification.UUID_target:=$context.target || ("0"*32)
			$eNotification.stmp:=cs:C1710.sfw_stmp.me.now()
			$eNotification.ID_level:=$context.level || 1
			$eNotification.moreData:=New object:C1471
			If ($context.targetDataclass#Null:C1517)
				$eNotification.moreData.targetDataclass:=$context.targetDataclass
			End if 
			$eNotification.comment:=$eNotificationType.description
			For each ($attribute; $context)
				If (Position:C15("##"+$attribute+"##"; $eNotification.comment)>0)
					$eNotification.comment:=Replace string:C233($eNotification.comment; "##"+$attribute+"##"; String:C10($context[$attribute]))
				End if 
			End for each 
			$info:=$eNotification.save()
			If ($info.success)
				If (Application type:C494=4D Server:K5:6)
					EXECUTE ON CLIENT:C651("@"; "sfw_notificationUpdate")
				Else 
					sfw_notificationUpdate
				End if 
			End if 
			
			//End if 
		End for each 
	End if 
	
Function onStartup()
	
	If (Application type:C494#4D Remote mode:K5:5)
		
		
	End if 
	
	
Function setToolbarWindowRef($windowRef : Integer)
	
	This:C1470.currentToolbarWindowRef:=$windowRef
	
	
Function createTypeIfNotExist($ident : Text; $label : Text; $definition : cs:C1710.sfw_definitionNotificationType)
	
	var $eNotificationType : cs:C1710.sfw_NotificationTypeEntity
	
	$eNotificationType:=ds:C1482.sfw_NotificationType.query("ident = :1"; $ident).first()
	If ($eNotificationType=Null:C1517)
		$eNotificationType:=ds:C1482.sfw_NotificationType.new()
		$eNotificationType.ident:=$ident
		$eNotificationType.label:=$label
		$eNotificationType.description:=String:C10($definition.description)
		$eNotificationType.active:=Bool:C1537($definition.active)
		$info:=$eNotificationType.save()
		
	End if 
	
Function updateNodifications()
	If (Bool:C1537(cs:C1710.sfw_definition.me.globalParameters.notifications.activate))
		If (This:C1470.currentToolbarWindowRef=0)
			This:C1470.currentToolbarWindowRef:=cs:C1710.sfw_window.me.toolbarWindowRef
		End if 
		If (This:C1470.currentToolbarWindowRef#0)
			CALL FORM:C1391(This:C1470.currentToolbarWindowRef; Formula:C1597(Form:C1466.sfw.displayNotification()))
		End if 
		
		$window:=cs:C1710.sfw_window.me.windows.query("process.name = :1"; cs:C1710.sfw_notificationManager.me.notificationWorkerName).first()
		If ($window#Null:C1517)
			CALL FORM:C1391($window.reference; Formula:C1597(cs:C1710.sfw_notificationManager.me.refreshNotification()))
		End if 
		
		
	End if 