

Case of 
		
	: (Form event code:C388=On Load:K2:1)
		// Form.BIN is the datasource of the form object
		
		Form:C1466.bin:=New object:C1471
		Form:C1466.bin.values:=New collection:C1472("Bin1"; \
			"Bin2"; "Bin3"; "Bin4"; "Bin5"; "Bin6"; \
			"Bin7"; "Bin8"; "Bin9"; "Bin10"; "Bin11"; \
			"Bin12"; "Bin13"; "Bin14"; "Bin15"; "Bin16"; \
			"Bin17"; "Bin18"; "Bin19"; "Bin20"; "Bin21"; \
			"Bin22"; "Bin23"; "Bin24"; "Bin25"; "Bin26"; \
			"Bin27"; "Bin28"; "Bin29"; "Bin30"; "Bin31"; "Bin32")
		Form:C1466.bin.index:=-1
		Form:C1466.bin.currentValue:="Select a Bin"
		
		Form:C1466.description:=""
		
End case 