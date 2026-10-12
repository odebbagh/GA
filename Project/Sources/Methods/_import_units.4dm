//%attributes = {}
// Seeds the [Unit] lookup table with the units of measure used by the legacy
// application. The list is held here rather than in project/imports, because it is
// agreed reference data, not a dump.
//
// SOURCE
//   The 33 distinct Units values of the legacy [Buy Items] table. "(empty)" is not a
//   unit - it is the 2609 rows that had none - so it is not imported.
//
// DUPLICATES
//   32 real values collapse to 23 units. The spellings that were dropped are kept as
//   aliases on the surviving row, in moreData.aliases / moreData.aliasKeys, so the
//   legacy values still resolve:
//     Hour  <- Hrs, Hours, HR
//     Pack  <- PK, PKG
//     Year  <- YR, YRS          (YEAR folds onto it by case alone)
//     Spool <- Spools           (SPOOL folds by case)
//     Pail  <- Pails
//     Pcs   <- Pc.              (the period and the case both fold away)
//   Everything else differed only in case: GALLON, BOX, DAYS, LBS.
//   "Yearly" and "Daily" are kept separate on purpose: they are billing periods, not
//   quantities.
//
//   ADDED after the first _import_buyOrders run [2026-sep-26]: Pair and Daily as their
//   own rows, Pc. as an alias of Pcs. The run reported 10 buy lines whose unit had no
//   [Unit] row, across exactly those three spellings.
//
// _unitMatchKey does the folding; _import_buyOrders uses the same function, so a buy
// line whose legacy unit reads "PKG" ends up on "Pack".
//
// Rows are matched on the folded key and updated in place, never deleted or recreated,
// so anything already pointing at a [Unit] row keeps working. Rows already in the table
// that are not in the list below are left alone and listed in the report.

var $units : Collection
var $unit : Object
var $alias : Text
var $eUnit : cs:C1710.UnitEntity
var $existing : Object
var $key : Text
var $aliasKeys : Collection
var $result : Object
var $created : Integer
var $updated : Integer
var $failed : Integer
var $listedKeys : Collection
var $unlisted : Collection

$units:=New collection:C1472

$units.push(New object:C1471("name"; "Pcs"; \
	"aliases"; New collection:C1472("Pc.")))
$units.push(New object:C1471("name"; "EA"))
$units.push(New object:C1471("name"; "Lot"))
$units.push(New object:C1471("name"; "Set"))
$units.push(New object:C1471("name"; "Pair"))
$units.push(New object:C1471("name"; "CT"))

$units.push(New object:C1471("name"; "Bag"))
$units.push(New object:C1471("name"; "Box"))
$units.push(New object:C1471("name"; "Bottle"))
$units.push(New object:C1471("name"; "Can"))
$units.push(New object:C1471("name"; "Case"))
$units.push(New object:C1471("name"; "Pack"; \
	"aliases"; New collection:C1472("PK"; "PKG")))
$units.push(New object:C1471("name"; "Pail"; \
	"aliases"; New collection:C1472("Pails")))
$units.push(New object:C1471("name"; "Roll"))
$units.push(New object:C1471("name"; "Spool"; \
	"aliases"; New collection:C1472("Spools")))
$units.push(New object:C1471("name"; "Ream"))
$units.push(New object:C1471("name"; "Bars"))

$units.push(New object:C1471("name"; "Gallon"))
$units.push(New object:C1471("name"; "Lbs"))

$units.push(New object:C1471("name"; "Hour"; \
	"aliases"; New collection:C1472("Hrs"; "Hours"; "HR")))
$units.push(New object:C1471("name"; "Days"))
$units.push(New object:C1471("name"; "Months"))
$units.push(New object:C1471("name"; "Year"; \
	"aliases"; New collection:C1472("YR"; "YRS")))
$units.push(New object:C1471("name"; "Daily"))
$units.push(New object:C1471("name"; "Yearly"))

$created:=0
$updated:=0
$failed:=0
$listedKeys:=New collection:C1472

//---index what is already there by folded key, so a row spelt the legacy way is
//   recognised and renamed rather than duplicated
$existing:=New object:C1471
For each ($eUnit; ds:C1482.Unit.all())
	$key:=_unitMatchKey($eUnit.name)
	If ($key#"") && ($existing[$key]=Null:C1517)
		$existing[$key]:=$eUnit.UUID
	End if
End for each

For each ($unit; $units)

	$key:=_unitMatchKey($unit.name)
	$listedKeys.push($key)

	//the aliases resolve to this same row, folded so the legacy spellings can be
	//looked up directly
	$aliasKeys:=New collection:C1472
	If ($unit.aliases#Null:C1517)
		For each ($alias; $unit.aliases)
			$aliasKeys.push(_unitMatchKey($alias))
			$listedKeys.push(_unitMatchKey($alias))
		End for each
	End if

	If ($existing[$key]=Null:C1517)
		$eUnit:=ds:C1482.Unit.new()
		$eUnit.name:=$unit.name
	Else
		//keep the UUID anything already points at
		$eUnit:=ds:C1482.Unit.query("UUID = :1"; $existing[$key]).first()
		$eUnit.name:=$unit.name
	End if

	$eUnit.moreData:=($eUnit.moreData=Null:C1517) ? New object:C1471 : $eUnit.moreData
	$eUnit.moreData.seededBy:="_import_units"
	$eUnit.moreData.matchKey:=$key
	$eUnit.moreData.aliases:=($unit.aliases=Null:C1517) ? New collection:C1472 : $unit.aliases.copy()
	$eUnit.moreData.aliasKeys:=$aliasKeys

	$result:=$eUnit.save()
	Case of
		: (Not:C34($result.success))
			$failed:=$failed+1
		: ($existing[$key]=Null:C1517)
			$created:=$created+1
		Else
			$updated:=$updated+1
	End case

End for each

//---anything already in the table that the list does not cover. Left in place on
//   purpose: inventory records may point at it.
$unlisted:=New collection:C1472
For each ($eUnit; ds:C1482.Unit.all())
	If ($listedKeys.indexOf(_unitMatchKey($eUnit.name))=-1)
		$unlisted.push($eUnit.name)
	End if
End for each

ALERT:C41("Import termine - units created: "+String:C10($created)\
	+" | updated: "+String:C10($updated)\
	+" | failed: "+String:C10($failed)\
	+" | listed: "+String:C10($units.length)+" (from 32 source values, 9 were duplicate spellings)"\
	+(($unlisted.length>0) ? "\r\rAlready in the table and not in the list, left untouched:\r"+$unlisted.join("\r") : ""))
