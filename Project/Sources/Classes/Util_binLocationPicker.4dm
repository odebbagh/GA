// Reusable hierarchical bin location picker.
// Usage: cs.Util_binLocationPicker.me.pickReadOnly / pickWithCreate / draw

singleton Class constructor


Function pickReadOnly($buttonName : Text; $currentPath : Text; $scopeLotUUID : Text)->$result : Text
	$result:=This:C1470._pick($buttonName; $currentPath; False:C215; $scopeLotUUID)


Function pickWithCreate($buttonName : Text; $currentPath : Text; $scopeLotUUID : Text)->$result : Text
	$result:=This:C1470._pick($buttonName; $currentPath; True:C214; $scopeLotUUID)


Function draw($buttonName : Text; $path : Text)
	If ($path=Null:C1517)
		$path:=""
	End if 
	Form:C1466.sfw.drawButtonPup($buttonName; $path; "sfw/image/skin/rainbow/icon/spacer-1x24.png"; ($path=""))


Function _stepBack($path : Text)->$parent : Text
	// Returns the parent path by removing the last "/" segment
	var $parts : Collection
	var $i : Integer
	If ($path="")
		$parent:=""
	Else 
		$parts:=Split string:C1554($path; "/")
		$parent:=""
		For ($i; 0; $parts.length-2)
			If ($parent="")
				$parent:=$parts[$i]
			Else 
				$parent:=$parent+"/"+$parts[$i]
			End if 
		End for 
	End if 


