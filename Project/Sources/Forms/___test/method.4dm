

Case of 
	: (Form event code:C388=On Load:K2:1)
		Form:C1466.paths:=New collection:C1472("ASSY OSS RACK/IQC/B1"; "ASSY OSS RACK/IQC/B10"; "ASSY OSS RACK/IQC/B15"; "ASSY OSS RACK/IQC/B16"; "ASSY OSS RACK/IQC/B20"; "ASSY OSS RACK/IQC/B7"; "ASSY OSS RACK/IQC/B8"; "ASSY OSS RACK/IQC/B9"; "BACKEND/IQC/B16"; "BACKEND/IQC/B20"; "Line/IQC/B1"; "Line/IQC/B10"; "Line/IQC/B11"; "Line/IQC/B12"; "Line/IQC/B15"; "Line/IQC/B16"; "Line/IQC/B19"; "Line/IQC/B20"; "Line/IQC/B5"; "Line/IQC/B7"; "Line/IQC/B8"; "WareHouse/ASSY OSS RACK"; "WareHouse/BACKEND"; "WareHouse/CBNT2/BIN 16"; "WareHouse/CBNT 3"; "WareHouse/CBNT1"; "WareHouse/CBNT1/B1"; "WareHouse/CBNT1/B10"; "WareHouse/CBNT1/B2"; "WareHouse/CBNT1/B3"; "WareHouse/CBNT1/B4"; "WareHouse/CBNT1/B5"; "WareHouse/CBNT1/B6"; "WareHouse/CBNT1/B7"; "WareHouse/CBNT1/B8"; "WareHouse/CBNT1/B9"; "WareHouse/CBNT10"; "WareHouse/CBNT11"; "WareHouse/CBNT12"; "WareHouse/CBNT2/B11"; "WareHouse/CBNT2/B12"; "WareHouse/CBNT2/B13"; "WareHouse/CBNT2/B14"; "WareHouse/CBNT2/B15"; "WareHouse/CBNT2/B16"; "WareHouse/CBNT2/B17"; "WareHouse/CBNT2/B18"; "WareHouse/CBNT2/B19"; "WareHouse/CBNT3/B21"; "WareHouse/CBNT4"; "WareHouse/DESICCATOR"; "WareHouse/Engineering"; "WareHouse/FOL-CABINET/75"; "WareHouse/FOL-CABINET/76"; "WareHouse/FOL-CABINET/77"; "WareHouse/FOL-CABINET/79"; "WareHouse/Freezer/1 (FOL)"; "WareHouse/Freezer/2"; "WareHouse/Inventory/CBNT 12/ROW A"; "WareHouse/Inventory/CBNT 12/ROW B"; "WareHouse/Inventory/CBNT 12/ROW C"; "WareHouse/Inventory/CBNT 12/ROW D"; "WareHouse/Inventory/CBNT 13/ROW A"; "WareHouse/Inventory/CBNT 13/ROW B"; "WareHouse/Inventory/CBNT 13/ROW C"; "WareHouse/Inventory/CBNT 13/ROW D"; "WareHouse/Inventory/CBNT 13/ROW E"; "WareHouse/Inventory/CBNT 14/ROW A"; "WareHouse/Inventory/CBNT 14/ROW C"; "WareHouse/Inventory/CBNT 14/ROW D"; "WareHouse/Inventory/CBNT 4/ROW A"; "WareHouse/Inventory/CBNT 4/ROW B"; "WareHouse/Inventory/CBNT 4/ROW C"; "WareHouse/Inventory/CBNT 4/ROW D"; "WareHouse/Inventory/CBNT 4/ROW E"; "WareHouse/Inventory/CBNT 5/ROW A"; "WareHouse/Inventory/CBNT 5/ROW B"; "WareHouse/Inventory/CBNT 5/ROW C"; "WareHouse/Inventory/CBNT 5/ROW D"; "WareHouse/Inventory/CBNT 6/ROW A"; "WareHouse/Inventory/CBNT 6/ROW B"; "WareHouse/Inventory/CBNT 6/ROW C"; "WareHouse/Inventory/CBNT 6/ROW D"; "WareHouse/Inventory/CBNT 6/ROW E"; "WareHouse/Inventory/CBNT 8/ROW A"; "WareHouse/Inventory/CBNT 8/ROW B"; "WareHouse/Inventory/CBNT 8/ROW C"; "WareHouse/Inventory/CBNT 8/ROW D"; "WareHouse/Inventory/CBNT 8/ROW E"; "WareHouse/Inventory/Milpitas"; "WareHouse/Inventory/OQC Rack"; "WareHouse/Inventory/Roller"; "WareHouse/Inventory/Shelve A"; "WareHouse/Inventory/Shelve B"; "WareHouse/Inventory/Shelve C"; "WareHouse/Inventory/Shelve E"; "WareHouse/Inventory/Shelve J"; "WareHouse/Inventory/Desiccator/Bank 22"; "WareHouse/Inventory/Desiccator/Bank 23"; "WareHouse/Inventory/Desiccator/Bank 24"; "WareHouse/Inventory/Desiccator/Bank 25"; "WareHouse/Inventory/Desiccator/Bank 26"; "WareHouse/LAB"; "WareHouse/LAB OSS RACK"; "WareHouse/Line"; "WareHouse/Vault/1"; "WareHouse/Vault/2")
		Form:C1466.sel1:=""
		Form:C1466.sel2:=""
		Form:C1466.sel3:=""
		Form:C1466.sel4:=""
		Form:C1466.selectedPath:=""
		OBJECT SET TITLE:C194(*; "pup_level1"; "Choisir emplacement")
		OBJECT SET VISIBLE:C603(*; "pup_level2"; False:C215)
		OBJECT SET VISIBLE:C603(*; "pup_level3"; False:C215)
		OBJECT SET VISIBLE:C603(*; "pup_level4"; False:C215)
	: (Form event code:C388=On Close Box:K2:21)
		CANCEL:C270
End case 

