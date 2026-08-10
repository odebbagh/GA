
sfw_on_server_startup_database("goldenAltos_definition")
If (ds:C1482.sfw_Notification.query("UUID_User = :1 and stmpOver = :2 order by stmp desc"; cs:C1710.sfw_userManager.me.info.UUID; 0).length>0)
	cs:C1710.sfw_notificationManager.me.openWizardNotifications()
End if 

_ga_notifications()
//CT_R_ST_COM_load

//appointments_cleaner

