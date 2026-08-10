Class extends sfw_chart


property yAxis : Object
property xAxis : Object
property averageLine : Boolean
property valuexOffset : Integer

property _series : Collection
property _yValuesKeys : Collection
property _nbSeries : Integer

Class constructor
	
	Super:C1705()
	
	This:C1470.yAxis:=New object:C1471
	This:C1470.yAxis.unitModulo:=1000
	This:C1470.yAxis.coefficents:=New collection:C1472(""; "K"; "M"; "G"; "T")
	This:C1470.yAxis.classNumber:="number"
	This:C1470.yAxis.coeffMargingMax:=1.05
	This:C1470.yAxis.logarithmic:=False:C215
	This:C1470.yAxis.nbDecades:=5
	
	This:C1470.xAxis:=New object:C1471
	This:C1470.xAxis.y:=50
	This:C1470.xAxis.timePeriod:=""
	This:C1470.xAxis.lineTimePeriod:=""
	This:C1470.averageLine:=False:C215
	This:C1470.xAxis.rotationLabel:=300
	This:C1470.xAxis.coeffOffsetLabel:=0.8
	This:C1470.xAxis.alignLabel:=Align right:K42:4
	
	This:C1470.valuexOffset:=0
	This:C1470.setAreaSize(500; 500)
	
Function set values($data : Collection)
	
	This:C1470._series:=$data
	This:C1470._yValuesKeys:=OB Entries:C1720(This:C1470._series[0]).query("key = :1"; "yValue@").distinct("key")
	This:C1470._nbSeries:=This:C1470._yValuesKeys.length
	
Function _loadShades()->$colors : Collection
	
	$max:=This:C1470._yValuesKeys.length
	$colors:=Split string:C1554("red;green;gold;orange;blue;pink;saddiebrown"; ";")
	$nb:=($max\$colors.length)+1
	For ($i; 2; $nb)
		$colors:=$colors.combine($colors)
	End for 
	
