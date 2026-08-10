//%attributes = {"executedOnServer":true}
var $eQuoteStatus : cs:C1710.QuoteStatusEntity
var $eRevision : cs:C1710.RevisionEntity

TRUNCATE TABLE:C1051([QuoteStatus:133])
If (True:C214)
	$file:=Folder:C1567(fk data folder:K87:12).file("DataJson/QuoteStatus_export.json")
	$records:=JSON Parse:C1218($file.getText())
	
	For each ($q; $records)
		$eQuoteStatus:=ds:C1482.QuoteStatus.new()
		$eQuoteStatus.code:=$q.code
		$eQuoteStatus.name:=$q.name
		$eQuoteStatus.statusID:=$q.statusID
		$eQuoteStatus.color:=$q.color
		
		$info:=$eQuoteStatus.save()
		If (Not:C34($info.success))
			TRACE:C157
		End if 
	End for each 
End if 

TRUNCATE TABLE:C1051([Revision:60])
If (True:C214)
	$file:=Folder:C1567(fk data folder:K87:12).file("DataJson/Revision_export.json")
	$records:=JSON Parse:C1218($file.getText())
	
	For each ($r; $records)
		$eRevision:=ds:C1482.Revision.new()
		$eRevision.code:=$r.code
		$eRevision.name:=$r.name
		$eRevision.levelID:=$r.levelID
		$eRevision.color:=$r.color
		
		$info:=$eRevision.save()
		If (Not:C34($info.success))
			TRACE:C157
		End if 
	End for each 
End if 