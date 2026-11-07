//%attributes = {}
// _diag_priceList
// Read-only check of the master price list (PriceListItem, PriceFlow). Writes
// Project/imports/price_list_diag.txt:
// - the operation processes with no price valid today
// - the prices with a warning (below cost, end before start, overlapping periods)
// - the flows that no price uses, and the default flow
// Changes nothing.

var $lines; $noPrice; $warned; $unused : Collection
var $process : cs:C1710.StepProcessEntity
var $item : cs:C1710.PriceListItemEntity
var $flow : cs:C1710.PriceFlowEntity
var $warning : Text
var $used : Object
var $row : Object
var $default : cs:C1710.PriceFlowEntity

$noPrice:=New collection:C1472
For each ($process; ds:C1482.StepProcess.all().orderBy("name asc"))
	If (ds:C1482.PriceListItem.validOn(Current date:C33; $process.UUID; "0"*32).length=0)
		$noPrice.push($process.name)
	End if
End for each

$warned:=New collection:C1472
$used:=New object:C1471
For each ($item; ds:C1482.PriceListItem.all().orderBy("code asc, stmpEffectiveFrom asc"))
	For each ($warning; $item.warnings)
		$warned.push($item.code+" ("+$item.customerName+" "+$item.effectiveFromText+"): "+$warning)
	End for each
	If ($item.flowPrices#Null:C1517) && (Value type:C1509($item.flowPrices.rows)=Is collection:K8:32)
		For each ($row; $item.flowPrices.rows)
			$used[String:C10($row.UUID_PriceFlow)]:=True:C214
		End for each
	End if
End for each

$unused:=New collection:C1472
For each ($flow; ds:C1482.PriceFlow.all().orderBy("levelID asc"))
	If ($used[$flow.UUID]=Null:C1517) && Not:C34($flow.isDefault)
		$unused.push($flow.code+" - "+$flow.name)
	End if
End for each
$default:=ds:C1482.PriceFlow.defaultFlow()

$lines:=New collection:C1472("_diag_priceList - "+String:C10(Current date:C33; ISO date:K1:8)+" "+String:C10(Current time:C178); \
String:C10(ds:C1482.PriceListItem.all().length)+" prices, "+String:C10(ds:C1482.PriceListItem.query("active = :1"; True:C214).length)+" active; "+String:C10(ds:C1482.PriceFlow.all().length)+" flows, default: "+(($default=Null:C1517) ? "none" : $default.code); \
""; "== Operation processes with no general price valid today ("+String:C10($noPrice.length)+")").combine($noPrice)\
.combine(New collection:C1472(""; "== Prices with a warning ("+String:C10($warned.length)+")")).combine($warned)\
.combine(New collection:C1472(""; "== Flows used by no price (they take the base price) ("+String:C10($unused.length)+")")).combine($unused)
Folder:C1567(fk database folder:K87:14).folder("Project/imports").file("price_list_diag.txt").setText($lines.join("\r\n"))

cs:C1710.sfw_dialog.me.info(String:C10($noPrice.length)+" processes without a price, "+String:C10($warned.length)+" warnings.\rDetails in Project/imports/price_list_diag.txt")
