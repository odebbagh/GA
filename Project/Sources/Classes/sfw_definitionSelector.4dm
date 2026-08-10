
property ident : Text
property entry : cs:C1710.sfw_definitionEntry
property view : cs:C1710.sfw_definitionView
property title : Text
property current_item : 4D:C1709.Entity
property selected : Boolean
property cutlink : Boolean
property create : Boolean
property cancel : Boolean
property hPosition : Text
property vPosition : Text
property subset : Text
property subsetParameters : Object
property sfw : Object
property startingWindow : Integer
property callbackAfterCreation : Text
property options : Object
property topLeftCorner : Object
property widthForm : Integer
property heightForm : Integer

Class constructor($ident : Text; $entryIdent : Text)
	
	This:C1470.ident:=$ident
	This:C1470.entry:=cs:C1710.sfw_definition.me.entries.query("ident = :1"; $entryIdent).first()
	This:C1470.view:=This:C1470.entry.views.first()
	This:C1470.current_item:=Null:C1517
	This:C1470.hPosition:="left"
	This:C1470.vPosition:="bottom"
	This:C1470.options:=New object:C1471
	FORM GET PROPERTIES:C674("sfw_selector"; $width; $height)
	This:C1470.widthForm:=$width
	This:C1470.heightForm:=$height
	
Function selectViewByIdent($identView : Text)
	
	This:C1470.view:=This:C1470.entry.views.query("ident = :1"; $identView).first()
	
Function setTitle($title : Text)
	This:C1470.title:=$title
	
Function setCurrentItem($currentItem : 4D:C1709.Entity)
	This:C1470.current_item:=$currentItem
	
Function getCurrentItem()->$currentItem : 4D:C1709.Entity
	$currentItem:=This:C1470.current_item
	
Function topLeftCornerCoordinate($x : Integer; $y : Integer)
	This:C1470.topLeftCorner:=New object:C1471
	This:C1470.topLeftCorner.x:=$x
	This:C1470.topLeftCorner.y:=$y
	
Function openSelector()
	If (This:C1470.topLeftCorner#Null:C1517)
		$x:=This:C1470.topLeftCorner.x
		$y:=This:C1470.topLeftCorner.y
		$x:=(This:C1470.hPosition="right") ? $x-This:C1470.widthForm : $x
		$y:=(This:C1470.vPosition="top") ? $y-This:C1470.heightForm : $y
	Else 
		$objectName:=FORM Event:C1606.objectName
		OBJECT GET COORDINATES:C663(*; $objectName; $g; $h; $d; $b)
		$x:=(This:C1470.hPosition="right") ? $d-This:C1470.widthForm : $g
		$y:=(This:C1470.vPosition="top") ? $h-This:C1470.heightForm : $b
	End if 
	CONVERT COORDINATES:C1365($x; $y; XY Current form:K27:5; XY Main window:K27:8)  //Screen)
	$ref:=Open form window:C675("sfw_selector"; Pop up form window:K39:11; $x; $y)
	DIALOG:C40("sfw_selector"; This:C1470)
	CLOSE WINDOW:C154($ref)
	
	
Function isSelected()->$ok : Boolean
	$ok:=This:C1470.selected
	
Function asCutTheLink()->$ok : Boolean
	$ok:=This:C1470.cutlink
	
Function needCreation()->$ok : Boolean
	$ok:=This:C1470.create
	
Function setSubset($expression : Text; $parameters : Object)
	This:C1470.subset:=$expression
	This:C1470.subsetParameters:=$parameters || New object:C1471
	
Function createANewEntity($callbackAfterCreation : Text)
	This:C1470.current_item:=Null:C1517
	This:C1470.startingWindow:=Current form window:C827
	This:C1470.callbackAfterCreation:=$callbackAfterCreation
	This:C1470.sfw:=cs:C1710.sfw_item.new()
	This:C1470.sfw.vision:=cs:C1710.sfw_definition.me.visions.query("ident = :1"; This:C1470.entry.visions.first()).first()
	This:C1470.sfw.entry:=cs:C1710.sfw_definition.me.entries.query("ident = :1"; This:C1470.entry.ident).first()
	This:C1470.sfw.openForm(This:C1470)
	
Function setOptions( ...  : Text)
	
	For ($p; 1; Count parameters:C259)
		$params:=Split string:C1554(${$p}; ":")
		$selector:=$params.shift()
		Case of 
			: ($selector="noCreation")
				This:C1470.options.noCreation:=True:C214
			: ($selector="noCutLink")
				This:C1470.options.noCutLink:=True:C214
				
		End case 
	End for 
	
	