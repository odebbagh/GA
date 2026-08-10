//%attributes = {"executedOnServer":true}
/*
_ga_notificationWorker

*/

_ga_dateRelatedNotifications

DELAY PROCESS:C323(Current process:C322; 5184000)  //1 day
CALL WORKER:C1389("notificationWorker"; Formula:C1597(_ga_notificationWorker))
