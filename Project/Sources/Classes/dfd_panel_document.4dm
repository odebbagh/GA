

singleton Class constructor
	//It's a singleton class
	
Function formMethod()
	Case of 
		: (FORM Event:C1606.code=On Resize:K2:27)
			Form:C1466.resizingAsked:=1
			SET TIMER:C645(20)
			//cs.sfw_tracker.me.mark("OnResize")
			
		: (FORM Event:C1606.code=On Timer:K2:25) && (Num:C11(Form:C1466.resizingAsked)>0)
			//cs.sfw_tracker.me.mark("OnTimer:"+String(Form.resizingAsked))
			If (Num:C11(Form:C1466.resizingAsked)=1)
				Form:C1466.sfw.panelFormMethod()  //The main body of the form method and basic sfw functionalities 
			End if 
			This:C1470.resizeObjects()
			
		: (Num:C11(Form:C1466.resizingAsked)>0)
			
		Else 
			//This function manages the main logic for updating and refreshing the form
			Form:C1466.sfw.panelFormMethod()  //The main body of the form method and basic sfw functionalities 
			If (Form:C1466.sfw.updateOfPanelNeeded())  //The current item is changed or reloaded, so it's necessary ti refresh 
			End if 
			If (Form:C1466.sfw.recalculationOfPanelPageNeeded())  //a page is displayed so it's time to load the sources of data to display
				Case of 
					: (FORM Get current page:C276(*)=1)
						// add load functions
						
						Form:C1466.zoom:=Form:C1466.zoom || 100
						Form:C1466.portrait:=Form:C1466.portrait || 1
						Form:C1466.rulers:=Form:C1466.rulers || 0
						Form:C1466.landscape:=Form:C1466.landscape || 0
						Form:C1466.paper:=Form:C1466.paper || New object:C1471
						Form:C1466.paper.formats:=Form:C1466.paper.formats || ds:C1482.dfd_Line.getFormatPapers()
						Form:C1466.paper.format:=Form:C1466.paper.format || "A4"
						
						If (Form:C1466.typologies=Null:C1517)
							cs:C1710.dfd_panel_template.me.load_typologies()
						End if 
						This:C1470.redraw_all()
						
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
			
			For each ($objectName; ["pictoLine"; "pictoObject"; "pictoVariable"; "counterLine"; "counterObject"; "counterVariable"])
				OBJECT GET COORDINATES:C663(*; $objectName; $g; $h; $d; $b)
				OBJECT SET COORDINATES:C1248(*; $objectName; $g; $heightSubform-5-$b+$h; $d; $heightSubform-5)
			End for each 
			
			$offset:=5
			$gap:=2
			For each ($objectName; ["bLandscape"; "bPortrait"; "bFormat"; "bRuler"; "bPDF"; "bPrint"; "ruler"])
				If ($objectName="ruler")
					$offset+=10
				End if 
				OBJECT GET COORDINATES:C663(*; $objectName; $g; $h; $d; $b)
				OBJECT SET COORDINATES:C1248(*; $objectName; $widthSubForm-$offset-$d+$g; $h; $widthSubForm-$offset; $b)
				$offset+=$d-$g+$gap
			End for each 
			
			
			OBJECT GET COORDINATES:C663(*; "lb_variables"; $g; $h; $d; $b)
			Form:C1466.delta:=($widthSubForm-$d)/2
			SET TIMER:C645(1)
		: (Form:C1466.resizingAsked=2)
			Form:C1466.splitterV1:=Form:C1466.delta
			SET TIMER:C645(1)
		: (Form:C1466.resizingAsked=3)
			OBJECT GET COORDINATES:C663(*; "lb_variables"; $g; $h; $d; $b)
			OBJECT SET COORDINATES:C1248(*; "lb_variables"; $g; $h; $widthSubForm-5; $b)
			Form:C1466.resizingAsked:=-1
			SET TIMER:C645(0)
			
	End case 
	Form:C1466.resizingAsked+=1
	
	
Function redraw_all()
	This:C1470.redraw_lb_variables()
	This:C1470.redraw_lb_settings()
	This:C1470.redraw_preview()
	This:C1470.redraw_buttons()
	
