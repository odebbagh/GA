//%attributes = {}
// _import_priceList
// Loads the client's master price list into PriceListItem (Administration > Master Price List).
// Reads Project/imports/price_list.json (an array of objects) or, when absent, price_list.csv
// (UTF-8, comma separated, a header row, quotes allowed). One row per item and flow:
//   code,description,process,flow,customer,unit,unitPrice,unitCost,minLotCharge,effectiveFrom,effectiveTo,notes
// - empty flow: the base price, cost and minimum lot charge of the item; a flow (PriceFlow code,
//   name or alias): the price and cost of that flow (flowPrices)
// - process: StepProcess.name (case and spaces ignored), empty for a charge that is not a process
// - customer: Customer.code, empty for the general price; dates ISO (2026-11-01), empty = open
// An item is (code, customer, effectiveFrom): found again it is updated, and its flow prices are
// replaced by those of the file. Safe to run again.
// Asks first: "Report only" changes nothing; "Apply" saves. Both write
// Project/imports/price_list_import.txt (rows created / updated, names not found, price below cost).
// Saves without the sfw callbacks: PriceListItemEntity.normalize() is called here.

var $folder : 4D:C1709.Folder
var $file : 4D:C1709.File
var $rows; $report; $notFound; $belowCost; $failed : Collection
var $row; $group; $groups; $processes; $count; $flowRow; $result : Object
var $key; $name; $flowText; $source; $warning : Text
var $apply : Boolean
var $e : cs:C1710.PriceListItemEntity
var $process : cs:C1710.StepProcessEntity
var $customer : cs:C1710.CustomerEntity
var $flow : cs:C1710.PriceFlowEntity
var $from : Date
var $stmpFrom : Integer

$folder:=Folder:C1567(fk database folder:K87:14).folder("Project/imports")
$file:=$folder.file("price_list.json")
If (Not:C34($file.exists))
	$file:=$folder.file("price_list.csv")
End if
If (Not:C34($file.exists))
	cs:C1710.sfw_dialog.me.alert("Put the price list in Project/imports as price_list.csv or price_list.json first.")
	return
End if

$apply:=cs:C1710.sfw_dialog.me.confirm("Import the master price list from "+$file.fullName+"?\r\r"+\
"Report only: writes Project/imports/price_list_import.txt and changes nothing.\r"+\
"Apply: does the same and saves the prices."; "Apply"; "Report only")

// the rows of the file, as objects with the header names
If ($file.extension=".json")
	$rows:=JSON Parse:C1218($file.getText("UTF-8"))
Else
	$rows:=_import_priceListCsv($file.getText("UTF-8"))
End if

// the processes by name, without case nor spaces
$processes:=New object:C1471
For each ($process; ds:C1482.StepProcess.all())
	$processes[Uppercase:C13(Replace string:C233($process.name; " "; ""))]:=$process.UUID
End for each

// the rows grouped by item: code + customer + start date
$report:=New collection:C1472
$notFound:=New collection:C1472
$belowCost:=New collection:C1472
$failed:=New collection:C1472
$count:=New object:C1471("rows"; $rows.length; "created"; 0; "updated"; 0; "skipped"; 0)
$groups:=New object:C1471
For each ($row; $rows)
	$row.code:=Uppercase:C13(cs:C1710.sfw_string.me.trimSpace(String:C10($row.code)))
	If ($row.code="")
		$count.skipped+=1
		$notFound.push("row without code skipped: "+JSON Stringify:C1217($row))
		continue
	End if
	$key:=$row.code+"|"+Uppercase:C13(cs:C1710.sfw_string.me.trimSpace(String:C10($row.customer)))+"|"+cs:C1710.sfw_string.me.trimSpace(String:C10($row.effectiveFrom))
	If ($groups[$key]=Null:C1517)
		$groups[$key]:=New object:C1471("base"; Null:C1517; "flows"; New collection:C1472; "first"; $row)
	End if
	If (cs:C1710.sfw_string.me.trimSpace(String:C10($row.flow))="")
		$groups[$key].base:=$row
	Else
		$groups[$key].flows.push($row)
	End if
End for each

