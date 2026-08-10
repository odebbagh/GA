//%attributes = {}


//TRUNCATE TABLE([UnitCost])

//var $eUnitCost : cs.UnitCostEntity

//$unitCost_log:=Folder(fk data folder).file("DataJson/unitCost_export.json")

//If ($unitCost_log.exists)
//$unitCosts:=JSON Parse($unitCost_log.getText())

//For each ($unitCost; $unitCosts)

//$eUnitCost:=ds.UnitCost.new()
////$eUnitCost.device:=$unitCost.Device
//$eUnitCost.singularUnitPrice:=$unitCost.Singular_Unit_Price
//$eUnitCost.minJobCharge:=$unitCost.MinJobCharge
//$eUnitCost.byStep:=$unitCost.By_Step
//$eUnitCost.stepCharges:=$unitCost.Step_Charges


//$res:=$eUnitCost.save()
//If (Not($res.success))
//TRACE
//End if 

//End for each 

//End if 
