// ga_mail
// Sends email through Microsoft 365 (Microsoft Graph, with the 4D NetKit component), as the user
// who signs in: the first time, the browser opens the Microsoft sign-in and asks to allow the app
// to send mail; the token is then kept in the data folder and refreshed without asking again.
// Proof of concept for sending quotes by email (sales demo of 2026-10-13).
// The sfw mail classes are not used: sfw_eMailManager._sendItemInQueue reads an $extraData it never
// sets, and sfw_microsoftGraphAPI only has the "service" mode, which needs an app secret.
//
// Settings: Project/Data/mail_settings.json (the Data folder is not in git)
//   clientId, tenant: the app registration in Microsoft Entra ID
//   redirectURI: as declared on the registration ("Mobile and desktop applications" platform)
//   scope: the delegated Graph permissions, "offline_access Mail.Send Mail.ReadWrite"
//   sender: the mailbox that signs in
//   redirectAllTo: when set, every mail goes to this address instead of its recipients (tests:
//   the imported contacts have real customer addresses)
// Token: Project/Data/mail_token.json. signOut() deletes it, to sign in again.

property settings : Object
property _oAuth2 : Object

singleton Class constructor
	This.settings:=Null
	This._oAuth2:=Null


	//Mark:-Settings
Function dataFile($name : Text)->$file : 4D.File
	$file:=Folder(Folder(fk data folder).platformPath; fk platform path).file($name)

	// the settings, read once. Null, with an alert, when the file is missing or incomplete
