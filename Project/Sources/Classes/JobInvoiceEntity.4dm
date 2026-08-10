Class extends Entity


local Function get invoiceDate()->$invoiceDate : Date
	$invoiceDate:=This:C1470.invoiceStmp=0 ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate(This:C1470.invoiceStmp; True:C214)
	
local Function set invoiceDate($invoiceDate : Date)
	This:C1470.invoiceStmp:=$invoiceDate=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build($invoiceDate)
	
local Function drowPup($dataClass; $queryField; $queryValue; $pupName; $displayField)
	
	$entity:=ds:C1482[$dataClass].query($queryField+" =:1"; Form:C1466.current_item[$queryValue]).first() || New object:C1471()
	$name:=String:C10($entity[$displayField])  //.name
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
	
	
local Function pup($cacheCollection; $dataClass; $queryField; $queryValue; $displayField)
	
	If (Form:C1466.sfw.checkIsInModification())
		$menu:=Create menu:C408
		If (Storage:C1525.cache=Null:C1517) || (Storage:C1525.cache[$cacheCollection]=Null:C1517)
			ds:C1482[$dataClass].cacheLoad()
		End if 
		
		For each ($eEntity; Storage:C1525.cache[$cacheCollection])
			APPEND MENU ITEM:C411($menu; String:C10($eEntity[$displayField]); *)
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
	
	
local Function get nameInWindowTitle()->$nameInWindowTitle : Text
	$nameInWindowTitle:=String:C10(This:C1470.invoiceNumber)
	
Function get type()->$type : Text
	$type:=This:C1470.job.lineItem=True:C214 ? "Not Related Job Order" : "Job Lot Related"
	
local Function afterCreation()
	This:C1470._initDataOnCreation()
	
local Function loadAfterCreation()
	// This callback is called after creating the new item but before displaying the panel.
	This:C1470._initDataOnCreation()
	
local Function itemLoad()
	// This callback is called when the item is selected in the itemList
	This:C1470._initDataOnCreation()
	
	
local Function isDeletable()->$isDeletable : Boolean
	// This callback must return false to inactivate the deletion mode for the current item.
	$isDeletable:=True:C214
	
	
	//mark:-Sub functions
	
local Function _initDataOnCreation()
	If (Form:C1466.current_item#Null:C1517) & (This:C1470.invoiceNumber="")
		$counter:=ds:C1482.JobInvoice.all().extract("invoiceNumber").map(Formula:C1597(Num:C11($1.value))).max()
		This:C1470.invoiceNumber:=String:C10($counter+1; "00000#")
		
	End if 
	
	
	
	