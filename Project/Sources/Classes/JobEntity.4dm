Class extends Entity


local Function get nameInWindowTitle()->$nameInWindowTitle : Text
	$nameInWindowTitle:=String:C10(This:C1470.jobNumber)
	
	
	//Mark:- Jobs & Deliveries (Lead page 3)
	// One definition of a job's figures, as the legacy app had them: per lot (Lotinfo trigger,
	// UpdateJobQtys, OntimeShipment), rolled up to the job, and from the job's own stamps for the
	// imported jobs whose lots were not imported. Dates are Dates (00-00-00 when unknown).

Function get quoteCode()->$code : Text
	// the quote of the job's purchase order: the linked quote, else the legacy "our quote" text
	var $po : cs:C1710.PurchaseOrderEntity
	$po:=This:C1470.purchaseOrderOrLine()
	If ($po#Null:C1517)
		$code:=String:C10($po.quote.code)
		If ($code="") && (Position:C15("|"+Lowercase:C14(String:C10($po.ourQuote))+"|"; "|none|na|n/a|")=0)
			$code:=String:C10($po.ourQuote)
		End if
	End if

Function get poLabel()->$label : Text
	var $po : cs:C1710.PurchaseOrderEntity
	$po:=This:C1470.purchaseOrderOrLine()
	$label:=($po#Null:C1517) ? String:C10($po.poNum) : ""
	If ($label="") && (Num:C11(This:C1470.poNumber)#0)
		$label:=String:C10(This:C1470.poNumber)  // imported jobs whose PO was not imported
	End if

Function purchaseOrderOrLine()->$po : cs:C1710.PurchaseOrderEntity
	// the job's PO, or the PO of a line released to it (new jobs are linked one way or the other)
	$po:=This:C1470.purchaseOrder
	If ($po=Null:C1517) && (This:C1470.purchaseOrderLines.length>0)
		$po:=This:C1470.purchaseOrderLines.first().purchaseOrder
	End if

Function liveLots()->$lots : cs:C1710.LotSelection
	// the lots that count for the job's dates: not the ones merged into another lot
	$lots:=This:C1470.lots.query("location # :1"; "merged")

Function get dueDate()->$date : Date
	// the date promised to the customer: the latest commit / recommit of its lots (the legacy job
	// roll-up), else the imported job's expected date, else the latest date asked on its PO lines
	var $lot : cs:C1710.LotEntity
	For each ($lot; This:C1470.liveLots())
		If ($lot.reCommit>$date)
			$date:=$lot.reCommit
		End if
		If ($lot.commit>$date)
			$date:=$lot.commit
		End if
	End for each
	If ($date=!00-00-00!)
		$date:=This:C1470.expectedDate
	End if
	If ($date=!00-00-00!) && (This:C1470.purchaseOrderLines.length>0)
		$date:=This:C1470.purchaseOrderLines.max("customerRequestedDate")
	End if

Function get deliveryDate()->$date : Date
	// shipped once every lot has a date out: the last of them (a partly shipped job is not
	// delivered yet); a job without lots: its imported last ship date
	var $lots : cs:C1710.LotSelection
	$lots:=This:C1470.liveLots()
	Case of
		: ($lots.length=0)
			$date:=This:C1470.lastShipDate
		: ($lots.query("dateOut = :1"; !00-00-00!).length=0)
			$date:=$lots.max("dateOut")
	End case

Function get daysLate()->$days : Integer
	$days:=This:C1470._daysLate(This:C1470.dueDate; This:C1470.deliveryDate)

Function get timing()->$timing : Text
	$timing:=This:C1470._timing(This:C1470.dueDate; This:C1470.deliveryDate)

Function get statusLabel()->$status : Text
	$status:=This:C1470._status(This:C1470.deliveryDate)

	// the "To Ship" view of Jobs (Job.entryDefinition): the due date as text, and a number to sort
	// it on (a text date sorts day first), the jobs without one last
Function get dueDateText()->$text : Text
	var $date : Date
	$date:=This:C1470.dueDate
	$text:=($date=!00-00-00!) ? "" : String:C10($date)

Function get dueDateKey()->$key : Integer
	var $date : Date
	$date:=This:C1470.dueDate
	$key:=($date=!00-00-00!) ? 99999999 : (Year of:C25($date)*10000)+(Month of:C24($date)*100)+Day of:C23($date)

	// its metaExpression: the timing in red once the due date is gone
local Function toShipMeta()->$meta : Object
	$meta:=New object:C1471("cell"; New object:C1471)
	If (This:C1470.daysLate>0)
		If (Form:C1466.current_lb_item=Null:C1517) || (Form:C1466.current_lb_item.UUID#This:C1470.UUID)
			$meta.cell.columnTiming:=New object:C1471("stroke"; "#C0392B")
		End if
	End if

Function _daysLate($due : Date; $delivered : Date)->$days : Integer
	// days past the due date: delivered after it, or not delivered and the due date is gone
	If ($due#!00-00-00!)
		$days:=(($delivered#!00-00-00!) ? $delivered : Current date:C33)-$due
		If ($days<0)
			$days:=0
		End if
	End if

Function _timing($due : Date; $delivered : Date)->$timing : Text
	// the legacy rule: shipped on or before the due date is on time
	var $days : Integer
	$days:=This:C1470._daysLate($due; $delivered)
	Case of
		: ($due=!00-00-00!)
			$timing:="No due date"
		: ($delivered#!00-00-00!)
			$timing:=($days>0) ? "Late "+String:C10($days)+" d" : "On time"
		: ($days>0)
			$timing:="Late, not shipped ("+String:C10($days)+" d)"
		Else
			$timing:="On track"
	End case

Function _status($delivered : Date)->$status : Text
	var $lots : cs:C1710.LotSelection
	$lots:=This:C1470.liveLots()
	Case of
		: (This:C1470.archived)
			$status:="Archived"
		: (This:C1470.stmpInvoiced>0) || (This:C1470.invoices.query("invoiceStmp > 0").length>0)
			$status:="Invoiced"
		: (This:C1470.shipped) || ($delivered#!00-00-00!)
			$status:="Shipped"
		: ($lots.query("onHold = :1"; True:C214).length>0)
			$status:="On hold"
		: ($lots.query("dateIn # :1"; !00-00-00!).length>0)
			$status:="In WIP"
		Else
			$status:="Not released"
	End case

Function jobsRow()->$row : Object
	// one row of the Jobs & Deliveries list (panel_lead), each figure worked out once
	var $date : Date
	$row:=New object:C1471("UUID"; This:C1470.UUID; "jobNumber"; This:C1470.jobNumber; "quote"; This:C1470.quoteCode; \
		"po"; This:C1470.poLabel; "due"; This:C1470.dueDate; "delivered"; This:C1470.deliveryDate; \
		"location"; This:C1470.locationLabel; "process"; String:C10(This:C1470.process))
	$row.daysLate:=This:C1470._daysLate($row.due; $row.delivered)
	$row.timing:=This:C1470._timing($row.due; $row.delivered)
	$row.status:=This:C1470._status($row.delivered)
	$row.reasons:=This:C1470.lots.query("latePareto # :1"; "").distinct("latePareto").join(", ")
	If ($row.reasons="") && ($row.daysLate>0)
		$row.reasons:=String:C10(This:C1470.jobComment)
	End if
	// what the filters use, as numbers (a Date kept in an object can become text): delivered or
	// not, and the date (delivered, else due) as yyyymmdd, 0 when unknown
	$row.dueText:=($row.due=!00-00-00!) ? "" : String:C10($row.due)
	$row.deliveredText:=($row.delivered=!00-00-00!) ? "" : String:C10($row.delivered)
	$row.isDelivered:=($row.delivered#!00-00-00!)
	$date:=$row.isDelivered ? $row.delivered : $row.due
	$row.refKey:=($date=!00-00-00!) ? 0 : (Year of:C25($date)*10000)+(Month of:C24($date)*100)+Day of:C23($date)
	// late rows in red in the list (its metaSource)
	$row.meta:=($row.daysLate>0) ? New object:C1471("stroke"; "#C0392B") : New object:C1471
	// the money columns (see "Job costs" below); texts empty when there is no cost to show
	$row.price:=Num:C11(This:C1470.totalCharge)
	$row.subcon:=This:C1470.subconCost
	$row.actual:=$row.subcon+This:C1470.materialCost
	$row.markup:=$row.price-$row.actual
	$row.subconText:=($row.subcon=0) ? "" : _ga_usdText($row.subcon)
	$row.actualText:=($row.actual=0) ? "" : _ga_usdText($row.actual)
	$row.markupText:=($row.actual=0) ? "" : _ga_usdText($row.markup)
	$row.markupPCText:=($row.actual=0) ? "" : String:C10(Round:C94($row.markup/$row.actual*100; 1))+"%"

	//Mark:- Job costs
	// As the legacy app had them (SubrSetJobCosts): the direct cost is the job's purchase lines
	// (subcontracting included: AutoBuyItem creates a BUY_ITEMS line with the job number), the
	// inventory cost the materials pulled for it. No markup was stored: it is the job's charge
	// minus those costs. Imported jobs without lines or pulls keep their imported figures.

	// what was bought for the job: its buying order lines, else the imported Direct_Cost
Function get subconCost()->$cost : Real
	If (This:C1470.buyingOrderLines.length>0)
		$cost:=This:C1470.buyingOrderLines.sum("lineTotal")
	Else
		$cost:=Num:C11(This:C1470.directCost)
	End if

	// the materials pulled for the job (ga_stock: cost = qty x unit cost, put backs deducted),
	// else the imported Inventory_Cost
Function get materialCost()->$cost : Real
	var $pulls : cs:C1710.InventoryPullSelection
	// a job without a number (0) would take every pull made for no job
	$pulls:=(Num:C11(This:C1470.jobNumber)=0) ? ds:C1482.InventoryPull.newSelection() : ds:C1482.InventoryPull.query("jobNumber = :1"; This:C1470.jobNumber)
	If ($pulls.length>0)
		$cost:=$pulls.query("type = :1"; "Pull").sum("cost")-$pulls.query("type = :1"; "Put Back").sum("cost")
	Else
		$cost:=Num:C11(This:C1470.inventoryCost)
	End if

Function get actualCost()->$cost : Real
	$cost:=This:C1470.subconCost+This:C1470.materialCost

	// the charge minus the actual cost; 0 when there is no cost
Function get markup()->$markup : Real
	var $cost : Real
	$cost:=This:C1470.actualCost
	$markup:=($cost=0) ? 0 : Num:C11(This:C1470.totalCharge)-$cost

Function get locationLabel()->$location : Text
	// where its lots are: each lot not shipped yet, at its current traveller step
	var $lot : cs:C1710.LotEntity
	var $parts : Collection
	$parts:=New collection:C1472
	For each ($lot; This:C1470.liveLots().query("dateOut = :1"; !00-00-00!))
		$parts.push($lot.locationLabel)
	End for each
	$location:=$parts.join(" · "; ck ignore null or empty:K85:5)

Function get delayReasons()->$reasons : Text
	// the late pareto codes of its lots; for a late job without one, the job comment
	$reasons:=This:C1470.lots.query("latePareto # :1"; "").distinct("latePareto").join(", ")
	If ($reasons="") && (This:C1470.daysLate>0)
		$reasons:=String:C10(This:C1470.jobComment)
	End if

Function get jobType()->$jobType : Text
	$jobType:=This:C1470.lineItem=False:C215 ? "Job Order" : "NR Job Order"
	
	
local Function get dateCreated()->$date : Date
	$date:=This:C1470.stmpCreated=0 ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate(This:C1470.stmpCreated; True:C214)
	
local Function set dateCreated($date : Date)
	This:C1470.stmpCreated:=$date=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build($date)
	
local Function get expectedDate()->$date : Date
	$date:=This:C1470.stmpExpected=0 ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate(This:C1470.stmpExpected; True:C214)
	
local Function set expectedDate($date : Date)
	This:C1470.stmpExpected:=$date=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build($date)
	
local Function get invoiceDate()->$date : Date
	$date:=This:C1470.stmpInvoiced=0 ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate(This:C1470.stmpInvoiced; True:C214)
	
local Function set invoiceDate($date : Date)
	This:C1470.stmpInvoiced:=$date=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build($date)
	
local Function get lastShipDate()->$date : Date
	$date:=This:C1470.stmpLastShipped=0 ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate(This:C1470.stmpLastShipped; True:C214)
	
local Function set lastShipDate($date : Date)
	This:C1470.stmpLastShipped:=$date=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build($date)
	
local Function get archivedDate()->$date : Date
	$date:=This:C1470.stmpArchived=0 ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate(This:C1470.stmpArchived; True:C214)
	
local Function set archivedDate($date : Date)
	This:C1470.stmpArchived:=$date=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build($date)
	
	
local Function drowPup($dataClass; $queryField; $queryValue; $pupName)
	
	$entity:=ds:C1482[$dataClass].query($queryField+" =:1"; Form:C1466.current_item[$queryValue]).first() || New object:C1471()
	$name:=$entity.name
	If ($name=Null:C1517)
		$name:=""
	End if 
	If (Not:C34(Undefined:C82($entity.color)))
		$color:=cs:C1710.sfw_htmlColor.me.getName($entity.color)
		$pathIcon:=($color#"") ? "sfw/colors/"+$color+"-circle.png" : "sfw/image/skin/rainbow/icon/spacer-1x24.png"
	Else 
		$pathIcon:=""
	End if 
	Form:C1466.sfw.drawButtonPup($pupName; $name; $pathIcon; ($entity=Null:C1517))
	
	
local Function pup($cacheCollection; $dataClass; $queryField; $queryValue)
	
	If (Form:C1466.sfw.checkIsInModification())
		$menu:=Create menu:C408
		If (Storage:C1525.cache=Null:C1517) || (Storage:C1525.cache[$cacheCollection]=Null:C1517)
			ds:C1482[$dataClass].cacheLoad()
		End if 
		
		For each ($eEntity; Storage:C1525.cache[$cacheCollection])
			APPEND MENU ITEM:C411($menu; $eEntity.name; *)
			SET MENU ITEM PARAMETER:C1004($menu; -1; $eEntity.UUID)
			If ($queryField="UUID")  //# TO BE REMOVED
				
				If ($eEntity[$queryField]=Form:C1466.current_item[$queryValue])
					SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
					If (Is Windows:C1573)
						SET MENU ITEM STYLE:C425($menu; -1; Bold:K14:2)
					End if 
				End if 
			Else 
				
				If (Num:C11($eEntity[$queryField])=Form:C1466.current_item[$queryValue])
					SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
					If (Is Windows:C1573)
						SET MENU ITEM STYLE:C425($menu; -1; Bold:K14:2)
					End if 
				End if 
				
			End if 
			
		End for each 
		$choose:=Dynamic pop up menu:C1006($menu)
		RELEASE MENU:C978($menu)
		
		Case of 
			: ($choose#"")
				$eEntity:=ds:C1482[$dataClass].get($choose)
				Form:C1466.current_item[$queryValue]:=$eEntity[$queryField]
		End case 
		
	End if 
	
local Function loadAfterCreation()
	// This callback is called after creating the new item but before displaying the panel.
	If (This:C1470.jobNumber=0)
		This:C1470.jobNumber:=Sequence number:C244([Job:117])  // the table's counter: never given twice, even to two users creating jobs at once ("highest + 1" was)
		This:C1470.address:=New object:C1471("addresses"; New collection:C1472())
		
		This:C1470.address.addresses.push(New object:C1471(\
			"type"; "billing"; \
			"detail"; New object:C1471("city"; ""; "country"; ""; "iso_code_2"; ""; "postcode"; ""; "state"; ""; "street_1"; ""; "street_2"; "")\
			))
		This:C1470.address.addresses.push(New object:C1471(\
			"type"; "shipping"; \
			"detail"; New object:C1471("city"; ""; "country"; ""; "iso_code_2"; ""; "postcode"; ""; "state"; ""; "street_1"; ""; "street_2"; "")\
			))
	End if 
	
	This:C1470.dateCreated:=Current date:C33(*)  //cs.sfw_stmp.me.now()
	
	
local Function rebuildAddress()->$address : Object
	Case of 
		: (Form:C1466.addressBilling=1)
			$type:="billing"
		: (Form:C1466.addressShipping=1)
			$type:="shipping"
	End case 
	
	If (This:C1470.address.addresses#Null:C1517)
		$address:=This:C1470.address.addresses.query("type = :1"; $type).first()
		Form:C1466.subFormAddress.address:=$address
	End if 
	Form:C1466.subFormAddress:=Form:C1466.subFormAddress