Function redraw_lb_variables()
	var $line : Object
	var $template_line : cs:C1710.dfd_LineEntity
	var $tag : Object
	var $tagName : Text
	var $indices : Collection
	var $item : Object
	var $lineProperty : Object
	
	Form:C1466.lb_variables:=New collection:C1472()
	
	If (Form:C1466.current_item#Null:C1517)
		
		Form:C1466.template:=Form:C1466.current_item.template
		If (Form:C1466.template#Null:C1517)
			For each ($line; Form:C1466.template.hierarchy.lines)
				
				Case of 
					: ($line.kind="template_line")
						$template_line:=ds:C1482.dfd_Line.get($line.UUID_entity)
						If ($template_line.variableItems.tags#Null:C1517)
							For each ($tag; $template_line.variableItems.tags)
								Case of 
									: ($tag.tag="this.@")
									: ($tag.tag="cumul.@")
									Else 
										$indices:=Form:C1466.lb_variables.indices("name = :1"; $tag.tag)
										If ($indices.length=0)
											$item:=New object:C1471
											$item.name:=$tag.tag
											$item.lines:=New collection:C1472
											Form:C1466.lb_variables.push($item)
										Else 
											$item:=Form:C1466.lb_variables[$indices[0]]
										End if 
										$item.lines.push($template_line.name)
								End case 
							End for each 
						End if 
						If ($line.properties#Null:C1517)
							For each ($lineProperty; $line.properties)
								If ($lineProperty.kind="collectionSource")
									$indices:=Form:C1466.lb_variables.indices("name = :1"; $lineProperty.value)
									If ($indices.length=0)
										$item:=New object:C1471
										$item.name:=$lineProperty.value
										$item.lines:=New collection:C1472
										$item.kind:="collection"
										Form:C1466.lb_variables.push($item)
									Else 
										$item:=Form:C1466.lb_variables[$indices[0]]
									End if 
									$item.lines.push($template_line.name)
								End if 
							End for each 
						End if 
				End case 
			End for each 
		End if 
		Form:C1466.lb_variables:=Form:C1466.lb_variables.orderBy("name")
		
		If (Form:C1466.current_item.variableItems#Null:C1517)
			For each ($tagName; Form:C1466.current_item.variableItems)
				$indices:=Form:C1466.lb_variables.indices("name = :1"; $tagName)
				If ($indices.length>0)
					Form:C1466.lb_variables[$indices[0]].value:=Form:C1466.current_item.variableItems[$tagName]
				End if 
			End for each 
		End if 
		
		For each ($item; Form:C1466.lb_variables)
			$item.type:=This:C1470.tool_display_ValueType($item.value)
			
			Case of 
				: (String:C10($item.kind)="collection")
					If (Value type:C1509($item.value)=Is collection:K8:32)
						$item.value:=JSON Stringify:C1217($item.value)
					Else 
						$item.type:=This:C1470.tool_display_ValueType(JSON Parse:C1218($item.value || "[]"))  // if the collection is stored as a text (old docs)
					End if 
					
				Else 
					$item.value:=This:C1470.valuate_tag($item.name; Form:C1466.current_item.variableItems; "")
					$item.type:=This:C1470.tool_display_ValueType($item.value)
			End case 
			
		End for each 
	End if 
	
	
Function redraw_lb_settings()
	var $setting : Object
	var $settingName : Text
	
	Form:C1466.lb_settings:=New collection:C1472
	If (Form:C1466.current_item#Null:C1517)
		If (Form:C1466.current_item.moreData=Null:C1517)
			Form:C1466.current_item.moreData:=New object:C1471
		End if 
		If (Form:C1466.current_item.moreData.settings=Null:C1517)
			Form:C1466.current_item.moreData.settings:=New object:C1471
		End if 
		
		$setting:=New object:C1471
		$setting.name:=Localized string:C991("document.template")
		$setting.kind:="--template"
		$setting.notEditable:=True:C214
		$setting.meta:=New object:C1471
		If (Form:C1466.current_item.template#Null:C1517)
			$setting.value:=Form:C1466.current_item.template.name
			$setting.meta.stroke:="navy"
		Else 
			$setting.value:=Localized string:C991("document.tdb")
			$setting.meta.stroke:="grey"
		End if 
		Form:C1466.lb_settings.push($setting)
		
		If (Form:C1466.current_item#Null:C1517) && (Form:C1466.current_item.template#Null:C1517) && (Form:C1466.current_item.template.moreData#Null:C1517) && (Form:C1466.current_item.template.moreData.settings#Null:C1517)
			For each ($settingName; Form:C1466.current_item.template.moreData.settings)
				If (Form:C1466.current_item.moreData.settings[$settingName]=Null:C1517)
					Form:C1466.current_item.moreData.settings[$settingName]:=Form:C1466.current_item.template.moreData.settings[$settingName]
				End if 
				$setting:=New object:C1471
				$setting.name:=$settingName
				$setting.value:=Form:C1466.current_item.moreData.settings[$settingName]
				$setting.notEditable:=(Position:C15($settingName; "format;orientation")>0)
				
				Form:C1466.lb_settings.push($setting)
			End for each 
		End if 
		
	End if 
	If (Form:C1466.current_item#Null:C1517) && (Form:C1466.current_item.moreData.settings.orientation#Null:C1517)
		Form:C1466.landscape:=Num:C11(Form:C1466.current_item.moreData.settings.orientation="landscape")
		Form:C1466.portrait:=Num:C11(Form:C1466.current_item.moreData.settings.orientation="portrait")
		
		Form:C1466.paper.format:=Form:C1466.current_item.moreData.settings.format
		OBJECT SET TITLE:C194(*; "bFormat"; Form:C1466.paper.format)
		
	End if 
	If (Form:C1466.current_item#Null:C1517)
		Form:C1466.copies:=Num:C11(Form:C1466.current_item.moreData.settings.printNbCopies)=0 ? 1 : Num:C11(Form:C1466.current_item.moreData.settings.printNbCopies)
	End if 
	
	
Function redraw_preview($context : Object; $destination : Text; $page : Integer)
	var $blob : Blob
	var $addInPage : Boolean
	var $even : Boolean
	var $firstRepeatInPage : Boolean
	var $goodPage : Boolean
	var $stop : Boolean
	var $useline : Boolean
	var $bkgdsToDraw : Collection
	var $collSource : Collection
	var $footersToDraw : Collection
	var $lines : Collection
	var $linesToCalculate : Collection
	var $linesToDraw : Collection
	var $linesToInsert : Collection
	var $linesToUse : Collection
	var $objects : Collection
	var $rules : Collection
	var $tagParts : Collection
	var $cumuls : Object
	var $file : 4D:C1709.File
	var $formDefinition : Object
	var $formula : Object
	var $lastECR : Object
	var $lastERR : Object
	var $line : Object
	var $newLine : Object
	var $nextLine : Object
	var $properties : Object
	var $this : Variant
	var $picture : Picture
	var $cm : Real
	var $coef : Real
	var $coefPolice : Real
	var $dim : Real
	var $height : Real
	var $heightUsed : Real
	var $i : Real
	var $lastPage : Real
	var $lineNum : Real
	var $margin_bottomPx : Real
	var $margin_left : Real
	var $margin_leftPx : Real
	var $margin_rightPx : Real
	var $margin_top : Real
	var $margin_topPx : Real
	var $maxBottomPx : Real
	var $n : Real
	var $numInColl : Real
	var $order : Real
	var $p : Real
	var $pageHeightPx : Real
	var $pageInCalculation : Real
	var $pageToPrint : Real
	var $pageToPrintMax : Real
	var $pageToPrintMin : Real
	var $pageWidthPx : Real
	var $paper_offset_left : Real
	var $paper_offset_top : Real
	var $paperHeight : Real
	var $paperWidth : Real
	var $pEnd : Real
	var $previousRepeatStep : Real
	var $pStart : Real
	var $r : Real
	var $rulersSize : Real
	var $s : Real
	var $verticalOffsetPx : Real
	var $zoom : Real
	var $attribut : Text
	var $color : Text
	var $idp : Text
	var $json : Text
	var $lastAttribute : Text
	var $lastCollectionSource : Text
	var $lastECRCollection : Text
	var $lastERRCollection : Text
	var $lastTypology : Text
	var $name : Text
	var $property : Text
	var $tag : Text
	var $target : Text
	var $targetTag : Text
	var $text64 : Text
	var $textToDisplay : Text
	var $tooltip : Text
	var $value : Text
	var $cumulTag : Text
	var $indices : Collection
	var $object : Object
	var $objectName : Text
	var $objectsForm : Object
	var $ruptureLine : Object
	var $templateLine : Object
	var $valCumul : Real
	var $valueToDisplay : Variant
	var $continue : Boolean
	var $currentPrinter : Text
	var $currentCRLine : Object
	
	If (Count parameters:C259=0)
		$context:=Form:C1466
	End if 
	If (Count parameters:C259<2)
		$destination:="--subform"
	End if 
	If (Count parameters:C259<3)
		$page:=($context.ddPage.index#Null:C1517) ? $context.ddPage.index+1 : 1
	End if 
	
	If (Form:C1466.current_item#Null:C1517) && ($context.document=Null:C1517)
		$context.document:=Form:C1466.current_item
	End if 
	
	$continue:=True:C214
	
	//MARK:-print settings
	$context.document.moreData:=$context.document.moreData || New object:C1471
	$context.document.moreData.settings:=$context.document.moreData.settings || New object:C1471
	
	$pdfDocumentName:=String:C10($context.document.moreData.settings.pdfDocumentName)
	If ($pdfDocumentName#"")
		SET PRINT OPTION:C733(Spooler document name option:K47:10; $pdfDocumentName)
	End if 
	
	Case of 
		: ($destination="--pdf")
			If (String:C10($context.document.moreData.settings.pdfPath)="")  // Dialog to select 
				If ($pdfDocumentName#"")  // select a folder
					$folder:=Select folder:C670($pdfDocumentName; ""; Package open:K24:8)
					$continue:=(ok=1)
					If ($continue)
						$context.document.moreData.settings.pdfPath:=$folder+$pdfDocumentName
						$doc:=Create document:C266($context.document.moreData.settings.pdfPath)
						CLOSE DOCUMENT:C267($doc)
					End if 
					
				Else 
					$doc:=Create document:C266(""; ".pdf")
					$continue:=(ok=1)
					If ($continue)
						$context.document.moreData.settings.pdfPath:=document
						CLOSE DOCUMENT:C267($doc)
					End if 
				End if 
				
			End if 
			
			
			If ($continue)
				
				If (Not:C34(Is macOS:C1572))
					$currentPrinter:=Get current printer:C788
					SET CURRENT PRINTER:C787($context.document.moreData.settings.pdfPrinter)
					If (Get current printer:C788#Generic PDF driver:K47:15)
						SET PRINT OPTION:C733(Destination option:K47:7; 2; $context.document.moreData.settings.pdfPath)
					Else 
						SET PRINT OPTION:C733(Destination option:K47:7; 3; $context.document.moreData.settings.pdfPath)
					End if 
				Else 
					SET PRINT OPTION:C733(Destination option:K47:7; 3; $context.document.moreData.settings.pdfPath)
				End if 
				SET PRINTABLE MARGIN:C710(0; 0; 0; 0)  //Fixe la marge papier
				
				If (String:C10($context.document.moreData.settings.orientation)="landscape")
					SET PRINT OPTION:C733(Orientation option:K47:2; 2)  // landscape
				Else 
					SET PRINT OPTION:C733(Orientation option:K47:2; 1)  // portrait
				End if 
				
				<>DFD_pictures:=New object:C1471()
				
			End if 
			
		: ($destination="--print")
			SET PRINTABLE MARGIN:C710(0; 0; 0; 0)  //Fixe la marge papier
			
			If (String:C10($context.document.moreData.settings.orientation)="landscape")
				SET PRINT OPTION:C733(Orientation option:K47:2; 2)  // landscape
			Else 
				SET PRINT OPTION:C733(Orientation option:K47:2; 1)  // portrait
			End if 
			SET PRINT OPTION:C733(Number of copies option:K47:4; $context.document.moreData.settings.printNbCopies || 1)
			PRINT OPTION VALUES:C785(Paper option:K47:1; $_formatName; $_heightPaper)
			$format:=$context.document.moreData.settings.format  //+" Borderless"
			//$position:=Find in array($_formatName; $format)
			//If ($position=-1)
			//$format:=$context.document.moreData.settings.format
			//End if 
			SET PRINT OPTION:C733(Paper option:K47:1; $format)
			<>DFD_pictures:=New object:C1471()
			
			If (Position:C15(String:C10($context.document.moreData.settings.printPreview); "True;Vrai")>0)
				$context.document.moreData.settings.printPreview:=True:C214
			Else 
				$context.document.moreData.settings.printPreview:=False:C215
			End if 
			
			If (Position:C15(String:C10($context.document.moreData.settings.printSettings); "True;Vrai")>0)
				$context.document.moreData.settings.printSettings:=True:C214
			Else 
				$context.document.moreData.settings.printSettings:=False:C215
			End if 
			
			If ($context.document.moreData.settings.printPreview=False:C215) && ($context.document.moreData.settings.printSettings=True:C214)
				PRINT SETTINGS:C106
				$continue:=(ok=1)
			End if 
			
		: ($destination="--subform")
			If ($context.preview=Null:C1517)
				$context.preview:=New object:C1471()
			End if 
			$context.preview.pictures:=New object:C1471()
	End case 
	
	
	If ($continue)
		
		$file:=File:C1566("/RESOURCES/dfd/json/form/container.json")
		$json:=$file.getText()
		
		If ($context.document#Null:C1517)
			
			If ($context.document.variableItems=Null:C1517)
				$context.document.variableItems:=New object:C1471()
			End if 
			
			$context.picturesCounter:=0
			
			$context.currentDate:=Current date:C33
			$context.currentTime:=Current time:C178
			
			$context.nbObjects:=0
			$context.nbLines:=0
			
			If ($context.document.template#Null:C1517)
				
				//MARK:-apply preliminary method if exist
				
				$variableItems:=OB Copy:C1225($context.document.variableItems)
				If ($context.document.template#Null:C1517) && ($context.document.template.moreData#Null:C1517) && ($context.document.template.moreData.methodPrep#Null:C1517)
					$method:="<!--#4DCODE \r"
					$method+="$data:=$1 \r"
					$method+=$context.document.template.moreData.methodPrep
					$method+="\r-->"
					ds:C1482.startTransaction()
					PROCESS 4D TAGS:C816($method; $result; $variableItems)
					ds:C1482.cancelTransaction()
				End if 
				
				
				//MARK:-Define margins and coef
				$margin_topPx:=Num:C11($context.document.moreData.settings.margin_top || 10)
				$margin_bottomPx:=Num:C11($context.document.moreData.settings.margin_bottom || 10)
				$margin_leftPx:=Num:C11($context.document.moreData.settings.margin_left || 10)
				$margin_rightPx:=Num:C11($context.document.moreData.settings.margin_right || 10)
				Case of 
					: ($destination="--print")
						$zoom:=Num:C11($context.document.moreData.settings.printZoom || 100)
						$coef:=1
						$coefPolice:=1
						$margin_top:=$margin_topPx
						$margin_left:=$margin_leftPx
						$paper_offset_top:=0
						$paper_offset_left:=0
						
					: ($destination="--pdf")
						$zoom:=100
						$coef:=1
						$coefPolice:=1
						$margin_top:=$margin_topPx
						$margin_left:=$margin_leftPx
						$paper_offset_top:=0
						$paper_offset_left:=0
						
					: ($destination="--subform")
						$zoom:=$context.zoom || 100
						$coef:=1.9*($zoom/100)
						$coefPolice:=1.9*($zoom/100)
						$rulersSize:=20
						$paper_offset_top:=10*(Num:C11($context.zoom)/100)+($rulersSize*Num:C11($context.rulers)*(Num:C11($context.zoom)/100)*$coef)
						$paper_offset_left:=10*(Num:C11($context.zoom)/100)+($rulersSize*Num:C11($context.rulers)*(Num:C11($context.zoom)/100)*$coef)
						$margin_top:=$margin_topPx  //+$paper_offset_top
						$margin_left:=$margin_leftPx  //+$paper_offset_left
						
				End case 
				
				$lines:=$context.document.template.hierarchy.lines.copy()  //to avoid any modification in the original definition
				
				//MARK:-remove lines with orphan of template line
				$linesToUse:=New collection:C1472
				For each ($line; $lines)
					$templateLine:=ds:C1482.dfd_Line.get($line.UUID_entity)
					If ($templateLine#Null:C1517)
						$linesToUse.push($line)
					End if 
				End for each 
				$lines:=$linesToUse
				
				//MARK:-Group repeated lines on same source
				$lastTypology:=""
				$lastCollectionSource:=""
				$openRepeatSource:=""
				For each ($line; $lines)
					$line.objectsForm:=New object:C1471()  // prepare the future ....
					Case of 
						: ($line.typology="CR") & (($lastTypology="CR") | ($lastTypology="CRS"))
							$indices:=$line.properties.indices("kind = :1"; "collectionSource")
							If ($indices.length>0)
								$tag:=$line.properties[$indices[0]].value
								$line.collectionSource:=$tag
								If ($lastCollectionSource=$tag)
									$line.groupWithPrevious:=True:C214
								Else 
									$lastCollectionSource:=$tag
									$openRepeatSource:=$tag
								End if 
							Else 
								$lastCollectionSource:=""
								$openRepeatSource:=""
							End if 
							
						: ($line.typology="CR")
							$indices:=$line.properties.indices("kind = :1"; "collectionSource")
							If ($indices.length>0)
								$tag:=$line.properties[$indices[0]].value
								$line.collectionSource:=$tag
								$lastCollectionSource:=$tag
								$openRepeatSource:=$tag
							Else 
								$lastCollectionSource:=""
								$openRepeatSource:=""
							End if 
							
						: ($line.typology="CRS") & (($lastTypology="CR") | ($lastTypology="CRS") | ($lastTypology="RP"))
							$line.groupWithPrevious:=True:C214
							$indices:=$line.properties.indices("kind = :1"; "collectionSource")
							If ($indices.length>0)
								$tag:=$line.properties[$indices[0]].value
								$line.collectionSource:=$tag
								$lastCollectionSource:=$tag
							Else 
								$line.collectionSource:=$openRepeatSource
							End if 
							$indices:=$line.properties.indices("kind = :1"; "subcollectionSource")
							If ($indices.length>0)
								$line.subcollectionSource:=$line.properties[$indices[0]].value
							End if 
							
						: ($line.typology="CRS")
							$indices:=$line.properties.indices("kind = :1"; "collectionSource")
							If ($indices.length>0)
								$tag:=$line.properties[$indices[0]].value
								$line.collectionSource:=$tag
							Else 
								$line.collectionSource:=$openRepeatSource
							End if 
							If ($line.collectionSource=$openRepeatSource) && ($openRepeatSource#"")
								$line.groupWithPrevious:=True:C214
								$lastCollectionSource:=$openRepeatSource
							End if 
							$indices:=$line.properties.indices("kind = :1"; "subcollectionSource")
							If ($indices.length>0)
								$line.subcollectionSource:=$line.properties[$indices[0]].value
							End if 
							
						: ($line.typology="RP")
							$indices:=$line.properties.indices("kind = :1"; "collectionSource")
							If ($indices.length>0)
								$tag:=$line.properties[$indices[0]].value
								$line.collectionSource:=$tag
								If ($tag#$openRepeatSource)
									$lastCollectionSource:=""
								End if 
							Else 
								$lastCollectionSource:=""
							End if 
							
						: ($line.typology="ECR")
							$indices:=$line.properties.indices("kind = :1"; "collectionSource")
							If ($indices.length>0)
								$tag:=$line.properties[$indices[0]].value
								$line.collectionSource:=$tag
								$lastCollectionSource:=""
							Else 
								$lastCollectionSource:=""
							End if 
							
						: ($line.typology="ERR")
							$indices:=$line.properties.indices("kind = :1"; "collectionSource")
							If ($indices.length>0)
								$tag:=$line.properties[$indices[0]].value
								$line.collectionSource:=$tag
								$lastCollectionSource:=""
							Else 
								$lastCollectionSource:=""
							End if 
							
						Else 
							$lastCollectionSource:=""
					End case 
					$lastTypology:=$line.typology
				End for each 
				
				//MARK:-remove lines with empty collection source
				$linesToUse:=New collection:C1472
				For each ($line; $lines)
					$useline:=True:C214
					Case of 
						: (Position:C15(";"+$line.typology+";"; ";CR;RP;ECR;ERR;")>0)
							$collSource:=New collection:C1472
							If ($line.properties#Null:C1517)
								$indices:=$line.properties.indices("kind = :1"; "collectionSource")
								If ($indices.length>0)
									$tag:=$line.properties[$indices[0]].value
									Case of 
										: ($variableItems[$tag]=Null:C1517)
										: (Value type:C1509($variableItems[$tag])=Is text:K8:3)
											$collSource:=JSON Parse:C1218($variableItems[$tag])
											
										: (Value type:C1509($variableItems[$tag])=Is collection:K8:32)
											$collSource:=$variableItems[$tag]
									End case 
								End if 
							End if 
							$line.nbInCollectionSource:=$collSource.length
							$useline:=($collSource.length>0)
					End case 
					
					//MARK:  Visibility (hidden & ##@##)
					If ($useline) && ($line.properties#Null:C1517)
						$indices:=$line.properties.indices("kind = :1"; "visibility")
						If ($indices.length>0)
							$propertyVisibility:=$line.properties[$indices[0]]
							$line.visibility:=$propertyVisibility.value
							Case of 
								: ($line.visibility=Null:C1517)
									
								: ($line.visibility="hidden")
									$useline:=False:C215
									
								: ($line.visibility="@this.@")
									
								: ($line.visibility="##@##")
									$tag:=Substring:C12($propertyVisibility.value; 3; Length:C16($propertyVisibility.value)-4)
									$valueToTreat:=This:C1470.valuate_tag($tag; $variableItems; "")
									If (Not:C34(Bool:C1537($valueToTreat)))
										$useline:=False:C215
									End if 
									OB REMOVE:C1226($line; "visibility")
									
							End case 
						End if 
					End if 
					
					If ($useline)
						$linesToUse.push($line)
					End if 
				End for each 
				$lines:=$linesToUse
				
				//MARK:-insert repeted lines
				$linesToInsert:=New collection:C1472
				$lineNum:=0
				$numInColl:=0
				$order:=0
				For each ($line; $lines)
					$lineNum:=$lineNum+1
					If (Num:C11($line.groupNum)=0)
						$order+=1
						$line.order:=$order
						$line.lineNum:=$lineNum
						$line.groupNum:=$lineNum
						$numInColl:=$numInColl+1
						$line.numInColl:=$numInColl
						Case of 
							: ($line.typology="CR") & ($line.groupWithPrevious=Null:C1517)  //corps répété
								$line.repeatNum:=1
								$collSource:=New collection:C1472
								If ($line.properties#Null:C1517)
									$indices:=$line.properties.indices("kind = :1"; "collectionSource")
									If ($indices.length>0)
										$tag:=$line.properties[$indices[0]].value
										Case of 
											: ($variableItems[$tag]=Null:C1517)
											: (Value type:C1509($variableItems[$tag])=Is text:K8:3)
												$collSource:=JSON Parse:C1218($variableItems[$tag])
											: (Value type:C1509($variableItems[$tag])=Is collection:K8:32)
												$collSource:=$variableItems[$tag]
										End case 
									End if 
								End if 
								$line.this:=($collSource.length>0) ? $collSource[0] : New object:C1471
								
								For ($r; 1; $collSource.length)
									If ($r=1)
										$newLine:=$line
									Else 
										$newLine:=OB Copy:C1225($line)  // important to have distinct lines
										$linesToInsert.push($newLine)
									End if 
									$order+=1
									$newLine.order:=$order
									$newLine.repeatNum:=$r
									$newLine.this:=($collSource.length>=$r) ? $collSource[$r-1] : New object:C1471
									For ($n; $lineNum; $lines.length-1)
										$nextLine:=$lines[$n]
										If (Bool:C1537($nextLine.groupWithPrevious))
											If ($nextLine.typology="CRS")
												$subcollSource:=New collection:C1472
												If ($nextLine.properties#Null:C1517)
													$indices:=$nextLine.properties.indices("kind = :1"; "subcollectionSource")
													If ($indices.length>0)
														$tag:=$nextLine.properties[$indices[0]].value
														Case of 
															: ($newLine.this[$tag]=Null:C1517)
															: (Value type:C1509($newLine.this[$tag])=Is text:K8:3)
																$subcollSource:=JSON Parse:C1218($newLine.this[$tag])
															: (Value type:C1509($newLine.this[$tag])=Is collection:K8:32)
																$subcollSource:=$newLine.this[$tag]
														End case 
													End if 
												End if 
												For ($rs; 1; $subcollSource.length)
													If ($r=1) & ($rs=1)
													End if 
													$newLineCRS:=OB Copy:C1225($nextLine)  // important to have distinct lines
													$linesToInsert.push($newLineCRS)
													
													$order+=1
													$newLineCRS.order:=$order
													$newLineCRS.repeatNum:=$r
													$newLineCRS.subRepeatNum:=$rs
													$newLineCRS.this:=($subcollSource.length>=$rs) ? $subcollSource[$rs-1] : New object:C1471
												End for 
											Else 
												$newLineGW:=OB Copy:C1225($nextLine)  // important to have distinct lines
												$order+=1
												$newLineGW.order:=$order
												$newLineGW.repeatNum:=$r
												$newLineGW.this:=($collSource.length>=$r) ? $collSource[$r-1] : New object:C1471
												$linesToInsert.push($newLineGW)
											End if 
										Else 
											If (Position:C15(";"+$nextLine.typology+";"; ";RP;ECR;ERR;")>0) && (String:C10($nextLine.collectionSource)=String:C10($line.collectionSource))
												
											Else 
												break
											End if 
										End if 
									End for 
									
								End for 
								
							: ($line.typology="CR")  //corps répété groupé avec le précédent
								$line.order:=-1
								$line.this:=New object:C1471
								
							: ($line.typology="CRS")  //corps répété secondaire
								$line.order:=-1
								$line.this:=New object:C1471
								
						End case 
					End if 
				End for each 
				$lines:=$lines.query("order > 0").combine($linesToInsert).orderBy("order")
				$context.nbLines:=$lines.length
				
				//MARK:-Remove lines with visibility = false
				$linesToUse:=New collection:C1472
				For each ($line; $lines)
					
					Case of 
						: ($line.visibility#Null:C1517) && ($line.visibility="##@##")
							$tag:=Substring:C12($line.visibility; 3; Length:C16($line.visibility)-4)
							$valueToTreat:=This:C1470.valuate_tag($tag; $line.this; $line.collectionSource)
							If (Bool:C1537($valueToTreat))
								$linesToUse.push($line)
							End if 
							
						: ($line.visibility#Null:C1517) && (($line.visibility="IF(@)") || ($line.visibility="IF (@)"))
							$expressionIF:=Substring:C12($line.visibility; 4; Length:C16($line.visibility)-4)
							$expressionIF:=Replace string:C233($expressionIF; "$data"; "$1")
							$valueToTreat:=Formula from string:C1601($expressionIF).call($line.this; $variableItems)
							If (Bool:C1537($valueToTreat))
								$linesToUse.push($line)
							End if 
							
						Else 
							$linesToUse.push($line)
					End case 
				End for each 
				$lines:=$linesToUse
				
				
				//MARK:-Calculate the tags, dynamics properties, rules and height for each line
				$lineNum:=0
				$cumuls:=New object:C1471
				For each ($line; $lines)
					$lineNum:=$line.lineNum
					Case of 
						: ($line.kind="pageBreak")
							$line.topPx:=0
							$line.bottomPx:=0
							$line.heightPx:=0
							$color:=cs:C1710.dfd_panel_template.me.tool_choose_color($line.numInColl)
							$line.rulerColor:=$color
							$tooltip:="Saut de page"
							$line.rulerTooltip:=$tooltip
							
						: ($line.kind="template_line")
							
							$templateLine:=ds:C1482.dfd_Line.get($line.UUID_entity)
							
							$maxBottomPx:=0
							$objects:=$templateLine.objectsForm.objects.orderBy("order").copy()  //copy to preserve original template
							
							$context.nbObjects+=Num:C11($objects.length)
							
							//MARK:  •replace tags by value (except cumul.)
							For each ($object; $objects)
								
								If ($object.properties#Null:C1517)
									For each ($property; $object.properties)
										Case of 
											: (Value type:C1509($object.properties[$property])=Is text:K8:3) && ($object.properties[$property]="=@")
												$formulaString:=Substring:C12($object.properties[$property]; 2)
												$formulaString:=Replace string:C233($formulaString; "$data"; "$1")
												$formula:=Formula from string:C1601($formulaString)
												$object.properties[$property]:=$formula.call($line.this; $variableItems)
												
											: (Value type:C1509($object.properties[$property])=Is text:K8:3) && ($property#"numberFormat") && ($property#"textFormat") && ($property#"dateFormat") && ($property#"timeFormat")
												$value:=$object.properties[$property]
												$pStart:=1
												Repeat 
													$pStart:=Position:C15("##"; $value; $pStart; *)
													If ($pStart>0)
														$pEnd:=Position:C15("##"; $value; $pStart+2; *)
														If ($pEnd>0)
															$tag:=Substring:C12($value; $pStart+2; $pEnd-$pStart-2)
															$pStart:=$pEnd+2
															Case of 
																: ($tag="this.@")
																	
																	$this:=$line.this
																	
																	$lastAttribute:=Split string:C1554($tag; ".").pop()
																	If ($line.this[$lastAttribute]=Null:C1517) && ($lastAttribute="counter")
																		$valueToDisplay:=$line.repeatNum
																	Else 
																		//$valueToDisplay:=$this[$lastAttribute]
																		$valueToDisplay:=This:C1470.valuate_tag($tag; $line.this; $line.collectionSource)
																	End if 
																	
																	Case of 
																		: ($object.properties._money#Null:C1517) && (($property="text") || ($property="dataSource"))
																			$textToDisplay:=This:C1470.tool_display_asMoney($valueToDisplay; $object.properties._money)
																			
																		: ($object.properties.type="text") && ($object.properties.numberFormat#Null:C1517) && ($object.properties.numberFormat="ƒ(@")
																			$formula:=Formula from string:C1601(Substring:C12($object.properties.numberFormat; 3; Length:C16($object.properties.numberFormat)-3))
																			$textToDisplay:=$formula.call($line.this; Num:C11($valueToDisplay))
																			
																		: ($object.properties.type="text") && ($object.properties.numberFormat#Null:C1517)
																			$textToDisplay:=String:C10($valueToDisplay; $object.properties.numberFormat)
																			
																		: ($object.properties.type="text") && ($object.properties.textFormat#Null:C1517) && ($object.properties.textFormat="ƒ(@")
																			$formula:=Formula from string:C1601(Substring:C12($object.properties.textFormat; 3; Length:C16($object.properties.textFormat)-3))
																			$textToDisplay:=$formula.call($line.this; String:C10($valueToDisplay))
																			
																		: ($object.properties.type="text") && ($object.properties.textFormat#Null:C1517)
																			$textToDisplay:=This:C1470.tool_format_string($valueToDisplay; $object.properties.textFormat)
																			
																		: ($object.properties.type="text") && ($object.properties.dateFormat#Null:C1517) && ($object.properties.dateFormat="ƒ(@")
																			$formula:=Formula from string:C1601(Substring:C12($object.properties.dateFormat; 3; Length:C16($object.properties.dateFormat)-3))
																			$textToDisplay:=$formula.call($line.this; Num:C11($valueToDisplay))
																			
																		: ($object.properties.type="text") && ($object.properties.dateFormat#Null:C1517)
																			$textToDisplay:=This:C1470.tool_format_date($valueToDisplay; $object.properties.dateFormat)
																			
																		: ($object.properties.type="text") && ($object.properties.timeFormat#Null:C1517) && ($object.properties.timeFormat="ƒ(@")
																			$formula:=Formula from string:C1601(Substring:C12($object.properties.timeFormat; 3; Length:C16($object.properties.timeFormat)-3))
																			$textToDisplay:=$formula.call($line.this; Num:C11($valueToDisplay))
																			
																		: ($object.properties.type="text") && ($object.properties.timeFormat#Null:C1517)
																			$textToDisplay:=This:C1470.tool_format_time($valueToDisplay; $object.properties.timeFormat)
																			
																		: ($object.properties.type="text") && ($object.properties.text#Null:C1517) && ($object.properties.text="ƒ(@")
																			$formula:=Formula from string:C1601(Substring:C12($object.properties.text; 3; Length:C16($object.properties.text)-3))
																			$textToDisplay:=$formula.call($line.this; String:C10($valueToDisplay))
																			
																		: ($object.properties[$property]#Null:C1517) && ($object.properties[$property]="IF(@)")
																			$textToDisplay:=This:C1470.treat_IFcondition(String:C10($object.properties[$property]); $line.this; $variableItems)
																			
																		Else 
																			$textToDisplay:=String:C10($valueToDisplay)
																			
																	End case 
																	
																	$object.properties[$property]:=Replace string:C233($object.properties[$property]; "##"+$tag+"##"; $textToDisplay)
																	If (Value type:C1509($line.this[$lastAttribute])=Is real:K8:4) && (Position:C15(".cumul."; $tag)=0) && ($line.subcollectionSource=Null:C1517)
																		If ($cumuls[$line.collectionSource]=Null:C1517)
																			$cumuls[$line.collectionSource]:=New object:C1471("steps"; New object:C1471)
																		End if 
																		If ($cumuls[$line.collectionSource][$lastAttribute]=Null:C1517)
																			$cumuls[$line.collectionSource][$lastAttribute]:=0
																			$cumuls[$line.collectionSource].steps[$lastAttribute]:=New collection:C1472
																		End if 
																		$cumuls[$line.collectionSource][$lastAttribute]+=$this[$lastAttribute]
																		$cumuls[$line.collectionSource].steps[$lastAttribute].push($cumuls[$line.collectionSource][$lastAttribute])
																	End if 
																	
																	If (String:C10($object.properties.dataSourceTypeHint)="picture")
																		If (Value type:C1509($this[$lastAttribute])=Is text:K8:3)
																			$text64:=$valueToDisplay
																			BASE64 DECODE:C896($text64; $blob)
																			BLOB TO PICTURE:C682($blob; $picture; ".png")
																			$context.picturesCounter+=1
																			$idp:="p"+String:C10($context.picturesCounter)
																			Case of 
																				: ($destination="--print")
																					<>DFD_pictures[$idp]:=$picture
																					$object.properties[$property]:="<>DFD_pictures."+String:C10($idp)
																					
																				: ($destination="--pdf")
																					<>DFD_pictures[$idp]:=$picture
																					$object.properties[$property]:="<>DFD_pictures."+String:C10($idp)
																					
																				: ($destination="--subform")
																					$context.preview.pictures[$idp]:=$picture
																					$object.properties[$property]:="Form.pictures."+String:C10($idp)
																					
																			End case 
																			
																		End if 
																	End if 
																	
																	
																: ($tag="cumul.@")
																	
																Else 
																	
																	Case of 
																		: (String:C10($object.properties.dataSourceTypeHint)="picture")
																			
																			If (Value type:C1509($variableItems[$tag])=Is text:K8:3)
																				$text64:=$variableItems[$tag]
																				BASE64 DECODE:C896($text64; $blob)
																				BLOB TO PICTURE:C682($blob; $picture; ".png")
																				$context.picturesCounter+=1
																				$idp:="p"+String:C10($context.picturesCounter)
																				Case of 
																					: ($destination="--print")
																						<>DFD_pictures[$idp]:=$picture
																						$object.properties[$property]:="<>DFD_pictures."+String:C10($idp)
																					: ($destination="--pdf")
																						<>DFD_pictures[$idp]:=$picture
																						$object.properties[$property]:="<>DFD_pictures."+String:C10($idp)
																						
																					: ($destination="--subform")
																						$context.preview.pictures[$idp]:=$picture
																						$object.properties[$property]:="Form:C1466.pictures."+String:C10($idp)
																						
																				End case 
																				
																			Else 
																				
																			End if 
																		Else 
																			
																			$valueToDisplay:=This:C1470.valuate_tag($tag; $variableItems; $line.collectionSource)
																			
																			Case of 
																				: ($object.properties._money#Null:C1517) && (($property="text") || ($property="dataSource"))
																					$textToDisplay:=This:C1470.tool_display_asMoney($valueToDisplay; $object.properties._money)
																					
																				: ($object.properties.type="text") && ($object.properties.numberFormat#Null:C1517) && ($object.properties.numberFormat="ƒ(@")
																					$formula:=Formula from string:C1601(Substring:C12($object.properties.numberFormat; 3; Length:C16($object.properties.numberFormat)-3))
																					$textToDisplay:=$formula.call($variableItems; Num:C11($valueToDisplay))
																					
																				: ($object.properties.type="text") && ($object.properties.numberFormat#Null:C1517)
																					$textToDisplay:=String:C10($valueToDisplay; $object.properties.numberFormat)
																					
																				: ($object.properties.type="text") && ($object.properties.textFormat#Null:C1517) && ($object.properties.textFormat="ƒ(@")
																					$formula:=Formula from string:C1601(Substring:C12($object.properties.textFormat; 3; Length:C16($object.properties.textFormat)-3))
																					$textToDisplay:=$formula.call($variableItems; String:C10($valueToDisplay))
																					
																				: ($object.properties.type="text") && ($object.properties.textFormat#Null:C1517)
																					$textToDisplay:=This:C1470.tool_format_string($valueToDisplay; $object.properties.textFormat)
																					
																				: ($object.properties.type="text") && ($object.properties.dateFormat#Null:C1517) && ($object.properties.dateFormat="ƒ(@")
																					$formula:=Formula from string:C1601(Substring:C12($object.properties.dateFormat; 3; Length:C16($object.properties.dateFormat)-3))
																					$textToDisplay:=$formula.call($variableItems; Num:C11($valueToDisplay))
																					
																				: ($object.properties.type="text") && ($object.properties.dateFormat#Null:C1517)
																					$textToDisplay:=This:C1470.tool_format_date($valueToDisplay; $object.properties.dateFormat)
																					
																				: ($object.properties.type="text") && ($object.properties.timeFormat#Null:C1517) && ($object.properties.timeFormat="ƒ(@")
																					$formula:=Formula from string:C1601(Substring:C12($object.properties.timeFormat; 3; Length:C16($object.properties.timeFormat)-3))
																					$textToDisplay:=$formula.call($variableItems; Num:C11($valueToDisplay))
																					
																				: ($object.properties.type="text") && ($object.properties.timeFormat#Null:C1517)
																					$textToDisplay:=This:C1470.tool_format_time($valueToDisplay; $object.properties.timeFormat)
																					
																				: ($object.properties.type="text") && ($object.properties.text#Null:C1517) && ($object.properties.text="ƒ(@")
																					$formula:=Formula from string:C1601(Substring:C12($object.properties.text; 3; Length:C16($object.properties.text)-3))
																					$textToDisplay:=$formula.call($line.this; String:C10($valueToDisplay))
																					
																				: ($object.properties[$property]#Null:C1517) && ($object.properties[$property]="IF(@)")
																					$textToDisplay:=This:C1470.treat_IFcondition(String:C10($object.properties[$property]); $line.this; $variableItems)
																					
																				Else 
																					$textToDisplay:=String:C10($valueToDisplay)
																			End case 
																			$object.properties[$property]:=Replace string:C233($object.properties[$property]; "##"+$tag+"##"; $textToDisplay)
																	End case 
															End case 
														Else 
															$pStart:=0
														End if 
													End if 
												Until ($pStart=0)
												
												Case of 
													: ($property="text") | ($property="datasource")
														Case of 
															: ($object.properties.type="text") && ($object.properties[$property]#Null:C1517) && ($object.properties[$property]="ƒ(@")
																$formula:=Formula from string:C1601(Substring:C12($object.properties[$property]; 3; Length:C16($object.properties[$property])-3))
																$object.properties[$property]:=$formula.call($line.this; String:C10($valueToDisplay))
																
															: ($object.properties.type="text") && ($object.properties[$property]#Null:C1517) && ($object.properties[$property]="IF(@)")
																$textToDisplay:=This:C1470.treat_IFcondition(String:C10($object.properties[$property]); $line.this; $variableItems)
																$object.properties[$property]:=$textToDisplay
																
														End case 
														
													: ($object.properties[$property]#Null:C1517) && ($object.properties[$property]="IF(@)")
														$textToDisplay:=This:C1470.treat_IFcondition(String:C10($object.properties[$property]); $line.this; $variableItems)
														
														$object.properties[$property]:=$textToDisplay
												End case 
										End case 
									End for each 
									
									
									If (String:C10($object.properties._origineType)="checkbox")
										$tag:=$object.properties.dataSource
										$tagParts:=Split string:C1554($tag; ".")
										$lastAttribute:=$tagParts.pop()
										$checkboxObject:=$variableItems
										If ($tagParts.length>0)
											$checkboxObject:=$checkboxObject[$tagParts.shift()]
											For each ($tagPart; $tagParts)
												$checkboxObject:=$checkboxObject[$tagPart]
											End for each 
										End if 
										$value:=String:C10($checkboxObject[$lastAttribute])
										
										If ($value="true") | ($value="vrai") | ($value="1")
											$object.properties.dataSource:="Num:C11(True:C214)"
										Else 
											$object.properties.dataSource:="Num:C11(False:C215)"
										End if 
										If (String:C10($object.properties.style)="")
											$object.properties.style:="flat"
										End if 
									End if 
								End if 
							End for each 
							
							//MARK:  •calculate the dynamic properties
							cs:C1710.dfd_panel_line.me.calculate_dynProp($objects; $destination)
							
							//MARK:  •apply the rules
							If ($templateLine.calculs.rules#Null:C1517)
								$rules:=$templateLine.calculs.rules.copy()
								cs:C1710.dfd_panel_line.me.apply_rules($objects; $rules)
							End if 
							
							//MARK:  •place the objects with margins
							For each ($object; $objects)
								//$name:=$object.name+"_"+String($lineNum)+"_"+String($line.repeatNum)
								//$name+=($line.subRepeatNum#Null) ? ("_"+String($line.subRepeatNum)) : ""
								$name:=$object.name+"___"+Generate UUID:C1066
								$properties:=OB Copy:C1225($object.properties)
								$properties.top:=$properties.top
								$properties.left:=$properties.left+$margin_left
								If (($properties.top+$properties.height)>$maxBottomPx)
									$maxBottomPx:=$properties.top+$properties.height
								End if 
								$line.objectsForm[$name]:=$properties
							End for each 
							
							//MARK:  •valuate visibility
							Case of 
								: ($properties.visibility=Null:C1517)
								: (String:C10($properties.visibility)="##@##")
									$tag:=Substring:C12(String:C10($properties.visibility); 3; Length:C16(String:C10($properties.visibility))-4)
									$valueToTreat:=This:C1470.valuate_tag($tag; $line.this; $line.collectionSource)
									$properties.visibility:=Bool:C1537($valueToTreat) ? "visible" : "hidden"
									
								: (String:C10($properties.visibility)#Null:C1517) && (String:C10($properties.visibility)="IF(@)")
									$expressionIF:=Substring:C12(String:C10($properties.visibility); 4; Length:C16(String:C10($properties.visibility))-4)
									$valueToTreat:=Formula from string:C1601($expressionIF).call($line.this)
									$properties.visibility:=Bool:C1537($valueToTreat) ? "visible" : "hidden"
									
							End case 
							
							//MARK:  •save global line size and rulers infos
							$line.topPx:=0
							$line.bottomPx:=$maxBottomPx
							$line.heightPx:=$maxBottomPx
							$color:=cs:C1710.dfd_panel_template.me.tool_choose_color($line.numInColl)
							$line.rulerColor:=$color
							$tooltip:=$templateLine.name
							If ($line.repeatNum#Null:C1517)
								$tooltip:=$tooltip+"\r"+"repeat : "+String:C10($line.repeatNum)
							End if 
							$line.rulerTooltip:=$tooltip
							
					End case 
				End for each 
				
				//MARK:-read the size of the paper
				$indices:=$context.paper.formats.indices("name = :1"; $context.paper.format)
				If ($indices.length>0)
					$pageWidthPx:=$context.paper.formats[$indices[0]].width
					$pageHeightPx:=$context.paper.formats[$indices[0]].height
				Else 
					$pageWidthPx:=595
					$pageHeightPx:=842
				End if 
				$portraitWidthPx:=$pageWidthPx
				$portraitHeightPx:=$pageHeightPx
				
				// reverse the dimension
				If ($context.document.moreData.settings.orientation="landscape")
					$dim:=$pageWidthPx
					$pageWidthPx:=$pageHeightPx
					$pageHeightPx:=$dim
				End if 
				
				
				//MARK:-display in pages by typology
				For each ($line; $lines)
					$line.displayInPages:=""
					$line.showInPage:=New collection:C1472
					Case of 
						: ($line.typology="EPP")
							$line.displayInPages:="1"
						: ($line.typology="ETP")
							$line.displayInPages:="all"
						: ($line.typology="EPS")
							$line.displayInPages:="2+"
						: ($line.typology="PP")
							$line.displayInPages:="all"
						: ($line.typology="PPS")
							$line.displayInPages:="2+"
						: ($line.typology="PPI")
							$line.displayInPages:="2+N-1"
						: ($line.typology="PPL")
							$line.displayInPages:="last"
						: ($line.typology="FP")
							$line.displayInPages:="all"
						: ($line.typology="FPP")
							$line.displayInPages:="1"
						: ($line.typology="FPS")
							$line.displayInPages:="2+"
					End case 
				End for each 
				
				//MARK:-group CRS with CR
				$ungroupNecessary:=False:C215
				$indices:=$lines.indices("typology = :1 and properties[a].name = :2 and properties[a].value = :3"; "CRS"; "groupWithMain"; "true")
				If ($indices.length>0)
					$ungroupNecessary:=True:C214
					$linesToUse:=New collection:C1472
					$currentCRLine:=Null:C1517
					For each ($line; $lines)
						Case of 
							: ($line.typology="CR")
								$currentCRLine:=$line
								$linesToUse.push($line)
							: ($line.typology="CRS")
								$indices:=$line.properties.query("name = :1 and value = :2"; "groupWithMain"; "true")
								If ($indices.length=0)
									$linesToUse.push($line)
								Else 
									If ($currentCRLine.subLines=Null:C1517)
										$currentCRLine.subLines:=New collection:C1472
									End if 
									$currentCRLine.subLines.push($line)
								End if 
							Else 
								$linesToUse.push($line)
						End case 
					End for each 
					$lines:=$linesToUse
				End if 
				
				//MARK:-split in pages
				$pageInCalculation:=0
				$stop:=False:C215
				$lastECRCollection:=""
				$lastERRCollection:=""
				$lastPage:=0
				$nextIsLast:=False:C215
				Repeat 
					$pageInCalculation+=1
					$heightUsed:=$margin_topPx+$margin_bottomPx
					For each ($line; $lines)  //mandoroty lines
						$addInPage:=Not:C34($nextIsLast)
						Case of 
							: ($line.displayInPages="all")
							: ($line.displayInPages="1") & ($pageInCalculation=1)
							: ($line.displayInPages="2+@") & ($pageInCalculation>1)
							Else 
								$addInPage:=False:C215
						End case 
						If ($addInPage)
							$line.showInPage.push($pageInCalculation)
							If (Position:C15(";"+$line.typology+";"; ";FP;FPP;FPS;")=0)
								$heightUsed+=$line.heightPx
							End if 
						End if 
					End for each 
					$lineNum:=0
					$firstRepeatInPage:=True:C214
					For each ($line; $lines)  // other lines
						If ($line.showInPage.length=0) & ($line.displayInPages="")
							Case of 
								: ($line.kind="pageBreak")
									If ($line.orientation="landscape")
										$pageWidthPx:=$portraitHeightPx
										$pageHeightPx:=$portraitWidthPx
									Else 
										$pageWidthPx:=$portraitWidthPx
										$pageHeightPx:=$portraitHeightPx
									End if 
									$line.showInPage.push($pageInCalculation)
									break
								Else 
									If (($heightUsed+$line.heightPx)<=$pageHeightPx)
										$addInPage:=True:C214
										Case of 
											: ($line.typology="ECR")
												$lastECR:=$line
												$lastECRCollection:=$line.collectionSource
												$firstRepeatInPage:=False:C215
												
											: ($line.typology="ERR")
												$lastERR:=$line
												$lastERRCollection:=$line.collectionSource
												$addInPage:=False:C215
												
											: (($line.typology="CR") | ($line.typology="CRS")) && ($lineNum<($lines.length-1))
												If ($firstRepeatInPage)
													$firstRepeatInPage:=False:C215
													If ($lastECRCollection=$line.collectionSource)
														$lastECR.showInPage.push($pageInCalculation)
														//$heightUsed+=$line.heightPx
														$heightUsed+=$lastECR.heightPx
													End if 
													If ($lastERRCollection=$line.collectionSource)
														$lastERR.showInPage.push($pageInCalculation)
														//$heightUsed+=$line.heightPx
														$heightUsed+=$lastERR.heightPx
													End if 
												End if 
												If ($line.subLines#Null:C1517)
													$heightPXLinesAndSubLines:=$line.heightPx+$line.subLines.sum("heightPx")
													If ($heightUsed+$heightPXLinesAndSubLines<=$pageHeightPx)
														For each ($subLine; $line.subLines)
															$subLine.showInPage.push($pageInCalculation)
															$heightUsed+=$subLine.heightPx
														End for each 
													Else 
														break
													End if 
												End if 
												
												For ($i; $lineNum+1; ($lines.length-1))
													If ($lines[$i].typology="RP") && (String:C10($lines[$i].collectionSource)=$line.collectionSource)
														Case of 
															: ($i=($lineNum+1))
																If ($ruptureLine#Null:C1517) && ($ruptureLine.showInPage.indexOf($pageInCalculation)=($ruptureLine.showInPage.length-1))
																	$indices:=$ruptureLine.properties.indices("kind = :1"; "displayAtEnd")
																	If ($indices.length>0)
																		If (Not:C34(String:C10($ruptureLine.properties[$indices[0]].value)="true"))
																			$pop:=True:C214
																			Case of 
																				: ($lines.length=$i)
																					
																				: ($lines[$i+1].heightPx+$heightUsed<=$pageHeightPx)
																					
																				Else 
																					$pop:=False:C215
																			End case 
																			If ($pop)
																				$p:=$ruptureLine.showInPage.pop()
																			End if 
																		End if 
																	End if 
																End if 
																
															Else 
																$ruptureLine:=$lines[$i]
																If ($ruptureLine.showInPage.indexOf($pageInCalculation)=-1)
																	If (($heightUsed+$line.heightPx+$ruptureLine.heightPx)<=$pageHeightPx)
																		$ruptureLine.showInPage.push($pageInCalculation)
																		$heightUsed+=$ruptureLine.heightPx
																	Else 
																		$addInPage:=False:C215
																		break
																	End if 
																End if 
																
														End case 
													End if 
												End for 
											: ($line.typology="RP")
												If ((Num:C11($lines[$lineNum-1].repeatNum)=Num:C11($line.nbInCollectionSource)))
													$line.showInPage.push(-1)
													$addInPage:=False:C215
												End if 
										End case 
										If ($addInPage)
											$line.showInPage.push($pageInCalculation)
											$heightUsed+=$line.heightPx
											$lastPage:=$pageInCalculation
										End if 
									Else 
										break
									End if 
							End case 
						End if 
						$lineNum:=$lineNum+1
					End for each 
					
					$stop:=True:C214
					For each ($line; $lines)  // need a new page ? 
						If ($line.showInPage.length=0) & (Position:C15(";"+$line.typology+";"; ";FP;FPP;FPS;ERR;PPL;")=0)
							Case of 
								: ($line.typology="EPS") & ($pageInCalculation=1)
									$line.showInPage.push(-1)
									
								Else 
									$stop:=False:C215
									break
							End case 
						End if 
						Case of 
							: ($line.typology="ERR") & ($pageInCalculation=1)
								$line.showInPage.push(-1)
						End case 
					End for each 
					If ($stop)
						$linesToDockInFooter:=$lines.query("showInPage.length=0")
						For each ($line; $linesToDockInFooter)
							If (($heightUsed+$line.heightPx)<=$pageHeightPx)
								$line.showInPage.push($pageInCalculation)
								$lastPage:=$pageInCalculation
								For each ($lineToUpdate; $lines)
									Case of 
										: ($lineToUpdate.typology="FP")
											$lineToUpdate.showInPage.push($pageInCalculation)
										: ($lineToUpdate.typology="ETP")
											$lineToUpdate.showInPage.push($pageInCalculation)
									End case 
								End for each 
								
							Else 
								$stop:=False:C215
								break
							End if 
						End for each 
						If ($stop=False:C215)
							For each ($line; $linesToDockInFooter)
								$pop:=$line.showInPage.pop()
								$nextIsLast:=True:C214
							End for each 
						End if 
					End if 
				Until ($stop)
				$context.nbOfPages:=$lastPage
				
				//MARK:-ungroup CRS in CR
				If ($ungroupNecessary)
					$linesToUse:=New collection:C1472
					$currentCRLine:=Null:C1517
					For each ($line; $lines)
						Case of 
							: ($line.typology="CR")
								$currentCRLine:=$line
								$linesToUse.push($line)
								If ($line.subLines#Null:C1517)
									For each ($subLine; $line.subLines)
										$linesToUse.push($subLine)
									End for each 
									OB REMOVE:C1226($line; "subLines")
								End if 
							Else 
								$linesToUse.push($line)
						End case 
					End for each 
					$lines:=$linesToUse
				End if 
				
				
				//MARK:-Output preparation
				Case of 
					: ($destination="--print")
						$pageToPrintMin:=1
						$pageToPrintMax:=$context.nbOfPages
						SET PRINT PREVIEW:C364($context.document.moreData.settings.printPreview)
						
					: ($destination="--pdf")
						$pageToPrintMin:=1
						$pageToPrintMax:=$context.nbOfPages
						SET PRINT PREVIEW:C364(False:C215)
						
					: ($destination="--subform")
						
						$context.ddPage:=New object:C1471
						$context.ddPage.values:=New collection:C1472
						For ($p; 1; $context.nbOfPages)
							$context.ddPage.values.push(Localized string:C991("tool.ddPage")+String:C10($p)+"/"+String:C10($context.nbOfPages))
						End for 
						If ($page>$context.ddPage.values.length)
							$page:=$context.ddPage.values.length
						End if 
						$context.ddPage.index:=$page-1
						$pageToPrintMin:=$page
						$pageToPrintMax:=$page
						
				End case 
				
				For ($pageToPrint; $pageToPrintMin; $pageToPrintMax)
					$context.pageToPrint:=$pageToPrint
					$formDefinition:=JSON Parse:C1218($json)
					
					
					//MARK:-Select the good pages
					$linesToDraw:=New collection:C1472
					$footersToDraw:=New collection:C1472
					$bkgdsToDraw:=New collection:C1472
					For each ($line; $lines)
						$goodPage:=($line.showInPage.indexOf($context.pageToPrint)>=0)
						Case of 
							: ($goodPage) & ((Position:C15(";"+$line.typology+";"; ";FP;FPP;FPS;")#0))
								$bkgdsToDraw.push(OB Copy:C1225($line))
							: ($goodPage) & ($line.typology="PP@")
								$footersToDraw.unshift(OB Copy:C1225($line))
							: ($goodPage)
								$linesToDraw.push(OB Copy:C1225($line))
						End case 
					End for each 
					
					//MARK:-replace page tags by value
					For ($s; 1; 3)
						Case of 
							: ($s=1)
								$linesToCalculate:=$linesToDraw
							: ($s=2)
								$linesToCalculate:=$footersToDraw
							: ($s=3)
								$linesToCalculate:=$bkgdsToDraw
						End case 
						$lineNum:=0
						For each ($line; $linesToCalculate)
							$objectsForm:=$line.objectsForm
							For each ($objectName; $objectsForm)
								For each ($property; $objectsForm[$objectName])
									Case of 
										: (Value type:C1509($objectsForm[$objectName][$property])=Is text:K8:3) && ($objectsForm[$objectName][$property]="=@")
											$formulaString:=Substring:C12($objectsForm[$objectName][$property]; 2)
											$formulaString:=Replace string:C233($formulaString; "$data"; "$1")
											$formula:=Formula from string:C1601($formulaString)
											$objectsForm[$objectName][$property]:=$formula.call($line.this; $variableItems)
											
										: (Value type:C1509($objectsForm[$objectName][$property])=Is text:K8:3) && ($property#"numberFormat") && ($property#"textFormat") && ($property#"dateFormat") && ($property#"timeFormat")
											$value:=This:C1470.valuate_sysTag($objectsForm[$objectName][$property]; $context; $objectsForm[$objectName])
											$objectsForm[$objectName][$property]:=$value
											$pStart:=1
											Repeat 
												$pStart:=Position:C15("##"; $value; $pStart; *)
												If ($pStart>0)
													$pEnd:=Position:C15("##"; $value; $pStart+2; *)
													If ($pEnd>0)
														$tag:=Substring:C12($value; $pStart+2; $pEnd-$pStart-2)
														$pStart:=$pEnd+2
														Case of 
															: ($tag="cumul.@")
																$tagParts:=Split string:C1554($tag; ".")
																$cumulTag:=$tagParts.shift()
																$lastAttribute:=$tagParts.pop()
																If ($tagParts.indexOf("steps")=-1)
																	$this:=$cumuls
																	For each ($attribut; $tagParts)
																		$this:=($attribut="this") ? $this[$line.collectionSource] : $this[$attribut]
																	End for each 
																	$valueToDisplay:=$this[$lastAttribute]
																	Case of 
																		: ($objectsForm[$objectName]._money#Null:C1517)
																			$textToDisplay:=This:C1470.tool_display_asMoney($valueToDisplay; $objectsForm[$objectName]._money)
																			
																		: ($objectsForm[$objectName].type="text") && ($objectsForm[$objectName].numberFormat#Null:C1517) && ($objectsForm[$objectName].numberFormat="ƒ(@")
																			$formula:=Formula from string:C1601(Substring:C12($objectsForm[$objectName].numberFormat; 3; Length:C16($objectsForm[$objectName].numberFormat)-3))
																			$textToDisplay:=$formula.call($cumuls; Num:C11($valueToDisplay))
																			
																		: ($objectsForm[$objectName].type="text") && ($objectsForm[$objectName].numberFormat#Null:C1517)
																			$textToDisplay:=String:C10($valueToDisplay; $objectsForm[$objectName].numberFormat)
																			
																		: ($objectsForm[$objectName].type="text") && ($objectsForm[$objectName].textFormat#Null:C1517) && ($objectsForm[$objectName].textFormat="ƒ(@")
																			$formula:=Formula from string:C1601(Substring:C12($objectsForm[$objectName].textFormat; 3; Length:C16($objectsForm[$objectName].textFormat)-3))
																			$textToDisplay:=$formula.call($cumuls; String:C10($valueToDisplay))
																			
																		: ($objectsForm[$objectName].type="text") && ($objectsForm[$objectName].textFormat#Null:C1517)
																			$textToDisplay:=This:C1470.tool_format_string($valueToDisplay; $objectsForm[$objectName].textFormat)
																			
																		: ($objectsForm[$objectName].type="text") && ($objectsForm[$objectName].dateFormat#Null:C1517) && ($objectsForm[$objectName].dateFormat="ƒ(@")
																			$formula:=Formula from string:C1601(Substring:C12($objectsForm[$objectName].dateFormat; 3; Length:C16($objectsForm[$objectName].dateFormat)-3))
																			$textToDisplay:=$formula.call($cumuls; Num:C11($valueToDisplay))
																			
																		: ($objectsForm[$objectName].type="text") && ($objectsForm[$objectName].dateFormat#Null:C1517)
																			$textToDisplay:=This:C1470.tool_format_date($valueToDisplay; $objectsForm[$objectName].dateFormat)
																			
																		: ($objectsForm[$objectName].type="text") && ($objectsForm[$objectName].timeFormat#Null:C1517) && ($objectsForm[$objectName].timeFormat="ƒ(@")
																			$formula:=Formula from string:C1601(Substring:C12($objectsForm[$objectName].timeFormat; 3; Length:C16($objectsForm[$objectName].timeFormat)-3))
																			$textToDisplay:=$formula.call($cumuls; Num:C11($valueToDisplay))
																			
																		: ($objectsForm[$objectName].type="text") && ($objectsForm[$objectName].timeFormat#Null:C1517)
																			$textToDisplay:=This:C1470.tool_format_time($valueToDisplay; $objectsForm[$objectName].timeFormat)
																			
																		Else 
																			$textToDisplay:=String:C10($valueToDisplay)
																			
																	End case 
																	
																	$objectsForm[$objectName][$property]:=Replace string:C233($objectsForm[$objectName][$property]; "##"+$tag+"##"; $textToDisplay)
																Else 
																	If ($lineNum>=1)  //was >1
																		$targetTag:=$tagParts.shift()
																		$target:=($targetTag="this") ? $line.collectionSource : $targetTag
																		If ($target#Null:C1517)
																			If ($line.typology="ERR")
																				$previousRepeatStep:=Num:C11($linesToCalculate[$lineNum+1].repeatNum)
																				$valCumul:=$cumuls[$target].steps[$lastAttribute][$previousRepeatStep-2]
																			Else 
																				$previousRepeatStep:=Num:C11($linesToCalculate[$lineNum-1].repeatNum)
																				If ($previousRepeatStep>$cumuls[$target].steps[$lastAttribute].length)
																					$previousRepeatStep:=$cumuls[$target].steps[$lastAttribute].length
																				End if 
																				$valCumul:=$cumuls[$target].steps[$lastAttribute][$previousRepeatStep-1]
																			End if 
																			Case of 
																				: ($objectsForm[$objectName]._money#Null:C1517)
																					$textToDisplay:=This:C1470.tool_display_asMoney($valCumul; $objectsForm[$objectName]._money)
																					
																				: ($objectsForm[$objectName].type="text") && ($objectsForm[$objectName].numberFormat#Null:C1517) && ($objectsForm[$objectName].numberFormat="ƒ(@")
																					$formula:=Formula from string:C1601(Substring:C12($objectsForm[$objectName].numberFormat; 3; Length:C16($objectsForm[$objectName].numberFormat)-3))
																					$textToDisplay:=$formula.call($cumuls; Num:C11($valCumul))
																					
																				: ($objectsForm[$objectName].type="text") && ($objectsForm[$objectName].numberFormat#Null:C1517)
																					$textToDisplay:=String:C10($valCumul; $objectsForm[$objectName].numberFormat)
																					
																				: ($objectsForm[$objectName].type="text") && ($objectsForm[$objectName].textFormat#Null:C1517) && ($objectsForm[$objectName].textFormat="ƒ(@")
																					$formula:=Formula from string:C1601(Substring:C12($objectsForm[$objectName].textFormat; 3; Length:C16($objectsForm[$objectName].textFormat)-3))
																					$textToDisplay:=$formula.call($cumuls; String:C10($valueToDisplay))
																					
																				: ($objectsForm[$objectName].type="text") && ($objectsForm[$objectName].textFormat#Null:C1517)
																					$textToDisplay:=This:C1470.tool_format_string($valueToDisplay; $objectsForm[$objectName].textFormat)
																					
																				: ($objectsForm[$objectName].type="text") && ($objectsForm[$objectName].dateFormat#Null:C1517) && ($objectsForm[$objectName].dateFormat="ƒ(@")
																					$formula:=Formula from string:C1601(Substring:C12($objectsForm[$objectName].dateFormat; 3; Length:C16($objectsForm[$objectName].dateFormat)-3))
																					$textToDisplay:=$formula.call($cumuls; Num:C11($valCumul))
																					
																				: ($objectsForm[$objectName].type="text") && ($objectsForm[$objectName].dateFormat#Null:C1517)
																					$textToDisplay:=This:C1470.tool_format_date($valCumul; $objectsForm[$objectName].dateFormat)
																					
																				: ($objectsForm[$objectName].type="text") && ($objectsForm[$objectName].timeFormat#Null:C1517) && ($objectsForm[$objectName].timeFormat="ƒ(@")
																					$formula:=Formula from string:C1601(Substring:C12($objectsForm[$objectName].timeFormat; 3; Length:C16($objectsForm[$objectName].timeFormat)-3))
																					$textToDisplay:=$formula.call($cumuls; Num:C11($valCumul))
																					
																				: ($objectsForm[$objectName].type="text") && ($objectsForm[$objectName].timeFormat#Null:C1517)
																					$textToDisplay:=This:C1470.tool_format_time($valCumul; $objectsForm[$objectName].timeFormat)
																					
																				Else 
																					$textToDisplay:=String:C10($valCumul)
																			End case 
																			
																			$objectsForm[$objectName][$property]:=Replace string:C233($objectsForm[$objectName][$property]; "##"+$tag+"##"; $textToDisplay)
																		End if 
																	End if 
																End if 
														End case 
													Else 
														$pStart:=0
													End if 
												End if 
											Until ($pStart=0)
											
									End case 
								End for each 
							End for each 
							$lineNum:=$lineNum+1
						End for each 
					End for 
					
					//MARK:-change the fill color in repeated lines
					For each ($line; $linesToDraw)
						
						If ($line.properties#Null:C1517)
							$indices:=$line.properties.indices("kind = :1"; "alternateWithMain")
							If ($indices.length>0)
								$line.alternateWithMain:=(String:C10($line.properties[$indices[0]].value)="true")
							End if 
						End if 
						Case of 
							: ($line.subRepeatNum#Null:C1517) & Not:C34(Bool:C1537($line.alternateWithMain))
								$repeat:=Num:C11($line.subRepeatNum)
							: ($line.repeatNum#Null:C1517)
								$repeat:=Num:C11($line.repeatNum)
							Else 
								$repeat:=-1
						End case 
						If ($repeat>0)
							For each ($name; $line.objectsForm)
								$properties:=$line.objectsForm[$name]
								$even:=(($repeat%2)=0)
								Case of 
									: ($properties._fillEven#Null:C1517) & ($even)
										$properties.fill:=$properties._fillEven
									: ($properties._fillOdd#Null:C1517) & (Not:C34($even))
										$properties.fill:=$properties._fillOdd
								End case 
								Case of 
									: ($properties._strokeEven#Null:C1517) & ($even)
										$properties.stroke:=$properties._strokeEven
									: ($properties._strokeOdd#Null:C1517) & (Not:C34($even))
										$properties.stroke:=$properties._strokeOdd
								End case 
							End for each 
						End if 
					End for each 
					
					//MARK:-place the objects in page for common lines
					$verticalOffsetPx:=$margin_topPx
					For each ($line; $linesToDraw)
						For each ($name; $line.objectsForm)
							$properties:=OB Copy:C1225($line.objectsForm[$name])
							$properties.top:=(($properties.top+$verticalOffsetPx)*($zoom/100)*$coef)+$paper_offset_top
							$properties.left:=($properties.left*($zoom/100)*$coef)+$paper_offset_left
							$properties.width:=$properties.width*($zoom/100)*$coef
							$properties.height:=$properties.height*($zoom/100)*$coef
							If ($properties.fontSize#Null:C1517)
								$properties.fontSize:=$properties.fontSize*($zoom/100)*$coefPolice
							End if 
							If ($properties.strokeWidth#Null:C1517)
								$properties.strokeWidth:=$properties.strokeWidth*($zoom/100)*$coef
							End if 
							$formDefinition.pages[1].objects[$name]:=$properties
							
						End for each 
						$verticalOffsetPx:=$verticalOffsetPx+$line.heightPx
					End for each 
					
					//MARK:-place the objects in page for footer
					$verticalOffsetPx:=$pageHeightPx-$margin_bottomPx
					For each ($line; $footersToDraw)
						For each ($name; $line.objectsForm)
							$properties:=OB Copy:C1225($line.objectsForm[$name])
							$properties.top:=(($properties.top+$verticalOffsetPx-$line.heightPx)*($zoom/100)*$coef)+$paper_offset_top
							$properties.left:=($properties.left*($zoom/100)*$coef)+$paper_offset_left
							$properties.width:=$properties.width*($zoom/100)*$coef
							$properties.height:=$properties.height*($zoom/100)*$coef
							If ($properties.fontSize#Null:C1517)
								$properties.fontSize:=$properties.fontSize*($zoom/100)*$coefPolice
							End if 
							If ($properties.strokeWidth#Null:C1517)
								$properties.strokeWidth:=$properties.strokeWidth*($zoom/100)*$coef
							End if 
							$formDefinition.pages[1].objects[$name]:=$properties
							
						End for each 
						$verticalOffsetPx:=$verticalOffsetPx-$line.heightPx
					End for each 
					
					
					Case of 
						: ($destination="--print")
							
							//MARK:-place the objects in background
							$verticalOffsetPx:=$margin_topPx
							For each ($line; $bkgdsToDraw)
								For each ($name; $line.objectsForm)
									$properties:=OB Copy:C1225($line.objectsForm[$name])
									$properties.top:=(($properties.top+$verticalOffsetPx)*($zoom/100)*$coef)+$paper_offset_top
									$properties.left:=($properties.left*($zoom/100)*$coef)+$paper_offset_left
									$properties.width:=$properties.width*($zoom/100)*$coef
									$properties.height:=$properties.height*($zoom/100)*$coef
									If ($properties.fontSize#Null:C1517)
										$properties.fontSize:=$properties.fontSize*($zoom/100)*$coefPolice
									End if 
									If ($properties.strokeWidth#Null:C1517)
										$properties.strokeWidth:=$properties.strokeWidth*($zoom/100)*$coef
									End if 
									$formDefinition.pages[0].objects[$name]:=$properties
									
								End for each 
								$verticalOffsetPx:=$verticalOffsetPx+$line.heightPx
							End for each 
							
							$height:=Print form:C5($formDefinition)
							If ($context.pageToPrint<$pageToPrintMax)
								PAGE BREAK:C6(>)
							Else 
								PAGE BREAK:C6
							End if 
						: ($destination="--pdf")
							
							//MARK:-place the objects in background
							$verticalOffsetPx:=$margin_topPx
							For each ($line; $bkgdsToDraw)
								For each ($name; $line.objectsForm)
									$properties:=OB Copy:C1225($line.objectsForm[$name])
									$properties.top:=(($properties.top+$verticalOffsetPx)*($zoom/100)*$coef)+$paper_offset_top
									$properties.left:=($properties.left*($zoom/100)*$coef)+$paper_offset_left
									$properties.width:=$properties.width*($zoom/100)*$coef
									$properties.height:=$properties.height*($zoom/100)*$coef
									If ($properties.fontSize#Null:C1517)
										$properties.fontSize:=$properties.fontSize*($zoom/100)*$coefPolice
									End if 
									If ($properties.strokeWidth#Null:C1517)
										$properties.strokeWidth:=$properties.strokeWidth*($zoom/100)*$coef
									End if 
									$formDefinition.pages[0].objects[$name]:=$properties
									
								End for each 
								$verticalOffsetPx:=$verticalOffsetPx+$line.heightPx
							End for each 
							
							$height:=Print form:C5($formDefinition)
							If ($context.pageToPrint<$pageToPrintMax)
								PAGE BREAK:C6(>)
							Else 
								PAGE BREAK:C6
							End if 
							
						: ($destination="--subform")
							
							$paperWidth:=$pageWidthPx*($zoom/100)*$coef
							$paperHeight:=$pageHeightPx*($zoom/100)*$coef
							
							$properties:=New object:C1471
							$properties.type:="rectangle"
							$properties.top:=$paper_offset_top
							$properties.left:=$paper_offset_left
							$properties.width:=$paperWidth
							$properties.height:=$paperHeight
							$properties.fill:="white"
							$properties.stroke:="white"
							$formDefinition.pages[0].objects.paper:=$properties
							
							If ($context.rulers=1)
								
								$properties:=New object:C1471
								$properties.type:="rectangle"
								$properties.top:=$paper_offset_top+($margin_topPx*(Num:C11($context.zoom)/100)*$coef)
								$properties.left:=$paper_offset_left+($margin_leftPx*(Num:C11($context.zoom)/100)*$coef)
								$properties.width:=$paperWidth-(($margin_leftPx+$margin_rightPx)*(Num:C11($context.zoom)/100)*$coef)
								$properties.height:=$paperHeight-(($margin_topPx+$margin_bottomPx)*(Num:C11($context.zoom)/100)*$coef)
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
								$verticalOffsetPx:=$margin_topPx
								For each ($line; $linesToDraw)
									$i:=$i+1
									$name:="lineInRulers"+String:C10($i)
									$properties:=New object:C1471
									$properties.type:="rectangle"
									$properties.top:=(($line.topPx+$verticalOffsetPx)*($zoom/100)*$coef)+$paper_offset_top
									$properties.left:=0
									$properties.width:=($rulersSize/2)*($zoom/100)*$coef
									$properties.height:=($line.heightPx)*($zoom/100)*$coef
									$properties.fill:=$line.rulerColor
									$properties.stroke:="black"
									$properties.strokeWidth:=0.1*($zoom/100)*$coef
									$formDefinition.pages[0].objects[$name]:=$properties
									
									If ($zoom>=100)
										$name:="lineInRulersPicto"+String:C10($i)
										$properties:=New object:C1471
										$properties.type:="picture"
										$properties.top:=(($line.topPx+$verticalOffsetPx)*($zoom/100)*$coef)+$paper_offset_top+(2*($zoom/100)*$coef)
										$properties.left:=2*($zoom/100)*$coef
										$properties.width:=(($rulersSize/2)*($zoom/100)*$coef)-($properties.left*2)
										$properties.height:=$properties.width
										$properties.picture:=cs:C1710.dfd_panel_template.me.typology_get_iconPath_byCode($line.typology)
										$properties.pictureFormat:="scaled"
										$formDefinition.pages[0].objects[$name]:=$properties
									End if 
									
									$name:="bLineInRulers"+String:C10($i)+"_"+String:C10($line.numInColl)
									$properties:=New object:C1471
									$properties.type:="button"
									$properties.top:=(($line.topPx+$verticalOffsetPx)*($zoom/100)*$coef)+$paper_offset_top
									$properties.left:=0
									$properties.width:=($rulersSize/2)*($zoom/100)*$coef
									$properties.height:=($line.heightPx)*($zoom/100)*$coef
									$properties.events:=New collection:C1472("onClick")
									$properties.style:="custom"
									$properties.focusable:=False:C215
									$properties.tooltip:=$line.rulerTooltip+"\r"+String:C10($line.topPx+$verticalOffsetPx)+" px\r"+String:C10($line.topPx+$verticalOffsetPx+$line.bottomPx)+" px\r"+cs:C1710.dfd_panel_template.me.typology_get_name_byCode($line.typology)
									
									$properties.method:="Document_manage_lineInRulers"
									$formDefinition.pages[0].objects[$name]:=$properties
									
									$verticalOffsetPx:=$verticalOffsetPx+$line.heightPx
									
								End for each 
								
								$verticalOffsetPx:=$pageHeightPx-$margin_bottomPx
								For each ($line; $footersToDraw)
									$i:=$i+1
									$name:="lineInRulers"+String:C10($i)
									$properties:=New object:C1471
									$properties.type:="rectangle"
									$properties.top:=(($line.topPx+$verticalOffsetPx-$line.heightPx)*($zoom/100)*$coef)+$paper_offset_top
									$properties.left:=0
									$properties.width:=($rulersSize/2)*($zoom/100)*$coef
									$properties.height:=($line.heightPx)*($zoom/100)*$coef
									$properties.fill:=$line.rulerColor
									$properties.stroke:="black"
									$properties.strokeWidth:=0.1*($zoom/100)*$coef
									$formDefinition.pages[0].objects[$name]:=$properties
									
									If ($zoom>=100)
										$name:="lineInRulersPicto"+String:C10($i)
										$properties:=New object:C1471
										$properties.type:="picture"
										$properties.top:=(($line.topPx+$verticalOffsetPx-$line.heightPx)*($zoom/100)*$coef)+$paper_offset_top+(2*($zoom/100)*$coef)
										$properties.left:=2*($zoom/100)*$coef
										$properties.width:=(($rulersSize/2)*($zoom/100)*$coef)-($properties.left*2)
										$properties.height:=$properties.width
										$properties.picture:=cs:C1710.dfd_panel_template.me.typology_get_iconPath_byCode($line.typology)
										$properties.pictureFormat:="scaled"
										$formDefinition.pages[0].objects[$name]:=$properties
									End if 
									
									$name:="bLineInRulers"+String:C10($i)+"_"+String:C10($line.numInColl)
									$properties:=OB Copy:C1225($properties)
									$properties.type:="button"
									$properties.events:=New collection:C1472("onClick")
									$properties.style:="custom"
									$properties.focusable:=False:C215
									$properties.tooltip:=$line.rulerTooltip+"\r"+String:C10($line.topPx+$verticalOffsetPx)+" px\r"+String:C10($line.topPx+$verticalOffsetPx+$line.bottomPx)+" px"
									$properties.method:="Document_manage_lineInRulers"
									$formDefinition.pages[0].objects[$name]:=$properties
									
									$verticalOffsetPx:=$verticalOffsetPx-$line.heightPx
									
								End for each 
								
							End if 
							
							
							//MARK:-place the objects in background
							$verticalOffsetPx:=$margin_topPx
							For each ($line; $bkgdsToDraw)
								For each ($name; $line.objectsForm)
									$properties:=OB Copy:C1225($line.objectsForm[$name])
									$properties.top:=(($properties.top+$verticalOffsetPx)*($zoom/100)*$coef)+$paper_offset_top
									$properties.left:=($properties.left*($zoom/100)*$coef)+$paper_offset_left
									$properties.width:=$properties.width*($zoom/100)*$coef
									$properties.height:=$properties.height*($zoom/100)*$coef
									If ($properties.fontSize#Null:C1517)
										$properties.fontSize:=$properties.fontSize*($zoom/100)*$coefPolice
									End if 
									If ($properties.strokeWidth#Null:C1517)
										$properties.strokeWidth:=$properties.strokeWidth*($zoom/100)*$coef
									End if 
									$formDefinition.pages[0].objects[$name]:=$properties
									
								End for each 
								$verticalOffsetPx:=$verticalOffsetPx+$line.heightPx
							End for each 
							
							Form:C1466.preview:=New object:C1471
							OBJECT SET SUBFORM:C1138(*; "preview"; $formDefinition)
							$context.formDefinition:=$formDefinition
					End case 
				End for 
				
			End if 
			
		Else 
			Case of 
				: ($destination="--subform")
					$context.ddPage:=New object:C1471
					$context.ddPage.values:=New collection:C1472
					$context.ddPage.index:=0
					$formDefinition:=JSON Parse:C1218($json)
					Form:C1466.preview:=New object:C1471
					OBJECT SET SUBFORM:C1138(*; "preview"; $formDefinition)
					
			End case 
			
		End if 
	End if   // $continue
	
	// MARK:-
	If ($currentPrinter#"")
		SET CURRENT PRINTER:C787($currentPrinter)
		SET PRINT OPTION:C733(Destination option:K47:7; 1)
	End if 
	
	
Function redraw_buttons()
	//Form.current_item.UUID:=Form.current_item.UUID
	
Function tool_display_ValueType($value : Variant)->$text : Text
	var $type : Integer
	
	$type:=Value type:C1509($value)
	Case of 
		: ($type=Is real:K8:4)
			$text:="real"
		: ($type=Is integer:K8:5)
			$text:="integer"
		: ($type=Is text:K8:3)
			$text:="text"
		: ($type=Is boolean:K8:9)
			$text:="boolean"
		: ($type=Is date:K8:7)
			$text:="date"
		: ($type=Is time:K8:8)
			$text:="time"
		: ($type=Is collection:K8:32)
			$text:="collection ("+String:C10($value.length)+")"
			
		: ($type=Is undefined:K8:13)
			$text:="undefined"
		Else 
			$text:="??"+String:C10($type)
	End case 
	
Function valuate_tag($tag : Text; $this : Variant; $collectionSource : Text)->$valueToDisplay : Variant
	
	If ($this#Null:C1517)
		
		$tagParts:=Split string:C1554($tag; ".")
		If ($tagParts.length>1)
			$thisTag:=$tagParts.shift()
			$lastAttribute:=$tagParts.pop()
			$position:=Position:C15("["; $thisTag)
			If ($position>0)
				$elementString:=Substring:C12($thisTag; $position)
				$thisTag:=Substring:C12($thisTag; 1; $position-1)
				$thisColl:=$this[$thisTag]
				If ($elementString#"") && ($elementString="[@") && ($elementString="@]") && (Value type:C1509($thisColl)=Is collection:K8:32)
					$elementPosition:=Num:C11(Substring:C12($elementString; 2; Length:C16($elementString)-2))
					If ($elementPosition>=0) & ($elementPosition<$thisColl.length)
						$this:=$thisColl[$elementPosition]
					End if 
				Else 
					$this:=Null:C1517
				End if 
			Else 
				$this:=($thisTag="this") ? $this : $this[$thisTag]
			End if 
			
			For each ($attribut; $tagParts)
				$elementString:=""
				$position:=Position:C15("["; $attribut)
				If ($position>0)
					$elementString:=Substring:C12($attribut; $position)
					$attribut:=Substring:C12($attribut; 1; $position-1)
				End if 
				$this:=($attribut="this") ? $this[String:C10($collectionSource)] : $this[$attribut]
				If ($elementString#"") && ($elementString="[@") && ($elementString="@]") && (Value type:C1509($this)=Is collection:K8:32)
					$elementPosition:=Num:C11(Substring:C12($elementString; 2; Length:C16($elementString)-2))
					If ($elementPosition>=0) & ($elementPosition<$this.length)
						$this:=$this[$elementPosition]
					End if 
				End if 
			End for each 
			
			$valueToDisplay:=$this[$lastAttribute]
		Else 
			$valueToDisplay:=$this[$tag]
		End if 
		
	Else 
		$valueToDisplay:=""
	End if 
	
Function valuate_sysTag($valueToTreat : Text; $context : Object; $properties : Object)->$valueToDisplay : Text
	
	$valueToDisplay:=$valueToTreat
	$pStart:=1
	Repeat 
		$pStart:=Position:C15("#!"; $valueToTreat; $pStart; *)
		If ($pStart>0)
			$pEnd:=Position:C15("!#"; $valueToTreat; $pStart+2; *)
			If ($pEnd>0)
				$tag:=Substring:C12($valueToTreat; $pStart+2; $pEnd-$pStart-2)
				$pStart:=$pEnd+2
				Case of 
					: ($tag="page")
						$valueToDisplay:=Replace string:C233($valueToDisplay; "#!"+$tag+"!#"; String:C10($context.pageToPrint))
					: ($tag="nbPages")
						$valueToDisplay:=Replace string:C233($valueToDisplay; "#!"+$tag+"!#"; String:C10($context.nbOfPages))
					: ($tag="currentDate")
						$valueToDisplay:=Replace string:C233($valueToDisplay; "#!"+$tag+"!#"; This:C1470.tool_format_date($context.currentDate; String:C10($properties.dateFormat)))
					: ($tag="currentTime")
						$valueToDisplay:=Replace string:C233($valueToDisplay; "#!"+$tag+"!#"; This:C1470.tool_format_time(Time:C179($context.currentTime); String:C10($properties.timeFormat)))
				End case 
			Else 
				$pStart:=$pStart+2
			End if 
		End if 
	Until ($pStart=0)
	
Function tool_display_asMoney($valueToDisplay : Variant; $money : Text)->$textToDisplay : Text
	Case of 
		: ($money="euro")
			$textToDisplay:=String:C10(Num:C11($valueToDisplay); "###,###,###,###.00 €")
		: ($money="dollar")
			$textToDisplay:=String:C10(Num:C11($valueToDisplay); "$ ###,###,###,###.00")
		Else 
			$textToDisplay:=String:C10(Num:C11($valueToDisplay))
	End case 
	
Function tool_format_string($valueToDisplay : Variant; $format : Text)->$textToDisplay : Text
	var $carFormatNum : Integer
	var $carValueNum : Integer
	
	$textToDisplay:=""
	$carValueNum:=0
	For ($carFormatNum; 1; Length:C16($format))
		Case of 
			: ($format[[$carFormatNum]]="#")
				$carValueNum+=1
				$textToDisplay+=Substring:C12(String:C10($valueToDisplay); $carValueNum; 1)
			Else 
				$textToDisplay+=$format[[$carFormatNum]]
		End case 
	End for 
	
	
Function tool_format_date($date : Variant; $format : Text)->$textToDisplay
	$dateToDisplay:=Date:C102($date)
	Case of 
		: ($format="systemLong")
			$textToDisplay:=String:C10($dateToDisplay; System date long:K1:3)
		: ($format="systemShort")
			$textToDisplay:=String:C10($dateToDisplay; System date short:K1:1)
		: ($format="systemMedium")
			$textToDisplay:=String:C10($dateToDisplay; System date abbreviated:K1:2)
		: ($format="short")
			$textToDisplay:=String:C10($dateToDisplay; Internal date short special:K1:4)
		: ($format="shortCentury")
			$textToDisplay:=String:C10($dateToDisplay; Internal date short:K1:7)
		: ($format="abbreviated")
			$textToDisplay:=String:C10($dateToDisplay; Internal date abbreviated:K1:6)
		: ($format="iso8601")
			$textToDisplay:=String:C10($dateToDisplay; ISO date GMT:K1:10)
		: ($format="rfc822")
			$textToDisplay:=String:C10($dateToDisplay; ISO date:K1:8)
		Else 
			If ($format="blankIfNull")
				$textToDisplay:=($dateToDisplay#!00-00-00!) ? String:C10($dateToDisplay) : ""
			Else 
				$textToDisplay:=String:C10($dateToDisplay)
			End if 
	End case 
	
Function tool_format_time($time : Variant; $format : Text)->$textToDisplay
	var $timeToDisplay : Time
	If (Value type:C1509($time)=Is time:K8:8)
		$timeToDisplay:=$time
	Else 
		$timeToDisplay:=Time:C179($time)
	End if 
	Case of 
		: ($format="systemLong")
			$textToDisplay:=String:C10($timeToDisplay; System time long:K7:11)
		: ($format="systemShort")
			$textToDisplay:=String:C10($timeToDisplay; System time short:K7:9)
		: ($format="systemMedium")
			$textToDisplay:=String:C10($timeToDisplay; System time long abbreviated:K7:10)
		: ($format="HH_MM_SS")
			$textToDisplay:=String:C10($timeToDisplay; HH MM SS:K7:1)
		: ($format="HH_MM")
			$textToDisplay:=String:C10($timeToDisplay; HH MM:K7:2)
		: ($format="MM_SS")
			$textToDisplay:=String:C10($timeToDisplay; MM SS:K7:6)
		: ($format="iso8601")
			$textToDisplay:=String:C10($timeToDisplay; ISO time:K7:8)
		: ($format="hh_mm_ss")
			$textToDisplay:=String:C10($timeToDisplay; Hour min sec:K7:3)
		: ($format="hh_mm")
			$textToDisplay:=String:C10($timeToDisplay; Hour min:K7:4)
		: ($format="mm_ss")
			$textToDisplay:=String:C10($timeToDisplay; Min sec:K7:7)
		Else 
			If ($format="blankIfNull")
				$textToDisplay:=($timeToDisplay#?00:00:00?) ? String:C10($timeToDisplay) : ""
			Else 
				$textToDisplay:=String:C10($timeToDisplay)
			End if 
	End case 
	
	
Function treat_IFcondition($expression : Text; $this : Object; $variableItems : Object)->$textToDisplay : Text
	var $expressionIF : Text
	var $expressionIFparts : Collection
	var $valueToTreat : Variant
	
	If ($expression="IF(@)")
		$expressionIF:=Substring:C12($expression; 4; Length:C16($expression)-4)
		$expressionIFpartsToStudy:=Split string:C1554($expressionIF; ";")
		$expressionIF:=$expressionIFpartsToStudy.shift()
		$expressionIFparts:=New collection:C1472
		$partsToJoin:=New collection:C1472()
		$imbrication:=0
		For each ($part; $expressionIFpartsToStudy)
			Case of 
				: ($part="IF(@")
					$partsToJoin.push($part)
					$imbrication+=1
				: ($part="@)") && (Length:C16(Replace string:C233($part; ")"; ""))<Length:C16(Replace string:C233($part; "("; "")))
					$partsToJoin.push($part)
					$imbrication-=1
					If ($imbrication=0)
						$expressionIFparts.push($partsToJoin.join(";"))
						$partsToJoin:=New collection:C1472()
					End if 
				Else 
					$partsToJoin.push($part)
					If ($imbrication=0)
						$expressionIFparts.push($partsToJoin.join(";"))
						$partsToJoin:=New collection:C1472()
					End if 
			End case 
		End for each 
		If ($imbrication=0)
			$expressionIF:=Replace string:C233($expressionIF; "$data"; "$1")
			$valueToTreat:=Formula from string:C1601($expressionIF).call($this; $variableItems)
			If (Bool:C1537($valueToTreat))
				$textToDisplay:=(($expressionIFparts.length>0) && ($expressionIFparts[0]#Null:C1517)) ? (This:C1470.treat_IFcondition($expressionIFparts[0]; $this)) : "True"
			Else 
				$textToDisplay:=(($expressionIFparts.length>1) && ($expressionIFparts[1]#Null:C1517)) ? (This:C1470.treat_IFcondition($expressionIFparts[1]; $this)) : "False"
			End if 
			If ($textToDisplay="\"@\"")
				$textToDisplay:=Substring:C12($textToDisplay; 2; Length:C16($textToDisplay)-2)
			End if 
		Else 
			$textToDisplay:="IF error"
		End if 
	Else 
		$textToDisplay:=$expression
	End if 
	
	If ($textToDisplay="ƒ(@")
		$formula:=Formula from string:C1601(Substring:C12($textToDisplay; 3; Length:C16($textToDisplay)-3))
		$textToDisplay:=$formula.call($this; String:C10($textToDisplay))
	End if 
	
	
	
Function lb_settings()
	Case of 
		: (Form:C1466.sfw.checkIsntInModification())
			
		: (FORM Event:C1606.code=On Drag Over:K2:13)
			
			$class:=OB Class:C1730(<>DFD_dragdrop.template)
			Case of 
				: ($class.name="dfd_TemplateEntity") & (Form:C1466.current_item#Null:C1517)
					
				Else 
					$0:=-1
			End case 
			
		: (FORM Event:C1606.code=On Drop:K2:12)
			
			$class:=OB Class:C1730(<>DFD_dragdrop.template)
			If ($class.name="DFD_templateEntity")
				If (Form:C1466.current_item.template#Null:C1517) && (Form:C1466.current_item.UUID_Template#<>DFD_dragdrop.template.UUID)
					CONFIRM:C162(Localized string:C991("document.define.drop.prompt"); Localized string:C991("document.define.drop.ok"); Localized string:C991("document.define.drop.ko"))
					$ok:=ok
				Else 
					$ok:=1
				End if 
				If ($ok=1)
					Form:C1466.current_item_toSave:=Form:C1466.current_item
					
					Form:C1466.template:=<>DFD_dragdrop.template
					Form:C1466.current_item.UUID_Template:=Form:C1466.template.UUID
					
					This:C1470.redraw_all()
					This:C1470.activate_saveCancel()
					
					BRING TO FRONT:C326(Current process:C322)
				End if 
			End if 
			
			
		: (FORM Event:C1606.code=On Clicked:K2:4) && (Right click:C712 | Contextual click:C713) & (Form:C1466.line#Null:C1517)
			
		: (FORM Event:C1606.code=On Double Clicked:K2:5) && (Form:C1466.setting#Null:C1517)
			
			If (Form:C1466.setting.name#Null:C1517) & (Form:C1466.setting.name="Modèle")
				$ref:=Open form window:C675("Template_dialog"; Plain form window:K39:10; Horizontally centered:K39:1; Vertically centered:K39:4)
				DIALOG:C40("Template_dialog"; New object:C1471("choosenTemplate"; Form:C1466.setting.value))
				CLOSE WINDOW:C154($ref)
			End if 
	End case 
	
	
Function bAction()
	var $edfd_Template : cs:C1710.dfd_TemplateEntity
	
	If (Form:C1466.sfw.checkIsInModification())
		
		$refMenus:=New collection:C1472
		$refMenu:=Create menu:C408
		$refMenus.push($refMenu)
		
		For each ($edfd_Template; ds:C1482.dfd_Template.all().orderBy("name"))
			APPEND MENU ITEM:C411($refMenu; $edfd_Template.name; *)
			SET MENU ITEM PARAMETER:C1004($refMenu; -1; $edfd_Template.UUID)
			If (Form:C1466.current_item.UUID_dfd_Template=$edfd_Template.UUID)
				SET MENU ITEM MARK:C208($refMenu; -1; Char:C90(18))
				If (Is Windows:C1573)
					SET MENU ITEM STYLE:C425($refMenu; -1; Bold:K14:2)
				End if 
			End if 
			If (Form:C1466.sfw.checkIsInModification()=False:C215)
				DISABLE MENU ITEM:C150($refMenu; -1)
			End if 
		End for each 
		$choose:=Dynamic pop up menu:C1006($refMenu)
		For each ($refMenu; $refMenus)
			RELEASE MENU:C978($refMenu)
		End for each 
		
		Case of 
			: ($choose#"")
				Form:C1466.current_item.UUID_dfd_Template:=$choose
				This:C1470.activate_saveCancel()
				This:C1470.redraw_all()
				
		End case 
		
		
	End if 
	
Function activate_saveCancel()
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
	
	
Function column_proprety_value()
	
	$0:=0
	Case of 
		: (Form:C1466.sfw.checkIsntInModification())
			
		: (FORM Event:C1606.code=On Before Data Entry:K2:39) && (Form:C1466.setting#Null:C1517) && (Bool:C1537(Form:C1466.setting.notEditable))
			$0:=-1
			
			
		: (FORM Event:C1606.code=On Before Data Entry:K2:39) && (Form:C1466.current_item#Null:C1517) && (Form:C1466.setting#Null:C1517)
			$0:=0
			
		: (FORM Event:C1606.code=On Data Change:K2:15)
			Form:C1466.current_item.moreData.settings[Form:C1466.setting.name]:=Form:C1466.setting.value
			This:C1470.activate_saveCancel()
			This:C1470.redraw_preview()
	End case 
	
Function column_variable_type()
	Case of 
		: (Form:C1466.sfw.checkIsntInModification())
			
		: (FORM Event:C1606.code=On Clicked:K2:4) & (Right click:C712 | Contextual click:C713)
			
			If (Form:C1466.variable#Null:C1517) && (Form:C1466.variable.value#Null:C1517) && (Form:C1466.variable.type#"collection@")
				
				$refMenu:=Create menu:C408()
				
				APPEND MENU ITEM:C411($refMenu; Localized string:C991("tool.convert.text"); *)  //"Convertir en texte"
				If (Form:C1466.position_variable>0)
					ENABLE MENU ITEM:C149($refMenu; -1)
				Else 
					DISABLE MENU ITEM:C150($refMenu; -1)
				End if 
				SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--asText")
				
				APPEND MENU ITEM:C411($refMenu; Localized string:C991("tool.convert.real"); *)  //"Convertir en réel"
				If (Form:C1466.position_variable>0)
					ENABLE MENU ITEM:C149($refMenu; -1)
				Else 
					DISABLE MENU ITEM:C150($refMenu; -1)
				End if 
				SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--asReal")
				
				APPEND MENU ITEM:C411($refMenu; Localized string:C991("tool.convert.date"); *)  //"Convertir en date"
				If (Form:C1466.position_variable>0)
					ENABLE MENU ITEM:C149($refMenu; -1)
				Else 
					DISABLE MENU ITEM:C150($refMenu; -1)
				End if 
				SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--asDate")
				
				
				APPEND MENU ITEM:C411($refMenu; Localized string:C991("tool.convert.boolean"); *)  // "Convertir en booléen"
				If (Form:C1466.position_variable>0)
					ENABLE MENU ITEM:C149($refMenu; -1)
				Else 
					DISABLE MENU ITEM:C150($refMenu; -1)
				End if 
				SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--asBool")
				
				
				
				$choose:=Dynamic pop up menu:C1006($refMenu)
				RELEASE MENU:C978($refMenu)
				
				Case of 
					: ($choose="--asBool")
						Form:C1466.variable.value:=Bool:C1537(Form:C1466.variable.value)
					: ($choose="--asText")
						Form:C1466.variable.value:=String:C10(Form:C1466.variable.value)
					: ($choose="--asDate")
						Form:C1466.variable.value:=Date:C102(Form:C1466.variable.value)
					: ($choose="--asReal")
						Form:C1466.variable.value:=Num:C11(Form:C1466.variable.value)
						
						
				End case 
				If ($choose#"")
					Form:C1466.variable.type:=This:C1470.tool_display_ValueType(Form:C1466.variable.value)
					Form:C1466.current_item.variableItems[Form:C1466.variable.name]:=Form:C1466.variable.value
					This:C1470.activate_saveCancel()
				End if 
			End if 
			
	End case 
	
Function column_variable_value()
	var $picture : Picture
	var $blob : Blob
	
	Case of 
		: (Form:C1466.sfw.checkIsntInModification())
			
		: (FORM Event:C1606.code=On Data Change:K2:15)
			
			If (String:C10(Form:C1466.variable.kind)="collection")
				Form:C1466.current_item.variableItems[Form:C1466.variable.name]:=JSON Parse:C1218(Form:C1466.variable.value)
			Else 
				Form:C1466.current_item.variableItems[Form:C1466.variable.name]:=Form:C1466.variable.value
			End if 
			
			
			This:C1470.redraw_preview()
			This:C1470.activate_saveCancel()
			
		: (FORM Event:C1606.code=On Clicked:K2:4) & (Right click:C712 | Contextual click:C713)
			
			If (Form:C1466.variable#Null:C1517)
				
				$isText:=(Value type:C1509(Form:C1466.variable.value)=Is text:K8:3)
				$isCollection:=$isText || (String:C10(Form:C1466.variable.kind)="collection")
				
				GET PICTURE FROM PASTEBOARD:C522($picture)
				
				$refMenu:=Create menu:C408()
				Case of 
					: ($isCollection)
						APPEND MENU ITEM:C411($refMenu; Localized string:C991("tool.edit.collection"); *)  //"Editer la collection"
						If (Form:C1466.position_variable>0)
							ENABLE MENU ITEM:C149($refMenu; -1)
						Else 
							DISABLE MENU ITEM:C150($refMenu; -1)
						End if 
						SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--editCollection")
						
					: ($isText)
						APPEND MENU ITEM:C411($refMenu; Localized string:C991("tool.edit.text"); *)  //"Editer le texte"
						If (Form:C1466.position_variable>0)
							ENABLE MENU ITEM:C149($refMenu; -1)
						Else 
							DISABLE MENU ITEM:C150($refMenu; -1)
						End if 
						SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--editText")
				End case 
				
				APPEND MENU ITEM:C411($refMenu; "-")
				APPEND MENU ITEM:C411($refMenu; Localized string:C991("tool.paste.picture"); *)  //"Coller l'image"
				If (Picture size:C356($picture)>0) && (String:C10(Form:C1466.variable.kind)#"collection")
					ENABLE MENU ITEM:C149($refMenu; -1)
				Else 
					DISABLE MENU ITEM:C150($refMenu; -1)
				End if 
				SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--pastePicture")
				
				$choose:=Dynamic pop up menu:C1006($refMenu)
				RELEASE MENU:C978($refMenu)
				
				Case of 
					: ($choose="--editCollection")
						
						var $collSource : Collection
						$collSource:=New collection:C1472()
						If (Form:C1466.variable.value#Null:C1517) && (Form:C1466.variable.value#"")
							$collSource:=JSON Parse:C1218(Form:C1466.variable.value)
						End if 
						$winRef:=Open form window:C675("dfd_collection_editor"; Sheet form window:K39:12)
						$form:=New object:C1471("elements"; $collSource)
						DIALOG:C40("dfd_collection_editor"; $form)
						CLOSE WINDOW:C154($winRef)
						
						If (ok=1)
							Form:C1466.variable.value:=JSON Stringify:C1217($form.elements)
							Form:C1466.current_item.variableItems[Form:C1466.variable.name]:=$form.elements
							This:C1470.redraw_preview()
							This:C1470.activate_saveCancel()
						End if 
						
						
					: ($choose="--editText")
						$winRef:=Open form window:C675("Text_editor"; Sheet form window:K39:12)
						$form:=New object:C1471("text"; Form:C1466.variable.value)
						DIALOG:C40("Text_editor"; $form)
						CLOSE WINDOW:C154($winRef)
						If (ok=1)
							Form:C1466.variable.value:=$form.text
							Form:C1466.current_item.variableItems[Form:C1466.variable.name]:=Form:C1466.variable.value
							This:C1470.redraw_preview()
							This:C1470.activate_saveCancel()
						End if 
						
					: ($choose="--pastePicture")
						PICTURE TO BLOB:C692($picture; $blob; ".png")
						BASE64 ENCODE:C895($blob; $base64)
						Form:C1466.variable.value:=$base64
						Form:C1466.variable.kind:="picture64"
						Form:C1466.current_item.variableItems[Form:C1466.variable.name]:=Form:C1466.variable.value
						This:C1470.redraw_preview()
						This:C1470.activate_saveCancel()
						
				End case 
				
			End if 
	End case 
	
	
Function ddPage()
	This:C1470.redraw_preview()
	
	
Function ruler()
	This:C1470.redraw_preview()
	
Function bPrint()
	$preview:=Form:C1466.current_item.moreData.settings.printPreview
	Form:C1466.current_item.moreData.settings.printPreview:=(Shift down:C543) ? $preview : "True"
	This:C1470.redraw_preview(Form:C1466; "--print")
	Form:C1466.current_item.moreData.settings.printPreview:=$preview
	
	
Function bPDF()
	This:C1470.redraw_preview(Form:C1466; "--pdf")
	
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
				This:C1470.activate_saveCancel()
			End if 
		End if 
		
		This:C1470.redraw_preview()
	End if 
	
Function bPortrait
	If (Form:C1466.sfw.checkIsInModification())
		If (Form:C1466.current_item.moreData.settings.orientation#"portrait")
			Form:C1466.current_item.moreData.settings.orientation:="portrait"
			This:C1470.redraw_lb_settings()
			This:C1470.activate_saveCancel()
		End if 
		This:C1470.redraw_preview()
	End if 
	
Function bLandscape
	If (Form:C1466.sfw.checkIsInModification())
		If (Form:C1466.current_item.moreData.settings.orientation#"landscape")
			Form:C1466.current_item.moreData.settings.orientation:="landscape"
			This:C1470.redraw_lb_settings()
			This:C1470.activate_saveCancel()
		End if 
		This:C1470.redraw_preview()
	End if 