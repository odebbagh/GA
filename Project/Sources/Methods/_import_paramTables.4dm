//%attributes = {}
// _import_paramTables($tables; $reportName) -> lines
// Shared by __import_quote_param and __import_lead_param. Each item of $tables is
// {table: pointer; dataclass; file; idField; withMoreData}: the file is read from the data
// folder's DataJson and replaces the table's records (code, name, color, the id field and, when
// withMoreData is True, moreData). A table whose file is missing or not a JSON array is left as it is:
// it is only emptied once its file has been read. Records with neither code nor name are skipped.
// The lines of the report are returned and written to Project/imports/<$reportName>.
#DECLARE($tables : Collection; $reportName : Text)->$lines : Collection

var $t : Object
var $q : Object
var $file : 4D:C1709.File
var $records : Collection
var $e : 4D:C1709.Entity
var $info : Object
var $nbSaved : Integer
var $nbSkipped : Integer
var $nbFailed : Integer

$lines:=New collection:C1472($reportName+" - "+String:C10(Current date:C33)+" "+String:C10(Current time:C178); "")
For each ($t; $tables)
	$file:=Folder:C1567(fk data folder:K87:12).file("DataJson/"+$t.file)
	If (Not:C34($file.exists))
		$lines.push($t.dataclass+": "+$t.file+" missing, table left as it is")
		continue
	End if
	$records:=JSON Parse:C1218($file.getText())
	If (Value type:C1509($records)#Is collection:K8:32)
		$lines.push($t.dataclass+": "+$t.file+" is not a JSON array, table left as it is")
		continue
	End if

	TRUNCATE TABLE:C1051($t.table->)
	$nbSaved:=0
	$nbSkipped:=0
	$nbFailed:=0
	For each ($q; $records)
		If (String:C10($q.code)="") && (String:C10($q.name)="")
			$nbSkipped+=1
			continue
		End if
		$e:=ds:C1482[$t.dataclass].new()
		$e.code:=String:C10($q.code)
		$e.name:=String:C10($q.name)
		$e.color:=String:C10($q.color)
		$e[$t.idField]:=Num:C11($q[$t.idField])
		If (Bool:C1537($t.withMoreData)) && ($q.moreData#Null:C1517)
			$e.moreData:=$q.moreData
		End if
		$info:=$e.save()
		If ($info.success)
			$nbSaved+=1
		Else
			$nbFailed+=1
		End if
	End for each
	$lines.push($t.dataclass+": "+String:C10($nbSaved)+" imported"\
		+(($nbSkipped>0) ? ", "+String:C10($nbSkipped)+" empty skipped" : "")\
		+(($nbFailed>0) ? ", "+String:C10($nbFailed)+" not saved" : ""))
End for each

Folder:C1567(fk database folder:K87:14).folder("Project/imports").file($reportName).setText($lines.join("\r\n"))