Function _buildOpts($currentPath : Text; $allowCreate : Boolean; $scopeLotUUID : Text)->$opts : Collection
	// Builds the complete options list for the current navigation level
	var $parts; $options; $partsChoice; $terminalFlags; $occupiedFlags : Collection
	var $value; $candidate; $param : Text
	var $depth; $i; $idx : Integer
	var $isTerm; $isOccupied; $isCurrentPathExisting; $currentBinIsOccupied : Boolean
	var $occupiedInventories : 4D.EntitySelection
	var $occupiedMap : Object
	var $locationUUID : Text
	var $inventory : 4D.Entity
	
	$parts:=New collection:C1472
	If ($currentPath#"")
		$parts:=Split string:C1554($currentPath; "/")
	End if 
	$depth:=$parts.length
	
	// Collect unique child segment names visible at this depth
	$options:=New collection:C1472
	For each ($bin; Storage:C1525.cache.bins)
		$partsChoice:=Split string:C1554($bin.binLocationPath; "/")
		If ($partsChoice.length>$depth)
			$param:=""
			For ($i; 0; $depth-1)
				If ($partsChoice[$i]#$parts[$i])
					$param:="noMatch"
					$i:=$depth
				End if 
			End for 
			If ($param#"noMatch")
				$value:=$partsChoice[$depth]
				If ($options.indexOf($value)=-1)
					$options.push($value)
				End if 
			End if 
		End if 
	End for each 
	
	// Build occupied locations map from related inventories (live stock), not from Bin.isEmpty.
	$occupiedMap:=New object:C1471
	If (($scopeLotUUID#"") & ($scopeLotUUID#String:C10("00"*16)))
		$occupiedInventories:=ds:C1482.Inventory.query("qtyInStock > :1 and UUID_Lot = :2"; 0; $scopeLotUUID)
	Else 
		$occupiedInventories:=ds:C1482.Inventory.query("qtyInStock > :1"; 0)
	End if 
	For each ($inventory; $occupiedInventories)
		$locationUUID:=$inventory.UUID_Location
		If ($locationUUID#"")
			$occupiedMap[$locationUUID]:=True:C214
		End if 
	End for each 
	
	// Determine terminal and occupied flags for each child in one cache pass
	$terminalFlags:=New collection:C1472
	$occupiedFlags:=New collection:C1472
	For each ($value; $options)
		$candidate:=($currentPath="") ? $value : ($currentPath+"/"+$value)
		$isTerm:=True:C214
		$isOccupied:=False:C215
		For each ($bin; Storage:C1525.cache.bins)
			If ($bin.binLocationPath=$candidate)
				If ($occupiedMap[$bin.UUID]#Null:C1517)
					$isOccupied:=True:C214
				End if 
			End if 
			If ($isTerm)
				If (Length:C16($bin.binLocationPath)>=(Length:C16($candidate)+2))
					If (Substring:C12($bin.binLocationPath; 1; Length:C16($candidate)+1)=($candidate+"/"))
						$isTerm:=False:C215
					End if 
				End if 
			End if 
		End for each 
		$terminalFlags.push($isTerm)
		$occupiedFlags.push($isOccupied)
	End for each 
	
	// Check whether the current path is itself an existing bin record
	$isCurrentPathExisting:=False:C215
	$currentBinIsOccupied:=False:C215
	If ($currentPath#"")
		For each ($bin; Storage:C1525.cache.bins)
			If ($bin.binLocationPath=$currentPath)
				$isCurrentPathExisting:=True:C214
				$currentBinIsOccupied:=($occupiedMap[$bin.UUID]#Null:C1517)
			End if 
		End for each 
	End if 
	
	$opts:=New collection:C1472
	$idx:=0
	For each ($value; $options)
		If ($terminalFlags[$idx])
			If ($occupiedFlags[$idx])
				$opts.push(New object:C1471("label"; "🟡 "+$value; "value"; "occupied|"+$value; "kind"; "yellow"))
			Else 
				$opts.push(New object:C1471("label"; "🟢 "+$value; "value"; "select|"+$value; "kind"; "green"))
			End if 
		Else 
			$opts.push(New object:C1471("label"; "🔵 "+$value; "value"; "select|"+$value; "kind"; "blue"))
		End if 
		$idx:=$idx+1
	End for each 
	
	// Confirm block shown only when the user has navigated into a terminal bin (no children)
	If (($currentPath#"") & $isCurrentPathExisting & ($options.length=0))
		$opts.push(New object:C1471("label"; ""; "value"; ""; "kind"; "divider"))
		$opts.push(New object:C1471("label"; "📍  "+$currentPath; "value"; ""; "kind"; "separator"))
		If ($currentBinIsOccupied)
			$opts.push(New object:C1471("label"; "⚠️  This bin is not empty"; "value"; "occupied_alert"; "kind"; "yellow"))
		Else 
			$opts.push(New object:C1471("label"; "✔   Select this location"; "value"; "finish"; "kind"; "action"))
			If ($allowCreate)
				$opts.push(New object:C1471("label"; "➕  Add a sub-location"; "value"; "createText"; "kind"; "action"))
			End if 
		End if 
	End if 
	
	If ($depth>0)
		$opts.push(New object:C1471("label"; "← Back"; "value"; "back"))
		$opts.push(New object:C1471("label"; "⇤ Back to root"; "value"; "backToRoot"))
	End if 


Function _handleChoice($choice : Text; $currentPath : Text; $allowCreate : Boolean)->$state : Object
	// Processes the popup result and returns the new navigation state {path, stop, confirmed}
	var $partsChoice : Collection
	var $newPath; $newName; $parentLabel; $candidate : Text
	var $saveResult : Object
	
	$state:=New object:C1471("path"; $currentPath; "stop"; False:C215; "confirmed"; False:C215)
	
	Case of 
		: ($choice="back")
			$state.path:=This:C1470._stepBack($currentPath)
			
		: ($choice="backToRoot")
			$state.path:=""
			
		: ($choice="finish")
			$state.stop:=True:C214
			$state.confirmed:=True:C214
			
		: ($choice="occupied_alert")
			ALERT:C41("Bin location \""+$currentPath+"\" is not empty and cannot be selected as a destination.")
			
		: ($choice="createText")
			$parentLabel:=($currentPath="") ? "(root)" : $currentPath
			$newName:=Request:C163("New sub-location under '"+$parentLabel+"':")
			If (ok=1) & ($newName#"")
				$newPath:=($currentPath="") ? $newName : ($currentPath+"/"+$newName)
				If (ds:C1482.Bin.query("binLocationPath = :1"; $newPath).length>0)
					ALERT:C41("A location '"+$newPath+"' already exists.")
				Else 
					$newBin:=ds:C1482.Bin.new()
					$newBin.binLocationPath:=$newPath
					$saveResult:=$newBin.save()
					If ($saveResult.success)
						Use (Storage:C1525.cache)
							Storage:C1525.cache.bins:=Null:C1517
						End use 
						ds:C1482.Bin.cacheLoad()
						$state.path:=$newPath
					Else 
						ALERT:C41("Error creating the location.")
					End if 
				End if 
			End if 
			
		Else 
			$partsChoice:=Split string:C1554($choice; "|")
			If ($partsChoice.length>1)
				Case of 
					: ($partsChoice[0]="select")
						$state.path:=($currentPath="") ? $partsChoice[1] : ($currentPath+"/"+$partsChoice[1])
					: ($partsChoice[0]="occupied")
						$candidate:=($currentPath="") ? $partsChoice[1] : ($currentPath+"/"+$partsChoice[1])
						ALERT:C41("Bin location \""+$candidate+"\" is not empty and cannot be selected as a destination.")
				End case 
			End if 
	End case 


Function _pick($buttonName : Text; $currentPath : Text; $allowCreate : Boolean; $scopeLotUUID : Text)->$result : Text
	var $left; $top; $right; $bottom; $menuX; $menuY; $winRef : Integer
	var $stop; $confirmed; $isTerm : Boolean
	var $state; $params : Object
	var $opts : Collection
	var $choice : Text
	
	$result:=""
	
	If (Storage:C1525.cache=Null:C1517) || (Storage:C1525.cache.bins=Null:C1517)
		ds:C1482.Bin.cacheLoad()
	End if 
	
	// If the current path is a terminal bin, open the picker at its parent level
	If ($currentPath#"")
		$isTerm:=True:C214
		For each ($bin; Storage:C1525.cache.bins) Until (Not:C34($isTerm))
			If (Length:C16($bin.binLocationPath)>=(Length:C16($currentPath)+2))
				If (Substring:C12($bin.binLocationPath; 1; Length:C16($currentPath)+1)=($currentPath+"/"))
					$isTerm:=False:C215
				End if 
			End if 
		End for each 
		If ($isTerm)
			$currentPath:=This:C1470._stepBack($currentPath)
		End if 
	End if 
	
	$stop:=False:C215
	$confirmed:=False:C215
	OBJECT GET COORDINATES:C663(*; $buttonName; $left; $top; $right; $bottom)
	CONVERT COORDINATES:C1365($left; $bottom; XY Current form:K27:5; XY Main window:K27:8)
	$menuX:=$left
	$menuY:=$bottom+30
	
	Repeat 
		$opts:=This:C1470._buildOpts($currentPath; $allowCreate; $scopeLotUUID)
		$params:=New object:C1471("options"; $opts; "choice"; ""; "allowCreate"; $allowCreate)
		$winRef:=Open form window:C675("_popup_binLocation"; Movable form dialog box:K39:8; $menuX; $menuY)
		SET WINDOW TITLE:C213("Select a Bin Location"; $winRef)
		DIALOG:C40("_popup_binLocation"; $params)
		CLOSE WINDOW:C154($winRef)
		
		$choice:=(ok=1) ? $params.choice : ""
		
		If ($choice="")
			$stop:=True:C214
		Else 
			$state:=This:C1470._handleChoice($choice; $currentPath; $allowCreate)
			$currentPath:=$state.path
			$stop:=$state.stop
			$confirmed:=$state.confirmed
		End if 
	Until ($stop)
	
	If ($confirmed) & ($currentPath#"")
		$result:=$currentPath
	End if 
