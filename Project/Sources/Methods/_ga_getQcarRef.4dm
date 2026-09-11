//%attributes = {}

// Purpose: Display reference prefix uses CAR# instead of QCAR# for picker lists and CI action linkage.
// modified by 4D/PS [2026-may-12]

$1.value.qcarNumberRef:="CAR# "+String:C10($1.value.qcarNumber)

$1.result:=$1.value

