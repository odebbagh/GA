//%attributes = {}
// _demo_compileCheck
// Runs 4D's compiler in syntax-check mode (no compiled code is produced, nothing changes)
// and reports the errors, the ones in code changed for this demo first. Catches what the
// _demo_check tests cannot reach: typos and type errors in buttons, form methods and panel
// functions. Run it in 4D (single user / developer), not from a remote 4D client.
// Report: Project/imports/demo_compileCheck.txt
	
var $result : Object
var $error : Object
var $text : Text
var $name : Text
var $isOurs : Boolean
var $ours : Collection
var $others : Collection
var $lines : Collection
var $changed : Collection
var $oursErrors : Integer
	
// code changed for the demo (classes, methods, forms)
$changed:=New collection:C1472("ga_events"; "ga_demoCheck"; "ga_stepDocuments"; "LotMergeService"; "LotSplitService"; \
	"LotStepEntity"; "LotEntity"; "CustomerEntity"; "Customer"; "panel_planning"; "panel_punch_in"; "panel_punch_out"; \
	"panel_specification"; "goldenAltos_definition"; "LotHoldForm_"; "_demo_"; "_fix_sequences"; "planning_mergeLot"; \
	"NCMN"; "ISSNF"; "sn_checkbox_pass"; "lb_tools"; "btn_hold_forms"; "bSpecView"; "df_steps_entry"; "field_disposition"; "chk_approval")
	
// targets: empty collection = syntax check only, no compiled code generated
$result:=Compile project:C1760(New object:C1471("targets"; New collection:C1472))
	
$ours:=New collection:C1472
$oursErrors:=0
$others:=New collection:C1472
If ($result.errors#Null:C1517)
	For each ($error; $result.errors)
		$text:=JSON Stringify:C1217($error.code)
		$isOurs:=False:C215
		For each ($name; $changed) Until ($isOurs)
			$isOurs:=(Position:C15($name; $text)>0)
		End for each 
		$text:=Choose:C955(Bool:C1537($error.isError); "ERROR   "; "warning ")+String:C10($error.code.path || $error.code.methodName)+" line "+String:C10($error.lineInFile || $error.line)+": "+String:C10($error.message)
		If ($isOurs)
			$ours.push($text)
			If (Bool:C1537($error.isError))
				$oursErrors+=1
			End if 
		Else 
			$others.push($text)
		End if 
	End for each 
End if 
	
$lines:=New collection:C1472
$lines.push("COMPILE CHECK - "+String:C10(Current date:C33)+" "+String:C10(Current time:C178; HH MM:K7:2))
$lines.push("In code changed for the demo: "+String:C10($oursErrors)+" error(s) - "+String:C10($ours.length)+" message(s)")
$lines.push("Elsewhere (older code): "+String:C10($others.length)+" message(s)")
$lines.push("")
$lines.push("== Code changed for the demo ==")
$lines.combine($ours.orderBy())
$lines.push("")
$lines.push("== Elsewhere ==")
$lines.combine($others.orderBy().slice(0; 300))
Folder:C1567(fk database folder:K87:14).folder("Project/imports").file("demo_compileCheck.txt").setText($lines.join("\r\n"))
	
ALERT:C41($lines.slice(0; 3).join("\r")+Choose:C955($ours.length=0; ""; "\r\r"+$ours.orderBy().slice(0; 8).join("\r"))+"\r\rFull report: Project/imports/demo_compileCheck.txt")
