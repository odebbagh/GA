// Purpose: Activate save/cancel while typing. Status history is appended once on save in EquipmentEntity.beforeSave.
// modified by 4D/PS [2026-november-03]
Case of 
	: (Form event code:C388=On After Edit:K2:43)
		cs:C1710.panel_equipment.me._activate_save_cancel_button()
	: (Form event code:C388=On Data Change:K2:15)
		cs:C1710.panel_equipment.me._activate_save_cancel_button()
End case 
