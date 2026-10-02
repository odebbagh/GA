//%attributes = {"executedOnServer":true}

// Purpose: Seed default CAR origin values (Product, Audit, Certification audit, Customer) without wiping admin additions.
// created by 4D/PS [2026-oct-02]
var $defaults : Collection
var $row : Object
var $eOrigin : cs:C1710.QcarOriginEntity
var $info : Object
var $created : Integer
var $maxLevel : Integer

$defaults:=New collection:C1472(\
	New object:C1471("name"; "Product"; "usesTraveler"; True:C214); \
	New object:C1471("name"; "Audit"; "usesTraveler"; False:C215); \
	New object:C1471("name"; "Certification audit"; "usesTraveler"; False:C215); \
	New object:C1471("name"; "Customer"; "usesTraveler"; False:C215)\
	)

$created:=0
If (ds:C1482.QcarOrigin.all().length=0)
	$maxLevel:=0
Else 
	$maxLevel:=ds:C1482.QcarOrigin.all().max("levelID")
	If ($maxLevel<0)
		$maxLevel:=0
	End if 
End if 

For each ($row; $defaults)
	If (ds:C1482.QcarOrigin.query("name = :1"; $row.name).length=0)
		$eOrigin:=ds:C1482.QcarOrigin.new()
		$maxLevel:=$maxLevel+1
		$eOrigin.levelID:=$maxLevel
		$eOrigin.name:=$row.name
		$eOrigin.usesTraveler:=$row.usesTraveler
		$eOrigin.moreData:=New object:C1471("barcodeData"; "")
		$info:=$eOrigin.save()
		If (Not:C34($info.success))
			ALERT:C41("QcarOrigin save failed for \""+$row.name+"\": "+JSON Stringify:C1217($info))
			return 
		End if 
		$created:=$created+1
	End if 
End for each 

ds:C1482.QcarOrigin.cacheClear()
ds:C1482.QcarOrigin.cacheLoad()
ALERT:C41("CAR origins: "+String:C10($created)+" created, "+String:C10(ds:C1482.QcarOrigin.all().length)+" total")
