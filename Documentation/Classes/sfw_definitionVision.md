<!-- Type your summary here -->
## sfw_definitionVision

The **``sfw_definitionVision``** class is designed to manage the visual components of an application with properties that allow easy identification, labeling, localization and customization of the appearance of user interface elements, particularly toolbars. 
This class is ideal for creating UI components that require both visual customization and localization support to meet diverse user needs.
### Summary

| |
| -------- |
|[.new(ident : Text; label : Text)](#-new-) <br> creates and initializes a new instance of the class.|
|[.setDisplayOrder(order : Integer)](#-setdisplayorder-) <br> defines the order in which an item should be displayed relative to other items.|
|[.setFocusRingColor(color : Text)](#-setfocusringcolor-) <br> customizes the appearance of the focus ring. |
|[.setToolbarBackgroundColor(color : Text)](#-settoolbarbackgroundcolor-) <br> customizes the background color of the toolbar associated.|
|[.setXliffLabel(xliff : Text)](#-setxlifflabel-) <br> assigns a value to the `xliff` property of the class instance. |


<!--   new() *********************   -->
## .new()

#### .new(ident : Text; label : Text)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| ident  | Text  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | Text that sets a unique identifier for the instance. |
| label  | Text  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | Text that sets a descriptive label.  |


#### Description

The ``.new()`` function in the `sfw_definitionVision` class is a constructor designed to create and initialize a new instance of the class. It takes two parameters: `ident` and `label`. 

- The `ident` parameter is used as a unique identifier for the instance, allowing it to be easily distinguished from other components within the application. 
- The `label` parameter serves as the display name or a descriptive reference for the component.

 When the `new()` function is called, it sets the **`ident`** property to the provided ident value and the **`label`** property to the label value. 

Additionally, it initializes the `xliff` property as an empty string (`""`). The `toolbar` property is also initialized as an object with a default `color` property set to `"#E0E0E0"`, providing a base styling for the toolbar component. 

#### Exemple
```4d
$vision:=cs.sfw_definitionVision.new("customer"; "Customer") // {ident:customer,label:Customer,xliff:,toolbar:{color:#E0E0E0}}
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

















<!--   .setFocusRingColor(color : Text) *********************   -->
## .setFocusRingColor()

#### .setFocusRingColor(color : Text)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| color  | Text  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | Text that sets the color of the focus ring |

#### Description

The ``setFocusRingColor()`` function is used to customize the appearance of the focus ring for the toolbar component. It is useful for customizing the appearance of the focus ring around input elements, such as a search bar.

This method takes one parameter, `color`, which specifies the color to be applied to the focus ring 
> The focus ring is a visual indicator that highlights the currently focused element, enhancing accessibility by making it easier for users to identify the active component, especially when navigating with a keyboard or other assistive devices.

#### Exemple
```4d
$vision:=cs.sfw_definitionVision.new("customer"; "Customer")  // {ident:customer,label:Customer,xliff:,toolbar:{color:#E0E0E0}}
$vision.setFocusRingColor("navy")                  //  {ident:customer,label:Customer,xliff:,toolbar:{color:#E0E0E0,focusRing:navy}}
```
































<!--   .setFocusRingColor(color : Text) *********************   -->
## .setToolbarBackgroundColor()

#### .setToolbarBackgroundColor(color : Text)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| color  | Text  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | Text value that sets the background color of the toolbar associated |

#### Description
The `.setToolbarBackgroundColor()` function is used to customize the background color of the toolbar associated.

This function takes a single parameter, `color`, which represents the color value to be applied to the toolbar. The color should be provided as a valid color code, such as a hexadecimal code (`"#52ABD8"`) or a recognized color name (`"Red"`). 

When this function is called, it updates the `color` property of the `toolbar` object within the `sfw_definitionVision` instance to the specified color value.

#### Exemple
```4d
$vision:=cs.sfw_definitionVision.new("customer"; "Customer")   // {ident:customer,label:Customer,xliff:,toolbar:{color:#E0E0E0}}
$vision.setToolbarBackgroundColor("#52ABD8")        // {ident:customer,label:Customer,xliff:,toolbar:{color:#52ABD8}}
```
























<!--   .setFocusRingColor(color : Text) *********************   -->
## .setXliffLabel()


#### .setXliffLabel(xliff : Text)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| xliff  | Text  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | Text value that assigns an XLIFF key, enabling localization of the component's label |

#### Description

The `setXliffLabel()` is a fonction designed to assign a value to the `xliff` property of the class instance. It takes one parameter `xliff`.

This function enables the component to associate with a specific translation key, allowing the label to be dynamically adapted based on the application's active language setting.

This fonction is particularly useful for applications that support multiple languages, as it facilitates seamless integration with external localization files. For example, calling `.setXliffLabel("vision.customer")` sets the `xliff` property to `"vision.customer"`, linking the component to the corresponding translation entry in the localization system. This allows the component to display the appropriate label based on the user’s language preference.

The `setXliffLabel()` function is essential for creating adaptable, user-friendly interfaces that can cater to diverse audiences by presenting content in their native languages.


#### Exemple
```4d
$vision:=cs.sfw_definitionVision.new("customer"; "Customer")
$vision.setXliffLabel("vision.customer")
```