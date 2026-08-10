var $framework : cs:C1710.sfw_item
$framework:=Form:C1466.sfw

Case of 
	: (FORM Event:C1606.code=On Load:K2:1)
		
		SET MENU BAR:C67(1)
		
		$framework.initOnLoad()
		
		Form:C1466.subForm:=New object:C1471()
		Form:C1466.situation:=New object:C1471()
		Form:C1466.situation.isInModification:=False:C215
		
		If (Form:C1466.current_item=Null:C1517)
			Form:C1466.situation.mode:="add"
			Form:C1466.sfw.cancelAndRestartTransaction()
			//Form.current_item:=ds[Form.entry.dataclass].new()
			//Form.current_item.UUID:=Generate UUID
			Form:C1466.sfw._createANewEntity()
			Form:C1466.sfw.callbackOnCurrentItem("loadAfterCreation")
		Else 
			Form:C1466.situation.mode:="view"
		End if 
		
		Form:C1466.subForm.sfw:=cs:C1710.sfw_item.new()
		Form:C1466.subForm.sfw.vision:=$framework.vision
		Form:C1466.subForm.sfw.entry:=$framework.entry
		Form:C1466.subForm.situation:=Form:C1466.situation
		
		$framework.selectionChange()
		
		Case of 
			: ($framework.entry.dataclass#Null:C1517)
				Form:C1466.sfw._displayHeaderTabFavorite()
				Form:C1466.sfw._displayHeaderTabSubscription()
				Form:C1466.sfw._displayHeaderTabAssignation()
				Form:C1466.sfw._displayHeaderTabComment()
				Form:C1466.sfw._displayHeaderTabEvent()
				cs:C1710.sfw_window.me.setWindowTitle()
				
				$framework.drawButtons()
				
		End case 
		
	: (FORM Event:C1606.code=On Resize:K2:27)
		Form:C1466.subForm:=Form:C1466.subForm
		
		
	: (FORM Event:C1606.code=On Close Box:K2:21)
		
		If ($framework.nothingToSave())
			ACCEPT:C269
			cs:C1710.sfw_commentManager.me.hide()
			cs:C1710.sfw_eventManager.me.hide()
			
		End if 
		
	: (FORM Event:C1606.code=On Clicked:K2:4)
		Case of 
			: (FORM Event:C1606.objectName="headerTabFavorite_button")
				cs:C1710.sfw_favoriteManager.me.clicOnHeader()
			: (FORM Event:C1606.objectName="headerTabSubscription_button")
				cs:C1710.sfw_subscriptionManager.me.clicOnHeader()
			: (FORM Event:C1606.objectName="headerTabAssignation_button")
				cs:C1710.sfw_assignationManager.me.clicOnHeader()
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

