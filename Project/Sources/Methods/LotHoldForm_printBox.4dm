//%attributes = {}
// LotHoldForm_printBox($ticked) -> the mark in a tick box of the printed GAF forms (_wpGafCheck): "X" or nothing
#DECLARE($ticked : Boolean)->$box : Text

$box:=$ticked ? "X" : ""
