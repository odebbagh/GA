//%attributes = {}
// _import_runSteps($title; $steps; $from; $logName)
// The engine shared by _import_all (everything from the legacy app) and _setup_all (only
// the set-up a new data file needs). The caller gives the ordered steps:
//   $steps   [{method: "name"; needs: ["project:x.json" | "data:x.json" | "data:Folder/"]}]
//            project: = Project/imports (read here, on this machine)
//            data:    = the data folder, checked on the server (_import_allSrv): a 4D
//                       Remote client has none
//   $from    "" = from the top, or a method name to resume from that step
//   $logName the log written to Project/imports on the server after every step
//   $keepExisting  True = a step that empties tables ({wipes: ["Dataclass"; ...]}) is
//            skipped when one of those tables already holds records, so data already in
//            the file - and every record linked to it - is left as it is.
// A step whose source is missing is skipped and reported; nothing stops the run.

#DECLARE($title : Text; $steps : Collection; $from : Text; $logName : Text; $keepExisting : Boolean)

var $log; $skippedList; $dataNeeds; $keptList; $wiped : Collection
var $step : Object
var $need; $root; $rel; $summary; $logPath; $name : Text
var $importsFolder : 4D:C1709.Folder
var $server; $counts : Object
var $started; $exists : Boolean
var $ran; $skipped; $kept; $t0 : Integer

// Project/imports as the client-side importers see it
$importsFolder:=Folder:C1567(fk database folder:K87:14).folder("Project/imports")

//---data folder sources: one round trip to the server for all of them
$dataNeeds:=[]
For each ($step; $steps)
	For each ($need; $step.needs)
		If ($need="data:@")
			$dataNeeds.push(Substring:C12($need; 6))
		End if
	End for each
End for each
$server:=_import_allSrv("check"; $dataNeeds)

$skippedList:=[]
For each ($step; $steps)
	$step.missing:=[]
	For each ($need; $step.needs)
		$root:=Substring:C12($need; 1; Position:C15(":"; $need)-1)
		$rel:=Substring:C12($need; Position:C15(":"; $need)+1)
		Case of
			: ($root="data")
				$exists:=($server.missing.indexOf($rel)=-1)
			: (Substring:C12($rel; Length:C16($rel))="/")
				$exists:=$importsFolder.folder($rel).exists
			Else
				$exists:=$importsFolder.file($rel).exists
		End case
		If (Not:C34($exists))
			$step.missing.push($need)
		End if
	End for each
	If ($step.missing.length>0)
		$skippedList.push($step.method+" (missing "+$step.missing.join(", ")+")")
	End if
End for each

//---steps that would empty tables already holding records (counted on the server)
$keptList:=[]
For each ($step; $steps)
	$step.kept:=[]
End for each
If ($keepExisting)
	$wiped:=[]
	For each ($step; $steps)
		If ($step.wipes#Null:C1517)
			$wiped:=$wiped.concat($step.wipes)
		End if
	End for each
	$counts:=_import_allSrv("count"; $wiped.distinct()).counts
	For each ($step; $steps)
		If ($step.wipes#Null:C1517)
			For each ($name; $step.wipes)
				If (Num:C11($counts[$name])>0)
					$step.kept.push($name+" "+String:C10($counts[$name]))
				End if
			End for each
		End if
		If ($step.kept.length>0) && ($step.missing.length=0)
			$keptList.push($step.method+" (has "+$step.kept.join(", ")+")")
		End if
	End for each
End if

If ($from#"") && ($steps.query("method = :1"; $from).length=0)
	cs:C1710.sfw_dialog.me.alert("No step named \""+$from+"\" in "+$title+".")
	return
End if

$summary:=($from="") ? $title+": run all "+String:C10($steps.length)+" steps on this data file?" : $title+": run from "+$from+"?"
$summary+="\rData file: "+String:C10($server.dataFile)
If ($keepExisting)
	$summary+="\r\rKeeps existing data: a step that would empty a table already holding records is skipped."
	If ($keptList.length>0)
		$summary+="\r\rKept as they are, already filled:\r"+$keptList.join("\r")
	End if
Else
	$summary+="\r\rThe imports replace what is in the tables they fill."
End if
If (Not:C34($importsFolder.exists))
	$summary+="\r\rProject/imports was not found on this machine ("+$importsFolder.platformPath+"): every step that reads it will be skipped."
End if
If ($skippedList.length>0)
	$summary+="\r\rSkipped, source not found:\r"+$skippedList.join("\r")
End if

If (Not:C34(cs:C1710.sfw_dialog.me.confirm($summary; "Import"; "Cancel")))
	return
End if

$log:=[$title+" "+String:C10(Current date:C33; ISO date:K1:8)+" "+String:C10(Current time:C178)+\
($from="" ? "" : " from "+$from); "data file: "+String:C10($server.dataFile); ""]
$started:=($from="")
$ran:=0
$skipped:=0
$kept:=0

For each ($step; $steps)
	If (Not:C34($started))
		$started:=($step.method=$from)
		If (Not:C34($started))
			continue
		End if
	End if

	If ($step.missing.length>0)
		$log.push("SKIPPED  "+$step.method+"  missing: "+$step.missing.join(", "))
		$skipped+=1
		$logPath:=_import_allSrv("log"; {name: $logName; text: $log.join("\r\n")}).path
		continue
	End if

	If ($step.kept.length>0)
		$log.push("KEPT     "+$step.method+"  already filled: "+$step.kept.join(", "))
		$kept+=1
		$logPath:=_import_allSrv("log"; {name: $logName; text: $log.join("\r\n")}).path
		continue
	End if

	$log.push(String:C10(Current time:C178)+"  "+$step.method+" ...")
	$logPath:=_import_allSrv("log"; {name: $logName; text: $log.join("\r\n")}).path

	$t0:=Milliseconds:C459
	EXECUTE METHOD:C1007($step.method)

	$log[$log.length-1]:=$log[$log.length-1]+" done ("+String:C10(Round:C94((Milliseconds:C459-$t0)/1000; 1))+" s)"
	$ran+=1
	$logPath:=_import_allSrv("log"; {name: $logName; text: $log.join("\r\n")}).path
End for each

$log.push("")
$log.push("ran: "+String:C10($ran)+"   skipped: "+String:C10($skipped)+"   kept (already filled): "+String:C10($kept))
$logPath:=_import_allSrv("log"; {name: $logName; text: $log.join("\r\n")}).path

cs:C1710.sfw_dialog.me.alert($title+" finished. Ran "+String:C10($ran)+" step(s), skipped "+String:C10($skipped)+\
", kept "+String:C10($kept)+" already filled."+\
"\rLog (on the server): "+$logPath)
