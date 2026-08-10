//%attributes = {}

// Export legacy [Steps_Files]: scalar fields + blob arrays that are actually used (see $record.arrays).
// Run against the OLD database where GET_VAR_FROM_BLOB matches SET_VAR_TO_BLOB types/order.
// Copy into this framework project after production export if needed.
//
// Replace [Steps_Files:119] if your Structure uses another table index.

var $records : Collection
var $record : Object
var $arrays : Object
var $resourcesFolder : 4D:C1709.Folder
var $exportsFolder : 4D:C1709.Folder
var $file : 4D:C1709.File
var $i : Integer
var $sz : Integer
var $col : Collection

// --- Full blob signature (must match legacy serialization; includes unused slots) ---
ARRAY LONGINT:C221(a_lotsinjob; 0)
ARRAY TEXT:C222(a_tsdesc; 0)
ARRAY LONGINT:C221(a_tsnum; 0)
ARRAY TEXT:C222(a_tstypestring; 0)
ARRAY LONGINT:C221(a_ttime; 0)
ARRAY LONGINT:C221(a_tstype; 0)
ARRAY BOOLEAN:C215(a_tsss; 0)
ARRAY TEXT:C222(a_tsalert; 0)
ARRAY TEXT:C222(a_Area; 0)
ARRAY REAL:C219(a_tsyield; 0)
ARRAY REAL:C219(a_tsalltime; 0)
ARRAY REAL:C219(a_tempC; 0)
ARRAY LONGINT:C221(a_template_repeat; 0)
ARRAY REAL:C219(a_planhrs; 0)
ARRAY TEXT:C222(A_BomForStep; 0)
ARRAY LONGINT:C221(A_StepProperty; 0)
ARRAY TEXT:C222(A_StepPropertyinText; 0)
ARRAY TEXT:C222(A_TSBCRecord; 0)
ARRAY DATE:C224(A_DATEOUT; 0)
ARRAY LONGINT:C221(A_BOMRESOLVED; 0)
ARRAY TEXT:C222(A_TS_SPEC; 0)
ARRAY TEXT:C222(A_TS_SetupSheet; 0)

$records:=New collection:C1472()

ALL RECORDS:C47([Steps_Files:119])

