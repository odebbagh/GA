// Class to export data to excel using one template

property templatePath : Text
property mapping : Collection:=New collection:C1472()
property area : Text
property entitySelection
property fileName : Text
property destinationFolderPath : Text
property autoQuit : Boolean
property title : Text
property sheetName : Text
property destinationFileName : Text
property showFooter : Boolean

Class constructor($templatePath : Text; $mapping : Collection; $entitySelection; $destinationFileName : Text; $destinationFolderPath : Text; $title : Text; $sheetName : Text; $showFooter : Boolean)
	This:C1470.templatePath:=$templatePath
	This:C1470.mapping:=$mapping
	This:C1470.entitySelection:=$entitySelection
	This:C1470.destinationFileName:=$destinationFileName
	This:C1470.autoQuit:=False:C215
	This:C1470.destinationFolderPath:=$destinationFolderPath
	This:C1470.title:=$title
	This:C1470.sheetName:=$sheetName
	This:C1470.showFooter:=$showFooter
	
	// This function will be called on each event of the offscreen area 
Function onEvent()
	Case of 
		: (FORM Event:C1606.code=On VP Ready:K2:59)
			
			$o:=New object:C1471()
			
			$excelOptions:={includeStyles: False:C215; includeFormulas: True:C214; openMode: ""}
			$o.excelOptions:=$excelOptions
			//$o.formula:=Formula(SET TIMER(1))
			VP IMPORT DOCUMENT(This:C1470.area; This:C1470.templatePath; $o)  // make an asynch callback
			
			//: (Form event code=On Timer)
			
			//SET TIMER(0)
			
			
		$row:=1
		$col:=0
		
		//Title (only if non-empty)
		If (This:C1470.title#"")
			
			$style:=New object:C1471
			$style.font:="14pt Arial bold"
			$style.borderBottom:=New object:C1471("color"; "black"; "style"; vk line style thin:K89:39)
			
			VP SET CELL STYLE(VP Cells(This:C1470.area; 0; $row; This:C1470.mapping.length; 1); $style)
			VP SET ROW ATTRIBUTES(VP Row(This:C1470.area; $row); New object:C1471("height"; 35))
			VP SET TEXT VALUE(VP Cell(This:C1470.area; $col; $row); This:C1470.title)
			VP Combine ranges(VP Cells(This:C1470.area; 0; $row; 2; 1); VP Cells(This:C1470.area; 3; $row; This:C1470.mapping.length; 1))
			
			$row:=2
			
		End if 
		
		$col:=0
		
		//Headers
		For each ($header; This:C1470.mapping.extract("header"))
			VP SET TEXT VALUE(VP Cell(This:C1470.area; $col; $row); $header)
			$col:=$col+1
		End for each 
		
		$columnCount:=$col
		
		$style:=New object:C1471
		$style.font:="bold Arial"
		$style.backColor:="#FFFF00"
		
		VP SET CELL STYLE(VP Cells(This:C1470.area; 0; $row; $col; 1); $style)
		VP SET ROW ATTRIBUTES(VP Row(This:C1470.area; $row); New object:C1471("height"; 30))
		
		$row:=$row+1
		$col:=0
		
		$colomnWith:=This:C1470.mapping.extract("header").map(Formula:C1597(Length:C16($1.value)))
		
		// Pre-initialize footer values
		$footerValues:=New collection:C1472()
		For ($j; 0; This:C1470.mapping.length-1)
			If (This:C1470.mapping[$j].footerOperation="sum")
				$footerValues[$j]:=0
			Else 
				$footerValues[$j]:=This:C1470.mapping[$j].footerOperation
			End if 
		End for 
		
		//Data
		For each ($entity; This:C1470.entitySelection)
			
			For each ($field; This:C1470.mapping.extract("field"))
				
				Case of 
						
					: ($field="")
						
					: (String:C10($entity[$field])="False") | (String:C10($entity[$field])="True")  //Boolean fields
						
						$content:=$entity[$field]=False:C215 ? "N" : "Y"
						VP SET TEXT VALUE(VP Cell(This:C1470.area; $col; $row); $content)
						
					Else 
						
						var $content : Variant
						
						$linksFields:=Split string:C1554($field; "."; sk ignore empty strings:K86:1+sk trim spaces:K86:2)
						
						$content:=$entity[String:C10($linksFields[0])]
						
						For ($i; 1; $linksFields.length-1)
							$content:=String:C10($content[String:C10($linksFields[$i])])
							If ($content=Null:C1517)
								$content:=""
								break
							End if 
							
						End for 
						
						If (This:C1470.mapping.extract("footerOperation")[$col]="sum")
							$footerValues[$col]:=Num:C11($footerValues[$col])+Num:C11($content)
						End if 
						
						//Fill the columns width collection
						If (Length:C16(String:C10($content))>$colomnWith[$col])
							$colomnWith[$col]:=Length:C16(String:C10($content))
						End if 
						
						If (String:C10($content)="False") | (String:C10($content)="True")
							$content:=$content=False:C215 ? "N" : "Y"
						End if 
						
						VP SET VALUE(VP Cell(This:C1470.area; $col; $row); New object:C1471("value"; $content))
						
				End case 
				
				$col:=$col+1
			End for each 
			$row:=$row+1
			$col:=0
			VP INSERT ROWS(VP Row(This:C1470.area; $row; 1))
		End for each 
		
		//Footer (only if requested)
		If (This:C1470.showFooter)
			
			For each ($value; $footerValues)
				VP SET VALUE(VP Cell(This:C1470.area; $col; $row); New object:C1471("value"; $value))
				$col:=$col+1
			End for each 
			
			$style:=New object:C1471
			$style.font:="bold underline"
			$style.backColor:="#D3D3D3"
			$style.borderTop:=New object:C1471("color"; "black"; "style"; vk line style thin:K89:39)
			
			VP SET CELL STYLE(VP Cells(This:C1470.area; 0; $row; $columnCount; 1); $style)
			
		End if 
			
			//Columns With
			For ($i; 0; $colomnWith.length-1)
				$size:=$colomnWith[$i]*10>500 ? 500 : $colomnWith[$i]*10
				VP SET COLUMN ATTRIBUTES(VP Column(This:C1470.area; $i); New object:C1471("width"; $size))
			End for 
			
			//Set Sheet Name
			VP SET SHEET NAME(This:C1470.area; This:C1470.sheetName; 0)
			
			//Export the content
			$file:=Folder:C1567(Convert path system to POSIX:C1106(This:C1470.destinationFolderPath)).file(This:C1470.destinationFileName)
			
			If (Not:C34($file.exists))
				$file.create()
			End if 
			
			var $params:={}
			$params.format:=vk MS Excel format:K89:2
			$params.formula:=Formula:C1597(ACCEPT:C269)
			$excelOptions:={includeStyles: True:C214; includeFormulas: True:C214}
			$params.excelOptions:=$excelOptions
			VP EXPORT DOCUMENT(This:C1470.area; $file.platformPath; $params)
			
			OPEN URL:C673($file.platformPath; *)
			
	End case 
	
	
	
	
	
	
	
	
	
	