//%attributes = {}
/*
BOStatus_seed

Seeds the four buying-order statuses into [BOStatus]. Idempotent: matched by
name, so it is safe to run more than once and stable across re-imports.
Run once from the method editor.
*/

var $defs : Collection
var $def : Object
var $st : Object
var $res : Object
var $created : Integer

$created:=0

$defs:=New collection:C1472(\
	New object:C1471("name"; "Requisition"; "levelID"; 1); \
	New object:C1471("name"; "Approved"; "levelID"; 2); \
	New object:C1471("name"; "Closed"; "levelID"; 3); \
	New object:C1471("name"; "On Hold"; "levelID"; 4)\
	)

For each ($def; $defs)
	If (ds:C1482.BOStatus.query("name = :1"; $def.name).length=0)
		$st:=ds:C1482.BOStatus.new()
		$st.name:=$def.name
		$st.levelID:=$def.levelID
		$res:=$st.save()
		If ($res.success)
			$created:=$created+1
		End if
	End if
End for each

ALERT:C41("BOStatus seed done - "+String:C10($created)+" status(es) created.")
