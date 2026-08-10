Class extends Entity


local Function get nameInWindowTitle()->$nameInWindowTitle : Text
	$nameInWindowTitle:=String:C10(This:C1470.assetNumber)
	
	
local Function drowPup($dataClass; $queryField; $queryValue; $pupName)
	
	$entity:=ds:C1482[$dataClass].query($queryField+" =:1"; Form:C1466.current_item[$queryValue]).first() || New object:C1471()
	$name:=$entity.name
	If ($name=Null:C1517)
		$name:=""
	End if 
	If (Not:C34(Undefined:C82($entity.color)))
		$color:=cs:C1710.sfw_htmlColor.me.getName($entity.color)
		$pathIcon:=($color#"") ? "sfw/colors/"+$color+"-circle.png" : "sfw/image/skin/rainbow/icon/spacer-1x24.png"
	Else 
		$pathIcon:=""
	End if 
	Form:C1466.sfw.drawButtonPup($pupName; $name; $pathIcon; ($entity=Null:C1517))
	
	
local Function pup($cacheCollection; $dataClass; $queryField; $queryValue)
	
	If (Form:C1466.sfw.checkIsInModification())
		$menu:=Create menu:C408
		If (Storage:C1525.cache=Null:C1517) || (Storage:C1525.cache[$cacheCollection]=Null:C1517)
			ds:C1482[$dataClass].cacheLoad()
		End if 
		
		For each ($eEntity; Storage:C1525.cache[$cacheCollection])
			APPEND MENU ITEM:C411($menu; $eEntity.name; *)
			SET MENU ITEM PARAMETER:C1004($menu; -1; $eEntity.UUID)
			If ($queryField="UUID")  //# TO BE REMOVED
				
				If ($eEntity[$queryField]=Form:C1466.current_item[$queryValue])
					SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
					If (Is Windows:C1573)
						SET MENU ITEM STYLE:C425($menu; -1; Bold:K14:2)
					End if 
				End if 
			Else 
				
				If (Num:C11($eEntity[$queryField])=Form:C1466.current_item[$queryValue])
					SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
					If (Is Windows:C1573)
						SET MENU ITEM STYLE:C425($menu; -1; Bold:K14:2)
					End if 
				End if 
				
			End if 
			
		End for each 
		$choose:=Dynamic pop up menu:C1006($menu)
		RELEASE MENU:C978($menu)
		
		Case of 
			: ($choose#"")
				$eEntity:=ds:C1482[$dataClass].get($choose)
				Form:C1466.current_item[$queryValue]:=$eEntity[$queryField]
		End case 
		
	End if 
	
	
Function get monthlyDepreciation()->$monthlyDepreciation : Real
	If (This:C1470.life#0)
		$monthlyDepreciation:=This:C1470.originalCost/This:C1470.life
	End if 
	
Function get monthInService()->$monthInService : Integer
	
	$monthInService:=Month of:C24(This:C1470.acquiredDate)
	$acquiredYear:=Year of:C25(This:C1470.acquiredDate)
	$currentYear:=Year of:C25(Current date:C33(*))
	$currentMonth:=Month of:C24(Current date:C33(*))
	Case of 
		: ($currentYear=$acquiredYear)
			$monthInService:=$currentMonth-$monthInService
			
		: ($currentYear>$acquiredYear)
			$monthInService:=(12-$monthInService)+(12*($currentYear-$acquiredYear-1))+$currentMonth
			
	End case 
	
Function get totalAccDepreciation()->$totalAccDepreciation : Real
	
	Case of 
		: (This:C1470.monthInService>=This:C1470.life)
			$totalAccDepreciation:=This:C1470.monthlyDepreciation*This:C1470.life
			
		Else 
			$totalAccDepreciation:=This:C1470.monthlyDepreciation*Num:C11(This:C1470.monthInService)
			
	End case 
	
	
local Function get acquiredDate()->$date : Date
	$date:=This:C1470.acquiredStmp=0 ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate(This:C1470.acquiredStmp; True:C214)
	
local Function set acquiredDate($date : Date)
	This:C1470.acquiredStmp:=$date=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build($date)
	
local Function get divestDate()->$date : Date
	$date:=This:C1470.divestStmp=0 ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate(This:C1470.divestStmp; True:C214)
	
local Function set divestDate($date : Date)
	This:C1470.divestStmp:=$date=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build($date)
	
local Function get bookValue()->$bookValue : Real
	Case of 
			
		: (This:C1470.monthInService>=This:C1470.life)
			$bookValue:=0
		: (This:C1470.isScrapped=True:C214) & (This:C1470.divestDate<=Current date:C33(*))
			$bookValue:=0
			This:C1470.totalAccDepreciation:=This:C1470.originalCost
			
		Else 
			$bookValue:=Round:C94(This:C1470.originalCost-This:C1470.totalAccDepreciation; 2)
			
	End case 