Function _drawOrdinateAxis
	
	This:C1470.yAxis.x:=This:C1470.areaSize.graphLeft
	
	This:C1470.yAxis.max:=0
	For each ($key; This:C1470._yValuesKeys)
		$max:=This:C1470._series.max($key)
		This:C1470.yAxis.max:=This:C1470.yAxis.max>$max ? This:C1470.yAxis.max : $max
	End for each 
	
	If (This:C1470.yAxis.logarithmic)
		$maxLenghtOrdinateLabel:=0
		For ($d; 0; This:C1470.yAxis.nbDecades)
			If (Length:C16(String:C10(10^$d))>$maxLenghtOrdinateLabel)
				$maxLenghtOrdinateLabel:=Length:C16(String:C10(10^$d))
			End if 
		End for 
		This:C1470.areaSize.graphLeft:=This:C1470.areaSize.graphLeft+(2*$maxLenghtOrdinateLabel)
		This:C1470.yAxis.x:=This:C1470.areaSize.graphLeft
		
		This:C1470.yAxis.nbDecades:=Int:C8(Log:C22(This:C1470.yAxis.max)/Log:C22(10))+1
		
		This:C1470.yAxis.heightStep:=This:C1470.areaSize.graphHeight/This:C1470.yAxis.nbDecades
		$xLeft:=This:C1470.areaSize.graphLeft
		$xRight:=This:C1470.areaSize.graphRight
		For ($d; 0; This:C1470.yAxis.nbDecades)
			$yLine:=This:C1470.areaSize.graphBottom-($d*This:C1470.yAxis.heightStep)
			$refAxe:=SVG_New_line(This:C1470.refSvg; $xLeft-5; $yLine; $xRight; $yLine; "navy"; 1)
			$refText:=SVG_New_text(This:C1470.refSvg; String:C10(10^$d); $xLeft-7; $yLine-5; This:C1470.legend.font; This:C1470.legend.size; Plain:K14:1; Align right:K42:4)
			For ($sd; 2; 9)
				$yLine:=This:C1470.areaSize.graphBottom-(Log:C22($sd*(10^$d))/Log:C22(10)*This:C1470.yAxis.heightStep)
				$refAxe:=SVG_New_line(This:C1470.refSvg; $xLeft; $yLine; $xRight; $yLine; "lightgrey"; 1)
			End for 
		End for 
		
		$x:=This:C1470.areaSize.graphLeft
		$yTop:=This:C1470.areaSize.graphTop
		$yBottom:=This:C1470.areaSize.graphBottom
		$refAxe:=SVG_New_line(This:C1470.refSvg; $x; $yTop; $x; $yBottom; "black"; 1)
		$top:=This:C1470.areaSize.graphTop
	Else 
		
		This:C1470.yAxis.unitMax:=This:C1470.yAxis.max*This:C1470.yAxis.coeffMargingMax
		This:C1470.yAxis.unitName:=This:C1470.yAxis.coefficents[0]
		This:C1470.yAxis.unitVal:=1
		If (This:C1470.yAxis.unitMax>(This:C1470.yAxis.unitModulo-1))
			This:C1470.yAxis.unitMax:=This:C1470.yAxis.unitMax/This:C1470.yAxis.unitModulo
			This:C1470.yAxis.unitName:=This:C1470.yAxis.coefficents[1]
			This:C1470.yAxis.unitVal:=This:C1470.yAxis.unitModulo
		End if 
		If (This:C1470.yAxis.unitMax>(This:C1470.yAxis.unitModulo-1))
			This:C1470.yAxis.unitMax:=This:C1470.yAxis.unitMax/This:C1470.yAxis.unitModulo
			This:C1470.yAxis.unitName:=This:C1470.yAxis.coefficents[2]
			This:C1470.yAxis.unitVal:=This:C1470.yAxis.unitModulo*This:C1470.yAxis.unitModulo
		End if 
		If (This:C1470.yAxis.unitMax>(This:C1470.yAxis.unitModulo-1))
			This:C1470.yAxis.unitMax:=This:C1470.yAxis.unitMax/This:C1470.yAxis.unitModulo
			This:C1470.yAxis.unitName:=This:C1470.yAxis.coefficents[3]
			This:C1470.yAxis.unitVal:=This:C1470.yAxis.unitModulo*This:C1470.yAxis.unitModulo*This:C1470.yAxis.unitModulo
		End if 
		This:C1470.yAxis.unitMax:=Round:C94(This:C1470.yAxis.unitMax; 2)
		
		This:C1470.yAxis.heightStep:=This:C1470.yAxis.max/This:C1470.areaSize.graphHeight
		
		
		$collMax:=New collection:C1472(1000; 750; 500; 250; 200; 100; 75; 50; 20; 10; 5; 2; 1)
		$graduationStep:=0
		For each ($val; $collMax) Until ($graduationStep>0)
			If (This:C1470.yAxis.unitMax>$val)
				$graduationStep:=$val/10
			End if 
		End for each 
		
		$i:=$graduationStep
		$maxLenghtOrdinateLabel:=0
		Repeat 
			$ySize:=String:C10($i)+" "+This:C1470.yAxis.unitName
			If (Length:C16($ySize)>$maxLenghtOrdinateLabel)
				$maxLenghtOrdinateLabel:=Length:C16($ySize)
			End if 
			$i:=$i+$graduationStep
		Until ($i>This:C1470.yAxis.unitMax)
		This:C1470.areaSize.graphLeft:=This:C1470.areaSize.graphLeft+(2*$maxLenghtOrdinateLabel)
		This:C1470.yAxis.x:=This:C1470.areaSize.graphLeft
		
		$i:=$graduationStep
		$nbLine:=0
		Repeat 
			//$yGraduation:=(This.xAxis.y-((This.xAxis.y-This.areaSize.graphTop)*(This.yAxis.unitVal*$i/(This.yAxis.unitMax*This.yAxis.unitVal))))
			$nbLine+=1
			$yGraduation:=This:C1470.areaSize.graphBottom-((This:C1470.yAxis.unitVal*$i)/This:C1470.yAxis.heightStep)
			$refline:=SVG_New_line(This:C1470.refSvg; This:C1470.areaSize.graphLeft-5; $yGraduation; This:C1470.areaSize.graphRight; $yGraduation; "lightgrey")
			$ySize:=String:C10($i)+" "+This:C1470.yAxis.unitName
			$refTexte:=SVG_New_text(This:C1470.refSvg; $ySize; This:C1470.areaSize.graphLeft-10; $yGraduation-6; This:C1470.font.family; This:C1470.font.size; Plain:K14:1; Align right:K42:4; "grey")
			$i:=$i+$graduationStep
		Until ($i>This:C1470.yAxis.unitMax)
		$top1:=This:C1470.areaSize.graphBottom-((This:C1470.yAxis.unitVal*$nbLine*$graduationStep)/This:C1470.yAxis.heightStep)-3
		$top2:=This:C1470.areaSize.graphTop
		$top:=($top1<$top2) ? $top1 : $top2
	End if 
	
	//$refline:=SVG_New_line(This.refSvg; This.yAxis.x; This.xAxis.y; This.yAxis.x; This.areaSize.graphTop; "grey")
	$refline:=SVG_New_line(This:C1470.refSvg; This:C1470.yAxis.x; This:C1470.xAxis.y; This:C1470.yAxis.x; $top; "grey")
	
