//%attributes = {"executedOnServer":true}
TRUNCATE TABLE:C1051([sfw_Country:15])
If (True:C214)
	$file:=Folder:C1567(fk data folder:K87:12).file("DataJson/sfw_country.json")
	
	$records:=JSON Parse:C1218($file.getText())
	For each ($record; $records)
		$country:=ds:C1482.sfw_Country.new()
		$country.name:=$record.name
		$country.capitalCity:=$record.capitalCity
		$country.iso_code_2:=$record.iso_code_2
		$country.iso_code_3:=$record.iso_code_3
		$country.address_format:=New object:C1471()
		$country.address_format:=$record.address_format
		
		$info:=$country.save()
		If (Not:C34($info.success))
			TRACE:C157
		End if 
		
	End for each 
	
End if 