Class extends DataClass


local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	
	$entry:=cs:C1710.sfw_definitionEntry.new("assumption"; "administration"; "Assumptions")
	$entry.setDataclass("Assumption")
	$entry.setIcon("image/entry/assumption-50x50-W.png"; "image/entry/assumption-50x50-B.png")
	$entry.setDisplayOrder(-21000)
	
	$entry.setSearchboxField("code")
	
	$entry.setPanel("panel_assumption")
	
	$entry.setLBItemsColumn("code"; "Code"; "width:50")
	$entry.setLBItemsColumn("value"; "value")
	// default: attached to every new quote (QuoteEntity.addAssumptions); the others are added by hand
	$entry.setLBItemsColumn("isDefault"; "Default"; "type:boolean"; "width:70")

	$entry.setLBItemsOrderBy("code")
	$entry.setLBItemsOrderBy("value")
	$entry.setLBItemsOrderBy("isDefault"; True:C214)
	
	$entry.setLBItemsCounter("###0###0##0^1;;"; "unit1:assumption"; "unitN:assumptions")
	
	$entry.setItemListPreconfigAction("exportReferenceRecords")
	$entry.setItemListPreconfigAction("importReferenceRecords")
	$entry.setAllowedProfilesForDeletion("admin")  // records may be in use by quotes and leads: admin only
	$entry.setItemListPreconfigAction("copyItemsListToPasteboard")
	
	$entry.setToolBarGroup("QuoteParameters")


	// The assumptions found on at least half of the $max most recent quotes (by code number), used by
	// _fix_assumptionDefaults and _demo_salesTestData to propose the defaults. Quotes that carry every
	// assumption are left out: they were created before isDefault, when everything was attached.
	// -> {total; counted (quotes); threshold (uses); uses (UUID -> number of quotes); UUIDs}
Function usualOnRecentQuotes($max : Integer)->$usual : Object
	var $quote : cs:C1710.QuoteEntity
	var $quotes : Collection
	var $row : Object
	var $uuid : Text

	$usual:=New object:C1471("total"; This:C1470.all().length; "uses"; New object:C1471; "UUIDs"; New collection:C1472)
	$quotes:=New collection:C1472
	For each ($quote; ds:C1482.Quote.all())
		If ($quote.assumptions#Null:C1517) && ($quote.assumptions.UUIDs#Null:C1517)
			If ($quote.assumptions.UUIDs.length>0) && ($quote.assumptions.UUIDs.length<$usual.total)
				$quotes.push(New object:C1471("n"; Num:C11($quote.code); "UUIDs"; $quote.assumptions.UUIDs))
			End if
		End if
	End for each
	$quotes:=$quotes.orderBy("n desc").slice(0; $max)
	$usual.counted:=$quotes.length
	$usual.threshold:=($usual.counted+1)\2

	For each ($row; $quotes)
		For each ($uuid; $row.UUIDs)
			$usual.uses[$uuid]:=Num:C11($usual.uses[$uuid])+1
		End for each
	End for each
	If ($usual.counted>0)
		For each ($uuid; OB Keys:C1719($usual.uses))
			If ($usual.uses[$uuid]>=$usual.threshold) && (This:C1470.get($uuid)#Null:C1517)  // not a deleted one
				$usual.UUIDs.push($uuid)
			End if
		End for each
	End if