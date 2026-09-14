Class extends Entity



local Function get dateClosed()->$dateClosed : Date
	$dateClosed:=cs:C1710.sfw_stmp.me.getDate(This:C1470.stmpClosed; True:C214)
	
local Function set dateClosed($dateClosed : Date)
	This:C1470.stmpClosed:=cs:C1710.sfw_stmp.me.build($dateClosed)
	
local Function get originalDueDate()->$originalDueDate : Date
	$originalDueDate:=cs:C1710.sfw_stmp.me.getDate(This:C1470.stmpOriginalDue; True:C214)
	
local Function set originalDueDate($originalDueDate : Date)
	This:C1470.stmpOriginalDue:=cs:C1710.sfw_stmp.me.build($originalDueDate)
	
local Function get currentDueDate()->$currentDueDate : Date
	$currentDueDate:=cs:C1710.sfw_stmp.me.getDate(This:C1470.stmpCurrentDue; True:C214)
	
local Function set currentDueDate($currentDueDate : Date)
	This:C1470.stmpCurrentDue:=cs:C1710.sfw_stmp.me.build($currentDueDate)
	
local Function get dateInitiated()->$dateInitiated : Date
	$dateInitiated:=cs:C1710.sfw_stmp.me.getDate(This:C1470.stmpInitiated; True:C214)
	
local Function set dateInitiated($dateInitiated : Date)
	This:C1470.stmpInitiated:=cs:C1710.sfw_stmp.me.build($dateInitiated)
	
local Function get eDisposition()->$disposition : Text
	
	If (This:C1470.moreData.disposition#"")
		$disposition:=This:C1470.moreData.disposition
	Else 
		$disposition:=This:C1470.disposition.name
	End if 
	
	
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
	// Purpose: Assign a unique barcode in moreData for scanner lookup on new records.
	// modified by 4D/PS [2026-june-29]
	This:C1470.moreData.barcodeData:=String:C10(cs:C1710.Util_ScannerManager.me.getBarcodeData(Form:C1466.sfw.entry.dataclass); "0000000000")
	
	// This callback is called after creating the new item but before displaying the panel.
	This:C1470._setItemNumber()
	If (This:C1470.moreData.disposition=Null:C1517)
		
		This:C1470.moreData.disposition:=""
		
	End if 
	
local Function afterCreation()
	This:C1470._setItemNumber()
	
local Function itemLoad()
	// This callback is called when the item is selected in the itemList
	This:C1470._setItemNumber()
	
	
local Function _setItemNumber()
	If (Form:C1466.current_item#Null:C1517) & (This:C1470.item=0)
		$counter:=ds:C1482.ContinuousImprovement.all().extract("item").map(Formula:C1597(Num:C11($1.value))).max()
		This:C1470.item:=$counter+1
		
	End if 
	
	