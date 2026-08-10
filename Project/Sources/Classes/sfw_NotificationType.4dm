Class extends DataClass


local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	If (cs:C1710.sfw_definition.me.globalParameters.notifications.activate)
		$entry:=cs:C1710.sfw_definitionEntry.new("notificationType"; "administration"; "Notification types")
		$entry.setXliffLabel("notificationtype.title")
		$entry.setDataclass("sfw_NotificationType")
		$entry.setDisplayOrder(-1200)
		$entry.setIcon("sfw/entry/notificationType-50x50.png")
		
		$entry.setSearchField("attribute:ident"; "tag:ident")
		$entry.setSearchField("attribute:label"; "tag:label")
		
		$entry.setPanel("sfw_panel_notificationType")
		
		$entry.setLBItemsColumn("ident"; "Identifier"; "width:80"; "xliff:notificationtype.field.ident")
		$entry.setLBItemsColumn("label"; "Label"; "width:100"; "xliff:notificationtype.field.label")
		$entry.setLBItemsColumn("description"; "Description"; "width:200")
		$entry.setLBItemsOrderBy("ident")
		
		$entry.setLBItemsCounter("###,###,##0 ^1;;"; "unit1:email template"; "unitN:email templates")
		$entry.setValidationRule("ident"; "entryField_ident"; "mandatory"; "trimSpace")
		$entry.setValidationRule("label"; "entryField_label"; "mandatory"; "trimSpace"; "capitalize")
		$entry.setValidationRule("description"; "entryField_description"; "trimSpace"; "capitalize")
		
		
		$entry.setItemListPreconfigAction("exportReferenceRecords")
		$entry.setItemListPreconfigAction("importReferenceRecords")
		$entry.setItemListPreconfigAction("copyItemsListToPasteboard")
		
	End if 