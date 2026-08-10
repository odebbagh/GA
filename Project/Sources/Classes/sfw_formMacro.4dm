property typeOfMacro : Text

Class constructor($macro : Object)
	This:C1470.typeOfMacro:=$macro.type
	
	
Function onInvoke($editor : Object)->$result : Object
	
	Case of 
		: (This:C1470.typeOfMacro="createAPanelFromZeroWithInherited")
			$result:=This:C1470._createAPanelFromZeroWithInherited($editor)
		: (This:C1470.typeOfMacro="createAPanelFromZero")
			$result:=This:C1470._createAPanelFromZero($editor)
		: (This:C1470.typeOfMacro="SelectNoneXliffText")
			$result:=This:C1470._selectNoneXliffText($editor)
	End case 
	
Function _createAPanelFromZeroWithInherited($editor : Object)->$result : Object
	If ($editor.editor.currentPageNumber#0)
		cs:C1710.sfw_dialog.me.alert("This macro is usable in page 0 only")
	Else 
		$answer:=Request:C163("Enter the number of field to create")
		
		$parts:=Split string:C1554($answer; ";")
		$numbers:=New collection:C1472()
		For each ($part; $parts)
			$numbers.push(Num:C11($part))
		End for each 
		
		$editor.editor.formProperties.rightMargin:=0
		$editor.editor.formProperties.bottomMargin:=0
		
		$height:=$numbers.max()
		If ($height>5)
			$height:=5
		End if 
		$editor.editor.formProperties.inheritedForm:="sfw_bkgd_header_"+String:C10($height)+"lines"
		
		
		$column:=0
		For each ($number; $numbers)
			
			For ($i; 1; $number)
				$label:=New object:C1471
				$label.type:="text"
				$label.top:=12+(($i-1)*25)
				$label.left:=12+(287*$column)
				$label.width:=90
				$label.height:=17
				$label.stroke:="#808080"
				$label.text:="label "+String:C10($column)+"_"+String:C10($i)
				$editor.editor.currentPage.objects["label_"+String:C10($column)+"_"+String:C10($i)]:=$label
				
				$input:=New object:C1471
				$input.type:="input"
				$input.top:=12+(($i-1)*25)
				$input.left:=132+(287*$column)
				$input.width:=140
				$input.height:=17
				$input.dataSource:="Form:C1466.current_item.field"+String:C10($i)
				$input.focusable:=False:C215
				$input.enterable:=False:C215
				$input.dragging:="none"
				$input.dropping:="custom"
				$input.events:=New collection:C1472("onDataChange")
				$input.fill:="transparent"
				$input.borderStyle:="none"
				$editor.editor.currentPage.objects["entryField_"+String:C10($column)+"_"+String:C10($i)]:=$input
				
			End for 
			
			$column:=$column+1
		End for each 
		$result:=New object:C1471("currentPage"; $editor.editor.currentPage; "formProperties"; $editor.editor.formProperties)
	End if 
	
Function _createAPanelFromZero($editor : Object)->$result : Object
	
	If ($editor.editor.currentPageNumber#0)
		cs:C1710.sfw_dialog.me.alert("This macro is usable in page 0 only")
	Else 
		$answer:=Request:C163("Enter the number of field to create")
		
		
		If (ok=1)
			
			$DoCreatePagesTabs:=cs:C1710.sfw_dialog.me.confirm("Do you want the page tabs ? "; "yes"; "no")
			
			$parts:=Split string:C1554($answer; ";")
			$numbers:=New collection:C1472()
			For each ($part; $parts)
				$numbers.push(Num:C11($part))
			End for each 
			
			$editor.editor.formProperties.rightMargin:=0
			$editor.editor.formProperties.bottomMargin:=0
			
			$bkgd:=New object:C1471()
			$bkgd.type:="rectangle"
			$bkgd.top:=0
			$bkgd.left:=0
			$width:=(287*$numbers.length)+17
			If ($width<813)
				$width:=813
			End if 
			$bkgd.width:=$width
			$bkgd.height:=12+7+(25*$numbers.max())
			$bkgd.sizingX:="grow"  //
			$bkgd.fill:="#A2C6D8"
			$bkgd.stroke:="transparent"
			$editor.editor.currentPage.objects.header_bkgd:=$bkgd
			
			
			$column:=0
			For each ($number; $numbers)
				
				For ($i; 1; $number)
					$label:=New object:C1471
					$label.type:="text"
					$label.top:=12+(($i-1)*25)
					$label.left:=12+(287*$column)
					$label.width:=90
					$label.height:=17
					$label.stroke:="#808080"
					$label.text:="label "+String:C10($column)+"_"+String:C10($i)
					$editor.editor.currentPage.objects["label_"+String:C10($column)+"_"+String:C10($i)]:=$label
					
					$input:=New object:C1471
					$input.type:="input"
					$input.top:=12+(($i-1)*25)
					$input.left:=132+(287*$column)
					$input.width:=140
					$input.height:=17
					$input.dataSource:="Form:C1466.current_item.field"+String:C10($i)
					$input.focusable:=False:C215
					$input.enterable:=False:C215
					$input.dragging:="none"
					$input.dropping:="custom"
					$input.events:=New collection:C1472("onDataChange")
					$input.fill:="transparent"
					$input.borderStyle:="none"
					$editor.editor.currentPage.objects["entryField_"+String:C10($column)+"_"+String:C10($i)]:=$input
					
				End for 
				
				$column:=$column+1
			End for each 
			
			
			If ($DoCreatePagesTabs)
				$vTab:=New object:C1471
				$vTab.type:="subform"
				$vTab.top:=$bkgd.height
				$vTab.left:=0
				$vTab.width:=50
				$vTab.height:=450
				$vTab.dataSource:="Form:C1466.vTabBar"
				$vTab.detailForm:="sfw_vTabBar"
				$vTab.hideFocusRing:=True:C214
				$vTab.deletableInList:=False:C215
				$vTab.doubleClickInRowAction:="editSubrecord"
				$vTab.doubleClickInEmptyAreaAction:="addSubrecord"
				$vTab.selectionMode:="multiple"
				$vTab.printFrame:="variable"
				$vtab.method:="sfw_main_vTabBar_sfo"
				$editor.editor.currentPage.objects.vTabBar_subform:=$vTab
				
			End if 
			
			
			$result:=New object:C1471("currentPage"; $editor.editor.currentPage; "formProperties"; $editor.editor.formProperties)
			
		End if 
	End if 
	
Function _selectNoneXliffText($editor : Object)->$result : Object
	var $objectName : Text
	var $hWnd : Integer
	var $obj : Object
	
	$obj:=New object:C1471(\
		"currentSelection"; $editor.editor.currentSelection; \
		"listObjects"; New collection:C1472)
	If ($editor.editor.formProperties.windowTitle#Null:C1517)
		If ($editor.editor.formProperties.windowTitle#":xliff:@")
			$curr_obj:=New object:C1471
			$curr_obj.name:="Window title"
			$curr_obj.type:="Window title"
			$curr_obj.text:=$editor.editor.formProperties.windowTitle
			$obj.listObjects.push($curr_obj)
		End if 
	End if 
	//Retrieve the list of object in the current page
	For each ($objectName; $editor.editor.currentPage.objects)
		$form_object:=$editor.editor.currentPage.objects[$objectName]
		If ($form_object.text#Null:C1517)
			If ($form_object.text#":xliff:@")
				$curr_obj:=New object:C1471
				$curr_obj.name:=$objectName
				$curr_obj.type:=$form_object.type
				$curr_obj.text:=$form_object.text
				$obj.listObjects.push($curr_obj)
			End if 
		End if 
		If ($form_object.placeholder#Null:C1517)
			If ($form_object.placeholder#":xliff:@")
				$curr_obj:=New object:C1471
				$curr_obj.name:=$objectName
				$curr_obj.type:=$form_object.type+"/place holder"
				$curr_obj.text:=$form_object.text
				$obj.listObjects.push($curr_obj)
			End if 
		End if 
		If ($form_object.tooltip#Null:C1517)
			If ($form_object.tooltip#":xliff:@")
				$curr_obj:=New object:C1471
				$curr_obj.name:=$objectName
				$curr_obj.type:=$form_object.type+"/tool tip"
				$curr_obj.text:=$form_object.text
				$obj.listObjects.push($curr_obj)
			End if 
		End if 
		If ($form_object.type="listbox")
			For each ($column; $form_object.columns)
				If ($column.header#Null:C1517)
					If ($column.header.text#Null:C1517)
						If ($column.header.text#":xliff:@")
							$curr_obj:=New object:C1471
							$curr_obj.name:=$column.header.name
							$curr_obj.type:="listbox/header"
							$curr_obj.text:=$column.header.text
							$obj.listObjects.push($curr_obj)
						End if 
					End if 
				End if 
				If ($column.footer#Null:C1517)
					If ($column.footer.text#Null:C1517)
						If ($column.footer.text#":xliff:@")
							$curr_obj:=New object:C1471
							$curr_obj.name:=$column.footer.name
							$curr_obj.type:="listbox/footer"
							$curr_obj.text:=$column.footer.text
							$obj.listObjects.push($curr_obj)
						End if 
					End if 
				End if 
			End for each 
		End if 
	End for each 
	
	// Open a dialog to select object in the list
	$hWnd:=Open form window:C675("sfw_lbXliff"; Movable form dialog box:K39:8; *)
	DIALOG:C40("sfw_lbXliff"; $obj)
	CLOSE WINDOW:C154
	
	// Select the form object 
	$editor.editor.currentSelection.clear()
	If ($obj.currentSelection#Null:C1517)
		For each ($name_obj; $obj.currentSelection)
			$editor.editor.currentSelection.push($name_obj.name)
		End for each 
	End if 
	
	// Notify to 4D the modification
	$result:=New object:C1471("currentSelection"; $editor.editor.currentSelection)