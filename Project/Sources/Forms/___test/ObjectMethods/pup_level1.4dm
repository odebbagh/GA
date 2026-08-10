var $path; $value; $choice; $currentPath; $newName; $param; $candidate; $prefix : Text
var $depth; $i; $bIndex; $bValue; $idx : Integer
var $left; $top; $right; $bottom; $menuX; $menuY : Integer
var $stop; $isTerminalB; $hasBChildren; $isCurrentPathExisting; $isTerm : Boolean
var $parts; $options; $partsChoice; $terminalFlags : Collection

If (Form.selectedPath#"")
	$currentPath:=Form.selectedPath
Else 
	$currentPath:=""
End if 

$stop:=False
OBJECT GET COORDINATES:C663(*; "pup_level1"; $left; $top; $right; $bottom)
CONVERT COORDINATES:C1365($left; $bottom; XY Current form:K27:5; XY Current window:K27:6)
$menuX:=$left
$menuY:=$bottom
Repeat 
	$parts:=New collection
	If ($currentPath#"")
		$parts:=Split string:C1554($currentPath; "/")
	End if 
	$depth:=$parts.length
	
	$isTerminalB:=False
	If ($depth>0)
		$value:=$parts[$depth-1]
		For ($bValue; 1; 32)
			If ($value=("B"+String:C10($bValue)))
				$isTerminalB:=True
				$bValue:=33
			End if 
		End for 
	End if 
	
	$options:=New collection
	$isCurrentPathExisting:=False
	For each ($path; Form.paths)
		If ($path=$currentPath)
			$isCurrentPathExisting:=True
		End if 
		$partsChoice:=Split string:C1554($path; "/")
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
	
	$terminalFlags:=New collection
	For each ($value; $options)
		If ($currentPath="")
			$candidate:=$value
		Else 
			$candidate:=$currentPath+"/"+$value
		End if 
		$isTerm:=True
		For each ($path; Form.paths) Until (Not:C34($isTerm))
			If (Length:C16($path)>=(Length:C16($candidate)+2))
				If (Substring:C12($path; 1; Length:C16($candidate)+1)=($candidate+"/"))
					$isTerm:=False
				End if 
			End if 
		End for each 
		$terminalFlags.push($isTerm)
	End for each 
	
	$menu:=Create menu:C408
	$idx:=0
	For each ($value; $options)
		If ($terminalFlags[$idx])
			$prefix:="🟩 "
		Else 
			$prefix:="🟦 "
		End if 
		APPEND MENU ITEM:C411($menu; $prefix+$value)
		SET MENU ITEM PARAMETER:C1004($menu; -1; "select|"+$value)
		$idx:=$idx+1
	End for each 
	
	If ($depth>0)
		APPEND MENU ITEM:C411($menu; "--------------------")
		DISABLE MENU ITEM:C150($menu; -1)
		APPEND MENU ITEM:C411($menu; "< Retour")
		SET MENU ITEM PARAMETER:C1004($menu; -1; "back")
	End if 
	
	If (($currentPath#"") & $isCurrentPathExisting)
		APPEND MENU ITEM:C411($menu; "Valider ici")
		SET MENU ITEM PARAMETER:C1004($menu; -1; "finish")
	End if 
	
	If (Not:C34($isTerminalB))
		APPEND MENU ITEM:C411($menu; "--------------------")
		DISABLE MENU ITEM:C150($menu; -1)
		APPEND MENU ITEM:C411($menu; "+ Creer sous niveau")
		SET MENU ITEM PARAMETER:C1004($menu; -1; "createText")
		APPEND MENU ITEM:C411($menu; "+ Creer niveau terminal B1..B32")
		SET MENU ITEM PARAMETER:C1004($menu; -1; "createB")
	End if 
	
	$choice:=Dynamic pop up menu:C1006($menu; ""; $menuX; $menuY)
	RELEASE MENU:C978($menu)
	
	If ($choice="")
		$stop:=True
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
			: ($choice="finish")
				$stop:=True
			: ($choice="createText")
				$value:=$currentPath
				If ($value="")
					$value:="(racine)"
				End if 
				$newName:=Request:C163("Nouveau sous niveau sous '"+$value+"' :")
				If ((ok=1) & ($newName#""))
					If ($currentPath="")
						$value:=$newName
					Else 
						$value:=$currentPath+"/"+$newName
					End if 
					If (Form.paths.indexOf($value)=-1)
						Form.paths.push($value)
					End if 
					$currentPath:=$value
				End if 
			: ($choice="createB")
				$hasBChildren:=False
				$menu:=Create menu:C408
				APPEND MENU ITEM:C411($menu; "< Retour")
				SET MENU ITEM PARAMETER:C1004($menu; -1; "backB")
				APPEND MENU ITEM:C411($menu; "--------------------")
				DISABLE MENU ITEM:C150($menu; -1)
				For ($bIndex; 1; 32)
					$value:="B"+String:C10($bIndex)
					If ($currentPath="")
						$path:=$value
					Else 
						$path:=$currentPath+"/"+$value
					End if 
					If (Form.paths.indexOf($path)=-1)
						APPEND MENU ITEM:C411($menu; "🟩 "+$value)
						SET MENU ITEM PARAMETER:C1004($menu; -1; $value)
						$hasBChildren:=True
					End if 
				End for 
				If ($hasBChildren)
					$choice:=Dynamic pop up menu:C1006($menu; ""; $menuX; $menuY)
					If (($choice#"") & ($choice#"backB"))
						If ($currentPath="")
							$currentPath:=$choice
						Else 
							$currentPath:=$currentPath+"/"+$choice
						End if 
						If (Form.paths.indexOf($currentPath)=-1)
							Form.paths.push($currentPath)
						End if 
						$stop:=True
					End if 
				Else 
					ALERT:C41("Tous les niveaux B1..B32 existent deja ici.")
				End if 
				RELEASE MENU:C978($menu)
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

If ($currentPath#"")
	Form.selectedPath:=$currentPath
	OBJECT SET TITLE:C194(*; "pup_level1"; Form.selectedPath)
End if 
