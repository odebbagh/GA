Class extends Entity


local Function get revisionDate()->$revisionDate : Date
	$revisionDate:=cs:C1710.sfw_stmp.me.getDate(This:C1470.stmpRevisionDate; True:C214)
	
local Function set revisionDate($revisionDate : Date)
	This:C1470.stmpRevisionDate:=cs:C1710.sfw_stmp.me.build($revisionDate)
	
local Function get reviewDate()->$reviewDate : Date
	$reviewDate:=cs:C1710.sfw_stmp.me.getDate(This:C1470.stmpReviewDate; True:C214)
	
local Function set reviewDate($reviewDate : Date)
	This:C1470.stmpReviewDate:=cs:C1710.sfw_stmp.me.build($reviewDate)
	
local Function get approvalDate()->$approvalDate : Date
	$approvalDate:=cs:C1710.sfw_stmp.me.getDate(This:C1470.stmpApproval; True:C214)
	
local Function set approvalDate($approvalDate : Date)
	This:C1470.stmpApproval:=cs:C1710.sfw_stmp.me.build($approvalDate)
	
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
	
	
	
	
	
	
	//mark:-Callbacks
	
local Function afterCreation()
	
	
	
local Function loadAfterCreation()
	// This callback is called after creating the new item but before displaying the panel.
	This:C1470._initReports()
	
	
local Function itemLoad()
	// This callback is called when the item is selected in the itemList
	
	
	
	
local Function isDeletable()->$isDeletable : Boolean
	// This callback must return false to inactivate the deletion mode for the current item.
	$isDeletable:=True:C214
	
	
local Function _initReports()
	
	If (This:C1470.documents.documentsCollection=Null:C1517)
		
		This:C1470.documents.documentsCollection:=New collection:C1472()
	End if 
	
	
local Function beforeSave()
	
	If (Form:C1466.current_item.isApproved=False:C215) & (Form:C1466.current_item.isApproved#Form:C1466.current_clone.isApproved)
		
		$context:=New object:C1471
		$context.target:=Form:C1466.current_item.UUID
		$context.targetDataclass:="Specification"
		$context.spec:=Form:C1466.current_item.spec
		
		$profiles:=New collection:C1472("qm"; "qs"; "pm"; "ps"; "vp"; "gm")
		$staff:=ds:C1482.Staff.query("user.userInscriptions.userProfile.ident in :1 | memberships.team.name =:2"; $profiles; "Facilities")
		
		$users:=$staff.extract("user").extract("UUID").distinct()
		cs:C1710.sfw_notificationManager.me.notify("SpecControlApproval"; $users; $context)
		
	End if 
	
	
local Function get nameInWindowTitle()->$nameInWindowTitle : Text
	$nameInWindowTitle:=String:C10(This:C1470.spec)
	
	
	