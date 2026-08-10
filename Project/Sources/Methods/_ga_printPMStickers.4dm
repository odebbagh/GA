//%attributes = {}



$form:=New object:C1471

$form.lb_equipments:=ds:C1482.Equipment.query("nextPMDate>=:1"; Current date:C33(*))

$winRef:=Open form window:C675("_ga_StickerSelectionList"; Plain form window:K39:10; Horizontally centered:K39:1; Vertically centered:K39:4)
DIALOG:C40("_ga_StickerSelectionList"; $form)

