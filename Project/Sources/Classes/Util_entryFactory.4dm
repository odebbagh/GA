// ============================================
// Class: GA Entry Generator 
// ============================================

property projectFolder : 4D:C1709.Folder
property sources : 4D:C1709.Folder
property errors : Collection
property warnings : Collection

Class constructor
	
	This:C1470.projectFolder:=Folder:C1567(fk database folder:K87:14)
	This:C1470.sources:=This:C1470.projectFolder.folder("Project/Sources")
	This:C1470.errors:=New collection:C1472()
	This:C1470.warnings:=New collection:C1472()
	
	// -------------------------------------------------------------------
	// buildEntry
	// -------------------------------------------------------------------
Function buildEntry($tableName : Text; $moduleName : Text; $listFields : Collection; $position : Integer; $searchField : Text; $titleField : Text; $entryImagePath : Text)
	
	// 1. Create necessary folders
	This:C1470.createFolders($tableName)
	
	// 2. Create necessary files
	This:C1470.generateDataClass($tableName; $moduleName; $listFields; $position; $searchField; $entryImagePath)
	This:C1470.generateEntityClass($tableName; $titleField)
	This:C1470.generatePanelClass($tableName)
	This:C1470.generateFormJson($tableName)
	
	// 3. Reload
	RELOAD PROJECT:C1739
	
	// 4. Display results
	If (This:C1470.errors.length=0)
		ALERT:C41("✅ Successful entry creation for table "+$tableName)
	Else 
		ALERT:C41("⚠️ Entry creation "+String:C10(This:C1470.errors.length)+" error(s)")
	End if 
	
	
	// -------------------------------------------------------------------
	// createFolders
	// -------------------------------------------------------------------
Function createFolders($tableName : Text)
	
	// Classes folder
	$classesFolder:=This:C1470.sources.folder("Classes")
	If (Not:C34($classesFolder.exists))
		$classesFolder.create()
		If (Not:C34($classesFolder.exists))
			This:C1470.errors.push("Unable to create Classes folder")
		End if 
	End if 
	
	// Forms/panel_xxx folder
	$formName:="panel_"+This:C1470.firstLetterLowerCase($tableName)
	$formsFolder:=This:C1470.sources.folder("Forms")
	If (Not:C34($formsFolder.exists))
		$formsFolder.create()
	End if 
	$panelFolder:=$formsFolder.folder($formName)
	If (Not:C34($panelFolder.exists))
		$panelFolder.create()
	End if 
	
	// ObjectMethods folder
	$objMethodsFolder:=$panelFolder.folder("ObjectMethods")
	If (Not:C34($objMethodsFolder.exists))
		$objMethodsFolder.create()
	End if 
	
	
	
	// -------------------------------------------------------------------
	// generateDataClass 
	// -------------------------------------------------------------------
Function generateDataClass($tableName : Text; $moduleName : Text; $listFields : Collection; $position : Integer; $searchField : Text; $entryImagePath : Text)
	
	$file:=This:C1470.sources.folder("Classes").file($tableName+".4dm")
	
	// Build code
	$code:="Class extends DataClass\n\n"
	$code+="// ----------------------------------------------\n"
	$code+="// entryDefinition\n"
	$code+="// ----------------------------------------------\n"
	$code+="\nlocal Function entryDefinition()->$entry : cs.sfw_definitionEntry\n"
	$code+="\t$entry:=cs.sfw_definitionEntry.new(\""+$tableName+"\"; [\""+$moduleName+"\"]; \""+$tableName+"s\")\n"
	$code+="\t$entry.setDataclass(\""+$tableName+"\")\n"
	$code+="\t$entry.setDisplayOrder("+String:C10($position)+")\n"
	$code+="\t$entry.setIcon(\"image/entry/"+$entryImagePath+"\")\n\n"
	$code+="\t$entry.setSearchboxField(\""+$searchField+"\")\n\n"
	$code+="\t$entry.setPanel(\"panel_"+This:C1470.firstLetterLowerCase($tableName)+"\")\n\n"
	$code+="\t$entry.setPanelPage(1; \"\"; \"Main\")\n\n"
	
	// Listbox columns
	For each ($field; $listFields)
		$code+="\t$entry.setLBItemsColumn(\""+$field.name+"\"; \""+$field.label+"\"; \"width:"+$field.width+"\")\n"
	End for each 
	
	$code+="\t$entry.setLBItemsOrderBy(\""+$searchField+"\")\n\n"
	$code+="\t$entry.enableTransaction()\n\n"
	$code+="\t$entry.activateComment()\n\n"
	
	$code+="\n"
	
	// Write with verification
	This:C1470.writeFile($file; $code)
	
	
	
	// -------------------------------------------------------------------
	// generateEntityClass
	// -------------------------------------------------------------------