For each ($key; OB Keys:C1719($groups))
	$group:=$groups[$key]
	$row:=($group.base#Null:C1517) ? $group.base : $group.first

	// customer
	$customer:=Null:C1517
	$name:=cs:C1710.sfw_string.me.trimSpace(String:C10($row.customer))
	If ($name#"")
		$customer:=ds:C1482.Customer.query("code = :1"; $name).first()
		If ($customer=Null:C1517)
			$notFound.push($row.code+": customer \""+$name+"\" not found, row skipped")
			$count.skipped+=1
			continue
		End if
	End if
	$from:=_import_priceListDate(String:C10($row.effectiveFrom))
	$stmpFrom:=($from=!00-00-00!) ? 0 : cs:C1710.sfw_stmp.me.build($from; ?00:00:00?)

	$e:=ds:C1482.PriceListItem.query("code = :1 and UUID_Customer = :2 and stmpEffectiveFrom = :3"; $row.code; ($customer=Null:C1517) ? "0"*32 : $customer.UUID; $stmpFrom).first()
	If ($e=Null:C1517)
		$e:=ds:C1482.PriceListItem.new()
		$e.code:=$row.code
		$e.UUID_Customer:=($customer=Null:C1517) ? "0"*32 : $customer.UUID
		$e.stmpEffectiveFrom:=$stmpFrom
		$e.active:=True:C214
		$e.currency:="USD"
		$source:="created"
	Else
		$source:="updated"
	End if

	// process
	$name:=cs:C1710.sfw_string.me.trimSpace(String:C10($row.process))
	If ($name="")
		$e.UUID_StepProcess:="0"*32
	Else
		If ($processes[Uppercase:C13(Replace string:C233($name; " "; ""))]=Null:C1517)
			$notFound.push($row.code+": process \""+$name+"\" not found (kept as a charge that is not a process)")
			$e.UUID_StepProcess:="0"*32
		Else
			$e.UUID_StepProcess:=$processes[Uppercase:C13(Replace string:C233($name; " "; ""))]
		End if
	End if

	If (cs:C1710.sfw_string.me.trimSpace(String:C10($row.description))#"")
		$e.description:=cs:C1710.sfw_string.me.trimSpace(String:C10($row.description))
	End if
	If ($e.description="")
		$e.description:=($name="") ? $row.code : $name
	End if
	If (cs:C1710.sfw_string.me.trimSpace(String:C10($row.unit))#"")
		$e.unit:=Lowercase:C14(cs:C1710.sfw_string.me.trimSpace(String:C10($row.unit)))
	End if
	If ($group.base#Null:C1517)
		$e.unitPrice:=_import_priceListNum($row.unitPrice)
		$e.unitCost:=_import_priceListNum($row.unitCost)
		$e.minLotCharge:=_import_priceListNum($row.minLotCharge)
	End if
	$e.effectiveTo:=_import_priceListDate(String:C10($row.effectiveTo))

	// the flow prices of the file replace those of the item
	$e.flowPrices:=New object:C1471("rows"; New collection:C1472)
	For each ($flowRow; $group.flows)
		$flowText:=cs:C1710.sfw_string.me.trimSpace(String:C10($flowRow.flow))
		$flow:=ds:C1482.PriceFlow.fromText($flowText)
		If ($flow=Null:C1517)
			$notFound.push($row.code+": flow \""+$flowText+"\" not found (add it in Administration > Price flows), price ignored")
		Else
			$e.flowPrices.rows.push(New object:C1471("UUID_PriceFlow"; $flow.UUID; "flowCode"; $flow.code; "unitPrice"; _import_priceListNum($flowRow.unitPrice); "unitCost"; _import_priceListNum($flowRow.unitCost)))
			If ($flow.code#"") && (cs:C1710.sfw_string.me.trimSpace(String:C10($flowRow.minLotCharge))#"") && (_import_priceListNum($flowRow.minLotCharge)#$e.minLotCharge)
				$notFound.push($row.code+": a minimum lot charge on the "+$flow.code+" row is ignored (it is the same for every flow)")
			End if
		End if
	End for each
	If ($group.base=Null:C1517)
		$notFound.push($row.code+": no row without flow, so no base price nor minimum lot charge")
	End if

	$e.moreData:=(($e.moreData=Null:C1517) ? New object:C1471 : OB Copy:C1225($e.moreData))
	$e.moreData.importRef:=New object:C1471("file"; $file.fullName; "date"; String:C10(Current date:C33; ISO date:K1:8); "notes"; String:C10($row.notes))
	$e.normalize()
	For each ($warning; $e.warnings)
		$belowCost.push($e.code+": "+$warning)
	End for each

	If ($apply)
		$result:=$e.save()
		If (Not:C34($result.success))
			$failed.push($row.code+": "+String:C10($result.statusText))
			continue
		End if
	End if
	$count[$source]+=1
	$report.push($source+"  "+$e.code+"  "+$e.description+"  "+String:C10($e.unitPrice; "###,###,##0.00##")+" / min "+String:C10($e.minLotCharge; "###,###,##0.00")+"  flows: "+$e.flowPricesText)
End for each

$report:=New collection:C1472("_import_priceList - "+String:C10(Current date:C33; ISO date:K1:8)+" "+String:C10(Current time:C178)+" - "+($apply ? "APPLIED" : "REPORT ONLY (nothing saved)"); \
"File: "+$file.path; \
String:C10($count.rows)+" rows read, "+String:C10($count.created)+" prices "+($apply ? "created" : "to create")+", "+String:C10($count.updated)+" "+($apply ? "updated" : "to update")+", "+String:C10($count.skipped)+" skipped"; \
""; "== Not found / ignored ("+String:C10($notFound.length)+")").combine($notFound)\
.combine(New collection:C1472(""; "== Warnings ("+String:C10($belowCost.length)+")")).combine($belowCost)\
.combine(New collection:C1472(""; "== Not saved ("+String:C10($failed.length)+")")).combine($failed)\
.combine(New collection:C1472(""; "== Prices")).combine($report)
$folder.file("price_list_import.txt").setText($report.join("\r\n"))

cs:C1710.sfw_dialog.me.info(String:C10($count.created)+" prices "+($apply ? "created" : "to create")+", "+String:C10($count.updated)+" "+($apply ? "updated" : "to update")+", "+String:C10($notFound.length)+" names not found.\rDetails in Project/imports/price_list_import.txt")
