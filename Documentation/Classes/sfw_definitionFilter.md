<!-- Type your summary here -->
## sfw_definitionFilter

The `sfw_definitionFilter` class provides various methods for managing linked entities, filters, dynamic titles, and ordering mechanisms. It is designed to facilitate flexible data representation and retrieval through attribute-based configurations.

### Summary

| |
| -------- |
|[.setAttributeLabelForItem(labelForItem : Text)](#-setattributelabelforitem-) Sets a label for an item attribute.|
|[.setDefaultTitle(title : Text)](#-setdefaulttitle-) <br> Sets a default title for the instance.|
|[.setDynamicTitle(attributeForSingleTitle : Text; formatForMutipleTitles : Text)](#-setdynamictitle-) <br> Sets a dynamic title format based on attributes.|
|[.setFilterByIDInTable(linkedDataclassName : Text; attributeID : Text; attributeForLink : Text; placeholderForLink : Text)](#-setFilterByIDInTable-) <br> Enables filtering by an ID in a table.|
|[.setFilterByLinkedEntity(linkedDataclassName : Text; attributeForLink : Text; placeholderForLink : Text; linkToFollowIfShift : Text)](#-setfilterbylinkedentity-) <br> Enables filtering by a linked entity.|
|[.setFilterByManyToManyEntity(finalDataclassName : Text; finalAttribute : Text; pathManyToMany : Text)](#-setfilterbymanytomanyentity-) <br> Enables filtering using a many-to-many entity relationship.|
|[.setOrderForItems(orderForItems : Text)](#-setorderforitems-) <br> Sets the order for items.|


<!--   .setAttributeLabelForItem(labelForItem : Text) *********************   -->
## .setAttributeLabelForItem()

### .setAttributeLabelForItem(labelForItem : Text)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| labelForItem  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The label text to be used for an item in the object |

#### Description
The ``.setAttributeLabelForItem()`` function assigns a label to an item, which can be used for display purposes. This is typically used when labeling UI components such as form fields, list items, or columns in a table. The label helps users identify what each item represents or how it should be interacted with.

This function is particularly useful when the item needs a user-friendly identifier to improve the clarity and usability of the application.

#### Example
```4d
	$filter:=cs.sfw_definitionFilter.new("filterStaff")
	$filter.setDefaultTitle("All staffs")
	$filter.setFilterByLinkedEntity("Staff"; "affectation.UUID_Staff"; "uuidStaff"; "affectation.staff")
	$filter.setDynamicTitle("fullName"; "## staffs")
	$filter.setOrderForItems("firstName, lastName")
	$filter.setAttributeLabelForItem("fullName")
```


<!--   .setDefaultTitle(title : Text) *********************   -->
## .setDefaultTitle(title : Text)

### .setDefaultTitle(title : Text)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| title  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The default title to be set for the filter |

#### Description
The ``.setDefaultTitle()`` function is used to assign a default title to the current filter.
 This title serves as the initial or fallback name when no other title is provided. 
It ensures that the filter is always identifiable by a clear and consistent title, which can be useful for user interfaces or reporting purposes. 

#### Example
```4d
	$filter:=cs.sfw_definitionFilter.new("filterCustomer")
	$filter.setDefaultTitle("All customers")
```


<!--   .setDynamicTitle(attributeForSingleTitle : Text; formatForMutipleTitles : Text) *********************   -->
## .setDynamicTitle()

### .setDynamicTitle(attributeForSingleTitle : Text; formatForMutipleTitles : Text)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| attributeForSingleTitle  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The attribute used for constructing a single title |
| formatForMutipleTitles  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The format string to be used when there are multiple titles |

#### Description
The ``.setDynamicTitle()`` function sets the title of the object dynamically, based on either a single attribute or a format for multiple titles. This is particularly useful in scenarios where the title might change depending on the context, such as displaying a list of items where each item may have a unique title or when a single title needs to be displayed differently based on specific attributes.

The formatForMultipleTitles parameter allows for the customization of titles when more than one title is required for the object.

#### Example
```4d
	$filter:=cs.sfw_definitionFilter.new("filterRole")
	$filter.setDefaultTitle("All skills")
	$filter.setFilterByManyToManyEntity("Role"; "name"; "skills.role")
	$filter.setDynamicTitle("name"; "## roles")
```

<!--   .setFilterByIDInTable(linkedDataclassName : Text; attributeID : Text; attributeForLink : Text; placeholderForLink : Text) *********************   -->
## .setFilterByIDInTable()

### .setFilterByIDInTable(linkedDataclassName : Text; attributeID : Text; attributeForLink : Text; placeholderForLink : Text)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| linkedDataclassName  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The name of the linked data class for the filter |
| attributeID  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The unique identifier (ID) for the linked entity |
| attributeForLink  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The attribute used to establish the link between entities |
| placeholderForLink  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The placeholder text for the link if not defined |

#### Description

The ``.setFilterByIDInTable()`` function applies a filter that specifically targets an ID within a table from a linked data class. This is especially useful for scenarios where the user needs to view data filtered by a unique identifier (e.g., an employee ID or product ID). 

This function allows you to specify a linked data class and the attributes used for the filter, offering flexibility in defining which records are shown based on their ID and related attributes.

#### Example
```4d
	$filter:=cs.sfw_definitionFilter.new("filterCurrentStatus")
	$filter.setDefaultTitle("All status")
	$filter.setFilterByIDInTable("ProjectStatus"; "statusID"; "currentStatusID")
```

<!--   .setFilterByLinkedEntity(linkedDataclassName : Text; attributeForLink : Text; placeholderForLink : Text; linkToFollowIfShift : Text) *********************   -->
## .setFilterByLinkedEntity()

### .setFilterByLinkedEntity(linkedDataclassName : Text; attributeForLink : Text; placeholderForLink : Text; linkToFollowIfShift : Text)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| linkedDataclassName  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The name of the linked data class for the filter |
| attributeForLink  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The attribute used for linking, typically a foreign key or relationship identifier|
| placeholderForLink  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The placeholder text to be used when no link is established|
| linkToFollowIfShift  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | Specifies the action or link to follow when the shift key is pressed|

#### Description
The ``.setFilterByLinkedEntity()`` function configures a filter based on a linked entity in another data class. 
This is commonly used in scenarios where an object needs to be filtered or restricted based on related data, such as filtering a list of items by a specific attribute of a linked entity (e.g., filtering invoices by client ID).

This method allows you to specify which attribute of the linked data class should be used for the filter, and provides an optional placeholder text to display when the link is empty or undefined.
#### Example
```4d
$filter.setFilterByLinkedEntity("Customer"; "UUID_Customer"; ""; "customer")
```



<!--   .setFilterByManyToManyEntity(finalDataclassName : Text; finalAttribute : Text; pathManyToMany : Text) *********************   -->
## .setFilterByManyToManyEntity()

### .setFilterByManyToManyEntity(finalDataclassName : Text; finalAttribute : Text; pathManyToMany : Text)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| finalDataclassName  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The final data class to which the filter applies after many-to-many relationship processing |
| finalAttribute  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The attribute within the final data class used for filtering |
| pathManyToMany  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The path or relationship string that defines the many-to-many relationship between the entities |

#### Description
The ``.setFilterByManyToManyEntity()`` function applies a filter based on a many-to-many relationship between data entities. Many-to-many relationships allow an entity to be linked to multiple records in another entity (e.g., students linked to multiple courses). 

This function is useful for complex filtering scenarios, where the relationship path and attributes must be specified to correctly map and filter the data. The pathManyToMany parameter defines the relationship structure between the entities involved.

#### Example
```4d
	$filter:=cs.sfw_definitionFilter.new("filterRole")
	$filter.setDefaultTitle("All skills")
	$filter.setFilterByManyToManyEntity("Role"; "name"; "skills.role")
```

<!--   .setOrderForItems(orderForItems : Text) *********************   -->
## .setOrderForItems()

### ..setOrderForItems(orderForItems : Text)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| orderForItems  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The order criteria for arranging the items (e.g., ascending or descending) |

#### Description
The ``.setOrderForItems()`` function defines the order in which items should be arranged. This is typically used when displaying a list or a set of items, and can be based on attributes such as alphabetical order, numerical order, or custom sorting criteria.

This function is often used in UI components or data grids where the presentation order of items is important.

#### Example
```4d
	$filter:=cs.sfw_definitionFilter.new("filterStaff")
	$filter.setDefaultTitle("All staffs")
	$filter.setFilterByLinkedEntity("Staff"; "affectation.UUID_Staff"; "uuidStaff"; "affectation.staff")
	$filter.setDynamicTitle("fullName"; "## staffs")
	$filter.setOrderForItems("firstName, lastName")
```

