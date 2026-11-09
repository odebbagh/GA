//%attributes = {}
// Saves a hold form object into lot.NCMN.items or lot.ISSNF.items for the current hold ON event.
#DECLARE($lot : 4D:C1709.Entity; $formFieldName : Text; $form : Object)->$success : Boolean

var $hold : Object
var $items : Collection
var $saved : Object
var $idx : Integer
var $i : Integer
var $numbered : Integer
var $it : Object

$success:=False:C215

If ($lot=Null:C1517) || ($form=Null:C1517)
	return $success
End if 

$hold:=LotHoldForm_getCurrentHoldOn($lot)

If ($hold=Null:C1517)
	return $success
End if 

LotHoldForm_ensureHoldUUID($lot; $hold)
LotHoldForm_ensureFormContainer($lot; $formFieldName; $hold)

Case of 
	: ($formFieldName="NCMN")
		$items:=$lot.NCMN.items.copy()
	: ($formFieldName="ISSNF")
		$items:=$lot.ISSNF.items.copy()
	Else 
		return $success
End case 

$saved:=LotHoldForm_cloneObject($form)
$saved.hold_UUID:=$hold.UUID
OB REMOVE:C1226($saved; "lot_UUID")  // the window's link to its lot (LotHoldForm_resolveForm)
OB REMOVE:C1226($saved; "readOnly")

If ($hold.date#Null:C1517)
	$saved.hold_date:=$hold.date
	$saved.hold_time:=$hold.time
Else 
	$saved.hold_date:=$hold.holdDate
	$saved.hold_time:=$hold.holdTime
End if 

$idx:=-1

If (String:C10($hold.UUID)#"")
	For ($i; 0; $items.length-1)
		If (String:C10($items[$i].hold_UUID)=String:C10($hold.UUID))
			$idx:=$i
		End if 
	End for 
End if 

// NCMN number: given once, the first time this hold's NCMN is saved, and kept afterwards.
// ncmnIndex says which non-conformance of this lot it is (1st, 2nd...), as asked in July.
If ($formFieldName="NCMN")
	If ($idx#-1)
		If (String:C10($items[$idx].ncmnNumber)#"")
			$saved.ncmnNumber:=$items[$idx].ncmnNumber
			$saved.ncmnIndex:=$items[$idx].ncmnIndex
		End if 
	End if 
	If (String:C10($saved.ncmnNumber)="")
		$numbered:=0
		For each ($it; $items)
			If (String:C10($it.ncmnNumber)#"")
				$numbered+=1
			End if 
		End for each 
		$saved.ncmnNumber:="NCMN-"+String:C10(ds:C1482.sfw_Counter.getNextValue("NCMN"); "00000")
		$saved.ncmnIndex:=$numbered+1
	End if 
End if 

If ($idx=-1)
	$items.push($saved)
Else 
	$items[$idx]:=$saved
End if 

Case of 
	: ($formFieldName="NCMN")
		$lot.NCMN:=New object:C1471("items"; $items)
	: ($formFieldName="ISSNF")
		$lot.ISSNF:=New object:C1471("items"; $items)
End case 

$success:=True:C214