Function _drawAbscissaAxis
	
	This:C1470.xAxis.moduloLegend:=Int:C8(40/This:C1470.xAxis.widthStep)
	If (This:C1470.xAxis.moduloLegend=0)
		This:C1470.xAxis.moduloLegend:=1
	End if 
	
	Case of 
		: (This:C1470.xAxis.timePeriod#"") & (This:C1470.xAxis.timePeriod#"automatic")
			$xtimeModulo:=1
			$collxtime:=Split string:C1554(This:C1470.xAxis.timePeriod; " ")
			Case of 
				: ($collxtime[1]="minute@")
					$xtimeModulo:=Num:C11($collxtime[0])*60
				: ($collxtime[1]="hour@")
					$xtimeModulo:=Num:C11($collxtime[0])*60*60
				Else 
					$xtimeModulo:=Num:C11($collxtime[0])
			End case 
			
			$xlineTimeModulo:=0
			$collxtime:=Split string:C1554(This:C1470.xAxis.lineTimePeriod; " ")
			Case of 
				: ($collxtime[0]="none@")
				: ($collxtime[1]="minute@")
					$xlineTimeModulo:=Num:C11($collxtime[0])*60
				: ($collxtime[1]="hour@")
					$xlineTimeModulo:=Num:C11($collxtime[0])*60*60
				Else 
					$xlineTimeModulo:=Num:C11($collxtime[0])
			End case 
			
			
			For ($i; 1; This:C1470._series.length; 1)
				$mainGraduation:=False:C215
				If (This:C1470._series[$i-1].xValue%$xtimeModulo=0)
					$refline:=SVG_New_line(This:C1470.refSvg; This:C1470.yAxis.x+($i*This:C1470.xAxis.widthStep); This:C1470.xAxis.y; This:C1470.yAxis.x+($i*This:C1470.xAxis.widthStep); This:C1470.xAxis.y+5; "grey")
					$label:=This:C1470._series[$i-1].xLabel
					$x:=This:C1470.yAxis.x+(($i-1)*This:C1470.xAxis.widthStep)-2+6
					$y:=This:C1470.xAxis.y+7
					$refTexte:=SVG_New_text(This:C1470.refSvg; $label; $x; $y; This:C1470.font.family; This:C1470.font.size; Plain:K14:1; Align left:K42:2; "grey"; 90)
					$mainGraduation:=True:C214
				End if 
				If ($xlineTimeModulo#0)
					If (This:C1470._series[$i-1].xValue%$xlineTimeModulo=0)
						If ($mainGraduation)
							$color:="grey:75"
						Else 
							$color:="lightgrey:75"
						End if 
						$refline:=SVG_New_line(This:C1470.refSvg; This:C1470.yAxis.x+($i*This:C1470.xAxis.widthStep); This:C1470.areaSize.graphTop; This:C1470.yAxis.x+($i*This:C1470.xAxis.widthStep); This:C1470.areaSize.graphBottom; $color)
						
					End if 
				End if 
			End for 
			
		Else 
			For ($i; 1; This:C1470._series.length; 1)
				If ($i%This:C1470.xAxis.moduloLegend=0)
					$refline:=SVG_New_line(This:C1470.refSvg; This:C1470.yAxis.x+($i*This:C1470.xAxis.widthStep); This:C1470.xAxis.y; This:C1470.yAxis.x+($i*This:C1470.xAxis.widthStep); This:C1470.xAxis.y+5; "grey")
					$label:=This:C1470._series[$i-1].xLabel
					$refTexte:=SVG_New_text(This:C1470.refSvg; $label; This:C1470.yAxis.x+(($i-1)*This:C1470.xAxis.widthStep)+(This:C1470.xAxis.widthStep*This:C1470.xAxis.coeffOffsetLabel); This:C1470.xAxis.y+5; This:C1470.font.family; This:C1470.font.size; Plain:K14:1; This:C1470.xAxis.alignLabel; "grey"; This:C1470.xAxis.rotationLabel)
				End if 
			End for 
	End case 
	
	$refline:=SVG_New_line(This:C1470.refSvg; This:C1470.yAxis.x; This:C1470.xAxis.y; This:C1470.yAxis.x+This:C1470.areaSize.graphWidth; This:C1470.xAxis.y; "grey")
	