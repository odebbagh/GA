property title : Object
property areaSize : Object
property font : Object
property gutter : Integer
property refSvg : Text
property margin; object
property legend : Object
property _series : Collection
property _nbSeries : Integer

Class constructor
	
	This:C1470.margin:=New object:C1471
	This:C1470.margin.left:=40
	This:C1470.margin.top:=20
	This:C1470.margin.right:=10
	This:C1470.margin.bottom:=50
	
	This:C1470.title:=New object:C1471
	This:C1470.title.height:=0
	This:C1470.title.text:=""
	This:C1470.title.subtext:=""
	This:C1470.title.font:=New object:C1471
	This:C1470.title.font.family:="Arial"
	This:C1470.title.font.size:=12
	
	This:C1470.font:=New object:C1471
	This:C1470.font.size:=10
	This:C1470.font.family:="Arial"
	
	This:C1470.gutter:=20
	This:C1470.areaSize:=New object:C1471
	
	This:C1470._series:=New collection:C1472
	
	
	//MARK:-management of area & graph size
Function setAreaSize($width : Integer; $height : Integer)
	
	This:C1470.areaSize.width:=$width
	This:C1470.areaSize.height:=$height
	
	This:C1470.areaSize.graphWidth:=This:C1470.areaSize.width-This:C1470.margin.left-This:C1470.margin.right
	If ((This:C1470.legend)#Null:C1517) & (This:C1470.legend.labels#Null:C1517)
		This:C1470.areaSize.graphWidth-=300
	End if 
	This:C1470.areaSize.graphHeight:=This:C1470.areaSize.height-This:C1470.margin.top-This:C1470.margin.bottom-This:C1470.title.height
	
	This:C1470.areaSize.graphLeft:=This:C1470.margin.left
	This:C1470.areaSize.graphRight:=This:C1470.areaSize.graphLeft+This:C1470.areaSize.graphWidth
	This:C1470.areaSize.graphTop:=This:C1470.margin.top+This:C1470.title.height
	This:C1470.areaSize.graphBottom:=This:C1470.areaSize.graphTop+This:C1470.areaSize.graphHeight
	
	//MARK:-management of data
Function set values($data : Collection)
	
	This:C1470._series:=$data
	This:C1470._nbSeries:=This:C1470._series.length
	
Function get values()->$data : Collection
	
	$data:=This:C1470._series
	
	
	//MARK:-management of the colors
Function _loadShades($parameters : Variant)->$colors : Collection  // Text : "blueShades", "redShades", etc. or or Collection = colors list 
	$max:=This:C1470._nbSeries
	
	$colors:=[]
	If (Count parameters:C259=0)
		$parameters:=""
	End if 
	
	If (Value type:C1509($parameters)=Is text:K8:3)
		
		Case of 
			: ($parameters="BlueShades")
				$colors.push("Orange")
				$colors.push("OrangeRed")
				$colors.push("DarkOrange")
				$colors.push("Tomato")
				$colors.push("Coral")
				$colors.push("Gold")
				$colors.push("Goldenrod")
				$colors.push("DarkGoldenrod")
				$colors.push("GreenYellow")
				$colors.push("Goldenrod")
				$colors.push("Peru")
				
			: ($parameters="RedShades")
				
			: ($parameters="OrangeShades")
				$shades.push("Orange")
				$shades.push("OrangeRed")
				$shades.push("DarkOrange")
				$shades.push("Tomato")
				$shades.push("Coral")
				$shades.push("Gold")
				$shades.push("Goldenrod")
				$shades.push("DarkGoldenrod")
				$shades.push("GreenYellow")
				$shades.push("Goldenrod")
				$shades.push("Peru")
				
			: ($parameters="YellowShades")
				$colors.push("Gold")
				$colors.push("PeachPuff")
				$colors.push("Yellow")
				$colors.push("LightYellow")
				$colors.push("DarkKhaki")
				$colors.push("LemonChiffon")
				$colors.push("PaleGoldenrod")
				$colors.push("LightGoldenrodYellow")
				$colors.push("Moccasin")
				$colors.push("PapayaWhip")
				$colors.push("Khaki")
				
			: ($parameters="ContrastingColors")
				
				$colors.push("Gold")
				$colors.push("PeachPuff")
				$colors.push("Yellow")
				$colors.push("LightYellow")
				$colors.push("DarkKhaki")
				$colors.push("LemonChiffon")
				$colors.push("PaleGoldenrod")
				$colors.push("LightGoldenrodYellow")
				$colors.push("Moccasin")
				$colors.push("PapayaWhip")
				$colors.push("Khaki")
				
			: ($parameters#"")
				$colors:=Split string:C1554($parameters; ";")
				
			Else 
				$colors:=Split string:C1554("darkred;red;orangered;darkgreen;green;olive;darkorange;orange;gold;yellow;saddiebrown"; ";")
		End case 
		
	Else 
		$colors:=$parameters
	End if 
	
	$nb:=($max\$colors.length)+1
	For ($i; 2; $nb)
		$colors:=$colors.combine($colors)
	End for 
	
	// MARK:-Drawing some common elements
Function _drawTitle
	
	If (This:C1470.title.text#Null:C1517)
		$label:=This:C1470.title.text
		$x:=0
		$y:=0
		$refTexte:=SVG_New_text(This:C1470.refSvg; $label; $x; $y; This:C1470.title.font.family; This:C1470.title.font.size; Plain:K14:1; Align left:K42:2)
	End if 
	If (This:C1470.title.subtext#Null:C1517)
		$label:=This:C1470.title.subtext
		$x:=0
		$y:=15
		$refTexte:=SVG_New_text(This:C1470.refSvg; $label; $x; $y; This:C1470.title.font.family; This:C1470.title.font.size; Plain:K14:1; Align left:K42:2)
	End if 