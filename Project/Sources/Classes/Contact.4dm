

Class extends DataClass


local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	//Mark: entry : Contact
	$entry:=cs:C1710.sfw_definitionEntry.new("contact"; ["customerService"; "salesAndQuotes"]; "Contacts")
	$entry.setDataclass("Contact")
	$entry.setDisplayOrder(-700)
	$entry.setIcon("image/entry/contact-white-50x50.png")
	
	$entry.setSearchboxField("fullName")
	$entry.setSearchboxField("companyName"; "placeholder:companyName")
	
	$entry.setPanelPage(1; "staff-32x32.png"; "Main")
	$entry.setPanel("panel_contact")
	$entry.setLBItemsColumn("fullName"; "Full Name"; "width:200")
	$entry.setLBItemsColumn("companyName"; "Company name"; "width:200")
	//$entry.setLBItemsColumn("title"; "Title"; "width:100")
	$entry.setLBItemsOrderBy("companyName")
	$entry.setMainViewLabel("All contacts")
	
	$entry.setItemAction("Generate Barcode"; "_ga_openBarCodeForm")
	
	$entry.setItemListAction("Search by Scanning"; "_ga_searchByBarcodeScanning")
	
	$entry.enableTransaction()

	$entry.activateFavorite()


	// MARK: - Filters
	$filter:=cs:C1710.sfw_definitionFilter.new("filterCompanyType")
	$filter.setDefaultTitle("All companies")
	$filter.setFilterByBooleanExpression("isVendor = :1"; "Vendors"; "Customers")
	$entry.addFilter($filter)


	// MARK: - Views Definition


	// MARK: Customers contact
	$view:=cs:C1710.sfw_definitionView.new("customersContacts"; "Customers Contacts")
	$view.setLBItemsColumn("companyName"; "Company name"; "width:200")
	$view.setLBItemsColumn("title"; "Title"; "width:100")
	$view.setLBItemsOrderBy("companyName")
	$view.setSubset("customersContacts")
	$entry.setView($view)

	// MARK: Vendors contact
	$view:=cs:C1710.sfw_definitionView.new("vendorsContacts"; "Vendors Contacts")
	$view.setLBItemsColumn("companyName"; "Company name"; "width:200")
	$view.setLBItemsColumn("title"; "Title"; "width:100")
	$view.setLBItemsOrderBy("companyName")
	$view.setSubset("vendorsContacts")
	$entry.setView($view)


Function customersContacts()->$contacts : cs:C1710.ContactSelection
	var $customersUUIDs : Collection
	$customersUUIDs:=ds:C1482.Customer.query("vendor = :1"; False:C215).toCollection("UUID").extract("UUID")
	$contacts:=ds:C1482.Contact.query("UUID_Company IN :1"; $customersUUIDs)

Function vendorsContacts()->$contacts : cs:C1710.ContactSelection
	var $vendorsUUIDs : Collection
	$vendorsUUIDs:=ds:C1482.Customer.query("vendor = :1"; True:C214).toCollection("UUID").extract("UUID")
	$contacts:=ds:C1482.Contact.query("UUID_Company IN :1"; $vendorsUUIDs)
	
	
local Function cacheLoad()
	
	If (Storage:C1525.cache=Null:C1517)
		Use (Storage:C1525)
			Storage:C1525.cache:=New shared object:C1526
		End use 
	End if 
	If (Storage:C1525.cache.companyTypes=Null:C1517)
		$companyTypes:=This:C1470._loadAsCollection()
		Use (Storage:C1525.cache)
			Storage:C1525.cache.companyTypes:=$companyTypes.copy(ck shared:K85:29; Storage:C1525.cache)
		End use 
	End if 
	
	
local Function _loadAsCollection()->$companyTypes : Collection
	$companyTypes:=New collection:C1472("Customer"; "Vendor")
	