Class extends DataClass

local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	
	$entry:=cs:C1710.sfw_definitionEntry.new("rma"; ["qualityAssurance"]; "RMA")
	$entry.setDataclass("RMA")
	$entry.setDisplayOrder(-500)
	$entry.setIcon("image/entry/rma-white-50x50.png")
	
	$entry.setSearchboxField("rmaNumber")
	
	
	$entry.setPanel("panel_rma"; 2)
	$entry.setPanelPage(1; ""; "Main")
	
	
	$entry.setLBItemsColumn("rmaNumber"; "#"; "width:40"; "center")
	$entry.setLBItemsColumn("qcar.customer.name"; "Customer"; "width:200")
	$entry.setLBItemsColumn("invoiceNumber"; "Invoice"; "width:140")
	$entry.setLBItemsColumn("receivedDate"; "Received"; "width:70"; "center")
	
	$entry.setLBItemsOrderBy("rmaNumber")
	
	$entry.enableTransaction()