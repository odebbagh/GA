# sfw_definitionView

The `sfw_definitionView` class is designed to manage the configuration and behavior of views within an application. This class allows for the dynamic setup of list box items, hierarchical list items, and various display settings.

### Usage Example

This class allows you to describe a view with various configurations such as list box columns, order by settings, meta expressions, and counters. Here is an example of how to use this class:

```4d
$view:=cs.sfw_definitionView.new("view1"; "Project View")
$view.setLBItemsColumn("name"; "Name"; "width:200"; "headerLeft")
$view.setLBItemsColumn("customer.name"; "Customer"; "width:150"; "headerCenter")
$view.setLBItemsOrderBy("name"; False)
$view.setLBItemsMetaExpression("metaExpression")
$view.setLBItemsCounter("###,###,##0 ^1;;"; "unit1:project"; "unitN:projects")
$view.setSubset("subsetFunction"; "param1"; "param2")
$view.setDisplayType("listbox")
$view.setPictoLabel("/RESOURCES/sfw/image/picto/custom.png")
$view.setHLItemsFirstLevelGroupBy("groupAttribute")
$view.setHLItemsLine("lineAttribute")
```

### Summary

| |
| -------- |
|[.new(ident : Text; label : Text)](#-new-) <br> Creates a new view with the specified identifier and label. |
|[.setDisplayType(type : Text)](#-setdisplaytype-) <br> Sets the display type for the view. |
|[.setHLItemsFirstLevelGroupBy(attribute : Text)](#-sethlitemsfirstlevelgroupby-) <br> Sets the first level group by attribute for hierarchical list items. |
|[.setHLItemsLine(attribute : Text)](#-sethlitemsline-) <br> Sets the line attribute for hierarchical list items. |
|[.setLBItemsColumn(attribute : Text; label : Text; ... : Text)](#-setlbitemscolumn-) <br> Adds a column to the list box with the specified attribute, label, and optional parameters. |
|[.setLBItemsCounter(format : Text; ... : Text)](#-setlbitemscounter-) <br> Sets the counter format and units for the list box items. |
|[.setLBItemsMetaExpression(metaExpression : Text)](#-setlbitemsmetaexpression-) <br> Sets the meta expression for the list box items. |
|[.setLBItemsOrderBy(propertyPath : Text; descending : Boolean)](#-setlbitemsorderby-) <br> Sets the order by property for the list box items. |
|[.setPictoLabel(pictopath : Text)](#-setpictolabel-) <br> Sets the pictogram label for the view. |
|[.setSubset(functionName : Text; ... : Variant)](#-setsubset-) <br> Sets the subset function and parameters for the view. |

<!--   new() *********************   -->
## .new()

### .new(ident : Text; label : Text)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| ident  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The identifier for the view |
| label  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The label for the view |
| result  | Object  | <img src="DocImages/arrowLeft.png"  height="25" align="center" /> | Creates a new view with the specified identifier and label |

#### Description

The `.new()` function creates a new view with the specified identifier and label. This function initializes the view with default values.

#### Example
```4d
$view:=cs.sfw_definitionView.new("view1"; "Project View")
```

<!--   setDisplayType() *********************   -->
## .setDisplayType()

### .setDisplayType(type : Text)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| type  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The display type for the view |
| result  | None  | <img src="DocImages/arrowLeft.png"  height="25" align="center" /> | Sets the display type for the view |

#### Description

The `.setDisplayType()` function sets the display type for the view. This function allows for the configuration of the view's display type, such as `listbox` or `hierarchical`.

#### Example
```4d
$view.setDisplayType("listbox")
```

<!--   setHLItemsFirstLevelGroupBy() *********************   -->
## .setHLItemsFirstLevelGroupBy()

### .setHLItemsFirstLevelGroupBy(attribute : Text)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| attribute  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The attribute for the first level group by |
| result  | None  | <img src="DocImages/arrowLeft.png"  height="25" align="center" /> | Sets the first level group by attribute for hierarchical list items |

#### Description

The `.setHLItemsFirstLevelGroupBy()` function sets the first level group by attribute for hierarchical list items. This function allows for the configuration of the attribute used to group items at the first level.

#### Example
```4d
$view.setHLItemsFirstLevelGroupBy("groupAttribute")
```

<!--   setHLItemsLine() *********************   -->
## .setHLItemsLine()

### .setHLItemsLine(attribute : Text)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| attribute  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The attribute for the line |
| result  | None  | <img src="DocImages/arrowLeft.png"  height="25" align="center" /> | Sets the line attribute for hierarchical list items |

#### Description

The `.setHLItemsLine()` function sets the line attribute for hierarchical list items. This function allows for the configuration of the attribute used to define the line items in a hierarchical list.

#### Example
```4d
$view.setHLItemsLine("lineAttribute")
```

<!--   setLBItemsColumn() *********************   -->
## .setLBItemsColumn()

### .setLBItemsColumn(attribute : Text; label : Text; ... : Text)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| attribute  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The attribute for the column |
| label  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The label for the column |
| ...  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | Optional parameters for the column |
| result  | None  | <img src="DocImages/arrowLeft.png"  height="25" align="center" /> | Adds a column to the list box with the specified attribute, label, and optional parameters |

#### Description

The `.setLBItemsColumn()` function adds a column to the list box with the specified attribute, label, and optional parameters. This function allows for the dynamic configuration of columns, including type, width, order by formula, header alignment, and format.

#### Optional Parameters
- `alignment`: Specifies the alignment of the column (`left`, `right`, `center`, `default`).
- `columnName`: Specifies the name of the column.
- `format`: Specifies the format for the column.
- `group`: Specifies the group for the column.
- `headerAlignment`: Specifies the alignment of the header (`headerLeft`, `headerRight`, `headerCenter`, `headerDefault`).
- `headerStroke`: Specifies the stroke for the header.
- `orderByFormula`: Specifies the formula for ordering the column.
- `type`: Specifies the type of the column.
- `width`: Specifies the width of the column.
- `xliff`: Specifies the xliff for the column.

#### Example
```4d
$view.setLBItemsColumn("name"; "Name"; "width:200"; "headerLeft")
```

<!--   setLBItemsCounter() *********************   -->
## .setLBItemsCounter()

### .setLBItemsCounter(format : Text; ... : Text)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| format  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The format for the counter |
| ...  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | Optional parameters for the counter |
| result  | None  | <img src="DocImages/arrowLeft.png"  height="25" align="center" /> | Sets the counter format and units for the list box items |

#### Description

The `.setLBItemsCounter()` function sets the counter format and units for the list box items. This function allows for the configuration of the format and units for displaying item counts.

#### Optional Parameters
- `unit1`: Specifies the singular unit for the counter.
- `unit1xliff`: Specifies the xliff for the singular unit.
- `unitN`: Specifies the plural unit for the counter.
- `unitNxliff`: Specifies the xliff for the plural unit.

#### Example
```4d
$view.setLBItemsCounter("###,###,##0 ^1;;"; "unit1:project"; "unitN:projects")
```

<!--   setLBItemsMetaExpression() *********************   -->
## .setLBItemsMetaExpression()

### .setLBItemsMetaExpression(metaExpression : Text)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| metaExpression  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The meta expression for the list box items |
| result  | None  | <img src="DocImages/arrowLeft.png"  height="25" align="center" /> | Sets the meta expression for the list box items |

#### Description

The `.setLBItemsMetaExpression()` function sets the meta expression for the list box items. This function allows for the configuration of a meta expression that can be used for additional processing or display logic.

#### Example
```4d
$view.setLBItemsMetaExpression("metaExpression")
```

<!--   setLBItemsOrderBy() *********************   -->
## .setLBItemsOrderBy()

### .setLBItemsOrderBy(propertyPath : Text; descending : Boolean)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| propertyPath  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The property path for ordering |
| descending  | Boolean  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | Whether the order is descending |
| result  | None  | <img src="DocImages/arrowLeft.png"  height="25" align="center" /> | Sets the order by property for the list box items |

#### Description

The `.setLBItemsOrderBy()` function sets the order by property for the list box items. This function allows for the configuration of the property path and whether the order is descending.

#### Example
```4d
$view.setLBItemsOrderBy("name"; False)
```

<!--   setPictoLabel() *********************   -->
## .setPictoLabel()

### .setPictoLabel(pictopath : Text)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| pictopath  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The path to the pictogram label |
| result  | None  | <img src="DocImages/arrowLeft.png"  height="25" align="center" /> | Sets the pictogram label for the view |

#### Description

The `.setPictoLabel()` function sets the pictogram label for the view. This function allows for the configuration of a custom pictogram to represent the view.

#### Example
```4d
$view.setPictoLabel("/RESOURCES/sfw/image/picto/custom.png")
```

<!--   setSubset() *********************   -->
## .setSubset()

### .setSubset(functionName : Text; ... : Variant)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| functionName  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The name of the subset function |
| ...  | Variant  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | Optional parameters for the subset function |
| result  | None  | <img src="DocImages/arrowLeft.png"  height="25" align="center" /> | Sets the subset function and parameters for the view |

#### Description

The `.setSubset()` function sets the subset function and parameters for the view. This function allows for the configuration of a subset function that can be used to filter or process the view's data.

#### Example
```4d
$view.setSubset("subsetFunction"; "param1"; "param2")
```