//%attributes = {}

// Imports project/imports/boApprovers_export.json into [BOApprover].
//
// Legacy's two tables, [BO_Approvers] (level 1) and [BO_Approvers2] (level 2), become one
// table with a level column. The approver is matched to a [Staff] record by name, because
// that is all legacy held - [BUY_ORDERS]Approver1/2 relates to BO_Approvers on
// Approved_by, a plain text name.
//
// Passwords are not imported and not wanted: approval verifies the [sfw_User] account
// password through cs.Util_Authorizer. What crosses over is WHO may approve, AT WHICH
// LEVEL, and UP TO WHAT AMOUNT.
//
// Delete-then-recreate, so it is safe to re-run.
//
// A row whose name does not resolve to a [Staff] record is reported rather than dropped
// silently - it means either _import_users has not run or the person has left, and both
// need a human decision.

var $projectFolder : 4D:C1709.Folder
var $file : 4D:C1709.File
var $records : Collection
var $record : Object
var $approverClass : 4D:C1709.DataClass
var $approver : 4D:C1709.Entity
var $staff : cs:C1710.StaffEntity
var $staffByName : Object
var $nameKey : Text
var $result : Object
var $created; $linked; $unmatched : Integer
var $report : Text
var $unmatchedNames : Collection

$approverClass:=ds:C1482["BOApprover"]
If ($approverClass=Null:C1517)
	ALERT:C41("Dataclass BOApprover not found. Create the table first.")
	return
End if

$projectFolder:=Folder:C1567(fk database folder:K87:14)
$file:=$projectFolder.folder("project/imports").file("boApprovers_export.json")

If (Not:C34($file.exists))
	ALERT:C41("Import file not found: "+$file.platformPath)
	return
End if

$records:=JSON Parse:C1218($file.getText())

//---staff by normalised full name. Legacy holds "Ben Mendoza"; Staff holds first and
//   last separately, so they are joined and folded the same way on both sides.
$staffByName:=New object:C1471()
For each ($staff; ds:C1482.Staff.all())
	$nameKey:=Lowercase:C14(Replace string:C233(String:C10($staff.firstName)+String:C10($staff.lastName); " "; ""))
	If ($nameKey#"")
		$staffByName[$nameKey]:=$staff.UUID
	End if
End for each

$approverClass.all().drop()

$created:=0
$linked:=0
$unmatched:=0
$unmatchedNames:=New collection:C1472()

For each ($record; $records)

	$approver:=$approverClass.new()
	$approver.level:=Num:C11($record.level)
	$approver.moneyLimit:=Num:C11($record.moneyLimit)
	$approver.active:=True:C214

	$nameKey:=Lowercase:C14(Replace string:C233(String:C10($record.approvedBy); " "; ""))
	If ($staffByName[$nameKey]#Null:C1517)
		$approver.UUID_Staff:=$staffByName[$nameKey]
		$linked:=$linked+1
	Else
		$unmatched:=$unmatched+1
		If ($unmatchedNames.indexOf(String:C10($record.approvedBy))=-1)
			$unmatchedNames.push(String:C10($record.approvedBy))
		End if
	End if

	$approver.moreData:=New object:C1471(\
		"importedBy"; "_import_boApprovers"; \
		"importedAt"; cs:C1710.sfw_stmp.me.now(); \
		"legacy"; New object:C1471(\
		"approvedBy"; $record.approvedBy; \
		"dateModified"; $record.dateModified; \
		"hadPassword"; Bool:C1537($record.hadPassword); \
		"ordersSigned"; $record.ordersSigned\
		)\
		)

	$result:=$approver.save()
	If ($result.success)
		$created:=$created+1
	End if

End for each

$report:="BO approvers - created: "+String:C10($created)+"\r"
$report:=$report+"linked to a Staff record: "+String:C10($linked)+" | name not found: "+String:C10($unmatched)

If ($unmatched>0)
	$report:=$report+"\r\rUnmatched names:\r  "+$unmatchedNames.join("\r  ")
	$report:=$report+"\r\rThose rows carry a level and a limit but no staff link, so nobody can"
	$report:=$report+"\rapprove through them. Either _import_users has not run, or the person"
	$report:=$report+"\rhas left and the row should be deactivated."
End if

ALERT:C41($report)
