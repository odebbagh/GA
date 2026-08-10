$isInModification:=sfw_checkIsInModification

If ($isInModification)
	$range:=SVG Find element ID by coordinates:C1054(*; "working_ranges_pict"; MouseX; MouseY)
	
	$attribute:=Form:C1466.period.name
	
	$workingRanges:=Form:C1466.schedule[$attribute].work.copy().orderBy()
	
	Case of 
		: ($range#"")
			$start:=Num:C11(Split string:C1554($range; "-").shift())
			$end:=Num:C11(Split string:C1554($range; "-").pop())
			
			$refmenus:=New collection:C1472()
			$menu:=Create menu:C408
			$refmenus.push($menu)
			
			$submenu:=Create menu:C408
			$refmenus.push($submenu)
			
			$indexOfPrevious:=$workingRanges.indexOf($start*900)-1
			If ($indexOfPrevious=-1)
				$qStart:=0
			Else 
				$qStart:=$workingRanges[$indexOfPrevious]\900
			End if 
			For ($q; $qStart; $end-1)
				APPEND MENU ITEM:C411($submenu; ds:C1482.sfw_readXliff("dateAndTime.startAt")+" "+String:C10(Time:C179($q*900); HH MM:K7:2))
				SET MENU ITEM PARAMETER:C1004($submenu; -1; $range+":"+String:C10($q*900)+"-"+String:C10($end*900))
				If ($q=$start)
					SET MENU ITEM MARK:C208($submenu; -1; Char:C90(18))
				End if 
			End for 
			APPEND MENU ITEM:C411($menu; ds:C1482.sfw_readXliff("dateAndTime.startAt")+" "+String:C10(Time:C179($start*900); HH MM:K7:2); $submenu)
			
			$submenu:=Create menu:C408
			$refmenus.push($submenu)
			$indexOfNext:=$workingRanges.indexOf($end*900)+1
			If ($indexOfNext>=$workingRanges.length)
				$qEnd:=96
			Else 
				$qEnd:=$workingRanges[$indexOfNext]\900
			End if 
			For ($q; $start+1; $qEnd)
				APPEND MENU ITEM:C411($submenu; ds:C1482.sfw_readXliff("dateAndTime.stopAt")+" "+String:C10(Time:C179($q*900); HH MM:K7:2))
				SET MENU ITEM PARAMETER:C1004($submenu; -1; $range+":"+String:C10($start*900)+"-"+String:C10($q*900))
				If ($q=$end)
					SET MENU ITEM MARK:C208($submenu; -1; Char:C90(18))
				End if 
			End for 
			APPEND MENU ITEM:C411($menu; ds:C1482.sfw_readXliff("dateAndTime.stopAt")+" "+String:C10(Time:C179($end*900); HH MM:K7:2); $submenu)
			
			APPEND MENU ITEM:C411($menu; "-")
			APPEND MENU ITEM:C411($menu; ds:C1482.sfw_readXliff("dateAndTime.remove"; "remove"))
			SET MENU ITEM PARAMETER:C1004($menu; -1; "remove:"+$range)
			APPEND MENU ITEM:C411($menu; ds:C1482.sfw_readXliff("dateAndTime.removeAll"; "remove all"))
			SET MENU ITEM PARAMETER:C1004($menu; -1; "removeall")
			
			$choose:=Dynamic pop up menu:C1006($menu)
			
			For each ($menu; $refmenus)
				RELEASE MENU:C978($menu)
			End for each 
			
		: ($range="")
			$quarterSize:=5
			$qCible:=MouseX\$quarterSize
			
			$refmenus:=New collection:C1472()
			$menu:=Create menu:C408
			$refmenus.push($menu)
			$qMin:=$qCible-3
			If ($qMin<0)
				$qMin:=0
			End if 
			$qMax:=$qCible+3
			If ($qMin>96)
				$qMin:=96
			End if 
			
			For ($q; $qMin; $qMax)
				APPEND MENU ITEM:C411($menu; ds:C1482.sfw_readXliff("dateAndTime.startAt")+" "+String:C10(Time:C179($q*900); HH MM:K7:2))
				SET MENU ITEM PARAMETER:C1004($menu; -1; String:C10($q*900)+"-"+String:C10(($q+1)*900))
			End for 
			
			$choose:=Dynamic pop up menu:C1006($menu; String:C10($qCible*900)+"-"+String:C10(($qCible+1)*900))
			
			For each ($menu; $refmenus)
				RELEASE MENU:C978($menu)
			End for each 
			
	End case 
	
	
	Case of 
		: ($choose="")
			$attribute:=""
			
		: ($choose="removeall")
			Form:C1466.schedule[$attribute].work:=New collection:C1472
			
		: ($choose="remove:@")
			$range:=Substring:C12($choose; 8)
			$start:=Num:C11(Split string:C1554($range; "-").shift())
			$end:=Num:C11(Split string:C1554($range; "-").pop())
			$workingRanges:=Form:C1466.schedule[$attribute].work
			$workingRanges.remove($workingRanges.indexOf($start*900))
			$workingRanges.remove($workingRanges.indexOf($end*900))
			
		: ($choose="@:@")
			$rangeBefore:=Split string:C1554($choose; ":").shift()
			$rangeAfter:=Split string:C1554($choose; ":").pop()
			$startBefore:=Num:C11(Split string:C1554($rangeBefore; "-").shift())*900
			$endBefore:=Num:C11(Split string:C1554($rangeBefore; "-").pop())*900
			$startAfter:=Num:C11(Split string:C1554($rangeAfter; "-").shift())
			$endafter:=Num:C11(Split string:C1554($rangeAfter; "-").pop())
			$workingRanges:=Form:C1466.schedule[$attribute].work.copy().orderBy()
			$workingRanges[$workingRanges.indexOf($startBefore)]:=$startAfter
			$workingRanges[$workingRanges.indexOf($endBefore)]:=$endafter
			Form:C1466.schedule[$attribute].work:=$workingRanges
			
		Else 
			$start:=Num:C11(Split string:C1554($choose; "-").shift())
			$end:=Num:C11(Split string:C1554($choose; "-").pop())
			
			Form:C1466.schedule[$attribute].work.push($start; $end)
			
	End case 
	
	If ($attribute#"")
		$workingRanges:=Form:C1466.schedule[$attribute].work.copy().orderBy()
		If ($workingRanges.length>0)
			$p:=1
			$previous:=$workingRanges[0]
			While ($p<$workingRanges.length)
				If ($workingRanges[$p]=$previous)
					$workingRanges.remove($p-1; 2)
					$p:=1
					$previous:=$workingRanges[0]
				Else 
					$previous:=$workingRanges[$p]
					$p:=$p+1
				End if 
			End while 
			
			$hquarters:=Split string:C1554("0;"*96; ";"; sk ignore empty strings:K86:1+sk trim spaces:K86:2)
			
			
			Form:C1466.schedule[$attribute].work:=$workingRanges
		End if 
		sfw_subpanel_schedule_draw($attribute)
		CALL SUBFORM CONTAINER:C1086(-98001)
		
	End if 
End if 