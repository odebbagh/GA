<!-- Type your summary here -->
## sfw_definitionEntry

The **`sfw_definitionEntry`** class is designed to manage and manipulate various properties and objects related to a user interface or data structure. It initializes a set of properties, collections, and objects essential for building and managing specific functionalities.

### Summary

| |
| -------- |
|[.new(ident : Text; vision_ident : Variant; label : Text)](#-new-) <br> creates and initializes a new instance of the class.|
|[.setItemAction(label : Text; method : Text; {params : Text})](#-setItemAction-) <br> defines and configures an action within an object .|
|[.setAddable(addable : Boolean)](#-setaddable-) <br> controls whether new items can be added to a particular collection or list in the context of an application.|
|[.setDataclass(dataclass : Text)](#-setdataclass-) <br> assigns a value to the `xliff` property of the class instance.|
|[.setDisplayOrder(order : Integer)](#-setdisplayorder-) <br> defines the order in which an item should be displayed relative to other items.|
|[.setIcon(iconRelativePath : Text)](#-seticon-) <br> sets the path to the icon file to be assigned.|
|[.setLBItemsColumn(attribute : Text; label : Text; {params : Text})](#-setlbitemscolumn-) <br>  configures and adds a column to a list box.|
|[.setLBItemsCounter(format : Text; {params : Text})](#-setlbitemscounter-) <br> configures the format and displays options for a counter associated with list box items in an application.|
|[.setLBItemsOrderBy(propertyPath : Text; descending : Boolean)](#-setlbitemsorderby-) <br> define the ordering criteria for the list box items.|
|[.setPanel(panelName : Text; currentPage : Integer)](#-setpanel-) <br> sets the properties of a `panel` object within an entry.|
|[.setPanelPage(pageNum : Integer; pict : Text)](#-setpanelpage-) <br> adds a new page configuration to the `pages` collection of a `panel` object.|
|[.setSearchboxField(attribute : Text; {params : Variant})](#-setsearchboxfield-) <br> adds a search field to an entry object's searchbox configuration .|
|[.setSearchboxSpecific(tag : Text; {params : Variant})](#-setsearchboxspecific-) <br> adds a custom search criterion to an entry's searchbox configuration.|
|[.setValidationRule(field : Text; widget : Text; {params : Text})](#-setvalidationrule-) <br> configures validation rules for fields within an entry or form. .|
|[.setVirtual(type : Text)](#-setvirtual-) <br>  defines the type of virtual object for an entry.|
|[.setVirtualItem(item : cs.sfw_definitionVirtualItem)](#-setvirtualitem-) <br> adds a virtual entry item to a collection of items.|
|[.setWizard(panel : Text)](#-setwizard-) <br> configures a wizard panel for a user interface.|
|[.setXliffLabel(xliff : Text)](#-setxlifflabel-) <br> assigns a value to the `xliff` property of the class instance.|







<!--   new() *********************   -->
## .new()

### .new(ident : Text; vision_ident : Variant; label : Text)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| ident  | Text  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | Text that sets a unique identifier for the instance. |
| vision_ident  | variant  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | a flexible field that can be a single identifier or a collection of identifiers.  |
| label  | Text  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | Text that sets a descriptive label.  |


#### Description

The  **`.new()`** is a function in the `sfw_definitionEntry` class designed to create and initialize a new instance of the class with the specified properties.

- **`ident`**: is used to assign a unique identifier to the instance. This ensures that the object can be distinguished from others within the application.
- **`vision_ident`**: is flexible, meaning it can either be a single text value or a collection of text values. It serves as a classification or reference key, allowing the object to be categorized or linked with other objects.
- **`label`**: is used to provide a descriptive name or label for the instance, which is helpful for user-facing interfaces or reports.

> Additionally, the constructor initializes the following properties: <br> - **`xliff`**: This property is set to an empty string `""`, which could later be used for localization or translation purposes. <br> - **`searchbox`**: An object is initialized, containing collections for **`fields`** and **`specificSearches`**, used for managing search functionality.<br>- **`panel`**: This property is initialized as an object with a **`name`** set to an empty string and a **`pages`** collection for managing related pages. <br> - **`lb_items`**: This property is initialized as an object with collections for **`columns`** and **`orderBy`**, and an object for **`counter`** to manage item listings. <br>- **`actions`**: This property is initialized as an empty collection to hold any actions associated with the object.


#### Exemple
```4d
$entry:=cs.sfw_definitionEntry.new("country"; "administration"; "Countries")
```










<!--   setItemAction($label : Text; $method : Text;  ...  : Text) *********************   -->
## .setItemAction()

### .setItemAction(label : Text; method : Text; {params : Text})

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| label  | Text  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | Text that represents the label of the action |
| method  | Text  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | Text that sets the name of function to be called when the action is triggered |
| params  | Text  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | Additional settings in the format key:value |

#### Description

The `setItemAction` function is designed to define and configure an action within an object.

This function takes two required parameters (`label` and `method`) and allows for additional optional parameters that further customize the action object. 
The function creates a new action object, assigns properties based on the provided arguments,
 and includes support for setting an XLIFF label for internationalization.

It can be used in applications where defining user actions (e.g., buttons, menu items) programmatically is required. 
It helps streamline the configuration of these actions by encapsulating label, method, and optional localization settings.

#### Exemple
```4d
$entry.setItemAction("alert"; "Customer_alertAction")
```
















<!--   setAddable($addable : Boolean) *********************   -->
## .setAddable()

### .setAddable(addable : Boolean)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| addable  | Boolean  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | Boolean that specifies whether items should be addable (`True`) or not (`False`). |

#### Description

The `setAddable` function is designed to control whether new items can be added to a particular collection or list in the context of an application. 
It modifies the `addable` property within the object, determining if the **add** functionality should be enabled or disabled.


This function is particularly useful for scenarios where conditional item addition is needed, 
such as dynamic forms, adjustable lists, or user interfaces that require a modifiable or restricted state.

#### Exemple
```4d
$entry.setAddable() // True
```









<!--   setDataclass($dataclass : Text) *********************   -->
## .setDataclass()

### .setDataclass(dataclass : Text)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| dataclass  | Text  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | Text parameter representing the name of the data class to be set |

#### Description

The `setDataclass()` function is designed to assign a specific name to dataclass that already exists in the datastore.

  - The function will check if the **dataclass**, specified by the `dataclass` parameter, exists within the datastore (`ds`).
  - If the **dataclass** is not found (i.e., `ds[dataclass]` is `Null`), an **alert** is triggered, informing the user that the specified dataclass does not exist in the datastore.
  - If the **dataclass** exists, it is assigned to the `dataclass`.

#### Exemple
```4d	
$entry:=cs.sfw_definitionEntry.new("customer"; "customer"; "Customers")
$entry.setDataclass("Person")
```






<!--   setDisplayOrder(order : Integer) *********************   -->
## .setDisplayOrder()

#### .setDisplayOrder(order : Integer)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| order  | Integer  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | Integer value that specifies the display order of the item. |

#### Description


The ``setDisplayOrder()`` function is used to define the order in which an item should be displayed relative to other items.
 By setting an integer order value, this function helps control the positioning of the item within a list or form. 
 
 This ensures that items are displayed in the correct sequence as defined by the order parameter, which can be useful for arranging items according to specific criteria or priorities.

#### Exemple
```4d
$entry.setDisplayOrder(100)
```














<!--   setIcon($iconRelativePath : Text) *********************   -->
## .setIcon()

### .setIcon(iconRelativePath : Text)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| iconRelativePath  | Text  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | Text that sets the path to the icon file to be assigned |

#### Description

The `setIcon()` function is used to set the icon for `sfw_definitionEntry` instance, using a **relative file path** that points to the location of the icon.

#### Exemple
```4d	
$entry:=cs.sfw_definitionEntry.new("customer"; "customer"; "Customers")
$entry.setIcon("image/entry/customers-50x50.png")
```
















<!--  setLBItemsColumn($attribute : Text; $label : Text;  ...  : Text) *********************   -->
## .setLBItemsColumn()

### .setLBItemsColumn(attribute : Text; label : Text; {params : Text})

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| attribute  | Text  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | Text that represents the underlying data attribute |
| label  | Text  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | Text that sets the label or name that will be displayed for the column |
| params  | Text  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | Text parameter that allow for further customization of the column, such as its type, width, ordering formula, and translation label |

#### Description

The `setLBItemsColumn()` function is used to configure and add a column to a list box. It sets the column’s attributes, label, and various optional properties, such as type, width, ordering formula, and translation labels.

This function allows for dynamic and flexible configuration of columns in a list box or table. It enables you to specify the essential attributes of a column and then further customize it with optional properties like its display label, type, width, sorting order, and translation labels. This ensures that each column is tailored to the specific needs of the user interface, improving usability and organization in the data display.

#### Exemple
```4d	
$entry.setLBItemsColumn("name"; "Name"; "xliff:entry.medicalHouse.field.name"; "width:200")
$entry.setLBItemsColumn("contactDetails.addresses[0].detail.city"; "City"; "xliff:address.city"; "orderByFormula:this.contactDetails.addresses[0].detail.city"; "width:150")
$entry.setLBItemsColumn("level"; "Level"; "xliff:entry.medicalHouse.field.level"; "width:20")
```































<!--  setLBItemsCounter($format : Text; {params : Text}) *********************   -->
## .setLBItemsCounter()

### .setLBItemsCounter(format : Text; {params : Text})

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| format  | Text  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | Text that specifies the display format of the counter |
| params  | Text  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | Text parameter that sets key-value pairs in the format `key:value` that allow you to specify details about units  |

#### Description

The `setLBItemsCounter` function is designed to configure the format and display options for a counter associated with list box items in an application. 
This function ensures that the counter is formatted and localized, providing singular and plural unit labels along with optional XLIFF translation keys for internationalization.

These additional settings are passed as strings in the format key:value. The supported keys include:

- ``unit1:value`` : Specifies the singular form of the unit (e.g., "item").

- ``unitN:value`` : Specifies the plural form of the unit (e.g., "items").

- ``unit1xliff:value`` : An XLIFF reference for the singular form of the unit, used for translation purposes.

- ``unitNxliff:value`` : An XLIFF reference for the plural form of the unit, used for translation purposes.

This function is essential for applications that need dynamic and localized counter displays,
 ensuring users see clear and appropriately labeled counts in their native language.


#### Exemple

```4d
$entry.setLBItemsCounter("###,###,##0 ^1;;"; "unit1:coach"; "unitN:coachs"; "unit1xliff:entry.coach.unit1"; "unitNxliff:entry.coach.unitN")
```














<!--  setLBItemsOrderBy($propertyPath : Text; $descending : Boolean) *********************   -->
## .setLBItemsOrderBy()

### .setLBItemsOrderBy(propertyPath : Text; descending : Boolean)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| propertyPath  | Text  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | Text value indicating specific attribute |
| descending  | Boolean  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | Boolean value indicating whether the sort order should be descending |

#### Description

The `setLBItemsOrderBy()` function is used to define the ordering criteria for the list box (or table) items, allowing them to be sorted based on a specific property.

This function is a flexible way to control the sorting of data within a list box or table. It allows sorting based on any property of the data model, and the order (ascending or descending) can be specified for each column. 

This function ensures that data is presented in a structured and user-defined manner.


#### Exemple

```4d
$entry.setLBItemsOrderBy("lastName")
$entry.setLBItemsOrderBy("firstName")
```








<!--   setPanel($panelName : Text; $currentPage : Integer) *********************   -->
## .setPanel()

### .setPanel(panelName : Text; currentPage : Integer)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| panelName  | Text  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | Text parameter representing the name of the panel to be set. |
| currentPage  | Integer  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | Integer that specifies the current page of the panel |

#### Description

The `setPanel()` function is used to set the properties of a `panel` object within an entry. It assigns the panel's name and optionally its current page if specified.

This function ensures that the panel being set exists within the current form's list of elements and updates the `panel` object with its `name` and, optionally, the `currentPage`. If the panel does not exist, the user is informed through an alert message.

This functionality is useful for managing dynamic user interfaces and navigating between different panels of a form.
#### Exemple
```4d	
$entry.setPanel("panel_person"; 2)
```
















<!--   setPanelPage($pageNum : Integer; $pict : Text) *********************   -->
## .setPanelPage()

### .setPanelPage(pageNum : Integer; pict : Text)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| pageNum  | Integer  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | Integer that specifies the number of the page to be set. |
| pict  | Text  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | Text that represents an image associated with the page |

#### Description

The `setPanelPage()` function is designed to add a new page configuration to the `pages` collection of a `panel` object.

This function is used to dynamically add page entries to a panel’s `pages` collection. Each page can have a specific page number and an associated image. This enables complex panel configurations where different pages can be set up with corresponding images or icons, enhancing user navigation and visual cues in the interface.

#### Exemple
```4d
$entry.setPanelPage(2; "appointments-32x32.png")
$entry.setPanelPage(1; "address-32x32.png")	
```















<!--   setSearchboxField($attribute : Text;  ...  : Variant) *********************   -->
## .setSearchboxField()

### .setSearchboxField(attribute : Text; {params : Variant})

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| attribute  | Text  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | Text representing the name of the attribute or field to be added to the searchbox configuration |
| params  | Variant  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | Variant parameter that customizes the field's behavior |

#### Description

The `setSearchboxField()` function is used to add a search field to an entry object's searchbox configuration. This function allows the entry to have specific fields that can be searched through a user interface, enhancing the search capabilities of an application or system.

The function takes an `attribute` parameter, which specifies the data field to be searchable, and additional optional parameters that customize the field's behavior, such as setting a placeholder text. 

> Internally, the function creates an object representing the search field and iterates over any extra parameters, parsing them into key-value pairs to apply specific configurations. For example, a parameter formatted as `"placeholder:city"` sets a user-friendly hint to guide input. <br><br> The configured field is then added to the `fields` collection in the searchbox object, making it available for user searches. <br><br>This approach enhances the search functionality's flexibility and improves user experience by offering clear input guidance. 

The ``setSearchboxField()``'s design allows it to be extended to other field properties if required, making it a handy tool for creating dynamic, user-centric search capabilities in applications.


#### Exemple
```4d	
$entry:=cs.sfw_definitionEntry.new("customer"; "customer"; "Customers")
$entry.setSearchboxField("firstName")
$entry.setSearchboxField("lastName")
$entry.setSearchboxField("contactDetails.addresses[].detail.city"; "placeholder:city")
```




























<!--   setSearchboxSpecific($tag : Text;  ...  : Variant) *********************   -->
## .setSearchboxSpecific()

### .setSearchboxSpecific(tag : Text; {params : Variant})

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| tag  | Text  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | Text that represents the identifier or label for the specific search criterion.  |
| params  | Variant  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | Variant parameter that allows the function to accept multiple key-value pairs formatted as strings |

#### Description

The `setSearchboxSpecific()` function is designed to add a custom search criterion to an entry's searchbox configuration, enhancing its ability to handle targeted and complex searches. 

This function accepts a `tag`, which serves as the identifier for the specific search, and additional optional parameters formatted as key-value pairs.
These pairs allow customization of properties such as `queryString`, `formula`, `collectionBuilder`, and `inCollection`.


#### Exemple

```4d	
$entry:=cs.sfw_definitionEntry.new("customer"; "customer"; "Customers")

$entry.setSearchboxField("firstName")
$entry.setSearchboxField("lastName")
$entry.setSearchboxField("contactDetails.addresses[].detail.city"; "placeholder:city")

$entry.setSearchboxSpecific("withAppointment"; "queryString:appointments # null")
$entry.setSearchboxSpecific("withoutAppointment"; "queryString:appointments = null")
$entry.setSearchboxSpecific("withLessons"; "queryString:privateLessons # null")
$entry.setSearchboxSpecific("withLessons2"; "queryString:privateLessons # null and idStatus = 0")
$entry.setSearchboxSpecific("withoutLessons"; "queryString:privateLessons = null")
$entry.setSearchboxSpecific("appointmentToday"; "formula:Person_appointment_today")
$entry.setSearchboxSpecific("appointmentTodayInColl"; "collectionBuilder:collPerson:=Person_appointment_today_coll"; "inCollection:UUID in :collPerson")
```
These examples demonstrate how the `setSearchboxSpecific()` function can be used to configure tailored searches by using `queryString`, `formula`, `collectionBuilder`, and `inCollection` properties. This level of customization allows for precise filtering and searching of data based on specific criteria, enhancing the functionality of the searchbox and providing users with refined search capabilities.











<!--   setValidationRule(field : Text; widget : Text; {params : Text}) *********************   -->
## .setValidationRule()

#### .setValidationRule(field : Text; widget : Text; {params : Text})

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| field  | Text  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | Text that sets the name of the field to which the validation rule is applied. |
| widget  | Text  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | Text that sets the widget associated with the field. |
| params  | Text  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | rules passed as key-value pairs, allowing for further customization. |



#### Description

The `setValidationRule` function is used to configure validation rules for fields within an entry or form. 
These rules can ensure that the user input meets specific criteria:
   - **`mandatory`**: Specifies that the field is required and cannot be left empty.
  - **`trimSpace`**: Indicates that any leading or trailing spaces should be removed from the input.
  - **`capitalize`**: Ensures the first letter of the input is capitalized.
  - **`uppercase`**: Converts all characters in the input to uppercase.

This functionality allows for improved input validation and user data consistency in an application.

#### Exemple
```4D
$entry.setValidationRule("firstName"; "entryFiled_firstName"; "mandatory"; "trimSpace"; "capitalize")
$entry.setValidationRule("lastName"; "entryFiled_lastName"; "mandatory"; "trimSpace"; "uppercase")
```





<!--   setVirtual(type : Text) *********************   -->
## .setVirtual()

#### .setVirtual(type : Text)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| type  | Text  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | Text that specifies the type of virtual object to assign to the entity |

#### Description

The `setVirtual` function is used to define the type of virtual object for an entry. 
In this case, the function specifically sets the entry's `virtual` property to a particular type, such as "collection", and adjusts the structure of the associated items accordingly.

#### Exemple
```4d
$entry.setVirtual("collection")
```






<!--   setVirtualItem(item : cs.sfw_definitionVirtualItem) *********************   -->
## .setVirtualItem()

#### .setVirtualItem(item : cs.sfw_definitionVirtualItem)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| item  | cs.sfw_definitionVirtualItem  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | An instance of the sfw_definitionVirtualItem class to be added to the virtual items collection. |

#### Description

The ``setVirtualItem()`` function is used to add a virtual entry item to a collection of items. 

The function takes an object of type ``sfw_definitionVirtualItem`` as an argument and adds it to the items collection of the current object. This allows the item to be part of the virtual entries managed by the system, enabling the display or interaction with the data as part of a larger structure or process.


#### Exemple
```4d
$entry:=cs.sfw_definitionEntry.new("heathdashboard"; "health"; "Dashboards")
$item := cs.sfw_definitionVirtualItem.new("onYearOfAppointments (arrays)", "hdb_oneYearOfAppointmentsArray")
$item.setXliffLabel("healthdasboard.title.oneYearOfAppointmets")
$item.setItemAction("demo", "zzzz")
$entry.setVirtualItem($item)

```













<!--   setWizard(panel : Text) *********************   -->
## .setWizard()

#### .setWizard(panel : Text)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| panel  | Text  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | Text that sets the name or identifier of the panel that will be set for the wizard. |

#### Description

The `setWizard` function is used to configure a wizard panel for a user interface. 
The function ensures that the current `wizard` object is properly initialized and associates it with a specified panel. 

This allows the application to manage and present the steps involved in a wizard-like interface, such as creating or managing an appointment, a task, or another process.

#### Exemple
```4d
$entry.setWizard("wizard_newAppointment")
```















<!--   setXliffLabel($xliff : Text *********************   -->
## .setXliffLabel()

#### .setXliffLabel(xliff : Text)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| xliff  | Text  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | Text value that assigns an XLIFF key, enabling localization of the component's label |

#### Description

The `setXliffLabel()` is a fonction designed to assign a value to the `xliff` property of the class instance. It takes one parameter `xliff`.

This function enables the component to associate with a specific translation key, allowing the label to be dynamically adapted based on the application's active language setting.

This fonction is particularly useful for applications that support multiple languages, as it facilitates seamless integration with external localization files. For example, calling `.setXliffLabel("entry.customers")` sets the `xliff` property to `"entry.customers"`, linking the component to the corresponding translation entry in the localization system. This allows the component to display the appropriate label based on the user’s language preference.

The `setXliffLabel()` function is essential for creating adaptable, user-friendly interfaces that can cater to diverse audiences by presenting content in their native languages.


#### Exemple
```4d
$entry:=cs.sfw_definitionEntry.new("customer"; "customer"; "Customers")
$entry.setXliffLabel("entry.customers")
```






