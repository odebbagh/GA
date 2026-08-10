var $refMenu : Text
var $attribut : Text
var $choose : Text
var $o : Object

Case of 
	: (FORM Event:C1606.code=On Data Change:K2:15)
		dfd_collection_save_element()
		
		
	: (FORM Event:C1606.code=On Clicked:K2:4) & (Right click:C712 | Contextual click:C713)
		$refMenu:=Create menu:C408()
		APPEND MENU ITEM:C411($refMenu; Localized string:C991("collection.editor.lb_attributs.add"); *)  // "Ajouter un attribut"
		If (Form:C1466.position_element>0)
			ENABLE MENU ITEM:C149($refMenu; -1)
		Else 
			DISABLE MENU ITEM:C150($refMenu; -1)
		End if 
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--add")
		
		APPEND MENU ITEM:C411($refMenu; Localized string:C991("collection.editor.lb_attributs.delete"); *)  //"Supprimer cet attribut"
		If (Form:C1466.position_attribute>0)
			ENABLE MENU ITEM:C149($refMenu; -1)
		Else 
			DISABLE MENU ITEM:C150($refMenu; -1)
		End if 
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--delete")
		
		APPEND MENU ITEM:C411($refMenu; "-")
		
		APPEND MENU ITEM:C411($refMenu; Localized string:C991("tool.convert.text"); *)  //"Convertir en texte"
		If (Form:C1466.position_attribute>0)
			ENABLE MENU ITEM:C149($refMenu; -1)
		Else 
			DISABLE MENU ITEM:C150($refMenu; -1)
		End if 
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--asText")
		
		APPEND MENU ITEM:C411($refMenu; Localized string:C991("tool.convert.real"); *)  //"Convertir en réel"
		If (Form:C1466.position_attribute>0)
			ENABLE MENU ITEM:C149($refMenu; -1)
		Else 
			DISABLE MENU ITEM:C150($refMenu; -1)
		End if 
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--asReal")
		
		APPEND MENU ITEM:C411($refMenu; Localized string:C991("tool.convert.date"); *)  //"Convertir en date"
		If (Form:C1466.position_attribute>0)
			ENABLE MENU ITEM:C149($refMenu; -1)
		Else 
			DISABLE MENU ITEM:C150($refMenu; -1)
		End if 
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--asDate")
		
		APPEND MENU ITEM:C411($refMenu; Localized string:C991("tool.convert.time"); *)  //"Convertir en heure"
		If (Form:C1466.position_attribute>0)
			ENABLE MENU ITEM:C149($refMenu; -1)
		Else 
			DISABLE MENU ITEM:C150($refMenu; -1)
		End if 
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--asTime")
		
		APPEND MENU ITEM:C411($refMenu; Localized string:C991("tool.convert.boolean"); *)  //"Convertir en booléen"
		If (Form:C1466.position_attribute>0)
			ENABLE MENU ITEM:C149($refMenu; -1)
		Else 
			DISABLE MENU ITEM:C150($refMenu; -1)
		End if 
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--asBool")
		
		
		
		$choose:=Dynamic pop up menu:C1006($refMenu)
		RELEASE MENU:C978($refMenu)
		
		Case of 
			: ($choose="--add")
				$attribut:=Request:C163(Localized string:C991("collection.editor.lb_attributs.add.prompt"); Localized string:C991("collection.editor.lb_attributs.add.default"))
				If (ok=1)
					$o:=New object:C1471("attribute"; $attribut; "value"; "")
					Form:C1466.lb_attributes.push($o)
					dfd_collection_save_element()
					EDIT ITEM:C870(*; "col_element_value"; Form:C1466.lb_attributes.length)
				End if 
				
			: ($choose="--delete")
				If (Form:C1466.position_attribute>0)
					CONFIRM:C162(Localized string:C991("collection.editor.lb_attributs.delete.prompt"))
					If (ok=1)
						Form:C1466.lb_attributes.remove(Form:C1466.position_attribute-1)
						dfd_collection_save_element()
					End if 
				End if 
				
			: ($choose="--asText")
				If (Form:C1466.position_attribute>0)
					Form:C1466.attribute.value:=String:C10(Form:C1466.attribute.value)
					Form:C1466.attribute.type:="text"
					dfd_collection_save_element()
					
				End if 
				
			: ($choose="--asReal")
				If (Form:C1466.position_attribute>0)
					Form:C1466.attribute.value:=Num:C11(Form:C1466.attribute.value)
					Form:C1466.attribute.type:="real"
					dfd_collection_save_element()
				End if 
				
			: ($choose="--asDate")
				If (Form:C1466.position_attribute>0)
					Form:C1466.attribute.value:=Date:C102(Form:C1466.attribute.value)
					Form:C1466.attribute.type:="date"
					dfd_collection_save_element()
				End if 
				
			: ($choose="--asBool")
				If (Form:C1466.position_attribute>0)
					Form:C1466.attribute.value:=Bool:C1537(Form:C1466.attribute.value)
					Form:C1466.attribute.type:="boolean"
					dfd_collection_save_element()
				End if 
				
			: ($choose="--asTime")
				If (Form:C1466.position_attribute>0)
					Form:C1466.attribute.value:=Time:C179(String:C10(Form:C1466.attribute.value))
					Form:C1466.attribute.type:="time"
					dfd_collection_save_element()
				End if 
				
				
				
		End case 
		
		
		
		
End case 