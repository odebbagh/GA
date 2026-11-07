Class extends DataClass

local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	$entry:=cs:C1710.sfw_definitionEntry.new("jobs"; ["customerService"]; "Jobs"; "Job")
	$entry.setDataclass("Job")
	$entry.setDisplayOrder(-200)
	$entry.setIcon("image/entry/jobs-white-50x50.png")
	
	$entry.setSearchboxField("jobNumber")
	
	$entry.setPanel("panel_job"; 1)
	$entry.setPanelPage(1; "po-infos-32x32.png"; "Main")
	// Addresses are now shown in their own section on the Main page, so this tab is
	// disabled (kept in place to preserve the page numbering of the following tabs).
	$entry.setPanelPage(2; "po-addresses-32x32.png"; "Addresses"; "disabled")
	$entry.setPanelPage(3; "po-lines-32x32.png"; "Line Items")
	$entry.setPanelPage(4; "lots-32x32.png"; "Lots"; "disabled:Form.current_item.lineItem=True")
	
	
	$entry.setLBItemsColumn("jobNumber"; "Job #"; "width:100")
	$entry.setLBItemsColumn("customer.name"; "Customer"; "width:250")
	$entry.setLBItemsColumn("dateCreated"; "Created"; "width:100")
	
	$entry.setLBItemsOrderBy("jobNumber")
	
	$entry.setItemListAction("Export to Excel"; "_ga_exportJobSelection")
	// totals of the jobs listed: timing, status, charge, costs, markup (jobRollup below)
	$entry.setItemListAction("Job roll-up"; "jobRollup")

	$entry.setItemAction("Print Shipper"; "_ga_printShipper")
	
	$entry.setItemAction("Generate Barcode"; "_ga_openBarCodeForm")
	
	$entry.setItemListAction("Search by Scanning"; "_ga_searchByBarcodeScanning")
	
	
	// MARK: -Views
	$view:=cs:C1710.sfw_definitionView.new("archivedJobs"; "Archived Jobs"; "derivedFrom:main"; $entry)
	$view.setSubset("archivedJobs")
	$view.setPictoLabel("/RESOURCES/ga/image/picto/archived-16x16.png")
	$entry.setView($view)
	
	$view:=cs:C1710.sfw_definitionView.new("shippedJobs"; "Shipped Jobs"; "derivedFrom:main"; $entry)
	$view.setSubset("shippedJobs")
	$view.setPictoLabel("/RESOURCES/ga/image/picto/shipped-16x16.png")
	$entry.setView($view)
	
	$view:=cs:C1710.sfw_definitionView.new("invoicedJobs"; "Invoiced Jobs"; "derivedFrom:main"; $entry)
	$view.setSubset("invoicedJobs")
	$view.setPictoLabel("/RESOURCES/ga/image/picto/invoiced-16x16.png")
	$entry.setView($view)
	
	$view:=cs:C1710.sfw_definitionView.new("lotRelatedJobs"; "Lot Related Jobs"; "derivedFrom:main"; $entry)
	$view.setSubset("lotRelatedJobs")
	$view.setPictoLabel("/RESOURCES/ga/image/picto/lotRelated-16x16.png")
	$entry.setView($view)
	
	$view:=cs:C1710.sfw_definitionView.new("notRelatedJobs"; "NR Jobs"; "derivedFrom:main"; $entry)
	$view.setSubset("notRelatedJobs")
	$view.setPictoLabel("/RESOURCES/ga/image/picto/notRelated-16x16.png")
	$entry.setView($view)

	// the shipping screen: what is still to ship, the earliest job first, with its due date,
	// timing and where its lots are; Print Shipper is the item action of the entry
	$view:=cs:C1710.sfw_definitionView.new("jobsToShip"; "To Ship")
	$view.setSubset("jobsToShip")
	$view.setPictoLabel("/RESOURCES/ga/image/picto/shipped-16x16.png")
	$view.setLBItemsColumn("jobNumber"; "Job #"; "width:70")
	$view.setLBItemsColumn("customer.name"; "Customer"; "width:200")
	$view.setLBItemsColumn("dueDateText"; "Due"; "width:80"; "center"; "headerCenter"; "orderByFormula:This.dueDateKey")
	$view.setLBItemsColumn("timing"; "Timing"; "width:150"; "columnName:columnTiming")
	$view.setLBItemsColumn("statusLabel"; "Status"; "width:90")
	$view.setLBItemsColumn("locationLabel"; "Location"; "width:250")
	$view.setLBItemsOrderBy("jobNumber")
	$view.setLBItemsMetaExpression("this.toShipMeta()")  // late in red
	$view.setLBItemsCounter("###,###,##0 ^1;;"; "unit1:job to ship"; "unitN:jobs to ship")
	$entry.setView($view)

	$entry.enableTransaction()
	
	
