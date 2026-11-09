//%attributes = {"executedOnServer":true}
// _import_allSrv($action; $param) -> Object
// The part of _import_all that has to happen on the server. In client/server the importers
// that read the data folder (DataJson, imports, GAF) are executedOnServer and read the
// SERVER's data folder; a 4D Remote client has none (Folder(fk data folder) raises "invalid
// constant" there), so the check is done here.
//   "check"  $param = collection of paths relative to the data folder ("DataJson/x.json",
//            "GAF/" for a folder) -> {missing: collection; dataFile: text}
//   "log"    $param = {name; text} (or just the text: import_all.txt) -> written to
//            Project/imports/<name> on the server -> {path: text}
//   "count"  $param = collection of dataclass names -> {counts: {name: records}}, -1 for a
//            dataclass that does not exist. Counted here so no record travels to the client.

#DECLARE($action : Text; $param : Variant)->$result : Object

var $rel; $name : Text
var $dataFolder : 4D:C1709.Folder
var $file : 4D:C1709.File
var $exists : Boolean

$result:={}

Case of
	: ($action="count")
		$result.counts:={}
		For each ($name; $param)
			$result.counts[$name]:=(ds:C1482[$name]=Null:C1517) ? -1 : ds:C1482[$name].getCount()
		End for each

	: ($action="check")
		$dataFolder:=Folder:C1567(fk data folder:K87:12)
		$result.missing:=[]
		$result.dataFile:=Data file:C490
		For each ($rel; $param)
			If (Substring:C12($rel; Length:C16($rel))="/")
				$exists:=$dataFolder.folder($rel).exists
			Else
				$exists:=$dataFolder.file($rel).exists
			End if
			If (Not:C34($exists))
				$result.missing.push($rel)
			End if
		End for each

	: ($action="log")
		If (Value type:C1509($param)=Is object:K8:27)
			$file:=Folder:C1567(fk database folder:K87:14).folder("Project/imports").file(String:C10($param.name))
			$file.setText(String:C10($param.text))
		Else
			$file:=Folder:C1567(fk database folder:K87:14).folder("Project/imports").file("import_all.txt")
			$file.setText(String:C10($param))
		End if
		$result.path:=$file.platformPath
End case
