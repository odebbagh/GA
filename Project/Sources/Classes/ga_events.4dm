// ga_events
// History lines for the changes the framework's event log cannot see on its own:
// - changes INSIDE object fields (lot holds, NCMN / ISSNF forms, SN table; customer
//   addresses and FTP). sfw.bItemSave compares the record with a clone() taken when it was
//   loaded, and a clone shares its object values with the record, so a change inside an
//   object field always compares equal.
// - lot changes saved outside the Save button: holds and hold forms from Punch In / Punch
//   Out are saved directly (LotHoldForm_trySaveLot), so they never reach the event log.
// Events are written with the framework's own API (sfw_eventManager.addEvent) into the
// entry's event table (LotEvent, CustomerEvent), so they show in the usual Events feed:
// the event type label is the title, moreData.comment the detail.
//
// Per-process singleton: "pending" holds the stored state read by an entity's beforeSave(),
// until its afterSave() compares it with what was saved.
property pending : Object
	
singleton Class constructor
	This:C1470.pending:=New object:C1471
	
	
	// ---------------------------------------------------------------------------------
	// stored state
	// ---------------------------------------------------------------------------------
	
	// The values of $attributes as stored in the database, i.e. before the in-memory changes
	// of $entity, deep-copied. Empty for a record not saved yet.
Function storedState($entity : 4D:C1709.Entity; $attributes : Collection)->$state : Object
	var $stored : 4D:C1709.Entity
	var $attribute : Text
	
	$state:=New object:C1471
	If ($entity=Null:C1517)
		return $state
	End if 
	If ($entity.isNew())
		return $state
	End if 
	$stored:=ds:C1482[$entity.getDataClass().getInfo().name].get($entity.getKey())
	If ($stored=Null:C1517)
		return $state
	End if 
	For each ($attribute; $attributes)
		If (Value type:C1509($stored[$attribute])=Is object:K8:27) | (Value type:C1509($stored[$attribute])=Is collection:K8:32)
			$state[$attribute]:=OB Copy:C1225($stored[$attribute])
		Else 
			$state[$attribute]:=$stored[$attribute]
		End if 
	End for each 
	
	
	// ---------------------------------------------------------------------------------
	// lot
	// ---------------------------------------------------------------------------------
	
	// Lines describing what changed in the lot's holds, hold forms and SN table between the
	// stored state $before and the lot $lot. Each line: {kind; text}, kind being holdOn,
	// holdOff, form or sn (used to title the event).
