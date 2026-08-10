Class extends DataClass


Function assignationsSummaryForTab($target : Text; $entryIdent : Text; $userUUID : Text)->$summary : Object
	var $esTodos : cs:C1710.sfw_TodoSelection
	var $formula : 4D:C1709.Function
	var $settings : Object
	
	$summary:=New object:C1471
	$esTodos:=ds:C1482.sfw_Todo.query("UUID_target = :1 and entryIdent = :2"; $target; $entryIdent)
	$summary.nbTodo:=$esTodos.length
	
	$uuidTargets:=$esTodos.distinct("UUID_targetAssigned")
	$uuidTargets:=$uuidTargets.concat(ds:C1482.sfw_UserProfile.query("UUID in :1"; $uuidTargets).userInscriptions.extract("UUID_User")).distinct()
	
	$summary.concernMe:=$uuidTargets.indexOf($userUUID)#-1
	
	$formula:=Formula:C1597(This:C1470.deadlineStmp<$1.now)
	$settings:=New object:C1471()
	$settings.args:=New object:C1471("now"; cs:C1710.sfw_stmp.me.now())
	
	$summary.notAchived:=Bool:C1537($esTodos.query("achievedStmp = 0 & deadlineStmp#0 & :1"; $formula; $settings).length#0)
	
	
Function assignationsSummaryForToolbar($userUUID : Text)->$summary : Object
	var $esTodos : cs:C1710.sfw_TodoSelection
	var $formula : 4D:C1709.Function
	var $settings : Object
	
	$summary:=New object:C1471
	
	$targetedMe:=[$userUUID].concat(ds:C1482.sfw_UserInscription.query("UUID_User = :1"; $userUUID).extract("UUID_UserProfile"))
	$formula:=Formula:C1597(This:C1470.deadlineStmp<$1.now)
	$settings:=New object:C1471()
	$settings.args:=New object:C1471("now"; cs:C1710.sfw_stmp.me.now())
	$esTodos:=ds:C1482.sfw_Todo.query("UUID_targetAssigned in :1 and achievedStmp = 0 & deadlineStmp#0"; $targetedMe; $settings)
	$summary.todoForMe:=$esTodos.length
	$esTodos:=ds:C1482.sfw_Todo.query("UUID_targetAssigned in :1 and achievedStmp = 0 & deadlineStmp#0 & :2"; $targetedMe; $formula; $settings)
	
	$summary.todoForMeLate:=$esTodos.length