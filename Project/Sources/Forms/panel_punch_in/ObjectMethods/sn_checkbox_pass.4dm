Case of
	: ((FORM Event:C1606.code=On Clicked:K2:4) | (FORM Event:C1606.code=On Data Change:K2:15))

		var $lot : cs:C1710.LotEntity
		var $lotItems : Collection
		var $idx : Collection
		var $restored : Object

		$lot:=Form:C1466.current_item.lot
		$nextSteps:=$lot.lotSteps.query("order > :1"; Form:C1466.current_item.order)

		If (Not:C34(Form:C1466.snItem.pass))

			// failing an SN at a step immediately fails it at the lot level
			If (($lot.snTable#Null:C1517) && ($lot.snTable.items#Null:C1517))
				$lotItems:=$lot.snTable.items.query("id = :1"; Form:C1466.snItem.id)
				If ($lotItems.length=1)
					$lotItems[0].pass:=False:C215
				End if
			End if
			$lot.snTable:=$lot.snTable  // touch the object attribute so save() persists the nested change
			$lot.save()

			// a failed SN no longer appears on the following steps
			For each ($step; $nextSteps)
				If (($step.snTable#Null:C1517) && ($step.snTable.items#Null:C1517))
					$idx:=$step.snTable.items.indices("id = :1"; Form:C1466.snItem.id)
					If ($idx.length=1)
						$step.snTable.items:=$step.snTable.items.remove($idx[0])
						$step.snTable:=$step.snTable
						$step.save()
					End if
				End if
			End for each

		Else

			// re-marked as pass: restore the lot flag and put the SN back on the following steps
			If (($lot.snTable#Null:C1517) && ($lot.snTable.items#Null:C1517))
				$lotItems:=$lot.snTable.items.query("id = :1"; Form:C1466.snItem.id)
				If ($lotItems.length=1)
					$lotItems[0].pass:=True:C214
				End if
			End if
			$lot.snTable:=$lot.snTable
			$lot.save()

			For each ($step; $nextSteps)
				If (($step.snTable#Null:C1517) && ($step.snTable.items#Null:C1517))
					If ($step.snTable.items.query("id = :1"; Form:C1466.snItem.id).length=0)
						$restored:=OB Copy:C1225(Form:C1466.snItem)
						$restored.pass:=True:C214
						$step.snTable.items:=$step.snTable.items.push($restored).orderBy("id asc")
						$step.snTable:=$step.snTable
						$step.save()
					End if
				End if
			End for each

		End if
End case
