property SMTP_object : Object

singleton Class constructor
	
	//This.serverSMTP:=cs.sfw_definition.me.globalParameters.serverSMTP
	//This.serverSMTP.logFile:="LogMail.txt"  //Extended log to save in the Logs folder
	This:C1470.SMTP_object:=cs:C1710.sfw_microsoftGraphAPI.new()  //SMTP New transporter(This.serverSMTP)
	
	//This.launch()
	
	
Function launch()
	
	ds:C1482.sfw_fireAndForgetFormula(Formula:C1597(cs:C1710.sfw_eMailManager.me.worker()); "sfw_eMail_manager")
	
	
Function worker()
	var $uuids : Collection
	var $uuid : Text
	
	$uuids:=ds:C1482.sfw_EMailQueue.all().orderBy("stmpEntranceInQueue").extract("UUID")
	For each ($uuid; $uuids)
		This:C1470._sendItemInQueue($uuid)
	End for each 
	
Function initEmailObject()->$email : Object
	
	$email:=New object:C1471
	
	// To
	$addressTo:=New object:C1471
	$addressTo.emailAddress:=New object:C1471
	$addressTo.emailAddress.address:="recipient@4d.com"
	$email.toRecipients:=New collection:C1472($addressTo)
	$email.subject:="subject"
	
	$email.body:=New object:C1471()
	$email.body.content:="body"
	$email.body.contentType:="text"  // or HTML, 
	
Function _sendItemInQueue($uuid : Text)
	var $eEMailQueue : cs:C1710.sfw_EMailQueueEntity
	var $eMailLog : cs:C1710.sfw_EMailLogEntity
	
	$eEMailQueue:=ds:C1482.sfw_EMailQueue.get($uuid)
	
	$status:=This:C1470.SMTP_object.sendMail($eEMailQueue.mailData)
	If (Not:C34($status.success))
		//ALERT("An error occurred sending the mail: "+$status.message)
	End if 
	$eMailLog:=ds:C1482.sfw_EMailLog.new()
	$eMailLog.stmpExpedition:=cs:C1710.sfw_stmp.me.now()
	$eMailLog.mailData:=$eEMailQueue.mailData
	$eMailLog.extraData:=$eEMailQueue.extraData
	$eMailLog.user:=$extraData.user.name
	$eMailLog.UUID_User:=$extraData.user.UUID_User
	$eMailLog.sendMailStatus:=$status
	$info:=$eMailLog.save()
	$info:=$eEMailQueue.drop()
	
Function sendAnEMail($mailData : Object; $extraData : Object)
	var $eEMailQueue : cs:C1710.sfw_EMailQueueEntity
	
	If ($extraData=Null:C1517)
		$extraData:=New object:C1471
	End if 
	If ($extraData.user=Null:C1517)
		$extraData.user:=New object:C1471
		$extraData.user.UUID_User:=cs:C1710.sfw_userManager.me.info.UUID
		$extraData.user.name:=Current user:C182
	End if 
	
	$eEMailQueue:=ds:C1482.sfw_EMailQueue.new()
	$eEMailQueue.UUID:=Generate UUID:C1066
	$eEMailQueue.stmpEntranceInQueue:=cs:C1710.sfw_stmp.me.now()
	$eEMailQueue.mailData:=$mailData
	$eEMailQueue.extraData:=$extraData || New object:C1471
	$info:=$eEMailQueue.save()
	
	This:C1470.launch()
	
	
	