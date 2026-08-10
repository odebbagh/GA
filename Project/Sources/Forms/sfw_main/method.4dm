var $framework : cs:C1710.sfw_main

$framework:=Form:C1466.sfw

Case of 
	: (FORM Event:C1606.code=On Load:K2:1)
		
		$framework.initOnLoad()
		
		Form:C1466.subForm:=New object:C1471()
		Form:C1466.situation:=New object:C1471()
		Form:C1466.situation.isInModification:=False:C215
		
		Form:C1466.situation.mode:="view"  // modify, add, delete, view
		
		Form:C1466.subForm.sfw:=cs:C1710.sfw_main.new()
		Form:C1466.subForm.sfw.vision:=$framework.vision
		Form:C1466.subForm.sfw.entry:=$framework.entry
		Form:C1466.subForm.situation:=Form:C1466.situation
		
		Form:C1466.filterByFavorite:=False:C215
		Form:C1466.filterByProjection:=(Form:C1466.projection#Null:C1517)
		
		Case of 
			: ($framework.entry.dataclass#Null:C1517)
				$framework.lb_items_define()
				If ($framework.lb_items=Null:C1517) || ($framework.lb_items.length=0)
					$framework.lb_items_search()
					
				End if 
				$framework.drawButtons()
				
			: (String:C10($framework.entry.virtual)="collection")
				$framework.virtual_lb_items_define()
				$framework.virtual_lb_items_fill()
				$framework.drawButtons_virtual()
				
		End case 
		
		$framework.displayFilter()
		$framework._displayPupViews()
		$framework.lb_items_counter_format()
		
	: (FORM Event:C1606.code=On Resize:K2:27)
		Form:C1466.subForm:=Form:C1466.subForm
		OBJECT GET SUBFORM CONTAINER SIZE:C1148($form_width; $form_height)
		OBJECT GET COORDINATES:C663(*; "vSplitter"; $gvspliter; $hvspliter; $dvspliter; $bvspliter)
		OBJECT GET COORDINATES:C663(*; "bkgd_topBar"; $gtopbar; $htopbar; $dtopbar; $btopbar)
		OBJECT GET COORDINATES:C663(*; "bkgd_bottomBar"; $gbottombar; $hbottombar; $dbottombar; $bbottombar)
		OBJECT SET COORDINATES:C1248(*; "detail_panel"; $dvspliter; $btopbar; $form_width; $hbottombar)
		
		
	: (FORM Event:C1606.code=On Close Box:K2:21)
		
		If ($framework.nothingToSave())
			$framework.callbackOnEntry("closeBoxMainForm")
			cs:C1710.sfw_commentManager.me.hide()
			cs:C1710.sfw_eventManager.me.hide()
			ACCEPT:C269
		End if 
		
	: (FORM Event:C1606.code=On Unload:K2:2)
		Form:C1466.sfw.clearHierarchicalList()
		cs:C1710.sfw_commentManager.me.hide()
		
	: (FORM Event:C1606.code=On Clicked:K2:4)
		Case of 
			: (FORM Event:C1606.objectName="headerTabFavorite_button")
				cs:C1710.sfw_favoriteManager.me.clicOnHeader()
			: (FORM Event:C1606.objectName="headerTabComment_title")
				cs:C1710.sfw_commentManager.me.clicOnHeader(Form:C1466.current_item.UUID)
			: (FORM Event:C1606.objectName="headerTabEvent_title")
				cs:C1710.sfw_eventManager.me.clicOnHeader(Form:C1466.current_item.UUID; Form:C1466.sfw.entry)
		End case 
		
	: (FORM Event:C1606.code=On Deactivate:K2:10)
		cs:C1710.sfw_commentManager.me.hide()
		cs:C1710.sfw_eventManager.me.hide()
		
	: (FORM Event:C1606.code=On Activate:K2:9)
		If (Form:C1466.current_item#Null:C1517) && (Form:C1466.sfw.entry.comment#Null:C1517)
			DELAY PROCESS:C323(Current process:C322; 15)
			cs:C1710.sfw_commentManager.me.refresh(Form:C1466.current_item.UUID)
		Else 
			cs:C1710.sfw_commentManager.me.hide()
		End if 
		If (Form:C1466.current_item#Null:C1517) && (Form:C1466.sfw.entry.event#Null:C1517)
			DELAY PROCESS:C323(Current process:C322; 15)
			cs:C1710.sfw_eventManager.me.refresh(Form:C1466.current_item.UUID; Form:C1466.sfw.entry)
		Else 
			cs:C1710.sfw_eventManager.me.hide()
		End if 
		
		
		
		
End case 

$framework.displayTransactionLevel()

