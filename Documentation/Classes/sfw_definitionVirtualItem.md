<!-- Type your summary here -->
## sfw_definitionVirtualItem

The ``sfw_definitionVirtualItem`` class is designed to manage and represent virtual entry items within a user interface or data structure.

### Summary

| |
| -------- |
|[.new(name : Text; panel : Text)](#-new-) <br> creates and initializes a new instance of the class.|
|[.setItemAction(label : Text; method : Text; {params : Text})](#-setItemAction-) <br> defines and configures an action within an object .|
|[.setXliffLabel(xliff : Text)](#-setxlifflabel-) <br> assigns a value to the `xliff` property of the class instance.|


<!--   new() *********************   -->
## .new()

### .new(name : Text; panel : Text)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| name  | Text  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | Text that sets a textual identifier for the entry item |
| panel  | Text  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | Text that sets the name of the associated panel.  |


#### Description

The **`new()`** function It is responsible for initializing a new instance of the class, setting the **`name`** property, which uniquely identifies the virtual entry item. Additionally, the function initializes the **`panel`** property, associating the virtual entry item with a specific **`panel`**.

#### Exemple
```4d
$item:=cs.sfw_definitionVirtualItem.new("onYearOfAppointments (arrays)"; "hdb_oneYearOfAppointmentsArray")
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
$item.setItemAction("Exporter vers Excel"; "exportViewProToXLS"; "xliff:ExporXLS")
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

This fonction is particularly useful for applications that support multiple languages, as it facilitates seamless integration with external localization files. For example, calling `.setXliffLabel("healthdasboard.title.oneYearOfAppointmets")` sets the `xliff` property to `"healthdasboard.title.oneYearOfAppointmets"`, linking the component to the corresponding translation entry in the localization system. This allows the component to display the appropriate label based on the user’s language preference.

The `setXliffLabel()` function is essential for creating adaptable, user-friendly interfaces that can cater to diverse audiences by presenting content in their native languages.


#### Exemple
```4d
$item.setXliffLabel("healthdasboard.title.oneYearOfAppointmets")
```

