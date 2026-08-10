Class constructor
	This:C1470.settings:=This:C1470._getSettings()
	
	
Function sendMail($email : Object)->$status : Object
	
	If (This:C1470.oAuth2=Null:C1517)
		This:C1470.getToken()
	End if 
	var $Office365 : cs:C1710.NetKit.Office365
	$Office365:=cs:C1710.NetKit.Office365.new(This:C1470.oAuth2; New object:C1471("mailType"; "Microsoft"))
	$Office365.mail.userId:=This:C1470.settings.userId
	
	// Envoi
	If ($email.from=Null:C1517)
		$email.from:=New object:C1471
		$email.from.emailAddress:=New object:C1471("address"; This:C1470.settings.sender)
	End if 
	$status:=$Office365.mail.send($email)
	
	
Function _getSettings()->$data : Object
	//$data:=cs.sfw_definition.me.globalParameters.microsoftGraphAPI
	//$data.sender:=cs.sfw_definition.me.globalParameters.mail.sender
	
Function getToken()->$token : Object
	var $eSetting : cs:C1710.sfw_SettingEntity
	var $param : Object
	var $ident : Text
	
	$param:=New object:C1471()
	$param.name:="Microsoft"
	$param.permission:="service"
	$ident:="microsoftGraphAPI_token"
	$param.clientId:=This:C1470.settings.clientId
	$param.clientSecret:=This:C1470.settings.clientSecret
	$param.tenant:=This:C1470.settings.tenant
	$param.scope:=This:C1470.settings.scope
	$OAuth2:=New OAuth2 provider($param)
	$token:=$OAuth2.getToken()
	This:C1470.token:=$token
	This:C1470.oAuth2:=$OAuth2