Function generateEntityClass($tableName : Text; $field : Text)
	
	$file:=This:C1470.sources.folder("Classes").file($tableName+"Entity.4dm")
	
	$code:="Class extends Entity\n\n"
	
	$code+="// ----------------------------------------------\n"
	$code+="// nameInWindowTitle\n"
	$code+="// ----------------------------------------------\n"
	$code+="local Function get nameInWindowTitle()->$nameInWindowTitle : Text\n"
	$code+="\t$nameInWindowTitle:=String(This."+$field+")\n\n"
	$code+="\n"
	
	This:C1470.writeFile($file; $code)
	
	
	// -------------------------------------------------------------------
	// generatePanelClass
	// -------------------------------------------------------------------
Function generatePanelClass($tableName : Text)
	
	$className:="panel_"+This:C1470.firstLetterLowerCase($tableName)
	$file:=This:C1470.sources.folder("Classes").file($className+".4dm")
	
	$code:="// ============================================\n"
	$code+="// Class: "+$className+"\n"
	$code+="// ============================================\n\n"
	$code+="singleton Class constructor\n"
	$code+="\t// It's a singleton class\n"
	$code+="\n\n"
	$code+="// ----------------------------------------------\n"
	$code+="// _activate_save_cancel_button\n"
	$code+="// ----------------------------------------------\n"
	$code+="Function _activate_save_cancel_button()\n"
	$code+="\tForm.current_item.UUID:=Form.current_item.UUID\n\n"
	$code+="// ----------------------------------------------\n"
	$code+="// formMethod\n"
	$code+="// ----------------------------------------------\n"
	$code+="Function formMethod()\n"
	$code+="\t// This function manages the main logic for updating and refreshing the form\n"
	$code+="\tForm.sfw.panelFormMethod()  // The main body of the form method and basic sfw functionalities\n"
	$code+="\tIf (Form.sfw.updateOfPanelNeeded())  // The current item is changed or reloaded, so it's necessary to refresh\n"
	$code+="\t\t// Add refresh logic here if needed\n"
	$code+="\tEnd if\n"
	$code+="\tIf (Form.sfw.recalculationOfPanelPageNeeded())  // A page is displayed so it's time to load the data sources\n"
	$code+="\t\tCase of\n"
	$code+="\t\t\t: (FORM Get current page(*)=1)\n"
	$code+="\t\t\t\t// add load functions for page 1\n"
	$code+="\t\tEnd case\n"
	$code+="\tEnd if\n"
	$code+="\tIf (Form.sfw.redrawAndSetVisibleInPanelNeeded())  // It's time to resize the object or set visibility\n"
	$code+="\t\tThis.redrawAndSetVisible()\n"
	$code+="\tEnd if\n"
	$code+="\n\n"
	$code+="// ----------------------------------------------\n"
	$code+="// redrawAndSetVisible\n"
	$code+="// ----------------------------------------------\n"
	$code+="Function redrawAndSetVisible()\n"
	$code+="\t// Adjusts the layout and visibility of form elements based on the current page and modification state to be implemented\n"
	$code+="\n"
	
	This:C1470.writeFile($file; $code)
	
	
	// -------------------------------------------------------------------
	// generateFormJson
	// -------------------------------------------------------------------
