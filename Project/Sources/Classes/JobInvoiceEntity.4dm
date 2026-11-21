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
	Case of
		: (This:C1470.job=Null:C1517)
			$type:="Legacy invoice (job archived in legacy)"
		: (This:C1470.job.lineItem=True:C214)
			$type:="Not Related Job Order"
		Else
			$type:="Job Lot Related"
	End case
	
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
	// Only a draft can be deleted: a posted invoice is voided (ga_invoicePosting), its number stays.
	$isDeletable:=(This:C1470.stateText="Draft")


	//mark:-Accounting (ga_invoicePosting)

	// Draft, Posted, Posted in legacy, Void
local Function get stateText()->$text : Text
	$text:=cs:C1710.ga_invoicePosting.me.stateText(This:C1470)

local Function get termText()->$text : Text
	$text:=(This:C1470.paymentTerm=Null:C1517) ? "" : This:C1470.paymentTerm.label

	// "11/15/2026 by Omar" once posted here; "in legacy" for the older ones
local Function get postedText()->$text : Text
	Case of
		: (This:C1470.postedStmp#0)
			$text:=String:C10(cs:C1710.sfw_stmp.me.getDate(This:C1470.postedStmp))+((This:C1470.postedBy=Null:C1517) ? "" : " by "+This:C1470.postedBy.fullName)
		: (cs:C1710.ga_invoicePosting.me.isLegacyPosted(This:C1470))
			$text:="in legacy"
	End case

local Function get dueDate()->$date : Date
	$date:=(This:C1470.dueStmp=0) ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate(This:C1470.dueStmp)

	// what the panel can still change: a draft, or a posted invoice whose month is open. Legacy
	// posted invoices (their amount is in the opening balance) and void ones are read-only.
local Function get isEditable()->$editable : Boolean
	Case of
		: (This:C1470.status="Void")
		: (cs:C1710.ga_invoicePosting.me.isLegacyPosted(This:C1470))
		: (cs:C1710.ga_invoicePosting.me.isPosted(This:C1470))
			$editable:=cs:C1710.ga_ledger.me.isOpen(cs:C1710.ga_invoicePosting.me.accountingDate(This:C1470))
		Else
			$editable:=True:C214
	End case

local Function get canPost()->$can : Boolean
	$can:=(This:C1470.stateText="Draft")

local Function get canUnpost()->$can : Boolean
	$can:=cs:C1710.ga_invoicePosting.me.isPosted(This:C1470) && This:C1470.isEditable

	// what is still to be paid (ga_receivables): 0 for a draft or a void invoice
local Function get balanceDue()->$amount : Real
	$amount:=cs:C1710.ga_receivables.me.openBalance(This:C1470; "")

	// a payment can be applied: in the books (here or open from legacy) with a balance due
local Function get canReceivePayment()->$can : Boolean
	$can:=(This:C1470.status="Posted") && Not:C34(cs:C1710.sfw_string.me.isAnEmptyUUID(This:C1470.UUID_Customer)) && (This:C1470.balanceDue>0)

local Function get canVoid()->$can : Boolean
	$can:=(This:C1470.stateText="Draft") || This:C1470.canUnpost

	// a posted invoice edited in the panel: its entry and the PO follow (inside the panel's
	// transaction, so Cancel puts everything back)
local Function afterSave()
	var $result : Object
	If (Bool:C1537(Form:C1466.info.success)) && cs:C1710.ga_invoicePosting.me.isPosted(This:C1470)
		$result:=cs:C1710.ga_invoicePosting.me.repost(This:C1470)
		If (Not:C34($result.success))
			cs:C1710.sfw_dialog.me.alert("The invoice is saved but its accounting entry was not updated:\r"+$result.errors.join("\r")+"\r\rCancel your changes, or fix the problem and save again.")
		End if
	End if
	
	
	//mark:-Sub functions
	
local Function _initDataOnCreation()
	If (Form:C1466.current_item#Null:C1517) & (This:C1470.invoiceNumber="")
		$counter:=ds:C1482.JobInvoice.all().extract("invoiceNumber").map(Formula:C1597(Num:C11($1.value))).max()
		This:C1470.invoiceNumber:=String:C10($counter+1; "00000#")
		
	End if 
	
	
	
	