Class extends Entity

// Purpose: Entity helpers for RejectCriteriaItem (list color picto, window title).
// created by 4D/PS [2026-may-19]

local Function get nameInWindowTitle()->$nameInWindowTitle : Text
	$nameInWindowTitle:=This:C1470.name
	
	
local Function get colorPicto()->$picto : Picture
	
	$color:=cs:C1710.sfw_htmlColor.me.getName(This:C1470.color)
	If ($color#"")
		READ PICTURE FILE:C678(Folder:C1567(fk resources folder:K87:11).file("sfw/colors/"+$color+".png").platformPath; $picto)
	End if 
	
	
local Function loadAfterCreation()
	// Purpose: Assign a unique barcode in moreData for scanner lookup on new records.
	// modified by 4D/PS [2026-june-29]
	This:C1470.moreData.barcodeData:=String:C10(cs:C1710.Util_ScannerManager.me.getBarcodeData(Form:C1466.sfw.entry.dataclass); "0000000000")
	If (ds:C1482.RejectCriteriaItem.all().length=0)
		This:C1470.levelID:=1
	Else 
		$max:=ds:C1482.RejectCriteriaItem.all().max("levelID")
		This:C1470.levelID:=($max>0) ? ($max+1) : 1
	End if 
	ds:C1482.RejectCriteriaCategory.cacheLoad()
	