Function lotChanges($before : Object; $lot : 4D:C1709.Entity)->$lines : Collection
	var $item : Object
	var $prev : Object
	var $known : Collection
	var $action : Text
	var $text : Text
	var $formName : Text
	var $oldCount : Integer
	var $newCount : Integer
	
	$lines:=New collection:C1472
	If ($lot=Null:C1517)
		return $lines
	End if 
	
	// holds added since the stored version
	$known:=This:C1470._items($before.lotHold).map(Formula:C1597(cs:C1710.ga_events.me._holdKey($1.value)))
	For each ($item; This:C1470._items($lot.lotHold))
		If ($known.indexOf(This:C1470._holdKey($item))#-1)
			continue
		End if 
		$action:=Choose:C955((String:C10($item.action)="on") | (String:C10($item.holdAction)="Hold ON"); "on"; "off")
		$text:=Choose:C955($action="on"; "Hold ON"; "Hold OFF")
		If (This:C1470._holdCode($item)#"")
			$text+=" - "+This:C1470._holdCode($item)
		End if 
		If (This:C1470._first($item.hold_reason; $item.holdReason)#"")
			$text+=": "+This:C1470._short(This:C1470._first($item.hold_reason; $item.holdReason))
		End if 
		If (String:C10($item.performedBy)#"")
			$text+=" (by "+String:C10($item.performedBy)+")"
		End if 
		$lines.push(New object:C1471("kind"; "hold"+Choose:C955($action="on"; "On"; "Off"); "text"; $text))
	End for each 
	
	// hold forms, matched on the hold they belong to
	For each ($formName; New collection:C1472("NCMN"; "ISSNF"))
		For each ($item; This:C1470._items($lot[$formName]))
			$prev:=This:C1470._items($before[$formName]).query("hold_UUID = :1"; String:C10($item.hold_UUID)).first()
			For each ($text; This:C1470._holdFormChanges($formName; $prev; $item))
				$lines.push(New object:C1471("kind"; "form"; "text"; $text))
			End for each 
		End for each 
	End for each 
	
	// SN table
	$oldCount:=This:C1470._items($before.snTable).length
	$newCount:=This:C1470._items($lot.snTable).length
	Case of 
		: ($oldCount=0) && ($newCount>0)
			$lines.push(New object:C1471("kind"; "sn"; "text"; "SN table generated: "+String:C10($newCount)+" unit(s), "+String:C10($lot.snRangeMin)+" to "+String:C10($lot.snRangeMax)))
		: ($oldCount>0) && ($newCount=0)
			$lines.push(New object:C1471("kind"; "sn"; "text"; "SN table cleared ("+String:C10($oldCount)+" unit(s))"))
		: ($oldCount#$newCount)
			$lines.push(New object:C1471("kind"; "sn"; "text"; "SN table: "+String:C10($oldCount)+" -> "+String:C10($newCount)+" unit(s)"))
	End case 
	
	
	// A lot saved outside the Save button (LotHoldForm_trySaveLot): one event in the lot's
	// history, titled after the most significant change.
Function logLotSave($before : Object; $lot : 4D:C1709.Entity)
	var $lines : Collection
	
	$lines:=This:C1470.lotChanges($before; $lot)
	If ($lines.length=0)
		return
	End if 
	Case of 
		: ($lines.query("kind = :1"; "holdOn").length>0)
			This:C1470.addEvent("planning"; $lot.UUID; "ga_lotHoldOn"; "Lot put on hold"; $lines.extract("text"))
		: ($lines.query("kind = :1"; "holdOff").length>0)
			This:C1470.addEvent("planning"; $lot.UUID; "ga_lotHoldOff"; "Lot taken off hold"; $lines.extract("text"))
		: ($lines.query("kind = :1"; "form").length>0)
			This:C1470.addEvent("planning"; $lot.UUID; "ga_lotHoldForms"; "NCMN / ISSNF updated"; $lines.extract("text"))
		Else 
			This:C1470.addEvent("planning"; $lot.UUID; "ga_lotUpdate"; "Lot updated"; $lines.extract("text"))
	End case 
	
	
	// ---------------------------------------------------------------------------------
	// customer
	// ---------------------------------------------------------------------------------
	
	// Lines describing what changed in the customer's addresses and FTP access. The FTP
	// password is never written into the history, only the fact that it changed.
Function customerChanges($before : Object; $customer : 4D:C1709.Entity)->$lines : Collection
	var $type : Text
	var $old : Text
	var $new : Text
	var $types : Collection
	var $oldRest : Text
	var $newRest : Text
	var $oldDetails : Object
	var $newDetails : Object
	var $oldFtp : Object
	var $newFtp : Object
	
	$lines:=New collection:C1472
	If ($customer=Null:C1517)
		return $lines
	End if 
	
	$oldDetails:=$before.contactDetails || New object:C1471
	$newDetails:=$customer.contactDetails || New object:C1471
	
	// addresses, by type (billing, shipping, ...)
	$types:=This:C1470._items($oldDetails.addresses).extract("type").combine(This:C1470._items($newDetails.addresses).extract("type")).distinct()
	For each ($type; $types)
		$old:=This:C1470._address($oldDetails.addresses; $type)
		$new:=This:C1470._address($newDetails.addresses; $type)
		If ($old#$new)
			$lines.push(Uppercase:C13(Substring:C12($type; 1; 1))+Substring:C12($type; 2)+" address: "+Choose:C955($old=""; "(none)"; $old)+" -> "+Choose:C955($new=""; "(none)"; $new))
		End if 
	End for each 
	
	// anything else kept in contactDetails (phones, e-mails...)
	$oldRest:=JSON Stringify:C1217(This:C1470._without($oldDetails; "addresses"))
	$newRest:=JSON Stringify:C1217(This:C1470._without($newDetails; "addresses"))
	If ($oldRest#$newRest)
		$lines.push("Contact details (phone / e-mail) changed")
	End if 
	
	// FTP access
	$oldFtp:=$before.ftp || New object:C1471
	$newFtp:=$customer.ftp || New object:C1471
	If (String:C10($oldFtp.domain)#String:C10($newFtp.domain))
		$lines.push("FTP domain: "+String:C10($oldFtp.domain)+" -> "+String:C10($newFtp.domain))
	End if 
	If (String:C10($oldFtp.user)#String:C10($newFtp.user))
		$lines.push("FTP user: "+String:C10($oldFtp.user)+" -> "+String:C10($newFtp.user))
	End if 
	If (String:C10($oldFtp.password)#String:C10($newFtp.password))
		$lines.push("FTP password changed")
	End if 
	
	
	// ---------------------------------------------------------------------------------
	// writing the history
	// ---------------------------------------------------------------------------------
	
	// A new event in the history of record $uuid of entry $entryIdent.
Function addEvent($entryIdent : Text; $uuid : Text; $ident : Text; $label : Text; $lines : Collection)
	var $entry : Object
	
	$entry:=cs:C1710.sfw_definition.me.entries.query("ident = :1"; $entryIdent).first()
	If ($entry=Null:C1517)
		return
	End if 
	If ($entry.event=Null:C1517)
		return
	End if 
	This:C1470._ensureEventType($ident; $label)
	cs:C1710.sfw_eventManager.me.addEvent($entry; $ident; $uuid; New object:C1471("comment"; $lines.join("\r")))
	
	
	// Adds $lines to the "Modify the record" event sfw.bItemSave has just written for record
	// $uuid (it writes it before calling afterSave), so one save stays one event. When the
	// entry is set to write no event without a tracked change, a new one is written instead.
Function mergeIntoSaveEvent($entry : Object; $uuid : Text; $lines : Collection)
	var $eventType : Object
	var $event : 4D:C1709.Entity
	var $res : Object
	
	If ($lines.length=0) | ($entry=Null:C1517)
		return
	End if 
	If ($entry.event=Null:C1517)
		return
	End if 
	
	$eventType:=cs:C1710.sfw_eventManager.me.getEventType("modifRecord")
	If ($eventType#Null:C1517)
		$event:=ds:C1482[$entry.event.dataclass].query("UUID_EventType = :1 AND "+$entry.event.linkedAttribute+" = :2 order by stmp desc"; $eventType.UUID; $uuid).first()
	End if 
	
	If ($event=Null:C1517)
		cs:C1710.sfw_eventManager.me.addEvent($entry; "modifRecord"; $uuid; New object:C1471("comment"; $lines.join("\r")))
	Else 
		$event.moreData:=$event.moreData || New object:C1471
		$event.moreData.comment:=Choose:C955(String:C10($event.moreData.comment)=""; ""; String:C10($event.moreData.comment)+"\r")+$lines.join("\r")
		$res:=$event.save()
	End if 
	cs:C1710.sfw_eventManager.me.refresh($uuid; $entry)
	
	
	// The event types of this class are application data: created on first use.
Function _ensureEventType($ident : Text; $label : Text)
	var $type : 4D:C1709.Entity
	var $res : Object
	
	If (cs:C1710.sfw_eventManager.me.getEventType($ident)#Null:C1517)
		return
	End if 
	$type:=ds:C1482.sfw_EventType.new()
	$type.UUID:=Generate UUID:C1066
	$type.ident:=$ident
	$type.label:=$label
	$res:=$type.save()
	cs:C1710.sfw_eventManager.me.getEventType($ident)  // loads it into the event manager's cache
	
	
	// ---------------------------------------------------------------------------------
	// helpers
	// ---------------------------------------------------------------------------------
	
Function _holdFormChanges($formName : Text; $prev : Object; $form : Object)->$lines : Collection
	var $approval : Object
	var $field : Object
	var $old : Text
	var $new : Text
	
	$lines:=New collection:C1472
	If ($prev=Null:C1517)
		$lines.push($formName+Choose:C955(String:C10($form.ncmnNumber)=""; ""; " "+String:C10($form.ncmnNumber))+" filled in")
		$prev:=New object:C1471
	End if 
	
	For each ($approval; New collection:C1472(\
		New object:C1471("key"; "approvalCustomerService"; "label"; "Customer Service"); \
		New object:C1471("key"; "approvalEngineering"; "label"; "Engineering"); \
		New object:C1471("key"; "approvalQAQC"; "label"; "QA/QC"); \
		New object:C1471("key"; "approvalProduction"; "label"; "Production")))
		Case of 
			: (Bool:C1537($form[$approval.key])) && (Not:C34(Bool:C1537($prev[$approval.key])))
				$lines.push($formName+" approval "+$approval.label+" signed"+Choose:C955(String:C10($form[$approval.key+"By"])=""; ""; " by "+String:C10($form[$approval.key+"By"])))
			: (Not:C34(Bool:C1537($form[$approval.key]))) && (Bool:C1537($prev[$approval.key]))
				$lines.push($formName+" approval "+$approval.label+" withdrawn")
		End case 
	End for each 
	
	For each ($field; New collection:C1472(\
		New object:C1471("key"; "disposition"; "label"; "disposition"); \
		New object:C1471("key"; "problemDetail"; "label"; "problem"); \
		New object:C1471("key"; "quantityInspected"; "label"; "qty inspected"); \
		New object:C1471("key"; "quantityAccepted"; "label"; "qty accepted"); \
		New object:C1471("key"; "quantityRejected"; "label"; "qty rejected"); \
		New object:C1471("key"; "originator"; "label"; "originator"); \
		New object:C1471("key"; "machine"; "label"; "M/C #"); \
		New object:C1471("key"; "statusLocation"; "label"; "held at"); \
		New object:C1471("key"; "carNumber"; "label"; "CAR #"); \
		New object:C1471("key"; "location"; "label"; "location / process"); \
		New object:C1471("key"; "informTo"; "label"; "inform to")))
		$old:=String:C10($prev[$field.key])
		$new:=String:C10($form[$field.key])
		If ($old#$new)
			$lines.push($formName+" "+$field.label+": "+Choose:C955($old=""; "(empty)"; This:C1470._short($old))+" -> "+Choose:C955($new=""; "(empty)"; This:C1470._short($new)))
		End if 
	End for each 
	
	
Function _items($container : Variant)->$items : Collection
	$items:=New collection:C1472
	Case of 
		: (Value type:C1509($container)=Is collection:K8:32)
			$items:=$container
		: (Value type:C1509($container)=Is object:K8:27)
			If (Value type:C1509($container.items)=Is collection:K8:32)
				$items:=$container.items
			End if 
	End case 
	
	
	// Punch In / Out holds carry a UUID; Planning writes them without one
Function _holdKey($item : Object)->$key : Text
	If (String:C10($item.UUID)#"")
		$key:=String:C10($item.UUID)
	Else 
		$key:=String:C10($item.holdAction)+String:C10($item.action)+"|"+String:C10($item.holdDate)+String:C10($item.date)+"|"+String:C10($item.holdTime)+String:C10($item.time)+"|"+String:C10($item.performedBy)
	End if 
	
	
Function _holdCode($item : Object)->$code : Text
	Case of 
		: (Value type:C1509($item.hold_code)=Is object:K8:27)
			$code:=String:C10($item.hold_code.code)
		: (Value type:C1509($item.hold_code)=Is text:K8:3)
			$code:=$item.hold_code
		Else 
			$code:=String:C10($item.holdCode)
	End case 
	
	
Function _first($a : Variant; $b : Variant)->$text : Text
	$text:=String:C10($a)
	If ($text="")
		$text:=String:C10($b)
	End if 
	
	
Function _short($text : Text)->$short : Text
	$short:=Replace string:C233(Replace string:C233($text; "\r"; " "); "\n"; " ")
	If (Length:C16($short)>120)
		$short:=Substring:C12($short; 1; 117)+"..."
	End if 
	
	
Function _address($addresses : Variant; $type : Text)->$line : Text
	var $address : Object
	
	$address:=This:C1470._items($addresses).query("type = :1"; $type).first()
	If ($address#Null:C1517)
		$line:=Address_toSingleLine($address)
	End if 
	
	
Function _without($object : Object; $key : Text)->$copy : Object
	$copy:=OB Copy:C1225($object)
	If (OB Is defined:C1231($copy; $key))
		OB REMOVE:C1226($copy; $key)
	End if 
	
	
	// ---------------------------------------------------------------------------------
	// lot steps (Punch In / Punch Out): written to the LOT's history
	// ---------------------------------------------------------------------------------
	
	// Attributes of a lot step read before a save, for stepChanges
Function stepAttributes()->$attributes : Collection
	$attributes:=New collection:C1472("qtyIn"; "qtyOut"; "rejects"; "dateIn"; "dateOut"; "timeIn"; "timeOut"; "inOperator"; "outOperator"; "approvedBy"; "isApproved"; "qaRejected"; "tools"; "stepInterruptions")
	
	
	// Lines describing what a Punch In / Punch Out save changed on a lot step. Each line:
	// {kind; text}, kind being in, out, qa or update (used to title the event).
Function stepChanges($before : Object; $step : 4D:C1709.Entity)->$lines : Collection
	var $label : Text
	var $text : Text
	var $item : Object
	var $prev : Object
	var $oldTools : Collection
	var $field : Object
	var $nbOld : Integer
	var $i : Integer
	
	$lines:=New collection:C1472
	If ($step=Null:C1517)
		return $lines
	End if 
	$label:="Step "+String:C10($step.order)+" "+This:C1470._short(This:C1470._firstLine(String:C10($step.description)))
	
	// punched in / out
	If (This:C1470._date($before.dateIn)=!00-00-00!) && ($step.dateIn#!00-00-00!)
		$text:=$label+" punched in: qty in "+String:C10($step.qtyIn)
		If (String:C10($step.inOperator)#"")
			$text+=" (by "+String:C10($step.inOperator)+")"
		End if 
		$lines.push(New object:C1471("kind"; "in"; "text"; $text))
	End if 
	If (This:C1470._date($before.dateOut)=!00-00-00!) && ($step.dateOut#!00-00-00!)
		$text:=$label+" punched out: qty out "+String:C10($step.qtyOut)+", rejects "+String:C10($step.rejects)
		If (String:C10($step.outOperator)#"")
			$text+=" (by "+String:C10($step.outOperator)+")"
		End if 
		$lines.push(New object:C1471("kind"; "out"; "text"; $text))
	End if 
	
	// quantities corrected afterwards
	For each ($field; New collection:C1472(\
		New object:C1471("key"; "qtyIn"; "label"; "qty in"; "after"; "dateIn"); \
		New object:C1471("key"; "qtyOut"; "label"; "qty out"; "after"; "dateOut"); \
		New object:C1471("key"; "rejects"; "label"; "rejects"; "after"; "dateOut")))
		If (This:C1470._date($before[$field.after])#!00-00-00!) && (Num:C11($before[$field.key])#Num:C11($step[$field.key]))
			$lines.push(New object:C1471("kind"; "update"; "text"; $label+" "+$field.label+": "+String:C10($before[$field.key])+" -> "+String:C10($step[$field.key])))
		End if 
	End for each 
	
	// QA sign-off (it is per step, LotStep_scanQASignoff)
	If (String:C10($before.approvedBy)#String:C10($step.approvedBy))
		If (String:C10($step.approvedBy)#"")
			$lines.push(New object:C1471("kind"; "qa"; "text"; $label+" QA sign-off: "+Choose:C955(Bool:C1537($step.qaRejected); "REJECTED"; "accepted")+" by "+String:C10($step.approvedBy)))
		Else 
			$lines.push(New object:C1471("kind"; "qa"; "text"; $label+" QA sign-off withdrawn"))
		End if 
	End if 
	
	// tools chosen
	$oldTools:=This:C1470._items($before.tools)
	For each ($item; This:C1470._items($step.tools))
		$prev:=$oldTools.query("order = :1"; $item.order).first()
		If (String:C10($item.toolName)#String:C10(($prev || New object:C1471).toolName))
			$lines.push(New object:C1471("kind"; "update"; "text"; $label+" tool "+String:C10($item.toolType)+": "+Choose:C955(String:C10(($prev || New object:C1471).toolName)=""; "(none)"; String:C10(($prev || New object:C1471).toolName))+" -> "+Choose:C955(String:C10($item.toolName)=""; "(none)"; String:C10($item.toolName))+Choose:C955(This:C1470._date($item.toolDate)=!00-00-00!; ""; " (calibration due "+String:C10(This:C1470._date($item.toolDate))+")")))
		End if 
	End for each 
	
	// interruptions logged
	$nbOld:=This:C1470._items($before.stepInterruptions).length
	For ($i; $nbOld; This:C1470._items($step.stepInterruptions).length-1)
		$item:=This:C1470._items($step.stepInterruptions)[$i]
		$text:=$label+" interruption: "+String:C10(This:C1470._date($item.start_date))+" "+This:C1470._time($item.start_time)+" - "+String:C10(This:C1470._date($item.end_date))+" "+This:C1470._time($item.end_time)
		If (String:C10($item.engineer)#"")
			$text+=" ("+String:C10($item.engineer)+")"
		End if 
		If (String:C10($item.description)#"")
			$text+=": "+This:C1470._short(String:C10($item.description))
		End if 
		$lines.push(New object:C1471("kind"; "update"; "text"; $text))
	End for 
	
	
	// A Punch In / Punch Out save of $step: one event in its lot's history
Function logStepSave($before : Object; $step : 4D:C1709.Entity)
	var $lines : Collection
	
	If ($step=Null:C1517)
		return 
	End if 
	$lines:=This:C1470.stepChanges($before; $step)
	If ($lines.length=0)
		return 
	End if 
	Case of 
		: ($lines.query("kind = :1"; "out").length>0)
			This:C1470.addEvent("planning"; $step.UUID_Lot; "ga_stepPunchOut"; "Step punched out"; $lines.extract("text"))
		: ($lines.query("kind = :1"; "in").length>0)
			This:C1470.addEvent("planning"; $step.UUID_Lot; "ga_stepPunchIn"; "Step punched in"; $lines.extract("text"))
		: ($lines.query("kind = :1"; "qa").length>0)
			This:C1470.addEvent("planning"; $step.UUID_Lot; "ga_stepQA"; "QA sign-off"; $lines.extract("text"))
		Else 
			This:C1470.addEvent("planning"; $step.UUID_Lot; "ga_stepUpdate"; "Step updated"; $lines.extract("text"))
	End case 
	
	
	// A serial number marked pass / fail at a step (sn_checkbox_pass saves at once)
Function logSnResult($step : 4D:C1709.Entity; $snItem : Object)
	var $text : Text
	
	If ($step=Null:C1517) | ($snItem=Null:C1517)
		return 
	End if 
	$text:="Step "+String:C10($step.order)+" "+This:C1470._short(This:C1470._firstLine(String:C10($step.description)))+": SN "+String:C10($snItem.serial_number)+Choose:C955(Bool:C1537($snItem.pass); " passed"; " FAILED")
	If (String:C10($snItem.comments)#"")
		$text+=" - "+This:C1470._short(String:C10($snItem.comments))
	End if 
	This:C1470.addEvent("planning"; $step.UUID_Lot; "ga_snResult"; "Serial number result"; New collection:C1472($text))
	
	
	// a date read from an object: a Date, or ISO text when the database stores dates as text
Function _date($value : Variant)->$date : Date
	Case of 
		: (Value type:C1509($value)=Is date:K8:7)
			$date:=$value
		: (Value type:C1509($value)=Is text:K8:3)
			$date:=Date:C102($value)
		Else 
			$date:=!00-00-00!
	End case 
	
	// a time read from an object (a Time, a number of seconds or text) as HH:MM
Function _time($value : Variant)->$text : Text
	Case of 
		: (Value type:C1509($value)=Is text:K8:3)
			$text:=Choose:C955($value=""; ""; String:C10(Time:C179($value); HH MM:K7:2))
		: (Value type:C1509($value)=Is real:K8:4) | (Value type:C1509($value)=Is longint:K8:6) | (Value type:C1509($value)=Is time:K8:8)
			$text:=String:C10(Time:C179($value); HH MM:K7:2)
		Else 
			$text:=""
	End case 
	
Function _firstLine($text : Text)->$line : Text
	$line:=Split string:C1554(Replace string:C233($text; "\n"; "\r"); "\r").first() || ""
