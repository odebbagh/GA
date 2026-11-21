//%attributes = {}
// _import_accountingCheckLine (for _import_accountingCheck): one "OK / DIFFERENT" line,
// "label: legacy x - here y". Returns $match.
#DECLARE($lines : Collection; $label : Text; $legacy : Variant; $here : Variant; $match : Boolean)->$ok : Boolean
var $l; $h : Text
$l:=(Value type($legacy)=Is real) ? String($legacy; "###,###,##0.00;-###,###,##0.00;0") : String($legacy)
$h:=(Value type($here)=Is real) ? String($here; "###,###,##0.00;-###,###,##0.00;0") : String($here)
$lines.push(($match ? "OK         " : "DIFFERENT  ")+$label+": legacy "+$l+" - here "+$h)
$ok:=$match
