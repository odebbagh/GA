Class extends Entity

Function getCurrentStep()->$currentStepOrder : Integer
	//$currentstep_es:=This.steps.query("qtyIn = :1 AND qtyOut = :1 AND dateIn = :2 AND dateOut = :2"; 0; !00-00-00!).orderBy("order asc")
	
	//If ($currentstep_es.length>0)
	//$currentStepOrder:=$currentstep_es[0].order
	//End if 
	
local Function beforeSaveCreation()
	// A new lot never takes a number already in use. Its number comes from the table counter when
	// New is clicked, inside the Modify transaction, and the counter can fall back below numbers
	// already given (a counter change made in a cancelled transaction is undone). When that
	// happens, the counter is moved past the highest number in use (_fix_sequences) and a fresh
	// number is taken.
	This:C1470.number:=cs:C1710.LotSplitService.me.freeLotNumber(This:C1470.number; This:C1470.UUID)

local Function loadAfterCreation()
	
	Case of 
		: (Form:C1466.sfw.entry.ident="customerReceivedMaterial")
			$job:=ds:C1482.Job.new()
			$job.dateCreated:=Current date:C33(*)  // the job's creation date (Created column of the job lists)
			$res:=$job.save()
			
			If ($res.success)
				This:C1470.UUID_Job:=$job.UUID
			End if 
			
			If (This:C1470.dateIn=!00-00-00!)
				This:C1470.dateIn:=Current date:C33
			End if 
			
			This:C1470.number:=Sequence number:C244([Lot:118])
			
		Else 
			// This callback is called after creating the new item but before displaying the panel.
			If (This:C1470.lotNumber="")
				// next lot number: highest numeric lot number + 1, ignoring the values 0 and 1.
				// max() of an empty collection is undefined, and undefined+1 raised error 15, so the
				// first lot of an empty table could not be created. When nothing is left after the
				// filter (no lot yet, or only 0/1), the highest of all lot numbers is used instead,
				// otherwise every new lot would get 1 again.
				var $lotNumbers : Collection
				var $highest : Variant
				$lotNumbers:=ds:C1482.Lot.all().extract("lotNumber").map(Formula:C1597(Num:C11($1.value)))
				$highest:=$lotNumbers.filter(Formula:C1597((Num:C11($1.value)#1) && (Num:C11($1.value)#0))).max()
				If (Undefined:C82($highest))
					$highest:=$lotNumbers.max()
				End if 
				This:C1470.lotNumber:=String:C10(String:C10(Num:C11($highest)+1); "0000000000#")
				
				//String(Num(ds.Lot.all().max("lotNumber")+1000); "00000#")
			End if 
			If (Form:C1466.sfw.entry.ident="receiver")
				$job:=ds:C1482.Job.new()
				
				$job.jobNumber:=Sequence number:C244([Job:117])  // the table's counter: never given twice ("highest + 1" could be)
				$job.dateCreated:=Current date:C33(*)
				$res:=$job.save()
				
				If ($res.success)
					This:C1470.UUID_Job:=$job.UUID
				End if 
			End if 
	End case 
	
local Function get nameInWindowTitle()->$nameInWindowTitle : Text
	// With this callback you return the name to displayed in the title of the window for the current item
	$nameInWindowTitle:=This:C1470.displayNumber
	
	// Lot # as people read it: a sublot is its mother's number + "-" + its sub number (41-1, 41-2),
	// as the client asked at the demo of 23 July 2026; any other lot is its number. `number` stays
	// the unique key of the record (every sublot still has its own).
local Function get displayNumber()->$text : Text
	$text:=String:C10(This:C1470.number)
	If (This:C1470.subSequence>0)
		If (This:C1470.lotParent#Null:C1517)
			$text:=String:C10(This:C1470.lotParent.number)+"-"+String:C10(This:C1470.subSequence)
		End if 
	End if 
	
	// a Lot # column (displayNumber) is sorted by the record number
Function orderBy displayNumber($event : Object)->$result : Text
	$result:="number"+Choose:C955(Bool:C1537($event.descending); " desc"; " asc")
	
	// the search box on the Lot # (it sends "@41@"): "41" finds lot 41 and its sublots (41-1,
	// 41-2), "41-1" finds that sublot; anything else finds nothing
Function query displayNumber($event : Object)->$result : Object
	var $text : Text
	var $parts : Collection
	
	$text:=Replace string:C233(String:C10($event.value); "@"; "")
	Case of 
		: (Match regex:C1019("^[0-9]+-[0-9]+$"; $text; 1))
			$parts:=Split string:C1554($text; "-")
			$result:=New object:C1471("query"; "lotParent.number = :1 AND subSequence = :2"; "parameters"; New collection:C1472(Num:C11($parts[0]); Num:C11($parts[1])))
		: (Match regex:C1019("^[0-9]+$"; $text; 1))
			$result:=New object:C1471("query"; "number = :1 OR lotParent.number = :1"; "parameters"; New collection:C1472(Num:C11($text)))
		Else 
			$result:=New object:C1471("query"; "number = :1"; "parameters"; New collection:C1472(-1))
	End case 
	
	// The lot's ship-to address: a copy of its customer's shipping address (else main, else billing),
	// then changed for this lot only on the Planning Ship To tab, without touching the customer.
	// customerUUID remembers which customer it came from, so a change of customer can replace it.
local Function copyShipToFromCustomer($customer : 4D:C1709.Entity)->$copied : Boolean
	var $source : Object
	var $type : Text
	
	$copied:=False:C215
	If ($customer=Null:C1517)
		return 
	End if 
	If ($customer.contactDetails=Null:C1517)
		return 
	End if 
	If ($customer.contactDetails.addresses=Null:C1517)
		return 
	End if 
	For each ($type; New collection:C1472("shipping"; "main"; "billing")) Until ($source#Null:C1517)
		$source:=$customer.contactDetails.addresses.query("type = :1"; $type).first()
	End for each 
	If ($source=Null:C1517)
		return 
	End if 
	This:C1470.shipToAddress:=OB Copy:C1225($source)
	This:C1470.shipToAddress.type:="shipping"
	This:C1470.shipToAddress.customerUUID:=$customer.UUID
	This:C1470.shipToAddress:=This:C1470.shipToAddress
	$copied:=True:C214
	
	// Called when the lot's job or customer changes: the ship-to follows the customer, unless it was
	// already copied from that same customer (and possibly changed for this lot since).
local Function followCustomerShipTo()
	var $customer : 4D:C1709.Entity
	
	If (This:C1470.job=Null:C1517)
		return 
	End if 
	$customer:=This:C1470.job.customer
	If ($customer=Null:C1517)
		return 
	End if 
	If (This:C1470.shipToAddress#Null:C1517)
		If (String:C10(This:C1470.shipToAddress.customerUUID)=$customer.UUID)
			return 
		End if 
	End if 
	This:C1470.copyShipToFromCustomer($customer)
	
Function getLastCompletedStep()->$lastCompletedStepOrder : Integer
	
	If (This:C1470.lotSteps#Null:C1517) && (This:C1470.lotSteps.length>0)
		$completedSteps:=This:C1470.lotSteps.query("dateOut # :1"; !00-00-00!).orderBy("order desc")
		If ($completedSteps.length>0)
			$lastCompletedStepOrder:=$completedSteps[0].order
		End if 
	End if 
	
	
// ----------------------------------------------
// beforeSave / afterSave - called by sfw.bItemSave around a Save-button save
// (callbackOnCurrentItem). The framework logs the tracked fields itself but cannot see
// changes inside object fields (holds, hold forms, SN table): the stored state is read before the
// save, compared after it, and the result is added to the event the framework has just
// written (ga_events).
// ----------------------------------------------
local Function _showNewSublots()
	// A split creates its sublot while the mother lot is in Modify; once the mother is saved, the
	// sublot joins the list of the entry, in its place after the mother (41, 41-1). It used to show
	// only after reloading the entry. Nothing to do outside a list (no Form.sfw.lb_items).
	var $new : 4D:C1709.EntitySelection

	If (Form:C1466=Null:C1517)
		return
	End if
	If (Form:C1466.sfw=Null:C1517)
		return
	End if
	If (Value type:C1509(Form:C1466.sfw.lb_items)#Is object:K8:27)
		return
	End if
	$new:=This:C1470.subLots.minus(Form:C1466.sfw.lb_items)
	If ($new.length>0)
		Form:C1466.sfw.lb_items:=Form:C1466.sfw.lb_items.copy().add($new).orderBy("number desc, subSequence asc")
	End if

local Function beforeSave()
	cs:C1710.ga_events.me.pending[String:C10(This:C1470.UUID)]:=cs:C1710.ga_events.me.storedState(This:C1470; New collection:C1472("lotHold"; "NCMN"; "ISSNF"; "snTable"))
	
local Function afterSave()
	var $before : Object
	var $key : Text
	
	This:C1470._showNewSublots()

	$key:=String:C10(This:C1470.UUID)
	$before:=cs:C1710.ga_events.me.pending[$key]
	If ($before=Null:C1517)
		return 
	End if 
	OB REMOVE:C1226(cs:C1710.ga_events.me.pending; $key)
	If (Bool:C1537(Form:C1466.info.success)) && (Form:C1466.sfw.entry.event#Null:C1517)
		cs:C1710.ga_events.me.mergeIntoSaveEvent(Form:C1466.sfw.entry; $key; cs:C1710.ga_events.me.lotChanges($before; This:C1470).extract("text"))
	End if 
