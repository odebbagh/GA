property refMenuWindows : Text
property windows : Collection
property toolbarWindowRef : Integer

shared singleton Class constructor
	
	
	This:C1470.windows:=New shared collection:C1527
	
shared Function openFormWindow($form : Text; $type : Integer; $left : Integer; $top : Integer)->$refWindow : Integer
	
	
	SET MENU BAR:C67(1)
	Case of 
		: (Count parameters:C259=2)
			$refWindow:=Open form window:C675($form; $type)
		: (Count parameters:C259=4)
			$refWindow:=Open form window:C675($form; $type; $left; $top)
		Else 
			TRACE:C157
	End case 
	
	
	
	$window:=New shared object:C1526
	This:C1470.windows.push($window)
	Use ($window)
		$window.reference:=$refWindow
		$window.process:=New shared object:C1526("number"; Current process:C322; "name"; Current process name:C1392)
	End use 
	
	If ($form="sfw_toolbar")
		Use (This:C1470)
			This:C1470.toolbarWindowRef:=$refWindow
		End use 
	End if 
	
	
	
shared Function closeWindow($refWindow : Integer)
	var $indices : Collection
	
	CLOSE WINDOW:C154($refWindow)
	
	$indices:=This:C1470.windows.indices("reference = :1"; $refWindow)
	If ($indices.length>0)
		This:C1470.windows.remove($indices[0])
	End if 
	This:C1470.buildMenuWindows()
	
	
shared Function setWindowTitle($title : Text)
	var $indices : Collection
	var $refWindow : Integer:=Current form window:C827
	var $titleParts : Collection:=New collection:C1472
	
	If (Count parameters:C259=0)
		Case of 
			: (OB Class:C1730(Form:C1466.sfw).name="sfw_item")
				$titleParts.push(Form:C1466.sfw.entry.labelSingle || Form:C1466.sfw.entry.label)
			: (Form:C1466.sfw.entry.views.length<=1)
				$titleParts.push(Form:C1466.sfw.entry.label)
			Else 
				$titleParts.push(Form:C1466.sfw.view.label#Null:C1517 ? Form:C1466.sfw.entry.label+" : "+Form:C1466.sfw.view.label : Form:C1466.sfw.entry.label)
		End case 
		Case of 
			: (Form:C1466.current_item#Null:C1517) && (Form:C1466.current_item["nameInWindowTitle"]#Null:C1517)
				$titleParts.push(Form:C1466.current_item.nameInWindowTitle)
			: (Form:C1466.current_item#Null:C1517) && (Form:C1466.current_item["fullName"]#Null:C1517)
				$titleParts.push(Form:C1466.current_item.fullName)
		End case 
		$title:=$titleParts.join(" : ")
	End if 
	SET WINDOW TITLE:C213($title; $refWindow)
	$indices:=This:C1470.windows.indices("reference = :1"; $refWindow)
	If ($indices.length>0)
		$window:=This:C1470.windows[$indices[0]]
		Use ($window)
			$window.title:=$title
		End use 
	End if 
	This:C1470.buildMenuWindows()
	
shared Function buildMenuWindows()
	ARRAY TEXT:C222($_ref; 0)
	ARRAY TEXT:C222($_title; 0)
	
	$RefBarreMenu:=Get menu bar reference:C979(Frontmost process:C327)
	GET MENU ITEMS:C977($RefBarreMenu; $_title; $_ref)
	$find:=Find in array:C230($_title; "Windows")
	If ($find>0)
		This:C1470.refMenuWindows:=$_ref{$find}
	Else 
		This:C1470.refMenuWindows:=Create menu:C408
		INSERT MENU ITEM:C412($RefBarreMenu; 2; "Windows"; This:C1470.refMenuWindows)
	End if 
	For ($m; Count menu items:C405(This:C1470.refMenuWindows); 1; -1)
		DELETE MENU ITEM:C413(This:C1470.refMenuWindows; $m)
	End for 
	
	For each ($window; This:C1470.windows.orderBy("title"))
		If ($window.title#Null:C1517)
			APPEND MENU ITEM:C411(This:C1470.refMenuWindows; $window.title)
			SET MENU ITEM METHOD:C982(This:C1470.refMenuWindows; -1; "sfw_menu_windows")
			SET MENU ITEM PARAMETER:C1004(This:C1470.refMenuWindows; -1; "process:"+String:C10($window.process.number))
		End if 
	End for each 
	
	
shared Function menuSelected()
	$lineMenu:=Menu selected:C152 & 0xFFFF
	$param:=Get menu item parameter:C1003(This:C1470.refMenuWindows; $lineMenu)
	If ($param="process:@")
		$numprocess:=Num:C11(Substring:C12($param; 9))
		BRING TO FRONT:C326($numprocess)
	End if 
	