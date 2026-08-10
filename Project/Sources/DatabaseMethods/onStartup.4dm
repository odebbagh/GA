SET DATABASE LOCALIZATION:C1104("en_us")

$version:=Num:C11(Substring:C12(Application version:C493; 1; 2))
$revision:=Substring:C12(Application version:C493; 3; 1)

If (Not:C34(($version=20) && (Position:C15($revision; "9ABCDEF")>0)))  // Compatibility starting with 4D 20 R9
	$ok:=cs:C1710.sfw_dialog.me.confirm("This database should be opened with 4D20 R9\rOpen anyway? (Cancel will QUIT 4D)")
	If ($ok=False:C215)
		QUIT 4D:C291
	End if 
End if 

_ga_setAllowedMethods()
//_ga_findScannerSeriaPort()

sfw_on_startup_database("goldenAltos_definition")

If (ds:C1482.sfw_Notification.query("UUID_User = :1 and stmpOver = :2 order by stmp desc"; cs:C1710.sfw_userManager.me.info.UUID; 0).length>0)
	cs:C1710.sfw_notificationManager.me.openWizardNotifications()
End if 