Function archivedJobs()->$jobs : cs:C1710.JobSelection
	cs:C1710.Util.me.setDateInterval(False:C215)
	$jobs:=ds:C1482.Job.query("archived =:1 & archivedDate >=:2 & archivedDate <=:3"; True:C214; Storage:C1525.cache.startDate; Storage:C1525.cache.endDate)
	
Function shippedJobs()->$jobs : cs:C1710.JobSelection
	cs:C1710.Util.me.setDateInterval(False:C215)
	$jobs:=ds:C1482.Job.query("shipped =:1 & lastShipDate >=:2 & lastShipDate <=:3 & archived =:4"; True:C214; Storage:C1525.cache.startDate; Storage:C1525.cache.endDate; False:C215)
	
Function invoicedJobs()->$jobs : cs:C1710.JobSelection
	cs:C1710.Util.me.setDateInterval(False:C215)
	$jobs:=ds:C1482.Job.query("shipped =:1 & invoiceDate >=:2 & invoiceDate <=:3 & archived =:4"; True:C214; Storage:C1525.cache.startDate; Storage:C1525.cache.endDate; False:C215)
	
Function lotRelatedJobs()->$jobs : cs:C1710.JobSelection
	$jobs:=ds:C1482.Job.query("lineItem =:1 & archived =:2"; False:C215; False:C215)
	
Function notRelatedJobs()->$jobs : cs:C1710.JobSelection
	$jobs:=ds:C1482.Job.query("lineItem =:1 & archived =:2"; True:C214; False:C215)

	// not shipped, not archived, not invoiced; the jobs whose lots are all out are shipped
	// (JobEntity.deliveryDate) even if the flag was not set, so they are left out too
Function jobsToShip()->$jobs : cs:C1710.JobSelection
	var $job : cs:C1710.JobEntity
	var $candidates : cs:C1710.JobSelection
	$candidates:=ds:C1482.Job.query("shipped = :1 & archived = :2 & stmpInvoiced = :3"; False:C215; False:C215; 0)
	$jobs:=ds:C1482.Job.newSelection()
	For each ($job; $candidates)
		If ($job.deliveryDate=!00-00-00!)
			$jobs.add($job)
		End if
	End for each


	// MARK: -Roll-up
	// one line under the Jobs & Deliveries list of a lead (panel_lead, object jobs_rollup), from
	// the rows of JobEntity.jobsRow shown there (filters applied)
Function rollupText($rows : Collection)->$text : Text
	var $sum : Object
	If ($rows=Null:C1517) || ($rows.length=0)
		return
	End if
	$sum:=This:C1470._rollup($rows)
	$text:=String:C10($sum.count)+" job"+(($sum.count>1) ? "s" : "")
	$text+=" · "+String:C10($sum.late)+" late · "+String:C10($sum.notShipped)+" not shipped"
	$text+=" · Charge "+_ga_usdText($sum.price)
	If ($sum.costed>0)
		$text+=" · Actual cost "+_ga_usdText($sum.actual)+" · Markup "+_ga_usdText($sum.markup)
		$text+=" ("+String:C10(Round:C94($sum.markup/$sum.actual*100; 1))+"%, "+String:C10($sum.costed)+" job"+(($sum.costed>1) ? "s" : "")+" with costs)"
	End if

	// "Job roll-up" (item list action of Jobs): the jobs listed (view, filters and search
	// applied), by status, with their timing and money. Run by sfw with .call(): ds.Job, not This
