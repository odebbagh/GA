//%attributes = {}
// _demo_toolDates
// Demo data only. Gives the tools calibration due dates on both sides of today, so Punch In /
// Punch OUT shows the expired-tool filter at work: the tool picker (lb_tools) offers a tool
// whose date is today or later, or that has no date, and hides the others.
// In the legacy data every microscope has no date and every dated tool is past today, so
// without this the filter has nothing to show.
//
// - Microscopes (the tool of step 1, Incoming QC Inspection, in the demo): sorted by name,
//   they alternate expired / valid - the 1st is expired, the 2nd valid, the 3rd expired...
//   Expired ones are due 1 to 52 weeks ago, valid ones in 6 months to 18 months.
// - Other tool types: the tools that had a date alternate the same way; tools without a date
//   are left alone (they stay always offered).
// - Each tool's date before the first run is kept in moreData.demoOriginalDate (ISO text,
//   "" when it had none). _demo_toolDates(True) puts those dates back.
//
// Re-runnable: the tools are chosen from their original dates, so a second run gives the
// same split. The result is shown and written to Project/imports/demo_toolDates.txt.
#DECLARE($restore : Boolean)

var $microscope : 4D:C1709.Entity
var $type : 4D:C1709.Entity
var $tool : 4D:C1709.Entity
var $tools : 4D:C1709.EntitySelection
var $lines : Collection
var $scopes : Collection
var $res : Object
var $i : Integer
var $n : Integer
var $expired : Integer
var $valid : Integer
var $failed : Integer
var $isMicroscope : Boolean

$lines:=New collection:C1472
$failed:=0

// ---- restore the original dates ----
If ($restore)
	$n:=0
	For each ($tool; ds:C1482.Tool.query("moreData.demoOriginalDate # null"))
		$tool.date:=(String:C10($tool.moreData.demoOriginalDate)="") ? !00-00-00! : Date:C102($tool.moreData.demoOriginalDate)
		OB REMOVE:C1226($tool.moreData; "demoOriginalDate")
		$tool.moreData:=$tool.moreData
		$res:=$tool.save()
		If ($res.success)
			$n+=1
		Else 
			$failed+=1
		End if 
	End for each 
	ALERT:C41("Tool dates restored: "+String:C10($n)+Choose:C955($failed=0; ""; " - not saved (locked?): "+String:C10($failed)))
	return 
End if 

// ---- keep each tool's original date, once ----
For each ($tool; ds:C1482.Tool.all())
	If ($tool.moreData=Null:C1517)
		$tool.moreData:=New object:C1471
	End if 
	If ($tool.moreData.demoOriginalDate=Null:C1517)
		$tool.moreData.demoOriginalDate:=($tool.date=!00-00-00!) ? "" : String:C10($tool.date; ISO date:K1:8)
		$tool.moreData:=$tool.moreData
		$res:=$tool.save()
		If (Not:C34($res.success))
			$failed+=1
		End if 
	End if 
End for each 

// ---- both sides of today, tool type by tool type ----
$microscope:=ds:C1482.ToolType.query("name = :1"; "Microscope").first()
$scopes:=New collection:C1472
$expired:=0
$valid:=0

For each ($type; ds:C1482.ToolType.all().orderBy("name asc"))
	$isMicroscope:=False:C215
	If ($microscope#Null:C1517)
		$isMicroscope:=($type.UUID=$microscope.UUID)
	End if 
	If ($isMicroscope)
		$tools:=ds:C1482.Tool.query("UUID_ToolType = :1"; $type.UUID).orderBy("name asc")
	Else 
		$tools:=ds:C1482.Tool.query("UUID_ToolType = :1 AND moreData.demoOriginalDate # :2"; $type.UUID; "").orderBy("name asc")
	End if 

	$i:=0
	For each ($tool; $tools)
		$i+=1
		If (($i%2)=1)
			$tool.date:=Current date:C33-(7*((($i\2)%52)+1))
			$expired+=1
		Else 
			$tool.date:=Current date:C33+182+(7*((($i\2)-1)%52))
			$valid+=1
		End if 
		$res:=$tool.save()
		If (Not:C34($res.success))
			$failed+=1
		End if 
		If ($isMicroscope)
			$scopes.push("  "+cs:C1710.sfw_string.me.trimSpace(String:C10($tool.name))+Choose:C955($tool.date<Current date:C33; "   EXPIRED (due "+String:C10($tool.date)+") - hidden"; "   valid until "+String:C10($tool.date)+" - offered"))
		End if 
	End for each 
End for each 

// ---- result ----
$lines.push("DEMO TOOL DATES ("+String:C10(Current date:C33)+")")
$lines.push("")
$lines.push("Tools set: "+String:C10($expired+$valid)+" - expired (hidden in Punch In / OUT): "+String:C10($expired)+", valid (offered): "+String:C10($valid))
$lines.push("Tools without a date, left alone (always offered): "+String:C10(ds:C1482.Tool.query("date = :1"; !00-00-00!).length))
If ($failed>0)
	$lines.push("Not saved (record locked?): "+String:C10($failed))
End if 
$lines.push("To put the original dates back: _demo_toolDates(True)")
$lines.push("")
If ($microscope=Null:C1517)
	$lines.push("No tool type named Microscope.")
Else 
	$lines.push("Microscopes (Punch In -> step 1 Incoming QC Inspection -> Tools):")
	$lines.combine($scopes)
End if 

Folder:C1567(fk database folder:K87:14).folder("Project/imports").file("demo_toolDates.txt").setText($lines.join("\r\n"))
ALERT:C41($lines.slice(0; 14).join("\r")+Choose:C955($lines.length>14; "\r  ...\r\rFull list: Project/imports/demo_toolDates.txt"; ""))
