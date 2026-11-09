Case of 
	: (Form event code:C388=On Before Keystroke:K2:6)
		Form:C1466.PreviousLimit:=Form:C1466.current_item.buyOrderLimit
	: (Form event code:C388=On Data Change:K2:15)
		//---Num() guards the first edit of a brand-new order, where PreviousLimit has
		//   never been set: Undefined#0 is true, which sent changeBOLimit down the
		//   "raising the limit" path and made it demand a signature for the very first
		//   value typed. Cancelling that reverted the field, so nothing was ever dirty
		//   and Save stayed greyed out.
		If (Num:C11(Form:C1466.PreviousLimit)#0)
			cs:C1710.panel_buyingOrder.me.changeBOLimit(Num:C11(Form:C1466.PreviousLimit); Form:C1466.current_item.buyOrderLimit)
		End if 
		//---touch the entity so the framework enables Save/Cancel
		cs:C1710.panel_buyingOrder.me._activate_save_cancel_button()
End case 