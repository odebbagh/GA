
Class extends DataClass


//local Function entryDefinition()->$entry : cs.sfw_definitionEntry
////Mark: entry : CreditMemo
//$entry:=cs.sfw_definitionEntry.new("CMItem"; ["accounting"]; "Credit Memos"; "CMItem")
//$entry.setDataclass("CMItem")
//$entry.setDisplayOrder(-300)
//$entry.setIcon("image/entry/creditMemo-white-50x50.png")

//$entry.setSearchboxField("creditMemo.cmNum")

//$entry.setPanel("panel_CreditMemo"; 1)
//$entry.setPanelPage(1; ""; "Main")

//$entry.setLBItemsColumn("creditMemo.cmNum"; "Credit Memo #"; "width:50")
//$entry.setLBItemsColumn("customer.name"; "Customer"; "width:200")
////$entry.setLBItemsColumn("description"; "description"; "width:100")
//$entry.setLBItemsColumn("creditMemo.cmTotal"; "Total"; "width:100")

//$entry.setLBItemsOrderBy("creditMemo.cmNum")
//$entry.setMainViewLabel("All Credit Memos")

//$entry.setItemListAction("Print Credit Note"; "_ga_printCreditNote")

//$entry.setItemAction("Generate Barcode"; "_ga_openBarCodeForm")

//$entry.setItemListAction("Search by Scanning"; "_ga_searchByBarcodeScanning")

//$entry.enableTransaction()

//$entry.activateFavorite()