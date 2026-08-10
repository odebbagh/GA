var $refMenu : Text
var $choose : Text
var $duplicatedElement : Object
var $line : Integer
var $o : Object

Case of 
	: (FORM Event:C1606.code=On Selection Change:K2:29)
		
		dfd_collection_redraw_lb_attrs()
		
	: (FORM Event:C1606.code=On Clicked:K2:4) & (Right click:C712 | Contextual click:C713)
		// contextual menu to add / delete an item
		$refMenu:=Create menu:C408()
		APPEND MENU ITEM:C411($refMenu; Localized string:C991("collection.editor.lb_items.add"); *)  //"Ajouter un élément"
		ENABLE MENU ITEM:C149($refMenu; -1)
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--add")
		
		
		APPEND MENU ITEM:C411($refMenu; Localized string:C991("collection.editor.lb_items.duplicate"); *)  // "Dupliquer cet élément"
		If (Form:C1466.position_element>0)
			ENABLE MENU ITEM:C149($refMenu; -1)
		Else 
			DISABLE MENU ITEM:C150($refMenu; -1)
		End if 
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--duplicate")
		
		APPEND MENU ITEM:C411($refMenu; "-")
		APPEND MENU ITEM:C411($refMenu; Localized string:C991("collection.editor.lb_items.delete"); *)  //"Supprimer cet élément"
		If (Form:C1466.position_element>0)
			ENABLE MENU ITEM:C149($refMenu; -1)
		Else 
			DISABLE MENU ITEM:C150($refMenu; -1)
		End if 
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--delete")
		
		$choose:=Dynamic pop up menu:C1006($refMenu)
		RELEASE MENU:C978($refMenu)
		
		Case of 
			: ($choose="--add")
				If (Form:C1466.elements.length>0)
					$o:=OB Copy:C1225(Form:C1466.elements[Form:C1466.elements.length-1])
				Else 
					$o:=New object:C1471()
				End if 
				
				Form:C1466.elements.push($o)
				
				Form:C1466.element:=$o
				Form:C1466.position_element:=Form:C1466.elements.length
				LISTBOX SELECT ROW:C912(*; "lb_elements"; Form:C1466.elements.length; lk replace selection:K53:1)
				CALL FORM:C1391(Current form window:C827; "dfd_collection_redraw_lb_attrs")
				
			: ($choose="--delete")
				CONFIRM:C162(Localized string:C991("collection.editor.lb_items.delete.prompt"))  //"Voulez-vous vraiment supprimer cette ligne ?"
				If (ok=1)
					Form:C1466.elements.remove(Form:C1466.position_element-1)
					Form:C1466.lb_attributes:=New collection:C1472()
					
				End if 
				
			: ($choose="--duplicate")
				CONFIRM:C162(Localized string:C991("collection.editor.lb_items.duplicate.prompt"))  //"Voulez-vous vraiment dupliquer cette ligne ?"
				If (ok=1)
					$duplicatedElement:=OB Copy:C1225(Form:C1466.element)
					Form:C1466.elements.insert(Form:C1466.position_element+2; $duplicatedElement)
					Form:C1466.lb_attributes:=New collection:C1472()
					
				End if 
				
		End case 
		
		
	: (FORM Event:C1606.code=On Begin Drag Over:K2:44)
		
		
	: (FORM Event:C1606.code=On Drop:K2:12)
		$line:=Drop position:C608
		If ($line<0)
			$line:=Form:C1466.elements.length
		End if 
		$element:=Form:C1466.element
		Form:C1466.elements.remove(Form:C1466.position_element-1)
		Form:C1466.elements:=Form:C1466.elements.insert($line-1; $element)
		Form:C1466.position_element:=$line
		LISTBOX SELECT ROW:C912(*; "lb_elements"; $line; lk replace selection:K53:1)
		CALL FORM:C1391(Current form window:C827; "dfd_collection_redraw_lb_attrs")
		
End case 