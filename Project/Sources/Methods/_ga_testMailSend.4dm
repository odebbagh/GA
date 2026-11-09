//%attributes = {}
// _ga_testMailSend
// Sends one test email through ga_mail (Microsoft 365) to the sender of
// Project/Data/mail_settings.json, with a small text file attached. Run it from the IDE.
// The first run opens the browser on the Microsoft sign-in: sign in with the sender's account and
// accept the permissions (4D waits 2 minutes at most). The next runs reuse the stored token.
// To sign in again (another account, permissions changed): cs.ga_mail.me.signOut()

var $settings; $mail; $status : Object
var $file : 4D.File
var $html; $message : Text

$settings:=cs.ga_mail.me.loadSettings()
If ($settings=Null)
	return
End if

$html:="<p>Hello,</p>"
$html:=$html+"<p>This is a test email sent by the GoldenAltos ERP through Microsoft 365, on "+String(Current date)+" at "+String(Current time)+".</p>"
$html:=$html+"<p>A small text file is attached.</p>"
$mail:=cs.ga_mail.me.newMail(New collection($settings.sender); "GoldenAltos ERP - test email"; $html)

$file:=Folder(Temporary folder; fk platform path).file("GA_mail_test.txt")
$file.setText("Test attachment, created on "+String(Current date)+" at "+String(Current time)+".")
cs.ga_mail.me.attachFile($mail; $file)

$status:=cs.ga_mail.me.send($mail; New object("test"; "_ga_testMailSend"))
If ($status.success)
	cs.sfw_dialog.me.info("The test email was sent to "+$settings.sender+". Check the inbox and the Sent Items.")
Else
	$message:="The test email was not sent: "+String($status.statusText)
	If ($status.errors#Null)
		$message:=$message+"\r"+JSON Stringify($status.errors)
	End if
	cs.sfw_dialog.me.alert($message)
End if
