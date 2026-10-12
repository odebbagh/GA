//%attributes = {}
// _fix_inventoryBinPath($text) -> the bin path a legacy location text stands for, "" when unknown.
// The legacy app glued its warehouse name to the location ("WareHouseCBNT1 B1"); the bins of this
// app are paths ("Warehouse/CBNT/CBNT1/B1", _import_warehouseBins). The rules cover the 113 texts
// found by _diag_inventory (Oct 2026). For _fix_inventoryLegacy.
#DECLARE($text : Text)->$path : Text

var $t; $rest : Text
var $pos; $len : Integer
ARRAY LONGINT:C221($starts; 0)
ARRAY LONGINT:C221($lengths; 0)

$path:=""
$t:=cs:C1710.sfw_string.me.trimSpace($text)
If ($t="")
	return
End if
If (Position:C15("/"; $t)>0)
	$path:=$t  // already a path
	return
End if

Case of
	: (Match regex:C1019("^LineIQC B(\\d+)$"; $t; 1; $starts; $lengths))
		$path:="Line/IQC B"+Substring:C12($t; $starts{1}; $lengths{1})

	: (Match regex:C1019("^(ASSY OSS RACK|BACK-END)IQC B(\\d+)$"; $t; 1; $starts; $lengths))
		$path:="Warehouse/Racks/"+Substring:C12($t; $starts{1}; $lengths{1})+"/IQC B"+Substring:C12($t; $starts{2}; $lengths{2})

	: ($t="WareHouse@")
		$rest:=cs:C1710.sfw_string.me.trimSpace(Substring:C12($t; 10))
		Case of
			: (Match regex:C1019("^CBNT ?(\\d+) B(?:IN )?(\\d+)$"; $rest; 1; $starts; $lengths))
				$path:="Warehouse/CBNT/CBNT"+Substring:C12($rest; $starts{1}; $lengths{1})+"/B"+Substring:C12($rest; $starts{2}; $lengths{2})
			: ($rest="CBNT 3")
				$path:="Warehouse/CBNT/CBNT 3"  // a bin of its own, beside CBNT3
			: (Match regex:C1019("^CBNT ?(\\d+)$"; $rest; 1; $starts; $lengths))
				$path:="Warehouse/CBNT/CBNT"+Substring:C12($rest; $starts{1}; $lengths{1})
			: (Match regex:C1019("^Inventory CBNT (\\d+) ROW ([A-Z])$"; $rest; 1; $starts; $lengths))
				$path:="Warehouse/Inventory/CBNT "+Substring:C12($rest; $starts{1}; $lengths{1})+"/ROW "+Substring:C12($rest; $starts{2}; $lengths{2})
			: (Match regex:C1019("^Inventory ?Desiccator Bank (\\d+)$"; $rest; 1; $starts; $lengths))
				$path:="Warehouse/Inventory/Desiccator Bank/"+Substring:C12($rest; $starts{1}; $lengths{1})
			: (Match regex:C1019("^Inventory (.+)$"; $rest; 1; $starts; $lengths))
				$path:="Warehouse/Inventory/"+Substring:C12($rest; $starts{1}; $lengths{1})  // Shelve B, Milpitas, OQC Rack, Roller
			: ($rest="LAB")
				$path:="Warehouse/LAB"
			: ($rest="LAB OSS RACK")
				$path:="Warehouse/LAB/LAB OSS RACK"
			: ($rest="BACK-END") || ($rest="BACKEND")
				$path:="Warehouse/Racks/BACK-END"
			: ($rest="ASSY OSS RACK")
				$path:="Warehouse/Racks/ASSY OSS RACK"
			: (Match regex:C1019("^FOL-CABINET (\\d+)$"; $rest; 1; $starts; $lengths))
				$path:="Warehouse/Racks/FOL-CABINET "+Substring:C12($rest; $starts{1}; $lengths{1})
			: ($rest="DESICCATOR")
				$path:="Warehouse/Desiccator"
			: (Match regex:C1019("^Freezer (.+)$"; $rest; 1; $starts; $lengths))
				$path:="Warehouse/Freezer/"+Substring:C12($rest; $starts{1}; $lengths{1})  // 2, 1 (FOL)
			: (Match regex:C1019("^Vault (\\d+)$"; $rest; 1; $starts; $lengths))
				$path:="Warehouse/Vault/"+Substring:C12($rest; $starts{1}; $lengths{1})
			: ($rest="Engineering")
				$path:="Warehouse/Engineering"
			: ($rest="Line")
				$path:="Line"
		End case
End case
