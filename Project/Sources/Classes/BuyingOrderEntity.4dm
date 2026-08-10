Class extends Entity


local Function get nameInWindowTitle()->$nameInWindowTitle : Text
	$nameInWindowTitle:=String:C10(This:C1470.boNumber)

local Function get orderDate()->$date : Date
	$date:=This:C1470.orderStmp=0 ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate(This:C1470.orderStmp; True:C214)
	
local Function set orderDate($date : Date)
	This:C1470.orderStmp:=$date=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build($date)


local Function rebuildAddress()->$address : Object

	Case of
		: (Form:C1466.addressBilling=1)
			$type:="billing"
		: (Form:C1466.addressShipping=1)
			$type:="shipping"
		: (Form:C1466.addressRemit=1)
			$type:="remit"
	End case

	If (Form:C1466.subFormAddress=Null:C1517)
		Form:C1466.subFormAddress:=New object:C1471()
		Form:C1466.subFormAddress.situation:=Form:C1466.situation
	End if

	If (This:C1470.contactDetails#Null:C1517) && (This:C1470.contactDetails.addresses#Null:C1517)
		$address:=This:C1470.contactDetails.addresses.query("type =:1"; $type).first()
		Form:C1466.subFormAddress.address:=$address

		// while editing, keep the attribute touched so nested address
		// modifications made through the subform are part of the save
		If (Form:C1466.sfw.checkIsInModification())
			This:C1470.contactDetails:=This:C1470.contactDetails
		End if
	Else
		Form:C1466.subFormAddress.address:=Null:C1517
	End if
	Form:C1466.subFormAddress:=Form:C1466.subFormAddress

local Function loadAfterCreation()
	var $nextNumber : Integer
	var $maxInDb : Integer
	var $all : cs:C1710.BuyingOrderSelection
	
	// Same pattern as customerReceivedMaterial (Lot.number): reserve the next autosequence value.
	$nextNumber:=Sequence number:C244([BuyingOrder:46])
	
	// Keep in sync when existing records were imported with explicit boNumber values.
	$all:=ds:C1482.BuyingOrder.all()
	$maxInDb:=($all.length>0) ? Num:C11($all.max("boNumber")) : 0
	This:C1470.boNumber:=($maxInDb>=$nextNumber) ? ($maxInDb+1) : $nextNumber

	// Default the issue date (orderDate) to today on creation
	This:C1470.orderDate:=Current date:C33(*)

	// Default the status to Requisition on creation
	var $reqStatus : Object
	$reqStatus:=ds:C1482.BOStatus.query("name = :1"; "Requisition").first()
	If ($reqStatus#Null:C1517)
		This:C1470.UUID_Status:=$reqStatus.UUID
	End if
	
	
	