$WParea:=WParea
WP INSERT PICTURE:C1437($WParea; $logo; wk append:K81:179)
WP SET TEXT:C1574($WParea; ds:C1482.sfw_readXliff("email.notificationAppointment"); wk append:K81:179)

$coll_ranges:=WP Find all:C1755($WParea; "##Formula:"; wk all insensitive:K81:334+wk find reverse:K81:335)
$coll_ranges2:=WP Find all:C1755($WParea; ":##"; wk all insensitive:K81:334+wk find reverse:K81:335)

For each ($range; $coll_ranges)
	$range2:=$coll_ranges2.shift()
	$defFormula:=WP Get text:C1575(WP Text range:C1341($WParea; $range.end; $range2.start))
	$formula:=Formula from string:C1601($defFormula)
	WP INSERT FORMULA:C1703(WP Text range:C1341($WParea; $range.start; $range2.end); $formula; wk replace:K81:177)
End for each 