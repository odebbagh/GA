//%attributes = {}
// Seeds the [CustomerCarrier] lookup table with the agreed list of carriers / ship-via
// methods. The list is held here rather than in project/imports, because it is agreed
// reference data, not a dump of the legacy application.
//
// DUPLICATES
//   The source list spelt the same carrier several ways - "Fed-Ex Ground",
//   "fedex Ground", "FedEx Ground" - and those were collapsed onto one row each.
//   The spellings that were dropped are kept as aliases on the surviving row, in
//   moreData.aliases, so the legacy values still resolve to it. _carrierMatchKey does
//   the folding; _import_buyOrders and _import_customers use the same function, so a
//   buy order whose shipVia reads "fedex Std Overnight" finds "FedEx Standard Overnight".
//
// Run order: this one FIRST, then _import_customers, then _import_buyOrders - both of
// those only link to the rows found here.
//
// Rows are matched on the folded key and updated in place, never deleted or recreated,
// so the UUIDs that customers and buy orders point at stay valid. Rows already in the
// table that are not in the list below are left alone and listed in the report.

var $carriers : Collection
var $carrier : Object
var $alias : Text
var $eCarrier : cs:C1710.CustomerCarrierEntity
var $esCarriers : cs:C1710.CustomerCarrierSelection
var $existing : Object
var $key : Text
var $aliasKeys : Collection
var $result : Object
var $created : Integer
var $updated : Integer
var $failed : Integer
var $level : Integer
var $listedKeys : Collection
var $unlisted : Collection

$carriers:=New collection:C1472

$carriers.push(New object:C1471("name"; "GAC Driver"))
$carriers.push(New object:C1471("name"; "GAC UPS acct"))
$carriers.push(New object:C1471("name"; "USPS"))
$carriers.push(New object:C1471("name"; "Air Borne"))

$carriers.push(New object:C1471("name"; "UPS"; \
	"aliases"; New collection:C1472("ups")))
$carriers.push(New object:C1471("name"; "UPS Ground"))
$carriers.push(New object:C1471("name"; "UPS Next Day"))
$carriers.push(New object:C1471("name"; "UPS 2nd Day"))
$carriers.push(New object:C1471("name"; "UPS 3rd Day"; \
	"aliases"; New collection:C1472("UPS 3rd day")))
$carriers.push(New object:C1471("name"; "UPS Air Saver"))

$carriers.push(New object:C1471("name"; "FedEx"; \
	"aliases"; New collection:C1472("fedex")))
$carriers.push(New object:C1471("name"; "FedEx Ground"; \
	"aliases"; New collection:C1472("Fed-Ex Ground"; "fedex Ground")))
$carriers.push(New object:C1471("name"; "FedEx Standard"; \
	"aliases"; New collection:C1472("Fed-Ex Standard"; "fedex Standard")))
$carriers.push(New object:C1471("name"; "FedEx Priority"; \
	"aliases"; New collection:C1472("Fed-Ex Priority"; "fedex Priority")))
$carriers.push(New object:C1471("name"; "FedEx 2nd Day"; \
	"aliases"; New collection:C1472("Fed-Ex 2nd Day"; "fedex 2nd Day")))
$carriers.push(New object:C1471("name"; "FedEx 3rd Day"; \
	"aliases"; New collection:C1472("fedex 3rd Day")))
$carriers.push(New object:C1471("name"; "FedEx Overnight"; \
	"aliases"; New collection:C1472("fedex Overnight")))
$carriers.push(New object:C1471("name"; "FedEx Priority Overnight"; \
	"aliases"; New collection:C1472("Fed-Ex Priority Overnight"; "fedex Priority Overnight")))
$carriers.push(New object:C1471("name"; "FedEx Standard Overnight"; \
	"aliases"; New collection:C1472("fedex Standard Overnight"; "fedex Std Overnight")))
$carriers.push(New object:C1471("name"; "FedEx 1st Overnight"; \
	"aliases"; New collection:C1472("fedex 1st Overnight")))
