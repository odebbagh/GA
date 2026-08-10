Class extends DataClass


local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	//If (cs.sfw_definition.me.globalParameters.counters.activate)
	$entry:=cs:C1710.sfw_definitionEntry.new("counter"; "administration"; "Counter")
	$entry.setXliffLabel("counter.counter")
	$entry.setDataclass("sfw_Counter")
	$entry.setIcon("sfw/entry/counter-50x50.png")
	$entry.setSearchboxField("ident")
	$entry.setSearchboxField("currentValue")
	$entry.setPanel("sfw_panel_counter")
	$entry.setLBItemsColumn("ident"; " ")
	$entry.setLBItemsColumn("currentValue"; "Current value"; "xliff:counter.field.currentvalue")
	$entry.setLBItemsOrderBy("ident")
	$entry.setDisplayOrder(-100)
	
	$entry.setItemListPreconfigAction("exportReferenceRecords")
	$entry.setItemListPreconfigAction("importReferenceRecords")
	$entry.setItemListPreconfigAction("copyItemsListToPasteboard")
	//End if 
	
local Function getNextValue($ident : Text)->$value : Integer
	
	$value:=This:C1470._getNextValueCS($ident)
	cs:C1710.sfw_tracker.me.internal("counter "+$ident)
	
Function _getNextValueCS($ident : Text)->$value : Integer
	var $signal : 4D:C1709.Signal
	
	$signal:=New signal:C1641()
	Use ($signal)
		$signal.ident:=$ident
	End use 
	
	CALL WORKER:C1389("sfw_Counter_worker"; Formula:C1597(ds:C1482.sfw_Counter._getNextValueWK($1)); $signal)
	
	$signal.wait(100)
	
	If ($signal.signaled)
		$value:=Num:C11($signal.nextValue)
	End if 
	
Function _getNextValueWK($signal : 4D:C1709.Signal)
	var $counter : cs:C1710.sfw_CounterEntity
	var $counters : cs:C1710.sfw_CounterSelection
	var $ident : Text
	var $info : Object
	
	$ident:=$signal.ident
	$counters:=ds:C1482.sfw_Counter.query("ident = :1"; $ident)
	If ($counters.length=0)
		$counter:=ds:C1482.sfw_Counter.new()
		$counter.ident:=$ident
		$counter.currentValue:=0
	Else 
		$counter:=$counters.first()
	End if 
	$counter.currentValue+=1
	$info:=$counter.save()
	
	If ($info.success)
		Use ($signal)
			$signal.nextValue:=$counter.currentValue
		End use 
	End if 
	$signal.trigger()
	
	
	
	
	