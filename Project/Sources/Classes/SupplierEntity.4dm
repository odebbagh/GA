Class extends Entity


local Function get nextAuditDate()->$nextAuditDate : Date
	$nextAuditDate:=cs:C1710.sfw_stmp.me.getDate(This:C1470.stmpNextAudit; True:C214)
	
local Function set nextAuditDate($nextAuditDate : Date)
	This:C1470.stmpNextAudit:=cs:C1710.sfw_stmp.me.build($nextAuditDate)
	
	
local Function get lastAuditDate()->$lastAuditDate : Date
	$lastAuditDate:=cs:C1710.sfw_stmp.me.getDate(This:C1470.stmpLastAudit; True:C214)
	
local Function set lastAuditDate($lastAuditDate : Date)
	This:C1470.stmpLastAudit:=cs:C1710.sfw_stmp.me.build($lastAuditDate)
	
	
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
	
	
local Function rebuildAddress()->$address : Object
	
	Case of 
		: (Form:C1466.mainAddress=1)
			$type:="main"
		: (Form:C1466.remitAddress=1)
			$type:="remit"
	End case 
	
	If (Form:C1466.current_item.contactDetails#Null:C1517) && (Form:C1466.current_item.contactDetails.addresses#Null:C1517)
		$address:=Form:C1466.current_item.contactDetails.addresses.query("type =:1"; $type).first()
		Form:C1466.subFormAddress.address:=$address
	End if 
	Form:C1466.subFormAddress:=Form:C1466.subFormAddress
	
	
local Function rebuildContact()->$contacts : Collection
	var $communication : cs:C1710.ContactEntity
	Case of 
		: (Form:C1466.primaryContact=1)
			$type:="Primary"
		: (Form:C1466.secondaryContact=1)
			$type:="Secondary"
	End case 
	$contacts:=New collection:C1472()
	$communication:=ds:C1482.Contact.query("UUID_Company =:1"; Form:C1466.current_item.UUID).query("title=:1"; $type).first()
	If ($communication#Null:C1517)
		$communications:=$communication.contactDetails.communications
		For ($i; 0; $communications.length-1)
			
			$object:=New object:C1471
			$Object.name:=$communications[$i].type
			$Object.value:=$communications[$i].contact
			$Object.comment:=$communications[$i].comment
			$contacts.push($Object)
			
		End for 
		
	End if 
	Form:C1466.lb_contact:=$contacts
	
	
	
	//mark:-Callbacks
	
local Function beforeSave()
	
	If (Form:C1466.current_item.nextAuditDate#!00-00-00!) & (Form:C1466.current_item.nextAuditDate<=Current date:C33(*)) & (Form:C1466.current_item.critical=True:C214) & (Form:C1466.current_item.critical#Form:C1466.current_clone.critical)
		
		$context:=New object:C1471
		$context.target:=Form:C1466.current_item.UUID
		$context.targetDataclass:="Supplier"
		$context.name:=Form:C1466.current_item.name
		
		$profiles:=New collection:C1472("qm"; "qs"; "pm"; "ps"; "vp"; "gm")
		$staff:=ds:C1482.Staff.query("user.userInscriptions.userProfile.ident in :1 | memberships.team.name =:2"; $profiles; "Facilities")
		
		$users:=$staff.extract("user").extract("UUID").distinct()
		cs:C1710.sfw_notificationManager.me.notify("CriticalSuppliersWithOverdueAudits"; $users; $context)
		
	End if 
	
	
local Function afterCreation()
	This:C1470._initAddress()
	This:C1470._initattachedDocuments()
	
local Function loadAfterCreation()
	// This callback is called after creating the new item but before displaying the panel.
	This:C1470._initAddress()
	This:C1470._initattachedDocuments()
	
local Function itemLoad()
	// This callback is called when the item is selected in the itemList
	This:C1470._initAddress()
	This:C1470._initattachedDocuments()
	
	
local Function isDeletable()->$isDeletable : Boolean
	// This callback must return false to inactivate the deletion mode for the current item.
	$isDeletable:=True:C214
	
	
	//mark:-Sub functions
	
local Function _initattachedDocuments()
	
	If (This:C1470.attachedDocuments.documents=Null:C1517)
		
		This:C1470.attachedDocuments.documents:=New collection:C1472()
		
	End if 
	
	
	If (ds:C1482.Contact.query("UUID_Company=:1"; This:C1470.UUID).extract("title").indexOf("Primary")=-1)
		var $apContact : cs:C1710.ContactEntity
		$apContact:=ds:C1482.Contact.new()
		$apContact.title:="Primary"
		$apContact.UUID_Company:=This:C1470.UUID
		
		$apContact.contactDetails:=New object:C1471
		
		$apContact.contactDetails.addresses:=New collection:C1472
		
		$mainAddress:=$apContact.contactDetails.addresses.query("type = :1"; "main").first()
		If ($mainAddress=Null:C1517)
			$mainAddress:=New object:C1471
			$mainAddress.type:="main"
			$mainAddress.detail:=New object:C1471
			$mainAddress.detail.country:="US"
			$apContact.contactDetails.addresses.push($mainAddress)
		End if 
		
		$apContact.contactDetails.communications:=New collection:C1472
		
		$apContact.save()
	End if 
	
	If (ds:C1482.Contact.query("UUID_Company=:1"; This:C1470.UUID).extract("title").indexOf("Secondary")=-1)
		var $statusContact : cs:C1710.ContactEntity
		$statusContact:=ds:C1482.Contact.new()
		$statusContact.title:="Secondary"
		$statusContact.UUID_Company:=This:C1470.UUID
		
		$statusContact.contactDetails:=New object:C1471
		
		$statusContact.contactDetails.addresses:=New collection:C1472
		
		$mainAddress:=$statusContact.contactDetails.addresses.query("type = :1"; "main").first()
		If ($mainAddress=Null:C1517)
			$mainAddress:=New object:C1471
			$mainAddress.type:="main"
			$mainAddress.detail:=New object:C1471
			$mainAddress.detail.country:="US"
			$statusContact.contactDetails.addresses.push($mainAddress)
		End if 
		
		$statusContact.contactDetails.communications:=New collection:C1472
		
		$statusContact.save()
	End if 
	
	
local Function _initAddress()
	// This callback is called when the item is selected in the itemList
	If (This:C1470.contactDetails=Null:C1517)
		This:C1470.contactDetails:=New object:C1471
	End if 
	If (This:C1470.contactDetails.addresses=Null:C1517)
		This:C1470.contactDetails.addresses:=New collection:C1472
	End if 
	$mainAddress:=This:C1470.contactDetails.addresses.query("type = :1"; "main").first()
	If ($mainAddress=Null:C1517)
		$mainAddress:=New object:C1471
		$mainAddress.type:="main"
		$mainAddress.detail:=New object:C1471
		$mainAddress.detail.country:=cs:C1710.sfw_definition.me.globalParameters.address.defaultCountry
		This:C1470.contactDetails.addresses.push($mainAddress)
	End if 
	
	$secondaryAddress:=This:C1470.contactDetails.addresses.query("type = :1"; "remit").first()
	If ($secondaryAddress=Null:C1517)
		$secondaryAddress:=New object:C1471
		$secondaryAddress.type:="remit"
		$secondaryAddress.detail:=New object:C1471
		$secondaryAddress.detail.country:=cs:C1710.sfw_definition.me.globalParameters.address.defaultCountry
		This:C1470.contactDetails.addresses.push($secondaryAddress)
	End if 
	
	
// Builds the aggregated monthly rating data for this supplier from its buying order lines.
// Returns a collection of objects, one per month, with LAR and composite rating computed.
// Used by panel_supplier.loadRatingData() and _ga_exportAllSupplierRatings.
local Function buildRatingData()->$data : Collection
	var $buyingOrders : cs:C1710.BuyingOrderSelection
	var $object : Object:=New object:C1471()
	var $data : Collection:=New collection:C1472()
	var $quarter : Integer
	
	$buyingOrders:=ds:C1482.BuyingOrder.query("UUID_Supplier =:1"; This:C1470.UUID)
	$buyingOrderLines:=New collection:C1472()
	
	If ($buyingOrders#Null:C1517)
		For each ($buyingOrder; $buyingOrders)
			$formula:=Formula:C1597(($1.value.expectedDeliveryDate#!00-00-00!) & ($1.value.actualDeliveryDate#!00-00-00!))
			$buyingOrderLines:=$buyingOrderLines.concat($buyingOrder.boLines.toCollection().filter($formula))
		End for each 
	End if 
	
	For ($i; 0; $buyingOrderLines.length-1)
		
		$year:=String:C10(Year of:C25($buyingOrderLines[$i].orderDate))
		If (Not:C34(OB Is defined:C1231($object; $year)))
			OB SET:C1220($object; $year; New object:C1471())
		End if 
		
		$month:=String:C10(Month of:C24($buyingOrderLines[$i].orderDate); "0#")
		$date:=$month+"-"+$year
		
		$indices:=$data.indices("date =:1"; $date)
		If ($indices.length=0)
			
			OB SET:C1220($object[$year]; $month; New collection:C1472())
			$quarter:=(Num:C11($month)<=3) ? 1 : (Num:C11($month)>3) && (Num:C11($month)<=6) ? 2 : (Num:C11($month)>6) && (Num:C11($month)<=9) ? 3 : 4
			
			$line:=New object:C1471(\
				"date"; $date; \
				"year"; $year; \
				"month"; $month; \
				"quarter"; $quarter; \
				"receivingTotalLots"; $buyingOrderLines[$i].qty; \
				"receivingWithoutNMNs"; $buyingOrderLines[$i].qtyReceived; \
				"receivingLAR"; 0; \
				"functionalTotalLots"; $buyingOrderLines[$i].qtyReceived; \
				"functionalWithoutNMNs"; $buyingOrderLines[$i].qtyFunctional; \
				"functionalLAR"; 0; \
				"deliveryTotalLots"; $buyingOrderLines[$i].qtyReceived; \
				"deliveryMinorDelay"; $buyingOrderLines[$i].qtyDeliveredMinDelay; \
				"deliveryMajorDelay"; $buyingOrderLines[$i].qtyDeliveredMajDelay; \
				"deliveryLAR"; 0; \
				"compositeOverAllRating"; 0; \
				"ISOCertified"; "N"\
				)
			$data.push($line)
			
		Else 
			
			$lineItem:=$data[$indices[0]]
			$lineItem.receivingTotalLots:=$lineItem.receivingTotalLots+$buyingOrderLines[$i].qty
			$lineItem.receivingWithoutNMNs:=$lineItem.receivingWithoutNMNs+$buyingOrderLines[$i].qtyReceived
			$lineItem.functionalTotalLots:=$lineItem.functionalTotalLots+$buyingOrderLines[$i].qtyReceived
			$lineItem.functionalWithoutNMNs:=$lineItem.functionalWithoutNMNs+$buyingOrderLines[$i].qtyFunctional
			$lineItem.deliveryTotalLots:=$lineItem.deliveryTotalLots+$buyingOrderLines[$i].qtyReceived
			$lineItem.deliveryMinorDelay:=$lineItem.deliveryMinorDelay+$buyingOrderLines[$i].qtyDeliveredMinDelay
			$lineItem.deliveryMajorDelay:=$lineItem.deliveryMajorDelay+$buyingOrderLines[$i].qtyDeliveredMajDelay
			$data.remove($indices[0])
			$data.push($lineItem)
			
		End if 
		
	End for 
	
	For ($i; 0; $data.length-1)
		$data[$i].receivingLAR:=($data[$i].receivingWithoutNMNs/$data[$i].receivingTotalLots)*100
		$data[$i].functionalLAR:=($data[$i].functionalWithoutNMNs/$data[$i].functionalTotalLots)*100
		$data[$i].deliveryLAR:=(100-(($data[$i].deliveryMinorDelay*0.5)+($data[$i].deliveryMajorDelay*1.5)))/100
		$data[$i].compositeOverAllRating:=($data[$i].receivingLAR+$data[$i].functionalLAR+$data[$i].deliveryLAR)/3
	End for 
	

local Function get nameInWindowTitle()->$nameInWindowTitle : Text
	$nameInWindowTitle:=String:C10(This:C1470.name)
	
	
	