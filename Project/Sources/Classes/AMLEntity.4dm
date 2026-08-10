Class extends Entity


local Function get approvalDate()->$approvalDate : Date
	$approvalDate:=cs:C1710.sfw_stmp.me.getDate(This:C1470.stmpApproval; True:C214)
	
local Function set approvalDate($approvalDate : Date)
	This:C1470.stmpApproval:=cs:C1710.sfw_stmp.me.build($approvalDate)
	
	
	
local Function rebuildAddress()->$address : Object
	
	
	If (Form:C1466.current_item#Null:C1517)
		
		If (Form:C1466.current_item.supplier#Null:C1517)
			
			If (OB Is defined:C1231(Form:C1466.current_item.supplier.contactDetails; "addresses"))
				$address:=Form:C1466.current_item.supplier.contactDetails.addresses.query("type =:1"; "main").first()
			End if 
		End if 
		Form:C1466.subFormAddress.address:=$address
		
	End if 
	Form:C1466.subFormAddress:=Form:C1466.subFormAddress
	
	
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
		$pathIcon:="sfw/colors/GhostWhite-circle.png"
	End if 
	Form:C1466.sfw.drawButtonPup($pupName; $name; $pathIcon; ($entity=Null:C1517))
	
	
local Function pup($cacheCollection; $dataClass; $queryField; $queryValue)
	
	If (Form:C1466.sfw.checkIsInModification())
		$menu:=Create menu:C408
		If (Storage:C1525.cache=Null:C1517) || (Storage:C1525.cache[$cacheCollection]=Null:C1517)
			ds:C1482[$dataClass].cacheLoad()
		End if 
		
		For each ($eImprovementPriority; Storage:C1525.cache[$cacheCollection])
			APPEND MENU ITEM:C411($menu; $eImprovementPriority.name; *)
			SET MENU ITEM PARAMETER:C1004($menu; -1; $eImprovementPriority.UUID)
			If ($eImprovementPriority[$queryField]=Form:C1466.current_item[$queryValue])
				SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
				If (Is Windows:C1573)
					SET MENU ITEM STYLE:C425($menu; -1; Bold:K14:2)
				End if 
			End if 
		End for each 
		$choose:=Dynamic pop up menu:C1006($menu)
		RELEASE MENU:C978($menu)
		
		Case of 
			: ($choose#"")
				$eImprovementPriority:=ds:C1482[$dataClass].get($choose)
				Form:C1466.current_item[$queryValue]:=$eImprovementPriority[$queryField]
		End case 
		
	End if 
	
local Function afterCreation()
	This:C1470._initattachedDocuments()
	
local Function loadAfterCreation()
	// This callback is called after creating the new item but before displaying the panel.
	This:C1470._initattachedDocuments()
	
local Function itemLoad()
	// This callback is called when the item is selected in the itemList
	This:C1470._initattachedDocuments()
	
	
local Function isDeletable()->$isDeletable : Boolean
	// This callback must return false to inactivate the deletion mode for the current item.
	$isDeletable:=True:C214
	
	
	//mark:-Sub functions
	
local Function _initattachedDocuments()
	
	If (This:C1470.attachedDocuments.documents=Null:C1517)
		
		This:C1470.attachedDocuments.documents:=New collection:C1472()
		
	End if 
	
	
local Function get nameInWindowTitle()->$nameInWindowTitle : Text
	$nameInWindowTitle:=String:C10(This:C1470.ourPartNum)
	
	
	