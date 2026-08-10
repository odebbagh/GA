cs:C1710.sfw_panel_user.me.formMethod()


//If (Form.current_item#Null)
//Form.canValidate:=(Form.current_item.firstName#"") && (Form.current_item.lastName#"")
//If (Form.current_item.login="") & (Form.canValidate)
//Form.current_item.setLogin()
//End if 

//End if 

//OBJECT SET ENABLED(*; "cb_asDesigner"; sfw_checkIsInModification)
//OBJECT SET ENABLED(*; "cb_isInactive"; sfw_checkIsInModification)
//OBJECT SET ENABLED(*; "btn_reset"; sfw_checkIsInModification && Not(Form.situation.mode="add") && (Not(Form.current_item.isInactive)))
//Form.sfw.redrawButtons()

OBJECT SET TITLE:C194(*; "firstname"; ds:C1482.sfw_readXliff("user.field.firstname"; "First name"))
OBJECT SET TITLE:C194(*; "lastname"; ds:C1482.sfw_readXliff("user.field.lastname"; "Last name"))
OBJECT SET TITLE:C194(*; "login"; ds:C1482.sfw_readXliff("user.field.login"; "Login"))
OBJECT SET TITLE:C194(*; "cb_asDesigner"; ds:C1482.sfw_readXliff("user.field.designeract"; "Acts as designer"))
OBJECT SET TITLE:C194(*; "cb_isInactive"; ds:C1482.sfw_readXliff("user.field.inactiveuser"; "Inactive user"))


OBJECT SET TITLE:C194(*; "profil"; ds:C1482.sfw_readXliff("user.listbox.profile"; "Profile"))