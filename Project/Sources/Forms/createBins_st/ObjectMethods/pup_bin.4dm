

Case of 
	: (Form event code:C388=On Data Change:K2:15)
		
		$existingBinIndex:=Form:C1466.existingBins.indexOf(Form:C1466.bin.currentValue)
		If ($existingBinIndex#-1)
			
			Form:C1466.bin.index:=Form:C1466.bin.values.indexOf(Form:C1466.existingBins[$existingBinIndex].num)
			Form:C1466.binType.index:=Form:C1466.binType.values.indexOf(Form:C1466.existingBins[$existingBinIndex].type)
			
			Form:C1466.bin.currentValue:=Form:C1466.existingBins[$existingBinIndex].num
			Form:C1466.binType.currentValue:=Form:C1466.existingBins[$existingBinIndex].type
			
			Form:C1466.binDefinition.definition:=Form:C1466.existingBins[$existingBinIndex].definition
		End if 
End case 