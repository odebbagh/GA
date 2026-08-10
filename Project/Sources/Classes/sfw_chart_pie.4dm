property refSvg : Text
property _center; margin : Object
property _pieRadius : Real
property _series : Collection

Class extends sfw_chart

property withLightEffect : Boolean


Class constructor
	Super:C1705()
	This:C1470.withLightEffect:=False:C215
	This:C1470.setAreaSize(500; 500)
	
Function setAreaSize($width : Integer; $height : Integer)
	
	Super:C1706.setAreaSize($width; $height)
	
	If (This:C1470.areaSize.graphWidth<This:C1470.areaSize.graphHeight)
		This:C1470._pieRadius:=(This:C1470.areaSize.graphWidth/2)*0.8
	Else 
		This:C1470._pieRadius:=(This:C1470.areaSize.graphHeight/2)*0.8
	End if 
	This:C1470._center:=New object:C1471
	This:C1470._center.X:=This:C1470._pieRadius+This:C1470.margin.left
	This:C1470._center.Y:=This:C1470._pieRadius+This:C1470.margin.top
	
Function drawGraph($option : Object)->$picture : Picture
	var $colors : Collection:=[]
	$option:=$option||new object()
	$option.groupAfterXslices:=$option.groupAfterXslices || 1000
	$colors:=This:C1470._series.extract("color")
	If ($colors.length#This:C1470._series.length)
		$colors:=This:C1470._loadShades()
	End if 
	This:C1470.refSvg:=SVG_New
	
	$offsetShadow:=5
	SVG_New_circle(This:C1470.refSvg; This:C1470._center.X+$offsetShadow; This:C1470._center.Y+$offsetShadow; This:C1470._pieRadius; "None"; SVG_Color_grey(60)+":70")
	
	$grandTotal:=This:C1470._series.sum("value")
	$start:=0
	This:C1470.gutter:=70
	$i:=0
	$values:=0
	$nb_others:=0
	For each ($serie; This:C1470._series)
		$i+=1
		If ($i<$option.groupAfterXslices)
			$finish:=$start+(360*$serie.value/$grandTotal)
			SVG_New_arc(This:C1470.refSvg; This:C1470._center.X; This:C1470._center.Y; This:C1470._pieRadius; $start; $finish; "none"; $colors[$i-1]; 1)
			SVG_New_text(This:C1470.refSvg; String:C10($serie.value/$grandTotal*100; "###.0%"); This:C1470.margin.left+(This:C1470._pieRadius*2)+This:C1470.gutter-12; 18+(($i-1)*25); "Arial"; 12; 0; 4)
			SVG_New_rect(This:C1470.refSvg; This:C1470.margin.left+(This:C1470._pieRadius*2)+This:C1470.gutter; 20+(($i-1)*25); 10; 10; 2; 2; "black"; $colors[$i-1]+":50"; 1)
			SVG_New_text(This:C1470.refSvg; $serie.name+" : "+String:C10($serie.value; "### ### ##0"); This:C1470.margin.left+(This:C1470._pieRadius*2)+This:C1470.gutter+20; 18+(($i-1)*25); "Arial"; 10.5)
			$start:=$finish
		Else 
			$values+=$serie.value
			$nb_others+=1
		End if 
	End for each 
	$finish:=$start+(360*$values/$grandTotal)
	
	$i:=$i+1
	If ($i>$option.groupAfterXslices)
		$i:=$option.groupAfterXslices
		SVG_New_arc(This:C1470.refSvg; This:C1470._center.X; This:C1470._center.Y; This:C1470._pieRadius; $start; $finish; "none"; "silver"; 1)
		SVG_New_text(This:C1470.refSvg; String:C10($values/$grandTotal*100; "###.0%"); This:C1470.margin.left+(This:C1470._pieRadius*2)+This:C1470.gutter-12; 18+(($i-1)*25); "Arial"; 12; 0; 4)
		SVG_New_rect(This:C1470.refSvg; This:C1470.margin.left+(This:C1470._pieRadius*2)+This:C1470.gutter; 20+(($i-1)*25); 10; 10; 2; 2; "black"; "silver:50"; 1)
		SVG_New_text(This:C1470.refSvg; String:C10($nb_others)+" others values : "+String:C10($values; "### ### ##0"); This:C1470.margin.left+(This:C1470._pieRadius*2)+This:C1470.gutter+20; 18+(($i-1)*25); "Arial"; 10.5)
		$i+=1
	End if 
	
	SVG_New_text(This:C1470.refSvg; "Total : "+String:C10($grandTotal; "### ### ##0"); This:C1470.margin.left+(This:C1470._pieRadius*2)+This:C1470.gutter+20; 18+(($i-1)*25); "Arial"; 10.5)
	
	If (This:C1470.withLightEffect)
		$nameOfGradient:="myGradient"
		SVG_Define_radial_gradient(This:C1470.refSvg; $nameOfGradient; "white:80"; SVG_Color_grey(30)+":30"; 50; 50; 50; 20; 20)
		SVG_New_circle(This:C1470.refSvg; This:C1470._center.X; This:C1470._center.Y; This:C1470._pieRadius; "none"; "url(#"+$nameOfGradient+")")
	End if 
	
	This:C1470._drawTitle()
	
	$picture:=SVG_Export_to_picture(This:C1470.refSvg)
	SVG_CLEAR(This:C1470.refSvg)
	
	
Function _drawTitle
	If (This:C1470.title.text#Null:C1517)
		$label:=This:C1470.title.text
		$x:=0
		$y:=0
		$refTexte:=SVG_New_text(This:C1470.refSvg; This:C1470.title.text; (This:C1470.margin.left+This:C1470._pieRadius)/2; This:C1470.margin.top+(This:C1470._pieRadius*2)+18; "Arial"; This:C1470.title.font.size)
	End if 
	If (This:C1470.title.subtext#Null:C1517)
		$label:=This:C1470.title.subtext
		$x:=0
		$y:=15
		$refTexte:=SVG_New_text(This:C1470.refSvg; $label; $x; $y; This:C1470.title.font.family; This:C1470.title.font.size; Plain:K14:1; Align left:K42:2)
	End if 
	
	