Class extends sfw_chart_twoAxis  // qui étend elle-même de la classe chart

Class constructor
	
	Super:C1705()
	
	
Function drawGraph()->$picture : Picture
	
	This:C1470.xAxis.y:=This:C1470.areaSize.height-50
	This:C1470.xAxis.widthStep:=This:C1470.areaSize.graphWidth/This:C1470._series.length
	
	This:C1470.refSvg:=SVG_New(This:C1470.areaSize.width; This:C1470.areaSize.height)
	This:C1470._drawOrdinateAxis()
	This:C1470._drawAbscissaAxis()
	This:C1470._drawTitle()
	
	$colors:=This:C1470._loadShades()
	$xLine:=This:C1470.areaSize.graphRight+This:C1470.gutter
	
	$i:=0
	For each ($key; This:C1470._yValuesKeys)
		This:C1470._drawPolyline(This:C1470._series.extract($key); $colors[$i])
		
		If (This:C1470.legend.labels#Null:C1517)
			//  Legend
			This:C1470.legend.labels[$key].color:=$colors[$i]
			// new Line
			$yLine:=This:C1470.areaSize.graphTop+(This:C1470.gutter*($i+1))
			$refline:=SVG_New_line(This:C1470.refSvg; $xLine; $yLine; $xLine+20; $yLine; $colors[$i])
			
			SVG_New_text(This:C1470.refSvg; This:C1470.legend.labels[$key].name; $xLine+20+This:C1470.gutter; $yLine-8; This:C1470.font.family; 12)
		End if 
		$i+=1
	End for each 
	
	If (This:C1470.averageLine)
		$average:=This:C1470._series.average("yValue")
		If (This:C1470.yAxis.logarithmic)
			If ($average=0)
				$height:=0
			Else 
				$height:=Log:C22($average)/Log:C22(10)*This:C1470.yAxis.heightStep
				If ($height=0)
					$height:=5
				End if 
			End if 
			$averageY:=This:C1470.areaSize.graphBottom-$height
		Else 
			$averageY:=(This:C1470.areaSize.graphBottom-((This:C1470.areaSize.graphHeight)*($average/(This:C1470.yAxis.unitMax*This:C1470.yAxis.unitVal))))
		End if 
		$averageValue:=cs:C1710[This:C1470.yAxis.classNumber].new($average).getBestFormat()
		$refline:=SVG_New_line(This:C1470.refSvg; This:C1470.areaSize.graphLeft; $averageY; This:C1470.areaSize.graphRight; $averageY; "blue"; 2)
		$refTexte:=SVG_New_text(This:C1470.refSvg; $averageValue; This:C1470.areaSize.graphLeft-10; $averageY-6; This:C1470.font.family; This:C1470.font.size; Plain:K14:1; Align right:K42:4; "blue")
		
		$totalYValues:=This:C1470._series.sum("yValue")
		$nbUsefullValues:=This:C1470._series.length-This:C1470._series.countValues(0; "yValue")
		If ($nbUsefullValues#0) & ($average#0)
			$relativeAverage:=$totalYValues/$nbUsefullValues
			If (($average/$relativeAverage)<0.9)
				If (This:C1470.yAxis.logarithmic)
					If ($relativeAverage=0)
						$height:=0
					Else 
						$height:=Log:C22($relativeAverage)/Log:C22(10)*This:C1470.yAxis.heightStep
						If ($height=0)
							$height:=5
						End if 
					End if 
					$relativeAverageY:=This:C1470.areaSize.graphBottom-$height
				Else 
					$relativeAverageY:=(This:C1470.xAxis.y-((This:C1470.xAxis.y-This:C1470.areaSize.graphTop)*($relativeAverage/(This:C1470.yAxis.unitMax*This:C1470.yAxis.unitVal))))
				End if 
				$relativeAverageValue:=cs:C1710[This:C1470.yAxis.classNumber].new($relativeAverage).getBestFormat()
				$refline:=SVG_New_line(This:C1470.refSvg; This:C1470.areaSize.graphLeft; $relativeAverageY; This:C1470.areaSize.graphRight; $relativeAverageY; "green"; 2)
				$refTexte:=SVG_New_text(This:C1470.refSvg; $relativeAverageValue; This:C1470.areaSize.graphLeft-10; $relativeAverageY-6; This:C1470.font.family; This:C1470.font.size; Plain:K14:1; Align right:K42:4; "green")
				
			End if 
		End if 
	End if 
	
	
	$picture:=SVG_Export_to_picture(This:C1470.refSvg)
	SVG_CLEAR(This:C1470.refSvg)
	
	OB REMOVE:C1226(This:C1470; "refSvg")
	
	
Function _drawPolyline($values : Collection; $color : Text)
	ARRAY REAL:C219($_x; $values.length)
	ARRAY REAL:C219($_y; $values.length)
	For ($i; 1; $values.length; 1)
		$_x{$i}:=This:C1470.yAxis.x+(($i-1)*This:C1470.xAxis.widthStep)+(This:C1470.xAxis.widthStep*This:C1470.valuexOffset)
		If (This:C1470.yAxis.logarithmic)
			$yvalue:=$values[$i-1].yValue
			If ($yvalue=0)
				$height:=0
			Else 
				$height:=Log:C22($yvalue)/Log:C22(10)*This:C1470.yAxis.heightStep
				If ($height=0)
					$height:=5
				End if 
			End if 
			$_y{$i}:=This:C1470.areaSize.graphBottom-$height
		Else 
			$_y{$i}:=This:C1470.areaSize.graphBottom-($values[$i-1]/This:C1470.yAxis.heightStep)
		End if 
	End for 
	
	$crayon:=1
	
	$objectRef:=SVG_New_polyline_by_arrays(This:C1470.refSvg; ->$_x; ->$_y; $color; "none"; $crayon)
	