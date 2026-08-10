//%attributes = {}

// Purpose: Scan every [Steps_Files] row, run GET_VAR_FROM_BLOB on DescriptionBlob with the same
// signature as your legacy app, and report which arrays never hold a non-default value (always empty
// or type default) across the whole table.
//
// Run this on the OLD database (classic tables / Blob field). If GET_VAR_FROM_BLOB fails or types
// do not match what SET_VAR_TO_BLOB used, adjust the ARRAY declarations below to match your compiler.
// Replace every [Steps_Files:119] with your actual table token from Structure if different.
//
// Output: Text file next to the database: steps_files_blob_array_usage_report.txt

var $report : Text
var $dataFolder : 4D:C1709.Folder
var $outFile : 4D:C1709.File
var $totalRec : Integer
var $blobEmptyCount : Integer
var $blobReadCount : Integer
var $j : Integer
var $sz : Integer

// --- Per-array "seen meaningful value at least once" flags (must mirror ARRAY list below) ---
var $has_a_lotsinjob : Boolean
var $has_a_tsdesc : Boolean
var $has_a_tsnum : Boolean
var $has_a_tstypestring : Boolean
var $has_a_ttime : Boolean
var $has_a_tstype : Boolean
var $has_a_tsss : Boolean
var $has_a_tsalert : Boolean
var $has_a_Area : Boolean
var $has_a_tsyield : Boolean
var $has_a_tsalltime : Boolean
var $has_a_tempC : Boolean
var $has_a_template_repeat : Boolean
var $has_a_planhrs : Boolean
var $has_A_BomForStep : Boolean
var $has_A_StepProperty : Boolean
var $has_A_StepPropertyinText : Boolean
var $has_A_TSBCRecord : Boolean
var $has_A_DATEOUT : Boolean
var $has_A_BOMRESOLVED : Boolean
var $has_A_TS_SPEC : Boolean
var $has_A_TS_SetupSheet : Boolean

// --- ARRAY types must match the legacy serialization exactly ----------------------------------
ARRAY LONGINT:C221(a_lotsinjob; 0)
ARRAY TEXT:C222(a_tsdesc; 0)
ARRAY LONGINT:C221(a_tsnum; 0)
ARRAY TEXT:C222(a_tstypestring; 0)
ARRAY LONGINT:C221(a_ttime; 0)
ARRAY LONGINT:C221(a_tstype; 0)
ARRAY TEXT:C222(a_tsss; 0)
ARRAY TEXT:C222(a_tsalert; 0)
ARRAY TEXT:C222(a_Area; 0)
ARRAY REAL:C219(a_tsyield; 0)
ARRAY REAL:C219(a_tsalltime; 0)
ARRAY REAL:C219(a_tempC; 0)
ARRAY LONGINT:C221(a_template_repeat; 0)
ARRAY REAL:C219(a_planhrs; 0)
ARRAY LONGINT:C221(A_BomForStep; 0)
ARRAY LONGINT:C221(A_StepProperty; 0)
ARRAY TEXT:C222(A_StepPropertyinText; 0)
ARRAY LONGINT:C221(A_TSBCRecord; 0)
ARRAY LONGINT:C221(A_DATEOUT; 0)
ARRAY BOOLEAN:C215(A_BOMRESOLVED; 0)
ARRAY TEXT:C222(A_TS_SPEC; 0)
ARRAY TEXT:C222(A_TS_SetupSheet; 0)

$has_a_lotsinjob:=False:C215
$has_a_tsdesc:=False:C215
$has_a_tsnum:=False:C215
$has_a_tstypestring:=False:C215
$has_a_ttime:=False:C215
$has_a_tstype:=False:C215
$has_a_tsss:=False:C215
$has_a_tsalert:=False:C215
$has_a_Area:=False:C215
$has_a_tsyield:=False:C215
$has_a_tsalltime:=False:C215
$has_a_tempC:=False:C215
$has_a_template_repeat:=False:C215
$has_a_planhrs:=False:C215
$has_A_BomForStep:=False:C215
$has_A_StepProperty:=False:C215
$has_A_StepPropertyinText:=False:C215
$has_A_TSBCRecord:=False:C215
$has_A_DATEOUT:=False:C215
$has_A_BOMRESOLVED:=False:C215
$has_A_TS_SPEC:=False:C215
$has_A_TS_SetupSheet:=False:C215

