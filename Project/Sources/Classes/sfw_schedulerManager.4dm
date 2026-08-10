property workerRunning : Boolean
property schedulers : cs:C1710.sfw_SchedulerSelection

singleton Class constructor
	
	Case of 
		: (Application type:C494=4D Server:K5:6)
			This:C1470.schedulers:=ds:C1482.sfw_Scheduler.query("onServer = true")
		: (Application type:C494=4D Remote mode:K5:5)
			This:C1470.schedulers:=ds:C1482.sfw_Scheduler.query("onServer = false")
		: (Application type:C494=4D Local mode:K5:1)
			This:C1470.schedulers:=ds:C1482.sfw_Scheduler.all()
		: (Application type:C494=4D Volume desktop:K5:2)
			This:C1470.schedulers:=ds:C1482.sfw_Scheduler.all()
	End case 
	This:C1470.workerRunning:=False:C215
	
	
	//Mark:-Worker
	
Function launch()
	CALL WORKER:C1389("sfw_scheduler"; Formula:C1597(cs:C1710.sfw_schedulerManager.me._worker()))
	
	
Function _worker()
	var $eScheduler : cs:C1710.sfw_SchedulerEntity
	var $eLastLog : cs:C1710.sfw_SchedulerLogEntity
	var $now : Integer
	var $lastStmp : Integer
	
	This:C1470.workerRunning:=True:C214
	Repeat 
		For each ($eScheduler; This:C1470.schedulers)
			$eLastLog:=$eScheduler.schedulerLogs.orderBy("stmp desc").first()
			$eScheduler.reload()  //to refresh active attrribute
			$execute:=False:C215
			If (Bool:C1537($eScheduler.active))
				$now:=cs:C1710.sfw_stmp.me.now()
				$currentHour:=cs:C1710.sfw_stmp.me.getHour()
				Case of 
					: ($eScheduler.periodicity.hourly)
						If ($currentHour>=$eScheduler.periodicity.hourMini) && ($currentHour<=$eScheduler.periodicity.hourMaxi)
							
							If ($eScheduler.periodicity.minutesToStart#Null:C1517)  // toutes les X minutes
								For each ($minute; $eScheduler.periodicity.minutesToStart)
									$lastStmp:=($eLastLog.stmp=Null:C1517) ? 0 : ($eLastLog.stmp\3600*3600)+($minute*60)
									$minuteToStart:=$minute
									
									$stringTime:=String:C10(Current time:C178)
									$stringStartTime:=Substring:C12($stringTime; 1; 3)+String:C10($minuteToStart; "00")+":00"
									$hourToExecute:=Time:C179($stringStartTime)
									
									If ($eLastLog=Null:C1517)
										If (($hourToExecute)<Current time:C178) && (($hourToExecute+?00:02:00?)>=Current time:C178)
											$execute:=True:C214
										End if 
									Else 
										//$hourPrevious:=cs.sfw_stmp.me.getHour($lastStmp)
										//$hourNow:=cs.sfw_stmp.me.getHour($now)
										If ($lastStmp<$now) || (cs:C1710.sfw_stmp.me.getDate($lastStmp)<Current date:C33)
											If (($hourToExecute)<Current time:C178) && (($hourToExecute+?00:01:00?)>=Current time:C178)
												$execute:=True:C214
											End if 
										End if 
									End if 
									
									If ($execute=True:C214)
										break
									End if 
								End for each 
							Else 
								$lastStmp:=($eLastLog.stmp=Null:C1517) ? 0 : ($eLastLog.stmp\3600*3600)+($eScheduler.periodicity.minuteToStart*60)
								$minuteToStart:=$eScheduler.periodicity.minuteToStart
								$stringTime:=String:C10(Current time:C178)
								$stringStartTime:=Substring:C12($stringTime; 1; 3)+String:C10($minuteToStart; "00")+":00"
								$hourToExecute:=Time:C179($stringStartTime)
								
								If ($eLastLog=Null:C1517)
									If (($hourToExecute)<Current time:C178) && (($hourToExecute+?00:02:00?)>=Current time:C178)
										$execute:=True:C214
									End if 
								Else 
									$hourPrevious:=cs:C1710.sfw_stmp.me.getHour($lastStmp)
									$hourNow:=cs:C1710.sfw_stmp.me.getHour($now)
									If ($hourPrevious<$hourNow) || (cs:C1710.sfw_stmp.me.getDate($lastStmp)<Current date:C33)
										If (($hourToExecute)<Current time:C178) && (($hourToExecute+?00:02:00?)>=Current time:C178)
											$execute:=True:C214
										End if 
									End if 
								End if 
							End if 
							
							
						End if 
						
					: ($eScheduler.periodicity.daily)
						$currentDayNumber:=Day number:C114(Current date:C33)
						If ($eScheduler.periodicity.dayNumbers.length=0) || ($eScheduler.periodicity.dayNumbers.indexOf($currentDayNumber)#-1)
							$lastDate:=($eLastLog=Null:C1517) ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate($eLastLog.stmp)
							$hourToExecute:=Time:C179(($eScheduler.periodicity.hourToStart*60*60)+($eScheduler.periodicity.minuteToStart*60))
							If ($lastDate<Current date:C33)
								If (($hourToExecute)<Current time:C178) && (($hourToExecute+?00:02:00?)>=Current time:C178)
									$execute:=True:C214
								End if 
							End if 
						End if 
						
					: ($eScheduler.periodicity.weekly)
						$currentDayNumber:=Day number:C114(Current date:C33)
						If ($eScheduler.periodicity.dayNumber=$currentDayNumber)
							$lastDate:=($eLastLog=Null:C1517) ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate($eLastLog.stmp)
							$hourToExecute:=Time:C179(($eScheduler.periodicity.hourToStart*60*60)+($eScheduler.periodicity.minuteToStart*60))
							If ($lastDate<Current date:C33)
								If (($hourToExecute)<Current time:C178) && (($hourToExecute+?00:02:00?)>=Current time:C178)
									$execute:=True:C214
								End if 
							End if 
						End if 
						
					: ($eScheduler.periodicity.monthly)
						
					: ($eScheduler.periodicity.yearly)
						
						
				End case 
			End if 
			
			If ($execute)
				If (cs:C1710[$eScheduler.targetDataclassName]#Null:C1517)
					If (cs:C1710[$eScheduler.targetDataclassName].__prototype[$eScheduler.functionToLaunch]#Null:C1517)
						$eLastLog:=ds:C1482.sfw_SchedulerLog.new()
						$eLastLog.UUID:=Generate UUID:C1066
						$eLastLog.UUID_Scheduler:=$eScheduler.UUID
						$eLastLog.stmp:=cs:C1710.sfw_stmp.me.now()
						$eLastLog.moreData:=New object:C1471("launch"; $eLastLog.stmp)
						$eLastLog.UUID_User:=cs:C1710.sfw_userManager.me.info.UUID
						$info:=$eLastLog.save()
						If ($info.success)
							CALL WORKER:C1389("Scheduler:"+$eScheduler.ident; Formula from string:C1601("cs."+$eScheduler.targetDataclassName+".new()."+$eScheduler.functionToLaunch+"($1)"); $eLastLog.UUID)
						End if 
					End if 
				End if 
			End if 
		End for each 
		
		DELAY PROCESS:C323(Current process:C322; 60*60)
	Until (Process aborted:C672)
	This:C1470.workerRunning:=False:C215
	
	
	//Mark: -Creation
	
Function createIfNotExist($ident : Text; $name : Text; $periodicity : Object; $targetClassName : Text; $functionToLaunch : Text; $onServer : Boolean)
	var $eScheduler : cs:C1710.sfw_SchedulerEntity
	If (Application type:C494#4D Remote mode:K5:5)
		$eScheduler:=ds:C1482.sfw_Scheduler.query("ident = :1"; $ident).first()
		If ($eScheduler=Null:C1517)
			$eScheduler:=ds:C1482.sfw_Scheduler.new()
			$eScheduler.UUID:=Generate UUID:C1066
			$eScheduler.ident:=$ident
			$eScheduler.name:=$name
			$eScheduler.periodicity:=$periodicity
			$eScheduler.targetDataclassName:=$targetClassName
			$eScheduler.functionToLaunch:=$functionToLaunch
			$eScheduler.onServer:=$onServer
			$eScheduler.active:=False:C215
			$info:=$eScheduler.save()
		End if 
	End if 