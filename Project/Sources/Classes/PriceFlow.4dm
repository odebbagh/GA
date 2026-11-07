// PriceFlow: the flows that change the unit price of the master price list (Commercial, MIL,
// Space, Class S, environmental...). The minimum lot charge does not depend on the flow.
// A quote has one flow (Quote.UUID_PriceFlow); with none, the default one (isDefault) is used.
// moreData.aliases: the legacy process-qualifier texts (Job.pr_qualifier / Lot.prQualifier, e.g.
// "MIL-STD-883", "Class S_V") that mean this flow, see fromQualifier.
Class extends DataClass

local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	$entry:=cs:C1710.sfw_definitionEntry.new("priceFlow"; "administration"; "Price flows"; "Price flow")
	$entry.setDataclass("PriceFlow")
	$entry.setIcon("image/entry/serviceType-50x50-W.png"; "image/entry/serviceType-50x50-B.png")
	$entry.setDisplayOrder(-20900)

	$entry.setSearchboxField("code")
	$entry.setSearchboxField("name")

	$entry.setPanel("panel_priceFlow")

	$entry.setLBItemsColumn("levelID"; "Order"; "width:50"; "right"; "headerRight")
	$entry.setLBItemsColumn("code"; "Code"; "width:80")
	$entry.setLBItemsColumn("name"; "Name"; "width:200")
	$entry.setLBItemsColumn("isDefault"; "Default"; "type:boolean"; "width:70")

	$entry.setLBItemsOrderBy("levelID")
	$entry.setLBItemsOrderBy("code")
	$entry.setLBItemsOrderBy("name")

	$entry.setLBItemsCounter("###0###0##0 ^1;;"; "unit1:flow"; "unitN:flows")

	$entry.setValidationRule("code"; "entryField_code"; "mandatory"; "trimSpace"; "uppercase")
	$entry.setValidationRule("name"; "entryField_name"; "mandatory"; "trimSpace")

	$entry.setItemListPreconfigAction("exportReferenceRecords")
	$entry.setItemListPreconfigAction("importReferenceRecords")
	$entry.setItemListPreconfigAction("copyItemsListToPasteboard")
	// the price list is maintained by the admin profile only
	$entry.setAllowedProfilesForCreation("admin")
	$entry.setAllowedProfilesForModification("admin")
	$entry.setAllowedProfilesForDeletion("admin")

	$entry.setToolBarGroup("QuoteParameters")


	// the flow used when a quote has none: the one marked default, else the first by order
Function defaultFlow()->$flow : cs:C1710.PriceFlowEntity
	$flow:=This:C1470.query("isDefault = :1"; True:C214).orderBy("levelID asc").first()
	If ($flow=Null:C1517)
		$flow:=This:C1470.all().orderBy("levelID asc").first()
	End if

	// the flow of a text: its code, its name or one of its aliases (case and spaces ignored).
	// Null when nothing matches. Used by the import and to price a job from its pr_qualifier.
Function fromText($text : Text)->$flow : cs:C1710.PriceFlowEntity
	var $e : cs:C1710.PriceFlowEntity
	var $alias : Text
	var $key : Text

	$key:=This:C1470._key($text)
	If ($key="")
		return
	End if
	For each ($e; This:C1470.all())
		If (This:C1470._key($e.code)=$key) || (This:C1470._key($e.name)=$key)
			return $e
		End if
		If ($e.moreData#Null:C1517) && (Value type:C1509($e.moreData.aliases)=Is collection:K8:32)
			For each ($alias; $e.moreData.aliases)
				If (This:C1470._key($alias)=$key)
					return $e
				End if
			End for each
		End if
	End for each

Function _key($text : Text)->$key : Text
	$key:=Uppercase:C13(Replace string:C233(Replace string:C233(Replace string:C233($text; " "; ""); "-"; ""); "_"; ""))
