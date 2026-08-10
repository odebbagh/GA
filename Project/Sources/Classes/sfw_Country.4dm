Class extends DataClass


local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	
	$entry:=cs:C1710.sfw_definitionEntry.new("country"; "administration"; "Countries")
	$entry.setXliffLabel("entry.countries")
	$entry.setDataclass("sfw_Country")
	$entry.setIcon("sfw/entry/world-50x50-1.png"; "sfw/entry/world-50x50.png")
	$entry.setDisplayOrder(-1100)
	//$entry.setSearchboxField("name")
	//$entry.setSearchboxField("iso_code_2")
	//$entry.setSearchboxField("iso_code_3")
	
	$entry.setSearchField("attribute:name"; "tag:name")
	$entry.setSearchField("attribute:iso_code_2"; "tag:isoCode2")
	$entry.setSearchField("attribute:iso_code_3"; "tag:isoCode3")
	
	
	$entry.setPanel("sfw_panel_country")
	$entry.setPanelPage(1; "address-32x32.png"; "Addresses")
	$entry.setLBItemsColumn("flag"; " "; "type:picture"; "width:30"; "orderByFormula:this.iso_code_2")
	$entry.setLBItemsColumn("iso_code_2"; "ISO"; "xliff:entry.sfw_country.field.iso_code_2"; "width:30")
	$entry.setLBItemsColumn("name"; "Name"; "xliff:entry.sfw_country.field.name")
	$entry.setLBItemsOrderBy("name")
	$entry.setLBItemsCounter("###,###,##0 ^1;;"; "unit1:country"; "unitN:countries"; "unit1xliff:entry.sfw_country.unit1"; "unitNxliff:entry.sfw_country.unitN")
	
	$entry.setItemListPreconfigAction("exportReferenceRecords")
	$entry.setItemListPreconfigAction("importReferenceRecords")
	$entry.setItemListPreconfigAction("copyItemsListToPasteboard")
	
	$entry.setToolBarGroup("International"; "Intl"; "sfw/entry/international-50x50.png")
	
local Function cacheClear()
	If (Storage:C1525.cache#Null:C1517)
		Use (Storage:C1525.cache)
			Storage:C1525.cache.sfw_country:=Null:C1517
		End use 
	End if 
	
	
local Function cacheLoad()
	
	If (Storage:C1525.cache=Null:C1517)
		Use (Storage:C1525)
			Storage:C1525.cache:=New shared object:C1526
		End use 
	End if 
	If (Storage:C1525.cache.sfw_country=Null:C1517)
		$countriesColl:=This:C1470._loadAsCollection()
		Use (Storage:C1525.cache)
			Storage:C1525.cache.sfw_country:=$countriesColl.copy(ck shared:K85:29; Storage:C1525.cache)
		End use 
	End if 
	
	
local Function cacheGet($uuid : Text)->$country : Object
	If (Storage:C1525.cache=Null:C1517)
		This:C1470.cacheLoad()
	Else 
		If (Storage:C1525.cache.sfw_country=Null:C1517)
			This:C1470.cacheLoad()
		End if 
	End if 
	$indices:=Storage:C1525.cache.sfw_country.indices("UUID = :1"; $uuid)
	If ($indices.length>0)
		$country:=Storage:C1525.cache.sfw_country[$indices[0]]
	Else 
		$country:=New object:C1471
	End if 
	
	
Function trigger()
	If (Application type:C494=4D Local mode:K5:1)
		This:C1470.cacheClear()
	Else 
		EXECUTE ON CLIENT:C651("@"; "sfw_cacheManager"; "clear"; "sfw_Country")
	End if 
	
	
Function _loadAsCollection()->$countriesColl : Collection
	
	If (This:C1470.getCount()=0)
		$file:=Folder:C1567(fk resources folder:K87:11).file("sfw/startdata/country_new.json")
		$records:=JSON Parse:C1218($file.getText())
		For each ($record; $records)
			$country:=ds:C1482.sfw_Country.new()
			$country.name:=$record.name
			$country.capitalCity:=$record.capitalCity
			$country.iso_code_2:=$record.iso_code_2
			$country.iso_code_3:=$record.iso_code_3
			$country.address_format:=New object:C1471()
			$country.address_format:=$record.address_format
			$country.moreData:=$record.moreData
			
			$info:=$country.save()
			If (Not:C34($info.success))
				TRACE:C157
			End if 
			
		End for each 
	End if 
	$countriesColl:=This:C1470.all().toCollection("name, iso_code_2, address_format").orderBy("name")
	
	