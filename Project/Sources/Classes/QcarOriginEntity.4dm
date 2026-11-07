Class extends Entity

// Purpose: Entity helpers for QcarOrigin (window title, default levelID).
// created by 4D/PS [2026-oct-02]

local Function get nameInWindowTitle()->$nameInWindowTitle : Text
	$nameInWindowTitle:=This:C1470.name
	
	
local Function loadAfterCreation()
	If (This:C1470.moreData=Null:C1517)
		This:C1470.moreData:=New object:C1471
	End if 
	This:C1470.moreData.barcodeData:=String:C10(cs:C1710.Util_ScannerManager.me.getBarcodeData(Form:C1466.sfw.entry.dataclass); "0000000000")
	If (ds:C1482.QcarOrigin.all().length=0)
		This:C1470.levelID:=1
	Else 
		$max:=ds:C1482.QcarOrigin.all().max("levelID")
		This:C1470.levelID:=($max>0) ? ($max+1) : 1
	End if
	This:C1470.usesTraveler:=False:C215
	ds:C1482.QcarOrigin.cacheLoad()
	
