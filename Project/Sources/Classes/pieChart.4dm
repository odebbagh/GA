Class constructor
	
	This:C1470.margin:=New object:C1471
	This:C1470.margin.left:=10
	This:C1470.margin.top:=10
	This:C1470.margin.right:=10
	This:C1470.margin.bottom:=10
	This:C1470.gutter:=70
	This:C1470.areaSize:=New object:C1471
	This:C1470.title:=""
	This:C1470.subtitle:=""
	This:C1470.useGradient:=False:C215
	This:C1470.lightEffect:=True:C214
	This:C1470.squareSize:=15
	This:C1470.offsetShadow:=5
	
	This:C1470.setAreaSize(500; 500)
	This:C1470.shades:=This:C1470._fillShades()
	
	
	
Function setAreaSize($width : Integer; $height : Integer)
	
	This:C1470.areaSize.width:=$width
	This:C1470.areaSize.height:=$height
	
	This:C1470.areaSize.graphWidth:=This:C1470.areaSize.width-This:C1470.margin.left-This:C1470.margin.right
	This:C1470.areaSize.graphHeight:=This:C1470.areaSize.height-This:C1470.margin.top-This:C1470.margin.bottom-This:C1470.offsetShadow
	
	
Function _fillShades
	
	var $shades : Collection
	
	$shades:=New collection:C1472
	$shades.push("Navy")
	$shades.push("DarkSlateBlue")
	$shades.push("SlateBlue")
	$shades.push("MediumSlateBlue")
	$shades.push("Blue")
	$shades.push("Indigo")
	$shades.push("RoyalBlue")
	$shades.push("SteelBlue")
	$shades.push("LightSteelBlue")
	$shades.push("Cyan")
	$shades.push("lavender")
	$0:=$shades
	
	
Function setSeries($series : Collection)
	
	This:C1470.series:=$series
	
	
Function drawGraph()->$picture : Picture
	
	If ((This:C1470.areaSize.graphWidth-300)>This:C1470.areaSize.graphHeight)
		This:C1470.pieRadius:=(This:C1470.areaSize.graphHeight/2)
	Else 
		This:C1470.pieRadius:=((This:C1470.areaSize.graphWidth-300)/2)
	End if 
	
	This:C1470.center:=New object:C1471
	This:C1470.center.x:=This:C1470.pieRadius+This:C1470.margin.left
	This:C1470.center.y:=This:C1470.pieRadius+This:C1470.margin.top
	$nb_total:=This:C1470.series.sum("count")
	
	If ($nb_total>0)
		This:C1470.refSvg:=SVG_New(This:C1470.areaSize.width; This:C1470.areaSize.height)
		
		$objectReference:=SVG_New_circle(This:C1470.refSvg; This:C1470.center.x+This:C1470.offsetShadow; This:C1470.center.y+This:C1470.offsetShadow; This:C1470.pieRadius; "None"; SVG_Color_grey(60)+":70")
		
		SVG_Define_radial_gradient(This:C1470.refSvg; "GradientLightEffect"; "white:80"; SVG_Color_grey(30)+":30"; 50; 50; 50; 20; 20)
		
		$start:=0
		$i:=0
		For each ($serie; This:C1470.series)
			$finish:=$start+(360*($serie.count)/$nb_total)
			If ($i=(This:C1470.series.length-1))
				$finish:=360
			End if 
			
			$colorSerie:=This:C1470.shades[($i%This:C1470.shades.length)]
			
			$objectReference:=SVG_New_arc(This:C1470.refSvg; This:C1470.center.x; This:C1470.center.y; This:C1470.pieRadius; $start; $finish; "none"; $colorSerie; 1)
			
			$start:=$finish
			$i:=$i+1
		End for each 
		
		If (Bool:C1537(This:C1470.lightEffect))
			$objectReference:=SVG_New_circle(This:C1470.refSvg; This:C1470.center.x; This:C1470.center.y; This:C1470.pieRadius; "none"; "url(#GradientLightEffect)")
		End if 
		This:C1470._drawLegend()
		
		$picture:=SVG_Export_to_picture(This:C1470.refSvg)
		SVG_CLEAR(This:C1470.refSvg)
		
	End if 
	
	OB REMOVE:C1226(This:C1470; "refSvg")
	
	
Function _drawLegend()
	
	$textReference:=SVG_New_text(This:C1470.refSvg; This:C1470.title; This:C1470.margin.left+(This:C1470.pieRadius*2)+This:C1470.gutter; This:C1470.margin.top; "Arial"; 12; Bold:K14:2; 0)
	$textReference:=SVG_New_text(This:C1470.refSvg; This:C1470.subtitle; This:C1470.margin.left+(This:C1470.pieRadius*2)+This:C1470.gutter; This:C1470.margin.top+15; "Arial"; 11; Plain:K14:1; 0)
	$i:=0
	$offsetLegend:=40+12
	$nb_total:=This:C1470.series.sum("count")
	
	For each ($serie; This:C1470.series)
		$colorSerie:=This:C1470.shades[($i%This:C1470.shades.length)]
		
		$objectReference:=SVG_New_rect(This:C1470.refSvg; This:C1470.margin.left+(This:C1470.pieRadius*2)+This:C1470.gutter; $offsetLegend+2+($i*25); This:C1470.squareSize; This:C1470.squareSize; 2; 2; "black"; $colorSerie+":70"; 1)
		$text:=$serie.name+" : "+String:C10($serie.count; "###,###,###,###,##0")
		$textReference:=SVG_New_text(This:C1470.refSvg; $text; This:C1470.margin.left+(This:C1470.pieRadius*2)+This:C1470.gutter+This:C1470.squareSize+10; $offsetLegend+($i*25); "Arial"; 12)
		
		$pc:=String:C10($serie.count/$nb_total*100; "###.00%")
		$textReference:=SVG_New_text(This:C1470.refSvg; $pc; This:C1470.margin.left+(This:C1470.pieRadius*2)+This:C1470.gutter-12; $offsetLegend+($i*25); "Arial"; 12; 0; 4)
		$i:=$i+1
	End for each 
	
	$text:="Total : "+String:C10($nb_total; "###,###,###,###,##0")
	$textReference:=SVG_New_text(This:C1470.refSvg; $text; This:C1470.margin.left+(This:C1470.pieRadius*2)+This:C1470.gutter+This:C1470.squareSize+10; $offsetLegend+($i*25); "Arial"; 12; Bold:K14:2)
	