Function loadSettings()->$settings : Object
	var $file : 4D.File

	If (This.settings=Null)
		$file:=This.dataFile("mail_settings.json")
		If (Not($file.exists))
			cs.sfw_dialog.me.alert("Email is not set up: "+$file.platformPath+" is missing.")
			return Null
		End if
		$settings:=Try(JSON Parse($file.getText()))
		Case of
			: ($settings=Null) || (Value type($settings)#Is object)
				cs.sfw_dialog.me.alert("Email settings: "+$file.platformPath+" is not valid JSON.")
				return Null
			: (String($settings.clientId)="") || (String($settings.tenant)="") || (String($settings.sender)="")
				cs.sfw_dialog.me.alert("Email settings: clientId, tenant and sender are required in "+$file.platformPath+".")
				return Null
		End case
		This.settings:=$settings
	End if
	$settings:=This.settings


	//Mark:-Sign-in
	// the OAuth2 provider with a valid token: the stored one (refreshed by NetKit when it has
	// expired), otherwise the browser sign-in, which this waits for (2 minutes at most).
	// Null, with an alert, when the sign-in fails
Function provider()->$oAuth2 : Object
	var $param; $token : Object
	var $file : 4D.File

	If (This.loadSettings()=Null)
		return Null
	End if

	$file:=This.dataFile("mail_token.json")
	If (This._oAuth2=Null)
		$param:=New object
		$param.name:="Microsoft"
		$param.permission:="signedIn"
		$param.clientId:=This.settings.clientId
		$param.tenant:=This.settings.tenant
		$param.redirectURI:=This.settings.redirectURI || "http://127.0.0.1:50993/authorize/"
		$param.scope:=This.settings.scope || "offline_access Mail.Send Mail.ReadWrite"
		$param.loginHint:=This.settings.sender
		If ($file.exists)
			$token:=Try(JSON Parse($file.getText()))
			If ($token#Null) && (Value type($token)=Is object)
				$param.token:=$token
			End if
		End if
		This._oAuth2:=cs.NetKit.OAuth2Provider.new($param)
	End if

	$token:=Try(This._oAuth2.getToken())
	If ($token=Null)
		This._oAuth2:=Null
		cs.sfw_dialog.me.alert("The Microsoft 365 sign-in failed: "+This._lastError())
		return Null
	End if
	$file.setText(JSON Stringify($token))
	$oAuth2:=This._oAuth2

	// forgets the token: the next send opens the sign-in again (another account, new permissions)
Function signOut()
	var $file : 4D.File

	$file:=This.dataFile("mail_token.json")
	If ($file.exists)
		$file.delete()
	End if
	This._oAuth2:=Null


	//Mark:-Mails (Microsoft Graph message objects)
	// $to, $cc: collections of addresses (Text); the body is HTML
Function newMail($to : Collection; $subject : Text; $htmlBody : Text; $cc : Collection)->$mail : Object
	$mail:=New object
	$mail.subject:=$subject
	$mail.body:=New object("contentType"; "html"; "content"; $htmlBody)
	$mail.toRecipients:=This._recipients($to)
	$mail.ccRecipients:=This._recipients($cc)
	$mail.attachments:=New collection

Function attachFile($mail : Object; $file : 4D.File)
	var $blob : Blob
	var $base64 : Text

	$blob:=$file.getContent()
	BASE64 ENCODE($blob; $base64)
	$mail.attachments.push(New object("@odata.type"; "#microsoft.graph.fileAttachment"; "name"; $file.fullName; "contentType"; This._contentType($file.extension); "contentBytes"; $base64))

	// sends $mail as the signed-in user, and logs it (sfw_EMailLog). $context: plain values kept
	// in the log (e.g. the quote code), no entities. Returns the NetKit status {success; statusText; errors}
Function send($mail : Object; $context : Object)->$status : Object
	var $oAuth2; $office365 : Object

	$oAuth2:=This.provider()
	If ($oAuth2=Null)
		return New object("success"; False; "statusText"; "Not signed in to Microsoft 365.")
	End if

	This._applyRedirect($mail)
	$office365:=cs.NetKit.Office365.new($oAuth2; New object("mailType"; "Microsoft"))
	$status:=Try($office365.mail.send($mail))
	If ($status=Null)
		$status:=New object("success"; False; "statusText"; This._lastError())
	End if
	This._log($mail; $context; $status)


	//Mark:-Private
Function _recipients($addresses : Collection)->$recipients : Collection
	var $address : Text

	$recipients:=New collection
	If ($addresses#Null)
		For each ($address; $addresses)
			If ($address#"")
				$recipients.push(New object("emailAddress"; New object("address"; $address)))
			End if
		End for each
	End if

	// tests: every recipient replaced by settings.redirectAllTo, the original ones written at the top
Function _applyRedirect($mail : Object)
	var $redirect; $original : Text

	$redirect:=String(This.settings.redirectAllTo)
	If ($redirect#"")
		$original:=""
		If ($mail.toRecipients#Null)
			$original:=$mail.toRecipients.extract("emailAddress.address").join(", ")
		End if
		If ($mail.ccRecipients#Null) && ($mail.ccRecipients.length>0)
			$original:=$original+" / Cc: "+$mail.ccRecipients.extract("emailAddress.address").join(", ")
		End if
		$mail.body.content:="<p style=\"color:#888888\">[Test - would have gone to: "+$original+"]</p>"+$mail.body.content
		$mail.toRecipients:=This._recipients(New collection($redirect))
		$mail.ccRecipients:=New collection
		$mail.bccRecipients:=New collection
	End if

Function _contentType($extension : Text)->$type : Text
	Case of
		: ($extension=".pdf")
			$type:="application/pdf"
		: ($extension=".txt")
			$type:="text/plain"
		: ($extension=".htm") || ($extension=".html")
			$type:="text/html"
		: ($extension=".png")
			$type:="image/png"
		: ($extension=".jpg") || ($extension=".jpeg")
			$type:="image/jpeg"
		Else
			$type:="application/octet-stream"
	End case

	// the log line, without the attachments' contents
Function _log($mail : Object; $context : Object; $status : Object)
	var $log : 4D.Entity
	var $data; $attachment; $info : Object

	$data:=OB Copy($mail)
	$data.attachments:=New collection
	If ($mail.attachments#Null)
		For each ($attachment; $mail.attachments)
			$data.attachments.push(New object("name"; $attachment.name; "contentType"; $attachment.contentType))
		End for each
	End if

	$log:=ds.sfw_EMailLog.new()
	$log.stmpExpedition:=cs.sfw_stmp.me.now()
	$log.mailData:=$data
	$log.extraData:=New object("context"; $context; "sender"; This.settings.sender; "user"; cs.sfw_userManager.me.info.name)
	$log.UUID_User:=cs.sfw_userManager.me.info.UUID || ("0"*32)
	$log.sendMailStatus:=$status
	$info:=$log.save()

Function _lastError()->$text : Text
	var $errors : Collection

	$errors:=Last errors
	If ($errors#Null) && ($errors.length>0)
		$text:=$errors.extract("message").join(" / ")
	Else
		$text:="unknown error"
	End if
