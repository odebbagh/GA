//%attributes = {}
// Call after editing target quantities in the wizard listbox.

If (Form:C1466.splitDraft#Null:C1517)
	cs:C1710.LotSplitService.me.syncDraftLines(Form:C1466.splitDraft)
	Form:C1466.splitReviewText:=cs:C1710.LotSplitService.me.formatDraftReview(Form:C1466.splitDraft)
End if 
