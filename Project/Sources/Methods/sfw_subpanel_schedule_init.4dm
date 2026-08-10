//%attributes = {}
var $periods : Collection

$periods:=New collection:C1472
$period:=New object:C1471()
$period.label:=ds:C1482.sfw_readXliff("period.type.default"; "default")
$period.kind:="-"
$periods.push($period)

$period:=New object:C1471()
$period.label:=ds:C1482.sfw_readXliff("period.type.year"; "Year")
$period.kind:="Y"
$periods.push($period)

$period:=New object:C1471()
$period.label:=ds:C1482.sfw_readXliff("period.type.quarter"; "Quarter")
$period.kind:="Q"
$periods.push($period)

$period:=New object:C1471()
$period.label:=ds:C1482.sfw_readXliff("period.type.month"; "Month")
$period.kind:="M"
$periods.push($period)

$period:=New object:C1471()
$period.label:=ds:C1482.sfw_readXliff("period.type.date"; "Date")
$period.kind:="D"
$periods.push($period)


Form:C1466.pupPeriods:=$periods

Form:C1466.months:=Split string:C1554(ds:C1482.sfw_readXliff("dateAndTime.months"; "January;Febuary;March;April;May;June;July;August;September;October;November;December"); ";")
Form:C1466.days:=Split string:C1554(ds:C1482.sfw_readXliff("dateAndTime.days"; "Sunday;Monday;Tuesday;Wednesday;Thursday;Friday;Saturday"); ";")
