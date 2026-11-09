//%attributes = {}
// _demo_priceListData
// Test data for the master price list until Golden Altos sends theirs:
// - the flows (PriceFlow), created only when there is none: COM (default), MIL, SPACE, CLASSS, ENV,
//   with the legacy process-qualifier texts as aliases. These are kept: they are not test data.
// - about ten general prices on the first operation processes found, with MIL and SPACE prices and
//   one engineering hour (not a process). Made-up amounts, marked moreData.demo.
// Run it again: the demo prices are removed and created again. "Remove" removes them only.

var $answer : Integer
var $flows : Object
var $processNames; $rows : Collection
var $name : Text
var $i : Integer
var $process : cs:C1710.StepProcessEntity
var $e : cs:C1710.PriceListItemEntity
var $flow : cs:C1710.PriceFlowEntity
var $base : Real
var $flowDef : Object

$answer:=Num:C11(cs:C1710.sfw_dialog.me.confirm("Create the demo prices of the Master Price List?\r(made-up amounts; the demo prices already there are replaced)"; "Create"; "Remove"))

// the demo prices of a previous run
ds:C1482.PriceListItem.query("moreData.demo = :1"; True:C214).drop()
If ($answer=0)
	cs:C1710.sfw_dialog.me.info("Demo prices removed.")
	return
End if

// the flows, once
If (ds:C1482.PriceFlow.all().length=0)
	For each ($flowDef; New collection:C1472(\
		New object:C1471("code"; "COM"; "name"; "Commercial"; "levelID"; 10; "isDefault"; True:C214; "aliases"; New collection:C1472("Commercial"; "NAP")); \
		New object:C1471("code"; "MIL"; "name"; "Military (MIL-STD-883 Class B)"; "levelID"; 20; "isDefault"; False:C215; "aliases"; New collection:C1472("MIL-STD-883"; "MIL-STD-750"; "MIL-STD-202"; "Class B_Q"; "Military")); \
		New object:C1471("code"; "SPACE"; "name"; "Space"; "levelID"; 30; "isDefault"; False:C215; "aliases"; New collection:C1472("Space"; "Space level")); \
		New object:C1471("code"; "CLASSS"; "name"; "Class S"; "levelID"; 40; "isDefault"; False:C215; "aliases"; New collection:C1472("Class S_V"; "Class S"; "Class V")); \
		New object:C1471("code"; "ENV"; "name"; "Environmental"; "levelID"; 50; "isDefault"; False:C215; "aliases"; New collection:C1472("Environmental"))))
		$flow:=ds:C1482.PriceFlow.new()
		$flow.code:=$flowDef.code
		$flow.name:=$flowDef.name
		$flow.levelID:=$flowDef.levelID
		$flow.isDefault:=$flowDef.isDefault
		$flow.moreData:=New object:C1471("aliases"; $flowDef.aliases)
		$flow.save()
	End for each
End if
$flows:=New object:C1471
For each ($name; New collection:C1472("MIL"; "SPACE"))
	$flows[$name]:=ds:C1482.PriceFlow.query("code = :1"; $name).first()
End for each

// ten processes: the usual screening steps when they exist, else the first ones by name
$processNames:=New collection:C1472("Burn In"; "Electrical Test"; "Fine Leak"; "Gross Leak"; "PIND"; "Temp Cycle"; "Centrifuge"; "Marking"; "Incoming QC"; "Outgoing QC")
$rows:=New collection:C1472
For each ($name; $processNames)
	$process:=ds:C1482.StepProcess.query("name = :1"; $name+"@").first()
	If ($process#Null:C1517)
		$rows.push($process)
	End if
End for each
If ($rows.length<10)
	For each ($process; ds:C1482.StepProcess.all().orderBy("name asc"))
		If ($rows.length>=10)
			break
		End if
		If ($rows.extract("UUID").indexOf($process.UUID)<0)
			$rows.push($process)
		End if
	End for each
End if

$i:=0
For each ($process; $rows)
	$i+=1
	$base:=0.5*$i
	$e:=ds:C1482.PriceListItem.new()
	$e.code:="DEMO-"+String:C10($i; "00")
	$e.description:=$process.name
	$e.UUID_StepProcess:=$process.UUID
	$e.UUID_Customer:="0"*32
	$e.unit:="unit"
	$e.unitPrice:=$base
	$e.unitCost:=Round:C94($base*0.6; 2)
	$e.minLotCharge:=150+(50*$i)
	$e.stmpEffectiveFrom:=cs:C1710.sfw_stmp.me.build(!2026-01-01!; ?00:00:00?)
	$e.active:=True:C214
	$e.currency:="USD"
	$e.flowPrices:=New object:C1471("rows"; New collection:C1472)
	If ($flows.MIL#Null:C1517)
		$e.flowPrices.rows.push(New object:C1471("UUID_PriceFlow"; $flows.MIL.UUID; "flowCode"; "MIL"; "unitPrice"; Round:C94($base*1.3; 2); "unitCost"; Round:C94($base*0.7; 2)))
	End if
	If ($flows.SPACE#Null:C1517)
		$e.flowPrices.rows.push(New object:C1471("UUID_PriceFlow"; $flows.SPACE.UUID; "flowCode"; "SPACE"; "unitPrice"; Round:C94($base*1.8; 2); "unitCost"; Round:C94($base*0.9; 2)))
	End if
	$e.moreData:=New object:C1471("demo"; True:C214)
	$e.save()
End for each

// a charge that is not a process
$e:=ds:C1482.PriceListItem.new()
$e.code:="DEMO-ENG-HR"
$e.description:="Engineering hour"
$e.UUID_StepProcess:="0"*32
$e.UUID_Customer:="0"*32
$e.unit:="hour"
$e.unitPrice:=185
$e.unitCost:=95
$e.stmpEffectiveFrom:=cs:C1710.sfw_stmp.me.build(!2026-01-01!; ?00:00:00?)
$e.active:=True:C214
$e.currency:="USD"
$e.flowPrices:=New object:C1471("rows"; New collection:C1472)
$e.moreData:=New object:C1471("demo"; True:C214)
$e.save()

cs:C1710.sfw_dialog.me.info(String:C10($rows.length+1)+" demo prices created (codes DEMO-...).\rAdministration > Quote P. > Master Price List")
