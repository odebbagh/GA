property postponedFormulas : Collection

singleton Class constructor
	//It's a singleton class
	
Function formMethod()
	var $nil : Pointer
	
	Case of 
		: (FORM Event:C1606.code=On Resize:K2:27)
			Form:C1466.resizingAsked:=1
			SET TIMER:C645(30)
			
		: (FORM Event:C1606.code=On Timer:K2:25) && (Num:C11(Form:C1466.resizingAsked)>0)
			This:C1470.resizeObjects()
			
		: (FORM Event:C1606.code=On Timer:K2:25) && (Form:C1466.postponedFormulas#Null:C1517) && (Form:C1466.postponedFormulas.length>0)
			$formula:=Form:C1466.postponedFormulas.shift()
			$formula.call()
			If (Form:C1466.postponedFormulas.length=0)
				SET TIMER:C645(0)
			End if 
			
		: (Num:C11(Form:C1466.resizingAsked)#0)
			
		Else 
			//This function manages the main logic for updating and refreshing the form
			Form:C1466.sfw.panelFormMethod()  //The main body of the form method and basic sfw functionalities 
			If (Form:C1466.sfw.updateOfPanelNeeded())  //The current item is changed or reloaded, so it's necessary ti refresh 
				
				Form:C1466.picts:=Null:C1517
				
			End if 
			If (Form:C1466.sfw.recalculationOfPanelPageNeeded())  //a page is displayed so it's time to load the sources of data to display
				
				Form:C1466.zoom:=Form:C1466.zoom || 100
				Form:C1466.portrait:=Form:C1466.portrait || 1
				Form:C1466.landscape:=Form:C1466.landscape || 0
				Form:C1466.rulers:=Form:C1466.rulers || 0
				Form:C1466.paper:=Form:C1466.paper || New object:C1471
				Form:C1466.paper.formats:=Form:C1466.paper.formats || ds:C1482.dfd_Line.getFormatPapers()
				Form:C1466.paper.format:=Form:C1466.paper.format || "A4"
				
				If (Form:C1466.picts=Null:C1517)
					$file:=File:C1566("/RESOURCES/dfd/json/Schema_item/_types.json")
					$json:=$file.getText()
					$definitions:=JSON Parse:C1218($json)
					Form:C1466.availableTypes:=$definitions.availableTypes
					
					Form:C1466.picts:=New object:C1471
					$i:=0
					$pictoSize:=32
					For each ($availableType; Form:C1466.availableTypes)
						$i:=$i+1
						$newName:="bTool_"+String:C10($i)
						If ($i=1)
							$format:=OBJECT Get format:C894(*; "bTool_1")
						Else 
							OBJECT DUPLICATE:C1111(*; "bTool_1"; $newName; $nil; ""; ($pictoSize+1)*($i-1); 0)
						End if 
						OBJECT SET FORMAT:C236(*; $newName; Replace string:C233($format; "text.png"; $availableType.picto+".png"))
						OBJECT SET HELP TIP:C1181(*; $newName; "Ajouter "+$availableType.labelMenu)
						$file:=File:C1566("/RESOURCES/dfd/json/picto/"+$availableType.picto+".png")
						READ PICTURE FILE:C678($file.platformPath; $pict)
						Form:C1466.picts[$availableType.type]:=$pict
					End for each 
				End if 
				
				Case of 
					: (FORM Get current page:C276(*)=1)
						// add load functions
						$uuid:=(Form:C1466.current_item#Null:C1517) ? Form:C1466.current_item.UUID : ""
						Form:C1466.templates:=ds:C1482.dfd_Template.query("hierarchy.lines[].UUID_entity = :1"; $uuid)
						Form:C1466.object:=Null:C1517
						
						This:C1470.redraw_settings()
						This:C1470.redraw_lb_objects(0)
						This:C1470.redraw_lb_variables()
						This:C1470.redraw_lb_rules()
						This:C1470.redraw_preview()
				End case 
			End if 
			If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())  //It's time to resize the object or set visible
				This:C1470.redrawAndSetVisible()
			End if 
			If (FORM Event:C1606.code=On Load:K2:1)
				This:C1470.resizeObjects()
				
				For each ($button; ["bMoveUp"; "bMoveLeft"; "bMoveRight"; "bMoveDown"; "bReduceHeight"; "bReduceWidth"; "bGrowWidth"; "bGrowHeight"; "bMoveUp10"; "bMoveLeft10"; "bMoveRight10"; "bMoveDown10"; "bReduceHeight10"; "bReduceWidth10"; "bGrowWidth10"; "bGrowHeight10"])
					OBJECT GET COORDINATES:C663(*; $button; $g; $h; $d; $b)
					OBJECT SET COORDINATES:C1248(*; $button; $g+10000; $h+10000; $d+10000; $b+10000)
				End for each 
				
			End if 
	End case 
	
Function redrawAndSetVisible()
	//Adjusts the layout and visibility of form elements based on the current page and modification state
	
	
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
			
			For each ($objectName; ["pictoDocument"; "pictoTemplate"; "pictoObject"; "pictoVariable"; "pictoRule"; "counterDocument"; "counterTemplate"; "counterObject"; "counterVariable"; "counterRule"])
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
	
Function redraw_settings()
	
	$toSave:=False:C215
	If (Form:C1466.current_item#Null:C1517)
		If (Form:C1466.current_item.moreData=Null:C1517)
			Form:C1466.current_item.moreData:=New object:C1471
		End if 
		If (Form:C1466.current_item.moreData.settings=Null:C1517)
			Form:C1466.current_item.moreData.settings:=New object:C1471
			$toSave:=True:C214
		End if 
		
		If (Form:C1466.current_item.moreData.settings.format=Null:C1517)
			Form:C1466.current_item.moreData.settings.format:="A4"
			$toSave:=True:C214
		End if 
		If (Form:C1466.current_item.moreData.settings.orientation=Null:C1517)
			Form:C1466.current_item.moreData.settings.orientation:="portrait"
			$toSave:=True:C214
		End if 
		
	End if 
	
	If (Form:C1466.current_item#Null:C1517) && (Form:C1466.current_item.moreData.settings.orientation#Null:C1517)
		Form:C1466.landscape:=Num:C11(Form:C1466.current_item.moreData.settings.orientation="landscape")
		Form:C1466.portrait:=Num:C11(Form:C1466.current_item.moreData.settings.orientation="portrait")
		
		Form:C1466.paper.format:=Form:C1466.current_item.moreData.settings.format
		OBJECT SET TITLE:C194(*; "bFormat"; Form:C1466.paper.format)
	End if 
	
	If ($toSave)
		Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
	End if 
	
	
Function redraw_lb_objects($option : Integer)
	var $pict : Picture
	var $object : Object
	
	Form:C1466.lb_properties:=New collection:C1472
	If (Form:C1466.current_item#Null:C1517)
		If (Form:C1466.current_item.objectsForm=Null:C1517)
			Form:C1466.current_item.objectsForm:=New object:C1471
		End if 
		If (Form:C1466.current_item.objectsForm.objects=Null:C1517)
			Form:C1466.current_item.objectsForm.objects:=New collection:C1472
		End if 
		Form:C1466.lb_objects:=Form:C1466.current_item.objectsForm.objects.orderBy("order").copy()
		For each ($object; Form:C1466.lb_objects)
			$pict:=Form:C1466.picts[$object.properties.type]
			If (String:C10($object.properties._origineType)#String:C10($object.properties.type)) && (String:C10($object.properties._origineType)#"")
				If (Form:C1466.picts[$object.properties._origineType]#Null:C1517)
					$pict:=Form:C1466.picts[$object.properties._origineType]
				End if 
			End if 
			$object.pict:=$pict
		End for each 
	Else 
		Form:C1466.lb_objects:=Null:C1517
	End if 
	
	This:C1470.compute_ObjectsStats()
	
	
Function compute_ObjectsStats()
	var $lines : Collection
	var $type : Text
	var $types : Collection
	
	$lines:=New collection:C1472
	If (Form:C1466.lb_objects#Null:C1517)
		$types:=Form:C1466.lb_objects.extract("properties.type"; "type").distinct("type")
		For each ($type; $types)
			$lines.push($type+" : "+String:C10(Form:C1466.lb_objects.countValues($type; "properties.type")))
		End for each 
	End if 
	OBJECT SET HELP TIP:C1181(*; "bObjectsStats"; $lines.join("\r"))
	
	
Function redraw_lb_variables()
	var $item : Object
	var $tag : Object
	
	Form:C1466.lb_variables:=New collection:C1472()
	
	If (Form:C1466.current_item#Null:C1517)
		If (Form:C1466.current_item.variableItems.tags#Null:C1517)
			For each ($tag; Form:C1466.current_item.variableItems.tags)
				$item:=New object:C1471()
				$item.name:=$tag.tag
				$item.nb:=$tag.objects.length
				$item.objects:=$tag.objects
				Form:C1466.lb_variables.push($item)
			End for each 
			Form:C1466.lb_variables:=Form:C1466.lb_variables.orderBy("name")
		End if 
	End if 
	
	
Function redraw_lb_rules()
	
	If (Form:C1466.current_item#Null:C1517)
		If (Form:C1466.current_item.calculs.rules=Null:C1517)
			Form:C1466.current_item.calculs.rules:=New collection:C1472
		End if 
		Form:C1466.lb_rules:=Form:C1466.current_item.calculs.rules
	End if 
	
	
Function redraw_preview($destination : Text)
	var $objects : Collection
	var $rules : Collection
	var $file : 4D:C1709.File
	var $formDefinition : Object
	var $properties : Object
	var $propertiesBarcode : Object
	var $cm : Real
	var $coef : Real  //le coefficient de zoom des objets lors de la preview
	var $coefPolice : Real  //le coefficient de zoom spécifique aux polices lors de la preview
	var $dim : Real
	var $dim1 : Real
	var $dim2 : Real
	var $height : Real
	var $i : Real
	var $margin_left : Real
	var $margin_top : Real
	var $paper_offset_left : Real
	var $paper_offset_top : Real
	var $rulersSize : Real
	var $json : Text
	var $name : Text
	var $nameBarCode : Text
	var $type : Text
	var $currentObject : Object
	var $indices : Collection
	var $object : Object
	var $scrollPosition : Integer
	var $width : Integer
	var $zoom : Integer  //le coefficient de zoom global de la preview
	
	$file:=File:C1566("/RESOURCES/dfd/json/form/container.json")
	$json:=$file.getText()
	$formDefinition:=JSON Parse:C1218($json)
	
	If (Form:C1466.lb_objects#Null:C1517)
		
		If (Count parameters:C259=0)
			$destination:="--subform"
		End if 
		
		//MARK:Define the various coefficients and constants
		Case of 
			: ($destination="--print")
				$zoom:=100
				$coef:=1
				$coefPolice:=1
				$margin_top:=10
				$margin_left:=15
				
			: ($destination="--subform")
				$zoom:=Form:C1466.zoom || 100
				$coef:=1.9*($zoom/100)
				$coefPolice:=1.9*($zoom/100)
				$rulersSize:=20
				$paper_offset_top:=20*($zoom/100)+($rulersSize*Num:C11(Form:C1466.rulers))
				$paper_offset_left:=20*($zoom/100)+($rulersSize*Num:C11(Form:C1466.rulers))
				$margin_top:=(20*($zoom/100))+$paper_offset_top
				$margin_left:=(20*($zoom/100))+$paper_offset_left
				
				OBJECT GET SCROLL POSITION:C1114(*; "preview"; $scrollPosition)
				Form:C1466.scrollPosition:=$scrollPosition
				
		End case 
		
		$objects:=Form:C1466.lb_objects.orderBy("order").copy()
		
		//MARK:calculate the dynamic properties
		This:C1470.calculate_dynProp($objects; $destination)
		
		//MARK:apply the rules
		$rules:=(Form:C1466.lb_rules#Null:C1517) ? Form:C1466.lb_rules.copy() : New collection:C1472()
		This:C1470.apply_rules($objects; $rules)
		
		
		//MARK:build the objects
		For each ($object; $objects)
			
			$name:=$object.name
			$properties:=$object.properties
			
			$properties.top:=$margin_top+($properties.top*($zoom/100)*$coef)
			$properties.left:=$margin_left+($properties.left*($zoom/100)*$coef)
			$properties.width:=$properties.width*($zoom/100)*$coef
			$properties.height:=$properties.height*($zoom/100)*$coef
			If ($properties.fontSize#Null:C1517)
				$properties.fontSize:=$properties.fontSize*($zoom/100)*$coefPolice
			End if 
			If ($properties.strokeWidth#Null:C1517)
				$properties.strokeWidth:=$properties.strokeWidth*($zoom/100)*$coef
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
				$propertiesBarcode.picture:="/RESOURCES/image/modeles/barcode.png"
				$formDefinition.pages[1].objects[$nameBarCode]:=$propertiesBarcode
			End if 
			
			$formDefinition.pages[1].objects[$name]:=$properties
			
		End for each 
		
		//MARK:finalize output
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
				
				Form:C1466.formDefinition:=OB Copy:C1225($formDefinition)
				If (Form:C1466.object#Null:C1517) && ($objects.length>0)
					$numSelectedObject:=0
					For each ($selectedObject; Form:C1466.objects)
						$numSelectedObject+=1
						$indices:=$objects.indices("name = :1"; $selectedObject.name)
						If ($indices.length>0)
							$currentObject:=$objects[$indices[0]]
						Else 
							$currentObject:=$objects[0]
						End if 
						$width:=$currentObject.properties.width
						
						$type:=$currentObject.properties.type
						$properties:=New object:C1471
						$properties.type:="oval"
						$properties.width:=8
						$properties.height:=8
						$properties.strokeWidth:=2
						$properties.stroke:="red"
						$properties.fill:="none"
						
						If ($type#"line") | (($type="line") & (String:C10($currentObject.properties.startPoint)#"bottomLeft"))
							$name:="cornerTopLeft"+String:C10($numSelectedObject)
							$properties.top:=-4+$currentObject.properties.top
							$properties.left:=-4+$currentObject.properties.left
							$formDefinition.pages[1].objects[$name]:=OB Copy:C1225($properties)
						End if 
						
						If ($type#"line") | (($type="line") & (String:C10($currentObject.properties.startPoint)="bottomLeft"))
							$name:="cornerTopRight"+String:C10($numSelectedObject)
							$properties.top:=-4+$currentObject.properties.top
							$properties.left:=-4+$currentObject.properties.left+$width
							$formDefinition.pages[1].objects[$name]:=OB Copy:C1225($properties)
						End if 
						
						If ($type#"line") | (($type="line") & (String:C10($currentObject.properties.startPoint)="bottomLeft"))
							$name:="cornerBottomLeft"+String:C10($numSelectedObject)
							$properties.top:=-4+$currentObject.properties.top+$currentObject.properties.height
							$properties.left:=-4+$currentObject.properties.left
							$formDefinition.pages[1].objects[$name]:=OB Copy:C1225($properties)
						End if 
						
						If ($type#"line") | (($type="line") & (String:C10($currentObject.properties.startPoint)#"bottomLeft"))
							$name:="cornerBottomRight"+String:C10($numSelectedObject)
							$properties.top:=-4+$currentObject.properties.top+$currentObject.properties.height
							$properties.left:=-4+$currentObject.properties.left+$width
							$formDefinition.pages[1].objects[$name]:=OB Copy:C1225($properties)
						End if 
					End for each 
				End if 
				
				
				//MARK:select the paper
				$indices:=Form:C1466.paper.formats.indices("name = :1"; Form:C1466.paper.format)
				If ($indices.length>0)
					$dim1:=Form:C1466.paper.formats[$indices[0]].width*($zoom/100)*$coef
					$dim2:=Form:C1466.paper.formats[$indices[0]].height*($zoom/100)*$coef
				Else 
					$dim1:=595*($zoom/100)*$coef
					$dim2:=842*($zoom/100)*$coef
				End if 
				
				If (Form:C1466.portrait=0)
					$dim:=$dim1
					$dim1:=$dim2
					$dim2:=$dim
				End if 
				
				$properties:=New object:C1471
				$properties.type:="rectangle"
				$properties.top:=$paper_offset_top
				$properties.left:=$paper_offset_left
				$properties.width:=$dim1
				$properties.height:=$dim2
				$properties.fill:="white"
				$properties.stroke:="white"
				$formDefinition.pages[0].objects.paper:=$properties
				
				//MARK:display the rulers
				If (Form:C1466.rulers=1)
					
					
					$properties:=New object:C1471
					$properties.type:="rectangle"
					$properties.top:=$margin_top
					$properties.left:=$margin_left
					$properties.width:=$dim1-$margin_left+$paper_offset_left-$margin_left+$paper_offset_left
					$properties.height:=$dim2-$margin_top+$paper_offset_top-$margin_top+$paper_offset_top
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
					$properties.width:=$dim1
					$properties.height:=($rulersSize-5)*($zoom/100)*$coef
					$properties.fill:="lightyellow"
					$properties.stroke:="black"
					$properties.strokeWidth:=0.1*($zoom/100)*$coef
					$formDefinition.pages[0].objects.rulerHorizontal:=$properties
					
					$cm:=28.33333333333
					For ($i; 1; Int:C8($dim1\($cm*($zoom/100)*$coef)))
						
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
					For ($i; 1; Int:C8($dim1*10\($cm*($zoom/100)*$coef)))
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
					$properties.height:=$dim2
					$properties.fill:="lightyellow"
					$properties.stroke:="black"
					$properties.strokeWidth:=0.1*($zoom/100)*$coef
					$formDefinition.pages[0].objects.rulerVertical:=$properties
					
					For ($i; 1; Int:C8($dim2\($cm*($zoom/100)*$coef)))
						
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
					For ($i; 1; Int:C8($dim2*10\($cm*($zoom/100)*$coef)))
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
					
				End if 
				
				
				
				
				$properties:=New object:C1471
				$properties.type:="button"
				$properties.top:=$paper_offset_top
				$properties.left:=$paper_offset_left
				$properties.width:=$dim1
				$properties.height:=$dim2
				$properties.style:="custom"
				$formDefinition.pages[1].objects.button:=$properties
				
				Form:C1466.preview:=New object:C1471
				$formDefinition.method:="dfd_line_manage_preview"
				
				OBJECT SET SUBFORM:C1138(*; "preview"; $formDefinition)
				This:C1470.postpone(Formula:C1597(cs:C1710.dfd_panel_line.me.scroll_preview()))  //postpone the scroll update
				
		End case 
	Else 
		
		OBJECT SET SUBFORM:C1138(*; "preview"; $formDefinition)
		
	End if 
	
	
Function calculate_dynProp($objects : Collection; $destination : Text)
	
	var $bestHeight : Integer
	var $bestWidth : Integer
	var $calculatorSignal : 4D:C1709.Signal
	var $delegate : Boolean
	var $maxHeight : Integer
	var $nbLines : Integer
	var $objDelegate : Object
	var $object : Object
	var $process : Integer
	var $properties : Object
	var $signaled : Boolean
	var $style : Integer
	var $text : Text
	var $file : 4D:C1709.File
	var $folder : 4D:C1709.Folder
	
	If (Current form name:C1298="") || (Not:C34(This:C1470.tool_object_isAvailable("text_calculator")))
		$delegate:=True:C214
		If (Storage:C1525.textCalculator=Null:C1517) || (Num:C11(Storage:C1525.textCalculator.window)=0)
			$signal:=New signal:C1641
			$process:=New process:C317("dfd_textCalculator_launch"; 0; "textCalculator"; $signal; *)
			$signal.wait(100)
			DELAY PROCESS:C323(Current process:C322; 10)
		Else 
			$process:=New process:C317("dfd_textCalculator_launch"; 0; "textCalculator"; *)
		End if 
	Else 
		$delegate:=False:C215
	End if 
	
	For each ($object; $objects)
		$properties:=$object.properties
		If ($properties.text#Null:C1517) && (Value type:C1509($properties.text)=Is text:K8:3)
			$properties.text:=Replace string:C233($properties.text; "\\r"; "\r"; *)  // to manage multi-lines text
		Else 
			$properties.text:=String:C10($properties.text)
		End if 
		
		If (String:C10($properties.width)="auto") | (String:C10($properties.height)="auto")
			If ($delegate)
				$objDelegate:=New shared object:C1526
				Use ($objDelegate)
					$objDelegate.width:=$properties.width
					$objDelegate.height:=$properties.height
					$objDelegate.text:=$properties.text
					$objDelegate.fontFamilly:=$properties.fontFamilly
					$objDelegate.fontSize:=$properties.fontSize
					$objDelegate.fontWeight:=$properties.fontWeight
					$objDelegate.fontStyle:=$properties.fontStyle
					$objDelegate.textDecoration:=$properties.textDecoration
				End use 
				$calculatorSignal:=New signal:C1641("textCalculator")
				Use ($calculatorSignal)
					$calculatorSignal.delegate:=$objDelegate
				End use 
				If (Num:C11(Storage:C1525.textCalculator.window)#0)
					CALL FORM:C1391(Num:C11(Storage:C1525.textCalculator.window); Formula:C1597(cs:C1710.dfd_panel_line.me.textCalculator_calc_bestSize($1)); $calculatorSignal)
					$signaled:=$calculatorSignal.wait(100)
					If ($signaled)
						$properties.width:=$calculatorSignal.delegate.width
						$properties.height:=$calculatorSignal.delegate.height
					End if 
				End if 
				
			Else 
				OBJECT SET TITLE:C194(*; "text_calculator"; String:C10($properties.text))
				OBJECT SET FONT:C164(*; "text_calculator"; String:C10($properties.fontFamilly))
				OBJECT SET FONT SIZE:C165(*; "text_calculator"; Num:C11($properties.fontSize))
				$style:=(String:C10($properties.fontWeight)="bold") ? 1 : 0
				$style:=$style+((String:C10($properties.fontStyle)="italic") ? 2 : 0)
				$style:=$style+((String:C10($properties.textDecoration)="underline") ? 4 : 0)
				OBJECT SET FONT STYLE:C166(*; "text_calculator"; $style)
				
				Case of 
					: (String:C10($properties.width)="auto") & (String:C10($properties.height)="auto")
						OBJECT GET BEST SIZE:C717(*; "text_calculator"; $bestWidth; $bestHeight; ($properties._maxWidth || MAXLONG:K35:2))
						$properties.width:=$bestWidth
						$properties.height:=$bestHeight
						
					: (String:C10($properties.width)="auto")
						OBJECT GET BEST SIZE:C717(*; "text_calculator"; $bestWidth; $bestHeight; ($properties._maxWidth || MAXLONG:K35:2))
						$properties.width:=$bestWidth
						
					: (String:C10($properties.height)="auto")
						OBJECT GET BEST SIZE:C717(*; "text_calculator"; $bestWidth; $bestHeight; $properties.width)
						$properties.height:=$bestHeight
				End case 
				
			End if 
		End if 
		
		
		If ($properties._maxWidth#Null:C1517) && ($properties.width>$properties._maxWidth)
			$properties.width:=$properties._maxWidth
		End if 
		
		If ($properties._maxHeight#Null:C1517)
			$maxHeight:=0
			Case of 
				: (Value type:C1509($properties._maxHeight)=Is real:K8:4)
					$maxHeight:=$properties._maxHeight
				: (Value type:C1509($properties._maxHeight)=Is text:K8:3) && ($properties._maxHeight=String:C10(Num:C11($properties._maxHeight)))
					$maxHeight:=Num:C11($properties._maxHeight)
				: (Value type:C1509($properties._maxHeight)=Is text:K8:3) && (($properties._maxHeight="@ lines") | ($properties._maxHeight="@ lignes"))
					$text:=Replace string:C233($properties._maxHeight; " lines"; "")
					$text:=Replace string:C233($text; " lignes"; "")
					$nbLines:=Num:C11($text)
					If ($nbLines>=1)
						If ($delegate)
							Use ($calculatorSignal.delegate)
								$calculatorSignal.delegate.text:="AA"+("\rAA"*($nbLines-1))
								$calculatorSignal.delegate.width:=100
							End use 
							If (Storage:C1525.textCalculator.window#0)
								CALL FORM:C1391(Storage:C1525.textCalculator.window; "textCalculator_calc_bestSize"; $calculatorSignal)
								$signaled:=$calculatorSignal.wait(100)
								If ($signaled)
									$maxHeight:=$calculatorSignal.delegate.height
								End if 
							End if 
						Else 
							OBJECT SET TITLE:C194(*; "text_calculator"; "AA"+("\rAA"*($nbLines-1)))
							OBJECT GET BEST SIZE:C717(*; "text_calculator"; $bestWidth; $bestHeight; MAXLONG:K35:2)
							$maxHeight:=$bestHeight-(1.9*Num:C11($destination="--subform"))
						End if 
					End if 
			End case 
			If ($maxHeight#0) && ($properties.height>$maxHeight)
				$properties.height:=$maxHeight
			End if 
		End if 
		
		
		Case of 
			: ($properties.picture#Null:C1517) && ($properties.picture="picture(@)")
				$pictureName:=Substring:C12($properties.picture; 9; Length:C16($properties.picture)-9)
				$pictures:=ds:C1482.dfd_Picture.query("name = :1"; $pictureName)
				If ($pictures.length=1)
					$properties.picture:=$pictures.first().picture
				End if 
			: ($properties.picture#Null:C1517) && (Value type:C1509($properties.picture)=Is text:K8:3)
				$folder:=Folder:C1567("/PACKAGE")
				If (Folder:C1567($folder.platformPath; fk platform path:K87:2).parent.name="Components")
					$componentFolder:=Folder:C1567($folder.platformPath; fk platform path:K87:2).parent
					$databaseFolder:=$componentFolder.parent
				Else 
					$databaseFolder:=Folder:C1567($folder.platformPath; fk platform path:K87:2)
				End if 
				$pathParts:=Split string:C1554($properties.picture; "/"; sk ignore empty strings:K86:1+sk trim spaces:K86:2)
				$path:=$databaseFolder.platformPath+$pathParts.join(Folder separator:K24:12)
				$file:=File:C1566($path; fk platform path:K87:2)
				READ PICTURE FILE:C678($file.platformPath; $pict)
				$properties.picture:=$pict
		End case 
		
	End for each 
	
	
Function tool_object_isAvailable($objectToFind : Text)->$result : Boolean
	
	ARRAY TEXT:C222($_objectName; 0)
	FORM GET OBJECTS:C898($_objectName)
	
	$result:=(Find in array:C230($_objectName; $objectToFind)>0)
	
Function apply_rules($objects : Collection; $rules : Collection)
	var $car : Text
	var $element : Text
	var $elements : Collection
	var $finalExpression : Text
	var $i : Integer
	var $indices : Collection
	var $lastAttribut : Text
	var $object : Object
	var $objectName : Text
	var $part : Text
	var $partNum : Integer
	var $rawExpression : Text
	var $rule : Object
	var $target : Text
	var $targetElements : Collection
	var $value : Integer
	var $ruleParts : Collection
	
	For each ($rule; $rules)
		$ruleParts:=Split string:C1554($rule.rule; ":=")
		$target:=$ruleParts.shift()
		$rawExpression:="("+$ruleParts.shift()+")"
		$partNum:=0
		$part:=""
		$finalExpression:=""
		For ($i; 1; Length:C16($rawExpression))
			$car:=$rawExpression[[$i]]
			Case of 
				: (Position:C15($car; "()[]+/*-")>0)
					If ($part#"")
						$elements:=Split string:C1554($part; ".")
						$objectName:=$elements.shift()
						$indices:=$objects.indices("name = :1"; $objectName)
						If ($indices.length>0)
							$object:=OB Copy:C1225($objects[$indices[0]].properties)
							$object.bottom:=Num:C11($object.top)+Num:C11($object.height)
							$object.right:=Num:C11($object.left)+Num:C11($object.width)
							$lastAttribut:=$elements.pop()
							For each ($element; $elements)
								$object:=$object[$element]
							End for each 
							$value:=Num:C11($object[$lastAttribut])
						Else 
							$value:=Num:C11($part)
						End if 
						$finalExpression:=$finalExpression+String:C10($value)
						$part:=""
					End if 
					$finalExpression:=$finalExpression+$car
				Else 
					$part:=$part+$car
			End case 
		End for 
		
		$targetElements:=Split string:C1554($target; ".")
		$objectName:=$targetElements.shift()
		$indices:=$objects.indices("name = :1"; $objectName)
		If ($indices.length>0)
			$object:=$objects[$indices[0]].properties
			$lastAttribut:=$targetElements.pop()
			For each ($element; $targetElements)
				$object:=$object[$element]
			End for each 
			Case of 
				: ($lastAttribut="bottom")
					$object.height:=Formula from string:C1601($finalExpression).call()-$object.top
				: ($lastAttribut="right")
					$object.width:=Formula from string:C1601($finalExpression).call()-$object.left
				Else 
					$object[$lastAttribut]:=Formula from string:C1601($finalExpression).call()
			End case 
		End if 
	End for each 
	
	
Function redraw_lb_properties()
	var $indices : Collection
	var $properties : Object
	var $property : Object
	var $property_name : Text
	
	Form:C1466.lb_properties:=New collection:C1472
	
	Case of 
		: (Form:C1466.object#Null:C1517) & (Form:C1466.objects.length=1)
			
			$properties:=Form:C1466.object.properties
			For each ($property_name; $properties)
				If ($property_name#"type")
					$property:=New object:C1471
					$property.name:=$property_name
					$property.value:=String:C10($properties[$property_name])
					$property.meta:=New object:C1471
					Form:C1466.lb_properties.push($property)
				End if 
			End for each 
			
			If (String:C10(Form:C1466.object.properties.width)#"auto")
				$property:=New object:C1471
				$property.name:="right"
				$property.value:=Form:C1466.object.properties.left+Form:C1466.object.properties.width
				$property.meta:=New object:C1471("unselectable"; True:C214; "disabled"; True:C214)
				$indices:=Form:C1466.lb_properties.indices("name = :1"; "left")
				If ($indices.length>0)
					Form:C1466.lb_properties.insert($indices[0]+1; $property)
				End if 
			End if 
			
			If (String:C10(Form:C1466.object.properties.height)#"auto")
				$property:=New object:C1471
				$property.name:="bottom"
				$property.value:=Form:C1466.object.properties.top+Form:C1466.object.properties.height
				$property.meta:=New object:C1471("unselectable"; True:C214; "disabled"; True:C214)
				$indices:=Form:C1466.lb_properties.indices("name = :1"; "top")
				If ($indices.length>0)
					Form:C1466.lb_properties.insert($indices[0]+1; $property)
				End if 
			End if 
			
			
		: (Form:C1466.objects.length>1)
			
			For each ($selectedObject; Form:C1466.objects)
				$properties:=$selectedObject.properties
				For each ($property_name; $properties)
					If ($property_name#"type")
						$indices:=Form:C1466.lb_properties.indices("name = :1"; $property_name)
						If ($indices.length=0)
							$property:=New object:C1471
							$property.name:=$property_name
							$property.meta:=New object:C1471
							Form:C1466.lb_properties.push($property)
						End if 
					End if 
				End for each 
			End for each 
			
			$numSelectedObject:=0
			For each ($selectedObject; Form:C1466.objects)
				$numSelectedObject+=1
				$properties:=$selectedObject.properties
				For each ($property; Form:C1466.lb_properties)
					If ($properties[$property.name]=Null:C1517)
						$property.name:="****"
					Else 
						If ($property.value=Null:C1517)
							$property.value:=String:C10($properties[$property.name])
						Else 
							If ($property.value#String:C10($properties[$property.name]))
								$property.value:=""
							End if 
						End if 
					End if 
				End for each 
				
			End for each 
			Form:C1466.lb_properties:=Form:C1466.lb_properties.query("name # :1"; "****")
			
	End case 
	
	
	
Function scroll_preview()
	OBJECT SET SCROLL POSITION:C906(*; "preview"; Form:C1466.scrollPosition)
	
	
Function activate_SaveCancel()
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
	Form:C1466.current_item.objectsForm:=New object:C1471("objects"; New collection:C1472())
	Form:C1466.current_item.objectsForm.objects:=Form:C1466.lb_objects
	
	This:C1470.redraw_lb_objects()
	This:C1470.redraw_lb_rules()
	This:C1470.redraw_lb_variables()
	If (Form:C1466.position_object<0) | (Form:C1466.position_object>Form:C1466.lb_objects.length)
		Form:C1466.position_object:=0
	End if 
	If (Form:C1466.position_object=0)
		LISTBOX SELECT ROW:C912(*; "lb_objects"; 0; lk remove from selection:K53:3)
		Form:C1466.object:=Null:C1517
	Else 
		Form:C1466.object:=Form:C1466.lb_objects[Form:C1466.position_object-1]
		LISTBOX SELECT ROW:C912(*; "lb_objects"; Form:C1466.position_object; lk replace selection:K53:1)
	End if 
	This:C1470.redraw_lb_properties()
	
	//mark:-Object methods
	
Function lb_variables()
	Case of 
		: (Form:C1466.sfw.checkIsntInModification())
		: (FORM Event:C1606.code=On Clicked:K2:4) & (Right click:C712 | Contextual click:C713) & (Form:C1466.variable#Null:C1517)
			$menus:=New collection:C1472()
			$refMenu:=Create menu:C408()
			$menus.push($refMenu)
			
			If (Form:C1466.variable.objects.length>0)
				$refSubMenu:=Create menu:C408()
				$menus.push($refSubMenu)
				
				For each ($object; Form:C1466.variable.objects)
					APPEND MENU ITEM:C411($refSubMenu; $object)
					SET MENU ITEM PARAMETER:C1004($refSubMenu; -1; "--selectObject:"+$object)
				End for each 
				
				APPEND MENU ITEM:C411($refMenu; Localized string:C991("template_line.lb_variables.useby"); $refSubMenu)
			End if 
			
			$choose:=Dynamic pop up menu:C1006($refMenu)
			For each ($refMenu; $menus)
				RELEASE MENU:C978($refMenu)
			End for each 
			
			Case of 
				: ($choose="--selectObject:@")
					$name:=Split string:C1554($choose; ":").pop()
					$indices:=Form:C1466.lb_objects.indices("name = :1"; $name)
					If ($indices.length>0)
						Form:C1466.position_object:=$indices[0]+1
						Form:C1466.object:=Form:C1466.lb_objects[Form:C1466.position_object-1]
						LISTBOX SELECT ROW:C912(*; "lb_objects"; Form:C1466.position_object; lk replace selection:K53:1)
						This:C1470.redraw_lb_properties()
						This:C1470.redraw_preview()
					End if 
			End case 
			
	End case 
	
	
Function lb_rules()
	Case of 
		: (Form:C1466.sfw.checkIsntInModification())
			
		: (FORM Event:C1606.code=On Clicked:K2:4) & (Right click:C712 | Contextual click:C713) & (Form:C1466.current_item#Null:C1517)
			$menus:=New collection:C1472()
			$refMenu:=Create menu:C408()
			$menus.push($refMenu)
			
			APPEND MENU ITEM:C411($refMenu; Localized string:C991("template_line.lb_rules.add"); *)  //"Ajouter une règle"
			SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--addRule")
			
			APPEND MENU ITEM:C411($refMenu; Localized string:C991("template_line.lb_rules.edit"); *)  //"Modifier la règle"
			SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--editRule")
			If (Form:C1466.rule#Null:C1517)
				ENABLE MENU ITEM:C149($refMenu; -1)
			Else 
				DISABLE MENU ITEM:C150($refMenu; -1)
			End if 
			
			APPEND MENU ITEM:C411($refMenu; Localized string:C991("template_line.lb_rules.duplicate"); *)  //"Dupliquer la règle"
			SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--duplicate")
			If (Form:C1466.rule#Null:C1517)
				ENABLE MENU ITEM:C149($refMenu; -1)
			Else 
				DISABLE MENU ITEM:C150($refMenu; -1)
			End if 
			
			APPEND MENU ITEM:C411($refMenu; Localized string:C991("template_line.lb_rules.detete"); *)  // "Supprimer la règle"
			SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--deleteRule")
			If (Form:C1466.rule#Null:C1517)
				ENABLE MENU ITEM:C149($refMenu; -1)
			Else 
				DISABLE MENU ITEM:C150($refMenu; -1)
			End if 
			
			APPEND MENU ITEM:C411($refMenu; "-")
			
			$refSubMenu:=Create menu:C408()
			$menus.push($refSubMenu)
			$enable:=False:C215
			
			APPEND MENU ITEM:C411($refSubMenu; Localized string:C991("tool.menu.first"); *)  //"En premier"
			SET MENU ITEM PARAMETER:C1004($refSubMenu; -1; "--toFirst")
			If (Form:C1466.position_rule>1)
				ENABLE MENU ITEM:C149($refSubMenu; -1)
				$enable:=True:C214
			Else 
				DISABLE MENU ITEM:C150($refSubMenu; -1)
			End if 
			
			APPEND MENU ITEM:C411($refSubMenu; Localized string:C991("tool.menu.up"); *)  //"Monter"
			SET MENU ITEM PARAMETER:C1004($refSubMenu; -1; "--up")
			If (Form:C1466.position_rule>1)
				ENABLE MENU ITEM:C149($refSubMenu; -1)
				$enable:=True:C214
			Else 
				DISABLE MENU ITEM:C150($refSubMenu; -1)
			End if 
			
			APPEND MENU ITEM:C411($refSubMenu; Localized string:C991("tool.menu.down"); *)  //"Descendre"
			SET MENU ITEM PARAMETER:C1004($refSubMenu; -1; "--down")
			If (Form:C1466.position_rule>0) & (Form:C1466.position_rule<Form:C1466.lb_rules.length)
				ENABLE MENU ITEM:C149($refSubMenu; -1)
				$enable:=True:C214
			Else 
				DISABLE MENU ITEM:C150($refSubMenu; -1)
			End if 
			
			APPEND MENU ITEM:C411($refSubMenu; Localized string:C991("tool.menu.last"); *)  //"En dernier"
			SET MENU ITEM PARAMETER:C1004($refSubMenu; -1; "--toLast")
			If (Form:C1466.position_rule>0) & (Form:C1466.position_rule<Form:C1466.lb_rules.length)
				ENABLE MENU ITEM:C149($refSubMenu; -1)
				$enable:=True:C214
			Else 
				DISABLE MENU ITEM:C150($refSubMenu; -1)
			End if 
			
			If ($enable)
				APPEND MENU ITEM:C411($refMenu; Localized string:C991("tool.menu.organize"); $refSubMenu; *)  //"Organiser"
			Else 
				APPEND MENU ITEM:C411($refMenu; Localized string:C991("tool.menu.organize"); *)  //"Organiser"
				DISABLE MENU ITEM:C150($refMenu; -1)
			End if 
			
			
			$choose:=Dynamic pop up menu:C1006($refMenu)
			For each ($refMenu; $menus)
				RELEASE MENU:C978($refMenu)
			End for each 
			
			Case of 
				: ($choose="--addRule")
					$answer:=cs:C1710.sfw_dialog.me.request(Localized string:C991("template_line.lb_rules.add.prompt"); ""; ds:C1482.sfw_readXliff("dfdLine.panel.addrule"); ds:C1482.sfw_readXliff("dfdLine.panel.cancel"); "trimSpace")
					If ($answer.ok) & ($answer.answer#"")
						$rule:=New object:C1471
						$rule.rule:=$answer.answer
						Form:C1466.lb_rules.push($rule)
						Form:C1466.current_item.calculs.rules:=Form:C1466.lb_rules
					End if 
					This:C1470.activate_SaveCancel()
					This:C1470.redraw_preview()
					
				: ($choose="--editRule")
					$answer:=cs:C1710.sfw_dialog.me.request(Localized string:C991("template_line.lb_rules.edit.prompt"); Form:C1466.rule.rule; ds:C1482.sfw_readXliff("dfdLine.panel.modifyrule"); ds:C1482.sfw_readXliff("dfdLine.panel.cancel"); "trimSpace")
					If ($answer.ok) & ($answer.answer#"")
						Form:C1466.rule.rule:=$answer.answer
						Form:C1466.current_item.calculs.rules:=Form:C1466.lb_rules
					End if 
					This:C1470.activate_SaveCancel()
					This:C1470.redraw_preview()
					
				: ($choose="--duplicate")
					$rule:=OB Copy:C1225(Form:C1466.rule)
					Form:C1466.lb_rules.push($rule)
					Form:C1466.current_item.calculs.rules:=Form:C1466.lb_rules
					$answer:=cs:C1710.sfw_dialog.me.request(ds:C1482.sfw_readXliff("dfdLine.panel.modifyduplicate"); $rule.rule; ds:C1482.sfw_readXliff("dfdLine.panel.modifyrule"); ds:C1482.sfw_readXliff("dfdLine.panel.cancel"); "trimSpace")
					If ($answer.ok) & ($answer.answer#"")
						$rule.rule:=$answer.answer
					End if 
					
					This:C1470.activate_SaveCancel()
					This:C1470.redraw_preview()
					
				: ($choose="--deleteRule")
					Form:C1466.lb_rules.remove(Form:C1466.position_rule-1)
					Form:C1466.current_item.calculs.rules:=Form:C1466.lb_rules
					This:C1470.activate_SaveCancel()
					This:C1470.redraw_preview()
					
				: ($choose="--toFirst")
					$rule:=Form:C1466.lb_rules[Form:C1466.position_rule-1]
					Form:C1466.lb_rules.remove(Form:C1466.position_rule-1)
					Form:C1466.lb_rules.unshift($rule)
					Form:C1466.current_item.calculs.rules:=Form:C1466.lb_rules
					This:C1470.activate_SaveCancel()
					This:C1470.redraw_preview()
					
				: ($choose="--toLast")
					$rule:=Form:C1466.lb_rules[Form:C1466.position_rule-1]
					Form:C1466.lb_rules.remove(Form:C1466.position_rule-1)
					Form:C1466.lb_rules.push($rule)
					Form:C1466.current_item.calculs.rules:=Form:C1466.lb_rules
					This:C1470.activate_SaveCancel()
					This:C1470.redraw_preview()
					
				: ($choose="--up")
					$rule1:=Form:C1466.lb_rules[Form:C1466.position_rule-1]
					$rule2:=Form:C1466.lb_rules[Form:C1466.position_rule-2]
					Form:C1466.lb_rules[Form:C1466.position_rule-2]:=$rule1
					Form:C1466.lb_rules[Form:C1466.position_rule-1]:=$rule2
					Form:C1466.current_item.calculs.rules:=Form:C1466.lb_rules
					This:C1470.activate_SaveCancel()
					This:C1470.redraw_preview()
					
				: ($choose="--down")
					$rule1:=Form:C1466.lb_rules[Form:C1466.position_rule-1]
					$rule2:=Form:C1466.lb_rules[Form:C1466.position_rule]
					Form:C1466.lb_rules[Form:C1466.position_rule]:=$rule1
					Form:C1466.lb_rules[Form:C1466.position_rule-1]:=$rule2
					Form:C1466.current_item.calculs.rules:=Form:C1466.lb_rules
					This:C1470.activate_SaveCancel()
					This:C1470.redraw_preview()
			End case 
			
		: (FORM Event:C1606.code=On Begin Drag Over:K2:44)
			<>DFD_dragdrop:=New object:C1471()
			<>DFD_dragdrop.rule:=Form:C1466.object
			<>DFD_dragdrop.origin:="lb_rules"
			
			$file:=File:C1566("/RESOURCES/dfd/image/icon/line-plus.png")
			READ PICTURE FILE:C678($file.platformPath; $pict)
			SET DRAG ICON:C1272($pict)
			
		: (FORM Event:C1606.code=On Drop:K2:12)
			
			If (<>DFD_dragdrop.origin#Null:C1517) && (<>DFD_dragdrop.origin="lb_rules")
				
				$line:=Drop position:C608
				If ($line<0)
					$line:=1
				End if 
				$rule:=Form:C1466.rule
				
				Form:C1466.lb_rules.remove(Form:C1466.position_rule-1)
				Form:C1466.lb_rules:=Form:C1466.lb_rules.insert($line-1; $rule)
				Form:C1466.position_rule:=$line
				This:C1470.activate_SaveCancel()
				LISTBOX SELECT ROW:C912(*; "lb_rules"; $line; lk replace selection:K53:1)
				This:C1470.postpone(Formula:C1597(cs:C1710.dfd_panel_line.me.redraw_preview()))
				
			End if 
			
	End case 
	
	
Function lb_objects()
	
	Case of 
		: (Form:C1466.sfw.checkIsntInModification())
			
		: (FORM Event:C1606.code=On Clicked:K2:4) & (Right click:C712 | Contextual click:C713) & (Form:C1466.current_item#Null:C1517)
			
			This:C1470.contextualClic_object()
			
			
			
		: (FORM Event:C1606.code=On Drop:K2:12)
			
			If (<>DFD_dragdrop.origin#Null:C1517)
				Case of 
					: (<>DFD_dragdrop.origin="Resources_@")
						
						This:C1470.add_object("picture"; Drop position:C608; <>DFD_dragdrop.resource)
						This:C1470.activate_SaveCancel()
						
					: (<>DFD_dragdrop.origin="lb_objects@")
						
						$line:=Drop position:C608
						If ($line<0)
							$line:=Form:C1466.lb_objects.length
						End if 
						
						Form:C1466.object.order:=$line
						If ($line>Form:C1466.position_object)
							$objects:=Form:C1466.lb_objects.slice(Form:C1466.position_object; $line)
							$newOrder:=Form:C1466.position_object-1
							For each ($object; $objects)
								$newOrder+=1
								$object.order:=$newOrder
							End for each 
							
						Else 
							$objects:=Form:C1466.lb_objects.slice($line-1; Form:C1466.position_object-1)
							$newOrder:=$line
							For each ($object; $objects)
								$newOrder+=1
								$object.order:=$newOrder
							End for each 
						End if 
						
						
						This:C1470.activate_SaveCancel()
						Form:C1466.lb_objects:=Form:C1466.lb_objects.orderBy("order")
						
				End case 
			End if 
			
			
		: (FORM Event:C1606.code=On Begin Drag Over:K2:44)
			<>DFD_dragdrop:=New object:C1471()
			<>DFD_dragdrop.object:=Form:C1466.object
			<>DFD_dragdrop.origin:="lb_objects"
			
			$file:=File:C1566("/RESOURCES/dfd/image/icon/line-plus.png")
			READ PICTURE FILE:C678($file.platformPath; $pict)
			SET DRAG ICON:C1272($pict)
		Else 
			
	End case 
	
	// to begin a new cycle and refresh the list
	This:C1470.postpone(Formula:C1597(cs:C1710.dfd_panel_line.me.redraw_lb_properties()))
	This:C1470.postpone(Formula:C1597(cs:C1710.dfd_panel_line.me.redraw_preview()))
	
	
Function contextualClic_object()
	$menus:=New collection:C1472()
	$refMenu:=Create menu:C408()
	$menus.push($refMenu)
	
	APPEND MENU ITEM:C411($refMenu; Localized string:C991("template_line.lb_objects.duplicate"); *)  //"Dupliquer"
	If (Form:C1466.position_object>0)
		ENABLE MENU ITEM:C149($refMenu; -1)
	Else 
		DISABLE MENU ITEM:C150($refMenu; -1)
	End if 
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--duplicate")
	
	APPEND MENU ITEM:C411($refMenu; Localized string:C991("template_line.lb_objects.rename"); *)  //"Renommer..."
	If (Form:C1466.position_object>0)
		ENABLE MENU ITEM:C149($refMenu; -1)
	Else 
		DISABLE MENU ITEM:C150($refMenu; -1)
	End if 
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--rename")
	
	$refSubMenu:=Create menu:C408()
	$menus.push($refSubMenu)
	$enable:=False:C215
	APPEND MENU ITEM:C411($refSubMenu; Localized string:C991("template_line.lb_objects.toFront"); *)  //"Premier plan"
	If (Form:C1466.position_object>0) & (Form:C1466.position_object<Form:C1466.lb_objects.length)
		ENABLE MENU ITEM:C149($refSubMenu; -1)
		$enable:=True:C214
	Else 
		DISABLE MENU ITEM:C150($refSubMenu; -1)
	End if 
	SET MENU ITEM PARAMETER:C1004($refSubMenu; -1; "--toFront")
	
	APPEND MENU ITEM:C411($refSubMenu; Localized string:C991("template_line.lb_objects.up"); *)  //"Vers le haut"
	If (Form:C1466.position_object>0) & (Form:C1466.position_object<Form:C1466.lb_objects.length)
		ENABLE MENU ITEM:C149($refSubMenu; -1)
		$enable:=True:C214
	Else 
		DISABLE MENU ITEM:C150($refSubMenu; -1)
	End if 
	SET MENU ITEM PARAMETER:C1004($refSubMenu; -1; "--up")
	
	APPEND MENU ITEM:C411($refSubMenu; Localized string:C991("template_line.lb_objects.down"); *)  //"Vers le fond"
	If (Form:C1466.position_object>1)
		ENABLE MENU ITEM:C149($refSubMenu; -1)
		$enable:=True:C214
	Else 
		DISABLE MENU ITEM:C150($refSubMenu; -1)
	End if 
	SET MENU ITEM PARAMETER:C1004($refSubMenu; -1; "--down")
	
	APPEND MENU ITEM:C411($refSubMenu; Localized string:C991("template_line.lb_objects.toBack"); *)  //"Dernier plan"
	If (Form:C1466.position_object>1)
		ENABLE MENU ITEM:C149($refSubMenu; -1)
		$enable:=True:C214
	Else 
		DISABLE MENU ITEM:C150($refSubMenu; -1)
	End if 
	SET MENU ITEM PARAMETER:C1004($refSubMenu; -1; "--toBack")
	
	
	
	If ($enable)
		APPEND MENU ITEM:C411($refMenu; Localized string:C991("template_line.lb_objects.organize"); $refSubMenu; *)  //"Organiser"
	Else 
		APPEND MENU ITEM:C411($refMenu; Localized string:C991("template_line.lb_objects.organize"); *)  //"Organiser"
		DISABLE MENU ITEM:C150($refMenu; -1)
	End if 
	
	APPEND MENU ITEM:C411($refMenu; "-")
	APPEND MENU ITEM:C411($refMenu; Localized string:C991("template_line.lb_objects.editCoordinates"); *)  //"Modifier les coordonnées ..."
	If (Form:C1466.position_object>0)
		ENABLE MENU ITEM:C149($refMenu; -1)
	Else 
		DISABLE MENU ITEM:C150($refMenu; -1)
	End if 
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--changeCoordinates")
	
	APPEND MENU ITEM:C411($refMenu; "-")
	APPEND MENU ITEM:C411($refMenu; Localized string:C991("template_line.lb_objects.delete"); *)  //"Supprimer"
	If (Form:C1466.position_object>0)
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
		: ($choose="--duplicate")
			$objectName:=Form:C1466.object.name
			$indices:=Form:C1466.lb_objects.indices("name = :1"; $objectName)
			If ($indices.length>0)
				$objectDuplicate:=OB Copy:C1225(Form:C1466.lb_objects[$indices[0]])
				$names:=Form:C1466.lb_objects.distinct("name")
				$type_object:=$objectDuplicate.properties.type
				$i:=0
				Repeat 
					$i:=$i+1
					$name:=$type_object+"_"+String:C10($i)
				Until ($names.countValues($name)=0)
				$objectDuplicate.name:=$name
				$objectDuplicate.order:=Form:C1466.lb_objects.length+1
				Form:C1466.lb_objects.push($objectDuplicate)
				This:C1470.activate_SaveCancel()
				
				LISTBOX SELECT ROW:C912(*; "lb_objects"; Form:C1466.lb_objects.length; lk replace selection:K53:1)
				Form:C1466.position_object:=Form:C1466.lb_objects.length
				Form:C1466.object:=Form:C1466.lb_objects[Form:C1466.lb_objects.length-1]
			End if 
			
			
		: ($choose="--rename")
			$objectName:=Form:C1466.object.name
			$othersObjects:=Form:C1466.lb_objects.query("name # :1"; $objectName)
			$answer:=cs:C1710.sfw_dialog.me.request(ds:C1482.sfw_readXliff("dfdLine.panel.renameobject"); $objectName; ds:C1482.sfw_readXliff("dfdLine.panel.rename"); ds:C1482.sfw_readXliff("dfdLine.panel.cancel"); "trimSpace")
			If ($answer.ok) & ($answer.answer#"")
				If ($othersObjects.query("name = :1"; $answer.answer).length>0)
					cs:C1710.sfw_dialog.me.alert(ds:C1482.sfw_readXliff("dfdLine.panel.norenameobject"))
				Else 
					
					Form:C1466.object.name:=$answer.answer
					This:C1470.activate_SaveCancel()
					This:C1470.rename_objectInRules($objectName; $answer.answer)
				End if 
			End if 
			
		: ($choose="--toFront")
			Form:C1466.object.order:=MAXLONG:K35:2
			Form:C1466.lb_objects:=Form:C1466.lb_objects.orderBy("order")
			$order:=0
			For each ($object; Form:C1466.lb_objects)
				$order+=1
				$object.order:=$order
			End for each 
			LISTBOX SELECT ROW:C912(*; "lb_objects"; Form:C1466.lb_objects.length; lk replace selection:K53:1)
			Form:C1466.position_object:=Form:C1466.lb_objects.length
			Form:C1466.object:=Form:C1466.lb_objects[Form:C1466.position_object-1]
			This:C1470.activate_SaveCancel()
			
			
		: ($choose="--up")
			$currentPosition:=Form:C1466.position_object
			$object1:=Form:C1466.lb_objects[$currentPosition-1]
			$object2:=Form:C1466.lb_objects[$currentPosition]
			$order1:=$object1.order
			$order2:=$object2.order
			$object1.order:=$order2
			$object2.order:=$order1
			Form:C1466.lb_objects:=Form:C1466.lb_objects.orderBy("order")
			
			LISTBOX SELECT ROW:C912(*; "lb_objects"; $currentPosition+1; lk replace selection:K53:1)
			Form:C1466.position_object:=$currentPosition+1
			Form:C1466.object:=Form:C1466.lb_objects[Form:C1466.position_object-1]
			This:C1470.activate_SaveCancel()
			
			
		: ($choose="--toBack")
			Form:C1466.object.order:=-1
			Form:C1466.lb_objects:=Form:C1466.lb_objects.orderBy("order")
			$order:=0
			For each ($object; Form:C1466.lb_objects)
				$order+=1
				$object.order:=$order
			End for each 
			LISTBOX SELECT ROW:C912(*; "lb_objects"; Form:C1466.position_object; lk replace selection:K53:1)
			Form:C1466.position_object:=1
			Form:C1466.object:=Form:C1466.lb_objects[Form:C1466.position_object-1]
			Thios.activate_SaveCancel()
			
			
			
		: ($choose="--down")
			$currentPosition:=Form:C1466.position_object
			$object1:=Form:C1466.lb_objects[$currentPosition-1]
			$object2:=Form:C1466.lb_objects[$currentPosition-2]
			$order1:=$object1.order
			$order2:=$object2.order
			$object1.order:=$order2
			$object2.order:=$order1
			Form:C1466.lb_objects:=Form:C1466.lb_objects.orderBy("order")
			
			LISTBOX SELECT ROW:C912(*; "lb_objects"; $currentPosition-1; lk replace selection:K53:1)
			Form:C1466.position_object:=$currentPosition-1
			Form:C1466.object:=Form:C1466.lb_objects[Form:C1466.position_object-1]
			This:C1470.activate_SaveCancel()
			
		: ($choose="--delete")
			$objectName:=Form:C1466.object.name
			$indices:=Form:C1466.lb_objects.indices("name = :1"; $objectName)
			If ($indices.length>0)
				Form:C1466.lb_objects.remove($indices[0])
				
				Form:C1466.object:=Null:C1517
				This:C1470.change_objectData()
				
				If (Form:C1466.position_object<=Form:C1466.lb_objects.length) && (Form:C1466.position_object>0)
					LISTBOX SELECT ROW:C912(*; "lb_objects"; Form:C1466.position_object; lk replace selection:K53:1)
					Form:C1466.object:=Form:C1466.lb_objects[Form:C1466.position_object-1]
					Form:C1466.position_object-=1
				Else 
					LISTBOX SELECT ROW:C912(*; "lb_objects"; 0; lk remove from selection:K53:3)
					Form:C1466.object:=Null:C1517
					Form:C1466.position_object:=0
				End if 
				
			End if 
			
		: ($choose="--changeCoordinates")
			$currentObject:=OB Copy:C1225(Form:C1466.object.properties)
			$currentObject.topPx:=$currentObject.top
			$currentObject.leftPx:=$currentObject.left
			$currentObject.widthPx:=$currentObject.width
			$currentObject.heightPx:=$currentObject.height
			$currentObject.bottom:=$currentObject.topPx+$currentObject.heightPx
			$currentObject.right:=$currentObject.leftPx+$currentObject.widthPx
			$currentObject.bottomPx:=$currentObject.bottom
			$currentObject.rightPx:=$currentObject.right
			
			$refWindow:=Open form window:C675("dfd_coordinates_editor"; Sheet form window:K39:12)
			DIALOG:C40("dfd_coordinates_editor"; $currentObject)
			CLOSE WINDOW:C154($refWindow)
			If (ok=1)
				Form:C1466.object.properties.top:=$currentObject.topPx
				Form:C1466.object.properties.left:=$currentObject.leftPx
				Form:C1466.object.properties.height:=$currentObject.heightPx
				Form:C1466.object.properties.width:=$currentObject.widthPx
				This:C1470.redraw_lb_properties()
			End if 
	End case 
	
	
Function add_object($type_object : Text; $objectPosition : Integer; $resource : Object)
	var $file : 4D:C1709.File
	var $height : Integer
	var $i : Integer
	var $image : Picture
	var $item : Object
	var $json : Text
	var $name : Text
	var $names : Collection
	var $order : Integer
	var $path : Text
	var $pictureFile : 4D:C1709.File
	var $properties : Object
	var $requieredProperty : Text
	var $schema : Object
	var $valBoolAsText : Text
	var $values : Collection
	var $width : Integer
	
	If ($objectPosition<0)
		$objectPosition:=Form:C1466.lb_objects.length+1
	End if 
	
	
	$file:=File:C1566("/RESOURCES/dfd/json/Schema_item/"+$type_object+".json")
	$json:=$file.getText()
	$schema:=JSON Parse:C1218($json)
	
	$properties:=New object:C1471()
	$properties.type:=($schema.type#Null:C1517) ? Substring:C12($schema.type; Position:C15(";"; $schema.type)+1) : $type_object
	$properties._origineType:=$type_object
	For each ($requieredProperty; $schema._requiered)
		$values:=Split string:C1554($schema[$requieredProperty]; ";")
		Case of 
			: ($schema[$requieredProperty]="long@")
				If ($values.length=1)
					$properties[$requieredProperty]:=0
				Else 
					$properties[$requieredProperty]:=Num:C11($values[1])
				End if 
				
			: ($schema[$requieredProperty]="boolean@")
				
				If ($values.length=1)
					$properties[$requieredProperty]:=False:C215
				Else 
					$valBoolAsText:=$values[1]
					$properties[$requieredProperty]:=($valBoolAsText="true") | ($valBoolAsText="vrai")
				End if 
				
			Else 
				If ($values.length=1)
					$properties[$requieredProperty]:=""
				Else 
					$properties[$requieredProperty]:=String:C10($values[1])
				End if 
				
		End case 
	End for each 
	
	If ($resource#Null:C1517)
		If (OB Class:C1730($resource).name="dfd_PictureEntity")
			$path:="picture("+$resource.name+")"
			$properties.picture:=$path
			$pictures:=ds:C1482.DFD_Picture.query("name = :1"; $resource.name)
			If ($pictures.length>0)
				$image:=$pictures.first().picture
				PICTURE PROPERTIES:C457($image; $width; $height)
				$properties.width:=$width
				$properties.height:=$height
			End if 
		Else 
			$path:="/RESOURCES/dfd/image/dynForm/"+$resource.name
			$pictureFile:=File:C1566($path)
			If ($pictureFile.exists)
				$properties.picture:=$path
				BLOB TO PICTURE:C682($pictureFile.getContent(); $image)
				PICTURE PROPERTIES:C457($image; $width; $height)
				$properties.width:=$width
				$properties.height:=$height
			End if 
		End if 
	End if 
	
	$names:=Form:C1466.lb_objects.distinct("name")
	$i:=0
	Repeat 
		$i:=$i+1
		$name:=$type_object+"_"+String:C10($i)
	Until ($names.countValues($name)=0)
	
	$item:=New object:C1471()
	$item.name:=$name
	
	$item.order:=$objectPosition
	$item.properties:=$properties
	$item.pict:=Form:C1466.picts[$type_object]
	Form:C1466.lb_objects.insert($objectPosition-1; $item)
	
	$order:=0
	For each ($item; Form:C1466.lb_objects)
		$order+=1
		$item.order:=$order
	End for each 
	
	LISTBOX SELECT ROW:C912(*; "lb_objects"; Form:C1466.lb_objects.length; lk replace selection:K53:1)
	Form:C1466.position_object:=Form:C1466.lb_objects.length
	Form:C1466.object:=Form:C1466.lb_objects[Form:C1466.position_object-1]
	
	This:C1470.compute_ObjectsStats()
	
Function rename_objectInRules($oldName; $newName : Text)
	var $rule : Object
	
	//update rules
	For each ($rule; Form:C1466.lb_rules)
		$rule.rule:=Replace string:C233($rule.rule; $oldName+"."; $newName+".")
	End for each 
	
Function change_objectData()
	var $file : 4D:C1709.File
	var $indices : Collection
	var $json : Text
	var $property : Object
	var $schema : Object
	var $type_object : Text
	var $type_property : Text
	var $value : Variant
	
	Form:C1466.current_item.objectsForm.objects:=Form:C1466.lb_objects
	
	For each ($current_object; Form:C1466.objects)
		//$current_object:=form.object
		If ($current_object#Null:C1517)
			$type_object:=$current_object.properties.type
			
			$file:=File:C1566("/RESOURCES/dfd/json/Schema_item/"+$type_object+".json")
			$json:=$file.getText()
			$schema:=JSON Parse:C1218($json)
			
			
			For each ($property; Form:C1466.lb_properties)
				$value:=$property.value
				If (String:C10($value)#"")
					$type_property:=String:C10($schema[$property.name])
					Case of 
						: ($type_property="long@")
							Case of 
								: (String:C10($property.value)="=@")
								: ($property.name="width") && (String:C10($property.value)="auto")
								: ($property.name="height") && (String:C10($property.value)="auto")
								: ($property.name="_maxHeight") && ((String:C10($property.value)="@ lines") | (String:C10($property.value)="@ lignes"))
								Else 
									$property.value:=Num:C11($property.value)
							End case 
						: ($type_property="boolean@")
							$property.value:=Bool:C1537($property.value)
						Else 
							
					End case 
					If ($schema[$property.name]#Null:C1517)
						$current_object.properties[$property.name]:=$property.value
					End if 
				End if 
			End for each 
			
			If (String:C10($current_object.properties.width)#"auto")
				$indices:=Form:C1466.lb_properties.indices("name = :1"; "right")
				If ($indices.length>0)
					Form:C1466.lb_properties[$indices[0]].value:=$current_object.properties.left+$current_object.properties.width
				End if 
			End if 
			If (String:C10($current_object.properties.height)#"auto")
				$indices:=Form:C1466.lb_properties.indices("name = :1"; "bottom")
				If ($indices.length>0)
					Form:C1466.lb_properties[$indices[0]].value:=$current_object.properties.top+$current_object.properties.height
				End if 
			End if 
		End if 
	End for each 
	
	This:C1470.activate_SaveCancel()
	
	This:C1470.extract_tags()
	This:C1470.redraw_preview()
	This:C1470.redraw_buttons()
	
Function extract_tags()
	var $indices : Collection
	var $object : Object
	var $pEnd : Integer
	var $pStart : Integer
	var $property : Text
	var $tag : Text
	var $value : Variant
	var $variableItem : Object
	
	If (Form:C1466.current_item#Null:C1517)
		
		Form:C1466.current_item.variableItems.tags:=New collection:C1472()
		
		For each ($object; Form:C1466.current_item.objectsForm.objects)
			
			For each ($property; $object.properties)
				
				$value:=$object.properties[$property]
				
				If (Value type:C1509($value)=Is text:K8:3)
					Case of 
						: ($property="dataSource")
							$indices:=Form:C1466.current_item.variableItems.tags.indices("tag = :1"; $value)
							If ($indices.length=0)
								$variableItem:=New object:C1471
								$variableItem.tag:=$value
								$variableItem.objects:=New collection:C1472
								Form:C1466.current_item.variableItems.tags.push($variableItem)
							Else 
								$variableItem:=Form:C1466.current_item.variableItems.tags[$indices[0]]
							End if 
							$variableItem.objects.push($object.name)
							
						: ($property="numberFormat")
							// don't extract
						: ($property="textFormat")
							// don't extract
						Else 
							
							Repeat 
								$pStart:=Position:C15("##"; $value; *)
								If ($pStart>0)
									$value:=Substring:C12($value; $pStart+2)
									$pEnd:=Position:C15("##"; $value; *)
									If ($pEnd>0)
										$tag:=Substring:C12($value; 1; $pEnd-1)
										$value:=Substring:C12($value; $pEnd+2)
										
										$indices:=Form:C1466.current_item.variableItems.tags.indices("tag = :1"; $tag)
										If ($indices.length=0)
											$variableItem:=New object:C1471
											$variableItem.tag:=$tag
											$variableItem.objects:=New collection:C1472
											Form:C1466.current_item.variableItems.tags.push($variableItem)
										Else 
											$variableItem:=Form:C1466.current_item.variableItems.tags[$indices[0]]
										End if 
										$variableItem.objects.push($object.name)
									Else 
										$pStart:=0
									End if 
								End if 
							Until ($pStart=0)
					End case 
				End if 
				
			End for each 
			
		End for each 
		
		This:C1470.redraw_lb_variables()
	End if 
	
Function redraw_buttons()
	//nothing to do
	
	
Function column_object_name()
	
	Case of 
		: (FORM Event:C1606.code=On Getting Focus:K2:7)
			OBJECT SET ENABLED:C1123(*; "bMove@"; False:C215)
			OBJECT SET ENABLED:C1123(*; "bReduce@"; False:C215)
			OBJECT SET ENABLED:C1123(*; "bGrow@"; False:C215)
			
		: (FORM Event:C1606.code=On Losing Focus:K2:8)
			OBJECT SET ENABLED:C1123(*; "bMove@"; True:C214)
			OBJECT SET ENABLED:C1123(*; "bReduce@"; True:C214)
			OBJECT SET ENABLED:C1123(*; "bGrow@"; True:C214)
			
			
		: (FORM Event:C1606.code=On Before Data Entry:K2:39)  // | (FORM Event.code=On Before Keystroke)
			Form:C1466.lastNameFormObject:=Form:C1466.object.name
			
		: (FORM Event:C1606.code=On Data Change:K2:15)
			
			If (Form:C1466.object#Null:C1517)
				$objectName:=Form:C1466.object.name
				$othersObjects:=Form:C1466.lb_objects.query("name = :1"; $objectName)
				If ($othersObjects.length>1)
					$0:=-1
					//$position:=Form.position_object
					//Form.lb_objects.remove($position-1)
					cs:C1710.sfw_dialog.me.alert(ds:C1482.sfw_readXliff("dfdLine.panel.norenameobject"))
					Form:C1466.object.name:=Form:C1466.lastNameFormObject
				Else 
					This:C1470.activate_SaveCancel()
					This:C1470.rename_objectInRules($objectName; $answer)
					// to begin a new cycle and refresh the list
					This:C1470.postpone(Formula:C1597(cs:C1710.dfd_panel_line.me.redraw_lb_properties()))
					This:C1470.postpone(Formula:C1597(cs:C1710.dfd_panel_line.me.redraw_preview()))
					$0:=0
				End if 
			End if 
	End case 
	
	
Function lb_properties()
	Case of 
		: (Form:C1466.sfw.checkIsntInModification())
			
		: (FORM Event:C1606.code=On Clicked:K2:4) & (Right click:C712 | Contextual click:C713) & (Form:C1466.object#Null:C1517)
			$type_object:=Form:C1466.object.properties.type
			
			$file:=File:C1566("/RESOURCES/dfd/json/Schema_item/"+$type_object+".json")
			$json:=$file.getText()
			$schema:=JSON Parse:C1218($json)
			
			
			$menus:=New collection:C1472()
			$refMenu:=Create menu:C408()
			$menus.push($refMenu)
			
			$refSubMenu:=Create menu:C408()
			$menus.push($refSubMenu)
			
			For each ($propertyName; $schema)
				Case of 
					: ($propertyName="_requiered")
					Else 
						$indices:=Form:C1466.lb_properties.indices("name = :1"; $propertyName)
						If ($indices.length=0)
							APPEND MENU ITEM:C411($refSubMenu; $propertyName)
							SET MENU ITEM PARAMETER:C1004($refSubMenu; -1; "++"+$propertyName)
						End if 
				End case 
			End for each 
			
			If (Form:C1466.property#Null:C1517)
				Case of 
					: (Form:C1466.property.name="text")
						APPEND MENU ITEM:C411($refMenu; "Editer")
						ENABLE MENU ITEM:C149($refMenu; -1)
						SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--edit")
					: (Form:C1466.property.name="width") | (Form:C1466.property.name="height")
						APPEND MENU ITEM:C411($refMenu; "auto")
						ENABLE MENU ITEM:C149($refMenu; -1)
						SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--setAuto")
						
				End case 
				
			End if 
			
			APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff("dfdLine.panel.addproperty"); $refSubMenu)
			APPEND MENU ITEM:C411($refMenu; "-")
			If (Form:C1466.property#Null:C1517)
				$index:=$schema._requiered.indexOf(String:C10(Form:C1466.property.name))
				If ($index=-1)
					APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff("dfdLine.panel.delete"); *)
					ENABLE MENU ITEM:C149($refMenu; -1)
					SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--delete")
				Else 
					APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff("dfdLine.panel.deletemandatory"); *)
					DISABLE MENU ITEM:C150($refMenu; -1)
				End if 
			Else 
				APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff("dfdLine.panel.delete"); *)
				DISABLE MENU ITEM:C150($refMenu; -1)
			End if 
			APPEND MENU ITEM:C411($refMenu; "-")
			APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff("dfdLine.panel.colorEditor"); *)
			If (Form:C1466.property#Null:C1517)
				ENABLE MENU ITEM:C149($refMenu; -1)
			Else 
				DISABLE MENU ITEM:C150($refMenu; -1)
			End if 
			SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--selectColor")
			
			$choose:=Dynamic pop up menu:C1006($refMenu)
			For each ($refMenu; $menus)
				RELEASE MENU:C978($refMenu)
			End for each 
			
			Case of 
				: ($choose="++@")
					//add a properties
					$propertyName:=Substring:C12($choose; 3)
					$properties:=Form:C1466.object.properties
					
					$values:=New collection:C1472()
					$values:=Split string:C1554(String:C10($schema[$propertyName]); ";")
					If ($values.length>0)
						$type:=$values.shift()
					End if 
					
					Case of 
						: ($schema[$propertyName]="long@")
							If ($values.length=0)
								$properties[$propertyName]:=0
							Else 
								$properties[$propertyName]:=Num:C11($values[0])
							End if 
							
						: ($schema[$propertyName]="boolean@")
							If ($values.length=0)
								$properties[$propertyName]:=False:C215
							Else 
								$valBool:=String:C10($values[0])
								$properties[$propertyName]:=($valBool="true") | ($valBool="vrai")
							End if 
							
						Else 
							If ($values.length=0)
								$properties[$propertyName]:=""
							Else 
								$properties[$propertyName]:=$values[0]
							End if 
					End case 
					
					This:C1470.activate_SaveCancel()
					This:C1470.redraw_lb_properties()
					This:C1470.redraw_preview()
					
				: ($choose="--delete")
					OB REMOVE:C1226(Form:C1466.object.properties; Form:C1466.property.name)
					This:C1470.redraw_lb_properties()
					This:C1470.change_objectData()
					
				: ($choose="--edit")
					$winRef:=Open form window:C675("dfd_text_editor"; Movable form dialog box:K39:8)
					$form:=New object:C1471("text"; Form:C1466.property.value)
					DIALOG:C40("dfd_text_editor"; $form)
					CLOSE WINDOW:C154($winRef)
					If (ok=1)
						Form:C1466.property.value:=$form.text
						Form:C1466.object.properties.text:=Form:C1466.property.value
						This:C1470.change_objectData()
					End if 
					
				: ($choose="--setAuto")
					Form:C1466.property.value:="auto"
					This:C1470.change_objectData()
					
				: ($choose="--selectColor")
					$color:=Select RGB color:C956
					If (ok=1)
						Form:C1466.property.value:="#"+Substring:C12(String:C10($color; "&x"); 5)
					End if 
					This:C1470.change_objectData()
					
			End case 
			
	End case 
	
	
Function column_property_value()
	Case of 
		: (FORM Event:C1606.code=On Before Data Entry:K2:39)
			
			If (Form:C1466.property#Null:C1517)
				$type_object:=Form:C1466.object.properties.type
				
				$file:=File:C1566("/RESOURCES/dfd/json/Schema_item/"+$type_object+".json")
				$json:=$file.getText()
				$schema:=JSON Parse:C1218($json)
				
				$values:=Split string:C1554(String:C10($schema[Form:C1466.property.name]); ";"; sk ignore empty strings:K86:1)
				If (Form:C1466.property.name="fontFamily") & ($values.length<=2)
					ARRAY TEXT:C222($fonts; 0)
					FONT LIST:C460($fonts; Favorite fonts:K80:2+System fonts:K80:1)
					
					ARRAY TO COLLECTION:C1563($values; $fonts)
					$values.unshift()
				End if 
				
				If ($values.length>2)  // the first value is the type and the second one is the default value
					$type:=$values.shift()
					$values:=$values.orderBy()
					
					$menus:=New collection:C1472()
					$refMenu:=Create menu:C408()
					$menus.push($refMenu)
					
					For each ($value; $values)
						APPEND MENU ITEM:C411($refMenu; $value)
						SET MENU ITEM PARAMETER:C1004($refMenu; -1; $value)
					End for each 
					APPEND MENU ITEM:C411($refMenu; "-")
					APPEND MENU ITEM:C411($refMenu; Localized string:C991("template_line.lb_objects.other"); *)  //"Autre..."
					SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--autre")
					
					$choose:=Dynamic pop up menu:C1006($refMenu)
					RELEASE MENU:C978($refMenu)
					
					Case of 
						: ($choose="--autre")
							
						: ($choose#"")
							Form:C1466.property.value:=$choose
							This:C1470.change_objectData()
					End case 
				End if 
				
				
			End if 
		: (FORM Event:C1606.code=On Getting Focus:K2:7)
			OBJECT SET ENABLED:C1123(*; "bMove@"; False:C215)
			OBJECT SET ENABLED:C1123(*; "bReduce@"; False:C215)
			OBJECT SET ENABLED:C1123(*; "bGrow@"; False:C215)
			
		: (FORM Event:C1606.code=On Losing Focus:K2:8)
			OBJECT SET ENABLED:C1123(*; "bMove@"; True:C214)
			OBJECT SET ENABLED:C1123(*; "bReduce@"; True:C214)
			OBJECT SET ENABLED:C1123(*; "bGrow@"; True:C214)
			
		: (FORM Event:C1606.code=On Data Change:K2:15)
			This:C1470.change_objectData()
			
	End case 
	
	
Function bTool()
	If (Form:C1466.current_item#Null:C1517) && (Form:C1466.sfw.checkIsInModification())
		
		
		$bToolName:=FORM Event:C1606.objectName
		$num:=Num:C11(Substring:C12($bToolName; 7))
		
		$availableType:=Form:C1466.availableTypes[$num-1]
		$type_object:=$availableType.type
		
		This:C1470.add_object($type_object; -1)
		This:C1470.activate_SaveCancel()
		This:C1470.redraw_lb_properties()
		This:C1470.redraw_preview()
		
	End if 
	
Function bTool_1()
	This:C1470.bTool()
	
Function bTool_2()
	This:C1470.bTool()
	
Function bTool_3()
	This:C1470.bTool()
	
Function bTool_4()
	This:C1470.bTool()
	
Function bTool_5()
	This:C1470.bTool()
	
Function bTool_6()
	This:C1470.bTool()
	
Function bTool_7()
	This:C1470.bTool()
	
Function bTool_8()
	This:C1470.bTool()
	
Function bTool_9()
	This:C1470.bTool()
	
Function bTool_10()
	This:C1470.bTool()
	
Function bTool_11()
	This:C1470.bTool()
	
Function bTool_12()
	This:C1470.bTool()
	
Function bTool_13()
	This:C1470.bTool()
	
Function bTool_14()
	This:C1470.bTool()
	
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
				This:C1470.redraw_settings()
				This:C1470.activate_SaveCancel()
			End if 
		End if 
		This:C1470.redraw_preview()
	End if 
	
Function bPortrait()
	If (Form:C1466.sfw.checkIsInModification())
		
		If (Form:C1466.current_item.moreData.settings.orientation#"portrait")
			Form:C1466.current_item.moreData.settings.orientation:="portrait"
			This:C1470.redraw_settings()
			This:C1470.activate_SaveCancel()
		End if 
		This:C1470.redraw_preview()
	End if 
	
Function bLandscape()
	If (Form:C1466.sfw.checkIsInModification())
		
		If (Form:C1466.current_item.moreData.settings.orientation#"landscape")
			Form:C1466.current_item.moreData.settings.orientation:="landscape"
			This:C1470.redraw_settings()
			This:C1470.activate_SaveCancel()
		End if 
		This:C1470.redraw_preview()
	End if 
	
Function postpone($formula : 4D:C1709.Function)
	Form:C1466.postponedFormulas:=Form:C1466.postponedFormulas || New collection:C1472
	Form:C1466.postponedFormulas.push($formula)
	SET TIMER:C645(-1)
	
Function preview()
	Case of 
		: (FORM Event:C1606.code=-100)
			$x:=Form:C1466.preview.dfd_current_x
			$y:=Form:C1466.preview.dfd_current_y
			This:C1470.select_objectByXY($x; $y)
	End case 
	
Function select_objectByXY($x : Integer; $y : Integer)
	var $names : Collection
	
	$contextual:=Contextual click:C713
	$shift:=Shift down:C543
	
	$names:=OB Keys:C1719(Form:C1466.formDefinition.pages[1].objects).reverse()
	$target:=""
	$coef:=1.9
	
	OBJECT GET SCROLL POSITION:C1114(*; "preview"; $scrollPositionV; $scrollPositionH)
	$x+=($scrollPositionH*100/Form:C1466.zoom)
	$y+=($scrollPositionV*100/Form:C1466.zoom)
	
	For ($tolerance; 0; 2; 1)
		For each ($name; $names)
			$properties:=Form:C1466.formDefinition.pages[1].objects[$name]
			If ($x>=($properties.left-$tolerance))\
				 && ($x<=($properties.left+($properties.width || 100)+$tolerance))\
				 && ($y>=($properties.top-$tolerance))\
				 && ($y<=($properties.top+($properties.height || 100)+$tolerance))
				$target:=$name
				break
			End if 
		End for each 
		If ($target#"")
			break
		End if 
	End for 
	
	Form:C1466.objectNames:=Form:C1466.objectNames || New collection:C1472
	Form:C1466.objects:=New collection:C1472
	Case of 
		: ($target#"") & (Not:C34($shift))
			$indices:=Form:C1466.lb_objects.indices("name = :1"; $target)
			If ($indices.length>0)
				LISTBOX SELECT ROW:C912(*; "lb_objects"; $indices[0]+1; lk replace selection:K53:1)
				OBJECT SET SCROLL POSITION:C906(*; "lb_objects"; $indices[0]+1; *)
				Form:C1466.position_object:=$indices[0]+1
				Form:C1466.object:=Form:C1466.lb_objects[Form:C1466.position_object-1]
				Form:C1466.objectNames:=New collection:C1472($target)
			Else 
				LISTBOX SELECT ROW:C912(*; "lb_objects"; 0; lk remove from selection:K53:3)
				Form:C1466.position_object:=0
				Form:C1466.object:=Null:C1517
				Form:C1466.objectNames:=New collection:C1472
			End if 
			
			If ($contextual)
				This:C1470.postpone(Formula:C1597(cs:C1710.dfd_panel_line.me.contextualClic_object()))
			End if 
			This:C1470.postpone(Formula:C1597(cs:C1710.dfd_panel_line.me.redraw_lb_properties()))
			This:C1470.postpone(Formula:C1597(cs:C1710.dfd_panel_line.me.redraw_preview()))
			
		: ($target#"") & ($shift)
			$indices:=Form:C1466.objectNames.indices("name = :1"; $target)
			If ($indices.length>0)
				Form:C1466.objectNames.remove($indices[0])
			Else 
				Form:C1466.objectNames.push($target)
			End if 
			
			$objects:=Form:C1466.lb_objects.query("name in :1"; Form:C1466.objectNames)
			$indices:=Form:C1466.lb_objects.indices("name in :1"; Form:C1466.objectNames)
			If ($objects.length>0)
				LISTBOX SELECT ROWS:C1715(*; "lb_objects"; $objects; lk replace selection:K53:1)
				OBJECT SET SCROLL POSITION:C906(*; "lb_objects"; $indices[0]+1; *)
				Form:C1466.position_object:=$indices[0]+1
				Form:C1466.object:=Form:C1466.lb_objects[Form:C1466.position_object-1]
			Else 
				LISTBOX SELECT ROW:C912(*; "lb_objects"; 0; lk remove from selection:K53:3)
				Form:C1466.position_object:=0
				Form:C1466.object:=Null:C1517
			End if 
			
			If ($contextual)
				This:C1470.postpone(Formula:C1597(cs:C1710.dfd_panel_line.me.contextualClic_object()))
			End if 
			This:C1470.postpone(Formula:C1597(cs:C1710.dfd_panel_line.me.redraw_lb_properties()))
			This:C1470.postpone(Formula:C1597(cs:C1710.dfd_panel_line.me.redraw_preview()))
			
			
		Else 
			LISTBOX SELECT ROW:C912(*; "lb_objects"; 0; lk remove from selection:K53:3)
			Form:C1466.position_object:=0
			Form:C1466.object:=Null:C1517
			This:C1470.redraw_lb_properties()
			This:C1470.redraw_preview()
			
	End case 
	Form:C1466.objects:=Form:C1466.lb_objects.query("name in :1"; Form:C1466.objectNames)
	
	
Function textCalculator_calc_bestSize($signal : 4D:C1709.Signal)
	
	var $bestHeight : Integer
	var $bestWidth : Integer
	var $style : Integer
	
	OBJECT SET TITLE:C194(*; "text_calculator"; String:C10($signal.delegate.text))
	OBJECT SET FONT:C164(*; "text_calculator"; String:C10($signal.delegate.fontFamilly))
	OBJECT SET FONT SIZE:C165(*; "text_calculator"; Num:C11($signal.delegate.fontSize))
	$style:=(String:C10($signal.delegate.fontWeight)="bold") ? 1 : 0
	$style:=$style+((String:C10($signal.delegate.fontStyle)="italic") ? 2 : 0)
	$style:=$style+((String:C10($signal.delegate.textDecoration)="underline") ? 4 : 0)
	OBJECT SET FONT STYLE:C166(*; "text_calculator"; $style)
	
	Use ($signal.delegate)
		Case of 
			: (String:C10($signal.delegate.width)="auto") & (String:C10($signal.delegate.height)="auto")
				OBJECT GET BEST SIZE:C717(*; "text_calculator"; $bestWidth; $bestHeight; ($signal.delegate._maxWidth || MAXLONG:K35:2))
				$signal.delegate.width:=$bestWidth
				$signal.delegate.height:=$bestHeight
				
			: (String:C10($signal.delegate.width)="auto")
				OBJECT GET BEST SIZE:C717(*; "text_calculator"; $bestWidth; $bestHeight; ($signal.delegate._maxWidth || MAXLONG:K35:2))
				$signal.delegate.width:=$bestWidth
				
			: (String:C10($signal.delegate.height)="auto")
				OBJECT GET BEST SIZE:C717(*; "text_calculator"; $bestWidth; $bestHeight; $signal.delegate.width)
				$signal.delegate.height:=$bestHeight
		End case 
		
	End use 
	
	$signal.trigger()
	
	
	//mark:-Moves
	
Function move_currentObject($properties : Text; $move : Integer)
	
	var $indices : Collection
	
	If (Form:C1466.sfw.checkIsInModification()) && (Form:C1466.objects#Null:C1517)
		//$currentObject:=Form.object
		For each ($currentObject; Form:C1466.objects)
			$currentObject.properties[$properties]:=$currentObject.properties[$properties]+$move
			//$indices:=Form.lb_properties.indices("name = :1"; $properties)
			//If ($indices.length>0)
			//Form.lb_properties[$indices[0]].value:=$currentObject.properties[$properties]
			//Form.lb_properties:=Form.lb_properties
			//End if 
		End for each 
		This:C1470.activate_SaveCancel()
		This:C1470.redraw_lb_properties()
		This:C1470.postpone(Formula:C1597(cs:C1710.dfd_panel_line.me.redraw_preview()))
	End if 
	
	
Function bMoveUp()
	This:C1470.move_currentObject("top"; -1)
Function bMoveLeft()
	This:C1470.move_currentObject("left"; -1)
Function bMoveRight()
	This:C1470.move_currentObject("left"; 1)
Function bMoveDown()
	This:C1470.move_currentObject("top"; 1)
Function bReduceHeight()
	This:C1470.move_currentObject("height"; -1)
Function bReduceWidth()
	This:C1470.move_currentObject("width"; -1)
Function bGrowWidth()
	This:C1470.move_currentObject("width"; 1)
Function bGrowHeight()
	This:C1470.move_currentObject("height"; 1)
Function bMoveUp10()
	This:C1470.move_currentObject("top"; -10)
Function bMoveLeft10()
	This:C1470.move_currentObject("left"; 10)
Function bMoveRight10()
	This:C1470.move_currentObject("left"; -10)
Function bMoveDown10()
	This:C1470.move_currentObject("top"; 10)
Function bReduceHeight10()
	This:C1470.move_currentObject("height"; -10)
Function bReduceWidth10()
	This:C1470.move_currentObject("width"; -10)
Function bGrowWidth10()
	This:C1470.move_currentObject("width"; 10)
Function bGrowHeight10()
	This:C1470.move_currentObject("height"; 10)
	
	
	
	