property hpup_menus : Collection

singleton Class constructor
	//It's a singleton class
	
Function formMethod()
	Case of 
		: (FORM Event:C1606.code=On Resize:K2:27)
			Case of 
				: (FORM Get current page:C276(*)=1)
					Form:C1466.resizingAsked:=1
					SET TIMER:C645(20)
				: (FORM Get current page:C276(*)=2)
					This:C1470.resizeObjectsPagePermissions()
				: (FORM Get current page:C276(*)=3)
					This:C1470.resizeObjectsPage3()
			End case 
			
		: (FORM Event:C1606.code=On Timer:K2:25) && (Num:C11(Form:C1466.resizingAsked)>0)
			This:C1470.resizeObjects()
			
		: (Num:C11(Form:C1466.resizingAsked)#0)
			
		Else 
			//This function manages the main logic for updating and refreshing the form
			Form:C1466.sfw.panelFormMethod()  //The main body of the form method and basic sfw functionalities 
			If (Form:C1466.sfw.updateOfPanelNeeded())  //The current item is changed or reloaded, so it's necessary ti refresh 
				This:C1470.drawPup_documentFolder()
				
			End if 
			If (Form:C1466.sfw.recalculationOfPanelPageNeeded())  //a page is displayed so it's time to load the sources of data to display
				Case of 
					: (FORM Get current page:C276(*)=1)
						// add load functions
						Form:C1466.lb_lines:=Form:C1466.lb_lines || New collection:C1472
						Form:C1466.lb_settings:=Form:C1466.lb_settings || New collection:C1472
						Form:C1466.lb_properties:=Form:C1466.lb_properties || New collection:C1472
						Form:C1466.lb_variables:=Form:C1466.lb_variables || New collection:C1472
						
						Form:C1466.zoom:=Form:C1466.zoom || 100
						Form:C1466.portrait:=Form:C1466.portrait || 1
						Form:C1466.rulers:=Form:C1466.rulers || 0
						Form:C1466.landscape:=Form:C1466.landscape || 0
						Form:C1466.paper:=Form:C1466.paper || New object:C1471
						Form:C1466.paper.formats:=Form:C1466.paper.formats || ds:C1482.dfd_Line.getFormatPapers()
						Form:C1466.paper.format:=Form:C1466.paper.format || "A4"
						
						If (Form:C1466.picts=Null:C1517)
							This:C1470.load_picts()
						End if 
						If (Form:C1466.typologies=Null:C1517)
							This:C1470.load_typologies()
						End if 
						This:C1470.redraw_all()
					: (FORM Get current page:C276(*)=2)
						This:C1470.buildHLPermissions()
						
					: (FORM Get current page:C276(*)=3)
						This:C1470.resizeObjectsPage3()
						
				End case 
			End if 
			If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())  //It's time to resize the object or set visible
				This:C1470.redrawAndSetVisible()
			End if 
			If (FORM Event:C1606.code=On Load:K2:1)
				This:C1470.resizeObjects()
			End if 
	End case 
	
Function redrawAndSetVisible()
	This:C1470.resizeObjectsPagePermissions()
	This:C1470.resizeObjectsPage3()
	
	This:C1470.drawPup_documentFolder()
	
	
	
	
Function resizeObjects()
	SET TIMER:C645(0)
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubForm; $heightSubform)
	Form:C1466.resizingAsked:=Form:C1466.resizingAsked || 1
	Case of 
		: (Form:C1466.resizingAsked=1)
			OBJECT GET COORDINATES:C663(*; "SplitterH"; $g; $h; $d; $b)
			OBJECT SET COORDINATES:C1248(*; "SplitterH"; $g; $h; $widthSubForm+100; $b)
			
			OBJECT GET COORDINATES:C663(*; "preview"; $g; $h; $d; $b)
			OBJECT SET COORDINATES:C1248(*; "preview"; $g; $h; $widthSubForm-21; $heightSubform-43)
			OBJECT SET COORDINATES:C1248(*; "bkgd_preview"; $g; $h; $widthSubForm-21; $heightSubform-43)
			
			For each ($objectName; ["pictoDocument"; "pictoLine"; "pictoObject"; "pictoVariable"; "counterDocument"; "counterLine"; "counterObject"; "counterVariable"])
				OBJECT GET COORDINATES:C663(*; $objectName; $g; $h; $d; $b)
				OBJECT SET COORDINATES:C1248(*; $objectName; $g; $heightSubform-5-$b+$h; $d; $heightSubform-5)
			End for each 
			
			$offset:=5
			$gap:=2
			For each ($objectName; ["bLandscape"; "bPortrait"; "bFormat"; "bRuler"; "bPrint"; "ruler"])
				If ($objectName="ruler")
					$offset+=10
				End if 
				OBJECT GET COORDINATES:C663(*; $objectName; $g; $h; $d; $b)
				OBJECT SET COORDINATES:C1248(*; $objectName; $widthSubForm-$offset-$d+$g; $h; $widthSubForm-$offset; $b)
				$offset+=$d-$g+$gap
			End for each 
			
			
			OBJECT GET COORDINATES:C663(*; "lb_properties"; $g; $h; $d; $b)
			Form:C1466.delta:=($widthSubForm-$d)/3
			SET TIMER:C645(-1)
		: (Form:C1466.resizingAsked=2)
			Form:C1466.splitterV3:=Form:C1466.delta
			SET TIMER:C645(-1)
		: (Form:C1466.resizingAsked=3)
			Form:C1466.splitterV2:=Form:C1466.delta
			SET TIMER:C645(-1)
		: (Form:C1466.resizingAsked=4)
			Form:C1466.splitterV1:=Form:C1466.delta
			SET TIMER:C645(-1)
		: (Form:C1466.resizingAsked=5)
			OBJECT GET COORDINATES:C663(*; "lb_properties"; $g; $h; $d; $b)
			OBJECT SET COORDINATES:C1248(*; "lb_properties"; $g; $h; $widthSubForm-5; $b)
			Form:C1466.resizingAsked:=-1
	End case 
	Form:C1466.resizingAsked+=1
	
	
	
Function resizeObjectsPage3()
	$margin:=10
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubForm; $heightSubForm)
	OBJECT GET COORDINATES:C663(*; "entryField_documentNameFormula"; $g; $h; $d; $b)
	OBJECT SET COORDINATES:C1248(*; "entryField_documentNameFormula"; $g; $h; $widthSubForm-$margin; $b)
	OBJECT GET COORDINATES:C663(*; "entryField_documentPrecalculationMethod"; $g; $h; $d; $b)
	OBJECT SET COORDINATES:C1248(*; "entryField_documentPrecalculationMethod"; $g; $h; $widthSubForm-$margin; $heightSubForm-$margin)
	
	
Function redraw_all()
	This:C1470.redraw_lb_settings()
	This:C1470.redraw_lb_lines()
	This:C1470.redraw_lb_variables()
	This:C1470.redraw_lb_properties()
	This:C1470.redraw_preview()
	This:C1470.redraw_buttons()
	
	