Function jobRollup()
	var $job : cs:C1710.JobEntity
	var $rows : Collection
	var $sum; $status : Object
	var $message; $cr : Text

	$rows:=New collection:C1472
	For each ($job; Form:C1466.sfw.lb_items)
		$rows.push($job.jobsRow())
	End for each
	If ($rows.length=0)
		cs:C1710.sfw_dialog.me.alert("No job is listed.")
		return
	End if
	$sum:=ds:C1482.Job._rollup($rows)
	$cr:=Char:C90(Carriage return:K15:38)
	$message:="Roll-up of the "+String:C10($sum.count)+" job"+(($sum.count>1) ? "s" : "")+" listed"+$cr+$cr
	$message+="Delivered: "+String:C10($sum.delivered)+" ("+String:C10($sum.onTime)+" on time, "+String:C10($sum.delivered-$sum.onTime)+" late)"+$cr
	$message+="Not shipped: "+String:C10($sum.notShipped)+" ("+String:C10($sum.lateNotShipped)+" past their due date)"+$cr
	$message+="On-time rate: "+(($sum.delivered=0) ? "-" : String:C10(Round:C94($sum.onTime/$sum.delivered*100; 1))+"%")+$cr+$cr
	$message+="By status:"+$cr
	For each ($status; $sum.byStatus)
		$message+="  "+$status.status+": "+String:C10($status.count)+" - "+_ga_usdText($status.price)+$cr
	End for each
	$message+=$cr+"Charge: "+_ga_usdText($sum.price)+$cr
	$message+="Subcon / purchases: "+_ga_usdText($sum.subcon)+$cr
	$message+="Actual cost: "+_ga_usdText($sum.actual)+$cr
	If ($sum.costed>0)
		$message+="Markup: "+_ga_usdText($sum.markup)+" ("+String:C10(Round:C94($sum.markup/$sum.actual*100; 1))+"% of cost, on the "+String:C10($sum.costed)+" job"+(($sum.costed>1) ? "s" : "")+" with costs)"
	Else
		$message+="Markup: - (no cost recorded)"
	End if
	cs:C1710.sfw_dialog.me.info($message)

	// the totals of jobsRow rows. The markup only counts the jobs with a cost: a job without
	// purchases or pulls would show its whole charge as markup
Function _rollup($rows : Collection)->$sum : Object
	var $row; $status : Object
	$sum:=New object:C1471("count"; $rows.length; "late"; 0; "lateNotShipped"; 0; "delivered"; 0; "onTime"; 0; "notShipped"; 0; \
		"price"; 0; "subcon"; 0; "actual"; 0; "markup"; 0; "costed"; 0; "byStatus"; New collection:C1472)
	For each ($row; $rows)
		If ($row.daysLate>0)
			$sum.late+=1
		End if
		If ($row.isDelivered)
			$sum.delivered+=1
			If ($row.daysLate=0)
				$sum.onTime+=1
			End if
		Else
			If ($row.status#"Archived") && ($row.status#"Invoiced")
				$sum.notShipped+=1
				If ($row.daysLate>0)
					$sum.lateNotShipped+=1
				End if
			End if
		End if
		$sum.price+=Num:C11($row.price)
		$sum.subcon+=Num:C11($row.subcon)
		If (Num:C11($row.actual)#0)
			$sum.actual+=$row.actual
			$sum.markup+=$row.markup
			$sum.costed+=1
		End if
		$status:=$sum.byStatus.query("status = :1"; $row.status).first()
		If ($status=Null:C1517)
			$status:=New object:C1471("status"; $row.status; "count"; 0; "price"; 0)
			$sum.byStatus.push($status)
		End if
		$status.count+=1
		$status.price+=Num:C11($row.price)
	End for each

	
	
	// MARK: -
	
local Function cacheLoad()
	
	If (Storage:C1525.cache=Null:C1517)
		Use (Storage:C1525)
			Storage:C1525.cache:=New shared object:C1526
		End use 
	End if 
	If (Storage:C1525.cache.jobs=Null:C1517)
		$jobs:=This:C1470._loadAsCollection()
		Use (Storage:C1525.cache)
			Storage:C1525.cache.jobs:=$jobs.copy(ck shared:K85:29; Storage:C1525.cache)
		End use 
	End if 
	
	
Function _loadAsCollection()->$jobs : Collection
	$jobs:=This:C1470.query("shipped =:1 & postToPO =:2"; True:C214; False:C215).toCollection("UUID,jobNumber").orderBy("jobNumber")
	
	
	