Function generateFormJson($tableName : Text)
	
	$formName:="panel_"+This:C1470.firstLetterLowerCase($tableName)
	$formFolder:=This:C1470.sources.folder("Forms").folder($formName)
	
	// 1. Create form.4DForm file
	$jsonFile:=$formFolder.file("form.4DForm")
	
	// Build complete JSON object
	$json:=New object:C1471()
	
	// 4D header
	$json["$4d"]:=New object:C1471()
	$json["$4d"].version:="1"
	$json["$4d"].kind:="form"
	
	// Window
	$json.windowSizingX:="variable"
	$json.windowSizingY:="variable"
	$json.windowMinWidth:=0
	$json.windowMinHeight:=0
	$json.windowMaxWidth:=32767
	$json.windowMaxHeight:=32767
	$json.rightMargin:=20
	$json.bottomMargin:=20
	
	// Standard events
	$json.events:=New collection:C1472("onLoad"; \
		"onPageChange"; "onValidate"; "onClick"; \
		"onDoubleClick"; "onOutsideCall"; "onBeginDragOver"; \
		"onDragOver"; "onDrop"; "onAfterKeystroke"; "onMenuSelect"; \
		"onPluginArea"; "onAfterEdit"; "onTimer"; "onBoundVariableChange"\
		)
	
	$json.windowTitle:="window title"
	$json.destination:="detailScreen"
	
	// Pages (two empty pages by default, modifiable)
	$pages:=New collection:C1472()
	$pages.push(New object:C1471("objects"; New object:C1471()))
	$pages.push(New object:C1471("objects"; New object:C1471()))
	$json.pages:=$pages
	
	// Inherited form (choose the one that fits your project)
	$json.inheritedForm:="sfw_bkgd_header_3lines"
	
	$json.geometryStamp:=1
	$json.method:="method.4dm"
	
	// Save
	$jsonString:=JSON Stringify:C1217($json; *)
	This:C1470.writeFile($jsonFile; $jsonString)
	
	// 2. Create associated method.4dm file
	This:C1470.generateFormMethod($formFolder; $tableName)
	
	
	// -------------------------------------------------------------------
	// generateFormMethod
	// -------------------------------------------------------------------
Function generateFormMethod($formFolder : 4D:C1709.Folder; $tableName : Text)
	
	$methodFile:=$formFolder.file("method.4dm")
	$className:="panel_"+This:C1470.firstLetterLowerCase($tableName)
	
	$code:="cs."+$className+".me.formMethod()\n"
	
	This:C1470.writeFile($methodFile; $code)
	
	
	// -------------------------------------------------------------------
	// writeFile (robust method)
	// -------------------------------------------------------------------
Function writeFile($file : 4D:C1709.File; $content : Text)
	
	$success:=$file.setText($content)
	
	// Verification
	If (Not:C34($success))
		This:C1470.errors.push("content overwriting failed : "+$path)
		return 
	End if 
	
	
	// -------------------------------------------------------------------
	// firstLetterLowerCase (utility)
	// -------------------------------------------------------------------
Function firstLetterLowerCase($text : Text) : Text
	return Lowercase:C14($text[[1]])+Substring:C12($text; 2)
	
	