Function redraw_lb_settings()
	var $setting : Object
	var $settingName : Text
	
	Form:C1466.lb_settings:=New collection:C1472()
	If (Form:C1466.current_item#Null:C1517)
		If (Form:C1466.current_item.moreData=Null:C1517)
			Form:C1466.current_item.moreData:=New object:C1471
		End if 
		If (Form:C1466.current_item.moreData.settings=Null:C1517)
			Form:C1466.current_item.moreData.settings:=New object:C1471
		End if 
		
		If (Form:C1466.current_item.moreData.settings.format=Null:C1517)
			Form:C1466.current_item.moreData.settings.format:="A4"
		End if 
		If (Form:C1466.current_item.moreData.settings.orientation=Null:C1517)
			Form:C1466.current_item.moreData.settings.orientation:="portrait"
		End if 
		If (Form:C1466.current_item.moreData.settings.margin_top=Null:C1517)
			Form:C1466.current_item.moreData.settings.margin_top:=10
		End if 
		If (Form:C1466.current_item.moreData.settings.margin_left=Null:C1517)
			Form:C1466.current_item.moreData.settings.margin_left:=10
		End if 
		If (Form:C1466.current_item.moreData.settings.margin_bottom=Null:C1517)
			Form:C1466.current_item.moreData.settings.margin_bottom:=10
		End if 
		If (Form:C1466.current_item.moreData.settings.margin_right=Null:C1517)
			Form:C1466.current_item.moreData.settings.margin_right:=10
		End if 
		If (Form:C1466.current_item.moreData.settings.printNbCopies=Null:C1517)
			Form:C1466.current_item.moreData.settings.printNbCopies:=1
		End if 
		If (Form:C1466.current_item.moreData.settings.printPreview=Null:C1517)
			Form:C1466.current_item.moreData.settings.printPreview:="False"
		End if 
		If (Form:C1466.current_item.moreData.settings.printSettings=Null:C1517)
			Form:C1466.current_item.moreData.settings.printSettings:="False"
		End if 
		If (Form:C1466.current_item.moreData.settings.pdfPath=Null:C1517)
			Form:C1466.current_item.moreData.settings.pdfPath:=""
		End if 
		If (Form:C1466.current_item.moreData.settings.pdfPrinter=Null:C1517)
			Form:C1466.current_item.moreData.settings.pdfPrinter:=Generic PDF driver:K47:15
		End if 
		If (Form:C1466.current_item.moreData.settings.pdfDocumentName=Null:C1517)
			Form:C1466.current_item.moreData.settings.pdfDocumentName:=""
		End if 
		If (Form:C1466.current_item.moreData.settings.printZoom=Null:C1517)
			Form:C1466.current_item.moreData.settings.printZoom:=100
		End if 
		
		
		For each ($settingName; Form:C1466.current_item.moreData.settings)
			$setting:=New object:C1471
			$setting.name:=$settingName
			$setting.value:=Form:C1466.current_item.moreData.settings[$settingName]
			$setting.notEditable:=(Position:C15($settingName; "format;orientation")>0)
			Form:C1466.lb_settings.push($setting)
		End for each 
		
	End if 
	
	If (Form:C1466.current_item#Null:C1517) && (Form:C1466.current_item.moreData.settings.orientation#Null:C1517)
		Form:C1466.landscape:=Num:C11(Form:C1466.current_item.moreData.settings.orientation="landscape")
		Form:C1466.portrait:=Num:C11(Form:C1466.current_item.moreData.settings.orientation="portrait")
		Form:C1466.paper.format:=Form:C1466.current_item.moreData.settings.format
		OBJECT SET TITLE:C194(*; "bFormat"; Form:C1466.paper.format)
	End if 
	
	
Function redraw_lb_lines($linePosition : Integer)
	
	var $indices : Collection
	var $item : Object
	var $line : Object
	var $lines : Collection
	var $template_line : cs:C1710.dfd_LineEntity
	
	Form:C1466.lb_lines:=New collection:C1472
	
	If (Form:C1466.current_item#Null:C1517)
		If (Form:C1466.current_item.hierarchy=Null:C1517)
			Form:C1466.current_item.hierarchy:=New object:C1471
		End if 
		If (Form:C1466.current_item.hierarchy.lines=Null:C1517)
			Form:C1466.current_item.hierarchy.lines:=New collection:C1472
		End if 
		$lines:=Form:C1466.current_item.hierarchy.lines
		
		For each ($line; $lines)
			$item:=New object:C1471
			$item.line:=$line
			$item.meta:=New object:C1471
			Case of 
				: ($line.kind="template_line")
					$template_line:=ds:C1482.dfd_Line.get($line.UUID_entity)
					If ($template_line#Null:C1517)
						$item.name:=$template_line.name
						$indices:=Form:C1466.typologies.indices("code = :1"; String:C10($line.typology))
						If ($indices.length>0)
							$item.typology:=Form:C1466.typologies[$indices[0]].label
						Else 
							$indices:=Form:C1466.typologies.indices("code = :1"; "LS")
							If ($indices.length>0)
								$item.typology:=Form:C1466.typologies[$indices[0]].label
							End if 
							$line.typology:="LS"
						End if 
						$item.pict:=This:C1470.typology_get_icon_byCode($line.typology)
					Else 
						break
					End if 
				: ($line.kind="pageBreak")
					$item.name:=ds:C1482.sfw_readXliff("dfdTemplate.panel.pagebreak")
					$item.pict:=Form:C1466.picts.pageBreak
					$line.typology:=""
					
			End case 
			Form:C1466.lb_lines.push($item)
			
		End for each 
		
		
		If ($linePosition=0) || (Form:C1466.lb_lines.length=0)
			Form:C1466.linePosition:=0
			Form:C1466.line:=Null:C1517
			LISTBOX SELECT ROW:C912(*; "lb_lines"; 0; lk remove from selection:K53:3)
		Else 
			Form:C1466.linePosition:=$linePosition
			If ($linePosition>Form:C1466.lb_lines.length)
				$linePosition:=Form:C1466.lb_lines.length
			End if 
			Form:C1466.line:=($linePosition>0) ? Form:C1466.lb_lines[$linePosition-1] : Null:C1517
			
			LISTBOX SELECT ROW:C912(*; "lb_lines"; $linePosition; lk replace selection:K53:1)
		End if 
		
	End if 
	
	This:C1470.redraw_preview()
	This:C1470.redraw_buttons()
	
	
Function redraw_lb_variables()
	var $line : Object
	var $item : Object
	var $lineProperty : Object
	var $tag : Object
	var $template_line : cs:C1710.dfd_LineEntity
	
	Form:C1466.lb_variables:=New collection:C1472
	If (Form:C1466.current_item#Null:C1517)
		For each ($line; Form:C1466.current_item.hierarchy.lines)
			
			Case of 
				: ($line.kind="template_line")
					$template_line:=ds:C1482.dfd_Line.get($line.UUID_entity)
					If ($template_line#Null:C1517)
						If ($template_line.variableItems.tags#Null:C1517)
							For each ($tag; $template_line.variableItems.tags)
								If ($tag.tag#"this.@")
									$indices:=Form:C1466.lb_variables.indices("name = :1"; $tag.tag)
									If ($indices.length>0)
										$variable:=Form:C1466.lb_variables[$indices[0]]
										$variable.lines+="\r• "+$template_line.name
										$variable.nbLines+=1
										$variable.infos:=String:C10($variable.nbLines)+" "+Localized string:C991("template.dialog.lb_variables.line")+"s"
									Else 
										$item:=New object:C1471
										$item.name:=$tag.tag
										$item.lines:="• "+$template_line.name
										$item.nbLines:=1
										$item.infos:=$template_line.name
										Form:C1466.lb_variables.push($item)
									End if 
								End if 
							End for each 
						End if 
						
						If ($line.properties#Null:C1517)
							For each ($lineProperty; $line.properties)
								If ($lineProperty.kind="collectionSource") && ($lineProperty.value#Null:C1517)
									$indices:=Form:C1466.lb_variables.indices("name = :1"; $lineProperty.value)
									If ($indices.length>0)
										$variable:=Form:C1466.lb_variables[$indices[0]]
										$variable.lines+="\r• "+$template_line.name
										$variable.nbLines+=1
										$variable.infos:=String:C10($variable.nbLines)+" "+Localized string:C991("template.dialog.lb_variables.line")+"s"
									Else 
										$item:=New object:C1471
										$item.nbLines:=1
										$item.name:=$lineProperty.value
										$item.lines:="• "+$template_line.name
										$item.infos:=$template_line.name
										Form:C1466.lb_variables.push($item)
									End if 
								End if 
							End for each 
						End if 
					End if 
			End case 
		End for each 
		Form:C1466.lb_variables:=Form:C1466.lb_variables.orderBy("name")
	End if 
	
	
Function redraw_lb_properties()
	var $property : Object
	var $label : Text
	var $lineProperty : Object
	var $indices : Collection
	
	Form:C1466.lb_properties:=New collection:C1472
	If (Form:C1466.line#Null:C1517) & (Form:C1466.current_item#Null:C1517)
		$property:=New object:C1471
		$property.name:=Localized string:C991("template.line")
		$property.value:=Form:C1466.line.name
		$property.notEditable:=True:C214
		$property.meta:=New object:C1471("stroke"; "grey")
		Form:C1466.lb_properties.push($property)
		
		$indices:=Form:C1466.typologies.indices("code = :1"; String:C10(Form:C1466.line.line.typology))
		If ($indices.length>0)
			$label:=Form:C1466.typologies[$indices[0]].label
			$property:=New object:C1471
			$property.name:=Localized string:C991("template.typology")
			$property.kind:="--typology"
			$property.value:=$label
			Form:C1466.lb_properties.push($property)
			If (Form:C1466.line.line.properties#Null:C1517)
				For each ($lineProperty; Form:C1466.line.line.properties)
					Form:C1466.lb_properties.push(OB Copy:C1225($lineProperty))
				End for each 
			End if 
		Else 
			$property:=New object:C1471
			$property.name:="orientation"
			$property.kind:="--orientation"
			Form:C1466.line.line.orientation:=Form:C1466.line.line.orientation || "portrait"
			$property.value:=Form:C1466.line.line.orientation
			Form:C1466.lb_properties.push($property)
			
		End if 
	End if 
	
	
	
	
Function redraw_preview($destination : Text)
	
	var $linesInRulers : Collection
	var $objects : Collection
	var $rules : Collection
	var $file : 4D:C1709.File
	var $formDefinition : Object
	var $lineInRulers : Object
	var $properties : Object
	var $propertiesBarcode : Object
	var $cm : Real
	var $coef : Real
	var $coefPolice : Real
	var $height : Real
	var $i : Real
	var $lineNum : Real
	var $margin_left : Real
	var $margin_leftPx : Real
	var $margin_top : Real
	var $margin_topPx : Real
	var $maxBottom : Real
	var $maxBottomPx : Real
	var $paper_offset_left : Real
	var $paper_offset_top : Real
	var $rulersSize : Real
	var $verticalOffset : Real
	var $verticalOffsetPx : Real
	var $zoom : Real
	var $color : Text
	var $json : Text
	var $name : Text
	var $nameBarCode : Text
	var $dim : Integer
	var $indices : Collection
	var $line : Object
	var $lines : Collection
	var $object : Variant
	var $paperHeight : Integer
	var $paperWidth : Integer
	var $templateLine : cs:C1710.dfd_LineEntity
	
	If (Count parameters:C259=0)
		$destination:="--subform"
	End if 
	
	$file:=File:C1566("/RESOURCES/dfd/json/form/container.json")
	$json:=$file.getText()
	$formDefinition:=JSON Parse:C1218($json)
	
	If (Form:C1466.current_item#Null:C1517)
		
		$zoom:=Form:C1466.zoom || 100
		
		$margin_topPx:=Num:C11(Form:C1466.current_item.moreData.settings.margin_top || 10)
		$margin_leftPx:=Num:C11(Form:C1466.current_item.moreData.settings.margin_left || 10)
		Case of 
			: ($destination="--print")
				$coef:=1
				$coefPolice:=1
				$margin_top:=$margin_topPx
				$margin_left:=$margin_leftPx
				
				
			: ($destination="--subform")
				$coef:=1.9*($zoom/100)
				$coefPolice:=1.9*($zoom/100)
				$rulersSize:=20
				$paper_offset_top:=10*($zoom/100)+($rulersSize*Num:C11(Form:C1466.rulers)*($zoom/100)*$coef)
				$paper_offset_left:=10*($zoom/100)+($rulersSize*Num:C11(Form:C1466.rulers)*($zoom/100)*$coef)
				
				$margin_top:=($margin_topPx*$coef*($zoom/100))+$paper_offset_top
				$margin_left:=($margin_leftPx*$coef*($zoom/100))+$paper_offset_left
				
		End case 
		
		$indices:=Form:C1466.paper.formats.indices("name = :1"; Form:C1466.paper.format)
		If ($indices.length>0)
			$paperWidth:=Form:C1466.paper.formats[$indices[0]].width*($zoom/100)*$coef
			$paperHeight:=Form:C1466.paper.formats[$indices[0]].height*($zoom/100)*$coef
		Else 
			$paperWidth:=595*($zoom/100)*$coef
			$paperHeight:=842*($zoom/100)*$coef
		End if 
		
		If (Form:C1466.portrait=0)
			$dim:=$paperWidth
			$paperWidth:=$paperHeight
			$paperHeight:=$dim
		End if 
		
		Form:C1466.nbObjects:=0
		
		$lines:=Form:C1466.current_item.hierarchy.lines
		$verticalOffset:=$margin_top
		$verticalOffsetPx:=$margin_topPx
		$lineNum:=0
		$linesInRulers:=New collection:C1472
		
		For each ($line; $lines)
			$lineNum+=1
			Case of 
				: ($line.kind="pageBreak") & ($destination="--subform")
					
					$name:="pageBreak"+String:C10($lineNum)
					$properties:=New object:C1471
					$properties.type:="line"
					$properties.top:=$verticalOffset
					$properties.left:=$paper_offset_left
					$properties.width:=$paperWidth+20
					$properties.height:=0
					$properties.fill:="black"
					$properties.stroke:="black"
					$properties.strokeWidth:=1
					$properties.strokeDashArray:=New collection:C1472(1; 3)
					$formDefinition.pages[1].objects[$name]:=$properties
					
					$name:="pageBreakPicture"+String:C10($lineNum)
					$properties:=New object:C1471
					$properties.type:="picture"
					$properties.top:=$verticalOffset-8
					$properties.left:=$paper_offset_left+$paperWidth+15
					$properties.width:=16
					$properties.height:=16
					$properties.picture:="/RESOURCES/dfd/image/icon/scissors.png"
					$formDefinition.pages[1].objects[$name]:=$properties
					
					
				: ($line.kind="template_line") & (Position:C15(";"+$line.typology+";"; ";FP;FPP;FPS;")=0)
					
					$templateLine:=ds:C1482.dfd_Line.get($line.UUID_entity)
					If ($templateLine#Null:C1517)
						$objects:=$templateLine.objectsForm.objects.orderBy("order").copy()
						
						// calculate the dynamic properties
						This:C1470.calculate_dynProp($objects; $destination)
						
						// apply the rules
						If ($templateLine.calculs.rules#Null:C1517)
							$rules:=$templateLine.calculs.rules.copy()
							This:C1470.apply_rules($objects; $rules)
						End if 
						
						// build the objects
						$maxBottom:=0
						$maxBottomPx:=0
						
						For each ($object; $objects)
							
							$name:=$object.name+"_"+String:C10($lineNum)
							$properties:=OB Copy:C1225($object.properties)
							
							If (($properties.top+$properties.height+$verticalOffsetPx)>$maxBottomPx)
								$maxBottomPx:=$properties.top+$properties.height+$verticalOffsetPx
							End if 
							
							$properties.top:=($properties.top*($zoom/100)*$coef)+$verticalOffset
							$properties.left:=$margin_left+($properties.left*($zoom/100)*$coef)
							$properties.width:=$properties.width*($zoom/100)*$coef
							$properties.height:=$properties.height*($zoom/100)*$coef
							If ($properties.fontSize#Null:C1517)
								$properties.fontSize:=$properties.fontSize*($zoom/100)*$coefPolice
							End if 
							If ($properties.strokeWidth#Null:C1517)
								$properties.strokeWidth:=$properties.strokeWidth*($zoom/100)*$coef
							End if 
							If (($properties.top+$properties.height)>$maxBottom)
								$maxBottom:=$properties.top+$properties.height
							End if 
							
							If (String:C10($properties._origineType)="barcode")
								$nameBarCode:=$object.name+"_barcode"
								$propertiesBarcode:=New object:C1471()
								$propertiesBarcode.top:=$properties.top
								$propertiesBarcode.left:=$properties.left
								$propertiesBarcode.width:=$properties.width
								$propertiesBarcode.height:=$properties.height
								$propertiesBarcode.type:="picture"
								$propertiesBarcode.pictureFormat:="scaled"
								$propertiesBarcode.picture:="/RESOURCES/dfd/image/modeles/barcode.png"
								$formDefinition.pages[1].objects[$nameBarCode]:=$propertiesBarcode
							End if 
							
							$formDefinition.pages[1].objects[$name]:=$properties
							Form:C1466.nbObjects+=1
							
						End for each 
						
						
						$lineInRulers:=New object:C1471
						$lineInRulers.min:=$verticalOffset
						$lineInRulers.max:=$maxBottom
						$color:=This:C1470.tool_choose_color($lineNum)
						$lineInRulers.color:=$color
						$lineInRulers.tooltip:=$templateLine.name+"\r"+String:C10($verticalOffsetPx)+" px\r"+String:C10($maxBottomPx)+" px"
						$lineInRulers.typology:=$line.typology
						$linesInRulers.push($lineInRulers)
						If (Form:C1466.rulers=1)
							Form:C1466.lb_lines[$lineNum-1].meta.fill:=$color
						Else 
							Form:C1466.lb_lines[$lineNum-1].meta.fill:="none"
						End if 
						
						$verticalOffset:=$maxBottom
						$verticalOffsetPx:=$maxBottomPx
					End if 
			End case 
			
		End for each 
		Form:C1466.lb_lines:=Form:C1466.lb_lines  //to force meta redraw
		
		
		
		Case of 
			: ($destination="--print")
				SET PRINTABLE MARGIN:C710(0; 0; 0; 0)  //Fixe la marge papier
				
				If (Form:C1466.landscape=1)
					SET PRINT OPTION:C733(Orientation option:K47:2; 2)  // landscape
				Else 
					SET PRINT OPTION:C733(Orientation option:K47:2; 1)  // portrait
				End if 
				
				SET PRINT PREVIEW:C364(True:C214)
				$height:=Print form:C5($formDefinition)
				
			: ($destination="--subform")
				
				$properties:=New object:C1471
				$properties.type:="rectangle"
				$properties.top:=$paper_offset_top
				$properties.left:=$paper_offset_left
				$properties.width:=$paperWidth
				$properties.height:=$paperHeight
				$properties.fill:="white"
				$properties.stroke:="white"
				$formDefinition.pages[0].objects.paper:=$properties
				
				If (Form:C1466.rulers=1)
					
					$properties:=New object:C1471
					$properties.type:="rectangle"
					$properties.top:=$paper_offset_top+(Form:C1466.current_item.moreData.settings.margin_top*($zoom/100)*$coef)
					$properties.left:=$paper_offset_left+(Form:C1466.current_item.moreData.settings.margin_left*($zoom/100)*$coef)
					$properties.width:=$paperWidth-((Form:C1466.current_item.moreData.settings.margin_left+Form:C1466.current_item.moreData.settings.margin_right)*($zoom/100)*$coef)
					$properties.height:=$paperHeight-((Form:C1466.current_item.moreData.settings.margin_top+Form:C1466.current_item.moreData.settings.margin_bottom)*($zoom/100)*$coef)
					$properties.fill:="none"
					$properties.stroke:="grey"
					$properties.strokeWidth:=1
					$properties.borderStyle:="solid"
					$properties.strokeDashArray:="5 10"
					$formDefinition.pages[0].objects.margin:=$properties
					
					
					$properties:=New object:C1471
					$properties.type:="rectangle"
					$properties.top:=0
					$properties.left:=$paper_offset_left
					$properties.width:=$paperWidth
					$properties.height:=($rulersSize-5)*($zoom/100)*$coef
					$properties.fill:="lightyellow"
					$properties.stroke:="black"
					$properties.strokeWidth:=0.1*($zoom/100)*$coef
					$formDefinition.pages[0].objects.rulerHorizontal:=$properties
					
					$cm:=28.33333333333
					For ($i; 1; Int:C8($paperWidth\($cm*($zoom/100)*$coef)))
						
						$name:="scaleCmH_"+String:C10($i)
						$properties:=New object:C1471
						$properties.type:="line"
						$properties.top:=($rulersSize-5)/2*($zoom/100)*$coef
						$properties.left:=$paper_offset_left+($i*$cm*($zoom/100)*$coef)
						$properties.width:=0
						$properties.height:=($rulersSize-5)/2*($zoom/100)*$coef
						$properties.fill:="black"
						$properties.stroke:="black"
						$properties.strokeWidth:=0.2*($zoom/100)*$coef
						$formDefinition.pages[0].objects[$name]:=$properties
						
					End for 
					For ($i; 1; Int:C8($paperWidth*10\($cm*($zoom/100)*$coef)))
						If ($i%10#0)
							$name:="scaleCmHH_"+String:C10($i)
							$properties:=New object:C1471
							$properties.type:="line"
							$properties.top:=($rulersSize-5)*4/5*($zoom/100)*$coef
							$properties.left:=$paper_offset_left+($i*$cm/10*($zoom/100)*$coef)
							$properties.width:=0
							$properties.height:=($rulersSize-5)/5*($zoom/100)*$coef
							$properties.fill:="lightgrey"
							$properties.stroke:="lightgrey"
							$properties.strokeWidth:=0.1*($zoom/100)*$coef
							$formDefinition.pages[0].objects[$name]:=$properties
						End if 
					End for 
					
					$properties:=New object:C1471
					$properties.type:="rectangle"
					$properties.top:=$paper_offset_top
					$properties.left:=0
					$properties.width:=($rulersSize-5)*($zoom/100)*$coef
					$properties.height:=$paperHeight
					$properties.fill:="lightyellow"
					$properties.stroke:="black"
					$properties.strokeWidth:=0.1*($zoom/100)*$coef
					$formDefinition.pages[0].objects.rulerVertical:=$properties
					
					For ($i; 1; Int:C8($paperHeight\($cm*($zoom/100)*$coef)))
						
						$name:="scaleCmV_"+String:C10($i)
						$properties:=New object:C1471
						$properties.type:="line"
						$properties.top:=$paper_offset_top+($i*$cm*($zoom/100)*$coef)
						$properties.left:=($rulersSize-5)/2*($zoom/100)*$coef
						$properties.width:=($rulersSize-5)/2*($zoom/100)*$coef
						$properties.height:=0
						$properties.fill:="black"
						$properties.stroke:="black"
						$properties.strokeWidth:=0.2*($zoom/100)*$coef
						$formDefinition.pages[0].objects[$name]:=$properties
						
					End for 
					For ($i; 1; Int:C8($paperHeight*10\($cm*($zoom/100)*$coef)))
						If ($i%10#0)
							$name:="scaleCmVV_"+String:C10($i)
							$properties:=New object:C1471
							$properties.type:="line"
							$properties.top:=$paper_offset_left+($i*$cm/10*($zoom/100)*$coef)
							$properties.left:=($rulersSize-5)*4/5*($zoom/100)*$coef
							$properties.width:=($rulersSize-5)/5*($zoom/100)*$coef
							$properties.height:=0
							$properties.fill:="lightgrey"
							$properties.stroke:="lightgrey"
							$properties.strokeWidth:=0.1*($zoom/100)*$coef
							$formDefinition.pages[0].objects[$name]:=$properties
						End if 
					End for 
					
					$i:=0
					For each ($lineInRulers; $linesInRulers)
						$i:=$i+1
						$name:="lineInRulers"+String:C10($i)
						$properties:=New object:C1471
						$properties.type:="rectangle"
						$properties.top:=$lineInRulers.min
						$properties.left:=0
						$properties.width:=($rulersSize/2)*($zoom/100)*$coef
						$properties.height:=$lineInRulers.max-$lineInRulers.min
						$properties.fill:=$lineInRulers.color
						$properties.stroke:="black"
						$properties.strokeWidth:=0.1*($zoom/100)*$coef
						$formDefinition.pages[0].objects[$name]:=$properties
						
						If ($zoom>=100)
							$name:="lineInRulersPicto"+String:C10($i)
							$properties:=New object:C1471
							$properties.type:="picture"
							$properties.top:=$lineInRulers.min+(2*($zoom/100)*$coef)
							$properties.left:=2*($zoom/100)
							$properties.width:=(($rulersSize/2)*($zoom/100)*$coef)-($properties.left*2)
							$properties.height:=$properties.width
							$properties.picture:=This:C1470.typology_get_iconPath_byCode($lineInRulers.typology)
							$properties.pictureFormat:="scaled"
							$formDefinition.pages[0].objects[$name]:=$properties
						End if 
						
						$name:="bLineInRulers"+String:C10($i)
						$properties:=New object:C1471
						$properties.type:="button"
						$properties.top:=$lineInRulers.min
						$properties.left:=0
						$properties.width:=($rulersSize/2)*($zoom/100)*$coef
						$properties.height:=$lineInRulers.max-$lineInRulers.min
						$properties.events:=New collection:C1472("onClick")
						$properties.style:="custom"
						$properties.focusable:=False:C215
						$properties.tooltip:=$lineInRulers.tooltip+"\r"+This:C1470.typology_get_name_byCode($lineInRulers.typology)
						$properties.method:="dfd_Template_lineInRulers"
						$formDefinition.pages[0].objects[$name]:=$properties
					End for each 
				End if 
				
				$verticalOffset:=$margin_top
				$verticalOffsetPx:=$margin_topPx
				
				For each ($line; $lines)
					$lineNum:=$lineNum+1
					Case of 
						: ($line.kind="template_line") & (Position:C15(";"+$line.typology+";"; ";FP;FPP;FPS;")#0)
							$templateLine:=ds:C1482.dfd_Line.get($line.UUID_entity)
							$objects:=$templateLine.objectsForm.objects.orderBy("order").copy()
							
							// calculate the dynamic properties
							This:C1470.calculate_dynProp($objects; $destination)
							
							
							// apply the rules
							If ($templateLine.calculs.rules#Null:C1517)
								$rules:=$templateLine.calculs.rules.copy()
								This:C1470.apply_rules($objects; $rules)
							End if 
							
							// build the objects
							$maxBottom:=0
							$maxBottomPx:=0
							
							For each ($object; $objects)
								
								$name:=$object.name+"_"+String:C10($lineNum)
								$properties:=OB Copy:C1225($object.properties)
								
								If (($properties.top+$properties.height+$verticalOffsetPx)>$maxBottomPx)
									$maxBottomPx:=$properties.top+$properties.height+$verticalOffsetPx
								End if 
								
								$properties.top:=($properties.top*($zoom/100)*$coef)+$verticalOffset
								$properties.left:=$margin_left+($properties.left*($zoom/100)*$coef)
								$properties.width:=$properties.width*($zoom/100)*$coef
								$properties.height:=$properties.height*($zoom/100)*$coef
								If ($properties.fontSize#Null:C1517)
									$properties.fontSize:=$properties.fontSize*($zoom/100)*$coefPolice
								End if 
								If ($properties.strokeWidth#Null:C1517)
									$properties.strokeWidth:=$properties.strokeWidth*($zoom/100)*$coef
								End if 
								If (($properties.top+$properties.height)>$maxBottom)
									$maxBottom:=$properties.top+$properties.height
								End if 
								$formDefinition.pages[0].objects[$name]:=$properties
								
							End for each 
							
							$verticalOffset:=$maxBottom
							$verticalOffsetPx:=$maxBottomPx
							
					End case 
				End for each 
				Form:C1466.preview:=New object:C1471
				OBJECT SET SUBFORM:C1138(*; "preview"; $formDefinition)
				
		End case 
		
	Else 
		Case of 
			: ($destination="--subform")
				Form:C1466.preview:=New object:C1471
				OBJECT SET SUBFORM:C1138(*; "preview"; $formDefinition)
				
		End case 
		
	End if 
	
	
Function redraw_buttons()
	//nothing to do
	
	
	
Function load_picts()
	var $file : 4D:C1709.File
	var $pict : Picture
	
	Form:C1466.picts:=New object:C1471
	$file:=File:C1566("/RESOURCES/dfd/image/icon/line.png")
	READ PICTURE FILE:C678($file.platformPath; $pict)
	Form:C1466.picts.line:=$pict
	
	$file:=File:C1566("/RESOURCES/dfd/image/icon/document-break.png")
	READ PICTURE FILE:C678($file.platformPath; $pict)
	Form:C1466.picts.pageBreak:=$pict
	
	$file:=File:C1566("/RESOURCES/dfd/image/icon/document-hf-select.png")
	READ PICTURE FILE:C678($file.platformPath; $pict)
	Form:C1466.picts.header:=$pict
	
	$file:=File:C1566("/RESOURCES/dfd/image/icon/document-hf-select-footer.png")
	READ PICTURE FILE:C678($file.platformPath; $pict)
	Form:C1466.picts.footer:=$pict
	
	$file:=File:C1566("/RESOURCES/dfd/image/icon/document-image.png")
	READ PICTURE FILE:C678($file.platformPath; $pict)
	Form:C1466.picts.bkgd:=$pict
	
	$file:=File:C1566("/RESOURCES/dfd/image/icon/arrow-repeat.png")
	READ PICTURE FILE:C678($file.platformPath; $pict)
	Form:C1466.picts.repeat:=$pict
	
	$file:=File:C1566("/RESOURCES/dfd/image/icon/arrow-repeat2.png")
	READ PICTURE FILE:C678($file.platformPath; $pict)
	Form:C1466.picts.repeat2:=$pict
	
	$file:=File:C1566("/RESOURCES/dfd/image/icon/table-sum.png")
	READ PICTURE FILE:C678($file.platformPath; $pict)
	Form:C1466.picts.rupture:=$pict
	
	$file:=File:C1566("/RESOURCES/dfd/image/icon/table-header.png")
	READ PICTURE FILE:C678($file.platformPath; $pict)
	Form:C1466.picts.repeatHeader:=$pict
	
	$file:=File:C1566("/RESOURCES/dfd/image/icon/table-sumHeader.png")
	READ PICTURE FILE:C678($file.platformPath; $pict)
	Form:C1466.picts.repeatReport:=$pict
	
	
Function load_typologies()
	var $topology : Object
	
	Form:C1466.typologies:=New collection:C1472
	
	// La ligne standard est la typologie par défaut
	$topology:=New object:C1471
	$topology.label:=Localized string:C991("typology.LS")  //"Ligne standard"
	$topology.code:="LS"
	$topology.order:=0
	Form:C1466.typologies.push($topology)
	
	$topology:=New object:C1471
	$topology.label:="-"
	$topology.code:="-"
	$topology.order:=99
	Form:C1466.typologies.push($topology)
	
	// L'entête toutes pages est présente sur toutes les pages 
	$topology:=New object:C1471
	$topology.label:=Localized string:C991("typology.ETP")  //"Entête pour toutes les pages"
	$topology.code:="ETP"
	$topology.order:=100
	Form:C1466.typologies.push($topology)
	
	// L'entête de première page est présente que sur la première page 
	$topology:=New object:C1471
	$topology.label:=Localized string:C991("typology.EPP")  //"Entête de première page"
	$topology.code:="EPP"
	$topology.order:=110
	Form:C1466.typologies.push($topology)
	
	// L'entête de page suivante est présente sur toutes les pages sauf la première page 
	$topology:=New object:C1471
	$topology.label:=Localized string:C991("typology.EPS")  //"Entête des pages suivantes"
	$topology.code:="EPS"
	$topology.order:=120
	Form:C1466.typologies.push($topology)
	
	$topology:=New object:C1471
	$topology.label:="-"
	$topology.code:="-"
	$topology.order:=499
	Form:C1466.typologies.push($topology)
	
	$topology:=New object:C1471
	$topology.label:=Localized string:C991("typology.ECR")  //"Entête corps répété"
	$topology.code:="ECR"
	$topology.order:=500
	$topology.lineProperties:=New collection:C1472
	$topology.lineProperties.push(New object:C1471("name"; "source collection"; "kind"; "collectionSource"; "defaultValue"; ""))
	Form:C1466.typologies.push($topology)
	
	$topology:=New object:C1471
	$topology.label:=Localized string:C991("typology.ERR")  //"Entête report répété"
	$topology.code:="ERR"
	$topology.order:=510
	$topology.lineProperties:=New collection:C1472
	$topology.lineProperties.push(New object:C1471("name"; "source collection"; "kind"; "collectionSource"; "defaultValue"; ""))
	Form:C1466.typologies.push($topology)
	
	// Le corps est repeté pour chaque élément de la collection 
	$topology:=New object:C1471
	$topology.label:=Localized string:C991("typology.CR")  //"Corps répété"
	$topology.code:="CR"
	$topology.order:=550
	$topology.lineProperties:=New collection:C1472
	$topology.lineProperties.push(New object:C1471("name"; "source collection"; "kind"; "collectionSource"; "defaultValue"; ""))
	Form:C1466.typologies.push($topology)
	
	$topology:=New object:C1471
	$topology.label:=Localized string:C991("typology.CRS")  //"Corps répété secondaire"
	$topology.code:="CRS"
	$topology.order:=560
	$topology.lineProperties:=New collection:C1472
	$topology.lineProperties.push(New object:C1471("name"; "main collection"; "kind"; "collectionSource"; "defaultValue"; ""))
	$topology.lineProperties.push(New object:C1471("name"; "sub collection"; "kind"; "subcollectionSource"; "defaultValue"; ""))
	$topology.lineProperties.push(New object:C1471("name"; "alternateWithMain"; "kind"; "alternateWithMain"; "defaultValue"; "True"))
	$topology.lineProperties.push(New object:C1471("name"; "groupWithMain"; "kind"; "groupWithMain"; "defaultValue"; "False"))
	Form:C1466.typologies.push($topology)
	
	$topology:=New object:C1471
	$topology.label:=Localized string:C991("typology.RP")  //"Rupture de page"
	$topology.code:="RP"
	$topology.order:=600
	$topology.lineProperties:=New collection:C1472
	$topology.lineProperties.push(New object:C1471("name"; "source collection"; "kind"; "collectionSource"; "defaultValue"; ""))
	$topology.lineProperties.push(New object:C1471("name"; "afficher en fin"; "kind"; "displayAtEnd"; "defaultValue"; "False"))
	Form:C1466.typologies.push($topology)
	
	$topology:=New object:C1471
	$topology.label:="-"
	$topology.code:="-"
	$topology.order:=999
	Form:C1466.typologies.push($topology)
	
	
	// Pied de page est présent sur toutes les pages 
	$topology:=New object:C1471
	$topology.label:=Localized string:C991("typology.PP")  //"Pied de page"
	$topology.code:="PP"
	$topology.order:=900
	Form:C1466.typologies.push($topology)
	
	$topology:=New object:C1471
	$topology.label:=Localized string:C991("typology.PPP")  //"Pied de premiere page"
	$topology.code:="PPP"
	$topology.order:=910
	Form:C1466.typologies.push($topology)
	
	$topology:=New object:C1471
	$topology.label:=Localized string:C991("typology.PPS")  //"Pied de premiere page"
	$topology.code:="PPS"
	$topology.order:=920
	Form:C1466.typologies.push($topology)
	
	//$topology:=New object
	//$topology.label:=localized string("typology.PPI")  //"Pied de page intermediaire"
	//$topology.code:="PPI"
	//$topology.order:=930
	//Form.typologies.push($topology)
	
	$topology:=New object:C1471
	$topology.label:=Localized string:C991("typology.PPL")  //"Pied de dernière page"
	$topology.code:="PPL"
	$topology.order:=940
	Form:C1466.typologies.push($topology)
	
	
	$topology:=New object:C1471
	$topology.label:="-"
	$topology.code:="-"
	$topology.order:=1999
	Form:C1466.typologies.push($topology)
	
	
	$topology:=New object:C1471
	$topology.label:=Localized string:C991("typology.FP")  //"Fond de page"
	$topology.code:="FP"
	$topology.order:=2000
	Form:C1466.typologies.push($topology)
	
	
	$topology:=New object:C1471
	$topology.label:=Localized string:C991("typology.FPP")  //"Fond de première page"
	$topology.code:="FPP"
	$topology.order:=2010
	Form:C1466.typologies.push($topology)
	
	$topology:=New object:C1471
	$topology.label:=Localized string:C991("typology.FPS")  //"Fond des pages suivantes"
	$topology.code:="FPS"
	$topology.order:=2020
	Form:C1466.typologies.push($topology)
	
	
Function typology_get_icon_byCode($typology : Text)->$icon : Picture
	
	Case of 
		: (Position:C15(";"+$typology+";"; ";ETP;EPP;EPS;")>0)
			$icon:=Form:C1466.picts.header
		: (Position:C15(";"+$typology+";"; ";PP;PPP;PPS;PPI;PPL;")>0)
			$icon:=Form:C1466.picts.footer
		: (Position:C15(";"+$typology+";"; ";FP;FPP;FPS;")>0)
			$icon:=Form:C1466.picts.bkgd
		: (Position:C15(";"+$typology+";"; ";CR;")>0)
			$icon:=Form:C1466.picts.repeat
		: (Position:C15(";"+$typology+";"; ";CRS;")>0)
			$icon:=Form:C1466.picts.repeat2
		: (Position:C15(";"+$typology+";"; ";RP;")>0)
			$icon:=Form:C1466.picts.rupture
		: (Position:C15(";"+$typology+";"; ";ECR;")>0)
			$icon:=Form:C1466.picts.repeatHeader
		: (Position:C15(";"+$typology+";"; ";ERR;")>0)
			$icon:=Form:C1466.picts.repeatReport
		Else 
			$icon:=Form:C1466.picts.line
	End case 
	
Function typology_get_iconPath_byCode($typology : Text)->$path : Text
	
	Case of 
		: (Position:C15(";"+$typology+";"; ";ETP;EPP;EPS;")>0)
			$path:="/RESOURCES/dfd/image/icon/document-hf-select.png"
		: (Position:C15(";"+$typology+";"; ";PP;PPP;PPS;PPI;PPL;")>0)
			$path:="/RESOURCES/dfd/image/icon/document-hf-select-footer.png"
		: (Position:C15(";"+$typology+";"; ";FP;FPP;FPS;")>0)
			$path:="/RESOURCES/dfd/image/icon/document-image.png"
		: (Position:C15(";"+$typology+";"; ";CR;")>0)
			$path:="/RESOURCES/dfd/image/icon/arrow-repeat.png"
		: (Position:C15(";"+$typology+";"; ";CRS;")>0)
			$path:="/RESOURCES/dfd/image/icon/arrow-repeat2.png"
		: (Position:C15(";"+$typology+";"; ";RP;")>0)
			$path:="/RESOURCES/dfd/image/icon/table-sum.png"
		: (Position:C15(";"+$typology+";"; ";ECR;")>0)
			$path:="/RESOURCES/dfd/image/icon/table-header.png"
		: (Position:C15(";"+$typology+";"; ";ERR;")>0)
			$path:="/RESOURCES/dfd/image/icon/table-sumHeader.png"
		Else 
			$path:="/RESOURCES/dfd/image/icon/line.png"
	End case 
	
Function typology_get_name_byCode($code : Text)->$name : Text
	var $indices : Collection
	If (Form:C1466.typologies=Null:C1517)
		This:C1470.load_typologies()
	End if 
	$indices:=Form:C1466.typologies.indices("code = :1"; $code)
	If ($indices.length>0)
		$name:=Form:C1466.typologies[$indices[0]].label
	Else 
		$name:=""
	End if 
	
Function calculate_dynProp($objects : Collection; $destination : Text)
	cs:C1710.dfd_panel_line.me.calculate_dynProp($objects; $destination)
	
Function apply_rules($objects : Collection; $rules : Collection)
	cs:C1710.dfd_panel_line.me.apply_rules($objects; $rules)
	
	
Function tool_choose_color($index : Integer)->$color : Text
	
	var $colors : Collection
	
	$colors:=New collection:C1472
	
	$colors.push("#ffcdd2")
	$colors.push("#f8bbd0")
	$colors.push("#ffccbc")
	$colors.push("#d1c4e9")
	$colors.push("#90caf9")
	$colors.push("#b2ebf2")
	$colors.push("#b2dfdb")
	$colors.push("#c8e6c9")
	$colors.push("#dcedc8")
	$colors.push("#fff9c4")
	$colors.push("#c5cae9")
	$colors.push("#ffecb3")
	$colors.push("#ffe0b2")
	$colors.push("#b3e5fc")
	$colors.push("#f0f4c3")
	$colors.push("#d7ccc8")
	$colors.push("#cfd8dc")
	$colors.push("#e1bee7")
	
	//$colors.push("#E67E22")
	//$colors.push("#85C1E9")
	//$colors.push("#C39BD3")
	//$colors.push("#F5B7B1")
	//$colors.push("#5499C7")
	//$colors.push("#DC7633")
	//$colors.push("#F1C40F")
	//$colors.push("#618a9c")
	//$colors.push("#ef5a78")
	//$colors.push("#f89a1c")
	//$colors.push("#c09e3d")
	//$colors.push("#faef07")
	//$colors.push("#9cd1bd")
	//$colors.push("#dfd284")
	//$colors.push("#4eb947")
	//$colors.push("#b8a181")
	//$colors.push("#ef2d36")
	//$colors.push("#df9846")
	//$colors.push("#b65671")
	//$colors.push("#97839c")
	//$colors.push("#d0b194")
	//$colors.push("#817d74")
	//$colors.push("#e3be25")
	//$colors.push("#b8cbf6")
	//$colors.push("#a0a48a")
	//$colors.push("#4eb947")
	//$colors.push("#df9e9c")
	//$colors.push("#be2947")
	//$colors.push("#f69b7f")
	//$colors.push("#66aba6")
	//$colors.push("#b6c46f")
	//$colors.push("#e0844b")
	//$colors.push("#da0c67")
	//$colors.push("#28b44b")
	//$colors.push("#f68a5c")
	
	$color:=$colors[$index%($colors.length)]
	
Function activate_SaveCancel()
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
	
	
	
	
	
	
	
	//mark:-object methods
	
Function column_setting_value()
	$0:=0
	Case of 
		: (Form:C1466.sfw.checkIsntInModification())
			
		: (FORM Event:C1606.code=On Before Data Entry:K2:39) && (Form:C1466.setting#Null:C1517) && (Bool:C1537(Form:C1466.setting.notEditable))
			$0:=-1
		: (FORM Event:C1606.code=On Data Change:K2:15)
			
			Form:C1466.current_item.moreData.settings[Form:C1466.setting.name]:=Form:C1466.setting.value
			This:C1470.activate_SaveCancel()
			This:C1470.redraw_preview()
	End case 
	
Function bMethod()
	var $data : Object
	var $ref : Integer
	
	If (Form:C1466.sfw.checkIsInModification())
		$data:=New object:C1471
		$data.method:=Form:C1466.current_item.moreData.methodPrep
		
		$ref:=Open form window:C675("dfd_method_editor"; Movable form dialog box:K39:8)
		DIALOG:C40("dfd_method_editor"; $data)
		CLOSE WINDOW:C154($ref)
		
		If (ok=1)
			Form:C1466.current_item.moreData.methodPrep:=$data.method
			Form:C1466.current_item:=Form:C1466.current_item
			This:C1470.activate_SaveCancel()
		End if 
	End if 
	
Function lb_variables()
	$0:=0
	
	Case of 
		: (Form:C1466.sfw.checkIsntInModification())
			
		: (FORM Event:C1606.code=On Clicked:K2:4) & (Right click:C712 | Contextual click:C713)
			
			$menus:=New collection:C1472()
			$refMenu:=Create menu:C408()
			$menus.push($refMenu)
			
			
			
			$refSubMenu:=Create menu:C408()
			$menus.push($refSubMenu)
			
			APPEND MENU ITEM:C411($refSubMenu; Localized string:C991("tool.menu.first"); *)  //"Premier"
			If (Form:C1466.linePosition>1)
				ENABLE MENU ITEM:C149($refSubMenu; -1)
			Else 
				DISABLE MENU ITEM:C150($refSubMenu; -1)
			End if 
			SET MENU ITEM PARAMETER:C1004($refSubMenu; -1; "--first")
			
			APPEND MENU ITEM:C411($refSubMenu; Localized string:C991("tool.menu.up"); *)  //"Monter"
			If (Form:C1466.linePosition>1)
				ENABLE MENU ITEM:C149($refSubMenu; -1)
			Else 
				DISABLE MENU ITEM:C150($refSubMenu; -1)
			End if 
			SET MENU ITEM PARAMETER:C1004($refSubMenu; -1; "--up")
			
			
			APPEND MENU ITEM:C411($refSubMenu; Localized string:C991("tool.menu.down"); *)  //"Descendre"
			If (Form:C1466.linePosition>0) & (Form:C1466.linePosition<Form:C1466.lb_lines.length)
				ENABLE MENU ITEM:C149($refSubMenu; -1)
			Else 
				DISABLE MENU ITEM:C150($refSubMenu; -1)
			End if 
			SET MENU ITEM PARAMETER:C1004($refSubMenu; -1; "--down")
			
			APPEND MENU ITEM:C411($refSubMenu; Localized string:C991("tool.menu.last"); *)  // "Dernier"
			If (Form:C1466.linePosition>0) & (Form:C1466.linePosition<Form:C1466.lb_lines.length)
				ENABLE MENU ITEM:C149($refSubMenu; -1)
			Else 
				DISABLE MENU ITEM:C150($refSubMenu; -1)
			End if 
			SET MENU ITEM PARAMETER:C1004($refSubMenu; -1; "--last")
			
			
			APPEND MENU ITEM:C411($refMenu; Localized string:C991("tool.menu.organize"); $refSubMenu; *)  //"Organiser";
			
			
			APPEND MENU ITEM:C411($refMenu; Localized string:C991("tool.menu.delete"); *)  //"Supprimer"
			If (Form:C1466.linePosition>0)
				ENABLE MENU ITEM:C149($refMenu; -1)
			Else 
				DISABLE MENU ITEM:C150($refMenu; -1)
			End if 
			SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--delete")
			
			$choose:=Dynamic pop up menu:C1006($refMenu)
			For each ($refMenu; $menus)
				RELEASE MENU:C978($refMenu)
			End for each 
			
			
			
			Case of 
				: ($choose="--delete")
					$uuid:=Form:C1466.line.line.UUID_entity
					$indices:=Form:C1466.current_item.hierarchy.lines.indices("UUID_entity = :1"; $uuid)
					If ($indices.length>0)
						Form:C1466.current_item.hierarchy.lines.remove($indices[0])
						This:C1470.activate_SaveCancel()
						
						If (Form:C1466.linePosition<=Form:C1466.lb_lines.length)
							This:C1470.redraw_lb_lines(Form:C1466.line)
						Else 
							This:C1470.redraw_lb_lines(0)
						End if 
					End if 
					
				: ($choose="--first")
					$uuid:=Form:C1466.line.line.UUID_entity
					$indices:=Form:C1466.current_item.hierarchy.lines.indices("UUID_entity = :1"; $uuid)
					If ($indices.length>0)
						$lineToMove:=Form:C1466.current_item.hierarchy.lines[$indices[0]]
						Form:C1466.current_item.hierarchy.lines.remove($indices[0])
						Form:C1466.current_item.hierarchy.lines.unshift($lineToMove)
						This:C1470.activate_SaveCancel()
						This:C1470.redraw_lb_lines(1)
					End if 
					
					
				: ($choose="--last")
					$uuid:=Form:C1466.line.line.UUID_entity
					$indices:=Form:C1466.current_item.hierarchy.lines.indices("UUID_entity = :1"; $uuid)
					If ($indices.length>0)
						$lineToMove:=Form:C1466.current_item.hierarchy.lines[$indices[0]]
						Form:C1466.current_item.hierarchy.lines.remove($indices[0])
						Form:C1466.current_item.hierarchy.lines.push($lineToMove)
						This:C1470.activate_SaveCancel()
						This:C1470.redraw_lb_lines(Form:C1466.lb_lines.length)
					End if 
					
				: ($choose="--up")
					$lineToMove1:=Form:C1466.current_item.hierarchy.lines[Form:C1466.linePosition-1]
					$lineToMove2:=Form:C1466.current_item.hierarchy.lines[Form:C1466.linePosition-2]
					Form:C1466.current_item.hierarchy.lines[Form:C1466.linePosition-2]:=$lineToMove1
					Form:C1466.current_item.hierarchy.lines[Form:C1466.linePosition-1]:=$lineToMove2
					This:C1470.activate_SaveCancel()
					This:C1470.redraw_lb_lines(Form:C1466.linePosition-1)
					
				: ($choose="--down")
					$lineToMove1:=Form:C1466.current_item.hierarchy.lines[Form:C1466.linePosition-1]
					$lineToMove2:=Form:C1466.current_item.hierarchy.lines[Form:C1466.linePosition]
					Form:C1466.current_item.hierarchy.lines[Form:C1466.linePosition]:=$lineToMove1
					Form:C1466.current_item.hierarchy.lines[Form:C1466.linePosition-1]:=$lineToMove2
					This:C1470.activate_SaveCancel()
					This:C1470.redraw_lb_lines(Form:C1466.linePosition)
					
					
			End case 
			
		: (FORM Event:C1606.code=On Clicked:K2:4) & (Form:C1466.line#Null:C1517)
			
			
		: (FORM Event:C1606.code=On Drag Over:K2:13)
			$class:=OB Class:C1730(<>DFD_dragdrop.template_line)
			Case of 
				: ($class.name="dfd_LineEntity") & (Form:C1466.current_item#Null:C1517)
					
				Else 
					$0:=-1
			End case 
			
		: (FORM Event:C1606.code=On Drop:K2:12)
			$class:=OB Class:C1730(<>DFD_dragdrop.template_line)
			If ($class.name="dfd_LineEntity")
				$position:=Drop position:C608
				$lines:=Form:C1466.current_item.hierarchy.lines
				
				$line:=New object:C1471
				$line.kind:="template_line"
				$line.UUID_entity:=<>DFD_dragdrop.template_line.UUID
				$line.typology:="LS"
				If ($position=-1)
					$lines.push($line)
					$position:=$lines.length
				Else 
					$lines.insert($position-1; $line)
				End if 
				This:C1470.redraw_lb_lines($position)
				This:C1470.activate_SaveCancel()
				
			End if 
			
		: (FORM Event:C1606.code=On Mouse Move:K2:35)
			$row:=FORM Event:C1606.row
			If ($row#Null:C1517) && (FORM Event:C1606.column=2)
				SET DATABASE PARAMETER:C642(Tips delay:K37:80; 0)
				OBJECT SET HELP TIP:C1181(*; OBJECT Get name:C1087(Object current:K67:2); Form:C1466.lb_variables[$row-1].lines)
			Else 
				OBJECT SET HELP TIP:C1181(*; OBJECT Get name:C1087(Object current:K67:2); "")
				
			End if 
	End case 
	
	
Function lb_lines()
	$0:=0
	
	Case of 
		: (Form:C1466.sfw.checkIsntInModification())
			
		: (FORM Event:C1606.code=On Clicked:K2:4) & (Right click:C712 | Contextual click:C713)
			
			$menus:=New collection:C1472()
			$refMenu:=Create menu:C408()
			$menus.push($refMenu)
			
			$refSubMenu:=Create menu:C408()
			$menus.push($refSubMenu)
			
			APPEND MENU ITEM:C411($refSubMenu; Localized string:C991("tool.menu.first"); *)  //"Premier"
			If (Form:C1466.linePosition>1)
				ENABLE MENU ITEM:C149($refSubMenu; -1)
			Else 
				DISABLE MENU ITEM:C150($refSubMenu; -1)
			End if 
			SET MENU ITEM PARAMETER:C1004($refSubMenu; -1; "--first")
			
			APPEND MENU ITEM:C411($refSubMenu; Localized string:C991("tool.menu.up"); *)  //"Monter"
			If (Form:C1466.linePosition>1)
				ENABLE MENU ITEM:C149($refSubMenu; -1)
			Else 
				DISABLE MENU ITEM:C150($refSubMenu; -1)
			End if 
			SET MENU ITEM PARAMETER:C1004($refSubMenu; -1; "--up")
			
			
			APPEND MENU ITEM:C411($refSubMenu; Localized string:C991("tool.menu.down"); *)  // "Descendre"
			If (Form:C1466.linePosition>0) & (Form:C1466.linePosition<Form:C1466.lb_lines.length)
				ENABLE MENU ITEM:C149($refSubMenu; -1)
			Else 
				DISABLE MENU ITEM:C150($refSubMenu; -1)
			End if 
			SET MENU ITEM PARAMETER:C1004($refSubMenu; -1; "--down")
			
			APPEND MENU ITEM:C411($refSubMenu; Localized string:C991("tool.menu.last"); *)  //"Dernier"
			If (Form:C1466.linePosition>0) & (Form:C1466.linePosition<Form:C1466.lb_lines.length)
				ENABLE MENU ITEM:C149($refSubMenu; -1)
			Else 
				DISABLE MENU ITEM:C150($refSubMenu; -1)
			End if 
			SET MENU ITEM PARAMETER:C1004($refSubMenu; -1; "--last")
			
			
			APPEND MENU ITEM:C411($refMenu; Localized string:C991("tool.menu.organize"); $refSubMenu; *)
			
			APPEND MENU ITEM:C411($refMenu; Localized string:C991("tool.menu.insertBreak"); *)  //"Insérer un saut de page"
			If (Form:C1466.linePosition>0)
				ENABLE MENU ITEM:C149($refMenu; -1)
			Else 
				DISABLE MENU ITEM:C150($refMenu; -1)
			End if 
			SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--pageBreak")
			
			APPEND MENU ITEM:C411($refMenu; "-")
			
			APPEND MENU ITEM:C411($refMenu; Localized string:C991("tool.menu.delete"); *)  //"Supprimer"
			If (Form:C1466.linePosition>0)
				ENABLE MENU ITEM:C149($refMenu; -1)
			Else 
				DISABLE MENU ITEM:C150($refMenu; -1)
			End if 
			SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--delete")
			
			$choose:=Dynamic pop up menu:C1006($refMenu)
			For each ($refMenu; $menus)
				RELEASE MENU:C978($refMenu)
			End for each 
			
			Case of 
				: ($choose="--delete") && (Form:C1466.line.line.UUID_entity#Null:C1517)
					$uuid:=Form:C1466.line.line.UUID_entity
					$indices:=Form:C1466.current_item.hierarchy.lines.indices("UUID_entity = :1"; $uuid)
					If ($indices.length>0)
						Form:C1466.current_item.hierarchy.lines.remove($indices[0])
						This:C1470.activate_SaveCancel()
						
						If (Form:C1466.linePosition<=Form:C1466.lb_lines.length)
							This:C1470.redraw_lb_lines(Form:C1466.linePosition)
						Else 
							This:C1470.redraw_lb_lines(0)
						End if 
					End if 
					
				: ($choose="--delete")
					
					Form:C1466.current_item.hierarchy.lines.remove(Form:C1466.linePosition)
					This:C1470.activate_SaveCancel()
					This:C1470.redraw_lb_lines(0)
					
					
				: ($choose="--first")
					$uuid:=Form:C1466.line.line.UUID_entity
					$indices:=Form:C1466.current_item.hierarchy.lines.indices("UUID_entity = :1"; $uuid)
					If ($indices.length>0)
						$lineToMove:=Form:C1466.current_item.hierarchy.lines[$indices[0]]
						Form:C1466.current_item.hierarchy.lines.remove($indices[0])
						Form:C1466.current_item.hierarchy.lines.unshift($lineToMove)
						This:C1470.activate_SaveCancel()
						This:C1470.redraw_lb_lines(1)
						
					End if 
					
					
				: ($choose="--last")
					$uuid:=Form:C1466.line.line.UUID_entity
					$indices:=Form:C1466.current_item.hierarchy.lines.indices("UUID_entity = :1"; $uuid)
					If ($indices.length>0)
						$lineToMove:=Form:C1466.current_item.hierarchy.lines[$indices[0]]
						Form:C1466.current_item.hierarchy.lines.remove($indices[0])
						Form:C1466.current_item.hierarchy.lines.push($lineToMove)
						This:C1470.activate_SaveCancel()
						This:C1470.redraw_lb_lines(Form:C1466.lb_lines.length)
					End if 
					
				: ($choose="--up")
					$lineToMove1:=Form:C1466.current_item.hierarchy.lines[Form:C1466.linePosition-1]
					$lineToMove2:=Form:C1466.current_item.hierarchy.lines[Form:C1466.linePosition-2]
					Form:C1466.current_item.hierarchy.lines[Form:C1466.linePosition-2]:=$lineToMove1
					Form:C1466.current_item.hierarchy.lines[Form:C1466.linePosition-1]:=$lineToMove2
					This:C1470.activate_SaveCancel()
					This:C1470.redraw_lb_lines(Form:C1466.linePosition-1)
					
				: ($choose="--down")
					$lineToMove1:=Form:C1466.current_item.hierarchy.lines[Form:C1466.linePosition-1]
					$lineToMove2:=Form:C1466.current_item.hierarchy.lines[Form:C1466.linePosition]
					Form:C1466.current_item.hierarchy.lines[Form:C1466.linePosition]:=$lineToMove1
					Form:C1466.current_item.hierarchy.lines[Form:C1466.linePosition-1]:=$lineToMove2
					This:C1470.activate_SaveCancel()
					This:C1470.redraw_lb_lines(Form:C1466.linePosition)
					
					
				: ($choose="--pageBreak")
					$lines:=Form:C1466.current_item.hierarchy.lines
					$linePageBreak:=New object:C1471
					$linePageBreak.kind:="pageBreak"
					$position:=Form:C1466.linePosition
					If ($position<=0)
						$lines.push($linePageBreak)
					Else 
						$lines.insert($position-1; $linePageBreak)
					End if 
					This:C1470.activate_SaveCancel()
					This:C1470.redraw_lb_lines($position)
					
			End case 
			This:C1470.redraw_lb_variables()
			
			
		: (FORM Event:C1606.code=On Clicked:K2:4)
			This:C1470.redraw_lb_properties()
			
			
		: (FORM Event:C1606.code=On Drag Over:K2:13)
			$class:=OB Class:C1730(<>DFD_dragdrop.template_line)
			Case of 
				: ($class.name="dfd_LineEntity") & (Form:C1466.current_item#Null:C1517)
					
				Else 
					$0:=-1
			End case 
			
		: (FORM Event:C1606.code=On Drop:K2:12)
			$class:=OB Class:C1730(<>DFD_dragdrop.template_line)
			If ($class.name="dfd_LineEntity")
				$position:=Drop position:C608
				$lines:=Form:C1466.current_item.hierarchy.lines
				
				$line:=New object:C1471
				$line.kind:="template_line"
				$line.UUID_entity:=<>DFD_dragdrop.template_line.UUID
				$line.typology:="LS"
				If ($position=-1)
					$lines.push($line)
					$position:=$lines.length
				Else 
					$lines.insert($position-1; $line)
				End if 
				This:C1470.redraw_lb_lines($position)
				This:C1470.redraw_lb_variables()
				
				This:C1470.activate_SaveCancel()
				
			End if 
			
		: (FORM Event:C1606.code=On Double Clicked:K2:5)
			
			//If (Form.line#Null)
			//$formData:=New object("choosenTemplateLine"; Form.line.line.UUID_entity)
			//$pr:=New process("DFD_TempLine_launch_dialog"; 0; "TempLine"; 1; $formData)
			//End if 
			
	End case 
	
	
Function lb_properties()
	Case of 
		: (Form:C1466.sfw.checkIsntInModification())
			
		: (FORM Event:C1606.code=On Clicked:K2:4) & (Right click:C712 | Contextual click:C713) & (Form:C1466.line#Null:C1517)
			$menus:=New collection:C1472()
			$refMenu:=Create menu:C408()
			$menus.push($refMenu)
			
			$refSubMenu:=Create menu:C408()
			$menus.push($refSubMenu)
			
			APPEND MENU ITEM:C411($refSubMenu; Localized string:C991("tool.menu.visibility"); *)  //"Visibility"
			If (Form:C1466.line.line#Null:C1517) && (Form:C1466.line.line.properties#Null:C1517)
				$indices:=Form:C1466.line.line.properties.indices("kind = :1"; "visibility")
			Else 
				$indices:=New collection:C1472
			End if 
			If ($indices.length=0)
				ENABLE MENU ITEM:C149($refSubMenu; -1)
			Else 
				DISABLE MENU ITEM:C150($refSubMenu; -1)
			End if 
			SET MENU ITEM PARAMETER:C1004($refSubMenu; -1; "--visibility")
			
			APPEND MENU ITEM:C411($refMenu; Localized string:C991("tool.menu.addProperty"); $refSubMenu; *)
			
			If (Form:C1466.position_property>0) && (Form:C1466.property.kind="visibility")
				APPEND MENU ITEM:C411($refMenu; Localized string:C991("tool.menu.delete"); *)
				SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--delete")
			End if 
			
			$choose:=Dynamic pop up menu:C1006($refMenu)
			For each ($refMenu; $menus)
				RELEASE MENU:C978($refMenu)
			End for each 
			
			Case of 
				: ($choose="--visibility")
					$property:=New object:C1471
					$property.name:=Localized string:C991("template.visibility")
					$property.kind:="visibility"
					$property.value:="visible"
					Form:C1466.line.line.properties.push($property)
					This:C1470.redraw_lb_properties()
					This:C1470.activate_SaveCancel()
					
				: ($choose="--delete")
					
					$indices:=Form:C1466.line.line.properties.indices("name = :1"; Form:C1466.property.name)
					If ($indices.length>0)
						Form:C1466.line.line.properties.remove($indices[0])
						This:C1470.redraw_lb_properties()
						This:C1470.activate_SaveCancel()
					End if 
			End case 
	End case 
	
Function column_property_value()
	$0:=0
	Case of 
		: (Form:C1466.sfw.checkIsntInModification())
			
		: (FORM Event:C1606.code=On Before Data Entry:K2:39) && (Form:C1466.property#Null:C1517) && (Bool:C1537(Form:C1466.property.notEditable))
			$0:=-1
			
		: (FORM Event:C1606.code=On Before Data Entry:K2:39) && (Form:C1466.line#Null:C1517) && (Form:C1466.property#Null:C1517) && (String:C10(Form:C1466.property.kind)="--typology")
			
			//If (Keystroke#"\t")
			
			$ref:=Form:C1466.current_item.getKey()+Form:C1466.line.name+Form:C1466.property.name
			
			//If (Form.lastLineEventOnBefore=Null) || (Form.lastLineEventOnBefore#$ref)
			//Form.lastLineEventOnBefore:=$ref
			
			$refMenu:=Create menu:C408()
			
			For each ($typology; Form:C1466.typologies)
				APPEND MENU ITEM:C411($refMenu; $typology.label)
				SET MENU ITEM PARAMETER:C1004($refMenu; -1; $typology.code)
				SET MENU ITEM ICON:C984($refMenu; -1; "Path:"+This:C1470.typology_get_iconPath_byCode($typology.code))
				If (Form:C1466.line.line.typology=$typology.code)
					SET MENU ITEM MARK:C208($refMenu; -1; Char:C90(18))
				End if 
			End for each 
			
			$choose:=Dynamic pop up menu:C1006($refMenu)
			RELEASE MENU:C978($refMenu)
			
			Case of 
				: ($choose#"")
					Form:C1466.line.line.typology:=$choose
					$indices:=Form:C1466.typologies.indices("code = :1"; $choose)
					If ($indices.length>0)
						Form:C1466.property.value:=Form:C1466.typologies[$indices[0]].label
						Form:C1466.line.typology:=Form:C1466.typologies[$indices[0]].label
						Form:C1466.line.pict:=This:C1470.typology_get_icon_byCode(Form:C1466.line.line.typology)
						If (Form:C1466.line.line.properties#Null:C1517)
							$old_lb_properties:=Form:C1466.line.line.properties.copy()
						Else 
							$old_lb_properties:=New collection:C1472
						End if 
						Form:C1466.line.line.properties:=New collection:C1472
						If (Form:C1466.typologies[$indices[0]].lineProperties#Null:C1517)
							For each ($property; Form:C1466.typologies[$indices[0]].lineProperties)
								$indices2:=$old_lb_properties.indices("kind = :1"; $property.kind)
								If ($indices2.length=0)
									Form:C1466.line.line.properties.push(OB Copy:C1225($property))
								Else 
									Form:C1466.line.line.properties.push(OB Copy:C1225($old_lb_properties[$indices2[0]]))
								End if 
							End for each 
						End if 
						
						Form:C1466.lb_lines:=Form:C1466.lb_lines
						This:C1470.redraw_lb_properties()
					End if 
					
					This:C1470.activate_SaveCancel()
			End case 
			
			//Form.lastLineEventOnBefore:=""
			$0:=-1
			//End if 
			//Else 
			//$0:=-1
			//End if 
			
		: (FORM Event:C1606.code=On Before Data Entry:K2:39) && (Form:C1466.line#Null:C1517) && (Form:C1466.property#Null:C1517)
			If (Form:C1466.line.line.kind="pageBreak")
				
				$refMenus:=New collection:C1472
				$refMenu:=Create menu:C408
				$refMenus.push($refMenu)
				
				APPEND MENU ITEM:C411($refMenu; "portrait"; *)
				SET MENU ITEM PARAMETER:C1004($refMenu; -1; "portrait")
				APPEND MENU ITEM:C411($refMenu; "landscape"; *)
				SET MENU ITEM PARAMETER:C1004($refMenu; -1; "landscape")
				$choose:=Dynamic pop up menu:C1006($refMenu)
				For each ($refMenu; $refMenus)
					RELEASE MENU:C978($refMenu)
				End for each 
				
				Case of 
					: ($choose#"")
						Form:C1466.line.line.orientation:=$choose
						This:C1470.activate_SaveCancel()
						Form:C1466.property.value:=$choose
				End case 
			Else 
				$0:=0
			End if 
			
		: (FORM Event:C1606.code=On Data Change:K2:15) && (Form:C1466.line#Null:C1517) && (Form:C1466.property#Null:C1517)
			$value:=Form:C1466.property.value
			$kind:=Form:C1466.property.kind
			$indices:=Form:C1466.line.line.properties.indices("kind = :1"; $kind)
			If ($indices.length>0)
				Form:C1466.line.line.properties[$indices[0]].value:=$value
			End if 
			This:C1470.activate_SaveCancel()
			
	End case 
	
	
	
Function ruler()
	This:C1470.redraw_preview()
	
Function bPrint()
	This:C1470.redraw_preview("--print")
	
Function bRuler()
	This:C1470.redraw_preview()
	
Function bFormat()
	If (Form:C1466.sfw.checkIsInModification())
		
		$refMenu:=Create menu:C408
		
		For each ($format; Form:C1466.paper.formats)
			APPEND MENU ITEM:C411($refMenu; $format.name)
			SET MENU ITEM PARAMETER:C1004($refMenu; -1; $format.name)
		End for each 
		$choose:=Dynamic pop up menu:C1006($refMenu)
		RELEASE MENU:C978($refMenu)
		
		If ($choose#"")
			Form:C1466.paper.format:=$choose
			OBJECT SET TITLE:C194(*; "bFormat"; Form:C1466.paper.format)
			If (Form:C1466.current_item.moreData.settings.format#$choose)
				Form:C1466.current_item.moreData.settings.format:=$choose
				This:C1470.redraw_lb_settings()
				This:C1470.activate_SaveCancel()
			End if 
		End if 
		This:C1470.redraw_preview()
	End if 
	
Function bPortrait()
	If (Form:C1466.sfw.checkIsInModification())
		If (Form:C1466.current_item.moreData.settings.orientation#"portrait")
			Form:C1466.current_item.moreData.settings.orientation:="portrait"
			This:C1470.redraw_lb_settings()
			This:C1470.activate_SaveCancel()
		End if 
		This:C1470.redraw_preview()
	End if 
	
Function bLandscape()
	If (Form:C1466.sfw.checkIsInModification())
		If (Form:C1466.current_item.moreData.settings.orientation#"landscape")
			Form:C1466.current_item.moreData.settings.orientation:="landscape"
			This:C1470.redraw_lb_settings()
			This:C1470.activate_SaveCancel()
		End if 
		This:C1470.redraw_preview()
	End if 
	
Function preview()
	Case of 
		: (FORM Event:C1606.code=-100)
			If (Form:C1466.preview.numLine<=Form:C1466.lb_lines.length)
				LISTBOX SELECT ROW:C912(*; "lb_lines"; Form:C1466.preview.numLine; lk replace selection:K53:1)
				Form:C1466.linePosition:=Form:C1466.preview.numLine-1
				Form:C1466.line:=Form:C1466.lb_lines[Form:C1466.preview.numLine-1]
				This:C1470.redraw_lb_properties()
			End if 
	End case 
	
	
Function bAddLine()
	
	If (Form:C1466.sfw.checkIsInModification())
		
		$refMenus:=New collection:C1472
		$refMenu:=Create menu:C408
		$refMenus.push($refMenu)
		
		For each ($line; ds:C1482.dfd_Line.all().orderBy("name"))
			APPEND MENU ITEM:C411($refMenu; $line.name; *)
			SET MENU ITEM PARAMETER:C1004($refMenu; -1; "addLine:"+$line.UUID)
		End for each 
		$choose:=Dynamic pop up menu:C1006($refMenu)
		For each ($refMenu; $refMenus)
			RELEASE MENU:C978($refMenu)
		End for each 
		
		Case of 
			: ($choose="addLine:@")
				$uuid:=Split string:C1554($choose; ":").pop()
				
				$lines:=Form:C1466.current_item.hierarchy.lines
				
				$lineObject:=New object:C1471
				$lineObject.kind:="template_line"
				$lineObject.UUID_entity:=$uuid
				$lineObject.typology:="LS"
				$lines.push($lineObject)
				$position:=$lines.length
				
				This:C1470.redraw_lb_lines($position)
				This:C1470.redraw_lb_variables()
				
				This:C1470.activate_SaveCancel()
		End case 
	End if 
	
	
	//Mark:-Pup_DocumentFolder
Function drawPup_documentFolder()
	
	If (Form:C1466.current_item#Null:C1517)
		$documentFolderName:=Form:C1466.current_item.documentFolder.name || " - Document folder - "
		Form:C1466.sfw.drawButtonPup("pup_documentFolder"; $documentFolderName; "sfw/image/skin/rainbow/icon/spacer-1x24.png"; (Form:C1466.current_item.documentFolder=Null:C1517))
	End if 
	
	
	
Function pup_documentFolder()
	If (Form:C1466.sfw.checkIsInModification())
		If (Storage:C1525.cache=Null:C1517) || (Storage:C1525.cache.documentFolder=Null:C1517)
			ds:C1482.sfw_DocumentFolder.cacheLoad()
		End if 
		
		This:C1470.hpup_menus:=New collection:C1472
		$menu:=This:C1470._hpup_documentFolder()
		
		$choose:=Dynamic pop up menu:C1006($menu)
		For each ($menu; This:C1470.hpup_menus)
			RELEASE MENU:C978($menu)
		End for each 
		
		Case of 
			: ($choose="")
			Else 
				$eDocumentFolder:=ds:C1482.sfw_DocumentFolder.get($choose)
				Form:C1466.current_item.UUID_DocumentFolder:=$eDocumentFolder.UUID
		End case 
	End if 
	
	This:C1470.drawPup_documentFolder()
	
Function _hpup_documentFolder($uuid_parent : Text)->$menu : Text
	var $parentFolder : Object
	var $parentFolders : Collection
	
	If (Count parameters:C259=0)
		$parentFolders:=Storage:C1525.cache.documentFolder.query("UUID_ParentFolder = :1"; (16*"00"))
	Else 
		$parentFolders:=Storage:C1525.cache.documentFolder.query("UUID_ParentFolder = :1 order by name"; $uuid_parent)
	End if 
	If ($parentFolders.length=0)
		$menu:=""
	Else 
		$menu:=Create menu:C408
		This:C1470.hpup_menus.push($menu)
		For each ($parentFolder; $parentFolders)
			$subMenu:=This:C1470._hpup_documentFolder($parentFolder.UUID)
			If ($subMenu="")
				APPEND MENU ITEM:C411($menu; $parentFolder.name; *)
			Else 
				APPEND MENU ITEM:C411($menu; $parentFolder.name; $subMenu; *)
			End if 
			SET MENU ITEM PARAMETER:C1004($menu; -1; $parentFolder.UUID)
			If ($parentFolder.UUID=Form:C1466.current_item.UUID_DocumentFolder)
				SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
			End if 
		End for each 
	End if 
	
	
	
	// Object methode
	
	
	//mark:-permissions
	
	
Function resizeObjectsPagePermissions()
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubForm; $heightSubForm)
	$margin:=3
	OBJECT GET COORDINATES:C663(*; "bAction_permissions"; $btg; $bth; $btd; $btb)
	$btHeight:=$btb-$bth
	$btWidth:=$btd-$btg
	OBJECT GET COORDINATES:C663(*; "permissions_bkgd"; $g; $h; $d; $b)
	
	OBJECT SET COORDINATES:C1248(*; "permissions_bkgd"; -1; $h; $d; $heightSubForm+1)
	OBJECT SET COORDINATES:C1248(*; "bAction_permissions"; $margin; $heightSubForm-$btHeight-($margin*1); $margin+$btWidth; $heightSubForm-($margin*1))
	OBJECT SET COORDINATES:C1248(*; "hl_permissions"; 0; $h; $d-1; $heightSubForm-$btHeight-($margin*2))
	OBJECT SET COORDINATES:C1248(*; "hl_bkgd"; 0; $h; $d-1; $heightSubForm-$btHeight-($margin*2))
	
	
Function buildHLPermissions()
	var $eProfile : cs:C1710.sfw_UserProfileEntity
	var $esProfiles : cs:C1710.sfw_UserProfileSelection
	
	If (Form:C1466.hl_permissions#Null:C1517) && (Is a list:C621(Form:C1466.hl_permissions))
		CLEAR LIST:C377(Form:C1466.hl_permissions; *)
	End if 
	Form:C1466.hl_permissions:=New list:C375
	$refInList:=0
	$identProfiles:=Form:C1466.current_item.moreData.allowedProfiles || New collection:C1472
	$esProfiles:=ds:C1482.sfw_UserProfile.query("ident in :1 order by name"; $identProfiles)
	If ($esProfiles.length>0)
		$subList:=New list:C375
		For each ($eProfile; $esProfiles)
			$refInList+=1
			APPEND TO LIST:C376($subList; $eProfile.name; $refInList)
			SET LIST ITEM PARAMETER:C986($subList; $refInList; "profilIdent"; $eProfile.ident)
		End for each 
		$refInList+=1
		APPEND TO LIST:C376(Form:C1466.hl_permissions; ds:C1482.sfw_readXliff("dfdTemplate.panel.profiles"); $refInList; $subList; True:C214)
		SET LIST ITEM PROPERTIES:C386(Form:C1466.hl_permissions; $refInList; False:C215; Bold:K14:2)
		SET LIST ITEM PARAMETER:C986(Form:C1466.hl_permissions; $refInList; Additional text:K28:7; String:C10($esProfiles.length))
		
	End if 
	
	$entries:=New collection:C1472()
	If (Form:C1466.current_item.moreData.allowedEntries#Null:C1517)
		$entries:=cs:C1710.sfw_definition.me.entries.query("ident in :1"; Form:C1466.current_item.moreData.allowedEntries || New collection:C1472).extract("ident"; "ident"; "label"; "label").orderBy("label")
	End if 
	If ($entries.length>0)
		$subList:=New list:C375
		For each ($entry; $entries)
			$refInList+=1
			APPEND TO LIST:C376($subList; $entry.label; $refInList)
			SET LIST ITEM PARAMETER:C986($subList; $refInList; "entryIdent"; $entry.ident)
		End for each 
		$refInList+=1
		APPEND TO LIST:C376(Form:C1466.hl_permissions; ds:C1482.sfw_readXliff("dfdTemplate.panel.entries"); $refInList; $subList; True:C214)
		SET LIST ITEM PROPERTIES:C386(Form:C1466.hl_permissions; $refInList; False:C215; Bold:K14:2)
		SET LIST ITEM PARAMETER:C986(Form:C1466.hl_permissions; $refInList; Additional text:K28:7; String:C10($entries.length))
	End if 
	
	
Function bAction_permissions()
	
	GET LIST ITEM:C378(Form:C1466.hl_permissions; *; $itemRef; $itemText)
	$profilIdent:=""
	$entryIdent:=""
	If ($itemRef#0)
		GET LIST ITEM PARAMETER:C985(Form:C1466.hl_permissions; $itemRef; "profilIdent"; $profilIdent)
		GET LIST ITEM PARAMETER:C985(Form:C1466.hl_permissions; $itemRef; "entryIdent"; $entryIdent)
	End if 
	$menus:=New collection:C1472()
	$menu:=Create menu:C408
	$menus.push($menu)
	
	If (Form:C1466.sfw.checkIsInModification())
		$subMenuProfiles:=Create menu:C408
		$menus.push($subMenuProfiles)
		$profiles:=ds:C1482.sfw_UserProfile.query("not(ident in :1) order by name"; Form:C1466.current_item.moreData.allowedProfiles || New collection:C1472)
		For each ($profil; $profiles)
			APPEND MENU ITEM:C411($subMenuProfiles; $profil.name; *)
			SET MENU ITEM PARAMETER:C1004($subMenuProfiles; -1; "Profil:"+$profil.ident)
		End for each 
		If ($profiles.length#0)
			APPEND MENU ITEM:C411($menu; ds:C1482.sfw_readXliff("dfdTemplate.panel.addpr"); $subMenuProfiles; *)
		Else 
			APPEND MENU ITEM:C411($menu; ds:C1482.sfw_readXliff("dfdTemplate.panel.addpr"); *)
			DISABLE MENU ITEM:C150($menu; -1)
		End if 
	Else 
		APPEND MENU ITEM:C411($menu; ds:C1482.sfw_readXliff("dfdTemplate.panel.addpr"); *)
		DISABLE MENU ITEM:C150($menu; -1)
	End if 
	
	If (Form:C1466.sfw.checkIsInModification())
		$subMenuEntries:=Create menu:C408
		$menus.push($subMenuEntries)
		$entries:=cs:C1710.sfw_definition.me.entries
		$colEntries:=New collection:C1472()
		For each ($entry; $entries)
			$e:=$colEntries.query("ident = :1"; $entry.ident)
			If ($e.length=0)
				$colEntries.push({ident: $entry.ident; label: $entry.label})
			End if 
		End for each 
		$colEntries:=$colEntries.orderBy("label")
		
		For each ($entry; $colEntries)
			APPEND MENU ITEM:C411($subMenuEntries; $entry.label; *)
			SET MENU ITEM PARAMETER:C1004($subMenuEntries; -1; "Entry:"+$entry.ident)
		End for each 
		If ($colEntries.length#0)
			APPEND MENU ITEM:C411($menu; ds:C1482.sfw_readXliff("dfdTemplate.panel.adde"); $subMenuEntries; *)
		Else 
			APPEND MENU ITEM:C411($menu; ds:C1482.sfw_readXliff("dfdTemplate.panel.adde"); *)
			DISABLE MENU ITEM:C150($menu; -1)
		End if 
	Else 
		APPEND MENU ITEM:C411($menu; ds:C1482.sfw_readXliff("dfdTemplate.panel.adde"); *)
		DISABLE MENU ITEM:C150($menu; -1)
	End if 
	
	APPEND MENU ITEM:C411($menu; "-")
	APPEND MENU ITEM:C411($menu; ds:C1482.sfw_readXliff("dfdTemplate.panel.delete"); *)
	SET MENU ITEM PARAMETER:C1004($menu; -1; "Delete")
	If (Form:C1466.sfw.checkIsInModification()) && (($profilIdent#"") || ($entryIdent#""))
	Else 
		DISABLE MENU ITEM:C150($menu; -1)
	End if 
	
	$choose:=Dynamic pop up menu:C1006($menu)
	For each ($menu; $menus)
		RELEASE MENU:C978($menu)
	End for each 
	
	Case of 
		: ($choose)="Profil:@"
			$profilIdent:=Split string:C1554($choose; ":").pop()
			If (Form:C1466.current_item.moreData.allowedProfiles=Null:C1517)
				Form:C1466.current_item.moreData.allowedProfiles:=New collection:C1472()
			End if 
			Form:C1466.current_item.moreData.allowedProfiles.push($profilIdent)
			Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
			This:C1470.buildHLPermissions()
			
		: ($choose)="Entry:@"
			$entryIdent:=Split string:C1554($choose; ":").pop()
			
			If (Form:C1466.current_item.moreData.allowedEntries=Null:C1517)
				Form:C1466.current_item.moreData.allowedEntries:=New collection:C1472()
			End if 
			
			Form:C1466.current_item.moreData.allowedEntries.push($entryIdent)
			Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
			This:C1470.buildHLPermissions()
			
			
		: ($choose="Delete") && ($profilIdent#"")
			
			$index:=Form:C1466.current_item.moreData.allowedProfiles.indexOf($profilIdent)
			If ($index>=0)
				Form:C1466.current_item.moreData.allowedProfiles.remove($index)
			End if 
			Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
			This:C1470.buildHLPermissions()
			
		: ($choose="Delete") && ($entryIdent#"")
			
			$index:=Form:C1466.current_item.moreData.allowedEntries.indexOf($entryIdent)
			If ($index>=0)
				Form:C1466.current_item.moreData.allowedEntries.remove($index)
			End if 
			Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
			This:C1470.buildHLPermissions()
			
	End case 
	
Function hl_permissions
	
	Case of 
		: (FORM Event:C1606.code=On Clicked:K2:4) && ((Right click:C712) || (Contextual click:C713))
			This:C1470.bAction_permissions()
			
	End case 
	
	