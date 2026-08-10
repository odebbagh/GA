Class extends Entity

local Function get nameInWindowTitle()->$nameInWindowTitle : Text
	
	$nameInWindowTitle:=This:C1470.name
	
	
local Function itemLoad()
	// This callback is called when the item is selected in the itemList
	
	If (This:C1470.moreData=Null:C1517)
		
		$file:=Folder:C1567(fk resources folder:K87:11).file("sfw/startdata/country_new.json")
		$records:=JSON Parse:C1218($file.getText())
		$country:=$records.query("iso_code_2 = :1"; This:C1470.iso_code_2).first()
		This:C1470.moreData:=$country.moreData
		$info:=This:C1470.save()
		
	Else 
		If (This:C1470.moreData.organisation=Null:C1517)
			$file:=Folder:C1567(fk resources folder:K87:11).file("sfw/startdata/country_new.json")
			$records:=JSON Parse:C1218($file.getText())
			$country:=$records.query("iso_code_2 = :1"; This:C1470.iso_code_2).first()
			If ($country#Null:C1517)
				This:C1470.moreData.organisations:=$country.moreData.organisations
				$info:=This:C1470.save()
			End if 
		End if 
		
	End if 