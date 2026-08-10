Class extends Entity


local Function get nameInWindowTitle()->$nameInWindowTitle : Text
	$nameInWindowTitle:=String:C10(This:C1470.jobNumber)
	
	
Function get quoteCode()->$code : Text
	
	If (This:C1470.purchaseOrderLines.first()#Null:C1517)
		$po:=This:C1470.purchaseOrderLines.first().purchaseOrder
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
		This:C1470.jobNumber:=ds:C1482.Job.all().max("jobNumber")+1
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