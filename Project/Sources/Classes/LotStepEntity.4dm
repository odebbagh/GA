Class extends Entity


local Function beforeSave()
	If (This:C1470.lot#Null:C1517)
		This:C1470.lot.save()
	End if 
	
local Function get approvalDate()->$approvalDate : Date
	If (This:C1470.stmpApproval=0)
		$approvalDate:=!00-00-00!
	Else 
		$approvalDate:=cs:C1710.sfw_stmp.me.getDate(This:C1470.stmpApproval; True:C214)
	End if 
local Function set approvalDate($approvalDate : Date)
	If ($approvalDate=!00-00-00!)
		This:C1470.stmpApproval:=0
	Else 
		This:C1470.stmpApproval:=cs:C1710.sfw_stmp.me.build($approvalDate)
	End if 
	
local Function get nameInWindowTitle()->$nameInWindowTitle : Text
	// With this callback you return the name to displayed in the title of the window for the current item
	$nameInWindowTitle:=String:C10(This:C1470.lot.number)+" - "+String:C10(This:C1470.order)
	
local Function afterCreation()
	This:C1470._initTools()
	This:C1470._initParametricMeasurements()
	This:C1470._initStepInterruptions()
	This:C1470._initDataTables()
	This:C1470._initBins()
	This:C1470._initSkills()
	This:C1470._initRequiredCertifications()
	
local Function itemLoad()
	//This._initTools()
	//This._initParametricMeasurements()
	//This._initStepInterruptions()
	//This._initDataTables()
	//This._initBins()
	//This._initSkills()
	//This._initRequiredCertifications()
	
local Function _initTools
	If (Form:C1466.currentStep.tools=Null:C1517)
		Form:C1466.currentStep.tools:=New object:C1471("items"; New collection:C1472())
	End if 
	
local Function _initParametricMeasurements
	If (Form:C1466.currentStep.parametricMeasurements=Null:C1517)
		Form:C1466.currentStep.parametricMeasurements:=New object:C1471("items"; New collection:C1472())
	End if 
	
local Function _initStepInterruptions
	If (Form:C1466.currentStep.stepInterruptions=Null:C1517)
		Form:C1466.currentStep.stepInterruptions:=New object:C1471("items"; New collection:C1472())
	End if 
	
local Function _initDataTables
	If (Form:C1466.currentStep.dataTables=Null:C1517)
		Form:C1466.currentStep.dataTables:=New object:C1471("items"; New collection:C1472())
	End if 
	
local Function _initBins
	If (Form:C1466.currentStep.bins=Null:C1517)
		Form:C1466.currentStep.bins:=New object:C1471("items"; New collection:C1472())
	End if 
	
local Function _initSkills
	If (Form:C1466.currentStep.skills=Null:C1517)
		Form:C1466.currentStep.skills:=New object:C1471("items"; New collection:C1472())
	End if 
	
local Function _initRequiredCertifications
	If (Form:C1466.currentStep.requitedCertifications=Null:C1517)
		Form:C1466.currentStep.requitedCertifications:=New object:C1471("items"; New collection:C1472())
	End if 
	
local Function getSpecificationControl()->$spectificationControl : Text
	
	var $item : Object
	var $spec : Text
	var $revision : Text
	var $parts : Collection
	var $specificationEntity : cs:C1710.SpecificationEntity
	
	$spectificationControl:=""
	$parts:=New collection:C1472()
	
	If (This:C1470.specificationControl#Null:C1517) && (This:C1470.specificationControl.items#Null:C1517) && (This:C1470.specificationControl.items.length>0)
		For each ($item; This:C1470.specificationControl.items)
			$spec:=String:C10($item.spec)
			If ($spec#"")
				$revision:=String:C10($item.revision)
				If ($revision="") && ($item.UUID_Specification#Null:C1517)
					$specificationEntity:=ds:C1482.Specification.get($item.UUID_Specification)
					If ($specificationEntity#Null:C1517)
						$revision:=String:C10($specificationEntity.revision)
					End if 
				End if 
				If ($revision#"")
					$parts.push($spec+" ("+$revision+")")
				Else 
					$parts.push($spec)
				End if 
			End if 
		End for each 
		If ($parts.length>0)
			$spectificationControl:=$parts.join(", ")
		End if 
	End if 
	
local Function isCurrentStep()->$isCurrentStep : Boolean
	
	$isCurrentStep:=(This:C1470.order=This:C1470.lot.lotSteps.query("qtyOut = 0 AND dateOut = :1"; !00-00-00!).orderBy("order asc").first().order)
	
local Function getPossibleActions()->$possibleActions : Collection
	
	$possibleActions:=New collection:C1472()
	
	If (This:C1470.isCurrentStep()) & ((This:C1470.qtyIn=0) | (This:C1470.dateIn=!00-00-00!))
		$possibleActions.push("Punch In")
	End if 
	
	If (This:C1470.isCurrentStep()) & ((This:C1470.qtyOut=0) | (This:C1470.dateOut=!00-00-00!)) & ((This:C1470.qtyIn#0) & (This:C1470.dateIn#!00-00-00!))
		$possibleActions.push("Punch Out")
	End if 
	
Function get specDisplay()->$text : Text
	$text:=This:C1470.getSpecificationControl()
	
Function get rowMeta()->$meta : Object
	If (This:C1470.qtyOut=0) && (This:C1470.dateOut=!00-00-00!) && (This:C1470.order=This:C1470.lot.lotSteps.query("qtyOut = 0 AND dateOut = :1"; !00-00-00!).orderBy("order asc").first().order)
		$meta:=New object:C1471("fill"; "#90EE90")
	Else 
		$meta:=New object:C1471()
	End if 

Function ensureDataTable()->$dataTable : Object
	
	var $key : Text
	
	$dataTable:=This:C1470.dataTable
	If ($dataTable#Null:C1517) && (Not:C34(OB Is empty:C1297($dataTable)))
		return $dataTable
	End if 
	If (This:C1470.step#Null:C1517) && (This:C1470.step.stepTemplate#Null:C1517) && (This:C1470.step.stepTemplate.dataTables#Null:C1517) && (This:C1470.step.stepTemplate.dataTables.items#Null:C1517) && (This:C1470.step.stepTemplate.dataTables.items.length>0)
		$dataTable:=New object:C1471()
		For each ($dtCol; This:C1470.step.stepTemplate.dataTables.items.orderBy("order asc"))
			$key:=String:C10($dtCol.key)
			If ($key="")
				$key:=String:C10($dtCol.name)
			End if 
			If ($key#"")
				$dataTable[$key]:=New collection:C1472()
			End if 
		End for each 
		If (OB Keys:C1719($dataTable).length>0)
			This:C1470.dataTable:=$dataTable
			return $dataTable
		End if 
	End if 
	$dataTable:=Null:C1517
	
Function getDataTableColumnKeys()->$headers : Collection
	
	var $dataTable : Object
	var $key : Text
	
	$headers:=New collection:C1472()
	$dataTable:=This:C1470.ensureDataTable()
	If ($dataTable=Null:C1517)
		return $headers
	End if 
	If (This:C1470.step#Null:C1517) && (This:C1470.step.stepTemplate#Null:C1517) && (This:C1470.step.stepTemplate.dataTables#Null:C1517) && (This:C1470.step.stepTemplate.dataTables.items#Null:C1517) && (This:C1470.step.stepTemplate.dataTables.items.length>0)
		For each ($dtCol; This:C1470.step.stepTemplate.dataTables.items.orderBy("order asc"))
			$key:=String:C10($dtCol.key)
			If ($key="")
				$key:=String:C10($dtCol.name)
			End if 
			If ($key#"") && ($dataTable[$key]#Null:C1517)
				$headers.push($key)
			End if 
		End for each 
	Else 
		$headers:=OB Keys:C1719($dataTable)
	End if 
	
Function buildDataTableList($includeHeaderInRows : Boolean)->$list : Object
	
	var $dataTable : Object
	var $fieldName; $header : Text
	var $headers : Collection
	var $i; $j; $colCount; $nbRows : Integer
	var $row; $headerRow : Object
	var $rows; $allRows : Collection
	var $stepDef : cs:C1710.StepEntity
	var $stepTemplate : cs:C1710.StepTemplateEntity
	var $templateItems : Collection
	
	$list:=New object:C1471(\
"hasTable"; False:C215; \
"colCount"; 0; \
"hdr1"; ""; "hdr2"; ""; "hdr3"; ""; "hdr4"; ""; "hdr5"; ""; \
"visibleCol1"; False:C215; "visibleCol2"; False:C215; "visibleCol3"; False:C215; "visibleCol4"; False:C215; "visibleCol5"; False:C215; \
"rows"; New collection:C1472()\
)
	
	$stepTemplate:=Null:C1517
	$templateItems:=New collection:C1472()
	
	If (This:C1470.step#Null:C1517)
		$stepTemplate:=This:C1470.step.stepTemplate
	Else 
		If (String:C10(This:C1470.UUID_Step)#"")
			$stepDef:=ds:C1482.Step.get(This:C1470.UUID_Step)
			If ($stepDef#Null:C1517)
				$stepTemplate:=$stepDef.stepTemplate
				If ($stepTemplate=Null:C1517) && (String:C10($stepDef.UUID_StepTemplate)#"")
					$stepTemplate:=ds:C1482.StepTemplate.get($stepDef.UUID_StepTemplate)
				End if 
			End if 
		End if 
	End if 
	
	If ($stepTemplate=Null:C1517) || ($stepTemplate.dataTables=Null:C1517)
		return $list
	End if 
	
	If ($stepTemplate.dataTables.items=Null:C1517) || ($stepTemplate.dataTables.items.length=0)
		return $list
	End if 
	
	$templateItems:=$stepTemplate.dataTables.items
	
	If ($templateItems.length=0)
		return $list
	End if 
	
	var $dtCol : Object
	var $key : Text
	
	$headers:=New collection:C1472()
	For each ($dtCol; $templateItems.orderBy("order asc"))
		$key:=String:C10($dtCol.key)
		If ($key="")
			$key:=String:C10($dtCol.name)
		End if 
		If ($key#"")
			$headers.push($key)
		End if 
	End for each 
	
	If ($headers.length=0)
		return $list
	End if 
	
	$dataTable:=This:C1470.dataTable
	
	$list.hasTable:=True:C214
	$colCount:=$headers.length
	If ($colCount>5)
		$colCount:=5
	End if 
	$list.colCount:=$colCount
	
	var $pageContentW; $scale; $dtAreaLeft; $divDetailsLeft; $dtAreaW; $colW : Integer
	var $partRowCount; $partBlockHeight; $rowIdx : Integer
	var $allRow : Object
	
	// Keep in sync with __seed_planLotTraveller — partTableLeft = divDetailsLeft (gray panel right edge)
	$pageContentW:=812
	$scale:=$pageContentW/1000
	$divDetailsLeft:=Round:C94(318*$scale; 0)
	$dtAreaLeft:=$divDetailsLeft
	$dtAreaW:=$pageContentW-$dtAreaLeft
	$colW:=Round:C94($dtAreaW/$colCount; 0)
	
	For ($j; 1; 5)
		If ($j<=$colCount)
			$list["visibleCol"+String:C10($j)]:=True:C214
			$list["colLeft"+String:C10($j)]:=$dtAreaLeft+(($j-1)*$colW)
			If ($j=$colCount)
				$list["colWidth"+String:C10($j)]:=$pageContentW-$list["colLeft"+String:C10($j)]
			Else 
				$list["colWidth"+String:C10($j)]:=$colW
			End if 
			$list["colTextLeft"+String:C10($j)]:=Num:C11($list["colLeft"+String:C10($j)])+2
			$list["colTextWidth"+String:C10($j)]:=Num:C11($list["colWidth"+String:C10($j)])-4
		Else 
			$list["visibleCol"+String:C10($j)]:=False:C215
			$list["colLeft"+String:C10($j)]:=0
			$list["colWidth"+String:C10($j)]:=0
			$list["colTextLeft"+String:C10($j)]:=0
			$list["colTextWidth"+String:C10($j)]:=0
		End if 
	End for 
	
	For ($j; 1; $colCount)
		$list["hdr"+String:C10($j)]:=String:C10($headers[$j-1])
	End for 
	
	$rows:=New collection:C1472()
	$nbRows:=0
	If ($dataTable#Null:C1517) && ($dataTable[$headers[0]]#Null:C1517)
		$nbRows:=$dataTable[$headers[0]].length
	End if 
	
	For ($i; 0; $nbRows-1)
		$row:=New object:C1471("isHeader"; False:C215)
		For ($j; 1; 5)
			If ($j<=$colCount)
				$header:=$headers[$j-1]
				$row["col_"+String:C10($j)]:=String:C10($dataTable[$header][$i])
				$row["visibleCol"+String:C10($j)]:=True:C214
				$row["headerCell"+String:C10($j)]:=False:C215
			Else 
				$row["visibleCol"+String:C10($j)]:=False:C215
				$row["headerCell"+String:C10($j)]:=False:C215
			End if 
			$row["colLeft"+String:C10($j)]:=$list["colLeft"+String:C10($j)]
			$row["colWidth"+String:C10($j)]:=$list["colWidth"+String:C10($j)]
			$row["colTextLeft"+String:C10($j)]:=$list["colTextLeft"+String:C10($j)]
			$row["colTextWidth"+String:C10($j)]:=$list["colTextWidth"+String:C10($j)]
		End for 
		$rows.push($row)
	End for 
	
	If ($includeHeaderInRows)
		$headerRow:=New object:C1471("isHeader"; True:C214)
		For ($j; 1; 5)
			If ($j<=$colCount)
				$headerRow["col_"+String:C10($j)]:=String:C10($headers[$j-1])
				$headerRow["visibleCol"+String:C10($j)]:=True:C214
				$headerRow["headerCell"+String:C10($j)]:=True:C214
			Else 
				$headerRow["visibleCol"+String:C10($j)]:=False:C215
				$headerRow["headerCell"+String:C10($j)]:=False:C215
			End if 
			$headerRow["colLeft"+String:C10($j)]:=$list["colLeft"+String:C10($j)]
			$headerRow["colWidth"+String:C10($j)]:=$list["colWidth"+String:C10($j)]
			$headerRow["colTextLeft"+String:C10($j)]:=$list["colTextLeft"+String:C10($j)]
			$headerRow["colTextWidth"+String:C10($j)]:=$list["colTextWidth"+String:C10($j)]
		End for 
		$allRows:=New collection:C1472($headerRow)
		$allRows:=$allRows.combine($rows)
		$list.rows:=$allRows
	Else 
		$list.rows:=$rows
	End if 
	
	$partRowCount:=$list.rows.length
	$partBlockHeight:=$partRowCount*14
	$rowIdx:=0
	For each ($allRow; $list.rows)
		$rowIdx:=$rowIdx+1
		$allRow.partRowIndex:=$rowIdx
		$allRow.partRowCount:=$partRowCount
		$allRow.partTableLeft:=$dtAreaLeft
		$allRow.partColCount:=$colCount
		For ($j; 1; 5)
			If ($allRow["visibleCol"+String:C10($j)]#Null:C1517)
				$allRow["showCol"+String:C10($j)]:=Bool:C1537($allRow["visibleCol"+String:C10($j)])
			End if 
		End for 
	End for each 
	
	$list.partTableLeft:=$dtAreaLeft
	$list.partColCount:=$colCount
	
	$list.colCount:=$colCount
	