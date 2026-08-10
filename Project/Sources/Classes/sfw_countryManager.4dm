property countries : Collection

singleton Class constructor
	ds:C1482.sfw_Country.cacheLoad()
	This:C1470.countries:=Storage:C1525.cache.sfw_country
	
Function get_pupMenu($countryCode : Text)->$chosenCountry : Object
	var $preferedCountries : Collection:=New collection:C1472
	var $preferedCountryCodes : Collection:=New collection:C1472
	
	$preferedCountryCodes:=cs:C1710.sfw_definition.me.globalParameters.preferedCountriesInPup || New collection:C1472
	
	$menu:=Create menu:C408
	For each ($country; Storage:C1525.cache.sfw_country)
		If ($preferedCountries.indexOf($country.iso_code_2)<0)
			APPEND MENU ITEM:C411($menu; $country.name; *)
			SET MENU ITEM ICON:C984($menu; -1; "file:image/flags/tiny/"+$country.iso_code_2+".png")
			SET MENU ITEM PARAMETER:C1004($menu; -1; $country.iso_code_2)
			If ($country.iso_code_2=$countryCode)
				SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
				If (Is Windows:C1573)
					SET MENU ITEM STYLE:C425($menu; -1; Bold:K14:2)
				End if 
			End if 
		End if 
	End for each 
	
	$preferedCountries:=Storage:C1525.cache.sfw_country.query("iso_code_2 IN :1"; $preferedCountryCodes).orderBy("name desc")
	If ($preferedCountries.length>0)
		INSERT MENU ITEM:C412($menu; 0; "-")
	End if 
	
	For each ($country; $preferedCountries)
		INSERT MENU ITEM:C412($menu; 0; $country.name; *)
		SET MENU ITEM ICON:C984($menu; 1; "file:image/flags/tiny/"+$country.iso_code_2+".png")
		SET MENU ITEM PARAMETER:C1004($menu; -1; $country.iso_code_2)
		If ($country.iso_code_2=$countryCode)
			SET MENU ITEM MARK:C208($menu; 1; Char:C90(18))
			If (Is Windows:C1573)
				SET MENU ITEM STYLE:C425($menu; -1; Bold:K14:2)
			End if 
		End if 
	End for each 
	$choose:=Dynamic pop up menu:C1006($menu)
	RELEASE MENU:C978($menu)
	
	If ($choose#"")
		$chosenCountry:=Storage:C1525.cache.sfw_country.query("iso_code_2 = :1"; $choose).first()
	End if 
	
	
	