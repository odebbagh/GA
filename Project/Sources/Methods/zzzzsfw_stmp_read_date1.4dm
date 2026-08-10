//%attributes = {}
// sfw_stmp_read_date (stmp : integer ) -> Date

#DECLARE($stmp : Integer)->$date : Date

$referenceDate:=Add to date:C393(!00-00-00!; Storage:C1525.kst.stmpRefYear; 1; 1)

$nbOfDays:=$stmp\86400

$date:=$referenceDate+$nbOfDays