$totalRec:=0
$blobEmptyCount:=0
$blobReadCount:=0

ALL RECORDS:C47([Steps_Files:119])

While (Not:C34(End selection:C36([Steps_Files:119])))
	
	$totalRec:=$totalRec+1
	
	If (BLOB size:C605([Steps_Files:119]DescriptionBlob)=0)
		$blobEmptyCount:=$blobEmptyCount+1
	Else 
		
		$blobReadCount:=$blobReadCount+1
		
		GET_VAR_FROM_BLOB(->[Steps_Files:119]DescriptionBlob; ->a_lotsinjob; ->a_tsdesc; ->a_tsnum; ->a_tstypestring; ->a_ttime; ->a_tstype; ->a_tsss; ->a_tsalert; ->a_Area; ->a_tsyield; ->a_tsalltime; ->a_tempC; ->a_template_repeat; ->a_planhrs; ->A_BomForStep; ->A_StepProperty; ->A_StepPropertyinText; ->A_TSBCRecord; ->A_DATEOUT; ->A_BOMRESOLVED; ->A_TS_SPEC; ->A_TS_SetupSheet)
		
		If (Not:C34($has_a_lotsinjob))
			$sz:=Size of array:C274(a_lotsinjob)
			For ($j; 1; $sz)
				If (a_lotsinjob{$j}#0)
					$has_a_lotsinjob:=True:C214
					$j:=$sz+1
				End if 
			End for 
		End if 
		
		If (Not:C34($has_a_tsdesc))
			$sz:=Size of array:C274(a_tsdesc)
			For ($j; 1; $sz)
				If (a_tsdesc{$j}#"")
					$has_a_tsdesc:=True:C214
					$j:=$sz+1
				End if 
			End for 
		End if 
		
		If (Not:C34($has_a_tsnum))
			$sz:=Size of array:C274(a_tsnum)
			For ($j; 1; $sz)
				If (a_tsnum{$j}#0)
					$has_a_tsnum:=True:C214
					$j:=$sz+1
				End if 
			End for 
		End if 
		
		If (Not:C34($has_a_tstypestring))
			$sz:=Size of array:C274(a_tstypestring)
			For ($j; 1; $sz)
				If (a_tstypestring{$j}#"")
					$has_a_tstypestring:=True:C214
					$j:=$sz+1
				End if 
			End for 
		End if 
		
		If (Not:C34($has_a_ttime))
			$sz:=Size of array:C274(a_ttime)
			For ($j; 1; $sz)
				If (a_ttime{$j}#0)
					$has_a_ttime:=True:C214
					$j:=$sz+1
				End if 
			End for 
		End if 
		
		If (Not:C34($has_a_tstype))
			$sz:=Size of array:C274(a_tstype)
			For ($j; 1; $sz)
				If (a_tstype{$j}#0)
					$has_a_tstype:=True:C214
					$j:=$sz+1
				End if 
			End for 
		End if 
		
		If (Not:C34($has_a_tsss))
			$sz:=Size of array:C274(a_tsss)
			For ($j; 1; $sz)
				If (a_tsss{$j}#"")
					$has_a_tsss:=True:C214
					$j:=$sz+1
				End if 
			End for 
		End if 
		
		If (Not:C34($has_a_tsalert))
			$sz:=Size of array:C274(a_tsalert)
			For ($j; 1; $sz)
				If (a_tsalert{$j}#"")
					$has_a_tsalert:=True:C214
					$j:=$sz+1
				End if 
			End for 
		End if 
		
		If (Not:C34($has_a_Area))
			$sz:=Size of array:C274(a_Area)
			For ($j; 1; $sz)
				If (a_Area{$j}#"")
					$has_a_Area:=True:C214
					$j:=$sz+1
				End if 
			End for 
		End if 
		
		If (Not:C34($has_a_tsyield))
			$sz:=Size of array:C274(a_tsyield)
			For ($j; 1; $sz)
				If (a_tsyield{$j}#0)
					$has_a_tsyield:=True:C214
					$j:=$sz+1
				End if 
			End for 
		End if 
		
		If (Not:C34($has_a_tsalltime))
			$sz:=Size of array:C274(a_tsalltime)
			For ($j; 1; $sz)
				If (a_tsalltime{$j}#0)
					$has_a_tsalltime:=True:C214
					$j:=$sz+1
				End if 
			End for 
		End if 
		
		If (Not:C34($has_a_tempC))
			$sz:=Size of array:C274(a_tempC)
			For ($j; 1; $sz)
				If (a_tempC{$j}#0)
					$has_a_tempC:=True:C214
					$j:=$sz+1
				End if 
			End for 
		End if 
		
		If (Not:C34($has_a_template_repeat))
			$sz:=Size of array:C274(a_template_repeat)
			For ($j; 1; $sz)
				If (a_template_repeat{$j}#0)
					$has_a_template_repeat:=True:C214
					$j:=$sz+1
				End if 
			End for 
		End if 
		
		If (Not:C34($has_a_planhrs))
			$sz:=Size of array:C274(a_planhrs)
			For ($j; 1; $sz)
				If (a_planhrs{$j}#0)
					$has_a_planhrs:=True:C214
					$j:=$sz+1
				End if 
			End for 
		End if 
		
		If (Not:C34($has_A_BomForStep))
			$sz:=Size of array:C274(A_BomForStep)
			For ($j; 1; $sz)
				If (A_BomForStep{$j}#0)
					$has_A_BomForStep:=True:C214
					$j:=$sz+1
				End if 
			End for 
		End if 
		
		If (Not:C34($has_A_StepProperty))
			$sz:=Size of array:C274(A_StepProperty)
			For ($j; 1; $sz)
				If (A_StepProperty{$j}#0)
					$has_A_StepProperty:=True:C214
					$j:=$sz+1
				End if 
			End for 
		End if 
		
		If (Not:C34($has_A_StepPropertyinText))
			$sz:=Size of array:C274(A_StepPropertyinText)
			For ($j; 1; $sz)
				If (A_StepPropertyinText{$j}#"")
					$has_A_StepPropertyinText:=True:C214
					$j:=$sz+1
				End if 
			End for 
		End if 
		
		If (Not:C34($has_A_TSBCRecord))
			$sz:=Size of array:C274(A_TSBCRecord)
			For ($j; 1; $sz)
				If (A_TSBCRecord{$j}#0)
					$has_A_TSBCRecord:=True:C214
					$j:=$sz+1
				End if 
			End for 
		End if 
		
		If (Not:C34($has_A_DATEOUT))
			$sz:=Size of array:C274(A_DATEOUT)
			For ($j; 1; $sz)
				If (A_DATEOUT{$j}#0)
					$has_A_DATEOUT:=True:C214
					$j:=$sz+1
				End if 
			End for 
		End if 
		
		If (Not:C34($has_A_BOMRESOLVED))
			$sz:=Size of array:C274(A_BOMRESOLVED)
			For ($j; 1; $sz)
				If (A_BOMRESOLVED{$j}=True:C214)
					$has_A_BOMRESOLVED:=True:C214
					$j:=$sz+1
				End if 
			End for 
		End if 
		
		If (Not:C34($has_A_TS_SPEC))
			$sz:=Size of array:C274(A_TS_SPEC)
			For ($j; 1; $sz)
				If (A_TS_SPEC{$j}#"")
					$has_A_TS_SPEC:=True:C214
					$j:=$sz+1
				End if 
			End for 
		End if 
		
		If (Not:C34($has_A_TS_SetupSheet))
			$sz:=Size of array:C274(A_TS_SetupSheet)
			For ($j; 1; $sz)
				If (A_TS_SetupSheet{$j}#"")
					$has_A_TS_SetupSheet:=True:C214
					$j:=$sz+1
				End if 
			End for 
		End if 
		
	End if 
	
	NEXT RECORD:C51([Steps_Files:119])
End while 

$report:="Steps_Files.DescriptionBlob — array usage scan"+Char:C90(Carriage return:K15:38)
$report:=$report+"Total records: "+String:C10($totalRec)+Char:C90(Carriage return:K15:38)
$report:=$report+"Records with empty blob (size 0): "+String:C10($blobEmptyCount)+Char:C90(Carriage return:K15:38)
$report:=$report+"Records with blob read: "+String:C10($blobReadCount)+Char:C90(Carriage return:K15:38)
$report:=$report+Char:C90(Carriage return:K15:38)
$report:=$report+"UNUSED = no index holds a non-default value on any row (see ARRAY types in method)."+Char:C90(Carriage return:K15:38)
$report:=$report+Char:C90(Carriage return:K15:38)

$report:=$report+"a_lotsinjob          "+Choose:C955($has_a_lotsinjob; "USED"; "UNUSED")+Char:C90(Carriage return:K15:38)
$report:=$report+"a_tsdesc             "+Choose:C955($has_a_tsdesc; "USED"; "UNUSED")+Char:C90(Carriage return:K15:38)
$report:=$report+"a_tsnum              "+Choose:C955($has_a_tsnum; "USED"; "UNUSED")+Char:C90(Carriage return:K15:38)
$report:=$report+"a_tstypestring       "+Choose:C955($has_a_tstypestring; "USED"; "UNUSED")+Char:C90(Carriage return:K15:38)
$report:=$report+"a_ttime              "+Choose:C955($has_a_ttime; "USED"; "UNUSED")+Char:C90(Carriage return:K15:38)
$report:=$report+"a_tstype             "+Choose:C955($has_a_tstype; "USED"; "UNUSED")+Char:C90(Carriage return:K15:38)
$report:=$report+"a_tsss               "+Choose:C955($has_a_tsss; "USED"; "UNUSED")+Char:C90(Carriage return:K15:38)
$report:=$report+"a_tsalert            "+Choose:C955($has_a_tsalert; "USED"; "UNUSED")+Char:C90(Carriage return:K15:38)
$report:=$report+"a_Area               "+Choose:C955($has_a_Area; "USED"; "UNUSED")+Char:C90(Carriage return:K15:38)
$report:=$report+"a_tsyield            "+Choose:C955($has_a_tsyield; "USED"; "UNUSED")+Char:C90(Carriage return:K15:38)
$report:=$report+"a_tsalltime          "+Choose:C955($has_a_tsalltime; "USED"; "UNUSED")+Char:C90(Carriage return:K15:38)
$report:=$report+"a_tempC              "+Choose:C955($has_a_tempC; "USED"; "UNUSED")+Char:C90(Carriage return:K15:38)
$report:=$report+"a_template_repeat    "+Choose:C955($has_a_template_repeat; "USED"; "UNUSED")+Char:C90(Carriage return:K15:38)
$report:=$report+"a_planhrs            "+Choose:C955($has_a_planhrs; "USED"; "UNUSED")+Char:C90(Carriage return:K15:38)
$report:=$report+"A_BomForStep         "+Choose:C955($has_A_BomForStep; "USED"; "UNUSED")+Char:C90(Carriage return:K15:38)
$report:=$report+"A_StepProperty       "+Choose:C955($has_A_StepProperty; "USED"; "UNUSED")+Char:C90(Carriage return:K15:38)
$report:=$report+"A_StepPropertyinText "+Choose:C955($has_A_StepPropertyinText; "USED"; "UNUSED")+Char:C90(Carriage return:K15:38)
$report:=$report+"A_TSBCRecord         "+Choose:C955($has_A_TSBCRecord; "USED"; "UNUSED")+Char:C90(Carriage return:K15:38)
$report:=$report+"A_DATEOUT            "+Choose:C955($has_A_DATEOUT; "USED"; "UNUSED")+Char:C90(Carriage return:K15:38)
$report:=$report+"A_BOMRESOLVED        "+Choose:C955($has_A_BOMRESOLVED; "USED"; "UNUSED")+Char:C90(Carriage return:K15:38)
$report:=$report+"A_TS_SPEC            "+Choose:C955($has_A_TS_SPEC; "USED"; "UNUSED")+Char:C90(Carriage return:K15:38)
$report:=$report+"A_TS_SetupSheet      "+Choose:C955($has_A_TS_SetupSheet; "USED"; "UNUSED")+Char:C90(Carriage return:K15:38)

$dataFolder:=Folder:C1567(fk database folder:K87:14)
$outFile:=$dataFolder.file("steps_files_blob_array_usage_report.txt")
If (Not:C34($outFile.exists))
	$outFile.create()
End if 
$outFile.setText($report)

ALERT:C41("Report written to:"+Char:C90(Carriage return:K15:38)+$outFile.platformPath)
