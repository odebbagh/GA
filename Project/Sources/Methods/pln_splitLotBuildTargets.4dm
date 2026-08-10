//%attributes = {}
// Rebuilds child-lot target rows from Form.splitDraft (Phase B).

If (Form:C1466.splitDraft#Null:C1517)
	cs:C1710.LotSplitService.me.rebuildSplitTargets(Form:C1466.splitDraft; False:C215)
	cs:C1710.LotSplitService.me.applyDraftToForm(Form:C1466.splitDraft; Form:C1466)
End if 
