# sfw_definitionPageListbox

The `sfw_definitionPageListbox` class is designed to manage the configuration and behavior of list boxes within an application. This class allows for the dynamic setup of data sources, columns, and actions associated with list boxes.

### Usage Example

This class allows you to describe a page where a list box will take up all the available space. The list box will be dynamically added to the definition of a standard form used as a panel for displaying record data. It is possible to have multiple pages of this type for the same panel. The resulting object of this class must be added to a panel using the `setPanelDynamicPage` function. Here is an example:

```4d
$entry.setPanel("panel_ProjectStatus"; 1)
$pageListbox:=cs.sfw_definitionPageListbox.new("lb_projects")
$pageListbox.setDatasource("Form.current_item.projects")
$pageListbox.addColumn("This.name"; "width:300"; "headerLabel:Contract name")
$pageListbox.addColumn("This.customer.name"; "width:200"; "headerLabel:Customer")
$pageListbox.addColumn("This.company.name"; "width:200"; "headerLabel:Company")
$pageListbox.addPredefinedAction("openInWindow"; "projectManagment"; "project")
$pageListbox.addPredefinedAction("OpenAProjection"; "projectManagment"; "project")
$pageListbox.addPredefinedAction("splitLine")
$pageListbox.addSpecificAction("contractAction"; "That's a test action"; Formula(cs.sfw_dialog.me.alert("Hello")); Formula(Random%2=0); "needAnEntity")
$pageListbox.addPredefinedAction("export")
$entry.setPanelDynamicPage(1; "project-32x32.png"; "Projects"; $pageListbox)
```

### Summary

| |
| -------- |
|[.addColumn(expression : Text; ... : Text)](#-addcolumn-) <br> Adds a column to the list box with the specified expression and optional parameters. |
|[.addPredefinedAction(type : Text; visionIdent : Text; entryIdent : Text)](#-addpredefinedaction-) <br> Adds a predefined action to the list box. |
|[.addSpecificAction(ident : Text; label : Text; formulaToCall : 4D.Function; formulaToActivate : 4D.Function; ... : Text)](#-addspecificaction-) <br> Adds a specific action to the list box with the specified parameters. |
|[.setDatasource(datasource : Text)](#-setdatasource-) <br> Sets the data source for the list box. |

<!--   addColumn() *********************   -->
## .addColumn()

### .addColumn(expression : Text; ... : Text)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| expression  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The expression for the column |
| ...  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | Optional parameters for the column |
| result  | None  | <img src="DocImages/arrowLeft.png"  height="25" align="center" /> | Adds a column to the list box with the specified expression and optional parameters |

#### Description

The `.addColumn()` function adds a column to the list box with the specified expression and optional parameters. This function allows for the dynamic configuration of columns, including width, header label, number format, and whether an entity needs to be selected for the column to be active.

#### Optional Parameters
- `needAnEntity`: When this parameter is passed, the action is only active if an entity is selected in the list box.

#### Example
```4d
cs.sfw_definitionPageListbox.me.addColumn("Name"; "width:100"; "headerLabel:Full Name"; "needAnEntity:True")
```

<!--   addPredefinedAction() *********************   -->
## .addPredefinedAction()

### .addPredefinedAction(type : Text; visionIdent : Text; entryIdent : Text)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| type  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The type of the predefined action |
| visionIdent  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The vision identifier for the action |
| entryIdent  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The entry identifier for the action |
| result  | None  | <img src="DocImages/arrowLeft.png"  height="25" align="center" /> | Adds a predefined action to the list box |

#### Description

The `.addPredefinedAction()` function adds a predefined action to the list box. This function allows for the configuration of actions that are predefined and associated with specific vision and entry identifiers.

#### Possible Types
- `openInWindow`
- `openAProjection`
- `export`

#### Example
```4d
cs.sfw_definitionPageListbox.me.addPredefinedAction("openInWindow"; "vision1"; "entry1")
```

<!--   addSpecificAction() *********************   -->
## .addSpecificAction()

### .addSpecificAction(ident : Text; label : Text; formulaToCall : 4D.Function; formulaToActivate : 4D.Function; ... : Text)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| ident  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The identifier for the specific action |
| label  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The label for the specific action |
| formulaToCall  | 4D.Function  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The formula to call for the specific action |
| formulaToActivate  | 4D.Function  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The formula to activate for the specific action |
| ...  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | Optional parameters for the specific action |
| result  | None  | <img src="DocImages/arrowLeft.png"  height="25" align="center" /> | Adds a specific action to the list box with the specified parameters |

#### Description

The `.addSpecificAction()` function adds a specific action to the list box with the specified parameters. This function allows for the configuration of custom actions, including the identifier, label, and formulas to call and activate.

#### Example
```4d
cs.sfw_definitionPageListbox.me.addSpecificAction("delete"; "Delete"; Formula(deleteAction); Formula(activateDelete))
```

<!--   setDatasource() *********************   -->
## .setDatasource()

### .setDatasource(datasource : Text)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| datasource  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The data source for the list box |
| result  | None  | <img src="DocImages/arrowLeft.png"  height="25" align="center" /> | Sets the data source for the list box |

#### Description

The `.setDatasource()` function sets the data source for the list box. This function allows for the dynamic configuration of the data source from which the list box will retrieve its data.

#### Example
```4d
cs.sfw_definitionPageListbox.me.setDatasource("EmployeeData")
```


