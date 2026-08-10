Case of 
	: (FORM Event:C1606.code=On Load:K2:1)
		Form:C1466.hList:=New list:C375
		
		Form:C1466.lb_items:=New collection:C1472()
		$count:=ds:C1482.PurchaseOrder.all().length
		
		For each ($po_e; ds:C1482.PurchaseOrder.all().orderBy("poNumber"))
			
			$subList:=New list:C375
			
			$po:=New object:C1471(\
				"uuid"; $po_e.UUID; \
				"poNumber"; $po_e.poNumber; \
				"id"; Form:C1466.lb_items.length+1; \
				"subs"; New collection:C1472()\
				)
			
			For each ($line; $po_e.lineItems)
				$id:=$count+$po.subs.length+$po.id
				
				$po.subs.push(New object:C1471(\
					"uuid"; $line.UUID; \
					"description"; $line.description; \
					"id"; $id\
					))
				
				APPEND TO LIST:C376($subList; $line.description; $id)
			End for each 
			
			APPEND TO LIST:C376(Form:C1466.hList; String:C10($po.poNumber); $po.id; $subList; False:C215)
			
			Form:C1466.lb_items.push($po)
		End for each 
End case 