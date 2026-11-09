//%attributes = {}
// _ga_exportWipReport
// Planning > list action "WIP report to Excel": the WIP tracking report (ga_wipReport) of every
// active lot with work under way, whatever the list shows, filtered in the WIP_reportOptions
// dialog. Written as the other Excel exports to Resources/exportedData (folder WIP), then opened.

var $options; $report : Object
var $folder : 4D:C1709.Folder
var $file : 4D:C1709.File
var $now : Date
var $name : Text

$options:=cs:C1710.ga_wipReport.me.askOptions()
If ($options=Null:C1517)
	return
End if

$report:=cs:C1710.ga_wipReport.me.build($options)

$now:=Current date:C33
$name:="WIP_Report_"+String:C10(Year of:C25($now))+"-"+String:C10(Month of:C24($now); "00")+"-"+String:C10(Day of:C23($now); "00")+"_"+Replace string:C233(String:C10(Current time:C178; HH MM:K7:2); ":"; "")+".xlsx"
$folder:=Folder:C1567(Get 4D folder:C485(Current resources folder:K5:16)+"exportedData"+Folder separator:K24:12+"WIP"; fk platform path:K87:2)
$folder.create()
$file:=$folder.file($name)

VP Run offscreen area(cs:C1710.ga_wipExcel.new($report; $file.platformPath))

If ($file.exists)
	OPEN URL:C673($file.platformPath; *)
Else
	cs:C1710.sfw_dialog.me.alert("The WIP report could not be written to "+$file.platformPath+".")
End if
