Class extends Entity


local Function get creationDate()->$creationDate : Date
	$creationDate:=cs:C1710.sfw_stmp.me.getDate(This:C1470.stmpCreationDate; True:C214)
	
local Function set creationDate($creationDate : Date)
	This:C1470.stmpCreationDate:=cs:C1710.sfw_stmp.me.build($creationDate)
	
	
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
				If ($eEntity#Null:C1517)
					Form:C1466.current_item[$queryValue]:=$eEntity[$queryField]
				End if 
		End case 
		
	End if 
	
	
	
	//mark:-Callbacks
	
local Function itemLoad()
	// This callback is called when the item is selected in the itemList
	//This._initDocument()
	
Function beforeSaveCreation()
	This:C1470._initDocument()
	If (Form:C1466.situation.mode="add")
		This:C1470.managementReviewNumber:=ds:C1482.ManagementReview.all().extract("managementReviewNumber").map(Formula:C1597($1.value)).max()+1
	End if 
	If (This:C1470.creationDate=!00-00-00!)
		This:C1470.creationDate:=Current date:C33(*)
	End if 
	
	
local Function afterCreation()
	//This._initDocument()
	
local Function _initDocument()
	
	If (Form:C1466.situation.mode="add")
		
		// Purpose: New reviews attach files via sfw_Document; embedded blob is not used — UUID_sfwDocument links framework rows after upload (_ga_managementReview_replaceAttchment).
		// modified by 4D/PS [2026-may-08]
		$doc:=New object:C1471
		
		$doc.code:=""
		$doc.creationDateTimeStamp:=0
		$doc.documentPath:=""
		$doc.sourcePath:=""
		$doc.description:=""
		$doc.approvalDate:=!00-00-00!
		$doc.approvedBy:=""
		$doc.isApproved:=False:C215
		$doc.UUID_sfwDocument:=""
		$doc.extension:=""
		
		This:C1470.document:=$doc
		
	End if 
	
	
local Function get nameInWindowTitle()->$nameInWindowTitle : Text
	$nameInWindowTitle:=String:C10(This:C1470.managementReviewNumber)

// Purpose: Initialize barcode data when a new record is created in the entry panel.
// created by 4D/PS [2026-june-29]
local Function loadAfterCreation()
	// Purpose: Assign a unique barcode in moreData for scanner lookup on new records.
	// modified by 4D/PS [2026-june-29]
	This:C1470.moreData.barcodeData:=String:C10(cs:C1710.Util_ScannerManager.me.getBarcodeData(Form:C1466.sfw.entry.dataclass); "0000000000")
