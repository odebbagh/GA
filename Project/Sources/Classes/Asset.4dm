
Class extends DataClass


local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	//Mark: entry : Asset
	$entry:=cs:C1710.sfw_definitionEntry.new("Asset"; ["accounting"]; "Assets"; "Asset")
	$entry.setDataclass("Asset")
	$entry.setDisplayOrder(-200)
	$entry.setIcon("image/entry/asset-white-50x50.png")
	
	$entry.setSearchboxField("assetNumber")
	
	$entry.setPanel("panel_asset"; 1)
	$entry.setPanelPage(1; ""; "Main")
	$entry.setPanelPage(2; ""; "Deprecation History")
	$entry.setSubset("main")
	
	$entry.setLBItemsColumn("assetNumber"; "Asset #"; "width:50")
	$entry.setLBItemsColumn("description"; "Description"; "width:200")
	$entry.setLBItemsColumn("originalCost"; "Original Cost"; "width:100")
	
	$entry.setLBItemsOrderBy("assetNumber")
	$entry.setMainViewLabel("All assets")
	
	$entry.setItemListAction("View Depreciation History"; "_ga_viewDepreciationHistory")
	$entry.setItemListAction("Print Asset List"; "_ga_printAssetSelection")
	$entry.setItemListAction("Export Asset List"; "_ga_exportAssetSelection")
	$entry.setItemListAction("Activate Automatique Depreciation"; "_ga_activateAutomatiqueDepreciation")
	
	$entry.setItemAction("Generate Barcode"; "_ga_openBarCodeForm")
	
	$entry.setItemListAction("Search by Scanning"; "_ga_searchByBarcodeScanning")
	
	$entry.enableTransaction()
	
	$entry.activateFavorite()
	
	
	
	// MARK: -Views
	
	$view:=cs:C1710.sfw_definitionView.new("fullyDepreciatedAssets"; "Assets fully Depreciated [Not Archived]"; "derivedFrom:main"; $entry)
	$view.setSubset("fullyDepreciatedAssets")
	$view.setPictoLabel("/RESOURCES/ga/image/picto/assets-16x16.png")
	$entry.setView($view)
	
	
	$view:=cs:C1710.sfw_definitionView.new("archivedorScrappedAssets"; "Archived or Scrapped Assets"; "derivedFrom:main"; $entry)
	$view.setSubset("archivedorScrappedAssets")
	$view.setPictoLabel("/RESOURCES/ga/image/picto/assets-16x16.png")
	$entry.setView($view)
	
Function main()->$assets : cs:C1710.AssetSelection
	$assets:=ds:C1482.Asset.query("excludeFmDepreciationList =:1"; False:C215)
	
Function fullyDepreciatedAssets()->$assets : cs:C1710.AssetSelection
	$assets:=ds:C1482.Asset.query("excludeFmDepreciationList =:1"; True:C214)
	
Function archivedorScrappedAssets()->$assets : cs:C1710.AssetSelection
	$assets:=ds:C1482.Asset.query("excludeFmDepreciationList =:1 & isScrapped =:2"; False:C215; True:C214)
	
	
	
	