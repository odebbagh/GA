//%attributes = {}

var $records : Collection
var $record : Object
var $resourcesFolder : 4D:C1709.Folder
var $exportsFolder : 4D:C1709.Folder
var $file : 4D:C1709.File

$records:=New collection:C1472()

ALL RECORDS:C47([Spec_Control])

While (Not:C34(End selection:C36([Spec_Control])))
	$record:=New object:C1471(\
		"Spec"; [Spec_Control]Spec; \
		"Rev"; [Spec_Control]Rev; \
		"Spec_Title"; [Spec_Control]Spec_Title; \
		"Revsion_Date"; [Spec_Control]Revsion_Date; \
		"Suppress"; [Spec_Control]Suppress; \
		"Form"; [Spec_Control]Form; \
		"Dosext"; [Spec_Control]Dosext; \
		"Division"; [Spec_Control]Division; \
		"DateTimeStamp"; [Spec_Control]DateTimeStamp; \
		"CreationDateTimeStamp"; [Spec_Control]CreationDateTimeStamp; \
		"UniqueID"; [Spec_Control]UniqueID; \
		"ApprovingAuthority1"; [Spec_Control]ApprovingAuthority1; \
		"ApprovingAuthority2"; [Spec_Control]ApprovingAuthority2; \
		"ApprovingAuthority3"; [Spec_Control]ApprovingAuthority3; \
		"ApprovingAuthority4"; [Spec_Control]ApprovingAuthority4; \
		"Status"; [Spec_Control]Status; \
		"CurrentOwner"; [Spec_Control]CurrentOwner; \
		"NumOfUploads"; [Spec_Control]NumOfUploads; \
		"Approved1"; [Spec_Control]Approved1; \
		"Approved2"; [Spec_Control]Approved2; \
		"Approved3"; [Spec_Control]Approved3; \
		"Approved4"; [Spec_Control]Approved4; \
		"ShareFileName"; [Spec_Control]ShareFileName; \
		"SharingHistory"; [Spec_Control]SharingHistory; \
		"LastLocalPath"; [Spec_Control]LastLocalPath; \
		"PublishedDocCategory"; [Spec_Control]PublishedDocCategory; \
		"ReviewIntervalInDays"; [Spec_Control]ReviewIntervalInDays; \
		"ControllingDept"; [Spec_Control]ControllingDept; \
		"Review_Date"; [Spec_Control]Review_Date; \
		"UpdateRequestWP"; [Spec_Control]UpdateRequestWP; \
		"DocumentsinDocServer"; [Spec_Control]DocumentsinDocServer\
		)
	
	$records.push($record)
	NEXT RECORD:C51([Spec_Control])
End while 

$resourcesFolder:=Folder:C1567(fk resources folder:K87:11)
$exportsFolder:=$resourcesFolder.folder("exports")

If (Not:C34($exportsFolder.exists))
	$exportsFolder.create()
End if 

$file:=$exportsFolder.file("specControl_export.json")

If (Not:C34($file.exists))
	$file.create()
End if 

$file.setText(JSON Stringify:C1217($records))

ALERT:C41("Export termine: "+$file.platformPath+" | rows: "+String:C10($records.length))
