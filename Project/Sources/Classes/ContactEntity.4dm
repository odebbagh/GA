Class extends Entity


Function get fullName()->$fullName : Text
	$fullName:=This:C1470.firstName+" "+This:C1470.lastName
	If ($fullName=" ")
		$fullName:="##########"
	End if 
	
	
Function get pickerLabel()->$label : Text
	// "Primary - Gregorio La Rosa". The 1toN picker binds This[Form.colName], so the
	// column has to be ONE attribute - a dotted path renders empty. Putting the title in
	// front is what lets the operator tell the Primary contact from the Secondary one
	// while choosing.
	var $type : Text

	$type:=String:C10(This:C1470.title)
	$label:=($type="") ? This:C1470.fullName : $type+" - "+This:C1470.fullName
Function get companyType()->$companyType : Text
	var $company : cs:C1710.CustomerEntity
	$company:=ds:C1482.Customer.query("UUID = :1"; This:C1470.UUID_Company).first()
	$companyType:=(($company#Null:C1517) && ($company.vendor)) ? "Vendor" : "Customer"
	
	
Function set companyType()


Function get isVendor()->$isVendor : Boolean
	// queryable flag used by the customer/vendor filter on the contacts list
	$isVendor:=(This:C1470.companyType="Vendor")


Function set isVendor()


Function get companyName()->$companyName : Text
	var $customer : cs:C1710.CustomerEntity
	$customer:=ds:C1482.Customer.query("UUID = :1"; This:C1470.UUID_Company).first()
	If ($customer#Null:C1517)
		$companyName:=$customer.name
	Else
		// legacy links to the Supplier table
		var $supplier : cs:C1710.SupplierEntity
		$supplier:=ds:C1482.Supplier.query("UUID = :1"; This:C1470.UUID_Company).first()
		If ($supplier#Null:C1517)
			$companyName:=$supplier.name
		End if
	End if
	
	
local Function rebuildAddress($type : Text)->$address : Object
	$type:=String:C10($type)="" ? "main" : $type
	If (This:C1470.contactDetails#Null:C1517) && (This:C1470.contactDetails.addresses#Null:C1517)
		$addresses:=This:C1470.contactDetails.addresses.query("type = :1"; $type)
		If ($addresses.length#0)
			$address:=$addresses[0]
		End if 
	End if 
	
	
local Function rebuidComunications->$communications : Collection
	
	If (This:C1470.contactDetails#Null:C1517) && (This:C1470.contactDetails.communications#Null:C1517)
		$communications:=This:C1470.contactDetails.communications
	Else 
		$communications:=New collection:C1472()
	End if 
	
	
	//mark:-Callbacks
	
	
local Function loadAfterCreation()
	// This callback is called after creating the new item but before displaying the panel.
	This:C1470._initAddress()
	This:C1470._initCommunication()
	
	
	//mark:-Sub functions
local Function _initCommunication()
	If (This:C1470.contactDetails.communications=Null:C1517)
		This:C1470.contactDetails.communications:=New collection:C1472
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
		$mainAddress.detail.country:="FR"
		This:C1470.contactDetails.addresses.push($mainAddress)
	End if 
	
	
	
	
	

	//mark:-Printable / document attributes

	// Exposed, not local: these are read by print methods and by Write Pro formulas
	// through the document data context, not only by the panel.

Function get contactBlock()->$text : Text
	// Tel / Fax / Email as lines, for a document
	$text:=_contactDetailsBlock(This.contactDetails)

Function communication($type : Text)->$value : Text
	// One communication - "phone", "fax" or "mail"
	$value:=_contactDetailsValue(This.contactDetails; $type)

Function addressText($type : Text)->$text : Text
	// One structured address as printable lines - "billing", "shipping", "remit", "main"
	$text:=_contactDetailsAddress(This.contactDetails; $type)