/*
// ============================================
// Class: GA Entry Generator 
// ============================================
	
property projectFolder : 4D.Folder
property sources : 4D.Folder
property errors : Collection
property warnings : Collection
	
Class constructor
	
This.projectFolder:=Folder(fk database folder)
This.sources:=This.projectFolder.folder("Project/Sources")
This.errors:=New collection()
This.warnings:=New collection()
	
// -------------------------------------------------------------------
// buildEntry
// -------------------------------------------------------------------
Function buildEntry($tableName : Text; $moduleName : Text; $listFields : Collection; $position : Integer; $searchField : Text; $titleField : Text)
	
// 1. Create necessary Folders
This.createFolders($tableName)
	
// 2. Create necessary files
This.generateDataClass($tableName; $moduleName; $listFields; $position; $searchField)
This.generateEntityClass($tableName; $titleField)
This.generatePanelClass($tableName)
This.generateFormJson($tableName)
	
// 3. Reload
RELOAD PROJECT
	
// 4. Display results
If (This.errors.length=0)
ALERT("✅ Successful entry creation for table "+$tableName)
Else 
ALERT("⚠️ Entry creation "+String(This.errors.length)+" erreur(s)")
End if 
	
	
// -------------------------------------------------------------------
// createFolders
// -------------------------------------------------------------------
Function createFolders($tableName : Text)
	
// Dossier Classes
$classesFolder:=This.sources.folder("Classes")
If (Not($classesFolder.exists))
$classesFolder.create()
If (Not($classesFolder.exists))
This.errors.push("Impossible de créer le dossier Classes")
End if 
End if 
	
// Dossier Forms/panel_xxx
$formName:="panel_"+This.firstLetterLowerCase($tableName)
$formsFolder:=This.sources.folder("Forms")
If (Not($formsFolder.exists))
$formsFolder.create()
End if 
$panelFolder:=$formsFolder.folder($formName)
If (Not($panelFolder.exists))
$panelFolder.create()
End if 
	
// Dossier ObjectMethods
$objMethodsFolder:=$panelFolder.folder("ObjectMethods")
If (Not($objMethodsFolder.exists))
$objMethodsFolder.create()
End if 
	
	
	
// -------------------------------------------------------------------
// generateDataClass 
// -------------------------------------------------------------------
Function generateDataClass($tableName : Text; $moduleName : Text; $listFields : Collection; $position : Integer; $searchField : Text)
	
$file:=This.sources.folder("Classes").file($tableName+".4dm")
	
// Construction du code
$code:="Class extends DataClass\n\n"
$code+="// ----------------------------------------------\n"
$code+="// entryDefinition\n"
$code+="// ----------------------------------------------\n"
$code+="\nlocal Function entryDefinition()->$entry : cs.sfw_definitionEntry\n"
$code+="\t$entry:=cs.sfw_definitionEntry.new(\""+$tableName+"\"; [\""+$moduleName+"\"]; \""+$tableName+"s\")\n"
$code+="\t$entry.setDataclass(\""+$tableName+"\")\n"
$code+="\t$entry.setDisplayOrder("+String($position)+")\n"
$code+="\t$entry.setIcon(\"image/entry/Step-white-50x50.png\")\n\n"
$code+="\t$entry.setSearchboxField(\""+$searchField+"\")\n\n"
$code+="\t$entry.setPanel(\"panel_"+This.firstLetterLowerCase($tableName)+"\")\n\n"
$code+="\t$entry.setPanelPage(1; \"\"; \"Main\")\n\n"
	
// Colonnes de la listbox
For each ($field; $listFields)
$code+="\t$entry.setLBItemsColumn(\""+$field.name+"\"; \""+$field.label+"\"; \"width:"+$field.width+"\")\n"
End for each 
	
$code+="\t$entry.setLBItemsOrderBy(\""+$searchField+"\")\n\n"
$code+="\t$entry.enableTransaction()\n\n"
$code+="\t$entry.activateComment()\n\n"
	
$code+="\n"
	
// Écriture avec vérification
This.writeFile($file; $code)
	
	
	
// -------------------------------------------------------------------
// generateEntityClass
// -------------------------------------------------------------------
Function generateEntityClass($tableName : Text; $field : Text)
	
$file:=This.sources.folder("Classes").file($tableName+"Entity.4dm")
	
$code:="Class extends Entity\n\n"
	
$code+="// ----------------------------------------------\n"
$code+="// nameInWindowTitle\n"
$code+="// ----------------------------------------------\n"
$code+="local Function get nameInWindowTitle()->$nameInWindowTitle : Text\n"
$code+="\t$nameInWindowTitle:=String(This."+$field+")\n\n"
$code+="\n"
	
This.writeFile($file; $code)
	
	
// -------------------------------------------------------------------
// generatePanelClass
// -------------------------------------------------------------------
Function generatePanelClass($tableName : Text)
	
$className:="panel_"+This.firstLetterLowerCase($tableName)
$file:=This.sources.folder("Classes").file($className+".4dm")
	
$code:="// ============================================\n"
$code+="// Class: "+$className+"\n"
$code+="// ============================================\n\n"
$code+="singleton Class constructor\n"
$code+="\t// It's a singleton class\n"
$code+="\n\n"
$code+="// ----------------------------------------------\n"
$code+="// _activate_save_cancel_button\n"
$code+="// ----------------------------------------------\n"
$code+="Function _activate_save_cancel_button()\n"
$code+="\tForm.current_item.UUID:=Form.current_item.UUID\n\n"
$code+="// ----------------------------------------------\n"
$code+="// formMethod\n"
$code+="// ----------------------------------------------\n"
$code+="Function formMethod()\n"
$code+="\t// This function manages the main logic for updating and refreshing the form\n"
$code+="\tForm.sfw.panelFormMethod()  // The main body of the form method and basic sfw functionalities\n"
$code+="\tIf (Form.sfw.updateOfPanelNeeded())  // The current item is changed or reloaded, so it's necessary to refresh\n"
$code+="\t\t// Add refresh logic here if needed\n"
$code+="\tEnd if\n"
$code+="\tIf (Form.sfw.recalculationOfPanelPageNeeded())  // A page is displayed so it's time to load the data sources\n"
$code+="\t\tCase of\n"
$code+="\t\t\t: (FORM Get current page(*)=1)\n"
$code+="\t\t\t\t// add load functions for page 1\n"
$code+="\t\tEnd case\n"
$code+="\tEnd if\n"
$code+="\tIf (Form.sfw.redrawAndSetVisibleInPanelNeeded())  // It's time to resize the object or set visibility\n"
$code+="\t\tThis.redrawAndSetVisible()\n"
$code+="\tEnd if\n"
$code+="\n\n"
$code+="// ----------------------------------------------\n"
$code+="// redrawAndSetVisible\n"
$code+="// ----------------------------------------------\n"
$code+="Function redrawAndSetVisible()\n"
$code+="\t// Adjusts the layout and visibility of form elements based on the current page and modification state to be implemented\n"
$code+="\n"
	
This.writeFile($file; $code)
	
	
// -------------------------------------------------------------------
// generateFormJson
// -------------------------------------------------------------------
Function generateFormJson($tableName : Text)
	
$formName:="panel_"+This.firstLetterLowerCase($tableName)
$formFolder:=This.sources.folder("Forms").folder($formName)
	
// 1. Créer le fichier form.4DForm
$jsonFile:=$formFolder.file("form.4DForm")
	
// Construction de l'objet JSON complet
$json:=New object()
	
// En-tête 4D
$json["$4d"]:=New object()
$json["$4d"].version:="1"
$json["$4d"].kind:="form"
	
// Fenêtre
$json.windowSizingX:="variable"
$json.windowSizingY:="variable"
$json.windowMinWidth:=0
$json.windowMinHeight:=0
$json.windowMaxWidth:=32767
$json.windowMaxHeight:=32767
$json.rightMargin:=20
$json.bottomMargin:=20
	
// Événements standard
$json.events:=New collection("onLoad"; \
"onPageChange"; "onValidate"; "onClick"; \
"onDoubleClick"; "onOutsideCall"; "onBeginDragOver"; \
"onDragOver"; "onDrop"; "onAfterKeystroke"; "onMenuSelect"; \
"onPluginArea"; "onAfterEdit"; "onTimer"; "onBoundVariableChange"\
)
	
$json.windowTitle:="window title"
$json.destination:="detailScreen"
	
// Pages (deux pages vides par défaut, modifiable)
$pages:=New collection()
$pages.push(New object("objects"; New object()))
$pages.push(New object("objects"; New object()))
$json.pages:=$pages
	
// Formulaire hérité (choisir celui qui convient à votre projet)
$json.inheritedForm:="sfw_bkgd_header_3lines"
	
$json.geometryStamp:=1
$json.method:="method.4dm"
	
// Sauvegarde
$jsonString:=JSON Stringify($json)
This.writeFile($jsonFile; $jsonString)
	
// 2. Créer le fichier method.4dm associé
This.generateFormMethod($formFolder; $tableName)
	
	
// -------------------------------------------------------------------
// generateFormMethod
// -------------------------------------------------------------------
Function generateFormMethod($formFolder : 4D.Folder; $tableName : Text)
	
$methodFile:=$formFolder.file("method.4dm")
$className:="panel_"+This.firstLetterLowerCase($tableName)
	
$code:="cs."+$className+".me.formMethod()\n"
	
This.writeFile($methodFile; $code)
	
	
// -------------------------------------------------------------------
// writeFile (méthode robuste)
// -------------------------------------------------------------------
Function writeFile($file : 4D.File; $content : Text)
	
$success:=$file.setText($content)
	
// Verification
If (Not($success))
This.errors.push("content overwriting failed : "+$path)
return 
End if 
	
	
// -------------------------------------------------------------------
// firstLetterLowerCase (utilitaire)
// -------------------------------------------------------------------
Function firstLetterLowerCase($text : Text) : Text
return Lowercase($text[[1]])+Substring($text; 2)
	
	
	
*/
	
	