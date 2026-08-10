property functions : Collection

shared singleton Class constructor
	
	var $fonction : Object
	
	This:C1470.functions:=New shared collection:C1527()
	
	$fonction:=New object:C1471
	$fonction.title:="entryDefinition"
	$fonction.syntax:="local Function entryDefinition()->$entry : cs.sfw_definitionEntry"
	$fonction.comment:="this function creates and configures an entry definition"
	
	This:C1470.functions.push(OB Copy:C1225($fonction; ck shared:K85:29))
	
	$fonction:=New object:C1471
	$fonction.title:="new"
	$fonction.syntax:="$entry:=cs.sfw_definitionEntry.new(\"\"; \"\"; \"\")"
	$fonction.comment:="this function creates and initializes a new instance of the class: identifier ;vision's identifier ;label"
	This:C1470.functions.push(OB Copy:C1225($fonction; ck shared:K85:29))
	
	$fonction:=New object:C1471
	$fonction.title:="setDataclass"
	$fonction.syntax:="$entry.setDataclass(\"\")"
	$fonction.comment:="It's designed to assign a specific name to dataclass that already exists in the datastore"
	This:C1470.functions.push(OB Copy:C1225($fonction; ck shared:K85:29))
	
	$fonction:=New object:C1471
	$fonction.title:="setIcon"
	$fonction.syntax:="$entry.setIcon(\"\")"
	$fonction.comment:="It assigns an icon to the entry"
	This:C1470.functions.push(OB Copy:C1225($fonction; ck shared:K85:29))
	
	$fonction:=New object:C1471
	$fonction.title:="setSearchboxField"
	$fonction.syntax:="$entry.setSearchboxField(\"\")"
	$fonction.comment:="It defines the field used for searching within this entry"
	This:C1470.functions.push(OB Copy:C1225($fonction; ck shared:K85:29))
	
	
	
	$fonction:=New object:C1471
	$fonction.title:="setSearchField"
	$fonction.syntax:="$entry.setSearchField(\"\")"
	$fonction.comment:="Dynamically creates and configures a search field for the application.\r//Each field can have attributes, data type (text, date, boolean, etc.),\r//tags, a placeholder, and can be linked to comments or documents."
	This:C1470.functions.push(OB Copy:C1225($fonction; ck shared:K85:29))
	
	
	$fonction:=New object:C1471
	$fonction.title:="setDisplayOrder"
	$fonction.syntax:="$entry.setDisplayOrder()"
	$fonction.comment:="It specifies the display order of this entry"
	This:C1470.functions.push(OB Copy:C1225($fonction; ck shared:K85:29))
	
	
	$fonction:=New object:C1471
	$fonction.title:="setPanel"
	$fonction.syntax:="$entry.setPanel(\"panel_\")"
	$fonction.comment:="It associates the entry with a panel"
	This:C1470.functions.push(OB Copy:C1225($fonction; ck shared:K85:29))
	
	$fonction:=New object:C1471
	$fonction.title:="setPanelPage"
	$fonction.syntax:="$entry.setPanelPage(; \"-32x32.png\"; \"\")"
	$fonction.comment:="It associates a specific page with the panel and sets an icon and label"
	This:C1470.functions.push(OB Copy:C1225($fonction; ck shared:K85:29))
	
	$fonction:=New object:C1471
	$fonction.title:="setLBItemsColumn"
	$fonction.syntax:="$entry.setLBItemsColumn(\"\"; \"\")"
	$fonction.comment:="It defines the columns used for displaying items in a list"
	This:C1470.functions.push(OB Copy:C1225($fonction; ck shared:K85:29))
	
	$fonction:=New object:C1471
	$fonction.title:="setLBItemsOrderBy"
	$fonction.syntax:="$entry.setLBItemsOrderBy(\"\")"
	$fonction.comment:="It defines the sorting order of the items"
	This:C1470.functions.push(OB Copy:C1225($fonction; ck shared:K85:29))
	
	$fonction:=New object:C1471
	$fonction.title:="setLBItemsCounter"
	$fonction.syntax:="$entry.setLBItemsCounter(\"###0###0##0^1;;\"; \"unit1:\"; \"unitN:\")"
	$fonction.comment:="It defines a counter for items in the list"
	This:C1470.functions.push(OB Copy:C1225($fonction; ck shared:K85:29))
	
	$fonction:=New object:C1471
	$fonction.title:="setValidationRule"
	$fonction.syntax:="$entry.setValidationRule(\"code\"; \"entryField_code\")"
	$fonction.comment:="It is used to set a validation rule for a specific field in an entry"
	This:C1470.functions.push(OB Copy:C1225($fonction; ck shared:K85:29))
	
	$fonction:=New object:C1471
	$fonction.title:="setItemListPreconfigAction"
	$fonction.syntax:="$entry.setItemListPreconfigAction(\"\")"
	$fonction.comment:="It is used to set a preconfigured action that will be executed on the item list of the entry \r //\"exportReferenceRecords\",\"importReferenceRecords\",\"copyItemsListToPasteboard\"..."
	This:C1470.functions.push(OB Copy:C1225($fonction; ck shared:K85:29))
	
	$fonction:=New object:C1471
	$fonction.title:="setItemListAction"
	$fonction.syntax:="$entry.setItemListAction(\"\"; \"\")"
	$fonction.comment:="It is used to set specific actions that will be executed on the item list of the entry"
	This:C1470.functions.push(OB Copy:C1225($fonction; ck shared:K85:29))
	
	
	
	$fonction:=New object:C1471
	$fonction.title:="enableTransaction"
	$fonction.syntax:="$entry.enableTransaction()"
	$fonction.comment:="o enable transaction handling for the entry"
	This:C1470.functions.push(OB Copy:C1225($fonction; ck shared:K85:29))
	
	$fonction:=New object:C1471
	$fonction.title:="activateFavorite"
	$fonction.syntax:="$entry.activateFavorite()"
	$fonction.comment:="to mark an item in the entry as a favorite"
	This:C1470.functions.push(OB Copy:C1225($fonction; ck shared:K85:29))
	$fonction:=New object:C1471
	$fonction.title:="activateComment"
	$fonction.syntax:="$entry.activateComment()"
	$fonction.comment:="To activate the comment feature for an entry. \r //You can use \"activateSearchTags\" to add all three tags (withComment, inComment, levelComment) at once,\r // or add each tag separately using a semicolon (;)"
	This:C1470.functions.push(OB Copy:C1225($fonction; ck shared:K85:29))
	
	$fonction:=New object:C1471
	$fonction.title:="activateEvent"
	$fonction.syntax:="$entry.activateEvent()"
	$fonction.comment:="to enable event handling for the entry."
	This:C1470.functions.push(OB Copy:C1225($fonction; ck shared:K85:29))
	
	$fonction:=New object:C1471
	$fonction.title:="setLBAllowedProfiles"
	$fonction.syntax:="$entry.setLBAllowedProfiles(\"\")"
	$fonction.comment:=" to set the allowed user profiles for accessing or interacting with the entry"
	This:C1470.functions.push(OB Copy:C1225($fonction; ck shared:K85:29))
	
	//marl:-definitions
	$fonction:=New object:C1471
	$fonction.title:="View definition"
	$fonction.syntax:="$view:=cs.sfw_definitionView.new(\"\"; \"\")"
	$fonction.comment:="this functions create and configure a view definition"
	$fonction.code:="$view.setLBItemsColumn(\"\"; \"\") \r"+\
		"$view.setLBItemsOrderBy(\"\")\r"+\
		"$view.setLBItemsCounter(\"###0###0##0^1; ; \"; \"unit1 :\"; \"unitN :\")\r"+\
		"$view.setSubset(\"\")\r"+\
		"$view.setPictoLabel(\"\")\r"+\
		"$entry.setView($view)\r"+\
		""
	This:C1470.functions.push(OB Copy:C1225($fonction; ck shared:K85:29))
	
	$fonction:=New object:C1471
	$fonction.title:="Filter definition"
	$fonction.syntax:="$view:=cs.sfw_definitionFilter.new(\"\"; \"\")"
	$fonction.comment:="this functions create and configure a filter definition"
	$fonction.code:="$filter.setDefaultTitle(\"\")\r"+\
		"$filter.setFilterByLinkedEntity(\"\"; \"\"; \"\"; \"\")\r"+\
		"$filter.setFilterByIDInTable(\"\"; \"\"; \"\")\r"+\
		"$filter.setDynamicTitle(\"\"; \"##\")\r"+\
		"$entry.addFilter($filter)\r"+\
		""
	This:C1470.functions.push(OB Copy:C1225($fonction; ck shared:K85:29))
	
	$fonction:=New object:C1471
	$fonction.title:="Page Listbox definition"
	$fonction.syntax:="$pageListbox:=cs.sfw_definitionPageListbox.new(\"\")"
	$fonction.comment:="this functions create and configure a page listbox definition"
	$fonction.code:="$pageListbox.setDatasource(\"\")\r"+\
		"$pageListbox.setOrderBy(\"\")\r"+\
		"$pageListbox.addColumn(\"\")\r"+\
		"$pageListbox.addPredefinedAction(\"export\")\r"+\
		"$pageListbox.addPredefinedFilter(\"periods\"; \"filterAttribute:\")\r"+\
		"$entry.setPanelDynamicPage(8; \"-32x32.png\"; \"\"; $pageListbox)\r"+\
		""
	This:C1470.functions.push(OB Copy:C1225($fonction; ck shared:K85:29))
	
	
	
	
	
	
	
	
	
	