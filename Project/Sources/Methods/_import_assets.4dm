//%attributes = {}
// _import_assets($options)
// The fixed assets from legacy, onto the Asset table: reads Project/imports/assets_export.json
// (legacy _export_assets, [Asset_List]). Matched on the asset number: an asset already here
// keeps its UUID (nothing is emptied), a missing one is created.
//
// For someone new to accounting: an asset (a tester, a vehicle...) is bought once and its cost
// is spread over its life ("depreciation", Phase 3 of the accounting). What has already been
// spread in legacy - the accumulated depreciation - and what is left - the book value - are
// kept in moreData.legacy, so the monthly depreciation of the new books continues from there
// and never counts a month twice. The totals of the accounts (cost, accumulated depreciation)
// are already in the opening entry.
//
// Set from legacy: number, type (created when missing), vendor (by name), description, cost,
// life, date acquired, scrapped / sold, divest date, excluded from depreciation.
// Re-runnable. Step of _import_accounting / _import_all. $options (optional): {unattended: True}.
#DECLARE($options : Object)

var $file : 4D.File
var $data; $row : Object
var $report; $problems : Collection
var $asset : cs.AssetEntity
var $type : cs.AssetTypeEntity
var $vendor : cs.SupplierEntity
var $created; $updated; $noVendor : Integer
var $cost; $accDep : Real
var $date : Date
var $save : Object

$file:=Folder(fk database folder).folder("Project/imports").file("assets_export.json")
If (Not($file.exists))
	_import_notify($options; "Import file not found: "+$file.platformPath+"\r\rRun _export_assets (or _export_accounting) in the legacy application and copy the file here.")
	return
End if
$data:=JSON Parse($file.getText())
$problems:=[]

ds.startTransaction()
For each ($row; $data.assets)
	$asset:=ds.Asset.query("assetNumber = :1"; Num($row.Asset_num)).first()
	If ($asset=Null)
		$asset:=ds.Asset.new()
		$asset.assetNumber:=Num($row.Asset_num)
		$created+=1
	Else
		$updated+=1
	End if

	// the type, created when missing (the list legacy used)
	$type:=Null
	If (cs.sfw_string.me.trimSpace(String($row.AssetType))#"")
		$type:=ds.AssetType.query("name = :1"; cs.sfw_string.me.trimSpace(String($row.AssetType))).first()
		If ($type=Null)
			$type:=ds.AssetType.new()
			$type.name:=cs.sfw_string.me.trimSpace(String($row.AssetType))
			$type.levelID:=Num(ds.AssetType.all().max("levelID"))+1
			$type.color:=""
			$type.save()
		End if
	End if
	$asset.UUID_AssetType:=($type=Null) ? ("0"*32) : $type.UUID

	$vendor:=Null
	If (cs.sfw_string.me.trimSpace(String($row.Vendor))#"")
		$vendor:=ds.Supplier.query("name = :1"; cs.sfw_string.me.trimSpace(String($row.Vendor))).first()
		If ($vendor=Null)
			$noVendor+=1
		End if
	End if
	$asset.UUID_Vendor:=($vendor=Null) ? ("0"*32) : $vendor.UUID

	$asset.description:=(String($row.Comments)#"") ? String($row.Comments) : String($row.Model)
	$asset.originalCost:=Num($row.Cost)
	$asset.life:=Num($row.Life)
	$date:=Date(String($row.Date_Acquired))
	$asset.acquiredStmp:=($date=!00-00-00!) ? 0 : cs.sfw_stmp.me.build($date; ?00:00:00?)
	$date:=Date(String($row.Divest_Date))
	If ($date=!00-00-00!)
		$date:=Date(String($row.Exit_Date))
	End if
	$asset.divestStmp:=($date=!00-00-00!) ? 0 : cs.sfw_stmp.me.build($date; ?00:00:00?)
	$asset.isScrapped:=Bool($row.Scrapped) || Bool($row.Sold)
	$asset.excludeFmDepreciationList:=Bool($row.ExcludeFmDepreciationList)
	$asset.moreData:=$asset.moreData || {}
	$asset.moreData.legacy:={\
		model: String($row.Model); \
		serialNumber: String($row.Serial_num); \
		glac: String($row.GLAC); \
		division: String($row.Division); \
		buyOrder: String($row.Buynum); \
		vendorInvoice: String($row.InvoiceNum); \
		vendorName: String($row.Vendor); \
		depreciationMethod: Bool($row.D_Method); \
		accumulatedDepreciation: Round(Num($row.Acc_dep); 2); \
		bookValue: Round(Num($row.Value); 2); \
		sold: Bool($row.Sold); \
		internalSale: Bool($row.Internal_sale); \
		saleInvoiceNumber: Num($row.SaleInvoiceNumber); \
		equipment: Bool($row.Equipment); \
		notAtSite: Bool($row.Not_at_site); \
		site: String($row.Site_name); \
		uniqueID: String($row.UniqueID); \
		figuresAsOf: String($data.exportedAt); \
		importedAt: cs.sfw_stmp.me.now()}
	$save:=$asset.save()
	If (Not($save.success))
		$problems.push("Asset "+String($row.Asset_num)+" could not be saved: "+String($save.statusText))
		continue
	End if
	$cost+=Num($row.Cost)
	$accDep+=Num($row.Acc_dep)
End for each
ds.validateTransaction()

$report:=[]
$report.push("ASSETS - "+String(Current date)+" "+String(Current time; HH MM))
$report.push("File: "+$file.platformPath+" (figures of legacy as of "+String($data.exportedAt)+")")
$report.push("Assets: "+String($created+$updated)+" ("+String($created)+" created, "+String($updated)+" updated) - vendor not found by name: "+String($noVendor))
$report.push("Cost "+String($cost; "###,###,##0.00")+" - accumulated depreciation "+String($accDep; "###,###,##0.00")+" - book value "+String($cost-$accDep; "###,###,##0.00"))
If ($problems.length>0)
	$report.push("")
	$report.combine($problems)
End if
$file.parent.file("assets_import.txt").setText($report.join("\r\n"))
_import_notify($options; $report.slice(2; 4).join("\r")+"\rReport: Project/imports/assets_import.txt")
