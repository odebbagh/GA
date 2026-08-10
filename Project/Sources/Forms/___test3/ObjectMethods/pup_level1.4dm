//var $value; $choice; $currentPath; $param; $candidate : Text
//var $depth; $i; $idx : Integer
//var $left; $top; $right; $bottom; $menuX; $menuY : Integer
//var $wLeft; $wTop; $wRight; $wBottom; $btnWidth : Integer
//var $stop; $isTerm; $isCurrentPathExisting; $confirmed : Boolean
//var $parts; $options; $partsChoice; $terminalFlags; $opts : Collection
//var $params : Object
//var $winRef : Integer

If (Form:C1466.selectedPath#"")
	$currentPath:=Form:C1466.selectedPath
Else 
	$currentPath:=""
End if 

If ($currentPath#"")
	$isTerm:=True:C214
	For each ($bin; Form:C1466.bins) Until (Not:C34($isTerm))
		If (Length:C16($bin.binLocationPath)>=(Length:C16($currentPath)+2))
			If (Substring:C12($bin.binLocationPath; 1; Length:C16($currentPath)+1)=($currentPath+"/"))
				$isTerm:=False:C215
			End if 
		End if 
	End for each 
	If ($isTerm)
		$partsChoice:=Split string:C1554($currentPath; "/")
		$currentPath:=""
		For ($i; 0; $partsChoice.length-2)
			If ($currentPath="")
				$currentPath:=$partsChoice[$i]
			Else 
				$currentPath:=$currentPath+"/"+$partsChoice[$i]
			End if 
		End for 
	End if 
End if 

$stop:=False:C215
$confirmed:=False:C215
OBJECT GET COORDINATES:C663(*; "pup_level1"; $left; $top; $right; $bottom)
CONVERT COORDINATES:C1365($left; $bottom; XY Current form:K27:5; XY Main window:K27:8)
$menuX:=$left
$menuY:=$bottom+30
Repeat 
	$parts:=New collection:C1472
	If ($currentPath#"")
		$parts:=Split string:C1554($currentPath; "/")
	End if 
	$depth:=$parts.length
	
	$options:=New collection:C1472
	For each ($bin; Form:C1466.bins)
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
	
	$terminalFlags:=New collection:C1472
	For each ($value; $options)
		If ($currentPath="")
			$candidate:=$value
		Else 
			$candidate:=$currentPath+"/"+$value
		End if 
		$isTerm:=True:C214
		For each ($bin; Form:C1466.bins) Until (Not:C34($isTerm))
			If (Length:C16($bin.binLocationPath)>=(Length:C16($candidate)+2))
				If (Substring:C12($bin.binLocationPath; 1; Length:C16($candidate)+1)=($candidate+"/"))
					$isTerm:=False:C215
				End if 
			End if 
		End for each 
		$terminalFlags.push($isTerm)
	End for each 
	
	// Check if the current path matches an existing bin
	$isCurrentPathExisting:=False:C215
	If ($currentPath#"")
		For each ($bin; Form:C1466.bins)
			If ($bin.binLocationPath=$currentPath)
				$isCurrentPathExisting:=True:C214
			End if 
		End for each 
	End if 
	
	$opts:=New collection:C1472
	$idx:=0
	For each ($value; $options)
		If ($terminalFlags[$idx])
			$opts.push(New object:C1471("label"; $value; "value"; "select|"+$value; "kind"; "green"))
		Else 
			$opts.push(New object:C1471("label"; $value; "value"; "select|"+$value; "kind"; "blue"))
		End if 
		$idx:=$idx+1
	End for each 
	
	// Show confirm block only on terminal nodes (no children)
	If (($currentPath#"") & $isCurrentPathExisting & ($options.length=0))
		$opts.push(New object:C1471("label"; ""; "value"; ""; "kind"; "divider"))
		$opts.push(New object:C1471("label"; "📍  "+$currentPath; "value"; ""; "kind"; "separator"))
		$opts.push(New object:C1471("label"; "✔   Select this location"; "value"; "finish"; "kind"; "action"))
	End if 
	
	If ($depth>0)
		$opts.push(New object:C1471("label"; "← Back"; "value"; "back"))
		$opts.push(New object:C1471("label"; "⇤ Back to root"; "value"; "backToRoot"))
	End if 
	
	$params:=New object:C1471("options"; $opts; "choice"; ""; "width"; $btnWidth)
	$winRef:=Open form window:C675("_popup_binLocation"; Movable form dialog box:K39:8; $menuX; $menuY)
	SET WINDOW TITLE:C213("Select a Bin Location"; $winRef)
	DIALOG:C40("_popup_binLocation"; $params)
	CLOSE WINDOW:C154($winRef)
	
	If (ok=1)
		$choice:=$params.choice
	Else 
		$choice:=""
	End if 
	
	If ($choice="")
		$stop:=True:C214
	Else 
		Case of 
			: ($choice="back")
				$partsChoice:=Split string:C1554($currentPath; "/")
				$currentPath:=""
				For ($i; 0; $partsChoice.length-2)
					If ($currentPath="")
						$currentPath:=$partsChoice[$i]
					Else 
						$currentPath:=$currentPath+"/"+$partsChoice[$i]
					End if 
				End for 
			: ($choice="backToRoot")
				$currentPath:=""
			: ($choice="finish")
				$stop:=True:C214
				$confirmed:=True:C214
			Else 
				$partsChoice:=Split string:C1554($choice; "|")
				If ($partsChoice.length>1)
					If ($partsChoice[0]="select")
						If ($currentPath="")
							$currentPath:=$partsChoice[1]
						Else 
							$currentPath:=$currentPath+"/"+$partsChoice[1]
						End if 
					End if 
				End if 
		End case 
	End if 
Until ($stop)

If ($confirmed) & ($currentPath#"")
	Form:C1466.selectedPath:=$currentPath
	OBJECT SET TITLE:C194(*; "pup_level1"; Form:C1466.selectedPath)
End if 