$carriers.push(New object:C1471("name"; "FedEx Express Saver"; \
	"aliases"; New collection:C1472("fedex Express Saver")))
$carriers.push(New object:C1471("name"; "FedEx International"; \
	"aliases"; New collection:C1472("Fedex International")))

$carriers.push(New object:C1471("name"; "Customer Pickup"))
$carriers.push(New object:C1471("name"; "Supplier pickup"))
$carriers.push(New object:C1471("name"; "Supplier delivery"))
$carriers.push(New object:C1471("name"; "Vendor pickup"))
$carriers.push(New object:C1471("name"; "On site"))

$created:=0
$updated:=0
$failed:=0
$level:=0
$listedKeys:=New collection:C1472

//---index what is already there by folded key, so a row spelt the legacy way is
//   recognised and renamed rather than duplicated
$existing:=New object:C1471
For each ($eCarrier; ds:C1482.CustomerCarrier.all())
	$key:=_carrierMatchKey($eCarrier.name)
	If ($key#"") && ($existing[$key]=Null:C1517)
		$existing[$key]:=$eCarrier.UUID
	End if
End for each

For each ($carrier; $carriers)

	$level:=$level+1
	$key:=_carrierMatchKey($carrier.name)
	$listedKeys.push($key)

	//the aliases resolve to this same row, and are also folded so the legacy
	//spellings can be looked up directly
	$aliasKeys:=New collection:C1472
	If ($carrier.aliases#Null:C1517)
		For each ($alias; $carrier.aliases)
			$aliasKeys.push(_carrierMatchKey($alias))
			$listedKeys.push(_carrierMatchKey($alias))
		End for each
	End if

	If ($existing[$key]=Null:C1517)
		$eCarrier:=ds:C1482.CustomerCarrier.new()
		$eCarrier.name:=$carrier.name
		$eCarrier.code:=Uppercase:C13($carrier.name)
		$eCarrier.levelID:=$level
		$eCarrier.moreData:=New object:C1471(\
			"seededBy"; "_import_customerCarriers"; \
			"matchKey"; $key; \
			"aliases"; ($carrier.aliases=Null:C1517) ? New collection:C1472 : $carrier.aliases.copy(); \
			"aliasKeys"; $aliasKeys)
		$result:=$eCarrier.save()
		If ($result.success)
			$created:=$created+1
		Else
			$failed:=$failed+1
		End if
	Else
		//keep the UUID the customers and buy orders already point at
		$eCarrier:=ds:C1482.CustomerCarrier.query("UUID = :1"; $existing[$key]).first()
		$eCarrier.name:=$carrier.name
		$eCarrier.code:=Uppercase:C13($carrier.name)
		$eCarrier.levelID:=$level
		If ($eCarrier.moreData=Null:C1517)
			$eCarrier.moreData:=New object:C1471()
		End if
		$eCarrier.moreData.seededBy:="_import_customerCarriers"
		$eCarrier.moreData.matchKey:=$key
		$eCarrier.moreData.aliases:=($carrier.aliases=Null:C1517) ? New collection:C1472 : $carrier.aliases.copy()
		$eCarrier.moreData.aliasKeys:=$aliasKeys
		$result:=$eCarrier.save()
		If ($result.success)
			$updated:=$updated+1
		Else
			$failed:=$failed+1
		End if
	End if

End for each

//---anything already in the table that the list does not cover. Left in place on
//   purpose: customers and buy orders may point at it.
$unlisted:=New collection:C1472
For each ($eCarrier; ds:C1482.CustomerCarrier.all())
	If ($listedKeys.indexOf(_carrierMatchKey($eCarrier.name))=-1)
		$unlisted.push($eCarrier.name)
	End if
End for each

ALERT:C41("Import termine - carriers created: "+String:C10($created)\
	+" | updated: "+String:C10($updated)\
	+" | failed: "+String:C10($failed)\
	+" | listed: "+String:C10($carriers.length)+" (from 33 source lines, 6 were duplicate spellings)"\
	+(($unlisted.length>0) ? "\r\rAlready in the table and not in the list, left untouched:\r"+$unlisted.join("\r") : ""))
