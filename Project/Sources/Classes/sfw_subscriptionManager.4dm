singleton Class constructor
	
	
	
	
Function clicOnHeader
	var $signal : 4D:C1709.Signal
	
	$signal:=New signal:C1641
	Use ($signal)
		$signal.UUID_target:=Form:C1466.current_item.UUID
		$signal.UUID_User:=cs:C1710.sfw_userManager.me.info.UUID
		$signal.entryIdent:=Form:C1466.sfw.entry.ident
	End use 
	CALL WORKER:C1389("sfw_subscription_worker"; Formula:C1597(cs:C1710.sfw_subscriptionManager.me._worker($1)); $signal)
	$signal.wait(100)
	If ($signal.signaled)
		This:C1470._displayHeaderTabSubscription()
	End if 
	
	
Function _worker($signal : 4D:C1709.Signal)
	var $eSubscription : cs:C1710.sfw_SubscriptionEntity
	If ($signal.UUID_User=("00"*16))
		$eSubscription:=ds:C1482.sfw_Subscription.query("UUID_target = :1 and entryIdent = :2"; $signal.UUID_target; $signal.entryIdent).first()
	Else 
		$eSubscription:=ds:C1482.sfw_Subscription.query("UUID_target = :1 and UUID_User = :2 and entryIdent = :3"; $signal.UUID_target; $signal.UUID_User; $signal.entryIdent).first()
	End if 
	If ($eSubscription=Null:C1517)
		$eSubscription:=ds:C1482.sfw_Subscription.new()
		$eSubscription.UUID:=Generate UUID:C1066
		$eSubscription.UUID_target:=$signal.UUID_target
		$eSubscription.UUID_User:=$signal.UUID_User
		$eSubscription.entryIdent:=$signal.entryIdent
		$eSubscription.stmp:=cs:C1710.sfw_stmp.me.now()
		$info:=$eSubscription.save()
		
	Else 
		$info:=$eSubscription.drop()
	End if 
	
	$signal.trigger()
	
	
	
Function _displayHeaderTabSubscription()
	var $esSubscription : cs:C1710.sfw_SubscriptionSelection
	
	If (Form:C1466.current_item#Null:C1517) && (Bool:C1537(Form:C1466.sfw.entry.allowSubscription))
		If (cs:C1710.sfw_userManager.me.info.UUID=("00"*16))
			$esSubscription:=ds:C1482.sfw_Subscription.query("UUID_target = :1 and entryIdent = :2"; Form:C1466.current_item.UUID; Form:C1466.sfw.entry.ident)
		Else 
			$esSubscription:=ds:C1482.sfw_Subscription.query("UUID_target = :1 and UUID_User = :2 and entryIdent = :3"; Form:C1466.current_item.UUID; cs:C1710.sfw_userManager.me.info.UUID; Form:C1466.sfw.entry.ident)
		End if 
		$title:=($esSubscription.length=0) ? ds:C1482.sfw_readXliff("subscription.addSubscription"; "Subcribe to notifications") : ds:C1482.sfw_readXliff("subscription.isSubscription"; "Notification subscriber")
		OBJECT SET HELP TIP:C1181(*; "headerTabSubscription_button"; $title)
		$format:=($esSubscription.length=0) ? ";path:/RESOURCES/sfw/image/picto/bell-empty.png;;4;1;1;4;0;0;0;0;0;1;1" : ";path:/RESOURCES/sfw/image/picto/bell.png;;4;1;1;4;0;0;0;0;0;1;1"
		OBJECT SET FORMAT:C236(*; "headerTabSubscription_button"; $format)
		$subscriptionTabVisible:=(Form:C1466.current_item#Null:C1517) && (Bool:C1537(Form:C1466.sfw.entry.allowSubscription))
		OBJECT SET VISIBLE:C603(*; "headerTabSubscription@"; $subscriptionTabVisible)
	Else 
		OBJECT SET VISIBLE:C603(*; "headerTabSubscription@"; False:C215)
	End if 
	
	Form:C1466.sfw.arrangeHeaderTabs()
	
	
Function getUUIDs($entryIdent : Text)->$uuids : Collection
	
	If (Count parameters:C259=0)
		If (cs:C1710.sfw_userManager.me.info.UUID=("00"*16))
			$uuids:=ds:C1482.sfw_Subscription.all().UUID_target
		Else 
			$uuids:=ds:C1482.sfw_Subscription.query("UUID_User = :1"; cs:C1710.sfw_userManager.me.info.UUID).UUID_target
		End if 
	Else 
		If (cs:C1710.sfw_userManager.me.info.UUID=("00"*16))
			$uuids:=ds:C1482.sfw_Subscription.query("entryIdent = :1"; $entryIdent).UUID_target
		Else 
			$uuids:=ds:C1482.sfw_Subscription.query("UUID_User = :1 and entryIdent = :2"; cs:C1710.sfw_userManager.me.info.UUID; $entryIdent).UUID_target
		End if 
	End if 
	
	
Function getSubscriptions($entryIdent : Text)->$esSubscription : cs:C1710.sfw_SubscriptionSelection
	
	$UUIDs:=This:C1470.getUUIDs($entryIdent)
	$entry:=cs:C1710.sfw_definition.me.getEntryByIdent($entryIdent)
	$esSubscription:=ds:C1482[$entry.dataclass].query("UUID in :1"; $UUIDs)
	
	