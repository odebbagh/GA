//%attributes = {}
// _ga_voidJournalEntry
// Item action "Void the entry" of Journal Entries (manual and opening entries only).
// Voiding removes the lines (the amounts no longer count) and keeps the entry, marked void, so the
// numbering has no hole. Not in Modify: it is done in its own transaction, as Quote_lifecycleAction.
var $entry : cs.JournalEntryEntity
var $result : Object

If (Form.current_item=Null)
	return 
End if 
If (Form.sfw.checkIsInModification())
	cs.sfw_dialog.me.alert("Save or cancel the changes first.")
	return 
End if 
$entry:=ds.JournalEntry.get(Form.current_item.UUID)  // as saved
If ($entry=Null)
	return 
End if 
If (Not($entry.canBeVoided))
	cs.sfw_dialog.me.alert("This entry cannot be voided: it is already void, it was written by a document (change the document), or it is dated in a closed period.")
	return 
End if 
If (Not(cs.sfw_dialog.me.confirm("Void journal entry #"+String($entry.number)+" ("+String($entry.totalAmount; "###,###,##0.00")+")?"+Char(Carriage return)+"Its amounts will no longer count. It stays in the list, marked void."; "Void"; "Cancel")))
	return 
End if 

ds.startTransaction()
$result:=cs.ga_ledger.me.voidEntry($entry)
If (Not($result.success))
	ds.cancelTransaction()
	cs.sfw_dialog.me.alert($result.errors.join(Char(Carriage return)))
	return 
End if 
ds.validateTransaction()

// the entry on screen again, with no lines
Form.current_item.reload()
If (Form.subForm#Null)
	Form.current_clone:=Form.current_item.clone()
	Form.subForm.previousItemUUID:=""  // panel_journalEntry reloads its lines
	Form.subForm:=Form.subForm
End if 
