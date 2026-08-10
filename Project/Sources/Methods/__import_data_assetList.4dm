//%attributes = {"executedOnServer":true}
/*
__import_assetList

*/


var $records : Collection:=New collection:C1472()
var $vendors : Text

If (True:C214)
	
	$file:=Folder:C1567(fk data folder:K87:12).file("DataJson/assetList_export.json")
	
	$records:=JSON Parse:C1218($file.getText())
	
	$assetTypes:=New collection:C1472("R&D Equipment"; "Others"; "Machinery & Equipment"; "Land"; "Improvements"; \
		"Goodwill"; "Furniture and Fixtures"; "Buildings"; "Auto / Transport Equipment"; "Amortization")
	//$records.extract("AssetType").distinct()
	
	TRUNCATE TABLE:C1051([AssetType:77])
	For ($i; 0; $assetTypes.length-1)
		
		$assetType:=ds:C1482.AssetType.new()
		$assetType.levelID:=$i+1
		$assetType.name:=$assetTypes[$i]
		$assetType.color:=""
		$assetType.save()
		
	End for 
	
	
	TRUNCATE TABLE:C1051([Asset:76])
	For each ($record; $records)
		
		$eAsset:=ds:C1482.Asset.new()
		
		$eAsset.assetNumber:=$record.Asset_num
		$type:=ds:C1482.AssetType.query("name =:1"; Split string:C1554($record.AssetType; "\r"; sk trim spaces:K86:2).join("\r"))
		If ($type.length>0)
			$eAsset.UUID_AssetType:=$type[0].UUID
		Else 
			$eAsset.UUID_AssetType:="00"*16
		End if 
		
		//$eAsset.UUID_Vendor:=$record.Vendor
		$vendor:=ds:C1482.Supplier.query("name =:1"; Split string:C1554($record.Vendor; "\r"; sk trim spaces:K86:2).join("\r"))
		If ($vendor.length>0)
			$eAsset.UUID_Vendor:=$vendor[0].UUID
		Else 
			$vendors:=$vendors+"\n"+$record.Vendor
			//Case of 
			
			//Else 
			$eAsset.UUID_Vendor:="00"*16
			
			//End case 
		End if 
		
		$eAsset.description:=$record.Comments
		$eAsset.originalCost:=$record.Cost
		$eAsset.isScrapped:=$record.Scrapped
		$eAsset.life:=$record.Life
		$eAsset.acquiredStmp:=Date:C102($record.Date_Acquired)=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build(Date:C102($record.Date_Acquired))
		$eAsset.divestStmp:=Date:C102($record.Divest_Date)=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build(Date:C102($record.Divest_Date))
		
		//$eAsset.UUID_PurchaseOrder:=$record.assetNumber
		
		//$eAsset.salvage:=$record.assetNumber
		//$eAsset.monthInService:=$record.Life
		
		//$eAsset.bookValue:=$record.Value
		//$eAsset.currentMonthDepreciation:=$record.assetNumber
		//$eAsset.totalAccDepreciation:=$record.Acc_dep
		
		//$eAsset.divestStmp:=$record.Divest_Date
		//$eAsset.excludeFmDepreciationList:=$record.ExcludeFmDepreciationList
		
		$info:=$eAsset.save()
		If (Not:C34($info.success))
			TRACE:C157
		End if 
		
	End for each 
	
	
	SET TEXT TO PASTEBOARD:C523($vendors)
End if 
