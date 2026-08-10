Case of 
	: (FORM Event:C1606.code=On Clicked:K2:4)
		
		Form:C1466.child_lots.push(New object:C1471(\
			"lotSubNumber"; Num:C11(Form:C1466.lot.lotNumber); \
			"totalTransferred"; 100; \
			"transferedGoods"; 70; \
			"transferedRejects"; 20\
			))
		
		For ($i; 1; Form:C1466.splitLotCount)
			Form:C1466.child_lots.push(New object:C1471(\
				"lotSubNumber"; $i; \
				"totalTransferred"; 0; \
				"transferedGoods"; 0; \
				"transferedRejects"; 0\
				))
		End for 
		
		If (Form:C1466.splitStepWithBins)
			FORM GOTO PAGE:C247(3)
		Else 
			FORM GOTO PAGE:C247(2)
		End if 
		
End case 
