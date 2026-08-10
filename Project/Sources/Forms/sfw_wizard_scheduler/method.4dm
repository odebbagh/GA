Case of 
	: (FORM Event:C1606.code=On Load:K2:1)
		Form:C1466.lb_schedulers:=ds:C1482.sfw_Scheduler.all()
		cs:C1710.sfw_window.me.setWindowTitle()
		
End case 

OBJECT SET TITLE:C194(*; "scheduler"; ds:C1482.sfw_readXliff("scheduler.title"; "Scheduler"))
OBJECT SET TITLE:C194(*; "name"; ds:C1482.sfw_readXliff("scheduler.name"; "Name"))
OBJECT SET TITLE:C194(*; "lastEx"; ds:C1482.sfw_readXliff("scheduler.lastEx"; "Last execution"))
OBJECT SET TITLE:C194(*; "time"; ds:C1482.sfw_readXliff("scheduler.time"; "Time"))