While (Not:C34(End selection:C36([Steps_Files:119])))
	
	$arrays:=New object:C1471
	
	If (BLOB size:C605([Steps_Files:119]DescriptionBlob)>0)
		
		GET_VAR_FROM_BLOB(->[Steps_Files:119]DescriptionBlob; ->a_lotsinjob; ->a_tsdesc; ->a_tsnum; ->a_tstypestring; ->a_ttime; ->a_tstype; ->a_tsss; ->a_tsalert; ->a_Area; ->a_tsyield; ->a_tsalltime; ->a_tempC; ->a_template_repeat; ->a_planhrs; ->A_BomForStep; ->A_StepProperty; ->A_StepPropertyinText; ->A_TSBCRecord; ->A_DATEOUT; ->A_BOMRESOLVED; ->A_TS_SPEC; ->A_TS_SetupSheet)
		
		// USED arrays only (per usage scan): push each slot into a collection
		$sz:=Size of array:C274(a_tsdesc)
		$col:=New collection:C1472()
		For ($i; 1; $sz)
			$col.push(a_tsdesc{$i})
		End for 
		$arrays.a_tsdesc:=$col
		
		$sz:=Size of array:C274(a_tsnum)
		$col:=New collection:C1472()
		For ($i; 1; $sz)
			$col.push(a_tsnum{$i})
		End for 
		$arrays.a_tsnum:=$col
		
		$sz:=Size of array:C274(a_ttime)
		$col:=New collection:C1472()
		For ($i; 1; $sz)
			$col.push(a_ttime{$i})
		End for 
		$arrays.a_ttime:=$col
		
		$sz:=Size of array:C274(a_tstype)
		$col:=New collection:C1472()
		For ($i; 1; $sz)
			$col.push(a_tstype{$i})
		End for 
		$arrays.a_tstype:=$col
		
		$sz:=Size of array:C274(a_tsalert)
		$col:=New collection:C1472()
		For ($i; 1; $sz)
			$col.push(a_tsalert{$i})
		End for 
		$arrays.a_tsalert:=$col
		
		$sz:=Size of array:C274(a_Area)
		$col:=New collection:C1472()
		For ($i; 1; $sz)
			$col.push(a_Area{$i})
		End for 
		$arrays.a_Area:=$col
		
		$sz:=Size of array:C274(a_tsyield)
		$col:=New collection:C1472()
		For ($i; 1; $sz)
			$col.push(a_tsyield{$i})
		End for 
		$arrays.a_tsyield:=$col
		
		$sz:=Size of array:C274(a_tempC)
		$col:=New collection:C1472()
		For ($i; 1; $sz)
			$col.push(a_tempC{$i})
		End for 
		$arrays.a_tempC:=$col
		
		$sz:=Size of array:C274(a_template_repeat)
		$col:=New collection:C1472()
		For ($i; 1; $sz)
			$col.push(a_template_repeat{$i})
		End for 
		$arrays.a_template_repeat:=$col
		
		$sz:=Size of array:C274(a_planhrs)
		$col:=New collection:C1472()
		For ($i; 1; $sz)
			$col.push(a_planhrs{$i})
		End for 
		$arrays.a_planhrs:=$col
		
		$sz:=Size of array:C274(A_BomForStep)
		$col:=New collection:C1472()
		For ($i; 1; $sz)
			$col.push(A_BomForStep{$i})
		End for 
		$arrays.A_BomForStep:=$col
		
		$sz:=Size of array:C274(A_StepProperty)
		$col:=New collection:C1472()
		For ($i; 1; $sz)
			$col.push(A_StepProperty{$i})
		End for 
		$arrays.A_StepProperty:=$col
		
		$sz:=Size of array:C274(A_StepPropertyinText)
		$col:=New collection:C1472()
		For ($i; 1; $sz)
			$col.push(A_StepPropertyinText{$i})
		End for 
		$arrays.A_StepPropertyinText:=$col
		
		$sz:=Size of array:C274(A_TS_SPEC)
		$col:=New collection:C1472()
		For ($i; 1; $sz)
			$col.push(A_TS_SPEC{$i})
		End for 
		$arrays.A_TS_SPEC:=$col
		
	Else 
		
		$arrays.a_tsdesc:=New collection:C1472()
		$arrays.a_tsnum:=New collection:C1472()
		$arrays.a_ttime:=New collection:C1472()
		$arrays.a_tstype:=New collection:C1472()
		$arrays.a_tsalert:=New collection:C1472()
		$arrays.a_Area:=New collection:C1472()
		$arrays.a_tsyield:=New collection:C1472()
		$arrays.a_tempC:=New collection:C1472()
		$arrays.a_template_repeat:=New collection:C1472()
		$arrays.a_planhrs:=New collection:C1472()
		$arrays.A_BomForStep:=New collection:C1472()
		$arrays.A_StepProperty:=New collection:C1472()
		$arrays.A_StepPropertyinText:=New collection:C1472()
		$arrays.A_TS_SPEC:=New collection:C1472()
		
	End if 
	
	$record:=New object:C1471(\
		"Name"; [Steps_Files:119]Name; \
		"Customer"; [Steps_Files:119]Customer; \
		"Date_made"; [Steps_Files:119]Date_made; \
		"Made_by"; [Steps_Files:119]Made_by; \
		"Date_mod"; [Steps_Files:119]Date_mod; \
		"Mod_by"; [Steps_Files:119]Mod_by; \
		"Mod_history"; [Steps_Files:119]Mod_history; \
		"arrays"; $arrays\
		)
	
	$records.push($record)
	NEXT RECORD:C51([Steps_Files:119])
End while 

$resourcesFolder:=Folder:C1567(fk resources folder:K87:11)
$exportsFolder:=$resourcesFolder.folder("exports")

If (Not:C34($exportsFolder.exists))
	$exportsFolder.create()
End if 

$file:=$exportsFolder.file("steps_files_export.json")

If (Not:C34($file.exists))
	$file.create()
End if 

$file.setText(JSON Stringify:C1217($records))

ALERT:C41("Export termine: "+$file.platformPath+" | records: "+String:C10($records.length))
